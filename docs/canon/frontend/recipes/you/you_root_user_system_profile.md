# Surface Recipe: You Root / User System Profile

## Canon Status
intended_canon

## Surface ID
you_root_user_system_profile

## Destination
You

## Surface Type
top_level_surface

## Hierarchy Level
destination_root

## Parent Surface
You Root

## Child Surfaces
- Trust detail
- Privacy detail
- Planning Defaults
- Local Data / Reset / Forget

## Final Intended Role
The User System Profile root. It is the native settings-style control center for trust, local runtime, defaults, privacy, notifications, and reset/forget controls.

## User Perception
The user should feel in control of a private local system, with settings-style clarity and no social, account, or admin-console tone.

## Why This Surface Exists
It exists so the You root can show trust, defaults, privacy, local runtime, and reset controls as one calm system surface. The recipe defines visible hierarchy, state meaning, accessibility, and anti-drift expectations without claiming implementation proof.

## Primary Object
User System Profile

## Supporting Objects
- Receipt System
- Source Freshness Badge
- Proof Trail
- Closure System

## Visible Regions
- user system profile header
- settings-style section body
- trust and local runtime explanation
- control row or disclosure
- receipt, reset, and source line
- warning, offline, and first-run state

## Region-by-Region Recipe

### Region 1: User System Profile header

- Purpose: Orient the user to the current object, destination, and state before any action is offered.
- Contains: User System Profile header; current User System Profile state; origin context when this is a drill-down or transient surface.
- Primitives: Compact Surface Header, Context Crown, LuminousTrace, semantic labels.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: None unless the header owns a back, close, or setup-later action.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap or back/close controls preserve origin and do not mutate data.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 2: Settings-style section body

- Purpose: Organize You as a native settings-style control surface for the user's system, with privacy, planning defaults, runtime learning, and reset controls grouped by consequence.
- Contains: Settings-style sections, Trust & Automation row, Personal Runtime row, Privacy row, Planning Defaults row, reset/forget controls, and receipt/source indicators.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: Use a visible primary command only when this region changes User System Profile; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 3: Trust/local runtime explanation

- Purpose: Explain local runtime behavior as inspectable rules, sources, corrections, and resets rather than AI model language or social profile attributes.
- Contains: Local runtime summary, learned defaults, source freshness, correction history, reset control, privacy boundary, and receipt expectation for changed settings.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: Use a visible primary command only when this region changes User System Profile; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 4: Control row or disclosure

- Purpose: Let the user commit, cancel, undo, or disclose detail with clear consequence.
- Contains: Primary and secondary commands for You Root / User System Profile; disabled/destructive states when applicable; cancel and undo where reversible.
- Primitives: Primary CTA, Secondary CTA, Destructive CTA, Disabled CTA, native button styling, haptic confirmation intent.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: One dominant primary command plus quieter cancel/secondary options; destructive commands require clear label and receipt path.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Confirms, cancels, opens detail, or restores the previous state; no silent mutation.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 5: Receipt/reset/source line

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for User System Profile.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 6: Warning/offline/first-run state

- Purpose: Keep warning, offline, and first-run states actionable and non-alarming while preserving local-first privacy and clear setup deferral.
- Contains: Offline/local-only label, first-run setup prompt, warning explanation, setup-later control, reset/forget route, source state, and VoiceOver consequence summary.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, User System Profile title or state label, source/proof caption, and readable action text. Emphasis stays on the active User System Profile decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to User System Profile, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Settings-style control, local runtime inspection, reset/forget clarity, no social/profile/admin framing.
- CTAs: Use a visible primary command only when this region changes User System Profile; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

## Primitive Inventory
GraphiteRecess, QuietGlass, LuminousTrace, CelestialField when semantic orientation is needed, Context Crown where orientation matters, Source Freshness Badge, Receipt System, Proof Trail, chevrons/disclosure rows, SF Symbols, semantic labels, primary/secondary/destructive/disabled CTA treatments.

## Object Inventory
User System Profile, Personal Runtime, Receipt System, Proof Trail, Closure System, and any source/proof objects referenced by this surface.

## Typography Recipe
Native iPhone semantic typography. The User System Profile title or active decision owns the strongest weight; explanatory source/proof text remains compact but readable. Dynamic Type must preserve User System Profile, the source/proof line, the primary command, and the recovery or cancel path.

## Spacing Recipe
Use a compact native iPhone rhythm: object-attached spacing, grouped rows only where they represent the same object, and no equal-weight dashboard/card stack. Primary controls remain thumb-zone aware with at least 44 pt touch intent.

## Material Recipe
GraphiteRecess is the ground. QuietGlass is reserved for sheets, trays, overlays, and inspectable transient layers. LuminousTrace expresses origin, attachment, source freshness, protection, pressure, or continuity. CelestialField appears only when it carries orientation or relationship meaning.

## Color and State Recipe
Color reinforces semantic state but never owns it. Fresh, stale, protected, pressure, blocked, waiting, recovery, local-only, disabled, receipt-confirmed, and unresolved states require visible labels, shape/placement, and accessibility text.

## Icon, Chevron, and Disclosure Recipe
Use SF Symbols where possible. Chevron means deeper inspection or navigation, not decoration. Icons must be paired with visible text or accessibility labels, especially for source, proof, protected, pressure, warning, receipt, and recovery meanings.

## CTA Recipe
One primary CTA maximum at rest. Secondary actions are quieter, cancel remains reachable, destructive actions are explicit and receipt-backed, and disabled actions explain what is needed without shame.

## Label and Microcopy Recipe
Use plain Ambitions language: Source, Privacy, Personal runtime, Reset, Forget, Notifications, Capture preferences, Focus defaults, and local trust terms where relevant. Avoid AI confidence, model language, productivity scores, overdue/failure copy, motivational filler, and retired top-level destination phrasing.

## Receipt / Proof / Source Recipe
Meaningful changes expose an expected receipt, existing receipt, proof link, source basis, or an explicit no-receipt reason. Proof is object-linked evidence, not decoration. Source freshness can be fresh, stale, unavailable, local-only, or unresolved and must be inspectable.

## State Model
default, active, empty, local-only, source unavailable, stale source, disabled, receipt-confirmed, unresolved direction, configured, needs setup, trust warning, offline local-only, reset pending.

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
- configured
- needs setup
- trust warning
- offline local-only
- reset pending

## Forbidden States
- shame/failure framing
- productivity score or streak framing
- hidden mutation
- chatbot or assistant framing
- color-only warnings
- retired destination framing

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

- Visual Canon: User System Profile stays settings-like, with local runtime, privacy, reset, and trust controls visible.
- SI: shared chrome, reusable primitives, and the object-first interface language.
- Accessibility: Dynamic Type, VoiceOver, Reduce Motion, contrast, and visible alternatives.
- QA / validation: declared validation scope, explicit gaps, and no screenshot or implementation proof claims.
- AOS: local runtime trust controls, inspectable reasoning, and no hidden inference.
- Privacy: memory, reset, delete, export, and local control.
- Runtime: on-device runtime posture and correction paths.
- You: User System Profile and personal control-plane language.
- PD: settings-style control language and personal defaults.

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
- social profile framing
- cloud account/admin-console framing

## Open Direction Gaps
- None for final visual intent in this recipe pass.

## P0 Proof Appendix

### Source Link Status

linked

### Implementation Proof Boundary

This recipe is final-state design canon for You Root / User System Profile in You. It does not prove implementation or release readiness.

### Good / Bad Example

- Good: You Root / User System Profile stays attached to User System Profile, with trust, proof, receipt, and recovery visible.
- Bad: You Root / User System Profile turns into a generic productivity pattern or hides its trust seam.

### Acceptance Checklist

- the surface stays anchored to User System Profile
- the source or trust seam is explicit
- the proof or receipt path is explicit
- the correction or recovery path is explicit
- the surface does not read as a generic dashboard, task list, or calendar clone

### Notes

- recipe path: docs/canon/frontend/recipes/you/you_root_user_system_profile.md
- source-link debt class: linked

## P0 Canon Appendix

### Source / Trust Behavior

You Root / User System Profile keeps its trust seam attached to User System Profile and You.

### Proof / Receipt Behavior

The surface keeps proof and receipt visible at the object edge instead of hiding them in a generic toast or feed.

### Transaction Behavior

Meaningful changes must be previewed, committed, receipted, and recoverable.

### VoiceOver Order

Object, state, source, proof, action, recovery.

### Dynamic Type Behavior

The dominant object and primary action must survive large text.

### Reduce Motion Behavior

Static before / after summaries replace motion meaning.

### Reduce Transparency Behavior

Opaque graphite layers must preserve state when blur is reduced.

### Increase Contrast Behavior

State boundaries and recovery affordances strengthen.

### Differentiate Without Color Behavior

Shape, label, spacing, and structure carry meaning without color.

### ADHD Density Law

One dominant action at rest. One safe recovery path always visible.

### Native iPhone Believability Requirements

The surface stays thumb-reachable, restrained, and native rather than dashboard-like.

### Anti-Generic Red Flags

- generic dashboard
- task list clone
- calendar clone
- chatbot persona

### Forbidden Interpretations

- implementation proof
- release proof
- screenshot proof
- production readiness

### Acceptance Checklist

- the object is still recognizable without labels
- the source / proof seam is visible
- the recovery path is visible
- the surface still reads as the named object, not a generic productivity app

## P0 Local Runtime Appendix

### Local Runtime

You Root / User System Profile exposes local runtime behavior as inspectable state, not hidden automation.

### User-Set / Learned / Suggested

The surface distinguishes user-set truth, learned guidance, and suggested defaults before any commitment.

### Reset / Forget

You Root / User System Profile previews local reset or forget consequences before the user commits to them.

### Trust Boundary

You remains local-first unless the active truth explicitly says otherwise.

### Acceptance Checklist

- local runtime is visible
- user-set, learned, and suggested states are distinguishable
- reset and forget are previewed
- automation remains inspectable
