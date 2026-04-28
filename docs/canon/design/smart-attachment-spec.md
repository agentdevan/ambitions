# Smart Attachment Spec

Status: Active supporting design canon.

Purpose: Define how Capture routes raw input into Ambitions without making the user think like the data model. Reflects product decision Wave 5.

## Definition

Smart Attachment is the Ambitions system that infers whether a capture belongs to an existing Life Area, Ambition, Goal, Plan, Step, Task, Proof item, Decision, Ritual, or Waiting item, then saves with the least friction possible and lets the user correct the route.

Smart Attachment serves the core Capture rules:

```text
Nothing gets lost.
Every capture gets a clear next route.
```

## Capture Input Feel

The main Capture input should feel like a:

```text
Quiet Command Sheet
```

It should not feel like:

- search
- chat
- a generic note app
- an inbox form

Primary Capture placeholder:

```text
What needs a place?
```

Onboarding keeps its separate first prompt:

```text
What do you want to organize?
```

## Supported Object Types

Launch/core routes:

- Task.
- Goal.
- Idea.
- Proof item.
- Waiting item.
- Plan.

Later/advanced routes:

- Contextual Note.
- Reminder.
- Ritual.
- Archive.
- Decision.

Supporting destination types:

- Life Area.
- Ambition / North Star.
- Path.
- Milestone.
- Step.

## Notes Policy

Ambitions should not have a general Notes object at launch.

Rules:

- Allow contextual notes attached to meaningful objects.
- Avoid turning Ambitions into a general notes app.
- Notes can attach to goals, tasks, proof, reviews, decisions, plans, or other meaningful objects.
- A larger notes surface can be reconsidered later after core execution is mature.

## Confidence Behavior

Confidence behavior:

```text
High confidence: route + receipt
Medium confidence: route + receipt + easy Change
Low confidence: ask 1 question or save to Needs a Place
```

Rules:

- High confidence should still show a correctable receipt.
- Medium confidence should avoid blocking the user; route safely and make `Change` obvious.
- Low confidence can ask one compact question or save to Needs a Place.
- Never silently discard uncertain input.

Temporary holding area:

```text
Needs a Place
```

## Editable Receipt Behavior

Every attachment result must show what was saved, where it went, why when useful, and how to change it. Receipts must be searchable later and privacy-sensitive details must hide by default where appropriate.

Preferred receipt pattern:

```text
Saved as Task · Today
Saved as Goal · Creative
Saved to Needs a Place
Attached as Proof · Music Goal
```

Avoid generic primary success copy:

- `Captured`
- `Routed`
- `Added to Ambitions`

Rules:

- Receipt should show object type, destination, and correction route where safe.
- Correction creates a new receipt or updates the receipt trail where technically safe.
- The old incorrect route should not silently remain as active truth.

## Clarification Behavior

Clarification choices should be compact and object-specific, such as:

- `Task`
- `Goal`
- `Idea`
- `Proof`
- `Waiting`
- `Plan`
- `Attach`
- `Keep Standalone`

Rules:

- Ask one clear question when low confidence needs user help.
- Do not open a chat conversation.
- Do not expose full domain machinery.
- The Quiet Command Sheet is not a chat interface.

## Task-To-Goal Promotion

Capture should suggest task-to-goal promotion; the user confirms before promotion.

Rules:

- Do not auto-promote tasks into goals.
- If a task appears to have too much structure, suggest `Turn Into Goal`.
- Promotion creates a receipt.
- Promotion preserves the original capture context.

## Voice Input

Voice input should use iOS dictation first.

Rules:

- Do not build a separate voice system at launch.
- Do not claim native voice capture beyond platform dictation until implemented.
- A dedicated voice capture system can come later.

## Examples

High confidence:

```text
Saved as Step · Career Goal · Later
Change
Keep Standalone
```

Medium confidence:

```text
Saved as Task · Career · Later
Change
Suggestion: Attach to Career Goal
```

Low confidence:

```text
Saved to Needs a Place
Choices: Task / Goal / Idea
```

Proof example:

```text
Attached as Proof · Music Goal
Change
```

Plan example:

```text
Saved as Plan item · This Week
Change
```

## Wrong Attachment Correction

Wrong routes must be correctable from the receipt. Correction creates a new receipt or updates the original receipt trail where technically safe. The old incorrect route should not silently remain as active truth.

## Future Behavior Learning

Future behavior may learn from explicit corrections and repeated user-confirmed patterns only. It must not infer sensitive categories or permanent preferences from a single ambiguous capture.

Low-risk repeated task routing may become Memory with receipt/visibility. Sensitive or high-impact routing patterns follow Trust/Memory confirmation rules.

## Privacy Rules

- Keep captured content local-first unless a future explicit sync/export path says otherwise.
- Do not copy calendar or external data into Smart Attachment stores unless needed for the route receipt.
- Hide sensitive details in receipts and external surfaces by default.
- Sensitive Life Area details should use generic labels such as `Private item` on external/compact surfaces.

## Failure States

- If classification fails, save to Needs a Place.
- If the intended destination is unavailable, save standalone with a receipt.
- If confidence is unclear, ask compact clarification or save to Needs a Place.
- If save fails, preserve the user's text and offer retry/copy.

## Accessibility Rules

- Route, confidence behavior, and correction action need VoiceOver labels.
- Choices must not require typing when a simple route choice works.
- Motion should communicate where the item went; Reduce Motion must provide equivalent static clarity.
- The Capture input should expose its role as a capture/command surface, not search/chat.

## Resolved Wave 5 Questions

- Capture input feel: Quiet Command Sheet.
- Capture placeholder: `What needs a place?`.
- Route behavior is confidence-based.
- Temporary holding area: Needs a Place.
- Launch/core routes: Task, Goal, Idea, Proof, Waiting, Plan.
- Later routes: Contextual Note, Reminder, Ritual, Archive, Decision.
- No general Notes object at launch; contextual notes only.
- Successful receipts use `Saved as...` / `Attached as...` pattern.
- Task-to-goal promotion is suggested and user-confirmed, not automatic.
- Voice input uses iOS dictation first; native voice capture later.
- Highest rules: nothing gets lost; every capture gets a clear next route.
