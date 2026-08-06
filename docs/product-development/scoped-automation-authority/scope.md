+++
initiative = "scoped-automation-authority"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user can explicitly allow one narrowly described reversible Capture operation
for a few exact current Captures, see and understand every boundary, let
Ambitions use that authority only inside the foreground app, and pause or revoke
it immediately. The user receives truthful local history for each use or block,
while ordinary confirmation remains available whenever authority is absent or
any safety fact changes.

The v1 outcome is evidence about whether a tiny, inspectable grant reduces
confirmation burden without increasing surprise. It is not a general automation
framework, autonomous agent permission, background execution entitlement, or
proof that the eligible Capture mutations are implemented or release-ready.

## In scope

- A durable user-owned authority lifecycle for one exact semantic operation.
- Exactly two eligible v1 Safe Automation action kinds: `.archiveItem` and
  `.markWaiting`.
- Exact current user-owned Capture identities/revisions and exact Waiting
  payloads where applicable.
- One-to-five target Captures, one target per use, one successful use per target,
  a seven-day maximum lifetime, and conservative per-grant/global use limits.
- Full in-app creation, review, activation, inspection, pause, terminal revoke,
  expiry, exhaustion, stale/policy-held states, and confirmation fallback.
- Re-evaluation of hard policy, owner rules, scope, revision, privacy,
  protection, principal, payload, budget, aggregate materiality, source, and
  actor before every use.
- The existing local command/event/projection/receipt/replay sequence, atomic
  authority-use accounting, idempotency, interruption, and concurrency behavior.
- Local-only storage, privacy-safe diagnostics, deletion/export classification,
  accessibility, direct-user comprehension, and explicit proof gates.
- In-app routing from Capture and inspection through You/Trust without creating
  a new root surface or permissions dashboard.

## Out of scope

- Any Safe Automation action other than `.archiveItem` and `.markWaiting`,
  including completion, priority/deadline/time changes, movement/reflow,
  attach/detach, create/route, notes, recommendations, attachments, Calendar,
  Reminders, export, sync conflict, deletion, forgetting, or external commands.
- Goals, Steps, Events, Reminders, schedule placements, recurring objects,
  attachments, Proof, Notes, shared/another-principal objects, or external data
  as authority targets.
- Background, closed-app, extension-process, scheduled, model/tool, learning,
  branch replay, repair, import, or hosted execution.
- Creating or consuming authority from widgets, App Intents, Shortcuts, Siri,
  Apple Intelligence, notifications, Live Activities, deep links, Spotlight,
  Control Center, or other compact/system/external surfaces.
- Treating platform permission, account connection, context-purpose permission,
  Goal/global automation posture, prior confirmation, prior success, silence,
  behavior, dismissal, correction, or lack of Undo as authority.
- Broad selectors, dynamic queries, “all current/future Captures,” inferred
  cohorts, wildcard payloads, automatic target addition, automatic renewal, or
  silent cap changes.
- A parallel executor, direct repository write, pre-authority ledger artifact,
  automatic retry after uncertain commit, or bypass of owner confirmation.
- Canon implementation, source implementation, migration execution, runtime
  enablement, release approval, or claims of build/simulator/device proof in this
  lifecycle initiative.

## Requirements

### REQ-001 — The hard safety ceiling always dominates
An authority can narrow an action but can never promote it. Every use remains
eligible only while current Safe Automation policy returns
`executeLocalOnly`, `notRequired`, `reversibleLocal`, and `safeLocalUndo`, and
the Capture owner finds no material, external, destructive, privacy-sensitive,
protected, fixed, unsupported, ambiguous, or another-principal consequence.
Any uncertainty requires ordinary user awareness.

### REQ-002 — The v1 eligible set is exact
Only `.archiveItem` and `.markWaiting` may be granted, and only for a current
user-owned Capture. Archive may change only that Capture to recoverable archived
state; it is not Trash or deletion. Mark Waiting may change only that Capture's
Waiting state and the exact user-authored waiting-on value/optional note shown in
the grant. It creates no contact, Reminder, notification, schedule, Goal, or
external effect.

### REQ-003 — Authority is created by explicit in-app choice
A grant becomes active only after a full in-app review names the action, each
Capture, current state, exact Waiting payload if applicable, consequence, expiry,
use limit, aggregate limit, Undo/recovery, excluded surfaces, and Pause/Revoke
controls, followed by an explicit activation action. Drafting or dismissing the
review changes no authority or target.

### REQ-004 — Authority is never inferred, inherited, or silently changed
Behavior, history, repeated confirmation, successful use, lack of correction,
automation posture, context-purpose grants, learning, platform permission, or
external discoverability cannot create, activate, renew, resume, widen, or add a
target/payload. Any action, target, payload, lifetime, or limit change creates a
new reviewable revision that is inactive until explicitly approved.

### REQ-005 — Every grant has exact bounded scope
One grant binds exactly one eligible action kind; one-to-five stable Capture IDs
and their current revisions; for Mark Waiting, a per-target exact waiting-on
value and optional note; creation/policy version; seven-day-or-earlier expiry;
and a maximum successful-use count equal to the target count. Wildcards, dynamic
membership, future objects, empty Waiting values, and more than five targets are
invalid.

### REQ-006 — Lifetime and use are deliberately finite
An active grant expires no later than seven days after activation and becomes
exhausted when every bound target has one successful use or its successful-use
limit is reached, whichever occurs first. A target can consume the grant once.
Failed/blocked/idempotent duplicate attempts do not consume a use. Expired or
exhausted authority never renews or reactivates automatically.

### REQ-007 — V1 creation and use are foreground in-app only
Grant review, activation, and consumption require the foreground Ambitions app
and an in-app Capture/You-owned context. Compact/system/external surfaces may
open the corresponding in-app review or ordinary in-app consequence
confirmation, but platform `requestConfirmation`, authentication, or invocation
does not satisfy or consume a scoped authority and cannot commit the mutation.

### REQ-008 — Every use revalidates current truth
Immediately before commit, Ambitions must re-read the current grant revision and
state, action eligibility, successful-use ledger, global aggregate budget,
target identity/revision/lifecycle/ownership, exact payload, privacy/protection,
source/actor, owner invariants, app foreground state, policy versions, and
expected Undo. A mismatch blocks automated use without target mutation.

### REQ-009 — Aggregate materiality cannot be split away
Each automated command affects exactly one Capture. Across all grants, at most
five successful automated mutations may commit in any rolling 24-hour window.
Concurrent commands, multiple grants, retries, renamed IDs, or command splitting
share the same global budget. The sixth or any owner-classified aggregate
material consequence stops automation and presents ordinary in-app grouped
review/confirmation; it cannot be processed as silent individual commands.

### REQ-010 — There is one sanctioned mutation path
Grant lifecycle changes and granted target mutations use the same local
`Command -> Event -> Projection -> Receipt -> Replay` authority as other
meaningful mutations. Grant validation/use accounting and target mutation commit
under one ordered authority boundary so neither can succeed alone, and no model,
adapter, surface, policy wrapper, or repository becomes a second executor.

### REQ-011 — Pause and revoke take effect at the authority boundary
`Pause now` immediately blocks new commits while preserving scope/history and
requires a fresh explicit review to resume. `Revoke now` is terminal for that
grant revision and invalidates pending/prepared uses. A concurrent use either
commits completely before the durable Pause/Revoke and remains in History, or
observes the newer grant revision and changes no target; there is no partial or
UI-only state.

### REQ-012 — Lifecycle and invalidity remain visible and non-reviving
The product distinguishes draft, active, user-paused, policy-held,
target-stale/missing, aggregate-held, expired, exhausted, revoked, and superseded
states. Policy/protection/privacy/version recovery never silently resumes a held
grant; the user must review current scope again. Revoked authority remains
terminal under relaunch, replay, restore, import, and clock changes.

### REQ-013 — Uses and blocks are inspectable without becoming Proof
Each successful use records grant/action/target/revision, reason, occurred-at,
use/budget position, local result, Undo/recovery availability, and resulting
Receipt/History lineage. Stale, paused, revoked, expired, exhausted,
policy/materiality, source, or privacy blocks state what did not change and the
safe next action. These records prove system handling, not user accomplishment.

### REQ-014 — Failure preserves ordinary control and honest recovery
A missing/corrupt/unavailable authority store, stale target, invalid payload,
budget race, interruption, failed commit, projection delay, or replay mismatch
cannot mutate the target, report success, consume a use, or auto-retry under new
identity. Recovery offers inspect, refresh, ordinary in-app confirmation, retry
with the same idempotency identity where safe, Pause, or Revoke as applicable.

### REQ-015 — Authority remains local and private
Grant scope, target labels, Waiting payloads, use history, and reasons are
private local data. No account, network, Source Atlas, R2, telemetry, model
context, compact payload, notification, or crash report receives them.
Diagnostics expose only versioned action/state/reason codes and coarse counts;
explicit export/deletion follows owning local data controls and never transfers
live authority.

### REQ-016 — Accessibility exposes scope, consequence, and control
VoiceOver, Voice Control, Switch Control, keyboard access, largest Dynamic Type,
Reduced Motion, RTL, non-color differentiation, and plain language expose action,
targets, Waiting payload, duration/use limits, current state, last use/block,
Undo/recovery, and Pause/Revoke in a deterministic order. Focus moves to the
result or exact blocking fact and never depends on transient animation.

### REQ-017 — Migration, replay, and version change fail closed
V1 starts with no grant and does not migrate global automation settings, prior
confirmations, policy decisions, command history, context grants, or behavior.
Grant/replay schemas are versioned; unknown/future/corrupt data is quarantined or
held with targets unchanged. Restore/import cannot reactivate authority, and
revoked/superseded records cannot become active after compaction or downgrade.

### REQ-018 — Enablement and claims are evidence gated
The v1 remains unavailable until focused tests establish both eligible Capture
mutations on the sanctioned durable command path, atomic grant-and-target commit,
replay/Undo, pause/revoke races, aggregate limits, external-surface denial,
privacy, and accessibility. Simulator/device and direct-user evidence must show
comprehension and acceptable surprise/prompt burden before release. Failure keeps
ordinary confirmation and Safe Automation policy intact.

## Acceptance criteria

- **AC-001 (REQ-001):** A matrix that changes every policy/owner safety field
  proves no grant can turn a non-eligible decision into automated execution.
- **AC-002 (REQ-002):** The complete `SafeAutomationActionKind` corpus admits
  only one-target user-owned Capture `.archiveItem` and `.markWaiting`; fixtures
  prove archive is recoverable and Waiting changes no adjacent/external state.
- **AC-003 (REQ-003):** Activate is unavailable until every required scope and
  consequence field is visible; cancel/dismiss leaves grant and target stores
  byte/fact-identical.
- **AC-004 (REQ-004):** Behavior, prior confirmation/use, global posture,
  context, learning, and platform permission canaries create or widen zero
  grants; editing any bound field requires a newly approved revision.
- **AC-005 (REQ-005):** Boundary fixtures reject zero/six targets, mixed action
  kinds, future/dynamic targets, stale revisions, wildcard payloads, and empty or
  changed Waiting values without activation.
- **AC-006 (REQ-006):** Clock/use fixtures show expiry at seven days or earlier,
  one successful use per target, exact exhaustion, no count for safe failures or
  duplicates, and no automatic renewal/resume.
- **AC-007 (REQ-007):** Widget, App Intent, Shortcut, notification, Live
  Activity, deep-link, external actor, and background fixtures produce only
  in-app routing/ordinary review and zero granted commits.
- **AC-008 (REQ-008):** Changing each grant/target/policy/privacy/protection/
  actor/source/foreground/payload/budget fact between preparation and commit
  blocks target mutation and records the exact stale reason.
- **AC-009 (REQ-009):** Parallel, split-command, multi-grant, retry, and rolling-
  window tests commit at most five successes in 24 hours and route the remainder
  to one ordinary grouped review without partial application.
- **AC-010 (REQ-010):** Mutation-path audit and integration tests find one
  authority transaction containing the grant-use and target Event/Projection/
  Receipt/replay lineage and no direct or pre-authority write.
- **AC-011 (REQ-011):** Deterministic race tests prove each use is wholly before
  Pause/Revoke or wholly rejected after it; Pause blocks immediately, resume
  requires review, and revoked authority never commits again.
- **AC-012 (REQ-012):** Every lifecycle/hold state renders distinctly; policy or
  protection recovery leaves held grants inactive until explicit review, and
  relaunch/replay cannot revive terminal states.
- **AC-013 (REQ-013):** Success and every named block produce accurate local
  inspection with scope, counts, what changed/did not, Undo/recovery, and no
  user-Proof claim.
- **AC-014 (REQ-014):** Fault injection at every preparation/authority/
  projection/replay phase yields no false success, no accidental use count, no
  new retry identity, and an exact safe recovery action.
- **AC-015 (REQ-015):** Private canaries from target labels and Waiting payloads
  appear nowhere in network, logs, metrics, crashes, models, compact payloads, or
  notifications; offline use remains complete.
- **AC-016 (REQ-016):** Automated accessibility checks plus simulator/device
  review cover every state and action at accessibility sizes with ordered labels,
  focus recovery, non-color parity, and no gesture-only control.
- **AC-017 (REQ-017):** Empty install, relaunch, replay, compaction, restore,
  import, corruption, future schema, and downgrade fixtures never invent or
  reactivate authority and preserve truthful minimized terminal history.
- **AC-018 (REQ-018):** Feature enablement fails closed until every named hard
  gate is independently satisfied; documentation and UI distinguish source,
  build, simulator, device, accessibility, approval, and release evidence.

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

Implementation would add an owning Scoped Automation Authority system contract
and update the Private Life Runtime, persistence/replay, privacy/data
classification, Capture, You, Trust inspection, external-entry, degraded-state,
testing, security/privacy, accessibility, and validation contracts. Existing
Force Nothing, material confirmation, local authority, mutation sequence, Goal
automation posture, context-purpose grants, and external-action authorization
remain ceilings; none is replaced or weakened.

## Risks and open decisions

The exact product decisions needed for Design are resolved: eligible actions,
Capture-only target type, one-to-five exact targets, exact Waiting payload,
seven-day lifetime, one use per target, five-use rolling global budget,
foreground in-app-only consumption, no inference, immediate Pause/Revoke, and
ordinary confirmation fallback.

Remaining risks are evidence questions rather than hard forks. The eligible
Capture actions may not create enough repetitive burden to justify the grant UI;
direct-user evaluation may therefore keep v1 unavailable or remove it. Existing
Capture durable lineage is unproven and must pass REQ-018 before enablement. The
current unrelated `.createReminder` action-kind mismatch remains outside Scope
and cannot be repaired by widening this initiative.

Review verdict: **PASS** after resolving the exact v1 eligibility set, target
and payload bounds, seven-day/five-use limits, cross-grant materiality, in-app-
only boundary, revalidation, Pause/Revoke ordering, and proof gates. Devan
delegated phase approval; Scope approved 2026-08-05.
