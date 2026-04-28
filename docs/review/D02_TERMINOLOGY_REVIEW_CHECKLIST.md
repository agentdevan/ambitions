# D02 Terminology Review Checklist

Status: Active review artifact for D02 / Shared Object Terminology Cleanup.

Purpose: Provide a focused acceptance checklist for reviewing the Codex D02 completion summary without interfering with the in-progress implementation branch/session. This checklist is review guidance only; it does not mark D02 complete.

## D02 Goal

D02 should make Ambitions terminology clear and human while preserving internal compatibility where broad renames would be risky.

The user should understand the difference between:

```text
Goal = meaningful direction or outcome.
Plan = the path that can actually hold.
Task / One-Step Goal = standalone useful action.
Step = contained action inside a goal, plan, milestone, or path.
Ritual = repeated support loop, not a top-level Habits app.
Receipt / Proof = evidence that something happened or changed.
```

## Source Docs To Check Against

Review D02 against:

1. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
2. `docs/canon/GOLDEN_LAUNCH_LOOP.md`
3. `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md`
4. `docs/canon/HUMAN_LANGUAGE_REVIEW.md`
5. `docs/canon/DOMAIN_MODEL.md`
6. `docs/canon/GOAL_PLAN_TASK_LIFECYCLE.md`
7. `docs/canon/IA_NAVIGATION_DRILLDOWN.md`
8. `docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md`

## Must Preserve

D02 must preserve:

- Top-level shell: `Today / Goals / Capture / Plan / You`.
- Local-first launch posture.
- No new top-level Tasks, Habits, Calendar, Insights, Life Areas, or Profile tab.
- Existing data compatibility.
- Existing deep-link compatibility where possible.
- Internal compatibility names when renaming would cause broad code churn.
- Human-language rules for all visible copy.

## User-Facing Terminology Acceptance

D02 passes visible terminology review when normal UI uses language like:

| Concept | Preferred visible language |
| --- | --- |
| next action | `Do this next`, `Next step`, `What is next?` |
| overloaded plan/day | `Too much for today`, `Too much planned` |
| recovery | `Make today doable`, `Move this later`, `Keep this on today` |
| internal believability | `Looks doable`, `Tight`, `No longer works` |
| memory | `What Ambitions knows` |
| command/global input | `Add something`, `What needs a place?` |
| protected/private | `Private`, `Private item`, `Time set aside` only where privacy/time is literal |
| confidence | `Looks useful`, `Strong signal`, `Needs review`, `Why this` |
| habits | `Rituals`, `Routines`, or Plan-owned support loops depending on context |
| profile | `You` |
| captures | `Capture` for the top-level surface; internal plural allowed if code-only |

## Rejected Visible Language

D02 should not leave normal user-facing UI that says:

```text
AI
model
confidence score
execution context
optimization
leverage
protected goal
needs protection
protect this
anchor
system center
memory graph
task dump
Profile as top-level label
Insights as top-level label
Habits as top-level label
Captures as top-level label
```

Exceptions:

- Internal model/service names may keep legacy terms if they are not visible to users.
- Historical docs may retain old terms if clearly historical/supporting.
- Tests may reference legacy compatibility only when asserting migration/deep-link behavior.

## Object Model Review

Check whether D02 clearly distinguishes:

### Goal

A goal is a meaningful desired outcome or direction. It may contain milestones, plans, steps, proof, decisions, and reviews.

Acceptance:

- Goals are not presented as simple tasks.
- Goal Detail can show next step and proof.
- Goal creation copy is plain and human.

### Task / One-Step Goal

A Task is a standalone useful action that does not need a full project/goal container yet.

Acceptance:

- No standalone Tasks tab is introduced.
- A standalone task can later attach/promote to a Goal when appropriate.
- Copy avoids making a user categorize everything too early.

### Step

A Step is an action inside a Goal, Plan, Milestone, or Path.

Acceptance:

- Step is not treated as the same thing as Task in visible copy where distinction matters.
- Today can show a step as the next action.

### Ritual / Routine

A Ritual/Routine is a repeated support pattern that helps execution, not a separate Habits product.

Acceptance:

- No top-level Habits tab returns.
- Plan may own ritual/routine shaping if relevant.
- Today may show a ritual only if it matters now.

### Receipt / Proof

Receipt confirms an action/result happened. Proof shows meaningful goal progress.

Acceptance:

- Meaningful actions show `Saved`, `Moved`, `Changed`, `Undo`, or similar plain feedback.
- Proof does not rely only on task completion.
- Proof can include artifacts, decisions, feedback, blockers resolved, and reviews when implemented.

## Search Queries For Reviewer

Use repo search or local grep for visible-risk terms:

```bash
rg -n 'Protected|protect this|Needs Protection|Fragile|High confidence|Medium confidence|Low confidence|execution context|Memory Lens|Quiet Command Sheet|Strategy Composer|Profile|Insights|Habits|Captures|Tasks|Calendar' Native Sources AppUI docs --glob '!docs/archive/**'
```

Then classify each hit as:

- visible user-facing issue
- internal compatibility okay
- test/migration compatibility okay
- historical/supporting doc okay
- needs follow-up

## D02 Completion Review Questions

When Codex reports D02 completion, ask:

1. Did D02 preserve the five-tab shell?
2. Did D02 avoid broad unsafe renames?
3. Did D02 clearly distinguish Task from Step?
4. Did D02 make Capture singular where user-facing?
5. Did D02 move top-level Profile language to You where visible?
6. Did D02 keep Habits/Rituals subordinate to Plan/Today where appropriate?
7. Did D02 avoid AI/producty visible copy?
8. Did D02 preserve deep-link compatibility?
9. Did D02 update affected tests/previews/accessibility labels?
10. Did D02 run build/tests or clearly explain what was not run?

## Minimum Acceptable Validation

Preferred validation:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test
```

If that simulator is unavailable, Codex should select an available iPhone simulator and state which one.

If full validation is not run, D02 should not be considered fully complete until the limitation is explicit.

## Reviewer Verdict Template

Use this when reviewing Codex output:

```markdown
## D02 Review Verdict

Verdict: Pass / Pass with follow-ups / Needs fix prompt

### What passed
- ...

### Issues found
- ...

### Required fixes before D03
- ...

### Validation status
- Build:
- Tests:
- UI tests:
- Not run:

### Move to D03?
Yes / No
```

## Notes From Pre-D02 Manual Cleanup

Before D02 finished, a non-Codex cleanup pass already humanized several visible shell/preview/component labels, including:

- `Memory Lens` visible shell label -> `What Ambitions knows`
- `Quiet Command Sheet` visible shell label -> `Add something`
- `Strategy Composer` visible goal setup reference -> `goal setup`
- `Profile` visible preview labels -> `You`
- `Confidence` visible chip/accessibility labels -> `Suggestion`, `Strong signal`, `Useful signal`, or `Needs review`
- `Protected` visible chip/status labels -> `Private` or `Time set aside`
- `Fragile` visible status labels -> `Too much planned`

D02 should preserve or improve those changes, not regress them.
