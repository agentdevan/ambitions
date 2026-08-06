+++
initiative = "external-action-integration-orchestration"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add an `ExternalActionOrchestrator` driven by a signed adapter/action registry.
Initiating owners provide non-executable intents. Adapters build exact drafts;
preview/confirmation produces a single-use `ExternalActionAuthorization` stored
separately from account credentials. A protected durable outbox executes via
adapter-specific idempotency, records proof-level results and reconciles before
notifying local owners. Initial `CalendarEditorHandoffAdapter` invokes system UI;
remote registry is empty.

## User flows

1. An accepted local owner offers **Prepare external action**; it creates intent.
2. If provider unavailable, show official deep-link/manual checklist. If an
   account connection is required, explain scopes/fallback and authenticate
   separately; return to a fresh draft.
3. Adapter preview shows destination/account, every field/diff, generated text
   disclosure, timing/cost, effect, permission, reversibility and unknowns.
4. User edits typed fields, opens provider/system editor, cancels, or confirms.
5. Confirmation screen binds exact draft and warns about irreversible/unknown
   consequences. After confirmation, visible outbox progress can be canceled
   only while adapter contract says no effect has begun.
6. Terminal view states confirmed, failed, unknown, needs action or reconciled,
   with exact next step. Local object update is a separate owner flow.
7. Connection settings expose account/scopes, queued actions, revoke/disconnect
   and local data deletion consequences.

Calendar first: Ambitions previews title/time/calendar-field categories, opens
the system EventKit editor, and records presented/canceled/saved-callback only
within actual API guarantees. System UI is final field review.

## States and recovery

Adapter: `unavailable`, `admitted`, `changedNeedsReview`, `revoked`. Connection:
`notRequired`, `disconnected`, `authorizing`, `connected`, `scopeInsufficient`,
`expired`, `revoked`, `disconnecting`. Action: `intent`, `drafting`, `draftReady`,
`awaitingConfirmation`, `authorized`, `queued`, `executing`, `handedOff`,
`confirmedSucceeded`, `confirmedFailed`, `unknownOutcome`,
`reconciliationNeeded`, `requiresUserAction`, `canceling`, `canceled`,
`compensationPending`, `compensated`, `compensationFailed`, `expired`.

One outbox actor serializes action transitions. Each transition uses operation/
draft/authorization/adapter/account/precondition revisions and idempotency key.
Journal is durable before send and after result. Relaunch asks adapter status and
reconciles; it never resends unknown automatically. Auth callbacks bind state,
PKCE verifier, issuer/redirect and initiating connection revision.

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
- Experience authority: Task 8 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

Add under `Native/Ambitions/Core/LocalRuntimeOS/ExternalActions/`:

- adapter/action admission models/registry/artifact loader/validator;
- intent/draft/payload/diff/target/precondition/risk/reversibility models;
- preview/confirmation/single-use authorization models/store;
- connection/scope/account models, OAuth session/PKCE/callback validator and
  Keychain credential vault;
- `ExternalActionAdapter` protocol, empty remote adapter registry and Calendar
  editor handoff adapter;
- outbox record/store/actor/journal/scheduler;
- idempotency/result/reconciliation/compensation models/services;
- external receipt/owner notification/revalidation handoff;
- disconnect/revoke/reset/purge and privacy/security diagnostics.

Adapter protocol exposes `validateIntent`, `buildDraft`, `preflight`, `execute`,
`status`, `reconcile`, `cancelBeforeEffect`, `compensateIfSupported` and
`disconnect`. Capability metadata states whether each exists and exact proof.
There is no generic raw HTTP method. Provider adapters reside in named
subdirectories and pass independent admission/evaluation.

Authorization stores exact draft hash and expiry but no credential. Credential
vault stores provider/account/scopes/token metadata and Keychain references, not
action authorization. Outbox payload is protected/encrypted, minimum fields and
removed after retention/reconciliation policy; external receipt stores minimized
payload hash/destination/action/result/remote ID/version/limitations.

Owner notification never calls a command. It presents `ExternalResultInput` to
the owner, which may build a new local preview. Branch receipts link intent/action
receipts but cannot execute them.

Migration imports no legacy link taps as successful actions. Existing calendar
objects remain external observations. Local purge removes draft/authorization/
outbox/credentials/account metadata/caches/exports as scoped; active unknown
operations retain minimum recovery record until resolved or user accepts manual
unknown closure.

## Privacy and accessibility

Use least system/provider permission; request contextually. Tokens/PKCE/payloads
never enter model context, logs, crash reports or exports. Redirect/URL/host/
issuer/audience/scope/payload schemas are allowlisted. Generated text is a draft
inside the exact preview. App-switcher/notifications redact sensitive actions.

Payload diffs have ordered text and redacted/reveal controls. Destination,
account, permission, irreversible effect and unknown status are announced before
the action control. Progress doesn't steal focus; recovery returns to exact
failed field/state. VoiceOver, Voice Control, Switch Control, keyboard, largest
Dynamic Type, Reduced Motion, RTL and non-color states cover all flows.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Signed adapter/action registry and independent gates |
| REQ-002 | Non-executable intent type |
| REQ-003 | Adapter draft/preflight with exact revisions/hash |
| REQ-004 | Full typed payload/consequence preview |
| REQ-005 | Separate connection and single-use authorization stores |
| REQ-006 | External-agent PKCE OAuth and Keychain vault |
| REQ-007 | Adapter-specific durable idempotent outbox |
| REQ-008 | Proof-level result state/receipt enums |
| REQ-009 | Journal/status/reconcile and unknown stop |
| REQ-010 | Notification-only owner handoff |
| REQ-011 | System Calendar editor handoff adapter |
| REQ-012 | Revision/expiry/replay-safe outbox actor |
| REQ-013 | Connection revoke/disconnect workflow |
| REQ-014 | Scoped local purge and recovery-record exception |
| REQ-015 | Schema/auth/redirect/payload security and redacted diagnostics |
| REQ-016 | Per adapter/action/version evidence binding |
| REQ-017 | Ordered accessible preview/progress/recovery/settings |

## Verification design

- Adapter registry/contract/change/revoke/deep-link fallback tests.
- Intent/draft/preview/authorization revision and payload golden/property tests.
- OAuth state/PKCE/issuer/redirect/mix-up/replay/scope/token vault threat tests
  using fake providers; no remote adapter enabled.
- Outbox every-phase fault, duplicate, timeout, unknown, reconcile, compensation,
  disconnect, background/relaunch tests.
- EventKit editor permission/callback/cancel/device tests with exact claim ceiling.
- Mutation spies and branch/model/background consent denial.
- Privacy canaries, local purge/unknown recovery/receipt retention.
- Accessibility/direct-user preview/result/unknown/disconnect comprehension and
  physical-device performance/resource evidence.

## Open decisions

None. Each remote provider/action requires its own future admission and evidence;
the framework does not need one to implement the Calendar conformance loop.

Review verdict: **PASS** after two reconciliation rounds. Review separated
authorization/credentials, prohibited generic HTTP, retained minimum unknown-
recovery state and made owner notification non-mutating. Devan delegated
approval; Design approved 2026-08-04.
