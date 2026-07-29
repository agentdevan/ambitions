# Goals Native Pursuit Continuum Synthesis Design

Direction: `AVF-GOALS-S08-INT-D09-R02 — Native Pursuit Continuum, Canonical Depth`

Status: `SELECTED_FOR_SYNTHESIS`

## Purpose

Replace the rejected Goals R01 visual spike with one bounded, fixture-driven
native prototype proving three canonical depths:

```text
Goals root → Home Life Area → Welcome our baby home
```

The prototype is inspection-only. It does not connect production Goals,
runtime state, persistence, mutation, or app entry.

## Protected meaning

- Goals is the Life Area index and exposes no child Goal identity.
- Home is a separate native drilldown containing stable Goal identities.
- `goal.welcome-baby-home` is the only fully supported focused fixture Goal.
- Accepted truth precedes progression.
- Proof substantiates accepted truth.
- `Paint the nursery wall` is the current movement and opens Goal Path.
- Possible and conditional future remain distinguishable without suggesting a
  metric, schedule, roadmap, or committed plan.
- `Protect our first weeks together` qualifies the future field and opens the
  existing relationship inspection.
- All routes are non-mutating and preserve stable fixture identities.

## Navigation and state

`GoalsNativeCalibrationRoute` adds a typed Life Area destination. One
`NavigationStack` owns the ordered path:

```text
[]
[.lifeArea(id: "life-area.home")]
[.lifeArea(id: "life-area.home"), .focusedGoal(id: "goal.welcome-baby-home")]
```

Goal Path and relationship inspection append to that canonical parent path.
Framework navigation owns Back, interactive Back, transition geometry, and
scroll-edge title behavior. The fixture journey state validates every path and
records a truthful focus anchor when a destination is popped. It never mutates
fixture content.

## Screen anatomy

### Goals root

The root crown remains Ambitions-owned and the Crowned Edge Dock remains the
existing provisional shell hypothesis. The content is a strict, naturally
scrolling Life Area index. Each row-wide native link contains only Life Area
identity, its current direction, a quiet semantic posture expressed by layout,
and native disclosure. Home, Relationships, and Career are comparable in
prominence but vary in rhythm according to their fixture truth. No Goal title,
Proof, movement, or Goal action appears.

### Home

Home uses a framework navigation title and presents three matte pursuit
passages. Every passage shares identity and accepted-posture anatomy. The
primary Goal adds a localized accepted-truth foundation, attached Proof
provenance, and current movement. Its entire passage is one native
`NavigationLink`; it has no separate `Open Goal` action. The two summary-only
fixture Goals remain truthful, noninteractive peers because their focused
snapshots do not exist in this fixture.

### Focused Goal

The navigation title remains compact. Goal identity, Home lineage, and accepted
truth form one stable pursuit object. A material seam—not an icon, progress bar,
or bracket—persists from Home into focused depth. Proof expands from the truth
foundation. Current movement is the principal row-wide path target. Future
certainty expands in place and uses diminishing emphasis and localized relief,
not distance or percentage. The protected relationship visibly reserves part
of that future field and opens the existing relationship destination.

## Interaction contract

- Root Life Area passages are row-wide `NavigationLink` targets.
- The supported Home Goal passage is a row-wide `NavigationLink` target.
- Proof uses native disclosure and changes no fixture truth.
- Current movement opens the existing Goal Path route.
- Future certainty uses native disclosure and changes no fixture truth.
- Protected relationship opens the existing relationship route.
- Back restores Home selection, then root Life Area focus, without mutation.

## Material, motion, and accessibility

Primary content remains opaque and matte. Liquid Glass remains limited to the
existing functional dock chrome with an authored opaque Reduce Transparency
equivalent. Native push and disclosure motion are used without custom spatial
theater. Reduce Motion removes additional state animation.

System typography and adaptive stacks recompose at Accessibility Dynamic Type.
No semantic relationship depends on fixed lines, color, transparency, or
motion. Every interactive passage has a minimum 44-point envelope, one grouped
VoiceOver element, a unique speakable label, and a logical return target.

## Evidence and proof ceiling

Native Simulator evidence will cover the three screens in Light and Dark plus
representative Accessibility Dynamic Type and Reduce Transparency states.
Package tests will prove typed route semantics and non-mutation; fixture-host UI
tests will prove navigation, Back restoration, disclosure reachability, and
layout presence. Interactive Back and assistive technology remain Simulator
evidence until repeated on a physical device.

Screenshots are evaluation references with `production_baseline = false`.
`APPROVED_FOR_SWIFTUI` remains false.

## Self-review

- No placeholders or unsupported capability are present.
- The root, Life Area, Goal, Path, and relationship owners remain distinct.
- The fixture remains synthetic and immutable.
- Production Goals, runtime, app entry, canon, tokens, and shared component APIs
  remain untouched.
