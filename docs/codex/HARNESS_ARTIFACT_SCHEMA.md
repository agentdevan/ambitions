# Harness Artifact Schema

Status: supporting schema.

## Artifact root

Harness proof packets should be written under:

```text
docs/proof/harness/<batch-id>/<utc-timestamp>/
```

Each packet should include:

```text
artifact-manifest.json
artifact-summary.md
logs or reports created by the command
```

## Manifest fields

```json
{
  "schema_version": "1.0",
  "batch_id": "HARNESS-T00-B01-baseline-audit",
  "status": "Green|Yellow|Red",
  "started_at_utc": null,
  "finished_at_utc": "2026-05-29T00:00:00Z",
  "git": {
    "branch": "main",
    "commit_sha": "...",
    "status_short": "..."
  },
  "environment": {
    "machine": "...",
    "platform": "...",
    "macos_version": "...",
    "xcode_version": "...",
    "xcodegen_version": "...",
    "python_version": "..."
  },
  "commands": [],
  "artifacts": [],
  "claims_made": [],
  "claims_not_made": [],
  "risks": [],
  "next_recommended_step": null
}
```

## Status rules

Green means the scoped operation is supported by current artifact evidence.

Yellow means useful work happened but local tooling, manual review, or proof is incomplete.

Red means the scoped operation failed or crossed an approved boundary.
