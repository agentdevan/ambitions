# Codex Batch Prompt — T-C: Private Life Runtime Proof

## Objective

Prove the local deterministic runtime moat with executable tests, replay, receipts, and correction loops.

## Scope

### AMB-FR-011 — Same-intent different-context runtime proof harness

Severity: Critical
Priority: P0
Labels: runtime, moat, proof, testing
Dependencies: AMB-FR-005, AMB-FR-007

Affected files:
- `Native/Ambitions/Runtime`
- `Native/Ambitions/Features/Today`
- `Native/AmbitionsTests/Runtime`

Problem: The core moat must be proven in code, not just docs.

Implementation: Create fixtures with same goal/intent but different local contexts and assert deterministically different Start here outputs with receipts.

Acceptance: Executable proof shows different recommended steps from different local contexts.

Validation: Runtime proof tests, explanation diff artifact, replay artifact.

Rollback: Keep existing Today selection logic as fallback.

### AMB-FR-012 — Deterministic planner rule-engine upgrade

Severity: High
Priority: P0
Labels: runtime, planning, deterministic, local-first
Dependencies: AMB-FR-011

Affected files:
- `Native/Ambitions/Domain/Planning`
- `Native/Ambitions/Runtime`
- `Native/AmbitionsTests/Runtime`

Problem: Planning heuristics need to be deeper than lexical or shallow priority matching.

Implementation: Build inspectable local rules using context vectors, user defaults, closure evidence, time fit, confidence, fallback reasons, and deterministic traces.

Acceptance: Planner output is local, deterministic, inspectable, and context-aware.

Validation: Golden plan tests, edge-case fixtures, no-network assertion, explanation trace tests.

Rollback: Keep current planner as deterministic fallback.

### AMB-FR-013 — Today runtime replay and receipt inspector

Severity: High
Priority: P1
Labels: today, runtime, receipts, trust
Dependencies: AMB-FR-011, AMB-FR-012

Affected files:
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Runtime`
- `Native/Ambitions/Persistence`

Problem: Start here recommendations need inspectable proof and replay evidence.

Implementation: Add receipt/proof drawer with inputs, freshness, local-only source boundaries, time fit, alternatives rejected, and closure/recovery effects.

Acceptance: Every Start here recommendation has inspectable proof and replay test coverage.

Validation: Today UI tests, runtime replay tests, receipt snapshot tests.

Rollback: Expose inspector behind internal flag until stable.

### AMB-FR-014 — User correction loop for runtime trust

Severity: High
Priority: P1
Labels: runtime, you, trust, feedback
Dependencies: AMB-FR-010, AMB-FR-013

Affected files:
- `Native/Ambitions/Features/You`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Runtime`

Problem: A personal life OS needs corrections that change future behavior without cloud dependence.

Implementation: Add correction flows for wrong reason, wrong context, wrong capacity, unavailable, still counts, blocked, waiting, and recovery needed.

Acceptance: Corrections change future local recommendations and generate receipts.

Validation: Correction loop tests, no-network tests, accessibility flow tests.

Rollback: Persist corrections separately until behavior is proven.

## Batch rules

- Keep the batch scoped to listed issues.
- Do not use generic task-manager terminology.
- Do not use cloud/external LLMs as core runtime architecture.
- Add or update tests before declaring Green.
- Add proof artifacts under `docs/audits/flagship-remediation/`.
- End with summary, files changed, validation, proof artifacts, risks, rollback path, and Green / Yellow / Red status.
