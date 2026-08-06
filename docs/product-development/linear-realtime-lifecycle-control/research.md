+++
initiative = "linear-realtime-lifecycle-control"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions uses Linear as its execution mirror while repository `main` remains
authoritative for product, architecture, lifecycle documents, implementation
plans, and proof. The workspace has been substantially reconciled, but keeping
it correct still depends on periodic manual inspection. Project phase, Issue
state, dependency readiness, proof status, cycles, views, templates, health,
and exact document mirrors can drift independently and become misleading.

The problem is not a lack of more planning objects. It is the absence of one
deterministic, repository-backed controller that can explain and continuously
repair operational state while retaining durable receipts for every mutation.

## Current truth

This Research inspected repository `main` at
`0c8a7901c0046c5dceb877758e951f5e1b33719f`, current lifecycle documents,
workflow configuration, live Linear metadata, and available Cloudflare
capabilities on 2026-08-05.

- Product-development initiatives use approved Research, Scope, Design, and
  implementation grooming documents under `docs/product-development/<slug>/`.
- Linear already exposes the required ten Issue states and the controlled
  namespaced Issue and Project labels.
- Active lifecycle Projects and Plan-task Issues have repository-backed
  documents and dependency relations, but there is no repository controller
  that proves continued one-to-one fidelity.
- The team has no active cycle and its existing views/templates retain stale
  assumptions from predecessor control planes.
- GitHub integration starts and reviews work automatically, but merge currently
  risks conflating source integration with required proof completion.
- The repository has no Linear webhook receiver, desired-state compiler,
  idempotency ledger, global scheduler, drift command, or automated repair lane.
- An existing Source Atlas Worker is public-reference infrastructure and is the
  wrong privacy and authority boundary for operational control.

No Ambitions private-life graph or app data is required. Inputs are repository
documents, GitHub implementation evidence, and Linear operational metadata.

## Evidence

The current workspace demonstrates that one-time cleanup is insufficient:
object names, exact mirrors, task relations, status, health, cycle placement,
and templates are independently mutable. Linear webhooks can announce changes
but are at-least-once operational signals, so duplicate and reordered delivery
must be expected. GitHub checks provide merge and proof evidence, but they need
a policy layer before becoming lifecycle state. Cloudflare Workers, Queues, a
dead-letter queue, and D1 provide an appropriate small hosted control plane with
durable idempotency and mutation receipts.

The strongest reliability model is reconciliation rather than imperative
scripts: compile desired state from repository authority, read current state,
produce a deterministic diff, apply only valid mutations, and prove convergence
with a second read.

## Alternatives

1. **Continue periodic manual reconciliation.** Lowest implementation cost, but
   drift is detected late and the result cannot be reproduced reliably.
2. **Use GitHub Actions only.** Useful for repository events and scheduled
   checks, but weak for real-time Linear events, durable retries, and a queryable
   mutation ledger.
3. **Use a local CLI only.** Good for diagnosis and emergency repair, but it
   makes workspace freshness depend on one workstation and operator.
4. **Reuse the Source Atlas Worker.** Rejected because public reference serving
   and execution-control authority are distinct trust boundaries.
5. **Create a dedicated shared compiler, CLI, and Cloudflare control plane.**
   Recommended because one rule engine can serve local explanation, CI drift
   checks, webhooks, retries, scheduled reconciliation, and autonomous repair.

## Unknowns and risks

- Linear APIs may expose deletion as Trash rather than immediate physical
  erasure; receipts must report the product's exact observable semantics.
- Webhook schemas and GraphQL fields can evolve; the controller must tolerate
  unknown fields and fail closed on unknown mutation contracts.
- Autonomous deletion is high consequence. It needs deterministic disposition,
  inbound-reference inspection, unique-content migration, and post-delete
  verification rather than age- or name-only heuristics.
- Exact Markdown mirrors are vulnerable to transport rewriting. Hashes must be
  computed from raw repository bytes and verified after update.
- A global sequence can become false precision. Only dependency-safe active and
  next groups should receive cycle commitments; the long backlog remains ranked
  without fabricated dates.
- Linear plan limits may constrain native Insights or automation features. Core
  scheduling and metrics must remain functional from the controller ledger.
- A compromised webhook or API credential could mutate the workspace. Secrets,
  signature verification, least privilege, structured audit logs, and rotation
  are mandatory.

No unresolved product hard fork blocks Scope. The exact authority boundary is
repository and operational metadata only; private app data remains excluded.

## Frontend impact investigation

- Potential frontend impact: none
- Existing surfaces investigated: N/A — this initiative is repository tooling or a documentation-only fixture.
- Evidence and unknowns: The approved scope, design, and grooming files create no application surface, route, asset, or user-visible state.

## Recommended direction

Proceed with a dedicated **Ambitions Real-Time Lifecycle Control** initiative.
Use one deterministic TypeScript policy engine shared by a local CLI, CI, and a
Cloudflare Worker backed by Queue, dead-letter queue, and D1. Compile current
repository lifecycle truth into a typed desired-state manifest, enforce a
two-Project/one-active-task-per-Project WIP policy, proof-gate Done, maintain a
two-week execution calendar, publish an exact portfolio sequence, install
controlled views/templates, and surface exceptions rather than activity noise.

The controller may autonomously reconcile the Ambitions workspace, including
referentially safe deletion, but may never infer repository authority from
Linear, modify product/app data, or describe Trash as stronger deletion than
Linear actually provides.
