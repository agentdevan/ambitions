+++
initiative = "external-action-integration-orchestration"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Eventually Ambitions should help carry out an approved plan: add a calendar
event, open or submit an application, enroll, reserve, contact, export, publish,
or update another service. External action creates a qualitatively different
risk. The remote system has independent permissions, state, terms, failures and
side effects; “Undo” may not exist. A model proposal, Goal confirmation or Life
Branch selection cannot be treated as authorization to send data or act.

The outcome is an External Action Center that converts an approved local intent
into an exact provider-specific draft, shows destination/payload/effect/cost/
reversibility, obtains last-moment confirmation, executes once through an
admitted adapter, reconciles the observed result and preserves truthful local
state on failure or uncertainty.

## Current truth

### Approved baseline

- Canon separates local canonical success from external side effects and has
  degraded/outbox/reconciliation/idempotency patterns.
- Goal/Path/Step/Time owners control accepted local mutations.
- Current Authority provides source-owned current links/offerings but performs
  no transactions.
- Private Generative Runtime prohibits write tools.
- Generalized Life Branch stores only external intents and rejects cross-system
  atomicity/consent replay.
- Permissions canon requires contextual explanation, system-owned authorization,
  local fallback and foreground reconciliation.

These plans and existing value models do not prove a production integration.

### Live source seams

Live code contains EventKit/notification permission and reconciliation, command/
event/projection/receipt/replay, external-effect degraded states, idempotency and
outbox-like types, URL/deep-link handling, Keychain/security/privacy audits and
schedule install kernels. It does not prove provider admission, OAuth security,
exact payload previews, remote idempotency, unknown-outcome reconciliation,
revocation or safe deletion across arbitrary integrations.

### Platform and protocol evidence

Apple's [EventKit access guidance](https://developer.apple.com/documentation/eventkit/accessing-the-event-store)
requires permission for calendar data and distinguishes write-only from full
access. Apple recommends requesting only the access needed; EventKit UI can let
the user review/create an event without broad calendar access. This makes a
user-presented Calendar editor a strong first reference adapter: the system UI
owns final save and Ambitions does not need broad read access.

For remote services, [RFC 8252](https://www.rfc-editor.org/info/rfc8252/) requires
native OAuth authorization through an external user agent and PKCE rather than
embedded credential capture. [RFC 9700](https://www.rfc-editor.org/info/rfc9700/)
updates OAuth security best practices, including redirect-flow protection,
token replay prevention and privilege restriction. Apple's
[`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
shows the destination domain and securely returns the callback to the requesting
app. A static secret embedded in an iPhone app is not a confidential client
secret.

These standards secure authorization transport; they do not prove the user
intended a particular external payload, that a request succeeded, or that a
provider supports idempotency/undo. Every adapter needs its own terms, scopes,
rate limits, field semantics, error states, deletion and reconciliation contract.

### Action classification

1. **Handoff only:** open a verified URL or system editor; Ambitions receives no
   reliable completion. Safest, useful fallback.
2. **Local platform effect:** Calendar/Reminders/Share/Files through Apple APIs
   and permissions. OS/app owns the external database/result.
3. **Remote reversible/compensatable:** provider API with stable resource ID,
   idempotency and supported update/cancel semantics.
4. **Remote irreversible/high consequence:** send message, submit application,
   publish, purchase, payment, account deletion or legally meaningful action.
   Requires strongest confirmation and may remain unsupported.
5. **Inbound observation:** read a remote status/result under scope; it never
   silently changes canonical truth.

Each action kind has risk, payload classes, destination authority, required
local owner state, system/provider permission, confirmation freshness,
idempotency/reconciliation/compensation and logging/deletion policies.

### Adapter admission

An adapter cannot ship because an API exists. Admission requires exact provider/
endpoint/version, owner and terms; native authorization flow and least scopes;
supported actions/fields; data classification and retention; rate/availability;
idempotency semantics; remote IDs/version/preconditions; success/error/unknown
mapping; reconciliation/read-back; cancellation/compensation; webhook/polling;
account disconnect/provider deletion; sandbox/fixture; security/privacy threat
model; source change monitoring; and evaluation evidence.

Unknown items make the action unavailable while preserving deep-link/manual
handoff. OAuth login authorizes scopes, not any action. Provider connection and
action confirmation are two separate controls.

### Draft, preview, authorization, execution and reconciliation

1. A typed local owner creates `ExternalActionIntent` after its own accepted
   decision, with no executable payload.
2. Adapter builds an exact `ExternalActionDraft` from current local/source/
   provider state and validates every field.
3. Preview shows provider/account, target, action, human-readable payload diff,
   recipients/audience, time/money, permissions, external consequences,
   reversibility, expiry and fallback.
4. User may edit through typed fields or open provider/system editor. A model may
   draft text but generated status remains visible and user-editable.
5. Last-moment confirmation creates a one-action authorization bound to exact
   draft hash/provider/account/permissions/preconditions/expiry/idempotency key.
6. Outbox executes once under network/background policy.
7. Result is `confirmedSucceeded`, `confirmedFailed`, `unknownOutcome`,
   `requiresUserAction`, or `reconciliationNeeded`; HTTP completion alone is not
   business success.
8. Reconciliation reads exact remote resource/status when supported, records a
   separate external receipt, and notifies local owner. Owner decides whether
   local projections need another confirmed change.

### Idempotency and unknown outcomes

Prefer provider idempotency keys scoped to account/action. Ambitions stores its
own operation ID, exact request hash and remote resource/version IDs. Retry reuses
the same idempotency identity only when provider contract says it is safe. If the
connection drops after sending and no reliable read-back/idempotency exists,
state is unknown and automatic retry is forbidden. The UI directs user to
inspect the provider or complete manually.

Provider webhook infrastructure would require a hosted receive service and new
privacy/security/availability surface. It is not assumed. Explicit/foreground or
bounded background reconciliation through the native app is the default; each
provider contract defines what is permitted.

### Permissions, secrets and account disconnect

Use least platform/provider scopes, contextual permission, external user-agent
OAuth with PKCE, redirect/state/issuer validation and Keychain-protected tokens.
Tokens never enter model context, logs, exports or branch data. Refresh token
rotation/revocation and provider account switching are explicit. Disconnect
stops queued work, revokes locally where possible, removes credentials/account
metadata and leaves truthful external receipts with minimized IDs; it cannot
claim remote resources were deleted.

### First implementation boundary

Build the orchestration framework and a Calendar handoff adapter that presents
`EKEventEditViewController` (or equivalent system-owned editor) so the user
reviews and saves. It may record only handed-off/canceled and an OS callback
result within actual guarantees; it must not call this remote/calendar success
unless verifiable. Direct write-only Calendar can be a later adapter mode after
separate device/user evidence. No remote OAuth provider is enabled initially.

### Safety, deletion and evaluation

High-consequence classes require stronger policy and may be permanently denied.
Actions never run from background prediction/model tool/branch replay. External
receipts state local request versus observed remote result. Deleting a local
draft/outbox/credential is separate from deleting a provider resource; remote
delete requires a new action.

Evaluation covers preview comprehension, payload/destination correctness,
least scopes, consent freshness, duplicate prevention, failure/unknown truth,
reconciliation, revocation/disconnect, privacy/security/accessibility and direct-
user trust. Every provider/action/version is independent.

## Evidence

Platform and OAuth standards provide secure permission primitives, not action
authority or business-result truth. The architecture must bind two controls—
connection authorization and exact action confirmation—and treat unknown
outcomes as a durable state. Calendar system-editor handoff exercises the user
loop without inventing remote infrastructure.

## Alternatives

1. **Model write tools.** Convenient but combines interpretation, authorization
   and side effect; reject.
2. **Deep links only.** Safest but cannot reconcile; retain fallback.
3. **Generic HTTP connector.** Broad but cannot express provider-specific
   idempotency/semantics/terms; reject.
4. **Strict provider adapters behind common orchestration.** Slower breadth but
   testable and honest; recommend.

## Unknowns and risks

- Each remote provider needs separate product/terms/security research.
- Background execution limits and provider rate/auth policies change.
- External resource mutation/deletion/compensation can never be universally
  guaranteed.
- Users may interpret handoff callback as success; copy must match actual proof.
- OAuth/account metadata and action payloads are highly sensitive.
- Webhook support would require a separately scoped hosted service.

No hard fork remains. Start with framework plus Calendar editor handoff and leave
remote adapters/high-consequence classes unavailable until individually approved.

## Recommended direction

Create `ExternalActionOrchestrator`, adapter admission registry, exact draft/
preview/one-action authorization, protected credential/outbox stores,
idempotency/unknown-outcome/reconciliation state machine, external receipts and
disconnect/purge. Ship Calendar editor handoff as the conformance adapter and no
enabled remote provider.

### Five compounding ruthless review passes

1. Completeness: covered action/admission/auth/draft/confirmation/outbox/result/
   reconcile/disconnect/deletion/evaluation.
2. Connections: separated local owners, current evidence, model, branch, system
   permission, provider account and external receipts.
3. Privacy/authority: prohibited OAuth-as-action-consent, token/model leakage,
   unknown retry, webhook assumption and misleading undo/success.
4. Feasibility: chose system editor first; grounded remote auth in native OAuth
   BCP and exact adapter contracts.
5. Coherence/value: preserved deep-link/manual fallback and truthful local versus
   external status at every failure.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
