# UX Writing State Language Matrix

Status: Active supporting design canon.

## Approved Voice Rules

- Calm, adult, specific, non-shaming, clear, direct, emotionally safe, action-oriented.
- Prefer concrete next steps over abstract encouragement.
- Prefer plain human language over branded, strategic, or AI-coded language.
- Use truthful capability language: stored locally, requires confirmation, manual fallback available, future planned, unavailable, not verified, suggested not applied.
- Ambitions may be intelligent internally, but normal UI should not sound like an AI product.
- Follow [../HUMAN_LANGUAGE_REVIEW.md](../HUMAN_LANGUAGE_REVIEW.md) for user-facing language cleanup.

## Plain Language Rule

Normal UI should sound like a calm person helping the user decide what to do.

Prefer:

- `Do this next`.
- `Most important today`.
- `Too much for today`.
- `Make today doable`.
- `Adjust plan`.
- `Keep this on today`.
- `What should stay on today?`.
- `Looks doable`.
- `No longer works`.
- `Nothing moved automatically`.

Avoid in normal UI:

- `AI Explanation`, `AI Confidence`, `Model Reasoning`, `Fix AI`.
- `protected`, `protection`, or `protect` unless the feature is literally about privacy/security.
- `anchor`, `execution context`, `optimization`, `leverage`, `intelligent system`, `engine`, `graph`, `model`, or `confidence`.
- `ADHD Mode`; use `Focus Support`.
- Shame language such as failed, lazy, behind again, streak lost.
- Claims of verified accessibility, sync, cloud memory, silent automation, or production platform support without evidence.

## Button Label Rules

- Verb-led.
- 1-3 words where possible.
- Exact labels for meaningful actions: `Start`, `Move This`, `Move Later`, `Keep This`, `Park`, `Mark Done`, `Open Plan`, `Save the Day`, `Make Today Doable`, `Change Route`, `Attach`.
- `OK`, `Continue`, or `Done` only when harmless and no semantic action is hidden.

## Capture Receipts

- `Needs a Place`.
- `Saved as Task · Career · Later`.
- `Saved as Step · Career · Become an Astronaut · Later`.
- `Suggestion: Attach to Become an Astronaut`.
- `Change`.
- `Keep Standalone`.

## Recovery Language

- `Save the Day`.
- `Save the Week`.
- `Make Today Doable`.
- `Make Lighter`.
- `Move This Later`.
- `Keep This On Today`.
- `Needs a New Place`.
- `Drifted`.
- `Not Today`.

Avoid:

- `Protect Later`.
- `Protect This`.
- `Needs Protection`.
- `Protected block`.

## Trust / Explanation Labels

- `Why This`.
- `Why Now`.
- `Why Changed`.
- `What This Uses`.
- `Needs Confirmation`.
- `Update This`.
- `From your calendar`.
- `Created in Ambitions`.
- `Based on your plan`.

## Memory Freshness Labels

- `Current`.
- `May Need Review`.
- `Based on Older Context`.

## Empty States

- Explain the missing object and offer one useful next action.
- Avoid marketing claims.
- Example: `Nothing needs a place right now.` Action: `Capture`.

## Error States

- Say what happened, what remains safe, and what the user can do.
- Example: `Calendar access is unavailable. Plan still works manually.` Action: `Keep Planning`.

## Loading States

- Use specific object language.
- Avoid fake intelligence theater.
- Example: `Checking today's plan` instead of `Thinking`.

## Success States

- Show the result and next useful route.
- Example: `Saved as Task · Home · Later` with `Change` and `Open`.

## Archive / Parked / North Star Wording

- `Parked` means intentionally paused.
- `North Star` means long-range dormant or identity-level ambition.
- `Archive` preserves learning; it is not trash.
- `Cancelled / Dropped` should preserve why it ended.

## Notification Wording

- Sparse, calm, operational, and privacy-aware.
- Hide sensitive goal names by default.
- Examples: `Do this next`, `Time for your next step`, `Open Plan to adjust today`, `Private item`.
- Avoid: `A protected block is starting`, `Your execution context changed`, `AI found an issue`, `Your plan is fragile`.

## Density-Scaled Copy Examples

- Minimal: `Next: Draft outline`.
- Balanced: `Next: Draft outline. It fits today.`
- Detailed: `Next: Draft outline. It fits the open 45-minute window and helps move your goal forward this week.`

## Expertise-Scaled Copy Examples

- New user: `This is suggested because it fits today.`
- Returning user: `Suggested because this goal needs a real step this week.`
- Expert/deep view: `Based on your plan, deadline pressure, and open window.`
