+++
initiative = "private-generative-model-runtime"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions features can request bounded generative work through one private,
inspectable runtime. The runtime selects only an enabled mode by deterministic
policy, shares the minimum permitted context, returns an untrusted typed draft,
validates it against product/source rules, and degrades honestly. Users know
when AI is used and when data would leave the device; no model can commit a
Goal, Step, schedule, profile, external action, or source claim.

## In scope

- Versioned task/input/output/prompt/tool/validation contracts.
- Deterministic/manual, on-device system-model, optional Apple PCC, disabled-by-
  default third-party hosted, and separately admitted custom-model modes.
- Capability/availability detection and deterministic mode selection.
- Purpose-bound, field-level, revision-bound context capsules.
- Explicit per-mode privacy controls and hosted-transfer preview/confirmation.
- Read-only, budgeted, allowlisted local/public tools.
- Guided structured output, untrusted envelopes, deterministic validation,
  bounded repair, partial/unavailable recovery and generated-content disclosure.
- Session cancellation, no-payload receipts, draft/asset/settings deletion,
  dependency invalidation and change/evaluation bindings.
- Accessibility, privacy, security, physical-device and direct-user evidence.

## Out of scope

- A general chat assistant, autonomous agent, arbitrary web browser or universal
  model router.
- Any enabled third-party provider before separate provider approval.
- Whole-graph/whole-profile prompt access, hidden personality or sensitive
  attribute inference, training on user data, federated analytics, prompt/
  response telemetry, or cross-user learning.
- Model-written source facts, citations not bound to retrieved evidence, hidden
  chain-of-thought storage/display, or model confidence as authority.
- Write-capable tools, automatic canonical/schedule/external mutation, automatic
  Goal creation, purchase, application, contact, deletion or export.
- Deep personalization/adaptive learning, which has its own owner.

## Requirements

### REQ-001 — Every generation is a registered task

Each task declares versioned purpose, input/output schema, prompt/instructions,
allowed context fields, read tools, modes, budgets, safety policy, validators,
fallback and evidence requirements. Unknown/unapproved versions fail closed.

### REQ-002 — Mode routing is deterministic and visible

Routing considers task capability, device/OS/locale, user setting, privacy mode,
network/resource state and evaluated model versions. It never uses private
content to choose a provider and never silently escalates off device.

### REQ-003 — On-device is preferred and core remains useful

When an evaluated on-device mode can perform the task, it is preferred. Every
feature has a manual/deterministic path when generation is disabled/unavailable.

### REQ-004 — Hosted modes require scoped informed control

Before first and materially changed PCC/hosted use, show task, data categories,
provider class, processing/retention, fallback and controls. Consent is
purpose/mode/version bound, revocable, never inferred and not a canonical commit.

### REQ-005 — Context is minimum and owner-mediated

Typed owners assemble field-level capsules with purpose, sensitivity, source,
revision, expiry and inclusion reason. Unrelated objects, raw stores, precise
history and sensitive fields are excluded unless explicitly necessary/allowed.

### REQ-006 — Hosted requests are unlinkable where practical

Use ephemeral request/session IDs and no stable user/object IDs, raw local paths,
account tokens or unnecessary metadata. Provider credentials are app/service
secrets, never user content, logs or artifacts.

### REQ-007 — Tools are read-only and bounded

Tools have typed arguments/results, fixed purpose, revision, row/token/time
budgets and allowlists. They cannot reach command executors, writes, arbitrary
URLs, external actions or recursive private graph traversal.

### REQ-008 — Outputs are untrusted structured candidates

The runtime records model/runtime/prompt/schema/tool/source versions and stop/
error state. Generated text/objects are never canonical or factual merely by
being structured.

### REQ-009 — Deterministic validation owns admissibility

Validation checks schema, bounds, IDs, citations, source support, unknowns,
duplicates, cycles, prohibited claims, privacy and feature invariants. Failure
returns exact reasons; no validator may fill missing evidence with generation.

### REQ-010 — Repair is bounded and honest

Repair retries are task-bounded, cancellation-aware and use only validation
feedback. Exhaustion yields partial/unavailable/manual recovery, never an
unvalidated best effort disguised as success.

### REQ-011 — Generated content is disclosed and correctable

Users can identify generated material, inspect sources/assumptions/limits,
edit, retry, choose alternatives, dismiss, report, undo an accepted downstream
mutation through its owner, and understand when corrections affect future work.

### REQ-012 — Model sessions cannot mutate product state

Runtime APIs return proposal envelopes/receipts only. Accepted mutations require
the existing owner's typed preview/confirm/commit/idempotency/replay contract.

### REQ-013 — Availability and failures are typed

Disabled, unsupported device/locale, model unavailable/downloading, resource
pressure, context overflow, refusal, timeout, offline, provider/entitlement/
policy error, invalid output, unsupported claim and cancellation are distinct.

### REQ-014 — Privacy-safe observability and deletion

Receipts/metrics contain task/mode/version, field-category set, hashes, budgets,
latency and reason codes—not prompt, response, private excerpts or stable user
identity. Users can clear drafts, receipts, optional model assets and settings;
deletion-terminal replay cannot restore them.

### REQ-015 — Model and prompt change is controlled

Every result binds exact task/model/runtime/prompt/schema/policy/source versions.
Changed dependencies invalidate exact drafts and require evaluation/promotion;
accepted canonical state remains owned and separately reconciled.

### REQ-016 — Security treats all content as data

Prompt injection, tool-result injection, hostile Unicode/markup, schema bombs,
resource exhaustion, cross-session bleed and unsafe URL/output must fail closed.
The model cannot change instructions, tools, modes, permissions or validators.

### REQ-017 — Evaluation is task/mode/version bound

Promotion requires structured validity, grounding/citation, unsupported claim,
privacy leakage, bias/dignity, refusal/recovery, correction, latency/resource and
direct-user usefulness evidence. No global AI score or inherited pass.

### REQ-018 — Accessibility covers consent, progress and recovery

AI disclosure, data-transfer preview, mode, progress, cancellation, sources,
validation failures and alternatives must be textual, focus-safe and usable with
assistive technologies, largest Dynamic Type, Reduced Motion and non-color cues.

## Acceptance criteria

- **AC-001 (REQ-001):** unregistered/changed task bundles cannot execute.
- **AC-002 (REQ-002):** routing matrices are deterministic and cloud escalation
  requires an already valid scoped permission plus visible mode.
- **AC-003 (REQ-003):** disabled/unavailable generation preserves manual core.
- **AC-004 (REQ-004):** transfer cannot start before exact preview/confirmation;
  revoke blocks later requests without deleting local truth.
- **AC-005 (REQ-005):** field minimization tests reject unrelated/sensitive data
  and produce inspectable inclusion reasons.
- **AC-006 (REQ-006):** network/receipt scans contain no stable private identity.
- **AC-007 (REQ-007):** write/arbitrary traversal/injection attempts are
  structurally impossible or fail closed.
- **AC-008 (REQ-008):** every result has complete version/stop/tool provenance
  and remains a draft.
- **AC-009 (REQ-009):** invalid citation/schema/ID/cycle/claim fixtures never
  reach a product projection.
- **AC-010 (REQ-010):** repair stops at budget and returns exact manual recovery.
- **AC-011 (REQ-011):** edit/retry/alternate/dismiss/report flows preserve
  source/assumption disclosure and user agency.
- **AC-012 (REQ-012):** mutation audit finds no model-to-command path.
- **AC-013 (REQ-013):** each failure has distinct copy/recovery and cancellation
  leaves no partial durable model state.
- **AC-014 (REQ-014):** payload canaries occur nowhere in logs/metrics/receipts;
  clear/purge is complete and resumable.
- **AC-015 (REQ-015):** dependency/version change invalidates only exact drafts
  and cannot rewrite accepted state.
- **AC-016 (REQ-016):** adversarial security corpus fails closed within budgets.
- **AC-017 (REQ-017):** each task/mode/version has claim-bound evidence or stays
  unavailable; no aggregate hides a hard-gate failure.
- **AC-018 (REQ-018):** simulator and physical-device accessibility evidence
  covers all modes/states/controls.

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

Implementation should add Private Generative Runtime canon and update privacy,
permissions, degraded states, trust inspection, local learning, Source Atlas,
Receipts/History and relevant proposal/evaluation/change-management contracts.
Canon cannot itself enable a hosted provider or prove model safety.

## Risks and open decisions

No hard fork remains. On-device plus deterministic fallback is complete without
PCC or third-party availability. PCC requires entitlement/platform verification;
third-party mode remains disabled until a separately approved provider decision.

Review verdict: **PASS** after two reconciliation rounds. Review added no-silent-
escalation, purpose/version-bound consent, no-payload observability, prompt-
injection defenses and exact accepted-state reconciliation. Devan delegated
approval; Scope was approved on 2026-08-04.
