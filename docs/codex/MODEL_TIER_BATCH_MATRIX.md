# Model Tier Batch Matrix

Status: Active Codex OS matrix for Mini/Senior batch routing.
Date: 2026-05-08
Scope: Remaining Ambitions global batch train routing under `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`.

This matrix is a routing aid, not source truth for product implementation. Current batch order still comes from `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md`, `docs/codex/BATCH_REGISTRY.md`, and `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.

## Routing Legend

| Route | Meaning |
| --- | --- |
| Mini-safe | Mini may execute if the active batch prompt/source truth is explicit and no senior-only gate appears. |
| Mini-safe with proof lock | Mini may implement or repair, but cannot close Green unless the named proof exists. Otherwise Yellow or defer. |
| Senior-review | Mini may prepare evidence, but Senior must close the judgment gate. |
| Senior-only | Mini must defer or stop. Senior owns execution/judgment. |
| Stop if blocking | Mini may not skip; stop Red for Senior if it blocks the next eligible batch. |

## Global Defaults

| Work type | Default route | Notes |
| --- | --- | --- |
| Docs-only source-truth reconciliation | Mini-safe | Senior required only for unresolved conflicts. |
| Registry/context/current-state updates | Mini-safe | Must cite repo evidence; no memory-only status changes. |
| Narrow copy/object-language updates | Mini-safe | No IA rewrite unless active source truth explicitly requires it. |
| Bounded SwiftUI owner-file implementation | Mini-safe with proof lock | Requires focused tests and rendered proof if UI-visible. |
| Domain/value-model contracts with focused tests | Mini-safe | No persistence/schema/runtime-store claim unless authorized. |
| Focused test repair from clear failure | Mini-safe | Stop after two same-root repair attempts. |
| Release/legal/privacy/device/accessibility/human approval claims | Senior-only | Mini may inventory evidence only. |
| Source-truth conflict resolution | Senior-only | Mini may collect evidence but not decide. |
| Route/raw-value compatibility retirement | Senior-only | Mini may inventory seams only. |
| Persistence/schema migration | Senior-only | Mini may write docs/test plans only if scoped. |
| Dependency/signing/entitlement/workflow changes | Senior-only | Mini must stop unless explicitly authorized and non-release-impacting. |
| Sync/cloud/account/backend runtime | Senior-only | Mini may write docs or local-only closure only if scoped. |
| Hosted AI/model runtime/tool bus | Senior-only | External LLMs are not core architecture; Mini may not introduce them. |
| Final visual/founder/taste judgment | Senior-review or Senior-only | Mini may generate screenshot inventory, not final approval. |

## Remaining Known Batch Families

### AFI09-AFI12

Route: Mini-safe with proof lock.

Mini may execute Time LifeShape Field, You User System Profile, Trust Seam / Receipts, and Accessibility / State Proof when the active AFI source truth gives exact owner files and proof requirements.

Mini must not close Green when screenshot, accessibility, Reduce Motion, or human/founder proof is required but missing. Record Yellow or defer.

### AFI13-AFI16

Route: Senior-review / Senior-only.

- AFI13 Visual QA And Drift Gallery: Mini may collect screenshots and scorecard inputs; Senior closes final visual score.
- AFI14 Cross-Surface Coherence Review: Mini may inventory cross-surface evidence; Senior closes coherence judgment.
- AFI15 Founder Acceptance Review: Senior-only unless the founder provides explicit acceptance text in the same run.
- AFI16 Release-Claim Safety Review: Senior-only for final closeout wording.

Mini must defer AFI15 and AFI16 if encountered outside a Senior run.

### LDI15-LDI16

Route: Mini-safe with proof lock.

Mini may implement local value-model/domain-contract work for Living Plan Recompiler and Mutation Permissions / Impact Levels when no persistence/schema/runtime mutation is introduced.

Stop or defer if the batch requires real plan mutation, hidden recompile runtime, irreversible state change, or route/persistence changes.

### LDI20-LDI21

Route: Mini-safe with proof lock / Senior-review.

Mini may implement Freshness Broker contracts, fixtures, and deterministic red-team suites. Senior must review any official/current requirement claim, professional-boundary ambiguity, or final evaluation sufficiency claim.

### LDI17-LDI19

Route: Senior-only unless explicitly scoped as docs-only or local value-model contract.

Continuity Sync, Archive / Schema Migration, and Multi-Device Merge Ledger are senior-owned because they can touch sync, schema, migration, merge, data-loss, or device/platform boundaries.

Mini may prepare docs-only inventories or deferral reports but must not close runtime implementation Green.

### LDI22

Route: Senior-review.

Mini may build governance inventory or local console contracts. Senior closes final governance/maintenance readiness if it affects release, legal/privacy, device, accessibility, or source-runtime claims.

### AOS24-AOS26

Route: Senior-review with Mini implementation slices.

Mini may perform bounded UI integration or fixture-library work from explicit prompts. Senior must close privacy/performance QA and any app-wide integration judgment.

### FCP27-FCP30

Route: Senior-review / Senior-only.

- FCP27 Cross-Surface Proof / Review Mesh: Mini may implement bounded mesh pieces; Senior closes app-wide proof coherence.
- FCP28 Full App 10/10 Audit: Senior-only.
- FCP29 Human Visual / Accessibility / Device Proof Packet: Senior-only for packet judgment; physical/human proof still requires external evidence.
- FCP30 Flagship Completion Handoff: Senior-only.

### PFC31-PFC35

Route: Senior-review with Mini implementation slices.

Mini may perform scoped repairs and matrix updates. Senior closes performance/battery, external accessibility, data freshness, and test strategy sufficiency.

### PFC34, PFC36-PFC40

Route: Senior-only.

App Store metadata, screenshots, claim-truth pack, release engineering, TestFlight readiness plan, FAANG handoff architecture packet, repo hygiene smell removal when destructive, full platform/legal/framework audit, and compliance handoff require Senior judgment. Mini may inventory and prepare evidence only.

### AOS27-AOS30

Route: Senior-only unless a prompt explicitly slices non-judgment implementation.

App Store claim truth, AOS handoff, conditional repair train, and beyond-roadmap work require Senior judgment.

### Conditional compatibility retirements

Route: Senior-only.

CS02C-CS06C / CS09C deferred compatibility retirements require explicit proof target, owner proof, focused tests, and Senior judgment. Mini must not delete, rename, or retire compatibility seams.

### RHC01-RHC06 Repo Hygiene Closeout

Route: Mini-safe for non-destructive inventories; Senior-only for destructive cleanup.

Mini may classify hygiene, add owner maps, and harden advisory allowlists. Mini must not delete files, retire seams, or rename owners unless the active batch explicitly authorizes it and owner proof/tests exist. If destructive cleanup is needed, defer.

## Mini Batch Closing Rule

Mini may close Green only when the batch route is Mini-safe, all proof is present, no senior-only gate appears, and the report includes the model-tier fields required by `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`.

## Senior Batch Closing Rule

Senior may close any eligible batch only with repo evidence. Senior cannot claim physical-device proof, public accessibility conformance, App Store/TestFlight readiness, legal/privacy approval, signed release readiness, or human approval without matching external/operator evidence.
