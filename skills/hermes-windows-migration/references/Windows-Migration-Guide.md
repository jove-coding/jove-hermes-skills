# Hermes Agent Windows Data Migration Guide

> **Move Hermes Agent data from `%LOCALAPPDATA%\hermes` (C: drive) to a custom path (e.g., D: drive, E: drive, etc.) — a complete walkthrough.**
>
> Version: v1.0.1 | Platform: Windows 10/11 (Native Install) | 2026-06-14

---

## Table of Contents

- [1. Background & Motivation](#1-background--motivation)
- [2. Core Concept: Program Files vs Data Files](#2-core-concept-program-files-vs-data-files)
- [3. Preparation](#3-preparation)
- [4. Step 1: Copy Data Files](#4-step-1-copy-data-files)
- [5. Step 2: Set the HERMES_HOME Environment Variable](#5-step-2-set-the-hermes_home-environment-variable)
- [6. Step 3: Restart the Gateway](#6-step-3-restart-the-gateway)
- [7. Step 4: Clean Up the Old Directory (Optional)](#7-step-4-clean-up-the-old-directory-optional)
- [8. Migration Verification Checklist](#8-migration-verification-checklist)
- [9. Common Pitfalls & Troubleshooting](#9-common-pitfalls--troubleshooting)
- [10. Rollback Plan](#10-rollback-plan)
- [11. Appendix: Directory Structure Reference](#11-appendix-directory-structure-reference)
- [12. Appendix: Quick Command Reference](#12-appendix-quick-command-reference)

---

## 1. Background & Motivation

### 1.1 Why Migrate?

| Scenario | Description |
|----------|-------------|
| **C: drive running out of space** | Hermes accumulates data (sessions, cache, databases, etc.) at `%LOCALAPPDATA%\hermes`, often reaching **1 GB+** |
| **More space available on another drive** | Move data to a larger disk to free up the C: drive |
| **Preserve data across OS reinstalls** | Separating data from the program means you only need to save the data directory; the program can be re-installed |
| **Multi-machine data sharing** | Put data on a NAS or synced folder for potential multi-machine access |

### 1.2 When This Applies

- ✅ **Windows native install** (Hermes Desktop installed via PowerShell)
- ❌ **WSL2 install** (`~/.hermes` on the Linux filesystem — use the Linux/macOS migration approach instead)
- ❌ Does **not** apply to Linux/macOS (though the concept is transferable)

---

## 2. Core Concept: Program Files vs Data Files

This is the most important — and most commonly confused — concept in the whole migration.

### Default Installation Layout

A Windows native install puts everything under `%LOCALAPPDATA%\hermes` (i.e., `C:\Users\<username>\AppData\Local\hermes`).

### Two Categories of Files

| Category | Contents | Example Paths | Migrate? |
|----------|----------|--------------|:--------:|
| **Program files** | Hermes binaries, venv, Git toolchain, Node.js, desktop app | `hermes-agent/` `git/` `bin/` `hermes-setup.exe` | ❌ Leave in place |
| **Data files** | Config, secrets, skills, sessions, memories, caches, databases, etc. | `config.yaml` `.env` `profiles/` `sessions/` `skills/` `memories/` `cron/` `cache/` `state.db` etc. | ✅ Migrate |

### What is HERMES_HOME?

Hermes uses the `HERMES_HOME` environment variable to locate its data directory. By default, it uses the program directory. Once `HERMES_HOME` is set, Hermes reads and writes configuration, sessions, memories, etc. to the path specified by the variable.

```
Before:
  %LOCALAPPDATA%\hermes\          ← Program and data mixed together
    ├── hermes-agent/              ← Program files
    ├── config.yaml                ← Data files
    ├── profiles/                  ← Data files
    └── sessions/                  ← Data files

After:
  %LOCALAPPDATA%\hermes\           ← Program files only
    ├── hermes-agent/              ← Program files
    └── git/                       ← Program toolchain

  %HERMES_HOME%\                   ← Your new data directory (custom path)
    ├── config.yaml                ← Data files ✓
    ├── profiles/                  ← Data files ✓
    └── sessions/                  ← Data files ✓
```

---

## 3. Preparation

### 3.1 Checklist

- [ ] Confirm the target disk has enough space (recommend **2 GB+**)
- [ ] Close Hermes Desktop (if running)
- [ ] Back up the old data (optional but recommended — copy, don't move)
- [ ] Record the current gateway state (optional, for comparison after migration)

### 3.2 Record Baseline State

Open **Git-Bash** (not PowerShell) and run:

```bash
# Check if HERMES_HOME is already set
echo $HERMES_HOME

# Check the old directory size
du -sh "${LOCALAPPDATA//\\//}/hermes"

# Check gateway status
hermes gateway status

# Check platform connections (if using gateway)
cat "${LOCALAPPDATA//\\//}/hermes/profiles/<your-profile>/gateway_state.json" 2>/dev/null
```

> **⚠️ PowerShell Execution Policy**: If you get _"running scripts is disabled on this system"_, run:
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1
> ```
>
> **Going forward**, wherever you see `<target-directory>`, replace it with your actual target path (e.g., `D:\HermesData`).  
> Wherever you see `<your-profile>`, replace it with your profile name (e.g., `default`, `rina`).

---

## 4. Step 1: Copy Data Files

### 4.1 Source and Target

| Item | Value |
|------|-------|
| **Source** (old) | `%LOCALAPPDATA%\hermes` |
| **Target** (new) | Your desired location, e.g., `D:\HermesData`, `E:\hermes-data` |

> **Recommendation**: Avoid spaces and non-ASCII characters in the target path to reduce potential compatibility issues.

### 4.2 Execute the Copy

**Method A: robocopy (recommended)**

Open **PowerShell** (no admin required) and run:

```powershell
# Replace <target-directory> with your actual target path
$src = "$env:LOCALAPPDATA\hermes"
$dst = "<target-directory>"

robocopy $src $dst /E /COPY:DAT /R:2 /W:3 /NP /NDL
```

| robocopy flag | Meaning |
|---------------|---------|
| `/E` | Copy subdirectories, including empty ones |
| `/COPY:DAT` | Copy data, attributes, timestamps |
| `/R:2` | Retry 2 times on failure |
| `/W:3` | Wait 3 seconds between retries |
| `/NP` | No progress percentage (cleaner output) |
| `/NDL` | No directory logging (less noise) |

**Why robocopy?**
- Handles long paths (>260 characters) correctly
- Supports resume on interruption
- Preserves file security attributes
- Built into Windows — no extra install needed

**Method B: File Explorer**

1. Open `C:\Users\<username>\AppData\Local\`
   - Tip: Type `%LOCALAPPDATA%` in the Explorer address bar to jump straight there
2. Right-click the `hermes` folder → **Copy**
3. Navigate to your target location → **Paste**
4. Note: If Hermes is running, some files may be locked and fail to copy

### 4.3 Locked Files to Expect

If Hermes Desktop or Gateway is running, the following files may be locked:

| File | Why locked |
|------|------------|
| `state.db` / `state.db-wal` / `state.db-shm` | SQLite database actively being written by Hermes |
| `profiles/<your-profile>/state.db*` | Same — profile-level state database |
| `gateway_state.json` | Written by the running Gateway |
| `gateway.lock` / `gateway.pid` | Gateway process locks |

**Solution**: Close Hermes Desktop before copying, or simply ignore these errors — the files will be recreated automatically when Gateway restarts.

---

## 5. Step 2: Set the HERMES_HOME Environment Variable

### 5.1 Set User-Level Variable

Open **PowerShell** (not Git-Bash, not cmd) and run:

```powershell
# Replace <target-directory> with your actual target path
[Environment]::SetEnvironmentVariable(
    'HERMES_HOME',
    '<target-directory>',
    'User'
)
```

> **Why User-level instead of Machine-level?**  
> A user-level variable is sufficient — no admin rights needed, and it won't affect other users on the same system.

### 5.2 Verify

**In a new PowerShell window** (existing windows don't pick up new env vars):

```powershell
echo $env:HERMES_HOME
```

**In Git-Bash** (after restarting it):

```bash
echo $HERMES_HOME
```

### 5.3 A Note About PATH

You do **not** need to modify PATH during migration. Here's why:

- The program binary (`hermes.exe`) still lives in the old install directory under `venv\Scripts\`
- `HERMES_HOME` tells Hermes **where to read and write data** — it's a separate concept from PATH
- PATH points to executables; HERMES_HOME points to your data

> ✅ **Simple rule**: PATH → programs, HERMES_HOME → data. We're moving data, not programs.

---

## 6. Step 3: Restart the Gateway

This is **the most critical step**. Copying data and setting the environment variable are just preparation — nothing changes until the Gateway restarts.

### 6.1 Why Restart?

```
After copying data + setting HERMES_HOME:
  Hermes Desktop (old install directory)
    │
    └─ Gateway (still running, reading old directory)
         ├─ Reads: old config.yaml         ❌
         ├─ Writes: old state.db           ❌
         └─ Platform connections: old path ❌

After restarting Gateway:
  Hermes Desktop (old install directory)
    │
    └─ Gateway (restarted, reading new directory)
         ├─ Reads: %HERMES_HOME%/config.yaml  ✅
         ├─ Writes: %HERMES_HOME%/state.db     ✅
         └─ Platform connections: new path    ✅
```

### 6.2 Option A: Full Desktop Restart (Recommended)

1. Fully exit Hermes Desktop (system tray → right-click → Quit)
2. Make sure all `Hermes.exe` processes are gone
3. Reopen Hermes Desktop

The Desktop app re-reads the environment variables and starts a fresh Gateway pointed at the new directory.

### 6.3 Option B: Kill + Restart Manually (Keep Desktop Running)

If you don't want to close the chat window:

```bash
# Step 1: Find the old gateway PID
ps aux | grep gateway

# Step 2: Check the gateway state file for the PID
cat "${LOCALAPPDATA//\\//}/hermes/profiles/<your-profile>/gateway_state.json"

# Step 3: Kill the old gateway
# ⚠️ In Git-Bash, do NOT use kill -9 — it doesn't work on Windows native processes
taskkill.exe //F //PID <old-gateway-PID>

# Step 4: Start the new gateway (use --accept-hooks to avoid permission popups)
hermes gateway run --accept-hooks &
```

> **Verify the new gateway started:**
> ```bash
> ps aux | grep gateway
> cat "${HERMES_HOME//\\//}/profiles/<your-profile>/gateway_state.json"
> ```

### 6.4 Verify Platform Connections

After the Gateway restarts, platform connections should recover automatically:

```bash
hermes gateway status
```

Expected output shows each platform with `"status": "connected"`:

```json
{
  "platforms": {
    "<platform-1>": {"status": "connected"},
    "<platform-2>": {"status": "connected"}
    // ... all configured platforms
  }
}
```

---

## 7. Step 4: Clean Up the Old Directory (Optional)

Once the new directory is confirmed working, you may clean up the migrated data from the old location.

### 7.1 Pre-Cleanup Confirmation

- [ ] Gateway is running from the new directory (verify with `hermes gateway status`)
- [ ] `state.db` in the new directory is being actively updated (check file modification time)
- [ ] All platform connections are healthy
- [ ] Sent at least one message through the new setup

### 7.2 What's Safe to Delete

Run these in **Git-Bash** from the **old** Hermes directory (`%LOCALAPPDATA%/hermes`):

```bash
cd "${LOCALAPPDATA//\\//}/hermes"

# Old gateway runtime lock files
rm -f gateway.lock gateway.pid gateway_state.json

# Old SQLite state databases
rm -f state.db state.db-shm state.db-wal
rm -f profiles/*/state.db profiles/*/state.db-shm profiles/*/state.db-wal

# Old runtime data
rm -f kanban.db kanban.db.init.lock
rm -f channel_directory.json
rm -f feishu_seen_message_ids.json

# Caches (Hermes will rebuild them automatically)
rm -rf cache/ bootstrap-cache/ audio_cache/ image_cache/

# Logs
rm -rf logs/

# Session/skill/memory backups (if you're sure the new directory is complete)
# ⚠️ Wait at least a week before deleting these
# rm -rf sessions/ skills/ memories/ cron/ profiles/ chats/
```

### 7.3 What to NEVER Delete

```bash
# ❌ Do NOT touch these — they are program files
# hermes-agent/    ← Hermes program binaries
# git/             ← Git toolchain
# bin/             ← Helper tools
# hermes-setup.exe ← Installer
```

### 7.4 Estimated Space Recovery

| Item | Estimated Size |
|------|:--------------:|
| State databases (state.db) | 5~50 MB |
| Cache files | 100~500 MB |
| Log files | 10~100 MB |
| Session/skill/memory backups | 10~50 MB |
| **Total** | **~0.1~1 GB** |

---

## 8. Migration Verification Checklist

### 8.1 Basic Configuration

| # | Check | How | Expected |
|:-:|-------|-----|----------|
| 1 | `HERMES_HOME` env var | `echo $HERMES_HOME` | Your target path (root directory, **not** `profiles/<name>`) |
| 2 | New directory exists | `ls -la $HERMES_HOME` | See config.yaml, profiles/, etc. |
| 3 | Config file readable | `cat "$HERMES_HOME/config.yaml"` | Contents display normally |

### 8.2 Gateway Status

| # | Check | How | Expected |
|:-:|-------|-----|----------|
| 4 | Gateway running | `hermes gateway status` | Shows running/active |
| 5 | Gateway PID matches | `cat "${HERMES_HOME//\\//}/profiles/<your-profile>/gateway_state.json"` | PID exists and is current |
| 6 | Platforms connected | `hermes gateway status` | Each platform shows connected |
| 7 | DB being written | `ls -la "${HERMES_HOME//\\//}/profiles/<your-profile>/state.db"` | Modification time is **now** |

### 8.3 Functional Tests

| # | Check | How | Expected |
|:-:|-------|-----|----------|
| 8 | Chat works | Send a message | Get a reply |
| 9 | Platform messaging works | Send a message on configured platforms | Get a reply |
| 10 | Skills load | `hermes skills` or use a skill | Skills list shows normally |
| 11 | Cron jobs work (if configured) | Check job status | Fires normally |

### 8.4 Old Directory Cleanup

| # | Check | How | Expected |
|:-:|-------|-----|----------|
| 12 | Gateway files cleaned | No `gateway.lock` `gateway_state.json` in old dir | ✅ |
| 13 | State DB cleaned | No `state.db*` in old dir | ✅ |
| 14 | Caches cleaned | No `cache/` etc. in old dir | ✅ |
| 15 | Program files intact | `ls "${LOCALAPPDATA//\\//}/hermes/hermes-agent/"` | Program files present |

---

## 9. Common Pitfalls & Troubleshooting

### ❌ Pitfall 1: Using `kill -9` in Git-Bash on Windows Processes

```bash
# ❌ WRONG: Git-Bash's kill command does NOT work on Windows native processes
kill -9 <PID>    # No effect, no error message

# ✅ CORRECT: Use Windows-native taskkill (note the double-slashes in Git-Bash)
taskkill.exe //F //PID <PID>

# Or from PowerShell (no double-slashes needed)
# taskkill /F /PID <PID>
```

### ❌ Pitfall 2: Thinking Copy = Migration Complete

Three steps, **all required**:

```
Copy data ✅
  → Set env var ✅
    → Restart Gateway ✅
      → Verify ✅
        → Done! 🎉
```

### ⚠️ Pitfall 3: Desktop Restart Doesn't Kill Manual Gateway

If you started the Gateway manually with `hermes gateway run`, closing Desktop will **not** stop it. You'll have a Gateway still reading the old directory.

**Solution**: Explicitly kill the old Gateway process with `taskkill.exe` before starting the new one.

### ⚠️ Pitfall 4: Environment Variable Doesn't Take Effect

After setting `HERMES_HOME`, **existing terminal windows** won't see the new variable. You must:

1. Close all Git-Bash / PowerShell windows
2. Open new ones

### ⚠️ Pitfall 5: Files Locked During Copy

If Hermes is running, robocopy will warn about inaccessible files. This is normal and harmless:

- Locked files are runtime files (state.db, etc.) — they'll be recreated on Gateway restart
- Config files (config.yaml, .env) are generally not locked
- Locked files don't block other files from being copied

### ⚠️ Pitfall 6: Paths with Spaces and Backslashes in Git-Bash

```bash
# ❌ Unquoted backslash path with spaces may fail
cd C:\Users\My Name\AppData\Local\hermes

# ✅ Solution 1: Use forward slashes, escape spaces
cd /c/Users/My\ Name/AppData/Local/hermes

# ✅ Solution 2: Quote the path
cd "C:\Users\My Name\AppData\Local\hermes"

# ✅ Solution 3: Use %LOCALAPPDATA% and convert backslashes
cd "${LOCALAPPDATA//\\//}/hermes"
```

### ⚠️ Pitfall 7: Windows Backslash Paths in Git-Bash

Environment variables like `$LOCALAPPDATA` or `$HERMES_HOME` may contain Windows-style backslashes (`C:\Users\...`). When concatenated with Unix-style forward slashes in Git-Bash, the path may be misinterpreted.

```bash
# ❌ May fail: mixed backslash + forward slash
ls -la "$HERMES_HOME/profiles/<your-profile>/state.db"

# ✅ Convert backslashes to forward slashes first
ls -la "${HERMES_HOME//\\//}/profiles/<your-profile>/state.db"
```

> **Tip**: The `${VAR//\\//}` syntax replaces every `\` with `/` in the variable before use.

### ⚠️ Pitfall 8: HERMES_HOME Points to the Profile Subdirectory Instead of the Root

Hermes resolves profile data relative to `HERMES_HOME`. If you set `HERMES_HOME` to `G:\AI\Hermes\profiles\rina` instead of `G:\AI\Hermes`, the migration may appear to work, but:

- The root `config.yaml` (`G:\AI\Hermes\config.yaml`) is ignored.
- A second nested `profiles/` directory may be created inside the profile folder.
- The active configuration can silently differ from what the migration docs describe.

**How to detect:**

```bash
echo $HERMES_HOME
# Should end with the migration target root, e.g. G:\AI\Hermes
# Should NOT end with profiles/<name>
```

**How to fix:**

```powershell
[Environment]::SetEnvironmentVariable('HERMES_HOME', 'G:\AI\Hermes', 'User')
```

Then fully restart Hermes Desktop (or kill + restart the Gateway) so the new value takes effect.

---

## 10. Rollback Plan

If something goes wrong after migration, here's how to get back:

### 10.1 Clear HERMES_HOME

```powershell
# In PowerShell — restores default behavior
[Environment]::SetEnvironmentVariable('HERMES_HOME', '', 'User')
```

### 10.2 Restart Gateway from Old Directory

Close and reopen Desktop, or manually:

```bash
taskkill.exe //F //PID <new-gateway-PID>
cd "${LOCALAPPDATA//\\//}/hermes"
hermes gateway run --accept-hooks &
```

### 10.3 Restore Data Files (if you cleaned the old directory)

```powershell
robocopy <target-directory> "$env:LOCALAPPDATA\hermes" /E /COPY:DAT /R:3 /W:5 /NP /NDL
```

---

## 11. Appendix: Directory Structure Reference

### After Migration — Recommended Layout

```
%HERMES_HOME%\                             ← Your new data directory
│
├── config.yaml                            # Main config (non-secret settings)
├── .env                                   # API keys (environment variables file)
├── auth.json                              # OAuth credentials
│
├── profiles\                              # Multi-profile configuration
│   └── <your-profile>\                    # e.g., default, rina, etc.
│       ├── config.yaml                    # Profile-specific config
│       ├── SOUL.md                        # Persona definition
│       ├── state.db                       # Session/memory database (actively written)
│       ├── gateway_state.json             # Gateway runtime state
│       ├── channel_directory.json         # Platform channel directory
│       ├── feishu_seen_message_ids.json   # Feishu read message tracking
│       ├── sessions\                      # Session records
│       ├── skills\                        # Custom skills
│       ├── memories\                      # Persistent memories
│       └── cron\                          # Scheduled jobs
│
├── chats\                                 # Chat scripts/plans
├── skills\                                # Global skills
├── sessions\                              # Global sessions
├── memories\                              # Global memories
├── cron\                                  # Global scheduled jobs
│
├── cache\                                 # Cache (safe to clean)
├── bootstrap-cache\                       # Bootstrap cache
├── audio_cache\                           # Audio cache
├── image_cache\                           # Image cache
├── logs\                                  # Runtime logs (safe to clean)
│
└── ...                                    # Other runtime files
```

### Old Path — Program Files (Keep)

```
%LOCALAPPDATA%\hermes\                     ← Program installation (leave untouched)
│
├── hermes-agent\                           # Hermes program binaries
│   ├── venv\Scripts\hermes.exe             # CLI entry point
│   ├── apps\desktop\release\win-unpacked\  # Desktop app
│   └── hermes_cli\                         # Core modules
│
├── git\                                    # Git-Bash toolchain (~45 MB MinGit)
├── bin\                                    # Helper tools (ripgrep, ffmpeg, etc.)
├── node\                                   # Node.js runtime
└── hermes-setup.exe                        # Installer
```

---

## 12. Appendix: Quick Command Reference

### Environment Variables

```powershell
# Set HERMES_HOME (PowerShell, user-level)
[Environment]::SetEnvironmentVariable('HERMES_HOME', '<target-directory>', 'User')

# Clear HERMES_HOME (rollback)
[Environment]::SetEnvironmentVariable('HERMES_HOME', '', 'User')

# Check current value (new terminal)
echo $env:HERMES_HOME
```

### File Operations

```powershell
# Copy data (PowerShell)
robocopy "$env:LOCALAPPDATA\hermes" "<target-directory>" /E /COPY:DAT /R:2 /W:3 /NP /NDL
```

```bash
# Check directory size (Git-Bash)
du -sh "${LOCALAPPDATA//\\//}/hermes"

# Check file modification time
ls -la "${HERMES_HOME//\\//}/profiles/<your-profile>/state.db"
```

### Gateway Management

```bash
# Check gateway status
hermes gateway status

# Start gateway in background
hermes gateway run --accept-hooks &

# Install as Windows scheduled task (auto-start on login)
hermes gateway install

# Check gateway PID
cat "${HERMES_HOME//\\//}/profiles/<your-profile>/gateway_state.json"
```

### Process Management (Git-Bash)

```bash
# Find Hermes-related processes
ps aux | grep -i hermes

# Kill a Windows process (must use taskkill)
taskkill.exe //F //PID <PID>

# Find Desktop processes
ps -W 2>/dev/null | grep -i Hermes.exe
```

### One-Shot Verification Script

```bash
echo "==============================================="
echo "  Hermes Migration Verification - $(date '+%Y-%m-%d %H:%M:%S')"
echo "==============================================="
echo ""
echo "[1] HERMES_HOME = $HERMES_HOME"
echo ""
echo "[2] Gateway status:"
hermes gateway status 2>&1 || echo "  ❌ Gateway not running"
echo ""
echo "[3] New directory state.db timestamp:"
ls -la ${HERMES_HOME//\\//}/profiles/*/state.db 2>/dev/null
echo ""
echo "[4] Platform connections:"
cat ${HERMES_HOME//\\//}/profiles/*/gateway_state.json 2>/dev/null || echo "  Cannot read"
echo ""

# What to look for:
# ① HERMES_HOME should show your target path
# ② Gateway should show running/active
# ③ state.db modification time should be now
# ④ gateway_state.json platforms should show "connected"
```

---

## Contributing & Feedback

This guide is based on **real migration experience**. If you run into Windows-specific issues not covered here, please:

- Open an Issue or PR on the [Hermes Agent](https://github.com/NousResearch/hermes-agent) repository
- Join the Hermes community discussions

---

> *Authored by Rina (Hermes Agent user) based on hands-on migration experience.*
> *Last updated: 2026-06-14*
