# Hermes Windows Migration Skill — Release Notes v1.0.1

> **Release Date**: 2026-06-14  
> **Scope**: Windows native install data migration from `%LOCALAPPDATA%\hermes` to a custom directory.  
> **Status**: Stable — cross-model reviewed and syntax-verified.

---

## What's Included

| File | Purpose |
|------|---------|
| `scripts/migrate-hermes.ps1` | Fully interactive PowerShell migration script |
| `references/Windows-Migration-Guide.md` | Step-by-step reference manual (12 chapters) |
| `references/review-checklist.md` | Checklist for future reviewers / auditors |
| `references/cross-model-review-notes.md` | Methodology + recurring pitfalls from cross-model review |
| `references/Release-Notes-v1.0.1.md` | This file |
| `references/Review-Report.md` | Detailed cross-model review history |

---

## Key Features

- **Interactive, safe migration** — never deletes source files.
- **Automatic HERMES_HOME management** — detects existing value, validates root-directory requirement, and sets the new user-level env var.
- **Robust file copying** — uses `robocopy` with resume/retry flags and sensible exit-code interpretation.
- **Gateway restart guidance** — explains why copying alone is not enough and walks through Desktop restart or manual kill/restart.
- **Post-migration verification** — built-in checklist and one-shot verification script.
- **Rollback plan** — documents how to revert to the old directory.

---

## Bug Fixes & Hardening (v1.0.1)

### PowerShell Script

- **Version bumped to v1.0.1** (was v1.0).
- **Removed `Clear-Host`** so users do not lose prior terminal output.
- **Renamed `Write-Error` to `Write-Fail`** to avoid shadowing the built-in cmdlet.
- **Added HERMES_HOME root-directory validation** — rejects targets ending in `profiles/<name>`.
- **Added target non-empty warning** with `Select-Object -First 1` to avoid hanging on huge directories.
- **Switched disk-space check** from `Get-PSDrive` to `Get-CimInstance Win32_LogicalDisk`.
- **Env-var set failures now `exit 1`** instead of continuing silently.
- **Added bash-safe path variants** (`$sourcePathBash`, `$targetDirBash`) for user-facing Git-Bash guidance.
- **Converted banners and migration log** from Unicode box-drawing characters to ASCII for encoding safety.

### Documentation

- **Unified WSL2 scope** — now explicitly states WSL2 is **not** covered.
- **Added Pitfall 8** for HERMES_HOME pointing to `profiles/<name>` instead of the migration root.
- **Converted all Git-Bash file-access examples** to use `${VAR//\\//}` so Windows backslash paths are normalized before concatenation.
- **Unified all placeholders** to `<target-directory>`.
- **Added `/NP /NDL`** to every `robocopy` example.

### Review Infrastructure

- Added `references/review-checklist.md` with v1.0.1 baseline.
- Added `references/Review-Report.md` documenting all review rounds.

---

## Known Limitations

- Windows native install only (PowerShell/Desktop install).
- Does **not** apply to WSL2, Linux, or macOS.
- `Ask-YesNo` only accepts single-letter `Y/y/N/n` responses.
- Process detection only checks for processes named `Hermes`; other related processes may be missed.

---

## How to Use

```powershell
# Interactive
powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1

# Unattended
powershell -ExecutionPolicy Bypass -File .\migrate-hermes.ps1 -Target "D:\HermesData" -AutoYes -SetEnv
```

---

## Verification

- PowerShell syntax validated with `[System.Management.Automation.PSParser]::Tokenize(...)`.
- Cross-model review completed (deepseek-v4-flash, DeepSeek Pro, kimi-k2.7-code).
- All three/four files reviewed for consistency.

---

## Review Infrastructure

- Added `references/review-checklist.md` with v1.0.1 baseline.
- Detailed review methodology and recurring pitfalls are in `references/cross-model-review-notes.md`.
- Round-by-round findings are recorded in `SKILL.md` under **Verification History**.

---

*Authored by Rina. Review history is available in `SKILL.md` and `references/cross-model-review-notes.md`.*
