# AMB-1061 parallel implementation guard prompt

Issue: AMB-1061
Train: M04.T04
Scope: Extend the existing Ambitions design-system component package with a canonical core reusable interaction primitive set for launch-path use. The work must reuse the existing AmbitionTheme, semantic token catalog, AdaptivePanel, AmbitionsActionButton, GroupedNavigationList, AmbitionChip, and chrome/control primitives instead of creating a duplicate component architecture.

Canonical owner to extend:
- Sources/Components/CoreReusableInteractionPrimitives.swift, new source-owned catalog/view wrappers for AMB-1061.
- Sources/Previews/CoreReusableInteractionPrimitivePreviews.swift, new preview/support gallery for component inventory and screenshot proof.
- Native/AmbitionsTests/App/CoreReusableInteractionPrimitiveTests.swift, focused tests for contract coverage, accessibility-ready states, launch-path actions, and generic-drift guards.

Allowed support metadata:
- docs/codex/concept-lock-registry.yml, limited to recording AMB-1061 as an allowed design-primitives train.
- artifacts/ambitions-master-build/validation/AMB-1061-parallel-guard-prompt.md.

Not authorized:
- new design-system root
- new theme root
- new material system
- duplicate button/chip/panel architecture
- root navigation changes
- Capture as a top-level tab
- product truth changes
- dependency additions
- telemetry
- network/provider work

Expected implementation pattern:
- define a small data contract for reusable interaction primitive roles, states, accessibility fallback, preview usage, and launch-path ownership.
- provide SwiftUI wrappers that compose existing primitives rather than restyling from scratch.
- include minimum tap target, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, disabled/loading, local-only/privacy, source-needed, recovery, waiting, and non-color-state semantics.
- preserve canonical user-facing language: Start here, Recommended step, Start now, Open step, Step.
- keep Capture as Global Capture / Atmosphere Composer, not a root destination.
- preserve runtime inspection vocabulary for any source/trust evidence: SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows remain the required inspection boundary.
