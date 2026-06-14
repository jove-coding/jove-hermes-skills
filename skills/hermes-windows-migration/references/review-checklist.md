# Windows Migration Skill Review Checklist

> **Version 1.0.1** — This checklist was used during the v1.0.1 cross-model review and all items passed. Re-run it for any future edits.

Use this checklist when reviewing PowerShell migration scripts and their companion documentation for Hermes Windows data migration.

## PowerShell Script

- [ ] No built-in cmdlet names are shadowed (e.g., `Write-Error`, `Write-Output`)
- [ ] `$ErrorActionPreference = "Stop"` does not swallow native command exit codes
- [ ] Source directory accounts for an already-set `HERMES_HOME` (repeat-run safety)
- [ ] Target directory is checked for non-empty state before merging
- [ ] Source ≠ target check handles trailing backslashes consistently
- [ ] Disk-space check uses `Get-CimInstance Win32_LogicalDisk` rather than `Get-PSDrive`
- [ ] UNC paths gracefully skip drive-letter checks
- [ ] robocopy exit codes: 0–7 = success/with-skips, ≥8 = failure
- [ ] `robocopy` call passes flags as an array (`@robocopyArgs`) for correct quoting
- [ ] Environment-variable set failure causes script to exit with error
- [ ] Manual fallback / error messages quote paths and include the same flags as the script
- [ ] Long-running scans show a "please wait" message

## Cross-Document Consistency

- [ ] All `robocopy` examples use the same flags (`/E /COPY:DAT /R:x /W:x /NP /NDL`)
- [ ] Placeholders use the same style (`<target-directory>` not `target-directory`)
- [ ] PowerShell execution-policy guidance appears everywhere `.ps1` is invoked
- [ ] bash examples that call PowerShell protect `$env:` variables with single quotes
- [ ] Scope limitations (WSL2 / Linux / macOS) are stated identically across files
- [ ] `taskkill.exe //F //PID` appears in Git-Bash examples, `taskkill /F /PID` in PowerShell

## Edge Cases

- [ ] Paths with spaces are handled and warned about
- [ ] Non-ASCII paths are warned about
- [ ] Empty / unset `$env:LOCALAPPDATA` fails cleanly
- [ ] Re-running the script after a previous migration picks the correct source
- [ ] Target path environment variables are expanded before comparison/use
- [ ] Documentation and verification steps remind the user that `HERMES_HOME` must point to the migration target root, not `profiles/<name>`
