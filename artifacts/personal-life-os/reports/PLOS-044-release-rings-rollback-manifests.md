# AMB-672 / PLOS-044 - Release Rings And Rollback Manifests

Status: Green for scoped documentation/control-plane release ring and rollback manifest specification after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-672
PLOS label: PLOS-044
Parent: AMB-612 / PLOS-M04
Scope: Specify staged release rings, promotion boundaries, rollback manifest metadata, safe retreat behavior, provenance preservation, ring-induced fetch complexity, and rollback drill evidence expectations.
Out of scope: Automated deployment tooling, promotion tooling, rollback tooling, rollback drill execution, runtime ring selection, runtime rollback evaluation, release tooling, pack publication, live R2 writes, Cloudflare/R2 configuration, credential creation, app source changes, dependency changes, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-672 / PLOS-044
- Linear issue: AMB-672
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped release ring and rollback manifest documentation; Yellow for automated deployment/promotion/rollback tooling, rollback drill evidence, runtime ring/rollback evaluation, live Cloudflare/R2 proof, bucket provisioning, network validation, privacy/legal, device, accessibility, performance, security certification, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: yes, already complete before this child; PLOS-M00 was not re-executed in AMB-672.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-672 documentation/control-plane spec after validation
- Yellow limits: no automated deployment/promotion/rollback tooling, rollback drill execution, runtime ring/rollback evaluation, release tooling, pack publication, live R2 writes, bucket provisioning, credential creation, privacy/legal/release/performance/accessibility/device proof, or M04 parent completion
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-672 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-673 / PLOS-045 only.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-672` by actual `AMB-*` identifiers.
- Active truth files, `AGENTS.md`, PLOS GOAL/run-state/queue/map/phase gates, PLOS validation/reporting/proof contracts.
- Source Atlas Factory goal, hardening plan, pack gate references, and R2 boundary standard.
- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`
- `artifacts/source-atlas-factory/r2/R2_IMMUTABLE_PACK_PATH_STRATEGY.md`
- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`
- `artifacts/personal-life-os/reports/PLOS-040-r2-bucket-object-layout-spec.md`
- `artifacts/personal-life-os/reports/PLOS-041-immutable-pack-path-strategy.md`
- `artifacts/personal-life-os/reports/PLOS-042-manifest-compatibility-spec.md`
- `artifacts/personal-life-os/reports/PLOS-043-freshness-revocation-manifests.md`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `tools/source-atlas/`

## Files Changed

- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`
- `artifacts/personal-life-os/reports/PLOS-044-release-rings-rollback-manifests.md`
- `artifacts/personal-life-os/validation/PLOS-044-ring-rollback-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-044-focused-ring-rollback-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-672-source-privacy-closeout-review.md`
- PLOS run-state/queue/map/phase-gate/changelog/decision/risk artifacts
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Ring / Rollback Spec

The ring/rollback spec is:

- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`

It defines:

- `dev`, `staging`, and `prod` release rings
- promotion evidence required before production eligibility
- rollback manifest fields for bad artifact, target artifact, reason, severity, manifests, release receipts, signer/trust state, and drill evidence
- provenance preservation rules that prevent overwrite/delete/relabel shortcuts
- current/revocation/freshness/compatibility interaction during safe retreat
- ring-induced fetch complexity and compact-control-document expectations
- future rollback/revocation drill evidence requirements

## Runtime Path Proof

Not applicable for this documentation/control-plane child. No app source changed and no runtime feature is claimed.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- Release ring and rollback metadata is public-reference-only and forbids private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, account ids, and write-token material.
- Rollback preserves bad and target provenance, release receipts, signer/trust state, manifest ids, reason, severity, effective date, and owner-visible operation receipt.
- Rollback cannot overwrite immutable bytes, delete receipts to hide failure, relabel older packs as new, promote unverified targets, or leave revoked/private-data-containing artifacts runtime-eligible.
- Production promotion is Red without a tested rollback path or explicitly recorded rollback drill owner.

## Accessibility Checks

Not applicable for this documentation/control-plane child. No UI changed and no accessibility proof is claimed.

## Performance Notes

The spec notes ring-aware reads increase control-manifest checks across current, compatibility, freshness, revocation, rollback, and release receipt artifacts. No measured network, battery, memory, or latency proof was run or claimed.

## Rollback / Failure Behavior

If this spec is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`, this report, and AMB-672 control-plane updates. Future release-ring/runtime promotion must remain blocked until staged promotion, rollback manifest, revocation, freshness, compatibility, source-boundary, drill-evidence, and provenance requirements are repaired.

## Validation

Commands run for AMB-672:

- `git status --short --branch` - clean on `main` before AMB-672 execution.
- Linear issue fetch for `AMB-672` - succeeded.
- Linear status update for `AMB-672` to In Progress - succeeded.
- `rg -n "ring|rollback|staged|released" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-044-ring-rollback-required-search-log.txt` - exited `0`, 18,808 lines, 2,180,035 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused ring/rollback search over Source Atlas artifacts, truth/codex laws, M03/M04 reports, Source Atlas domain models, and Source Atlas tools - exited `0`, 2,674 lines, 430,284 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-044-focused-ring-rollback-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-044-release-rings-rollback-manifests.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`
- `artifacts/personal-life-os/reports/PLOS-044-release-rings-rollback-manifests.md`
- `artifacts/personal-life-os/validation/PLOS-044-ring-rollback-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-044-focused-ring-rollback-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-672-source-privacy-closeout-review.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Remaining Yellow / Red

- Yellow: no automated deployment/promotion/rollback tooling, rollback drill execution, runtime ring/rollback evaluation, release tooling, pack publication, live R2 account proof, bucket provisioning, network validation, runtime fetch/cache/quarantine proof, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or performance proof.
- Yellow: AMB-612 parent closeout remains blocked by active M04 children, including unresolved duplicate-looking Backlog children `AMB-730` through `AMB-737` unless Linear later marks them Duplicate/Canceled or owner accepts them as non-blocking.
- Red blockers: none for AMB-672 scoped documentation/control-plane closeout.

## Follow-Up Issues Created

None.

## Next Issue To Run

After AMB-672 is committed, pushed, and closed in Linear, continue one child at a time with `AMB-673` / `PLOS-045`.

## Non-Claims

AMB-672 does not claim app source change, runtime feature implementation, automated deployment tooling, promotion tooling, rollback tooling, rollback drill execution, runtime ring selection, runtime rollback evaluation, release tooling implementation, pack publication, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, runtime fetch/cache/quarantine implementation, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, performance proof, owner approval, AMB-673 execution, or PLOS-M04 parent completion.
