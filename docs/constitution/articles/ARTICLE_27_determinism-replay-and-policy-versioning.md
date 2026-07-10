# Article 27 — Determinism, replay, and policy versioning

## DETERMINISM-001 — Deterministic decisions

Equivalent canonical inputs, policy version, user rules, clock, and seed produce equivalent decisions. Collection iteration order, process scheduling, and hash randomization may not alter accepted product behavior.

## DETERMINISM-002 — Causal identity and ordering

Commands, events, transactions, receipts, and external effects carry stable correlation and causal identifiers. Equal timestamps do not determine order by themselves.

## DETERMINISM-003 — Idempotency

Every externally repeatable mutation path supports an idempotency key or equivalent duplicate detector, including notification actions, App Intents, widgets, Share intake, imports, sync retries, and relaunch recovery.

## DETERMINISM-004 — Replay equivalence

Replaying durable history must reproduce logically equivalent canonical state and projections. External effects are not automatically reissued during ordinary replay.

## DETERMINISM-005 — Policy version capture

Every fit, placement, reflow, path-generation, recovery, proof, and learned-behavior decision records the policy identifier/version required to explain historical behavior.

## DETERMINISM-006 — Seeded randomness

Legitimate random behavior uses an injected, recorded seed. Unrecorded randomness may not affect canonical decisions.

## DETERMINISM-007 — Golden replay corpus

The repo maintains a versioned corpus of historical and synthetic event streams. A release-changing runtime or persistence policy must prove replay compatibility or provide an explicit migration.

---
