# Pattern Atlas

These are structural patterns, not components or visual prescriptions. `Test` means worthy of a bounded prototype; `Hold` means useful but premature; `Reject` means informative mainly as a boundary.

## PAT-G01 — Persistent object anchor

- **Examples:** Flighty flight identity; Day One entry; Apple Photos person or memory.
- **Problem solved:** Keeps one canonical object recognizable while state and perspective change.
- **Spatial mechanism:** Stable identity position or repeated alignment, with changing context around it.
- **Interaction mechanism:** Depth and alternate views preserve the same object identifier and return target.
- **Accessibility equivalent:** Announce object identity first and retain it as the navigation heading.
- **Strength:** Prevents depth from feeling like unrelated screens.
- **Risk:** Can become an oversized repeated hero title.
- **Ambitions relevance:** Essential for Life Area → Goal → Path → relationship → return.
- **Not a card/list/stepper/graph:** Continuity comes from identity and placement, not a container or sequence widget.
- **Disposition:** `TEST`.

## PAT-G02 — Identity-preserving expansion

- **Examples:** Things Areas; Reminders collapsible sections; Bear folded sections.
- **Problem solved:** Reveals depth without replacing the parent context.
- **Spatial mechanism:** One region expands in place while peers compress or recede.
- **Interaction mechanism:** Native disclosure with stable selection and reversible return.
- **Accessibility equivalent:** Expanded/collapsed traits and a logical parent-before-child reading order.
- **Strength:** One Life Area can become materially deeper without implying rank.
- **Risk:** Accordion or disclosure-list appearance.
- **Ambitions relevance:** Strong root candidate if expansion becomes spatially meaningful rather than generic.
- **Not a card/list/stepper/graph:** Expansion alters the field’s hierarchy, not merely a row’s height.
- **Disposition:** `TEST`.

## PAT-G03 — Focus isolation

- **Examples:** iA Writer Focus Mode; Bear editor; Primary’s content-first interface.
- **Problem solved:** Gives one object decisive authority without more chrome.
- **Spatial mechanism:** Selective emphasis and contextual recession.
- **Interaction mechanism:** Entering depth removes nonessential controls while navigation stays native.
- **Accessibility equivalent:** Heading order and focus placement provide the same prioritization without dimming.
- **Strength:** Calm, clear, and native.
- **Risk:** Can create a sparse copy-heavy document.
- **Ambitions relevance:** Useful only when paired with living pursuit structure.
- **Not a card/list/stepper/graph:** Authority comes from subtraction and emphasis.
- **Disposition:** `TEST`.

## PAT-G04 — Attached contextual lens

- **Examples:** Craft backlinks/Collections; Apple Health trend detail; Weather map depth.
- **Problem solved:** Adds a meaningful perspective without creating a disconnected dashboard module.
- **Spatial mechanism:** Lens shares an edge, alignment, or transition origin with its object.
- **Interaction mechanism:** Selection expands the lens from the current object and returns to it.
- **Accessibility equivalent:** Named relationship and explicit return to the owning Goal.
- **Strength:** Fits the Linked Goal Lens doctrine.
- **Risk:** Can become an inset card or database panel.
- **Ambitions relevance:** High if the lens changes what is perceptible, not merely how much copy is shown.
- **Not a card/list/stepper/graph:** The lens is a perspective transition attached to identity.
- **Disposition:** `TEST`.

## PAT-G05 — Current-position seam

- **Examples:** Flighty phase changes; Gentler Streak present load; Weather current condition.
- **Problem solved:** Makes “where this pursuit is now” immediately legible.
- **Spatial mechanism:** A seam or boundary separates lived/accepted state from what has not happened.
- **Interaction mechanism:** Selecting the seam reveals the current state without implying completion.
- **Accessibility equivalent:** Explicit “current” state label plus ordered surrounding context.
- **Strength:** Can replace decorative current nodes and duplicated labels.
- **Risk:** Easily becomes a progress line or stepper marker.
- **Ambitions relevance:** Central to Path and focused Goal.
- **Not a card/list/stepper/graph:** It marks a semantic boundary, not a numeric position.
- **Disposition:** `TEST`.

## PAT-G06 — Future-state horizon

- **Examples:** Weather forecast horizon; Tide Guide movement beyond now; Calendar forthcoming views.
- **Problem solved:** Shows future possibility without claiming a determined plan.
- **Spatial mechanism:** Reduced specificity, openness, or soft boundary as distance increases.
- **Interaction mechanism:** Progressive disclosure reveals only source-supported future detail.
- **Accessibility equivalent:** Ordered “next” and “possible later” groups with uncertainty stated.
- **Strength:** Makes uncertainty structural rather than footnoted.
- **Risk:** Gradients or fading can become decorative or inaccessible.
- **Ambitions relevance:** Strong for Future Steps.
- **Not a card/list/stepper/graph:** Future is an epistemic horizon, not a row of milestones.
- **Disposition:** `TEST`.

## PAT-G07 — Recovery envelope

- **Examples:** Flighty disruption context; Gentler Streak recovery guidance; Apple system undo/retry patterns.
- **Problem solved:** Preserves identity and accepted truth when progress is interrupted.
- **Spatial mechanism:** Interruption wraps or bends the current context without replacing it.
- **Interaction mechanism:** Recovery appears in place with safe continuation and deferral.
- **Accessibility equivalent:** State announcement, preserved object heading, explicit recovery actions.
- **Strength:** Humane and truthful.
- **Risk:** Warning-panel or remediation-workflow drift.
- **Ambitions relevance:** Required for a living pursuit.
- **Not a card/list/stepper/graph:** Recovery is a state of the same object, not an error module.
- **Disposition:** `TEST`.

## PAT-G08 — History-relative continuity band

- **Examples:** Gentler Streak Activity Path; Apple Fitness trends; Apple Health change detection.
- **Problem solved:** Places present reality in personal history without an absolute score.
- **Spatial mechanism:** A qualitative band or range contextualizes current state against recent history.
- **Interaction mechanism:** Scrub or select to inspect meaningful changes.
- **Accessibility equivalent:** A concise comparison such as “steadier than recent weeks,” with detail on demand.
- **Strength:** Emotionally intelligent progression.
- **Risk:** Quantification, chart authority, or fitness imitation.
- **Ambitions relevance:** Potentially powerful if qualitative and source-backed.
- **Not a card/list/stepper/graph:** It is contextual range, not a completion axis.
- **Disposition:** `HOLD` pending semantic precision.

## PAT-G09 — Selected-detail emergence

- **Examples:** Weather map selection; Freeform scenes; Tide Guide press-and-hold value inspection.
- **Problem solved:** Reveals exact detail without permanent panel clutter.
- **Spatial mechanism:** Detail emerges at or near the selected spatial position.
- **Interaction mechanism:** Tap, press, or focus exposes a transient anchored inspector.
- **Accessibility equivalent:** Selecting an item navigates to or expands a labeled semantic detail region.
- **Strength:** Preserves whole-to-part context.
- **Risk:** Popover/tool-tip behavior can be hard to discover or scale.
- **Ambitions relevance:** Useful for Path current/uncertain/Proof detail.
- **Not a card/list/stepper/graph:** Detail is conditional and anchored, not a permanent selected card.
- **Disposition:** `TEST`.

## PAT-G10 — Consequence-layered relationship

- **Examples:** Photos collections around people/events; Flighty delay cause and impact; Journal suggestion context.
- **Problem solved:** Explains a relationship through what it changes or protects rather than ontology.
- **Spatial mechanism:** Related object appears as a supporting or constraining layer adjacent to the Goal.
- **Interaction mechanism:** Selecting the relationship reveals its consequence, then the related identity.
- **Accessibility equivalent:** “Supports,” “protects,” or “constrains” phrasing before metadata.
- **Strength:** Human and operational.
- **Risk:** Ambiguous ownership if proximity is the only cue.
- **Ambitions relevance:** Direct replacement for the rejected relationship inspector.
- **Not a card/list/stepper/graph:** Relationship is experienced as consequence and adjacency, not an edge diagram.
- **Disposition:** `TEST`.

## PAT-G11 — Inline owner depth

- **Examples:** Things projects under Areas; Photos people collections; Reminders lists under groups.
- **Problem solved:** Keeps canonical ownership visible through depth.
- **Spatial mechanism:** Owner is a stable parent plane or inline identity band rather than detached metadata.
- **Interaction mechanism:** Native back/return restores the exact owner context.
- **Accessibility equivalent:** Announce Goal, then “in Home,” and provide a labeled return action.
- **Strength:** Prevents Goal from becoming a free-floating project.
- **Risk:** Breadcrumb proliferation.
- **Ambitions relevance:** Essential Life Area lineage.
- **Not a card/list/stepper/graph:** Ownership is hierarchy and return, not a connector.
- **Disposition:** `TEST`.

## PAT-G12 — Multi-view same corpus

- **Examples:** Day One views; Calendar month/week/list; Weather forecast/map.
- **Problem solved:** Provides different questions over the same truth without duplicating canonical objects.
- **Spatial mechanism:** Each view transforms density and emphasis but keeps identity anchors.
- **Interaction mechanism:** Native view switching or depth transition with preserved selection.
- **Accessibility equivalent:** Same accessible object IDs and state labels across compositions.
- **Strength:** Supports root, Lens, focused Goal, and Path coherence.
- **Risk:** Mode complexity and navigation duplication.
- **Ambitions relevance:** High if each view has a distinct owned question.
- **Not a card/list/stepper/graph:** These are semantic projections, not duplicated panels.
- **Disposition:** `TEST`.

## PAT-G13 — Spatial scrub

- **Examples:** Tide Guide chart; Weather map timeline; media timelines.
- **Problem solved:** Makes change inspectable through direct manipulation.
- **Spatial mechanism:** One continuous field responds at the touched position.
- **Interaction mechanism:** Drag or scrub changes selected context while keeping the whole visible.
- **Accessibility equivalent:** Stepper/adjustable action with spoken positions and a semantic list fallback.
- **Strength:** Immediate understanding.
- **Risk:** Falsely continuous Path, poor discoverability, motor-access burden.
- **Ambitions relevance:** Possibly useful for history, not for invented future precision.
- **Not a card/list/stepper/graph:** Direct exploration of a field rather than discrete milestone navigation.
- **Disposition:** `HOLD`.

## PAT-G14 — Glance-to-depth bridge

- **Examples:** Flighty Live Activities; Apple Health Highlights; Opal widgets.
- **Problem solved:** Carries one important state from glanceable summary into full context.
- **Spatial mechanism:** Compact state shares identity and visual signature with depth.
- **Interaction mechanism:** Tapping the compact projection opens the same canonical object.
- **Accessibility equivalent:** Consistent label, value, and route identity.
- **Strength:** Supports eventual Today projection without conflating roots.
- **Risk:** Widget-first or notification-led product drift.
- **Ambitions relevance:** Important cross-root law, not a Goals R01 feature.
- **Not a card/list/stepper/graph:** It is an identity bridge between surfaces.
- **Disposition:** `HOLD`.

## PAT-G15 — Material-change-first hierarchy

- **Examples:** Apple Health Trends; Flighty disruption; Primary content hierarchy.
- **Problem solved:** Surfaces what matters before data volume or explanatory copy.
- **Spatial mechanism:** The changed truth receives the main landmark; evidence recedes.
- **Interaction mechanism:** Detail opens only after the consequence is understood.
- **Accessibility equivalent:** State/change announced before evidence and metadata.
- **Strength:** Operationally clear and emotionally restrained.
- **Risk:** The system may overstate what counts as material.
- **Ambitions relevance:** Strong for progression, recovery, and closure.
- **Not a card/list/stepper/graph:** Hierarchy arises from meaning, not container count.
- **Disposition:** `TEST`.

## PAT-G16 — Adaptive density transform

- **Examples:** Calendar views; Mail category/list switching; Reminders sections; Photos collections.
- **Problem solved:** Preserves clarity across many objects and large type.
- **Spatial mechanism:** Composition changes mode—overview, grouped list, or depth—instead of shrinking.
- **Interaction mechanism:** System controls or context determine an alternate composition.
- **Accessibility equivalent:** Open vertical list with the same semantic order and actions.
- **Strength:** Handles dense and Accessibility Dynamic Type states honestly.
- **Risk:** Multiple layouts can drift semantically.
- **Ambitions relevance:** Mandatory.
- **Not a card/list/stepper/graph:** It is a responsive semantic transformation.
- **Disposition:** `TEST`.

## PAT-G17 — Semantic list equivalent

- **Examples:** Calendar list alternative; Weather text forecast; Apple accessibility fallbacks.
- **Problem solved:** Makes a spatial model usable without relying on position, color, or motion.
- **Spatial mechanism:** Ordered textual/grouped equivalent of the spatial field.
- **Interaction mechanism:** Same selection and navigation actions.
- **Accessibility equivalent:** The pattern is itself the equivalent.
- **Strength:** Keeps spatial ambition compatible with assistive technology.
- **Risk:** Can become the default design and erase the intended model.
- **Ambitions relevance:** Required for every spatial direction.
- **Not a card/list/stepper/graph:** It is an alternate representation, not the primary visual model.
- **Disposition:** `TEST`.

## PAT-G18 — Proof-in-place

- **Examples:** Day One entry media/context; Health trend evidence; Flighty event updates.
- **Problem solved:** Shows why a state is trusted without turning Proof into a checklist.
- **Spatial mechanism:** Evidence appears attached to the truth it substantiates.
- **Interaction mechanism:** Expand the truth to inspect exact Proof and history.
- **Accessibility equivalent:** “Supported by…” disclosure after the accepted truth.
- **Strength:** Preserves trust while keeping identity primary.
- **Risk:** Decorative badges or hidden critical evidence.
- **Ambitions relevance:** Direct replacement for the rejected Proof checklist.
- **Not a card/list/stepper/graph:** Proof is lineage attached to truth, not a task list.
- **Disposition:** `TEST`.

## PAT-G19 — Uncertainty aperture

- **Examples:** Weather forecast confidence implications; Gentler adaptive range; Flighty pending changes.
- **Problem solved:** Makes unknown future movement visible without false certainty.
- **Spatial mechanism:** An open boundary, forked possibility, or deliberately unresolved region.
- **Interaction mechanism:** Selecting it explains what is known, unknown, and what could clarify it.
- **Accessibility equivalent:** Explicit “not decided yet” state and available clarification action.
- **Strength:** Distinctive opportunity for Ambitions.
- **Risk:** Abstract symbolism or anxiety-inducing ambiguity.
- **Ambitions relevance:** Core to Future Steps and recovery.
- **Not a card/list/stepper/graph:** Uncertainty changes the geometry of knowledge rather than adding a status chip.
- **Disposition:** `TEST`.

## PAT-G20 — Calm compression

- **Examples:** Things hierarchy; Apple Mail categories; Photos collections.
- **Problem solved:** Keeps many persistent objects manageable without a dashboard.
- **Spatial mechanism:** Nonselected objects compress to identity plus one material state.
- **Interaction mechanism:** Selection restores depth in place or through native navigation.
- **Accessibility equivalent:** Collapsed summaries remain fully named and expandable.
- **Strength:** Supports dense roots.
- **Risk:** Hidden distinctions and generic rows.
- **Ambitions relevance:** Useful for nonselected Life Areas and Goals.
- **Not a card/list/stepper/graph:** Compression is semantic prioritization, not tile reduction.
- **Disposition:** `TEST`.

## PAT-G21 — Exact return restoration

- **Examples:** Native back navigation; Day One present-date return; Freeform saved scenes.
- **Problem solved:** Preserves context after deep inspection.
- **Spatial mechanism:** Return restores selection, expansion, and meaningful position.
- **Interaction mechanism:** System back and explicit owner return share one typed anchor.
- **Accessibility equivalent:** Focus returns to the exact selected Goal or relationship.
- **Strength:** Makes deep pursuit inspection feel safe.
- **Risk:** Stale restoration when object truth changes.
- **Ambitions relevance:** Required fixture semantic.
- **Not a card/list/stepper/graph:** Continuity is navigational state, not visual decoration.
- **Disposition:** `TEST`.

## PAT-G22 — Functional-chrome separation

- **Examples:** Current Apple materials guidance; iA Writer; Primary.
- **Problem solved:** Keeps controls distinct without turning content into glass panels.
- **Spatial mechanism:** Matte content plane with material reserved for transient controls/navigation.
- **Interaction mechanism:** Standard controls receive platform appearance and feedback.
- **Accessibility equivalent:** Opaque Reduce Transparency variants and system semantics.
- **Strength:** Native hierarchy and legibility.
- **Risk:** Content can become visually timid without another spatial signature.
- **Ambitions relevance:** Protected law.
- **Not a card/list/stepper/graph:** It is a material ownership rule.
- **Disposition:** `TEST`.

## PAT-G23 — Tactile direct manipulation

- **Examples:** Tide Guide scrubbing; Play’s native canvas; (Not Boring) Camera controls.
- **Problem solved:** Turns structure into something learned through use rather than explanation.
- **Spatial mechanism:** Object responds continuously to a bounded gesture.
- **Interaction mechanism:** Drag, reveal, or press with immediate native feedback.
- **Accessibility equivalent:** Buttons, adjustable actions, and static state transitions.
- **Strength:** Memorable, ownable interaction.
- **Risk:** Novelty, discoverability, haptic dependence, and trade-dress imitation.
- **Ambitions relevance:** Only if tied to pursuit meaning, never decoration.
- **Not a card/list/stepper/graph:** Interaction changes comprehension of one object.
- **Disposition:** `HOLD` until a direction proves semantic need.

## PAT-G24 — Persistent avatar continuity

- **Examples:** Finch’s pet.
- **Problem solved:** Makes return emotionally warm and the long horizon legible.
- **Spatial mechanism:** A living character embodies continuity.
- **Interaction mechanism:** Progress changes the avatar and unlocks rewards.
- **Accessibility equivalent:** State descriptions and nonvisual progress announcements.
- **Strength:** Extremely memorable and emotionally immediate.
- **Risk:** Gamification, reward substitution, sentimentality, and a false agent.
- **Ambitions relevance:** The underlying lesson is “make the pursuit feel alive,” not “add a character.”
- **Not a card/list/stepper/graph:** Continuity is embodied, but in an incompatible metaphor.
- **Disposition:** `REJECT` as expression; retain the emotional lesson.
