# Ambitions Canon Source Of Truth Map

Status: Active canon consolidation layer.

Purpose: Make Ambitions documentation easier to read, safer for Codex, and harder to drift. This document maps which active documents own each kind of truth and identifies the focused consolidation docs that clarify implementation after product-decision Waves 1-19.

## Operating Rule

When a future planning, design, roadmap, or implementation task needs context, use this order:

1. `docs/codex/BATCH_REGISTRY.md` for current work status only.
2. `docs/canon/SOURCE_OF_TRUTH_MAP.md` for document ownership and reading order.
3. `docs/canon/PRODUCT_DECISIONS.md` for resolved product decisions from Waves 1-19.
4. `docs/canon/HUMAN_LANGUAGE_REVIEW.md` for user-facing language rules and AI/producty copy rejection.
5. `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md` for completion status, open questions, no-drift rules, and next reconciliation prompt.
6. `MASTER_PRODUCT_SPEC.md` for current shipping product truth and product promise.
7. `docs/canon/design/Ambitions_Design_Constitution.md` for design, IA, UX writing, interaction, trust, accessibility posture, and external-surface behavior.
8. `docs/canon/Ambitions_2_0_Product_Architecture.md` for surface ownership, drilldown rules, object hierarchy, and operating loops.
9. `docs/canon/Ambitions_2_0_Systems_Architecture.md` for shared engines, local-first systems, and system ownership.
10. `docs/canon/Ambitions_2_0_Visual_System.md` plus `docs/canon/design/*` for visual, component, panel, density, grouped-list, accessibility, and UX-writing contracts.
11. Focused consolidation docs for implementation-readable detail.
12. `docs/canon/Ambitions_2_0_Roadmap.md`, `docs/canon/Ambitions_2_0_Batch_Plan.md`, and `docs/codex/batches/*` for execution sequencing after canon reconciliation.
13. QA, review, and release docs for acceptance evidence.
14. Archived docs only when explicitly marked as historical context and only where they do not conflict with active canon.

## Active Ownership Map

| Truth Area | Primary Owner | Supporting Owner(s) | Notes |
| --- | --- | --- | --- |
| Product identity and promise | `MASTER_PRODUCT_SPEC.md` | `PRODUCT_DECISIONS.md`, `Ambitions_Design_Constitution.md` | Ambitions is a life organization system / personal life OS. |
| Product decisions | `PRODUCT_DECISIONS.md` | focused canon docs | Resolved Wave 1-19 decision ledger. |
| Human user-facing language | `HUMAN_LANGUAGE_REVIEW.md` | `ux-writing-state-language-matrix.md`, Acceptance Gates, Today canon | Plain, human UI copy. Rejects AI/producty language such as protected/protection, anchor, optimize, AI/model/confidence in normal UI. |
| Final canon status | `AMBITION_CANON_COMPLETION_REPORT.md` | `ROADMAP_BATCH_GOVERNANCE.md` | Completion report, open questions, no-drift rules, next Codex prompt. |
| Top-level shell | `IA_NAVIGATION_DRILLDOWN.md` | `Ambitions_Design_Constitution.md`, Product Architecture | Locked shell: Today, Goals, Capture, Plan, You. |
| IA and navigation | `IA_NAVIGATION_DRILLDOWN.md` | `screen-contract-matrix.md`, `grouped-navigation-list-spec.md` | Fewer top-level surfaces, deeper drilldowns. |
| Surface ownership | `Ambitions_2_0_Product_Architecture.md` | `IA_NAVIGATION_DRILLDOWN.md`, `screen-contract-matrix.md` | Defines what each tab owns and what never appears top-level. |
| Object/domain hierarchy | `DOMAIN_MODEL.md` | Product Architecture, Design Constitution | Object, field, and relationship reference. |
| Goal/Plan/Task lifecycle | `GOAL_PLAN_TASK_LIFECYCLE.md` | Product Architecture, Systems Architecture, Visual System | State-machine and lifecycle reference. |
| Goals and Goal Detail | `GOALS_GOAL_DETAIL.md` | Lifecycle, Visual System, Human Language Review | Goals direction, Goal Weather, Proof, next visible step; normal UI should use plain language such as `Most important goal`, `What is next?`, and `How is this going?`. |
| Today and Now State | `TODAY_NOW_STATE.md` | Product Architecture, Plan canon, Human Language Review | Best next action, daily schedule, recovery, Now State; normal UI should say `Do this next`, `Too much for today`, and `Make today doable`. |
| You / Profile / Reviews | `YOU_PROFILE_REVIEWS.md` | Trust/Memory, IA, Human Language Review | You is canonical; Profile is legacy compatibility only during migration; normal UI avoids data-console language. |
| Capture / Smart Attachment | `CAPTURE_SMART_ATTACHMENT.md` | `design/smart-attachment-spec.md`, Human Language Review | Quiet Command Sheet, Needs a Place, routing receipts; normal UI should say `Suggested place` / `Move it here?`. |
| Plan / Calendar / Believability | `PLAN_CALENDAR_BELIEVABILITY.md` | Systems Architecture, Today canon, Human Language Review | Believable day/week, daily schedule, optional calendar awareness; normal UI should say `Looks doable`, `Too much planned`, and `No longer works`. |
| Intelligence / Automation | `INTELLIGENCE_AUTOMATION_SUGGESTIONS.md` | Intelligence Standards, Systems Architecture, Human Language Review | Explain, suggest, prepare; no silent important changes and no AI/model language in normal UI. |
| Visual system / components / motion | `VISUAL_SYSTEM_COMPONENTS_MOTION.md` | Visual System, component matrix, `DESIGN_TOKENS.md` | Premium calm OS, meaningful motion, reusable tokens/components. |
| Accessibility / Focus Support | `ACCESSIBILITY_FOCUS_SUPPORT.md` | Accessibility Nutrition docs, screen/component matrices | Accessibility is core quality; Focus Support protects next action clarity internally, but normal UI should avoid `protect/protected` copy. |
| External surfaces | `EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md` | External Surfaces Contract, Human Language Review | Notifications, widgets, Live Activities, App Intents, Shortcuts; external copy must be especially plain and context-safe. |
| Data / local-first / sync / export | `DATA_LOCAL_SYNC_EXPORT.md` | Trust/Memory, Systems Architecture | Local-first, no account required at launch, no launch sync, export before sync. |
| Monetization | `MONETIZATION_PRICING_BUSINESS_MODEL.md` | Launch Scope, Data canon | Premium but accessible; no ads; no data hostage; trust controls not paywalled. |
| Launch scope / MVP / quality | `LAUNCH_SCOPE_MVP_QUALITY_BAR.md` | Acceptance Gates, Roadmap Governance | Launch proves one meaningful goal can become organized, believable, actionable. |
| Roadmap / batch governance | `ROADMAP_BATCH_GOVERNANCE.md` | Batch Registry, Batch Plan | No-drift execution, canon proposals, shipped/planned/deferred discipline. |
| Trust, privacy, memory, receipts | `TRUST_PRIVACY_MEMORY.md` | Design Constitution, Systems Architecture, Data canon | Trust Center, What Ambitions Knows, receipts, sensitive Life Areas. |
| Onboarding | `ONBOARDING_SPEC.md` | Design Constitution, Today, Capture | First useful object, safe skip, permission timing. |
| Empty/error/recovery states | `EMPTY_ERROR_RECOVERY_STATES.md` | UX writing matrix, Human Language Review, Acceptance Gates | Screen-state behavior and recovery standards. |
| Completion and QA gates | `IMPLEMENTATION_ACCEPTANCE_GATES.md` | Visual Review Checklist, RC Maturity Plan, focused canon docs | Definition of done and validation requirements. |
| Design tokens | `design/DESIGN_TOKENS.md` | Visual System, component matrix | Implementation naming for visual primitives. |
| Roadmap and batch sequencing | `Ambitions_2_0_Roadmap.md`, `Ambitions_2_0_Batch_Plan.md` | `ROADMAP_BATCH_GOVERNANCE.md`, `BATCH_REGISTRY.md` | Pending reconciliation against Waves 1-19. |
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
- `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
- `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
- `docs/canon/ONBOARDING_SPEC.md`
- `docs/canon/CAPTURE_SMART_ATTACHMENT.md`
- `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/EMPTY_ERROR_RECOVERY_STATES.md`
- `docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md`
- `docs/canon/design/DESIGN_TOKENS.md`

## Settled Canon Rules

Future work must preserve these settled rules unless a later explicit canon decision supersedes them:

- Top-level shell stays `Today / Goals / Capture / Plan / You`.
- Ambitions stays deep, not wide.
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
- Launch proves one meaningful goal can become organized, believable, and actionable.
- Roadmap/batch work must prevent drift and distinguish shipped, planned, and deferred.

## Reconciliation Rule

The next operating phase is roadmap/batch reconciliation, not more product-definition waves.

Do not create more major docs by default. Reconcile the active roadmap, batch plan, batch registry, implementation gap audit, and batch docs against:

- `PRODUCT_DECISIONS.md`
- `HUMAN_LANGUAGE_REVIEW.md`
- `AMBITION_CANON_COMPLETION_REPORT.md`
- the focused canon set above

## Future Prompt Rule

Every future Codex prompt should include this instruction:

```text
Before implementation, read docs/canon/SOURCE_OF_TRUTH_MAP.md and follow its source-of-truth order. Do not treat archived or superseded docs as active canon. Do not create duplicate engines when Systems Architecture already assigns ownership. Distinguish planned canon from shipped code. Preserve Waves 1-19 decisions and the Human Language Review unless a later explicit canon decision supersedes them. Normal UI must sound human, plain, and obvious; do not ship AI/model/confidence/protected/protection/anchor/optimize/execution-context language in visible copy.
```

## Archive Rule

Do not delete or archive active docs casually. Archive only after:

1. roadmap/batch reconciliation is complete
2. unique content has been migrated or explicitly preserved
3. the archived doc is linked from `docs/archive/README.md`
4. no active source-of-truth doc depends on it

## Next Step

Run the Codex reconciliation prompt inside `AMBITION_CANON_COMPLETION_REPORT.md` to align roadmap and batch execution with the completed canon system, then run the user-facing language cleanup prompt inside `HUMAN_LANGUAGE_REVIEW.md` before visual/UI release work.
