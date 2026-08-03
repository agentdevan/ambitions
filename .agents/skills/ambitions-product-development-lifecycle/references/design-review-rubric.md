# Design review rubric

## Content review

Confirm every material `DESIGN-*` decision maps to requirements, acceptance,
verification, owner layer, and relevant recovery. Confirm native interaction,
state, object ownership, persistence, migration, concurrency, replay, privacy,
accessibility, proof, performance, seams, legacy deletion, and canon deltas are
bounded. Confirm declared owner paths cover every material repository, canon,
source, test, and evidence dependency.

## Codex consumption review

Confirm canon reconciliation and implementation grooming can proceed from the
summary and linked sections without product invention. Verify committed inputs,
seal binding, freshness, traceability, authority boundary, and undeclared
canon/source conflicts.

## Required output

`Verdict: PASS | NEEDS REVISION`
`Review lane: CONTENT | CONSUMER`
`Review ID: REV-<LANE>-<NUMBER>`
`Reviewed revision: <integer>`
`Reviewed contract hash: sha256:<hash>`

Then state Blocking findings, Non-blocking improvements, Traceability gaps,
Stale or conflicting inputs, Required revisions, and Next permitted lifecycle
phase. A PASS has no blocking finding.
