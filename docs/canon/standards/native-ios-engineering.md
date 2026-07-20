+++
spec_id = "STANDARD-NATIVE-IOS-ENGINEERING"
title = "Native iOS Engineering"
kind = "standard"
status = "normative"
owner_domain = "standard-native-ios-engineering"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "engineering.concurrency.isolation",
  "engineering.concurrency.main-actor",
  "engineering.concurrency.sendable",
  "engineering.concurrency.tasks",
  "engineering.concurrency.cancellation",
  "engineering.concurrency.reentrancy",
  "engineering.concurrency.clock",
  "engineering.concurrency.backpressure",
  "engineering.concurrency.race-proof",
  "engineering.determinism.decisions",
  "engineering.determinism.causal-order",
  "engineering.determinism.idempotency",
  "engineering.determinism.replay",
  "engineering.determinism.policy-version",
  "engineering.determinism.randomness",
  "engineering.determinism.golden-corpus",
  "engineering.lifecycle.scene",
  "engineering.lifecycle.system-change",
  "engineering.lifecycle.background",
  "engineering.lifecycle.extension",
]
inherits = ["LAW-LOCAL-AUTHORITY-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PERSISTENCE-REPLAY"]
source_owners = ["Native/Ambitions/App/", "Native/Ambitions/Core/LocalRuntimeOS/", "Native/Ambitions/Quality/"]
+++

# Native iOS Engineering

This standard consolidates cross-cutting native engineering law.

## CONCURRENCY-001 — Explicit isolation ownership
- **Concept:** `engineering.concurrency.isolation`
- **Modality:** `MUST`
- **Scope:** Mutable native subsystems
- **Status:** `normative`
- **Verification:** `TEST-CONCURRENCY-ISOLATION-001`
- **Supersedes:** none

Every mutable subsystem MUST have one documented isolation owner. Presentation uses `@MainActor`; storage, journals, projections, indexing, continuity, attachments, and external-effect coordination use responsibility-appropriate isolation.

UI presentation MUST run on `@MainActor`; storage, event journal, projection materialization, Search indexing, CloudKit reconciliation, attachment processing, and external-write coordination MUST use dedicated isolation appropriate to their responsibilities.

## CONCURRENCY-002 — Main-actor budget
- **Concept:** `engineering.concurrency.main-actor`
- **Modality:** `MUST NOT`
- **Scope:** Material planning, recurrence, indexing, import, hashing, migration, backup, restore, merge, and rebuild work
- **Status:** `normative`
- **Verification:** `TEST-MAIN-ACTOR-BUDGET-001`
- **Supersedes:** none

Material non-presentation work MUST NOT execute on the main actor.

## CONCURRENCY-003 — Sendable integrity
- **Concept:** `engineering.concurrency.sendable`
- **Modality:** `MUST`
- **Scope:** Cross-isolation values
- **Status:** `normative`
- **Verification:** `TEST-SENDABLE-INTEGRITY-001`
- **Supersedes:** none

Cross-isolation values MUST be immutable and `Sendable`; any `@unchecked Sendable` use requires a narrow written invariant, concurrency tests, and explicit review.

## CONCURRENCY-004 — Structured task ownership
- **Concept:** `engineering.concurrency.tasks`
- **Modality:** `MUST`
- **Scope:** Asynchronous task creation
- **Status:** `normative`
- **Verification:** `AUDIT-STRUCTURED-TASKS-001`
- **Supersedes:** none

Every asynchronous task MUST have a lifecycle owner, cancellation path, error destination, bounded resources, observability, and tests. Unowned fire-and-forget work is forbidden; detached work requires architectural justification.

Unowned fire-and-forget tasks MUST NOT occur.

Every asynchronous task MUST have a lifecycle owner, cancellation path, error destination, bounded resource use, observability, and test coverage.

## CONCURRENCY-005 — Cancellation safety
- **Concept:** `engineering.concurrency.cancellation`
- **Modality:** `MUST`
- **Scope:** Long-running local or optional-network work
- **Status:** `normative`
- **Verification:** `TEST-CANCELLATION-SAFETY-001`
- **Supersedes:** none

Long work MUST provide cancellation checkpoints and cleanup, and cancellation MUST NOT expose a partial canonical commit.

Long-running import, migration, rebuild, backup, restore, sync, attachment, and planning operations MUST define cancellation checkpoints and cleanup.

Cancellation MUST NOT leave canonical state half-committed.

## CONCURRENCY-006 — Reentrancy safety
- **Concept:** `engineering.concurrency.reentrancy`
- **Modality:** `MUST NOT`
- **Scope:** Invariant-sensitive actor transactions
- **Status:** `normative`
- **Verification:** `TEST-REENTRANCY-001`
- **Supersedes:** none

Invariant-sensitive code MUST NOT suspend between dependent writes unless an explicit staged protocol revalidates conflicts before commit.

## CONCURRENCY-007 — Injected temporal context
- **Concept:** `engineering.concurrency.clock`
- **Modality:** `MUST`
- **Scope:** Planning, recurrence, deadline, recovery, and replay policy
- **Status:** `normative`
- **Verification:** `TEST-INJECTED-CLOCK-001`
- **Supersedes:** none

Business policy MUST receive an injectable clock, calendar, locale, and time-zone context; uncontrolled wall-clock reads MUST NOT decide canonical behavior.

Business logic MUST receive an injected clock and time-zone provider.

Tests MAY advance time deterministically.

Planning, recurrence, deadline, recovery, and replay policy MUST NOT read the wall clock directly without an injected temporal provider.

## CONCURRENCY-008 — Bounded backpressure
- **Concept:** `engineering.concurrency.backpressure`
- **Modality:** `MUST`
- **Scope:** Event, projection, notification, import, attachment, sync, and diagnostic queues
- **Status:** `normative`
- **Verification:** `TEST-BACKPRESSURE-001`
- **Supersedes:** none

Queues and buffers MUST be bounded and observable; unbounded task creation or buffered growth is P0 Red.

Queues for events, projections, notifications, imports, attachments, sync, and diagnostics MUST be bounded and observable.

## CONCURRENCY-009 — Race proof
- **Concept:** `engineering.concurrency.race-proof`
- **Modality:** `MUST`
- **Scope:** Concurrent mutation and read paths
- **Status:** `normative`
- **Verification:** `TEST-RACE-PROOF-001`
- **Supersedes:** none

Changed concurrent paths MUST have applicable stress, duplicate-command, cancellation, stale-read, replay-under-read, and sanitizer evidence.

## DETERMINISM-001 — Deterministic decisions
- **Concept:** `engineering.determinism.decisions`
- **Modality:** `MUST`
- **Scope:** Canonical decisions
- **Status:** `normative`
- **Verification:** `TEST-DETERMINISM-001`
- **Supersedes:** none

Equivalent canonical inputs, policy version, user rules, temporal context, and seed MUST produce equivalent decisions independent of collection order, process scheduling, or hash randomization.

Collection iteration order, process scheduling, and hash randomization MUST NOT alter accepted product behavior.

## DETERMINISM-002 — Causal identity and ordering
- **Concept:** `engineering.determinism.causal-order`
- **Modality:** `MUST`
- **Scope:** Commands, events, transactions, receipts, and external effects
- **Status:** `normative`
- **Verification:** `TEST-CAUSAL-ORDER-001`
- **Supersedes:** none

Durable operations MUST carry stable correlation and causal identity; equal timestamps MUST NOT decide ordering alone.

## DETERMINISM-003 — Idempotency
- **Concept:** `engineering.determinism.idempotency`
- **Modality:** `MUST`
- **Scope:** Every externally repeatable mutation entry
- **Status:** `normative`
- **Verification:** `TEST-IDEMPOTENCY-001`
- **Supersedes:** none

Notification, App Intent, widget, Share, import, continuity retry, deep-link, and relaunch paths MUST reject or reconcile duplicate accepted intent through stable idempotency identity.

## DETERMINISM-004 — Replay equivalence
- **Concept:** `engineering.determinism.replay`
- **Modality:** `MUST`
- **Scope:** Durable history replay
- **Status:** `normative`
- **Verification:** `TEST-REPLAY-EQUIVALENCE-001`
- **Supersedes:** none

Replay MUST reproduce logically equivalent canonical state and projections and MUST NOT reissue external effects during ordinary replay.

## DETERMINISM-005 — Policy version capture
- **Concept:** `engineering.determinism.policy-version`
- **Modality:** `MUST`
- **Scope:** Fit, placement, reflow, path, recovery, proof, and learning decisions
- **Status:** `normative`
- **Verification:** `TEST-POLICY-VERSION-001`
- **Supersedes:** none

Every material decision MUST retain the policy identity required to explain historical behavior.

Every fit, placement, reflow, path-generation, recovery, proof, and learned-behavior decision MUST record the policy identifier/version required to explain historical behavior.

## DETERMINISM-006 — Seeded randomness
- **Concept:** `engineering.determinism.randomness`
- **Modality:** `MUST`
- **Scope:** Random behavior affecting canonical results
- **Status:** `normative`
- **Verification:** `TEST-SEEDED-RANDOMNESS-001`
- **Supersedes:** none

Randomness affecting canonical results MUST use an injected recorded seed.

Unrecorded randomness MUST NOT affect canonical decisions.

## DETERMINISM-007 — Golden replay corpus
- **Concept:** `engineering.determinism.golden-corpus`
- **Modality:** `MUST`
- **Scope:** Runtime and persistence policy changes
- **Status:** `normative`
- **Verification:** `TEST-GOLDEN-REPLAY-001`
- **Supersedes:** none

The repo MUST retain privacy-safe versioned historical and synthetic event streams; incompatible policy changes require explicit migration and replay proof.

## LIFECYCLE-001 — Scene transitions
- **Concept:** `engineering.lifecycle.scene`
- **Modality:** `MUST`
- **Scope:** Cold/warm launch, background, foreground, reconnect, termination, and memory pressure
- **Status:** `normative`
- **Verification:** `TEST-SCENE-LIFECYCLE-001`
- **Supersedes:** none

Every supported transition MUST define draft, transaction, projection, and external-reconciliation behavior.

## LIFECYCLE-002 — System-change reconciliation
- **Concept:** `engineering.lifecycle.system-change`
- **Modality:** `MUST`
- **Scope:** Time-zone, significant-time, locale, calendar, notification, iCloud-account, and protected-data changes
- **Status:** `normative`
- **Verification:** `TEST-SYSTEM-CHANGE-001`
- **Supersedes:** none

System changes MUST trigger deterministic, idempotent reconciliation through canonical owners.

## LIFECYCLE-003 — Background limits
- **Concept:** `engineering.lifecycle.background`
- **Modality:** `MUST`
- **Scope:** Background execution
- **Status:** `normative`
- **Verification:** `TEST-BACKGROUND-LIMITS-001`
- **Supersedes:** none

Background work MUST be bounded, cancellable, idempotent, privacy-safe, and resumable without assuming completion.

Relaunch MUST resume or reconcile background work safely.

## LIFECYCLE-004 — Extension handoff
- **Concept:** `engineering.lifecycle.extension`
- **Modality:** `MUST`
- **Scope:** Widgets, Share, App Intents, notification actions, and Live Activity handoffs
- **Status:** `normative`
- **Verification:** `TEST-EXTENSION-HANDOFF-001`
- **Supersedes:** none

Extension handoffs MUST preserve command identity, minimum data, timeout behavior, local authority, and safe fallback.

<!-- canon-section: purpose -->
Provide one cross-cutting native execution contract for isolation, determinism, lifecycle, and platform handoff.

<!-- canon-section: scope -->
Applies to native iPhone source and extensions; product meaning, object lifecycle, and system policy remain with their exact Atlas owners.

<!-- canon-section: requirements -->
The stable requirements above consolidate useful Articles 26, 27, and 40 without preserving article topology.

<!-- canon-section: exceptions -->
An exception requires a narrow technical rationale with safety, privacy, accessibility, performance, test, migration, and rollback impact; convenience is insufficient.

<!-- canon-section: verification -->
Verify through compiler audit plus applicable concurrency, replay, lifecycle, extension, cancellation, stress, and sanitizer lanes.

<!-- canon-section: source-ownership -->
Target ownership is `App/`, exact `Core/LocalRuntimeOS/` subsystem owners, and `Quality/`;

<!-- canon-section: proof -->
Verification includes isolation analysis, concurrency/replay/lifecycle/extension test results, deterministic fixtures, and sanitizer output where applicable.

<!-- canon-section: amendment-impact -->
When native execution behavior changes, update affected requirements, source, tests, data classes, extensions, migrations, and rollback handling.
