+++
initiative = "generalized-life-branch-simulation"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Users can compare complete multi-owner Life Branch alternatives, understand
assumptions/consequences/reversibility/external boundaries, and explicitly apply
one through owner-validated local reconciliation. Partial failure is visible and
recoverable; external actions require a separate fresh confirmation. Production
availability is gated on v1/portfolio/owner/user evidence.

## In scope

- Branch qualification, immutable baseline and always-present keep-current.
- Complete affected/unchanged owner set, assumptions, resource/consequence/
  external-intent/precondition/operation dependency graphs.
- Local atomic-reversible, local-compensatable, externally-pending/
  compensatable/irreversible and unknown reversibility semantics.
- Deterministic branch simulation/comparison and optional validated explanation.
- Owner snapshot/validate/prepare/commit/abort/compensate/reconcile protocol.
- Atomic local commit where proven; idempotent saga otherwise.
- Branch/owner receipts, recovery, resume, retry/compensate and stale handling.
- Separate External Action handoff, private lifecycle, accessibility/evaluation.
- Conformance-only operation until activation evidence passes.

## Out of scope

- Alternate copy of the whole life graph, deterministic future/probability,
  global score, automatic branch selection or model-authored commands.
- Raw repository writes, bypassing owner invariants, forcing universal atomicity
  or claiming compensation guarantees.
- Executing/authenticating/contacting/applying/enrolling/purchasing/reserving/
  publishing/deleting externally or replaying prior consent.
- Silent Goal/Path/Step/Time/Proof mutation or hiding partial failure.

## Requirements

### REQ-001 — Branch qualification is strict
Use Life Branch only for a coherent alternative requiring at least two owner
domains or inseparable multi-object changes. Route/schedule/single-owner changes
return to their owner. Keep-current is always included.

### REQ-002 — Baseline and branch are complete
Bind exact owner/source/context/policy revisions; list changed and intentionally
unchanged objects, assumptions, consequences, constraints, resources, unknowns,
external intents and final invariants.

### REQ-003 — Every operation is owner validated
Proposed operations use typed owner-local deltas. Owners alone return validity,
preconditions, conflicts, prepared tokens, commit/abort and compensation; the
branch coordinator has no raw repository write authority.

### REQ-004 — Dependency/order semantics are explicit
Operation graph expresses before/after/all/conditional/barrier/independent and
compensation order, rejects cycles/unknown preconditions and is bounded.

### REQ-005 — Reversibility is truthful
Every operation/branch has one exact reversibility class, undo/compensation
window/limits and unknown blockers. Local undo never implies external reversal.

### REQ-006 — Simulation is deterministic and non-predictive
Stable snapshots/assumptions produce equivalent semantic branches. Results show
qualitative consequences/unknowns/sensitivity, no probability/best-life score.

### REQ-007 — Generation cannot create authority
Optional private-runtime composition/explanation uses closed aliases and cannot
mint objects, operations, preconditions, compensation, external intents or choice.

### REQ-008 — Preview and confirmation bind exact scope
Before commit, show before/after per owner, unchanged protections, order,
reversibility/external separation and recovery. Confirmation expires and binds
exact plan/baseline/policy; stale state requires new preview.

### REQ-009 — Local commit is atomic or saga-recoverable
Use a proven shared transaction for atomic operations; otherwise journaled
idempotent saga prepares all owners, orders commits and compensates/reconciles.
No owner is successful without its receipt.

### REQ-010 — Partial failure never masquerades as success
Abort before first commit where possible. After partial commit, enter explicit
reconciliation-required with completed/pending/compensation/failure state and
safe retry/recovery; preserve unaffected truth.

### REQ-011 — External effects are separate
Branch may persist only typed intent/precondition. External Action owner
revalidates and asks fresh confirmation. Its result is separately reconciled;
branch never promises cross-system atomicity or automatic retry.

### REQ-012 — Receipts and replay are exact
One branch receipt links immutable owner receipts, journal phases, compensation
and external results. Relaunch resumes idempotently without duplicate command or
consent replay.

### REQ-013 — Privacy and lifecycle are scoped
Drafts/prepared tokens are protected private data. Delete uncommitted branch
removes all derivatives; committed History follows owner retention/redaction.
No branch payload enters public/hosted/diagnostic paths.

### REQ-014 — Evaluation is branch/owner/failure bound
Measure completeness, snapshot consistency, invariant preservation,
reversibility truth, recovery, privacy/security, bias/dignity, comprehension and
usefulness by branch/owner/protocol version.

### REQ-015 — Accessibility communicates complete consequences
Ordered nonvisual views cover branch/owner/operation/assumption/unknown/
reversibility/external/partial states and every control in calm language.

### REQ-016 — Production activation is evidence gated
V1 Life Branch runtime, Portfolio conformance, owner protocol and direct-user
evidence must be signed/current; missing/revoked evidence keeps conformance-only.

## Acceptance criteria

- AC-001: single-owner/route/schedule cases are rejected to correct owner.
- AC-002: missing changed/unchanged owner or invariant blocks completeness.
- AC-003: raw write/malformed/stale owner delta cannot prepare.
- AC-004: cycles/unknown/order violations and budget overflow fail closed.
- AC-005: reversibility/undo/external-compensation copy matches exact contracts.
- AC-006: stable inputs replay; probability/score/prediction language fails.
- AC-007: model outputs cannot add any authority-bearing semantic.
- AC-008: stale/expired confirmation cannot commit or replay.
- AC-009: atomic and saga fixtures preserve owner invariants/idempotency.
- AC-010: every partial fault yields visible recovery, never success.
- AC-011: branch selection executes zero external effects.
- AC-012: relaunch/replay duplicates zero owner/external actions.
- AC-013: private canaries/purge/committed-history boundaries pass.
- AC-014: each branch/owner/failure hard gate passes.
- AC-015: accessibility/device/user comprehension passes.
- AC-016: production entry remains unavailable until gate record passes.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

Add Generalized Life Branch canon; update Life Branch/reconciliation, runtime
commands/transactions, Goal/Path/Step/Time/Proof, portfolio, external effects,
History/Receipts, privacy/trust/degraded/deletion and evaluation/change canon.

## Risks and open decisions

No product fork remains. Atomic versus saga is determined per prepared owner set
by proven capabilities; unknown reversibility blocks commit. Production remains
evidence-gated.

Review verdict: **PASS** after two reconciliation rounds. Review required a
complete unchanged set, owner-provided preparation, exact reversibility and
separate external confirmation, plus conformance-only activation. Devan
delegated approval; Scope approved 2026-08-04.
