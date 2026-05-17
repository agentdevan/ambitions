Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

# Failure Recovery Policy

Failure handling in Ambitions is explicit:

- Normal repo doctor collects all failures and keeps going.
- Strict repo doctor exits non-zero when unresolved governance remains.
- Next-action routing must turn Red into a repair command.
- Authorized batch wrapper must surface governance Red clearly.
- Repair commands must target the smallest failing seam first.

Recovery classes:

- Governance repair
- Canon propagation repair
- Prompt rewrite repair
- Frontend authority repair
- Encyclopedia repair
- Global train sequencing repair
- Proof / closeout repair
- Archive / shrink repair
- Implementation safety repair

When the failure is ambiguous, prefer the narrower repair that restores truth without widening scope.
