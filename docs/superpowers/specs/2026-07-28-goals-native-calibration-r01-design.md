# Goals Native Calibration R01 Design

Status: implementation contract  
Identity: `AVF-GOALS-S08-NATIVE-CALIBRATION-R01`  
Title: Singular Living Pursuit Passage — Native Calibration  
Program position: `POST_VC14_NATIVE_CALIBRATION / CROSS_ROOT_GOALS_CALIBRATION`

## Scope and proof ceiling

This contract defines an eight-frame, fixture-driven Native Visual Foundry calibration for Goals. It proves native composition, selection, inspection, navigation, restoration, accessibility transformation, and Simulator rendering against synthetic values. It does not prove production Goals ownership, persistence, mutations, path generation, restoration architecture, runtime integration, migration, app entry, shell freeze, or cutover.

The implementation is package-backed and confined to `AmbitionsNativeVisualFoundry`, its fixture host, focused tests, and the Goals R01 evidence package. Today sources, production Goals sources, runtime adapters, canon authority, generated canon, and app entry remain unchanged.

## Design thesis

Goals presents persistent pursuits as living canonical identities. A selected Life Area opens spatially, a Goal becomes legible through identity and current truth, and its Linked Goal Lens appears as attached relief rather than a detached dashboard module. Deeper navigation preserves that identity while revealing pursuit continuity, one consequential relationship, and Goal Path history.

The visual family inherits R14's matte plane, system typography, identity-first hierarchy, lineage, truth, consequence, native action roles, progressive disclosure, natural scrolling, and accessibility recomposition. It deliberately does not inherit Start Here, Later Today, Today’s temporal rail, View Full Day, Still Counts, settlement geometry, or Today restoration composition.

## Deterministic fixture

Fixture family: `goals-flagship/home/welcome-baby-home/v1`.

### Life Areas

- `life-area.home`: Home, selected and solely expanded.
- `life-area.relationships`: Relationships, compact.
- `life-area.career`: Career, compact.
- `life-area.health`: Health, optional only when the rendered viewport remains calm.

No Life Area has a decorative category color or rank.

### Goals

- `goal.welcome-baby-home`: Welcome our baby home, selected under Home.
- `goal.make-home-easier-to-run`: Make the house easier to run.
- `goal.finish-essential-move-in-work`: Finish essential move-in work.
- `goal.protect-first-weeks-together`: Protect our first weeks together, under Relationships.
- `goal.ship-launch-well`: Ship the launch well, under Career.

Selected Goal content is exact:

- current direction: “Make the home ready for the baby without consuming the time and energy the family needs now.”
- current accepted truth: “The wall is primed, the color is confirmed, and the crib corner is clear.”
- active thread: “Finish the nursery.”
- next meaningful movement: “Paint the nursery wall.”
- following movement: “Assemble the crib.”
- consequence: “Finishing the room now reduces last-minute setup while protecting family time.”
- schedule fit: “The next movement currently fits before protected family time.”

### Relationship

`goal.welcome-baby-home` is inspected alongside `goal.protect-first-weeks-together`. Home owns the inspected setup decision; Relationships owns the related Goal. Meaning: “A ready nursery lowers pressure during the first days at home.” Practical consequence: “Home setup should support the family’s first-week plan rather than consume it.” Inspection is non-mutating and creates no relationship command.

### Goal Path

Path ID: `goalpath.welcome-baby-home.v1`.

1. `goalpath-node.define-ready` — Define what ready means — completed.
2. `goalpath-node.clear-crib-corner` — Clear the crib corner — completed; Proof: Crib corner cleared.
3. `goalpath-node.prime-wall` — Prime the wall and confirm the color — settled; Proof: Paint color confirmed, Wall primed.
4. `goalpath-node.paint-wall` — Paint the nursery wall — current.
5. `goalpath-node.assemble-crib` — Assemble the crib — next.
6. `goalpath-node.changing-station` — Set up the changing station — planned.
7. `goalpath-node.final-furniture` — Arrange final furniture after delivery — conditional / Future Step.
8. `goalpath-node.nursery-ready` — Nursery ready for the crib — finish posture.

No percentage, score, progress ring, automatic completion, or game vocabulary is present.

## State and navigation model

`GoalsNativeCalibrationJourneyState` is a small value-semantic fixture state. It owns:

- `selectedLifeAreaID`;
- `selectedGoalID`;
- `isLinkedLensExpanded`;
- a typed `[GoalsNativeCalibrationRoute]` navigation path;
- `selectedPathNodeID`;
- a semantic restoration anchor.

Routes are limited to `.focusedGoal`, `.relationship`, and `.goalPath`. Navigation uses one `NavigationStack(path:)` and one `navigationDestination(for:)` mapping. Paths contain identifiers and route cases, never views. Selection, disclosure, navigation, and return are the only transitions. The fixture canonical snapshot remains byte-for-byte/equality stable through every route.

Back from relationship and Goal Path restores focused Goal. Back to root restores Home, the selected Goal, the Linked Goal Lens posture, and a meaningful focus anchor. No Receipt, durable mutation, activation, or production route is created.

## Goals-local visual grammar

### Content plane

Dark uses deep graphite with restrained tonal structure; Light uses mineral-neutral warmth. Both are matte and opaque. Open plane is the default. Local relief appears only for the selected Goal/Lens and state-bearing Path detail, using spacing, a partial seam, separator, and tonal lift rather than complete card perimeters.

### Type roles

System typography only:

1. identity — Life Area or Goal name;
2. truth — current accepted pursuit truth;
3. relationship — lineage, active thread, consequence;
4. metadata — state or Proof posture;
5. action — native disclosure/navigation controls.

Goal identity precedes state and metadata. Compact objects use no more than three roles and two weights. Dynamic Type recomposes; it never shrinks fixed screenshot-tuned type.

### Semantic markers

Markers communicate selected, settled, current, next, planned, conditional, and finish postures using shape plus labels. Color is supportive, never sufficient. Markers are local Goals calibration primitives, not global tokens or component APIs.

### Actions

- selection: native row/button treatment, not a commitment fill;
- disclosure: reveal Linked Goal Lens in place;
- navigation: Open Goal, View Goal Path, inspect relationship;
- Path jump: Start, Now, Next, Finish native compact controls.

There is no mutation or consequential-commit action in this calibration.

## Screen contracts

### GNC-F01 — Goals Root Light

Compact Ambitions/Goals crown, Goals selected in provisional shell semantics, Home solely expanded, selected Goal legible without rank, compact peer Life Areas, lens entry seam near the lower fold, and dock Peek. Mineral Light must avoid white card stacks and decorative categories.

### GNC-F02 — Goals Root Dark

Same semantic state on deep graphite. Secondary type, selected geometry, and relief remain legible without glow or a black-plus-purple-only hierarchy.

### GNC-F03 — Selected Life Area and Goal

Home remains the only expanded area. Supporting Home Goals stay subordinate, compact Life Areas remain equal, and one native disclosure reveals the Linked Goal Lens. The selected Goal is not enclosed as a large card.

### GNC-F04 — Linked Goal Lens

The lens remains visually attached directly beneath `Welcome our baby home`. It exposes current truth, one consequence, active thread, next movement, compact Proof posture, and Open Goal. It does not expose the complete Path or repeat all Goal metadata.

### GNC-F05 — Focused Goal Depth

Native Back to Goals, stable Goal identity, Home lineage, current direction and accepted truth, active thread, next movement, Proof moments, schedule-fit relationship, attached lens grammar, and View Goal Path. It must read as pursuit continuity, never a Form, checklist, project dashboard, or milestone chart.

### GNC-F06 — Consequential Relationship

Both Goal identities and Life Areas, relationship meaning, practical consequence, and Home ownership of the inspected setup decision. Native Back returns to the selected focused Goal. No graph, score, command, or automatic synchronization.

### GNC-F07 — Goal Path and Progression History

At standard size, a horizontal native `ScrollView`/lazy row anchors to the current node. Current and next are legible at rest; all eight postures use shape and text. Selected detail and Proof moments sit below the path. Start/Now/Next/Finish controls select exact fixture nodes. This is read-only pursuit continuity.

### GNC-F08 — Accessibility Dynamic Type

The root, selected Goal, and Linked Goal Lens recompose vertically with natural scrolling. Semantic order is Life Area, Goal, current truth, consequence, active thread, next movement, Proof, action, return. The compact edge dock is replaced by the existing-style Adaptive Navigation Passage concept local to the host proof. Every action remains at least 44 points.

## Accessibility and adaptivity

- Stable accessibility identifiers encode canonical fixture identity, not visible position.
- Selected state combines label/value, geometry, and symbol.
- VoiceOver groups Life Area identity before contained Goals, and Lens content in the required semantic sequence.
- Increased Contrast strengthens seams and marker outlines; Differentiate Without Color retains explicit state labels and shapes.
- Reduce Transparency uses opaque shell chrome; Reduce Motion relies on native navigation/focus with no decorative motion dependency.
- Standard Path is horizontal; accessibility sizes use a vertical ordered list with identical node semantics and jump controls.
- Long content wraps; safe areas and flexible stacks avoid fixed screenshot coordinates.
- Minimum targets are 44 points. Physical VoiceOver, switch/voice control, keyboard, reach, haptics, and edge gestures remain direct-device obligations.

## Shell boundary

Goals receives a Goals-specific compact crown and selected-root semantics while Search and Capture remain dock-owned. The existing Crowned Edge Dock is a provisional context and is not redesigned, frozen, or device-approved here. The Goals implementation may use a journey-local shell representation matching the existing Foundry proof; a blocking shared-shell need triggers stop-loss rather than a Today/shared edit.

## Performance contract

- immutable fixture collections and stable IDs;
- local value state only, avoiding broad observation fan-out;
- `LazyHStack` for the standard Path and `LazyVStack` for accessibility history where useful;
- no filtering, sorting, formatter creation, or unstable identity in `body`;
- Path selection updates only local selected-node detail;
- no image decode, expensive material layering, or ambient animation.

ETTrace and memgraph are excluded unless rendered interaction exposes a symptom.

## Evidence and acceptance

Exactly eight Simulator screenshots and two contact sheets are produced. All have `production_baseline = false`. No recording is produced. `GNC-C02` compares only plane, identity, lineage, truth, consequence, action, and accessibility against R14, and explicitly denies composition copying.

Owner review remains the visual acceptance gate. Direct-device shell and physical accessibility proof remain incomplete. `APPROVED FOR SWIFTUI` remains false.

## Stop-loss boundaries

Stop if truthful implementation requires production persistence/runtime, mutation, path generation, activation, Receipt/Undo, schedule mutation, production restoration, broad routing, app-entry changes, Today changes, shell redesign/freeze, another root, dependencies, global tokens/components, Figma, Code Connect, production baselines, merge, or push.

