---
name: ambitions-runtime-persistence
description: Use for Ambitions Private Life Runtime, deterministic local decisions, receipts, replay, SwiftData migration, export/delete/reset, account/R2 boundaries, and persistence safety.
---

# Ambitions Runtime Persistence

## Authority Boundary

Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Cross-surface behavior: Motion
Trust inspection: Proof / Source / Privacy / History / Receipts
```

`Capture` is not a tab. `Motion` is not a tab or destination; it is Stage/Motion behavior. `Plan`, `Profile`, `Captures`, and `Pulse` may appear only as historical or compatibility seams unless an active truth-file-scoped migration changes them.

## Account / R2 Boundary

Ambitions supports optional launch Ambitions Accounts using Sign in with Apple and Google Sign-In. The core app must remain fully usable offline with no account.

Ambitions Account may support identity, entitlements, R2 reference/freshness access, account recovery/support, and future paid identity features.

Ambitions Account must not store the private life graph unless future canon explicitly approves a user-owned sync architecture.

R2/Source Atlas is public/reference/freshness infrastructure only. R2 must not receive goals, captures, calendar context, closures, proof, receipts, personalization, inferred priorities, private user context, or the private life graph.

## Hard Stops

Stop for:

- required cloud AI/LLM core behavior
- hosted AI service core dependency
- hosted personal-data backend
- private life graph backend
- R2 private user data path
- account sign-in required for core local value
- analytics/tracking SDKs without approval
- privacy manifest dishonesty
- release/App Store/TestFlight/device/accessibility/performance/account/R2 claims without evidence
- Motion as top-level IA
- Capture as top-level IA
- Plan/Profile/Captures/Pulse as active top-level IA
- broad staging
- destructive cleanup without indexed approval
- dashboard/chatbot/calendar clone/task manager/habit tracker drift

## Runtime Rule

The moat is the Private Life Runtime: local, deterministic, inspectable, capacity-aware decisions with receipts, replay, closure, proof, and recovery. Do not add opaque ranking, required cloud AI, hosted personal intelligence, or uninspectable learning.

## Workflow

1. Inspect runtime/domain/persistence boundaries before changing behavior.
2. Require deterministic fixtures for recommendation, compilation, closure, recovery, and replay changes.
3. Prefer existing receipt/event ledgers before new schema.
4. Do not make destructive SwiftData changes without migration fixtures and rollback behavior.
5. For export/delete/reset, require confirmation, failure recovery, and proof-bound UI status.
6. For account work, prove offline core still works without sign-in.
7. For R2/Source Atlas work, prove no private user context enters requests.
8. For sync work, require future-canon approval plus conflict, tombstone, delete, export, rollback, and privacy proof.
