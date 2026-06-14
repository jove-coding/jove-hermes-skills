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
| review-checklist.md | Review checklist for future migrations / script audits | references/review-checklist.md |
| Release-Notes-v1.0.1.md | Release notes and changelog | references/Release-Notes-v1.0.1.md |
| Review-Report.md | Comprehensive cross-model review report | references/Review-Report.md |
| cross-model-review-notes.md | Methodology + recurring pitfalls learned during cross-model review | references/cross-model-review-notes.md |

## FAQ

### Q: Will the script delete files from the old directory?
A: No. This script never deletes anything. Old directory cleanup is manual and optional.

### Q: Do I need administrator rights?
A: No. Setting a user-level HERMES_HOME variable does not require admin privileges.

### Q: Will old data be overwritten?
A: No. Hermes reads and writes from the new directory. Old data stays untouched.

## Verification History

This skill and its companion files have been reviewed via cross-model verification (deepseek-v4-flash → DeepSeek Pro). Issues found and fixed during review:

| Round | Model | Finding | Fix |
|-------|-------|---------|-----|
| 1 | flash | Option B placeholders not clearly marked (`target-directory` vs `<target-directory>`) | Added `<>` to all placeholders |
| 1 | flash | Missing PowerShell `-ExecutionPolicy Bypass` guidance | Added Bypass to all `.ps1` examples |
| 1 | flash | Option C: `$env:LOCALAPPDATA` expanded by bash in double-quoted string (not passed to PowerShell) | Switched to single quotes in bash so the literal string reaches PowerShell |
| 2 | flash | Option A: second example lacked `-ExecutionPolicy Bypass` | Added Bypass to second example |
| 3 | pro | **`Write-Fail` function undefined** (line 195 of `migrate-hermes.ps1`) — runtime crash if robocopy fails | Defined `Write-Fail` function |
| 3 | pro | Option B robocopy missing `/NP /NDL` flags (inconsistent with script and doc) | Added `/NP /NDL` to Option B |
| 5 | kimi-k2.7-code | `Write-Error` shadowed built-in PowerShell cmdlet | Renamed to `Write-Fail` |
| 5 | kimi-k2.7-code | Repeated runs used wrong source directory when `HERMES_HOME` was already set | Detect existing `HERMES_HOME` and offer to migrate from it |
| 5 | kimi-k2.7-code | Target directory non-empty check missing | Added non-empty warning + confirmation |
| 5 | kimi-k2.7-code | Disk-space check used `Get-PSDrive`, unreliable for some drives | Switched to `Get-CimInstance Win32_LogicalDisk` |
| 5 | kimi-k2.7-code | Env-var set failure did not stop script | Added `exit 1` in catch block |
| 5 | kimi-k2.7-code | PID hint only showed old path | Show both old and new `gateway_state.json` paths |
| 5 | kimi-k2.7-code | Guide.md quick-reference robocopy lacked `/NP /NDL` | Added flags |
| 5 | kimi-k2.7-code | Guide.md said WSL2 applied; SKILL.md said it did not | Unified to "does not apply to WSL2" |
| 6 | kimi-k2.7-code | `Clear-Host` cleared user's terminal history | Removed `Clear-Host`; use plain banner with leading blank line |
| 6 | kimi-k2.7-code | `Get-ChildItem -Force` on target could hang on huge dirs | Piped to `Select-Object -First 1` |
| 6 | kimi-k2.7-code | SKILL.md program-files warning omitted `node/` | Added `node/` to the do-not-move list |
| 6 | kimi-k2.7-code | Git-Bash examples mixed backslash Windows paths with forward slashes | Converted `du` example and added Pitfall 7 with `${VAR//\\//}` |
| 7 | deepseek-v4-flash | After restart, `HERMES_HOME` can be set to `profiles/<name>` instead of the migration root | Added Pitfall 8 and root-directory checks to warnings + checklists |
| 8 | kimi-k2.7-code | `migrate-hermes.ps1` still at v1.0 while docs were v1.0.1 | Bumped script version + banner to v1.0.1 |
| 8 | kimi-k2.7-code | Script did not validate that target is the migration root | Added regex check rejecting `profiles/<name>` targets |
| 8 | kimi-k2.7-code | End banner still used Unicode box-drawing characters | Converted to ASCII for consistency and encoding safety |
| 8 | kimi-k2.7-code | Round 6 had added a duplicate source≠target check before `$targetDir` was initialized | Removed; existing source≠target check after target input already covers the `HERMES_HOME` branch |
| 8 | kimi-k2.7-code | Bash guidance in script output mixed backslashes with forward slashes | Added `$sourcePathBash`/`$targetDirBash` variants for user-facing Git-Bash commands |
| 8 | kimi-k2.7-code | `$HERMES_HOME/profiles/...` Git-Bash examples could fail with Windows backslash paths | Converted all Git-Bash file-access examples to `${HERMES_HOME//\\//}/profiles/...` |
| 8 | kimi-k2.7-code | Guide.md `du` and `cd` examples still mixed backslashes | Converted all `$LOCALAPPDATA/hermes` examples to `${LOCALAPPDATA//\\//}/hermes` |
| 8 | kimi-k2.7-code | SKILL.md Option C used `<target-dir>` while rest of doc used `<target-directory>` | Unified to `<target-directory>` |

All three deliverables are now consistent and verified.
