# 18 — Trust, Receipts, And Closure Language

Status: active canon, docs-only.

Purpose:

- make Ambitions intelligence inspectable without AI chrome
- make receipts a signature proof pattern
- make closure humane, non-shaming, and product-defining
- preserve user control across recommendations, reflow, automation, and memory

## Trust Thesis

Trust comes before automation.

Ambitions may suggest, shape, remember, and reflow only when the user can understand the source, reason, control, and receipt path.

Ambitions must never feel like an AI coach, chatbot, black-box scheduler, surveillance system, productivity judge, or motivational assistant.

## User-Facing Label

Preferred:

```text
Trust & Automation
```

Superseded:

```text
Automation & Trust
```

Reason: trust must come before automation in the user’s mental model.

## Why This? Explanation Contract

Every adaptive recommendation uses this structure:

```text
Recommendation
Source
Reason
Uncertainty, if any
User control
Receipt behavior
```

Example:

```text
Recommended step: Draft chorus idea
Source: Music goal + 30 minutes open
Reason: This fits before your next protected block
Control: Start now, adjust plan, or skip for now
Receipt: Starting leaves no schedule change
```

Forbidden:

- AI recommends
- The model thinks
- Optimized for you
- Best next move
- You should
- confidence percentages
- chatbot drawer
- AI avatar
- creepy memory phrasing

## Source Labels

Approved source labels:

- Calendar
- Music goal
- Career goal
- Goal thread
- Planning default
- Protected time
- Recent capture
- Manual mode
- User adjustment
- Source unavailable

Rules:

1. Calendar is a source, not a product identity.
2. Event names appear only when needed to understand conflict/capacity.
3. Memory references must be inspectable.
4. Source labels must be concrete, not AI-branded.
5. Manual fallback must remain visible.

## Receipt Anatomy

Receipts are calm proof that something changed.

Every meaningful receipt contains:

1. action
2. source when relevant
3. affected object
4. time/reference
5. user control
6. undo/review where relevant

Receipt object label:

```text
Receipt
```

Archive destination inside You:

```text
Receipts & History
```

## Receipt Tone

Receipts are:

- calm proof
- quiet
- inspectable
- accessible
- dismissible
- archived when meaningful

Receipts are not:

- notifications
- alerts
- achievements
- streaks
- celebrations
- activity feed
- confetti
- guilt
- AI logs

## Receipt Examples

```text
Receipt
Still Counts saved.
```

```text
Receipt
Week shaped · You approved this.
```

```text
Receipt
Protected time preserved.
```

```text
Receipt
Capture placed in Music.
```

```text
Receipt
Goal thread connected to Today.
```

```text
Receipt
Source unavailable · Manual planning remains available.
```

## Closure Thesis

Closure is not completion policing. Closure is how Ambitions respects reality.

A prior open step does not become overdue by default. It becomes a calm closure prompt.

Primary closure copy:

```text
Needs closure
Still counts, move it, or let it go.
```

Supported closure states:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

Forbidden closure language:

- failed
- overdue
- overdue again
- you missed it
- streak broken
- productivity dropped
- get back on track
- catch up

## Closure Patterns

### Still Counts

Use when partial progress is real.

```text
Still counts
You made progress. Close the loop without changing the plan.
```

### Moved

Use when the user intentionally moves the step.

```text
Moved
This has a new place in Time.
```

### Skipped / Not Needed

Use when the step no longer matters.

```text
Not needed
Removed from Today without marking it as failure.
```

### Waiting

Use when the user is waiting on another person/system.

```text
Waiting
No action needed until this comes back.
```

### Blocked

Use when a dependency prevents progress.

```text
Blocked
This needs something else before it can move.
```

### Needs Recovery

Use when the plan needs to become lighter.

```text
Needs recovery
Make today lighter before adding more.
```

## Quiet Reflow Contract

Quiet Reflow handles reality changes.

Flow:

```text
Detect mismatch → Explain source → Preview change → User approves → Receipt
```

Launch cap remains:

1. Manual
2. Suggest
3. Preview Reflow

No silent reflow at launch.

## Trust Before Action Pattern

Any adaptive action must answer:

1. What is suggested?
2. Why now?
3. What source supports it?
4. What can the user change?
5. What receipt will remain?

If these are missing, the action is Yellow or Red.

## Manual Is Respected Pattern

Manual mode is not degraded mode.

Copy:

```text
Manual mode
Ambitions will suggest nothing until you ask.
```

Manual mode must preserve core app value:

- Capture still works
- Goals still work
- Time still supports manual shaping
- Today still supports manual Start Here selection
- You still exposes trust/privacy/defaults

## Trust Debt

If Ambitions suggests or changes something without adequate source/control/receipt, it creates trust debt. Trust debt must be repaired by adding explanation, receipt, user control, or removing the behavior.

## Explanation Debt

Any adaptive UI without Why this? or equivalent explanation is Yellow.

## Receipt Debt

Any meaningful system change without a receipt is Red unless the canon explicitly says no receipt is required.

## Permission Debt

Any permission prompt without immediate visible value is Yellow or Red.

## Trust Hard Reds

Stop and repair if:

1. automation appears before trust
2. recommendation has no source
3. recommendation has no user control
4. meaningful change has no receipt
5. reflow is silent
6. manual mode feels lesser
7. calendar permission is required for core value
8. event names are overexposed
9. memory phrasing feels creepy
10. AI assistant/chrome/chatbot appears
11. source label is vague or AI-branded
12. closure language shames the user
13. receipts become notifications/feed
14. user cannot find Trust & Automation
15. user cannot inspect Receipts & History
