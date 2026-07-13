# Task 21 semantic response — legacy read path

Model assignment: Ultra. Work read-only. Do not edit files, commit, run network tools, or use `.codex/canon-packs`, `docs/canon/generated/codex-consumption-benchmark.md`, or `tests/canon/fixtures/benchmarks`.

For each scenario below, use the pre-cutover Ambitions read path from `AGENTS.md` and active `docs/truth/*`, plus current source/tests only when needed. Produce one compact JSON object per scenario with these exact keys: `scenario_id`, `applicable_requirement_ids`, `applicable_laws`, `source_owners`, `required_validation`, `required_proof`, `forbidden_changes`, `claim_ceiling`, `assumptions`, `contradictions`. IDs and paths must be exact when available. Never infer current implementation or proof from intended law. Keep product/runtime/visual/accessibility/privacy/device/release claims within current evidence.

Scenarios:

1. `today-swiftui`: SwiftUI work scoped to `surface.today.first-viewport`; changed owner `Native/Ambitions/Surfaces/Today/`; source claim.
2. `time-recurrence`: runtime work scoped to `surface.time.object-detail`; changed owner `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/`; runtime claim.
3. `capture-proposal`: SwiftUI work scoped to `global.capture.proposal-flow`; changed owners `Native/Ambitions/Composer/Capture/` and `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/`; source claim.
4. `local-runtime-mutation`: runtime work scoped to `system.runtime.mutation-sequence`; changed owners Commands, Transactions, and EventJournal under `Native/Ambitions/Core/LocalRuntimeOS/`; runtime claim.
5. `cloudkit-continuity`: privacy work scoped to `system.continuity.user-owned-cloudkit`; changed owner `Native/Ambitions/Core/LocalRuntimeOS/Continuity/`; privacy-proof claim.
6. `source-atlas-boundary`: privacy work scoped to `system.source-atlas.egress-firewall`; changed owners SourceAtlas and Boundary under `Native/Ambitions/Core/LocalRuntimeOS/`; privacy-proof claim.
7. `accessibility-repair`: SwiftUI work scoped to `accessibility.dynamic-type`; changed owners `Native/Ambitions/Interaction/Accessibility/` and `Native/Ambitions/Quality/Accessibility/`; accessibility-proof claim.
8. `release-proof-claim`: release work scoped to `engineering.release.claim-ceiling`; changed owners `Native/Ambitions/Quality/` and `docs/canon/`; release-proof claim.

Return only a JSON array in scenario order followed by a one-sentence proof ceiling.
