# Ambitions Human Language Review

Status: Active post-canon language correction layer.

Purpose: Review Ambitions docs for user-facing language that sounds like AI, product strategy, or internal systems language. This document sets the active rule for human, obvious, plain UI copy. It supersedes earlier user-facing wording in active docs where those docs use phrases such as `protected`, `protect`, `anchor`, `optimize`, `AI`, `intelligent`, `system`, or abstract execution labels in normal UI.

## Core Finding

Ambitions should not sound like an AI product talking about productivity.

Ambitions should sound like a calm, capable person helping the user answer:

```text
What matters?
What should I do next?
What can move later?
What changed?
What is still okay?
```

The product can be intelligent internally. The UI should not perform intelligence.

## Primary Rule

User-facing copy should prefer plain human language over branded, abstract, strategic, or AI-coded language.

Use:

```text
Do this next.
Most important today.
Too much for today.
Move this to later.
What should stay on today?
This still works.
This no longer works.
Saved.
Changed.
Nothing moved automatically.
```

Avoid in normal UI:

```text
Best Next Action.
Protected.
Protection.
Protect this.
Protect later.
Anchor.
Mission control.
Optimize.
Leverage.
Intelligent.
AI.
Model.
Confidence.
Execution context.
Believability engine.
System center.
Strategic chamber.
Operating system.
Proof rail.
Continuity mesh.
```

## Internal vs User-Facing Boundary

Some terms are allowed internally in docs, code, roadmap, or architecture when they name systems.

Examples allowed internally:

- Best Next Action
- Now State
- Believability
- Goal Weather
- Action Closure
- Smart Attachment
- Focus Support
- Life OS
- external brain
- Command Pipeline

But normal UI should translate them into human copy.

| Internal / canon term | User-facing copy direction |
| --- | --- |
| Best Next Action | `Do this next` |
| Now State | `Right now` / `Why this now` |
| Protected / Protect | `Most important`, `Keep this`, `Move this later`, `What should stay?` |
| Needs Protection | `Too much for today` / `Too much planned` |
| Protected block | `Time set aside` / `Focus time` |
| Goal Weather | `How this goal is going` / status-specific copy |
| Believable | `Looks doable` |
| Fragile / Needs Protection | `Too much planned` |
| Broken / No Longer Holds | `No longer works` |
| Smart Attachment | `Suggested place` / `Move it here?` |
| Intelligence / AI | `Suggested` / `Based on...` |
| System Center | `You` / `Your settings and history` |
| Action Closure | `Saved`, `Moved`, `Changed`, `Undo` |

## Today Language Rule

Today should be the plainest surface in the app.

Today should sound like:

```text
Today
Do this next
Most important today
Too much for today
Make today doable
Move this to later
What should stay on today?
If there is time
Nothing moved automatically
```

Today should not use:

```text
Protected must-do
Needs protection
Protect later
Today’s anchor
Execution context
Optimization
```

Recommended Today recovery copy:

```text
Too much for today.
Pick what still needs to happen, and move the rest later.
```

Recommended action:

```text
Make today doable
```

Recommended secondary actions:

```text
Move to later
Keep on today
Open Plan
```

## Plan Language Rule

Plan can talk about whether the day or week works, but should avoid artificial certainty.

Use:

```text
Looks doable
Tight
Too much planned
No longer works
Find open time
Move to later
Keep this week lighter
```

Avoid:

```text
Believable plan
Needs Protection
Optimize schedule
Calendar intelligence
Capacity engine
```

Internal labels may remain for state machines, but visible labels should use the plain language above.

## Goals Language Rule

Goals should feel meaningful and grounded, not like a corporate operating model.

Use:

```text
Most important goal
What is next?
How is this going?
What changed?
Still worth doing?
Put this on pause
End this goal
```

Avoid in normal UI:

```text
Protected goal
Mission control
Strategic chamber
Proof spine
Goal portfolio health
North Star optimization
```

Internal docs may keep precise terms where useful, but UI should translate them.

## Capture Language Rule

Capture should feel like putting something where it belongs.

Use:

```text
What needs a place?
Saved as Task
Saved to Later
Move it here?
Keep it by itself
Needs a Place
```

Avoid:

```text
AI routed this
Smart classification
Confidence score
Semantic routing
```

## You / Trust Language Rule

You can remain the personal control area, but normal UI should avoid sounding like a data console.

Use:

```text
You are in control
What Ambitions knows
Your settings
Your history
Delete what Ambitions remembers
Export your data
```

Avoid:

```text
Personal system center
Trust score
Memory graph
User model
Identity substrate
```

`Personal system center` remains acceptable as product/design language only, not a normal UI title.

## Notification And Widget Language Rule

External copy must be extra plain because it appears out of context.

Use:

```text
Do this next
Time for your next step
Open Plan to adjust today
Private item
```

Avoid:

```text
A protected block is starting
Your execution context changed
AI found an issue
Your plan is fragile
```

## Replacement Table

| Avoid | Use instead |
| --- | --- |
| Protected must-do | Most important today |
| Protected goal | Most important goal |
| One protected / most important goal | Most important goal |
| Needs Protection | Too much planned / Too much for today |
| Protect this | Keep this |
| Protect later | Move this later |
| Ask what to protect | Ask what should stay on today |
| Protected block | Focus time / Time set aside |
| Best Next Action | Do this next |
| Now State | Right now / Why this now |
| Believable | Looks doable |
| No Longer Holds | No longer works |
| Make Plan calendar-aware | Find open time from Calendar |
| Explainability | Why this |
| Action Closure | Receipt / what changed |
| Intelligence | Suggestions |
| Smart | Suggested / helpful |
| Optimize | Make better / make doable / adjust |
| Leverage | Use |
| Friction | Hard part / slowdown |
| System center | Settings and history / You |

## Audit Findings

### Required immediate canon cleanup

- `TODAY_NOW_STATE.md` uses `ask what to protect`, `Protect This`, and `Protect Later` in user-facing recovery examples.
- `ux-writing-state-language-matrix.md` approves `Protect Later`, `A protected block is starting`, and copy that says a step `protects` a goal.
- `PRODUCT_DECISIONS.md` preserves earlier Wave 2/Wave 6/Wave 7/Wave 8 language such as `Needs Protection`, `ask what to protect`, and `one protected / most important goal`. This document supersedes those phrases for normal UI copy.

### Acceptable internal language

- Roadmap and architecture docs may use `intelligence`, `system`, `engine`, `Believability`, `Now State`, or `Action Closure` when naming internal systems.
- Code and tests may continue to use internal state names until implementation batches migrate them.
- Historical docs may preserve old language as history if clearly marked as historical.

### Later implementation cleanup

Code-facing strings and previews should be reviewed for the same language rules before a user-visible release. Search terms for that pass:

```text
protected
protect
anchor
AI
intelligent
optimize
leverage
execution context
believable
fragile
No Longer Holds
```

## Acceptance Criteria

User-facing copy passes when:

- A non-technical user understands it immediately.
- It sounds like a person, not a product system.
- It does not say AI, model, confidence, engine, graph, optimization, or execution context.
- It does not use `protect/protected/protection` unless the feature is literally about privacy/security.
- It avoids branded metaphors where plain words work.
- It says what happened and what the user can do next.
- It does not shame, pressure, perform intelligence, or exaggerate certainty.

## Next Codex Prompt

```markdown
Review user-facing strings in the Ambitions repo for human language compliance.

Read first:
1. `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
2. `docs/canon/design/ux-writing-state-language-matrix.md`
3. `docs/canon/TODAY_NOW_STATE.md`
4. `docs/canon/PRODUCT_DECISIONS.md`
5. `docs/canon/SOURCE_OF_TRUTH_MAP.md`

Task:
- Search app code, previews, tests, and docs for user-facing strings that sound AI/producty.
- Replace visible UI copy that uses protected/protection/anchor/AI/model/confidence/optimize/leverage/execution context with plain human alternatives.
- Do not rename internal models, services, or state-machine cases unless specifically scoped.
- Do not break tests without updating expected user-facing strings.
- Preserve internal canon names where they are not visible UI.

Acceptance:
- Today uses `Do this next`, `Most important today`, `Too much for today`, `Make today doable`, `Move this later`, and related plain language.
- Plan uses `Looks doable`, `Tight`, `Too much planned`, and `No longer works` for visible state labels.
- Goals uses `Most important goal`, `What is next?`, and `How is this going?` style copy.
- External surfaces avoid `protected block` and use plain copy.
- No normal UI uses AI/model/confidence language.
```
