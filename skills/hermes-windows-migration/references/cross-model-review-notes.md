# Cross-Model Review Notes — Hermes Windows Migration

This file captures the review methodology and recurring pitfalls discovered while hardening the Windows migration skill (v1.0.1). Use it when extending the skill or conducting similar reviews.

## Review Methodology

The skill was reviewed in rounds across multiple models:

1. **Round 1–4**: `deepseek-v4-flash` — syntax, placeholders, execution-policy guidance, bash quoting.
2. **Round 5**: `kimi-k2.7-code` — deep PowerShell logic, cross-file consistency, edge cases.
3. **Round 6**: `kimi-k2.7-code` — fresh-perspective pass (non-ASCII paths, permissions, interruption recovery).
4. **Round 7**: `deepseek-v4-flash` — HERMES_HOME root vs profile subdirectory confusion.
5. **Round 8**: `kimi-k2.7-code` — final read-through, version sync, remaining bash/PowerShell inconsistencies.

Key takeaway: **no single model caught everything**. Cross-model review works best when each round is given a distinct mandate (e.g., "fresh eyes", "specific file", "edge cases").

## PowerShell Pitfalls

| Issue | Why It Bites | Pattern to Use |
|-------|--------------|----------------|
| `Write-Error` shadows built-in cmdlet | Calling `Write-Error` inside a user-defined function named `Write-Error` creates recursion or runtime crash. | Use `Write-Fail` or another non-conflicting name. |
| `Get-PSDrive` for disk space | Does not reflect real free space on all drive types; returns `$null` or stale values for some volumes. | Use `Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='<drive>'"`. |
| `Clear-Host` at script start | Wipes the user's terminal history, destroying context they may need. | Use a leading blank line + ASCII banner. |
| `Get-ChildItem -Force` on huge target dirs | Can hang when checking whether a target directory is empty. | Pipe to `Select-Object -First 1`. |
| Native command stderr under `$ErrorActionPreference = "Stop"` | `robocopy` writing to stderr can pollute the error stream. | Redirect with `2>&1` if you need to capture/inspect output. |
| Environment-variable set failure not exiting | A failed `[Environment]::SetEnvironmentVariable` would leave HERMES_HOME unset while the script claimed success. | Add `exit 1` inside the `catch` block. |
| `$targetDir` referenced before initialization | A well-intentioned duplicate source≠target check was placed before the target was read. | Keep source≠target checks **after** both source and target are finalized. |

## Bash ↔ PowerShell Path Handling

Git-Bash/MSYS variables like `$LOCALAPPDATA` contain Windows backslashes. Concatenating them with Unix forward slashes produces mixed paths that some tools misparse:

```bash
# ❌ May fail
ls -la "$HERMES_HOME/profiles/<your-profile>/state.db"

# ✅ Convert backslashes first
ls -la "${HERMES_HOME//\\//}/profiles/<your-profile>/state.db"
```

Apply this to **all file-access commands** (`ls`, `cat`, `du`, `cd` when used as part of a file path). Inside PowerShell string output intended for Git-Bash, compute a forward-slash variant:

```powershell
$sourcePathBash = $sourcePath -replace '\\', '/'
Write-Host "    cat `"$sourcePathBash/profiles/*/gateway_state.json`""
```

## robocopy Consistency Checklist

Every `robocopy` example in the skill should use:

```text
/E /COPY:DAT /R:x /W:x /NP /NDL
```

- `/E` — subdirectories, including empty ones
- `/COPY:DAT` — data, attributes, timestamps
- `/R:x` / `/W:x` — bounded retries
- `/NP` — no progress percentage (cleaner output)
- `/NDL` — no directory logging (less noise)

Exit-code interpretation: **0–7 = success or success-with-skips; ≥8 = failure**.

## HERMES_HOME Root Validation

A common user mistake is setting `HERMES_HOME` to `D:\HermesData\profiles\rina` instead of `D:\HermesData`. This causes Hermes to ignore the root `config.yaml` and create nested `profiles/` directories.

Detection in PowerShell:

```powershell
if ($targetDir -match '\\profiles\\[^\\]+\$') {
    Write-Error "HERMES_HOME must point to the migration root, not a profiles subfolder."
    exit 1
}
```

Also warn in documentation and verification checklists.

## Version Synchronization Across Deliverables

The skill ships multiple artifacts. Keep their version strings in sync:

| File | Version Location |
|------|------------------|
| `SKILL.md` | YAML frontmatter `version:` |
| `scripts/migrate-hermes.ps1` | `.NOTES` block + banner text |
| `references/Windows-Migration-Guide.md` | Header line |
| `references/review-checklist.md` | Top note |

After any version bump, search for the old version string across the whole skill directory.

## ASCII vs Unicode in Scripts

Avoid Unicode box-drawing characters (`╔╗╚╝═`) in PowerShell output. They render inconsistently across terminals, fonts, and encoding settings, and can be corrupted during copy-paste. Use ASCII art (`+`, `-`, `|`, `=`) instead.
