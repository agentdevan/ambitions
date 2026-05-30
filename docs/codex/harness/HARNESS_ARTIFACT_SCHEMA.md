# HARNESS Artifact Manifest Schema

Status: supporting schema for harness docs/script lanes.

## Artifact root

Harness packets should be written under:

```text
build/reports/harness/<batch-id>/<utc-timestamp>/
```

Each packet should include:

```text
artifact-manifest.json
artifact-summary.md
wrapper-inventory.json
wrapper-inventory.md
```

## Required manifest fields

```json
{
  "schema_version": "1.0",
  "batch_id": "HARNESS-T02-B01-artifact-manifest-schema",
  "mode": "manual|inventory-only|build",
  "status": "Green|Yellow|Red",
  "started_at_utc": null,
  "finished_at_utc": "2026-05-30T00:00:00Z",
  "git": {
    "branch": "main",
    "commit_sha": "<sha>",
    "status_short": "<git status --short>",
    "dirty": false
  },
  "environment": {
    "machine": "<machine>",
    "platform": "<platform>",
    "release": "<os-release>",
    "python_version": "<python-version>"
  },
  "commands": [
    {
      "command": "<executed command>",
      "exit_code": 0,
      "output": "<captured output or null>"
    }
  ],
  "artifacts": [
    {
      "path": "<artifact path>",
      "exists": true
    }
  ],
  "risks": ["<risk text>"],
  "claims_made": ["<bounded claim>"],
  "claims_not_made": ["<explicit non-claim>"],
  "next_recommended_step": "<next bounded step>"
}
```

## Status model

- `Green`: scoped operation succeeded and required artifacts/fields were produced.
- `Yellow`: useful progress occurred with bounded gaps or environment limitations.
- `Red`: operation failed, required files are missing, or scope boundary drift occurred.

## Claim boundary

This schema supports harness proof packets only. It does not itself prove build, release, app readiness, accessibility, privacy/legal approval, device readiness, TestFlight, or App Store readiness.
