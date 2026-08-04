+++
initiative = "context-quality-scheduling"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Two open windows with the same duration are not necessarily interchangeable.
An hour after the gym may involve recovery and travel; an hour before leaving
for work may have a hard stop and setup pressure. A Step that fits one window
may fail in the other even when both appear “free.” Ambitions should help the
user place accepted work into the window where it is most realistic, then adapt
when reality changes without diagnosing the person or turning time into a score.

The user problem is broader than energy. Fit can depend on the Step's focus and
effort shape, the preceding and following commitments, transition and recovery,
place, tools, connectivity, interruption risk, and what the user has explicitly
said works. Duration-only placement hides those constraints and creates plans
that look valid but do not survive contact with the day.

## Current truth

This Research uses `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, current canon/source/tests, and the
portfolio synthesis in
`docs/product-development/adaptive-skills-and-pathways/research.md`.

Canon already makes Scheduling the authority for fit, placement, consequence
preview, and reflow. `SYSTEM-SCHEDULING-CAPACITY-001` and
`SYSTEM-SCHEDULING-REFLOW-001` require availability, energy, context, Step
shape, transitions, Protected time, Fixed time, constraints, and downstream
effects to remain inspectable. Simulation is local, deterministic, bounded, and
side-effect-free until the user accepts a material change. Time presents the
schedule; Local Learning may supply bounded evidence but cannot own placement
or silently commit it.

Live source contains meaningful but incomplete seams:

- `TimeContextHierarchy.swift` distinguishes work, school, commute, setup,
  transition, recovery, protected, open, and free context.
- `GoalEnergyFitModels.swift` and `GoalEnergyFitService.swift` represent work
  shape, effort, focus demand, recovery posture, fit bands, and reasons. Current
  capacity evidence is often unknown, assumed neutral, or structurally derived.
- `LearningAnticipationService.swift` learns goal-local session length,
  morning/afternoon/evening focus windows, completion fit, and drift patterns.
  It does not yet model a relational signature such as after one event and
  before another.
- `RecommendationEngine.swift` and `StepImpactSimulationSupport.swift` provide
  explained suggestions and non-committing previews.

Inspected tests assert structural exclusion, fit reasoning, explicit approval,
and coarse time buckets. They do not prove event-relative learning, correction,
generalization boundaries, user-facing comparison between equal-duration
windows, or full placement/reflow behavior.

## Evidence

The initiating example is strong evidence for relational context, but it does
not establish a universal gym rule. The 2025 systematic review “Chronotype and
synchrony effects in human cognitive performance” reviewed 65 studies: most
found no main chronotype effect, while some found task-, age-, and time-specific
synchrony effects. The 2025 meta-review “Effects of acute exercise on cognitive
function” found a small-to-medium average benefit across reviewed studies, with
assessment timing as a moderator. Both were rechecked through PubMed on
2026-08-03 ([PMID 40293205](https://pubmed.ncbi.nlm.nih.gov/40293205/) and
[PMID 39883421](https://pubmed.ncbi.nlm.nih.gov/39883421/)).

Those findings argue against declaring that mornings, evenings, or post-gym
time are intrinsically better. They support user-specific, task-specific
learning with uncertainty. Structural facts are more reliable starting inputs:
a hard stop, travel transition, required equipment, location, or insufficient
duration can rule out a placement without inferring mood or health.

Useful candidate inputs fall into distinct groups:

- **Window structure:** start/end, hard stop, Protected/Fixed boundaries,
  preceding/following event, transition, setup, recovery, place, tools,
  connectivity, and likely interruption.
- **Step shape:** duration range, decomposability, focus demand, effort, location,
  tools, dependencies, and whether interruption is safe.
- **User direction:** explicit placement preference, “not after this event,”
  “lighter work here,” correction, and temporary exception.
- **Local evidence:** accepted completion plus explicit feedback about fit.
  Deferral, resizing, interruption, or repeated friction may prompt reflection,
  but only the user's confirmation or correction may turn those observations
  into a persisted placement preference or learned influence.

Absence, cancellation, or missed work does not prove inability. Health,
disability, burnout, chronotype, discipline, or personality must never be
diagnosed from timing patterns. A learned fit should remain an inspectable
influence that the user can correct, disable, reset, or delete.

## Alternatives

### Duration-only scheduling

This is predictable and easy to explain, but it ignores hard stops, transition,
recovery, and work shape. It remains a valid fallback when richer evidence is
unknown.

### Static user labels

Let the user label windows as high, medium, or low quality. This is controllable
but creates a universal score and misses that the same window can fit different
Steps differently.

### Global chronotype or energy model

Classify the user as a morning/evening type or infer a daily energy curve. This
overgeneralizes mixed research, creates sensitive person-model risk, and cannot
explain event-relative differences.

### Context signature with cautious local learning

Use structural context and explicit user preferences first, then propose narrow
patterns from repeated, accepted evidence in meaningfully similar
Step-and-window contexts. Show reasons and uncertainty, fall back quietly, and
keep the user in control. This best matches canon and evidence.

## Unknowns and risks

- “Meaningfully similar” needs an observable product boundary so Design does
  not invent an unbounded behavioral model.
- Sparse evidence can produce false confidence. The product needs a quiet state
  and a minimum evidence threshold before proposing a learned pattern.
- Feedback may reflect temporary illness, unusual travel, caregiving, or an
  exceptional deadline. A correction must be able to stay local to one context
  instead of becoming a global trait.
- A fit explanation can expose protected calendar or health-adjacent context.
  Derived reasons remain private and must be minimized in notifications,
  diagnostics, and exports.
- Generated-path Steps are one consumer, but existing user-created Steps should
  also benefit. The feature should not depend on Goal Path generation to be
  coherent.
- Reflow can affect multiple commitments. Preview, consequence, confirmation,
  recovery, and partial-failure semantics must remain owned by Scheduling.
- External user research is still needed to learn which contextual factors users
  understand, want to state, or consider intrusive.

## Recommended direction

Research supports a task-specific context-fit system rather than a universal
time-quality score. Start with current structural facts and explicit user
preferences. When repeated accepted evidence exists, Ambitions can propose a
narrow event-relative pattern with its evidence, uncertainty, affected Step
shape, and controls. Raw behavior may prompt that proposal but cannot silently
become a trait or preference; persistence requires user confirmation. Sparse,
conflicting, or merely repeated friction produces no learned rule.

The candidate direction compares eligible windows, explains why one fits the
accepted Step better, previews placement or reflow consequences, and commits
nothing until existing scheduling authority allows it. The user can correct a
single placement, a context relationship, or a learned influence without
creating a diagnosis or rewriting unrelated history.

This initiative can research and deliver value for existing Steps independently
of generated paths. It depends on Goal Path generation only when scheduling
Steps produced by that later route, and it never owns Goal, Goal Path, Life
Branch, or destination decisions.
