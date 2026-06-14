---
name: hermes-windows-migration
description: Migrate Hermes Agent data from default Windows path to a custom drive/directory — script automation + step-by-step guidance
version: 1.0.1
author: Rina
license: CC0
platforms: [windows]
metadata:
  hermes:
    tags: [Windows, Migration, HERMES_HOME, Data-Migration]
    related_skills: []
---

# Hermes Windows Data Migration

## When to Load This Skill

Load this skill when the user says anything like:

- "I want to move my Hermes data from the C: drive"
- "My C: drive is full, how do I relocate Hermes data?"
- "How to migrate Hermes data to another drive?"
- "Set HERMES_HOME environment variable"
- "Hermes data is growing too large, where should I put it?"
- "How to move Hermes data folder to D: drive?"

## Workflow

### Option A: User Has PowerShell (Recommended)

Guide the user to run the `migrate-hermes.ps1` script. It handles:

1. Checking current Hermes installation status
2. Asking for target directory
3. Copying data via robocopy
4. Setting the HERMES_HOME environment variable
5. Guiding Gateway restart
6. Outputting a verification checklist

**How to run** (tell the user):

```powershell
# Interactive mode (use Bypass if execution policy blocks it)
powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1

# Or specify target directly (skips the prompt):
powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1 -Target "D:\HermesData"
```

> **Note**: If the user obtained the `.ps1` file from someone else, remind them to review the script contents first.
> **Note**: If PowerShell says "running scripts is disabled", run with `powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1` instead.

### Option B: User Prefers Manual Steps

Guide through these steps:

**Step 1: Check current state**
```bash
echo $HERMES_HOME
du -sh "${LOCALAPPDATA//\\//}/hermes"
hermes gateway status
```

**Step 2: Copy data**
```powershell
# In PowerShell — replace <target-directory> with your actual path
robocopy "$env:LOCALAPPDATA\hermes" "<target-directory>" /E /COPY:DAT /R:2 /W:3 /NP /NDL
```

**Step 3: Set environment variable**
```powershell
[Environment]::SetEnvironmentVariable('HERMES_HOME', '<target-directory>', 'User')
```

**Step 4: Restart Gateway**
- Close & reopen Desktop, or
- Manually kill + restart:
  ```bash
  taskkill.exe //F //PID <old-gateway-PID>
  hermes gateway run --accept-hooks &
  ```

**Step 5: Verify**
```bash
echo $HERMES_HOME
hermes gateway status
ls -la "${HERMES_HOME//\\//}/profiles/*/state.db"
```

### Option C: User Wants Me (Rina) to Do It All

If the user says "you handle it" and they're at a Windows machine:

**Prerequisite**: I need terminal access to run commands on their Windows machine.

1. **Check environment**
   ```bash
   echo $HERMES_HOME
   hermes gateway status
   ls "${LOCALAPPDATA//\\//}/hermes/config.yaml"
   ```

2. **Copy data via robocopy** (calling PowerShell from Git-Bash)
   ```bash
   # ⚠️ Use single quotes so bash doesn't mangle $env:LOCALAPPDATA
   powershell.exe -Command 'robocopy "$env:LOCALAPPDATA\hermes" "<target-directory>" /E /COPY:DAT /R:2 /W:3 /NP /NDL'
   ```

3. **Set environment variable**
   ```bash
   powershell.exe -Command "[Environment]::SetEnvironmentVariable('HERMES_HOME', '<target-directory>', 'User')"
   ```

4. **Restart Gateway**
   - Recommend user close & reopen Desktop (simplest)
   - Or kill old gateway + start new one (requires user to confirm PID)

## Critical Warnings

### Always Emphasize These

1. **Program files vs data files** — always clarify first. `hermes-agent/`, `git/`, `bin/`, `node/` must NOT be moved
2. **Copying data ≠ migration complete** — Gateway must be restarted
3. **Env var needs new terminal** — existing windows won't see the change
4. **On Windows, use `taskkill`** — `kill -9` doesn't work on Windows native processes
5. **Locked files are OK** — runtime files (state.db, etc.) auto-recreate on Gateway restart
6. **HERMES_HOME must point to the migration target root** — not the `profiles/<name>` subdirectory. If `HERMES_HOME` ends in `profiles/<profile>`, Hermes will use that subdirectory as root and ignore the root `config.yaml`

### Limitations

- Windows native install only (PowerShell install method)
- Does NOT apply to WSL2 Hermes (`~/.hermes` is on the Linux filesystem)
- Does NOT apply to Linux/macOS

## Post-Migration Checklist (Show to User)

```
□ HERMES_HOME env var = target path (must be the root directory, not profiles/<name>)
□ Gateway is running
□ All platforms show "connected"
□ state.db modification time = current time
□ Can send and receive messages
```

## Included Files

| File | Purpose | Location |
|------|---------|----------|
| migrate-hermes.ps1 | Fully automated migration script (interactive) | scripts/migrate-hermes.ps1 |
| Windows-Migration-Guide.md | Detailed step-by-step reference document | references/Windows-Migration-Guide.md |


## FAQ

### Q: Will the script delete files from the old directory?
A: No. This script never deletes anything. Old directory cleanup is manual and optional.

### Q: Do I need administrator rights?
A: No. Setting a user-level HERMES_HOME variable does not require admin privileges.

### Q: Will old data be overwritten?
A: No. Hermes reads and writes from the new directory. Old data stays untouched.


