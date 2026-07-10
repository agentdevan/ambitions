# Article 26 — Swift concurrency and isolation

## CONCURRENCY-001 — Explicit isolation ownership

Every mutable subsystem has one documented isolation owner. UI presentation runs on `@MainActor`; storage, event journal, projection materialization, search indexing, CloudKit reconciliation, attachment processing, and external-write coordination use dedicated isolation appropriate to their responsibilities.

## CONCURRENCY-002 — Main-actor budget

Planning, recurrence expansion, search rebuild, import scanning, hashing, migrations, backup/restore, CloudKit merge, and projection rebuild may not perform material work on the main actor.

## CONCURRENCY-003 — Sendable integrity

Cross-isolation values are immutable and `Sendable`. `@unchecked Sendable` requires a written invariant, narrow scope, concurrency tests, and explicit review.

## CONCURRENCY-004 — Structured task ownership

Unowned fire-and-forget tasks are forbidden. Every asynchronous task has:

- lifecycle owner,
- cancellation path,
- error destination,
- bounded resource use,
- observability,
- test coverage.

`Task.detached` requires explicit architectural justification.

## CONCURRENCY-005 — Cancellation

Long-running import, migration, rebuild, backup, restore, sync, attachment, and planning operations define cancellation checkpoints and cleanup. Cancellation may not leave canonical state half-committed.

## CONCURRENCY-006 — Reentrancy safety

Actor-isolated transactional code may not suspend between invariant-sensitive writes unless the protocol explicitly uses a staged transaction with conflict revalidation.

## CONCURRENCY-007 — Clock injection

Business logic receives an injected clock and time-zone provider. Tests may advance time deterministically. Direct uncontrolled wall-clock reads are forbidden inside planning, recurrence, deadline, recovery, and replay policy.

## CONCURRENCY-008 — Backpressure

Queues for events, projections, notifications, imports, attachments, sync, and diagnostics are bounded and observable. Unbounded task creation or buffered growth is Red.

## CONCURRENCY-009 — Race proof

Required evidence includes concurrency stress tests, duplicate-command tests, cancellation tests, stale read-set tests, repeated replay under concurrent reads, and sanitizer lanes where supported.

---
