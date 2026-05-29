# DPTG00 Physical Device Terminal Gate Lock Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: future terminal release-candidate proof gate.
Type: terminal device proof governance.
App behavior: none until a later release-candidate gate explicitly runs device proof.

## Purpose

Lock physical-device proof as the final terminal release-candidate gate for Ambitions. The gate verifies a release candidate after all earlier code, product, visual, accessibility, performance, privacy/legal, platform, release, signed-RC, and claim-safety gates close.

## Entry Conditions

DPTG00 may begin only when all of the following are true:

- The candidate has a named release-candidate proof packet.
- Feature and product-object gates are Green or accepted Yellow with explicit release-safe owner/follow-up/recheck conditions.
- Primitive, intelligence, Source Atlas, Pack Factory, source/freshness, proof, privacy, trust, accessibility, visual, performance, platform, release, signed-RC, and claim-safety gates have closed.
- Signed archive and release-candidate provenance are proven by local terminal evidence.
- No active docs instruct operators to use GitHub Actions, hosted CI, or Actions artifacts as current validation proof.
- The physical-device plan is written before execution and contains exact devices, OS versions, build identity, commands, observations, failures, screenshots/log paths, and claim boundaries.

## Forbidden Preconditions

DPTG00 must not be used when:

- The device run is being used to discover missing implementation work.
- Any pre-device gate remains open.
- A release/platform/legal/privacy/accessibility claim depends on device proof alone.
- The candidate lacks local command logs and checked-in proof artifacts.
- Hosted CI, GitHub Actions, workflow artifacts, or `.github/workflows/**` are being treated as current proof.

## Failure Behavior

If the physical-device gate fails, the release candidate is invalidated. The train routes back to the owning repair batch for the needs review domain.

No code changes may occur inside DPTG00. The device gate records failure evidence, assigns the repair owner, and exits Red or Yellow according to the release-candidate impact.

## Proof Packet Requirements

The DPTG00 proof packet must include:

- release-candidate identifier
- commit SHA and local working-tree status
- local build/signing/archive evidence
- exact device model and OS version
- install method and terminal command evidence
- launch/smoke proof
- top-level surface smoke proof for Today, Goals, Capture, Plan, You
- Start Here Surface proof
- Capture composer proof
- Goal Detail / Mission Control proof
- Plan proof
- You proof
- Action Closure / recovery proof
- reduced-motion and accessibility smoke notes
- privacy/legal/platform/release claim boundaries
- failure log with owning repair batch when applicable

## No-Code-Changes Rule

DPTG00 is terminal validation only. It may not edit production Swift, tests, docs, scripts, project files, signing, entitlements, workflows, dependencies, runtime configuration, persistence/schema, or release configuration.

Any required repair belongs to a separate owning repair batch, followed by renewed pre-device closure and a new terminal device attempt.

## Acceptance

DPTG00 is Green only when terminal device proof passes from local terminal evidence and all claim boundaries remain evidence-bound. It cannot Green a release candidate with unclosed pre-device gates.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
