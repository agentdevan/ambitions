# ADR-2026-06-22 — Runtime Remediation Canon and Codex Dossier System

**Status:** Accepted  
**Date:** 2026-06-22  
**Decision owner:** Ambitions product / design / QA / repo governance  
**Related Linear project:** `Ambitions Runtime QA Remediation — 2026-06-22 Device Review`

## Context

The 2026-06-22 on-device runtime review found that Ambitions’ current implementation still had release-blocking issues across Today, Capture, Goals, Time, You, Search, Shell, Light Mode, and proof/accessibility readiness.

The review was installed into Linear as a runtime QA remediation project with parent trains, execution bundles, QA leaves, milestones, evidence references, and proof gates. That made Linear usable for tracking, but Linear issue bodies alone are not a safe implementation authority for Codex. Codex needs product behavior, visual law, runtime-state law, deletion law, proof law, and status ceiling made explicit before implementation.

## Decision

Install a repo-backed remediation canon and Codex dossier system.

The repo owns canonical implementation law for the remediation run:

- `docs/truth/2026-06-22-runtime-remediation-decision-register.md`
- `docs/qa/remediation/2026-06-22-codex-remediation-law.md`
- `docs/qa/remediation/dossiers/*.md`

Linear remains the operational tracker for state, ownership, dependencies, proof, and owner acceptance. ChatGPT project source remains a compact working-memory layer that points back to repo truth.

Codex must not implement from vague issue titles, broad Linear bodies, or screenshots alone. Codex receives global remediation law first, then one execution-bundle dossier at a time. QA leaf issues are acceptance criteria, not design prompts.

## Consequences

Positive:

- Reduces Codex improvisation and plausible-but-wrong fixes.
- Keeps product truth in the repo instead of Linear comments.
- Gives every execution bundle a status ceiling and proof matrix.
- Preserves traceability from runtime evidence to issue register to implementation dossier to closeout proof.
- Prevents source-only closure of runtime-visible defects.

Costs:

- More upfront documentation before the first code train.
- Every bundle requires a dossier and proof packet.
- Dossiers must be maintained when canon changes.

## Non-negotiable closeout law

An implementation train may not be marked Done from source changes alone.

Codex may move a bundle to In Review when scoped implementation, tests/audits, and required proof artifacts are present. Owner acceptance is required for Done. `docs/qa/KNOWN_ISSUES.md` must be updated for every affected issue row.

## Status ceiling

```text
No validation = Red
Source/test only = Source Green / Runtime Yellow max
Simulator-only visual proof = Visual Yellow max
Device screenshot/video + tests + docs update = Candidate Runtime/Visual Green
Owner acceptance = Done
```
