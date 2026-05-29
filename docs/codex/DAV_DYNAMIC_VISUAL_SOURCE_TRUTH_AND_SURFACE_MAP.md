# DAV Dynamic Visual Source Truth And Surface Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-15909831, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

Status: Historical/supporting DAV01 source-truth map; not SwiftUI implementation evidence.
Date: 2026-05-03

## Source Truth Hierarchy

1. `docs/truth/*` are the active repo authority.
2. Ambitions 3.0 material is historical source context only.
3. Ambitions 4.0 Execution Program owns active planned batch status and order.
4. PXOS owns future product-experience surface shape.
5. PXEQ owns product-experience equivalence and living-interface gates.
6. EB kernel canon owns External Brain trust, capture, memory, onboarding,
   accessibility, and receipt boundaries.
7. DAV owns implementation sequencing and visual primitive/surface evidence only.

DAV must not create duplicate canon for PXEQ, PXOS, SI, EB, trust, memory,
accessibility, or release claims. DAV implements or maps visual evidence against
those owners.

## Surface Owner Map

| Surface | Primary visual object | DAV batch | Swift owner boundary | Proof boundary |
| --- | --- | --- | --- | --- |
| Today | Reality Meridian / Start Here (historical aliases: DayTimelineRail, Hero Step Panel) | DAV03 | `Native/Ambitions/Features/Today/**`, shared `Sources/Components/**` only when using DAV02 primitives | Today behavior unchanged unless DAV03 tests prove it |
| Capture | CaptureAtmosphereComposer plus RoutingReceipt | DAV04 | `Native/Ambitions/Features/Capture/**`, shared `Sources/Components/**` | Capture remains composer-first; no persistence/routing raw changes |
| Time | LifeShapeMap plus capacity/pressure visuals (Plan compatibility seam) | DAV05 | `Native/Ambitions/Features/Plan/**`, shared `Sources/Components/**` | Time remains suggestion-only; no calendar-write claim |
| Goals | GoalMissionControlLanes | DAV06 | `Native/Ambitions/Features/Goals/**`, shared `Sources/Components/**` | No OKR/dashboard/task-list clone |
| You | SystemProfilePanel plus GroupedNavigationSystem | DAV07 | `Native/Ambitions/Features/Profile/**`, shared `Sources/Components/**` | You remains Personal System Center; no settings dump |
| Memory | ContextRecallCard and bounded MemoryConstellation | DAV08 | owned memory/trust drill-down surfaces or shared components only | Source, confidence, edit/delete, stale/rejected labels required |
| Trust / Receipts | TrustReceiptStack, EvidenceLabel, ProofPulse | DAV09 | trust/receipt surfaces or shared components only | Audit clarity without legal/release/privacy certification claims |
| Motion | Adaptive state transitions | DAV10 | shared components and touched surface files from DAV03-DAV09 | Reduce Motion equivalent required |
| Accessibility | Visual accessibility closeout | DAV11 | tests, reports, and narrow UI fixes only if needed | No public accessibility conformance claim |
| Previews | Scenario gallery | DAV12 | `Sources/Previews/**`, `Native/Ambitions/PreviewSupport/**` | Preview evidence only; not device proof |
| Performance | Rendering/battery risk | DAV13 | reports/scripts/tests; code only for bounded performance repair | No performance certification claim |
| QA | PXEQ/product experience QA | DAV14 | reports/tests/scripts | Technical pass can still be Yellow or Red for product experience |
| Closeout | DAV handoff | DAV15 | docs/reports/run-state | No release readiness or App Store/TestFlight claim |

## DAV02 Primitive Ownership

DAV02 may implement reusable native SwiftUI primitives in existing design-system
families, preferring `Sources/Components/**`, `Sources/Theme/**` only if needed,
and `Sources/Previews/**` for preview evidence. The required primitive names
are:

- `LivingSurfaceBackground`
- `AdaptiveModuleChrome`
- `EvidenceLabel`
- `PressureGlow`
- `ProofPulse`
- `ContextAtmosphereLayer`
- `QuietCommandSurface`
- `GroupedNavigationSystem`
- `LivingTabContext`
- `StateDrivenMaterialPanel`

DAV02 may add non-persistent visual state models if they are view-local,
Sendable where appropriate, and do not alter persistence, routes, enum raw
values, default tabs, dependencies, workflows, or app behavior outside the
rendered visual primitives.

## Motion And Accessibility Map

Every DAV UI batch must record:

- allowed motion and its state meaning;
- Reduce Motion static or low-motion equivalent;
- Dynamic Type behavior and text hierarchy;
- VoiceOver label/order/hint behavior;
- tap target and non-color meaning notes;
- before/after product-experience impact;
- preview or fixture evidence, or a no-UI explanation.

Motion must be finite, state-driven, and native SwiftUI. Infinite ambient motion,
multi-axis spectacle, spinning/vortex effects, fake intelligence glow, and
readability-reducing glass are Red unless the batch repairs them before commit.

## Preview Scenario Map

DAV12 owns full fixture closeout, but DAV02-DAV09 should add preview evidence
when they touch UI. Required scenarios are:

- calm normal day;
- overloaded day;
- recovery day;
- empty capture;
- routed capture;
- blocked step;
- Still Counts closure;
- goal with proof;
- goal with blocker;
- stale memory;
- rejected memory;
- private or sensitive memory;
- high Dynamic Type;
- Reduce Motion.

## Non-Claims

DAV01 does not implement production Swift, visual UI, app behavior, persistence,
routes/raw values, enum/raw values, dependencies, workflows, signing, TestFlight,
App Store readiness, release readiness, public accessibility conformance,
privacy certification, or physical-device proof.

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
