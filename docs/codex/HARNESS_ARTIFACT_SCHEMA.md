# Harness Artifact Schema

Status: supporting schema.

## Artifact root

Harness inventory and proof-support packets should be written under:

```text
build/reports/harness/<batch-id>/<utc-timestamp>/
```

This slice does not use `docs/proof/harness/**` as the active output boundary. That path remains a later owner-approved destination if a future batch widens the scope.

Each packet should include:

```text
artifact-manifest.json
artifact-summary.md
wrapper-inventory.json
wrapper-inventory.md
```

## Manifest fields

```json
{
  "schema_version": "1.0",
  "batch_id": "HARNESS-T00-B01-baseline-audit",
  "mode": "inventory-only",
  "status": "Green|Yellow|Red",
  "started_at_utc": null,
  "finished_at_utc": "2026-05-29T00:00:00Z",
  "git": {
    "branch": "main",
    "commit_sha": "...",
    "status_short": "...",
    "dirty": false
  },
  "environment": {
    "machine": "...",
    "platform": "...",
    "release": "...",
    "python_version": "..."
  },
  "commands": [],
  "artifacts": [],
  "risks": [],
  "claims_not_made": [],
  "next_recommended_step": null
}
```

## Status rules

Green means the scoped operation produced the expected inventory or gate artifacts without boundary drift.

Yellow means useful work happened but the worktree is dirty or the packet is missing a non-blocking environmental detail.

Red means the scoped operation failed, the required files are missing, or a forbidden path drift was detected.
