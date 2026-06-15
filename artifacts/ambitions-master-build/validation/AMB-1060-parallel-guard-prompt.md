# AMB-1060 parallel implementation guard prompt

Issue: AMB-1060
Train: M04.T03
Scope: Extend the existing design-system token catalog with a flagship semantic foundation contract for material roles, typography roles, spacing rhythm, hierarchy, accessibility fallback, and native visual consistency. Include only the narrow screenshot-driven quality repairs needed for representative Today, Goals, Time, Motion, and You evidence to avoid clipped compact proof cells, stale Time wording, or truncated root header context.

Canonical owner to extend:
- Sources/Theme/SemanticDesignTokenCatalog.swift
- Native/AmbitionsTests/DesignSystem/SemanticDesignTokenCatalogTests.swift
- Native/Ambitions/App/AppShellView.swift, limited to root header context fit.
- Native/Ambitions/Features/Goals/GoalComponents.swift, limited to compact source/proof evidence cell fit.
- Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift, limited to Time wording.
- Native/Ambitions/Features/Time/TimeScreen.swift, limited to Time wording.
- Native/Ambitions/PreviewSupport/PreviewTimeScenarios.swift, limited to Time wording.

Allowed support metadata:
- docs/codex/concept-lock-registry.yml, limited to recording AMB-1060 as an allowed design-primitives train.
- artifacts/ambitions-master-build/validation/AMB-1060-parallel-guard-prompt.md.

Not authorized:
- new theme root
- new token generator
- new material system
- root navigation structure changes
- product truth changes
- dependency additions
- telemetry
- network/provider work

Expected implementation pattern:
- reuse AmbitionTokens and AmbitionTheme as the only source-owned theme bridge
- keep screenshot-driven UI repairs fit-only and copy-only, without changing routing or root destinations
- add focused tests and token inventory evidence
- keep Capture as the global action layer, not a root destination
- preserve runtime inspection vocabulary for any source/trust evidence: SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows remain the required inspection boundary.
