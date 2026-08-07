# 05 — Goals R03 Recovery Architecture

Status: **analytical architecture complete; no visual direction approved; no implementation authorized**

## Problem statement

R01 preserved meaningful pursuit depth but forced the user to read the system. R02 preserved scan speed by deleting the system’s visible intelligence. R03 must not average them. It must change the information architecture so rich meaning is recognized before it is read.

## R03 mental model

Goals is the user's **living pursuit field**: Life Areas define enduring direction; Goals carry active pursuit identity; Paths expose accepted past, current movement, adaptable future, Proof, recovery, and closure. The user should recognize what matters, what is moving, what requires judgment, and what changed without encountering a dashboard or an essay.

## First-viewport contract

### Goals root

1. **Life Area constellation as an editable index, not a map.** Show 3–5 Life Areas as mature, text-led spatial bands/segments with identity, a concise direction phrase, and one visual pursuit-continuity signal.
2. **Dominant current direction.** One selected Life Area receives visual amplitude; others remain legible, not hidden.
3. **Context layer 1 — active pursuits.** Expose selected-area Goal identities and state/trajectory through compact aligned markers or rows, not metrics tiles.
4. **Context layer 2 — current pressure.** Show one meaningful condition such as “2 moving / 1 needs a decision” using plain language and structure.
5. **Primary action.** “Open [Life Area]” or the most consequential current Goal action is unmistakable but subordinate to identity/truth.
6. Dock remains shell-owned and root-only.

### Life Area depth

- Header: Life Area identity + concise direction statement.
- Continuous pursuit field: active, planned, uncertain, completed/settled Goals shown as a coherent sequence/field.
- Selected Goal lens: identity, current movement, route/fit, one consequential relationship, and one next action.
- Secondary Goals remain visible enough to preserve context; do not page the user into amnesia.

### Goal depth

First viewport must include:

- Goal identity and Life Area membership
- lifecycle/truth state
- current Step or multiple active Steps
- current route and trajectory
- next movement or pending decision
- Proof/settled completion signal
- schedule fit/pressure when material
- Linked Goal Lens with at most one consequential relationship at overview depth
- one unmistakable primary action

The content can occupy multiple visual layers while preserving one dominant focal object.

## Object anatomy

| Layer | Must communicate | Preferred expression |
| --- | --- | --- |
| Identity | What pursuit is this? | Text-first title + Life Area lineage |
| Current truth | What is accepted now? | Compact explicit state, not colored score |
| Trajectory | Where did it come from and where is it going? | Continuous path/rail with accepted/current/adaptable distinctions |
| Movement | What is active now? | Step identity + bounded temporal fit |
| Decision | What requires judgment? | One concise consequence/action seam |
| Evidence | What proves movement or closure? | Proof indicator/summary, never gamified percentage |
| Relationship | What materially affects this pursuit? | One Linked Goal Lens at overview depth |
| Recovery/closure | What if movement fails or ends? | Open continuation rail and explicit history |

## Cognitive-load strategy

- Encode status/trajectory/relationship spatially and structurally before adding copy.
- A typical first viewport should expose 5–8 meaningful facts but require no more than roughly 35–55 words to understand at rest.
- No explanatory paragraph over two short lines in the first viewport.
- Avoid generic metadata labels when position and symbol already establish role.
- Progressive disclosure moves proof details, history, full route, and secondary relationships deeper—not identity, truth, consequence, or next movement.

## Interaction depth

1. Root selects a Life Area without losing surrounding areas.
2. Life Area selects a Goal without replacing all surrounding pursuit context.
3. Goal opens full Path, Recovery, Closure, Proof, and History with native navigation.
4. Cross-owner time editing transfers to Time; Search/Capture return to exact origin.
5. Framework Back and shell path preservation remain non-negotiable.

## Accessibility transformation

At accessibility sizes, linearize the same semantic sequence: Life Area identity → current direction → selected Goal identity → current truth → current movement → material condition → action → other pursuits. Do not replace the experience with giant Previous/Next paging as a default; paging may assist dense traversal but cannot erase context.

## Prohibited regressions

- R01 paragraph stacks and repeated “what this means” copy
- R02 giant icon, giant empty field, primitive progress blocks, or one-object-only composition
- percentage progress, scores, streaks, badges, celebration theater
- generic card grid or project-board columns
- decorative constellation or custom gesture canvas
- action button as the primary visual identity
- status conveyed only by color

## Exit criteria before a native R03 candidate

- Owner approves this architecture or a revised written equivalent.
- Candidate wire anatomy passes the owner-fit engine with no hard fail.
- The first viewport visibly satisfies current Goals canon.
- R01/R02 anti-pattern comparison is completed before build work.
- Only then may one native candidate be implemented; adaptation/full-proof work waits until owner-fit survives a first board review.

## Evidence

- `ZIP:Ambitions_Goals_Maximum_Polish_R01_overview.png`
- `ZIP:Ambitions_Goals_Maximum_Polish_R02_overview.png`
- `REPO:docs/canon/specifications/surfaces/goals.md@0f56e8f1c`
- `REPO:docs/canon/migration/UX_BLUEPRINT.md@0f56e8f1c`
- D-077 and D-079 owner rejections
