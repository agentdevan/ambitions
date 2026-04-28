# Ambitions Intelligence, Automation, And Suggestions

Status: Active canon consolidation layer.

Purpose: Consolidate Ambitions intelligence behavior, automation boundaries, suggestion language, confidence display, user control, and anti-AI-theater rules into one implementation-readable reference. This document reflects Wave 11 product decisions.

## Core Intelligence Doctrine

Ambitions intelligence should primarily:

```text
Explain, suggest, and prepare.
```

Ambitions intelligence should not primarily:

- chat with the user
- make decisions for the user
- automate everything
- score the user
- hide uncertainty

## User-Facing Language Policy

Normal UI should not expose AI/model language.

Avoid normal UI labels such as:

- AI
- model confidence
- model reasoning
- prompt
- agent
- hallucination
- LLM

Prefer user-facing labels such as:

- `Why This`
- `Why Now`
- `Why Changed`
- `What This Uses`
- `Suggested`
- `Needs Confirmation`
- `Update This`

Rules:

- Technical/debug surfaces may expose internal language where necessary.
- User-facing product language should focus on usefulness, control, explanation, and correction.

## Suggestion Feel

Suggestions should feel like:

```text
Calm options.
```

Suggestions should not feel like:

- commands
- ads
- motivational nudges
- warnings by default
- pressure tactics

Rules:

- Suggestions should be dismissible.
- Suggestions should not imply the user is wrong or behind.
- Suggestions should be specific enough to act on.

## Suggestion Requirements

Every meaningful suggestion should include:

```text
Why this.
Evidence or assumption.
User control.
Dismiss/change option.
```

Implementation pattern:

- show the suggestion
- explain why it appears
- identify whether it is based on evidence or assumption
- let user accept, change, dismiss, or review
- create receipt when a meaningful action occurs

## Plan / Goal Change Boundary

Ambitions should only change plans/goals after user confirmation when the change is important.

Rules:

- Do not silently rewrite goals.
- Do not silently change important deadlines.
- Do not silently reschedule meaningful work.
- Do not silently change external calendars.
- Reversible local representation changes may use receipt + undo where safe.

## Confidence Display

Normal UI:

```text
Qualitative only.
```

Debug/internal contexts:

```text
Numeric/debug confidence allowed.
```

Preferred normal labels:

- `Clear`
- `Likely`
- `Needs Review`
- `Uncertain`
- `Based on Older Context`

Rules:

- Avoid fake precision.
- Do not use numerical confidence in normal UI.
- Confidence should not become a score for the user.

## Meaning Of Smart

Smart means:

```text
Predictive.
Personalized.
Explainable.
Correctable.
Explainable/correctable first.
```

Rules:

- Prediction without explanation is not enough.
- Personalization without correction is not trustworthy.
- Smart behavior must preserve user agency.
- Smart behavior must degrade safely when uncertain.

## Acting Without User Input

Allowed without explicit input:

```text
Safe local reversible actions.
```

Requires confirmation:

```text
External actions.
Important changes.
Destructive actions.
Major deadline changes.
Calendar writes.
Sensitive/high-impact memory creation.
```

Rules:

- Safe local reversible actions should produce receipt + undo where meaningful.
- External actions require confirmation.
- Important plan/goal changes require confirmation.
- Deleting memory requires confirmation.

## Safe Automation Boundary

Safe automation boundary:

```text
Confirm before important changes.
Safe local reversible actions allowed.
```

Ambitions may:

- suggest
- prepare
- explain
- draft
- route low-risk captures
- perform safe local reversible actions with receipt/undo
- ask for confirmation

Ambitions must not silently:

- send/share/export personal information
- write to calendar
- delete memory
- create sensitive/high-impact memory
- make major deadline changes
- rewrite goals/plans
- hide uncertainty
- pretend certainty

## Receipts And Corrections

Meaningful intelligence-driven actions should create receipts.

Receipt should explain:

- what happened
- why it happened
- what evidence or assumption was used
- how to undo or correct where safe

Rules:

- Correction should improve future suggestions where memory rules allow.
- Sensitive or high-impact corrections should follow Trust/Memory confirmation rules.

## Intelligence Must Never

Intelligence must never:

```text
Hide uncertainty.
Pretend certainty.
Shame the user.
Make external changes silently.
```

Additional red flags:

- suggestion appears with no explanation
- suggestion cannot be dismissed
- user cannot correct wrong assumptions
- external write happens silently
- model/AI language leaks into normal UI
- user is scored instead of supported

## QA Acceptance Criteria

Intelligence / automation is acceptable when:

- Intelligence primarily explains, suggests, and prepares.
- Normal UI avoids AI/model language.
- Suggestions feel like calm options.
- Important plan/goal changes require user confirmation.
- Meaningful suggestions include why this, evidence/assumption, user control, and dismiss/change option.
- Confidence is qualitative in normal UI and numeric only in debug/internal contexts.
- Smart behavior is predictive/personalized only when explainable and correctable.
- Safe local reversible actions can occur with receipt/undo where safe.
- External actions require confirmation.
- Automation confirms before important changes.
- Intelligence never hides uncertainty, pretends certainty, shames the user, or makes external changes silently.

## Open Questions For Future Waves

- Which suggestions should appear inline versus in review surfaces?
- Should suggestions have persistent receipts or only action receipts?
- What qualitative confidence labels should ship first?
- Should debug confidence be completely hidden from release builds?
- Which safe local reversible actions are allowed without explicit pre-confirmation in v1?
