# 2>nul & @echo off & copy /y "%~f0" "%temp%\install_zarr_extensions.ps1" >nul & powershell -ExecutionPolicy Bypass -File "%temp%\install_zarr_extensions.ps1" %* & del "%temp%\install_zarr_extensions.ps1" >nul 2>&1 & pause & exit /b

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# === Configuration ===========================================================
$EdmExe   = "$env:USERPROFILE\AppData\Local\Programs\Enthought\edm\edm.bat"
$RepoBase = "https://raw.githubusercontent.com/janelia-cellmap/amira_python_extensions/master/src/extensions/zarr"
$Files    = @("ZarrRead.pyscro", "ZarrRead.rc", "ZarrWrite.pyscro", "ZarrWrite.rc")
$Packages = @("zarr==3.1.5", "numpy==1.26.4", "ome-zarr-models==1.7", "tensorstore==0.1.82")
# =============================================================================

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

# 3. Ask user which EDM environment to use
Write-Step "Choose an EDM environment"
$envsDir = "$env:USERPROFILE\.edm\envs"
if (-not (Test-Path $envsDir)) {
    Fail "No EDM environments found. Create one first inside Amira (Python -> Environment), then re-run this installer."
}
$envs = @(Get-ChildItem $envsDir -Directory | Select-Object -ExpandProperty Name)
if ($envs.Count -eq 0) {
    Fail "No EDM environments found. Create one first inside Amira (Python -> Environment), then re-run this installer."
}
for ($i = 0; $i -lt $envs.Count; $i++) {
    Write-Host ("  [{0}] {1}" -f ($i + 1), $envs[$i])
}
$choice = Read-Host "Enter the number of the environment to use"
$num = $choice -as [int]
if ($null -eq $num -or $num -lt 1 -or $num -gt $envs.Count) {
    Fail "Invalid selection: '$choice'."
}
$EdmEnv = $envs[$num - 1]
Write-Host "Using environment '$EdmEnv'."

# 4. Install Python packages
Write-Step "Installing packages into '$EdmEnv'"
& $EdmExe run -e $EdmEnv -- pip install @Packages
if ($LASTEXITCODE -ne 0) { Fail "pip install failed (exit $LASTEXITCODE)" }

# 5. Download scripts from GitHub and copy to Amira
$ScriptsDir = Join-Path $AmiraRoot "share\python_script_objects"
Write-Step "Deploying scripts to '$ScriptsDir'"
if (-not (Test-Path $ScriptsDir)) {
    New-Item -ItemType Directory -Path $ScriptsDir | Out-Null
}

foreach ($file in $Files) {
    $dest = Join-Path $ScriptsDir $file
    Write-Host "  $file"
    Invoke-WebRequest -Uri "$RepoBase/$file" -OutFile $dest -UseBasicParsing
}

Write-Step "Done. In Amira, go to Developer -> Python Environments -> Select Python Environment -> '$EdmEnv', then restart."
