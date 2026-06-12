# PLOS Phase Gate Template

Use this template when opening or closing a PLOS phase. Fill it with evidence; do not use it as proof by itself.

## Phase

- Phase label: `PLOS-M##`
- Linear issue: `AMB-###`
- Linear title:
- Parent/child binding source:
- Previous phase status:
- Current branch:
- Base SHA:

## Scope

- Allowed files:
- Explicitly forbidden files:
- Runtime features authorized: yes/no
- Source Atlas changes authorized: yes/no
- UI changes authorized: yes/no

## Required Reads

- Truth files:
- PLOS artifacts:
- Active Linear issue:
- Live source/tests/scripts:
- Source Atlas artifacts if relevant:

## Validation

- Preflight: `scripts/codex/program-preflight.sh plos`
- Phase gate: `scripts/codex/program-phase-gate.sh plos M##`
- Focused build/test/script commands:
- Reviewer prompts:
- Closeout validator:

## Proof Boundary

- Verified:
- Failed:
- Not verified:
- Blocked:
- Human/device follow-up:

## Gate Verdict

Green only if the phase is AMB-bound, in order, validated, scoped, and proof-backed.

Yellow only if missing proof is named, owned, non-blocking, and carries a no-claim boundary.

Red if synthetic issue drift, phase-order violation, runtime overreach, privacy/source/safety drift, or false readiness claim is present.
