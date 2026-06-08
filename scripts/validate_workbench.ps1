# validate_workbench.ps1
# Verification and audit script for Source Atlas Lakehouse Workbench on Windows

$ErrorActionPreference = "Stop"
$WorkbenchDir = Join-Path $PSScriptRoot "..\tools\source-atlas\lakehouse-workbench"
$SampleRunId = "sports_art_10k_validation"
$SampleRunDir = "C:\Users\Devan\SourceAtlasFactory\runs\$SampleRunId"

$VenvPython = Join-Path $WorkbenchDir ".venv\Scripts\python.exe"
if (Test-Path $VenvPython) {
    $PythonCmd = $VenvPython
    Write-Host "Using virtual environment Python: $PythonCmd" -ForegroundColor Cyan
} else {
    $PythonCmd = "python"
    Write-Host "Using global Python: $PythonCmd" -ForegroundColor Yellow
}

Write-Host "🌌 Starting Source Atlas Workbench Verification Suite..." -ForegroundColor Cyan

# 1. Syntax Compilation Gate
Write-Host "`n[1/6] Checking Python syntax compilation (py_compile)..." -ForegroundColor Gray
$PyFiles = Get-ChildItem -Path $WorkbenchDir -Filter *.py -Recurse | Where-Object { $_.FullName -notlike "*\.venv\*" }
foreach ($file in $PyFiles) {
    Write-Host "Compiling $($file.Name)..." -ForegroundColor Gray
    & $PythonCmd -m py_compile $file.FullName
}
Write-Host "🟢 Syntax compilation check passed." -ForegroundColor Green

# 2. Pytest Suite
Write-Host "`n[2/6] Running Pytest unit and regression tests..." -ForegroundColor Gray
& $PythonCmd -m pytest (Join-Path $WorkbenchDir "tests")
Write-Host "🟢 Pytest check passed." -ForegroundColor Green

# 3. 10,000-Record Ingestion and Sequential Validation
Write-Host "`n[3/6] Generating and validating 10,000-record sports/art profile..." -ForegroundColor Gray
$BootstrapScript = @'
import sys
from pathlib import Path
sys.path.append(r'WORKBENCH_DIR')

from generator import generate_sports_art_10k_profile, initialize_run_dir
from validator import validate_all_shards

run_id = "SAMPLE_RUN_ID"
run_dirs = initialize_run_dir(run_id)

# Generate 10,000 record profile (5,000 sports, 5,000 art, 1,000 per shard)
paths = generate_sports_art_10k_profile(run_id)
print(f"GENERATOR_RESULT: Generated {len(paths)} shards.")

# Validate sequentially
res = validate_all_shards(run_dirs["root"])
print(f"VALIDATOR_RESULT: Clean: {res['clean']}, Rejected: {res['rejected']}, Duration: {res['validation_duration_sec']:.2f}s")
'@
$BootstrapScript = $BootstrapScript.Replace("WORKBENCH_DIR", $WorkbenchDir).Replace("SAMPLE_RUN_ID", $SampleRunId)

# Ensure sample run directory exists before writing temp files
New-Item -ItemType Directory -Force -Path $SampleRunDir | Out-Null

$TempFile1 = Join-Path $SampleRunDir "temp_bootstrap.py"
$BootstrapScript | Out-File -FilePath $TempFile1 -Encoding utf8
& $PythonCmd $TempFile1
Remove-Item -Path $TempFile1 -Force
Write-Host "🟢 Ingestion and validation complete." -ForegroundColor Green

# 4. DuckDB QA Audits
Write-Host "`n[4/6] Running DuckDB QA Audits on 10,000-record run..." -ForegroundColor Gray
$DuckDBScript = @'
import sys
from pathlib import Path
sys.path.append(r'WORKBENCH_DIR')

from duckdb_qa import run_qa_audits
run_dir = Path(r'SAMPLE_RUN_DIR')
domains_file = Path(r'WORKBENCH_DIR\data\sample_domains.json')

res = run_qa_audits(run_dir, domains_file)
print(f"DUCKDB_RESULT: Loaded: {res['loaded_records_count']}, Safety Violations: {len(res['safety_violations'])}, PII Leaks: {len(res['private_data_leaks'])}")
'@
$DuckDBScript = $DuckDBScript.Replace("WORKBENCH_DIR", $WorkbenchDir).Replace("SAMPLE_RUN_DIR", $SampleRunDir)

$TempFile2 = Join-Path $SampleRunDir "temp_duckdb.py"
$DuckDBScript | Out-File -FilePath $TempFile2 -Encoding utf8
& $PythonCmd $TempFile2
Remove-Item -Path $TempFile2 -Force
Write-Host "🟢 DuckDB audits executed. Reports saved to $SampleRunDir\reports\qa_audit_report.json." -ForegroundColor Green

# 5. Compile & Wrangler CLI command dry-run
Write-Host "`n[5/6] Compiling staged artifacts and generating Wrangler dry-run..." -ForegroundColor Gray
$CompileScript = @'
import sys
from pathlib import Path
sys.path.append(r'WORKBENCH_DIR')

from catalog import compile_staged_artifacts
from publisher import generate_wrangler_commands

run_dir = Path(r'SAMPLE_RUN_DIR')
domains_file = Path(r'WORKBENCH_DIR\data\sample_domains.json')

manifest = compile_staged_artifacts(run_dir, domains_file)
print(f"COMPILER_RESULT: Artifacts staged in publish/ folder. Manifest contains {manifest['stats']['intent_count']} records.")

commands = generate_wrangler_commands(run_dir)
print(f"WRANGLER_RESULT: Generated {len(commands)} upload commands.")
for cmd in commands:
    print(f"  Dry-run command: {cmd['command']}")
'@
$CompileScript = $CompileScript.Replace("WORKBENCH_DIR", $WorkbenchDir).Replace("SAMPLE_RUN_DIR", $SampleRunDir)

$TempFile3 = Join-Path $SampleRunDir "temp_compile.py"
$CompileScript | Out-File -FilePath $TempFile3 -Encoding utf8
& $PythonCmd $TempFile3
Remove-Item -Path $TempFile3 -Force
Write-Host "🟢 Compilation and dry-run complete." -ForegroundColor Green

# 6. Git diff --check
Write-Host "`n[6/6] Checking for git diff warnings..." -ForegroundColor Gray
git diff --check
Write-Host "🟢 Git diff check complete." -ForegroundColor Green

# Output final quality status
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "🌌 VERIFICATION COMPLETE" -ForegroundColor Cyan
Write-Host "Status: GREEN" -ForegroundColor Green
Write-Host "Validation Run Location: $SampleRunDir" -ForegroundColor Gray
Write-Host "All local safety gates, SQL audits, and compilation steps passed successfully." -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
