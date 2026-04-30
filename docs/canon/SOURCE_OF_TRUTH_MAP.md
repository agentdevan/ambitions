# Ambitions Canon Source Of Truth Map

Status: Active canon consolidation layer.

Purpose: Make Ambitions documentation easier to read, safer for Codex, and harder to drift. This document maps which active documents own each kind of truth and identifies the focused consolidation docs that clarify implementation after product-decision Waves 1-19.

## Operating Rule

When a future planning, design, roadmap, or implementation task needs context, use this order:

1. `docs/codex/BATCH_REGISTRY.md` for current work status only.
2. `docs/canon/SOURCE_OF_TRUTH_MAP.md` for document ownership and reading order.
3. `docs/canon/PRODUCT_DECISIONS.md` for resolved product decisions from Waves 1-19.
4. `docs/canon/GOLDEN_LAUNCH_LOOP.md` for the smallest undeniable launch loop, launch-critical cutline, demo story, and product-strength rules.
5. `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md` for launch-critical / soon-after-launch / post-launch / deferred / decision-gated classification of D01-D26.
6. `docs/canon/HUMAN_LANGUAGE_REVIEW.md` for user-facing language rules and AI/producty copy rejection.
7. `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md` for completion status, open questions, no-drift rules, and next reconciliation prompt.
8. `docs/canon/Ambitions_Master_Product_Visual_System_Spec_v2.md` for the current master product and visual direction, including grounded time context, Action Closure, receipt visibility, user-owned planning, and v2 language rules.
9. `MASTER_PRODUCT_SPEC.md` for current shipping product truth and product promise where not superseded by v2 canon.
10. `docs/canon/design/Ambitions_Design_Constitution.md` for design, IA, UX writing, interaction, trust, accessibility posture, and external-surface behavior where not superseded by v2 canon.
11. `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership, drilldown rules, object hierarchy, and operating loops.
12. `docs/canon/Ambitions_2_0_Systems_Architecture.md` for shared engines, local-first systems, and system ownership.
13. `docs/canon/Ambitions_2_0_Visual_System.md` plus `docs/canon/design/*` for visual, component, panel, density, grouped-list, accessibility, and UX-writing contracts.
14. Focused consolidation docs for implementation-readable detail.
15. `docs/canon/Ambitions_2_0_Roadmap.md`, `docs/canon/Ambitions_2_0_Batch_Plan.md`, `docs/canon/POST_D26_MATURITY_ROADMAP.md`, and `docs/codex/batches/*` for execution sequencing after canon reconciliation.
16. QA, review, and release docs for acceptance evidence.
17. Archived docs only when explicitly marked as historical context and only where they do not conflict with active canon.

## Active Ownership Map

| Truth Area | Primary Owner | Supporting Owner(s) | Notes |
| --- | --- | --- | --- |
| Product identity and promise | `Ambitions_Master_Product_Visual_System_Spec_v2.md` | `MASTER_PRODUCT_SPEC.md`, `PRODUCT_DECISIONS.md`, `Ambitions_Design_Constitution.md` | Ambitions is a premium iPhone-native life operating system; shipping truth remains evidence-gated. |
| Product decisions | `PRODUCT_DECISIONS.md` | focused canon docs | Resolved Wave 1-19 decision ledger. |
| Golden launch loop / product-strength cutline | `GOLDEN_LAUNCH_LOOP.md` | `ROADMAP_BATCH_CLASSIFICATION.md`, `LAUNCH_SCOPE_MVP_QUALITY_BAR.md`, Roadmap Governance, Acceptance Gates | Defines the smallest undeniable loop: capture, place, plan, do today, recover, save proof. Launch-critical work must map here. |
| Roadmap/batch classification | `ROADMAP_BATCH_CLASSIFICATION.md` | `GOLDEN_LAUNCH_LOOP.md`, Roadmap Governance, Batch Registry, Batch Plan | Classifies D01-D26 as launch-critical, soon-after-launch, post-launch, deferred, decision-gated, or infrastructure-unlock. |
| Post-D26 maturity roadmap | `POST_D26_MATURITY_ROADMAP.md` | Roadmap Merge Audit, Batch Registry, Roadmap/Batch Governance, Acceptance Gates | Rewrites original Batches 89-120 into M-series maturity batches and R-series release-readiness gates after D26. Planning only; does not mark D01-D26 complete. |
| Human user-facing language | `HUMAN_LANGUAGE_REVIEW.md` | `ux-writing-state-language-matrix.md`, Acceptance Gates, Today canon | Plain, human UI copy. Rejects AI/producty language such as protected/protection, anchor, optimize, AI/model/confidence in normal UI. |
| Final canon status | `AMBITION_CANON_COMPLETION_REPORT.md` | `ROADMAP_BATCH_GOVERNANCE.md` | Completion report, open questions, no-drift rules, next Codex prompt. |
| Top-level shell | `IA_NAVIGATION_DRILLDOWN.md` | `Ambitions_Design_Constitution.md`, Product Architecture | Locked shell: Today, Goals, Capture, Plan, You. |
| IA and navigation | `IA_NAVIGATION_DRILLDOWN.md` | `screen-contract-matrix.md`, `grouped-navigation-list-spec.md` | Fewer top-level surfaces, deeper drilldowns. |
| Surface ownership | `Ambitions_2_0_Product_Architecture.md` | `IA_NAVIGATION_DRILLDOWN.md`, `screen-contract-matrix.md`, Golden Launch Loop | Defines what each tab owns and what never appears top-level. |
| Object/domain hierarchy | `DOMAIN_MODEL.md` | Product Architecture, Design Constitution | Object, field, and relationship reference. |
| Goal/Plan/Task lifecycle | `GOAL_PLAN_TASK_LIFECYCLE.md` | Product Architecture, Systems Architecture, Visual System | State-machine and lifecycle reference. |
| Goals and Goal Detail | `GOALS_GOAL_DETAIL.md` | Lifecycle, Visual System, Human Language Review, Golden Launch Loop | Goals direction, Goal Weather, Proof, next visible step; normal UI should use plain language such as `Most important goal`, `What is next?`, and `How is this going?`. |
| Today and Now State | `TODAY_NOW_STATE.md` | Product Architecture, Plan canon, Human Language Review, Golden Launch Loop, v2 master spec | Recommended step, daily schedule, recovery, Now State; normal UI should say `Start here`, `Recommended step`, `Too much for today`, and `Make today doable`. |
| You / Profile / Reviews | `YOU_PROFILE_REVIEWS.md` | Trust/Memory, IA, Human Language Review | You is canonical; Profile is legacy compatibility only during migration; normal UI avoids data-console language. |
| Capture / Smart Attachment | `CAPTURE_SMART_ATTACHMENT.md` | `design/smart-attachment-spec.md`, Human Language Review, Golden Launch Loop | Quiet Command Sheet, Needs a Place, routing receipts; normal UI should say `Suggested place` / `Move it here?`. |
| Plan / Calendar / Believability | `PLAN_CALENDAR_BELIEVABILITY.md` | Systems Architecture, Today canon, Human Language Review, Golden Launch Loop | Believable day/week, daily schedule, optional calendar awareness; normal UI should say `Looks doable`, `Too much planned`, and `No longer works`. |
| Intelligence / Automation | `INTELLIGENCE_AUTOMATION_SUGGESTIONS.md` | Intelligence Standards, Systems Architecture, Human Language Review | Explain, suggest, prepare; no silent important changes and no AI/model language in normal UI. |
| Visual system / components / motion | `VISUAL_SYSTEM_COMPONENTS_MOTION.md` | Visual System, component matrix, `DESIGN_TOKENS.md` | Premium calm OS, meaningful motion, reusable tokens/components. |
| Master product and visual v2 direction | `Ambitions_Master_Product_Visual_System_Spec_v2.md` | Visual System, Design Constitution, Product Architecture, Systems Architecture | Supersedes older conflicting language around next-move wording, Focus CTAs, guessed durations, vacation/free-time assumptions, silent reflow, and punitive closure states. |
| Accessibility / Focus Support | `ACCESSIBILITY_FOCUS_SUPPORT.md` | Accessibility Nutrition docs, screen/component matrices | Accessibility is core quality; Focus Support protects next action clarity internally, but normal UI should avoid `protect/protected` copy. |
| External surfaces | `EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md` | External Surfaces Contract, Human Language Review | Notifications, widgets, Live Activities, App Intents, Shortcuts; external copy must be especially plain and context-safe. |
| Data / local-first / sync / export | `DATA_LOCAL_SYNC_EXPORT.md` | Trust/Memory, Systems Architecture | Local-first, no account required at launch, no launch sync, export before sync. |
| Monetization | `MONETIZATION_PRICING_BUSINESS_MODEL.md` | Launch Scope, Data canon | Premium but accessible; no ads; no data hostage; trust controls not paywalled. |
| Launch scope / MVP / quality | `LAUNCH_SCOPE_MVP_QUALITY_BAR.md` | Golden Launch Loop, Acceptance Gates, Roadmap Governance | Launch proves one meaningful goal can become organized, believable, actionable. |
| Roadmap / batch governance | `ROADMAP_BATCH_GOVERNANCE.md` | `ROADMAP_BATCH_CLASSIFICATION.md`, `POST_D26_MATURITY_ROADMAP.md`, Golden Launch Loop, Batch Registry, Batch Plan | No-drift execution, canon proposals, shipped/planned/deferred discipline. |
| Trust, privacy, memory, receipts | `TRUST_PRIVACY_MEMORY.md` | Design Constitution, Systems Architecture, Data canon | Trust Center, What Ambitions Knows, receipts, sensitive Life Areas. |
| Onboarding | `ONBOARDING_SPEC.md` | Design Constitution, Today, Capture, Golden Launch Loop | First useful object, safe skip, permission timing. |
| Empty/error/recovery states | `EMPTY_ERROR_RECOVERY_STATES.md` | UX writing matrix, Human Language Review, Acceptance Gates | Screen-state behavior and recovery standards. |
| Completion and QA gates | `IMPLEMENTATION_ACCEPTANCE_GATES.md` | Golden Launch Loop, Human Language Review, Visual Review Checklist, RC Maturity Plan, focused canon docs | Definition of done and validation requirements. |
| Design tokens | `design/DESIGN_TOKENS.md` | Visual System, component matrix | Implementation naming for visual primitives. |
| Roadmap and batch sequencing | `Ambitions_2_0_Roadmap.md`, `Ambitions_2_0_Batch_Plan.md`, `POST_D26_MATURITY_ROADMAP.md` | `ROADMAP_BATCH_CLASSIFICATION.md`, `GOLDEN_LAUNCH_LOOP.md`, `ROADMAP_BATCH_GOVERNANCE.md`, `BATCH_REGISTRY.md` | D01-D26 remain the active Layer 1 execution track; Post-D26 Maturity Roadmap plans Layer 2/3 after D26 without marking D batches complete. |
| Canon weakness/gap analysis | `CANON_CONSOLIDATION_GAP_AUDIT.md` | Completion Report | Documentation architecture audit, not feature gap audit. |

## Active Focused Canon Set

The focused consolidation set now includes:

- `docs/canon/CANON_CONSOLIDATION_GAP_AUDIT.md`
- `docs/canon/DOMAIN_MODEL.md`
- `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md`
- `docs/canon/GOALS_GOAL_DETAIL.md`
- `docs/canon/TODAY_NOW_STATE.md`
- `docs/canon/YOU_PROFILE_REVIEWS.md`
- `docs/canon/IA_NAVIGATION_DRILLDOWN.md`
- `docs/canon/INTELLIGENCE_AUTOMATION_SUGGESTIONS.md`
- `docs/canon/VISUAL_SYSTEM_COMPONENTS_MOTION.md`
- `docs/canon/ACCESSIBILITY_FOCUS_SUPPORT.md`
- `docs/canon/EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/MONETIZATION_PRICING_BUSINESS_MODEL.md`
- `docs/canon/LAUNCH_SCOPE_MVP_QUALITY_BAR.md`
- `docs/canon/ROADMAP_BATCH_GOVERNANCE.md`
- `docs/canon/GOLDEN_LAUNCH_LOOP.md`
- `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md`
- `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
- `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
- `docs/canon/ONBOARDING_SPEC.md`
- `docs/canon/CAPTURE_SMART_ATTACHMENT.md`
- `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/EMPTY_ERROR_RECOVERY_STATES.md`
- `docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md`
- `docs/canon/POST_D26_MATURITY_ROADMAP.md`
- `docs/canon/design/DESIGN_TOKENS.md`

## Settled Canon Rules

Future work must preserve these settled rules unless a later explicit canon decision supersedes them:

- Top-level shell stays `Today / Goals / Capture / Plan / You`.
- Today hero language is `Start here`; the primary user action is a step, not a `move`, and Focus is context rather than a manual Today CTA.
- Guided automation is the default; meaningful planning changes ask first unless a later explicit safe rule proves otherwise.
- Vacation is not free time by default; per-vacation availability choice is required for new vacation/away setup.
- Durations must be user-set, user-accepted, suggested, historical, actual, or unset.
- Closure receipts must remain visible through Today, Trust Center, and Goal Detail where the current repo has receipt data.
- Ambitions stays deep, not wide.
- Launch-critical work must map to the Golden Launch Loop: capture, place, plan, do today, recover, save proof.
- D01-D26 classification must follow `ROADMAP_BATCH_CLASSIFICATION.md` unless a later explicit decision supersedes it.
- Post-D26 maturity work must follow `POST_D26_MATURITY_ROADMAP.md` after D26 and must not mark D01-D26 complete by assumption.
- Today is not a task dump.
- Goals is not a project-management board.
- Plan is not a raw calendar clone.
- You is not a junk drawer.
- Normal UI must sound human and obvious; it must not sound like AI, a productivity engine, or product strategy.
- Normal UI should avoid `protected/protection/protect`, `anchor`, `optimize`, `AI`, `model`, `confidence`, and `execution context` unless literally about privacy/security or internal-only docs.
- Intelligence explains, suggests, and prepares; it does not silently decide important things.
- Local-first launch means no required account and no launch sync.
- Export should exist before sync and must not feel hostage.
- Trust/privacy/data controls are not paywalled.
- Accessibility and Focus Support are core product quality.
- Launch proves one meaningful goal can become organized, doable, and actionable today.
- Roadmap/batch work must prevent drift and distinguish shipped, planned, deferred, decision-gated, and infrastructure-unlock work.

## Reconciliation Rule

The active implementation phase remains D01-D26 until D26 is complete. Do not treat post-D26 M-batches as runnable implementation work until D26 is complete or the user explicitly authorizes planning-only scenario preparation.

Do not create more major docs by default. Reconcile the active roadmap, batch plan, batch registry, implementation gap audit, and batch docs against:

- `PRODUCT_DECISIONS.md`
- `GOLDEN_LAUNCH_LOOP.md`
- `ROADMAP_BATCH_CLASSIFICATION.md`
- `HUMAN_LANGUAGE_REVIEW.md`
- `POST_D26_MATURITY_ROADMAP.md` when planning Layer 2/3 after D26
- `AMBITION_CANON_COMPLETION_REPORT.md`
- the focused canon set above

## Future Prompt Rule

Every future Codex prompt should include this instruction:

```text
Before implementation, read docs/canon/SOURCE_OF_TRUTH_MAP.md and follow its source-of-truth order. Do not treat archived or superseded docs as active canon. Do not create duplicate engines when Systems Architecture already assigns ownership. Distinguish planned canon from shipped code. Preserve Waves 1-19 decisions, the Golden Launch Loop, Roadmap/Batch Classification, and the Human Language Review unless a later explicit canon decision supersedes them. Launch-critical work must map to capture/place/plan/do today/recover/save proof. Normal UI must sound human, plain, and obvious; do not ship AI/model/confidence/protected/protection/anchor/optimize/execution-context language in visible copy.
```

For future M-batches after D26, also include:

```text
D01-D26 are assumed complete for this planning/execution layer only. Do not alter D-batch completion history unless the registry already says they are complete. Preserve the five-tab shell, Golden Launch Loop, Human Language Review, Object Terminology, Design Constitution, local-first trust posture, receipt/privacy boundaries, and accessibility evidence requirements. Do not restore old 89-120 scope that conflicts with the newer canon. Follow docs/canon/POST_D26_MATURITY_ROADMAP.md.
```

## Archive Rule

Do not delete or archive active docs casually. Archive only after:

1. roadmap/batch reconciliation is complete
2. unique content has been migrated or explicitly preserved
3. the archived doc is linked from `docs/archive/README.md`
4. no active source-of-truth doc depends on it

## Next Step

Continue D01-D26 implementation. After D26, reopen `POST_D26_MATURITY_ROADMAP.md` for evidence-based adjustment before starting M01.
