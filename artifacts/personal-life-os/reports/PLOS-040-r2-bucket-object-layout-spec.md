# AMB-668 / PLOS-040 - R2 Bucket/Object Layout Spec

Status: Green for scoped documentation/control-plane R2 bucket/object layout specification after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-668
PLOS label: PLOS-040
Parent: AMB-612 / PLOS-M04
Scope: Specify R2 bucket and immutable object-key organization for public Source Atlas packs, seeds, manifests, receipts, revocations, compatibility data, validation reports, and rollback manifests.
Out of scope: Provisioning production buckets, configuring Cloudflare/R2, creating credentials, performing live R2 writes, implementing runtime fetch/cache/quarantine behavior, changing app source, changing dependencies, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-668 / PLOS-040
- Linear issue: AMB-668
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped R2 bucket/object layout documentation; Yellow for live Cloudflare/R2 account proof, bucket provisioning, CORS/cache/header setup, network validation, production writes, app runtime fetch, privacy/legal, device, accessibility, performance, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; PLOS-M00 through PLOS-M03 were already complete before this child and were not re-executed in AMB-668.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-668 documentation/control-plane layout spec after validation
- Yellow limits: no live R2 writes, no bucket provisioning, no credential creation, no runtime fetch, no production pack publication, no security/privacy/legal/release/performance/accessibility/device proof
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-668 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-669 / PLOS-041 only. Do not execute AMB-971 because it is Canceled/non-authoritative.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-668` by actual `AMB-*` identifiers.
- Live Linear M04 child list under `AMB-612`.
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`
- `docs/codex/PLOS_GREEN_YELLOW_RED_REPORTING.md`
- `docs/codex/PLOS_VALIDATION_REGISTRY.md`
- `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md`
- `artifacts/source-atlas-factory/SAF_GOAL.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `.agents/skills/source-atlas-factory/references/source-atlas-pack-gates.md`
- `.agents/skills/source-atlas-factory/references/source-atlas-r2-boundary-standard.md`
- `artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md`
- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`
- `artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`
- `artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `tools/source-atlas/`

## Layout Artifact

The layout spec is:

- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`

It defines:

- dev/staging/prod or equivalent release-ring segregation
- immutable content-addressed object-key grammar
- allowlisted object families for packs, seeds, manifests, freshness, revocations, compatibility, validation reports, release receipts, and rollback manifests
- forbidden private-user-data classes
- manifest-first current pointer rules
- non-private metadata allowlist
- cache/fan-out expectations
- Red conditions for private data, runtime write authority, unauditable paths, and production writes without required proof

## M04 Child Classification Note

Live Linear currently shows canonical M04 children `AMB-668` through `AMB-675` in Backlog/In Progress ordering, `AMB-971` as Canceled/non-authoritative, and later duplicate-looking Backlog children `AMB-730` through `AMB-737` that are not marked Duplicate/Canceled by Linear as of this run. AMB-668 does not execute AMB-971 and does not classify or execute AMB-730 through AMB-737.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- R2 remains public-reference/source/pathing distribution only.
- The layout forbids user goals, captures, schedules, proof, receipts, replay, local learning, private source imports, diagnostics, support bundles, exports, user identifiers, analytics IDs, device IDs, private locations, raw private text, and secrets.
- Object keys are content-addressed and non-user-specific.
- Current pointers are signed manifest/index controlled, not mutable pack overwrites.
- Runtime eligibility remains blocked until future Source Atlas gates prove source binding, freshness, revocation, release receipt, rollback, compatibility, and review.

## Accessibility Checks

Not applicable for this documentation/control-plane child. No UI changed and no accessibility proof is claimed.

## Performance Notes

The layout considers cacheability and object fan-out by:

- keeping current manifests/freshness/revocation/compatibility/rollback objects compact and short-TTL
- keeping hash-addressed pack payloads immutable and long-TTL
- requiring manifest-first reads before payload reads
- requiring future range-read proof only when a concrete size/performance need exists

No network, battery, memory, app launch, or runtime fetch performance was measured.

## Rollback / Failure Behavior

If this layout is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md` and this report, and keep all R2 distribution local/staged until the layout is repaired. Any private data path in an R2 key/object/metadata/request/log is Red and blocks runtime or production distribution.

## Validation

Commands run for AMB-668:

- `git status --short --branch` - clean on `main` before AMB-668 execution.
- Linear issue fetch for `AMB-612` and `AMB-668` - succeeded.
- Linear status update for `AMB-612` and `AMB-668` to In Progress - succeeded.
- `scripts/codex/program-phase-gate.sh plos M04` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M04-20260612T212935.log`.
- `rg -n "bucket|object|manifest|receipt|revocation" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-040-r2-bucket-object-layout-required-search-log.txt` - exited `0`, 8,868 lines, 1,455,433 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused R2 layout search over Source Atlas artifacts, truth/codex laws, M02/M03 reports, Source Atlas domain models, and Source Atlas tools - exited `0`, 1,251 lines, 249,477 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-040-focused-r2-layout-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-040-r2-bucket-object-layout-spec.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`
- `artifacts/personal-life-os/reports/PLOS-040-r2-bucket-object-layout-spec.md`
- `artifacts/personal-life-os/validation/PLOS-040-r2-bucket-object-layout-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-040-focused-r2-layout-search-log.txt`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Non-Claims

AMB-668 does not claim app source change, runtime feature implementation, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, production pack publication, runtime fetch/cache/quarantine implementation, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, performance proof, owner approval, AMB-669 execution, or PLOS-M04 parent completion.
