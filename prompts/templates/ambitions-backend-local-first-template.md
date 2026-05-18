<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Backend Local-First Template

This template is for local durability, receipts, and data-flow repairs that
must preserve the local-first posture.

## Batch ID

`<BATCH_ID>`

## Type

`repair`

## Local-first invariants

- local store is primary
- no custom server dependency unless explicitly scoped
- deterministic recommendation behavior remains inspectable
- Apple continuity is considered when relevant
- receipts remain inspectable
- mutations remain durable
- privacy claims remain honest

## Projection ownership

<State which module owns the projection or persistence seam.>

## Validation

- exact unit or integration tests
- exact logs or proof artifacts
- exact claim boundaries
