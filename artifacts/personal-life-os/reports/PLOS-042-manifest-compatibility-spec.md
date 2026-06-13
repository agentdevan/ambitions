# AMB-670 / PLOS-042 - Signed Manifest And Compatibility Manifest

Status: Green for scoped documentation/control-plane signed manifest and compatibility manifest specification after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-670
PLOS label: PLOS-042
Parent: AMB-612 / PLOS-M04
Scope: Specify manifest roles, signing expectations, compatibility metadata, validation expectations, invalid-manifest quarantine, and fetch-size posture.
Out of scope: Runtime parser implementation, signature verification implementation, compatibility evaluator implementation, release tooling, pack publication, live R2 writes, Cloudflare/R2 configuration, credential creation, app source changes, dependency changes, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-670 / PLOS-042
- Linear issue: AMB-670
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped signed manifest and compatibility manifest documentation; Yellow for runtime parser/evaluator implementation, release tooling, live Cloudflare/R2 proof, bucket provisioning, network validation, privacy/legal, device, accessibility, performance, security certification, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: yes, already complete before this child; PLOS-M00 was not re-executed in AMB-670.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-670 documentation/control-plane spec after validation
- Yellow limits: no runtime parser/evaluator implementation, release tooling, pack publication, live R2 writes, bucket provisioning, credential creation, privacy/legal/release/performance/accessibility/device proof, or M04 parent completion
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-670 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-671 / PLOS-043 only.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-670` by actual `AMB-*` identifiers.
- Live Linear M04 child list under `AMB-612`.
- Active truth files, `AGENTS.md`, PLOS GOAL/run-state/queue/map/phase gates, PLOS validation/reporting/proof contracts.
- Source Atlas Factory goal, hardening plan, pack gate references, and R2 boundary standard.
- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`
- `artifacts/source-atlas-factory/r2/R2_IMMUTABLE_PACK_PATH_STRATEGY.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`
- `artifacts/personal-life-os/reports/PLOS-040-r2-bucket-object-layout-spec.md`
- `artifacts/personal-life-os/reports/PLOS-041-immutable-pack-path-strategy.md`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `tools/source-atlas/`

## Files Changed

- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/personal-life-os/reports/PLOS-042-manifest-compatibility-spec.md`
- `artifacts/personal-life-os/validation/PLOS-042-manifest-compatibility-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-042-focused-manifest-compatibility-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-670-source-privacy-closeout-review.md`
- PLOS run-state/queue/map/phase-gate/changelog/decision/risk artifacts
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Manifest Spec

The manifest spec is:

- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`

It defines:

- current, index, compatibility, freshness, revocation, and rollback manifest roles
- signing and integrity requirements
- compatibility metadata and fallback modes
- manifest size/fetch overhead expectations
- quarantine rules for unsigned, incompatible, unsupported, stale, revoked, mismatched, or private-data-containing manifests

## Runtime Path Proof

Not applicable for this documentation/control-plane child. No app source changed and no runtime feature is claimed.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- Manifests are public-reference-only and forbid private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, and write-token material.
- Unsigned or incompatible manifests cannot select runtime-eligible production packs.
- Unknown/revoked signer, hash mismatch, unsupported schema, missing release receipt, missing revocation reference, missing rollback reference, and private data are Red for production eligibility.
- Invalid manifests quarantine fail-closed and route to verified last-known-good, bundled public data, source-needed, needs-review, or blocked fallback.

## Accessibility Checks

Not applicable for this documentation/control-plane child. No UI changed and no accessibility proof is claimed.

## Performance Notes

The spec notes that manifests should be small pointer/control documents and avoid embedding full packs, large validation logs, screenshots, or source bodies. No measured network, battery, memory, or latency proof was run or claimed.

## Rollback / Failure Behavior

If this spec is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`, this report, and AMB-670 control-plane updates. Future manifest runtime use must remain blocked until signing, compatibility, quarantine, revocation, rollback, and source-boundary requirements are repaired.

## Validation

Commands run for AMB-670:

- `git status --short --branch` - clean on `main` before AMB-670 execution.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-670` - succeeded.
- Linear status update for `AMB-670` to In Progress - succeeded.
- `rg -n "manifest|compatib|sign" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-042-manifest-compatibility-required-search-log.txt` - exited `0`, 6,234 lines, 1,327,104 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused manifest compatibility search over Source Atlas artifacts, truth/codex laws, M03/M04 reports, Source Atlas domain models, and Source Atlas tools - exited `0`, 2,312 lines, 361,001 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-042-focused-manifest-compatibility-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-042-manifest-compatibility-spec.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/personal-life-os/reports/PLOS-042-manifest-compatibility-spec.md`
- `artifacts/personal-life-os/validation/PLOS-042-manifest-compatibility-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-042-focused-manifest-compatibility-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-670-source-privacy-closeout-review.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Remaining Yellow / Red

- Yellow: no runtime parser/evaluator implementation, release tooling, pack publication, live R2 account proof, bucket provisioning, network validation, runtime fetch/cache/quarantine proof, privacy/legal approval, release readiness, device proof, accessibility proof, or performance proof.
- Yellow: AMB-612 parent closeout remains blocked by active M04 children, including unresolved duplicate-looking Backlog children `AMB-730` through `AMB-737` unless Linear later marks them Duplicate/Canceled or owner accepts them as non-blocking.
- Red blockers: none for AMB-670 scoped documentation/control-plane closeout.

## Follow-Up Issues Created

None.

## Next Issue To Run

After AMB-670 is committed, pushed, and closed in Linear, continue one child at a time with `AMB-671` / `PLOS-043`.

## Non-Claims

AMB-670 does not claim app source change, runtime feature implementation, runtime parser implementation, signature verification implementation, compatibility evaluator implementation, release tooling implementation, pack publication, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, runtime fetch/cache/quarantine implementation, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, performance proof, owner approval, AMB-671 execution, or PLOS-M04 parent completion.
