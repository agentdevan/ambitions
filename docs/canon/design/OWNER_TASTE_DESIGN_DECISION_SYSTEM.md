# Owner Taste and Design Decision System

Status: `OWNER_APPROVED / SUPREME_DESIGN_AUTHORITY`
Scope: Ambitions iPhone and future iPhone-native surfaces
Machine peer: `docs/canon/design/owner-taste-design-decision-system.json`

This is the durable record of the owner's R01–R66 calibration and the supreme
active design authority for Ambitions. When this source conflicts with any
other visual system, closure package, surface treatment, design precedent,
local preference, or decorative convention, this source wins. The VC-01–VC-14
Visual Closure Input Contract and its packages are subordinate implementation
and calibration material. They may realize, test, or refine this source, but
they may not narrow, reinterpret, or override it.

## Precedence and boundary

Owner Taste is first in the design-authority order. Owner-approved
surface-specific decisions follow it; Visual Closure implementation and
calibration follows those; historical design provenance, local preference, and
decorative novelty follow last. No subordinate design source may win a
conflict with Owner Taste by being older, more detailed, implemented, or
described as closed.

Product truth, domain and object semantics, safety, privacy, correctness,
accessibility requirements, Apple platform requirements, and verified
usability limits are non-design boundary conditions rather than competing
taste authorities. They define the feasible and truthful solution space.
Within that space, Owner Taste controls presentation, interaction character,
hierarchy, atmosphere, motion, sound, and haptic intent. Evidence may reject an
implementation or proof claim that fails those constraints; it cannot install
a competing design direction. Current scope is iPhone only; iPad and Apple
Watch are excluded.

## Governing objective

> Make the product feel richer because it understands and organizes more—not
> because it draws more things.

The target is **contextual richness plus native discipline**: dense but
breathable, tactile but controlled, atmospheric but legible, intelligent but
quiet, native in the hand and authored in composition. Never spend visual
complexity unless it improves meaning, orientation, interaction, identity, or
emotional value.

Goals R02 is rejected evidence. It reduced reading burden by removing
sophistication, perceived intelligence, adult character, and information
value. The correction is: **low reading burden without low informational
richness** and **one dominant focus, multiple legible layers, one unmistakable
next action**. Architecture—not decoration—must resolve a weak surface.

## Universal laws

- Prefer information value, relationships, chronology, hierarchy, state, and
  selective density over sparse premium styling, explanatory prose, repeated
  containers, decorative badges, or maximum module count.
- Prefer integrated canvases, continuous structured lists, contextual layers,
  strong axes, and object-led composition. A card is bounded containment when
  earned, never a default grouping primitive.
- Preserve native or refined-native behavior; create identity through
  composition, hierarchy, atmosphere, semantic state, and continuity rather
  than reskinning controls.
- Use localized glass only when focus, separation, tactility, or navigation
  prominence earns it. Glass is never the screen's subject.
- Make an adult, confident, intelligent product. No bubbly, gamified,
  motivational, toy-like, mascot-driven, or cute treatment.
- Create prominence through placement and context before large buttons,
  accent fills, halos, or material. Giant full-width CTAs are disfavored.

## Contextual routing

| Domain | Preferred composition |
| --- | --- |
| Connected life system | Integrated contextual canvas |
| Browsable media or content | Visual collection/discovery grid |
| Single rich object | Cinematic/editorial immersion when content earns it |
| Spatial/location work | Full spatial canvas |
| Settings/configuration/utility | Refined native utility architecture |

The route is not a component recipe. Preserve higher-order intent when context
changes: cinematic is wrong for ordinary utility; dense analytical grammar is
wrong for a daily glance; full push is for a genuinely new destination.

## Interaction, information, and motion

- Native inline actions lead; persistent chrome must be justified. Prefer soft
  tint plus outline for selection and dot plus concise label for status.
- Stay in place by default: inline expansion for attached detail, sidecar for
  related context, sheet for temporary focused review, and push only for a new
  owned destination.
- Use long-press for rich contextual commands and swipe for frequent
  shortcuts; never keep persistent trailing row actions merely for
  discoverability. Semantic moves expose semantic drop zones; simple reorder
  uses native lift/insertion. Bulk selection is an explicit temporary native
  mode, not persistent checkboxes.
- Capture is freeform → infer → clarify only what matters → settle into
  structure. Intelligence stays invisible while composing unless a
  consequential error needs restrained live clarification. Search is find →
  contextualize → act, not default chat.
- Preserve compact professional density with selective inline encoding; exact
  chart inspection begins with a compact point tooltip and expands on demand.
- Chrome retreats when sustained scroll commits to content; compact collapse is
  the fallback where orientation or action must remain.
- Motion explains continuity, ownership, causality, or state. Default to crisp
  damping, fast settle, minimal overshoot; use soft spring only when tactility
  adds meaning. Routine sound nearly disappears.

## Appearance and authored presentation

Owner direction is cool ink/subtle navy-black before graphite, OLED black,
and warm black; light mode favors tinted atmosphere before mineral neutral,
warm editorial, and stock white. Use atmosphere families plus stable semantic
color families, restrained abstract/neutral utility backgrounds, role-based
tight geometry, and intentional axes. Imagery may dominate only where it is
the content. Visual Closure may offer a current implementation calibration for
these decisions but cannot turn a conflicting calibration into authority.
Semantic meaning, accessibility requirements, and native control behavior
remain boundary conditions.

## Hard kill signals

Kill or fundamentally rethink directions that are boring, juvenile, visually
empty, sparse by information removal, giant-CTA-led, generic card stacks or
dashboards, prototype-like, novel without product reason, glass-led,
ornamentally animated, explanatory-prose-dependent, architecture-rescued by
polish, checkbox- or trailing-action-chrome-led, gratuitously pill-shaped,
bouncy, coaching/motivational, mascot-driven, gratuitously graph-like,
cinematic for utility, maximally dense without scanability, or minimal enough
to erase perceived intelligence.

## Taste gate and proof ceiling

Before expensive native work, score 0–2 for information value, reading
efficiency, screen utilization, integrated composition, native credibility,
adult sophistication, engagement, material restraint, contextual intelligence,
action clarity, purposeful distinctiveness, and absence of decorative novelty.
21–24 is worth native proof; 17–20 revise; 13–16 rethink; 0–12 kill. A hard
kill wins regardless of score. The score is not owner approval, accessibility
proof, runtime proof, release Green, or physical-device proof.

Physical iPhone validation remains the final proving environment for
scale/density, one-handed reach, touch certainty, scroll and motion character,
gesture and semantic drag/drop clarity, hardware haptic realization,
repeated-use sound, OLED/material behavior, keyboard occlusion, system-gesture
coexistence, latency, fatigue, and interaction pull. A failed observation can
invalidate the tested implementation or proof claim and require a new
calibration; it does not create design authority above Owner Taste. Screenshots
and simulator frames cannot certify these properties.

## Domain-scoped calibration evidence

| Domain | Ranking / law |
| --- | --- |
| Home widget | `A > D > B > C`: utility first |
| Lock Screen | contextual active/next-up/attention before abstract ambient state |
| Professional table | `D > B > A/C`: compact density plus selective encoding |
| Analytical chart | `D > B > C > A`: retain rigor, layer meaning selectively |
| Multi-select | `A > B > D > C`: explicit temporary mode |
| Drag/drop | `C > A > D > B`: semantic zones for semantic moves |
| Gesture affordance | `B >> A > D > never C`: long-press, then swipe |
| Typing state | `C > A > D > B`: invisible intelligence while composing |
| Sound | `A > D > B > C`: routine feedback nearly silent |
| Chart inspection | `A >> D > C > B`: compact tooltip first |
| Spring/damping | `A > B > D > C`: crisp damping first |
| Scroll/header | `D > A > B > C`: content wins on sustained scroll |

These rankings are evidence within their named domains, never universal
component recipes.
