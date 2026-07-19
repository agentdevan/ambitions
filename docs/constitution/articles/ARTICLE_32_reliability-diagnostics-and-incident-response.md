# Article 32 — Reliability, diagnostics, and incident response

## RELIABILITY-001 — Failure taxonomy

Ambitions classifies data loss, corruption, crash, hang, failed mutation, failed projection, stale UI, external-write failure, sync conflict, partial import, privacy breach, and visual/accessibility regression by severity and stop-ship posture.

## RELIABILITY-002 — Structured diagnostics

Logs use stable categories, privacy annotations, correlation IDs, bounded retention, and signposts. Private content is excluded by default.

## RELIABILITY-003 — Subsystem health

Major subsystems report one of:

```text
healthy / degraded / recoverable / quarantined / blocked / unknown
```

Health is evidence-backed and user-facing only when action or interpretation changes.

## RELIABILITY-004 — Crash and hang response

Release process defines capture, redaction, symbolication, reproduction, severity, regression-test requirement, and rollback/forward-fix decision.

## RELIABILITY-005 — Incident lifecycle

P0/P1 production incidents require containment, diagnosis, owner, repair, validation, user-impact assessment, rollback or kill switch where available, postmortem, and regression prevention.

## RELIABILITY-006 — No silent repair

Any repair that changes canonical state requires preview, backup or rollback protection, receipt, and post-repair invariant verification.

---
