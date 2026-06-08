# run_workbench.ps1
# Launcher script for the Source Atlas Lakehouse Workbench on Windows

$WorkbenchDir = Join-Path $PSScriptRoot "..\tools\source-atlas\lakehouse-workbench"
$VenvDir = Join-Path $WorkbenchDir ".venv"
$RequirementsFile = Join-Path $WorkbenchDir "requirements.txt"
$EnvFile = Join-Path $WorkbenchDir ".env"
$EnvExampleFile = Join-Path $WorkbenchDir ".env.example"

Write-Host "🌌 Source Atlas Lakehouse Workbench Initializing..." -ForegroundColor Cyan

# 1. Virtual Environment check
if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating Python virtual environment in $VenvDir..." -ForegroundColor Yellow
    python -m venv $VenvDir
}

# 2. Activate Virtual Environment
$ActivateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $ActivateScript) {
    Write-Host "Activating virtual environment..." -ForegroundColor Gray
    & $ActivateScript
} else {
    Write-Error "Could not find virtual environment activation script at $ActivateScript"
    exit 1
}

# 3. Upgrade pip and Install dependencies
Write-Host "Installing requirements from $RequirementsFile..." -ForegroundColor Gray
python -m pip install --upgrade pip | Out-Null
pip install -r $RequirementsFile

# 4. Instate default .env if missing
if (-not (Test-Path $EnvFile)) {
    Write-Host "Setting up default .env from .env.example..." -ForegroundColor Yellow
    Copy-Item $EnvExampleFile $EnvFile
}

# 5. Launch Streamlit UI
Write-Host "Starting Streamlit workbench UI..." -ForegroundColor Green
streamlit run (Join-Path $WorkbenchDir "app.py")
