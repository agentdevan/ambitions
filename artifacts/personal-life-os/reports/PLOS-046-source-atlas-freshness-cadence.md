# AMB-674 / PLOS-046 - Source Atlas Freshness Cadence

Status: Green for scoped documentation/control-plane freshness cadence policy after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-674
PLOS label: PLOS-046
Parent: AMB-612 / PLOS-M04
Scope: Define Source Atlas refresh windows, check cadence, urgency tiers, freshness classes, revocation/safety precedence, stale-state behavior, and battery/network cost posture.
Out of scope: Background task implementation, runtime freshness evaluator implementation, runtime refresh scheduling, network code, manifest parsing, cache/quarantine storage, release tooling, pack publication, live R2 writes, Cloudflare/R2 configuration, credential creation, app source changes, dependency changes, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-674 / PLOS-046
- Linear issue: AMB-674
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped freshness cadence policy documentation; Yellow for background task/runtime implementation, live Cloudflare/R2 proof, bucket provisioning, network validation, privacy/legal, device, accessibility, measured performance, security certification, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: yes, already complete before this child; PLOS-M00 was not re-executed in AMB-674.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-674 documentation/control-plane cadence policy after validation
- Yellow limits: no background task implementation, runtime freshness evaluator, runtime refresh scheduling, release tooling, pack publication, live R2 writes, bucket provisioning, credential creation, network validation, privacy/legal/release/performance/accessibility/device proof, or M04 parent completion
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-674 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-675 / PLOS-047 only.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-674` by actual `AMB-*` identifiers.
- Active truth files, `AGENTS.md`, PLOS GOAL/run-state/queue/map/phase gates, PLOS validation/reporting/proof contracts.
- Source Atlas Factory goal, hardening plan, risk register, release ledger, and R2 boundary standard.
- M04 R2 specs from `R2_BUCKET_LAYOUT.md` through `R2_APP_FETCH_VERIFY_CACHE_QUARANTINE_PLAN.md`.
- M03/M04 reports for signing, R2 API compatibility, layout, immutable paths, manifest compatibility, freshness/revocation, release rings/rollback, and fetch/verify/cache/quarantine.
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`

## Files Changed

- `artifacts/source-atlas-factory/r2/R2_SOURCE_ATLAS_FRESHNESS_CADENCE_POLICY.md`
- `artifacts/personal-life-os/reports/PLOS-046-source-atlas-freshness-cadence.md`
- `artifacts/personal-life-os/validation/PLOS-046-freshness-cadence-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-046-focused-freshness-cadence-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-674-source-privacy-closeout-review.md`
- PLOS run-state/queue/map/phase-gate/changelog/decision/risk artifacts
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Cadence Policy

The cadence policy is:

- `artifacts/source-atlas-factory/r2/R2_SOURCE_ATLAS_FRESHNESS_CADENCE_POLICY.md`

It defines:

- freshness classes from stable reference to emergency revocation
- default control-check, soft-stale, and hard-expiry windows
- calm/routine/attention/urgent/stop urgency tiers
- revocation, signer, compatibility, rollback, source-authority, and privacy-boundary precedence over freshness
- stale-state contract for current, stale-allowed, source-needed, review-needed, hard-expired, and revoked/quarantined states
- battery/network cost posture that keeps launch local-first and uses compact control manifests before immutable pack fetches
- rollback and failure behavior that prefers stale-but-explicit over unverified freshness claims

## Runtime Path Proof

Not applicable for this documentation/control-plane child. No app source changed and no runtime feature is claimed.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- Freshness cadence does not override revocation, signer trust, compatibility, rollback, release receipt, source authority, jurisdiction/high-risk policy, or privacy-boundary checks.
- Public Source Atlas material remains public-reference-only; private user data, identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, account ids, and write-token material remain prohibited from R2.
- Stale state must be explicit: cached material may not be presented as current merely because it is available locally.
- High-risk and emergency revocation paths fail closed instead of using stale grace.

## Accessibility Checks

Not applicable for this documentation/control-plane child. No UI changed and no accessibility proof is claimed.

## Performance Notes

The policy accounts for battery/network cost by preferring verified local state at launch, compact control-manifest checks before immutable pack fetches, per-pack/source-family refresh instead of full-bucket sweeps, Low Power Mode/constrained-network deferral for calm/routine checks, and future measured proof before any performance Green claim. No measured startup, network, battery, memory, or latency proof was run or claimed.

## Rollback / Failure Behavior

If this policy is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_SOURCE_ATLAS_FRESHNESS_CADENCE_POLICY.md`, this report, and AMB-674 control-plane updates. Future runtime freshness work must remain blocked until cadence windows, urgency tiers, stale-state behavior, revocation precedence, battery/network cost, and source-authority requirements are repaired.

## Validation

Commands run for AMB-674:

- `git status --short --branch` - clean on `main` except AMB-674 generated validation logs before report/policy edits.
- Linear issue fetch for `AMB-674` - succeeded.
- Linear status update for `AMB-674` to In Progress - succeeded.
- `rg -n "fresh|cadence|refresh" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-046-freshness-cadence-required-search-log.txt` - exited `0`, 2,933 lines, 518,539 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused freshness/cadence search over Source Atlas artifacts, truth/codex laws, M03/M04 reports, Source Atlas domain models, and Source Atlas tools - exited `0`, 1,232 lines, 242,193 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-046-focused-freshness-cadence-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py --self-test` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-046-source-atlas-freshness-cadence.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_SOURCE_ATLAS_FRESHNESS_CADENCE_POLICY.md`
- `artifacts/personal-life-os/reports/PLOS-046-source-atlas-freshness-cadence.md`
- `artifacts/personal-life-os/validation/PLOS-046-freshness-cadence-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-046-focused-freshness-cadence-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-674-source-privacy-closeout-review.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Remaining Yellow / Red

- Yellow: no background task implementation, runtime freshness evaluator, runtime refresh scheduling, network fetching, manifest parsing, cache/quarantine storage, release tooling, pack publication, live R2 account proof, bucket provisioning, network validation, runtime proof, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
- Yellow: AMB-612 parent closeout remains blocked by active M04 children, including unresolved duplicate-looking Backlog children `AMB-730` through `AMB-737` unless Linear later marks them Duplicate/Canceled or owner accepts them as non-blocking.
- Red blockers: none for AMB-674 scoped documentation/control-plane closeout.

## Follow-Up Issues Created

None.

## Next Issue To Run

After AMB-674 is committed, pushed, and closed in Linear, continue one child at a time with `AMB-675` / `PLOS-047`.

## Non-Claims

AMB-674 does not claim app source change, runtime feature implementation, background tasks, runtime freshness evaluation, runtime refresh scheduling, network fetching, manifest parsing, cache/quarantine storage, release tooling implementation, pack publication, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, measured performance proof, owner approval, AMB-675 execution, or PLOS-M04 parent completion.
