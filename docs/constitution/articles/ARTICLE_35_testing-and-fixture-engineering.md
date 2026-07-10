# Article 35 — Testing and fixture engineering

## TEST-001 — Required lanes

Applicable work uses unit, property-based, runtime integration, persistence/migration, concurrency, UI, accessibility, visual, performance, security/fuzz, and release lanes.

## TEST-002 — Deterministic fixtures

Fixtures declare schema version, clock, locale, time zone, seed, privacy classification, expected state, and origin. Real private user data is forbidden.

## TEST-003 — Production bug rule

Every reproducible production or pre-release escape receives a regression test or an explicit documented reason why automation is impossible.

## TEST-004 — Failure injection

Critical runtime and persistence work injects failure at every transaction, migration, external-write, sync, attachment, and projection phase.

## TEST-005 — No proof theater

Blind sleeps, retry-until-pass, expected-failure completion, optional lookup that hides failure, and source-string-only UI proof cannot support required Green claims.

## TEST-006 — Property-based priorities

Property-based testing is required for recurrence, time zones, ordering, idempotency, merges, migrations, conversion round trips, and invariant preservation where applicable.

## TEST-007 — Coverage meaning

Coverage percentage is diagnostic only. Required behaviors and failure states must be explicitly mapped to tests and proof.

---
