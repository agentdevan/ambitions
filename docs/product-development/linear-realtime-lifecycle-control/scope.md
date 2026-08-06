+++
initiative = "linear-realtime-lifecycle-control"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions has a continuously current Linear execution surface derived from
repository `main`. Every operational object is explainable, dependency-safe,
proof-aware, globally sequenced, and automatically repaired after drift or a
missed event. Devan can see what is executable now, what can run in parallel,
what comes next, and exactly why work is blocked without manually rebuilding
portfolio truth.

## In scope

- A repository compiler, read-only checker, mutation planner, apply command,
  explanation command, and failed-delivery replay command.
- Dedicated Cloudflare webhook ingress, Queue, dead-letter queue, D1 ledger,
  scheduled reconciliation, health endpoint, and structured observability.
- Desired-state control for Initiatives, Projects, Issues/sub-issues,
  milestones, Documents, relations, states, labels, cycles, status/health
  updates, controlled templates, and operational views.
- Exact raw-byte repository mirrors with commit, revision, hash, lifecycle
  status, synchronization timestamp, and repository-authority warning.
- A deterministic Project/Issue state machine and proof-gated Done.
- A stable global dependency order, dependency-safe parallel Project pairs,
  WIP limits, active/next cycle placement, and a Portfolio Execution Index.
- Safe autonomous reconciliation and referentially safe deletion with durable
  receipts and post-mutation verification.
- Exception-focused freshness, flow, blocker, review, repair, proof, and
  rollover metrics.
- GitHub Code Quality integration and controller deployment automation.

## Out of scope

- Product behavior, iOS app implementation, app runtime authority, private-life
  graph data, Source Atlas public-serving behavior, Figma, App Store release,
  and deployment of the Ambitions iPhone app.
- Turning Linear into product/design authority or permitting Linear edits to
  rewrite canonical repository documents.
- Automatically implementing Plan tasks, assigning estimates, inventing due
  dates for the long backlog, or manufacturing filler work.
- Slack, email, or third-party notification integrations.
- Deleting an unclassified object merely because it is old, inactive, or not
  recognized by a stale controller build.

## Requirements

### REQ-001 — Repository authority is explicit
Every managed Project, task, and synchronized Document identifies its canonical
repository path and authority commit. Linear content never overrides main.

### REQ-002 — Desired state is deterministic
The same repository commit and Linear read model produce the same manifest,
sequence, reconciliation plan, hashes, and health classification.

### REQ-003 — Events are durable and idempotent
Linear, GitHub, scheduled, and manual events have stable delivery identities,
survive retries, and can be replayed without duplicate side effects.

### REQ-004 — Reconciliation converges
Apply reads current state, emits exact mutations, records receipts, re-reads
affected objects, and reaches zero unexplained drift on a second check.

### REQ-005 — WIP is bounded
At most two Projects are Building and at most one implementation Issue is In
Progress per Building Project. Validation/review does not consume another
implementation slot. Shared-authority paths are serialized.

### REQ-006 — Readiness is dependency-derived
Ready For Codex requires a complete current task contract and no unresolved
blocker. Blocked requires a named open dependency. Capacity alone cannot make
blocked work ready.

### REQ-007 — Done is proof-gated
A merge can enter or retain In Review, but Done requires current-main inclusion
and every required validation/proof field to pass. Failed proof produces Needs
Repair without losing the original task mapping.

### REQ-008 — Project lifecycle is milestone-derived
Each Project has exactly one lifecycle phase and M0–M6. Phase progression is
derived from approved documents, grooming, implementation, validation, merge,
and closeout evidence rather than manual narrative.

### REQ-009 — Global sequence is honest
Every executable task has one stable global rank derived from dependencies and
shared-file conflicts. Parallel groups contain no more than two Projects. Only
active and next groups receive cycle commitments.

### REQ-010 — Cycles express commitments
The team uses Monday-start two-week cycles. Rollover is explicit and retains a
reason. The controller does not fabricate long-range dates.

### REQ-011 — Operational views answer decisions
Shared views expose Now, Parallel Wave, Critical Path, Next Up, Proof Queue,
External Gates, Drift, Portfolio Health, and Closeout using current controlled
fields and relations.

### REQ-012 — Templates cannot recreate legacy hierarchy
Default templates create only Lifecycle Project, Plan Task, Unplanned Intake,
Validation/Repair, External Gate/Owner Decision, Accepted Yellow Follow-up, and
Closeout contracts using the current M0–M6 hierarchy and taxonomy.

### REQ-013 — Taxonomy is controlled
Surviving labels belong to approved namespaced families. Project phase is
native where available and represented by exactly one phase label only where
needed. Legacy labels are migrated before deletion.

### REQ-014 — Mirrors are byte-verifiable
Repository document bytes have a SHA-256 hash. Linear mirrors include metadata
plus an exact fenced copy and are verified after synchronization. Placeholders
or silently transformed authority content are drift.

### REQ-015 — Autonomous deletion is referentially safe
Before deletion, the controller proves a replacement or zero value, inspects
comments/attachments/descendants/inbound relations, migrates unique current
content, repairs references, re-reads the object, records a receipt, and
verifies Linear's observable deletion/Trash result.

### REQ-016 — Exceptions drive health
Health and status updates are derived from WIP violations, blocker/review age,
failed proof, cycle risk, and synchronization freshness. Routine no-op syncs do
not create activity noise.

### REQ-017 — Credentials and data are bounded
Webhook signatures use timing-safe verification; secrets never enter source,
logs, manifests, or Linear Documents. The controller processes no private app
graph or user content outside operational planning metadata.

### REQ-018 — Operation remains recoverable
Operators can run check/plan/explain locally, inspect receipts, replay a failed
delivery, stop autonomous mutation, and restore service without losing event or
mapping history.

## Acceptance criteria

- Two consecutive full checks against one authority commit report zero
  unexplained drift and produce identical global ordering.
- Duplicate and reordered webhook fixtures produce one mutation set.
- Every active lifecycle Project has one canonical folder, Initiative, phase,
  M0–M6, five exact mirrors, and Plan-task mapping.
- No active Issue uses a retired state or label; no managed Document contains a
  placeholder or a mismatched repository hash.
- WIP never exceeds two Building Projects or one active implementation task in
  either Project; the next eligible work is promoted after capacity opens.
- Merge without proof cannot reach Done; passing proof causes deterministic
  completion and failed proof causes Needs Repair.
- The active pair is in the current cycle, the next pair is staged, and the
  Portfolio Execution Index matches the dependency graph.
- Every autonomous deletion has a complete safety receipt and verified result.
- Queue retry/DLQ replay, API throttling, scheduled repair, and credential
  rejection tests pass.

## Frontend impact contract

- Surface impact: none
- IA/navigation: none
- Assets/iconography: none
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: N/A — no application copy is created or changed.
- Accessibility: N/A — no rendered application interface is created or changed.
- Visual proof: N/A — repository structural evidence is the applicable proof ceiling.

## Canon impact

No product canon change is required. This initiative governs the external
engineering execution mirror and must not add process gates to product canon.
Repository contributor guidance may reference the check command after the
controller is implemented, but current product requirements remain unchanged.

## Risks and open decisions

The plan's operating choices are resolved: one control-plane initiative, full
autonomous reconciliation, proof-gated Done, Cloudflare hosting, two concurrent
Projects with one active task each, and two-week Monday cycles. API capability
loss must fail closed and become an explicit exception; it does not authorize a
weaker silent representation.
