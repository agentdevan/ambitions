# Ambitions Canon Source Of Truth Map

Status: Active canon consolidation layer.

Purpose: Make Ambitions documentation easier to read, safer for Codex, and harder to drift. This document does not replace the existing canon. It maps which existing document owns each kind of truth and identifies the focused consolidation docs that clarify implementation.

## Operating Rule

When a future planning, design, or implementation task needs context, use this order:

1. `docs/codex/BATCH_REGISTRY.md` for current work status only.
2. `docs/canon/SOURCE_OF_TRUTH_MAP.md` for document ownership and reading order.
3. `MASTER_PRODUCT_SPEC.md` for current shipping product truth and product promise.
4. `docs/canon/design/Ambitions_Design_Constitution.md` for design, IA, UX writing, component naming, interaction, trust, accessibility posture, and external-surface behavior.
5. `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership, drilldown rules, object hierarchy, and operating loops.
6. `docs/canon/Ambitions_2_0_Systems_Architecture.md` for shared engines, local-first systems, and system ownership.
7. `docs/canon/Ambitions_2_0_Visual_System.md` plus `docs/canon/design/*` for visual, component, panel, density, grouped-list, accessibility, and UX-writing contracts.
8. Focused consolidation docs for implementation-readable detail: `DOMAIN_MODEL.md`, `GOAL_PLAN_TASK_LIFECYCLE.md`, `ONBOARDING_SPEC.md`, `TRUST_PRIVACY_MEMORY.md`, `EMPTY_ERROR_RECOVERY_STATES.md`, `IMPLEMENTATION_ACCEPTANCE_GATES.md`, and `design/DESIGN_TOKENS.md`.
9. `docs/canon/Ambitions_2_0_Roadmap.md`, `docs/canon/Ambitions_2_0_Batch_Plan.md`, and `docs/codex/batches/*` for execution sequencing.
10. QA, review, and release docs for acceptance evidence.
11. Archived docs only when explicitly marked as historical context and only where they do not conflict with active canon.

## Active Ownership Map

| Truth Area | Primary Owner | Supporting Owner(s) | Notes |
| --- | --- | --- | --- |
| Product identity and promise | `MASTER_PRODUCT_SPEC.md` | `Ambitions_Design_Constitution.md` | Product identity is already defined; do not create a competing product constitution unless it extracts this truth. |
| Top-level shell | `Ambitions_Design_Constitution.md` | `Ambitions_2_0_Product_Architecture.md` | Locked shell: Today, Goals, Capture, Plan, You. |
| IA and navigation | `Ambitions_Design_Constitution.md` | `screen-contract-matrix.md`, `grouped-navigation-list-spec.md` | IA exists; dedicated maps should clarify, not replace. |
| Surface ownership | `Ambitions_2_0_Product_Architecture.md` | `screen-contract-matrix.md` | Defines what each tab owns and what never appears top-level. |
| Object/domain hierarchy | `Ambitions_2_0_Product_Architecture.md` | `Ambitions_Design_Constitution.md`, `DOMAIN_MODEL.md` | Extracted into `DOMAIN_MODEL.md` for field/state clarity. |
| Goal/Plan/Task lifecycle | `GOAL_PLAN_TASK_LIFECYCLE.md` | Product Architecture, Systems Architecture, Visual System | Consolidated state-machine doc. |
| Intelligence rules | `Ambitions_2_0_Intelligence_Standards.md` | Systems Architecture, Recommendation Explanation Model references | Ambitions is intelligent, not chat-first AI. |
| System ownership | `Ambitions_2_0_Systems_Architecture.md` | `IMPLEMENTATION_ACCEPTANCE_GATES.md` | Prevents duplicate engines and per-screen logic. |
| Visual direction | `Ambitions_2_0_Visual_System.md` | `component-contract-matrix.md`, `panel-density-size-spec.md`, `DESIGN_TOKENS.md` | Design tokens are extracted for implementation naming. |
| Components | `component-contract-matrix.md` | `DESIGN_TOKENS.md` | Component behavior already exists; tokens add implementation precision. |
| UX writing | `ux-writing-state-language-matrix.md` | `EMPTY_ERROR_RECOVERY_STATES.md` | State language exists; new doc expands screen-state coverage. |
| Grouped navigation lists | `grouped-navigation-list-spec.md` | Component matrix | Official pattern already exists. |
| Trust, privacy, memory, receipts | `TRUST_PRIVACY_MEMORY.md` | Design Constitution, Systems Architecture | Extracted because it is important enough to stand alone. |
| Onboarding | `ONBOARDING_SPEC.md` | Design Constitution, External Surfaces Contract | Extracted into first-run flow spec. |
| Accessibility / ADHD posture | Design Constitution | Accessibility Nutrition docs, screen/component matrices | User-facing claims remain unavailable until verified. |
| Roadmap and batch sequencing | `Ambitions_2_0_Roadmap.md`, `Ambitions_2_0_Batch_Plan.md` | `BATCH_REGISTRY.md` | Batch registry is status, not product doctrine. |
| Completion and QA gates | `IMPLEMENTATION_ACCEPTANCE_GATES.md` | Visual Review Checklist, RC Maturity Plan | Consolidated definition-of-done doc. |
| Canon weakness/gap analysis | `CANON_CONSOLIDATION_GAP_AUDIT.md` | Source map | Documentation architecture audit, not feature gap audit. |

## Consolidation Findings

The repo was not missing the entire major-document stack. The active canon already contains most of the major product, design, IA, visual, intelligence, roadmap, accessibility, and QA concepts.

The real weaknesses were:

1. **Authority overlap.** `MASTER_PRODUCT_SPEC.md`, the Design Constitution, Product Architecture, and Visual System repeat some product identity and IA doctrine. This is acceptable if the ownership map is followed, but risky without a source map.
2. **Object model spread.** Life Area, North Star, Goal, Plan, Path, Milestone, Step, Task, Proof, Receipt, Review, Decision, and Archive are defined across multiple docs. They now have one domain reference.
3. **Lifecycle implied, not fully executable.** Goal Weather, Goal Lifecycle Rail, Proof Spine, Decision Trail, Plan Treaty, and Completion Archive were defined, but a compact state-machine doc was missing.
4. **Future-vs-shipped ambiguity.** Some docs describe planned future systems in the same language as implemented systems. Future implementation prompts must explicitly distinguish planned canon from shipped code.
5. **Design tokens not literal enough.** Visual direction is strong, but token names and implementation-level mapping needed a dedicated token contract.
6. **Onboarding was under-specified.** The constitution defines onboarding principles, but not a full screen-by-screen flow.
7. **Trust/memory is strategically important enough to stand alone.** It existed, but was embedded inside broader docs.
8. **Empty/error/recovery states needed a screen-by-screen acceptance matrix.** UX writing rules existed, but they were not exhaustive by surface.
9. **Acceptance gates needed one explicit implementation standard.** QA material existed, but future Codex prompts need a single definition of done.
10. **Archived docs can still confuse Codex.** Any prompt must instruct Codex to read active canon first and treat archived docs as historical only.

For the complete documentation architecture audit, read `docs/canon/CANON_CONSOLIDATION_GAP_AUDIT.md`.

## Consolidation Rule

Do not delete or rewrite large active canon docs casually. Instead:

- Extract repeated doctrine into a focused doc when it improves execution.
- Link focused docs back to their parent canon owner.
- Keep `Ambitions_Design_Constitution.md` as the design/IA/UX authority.
- Keep `MASTER_PRODUCT_SPEC.md` as product truth.
- Keep `BATCH_REGISTRY.md` as status truth.
- Keep implementation claims separate from future product canon.

## Future Prompt Rule

Every future Codex prompt should include this instruction:

```text
Before implementation, read docs/canon/SOURCE_OF_TRUTH_MAP.md and follow its source-of-truth order. Do not treat archived or superseded docs as active canon. Do not create duplicate engines when Systems Architecture already assigns ownership. Distinguish planned canon from shipped code.
```

## Consolidation Docs Added

The immediate consolidation set is complete:

- `docs/canon/CANON_CONSOLIDATION_GAP_AUDIT.md`
- `docs/canon/DOMAIN_MODEL.md`
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md`
- `docs/canon/ONBOARDING_SPEC.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/EMPTY_ERROR_RECOVERY_STATES.md`
- `docs/canon/design/DESIGN_TOKENS.md`
- `docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md`

These documents should stay concise, canonical, and implementation-useful. They should not become new parallel roadmaps.

## Next Step

Do not add more major docs by default. Fill the open questions inside these docs through focused product-decision waves, then update the relevant focused doc with the resolved answers.
