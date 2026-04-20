# Ambitions Codex Batch Plan

## Status

Ambitions 1.0 is complete through registry Batch 18. Those batches remain completed historical foundation work and must not be renumbered, erased, or rewritten into a new numbering system.

The currently queued Ambitions 2.0 execution wave is complete through registry Batch 34. It began at registry Batch 19, continued the existing operational numbering, and must not be extended by inventing a normal Batch 35 inside this exhausted registry wave.

The next repo step is a post-2.0 whole-repo/app hardening and product-audit planning pass. Any future implementation wave should be planned explicitly before new registry entries are added.

Work on `main` only unless the user explicitly requests branch-based work.

## How to Use This Plan

Use three layers of context, not one giant prompt every time.

### Layer 1 — Persistent Repo Context

Use `AGENTS.md` and `docs/codex/CONTEXT_INDEX.md` for:

- source-of-truth order
- architecture boundaries
- main-only execution rule
- one-batch-at-a-time rule
- branch, validation, and completion expectations

### Layer 2 — Canon Context

Use the canonical planning stack in-place:

- `MASTER_PRODUCT_SPEC.md`
- `docs/canon/Ambitions_OS_Master_Roadmap.md`
- `docs/canon/Ambitions_Surgical_Execution_Plan.md`
- `docs/canon/Ambitions_Codex_Batch_Plan.md`
- `docs/codex/BATCH_REGISTRY.md`

Do not create parallel canon docs or duplicate planning stacks.

### Layer 3 — Per-Batch Prompt

For each Codex task, send only:

- active batch name and status
- goal
- in-scope and out-of-scope items
- dependency rules
- exact files/folders in scope
- required validation
- completion rule

Keep prompts deterministic, repo-oriented, and tightly scoped.

## Operating Rules

1. One batch at a time.
2. Do not start Batch N+1 while Batch N is active or unstable.
3. Keep old Ambitions 1.0 history completed and intact.
4. Build foundations before surfaces.
5. Do not add UI for engines/contracts that do not exist.
6. Do not add retrieval-backed recommendations before provenance and freshness exist.
7. Do not add opaque AI behavior before correction and explainability exist.
8. Shared logic belongs in domain/services/runtime boundaries, not product surfaces.
9. Tests and validation are part of the batch.
10. Update the registry only after validation or explicit user decision.
11. Work on `main` only unless the user explicitly requests branch-based work.
12. Do not create, switch to, or suggest branches for the standard program.

## Completed Foundation: Ambitions 1.0

Registry Batch 00 through Batch 18 are completed foundation work. They established the native app, domain and planning foundations, capture core, recovery/time orchestration, external action and ambient surfaces, ritual loops, sync-trust boundary, life graph/path systems, learning, shared-life intelligence, runtime separation, and a constrained dedicated-device prototype seam.

This completed history is preserved in `docs/codex/BATCH_REGISTRY.md`.

## Ambitions 2.0 Forward Program

### Batch 19 — Ambitions 2.0 Batch 00 / Canon Reset

Goal:

- establish Ambitions 2.0 as the active canon program while preserving Ambitions 1.0 history

In scope:

- canon roadmap reset
- surgical execution reset
- batch plan reset
- registry seeding
- active Batch 19 file
- AGENTS/context index truth alignment

Acceptance:

- canonical file paths remain unchanged
- Batch 00-18 remain completed
- Batch 19 is active
- Batch 20-34 are queued
- no product/runtime Swift code changes

### Batch 20 — Ambitions 2.0 Batch 01 / Knowledge Provider Boundary

Goal:

- define provider, provenance, freshness, trust, and uncertainty contracts for external knowledge

Acceptance:

- retrieval providers are abstracted behind testable boundaries
- retrieved claims cannot exist without source and freshness metadata

### Batch 21 — Ambitions 2.0 Batch 02 / External Knowledge Ingestion Core

Goal:

- ingest external knowledge through the provider boundary and normalize it into auditable claims/resources

Acceptance:

- ingestion is deterministic
- stale, unknown, or low-trust inputs are preserved as such instead of promoted

### Batch 22 — Ambitions 2.0 Batch 03 / Clarification and Ambiguity Engine

Goal:

- detect ambiguity in life goals and produce structured clarification needs

Acceptance:

- ambiguous inputs produce explicit clarification prompts
- user answers can resolve or update the ambiguity model

### Batch 23 — Ambitions 2.0 Batch 04 / Generalized Goal Understanding Contracts

Goal:

- create stable goal-understanding outputs for domain, constraints, readiness, risk, and missing information

Acceptance:

- path compilation can consume goal-understanding contracts without parsing product copy

### Batch 24 — Ambitions 2.0 Batch 05 / Path Compiler Foundation

Goal:

- compile understood goals into staged path candidates with dependencies, assumptions, risks, and fallback branches

Acceptance:

- path outputs are structured and testable
- no product path UX is required to prove the compiler

### Batch 25 — Ambitions 2.0 Batch 06 / Domain Pack Framework

Goal:

- let domain packs contribute requirements, resources, risks, and readiness criteria to the compiler

Acceptance:

- domain intelligence is modular, inspectable, and testable

### Batch 26 — Ambitions 2.0 Batch 07 / Resource Graph and Source Ranking

Goal:

- connect path stages to ranked resources and source entities

Acceptance:

- resource ranking includes trust/provenance signals
- resource links remain auditable

### Batch 27 — Ambitions 2.0 Batch 08 / Update and Freshness Engine

Goal:

- detect stale knowledge/resource chains and propagate freshness changes into rankings and explanations

Acceptance:

- stale evidence can be downgraded or flagged
- update status is visible to downstream services

### Batch 28 — Ambitions 2.0 Batch 09 / Energy Model Foundation

Goal:

- define energy and capacity contracts as effort fit, focus fit, recovery state, and sustainable pacing

Acceptance:

- no fake biometric claims
- path/task ranking can consume shared capacity outputs

### Batch 29 — Ambitions 2.0 Batch 10 / Energy Learning and Ranking

Goal:

- learn energy/capacity fit from behavior and explicit user feedback, then use it in recommendation ranking

Acceptance:

- ranking can prefer sustainable fit over raw urgency
- learning signals remain user-correctable

### Batch 30 — Ambitions 2.0 Batch 11 / Contradiction Engine

Goal:

- detect contradictions between user goals, behavior, retrieved requirements, plans, and system assumptions

Acceptance:

- contradictions are represented structurally and can be explained

### Batch 31 — Ambitions 2.0 Batch 12 / Correction and Teaching Loop

Goal:

- let users correct assumptions, source judgments, path decisions, and energy-fit guesses

Acceptance:

- corrections become durable teaching signals
- future interpretation/ranking uses those corrections

### Batch 32 — Ambitions 2.0 Batch 13 / Explainability and Source Audit Surfaces

Goal:

- expose why-this explanations, source audit, freshness, confidence, and correction controls

Acceptance:

- recommendations distinguish source facts, memory, inference, uncertainty, and assumptions

### Batch 33 — Ambitions 2.0 Batch 14 / Intelligence Runtime Integration

Goal:

- integrate 2.0 intelligence services behind stable runtime contracts

Acceptance:

- runtime consumers receive source-aware, correctable, trust-controlled outputs
- no product surface duplicates intelligence logic

### Batch 34 — Ambitions 2.0 Batch 15 / Ambitions 2.0 Product Shell Integration

Goal:

- integrate path, resource, energy, correction, and explanation experiences into the product shell

Acceptance:

- shell surfaces consume stable service/runtime outputs
- user-facing behavior is explainable, correctable, and source-aware

## Batch Prompt Template

```text
You are working in the Ambitions repo.

Work on main only. Do not create, switch to, or suggest branches.

Follow AGENTS.md and the canonical planning stack, but only implement the active batch below. Do not skip ahead. Do not opportunistically add later-batch features. Preserve Ambitions 1.0 completed history.

ACTIVE BATCH: [name]

BATCH GOAL:
[one paragraph]

IN SCOPE:
- [item]

OUT OF SCOPE:
- [item]

DEPENDENCY RULES:
- [batch-specific rule]

FILES / AREAS TO TOUCH:
- [paths]

REQUIRED VALIDATION:
- [commands]

DELIVERABLES:
- implementation
- tests or docs validation
- concise change summary

First, inspect the repo and provide a brief implementation plan for this batch only when the batch is risky or multi-file.
```

## Completion Rule

An Ambitions 2.0 batch is complete only when:

- the implementation matches the active batch scope
- later batches were not started
- validation was run and reported truthfully
- registry status is updated only after validation or explicit user decision
- the checked-out branch remains `main`
