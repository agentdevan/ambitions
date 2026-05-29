# AmbitionsOS AOS Governance Kernel Registry

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active AOS23 Governance Kernel evidence
Date: 2026-05-07
Batch: AOS23 Governance Kernel Registry

## Purpose

This registry is the compact owner map for AmbitionsOS AOS train integrity after
AOS01-AOS22. It records which kernel owns each proven contract, what proof is
current, which gates remain closed before UI/runtime work can proceed, and what
the current evidence does not claim.

AOS23 is docs/Codex OS governance only. It adds no app behavior, production
Swift, routes, persistence/schema, signing, entitlement, dependency, generated
project, hosted workflow, platform integration, sync/cloud, AI runtime, LDI
runtime, model runtime, or release configuration change.

## Train Status

| Range | Status | Current proof |
| --- | --- | --- |
| AOS01 | Accepted Yellow | Runtime contract and governance overlay source truth; no runtime behavior. |
| AOS02-AOS17 | Green | Foundation, kernel, source, privacy, language, performance, and safety typed contracts with focused tests. |
| AOS18-AOS22 | Green | Evaluation, experience, adaptation, interoperability planning, and longevity typed contracts with focused tests. |
| AOS23 | Green after validation | Governance registry, ownership map, train-integrity rules, and current-state ledgers. |
| AOS24-AOS30 | Queued | Must satisfy predecessor and overlay gates before execution. |

## Kernel Ownership Map

| Kernel | AOS owner batches | Current evidence | Current boundary |
| --- | --- | --- | --- |
| Governance / Runtime Contract | AOS01, AOS23, later AOS27-AOS30 | Runtime contract, AOS train control docs, evidence ledger, this registry, AOS23 audit report. | Governance only; no runtime implementation or release claim. |
| Life Graph | AOS02, AOS03 | Event-log and graph-delta review contracts plus focused tests. | No persistence, graph store runtime, or Life Graph mutation. |
| Control Plane | AOS04 | Work request, gate, output, and deterministic classification contracts plus focused tests. | No orchestrator runtime or model invocation. |
| Starting Position | AOS05 | Baseline snapshot, intake, source/review, dignity-language, and path-fit contracts plus focused tests. | No intake runtime, profile persistence, or eligibility database. |
| Goal Path / Local Packs | AOS06, AOS07 | Goal compiler and Source Atlas anchored pack/slot contracts plus focused tests. | No path activation, pack runtime, or official requirement database. |
| Alternate Path / Option Value | AOS08, AOS09 | Path portfolio, proof-transfer, North Star, and option-value contracts plus focused tests. | No recommendation, transfer, path mutation, or ranking runtime. |
| Commitment Time / Reality Drift | AOS10, AOS11 | Capacity-fit, drift, bounded reflow, review, and receipt contracts plus focused tests. | No EventKit/Reminder writes, schedule mutation, notification behavior, or reflow runtime. |
| Proof Trust | AOS12 | Proof receipt, closure prompt, source/freshness, professional-boundary, and mutation-evidence contracts plus focused tests. | No persistent receipt store or UI integration. |
| Source Truth | AOS13 | Claim state, source quality, freshness/review/privacy/risk contracts plus focused tests. | No source ingestion, OCR/PDF parsing, certification, or source ledger runtime. |
| Recommendation | AOS14 | Start Here recommendation, explanation, assumption, alternative, user-control, and no-confidence contracts plus focused tests. | No recommendation runtime, ranking engine, Start Here rendering, or model runtime. |
| Local Language | AOS15 | Local language plan, deterministic fallback, adapter-tier planning, tool-approval, and source/privacy gates plus focused tests. | No Foundation Models adapter, extraction runtime, tool bus, or hosted AI. |
| Performance Energy | AOS16 | Budget envelope, scheduler-contract, fallback-state, measurement-plan, and release-claim-evidence contracts plus focused tests. | No runtime scheduler, telemetry, Instruments automation, device measurement, or battery claim. |
| Privacy Safety | AOS17 | Sensitive-area, projection-policy, privacy-receipt, redaction, tool-approval, and hidden-mutation contracts plus focused tests. | No privacy compliance, legal approval, durable memory, external projection runtime, or public accessibility claim. |
| Evaluation | AOS18 | Evaluation suite, scenario, oracle, fixture-family, repair-owner, and evidence-link contracts plus focused tests. | No evaluation runner, generated fixture library, model evaluation runtime, or LDI runtime. |
| Experience | AOS19 | Surface/object, wayfinding, density, accessibility posture, privacy-label, and no-drift contracts plus focused tests. | No UI integration, rendered proof, visual redesign, or public accessibility conformance. |
| Adaptation | AOS20 | User-controlled calibration, assumptions, receipts, permission, deterministic fallback, and no-hidden-personalization contracts plus focused tests. | No personalization runtime, durable memory, hidden learning, or model runtime. |
| Interoperability | AOS21 | External-surface planning, source/freshness/review, redaction, tool approval, performance, and compatibility contracts plus focused tests. | No App Intent implementation, EventKit/Reminder writes, platform permission prompt, external invocation, or route/signing/project change. |
| Longevity | AOS22 | Archive-aging, legacy survival, proof/source continuity, redaction, restore/rollback, migration, and conflict-review contracts plus focused tests. | No archive runtime, restore runtime, schema migration, sync/cloud, merge runtime, or conflict-resolution runtime. |

## Gate Registry

- Predecessor gate: AOS01 is accepted Yellow; AOS02-AOS22 are Green. AOS23 may
  close after docs validation because it changes governance evidence only.
- HPS gate: AOS work inherits HPS object, proof, source, memory, recommendation,
  privacy, governance, and singular-experience constraints; no AOS batch may
  create surface, score, chatbot, or source-certification drift.
- Source Atlas / Pack Factory gate: source, freshness, provenance, review,
  pack-sprawl, and no-duplicate-pack gates precede consequential
  recommendations, external actions, and source-sensitive claims.
- Privacy gate: sensitive projection, external surfaces, tool actions, memory
  posture, and redaction requirements must stay explicit before runtime work.
- Accessibility gate: VoiceOver, Dynamic Type, Reduce Motion, non-color
  meaning, hit targets, cognitive load, and privacy-safe labels are
  pre-device gates.
- Visual gate: rendered simulator proof and human design review precede
  physical-device proof for UI-affecting batches.
- Performance gate: runtime-heavy work requires bounded budgets, fallback
  states, local measurement plans, and no release-style performance claims
  without measured evidence.
- Hosted-workflow gate: `.github/workflows` is intentionally absent; GitHub
  Actions, hosted CI, Actions artifacts, and `ios-validate.yml` are not valid
  current proof.
- Terminal-device gate: physical-device proof is terminal-only, final-only, not
  discovery, and begins only after every pre-device gate closes. A needs review device
  gate invalidates the release-candidate path and routes back to the owning
  repair batch; no code changes occur inside the device gate.

## Governance Metrics

AOS23 records governance metrics without user personal data:

- Pack/source coverage: every source-sensitive AOS contract names Source Atlas
  review, freshness, provenance, or pack-boundary gates before consequential
  use.
- Safety coverage: professional-boundary, crisis/safety, privacy, hidden
  mutation, harmful language, and unsupported claim gates remain explicit.
- Sync/platform coverage: sync/cloud, backend, account, EventKit, Reminders,
  widgets, App Intents, Live Activities, and platform permission behavior stay
  unclaimed unless a later scoped batch proves them.
- Evidence coverage: AOS01-AOS22 have ledger, traceability, test-impact, and
  audit evidence; AOS23 adds registry and train-integrity evidence only.

## Continuation Rule

Continue the next eligible global batch after AOS23 Green unless a Hard Red or
unrecoverable Red appears. Yellow advisories remain non-blocking only when each
has an owner, reason, follow-up, and recheck condition.

## Does Not Claim

AOS23 does not claim AmbitionsOS runtime implementation, an on-device reasoning
engine, production model behavior, LDI runtime, UI integration, rendered proof,
platform integration, sync/cloud readiness, legal/privacy compliance, public
accessibility conformance, physical-device proof, release readiness, TestFlight
readiness, App Store readiness, or hosted CI proof.

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
