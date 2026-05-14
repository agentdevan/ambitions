# Surface Recipe: Automation & Trust

## Canon Status
intended_canon

## Surface ID
automation_and_trust

## Destination
You

## Surface Type
drill_down

## Hierarchy Level
secondary_surface

## Parent Surface
You Root

## Child Surfaces
- Trust detail
- Privacy detail
- Planning Defaults
- Local Data / Reset / Forget

## Final Intended Role
A trust/control surface that makes local learning, source use, reset, and privacy choices inspectable without account/admin framing.

## User Perception
The user should feel in control of a private local system, with settings-style clarity and no social, account, or admin-console tone.

## Why This Surface Exists
This recipe defines the intended final-state visual contract for Automation & Trust: what the user sees first, which Ambitions object owns the surface, how source/proof/receipt meaning appears, and which accessibility and anti-drift constraints govern future implementation. It remains design canon only; it is not SwiftUI instruction, screenshot proof, implementation status, or release evidence.

## Primary Object
User System Profile

## Supporting Objects
- Receipt System
- Source Freshness Badge
- Why This Sheet
- Closure System

## Visible Regions
- User System Profile header
- Settings-style section body
- Trust/local runtime explanation
- Control row or disclosure
- Receipt/reset/source line
- Warning/offline/first-run state

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

- Purpose: Show how Settings-style section body changes the visible hierarchy, source/proof meaning, and available action for Automation & Trust.
- Contains: User System Profile; visible ingredients include User System Profile setting or runtime object, local data boundary, privacy/control state, receipt/history link, export/reset disclosure, and source or proof context. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
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

- Purpose: Show how Trust/local runtime explanation changes the visible hierarchy, source/proof meaning, and available action for Automation & Trust.
- Contains: User System Profile; visible ingredients include User System Profile setting or runtime object, local data boundary, privacy/control state, receipt/history link, export/reset disclosure, and source or proof context. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
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
- Contains: Primary and secondary commands for Automation & Trust; disabled/destructive states when applicable; cancel and undo where reversible.
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

- Purpose: Show how Warning/offline/first-run state changes the visible hierarchy, source/proof meaning, and available action for Automation & Trust.
- Contains: User System Profile; visible ingredients include User System Profile setting or runtime object, local data boundary, privacy/control state, receipt/history link, export/reset disclosure, and source or proof context. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
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
User System Profile, plus any visible Receipt System, Closure System, Recommendation Source System, Proof Trail System, Commitment Staging Tray, Reflow Preview Tray, Personal Runtime, or source/proof objects referenced by this surface.

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
Use plain Ambitions language: Start here, Shape Time, Still counts, Source, Why this?, Receipt, Needs a Place, Protected, Waiting, Blocked, Needs recovery, and local trust terms where relevant. Avoid AI confidence, model language, productivity scores, overdue/failure copy, motivational filler, and retired top-level destination phrasing.

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

- Visual Canon: quiet-luxury hierarchy, native primitives, and no generic dashboard drift.
- SI: shared chrome, reusable primitives, and the object-first interface language.
- Accessibility: Dynamic Type, VoiceOver, Reduce Motion, contrast, and visible alternatives.
- QA / validation: declared validation scope, explicit gaps, and no screenshot or implementation proof claims.
- AOS: local runtime trust controls, inspectable reasoning, and no hidden inference.
- Privacy: memory, reset, delete, export, and local control.
- Runtime: on-device runtime posture and correction paths.
- You: User System Profile and personal control-plane language.
- PD: settings-style control language and personal defaults.
- REC: receipt, proof, source, and correction visibility.
- MRI: inspectable source basis and correction routing.
- LID: local-intelligence freshness and source explanation.

## Source Truth
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- frontend/visual-encyclopedia/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md

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

intended_only

### Implementation Proof Boundary

This recipe is final-state design canon for Automation & Trust in You. It does not prove implementation or release readiness.

### Good / Bad Example

- Good: Automation & Trust stays attached to User System Profile, with trust, proof, receipt, and recovery visible.
- Bad: Automation & Trust turns into a generic productivity pattern or hides its trust seam.

### Acceptance Checklist

- the surface stays anchored to User System Profile
- the source or trust seam is explicit
- the proof or receipt path is explicit
- the correction or recovery path is explicit
- the surface does not read as a generic dashboard, task list, or calendar clone

### Notes

- recipe path: frontend/visual-encyclopedia/recipes/you/automation_and_trust.md
- source-link debt class: intended_only

## P0 Canon Appendix

### Source / Trust Behavior

Automation & Trust keeps its trust seam attached to User System Profile and You.

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

Automation & Trust exposes local runtime behavior as inspectable state, not hidden automation.

### User-Set / Learned / Suggested

The surface distinguishes user-set truth, learned guidance, and suggested defaults before any commitment.

### Reset / Forget

Automation & Trust previews local reset or forget consequences before the user commits to them.

### Trust Boundary

You remains local-first unless the active truth explicitly says otherwise.

### Acceptance Checklist

- local runtime is visible
- user-set, learned, and suggested states are distinguishable
- reset and forget are previewed
- automation remains inspectable

<!-- VISUAL_100_FINAL_PROOF_CONTRACT_BEGIN -->

# Visual 100 Final Proof Contract

## Purpose
Automation & Trust exists to make You understandable through the User System Profile, not through a generic productivity screen.
Minimum specificity: the recipe must name automation_and_trust, the user job, and the reason this surface owns that job.

## Surface Hierarchy
Automation & Trust sits inside You and is subordinate to the User System Profile; supporting surfaces must not outrank it.
Minimum specificity: parent, child, and return-path behavior must remain attached to User System Profile rather than becoming separate navigation chrome.

## Primary Object Dependency
The governing object is User System Profile; source, proof, receipt, correction, and recovery behavior must stay attached to that object.
Minimum specificity: if Automation & Trust cannot show what User System Profile owns, the surface is not final-proof eligible.

## Label-Off Signature
With labels blurred, Automation & Trust must still read as User System Profile through local runtime panel, trust controls, reset/forget preview, source/proof edge, and recovery return path.
Minimum specificity: the signature must be structural, not a title, icon label, color wash, or decorative mark.

## Canonical Anatomy
The anatomy is local runtime panel, trust controls, reset/forget preview, source/proof edge, and recovery return path; those regions appear in stable order and preserve one dominant object at rest.
Minimum specificity: each region must name its role and must not become an interchangeable card in You.

## Visible Regions
Visible regions for Automation & Trust: local runtime panel, trust controls, reset/forget preview, source/proof edge, and recovery return path.
Minimum specificity: each visible region must declare allowed state, allowed proof/source content, and its correction affordance.

## Dominant Object
The dominant object at rest is User System Profile, and all secondary content must explain or act on that object.
Minimum specificity: no equal-weight list, feed, grid, score, or decorative panel may compete with User System Profile.

## Supporting Objects
Supporting objects may include source freshness, proof trail, receipt, correction, and recovery affordances for User System Profile.
Minimum specificity: supporting objects stay visibly subordinate and cannot become independent destinations or hidden automation.

## Primitive Usage
Allowed primitives are object hierarchy, trust seam, source freshness, proof/receipt, disclosure, correction, and recovery for User System Profile.
Minimum specificity: primitives must communicate Ambitions state and never become generic decoration or model-confidence theater.

## Typography Roles
Typography gives User System Profile the strongest weight, source/proof compact weight, and correction or recovery an always-readable command weight.
Minimum specificity: large text must preserve object, state, action, and recovery before secondary metadata.

## Spacing Rules
Spacing groups content by relationship to User System Profile; source/proof, action, and recovery stay object-attached with native touch intent.
Minimum specificity: the surface must avoid equal card spacing that makes every panel look equally important.

## Material Rules
Ground, layer, and transient material must clarify User System Profile, source/proof inspection, and correction depth.
Minimum specificity: glass or texture is allowed only when it communicates hierarchy, source, proof, or reversible action.

## Color / State Rules
Color may reinforce fresh, stale, blocked, protected, local-only, receipt-confirmed, or recovery state for User System Profile.
Minimum specificity: every state must also use words, shape, placement, or structure so color never carries meaning alone.

## Iconography
Icons may identify source, proof, receipt, disclosure, warning, protected state, or recovery for User System Profile.
Minimum specificity: an icon must never replace the visible state or become the only explanation of consequence.

## Chevron / Disclosure Rules
Disclosure opens deeper source, proof, consequence, or correction detail for Automation & Trust; it is never decorative navigation noise.
Minimum specificity: every chevron must have a visible label or accessibility meaning tied to User System Profile.

## Source / Trust Behavior
Source Link Status: intended_only. Automation & Trust must show whether source is linked, intended-only, stale, unavailable, or local-only.
Minimum specificity: trust behavior must expose source basis and correction path without implying implementation proof.

## Proof / Receipt Behavior
Proof and Receipt behavior stays attached to User System Profile; receipts confirm meaningful changes and proof explains what changed or why.
Minimum specificity: proof cannot be a detached feed, generic toast, or release claim for Automation & Trust.

## Transaction Behavior
Transactions on Automation & Trust require visible intent, preview when consequence matters, explicit commit, receipt, and undo or recovery.
Minimum specificity: the surface must block silent mutation and show the consequence of acting on User System Profile.

## Primary Action
Primary Action: one dominant action at rest acts on User System Profile and explains why it is available now.
Minimum specificity: competing CTAs must collapse behind disclosure or become secondary correction paths.

## Secondary Correction Path
Secondary correction path lets the user inspect, undo, re-place, reset, recover, or choose a safer route for User System Profile.
Minimum specificity: correction must be visible without blame and cannot be hidden behind model-like explanation copy.

## Empty State
No trust control is being edited yet; keep local data status, reset/forget preview, and support paths visible.
Minimum specificity: empty state must preserve destination purpose and avoid motivational filler or fake completion.

## Loading / Unknown State
If local runtime state is unresolved, show the exact control state and avoid hidden automation claims.
Minimum specificity: unknown state must be explicit and must not present guessed source, proof, or readiness.

## Error / Conflict State
When trust, reset, or automation state conflicts, show the consequence preview and require explicit confirmation.
Minimum specificity: conflict state must identify source/proof/fit conflict without shame or hidden mutation.

## Recovery State
Recovery previews local-data consequences, offers cancel, and keeps export/reset/forget receipts inspectable.
Minimum specificity: recovery must include a visible correction path and no blame-oriented language.

## VoiceOver Order
VoiceOver Order: You, Automation & Trust, User System Profile, state, source status, proof or receipt status, primary action, correction path.
Minimum specificity: announcement order must preserve object, state, source/proof, action, and recovery without relying on layout.

## Dynamic Type Behavior
Dynamic Type keeps User System Profile, current state, source/proof line, primary action, and correction path visible before secondary details.
Minimum specificity: large text may collapse metadata but must not hide action, receipt, source, or recovery meaning.

## Reduce Motion Behavior
Reduce Motion replaces movement in Automation & Trust with static before/after labels, source summaries, receipt state, and recovery labels.
Minimum specificity: no meaning may depend only on animation, haptics, parallax, or moving continuity.

## Reduce Transparency Behavior
Reduce Transparency turns transient layers for User System Profile into opaque native surfaces while preserving state, hierarchy, and disclosure.
Minimum specificity: blur removal must not erase source/proof separation or correction affordances.

## Increase Contrast Behavior
Increase Contrast strengthens boundaries around User System Profile, state labels, proof/source seams, destructive choices, and recovery controls.
Minimum specificity: contrast changes must add stronger borders, clearer boundaries, or reinforced separation without introducing color-only meaning.

## Differentiate Without Color Behavior
Differentiate Without Color uses labels, shape, placement, icons with text, and hierarchy to distinguish User System Profile states.
Minimum specificity: fresh/stale/blocked/protected/recovery states must remain legible without hue differences.

## ADHD Density Law
ADHD Density Law: one dominant User System Profile decision at rest, one primary action, and one safe correction or recovery path.
Minimum specificity: supporting details must progressively disclose rather than competing for first attention.

## Native iPhone Believability Requirements
Automation & Trust must feel like a restrained native iPhone surface with thumb-reachable actions, semantic rows, sheets, and stable safe areas.
Minimum specificity: include sheet and tray behavior, SF Symbols with labels, thumb reach, safe-area respect, and native iPhone controls while avoiding web-dashboard density, custom novelty chrome, hidden gestures, and unlabelled visual state.

## Train / Source-Family Influence
Source-family influence for Automation & Trust: visual canon, accessibility, source/proof receipts, local trust, transaction, and You object depth.
Minimum specificity: train references must explain behavior, not imply shipped SwiftUI implementation.

## Source Linkage
Source Link Status: intended_only. Implementation Proof Boundary: Not In Scope. Required gates: hidden_automation, local_first_trust, accessibility.
Minimum specificity: linked and intended-only debt must remain visible in reports and cannot be converted into implementation claims.

## Implementation Proof Boundary
Implementation Proof Boundary: this recipe is final-state design canon for Automation & Trust; it does not prove SwiftUI, device, release, or accessibility implementation.
Minimum specificity: proof requires source inspection, local validation, and release evidence outside this recipe.

## Unresolved Direction
Unresolved direction for Automation & Trust: any missing implementation source remains intended_only debt and must stay visible until a scoped implementation batch lands.
Minimum specificity: unresolved work must be named as debt, not hidden behind Green language.

## Anti-Generic Red Flags
Bad example: a generic settings clone that hides local data, reset, and trust behavior.
Validator hint: fail Automation & Trust if User System Profile can be replaced by a generic list, calendar, chat, settings, score, or dashboard surface.

## Forbidden Interpretations
Forbidden interpretations: implementation proof, release proof, device proof, accessibility conformance proof, hosted automation, or top-level IA changes.
Minimum specificity: Automation & Trust may define design canon only and must not claim production readiness.

## Acceptance Checklist
Good example: one local-control object where privacy, runtime, reset, export, and correction stay inspectable.
Acceptance requires source linkage, proof boundary, VoiceOver/Dynamic Type/Reduce Motion coverage, primary action, correction path, and anti-generic checks for Automation & Trust.

## P0 Proof Appendix
- Source Link Status: intended_only; Automation & Trust must keep source status inspectable, including local-only and stale source states, and must not hide intended-only debt.
- Implementation Proof Boundary: Not In Scope; this recipe does not prove shipped SwiftUI, device behavior, release readiness, or accessibility conformance.
- Good / Bad Example: good is one local-control object where privacy, runtime, reset, export, and correction stay inspectable; bad is a generic settings clone that hides local data, reset, and trust behavior.
- Acceptance Checklist: source status visible, implementation boundary named, primary action visible, correction path visible, and proof/receipt behavior attached to User System Profile.
The proof appendix exists to prevent a false Green for Automation & Trust. It records what can be claimed as design canon and what remains outside implementation proof.
A reviewer should be able to inspect You, locate User System Profile, identify the source/proof seam, and see why implementation proof remains Not In Scope.
Evidence note: Automation & Trust must keep generated reports, source-link status, and Not In Scope implementation proof aligned before any Green claim.
If any report upgrades Automation & Trust without this boundary, the validator must fail rather than convert intended canon into shipped behavior.

## P0 Canon Appendix
VoiceOver must announce You, Automation & Trust, User System Profile, state, Source, Proof, Receipt, Primary Action, and recovery in that order.
Dynamic Type must preserve the dominant object, source/proof line, primary action, and correction path before secondary metadata.
Reduce Motion must replace animated meaning with static source, proof, before/after, and receipt labels.
Reduce Transparency must preserve hierarchy with opaque native layers when blur or glass is reduced.
Increase Contrast and Differentiate Without Color must keep state, warning, protected, blocked, receipt, and recovery meanings visible without hue alone.
Proof, Receipt, and Source remain attached to User System Profile; Primary Action stays singular and correction remains visible without shame language.
This appendix is canon authority for Automation & Trust, not implementation proof, release proof, or an approval to alter top-level IA.

<!-- VISUAL_100_FINAL_PROOF_CONTRACT_END -->
