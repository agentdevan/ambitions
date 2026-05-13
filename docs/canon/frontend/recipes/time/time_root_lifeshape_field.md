# Surface Recipe: Time Root / LifeShape Field

## Canon Status
intended_canon

## Surface ID
time_root_lifeshape_field

## Destination
Time

## Surface Type
top_level_surface

## Hierarchy Level
destination_root

## Parent Surface
Time Root

## Child Surfaces
- Day Detail
- Week Detail
- Month Detail
- Reflow Preview Tray
- Best Fit Explanation Sheet

## Final Intended Role
The LifeShape Field root. It treats time as capacity, pressure, protection, fit, and recovery across horizons rather than a calendar grid.

## User Perception
The user should see capacity, protection, pressure, and fit as a living field, not a calendar clone or schedule spreadsheet.

## Why This Surface Exists
It exists so the Time root can show the capacity object, scope controls, pressure, protected time, and reflow preview as one calm field. The recipe defines visible hierarchy, state meaning, accessibility, and anti-drift expectations without claiming implementation proof.

## Primary Object
LifeShape Field

## Supporting Objects
- Receipt System
- Source Freshness Badge
- Proof Trail
- Closure System

## Visible Regions
- LifeShape horizon header
- open, protected, pressure, and best-fit field
- selected horizon detail
- reflow or explanation affordance
- source freshness and calendar availability line
- receipt and recovery state

## Region-by-Region Recipe

### Region 1: LifeShape horizon header

- Purpose: Orient the user to the current object, destination, and state before any action is offered.
- Contains: LifeShape horizon header; current LifeShape Field state; origin context when this is a drill-down or transient surface.
- Primitives: Compact Surface Header, Context Crown, LuminousTrace, semantic labels.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: None unless the header owns a back, close, or setup-later action.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap or back/close controls preserve origin and do not mutate data.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 2: Open/protected/pressure/best-fit field

- Purpose: Make the LifeShape Field read as capacity, not a calendar grid, by showing open time, protected time, pressure, and best-fit opportunities as semantic regions.
- Contains: Open/protected/pressure/best-fit markers, selected horizon label, source freshness line, protected-time lock, pressure explanation, and route to best-fit detail.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 3: Selected horizon detail

- Purpose: Let the user inspect day, week, month, year, or life-range detail without widening root IA or flattening Time into a schedule table.
- Contains: Horizon scope control, selected horizon summary, capacity and protection labels, unavailable/stale source state, disclosure into detail, and VoiceOver horizon summary.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 4: Reflow or explanation affordance

- Purpose: Make reflow consentful and explainable by previewing movement, preserved proof, protected blocks, source basis, and receipt before any schedule-shaped change.
- Contains: Reflow preview entry, Why this? affordance, protected-time lock line, best-fit reason, cancel path, undo expectation, and expected receipt.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: Only if the region owns the current decision; otherwise use disclosure rows.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 5: Source freshness/calendar availability line

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for LifeShape Field.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 6: Receipt/recovery state

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for LifeShape Field.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: SF-first semantic type; region label stays compact, object/action text gets hierarchy only when it owns the current decision.
- Spacing: Attached to the object it explains; dense native rhythm with enough separation to avoid card-stack equivalence.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for LifeShape capacity semantics, open/protected/pressure/best-fit markers, consentful reflow, no calendar-grid primacy.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Generic dashboard modules, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

## Primitive Inventory
GraphiteRecess, QuietGlass, LuminousTrace, CelestialField when semantic orientation is needed, Context Crown where orientation matters, Source Freshness Badge, Receipt System, Proof Trail, chevrons/disclosure rows, SF Symbols, semantic labels, primary/secondary/destructive/disabled CTA treatments.

## Object Inventory
LifeShape Field, Recommendation Source System, Receipt System, Proof Trail, Closure System, and any source/proof objects referenced by this surface.

## Typography Recipe
SF-first semantic type. The dominant object or decision owns the strongest weight; explanatory source/proof text remains compact but readable. Dynamic Type must preserve LifeShape Field, the source/proof line, the primary command, and the recovery or cancel path.

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
Use plain Ambitions language: Shape Time, Source, Receipt, Why this?, Protected, Pressure, Best fit, Needs recovery, Waiting, Blocked, and local trust terms where relevant. Avoid AI confidence, model language, productivity scores, overdue/failure copy, motivational filler, and retired top-level destination phrasing.

## Receipt / Proof / Source Recipe
Meaningful changes expose an expected receipt, existing receipt, proof link, source basis, or an explicit no-receipt reason. Proof is object-linked evidence, not decoration. Source freshness can be fresh, stale, unavailable, local-only, or unresolved and must be inspectable.

## State Model
default, active, empty, local-only, source unavailable, stale source, disabled, receipt-confirmed, unresolved direction, open time, protected time, pressure, best fit, reflow preview, overloaded, away.

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
- open time
- protected time
- pressure
- best fit
- reflow preview
- overloaded
- away

## Forbidden States
- shame/failure framing
- productivity score or streak framing
- hidden mutation
- chatbot or assistant framing
- color-only warnings
- retired destination framing
- calendar clone as primary model

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

- Visual Canon: LifeShape Field stays capacity-first, with protected time, pressure, and best-fit read as field states.
- SI: shared chrome, reusable primitives, and the object-first interface language.
- Accessibility: Dynamic Type, VoiceOver, Reduce Motion, contrast, and visible alternatives.
- QA / validation: declared validation scope, explicit gaps, and no screenshot or implementation proof claims.
- PK: life-shape field, protected time, pressure, and recovery.
- HBI: historical comparison for reflow and protected-state context.
- Planning: planning defaults, availability, and schedule shape.
- Time: LifeShape Field, day/week/month depth, and horizon controls.
- PD: time horizon specificity and planning depth.

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
- LifeShape reduced to calendar grid
- silent schedule mutation

## Open Direction Gaps
- None for final visual intent in this recipe pass.
