# Surface Recipe: Reflow Preview Tray

## Canon Status
planned_canon

## Surface ID
reflow_preview_tray

## Destination
Cross-surface

## Surface Type
tray

## Hierarchy Level
transient_surface

## Parent Surface
Global App Shell

## Child Surfaces
- Owning destination surfaces
- Receipt/proof/source details

## Final Intended Role
The Time-specific preview tray for schedule/capacity changes. It shows before/after, protected time, why the reflow fits, source basis, expected receipt, confirm, cancel, and undo.

## User Perception
The user should see a calm transaction preview: what will change, what will not change, why, and how to confirm or back out.

## Why This Surface Exists
This surface recipe records the final-state visual intent for Reflow Preview Tray.

## Primary Object
Shared object system

## Supporting Objects
- Receipt System
- Source Freshness Badge
- Why This Sheet
- Closure System

## Visible Regions
- Before/after LifeShape summary
- Proposed movement list
- Protected time lock line
- Best-fit explanation
- Source freshness and expected receipt
- Confirm/cancel/undo controls

## Region-by-Region Recipe

### Region 1: Before/after LifeShape summary

- Purpose: Compare before/after capacity as a cross-surface consequence preview, keeping LifeShape change, proof preservation, and expected receipt visible above controls.
- Contains: Before/after LifeShape summary, source freshness badge, proof-transfer note, pressure/protection delta, affected object count, and expected receipt.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 2: Proposed movement list

- Purpose: Present proposed movements as inspectable object changes rather than a schedule spreadsheet, with origin, destination, reason, and undoability per row.
- Contains: Movement rows, origin/destination labels, fit reason, conflict or stale-source marker, remove-from-preview control, and disclosure to affected object.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 3: Protected time lock line

- Purpose: Keep protected time and unchanged commitments visibly locked so the preview proves its boundary before the user commits.
- Contains: Protected-time lock line, unchanged commitment labels, proof-preserved note, source owner, no-change explanation, and accessible unchanged-state summary.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 4: Best-fit explanation

- Purpose: Explain best-fit as inspectable local reasoning, including source basis, uncertainty, correction route, and why the proposed movement respects protected constraints.
- Contains: Best-fit reason, Why this? disclosure, source freshness badge, uncertainty marker, correction control, and receipt preview.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 5: Source freshness and expected receipt

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for Shared object system.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 6: Confirm/cancel/undo controls

- Purpose: Let the user commit, cancel, undo, or disclose detail with clear consequence.
- Contains: Primary and secondary commands for Reflow Preview Tray; disabled/destructive states when applicable; cancel and undo where reversible.
- Primitives: Primary CTA, Secondary CTA, Destructive CTA, Disabled CTA, native button styling, haptic confirmation intent.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Cross-surface consistency, native disclosure, receipt/source/proof continuity, and forbidden-drift protection.
- CTAs: One dominant primary command plus quieter cancel/secondary options; destructive commands require clear label and receipt path.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Confirms, cancels, opens detail, or restores the previous state; no silent mutation.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

## Primitive Inventory
GraphiteRecess, QuietGlass, LuminousTrace, CelestialField when semantic orientation is needed, Context Crown where orientation matters, Source Freshness Badge, Receipt System, Proof Trail, chevrons/disclosure rows, SF Symbols, semantic labels, primary/secondary/destructive/disabled CTA treatments.

## Object Inventory
Shared object system, plus any visible Receipt System, Closure System, Recommendation Source System, Proof Trail System, Commitment Staging Tray, Reflow Preview Tray, Personal Runtime, or source/proof objects referenced by this surface.

## Typography Recipe
SF-first semantic type. The dominant object or decision owns the strongest weight; explanatory source/proof text remains compact but readable. Dynamic Type must preserve Shared object system, the source/proof line, the primary command, and the recovery or cancel path.

## Spacing Recipe
Use a dense native iPhone rhythm: object-attached spacing, grouped rows only where they represent the same object, and no equal-weight dashboard/card stack. Primary controls remain thumb-zone aware with at least 44 pt touch intent.

## Material Recipe
GraphiteRecess is the ground. QuietGlass is reserved for sheets, trays, overlays, and inspectable transient layers. LuminousTrace expresses origin, attachment, source freshness, protection, pressure, or continuity. CelestialField appears only when it carries orientation or relationship meaning.

## Color and State Recipe
Color reinforces semantic state but never owns it. Fresh, stale, protected, pressure, blocked, waiting, recovery, local-only, disabled, receipt-confirmed, and unresolved states require visible labels, shape/placement, and accessibility text.

## Icon, Chevron, and Disclosure Recipe
Use SF Symbols where possible. Chevron means deeper inspection or navigation, not decoration. Icons must be paired with visible text or accessibility labels, especially for source, proof, protected, pressure, warning, receipt, and recovery meanings.

## CTA Recipe
One primary CTA maximum at rest. Secondary actions are quieter, cancel remains reachable, destructive actions are explicit and receipt-backed, and disabled actions explain what is needed without shame.

## Label and Microcopy Recipe
Use plain Ambitions language: Start here, Shape Time, Still counts, Source, Why this?, Receipt, Needs a Place, Protected, Waiting, Blocked, Needs recovery, and local trust terms where relevant. Avoid AI confidence, model language, productivity scores, overdue/failure copy, motivational filler, and retired top-level destination phrasing.

## Receipt / Proof / Source Recipe
Meaningful changes expose an expected receipt, existing receipt, proof link, source basis, or an explicit no-receipt reason. Proof is object-linked evidence, not decoration. Source freshness can be fresh, stale, unavailable, local-only, or unresolved and must be inspectable.

## State Model
default, active, empty, local-only, source unavailable, stale source, disabled, receipt-confirmed, unresolved direction, expanded, collapsed, confirming, cancelled, undo available.

## Allowed States
- default
- active
- empty
- local-only
- source unavailable
- stale source
- disabled
- receipt-confirmed
- unresolved direction
- expanded
- collapsed
- confirming
- cancelled
- undo available

## Forbidden States
- shame/failure framing
- productivity score or streak framing
- hidden mutation
- chatbot or assistant framing
- color-only warnings
- retired destination framing
- banned gambling, sportsbook, or urgency-framed transaction language

## Motion and Haptic Intent
Motion clarifies origin, relationship, before/after, confirmation, and recovery. Haptics are light confirmation or boundary feedback only and never the sole indication. Continuous motion is allowed only when it communicates real state, not atmosphere.

## Accessibility Intent
The surface must preserve object, state, source/proof, action, and recovery meaning without depending on color, motion, small type, or visual layout. Primary actions require visible alternatives and readable contrast.

## Dynamic Type Intent
At larger sizes, preserve the dominant object, source/proof line, primary command, cancel/recovery path, and disclosure order even if secondary metadata collapses or moves below.

## VoiceOver Intent
VoiceOver order: destination or origin, surface name, primary object, current state, source/proof availability, primary action, secondary disclosure, cancel/recovery where relevant.

## Reduce Motion Intent
Replace animated continuity with static before/after labels, attachment lines, origin labels, and explicit receipt/source summaries. No meaning may depend only on movement.

## ADHD Usability Intent
Keep one dominant decision or one state explanation visible. Use short labels at rest, progressive disclosure for reasons, stable placement for cancel/undo/recovery, and no competing CTAs.

## Relationship to Planned Train / Source Families

- Visual Canon: Reflow preview reads as before/after fit, protected time, and undoable movement, with no betting, sportsbook, or urgency framing.
- SI: shared chrome, reusable primitives, and the object-first interface language.
- Accessibility: Dynamic Type, VoiceOver, Reduce Motion, contrast, and visible alternatives.
- QA / validation: declared validation scope, explicit gaps, and no screenshot or implementation proof claims.
- Moat Runtime: proof, recovery, trust, and anti-commodity guardrails.
- Runtime: local execution, receipts, and explainable state.
- REC: receipt/proof surfaces and acknowledgements.
- Planning: planning depth and time-shape specificity.
- PD: specific planning detail and fit language.

## Source Truth
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md

## Planned Batch Sources
- prompts/batches/FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001.md
- prompts/batches/VISUAL-CANON-MOAT-01.md
- prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md
- prompts/batches/MOAT-ALIGNMENT-01.md

## Precedence / Conflict Notes
Final intended visual direction uses current truth files first, then planned frontend batch direction for future-state details; current source does not prove this recipe is implemented. Current implementation does not prove this surface exists or is complete.

## Forbidden Generic Drift
- generic dashboard
- card-stack fallback
- task-list clone
- calendar clone
- chatbot UI
- AI confidence or model jargon
- sportsbook or gambling language
- color-only state meaning
- shame language
- banned gambling-market vocabulary listed by the batch prompt

## Open Direction Gaps
- None for final visual intent in this recipe pass.
