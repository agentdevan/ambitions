# Source Atlas M04 R2 Manifest/Freshness Evidence Note and Non-Claim Ledger

Status: current local R2 manifest/freshness/staging-plan evidence only; no R2 readiness or release readiness claim
Scope: AMB-1338 through AMB-1342 / M04 staging manifest, freshness, revocation, last-known-good, dry-run plan, promotion-gate handoff, and non-claim ledger
Branch: `source-atlas-train-02-m03-m04`
Baseline SHA: `86d609976c40be9f1601bd59ebf75ae29f0c17f4`
Date: 2026-06-26

This note records local M04 implementation evidence. It does not claim remote R2 staging, stable-channel promotion, R2 production freshness, app runtime fetch/cache, account/entitlement behavior, privacy/legal approval, known-issue closure, parent feature closure, or release readiness.

## Scope Boundary

M04 implemented local R2 infrastructure contracts only:

- R2-safe object layout contract
- release manifest schema contract
- freshness manifest schema contract
- revocation manifest schema contract
- last-known-good manifest schema and candidate writer
- dry-run promotion gate validator
- dry-run privacy verification fixtures
- non-claim ledger

No R2 upload, real promotion, app-side fetch/cache, account gating, entitlement flow, or runtime/cache integration was implemented.

## Artifact Inventory

R2 object layout and manifest schema files:

- `tools/source-atlas/foundry/contracts/r2-object-layout.json`
- `tools/source-atlas/foundry/contracts/release-manifest-schema.json`
- `tools/source-atlas/foundry/contracts/freshness-manifest-schema.json`
- `tools/source-atlas/foundry/contracts/revocation-manifest-schema.json`
- `tools/source-atlas/foundry/contracts/last-known-good-schema.json`

R2/freshness/promotion implementation:

- `tools/source-atlas/foundry/r2_contracts.py`
- `tools/source-atlas/foundry/publisher.py`
- `tools/source-atlas/foundry/validator.py`
- `docs/platform/SOURCE_ATLAS_R2_PROMOTION_GATE_SPEC.md`
- `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md`

Dry-run privacy verification fixtures:

- `tools/source-atlas/fixtures/r2/valid/public-reference-r2-plan.json`
- `tools/source-atlas/fixtures/r2/invalid/private-object-key-plan.json`
- `tools/source-atlas/fixtures/r2/invalid/missing-checksum-plan.json`
- `tools/source-atlas/fixtures/r2/invalid/credential-leak-plan.json`

Local smoke outputs:

- `/tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/r2-plan.json`
- `/tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/revocation-manifest.json`
- `/tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/last-known-good.json`
- `/tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/promotion-gate-dry-run.json`

## R2 Plan Evidence

- `python3 tools/source-atlas/source-atlas-foundry.py r2-plan --bundle-root /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke --bucket ambitions-source-atlas-staging --prefix source-atlas/v1 --channel staging --output /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/r2-plan.json`: passed; `validForUpload: true`, `objectKeyIssues: []`, `--remote` present in generated Wrangler arguments, no credentials included.
- The plan is local shape evidence only. It was not executed.

## Freshness/Revocation Evidence

- `python3 tools/source-atlas/source-atlas-foundry.py revocation-manifest --bundle-root /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke --output /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/revocation-manifest.json`: passed; all indexed artifacts active with checksums.
- `python3 tools/source-atlas/source-atlas-foundry.py last-known-good --bundle-root /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke --channel staging --output /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/last-known-good.json`: passed; LKG candidate points at manifest SHA `d10210acf1ac115b20bf04190773eaf3c9e6b98584222e5bfa2b6387464852db`.
- `python3 tools/source-atlas/source-atlas-foundry.py promotion-gate --bundle-root /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke --r2-plan /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/r2-plan.json --revocation /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/revocation-manifest.json --channel staging --output /tmp/ambitions-source-atlas-train02/train02-m03-m04-smoke/promotion-gate-dry-run.json`: passed; `dryRunOnly: true`, `wouldUpload: false`, `validForPromotion: true`, 9 checks passed.
- Negative fixture/test coverage proves failure paths for private object keys, missing checksums, revoked artifact use, and credential-looking payloads.

Local required gate evidence:

- `bash scripts/ci/ambitions-pr-review-local.sh --continue`: passed; 16 checks, 0 failed. Log: `/tmp/ambitions-pr-review-local-train02-final.log`.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard`: passed; `Test Build Succeeded`, `FAILURE_CLASS=passed`. Summary: `.codex/xcode-summaries/green-standard/20260626T174040Z/extract/summary.json`.
- `git diff --check`: passed.
- `python3 scripts/ambitions-green-standard-audit.py`: passed.
- `python3 scripts/source-atlas-boundary-audit.py`: passed; 40 targets.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`: passed.
- `python3 tools/source-atlas/source-atlas-foundry.py doctor`: passed.
- `python3 tools/source-atlas/source-atlas-foundry.py catalog`: passed.
- `python3 tools/source-atlas/source-atlas-foundry.py validate --help`: passed.
- `python3 tools/source-atlas/coverage.py --help`: passed.

## Known-Issue Mapping

No known issue was closed. AMB-ISSUE-2012 or any other known issue remains open unless separately reviewed and closed with its own evidence.

## Upload/Promotion Statement

No R2 upload was run. No stable-channel promotion was run. No Cloudflare Worker was deployed or invoked. No production bucket was touched.

## Validation Not Run

- No remote R2 staging or production upload.
- No deployed Worker promotion gate.
- No app runtime fetch/cache/offline fallback validation.
- No account/auth/entitlement validation.
- No privacy/legal approval.
- No TestFlight/App Store validation.
- No physical-device, visual, accessibility, or release validation.

## Non-Claim Ledger

M04 has current local evidence that a temporary Source Atlas bundle can compile, validate, produce a public/reference R2 staging-plan shape with no object-key issues, produce revocation and last-known-good candidate manifests, pass a dry-run promotion gate, pass the local PR review stack, and pass Xcode build-for-testing. No R2 upload was run. This does not prove remote R2 staging, production freshness, stable-channel promotion, deployed Worker promotion, app runtime fetch/cache, offline fallback, account or entitlement gating, privacy/legal approval, official source approval, AMB-ISSUE-2012 closure, release readiness, or App Store/TestFlight readiness.

## Remaining Gaps

- Remote R2 upload/promotion remains out of scope and unproven.
- Worker-side promotion gate deployment remains out of scope and unproven.
- App-side fetch/cache, pack verification, LKG cache use, entitlement gating, and offline fallback remain out of scope and unproven.
- Privacy/legal approval remains unproven.

## Closeout Block

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `tools/source-atlas/` Foundry tooling, `docs/platform/`, `docs/qa/source-atlas/`.
- Files moved or created: R2 contracts, promotion spec, fixtures, tests, and evidence note listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: none introduced for app source; no `Features/` ownership touched.
- Next repair train if debt remains: remote Worker/R2 promotion implementation and app runtime integration remain future trains, not M04 debt.
- No equivalent folder/path interpretation was used.
