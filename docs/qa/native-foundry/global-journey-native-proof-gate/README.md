# Search and Capture native-proof gate

Status: `READY_FOR_OWNER_GLOBAL_JOURNEY_PROOF_SELECTION`

This record decides whether the current Search and Capture evidence is sufficient for cross-root synthesis. It does not reopen Today, Goals, Time, or You, and it does not authorize implementation, runtime integration, cross-root synthesis, or `APPROVED_FOR_SWIFTUI`.

## 1. Verified baseline

- Repository: `agentdevan/ambitions`
- Starting `main`: `448ad0b9db62ac52d3e6f16b406254def123c970`
- Starting `origin/main`: `448ad0b9db62ac52d3e6f16b406254def123c970`
- Gate branch: `codex/global-journey-native-proof-gate`
- Gate branch base: `448ad0b9db62ac52d3e6f16b406254def123c970`
- Today, Goals, Time, and You remain provisionally closed and untouched.
- The four pre-existing primary-worktree Xcode user-scheme modifications are outside this worktree and remain protected.

The inventory uses these classifications:

- `PROVEN_BY_ACCEPTED_NATIVE_EVIDENCE`: owner-accepted, rendered native evidence directly exercises the claim.
- `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY`: the current native implementation and previously recorded focused execution support the claim, but no accepted Foundry evidence does.
- `PARTIALLY_PROVEN`: only part of the claim, state family, or end-to-end journey has current evidence.
- `UNPROVEN`: no qualifying current native proof was found.
- `OUTSIDE_CURRENT_CAPABILITY`: current authority excludes the behavior from the bounded baseline.
- `DEFERRED_TO_PRODUCTION_RECONCILIATION`: the proving slice may model the boundary, but production ownership or wiring must be reconciled later.

Source presence, contract text, enum cases, dormant routes, previews, tests not executed in this gate, and generated images are not counted as accepted native evidence.

## 2. Accepted existing authority

The binding product and presentation boundary comes from:

- [UX Blueprint](../../../canon/migration/UX_BLUEPRINT.md)
- [Navigation](../../../canon/specifications/app/navigation.md)
- [Shell](../../../canon/specifications/app/shell.md)
- [Search](../../../canon/specifications/global/search.md)
- [Capture](../../../canon/specifications/global/capture.md)
- [Visual System R1](../../../canon/design/VISUAL_SYSTEM_R1.md)
- [Surface Journey Closure](../../../canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md)
- [Accessibility Stress Closure](../../../canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md)
- [Native Matched Closure](../../../canon/design/VC_14_NATIVE_MATCHED_CLOSURE.md)

This authority establishes the intended journeys, not their proof status. Search and Capture are temporary global non-roots. Each must preserve its originating relationship, use one presentation owner, keep primary-object ownership distinct, and return exactly. Search owns finding, bounded understanding, inspection, and action preparation; it does not own consequential mutation. Capture owns expression, draft correction, interpretation review, and handoff; the canonical destination owner owns consequential mutation.

The current evidence floor is materially lower than that target:

- There is no Search or Capture Native Visual Foundry host, fixture family, accepted journey package, or accepted owner-review closeout.
- Existing Search/Capture workshop and VSP images are generated design evidence, not native proof.
- The current app contains Stage-owned Search and Capture implementations, focused tests, and previously recorded Simulator screenshots. The repository continues to label their device and acceptance proof as pending in [Known Issues](../../KNOWN_ISSUES.md) and the [frontend journey registry](../../../audits/frontend-journey-registry.md).
- The [frontend remediation ledger](../../frontend-flagship-shippability-remediation/EXECUTION_LEDGER.md) records earlier Simulator execution for Capture composition and the light/dark overlay matrix. Those artifacts establish implementation observations only; they were not accepted as Search or Capture Foundry calibration evidence.

Therefore no Search or Capture journey claim in this gate is classified `PROVEN_BY_ACCEPTED_NATIVE_EVIDENCE`.

## 3. Search proof inventory

Current implementation references include the Stage-owned [Search overlay](../../../../Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift), [overlay host](../../../../Native/Ambitions/Stage/AmbitionsStage.swift), [local result service](../../../../Native/Ambitions/Core/LocalRuntimeOS/Search/MemoryLensService.swift), [Find / Act / Inspect contract](../../../../Native/Ambitions/Core/LocalRuntimeOS/Search/FindActInspectContract.swift), [command router](../../../../Native/Ambitions/App/ShellCommandRouter.swift), and focused [Search route UI test](../../../../Native/AmbitionsUITests/GoalsSurfaceUITests.swift). They are not a substitute for accepted journey evidence.

| Proof claim | Classification | Current evidence and limit |
|---|---|---|
| Full-screen temporary non-root presentation | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Search is a Stage-level, edge-covering seam and the root dock is suppressed while it is active. Earlier Simulator overlay captures exist, but there is no accepted Search proof package or owner acceptance. |
| Originating-root relationship | `PARTIALLY_PROVEN` | `entrySource` and origin-biased search inputs are carried. Existing proof enters mainly by launch URL or isolated route; it does not demonstrate invocation from a retained root depth and exact restoration to that origin. |
| Query focus and keyboard behavior | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | The native field is focus-bound and requests focus on Search appearance. The current gate did not rerun a keyboard interaction, and no accepted focus/keyboard evidence exists. |
| Cancel and exact return | `PARTIALLY_PROVEN` | Close dismisses the overlay without changing the selected root. Exact root depth, scroll position, selection, and invoking-control focus restoration are not proven. |
| Representative local results | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | The local service produces goals, steps, captures, proof, receipts, Time, and settings results, and an existing UI test opens a Time result. A representative accepted rendered fixture family does not exist. |
| Compact result hierarchy | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Current rows expose family, source, state, title, context, action, and optional inspect indication. Earlier visual evidence calls the result treatment card-heavy; owner-accepted hierarchy proof is absent. |
| Find behavior | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Deterministic local ranking and origin bias exist and have focused tests recorded elsewhere. The current gate did not execute those tests. |
| Open behavior | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Trusted results route to typed destinations, including a previously exercised Time route. Exact return to Search after owner inspection is not proven. |
| Inspect behavior | `PARTIALLY_PROVEN` | Inspect metadata and an accessibility action exist for selected result kinds, but the visible UI does not prove a distinct compact inspection journey with source, freshness, and return continuity. |
| Bounded Understand behavior | `UNPROVEN` | Explanation data exists in lower-level contracts, but no accepted object-backed answer presentation, evidence disclosure, or rendered semantic order was found in the active Search UI. |
| Owner-routed action preparation without Search-owned mutation | `PARTIALLY_PROVEN` | Search routes trusted results and does not directly mutate saved objects. A distinct prepared action reviewed by the owning surface, with Search context and return preserved, is not proven. Production action authority remains subject to reconciliation. |
| No-results state | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | The active UI distinguishes an empty prompt from “No local match” and offers a Capture handoff. It has no accepted rendered proof. |
| One degraded state | `UNPROVEN` | Service errors collapse to an empty result array. No separate stale, unavailable, partial-index, or permission-constrained native state is proven. |
| Privacy suppression | `UNPROVEN` | Privacy filtering exists in a lower-level Find contract, while the active Memory Lens result path does not visibly distinguish suppressed results from no results. No native suppression proof was found. |
| Dynamic Type recomposition | `UNPROVEN` | SwiftUI text wrapping is present, but no Search-specific accessibility-size capture or focused geometry assertion proves the complete field/result/action hierarchy. |
| Semantic focus order | `UNPROVEN` | Result labels are combined, but no accepted ordered transcript or targeted focus-order assertion covers dismiss, query, status, results, inspection, and recovery. |
| Result selection and return focus | `PARTIALLY_PROVEN` | Result selection and owner routing exist. Return to the same query, selected result, scroll position, and invoking result focus after owner depth is not proven. |

**Search verdict:** Search does not possess sufficient accepted native evidence to enter cross-root synthesis. It requires one bounded fixture-driven native proving slice.

## 4. Capture proof inventory

Current implementation references include the full-height [activated Capture seam](../../../../Native/Ambitions/App/AppShellActivatedCaptureSeam.swift), [Capture object input](../../../../Native/Ambitions/Composer/Capture/CaptureAtmosphereComposer.swift), [placement review](../../../../Native/Ambitions/Composer/Capture/CaptureProposalStage.swift), [draft routing](../../../../Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureDraftRouteService.swift), and focused [Capture UI tests](../../../../Native/AmbitionsUITests/CaptureComposerUITests.swift). Earlier Simulator artifacts prove more of Capture’s current implementation than Search’s, but the program has never accepted them as bounded Foundry calibration evidence.

| Proof claim | Classification | Current evidence and limit |
|---|---|---|
| Full-screen temporary non-root presentation | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Focused UI tests previously asserted a Stage takeover, hidden root dock, keyboard clearance, and recovered height. The artifacts are Simulator implementation proof, not accepted Capture calibration evidence. |
| Originating-root relationship | `PARTIALLY_PROVEN` | Capture carries an `entrySource` into its local source label. Most focused proof uses a launch URL or command sheet and does not preserve a complete originating root/depth/focus tuple. |
| Initial expression focus and keyboard behavior | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | The activated seam requests focus and earlier UI execution captured the native keyboard and clearance. No accepted journey package owns that proof. |
| Retained original expression | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Placement review displays the original text, and editing is not cleared before successful save. The behavior is implementation evidence only. |
| Bounded interpretation | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Deterministic draft routing produces a bounded destination, object type, time fit, privacy posture, and change choices. The proving ceiling must remain the supported synthetic inputs; arbitrary semantic interpretation is outside scope. |
| One clarification state only when required | `UNPROVEN` | A clarification model and rendering primitive exist, but the active global seam and its focused tests do not prove one necessary clarification, its correction, and the absence of gratuitous clarification. |
| Consequential review | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | The active placement review retains captured text, destination, time fit, goal/area, local posture, alternatives, and pre-save actions. It lacks accepted owner review as a Capture Foundry journey. |
| Accept | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Earlier focused UI execution accepted the proposal and observed a local save status. That proves the current implementation path only. |
| Change | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Destination choices are visible and a focused UI test changed the selected route before acceptance. |
| Cancel | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Proposal cancellation returns to the draft without saving in current source. It was not separately captured and accepted. |
| Owner transfer without Capture-owned mutation | `DEFERRED_TO_PRODUCTION_RECONCILIATION` | Current acceptance executes a Capture command and can create a local Capture before later routing. A fixture can prove a prepared handoff boundary, but whether each destination owner receives and commits the canonical object requires production authority reconciliation. |
| Draft preservation through cancellation or failure | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | Proposal cancellation retains the in-session expression and failed saves retain editable text. Exact preservation through full dismissal, process loss, or relaunch is not established. |
| Exact dismissal and return | `PARTIALLY_PROVEN` | Dismissal reveals the underlying selected root, but exact route depth, scroll position, selection, and invoking-control focus restoration are not proven. |
| Dynamic Type recomposition | `PROVEN_BY_CURRENT_NATIVE_IMPLEMENTATION_ONLY` | A previous Accessibility XL UI path exercised input and proposal controls. No accepted Capture semantic-equivalent evidence or complete reading-order proof exists. |
| Semantic focus order | `UNPROVEN` | Accessibility labels and containment exist, but no focused ordered transcript proves expression, interpretation, clarification, review consequence, actions, and recovery order. |

**Capture verdict:** Capture has useful current native implementation evidence, but not sufficient accepted evidence for cross-root synthesis. It requires one bounded fixture-driven native proving slice.

## 5. Exact evidence gaps

### Shared gaps

- No accepted Search or Capture Foundry package, fixture contract, owner decision, or evidence ceiling.
- No proof beginning at a real provisionally closed root, retaining root route depth and selection, and returning the exact invoking control to focus.
- No accepted keyboard, Dynamic Type, semantic focus-order, and dismissal family under one controlled device profile.
- No evidence attribution that separates shell presentation behavior from Search-owned and Capture-owned behavior.

### Search-only gaps

- No bounded object-backed Understand state.
- No visible Inspect depth distinct from Open.
- No privacy-suppressed result treatment.
- No separate degraded state; current failures collapse into empty results.
- No complete owner-action preparation and return journey.
- No result-selection restoration to the same query, scroll position, and result focus.

### Capture-only gaps

- No one-and-only-one necessary clarification journey.
- No accepted comparison of original expression, bounded interpretation, practical consequence, and changed destination in one flow.
- No end-to-end proof that Cancel or failure preserves the draft and exact origin relationship.
- No fixture-bounded owner-transfer review that avoids claiming Capture-owned canonical mutation.
- No accepted semantic order for the complete expression-to-review journey.

## 6. Native-proof determination

| Global journey | Accepted native evidence sufficient for synthesis? | Native proof required? | Reason |
|---|---|---|---|
| Search | No | Yes, one bounded slice | Current implementation proves local Find and basic routing, but not accepted presentation, Understand, Inspect, degraded/privacy states, semantic order, or exact return. |
| Capture | No | Yes, one bounded slice | Current implementation proof is stronger, but owner acceptance, clarification, exact return, draft recovery, transfer authority, and full accessibility order remain open. |

Passing existing tests again would not close these gaps. The missing artifact is a bounded, controlled, owner-reviewable native journey with explicit claim attribution.

## 7. Minimum proposed Search slice

Proposed fixture identity: `search-flagship/local-find-understand-inspect/v1`.

The smallest sufficient slice is one full-app, fixture-driven Search journey with immutable local records:

1. Begin on one provisionally closed root at a named invoking control; record root, route depth, scroll/selection state, and focus target.
2. Present Search full-screen with the native query field focused and keyboard visible.
3. Enter one deterministic query returning a compact mixed set: one Goal, one Step, one temporal object, and one local proof/source record.
4. Prove Find and Open with one result, then return to the same Search query, result position, and focus.
5. Prove a separate read-only Inspect state and one object-backed bounded Understand disclosure; neither mutates.
6. Prepare one owner-routed action, label it uncommitted, transfer to the owning surface for inspection only, and preserve Search return context. Production mutation remains absent.
7. Exercise a no-results state and exactly one degraded privacy-suppressed state; do not collapse them together.
8. Cancel Search and restore the exact originating root context and invoking-control focus.
9. Capture one accessibility-size semantic equivalent and assert the ordered focus sequence.

This is not a request for a Search redesign, broad index rebuild, production mutation, Ask mode, or Search-to-Capture expansion.

## 8. Minimum proposed Capture slice

Proposed fixture identity: `capture-flagship/bounded-expression-handoff/v1`.

The smallest sufficient slice is one full-app, fixture-driven Capture journey with an immutable draft and fixture-only handoff outcomes:

1. Begin on the same provisionally closed root substrate at a named Capture trigger; record origin, route depth, selection, scroll state, and focus target.
2. Present Capture full-screen with the expression field focused and the native keyboard visible.
3. Enter one supported expression with deterministic object and simple-time interpretation; retain the exact original text throughout review.
4. Exercise exactly one second fixture whose real ambiguity requires one clarification, then return to the corrected interpretation without opening a general conversation.
5. Show one consequential review with original expression, bounded meaning, destination owner, practical consequence, and explicit Accept, Change, and Cancel.
6. Change the destination once, cancel once while preserving the draft, and model one failure that leaves the draft editable.
7. Accept only into a fixture-level owner handoff or inspection state. Do not claim canonical mutation, durable settlement, Receipt, or Undo.
8. Dismiss and restore the exact originating root context and invoking-control focus.
9. Capture one accessibility-size semantic equivalent and assert expression → interpretation → clarification when present → consequence → actions order.

This slice must not reuse the current local-save result as proof of universal owner transfer. That production authority question remains deferred.

## 9. Recommended sequence and usage rationale

| Path | Risk and usage assessment |
|---|---|
| 1. Capture then Search | Capture exercises the more consequential draft, clarification, review, and handoff boundaries first. It creates the highest initial debugging and evidence-attribution risk and then repeats presentation/return work in Search. |
| 2. Search then Capture | Search is the lower-consequence first journey and can expose presentation and restoration faults earlier. Without an explicit shared substrate contract, Capture would still repeat the same proof work. |
| 3. Shared presentation substrate, then separate Search and Capture journeys | Lowest-risk and lowest-duplication path if the shared work is limited to shell-owned presentation, origin tuple, keyboard/focus containment, dismissal, and exact return. Search and Capture retain separate fixtures, primary objects, screenshots, tests, and owner decisions. |

**Recommendation:** path 3, ordered as shared shell contract → Search slice → Capture slice.

Search should exercise the substrate first because it is read-only and exposes presentation, keyboard, and restoration failures without draft or mutation ambiguity. Capture should then reuse the proven shell contract while adding expression, clarification, consequence, draft preservation, and owner-transfer proof.

The shared substrate is not a third product surface or an all-in-one prototype. It should be a small reusable host/test contract exercised separately by each journey. A combined Search-and-Capture prototype is rejected because it would blur primary objects, privacy states, owner handoff, capability ceilings, and evidence attribution.

## 10. Explicit exclusions

### Search

- Conversational Ask and open-ended synthesis: `OUTSIDE_CURRENT_CAPABILITY`.
- Search-owned mutation or generic action execution: `OUTSIDE_CURRENT_CAPABILITY`.
- Broad index reconstruction, cloud or network search, and speculative source families: `OUTSIDE_CURRENT_CAPABILITY`.
- Production consolidation of Memory Lens and Find / Act / Inspect models: `DEFERRED_TO_PRODUCTION_RECONCILIATION`.
- Production cross-root action commit and exact return wiring: `DEFERRED_TO_PRODUCTION_RECONCILIATION`.

### Capture

- App-owned dictation or microphone UI: `OUTSIDE_CURRENT_CAPABILITY`; ordinary system-keyboard dictation is not a proof target.
- Broad attachments and arbitrary external payload interpretation: `OUTSIDE_CURRENT_CAPABILITY`.
- Arbitrary semantic interpretation and universal conflict detection: `OUTSIDE_CURRENT_CAPABILITY`.
- Partial settlement, Capture-owned Undo, and durable relaunch restoration: `OUTSIDE_CURRENT_CAPABILITY`.
- Production owner mutation, canonical object persistence, and cross-owner settlement: `DEFERRED_TO_PRODUCTION_RECONCILIATION`.

### Program-wide

- No SwiftUI, fixtures, screenshots, image generation, Xcode, Simulator, runtime integration, canon modification, or cross-root synthesis is authorized by this gate.
- No existing root calibration is reopened.
- `APPROVED_FOR_SWIFTUI` remains false.

## 11. Architecture-sensitive assumptions

1. A full-app host is required for the next proof because a package preview cannot establish Stage ownership, native keyboard containment, root-depth restoration, or focus return.
2. The shared presentation contract must record a structured origin tuple, not only `ShellCommandEntrySource`; exact return requires root, route depth, selected object, scroll/selection state, and focus target.
3. Search currently presents `MemoryLensResult` while a separate Find / Act / Inspect contract carries richer privacy, provenance, explanation, and Inspect data. The proving fixture must not silently claim those models are reconciled in production.
4. Search failure currently collapses to an empty array. A fixture-only degraded state may prove the required anatomy, but production error and privacy-suppression sources remain a later reconciliation.
5. Capture’s activated seam currently performs a local Capture command on Accept. The proving fixture must stop at owner handoff or inspection so it does not establish the wrong mutation authority.
6. Existing closed-root Foundry hosts can supply visual substrate only. A root fixture host without the real Stage cannot prove global presentation or exact return.
7. Search and Capture may share presentation infrastructure, but they cannot share primary-object state, fixture records, action semantics, acceptance evidence, or review status.
8. Simulator evidence can support provisional calibration only. Physical-device, manual assistive-technology, production baseline, and runtime integration proof remain outside these slices unless separately performed and recorded.

## 12. Owner decision options

The owner may choose one of:

- authorize the recommended shared presentation-substrate contract followed by separate Search and Capture proving slices;
- authorize Search first, then decide whether its substrate is reusable for Capture;
- authorize Capture first despite its higher consequence and authority risk;
- request a narrower proof classification revision;
- defer Search and Capture and pause cross-root synthesis entry.

No option is selected by this record.

Final status: `READY_FOR_OWNER_GLOBAL_JOURNEY_PROOF_SELECTION`
