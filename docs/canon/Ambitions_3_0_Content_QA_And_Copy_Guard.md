# Ambitions 3.0 — Content QA And Copy Guard

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Language system: [Ambitions 3.0 Product Language System](./Ambitions_3_0_Product_Language_System.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines Codex-only content QA for Ambitions 3.0.

The goal is to remove legacy wording from visible UI, accessibility labels, previews, tests, fixtures, docs, and new code identifiers where practical.

---

## Copy Guard Scope

Scan:

- SwiftUI visible strings
- accessibility labels/hints
- App Intent titles and phrases
- preview fixtures
- UI tests
- snapshot names if user-visible
- docs/canon
- docs/codex
- release notes
- screenshot/demo content

---

## Banned User-Facing Terms

These must not appear in visible UI:

- best next move
- next best move
- Start Focus
- Focus Session
- AI confidence
- productivity score
- overdue
- failed
- behind
- missed
- incomplete
- streak
- profile tab
- insights tab
- habits tab
- task dashboard
- calendar clone

---

## Restricted Terms

These require review:

- Task
- Project
- Inbox
- Focus
- Assistant
- Optimize
- Score
- Streak
- Dashboard

Allowed exceptions:

- Swift concurrency `Task {}`
- imported external task objects when explicitly labeled external
- internal test names that verify legacy migration, if marked compatibility-only

---

## Preferred Replacements

| Avoid | Use |
|---|---|
| Start Focus | Start now |
| Focus Session | Step Session |
| best next move | Recommended step |
| Profile | You |
| Inbox | Needs a Place |
| Task | Step |
| Project | Goal / Path / Ambition |
| AI confidence | Why this / Based on |
| Overdue | Needs closure |
| Failed | Needs recovery / Not completed as planned |
| Missed | Needs a quick check |
| Analytics | Reviews / Receipts / What changed |

---

## Required Grep Patterns

Codex should run or approximate scans for:

```bash
grep -Rni "best next move\|next best move\|Start Focus\|Focus Session\|AI confidence\|productivity score\|overdue\|failed\|behind\|missed\|incomplete\|profile tab\|insights tab\|habits tab" Native docs Sources || true
```

Additional restricted scan:

```bash
grep -Rni "Inbox\|Dashboard\|Optimize\|Assistant\|Streak" Native docs Sources || true
```

---

## QA Rules

A term found in repo is acceptable only if:

1. It is in this doc as a banned/restricted term.
2. It is in migration documentation.
3. It is in a compatibility test with explicit compatibility label.
4. It is part of external API terminology and not visible to users.
5. It is Swift language syntax such as `Task`.

Otherwise, it should be renamed or documented as a known debt.

---

## Microcopy Requirements

Every major surface must define copy for:

- empty state
- first-use state
- save failed
- action succeeded
- undo available
- undo unavailable
- sensitive/private state
- permission unavailable
- recommendation explanation
- closure prompt
- receipt
- proof saved

---

## Accessibility Copy

Accessibility labels must use the same human language as visible UI.

Do not preserve legacy words in accessibility labels.

Examples:

- `Start now, recommended step` not `Start focus`
- `Needs closure` not `Overdue`
- `You destination` not `Profile tab`

---

## Acceptance Criteria

A batch passes content QA when:

- banned visible terms are absent or documented compatibility-only
- replacement terms follow Product Language System
- receipt grammar is consistent
- copy is plain and human
- accessibility labels are updated
- previews and tests do not reintroduce legacy language
- Codex completion summary includes copy guard results
