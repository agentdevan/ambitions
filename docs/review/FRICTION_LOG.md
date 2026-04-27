# Ambitions Friction Log

Use this file to capture friction found while actually using, reviewing, or validating Ambitions.

This is not a roadmap, canon file, or feature wishlist. It is a parking lot for observed product friction that should later be triaged into the correct batch, issue, or canon update.

## How to use this file

Add notes only when friction is observed from:

- Running the app.
- Reviewing screenshots.
- Testing a user journey.
- Reading a Codex completion summary.
- Comparing implementation to the active canon.
- Catching roadmap/doc drift.

Do not use this file for speculative invention unless the idea was triggered by a real friction point.

## Severity scale

- **High** — blocks comprehension, trust, navigation, task completion, or batch acceptance.
- **Medium** — weakens quality, clarity, or polish but does not block the flow.
- **Low** — minor polish, language, spacing, or future enhancement.

## Status scale

- **Open** — not triaged yet.
- **Assigned** — belongs to a known batch or issue.
- **Deferred** — intentionally later.
- **Resolved** — fixed or no longer relevant.
- **Rejected** — not aligned with Ambitions direction.

## Entry template

```markdown
## YYYY-MM-DD — Short friction title

Status: Open / Assigned / Deferred / Resolved / Rejected
Severity: High / Medium / Low
Surface: Today / Goals / Goal Detail / Capture / Plan / You / Docs / Architecture / Other
Observed in: Simulator / Screenshot / Codex summary / Repo audit / Manual review / Other
Candidate owner: Batch XX / Future batch / Docs reconciliation / Unknown

### What happened
- ...

### Why it matters
- ...

### Desired outcome
- ...

### Notes / evidence
- ...
```

## Open friction

## 2026-04-27 — You trust rows wrap too narrowly during review

Status: Open
Severity: Medium
Surface: You
Observed in: Simulator screenshot review
Candidate owner: Future batch

### What happened
- During Batch 88 wrap-up review on iPhone 17, several existing You trust/control rows wrapped labels and body copy into very narrow columns, making cards like Accessibility Nutrition, Event Ledger, and Active corrections harder to scan.

### Why it matters
- The copy remains truthful, but the visual hierarchy is harder to understand quickly and weakens the calm trust-center feel.

### Desired outcome
- Revisit row layout constraints so labels, status pills, and body copy keep a readable measure without changing the top-level shell or adding new surfaces.

### Notes / evidence
- Observed while navigating the existing You surface during simulator visual review; this was not required to complete Batch 88 and was not fixed in the wrap-up pass.

## Resolved friction

_No resolved friction logged yet._
