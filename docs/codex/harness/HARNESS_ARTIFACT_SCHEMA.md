# Harness Artifact Manifest Schema

Status: active support schema.

This schema defines the machine-readable manifest emitted by the harness artifact
manifest tool. It is a support contract for docs/scripts batches only and does
not prove app behavior, build success, test success, or release readiness.

## Output Root

The default artifact packet root is:

```text
build/reports/harness/<batch-id>/<utc-timestamp>/
```

The manifest emitter should place the JSON manifest in that packet root unless
an explicit output path is supplied.

## Required Top-Level Fields

The emitted JSON manifest must include these top-level fields:

```json
{
  "schema_version": "artifact-manifest.v1",
  "batch_id": "HARNESS-T02-B01-artifact-manifest-schema",
  "mode": "inventory-only",
  "status": "Green",
  "created_at_utc": "2026-05-29T00:00:00Z",
  "started_at_utc": "2026-05-29T00:00:00Z",
  "finished_at_utc": "2026-05-29T00:00:00Z",
  "git": {
    "branch": "main",
    "commit_sha": "0123456789abcdef0123456789abcdef01234567",
    "status_short": "",
    "dirty": false
  },
  "environment": {},
  "commands": [],
  "artifacts": [],
  "risks": [],
  "claims_made": [],
  "claims_not_made": [],
  "non_claims": [],
  "notes": []
}
```

## Field Requirements

### `schema_version`

Must be `artifact-manifest.v1`.

### `batch_id`

Must be the batch identifier for the run that produced the manifest.

### `mode`

Must describe the run mode, such as `inventory-only`.

### `status`

Must be one of:

- `Green`
- `Yellow`
- `Red`

### Timestamp fields

- `created_at_utc`
- `started_at_utc`
- `finished_at_utc`

All timestamps must use UTC ISO-8601 format, for example `2026-05-29T00:00:00Z`.

### `git`

The `git` object must capture the current branch/SHA and dirty-state evidence:

- `branch`
- `commit_sha`
- `status_short`
- `dirty`

### `environment`

The `environment` object should capture local runtime context such as machine,
platform, release, shell, and Python version when available.

### `commands`

`commands` must be an array of command output metadata objects. Each item should
record the command string and the observed output metadata. At minimum, each
entry should preserve:

- `command`
- `exit_code`
- `started_at_utc`
- `finished_at_utc`
- `duration_ms`
- `stdout`
- `stderr`
- `stdout_truncated`
- `stderr_truncated`

### `artifacts`

`artifacts` must list the produced artifact paths or artifact records for the
run. The manifest should at least include the emitted JSON manifest path when it
is written to disk.

### `risks`

`risks` must record any known non-blocking concerns or Yellow-class caveats.

### `claims_made`

`claims_made` must list only the claims actually supported by the manifest
contents.

### `claims_not_made`

`claims_not_made` must explicitly list the claims the manifest does not make.
This field is required even when the list is empty.

### `non_claims`

`non_claims` must carry the proof boundary text for the manifest. It may mirror
`claims_not_made`, but it must still exist as a distinct field.

### `notes`

`notes` may contain short implementation notes, runner notes, or boundary notes.

## Status Rules

- `Green` means the manifest was emitted successfully and the recorded metadata
  does not contain a blocking issue.
- `Yellow` means the manifest was emitted successfully but carries a non-blocking
  caveat such as a dirty worktree or a deferred proof boundary.
- `Red` means the manifest could not be trusted as a clean record because a
  required field is missing, command execution failed, or the batch encountered a
  blocking error.

## Proof Boundaries

This schema does not prove:

- app build success
- test success
- accessibility validation
- performance validation
- device validation
- privacy/legal approval
- TestFlight readiness
- App Store readiness
- release readiness

If one of those claims is needed later, it must come from dedicated proof
artifacts, not this manifest alone.
