# Smart Attachment Spec

Status: Active supporting design canon.

## Definition

Smart Attachment is the Ambitions system that infers whether a capture belongs to an existing Life Area, Ambition, Goal, Plan, Step, Task, Proof item, Decision, Ritual, or Waiting item, then saves with the least friction possible and lets the user correct the route.

## Supported Object Types

- Life Area.
- Ambition / North Star.
- Goal.
- Plan.
- Step.
- Task / One-Step Goal.
- Proof item.
- Decision.
- Ritual.
- Waiting item.

## Confidence Behavior

- High confidence: attach automatically and show an editable receipt.
- Medium confidence: save standalone and suggest an attachment in the receipt.
- Low confidence: save to Needs a Place.
- Clarification: compact 1-3 choices, not chat.

## Editable Receipt Behavior

Every attachment result must show what was saved, where it went, why when useful, and how to change it. Receipts must be searchable later and privacy-sensitive details must hide by default where appropriate.

## Clarification Behavior

Clarification choices should be compact and object-specific, such as `Task`, `Goal`, `Seed`, `Attach`, `Keep Standalone`, or named destination choices. The Quiet Command Sheet is not a chat interface.

## Examples

Input: `find NASA contacts on LinkedIn later`.

High confidence:

```text
Saved as Step · Career · Become an Astronaut · Later
Change
Keep Standalone
```

Medium confidence:

```text
Saved as Task · Career · Later
Suggestion: Attach to Become an Astronaut
```

Low confidence:

```text
Saved to Needs a Place
Choices: Task / Goal / Seed
```

## Wrong Attachment Correction

Wrong routes must be correctable from the receipt. Correction creates a new receipt or updates the original receipt trail where technically safe. The old incorrect route should not silently remain as active truth.

## Future Behavior Learning

Future behavior may learn from explicit corrections and repeated user-confirmed patterns only. It must not infer sensitive categories or permanent preferences from a single ambiguous capture.

## Privacy Rules

- Keep captured content local-first unless a future explicit sync/export path says otherwise.
- Do not copy calendar or external data into Smart Attachment stores unless needed for the route receipt.
- Hide sensitive details in receipts and external surfaces by default.

## Failure States

- If classification fails, save to Needs a Place.
- If the intended destination is unavailable, save standalone with a receipt.
- If confidence is unclear, ask compact clarification.

## Accessibility Rules

- Route, confidence behavior, and correction action need VoiceOver labels.
- Choices must not require typing when a simple route choice works.
- Motion should communicate where the item went; Reduce Motion must provide equivalent static clarity.
