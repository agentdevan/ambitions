# AMB-671 / PLOS-043 - Freshness And Revocation Manifests

Status: Green for scoped documentation/control-plane freshness and revocation manifest semantics after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-671
PLOS label: PLOS-043
Parent: AMB-612 / PLOS-M04
Scope: Specify freshness windows, stale thresholds, revocation payloads, cache invalidation semantics, degraded-mode routing, and unsafe/stale state handling.
Out of scope: Background fetch implementation, runtime parser implementation, freshness evaluator implementation, revocation evaluator implementation, release tooling, pack publication, live R2 writes, Cloudflare/R2 configuration, credential creation, app source changes, dependency changes, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-671 / PLOS-043
- Linear issue: AMB-671
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped freshness and revocation manifest documentation; Yellow for background fetch/runtime evaluator implementation, release tooling, live Cloudflare/R2 proof, bucket provisioning, network validation, privacy/legal, device, accessibility, performance, security certification, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: yes, already complete before this child; PLOS-M00 was not re-executed in AMB-671.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-671 documentation/control-plane spec after validation
- Yellow limits: no background fetch/runtime evaluator implementation, release tooling, pack publication, live R2 writes, bucket provisioning, credential creation, privacy/legal/release/performance/accessibility/device proof, or M04 parent completion
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-671 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-672 / PLOS-044 only.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-671` by actual `AMB-*` identifiers.
- Live Linear M04 child list under `AMB-612`.
- Active truth files, `AGENTS.md`, PLOS GOAL/run-state/queue/map/phase gates, PLOS validation/reporting/proof contracts.
- Source Atlas Factory goal, hardening plan, pack gate references, and R2 boundary standard.
- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`
- `artifacts/source-atlas-factory/r2/R2_IMMUTABLE_PACK_PATH_STRATEGY.md`
- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`
- `artifacts/personal-life-os/reports/PLOS-040-r2-bucket-object-layout-spec.md`
- `artifacts/personal-life-os/reports/PLOS-041-immutable-pack-path-strategy.md`
- `artifacts/personal-life-os/reports/PLOS-042-manifest-compatibility-spec.md`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `tools/source-atlas/`

## Files Changed

- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/personal-life-os/reports/PLOS-043-freshness-revocation-manifests.md`
- `artifacts/personal-life-os/validation/PLOS-043-freshness-revocation-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-043-focused-freshness-revocation-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-671-source-privacy-closeout-review.md`
- PLOS run-state/queue/map/phase-gate/changelog/decision/risk artifacts
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Manifest Semantics Doc

The manifest semantics doc is:

- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`

It defines:

- freshness manifest required fields and stale-window behavior
- revocation manifest required fields and reason classes
- runtime eligibility routing for current, stale, source-needed, review-needed, contradicted, revoked, unknown, and missing states
- cache invalidation and offline/degraded behavior
- Golden Slice and Source Authority proof expectations for future implementation
- refresh cadence cost posture by risk class

## Runtime Path Proof

Not applicable for this documentation/control-plane child. No app source changed and no runtime feature is claimed.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- Freshness and revocation manifests are public-reference-only and forbid private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, and write-token material.
- Revoked packs, sources, claims, signers, manifests, hashes, or paths become runtime-ineligible even if cached, signed, compatible, or still available in R2.
- Stale, hard-expired, contradicted, unknown, or missing freshness/revocation states route to source-needed, review-needed, degraded, blocked, quarantine, or verified rollback; they do not silently pass as current.
- Missing or unverifiable freshness/revocation data is Red for production runtime use.

## Accessibility Checks

Not applicable for this documentation/control-plane child. No UI changed and no accessibility proof is claimed.

## Performance Notes

The spec notes that freshness and revocation manifests should be compact control documents and that refresh cadence should be risk-class based. No measured network, battery, memory, or latency proof was run or claimed.

## Rollback / Failure Behavior

If this spec is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`, this report, and AMB-671 control-plane updates. Future freshness/revocation runtime use must remain blocked until stale-state routing, revocation blocking, cache invalidation, offline grace, rollback, source-boundary, and compatibility requirements are repaired.

## Validation

Commands run for AMB-671:

- `git status --short --branch` - clean on `main` before AMB-671 execution.
- Linear issue fetch for `AMB-671` - succeeded.
- Linear status update for `AMB-671` to In Progress - succeeded.
- `rg -n "fresh|revok|stale" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-043-freshness-revocation-required-search-log.txt` - exited `0`, 4,316 lines, 709,007 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused freshness/revocation search over Source Atlas artifacts, truth/codex laws, M03/M04 reports, Source Atlas domain models, and Source Atlas tools - exited `0`, 1,086 lines, 202,511 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-043-focused-freshness-revocation-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-043-freshness-revocation-manifests.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/personal-life-os/reports/PLOS-043-freshness-revocation-manifests.md`
- `artifacts/personal-life-os/validation/PLOS-043-freshness-revocation-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-043-focused-freshness-revocation-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-671-source-privacy-closeout-review.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Remaining Yellow / Red

- Yellow: no background fetch/runtime evaluator implementation, release tooling, pack publication, live R2 account proof, bucket provisioning, network validation, runtime fetch/cache/quarantine proof, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or performance proof.
- Yellow: AMB-612 parent closeout remains blocked by active M04 children, including unresolved duplicate-looking Backlog children `AMB-730` through `AMB-737` unless Linear later marks them Duplicate/Canceled or owner accepts them as non-blocking.
- Red blockers: none for AMB-671 scoped documentation/control-plane closeout.

## Follow-Up Issues Created

None.

## Next Issue To Run

After AMB-671 is committed, pushed, and closed in Linear, continue one child at a time with `AMB-672` / `PLOS-044`.

## Non-Claims

AMB-671 does not claim app source change, runtime feature implementation, background fetch implementation, runtime parser implementation, freshness evaluator implementation, revocation evaluator implementation, release tooling implementation, pack publication, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, runtime fetch/cache/quarantine implementation, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, performance proof, owner approval, AMB-672 execution, or PLOS-M04 parent completion.
