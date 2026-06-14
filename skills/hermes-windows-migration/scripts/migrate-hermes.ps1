<#
.SYNOPSIS
    Hermes Agent Windows Data Migration Script
.DESCRIPTION
    Migrates Hermes Agent data from %LOCALAPPDATA%\hermes to a custom path.
    Interactive, safe (never deletes any files).
.PARAMETER Target
    Optional: specify target directory directly. E.g.: .\migrate-hermes.ps1 -Target "D:\HermesData"
.PARAMETER AutoYes
    Optional: skip all confirmation prompts (use with -Target for unattended runs).
.PARAMETER SetEnv
    Optional: set HERMES_HOME env var automatically. Default: ask user. Values: $true / $false
.EXAMPLE
    .\migrate-hermes.ps1
    Interactive mode — guides through every step.
.EXAMPLE
    .\migrate-hermes.ps1 -Target "E:\hermes-data"
    Specifies target directly, reduces interactive prompts.
.NOTES
    Version: 1.0.1
    Platform: Windows 10/11 (Hermes Agent native install)
    Author: Rina
    Note: This script NEVER deletes any files. Manual cleanup guidance is provided at the end.
#>

param(
    [string]$Target = "",
    [switch]$AutoYes = $false,
    [switch]$SetEnv = $false
)

# ============================================================
# Initialization
# ============================================================
$ErrorActionPreference = "Stop"

function Write-Info  { Write-Host "  ℹ️  $($args[0])" -ForegroundColor Cyan }
function Write-Step  { Write-Host "`n▶ $($args[0])" -ForegroundColor Yellow }
function Write-Done  { Write-Host "  ✅ $($args[0])" -ForegroundColor Green }
function Write-Warn  { Write-Host "  ⚠️  $($args[0])" -ForegroundColor DarkYellow }
function Write-Fail  { Write-Host "  ❌ $($args[0])" -ForegroundColor Red }

function Ask-YesNo {
    param([string]$Prompt, [string]$Default = "Y")
    if ($AutoYes) { return ($Default -eq "Y") }
    $defaultText = if ($Default -eq "Y") { "Y/n" } else { "y/N" }
    $answer = Read-Host "  💬 $Prompt [$defaultText]"
    if ($answer -eq "") { $answer = $Default }
    return ($answer -eq "Y" -or $answer -eq "y")
}

# ============================================================
# Banner
# ============================================================
Write-Host ""
Write-Host "+--------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|     Hermes Agent Windows Data Migration v1.0.1   |" -ForegroundColor Cyan
Write-Host "|     Move data from C: drive to any location     |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------------+" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Step 0: Check current state
# ============================================================
Write-Step "Step 0/5: Checking current environment"

$sourcePath = "$env:LOCALAPPDATA\hermes"
$sourceExists = Test-Path $sourcePath

if (-not $sourceExists) {
    Write-Fail "Hermes data directory not found: $sourcePath"
    Write-Info "Make sure Hermes Agent is installed and has been run at least once."
    exit 1
}

Write-Info "Source directory: $sourcePath"
Write-Info "Calculating source size..."
Write-Info "Scanning files, please wait..."
try {
    $sourceSize = (Get-ChildItem $sourcePath -Recurse -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sourceSizeMB = [math]::Round($sourceSize / 1MB, 1)
    Write-Info "Source size: ~$sourceSizeMB MB"
} catch {
    Write-Warn "Could not calculate source size (some files may be locked)"
    $sourceSizeMB = 0
}

# Check current HERMES_HOME
$currentHome = [Environment]::GetEnvironmentVariable('HERMES_HOME', 'User')
if ($currentHome -and (Test-Path $currentHome)) {
    Write-Warn "HERMES_HOME is already set to: $currentHome"
    Write-Info "Hermes is currently using that directory as its data home."
    if (Ask-YesNo "Migrate from current HERMES_HOME instead of default location?" "Y") {
        $sourcePath = $currentHome
    } else {
        Write-Info "Keeping default source: $sourcePath"
        Write-Info "To migrate from default location, clear HERMES_HOME first."
    }
} elseif ($currentHome) {
    Write-Warn "HERMES_HOME points to a non-existent directory: $currentHome"
    Write-Info "Falling back to default source: $sourcePath"
}

# Warn about running Desktop
$desktopRunning = @(Get-Process -Name "Hermes" -ErrorAction SilentlyContinue).Count -gt 0
if ($desktopRunning) {
    Write-Warn "Hermes Desktop is running!"
    Write-Warn "It is recommended to exit Desktop (system tray → right-click → Quit) before migrating."
    if (-not (Ask-YesNo "Continue anyway?" "N")) {
        Write-Info "Please exit Hermes Desktop and re-run this script."
        exit 0
    }
}

Write-Host ""

# ============================================================
# Step 1: Choose target directory
# ============================================================
Write-Step "Step 1/5: Choose target directory"

$targetDir = $Target
if (-not $targetDir) {
    $defaultTarget = "D:\HermesData"
    $inputTarget = Read-Host "  💬 Enter target directory path (press Enter for '$defaultTarget')"
    $targetDir = if ($inputTarget) { $inputTarget } else { $defaultTarget }
}

# Expand environment variables if any
$targetDir = [Environment]::ExpandEnvironmentVariables($targetDir)

# Bash-safe path variants for guidance output
$sourcePathBash = $sourcePath -replace '\\', '/'
$targetDirBash = $targetDir -replace '\\', '/'

Write-Info "Target directory: $targetDir"

# Check not same as source
if ($targetDir.TrimEnd('\') -eq $sourcePath.TrimEnd('\')) {
    Write-Fail "Target directory is the same as source! Please choose a different path."
    exit 1
}

# Check target is not a profile subdirectory (HERMES_HOME must point to the migration root)
if ($targetDir -match '\\profiles\\[^\\]+\$') {
    Write-Fail "Target directory appears to be a profile subdirectory: $targetDir"
    Write-Info "HERMES_HOME must point to the migration root directory, not a profiles subfolder."
    Write-Info 'Use the root folder, e.g. D:\HermesData'
    exit 1
}

# Warn about non-ASCII characters
if ($targetDir -match '[^\x00-\x7F]') {
    Write-Warn "Target path contains non-ASCII characters — may cause compatibility issues."
    if (-not (Ask-YesNo "Continue?" "N")) { exit 0 }
}
if ($targetDir -match ' ') {
    Write-Warn "Target path contains spaces — may cause compatibility issues."
    if (-not (Ask-YesNo "Continue?" "N")) { exit 0 }
}

# Check disk space
$targetDrive = Split-Path $targetDir -Qualifier
if ($targetDrive) {
    try {
        $driveInfo = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$targetDrive'" -ErrorAction Stop
        if (-not $driveInfo) {
            throw "Drive not found"
        }
        $freeGB = [math]::Round($driveInfo.FreeSpace / 1GB, 1)
        Write-Info "Drive $targetDrive free space: ~$freeGB GB"
        if ($freeGB -lt 2) {
            Write-Warn "Less than 2 GB free — consider freeing up space before continuing."
            if (-not (Ask-YesNo "Continue?" "N")) { exit 0 }
        }
    } catch {
        Write-Warn "Could not check disk space (drive '$targetDrive' may not exist)"
        if (-not (Ask-YesNo "Continue?" "N")) { exit 0 }
    }
}

# Confirm
if (-not $AutoYes) {
    Write-Host "`n  📋 Migration plan:"
    Write-Host "     Source: $sourcePath"
    Write-Host "     Target: $targetDir"
    Write-Host "     Estimated size: ~$sourceSizeMB MB"
    Write-Host "     Note: Only data files will be copied — program files stay in place`n"
    if (-not (Ask-YesNo "Proceed with copy?" "N")) {
        Write-Info "Cancelled. Run again anytime."
        exit 0
    }
}

# ============================================================
# Step 2: Copy data
# ============================================================
Write-Step "Step 2/5: Copying data to target directory"

# Create target if it doesn't exist (or warn if not empty)
if (Test-Path $targetDir) {
    $existingItems = Get-ChildItem $targetDir -Force | Select-Object -First 1
    if ($existingItems) {
        Write-Warn "Target directory is not empty: $targetDir"
        if (-not (Ask-YesNo "Continue and merge Hermes data into this directory?" "N")) {
            Write-Info "Cancelled. Choose an empty directory or create a new one."
            exit 0
        }
    }
} else {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Info "Created target directory: $targetDir"
}

Write-Info "Copying data via robocopy... (this may take a few minutes)"

$robocopyArgs = @(
    $sourcePath, $targetDir,
    "/E", "/COPY:DAT",
    "/R:2", "/W:3",
    "/NP", "/NDL"
)

$robocopyResult = robocopy @robocopyArgs
$rcExitCode = $LASTEXITCODE

if ($rcExitCode -ge 8) {
    Write-Fail "robocopy failed (exit code: $rcExitCode)"
    Write-Info "Check that the target path is writable, or copy manually:"
    Write-Info "  robocopy `"$sourcePath`" `"$targetDir`" /E /COPY:DAT /R:2 /W:3 /NP /NDL"
    exit 1
}

Write-Done "Data copy complete (robocopy exit code: $rcExitCode — 0-7 all indicate success)"

# Report skipped files
$skippedCount = ($robocopyResult | Select-String "^\s*ERROR\s" | Measure-Object).Count
if ($skippedCount -gt 0) {
    Write-Warn "$skippedCount file(s) were skipped (usually runtime-locked files — this is normal)"
    Write-Info "Skipped files are typically runtime databases (state.db, etc.)"
    Write-Info "They will be recreated automatically when Gateway restarts."
}

Write-Host ""

# ============================================================
# Step 3: Set HERMES_HOME environment variable
# ============================================================
Write-Step "Step 3/5: Setting HERMES_HOME environment variable"

$shouldSetEnv = $SetEnv
if (-not $shouldSetEnv) {
    $shouldSetEnv = Ask-YesNo "Set HERMES_HOME to point to the new directory?" "Y"
}

if ($shouldSetEnv) {
    try {
        [Environment]::SetEnvironmentVariable('HERMES_HOME', $targetDir, 'User')
        Write-Done "HERMES_HOME set to: $targetDir"

        # Also set for the current PowerShell session so we can verify
        $env:HERMES_HOME = $targetDir
        Write-Info "Loaded in current session."
        Write-Info "Existing terminal windows need to be closed and reopened to see the new variable."
    } catch {
        Write-Fail "Failed to set environment variable: $_"
        Write-Info "Set it manually in PowerShell:"
        Write-Info "  [Environment]::SetEnvironmentVariable('HERMES_HOME', '$targetDir', 'User')"
        exit 1
    }
} else {
    Write-Info "Skipped. Set HERMES_HOME manually after the script:"
    Write-Info "  [Environment]::SetEnvironmentVariable('HERMES_HOME', '$targetDir', 'User')"
}

Write-Host ""

# ============================================================
# Step 4: Gateway restart guidance
# ============================================================
Write-Step "Step 4/5: Restart Gateway (THE CRITICAL STEP)"

Write-Warn "Copying data + setting env var is just preparation!"
Write-Warn "You MUST restart the Gateway for the change to take effect!"
Write-Host ""

Write-Info "Choose one of these options:"
Write-Host ""
Write-Host "  [Option A] Quick restart (recommended)"
Write-Host "    1. Fully exit Hermes Desktop (system tray -> right-click -> Quit)"
Write-Host "    2. Reopen Hermes Desktop"
Write-Host "    3. Gateway auto-reads the new directory"
Write-Host ""
Write-Host "  [Option B] Manual kill + restart (keep Desktop open)"
Write-Host "    1. In Git-Bash, kill the old gateway:"
Write-Host "       taskkill.exe //F //PID <old-gateway-PID>"
Write-Host "    2. Start the new gateway:"
Write-Host "       hermes gateway run --accept-hooks &"
Write-Host ""

if (Ask-YesNo "Show current gateway process info?" "N") {
    Write-Info "Run in Git-Bash:"
    Write-Info "  ps aux | grep gateway"
    Write-Info "  Old gateway state (before migration):"
    Write-Info "    cat `"$sourcePathBash/profiles/*/gateway_state.json`""
    Write-Info "  New gateway state (after restart):"
    Write-Info "    cat `"$targetDirBash/profiles/*/gateway_state.json`""
}

# ============================================================
# Step 5: Post-migration guidance
# ============================================================
Write-Step "Step 5/5: Post-migration checklist"

Write-Host ""
Write-Info "========================================"
Write-Info " Data migration complete! Next steps:"
Write-Info "========================================"
Write-Host ""

Write-Info "[Step 1] Restart Gateway (mandatory)"
Write-Info "  -> Close & reopen Desktop, or manually restart in Git-Bash"
Write-Host ""

Write-Info "[Step 2] Verify migration"
Write-Host "  - HERMES_HOME = $targetDir"
Write-Host "  - Gateway is running"
Write-Host "  - All platforms show 'connected'"
Write-Host "  - state.db timestamp = current time"
Write-Host "  - Can send and receive messages"
Write-Host ""

Write-Info "[Step 3] Clean up old directory (optional — wait until stable)"
Write-Host "  In Git-Bash, from the old directory:"
Write-Host "    cd `"$sourcePathBash`""
Write-Host "  Safe to remove:"
Write-Host "    rm -f gateway.lock gateway.pid gateway_state.json"
Write-Host "    rm -f state.db state.db-shm state.db-wal"
Write-Host "    rm -rf cache/ bootstrap-cache/ audio_cache/ image_cache/ logs/"
Write-Host ""
Write-Warn "  NEVER delete: hermes-agent/  git/  bin/  hermes-setup.exe"

Write-Host ""

# Save migration log
$migrationLog = @"
Hermes Agent Migration Record
=======================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Source: $sourcePath
Target: $targetDir
Data size: ~$sourceSizeMB MB
HERMES_HOME: $(if ($shouldSetEnv) { $targetDir } else { 'Not set' })
Status: Copied, not yet cleaned (Gateway restart required)
=======================================
"@
$logPath = Join-Path $targetDir "MIGRATION_LOG.txt"
$migrationLog | Out-File -FilePath $logPath -Encoding utf8
Write-Info "Migration log saved to: $logPath"

Write-Host ""
Write-Host "+--------------------------------------------------+" -ForegroundColor Green
Write-Host "|  Done! Restart Gateway to start using the new   |" -ForegroundColor Green
Write-Host "|  directory                                      |" -ForegroundColor Green
Write-Host "+--------------------------------------------------+" -ForegroundColor Green
