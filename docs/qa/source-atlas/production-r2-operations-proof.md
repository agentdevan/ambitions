# Source Atlas Production R2 Operations Proof

Status: Green for Source Atlas Production R2 Operations Proof only

Issue: AMB-1429 - Validation / Repair - Source Atlas Production R2 Operations Proof

Parent: AMB-1317 - M04 Parent Feature - R2 Staging Manifest + Freshness Infrastructure

Related context:

- `docs/qa/source-atlas/2026-06-26-source-atlas-final-closeout.md`
- `docs/qa/source-atlas/2026-06-26-source-atlas-final-closeout.json`
- `docs/qa/source-atlas/2026-06-26-m04-r2-evidence-note.md`
- Source Provenance + Freshness UX Design boundary, via Source Atlas public/reference freshness law

## Scope

This proof turns the prior accepted Yellow reason "Production R2 operations not proven" Green for this narrow operations-proof scope only.

It proves real R2 operations can store and serve public/reference Source Atlas artifacts under a production bucket validation prefix without private graph leakage.

It does not claim account readiness, app runtime production fetch, release readiness, privacy/legal approval, known issue closure, complete Source Atlas Green, complete app runtime Green, TestFlight readiness, or App Store readiness.

## Environment Inventory

Observed R2 buckets from `wrangler r2 bucket list`:

- `ambitions-source-atlas-dev`
- `ambitions-source-atlas-staging`
- `ambitions-source-atlas-prod`

Environment names:

- Staging bucket: `ambitions-source-atlas-staging`
- Production bucket: `ambitions-source-atlas-prod`
- Staging env keys: `SOURCE_ATLAS_R2_STAGING_BUCKET`, `SOURCE_ATLAS_R2_STAGING_PREFIX`
- Production env keys: `SOURCE_ATLAS_R2_PRODUCTION_BUCKET`, `SOURCE_ATLAS_R2_PRODUCTION_PREFIX`

Production proof prefix:

```text
source-atlas/v1/validation/amb-1429
```

The command requires explicit `--environment staging|production`. This proof used `--environment production`, bucket `ambitions-source-atlas-prod`, and the validation-only prefix above. It did not write to the main stable Source Atlas channel prefix.

Credential handling:

- Wrangler was installed and authenticated.
- The command recorded only credential environment variable names, never values.
- No credential values were committed or printed.
- Real operations required `--execute` and `--confirm-public-reference-only`.

## Allowed Object Shape

Allowed prefixes:

- `source-atlas/v1/validation/amb-1429/releases/`
- `source-atlas/v1/validation/amb-1429/channels/`
- `source-atlas/v1/validation/amb-1429/revocations/`
- `source-atlas/v1/validation/amb-1429/last-known-good/`

Allowed artifact classes:

- public release manifest
- public foundry pack
- public schema
- public shard
- public registry
- public provenance receipt
- public freshness manifest
- public revocation manifest
- public last-known-good manifest

Forbidden artifact classes:

- private life graph
- goals, captures, schedules, capacity
- Life Capital
- proof payloads and receipt payloads
- behavior history and inferred priorities
- user IDs
- access tokens, refresh tokens, and account secrets

## Synthetic Fixtures

Created public/synthetic fixtures under `tools/source-atlas/fixtures/r2/operations/`:

- `current-manifest.json`
- `stale-manifest.json`
- `stale-critical-manifest.json`
- `revoked-manifest.json`
- `last-known-good-manifest.json`
- `checksum-fixture.json`
- `invalid/invalid-private-key-fixture.json`
- `invalid/invalid-private-payload-fixture.json`

The invalid fixtures are marked as expected rejection fixtures and are not promotable public/reference truth.

## Operations Run

Generated public/reference bundle:

```bash
python3 tools/source-atlas/source-atlas-foundry.py compile --output-root /tmp/ambitions-source-atlas-r2-ops-proof --version-id source-atlas-r2-ops-proof-2026-06-27-stable --channel stable
```

Dry run:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode dry-run --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable
```

Result: planned 16 uploads, including generated revocation and last-known-good manifests.

Upload:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode upload-public-reference-artifact --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --execute --confirm-public-reference-only
```

Result: Green; 16 remote uploads succeeded.

Readback:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode readback --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --execute --confirm-public-reference-only --readback-root /tmp/ambitions-source-atlas-r2-ops-proof-readback
```

Result: Green; 14 remote release/channel objects read back.

Checksum:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode verify-checksum --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --readback-root /tmp/ambitions-source-atlas-r2-ops-proof-readback
```

Result: 14 of 14 readback checksums matched expected SHA-256 values.

Privacy checks:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode verify-object-key-privacy --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode verify-manifest --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable
```

Result: object-key privacy, payload privacy, manifest privacy, and log redaction passed with no issues.

Revocation:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode revoke --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --execute --confirm-public-reference-only
```

Result: Green; revocation manifest uploaded to production proof prefix.

Last known good:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode read-last-known-good --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --execute --confirm-public-reference-only --readback-root /tmp/ambitions-source-atlas-r2-ops-proof-readback
```

Result: Green; last-known-good manifest read back from production proof prefix.

Rollback selection:

```bash
python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode rollback-select --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --candidate-manifest tools/source-atlas/fixtures/r2/operations/stale-critical-manifest.json --last-known-good tools/source-atlas/fixtures/r2/operations/last-known-good-manifest.json
```

Result: selected `last-known-good` because the candidate was stale-critical.

## Command Output Snippets

- Upload: `Upload complete.`
- Readback: `Download complete.`
- Checksum: `14 of 14 readback checksums matched`
- Object-key privacy: `object_key_privacy passed`
- Manifest privacy: `bundle_manifest`, `payload_privacy`, and `manifest_privacy` passed
- Revocation: `Upload complete.`
- Last known good: `Download complete.`
- Rollback: `selected: last-known-good`

## Privacy Proof

Passed:

- object-key privacy checks
- payload no-private-graph checks
- manifest no-private-graph checks
- log redaction checks
- checksum readback verification
- revocation behavior
- last-known-good behavior
- rollback/select behavior

No private user data, private life graph data, goals, captures, schedules, capacity, Life Capital, proof payloads, receipt payloads, behavior history, inferred priorities, user IDs, access tokens, refresh tokens, or account secrets were uploaded.

## Rollback Plan

Remote rollback: this proof used a validation-only prefix. Production stable channel paths were not changed. If cleanup is required, delete or ignore objects under:

```text
source-atlas/v1/validation/amb-1429
```

Source rollback: revert the AMB-1429 branch changes to remove the command, fixtures, and evidence docs.

## Validation

Required validation passed:

- `git diff --check`
- `bash scripts/ci/ambitions-pr-review-local.sh --continue`
- `python3 scripts/ambitions-green-standard-audit.py`
- `python3 scripts/source-atlas-boundary-audit.py`
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
- `python3 -m pytest tools/source-atlas/foundry/tests/test_foundry.py tools/source-atlas/foundry/tests/test_boundary.py`
- `semgrep scan --config .semgrep/ambitions-source-atlas.yml --error`
- `python3 scripts/ci/ambitions-no-weak-implementation-scan.py`
- `python3 tools/source-atlas/source-atlas-foundry.py r2-operations-proof --mode dry-run --environment production --bundle-root /tmp/ambitions-source-atlas-r2-ops-proof/source-atlas-r2-ops-proof-2026-06-27-stable --bucket ambitions-source-atlas-prod --prefix source-atlas/v1/validation/amb-1429 --channel stable --output /tmp/ambitions-source-atlas-r2-ops-proof-evidence/dry-run-final-validation.json`

Validation not run: none for this narrow operations-proof scope.

## Non-Claims

This is not Green for:

- account readiness
- release readiness
- privacy/legal approval
- known issue closure
- complete Source Atlas project Green
- complete app runtime Green
- TestFlight readiness
- App Store readiness

## Architecture Closeout

- Final Architecture Tree inspected: yes
- Canonical owners touched: `tools/source-atlas/`, `docs/qa/source-atlas/`, `scripts/`
- Files moved or created: `tools/source-atlas/foundry/r2_operations_proof.py`, R2 operations fixtures, and this proof note/JSON
- Old/non-canonical paths removed: none
- Compatibility shims left behind: none
- Yellow architecture debt: none introduced
- Next repair train if debt remains: none for this operations-proof scope
- No equivalent folder/path interpretation was used
