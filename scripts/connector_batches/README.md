# Ambitions Connector Batches

This directory is for deterministic source-changing batches that run through GitHub Actions on the self-hosted Mac runner.

The model is:

1. ChatGPT/GitHub Connector authors a manifest plus either a patch file or deterministic Python apply script.
2. GitHub Actions runs `scripts/connector_batches/runner.py` on the self-hosted Mac.
3. The runner applies the batch, validates allowed paths, runs guards/builds, commits, and pushes when requested.

This lane does not invoke `codex exec` and does not use model quota from the self-hosted Mac runner. It can only apply deterministic work already encoded in repo-owned batch files.

## Batch manifest

Each batch needs a JSON manifest under:

```text
scripts/connector_batches/manifests/<batch-id>.json
```

Patch batch example:

```json
{
  "id": "AMB-AOM-04",
  "title": "Capture Global Composer",
  "mode": "patch",
  "patch": "scripts/connector_batches/patches/AMB-AOM-04.patch",
  "allowed_paths": [
    "Native/Ambitions/App/",
    "Native/Ambitions/Features/Capture/",
    "Native/AmbitionsTests/App/",
    "Native/AmbitionsUITests/",
    "artifacts/object-stage-mega-train/"
  ],
  "source_required": true
}
```

Script batch example:

```json
{
  "id": "AMB-AOM-04",
  "title": "Capture Global Composer",
  "mode": "script",
  "script": "scripts/connector_batches/apply_AMB_AOM_04.py",
  "allowed_paths": ["Native/Ambitions/App/", "Native/AmbitionsTests/App/"],
  "source_required": true
}
```

## Dispatch

Use:

```powershell
pwsh -NoProfile -File .\scripts\connector_batches\dispatch-connector-batch.ps1 `
  -Batch AMB-AOM-04 `
  -CommitChanges `
  -RunXcodeBuild `
  -Watch
```

Or directly:

```powershell
gh workflow run ambitions-connector-batches.yml `
  --repo agentdevan/ambitions `
  -f batch=AMB-AOM-04 `
  -f commit_changes=true `
  -f run_xcode_build=true
```

## Completion rules

A source batch cannot complete Green with only artifacts. It must change at least one allowed app source or test file. A proof-only validation pass belongs in the validation workflow, not this source-changing lane.
