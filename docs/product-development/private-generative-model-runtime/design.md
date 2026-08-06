+++
initiative = "private-generative-model-runtime"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add `PrivateGenerativeRuntime` as a non-authoritative service between feature
proposal owners and model adapters. A signed `GenerationTaskRegistry` defines
contracts. `GenerationModePolicy` chooses an evaluated enabled adapter without
reading prompt content. `GenerationContextAssembler` asks typed owners for the
minimum fields. A read-only tool gateway serves revision-bound facts. Adapters
return an `UntrustedGenerationEnvelope`; deterministic validators produce either
a `ValidatedGenerationCandidate`, partial result, or typed failure. No API
accepts a command client.

## User flows

### Generate locally

1. A feature explains the bounded AI task and starts only after user action.
2. Runtime shows on-device mode and cancellable task-specific progress.
3. Context preview is available; typed owners assemble only registered fields.
4. Model produces structured output; validation checks all invariants/evidence.
5. User sees a generated draft with sources, assumptions, unknowns and options.
6. Edit/retry/dismiss/report are local. “Use this” hands a validated candidate
   to the feature owner's ordinary confirmation flow; it commits nothing itself.

### Use PCC or a future hosted mode

Before first/materially changed use, a sheet lists task, exact field categories,
provider class, processing/retention contract, mode limits and local fallback.
Cancel stays local. Confirm creates a scoped permission receipt, then one
ephemeral request. The mode remains visible during/result inspection. Revocation
blocks future transfer. Third-party mode is not shown without an admitted
provider configuration.

### Failure and recovery

Unavailable device/model/locale shows manual/deterministic fallback. Context
overflow offers a smaller capsule or manual editing, not silent cloud use.
Invalid structure can retry within the visible task budget. Source-invalid
claims are removed or block the result based on schema; the UI identifies the
missing evidence. Cancellation deletes transient bytes. Clear AI data offers
separate draft, receipt, optional asset and settings scopes.

## States and recovery

Task: `idle`, `preparingContext`, `awaitingTransferConsent`, `queued`,
`generating`, `validating`, `repairing`, `partial`, `readyDraft`, `canceling`,
`canceled`, `failed`, `unavailable`.

Mode: `deterministic`, `onDevice`, `privateCloudCompute`,
`thirdPartyHostedDisabled`, `customLocalUnavailable`. Availability has exact
reason codes for device, OS, locale, feature setting, consent, entitlement,
network, download, thermal/memory/power, provider/policy and evaluation state.

One `GenerationSessionActor` serializes state per request. Cancellation tokens
propagate through assembly, tools, adapter streaming, validation and repair.
Each event checks task registry generation, owner revisions, source releases,
mode policy and consent revision. A changed dependency discards the result.
Crash recovery retains only a privacy-safe terminal receipt and locally saved
drafts the user explicitly kept; it never resumes a hosted request implicitly.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 9 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Exact components

Add under
`Native/Ambitions/Core/LocalRuntimeOS/GenerativeRuntime/`:

- task bundle/input/output/version and availability models;
- task registry artifact loader/validator/store;
- mode policy and capability registry;
- context field/capsule/purpose/sensitivity models and assembler;
- transfer consent policy/store and preview projection;
- read tool registry/gateway/budget/receipt models;
- untrusted envelope and validated candidate models;
- schema/source/identifier/invariant/safety validation pipeline;
- bounded repair coordinator;
- session actor/coordinator/cancellation/recovery;
- on-device Foundation Models adapter;
- PCC adapter behind entitlement and user control;
- disabled hosted-provider protocol/registry;
- privacy-safe receipt store, invalidation, clear/purge; and
- feature-facing `PrivateGenerationClient`.

The task registry is a generated, signed resource compiled from
`tools/generative-runtime/` schemas/configs/golden cases. Prompt instruction
text, output schema and validators share a version bundle; features reference a
task ID/version rather than embedding prompts.

### Protocols

```
protocol PrivateGenerationClient {
  func availability(task: TaskID) -> TaskAvailability
  func preview(request: TypedTaskRequest) async -> GenerationPreview
  func generate(confirmed: ConfirmedGenerationRequest) -> AsyncSequence<GenerationEvent>
  func cancel(requestID: EphemeralRequestID) async
}

protocol GenerationModelAdapter {
  func capabilities() -> EvaluatedCapabilities
  func generate(envelope: AdapterInput, readTools: ReadToolGateway) async throws
    -> UntrustedGenerationEnvelope
}
```

Neither protocol contains mutation, persistence-owner access, arbitrary query,
credential disclosure, web browsing or external operation.

### Context and tool data flow

Task registration maps semantic fields to typed owner clients. The assembler
requests an exact object/revision and emits a sorted capsule of `{ephemeralID,
fieldType, redactedValue, purpose, sensitivity, sourceRevision, expiry,
inclusionReason}`. On-device mode can have a broader separately registered
capsule than hosted mode. Preview derives from categories, not secret values.

Tool calls are selected from the task allowlist. The gateway revalidates the
session/task/revision, bounds rows/tokens/time, returns typed excerpts and stores
only request/result hashes. Source material is delimited as data and cannot
alter instructions. Tool results carry public source claim IDs or private owner
revision IDs; raw private content is never copied into receipts.

### Validation and feature handoff

The envelope is quarantined in memory. Validation order: transport/stop state,
schema/depth/size, identifiers/enums, source bindings/citations, task invariants,
prohibited claims, privacy/safety, duplicates/cycles and feature-specific rules.
Only the final semantic candidate can be persisted as a generated draft.

Feature handoff includes task/version provenance, validated fields, evidence
bindings, unknowns, limitations and candidate hash. The feature owner recreates
its own preview at current revisions. Model prose is rendered from validated
fields and never parsed back into authority.

### Persistence, replay and deletion

Persist task registry/model capability snapshots as public/configuration data;
mode consent, user settings, saved drafts and no-payload receipts as protected
private data. Raw prompts, contexts, tool contents, streams and unvalidated
responses are transient. Optional local assets are signed/versioned and isolated.

Receipts include task/mode/provider class/model/runtime/prompt/schema/policy,
field categories, source/owner revision hashes, token/resource budget, outcome/
reason and timings. Purge is actor-serialized, journaled, resumable and removes
all requested drafts/receipts/assets/settings/caches; tombstones have no payload.

### Migration and change

Existing deterministic recommendations are not imported as model outputs.
Legacy generated-looking text remains ordinary user/content data unless exact
provenance exists. Model/OS/prompt/schema/policy/tool/source changes create a new
runtime compatibility tuple. Change Management evaluates/publishes/rolls back
tuples and invalidates exact unaccepted drafts. Accepted canonical objects are
never rolled back by the runtime.

## Privacy and accessibility

Context previews list human-readable categories and purpose; users can remove
optional categories. Hosted consent is separate from analytics and can be
revoked. Network capture and logs must show no stable user/object IDs, exact
location, prompt, response, tool payload or unrelated metadata. Sensitive
fields are opt-in per task, not inferred from other behavior.

All progress is textual and cancellable. Streaming does not steal focus or
announce every token. Consent and result structure survive largest Dynamic Type.
Sources, assumptions, validation issues and modes have ordered list views.
VoiceOver, Voice Control, Switch Control, keyboard, Reduced Motion, RTL and
non-color cues cover preview, generate, retry, alternative, cancel and clear.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Signed task bundle registry |
| REQ-002 | Content-blind deterministic mode policy and visible mode |
| REQ-003 | On-device preference plus deterministic/manual fallback |
| REQ-004 | Versioned transfer preview/consent store |
| REQ-005 | Owner-mediated field capsule with inclusion reasons |
| REQ-006 | Ephemeral IDs and metadata-minimized adapters |
| REQ-007 | Typed budgeted read-only tool gateway |
| REQ-008 | Quarantined untrusted envelope and full provenance |
| REQ-009 | Ordered deterministic validation pipeline |
| REQ-010 | Bounded repair coordinator and partial/manual recovery |
| REQ-011 | Generated disclosure and edit/retry/alternate controls |
| REQ-012 | Read-only runtime/client protocols and owner revalidation |
| REQ-013 | Typed task/mode/session failures |
| REQ-014 | No-payload receipts and scoped resumable purge |
| REQ-015 | Compatibility tuple and exact draft invalidation |
| REQ-016 | Content-as-data delimiters, fixed instructions and security limits |
| REQ-017 | Task/mode/version evaluation binding |
| REQ-018 | Accessible preview/progress/result/recovery design |

## Verification design

- Registry schema/signature/version and unknown-task failure tests.
- Routing matrices across device/OS/locale/consent/network/resource/evaluation;
  prove no prompt-content dependency and no silent escalation.
- Field minimization/private canaries and hosted network-capture tests.
- Adapter golden/invalid/timeout/cancel/refusal/context-overflow suites with
  deterministic fake adapters and eligible physical-device system models.
- Structured validation fuzzing for depth/size/Unicode/injection/schema/IDs/
  citations/cycles/claims and bounded repair exhaustion.
- Tool authorization, row/token/time, revision, injection and write-path audits.
- Concurrency/replay/change/purge fault injection and accepted-state immutability.
- Evaluation hard gates per task/mode/version plus OS/model upgrade regression.
- Accessibility/simulator/device evidence and oldest-supported-device latency,
  time-to-first-useful-result, memory, thermal, energy and cancellation metrics.

## Open decisions

None for implementation of the on-device/deterministic runtime. PCC can be
compiled unavailable until entitlement and product evaluation pass. The hosted
provider protocol intentionally has no implementation or enabled configuration;
choosing a provider is a future separate approval, not a hidden fork here.

Review verdict: **PASS** after two reconciliation rounds. Review removed durable
raw responses, made content-blind routing explicit, made owner revalidation the
only commit handoff and isolated provider choice. Devan delegated approval;
Design was approved on 2026-08-04.
