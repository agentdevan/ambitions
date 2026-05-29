# Moat Runtime Loop Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-79120370

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active control-plane overlay  
Batch: MRI00-MOAT-RUNTIME-GAP-LOCK

## Purpose

This matrix maps Ambitions' end-game product loops to current and future implementation work. It prevents component-only batch completion from being mistaken for product-loop completion.

## Loop Matrix

| Loop | End-Game User Outcome | Existing Coverage | MRI Coverage | Acceptance Proof |
|---|---|---|---|---|
| Capture-to-meaning | A raw capture becomes the correct durable object: proof, source, constraint, commitment, reflection, held item, goal seed, or ready-to-place action. | PK capture services, SA import/review plans, Capture visual canon | MRI14, MRI28, MRI37 | Capture examples route correctly, can be corrected, and create receipts. |
| Source-to-recommendation | A source/claim/freshness state can explain or constrain a recommendation. | SA07-SA32, PK33 recommendation evidence, PK34 quarantine | MRI09, MRI10, MRI11, MRI39 | Why This? shows source, claim state, freshness, reason, uncertainty, controls. |
| Start Here execution | Today recommends a step that fits actual reality and closes with proof or recovery. | PK Today service extraction, recommendation evidence, visual Today lane | MRI17-MRI24, MRI26, MRI36 | Start Here can explain fit, start step, close action, record receipt, reflow if needed. |
| Goal-to-life-direction | Goals belong to Ambition Graph hierarchy, not only standalone task containers. | Goals source, LDI/AOS plans, moat truth | MRI01-MRI08, MRI27 | Identity Direction -> Ambition -> Commitment -> Step -> Proof is visible and navigable. |
| Reality Fit / LifeShape | Time shows realistic capacity/pressure and affects recommended work. | PK cache/performance, Time visual canon, AOS planning | MRI17-MRI24, MRI29 | Protected/open time and pressure visibly affect Start Here and reflow. |
| Recovery and re-entry | Ambitions restarts from the last honest point without shame. | Closure states, recovery copy, moat truth | MRI03-MRI06, MRI20, MRI38 | Broken day creates Still Counts/Needs Recovery path with proof preservation. |
| Personal Runtime trust/control | User can inspect, reset, disable, delete, or correct local learning inputs. | PK data controls/privacy, You/Profile controls | MRI12, MRI13, MRI15, MRI30, MRI43 | You shows what Ambitions learned/used and supports reset/delete receipts. |
| Native Apple surfaces with receipts | Widgets/App Intents/Share/Notifications preserve command, policy, receipt, and trust boundaries. | PK side-effect ledgers, PFC plans | MRI31, MRI47 | External action creates guarded command/receipt and does not bypass local policy. |
| Visual runtime acceptance | Top-level surfaces feel like Ambitions, not generic productivity UI. | Visual canon/moat control-plane docs | MRI25-MRI34, MRI40, MRI45 | Screens pass anti-generic, object-first, native iPhone, accessibility-aware review. |
| Final proof/release gates | Readiness claims are made only after current proof. | RELEASE_TRUTH.md, PFC/RHC plans | MRI41-MRI44, MRI46-MRI50 | Build/test/device/accessibility/performance/privacy/release proof packets exist. |

## Gap Rules

If a batch contributes to a loop but does not close it, its report must state:

- the loop it supports,
- what artifact it adds,
- what loop behavior remains open,
- which later MRI/SA/AOS/FCP/PFC batch closes the behavior.

## Loop Completion Rule

A loop is complete only when the user-facing behavior, local runtime data flow, trust/receipt path, accessibility path, and validation proof all exist.

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
