+++
initiative = "linear-realtime-lifecycle-control"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

A pure TypeScript control core compiles repository lifecycle folders into a
typed desired-state manifest, normalizes a Linear read model, computes a stable
dependency/WIP schedule, evaluates state and health, and emits a deterministic
reconciliation plan. The same core runs in a Node CLI, Code Quality, and a
dedicated Cloudflare Worker. D1 records delivery idempotency, canonical object
mappings, runs, exceptions, and before/after mutation receipts. Queue delivery
serializes mutation work; a dead-letter queue preserves exhausted failures.

## User flows

1. **Inspect:** Devan runs `check` or `explain AMB-####`; the CLI fetches current
   repository/Linear truth and reports authority, rank, phase, blockers, proof,
   health, and exact drift without mutation.
2. **Repository change:** a main push or Code Quality result posts a signed
   event. The Worker validates and enqueues it, the consumer compiles that exact
   commit, reconciles affected objects, records receipts, and verifies them.
3. **Linear change:** a signed webhook is acknowledged after durable enqueue.
   The consumer determines whether it is valid operational input or drift and
   preserves or repairs it accordingly.
4. **Scheduling:** completion or blocker changes recompute the DAG. Capacity
   opens only after lifecycle and shared-file constraints pass; the active and
   next Project pair, cycles, states, and Portfolio Execution Index update.
5. **Proof completion:** merge retains In Review. A successful required check
   and proof contract advances Done/M4–M6 as applicable; failure sets Needs
   Repair and updates health.
6. **Failure:** retriable errors are delayed and retried. Exhausted deliveries
   enter the DLQ and create one exception. `replay` resumes the same delivery
   identity without duplicating successful mutations.
7. **Deletion:** a classified stale/duplicate object enters a safety evaluation;
   unique content and references migrate first, then deletion and re-read occur.

## States and recovery

- Delivery: received → queued → processing → applied/no-op → verified, or
  retrying → dead-lettered → replayed.
- Reconciliation run: planned → applying → verifying → converged, or failed.
- Drift: none, repairable, blocked-capability, blocked-authority, or unsafe.
- Project health: On Track; At Risk for WIP violation, blocker older than three
  business days, review older than two business days, or sync older than 15
  minutes; Off Track for blocker older than seven business days, unresolved
  failed proof, or sync older than 60 minutes.
- Mutation kill switch disables writes while preserving ingress, ledger, check,
  plan, explain, and metrics.
- Unknown schemas, missing authority commits, stale document dependencies,
  ambiguous duplicates, incomplete deletion evidence, and unavailable required
  API capabilities fail closed and surface one actionable exception.

Recovery is replay-based. Idempotency keys combine source, delivery ID,
authority commit, canonical object key, operation, and desired hash. Partial
runs resume from verified receipts; successful mutations are not repeated.

## Architecture and data

### Repository package

`tools/linear-control/` contains:

- `src/core/` — manifest types, lifecycle parser, task parser, DAG scheduler,
  state machine, health policy, reconciliation planner, and deletion guard;
- `src/adapters/` — Linear GraphQL and GitHub evidence adapters;
- `src/cli.ts` — compile/check/plan/apply/explain/replay commands;
- `src/worker.ts` — HTTP, queue, and scheduled handlers;
- `migrations/` — ordered D1 schema migrations; and
- `test/` — pure policy and Worker integration fixtures.

The generated manifest has schema version, authority commit, generated time,
Initiatives, Projects, documents, tasks, dependencies, proof contracts, shared
paths, global rank, and parallel group. Generated time is excluded from the
semantic contract hash.

### Interfaces

- `DesiredWorkspaceManifest`, `ProjectContract`, `DocumentContract`,
  `TaskContract`, `ProofContract`, `ScheduleGroup`, `CurrentWorkspace`,
  `ReconciliationPlan`, `Mutation`, `DeletionEvidence`, and `MutationReceipt`.
- CLI: `compile`, `check`, `plan`, `apply`, `explain`, and `replay`.
- HTTP: `POST /webhooks/linear`, `POST /events/github`,
  `POST /reconcile`, and `GET /health`.
- D1: `deliveries`, `runs`, `object_mappings`, `mutation_receipts`,
  `exceptions`, and `metric_snapshots`.

### Scheduling

Task dependencies and Project dependencies form one DAG. Kahn topological sort
uses canonical slug/task ID as a stable tie-breaker. The scheduler greedily
forms groups of at most two Projects whose current tasks have no dependency or
shared-authority-path conflict. Only one implementation task per selected
Project becomes Ready/In Progress eligible. Validation/review lanes remain
visible without consuming implementation capacity. Cycles are assigned only to
the active and next group.

### Documents and mappings

Raw bytes are hashed before Markdown parsing. A mirror contains a metadata
header and exact content in a fenced `text` block. The adapter re-reads content
and verifies the recorded SHA-256. Repository canonical keys—not Linear IDs—are
used by the manifest; D1 mappings bind those keys to current Linear IDs.

## Privacy and accessibility

The control plane processes only public repository lifecycle text, GitHub
engineering evidence, and Linear planning metadata. It never reads or emits
Ambitions private-life graph data. Secrets are Worker/GitHub environment
secrets, signature comparisons are timing-safe, and logs use IDs/hashes rather
than document bodies or credentials.

Linear remains the accessible operator UI. Views, templates, states, health,
and descriptions use plain language and do not rely on color alone. The CLI
emits deterministic text and JSON modes suitable for screen readers and other
automation. No new iOS accessibility surface is introduced.

## Requirement traceability

- REQ-001, REQ-002, REQ-003, REQ-004: manifest compiler, exact authority commit, event ledger,
  reconciliation planner, receipts, and convergence verification.
- REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010: DAG scheduler, WIP evaluator, lifecycle state machine,
  proof gate, stable rank, and rolling cycle allocator.
- REQ-011, REQ-012, REQ-013: controlled view definitions, current templates, native
  states, and controlled label reconciliation.
- REQ-014: raw-byte hashing, fenced mirrors, and post-write verification.
- REQ-015: `DeletionEvidence`, reference repair, guarded mutation, and re-read.
- REQ-016: health policy, metric snapshots, exception-triggered updates.
- REQ-017: isolated Worker, bounded adapters, secret/signature policy, and
  privacy-safe logs.
- REQ-018: CLI, kill switch, D1 history, DLQ, replay, and health endpoint.

## Verification design

- Automated: parsers, hashes, deterministic manifests, DAG cycles/tie-breaks,
  WIP, state transitions, health thresholds, deletion gates, idempotency, event
  ordering, retries, and reconciliation convergence.
- Build: TypeScript strict typecheck, lint, test, Wrangler generated types,
  configuration validation, and deployment dry run.
- Runtime: local Worker integration with D1/Queue fixtures followed by signed
  staging ingress and live no-op convergence.
- Accessibility: CLI text/JSON clarity and Linear view/template semantic review.
- Privacy/security: secret scan, invalid/replayed signature tests, bounded-body
  rejection, mutation kill switch, and absence of private-life data fields.
- Migration: empty and incremental D1 migrations, repeated application, partial
  run recovery, mapping changes, and DLQ replay.
- Performance: bounded webhook acknowledgement, batch reconciliation, API
  backoff, and no unbounded body buffering.
- Device: N/A; this is engineering control-plane infrastructure with no iOS
  runtime or user-facing app change.

## Open decisions

None. Product and operating choices required for grooming are resolved.
