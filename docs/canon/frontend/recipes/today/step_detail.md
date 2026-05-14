# Surface Recipe: Step Detail

## Canon Status
intended_canon

## Surface ID
step_detail

## Destination
Today

## Surface Type
drill_down

## Hierarchy Level
secondary_surface

## Parent Surface
Today Root

## Child Surfaces
- Step Detail
- Recommendation Source Sheet
- Closure Sheet
- Receipt Detail
- Reflow Preview Entry

## Final Intended Role
A Today support surface that keeps current context, action, proof, source, and recovery visibly attached to the Reality Meridian.

## User Perception
The user should immediately know what today is asking of them, why that action fits now, and how to close, adjust, or recover without shame.

## Why This Surface Exists
This recipe defines the intended final-state visual contract for Step Detail: what the user sees first, which Ambitions object owns the surface, how source/proof/receipt meaning appears, and which accessibility and anti-drift constraints govern future implementation. It remains design canon only; it is not SwiftUI instruction, screenshot proof, implementation status, or release evidence.

## Primary Object
Reality Meridian

## Supporting Objects
- Receipt System
- Source Freshness Badge
- Why This Sheet
- Closure System

## Visible Regions
- Reality Meridian orientation
- Current context/source strip
- Start Here or active Step object
- Now / Next / Later continuity
- Commitments and protected-time edge
- Closure/recovery/receipt shelf

## Region-by-Region Recipe

### Region 1: Reality Meridian orientation

- Purpose: Orient the user to the current object, destination, and state before any action is offered.
- Contains: Reality Meridian orientation; current Reality Meridian state; origin context when this is a drill-down or transient surface.
- Primitives: Compact Surface Header, Context Crown, LuminousTrace, semantic labels.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: None unless the header owns a back, close, or setup-later action.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap or back/close controls preserve origin and do not mutate data.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 2: Current context/source strip

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for Reality Meridian.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 3: Start Here or active Step object

- Purpose: Show how Start Here or active Step object changes the visible hierarchy, source/proof meaning, and available action for Step Detail.
- Contains: Reality Meridian; visible ingredients include current-day fit, Now / Next / Later continuity, protected-time or commitment context, source freshness, proof trail entry, receipt expectation, recovery path, and Why this? disclosure. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: Use a visible primary command only when this region changes Reality Meridian; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 4: Now / Next / Later continuity

- Purpose: Show how Now / Next / Later continuity changes the visible hierarchy, source/proof meaning, and available action for Step Detail.
- Contains: Reality Meridian; visible ingredients include current-day fit, Now / Next / Later continuity, protected-time or commitment context, source freshness, proof trail entry, receipt expectation, recovery path, and Why this? disclosure. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: Use a visible primary command only when this region changes Reality Meridian; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 5: Commitments and protected-time edge

- Purpose: Show how Commitments and protected-time edge changes the visible hierarchy, source/proof meaning, and available action for Step Detail.
- Contains: Reality Meridian; visible ingredients include current-day fit, Now / Next / Later continuity, protected-time or commitment context, source freshness, proof trail entry, receipt expectation, recovery path, and Why this? disclosure. Supporting objects: Receipt System, Source Freshness Badge, Why This Sheet, Closure System. Region context: orientation, primary object, source/proof line.
- Primitives: GraphiteRecess ground, LuminousTrace attachment, CelestialField only for semantic orientation, SF Symbols, chevrons, label system.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: Use a visible primary command only when this region changes Reality Meridian; otherwise prefer named disclosure rows such as Why this?, View source, View receipt, Add proof, Undo, or Close.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Tap inspects the object, opens the related detail, previews a change, or expands state context.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

### Region 6: Closure/recovery/receipt shelf

- Purpose: Make trust inspectable at rest and deeper on demand.
- Contains: Source freshness, proof basis, receipt expectation, unresolved-direction note, or Why this? affordance for Reality Meridian.
- Primitives: Source Freshness Badge, Receipt System, Proof Trail, Why This Sheet, QuietGlass for sheet depth.
- Typography: Use native iPhone semantic text hierarchy: compact region label, Reality Meridian title or state label, source/proof caption, and readable action text. Emphasis stays on the active Reality Meridian decision or inspected state.
- Spacing: Keep source, proof, CTA, and state notes visually attached to Reality Meridian, with tight native grouping, thumb-zone reach for actions, and enough separation to prevent equal-weight card stacking.
- Materials: GraphiteRecess as default ground; QuietGlass only for transient inspectable layers; LuminousTrace only where state or origin attachment needs to be visible.
- Color/state behavior: Meaning is carried by label, shape, placement, and accessibility text before color; color only reinforces state.
- Icons/chevrons: SF Symbols or chevrons clarify navigation, source, lock/protected, receipt, warning, or disclosure; icons never carry meaning alone.
- Labels: Use Ambitions-native language for Reality Meridian attachment, Start Here continuity, current-day fit, protected-time respect, closure and recovery visibility.
- CTAs: Why this?, View source, View receipt, Add proof, Undo, or Learn more depending on the surface.
- Receipts/proof: Source, proof, receipt, or explicit no-receipt reason remains visually attached to the changed or inspected object.
- Interaction meaning: Opens source/proof/receipt detail or a reversible explanation surface.
- Accessibility intent: VoiceOver names region, object, state, source/proof availability, and available action in that order.
- ADHD usability intent: The region reduces choice load by keeping one decision or one state explanation dominant.
- Forbidden treatments: Unowned dashboard panes, equal card stack, decorative celestial effects, chatbot framing, shame/score/streak language, color-only state, or retired top-level destination language.

## Primitive Inventory
GraphiteRecess, QuietGlass, LuminousTrace, CelestialField when semantic orientation is needed, Context Crown where orientation matters, Source Freshness Badge, Receipt System, Proof Trail, chevrons/disclosure rows, SF Symbols, semantic labels, primary/secondary/destructive/disabled CTA treatments.

## Object Inventory
Reality Meridian, plus any visible Receipt System, Closure System, Recommendation Source System, Proof Trail System, Commitment Staging Tray, Reflow Preview Tray, Personal Runtime, or source/proof objects referenced by this surface.

## Typography Recipe
Native iPhone semantic typography. The Reality Meridian title or active decision owns the strongest weight; explanatory source/proof text remains compact but readable. Dynamic Type must preserve Reality Meridian, the source/proof line, the primary command, and the recovery or cancel path.

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
default, active, empty, local-only, source unavailable, stale source, disabled, receipt-confirmed, unresolved direction, now, next, later, protected time, waiting, blocked, recovery, overloaded, away.

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
- now
- next
- later
- protected time
- waiting
- blocked
- recovery
- overloaded
- away

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
- PK: source/proof/receipt continuity for the current-day object and recovery state.
- MRI: recommendation source, correction, and return-path clarity.
- LID: inspectable local intelligence freshness and current-state explanation.
- REC: receipt and proof continuity attached to the changed object.
- Today: Reality Meridian, now/next/later sequencing, and current-day fit.
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
- Start Here as detached card
- Reality Meridian reduced to task list

## Open Direction Gaps
- None for final visual intent in this recipe pass.

## P0 Proof Appendix

### Source Link Status

intended_only

### Implementation Proof Boundary

This recipe is final-state design canon for Step Detail in Today. It does not prove implementation or release readiness.

### Good / Bad Example

- Good: Step Detail stays attached to Reality Meridian, with trust, proof, receipt, and recovery visible.
- Bad: Step Detail turns into a generic productivity pattern or hides its trust seam.

### Acceptance Checklist

- the surface stays anchored to Reality Meridian
- the source or trust seam is explicit
- the proof or receipt path is explicit
- the correction or recovery path is explicit
- the surface does not read as a generic dashboard, task list, or calendar clone

### Notes

- recipe path: docs/canon/frontend/recipes/today/step_detail.md
- source-link debt class: intended_only

## P0 Canon Appendix

### Source / Trust Behavior

Step Detail keeps its trust seam attached to Reality Meridian and Today.

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

Step Detail exposes local runtime behavior as inspectable state, not hidden automation.

### User-Set / Learned / Suggested

The surface distinguishes user-set truth, learned guidance, and suggested defaults before any commitment.

### Reset / Forget

Step Detail previews local reset or forget consequences before the user commits to them.

### Trust Boundary

Today remains local-first unless the active truth explicitly says otherwise.

### Acceptance Checklist

- local runtime is visible
- user-set, learned, and suggested states are distinguishable
- reset and forget are previewed
- automation remains inspectable

<!-- VISUAL_100_FINAL_PROOF_CONTRACT_BEGIN -->

# Visual 100 Final Proof Contract

## Purpose
Step Detail exists to make Today understandable through the Reality Meridian, not through a generic productivity screen.
Minimum specificity: the recipe must name step_detail, the user job, and the reason this surface owns that job.

## Surface Hierarchy
Step Detail sits inside Today and is subordinate to the Reality Meridian; supporting surfaces must not outrank it.
Minimum specificity: parent, child, and return-path behavior must remain attached to Reality Meridian rather than becoming separate navigation chrome.

## Primary Object Dependency
The governing object is Reality Meridian; source, proof, receipt, correction, and recovery behavior must stay attached to that object.
Minimum specificity: if Step Detail cannot show what Reality Meridian owns, the surface is not final-proof eligible.

## Label-Off Signature
With labels blurred, Step Detail must still read as Reality Meridian through orientation rail, current state seam, source/proof edge, primary action shelf, and recovery return path.
Minimum specificity: the signature must be structural, not a title, icon label, color wash, or decorative mark.

## Canonical Anatomy
The anatomy is orientation rail, current state seam, source/proof edge, primary action shelf, and recovery return path; those regions appear in stable order and preserve one dominant object at rest.
Minimum specificity: each region must name its role and must not become an interchangeable card in Today.

## Visible Regions
Visible regions for Step Detail: orientation rail, current state seam, source/proof edge, primary action shelf, and recovery return path.
Minimum specificity: each visible region must declare allowed state, allowed proof/source content, and its correction affordance.

## Dominant Object
The dominant object at rest is Reality Meridian, and all secondary content must explain or act on that object.
Minimum specificity: no equal-weight list, feed, grid, score, or decorative panel may compete with Reality Meridian.

## Supporting Objects
Supporting objects may include source freshness, proof trail, receipt, correction, and recovery affordances for Reality Meridian.
Minimum specificity: supporting objects stay visibly subordinate and cannot become independent destinations or hidden automation.

## Primitive Usage
Allowed primitives are object hierarchy, trust seam, source freshness, proof/receipt, disclosure, correction, and recovery for Reality Meridian.
Minimum specificity: primitives must communicate Ambitions state and never become generic decoration or model-confidence theater.

## Typography Roles
Typography gives Reality Meridian the strongest weight, source/proof compact weight, and correction or recovery an always-readable command weight.
Minimum specificity: large text must preserve object, state, action, and recovery before secondary metadata.

## Spacing Rules
Spacing groups content by relationship to Reality Meridian; source/proof, action, and recovery stay object-attached with native touch intent.
Minimum specificity: the surface must avoid equal card spacing that makes every panel look equally important.

## Material Rules
Ground, layer, and transient material must clarify Reality Meridian, source/proof inspection, and correction depth.
Minimum specificity: glass or texture is allowed only when it communicates hierarchy, source, proof, or reversible action.

## Color / State Rules
Color may reinforce fresh, stale, blocked, protected, local-only, receipt-confirmed, or recovery state for Reality Meridian.
Minimum specificity: every state must also use words, shape, placement, or structure so color never carries meaning alone.

## Iconography
Icons may identify source, proof, receipt, disclosure, warning, protected state, or recovery for Reality Meridian.
Minimum specificity: an icon must never replace the visible state or become the only explanation of consequence.

## Chevron / Disclosure Rules
Disclosure opens deeper source, proof, consequence, or correction detail for Step Detail; it is never decorative navigation noise.
Minimum specificity: every chevron must have a visible label or accessibility meaning tied to Reality Meridian.

## Source / Trust Behavior
Source Link Status: intended_only. Step Detail must show whether source is linked, intended-only, stale, unavailable, or local-only.
Minimum specificity: trust behavior must expose source basis and correction path without implying implementation proof.

## Proof / Receipt Behavior
Proof and Receipt behavior stays attached to Reality Meridian; receipts confirm meaningful changes and proof explains what changed or why.
Minimum specificity: proof cannot be a detached feed, generic toast, or release claim for Step Detail.

## Transaction Behavior
Transactions on Step Detail require visible intent, preview when consequence matters, explicit commit, receipt, and undo or recovery.
Minimum specificity: the surface must block silent mutation and show the consequence of acting on Reality Meridian.

## Primary Action
Primary Action: one dominant action at rest acts on Reality Meridian and explains why it is available now.
Minimum specificity: competing CTAs must collapse behind disclosure or become secondary correction paths.

## Secondary Correction Path
Secondary correction path lets the user inspect, undo, re-place, reset, recover, or choose a safer route for Reality Meridian.
Minimum specificity: correction must be visible without blame and cannot be hidden behind model-like explanation copy.

## Empty State
No day object is ready yet; keep Start Here, source state, and a safe capture or recovery path visible.
Minimum specificity: empty state must preserve destination purpose and avoid motivational filler or fake completion.

## Loading / Unknown State
If source state is unresolved, label it as local, stale, unavailable, or still reading instead of guessing.
Minimum specificity: unknown state must be explicit and must not present guessed source, proof, or readiness.

## Error / Conflict State
When recommendation, proof, or current-day fit conflicts, show the source mismatch and the correction path.
Minimum specificity: conflict state must identify source/proof/fit conflict without shame or hidden mutation.

## Recovery State
Recovery keeps one safe next step, proof context, and a visible way back without shame language.
Minimum specificity: recovery must include a visible correction path and no blame-oriented language.

## VoiceOver Order
VoiceOver Order: Today, Step Detail, Reality Meridian, state, source status, proof or receipt status, primary action, correction path.
Minimum specificity: announcement order must preserve object, state, source/proof, action, and recovery without relying on layout.

## Dynamic Type Behavior
Dynamic Type keeps Reality Meridian, current state, source/proof line, primary action, and correction path visible before secondary details.
Minimum specificity: large text may collapse metadata but must not hide action, receipt, source, or recovery meaning.

## Reduce Motion Behavior
Reduce Motion replaces movement in Step Detail with static before/after labels, source summaries, receipt state, and recovery labels.
Minimum specificity: no meaning may depend only on animation, haptics, parallax, or moving continuity.

## Reduce Transparency Behavior
Reduce Transparency turns transient layers for Reality Meridian into opaque native surfaces while preserving state, hierarchy, and disclosure.
Minimum specificity: blur removal must not erase source/proof separation or correction affordances.

## Increase Contrast Behavior
Increase Contrast strengthens boundaries around Reality Meridian, state labels, proof/source seams, destructive choices, and recovery controls.
Minimum specificity: contrast changes must add stronger borders, clearer boundaries, or reinforced separation without introducing color-only meaning.

## Differentiate Without Color Behavior
Differentiate Without Color uses labels, shape, placement, icons with text, and hierarchy to distinguish Reality Meridian states.
Minimum specificity: fresh/stale/blocked/protected/recovery states must remain legible without hue differences.

## ADHD Density Law
ADHD Density Law: one dominant Reality Meridian decision at rest, one primary action, and one safe correction or recovery path.
Minimum specificity: supporting details must progressively disclose rather than competing for first attention.

## Native iPhone Believability Requirements
Step Detail must feel like a restrained native iPhone surface with thumb-reachable actions, semantic rows, sheets, and stable safe areas.
Minimum specificity: include sheet and tray behavior, SF Symbols with labels, thumb reach, safe-area respect, and native iPhone controls while avoiding web-dashboard density, custom novelty chrome, hidden gestures, and unlabelled visual state.

## Train / Source-Family Influence
Source-family influence for Step Detail: visual canon, accessibility, source/proof receipts, local trust, transaction, and Today object depth.
Minimum specificity: train references must explain behavior, not imply shipped SwiftUI implementation.

## Source Linkage
Source Link Status: intended_only. Implementation Proof Boundary: Not In Scope. Required gates: object_depth, transaction, proof_source_receipt, accessibility.
Minimum specificity: linked and intended-only debt must remain visible in reports and cannot be converted into implementation claims.

## Implementation Proof Boundary
Implementation Proof Boundary: this recipe is final-state design canon for Step Detail; it does not prove SwiftUI, device, release, or accessibility implementation.
Minimum specificity: proof requires source inspection, local validation, and release evidence outside this recipe.

## Unresolved Direction
Unresolved direction for Step Detail: any missing implementation source remains intended_only debt and must stay visible until a scoped implementation batch lands.
Minimum specificity: unresolved work must be named as debt, not hidden behind Green language.

## Anti-Generic Red Flags
Bad example: an equal stack of tasks, metrics, and recommendations with no clear daily orientation object.
Validator hint: fail Step Detail if Reality Meridian can be replaced by a generic list, calendar, chat, settings, score, or dashboard surface.

## Forbidden Interpretations
Forbidden interpretations: implementation proof, release proof, device proof, accessibility conformance proof, hosted automation, or top-level IA changes.
Minimum specificity: Step Detail may define design canon only and must not claim production readiness.

## Acceptance Checklist
Good example: one current-day object with source, proof, action, and recovery visibly attached.
Acceptance requires source linkage, proof boundary, VoiceOver/Dynamic Type/Reduce Motion coverage, primary action, correction path, and anti-generic checks for Step Detail.

## P0 Proof Appendix
- Source Link Status: intended_only; Step Detail must keep source status inspectable, including local-only and stale source states, and must not hide intended-only debt.
- Implementation Proof Boundary: Not In Scope; this recipe does not prove shipped SwiftUI, device behavior, release readiness, or accessibility conformance.
- Good / Bad Example: good is one current-day object with source, proof, action, and recovery visibly attached; bad is an equal stack of tasks, metrics, and recommendations with no clear daily orientation object.
- Acceptance Checklist: source status visible, implementation boundary named, primary action visible, correction path visible, and proof/receipt behavior attached to Reality Meridian.
The proof appendix exists to prevent a false Green for Step Detail. It records what can be claimed as design canon and what remains outside implementation proof.
A reviewer should be able to inspect Today, locate Reality Meridian, identify the source/proof seam, and see why implementation proof remains Not In Scope.
Evidence note: Step Detail must keep generated reports, source-link status, and Not In Scope implementation proof aligned before any Green claim.
If any report upgrades Step Detail without this boundary, the validator must fail rather than convert intended canon into shipped behavior.

## P0 Canon Appendix
VoiceOver must announce Today, Step Detail, Reality Meridian, state, Source, Proof, Receipt, Primary Action, and recovery in that order.
Dynamic Type must preserve the dominant object, source/proof line, primary action, and correction path before secondary metadata.
Reduce Motion must replace animated meaning with static source, proof, before/after, and receipt labels.
Reduce Transparency must preserve hierarchy with opaque native layers when blur or glass is reduced.
Increase Contrast and Differentiate Without Color must keep state, warning, protected, blocked, receipt, and recovery meanings visible without hue alone.
Proof, Receipt, and Source remain attached to Reality Meridian; Primary Action stays singular and correction remains visible without shame language.
This appendix is canon authority for Step Detail, not implementation proof, release proof, or an approval to alter top-level IA.

<!-- VISUAL_100_FINAL_PROOF_CONTRACT_END -->
