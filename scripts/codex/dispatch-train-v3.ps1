# Dispatch Ambitions Codex Train V3 through GitHub Actions.
#
# Intended Windows/PowerShell operator usage:
#   pwsh ./scripts/codex/dispatch-train-v3.ps1 `
#     -StartBatch AMB-AOM-04 `
#     -EndBatch AMB-AOM-04 `
#     -RerunCompleted `
#     -RunXcodeBuild `
#     -RunTests focused `
#     -Watch
#
# Then replay AMB-AOM-06:
#   pwsh ./scripts/codex/dispatch-train-v3.ps1 `
#     -StartBatch AMB-AOM-06 `
#     -EndBatch AMB-AOM-06 `
#     -RerunCompleted `
#     -RunXcodeBuild `
#     -RunTests focused `
#     -Watch

[CmdletBinding()]
param(
    [string]$Repo = "agentdevan/ambitions",
    [string]$Workflow = "ambitions-codex-train-v3.yml",
    [string]$Train = "object-stage-mega-train",
    [string]$StartBatch = "auto",
    [string]$EndBatch = "auto",
    [ValidateSet("dry-run", "execute")]
    [string]$Mode = "execute",
    [ValidateSet("none", "batch")]
    [string]$CommitStrategy = "batch",
    [switch]$RunXcodeBuild,
    [ValidateSet("none", "focused", "full")]
    [string]$RunTests = "none",
    [int]$MaxBatches = 99,
    [switch]$RerunCompleted,
    [switch]$Watch
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Bool-String {
    param([bool]$Value)
    if ($Value) { return "true" }
    return "false"
}

Require-Command gh

$runXcode = Bool-String $RunXcodeBuild.IsPresent
$rerun = Bool-String $RerunCompleted.IsPresent

Write-Host "Dispatching Ambitions Codex Train V3" -ForegroundColor Cyan
Write-Host "Repo: $Repo"
Write-Host "Workflow: $Workflow"
Write-Host "Train: $Train"
Write-Host "Range: $StartBatch -> $EndBatch"
Write-Host "Mode: $Mode"
Write-Host "Commit strategy: $CommitStrategy"
Write-Host "Run Xcode build: $runXcode"
Write-Host "Run tests: $RunTests"
Write-Host "Rerun completed: $rerun"

$dispatchArgs = @(
    "workflow", "run", $Workflow,
    "--repo", $Repo,
    "-f", "train=$Train",
    "-f", "start_batch=$StartBatch",
    "-f", "end_batch=$EndBatch",
    "-f", "mode=$Mode",
    "-f", "commit_strategy=$CommitStrategy",
    "-f", "run_xcode_build=$runXcode",
    "-f", "run_tests=$RunTests",
    "-f", "max_batches=$MaxBatches",
    "-f", "rerun_completed=$rerun"
)

& gh @dispatchArgs

if ($Watch.IsPresent) {
    Start-Sleep -Seconds 5
    $runId = & gh run list `
        --repo $Repo `
        --workflow $Workflow `
        --limit 1 `
        --json databaseId `
        --jq '.[0].databaseId'

    if (-not $runId) {
        throw "Could not resolve latest workflow run id for $Workflow"
    }

    Write-Host "Watching run $runId" -ForegroundColor Cyan
    & gh run watch $runId --repo $Repo --exit-status
}
