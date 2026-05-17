# Ambitions Object Graph Architecture

Status: Active frontend canon overlay
Installed: 2026-05-16
Authority: Subordinate to `docs/truth/*`, `FRONTEND_AUTHORITY_INDEX.md`, and `FLAGSHIP_OBJECT_SYSTEM_DOCTRINE.md`; authoritative for object graph structure and future implementation sequencing where compatible.
Implementation claim: Docs-only. This architecture does not prove SwiftUI implementation, screenshot parity, accessibility conformance, performance, release readiness, or shipped behavior.

## Purpose

This file defines the front-end design graph required for Ambitions to produce world-class, living, adaptive, visually impressive, production-quality objects.

Ambitions must not be implemented as independent screens or decorative components. It must be implemented as a graph of semantic product objects whose state, proof, motion, accessibility, and rendering are explicit.

## Graph Summary

```text
Truth Files
  -> Surface Universe
    -> Surface Recipes
      -> Flagship Objects
        -> Object Kernels
          -> State Machines
            -> Motion Contracts
            -> Accessibility Contracts
            -> Proof / Receipt Contracts
              -> SwiftUI Renderers
                -> Preview Matrices
                  -> Tests / Visual Proof / Receipts
```

## Required Graph Node Types

| Node Type | Description | Example |
| --- | --- | --- |
| Truth Node | Highest authority product/runtime/release truth. | `PRODUCT_MOAT_TRUTH.md` |
| Surface Node | Visible app surface or state. | `today_start_here_region` |
| Object Node | Semantic product unit. | `StartHereSurface` |
| Kernel Node | Swift/domain model defining object meaning. | `StartHereObjectKernel` |
| State Machine Node | Allowed object states/transitions. | `RealityMeridianStateMachine` |
| Motion Node | Motion/haptic contract. | `AmbitionObjectMotionContract` |
| Accessibility Node | VoiceOver/Dynamic Type/reduced-motion behavior. | `AmbitionObjectAccessibilityContract` |
| Proof Node | Source/proof/receipt requirements. | `ReceiptDrawerProofContract` |
| Renderer Node | SwiftUI view rendering object state. | `StartHereSurfaceView` |
| Preview Node | Scenario matrix for object proof. | `StartHereObjectScenarios` |
| Test Node | Unit/UI/visual validation. | `StartHereObjectKernelTests` |
| Receipt Node | Implementation evidence. | `implementation-receipt.md` |

## Required Graph Edge Types

| Edge | Required Meaning |
| --- | --- |
| `truth_defines_surface` | Truth file defines valid product intent. |
| `surface_owns_object` | Surface owns a flagship object or subordinate object. |
| `object_uses_kernel` | Object has semantic/domain kernel. |
| `kernel_drives_state_machine` | Kernel state maps to visual state. |
| `state_uses_motion_contract` | State transition has motion/haptic behavior. |
| `state_uses_accessibility_contract` | State has VoiceOver/Dynamic Type/reduced-motion behavior. |
| `object_exposes_proof` | Object has source/proof/receipt/no-receipt behavior. |
| `object_renders_with` | Object maps to SwiftUI renderer. |
| `object_has_preview_scenarios` | Object has preview matrix. |
| `object_has_tests` | Object has tests. |
| `implementation_has_receipt` | Source change has receipt and proof. |

## Object Kernel Contract

Every object kernel must expose:

- `id`
- `objectID`
- `destination`
- `surfaceID`
- `primaryRole`
- `state`
- `context`
- `sourceQuality`
- `proofSummary`
- `receiptAvailability`
- `primaryAction`
- `secondaryActions`
- `motionToken`
- `accessibilitySummary`
- `previewScenarioID`
- `knownGaps`

Recommended Swift base concepts:

```swift
struct AmbitionObjectNode<ID: Hashable>: Identifiable, Equatable, Sendable {
    let id: ID
    let objectID: AmbitionObjectID
    let destination: AmbitionDestination
    let surfaceID: AmbitionSurfaceID
    let state: AmbitionObjectState
    let proof: AmbitionObjectProofSummary
    let motion: AmbitionObjectMotionContract
    let accessibility: AmbitionObjectAccessibilityContract
}
```

Concrete objects should use specialized kernels, not only a generic node.

## Object State Machine Contract

Every state machine must define:

- all supported states
- allowed transitions
- forbidden transitions
- transition trigger
- visual consequence
- motion token
- haptic policy
- receipt/proof consequence
- accessibility update
- rollback/undo behavior where relevant

Example transition shape:

```text
StartHereSurface.normal
  -> StartHereSurface.needsRecovery
Trigger: recommended step no longer fits current time context
Visual: Start Here expands to recovery explanation
Motion: correction / state settle
Receipt: required
User action: Review options / Adjust plan / Keep current
```

## Flagship Object Tiering

| Tier | Meaning | Required Proof |
| --- | --- | --- |
| FO-P0 | Primary destination object or Start Here. | full scenario, visual, accessibility, motion, source, and receipt proof |
| FO-P1 | Cross-surface trust/execution object. | targeted scenario, accessibility, interaction, and receipt proof |
| FO-P2 | Supporting object or state marker. | implementation receipt and targeted proof |
| FO-Candidate | Proposed future object. | docs and source-binding plan only |

FO-P0 objects:

- Reality Meridian
- Start Here Surface
- Constellation Atlas
- Atmosphere Composer
- LifeShape Field
- User System Profile

FO-P1 objects:

- Receipt Drawer
- Closure Sheet
- Recovery Sheet
- Adjust Plan / Reflow Preview
- Continuity Strip
- Step Detail
- Step Session
- Proof Trail
- Schedule Conflict Sheet
- Source Quality Line
- Local Proof Chip

## Required Future Swift Files

The first implementation batch should create or map these files, respecting existing source where equivalent files already exist:

```text
Native/Ambitions/DesignSystem/Objects/AmbitionObjectID.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectNode.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectState.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectAction.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectProof.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectMotionContract.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectAccessibilityContract.swift
Native/Ambitions/DesignSystem/Objects/AmbitionObjectPreviewContract.swift
Native/Ambitions/DesignSystem/Objects/RealityMeridianObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/StartHereObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/ConstellationAtlasObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/AtmosphereComposerObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/LifeShapeFieldObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/UserSystemProfileObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/ReceiptObjectKernel.swift
Native/Ambitions/DesignSystem/Objects/ClosureRecoveryObjectKernel.swift
```

## Required Future Preview Files

```text
Native/Ambitions/PreviewScenarios/ObjectPreviewScenario.swift
Native/Ambitions/PreviewScenarios/ObjectScenarioMatrix.swift
Native/Ambitions/PreviewScenarios/RealityMeridianObjectScenarios.swift
Native/Ambitions/PreviewScenarios/StartHereObjectScenarios.swift
Native/Ambitions/PreviewScenarios/ConstellationAtlasObjectScenarios.swift
Native/Ambitions/PreviewScenarios/AtmosphereComposerObjectScenarios.swift
Native/Ambitions/PreviewScenarios/LifeShapeFieldObjectScenarios.swift
Native/Ambitions/PreviewScenarios/UserSystemProfileObjectScenarios.swift
Native/Ambitions/PreviewScenarios/ReceiptClosureObjectScenarios.swift
```

## Required Future Renderer Files

Renderer files should preserve existing feature organization but move toward object-owned renderers:

```text
Native/Ambitions/Features/Today/Objects/RealityMeridianView.swift
Native/Ambitions/Features/Today/Objects/StartHereSurfaceView.swift
Native/Ambitions/Features/Today/Objects/CurrentTimeGlowView.swift
Native/Ambitions/Features/Goals/Objects/ConstellationAtlasView.swift
Native/Ambitions/Features/Captures/Objects/AtmosphereComposerView.swift
Native/Ambitions/Features/Time/Objects/LifeShapeFieldView.swift
Native/Ambitions/Features/Profile/Objects/UserSystemProfileView.swift
Native/Ambitions/Features/Shared/Objects/ReceiptDrawerView.swift
Native/Ambitions/Features/Shared/Objects/ClosureSheetView.swift
Native/Ambitions/Features/Shared/Objects/ContinuityStripView.swift
```

## Required Future Test Files

```text
Native/AmbitionsTests/Objects/AmbitionObjectGraphTests.swift
Native/AmbitionsTests/Objects/RealityMeridianObjectKernelTests.swift
Native/AmbitionsTests/Objects/StartHereObjectKernelTests.swift
Native/AmbitionsTests/Objects/ConstellationAtlasObjectKernelTests.swift
Native/AmbitionsTests/Objects/AtmosphereComposerObjectKernelTests.swift
Native/AmbitionsTests/Objects/LifeShapeFieldObjectKernelTests.swift
Native/AmbitionsTests/Objects/UserSystemProfileObjectKernelTests.swift
Native/AmbitionsTests/Objects/ReceiptClosureObjectKernelTests.swift
Native/AmbitionsUITests/ObjectInteractionUITests.swift
```

## Required Validation Gates

Future implementation must add or update scripts that verify:

- every FO-P0 object has a kernel
- every FO-P0 object has state machine coverage
- every FO-P0 object has preview scenarios
- every FO-P0 object has accessibility contract
- every FO-P0 object has motion contract
- every FO-P0 object has renderer binding
- every FO-P0 object has proof receipt or explicit unproven status
- every shallow display object is flagged unless subordinate to a flagship object
- no object uses forbidden generic productivity patterns

Recommended scripts:

```text
scripts/ambitions-object-graph-check.py
scripts/ambitions-flagship-object-contract-check.py
scripts/ambitions-object-preview-matrix-check.py
scripts/ambitions-object-accessibility-proof-check.py
scripts/ambitions-object-motion-proof-check.py
scripts/ambitions-object-source-binding-check.py
scripts/ambitions-flagship-object-quality-score.py
```

## Proof Artifact Structure

Future implementation batches should write proof to:

```text
build/reports/object-proof/<object-id>/scenario-matrix.json
build/reports/object-proof/<object-id>/accessibility.md
build/reports/object-proof/<object-id>/dynamic-type.md
build/reports/object-proof/<object-id>/reduce-motion.md
build/reports/object-proof/<object-id>/motion.md
build/reports/object-proof/<object-id>/visual-proof.md
build/reports/object-proof/<object-id>/screenshots/*.png
build/reports/object-proof/<object-id>/implementation-receipt.md
```

## Object Readiness States

| State | Meaning |
| --- | --- |
| `canon_only` | Object exists only in canon docs. |
| `source_bound_unproven` | Source exists but proof is missing. |
| `kernel_installed` | Semantic object kernel exists. |
| `state_machine_installed` | States/transitions are explicit. |
| `renderer_installed` | SwiftUI renderer exists. |
| `previewed` | Scenario previews exist. |
| `tested` | Unit/UI tests exist. |
| `proof_complete` | Required proof artifacts exist. |
| `flagship_ready` | Object passed all gates; not release-ready unless release truth says so. |

## Anti-Generic Enforcement

Objects fail if they could be dropped unchanged into a generic productivity app.

Failure patterns:

- task card
- dashboard tile
- calendar clone
- chat bubble feed
- settings clone
- motivational widget
- score/streak object
- AI confidence widget
- generic card stack
- static icon/title/subtitle component
- hidden mutation without receipt

## Installation Sequence

1. `FLAGSHIP-OBJECT-SYSTEM-01`: install docs, matrices, gates, and Swift core contracts.
2. `TODAY-FLAGSHIP-OBJECTS-01`: install Reality Meridian, Start Here, Current Time Glow, Step Detail.
3. `SHARED-RECEIPT-CLOSURE-OBJECTS-01`: install Receipt Drawer, Closure Sheet, Recovery Sheet, Reflow Preview.
4. `CAPTURE-ATMOSPHERE-OBJECT-01`: install Atmosphere Composer and post-capture routing.
5. `TIME-LIFESHAPE-OBJECT-01`: install LifeShape Field and Day/Week/Month object grammar.
6. `GOALS-CONSTELLATION-OBJECT-01`: install Constellation Atlas, lanes, proof trail, blockers.
7. `YOU-TRUST-PROFILE-OBJECT-01`: install User System Profile, local runtime trust panel, planning setup.
8. `OBJECT-PROOF-MATRIX-01`: generate proof matrix across all FO-P0 and FO-P1 objects.
9. `APP-DESIGN-AWARDS-READINESS-01`: audit production value, accessibility, interaction, visual distinctiveness, and proof without claiming award readiness.

## Hard Red Stops

Stop red if implementation would:

- create one-off screens instead of object graph nodes
- create shallow card components without semantic kernels
- bypass local-proof/receipt behavior
- hide plan mutation or reflow
- remove user control
- rely on color/glow/motion only
- reintroduce top-level Plan
- add chatbot-first destination
- use generic productivity patterns
- claim release or award readiness without proof

## Rollback

Rollback must be scoped to the object layer touched. If a flagship object implementation fails, keep doctrine unless doctrine conflicts with higher truth. Revert only source, proof, and docs introduced by the failing batch.