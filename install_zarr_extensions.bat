# 2>nul & @echo off & powershell -ExecutionPolicy Bypass -File "%~f0" %* & pause & exit /b

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ─────────────────────────────────────────────────────────────
$EdmEnv   = "hxEnv1"
$EdmExe   = "$env:USERPROFILE\AppData\Local\Programs\Enthought\edm\edm.bat"
$RepoBase = "https://raw.githubusercontent.com/janelia-cellmap/amira_python_extensions/master"
$Files    = @("ZarrRead.pyscro", "ZarrRead.rc", "ZarrWrite.pyscro", "ZarrWrite.rc")
$Packages = @("zarr==3.1.5", "numpy==1.26.4", "ome-zarr-models==1.7", "tensorstore==0.1.82")
# ──────────────────────────────────────────────────────────────────────────────

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Fail($msg)       { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

# 1. Locate latest Amira installation
Write-Step "Locating latest Amira installation"
$ProgramFiles = [Environment]::GetFolderPath("ProgramFiles")
$AmiraRoot = Get-ChildItem $ProgramFiles -Directory |
    Where-Object { $_.Name -match '^Thermo Scientific Amira-Avizo3D\s+([\d.]+)' } |
    Sort-Object {
        $m = [regex]::Match($_.Name, '([\d.]+)$')
        [System.Version]($m.Value + ".0")
    } -Descending |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $AmiraRoot) { Fail "No Amira installation found under '$ProgramFiles'" }
Write-Host "Using: $AmiraRoot"

# 2. Verify EDM is present
if (-not (Test-Path $EdmExe)) { Fail "EDM not found at '$EdmExe'" }

# 3. Create EDM environment from Amira's bundle (skip if already exists)
Write-Step "Checking EDM environment '$EdmEnv'"
$envList = cmd /c `"$EdmExe`" envs list 2`>`&1
if ($envList -match "\b$EdmEnv\b") {
    Write-Host "Environment '$EdmEnv' already exists — skipping creation."
} else {
    $BundleFile = Join-Path $AmiraRoot "python\bundles\3dSoftware_win64.json"
    if (-not (Test-Path $BundleFile)) { Fail "Amira bundle not found: '$BundleFile'" }
    Write-Host "Creating environment from bundle..."
    cmd /c `"$EdmExe`" envs import --force -f `"$BundleFile`" $EdmEnv
    if ($LASTEXITCODE -ne 0) { Fail "EDM environment creation failed (exit $LASTEXITCODE)" }
}
