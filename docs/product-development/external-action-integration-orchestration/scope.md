+++
initiative = "external-action-integration-orchestration"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user can turn an accepted local intent into an exact external-action draft,
review destination/payload/consequences, confirm one expiring action, and receive
truthful executed/failed/unknown/reconciled status. The first adapter is a system-
owned Calendar editor handoff; no remote provider or high-consequence action is
enabled without separate adapter admission.

## In scope

- Adapter/action admission registry and unavailable/deep-link fallback.
- Typed external intent, draft, payload diff, preview and user editing.
- Separate account/permission connection and exact one-action authorization.
- Local platform, handoff, remote adapter protocol and risk/reversibility classes.
- Protected credentials/account metadata, least scopes and secure native OAuth
  contract for future providers.
- Durable outbox, idempotency, preconditions, execution, cancellation, result,
  unknown outcome, reconciliation, compensation request and external receipt.
- Provider change/revocation/disconnect/delete-local controls.
- Calendar system editor handoff conformance adapter.
- Privacy/security/accessibility/provider/action evaluation.

## Out of scope

- Enabled remote OAuth provider, generic HTTP connector, webhook hosting,
  embedded credentials/browser, or static secret treated as confidential.
- Automatic/model/background-predicted/branch-replayed action confirmation.
- Unrestricted send/apply/enroll/purchase/pay/publish/delete or other high-
  consequence classes.
- Cross-system atomicity, guaranteed external undo/compensation/success,
  automatic retry after unknown outcome or remote delete implied by local purge.
- External result silently mutating Goal/Path/Step/Time/Proof.

## Requirements

### REQ-001 — Every adapter/action is admitted
Contract names provider/endpoint/version/terms, scopes, fields, risks, retention,
idempotency, results/errors/unknowns, reconciliation, compensation, disconnect,
change owner and test evidence. Missing/changed contract is unavailable.

### REQ-002 — Intent is not executable
Local owners emit a typed intent with purpose/public target/required field
categories and expected revisions. It contains no credential, provider request
or inherited confirmation.

### REQ-003 — Draft is exact and current
Adapter builds from current owner/source/provider/account/permission state and
binds exact payload, target, action, preconditions, expiry, adapter/policy version
and request hash. Unsupported/unknown fields block execution.

### REQ-004 — Preview communicates full consequences
Show provider/account/recipient/audience, field-level human payload/diff, timing/
money, permissions/scopes, external effect, reversibility/compensation limits,
expiry, unknowns and manual fallback before confirmation.

### REQ-005 — Connection and action authorization are separate
System/provider permission or OAuth connection never authorizes an action. Each
execution requires last-moment confirmation bound to exact draft/account/
permission/preconditions/idempotency/expiry; changed scope requires new preview.

### REQ-006 — Authentication uses least privilege
Future remote adapters use system external-user-agent OAuth authorization code +
PKCE and current security BCP, issuer/redirect/state validation, least scopes,
Keychain token protection/rotation/revoke. Tokens never reach model/log/export.

### REQ-007 — Execution is adapter specific and idempotent
Outbox validates confirmation/revisions immediately before send. Provider
idempotency is used exactly as contracted; no automatic retry where duplicate
effect cannot be excluded.

### REQ-008 — Results distinguish proof levels
`handedOff`, `confirmedSucceeded`, `confirmedFailed`, `unknownOutcome`,
`requiresUserAction`, `reconciliationNeeded`, `canceled`, `compensated` and
`compensationFailed` remain distinct. Transport success is not business success.

### REQ-009 — Unknown outcomes fail safe
Persist request hash/idempotency/remote IDs available; reconcile/read back when
contracted. Without reliable method, stop automatic execution and direct manual
inspection. Never send a new request under a new ID silently.

### REQ-010 — Local and external truth remain separate
External receipt notifies the initiating owner; owner revalidates and confirms
any local change. External failure does not roll back accepted local truth, and
local undo does not claim remote reversal.

### REQ-011 — Calendar reference adapter is system-owned
Initial adapter presents a prefilled system Calendar editor with exact preview
and records only the callback/proof EventKit provides. It requests no broader
access than needed and never claims saved/synced when unverified.

### REQ-012 — Background and replay cannot repeat consent
Queued work contains an exact confirmed draft and expiry. Relaunch/background
may execute only within contract/authorization; expired/revoked/stale/unknown
requires user action. Replay is idempotent and never reconfirms.

### REQ-013 — Disconnect/revocation is safe
Disconnect cancels safe queued work, blocks new execution, revokes/clears tokens
where possible and minimizes account metadata. It does not claim remote resource
deletion; receipts preserve truthful minimized history.

### REQ-014 — Local deletion is scoped
Draft/outbox/credential/account/cache/export purge is atomic/resumable and
deletion terminal. Deleting remote data requires a separately admitted/action-
confirmed provider operation.

### REQ-015 — Privacy-safe observability and security
No secret/token/private payload in logs/metrics/crashes. Redacted operation/
adapter/state/reason/timing only. Injection, redirect mix-up, token replay,
malformed URLs/payloads, over-scoping and tampering fail closed.

### REQ-016 — Evaluation is adapter/action/version bound
Measure payload/destination correctness, preview comprehension, least scope,
duplicate prevention, outcome/reconciliation truth, revoke/disconnect, privacy,
security, accessibility and trust. Passes never transfer across adapters/actions.

### REQ-017 — Accessibility covers consequence and recovery
Preview/diff/destination/permissions/reversibility/status/retry/manual/disconnect/
delete are textual, ordered and assistive-technology accessible.

## Acceptance criteria

- AC-001: incomplete/changed adapter contract leaves action unavailable/deep-link.
- AC-002: intents contain no executable payload/secret/confirmation.
- AC-003: any stale/unsupported field/precondition blocks draft execution.
- AC-004: every payload/consequence/unknown appears before confirmation.
- AC-005: OAuth/permission/branch/Goal confirmations cannot authorize action.
- AC-006: auth threat tests prove external agent/PKCE/least scope/token safety.
- AC-007: duplicate/crash/retry fixtures produce at most one contracted effect.
- AC-008: all proof-level states remain distinct in receipts/UI/replay.
- AC-009: unknown outcome never auto-retries unsafely.
- AC-010: local owner bytes change only through separate confirmed command.
- AC-011: Calendar handoff claims only verified callback semantics/minimal access.
- AC-012: expiry/revoke/stale/relaunch never repeats consent/action.
- AC-013: disconnect blocks/cancels/clears safely and preserves truthful receipts.
- AC-014: local purge is complete and never implies remote delete.
- AC-015: security/private canary matrix passes.
- AC-016: each enabled adapter/action hard gate passes independently.
- AC-017: accessibility/device/direct-user comprehension passes.

## Canon impact

Add External Action Orchestration canon; update external effects, permissions,
privacy/security, degraded states, History/Receipts, Time/Calendar, Life Branch,
private runtime, account/continuity and evaluation/change management.

## Risks and open decisions

No hard fork remains. Remote provider/actions are separate future admissions;
the framework plus Calendar editor handoff is complete without them.

Review verdict: **PASS** after two reconciliation rounds. Review separated
connection/action consent, made unknown outcomes durable, restricted initial
Calendar proof language and isolated local purge from remote deletion. Devan
delegated approval; Scope approved 2026-08-04.
