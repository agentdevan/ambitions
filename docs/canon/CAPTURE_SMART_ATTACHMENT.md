# Ambitions Capture And Smart Attachment

Status: Active canon consolidation layer.

Purpose: Consolidate Capture and Smart Attachment decisions into one implementation-readable reference. This document reflects Wave 5 product decisions and complements `docs/canon/design/smart-attachment-spec.md`.

## Core Capture Doctrine

Capture exists so the user can put life into Ambitions without deciding the perfect structure immediately.

Highest rules:

```text
Nothing gets lost.
Every capture gets a clear next route.
```

Capture should feel fast, calm, and organized, but never at the cost of losing or misrouting user intent.

## Capture Input Feel

The main Capture input should feel like:

```text
Quiet Command Sheet
```

It should not feel like:

- search
- chat
- a generic note app
- an inbox form

Capture tab placeholder:

```text
What needs a place?
```

Onboarding prompt:

```text
What do you want to organize?
```

Rules:

- Capture is not a chat-first AI surface.
- Capture is not general notes.
- Capture is not a long-term inbox graveyard.
- Capture is a routing surface that makes life objects easier to place.

## Route Confidence Behavior

When Ambitions is unsure where a capture belongs, behavior depends on confidence.

```text
High confidence: route + receipt
Medium confidence: route + receipt + easy Change
Low confidence: ask 1 question or save to Needs a Place
```

Rules:

- High confidence still requires a correctable receipt.
- Medium confidence should not block flow; it should make correction obvious.
- Low confidence should either ask one compact question or save safely to Needs a Place.
- Failed classification should never discard input.

## Temporary Holding Area

Name:

```text
Needs a Place
```

Purpose:

- safe holding area for low-confidence captures
- not a permanent inbox
- not an archive
- not a dumping ground

Rules:

- Needs a Place should have route choices.
- Needs a Place should not punish the user for not deciding immediately.
- Items in Needs a Place should eventually route to a clearer object or remain visibly unresolved.

## Allowed Capture Routes

Launch/core routes:

```text
Task
Goal
Idea
Proof
Waiting
Plan
```

Later/advanced routes:

```text
Contextual Note
Reminder
Ritual
Archive
Decision
```

Rules:

- `Task` means user-facing standalone action.
- `Goal` means meaningful outcome that may need a plan.
- `Idea` means seed that does not need immediate commitment.
- `Proof` means evidence attached to a relevant object.
- `Waiting` means blocked by another person, event, or context.
- `Plan` means something that affects day/week/phase shape.

## Notes Policy

Ambitions should not have a general Notes object at launch.

Resolved decision:

```text
No general Notes object at launch. Allow contextual notes attached to objects.
```

Rules:

- Avoid becoming a notes app.
- Contextual notes can attach to Goal, Task, Plan, Proof, Review, Decision, or other meaningful objects.
- A larger notes surface can be reconsidered after core execution is mature.

## Receipt Pattern

Successful capture receipts use the `Saved as...` / `Attached as...` pattern.

Examples:

```text
Saved as Task · Today
Saved as Goal · Creative
Saved to Needs a Place
Attached as Proof · Music Goal
```

Rules:

- Show object type.
- Show destination.
- Show next useful action when available.
- Show `Change` or correction route where safe.
- Avoid generic primary success copy such as `Captured`, `Routed`, or `Added to Ambitions`.

## Task-To-Goal Promotion

Capture should suggest task-to-goal promotion; user confirms before promotion.

Rules:

- Do not auto-promote tasks into goals.
- Suggest `Turn Into Goal` when a task appears to have too much structure.
- Promotion creates a receipt.
- Promotion preserves the original capture context.

## Voice Input

Voice input should use iOS dictation first.

Rules:

- Do not build a separate native voice capture system at launch.
- Do not claim voice capture beyond platform dictation until implemented.
- A dedicated voice capture system can come later.

## Failure States

If save fails:

```text
This did not save. Your text is still here.
```

Actions:

```text
Try Again
Copy Text
```

If classification fails:

```text
Saved to Needs a Place
```

If route is wrong:

```text
Change
```

Rules:

- Preserve input.
- Do not discard raw user thought.
- Do not fake a successful route.
- Failed or uncertain captures should remain recoverable.

## Memory / Learning Boundary

Low-risk repeated task routing may become Memory with receipt/visibility.

Sensitive or high-impact routing patterns follow Trust/Memory confirmation rules.

Rules:

- Do not infer sensitive categories from a single ambiguous capture.
- Do not create hidden profile memory from capture behavior.
- Learning from capture should be visible in `What Ambitions Knows` when it becomes memory.

## Accessibility Requirements

- Capture input must have a VoiceOver label describing it as a capture/command surface, not search/chat.
- Route choices must be reachable without gestures.
- Receipt correction must be VoiceOver-readable.
- Motion that shows routing must have a Reduce Motion equivalent.
- `Needs a Place` should be understandable as a temporary holding area.

## QA Acceptance Criteria

Capture is acceptable when:

- The main input uses `What needs a place?`.
- The input feels like a Quiet Command Sheet.
- Capture does not present as chat/search/general notes.
- Route confidence behavior matches high/medium/low rules.
- Low-confidence items are asked one question or saved to Needs a Place.
- Launch/core routes are Task, Goal, Idea, Proof, Waiting, and Plan.
- General Notes are not introduced as a launch object.
- Contextual notes can attach to meaningful objects where supported.
- Receipts use the `Saved as...` / `Attached as...` pattern.
- Wrong routes are correctable from the receipt.
- Task-to-goal promotion is suggested and user-confirmed.
- Voice input relies on iOS dictation first.
- Save failure preserves text.
- Nothing gets lost.
- Every capture gets a clear next route.

## Open Questions For Future Waves

- Should Capture low-confidence choices be Task / Goal / Idea or Task / Goal / Later?
- Should Needs a Place have a daily/weekly review prompt?
- Should contextual notes support rich text, attachments, links, or plain text only?
- Should voice capture later become its own protected capture mode?
