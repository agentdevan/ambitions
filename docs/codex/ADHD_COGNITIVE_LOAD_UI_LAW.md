# ADHD Cognitive Load UI Law

Status: Active PLOS M00 governance law
Issue: AMB-642 / PLOS-006
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none
UI implementation proof: none

This law defines cognitive-load constraints for future PLOS UI. It does not redesign UI, add SwiftUI surfaces, change app copy, add screenshots, or prove accessibility.

## Core Law

Ambitions must help a user act when attention, executive function, time, energy, or emotional bandwidth is limited.

Top-level PLOS UI must make the next decision obvious without turning the screen into a checklist, dashboard, paragraph stack, calendar clone, chatbot, scorecard, or shame surface. Deeper reasoning must remain available, but the first screen must not require the user to parse internal runtime machinery before acting.

The law is not a medical claim. It is a product-quality and accessibility law for low cognitive load, calm prioritization, and progressive disclosure.

## Existing Authority Anchors

AMB-642 inspected current docs and source before installing this law. Existing anchors include:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - current design truth requires one-primary-object discipline, one clear top-level decision, calm copy, low shame, trust receipts, Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, safe areas, and no dashboard/card-stack/chatbot posture.
- `docs/codex/ui-quality-firewall.md`
  - current UI firewall treats ugly UI, unreadable dock, clipped text, weak accessibility semantics, generic dashboard/card/list/form anatomy, and false Green as blockers.
- `docs/codex/ambitions_ui_review_checklist.md`
  - current review checklist requires source-backed inspection, primary object/action, compact trust/receipt, no old IA drift, and honest visual/accessibility status.
- `docs/codex/ambitions_no_card_replacement_taxonomy.md`
  - current taxonomy blocks card piles, metric grids, generic task rows, chat transcript panels, and calendar-copy cards.
- `docs/codex/ambitions_primitive_invention_registry.md`
  - existing primitive registry already identifies source trust strips, proof relationship traces, quiet reflow, and accessibility fallback contracts.
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
  - existing primitives already support adaptive accessibility interface posture.
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
  - existing primitives already provide receipt, source, review, privacy, and accessibility-summary vocabulary.
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
  - trust-light disclosure requires compact top-level meaning with inspectable drill-down.

These anchors are existing-first context only. They do not prove UI implementation.

## Top-Level Cognitive Load Rules

Future PLOS UI claims must satisfy these rules:

- one primary object per surface
- one primary action at the decision moment
- one short reason before any advanced explanation
- one visible recovery or fallback path when action cannot proceed
- no paragraph wall in the default state
- no dense metric grid in the default state
- no source/debug dump in the default state
- no fake urgency, shame, score pressure, or streak pressure
- no hidden material consequence
- no unlabeled glyph-only status

The top-level surface can include a compact trust strip, receipt preview, or consequence phrase when needed. It cannot make the user solve the interface before solving the life problem.

## Disclosure Density

Density must be chosen by user need and consequence severity:

| Density | Allowed use | Requirements |
|---|---|---|
| calm default | Normal recommended Step or plan state. | Short reason, one action, compact trust path. |
| review-needed | Source, consequence, privacy, schedule, or proof review is required. | Explain what needs review and provide one clear review route. |
| confirm/warn | Mutation or material consequence is safe only after user choice. | Show human consequence phrase before mutation. |
| blocked/impossible | Current constraints prevent the action. | State why, offer safe fallback or scope review, do not present action as viable. |
| detailed drill-down | User intentionally asks for trace. | Show source, context, constraints, receipts, rollback, and fallback in readable sections. |

Default density must not be used to hide a review-needed, confirm, warn, blocked, or impossible state.

## Copy Constraints

Future UI copy in PLOS surfaces must be:

- short enough to scan
- concrete enough to act on
- calm under failure
- honest about uncertainty, source state, and blocked paths
- free of guilt, productivity scoring, streak pressure, and AI theater

Use Ambitions language:

- Start here
- Recommended step
- Start now
- Open step
- Step

Avoid:

- next best move
- best next move
- Begin Focus
- generic task language
- top-level Plan language
- AI wrapper language
- productivity score language
- dashboard/admin/spec/debug language

Law examples, not shipped copy:

- "This protects tonight's sleep and keeps the deadline."
- "Needs review because the source changed."
- "Open step."
- "This cannot fit today without moving protected time."

## Accessibility And Attention Rules

Future PLOS UI claims must check:

- Dynamic Type does not clip, overlap, or hide key action/trust text
- VoiceOver order names the primary object, reason, action, source/trust state, and fallback path
- Reduce Motion preserves meaning without animation dependency
- Reduce Transparency keeps foreground and dock/shell text legible
- Increase Contrast does not collapse state distinctions
- color is not the only state channel
- touch targets remain usable
- compact glyphs have accessible names
- copy and controls do not occlude each other

Screenshots are not proof unless visually evaluated. Accessibility cannot be claimed from this law alone.

## Progressive Disclosure Rules

Future detailed PLOS UI must be deep without becoming noisy:

- top-level action remains visible or recoverable after opening detail
- drill-down sections are grouped by user question, not implementation subsystem
- source, receipt, consequence, privacy, and fallback are separable
- advanced detail is not required for routine action
- review-needed state is not buried under optional expert detail
- a user can back out without losing the decision context

The default view should answer "What should I do now and why is it safe enough to consider?" The drill-down can answer "What source, context, constraints, receipts, and fallback paths led here?"

## Green Enforcement

Any future PLOS issue that claims low cognitive-load UI, ADHD-friendly UI, trust-light UI, top-level runtime reasoning, deep drill-down, source/receipt/replay UI, accessibility readiness, or visual Green must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of active UI, copy, shell, accessibility, trust, source, and receipt ownership
- explicit top-level primary object and action
- explicit default density and drill-down boundary
- no paragraph-heavy default state
- no dashboard/card-stack/chatbot/calendar-copy anatomy
- no hidden review-needed, confirm, warn, blocked, or impossible state
- visual evaluation of relevant screenshots for UI claims
- Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, safe-area, tap-target, and legibility evidence for accessibility claims
- honest no-claim boundary when proof is absent

Yellow is allowed when this law is installed but future UI implementation, screenshot review, accessibility proof, or runtime drill-down proof remains owned by later phases. Red is required for paragraph-heavy default UI, generic dashboard/card/list/form anatomy, hidden material consequences, guilt or scoring language, glyph-only state without accessible names, accessibility claims without proof, PLOS label Linear access, or phase-order violation.

## Cross-Links

Primary authority:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`

PLOS law authority:

- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md`
- `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md`
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`

Future phase owners:

- AMB-624 / PLOS-M17 must use this law before Trust-light UI and deep drill-down Green.
- AMB-617 / PLOS-M10 must use this law for Golden Slice UI Green.
- AMB-618 / PLOS-M11 must use this law for onboarding and first-run activation Green.

## Non-Claims

AMB-642 does not claim:

- UI implementation
- SwiftUI source change
- runtime feature implementation
- low cognitive-load UI proof
- ADHD medical validation
- screenshot proof
- accessibility verification
- privacy/legal approval
- release, TestFlight, or App Store readiness
- PLOS-M00 completion
- PLOS-M01 or later execution
