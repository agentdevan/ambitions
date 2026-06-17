# AOM-00 Risk Register

## 1) Canonical IA drift through compatibility routes
- **Risk**: Legacy compatibility routes (e.g., `plan`, `captures`, `pulse`) could appear as active shell affordances and regress authority.
- **Evidence**: `LegacyIARouteCompatibility` in `Native/Ambitions/App/AppTab.swift`.
- **Impact**: Product-language violation and ambiguous IA.
- **Mitigation**: Enforce `AppTab` contract; ensure all canonical paths continue to resolve only through validated legacy compatibility layer and keep tab list fixed to Today/Goals/Time/Motion/You.

## 2) Capture reappearing as a root tab/action surface
- **Risk**: Route changes in shell or command handling could surface capture as a top-level destination.
- **Evidence**: Capture entry seams are in `ShellCommandModels.swift`, `ShellCommandRouter.swift`, and `AppNavigation` overlay routing.
- **Impact**: Violates explicit IA law and likely contract/validator failures.
- **Mitigation**: Keep capture as composer overlay/command path; forbid new tab additions or root destinations.

## 3) Motion interpreted as a dashboard/feed
- **Risk**: Motion UI could shift toward dashboard or list-feed behavior unrelated to object-stage behavior.
- **Evidence**: Motion behavior is object-stage driven in `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift` and shell action routing.
- **Impact**: Product regression, trust/legal/completion-state ambiguity.
- **Mitigation**: Preserve existing motion semantics and verify via existing integration/tests and contract artifacts.

## 4) Trust/receipt paths being bypassed in edits
- **Risk**: Changes to surface composition may detach trust/proof surfaces from You or action history repositories.
- **Evidence**: `YouTrustHistoryCenterCard`, `YouCrossSurfaceProofReviewCard`, `YouViewModel`, persistence proof repositories.
- **Impact**: Reduced auditability and proof continuity.
- **Mitigation**: Keep trust inspection surfaces in You and ensure repository bindings in `AppContainerFactory.swift` remain intact.

## 5) SwiftData schema/bootstrapping churn without audit trail
- **Risk**: Persistence wiring edits could silently alter container/model composition and break existing migration assumptions.
- **Evidence**: `SwiftDataStore.swift`, `SwiftDataModels.swift`, `AppContainerFactory.swift`.
- **Impact**: Data access regressions and offline integrity risk.
- **Mitigation**: Map all SwiftData touchpoints before changes and require compile-time/validator evidence before any schema wiring adjustments.

## 6) Validation command drift in runner path
- **Risk**: Required validator commands are not executed through expected policy runner context.
- **Evidence**: Train manifest marks this as required and direct execution is constrained.
- **Impact**: False-confidence closeout or audit non-compliance.
- **Mitigation**: Run all four required commands and record status explicitly in final report (or explicitly mark any blocker).
