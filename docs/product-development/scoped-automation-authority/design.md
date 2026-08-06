+++
initiative = "scoped-automation-authority"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add one local canonical `ScopedAutomationGrant` aggregate beneath the existing
Safe Automation policy and inside LocalRuntimeOS authority. A grant contains one
eligible action, one-to-five exact Capture bindings, current target revisions,
exact per-target Waiting payloads where applicable, a seven-day-or-earlier
expiry, one use per target, and a maximum use count equal to the target count.
A singleton local materiality aggregate enforces five successful granted
mutations across all grants in any rolling 24 hours.

Activation never mutates a target. The only v1 execution trigger is the user's
in-app `Run allowed upkeep` or `Continue` action from the full grant review/detail
while Ambitions is foregrounded. A coordinator submits one exact Capture command
at a time. Every command re-enters runtime preparation, current Safe Automation
evaluation, owner validation, and atomic authority acceptance. Relaunch,
foreground return, a compact surface, a model, or a timer never starts or resumes
execution.

Grant creation, lifecycle, successful-use accounting, target mutation,
materiality accounting, Receipt, Projection, and Replay use the sanctioned
LocalRuntimeOS path. `PolicyGuardedCommandExecutor` remains only a compatibility/
test seam; it is not grant storage or a second executor. Existing direct user
commands remain user commands and do not need a grant.

The feature is unavailable by default until the approved proof gates pass. This
Design specifies intended behavior and architecture; it is not implementation,
runtime, accessibility, device, or release proof.

## User flows

### 1. Create and activate in Capture

1. In the foreground Capture experience, the user explicitly chooses **Allow
   limited upkeep**. Ambitions never raises this from inferred behavior.
2. The user chooses Archive or Mark Waiting, then selects one-to-five current
   Captures. Mixed actions and dynamic/future selectors are impossible.
3. Archive preview says only that each selected Capture can become recoverably
   archived. Mark Waiting requires an exact non-empty waiting-on value for each
   target and allows an exact optional note; no value is generated or inherited.
4. The full review orders action, named targets/current state, exact Waiting
   payload, seven-day expiry, one use per target, per-grant count, global five-
   per-24-hour limit, what will never change, Undo/recovery, in-app-only rule,
   and `Pause now`/`Revoke now` availability.
5. **Activate limited authority** commits only the grant Event, Projection,
   Receipt, and replay state. Cancel/dismiss leaves grant and target stores
   unchanged. Success focuses the active status and `Run allowed upkeep`.

### 2. Run allowed upkeep

1. The user opens the active grant and selects **Run allowed upkeep**. If some
   targets were already consumed, **Continue** applies only to pending bindings.
2. The coordinator creates one deterministic use ID from grant ID/revision and
   target-binding ID and submits one typed Capture command with actor `.system`,
   source `.capture`, exact expected target revision, and a typed authority claim.
3. Runtime preparation re-reads grant, target, policy, protection/privacy,
   materiality, foreground, owner, and payload truth. A passing preparation
   commits grant-use, materiality-use, Capture mutation, Receipt, History, and
   projection inputs atomically.
4. The detail updates the target row to Used and announces the exact result and
   Undo. The next pending target does not start until the preceding terminal
   result is visible. `Pause now` and `Revoke now` remain available between uses.
5. When every binding is consumed, the grant becomes Exhausted. It never
   renews. A duplicate use ID returns the prior result without another mutation
   or count.

### 3. Stale, held, or material use

If any current fact differs, the target does not change. The row shows the exact
reason: target changed/missing, policy changed, protected/private state,
different Waiting payload, wrong source/actor, app not foreground, grant paused/
expired/revoked, or aggregate limit. The user can inspect current truth, use the
ordinary in-app consequence confirmation, pause, revoke, or create a newly
reviewed grant revision. A policy-held or stale grant never resumes itself.

The sixth successful granted mutation in a rolling 24 hours—or an earlier owner
materiality decision—stops the run before that mutation and offers one ordinary
in-app grouped review for the remaining current targets. Accepting that review
uses ordinary user confirmation, not the grant, and does not raise the global
grant budget.

### 4. Pause, resume, and revoke

- **Pause now** commits immediately, invalidates pending preparations, retains
  scope/history, and focuses Paused. **Review and resume** rebuilds the current
  consequence review and activates a new grant revision only after approval.
- **Revoke now** commits terminal revocation with a plainly labeled consequence,
  invalidates pending preparations, and focuses Revoked. It has no Unrevoke; a
  new authority requires a new review.
- A concurrent use is linearized at authority commit: it is wholly committed
  before Pause/Revoke and remains in History, or it observes the newer grant
  revision and changes no target/use count. No UI-only cancellation is claimed.

### 5. Interruption and relaunch

Backgrounding stops scheduling new uses. An already accepted atomic transaction
finishes or fails according to runtime authority; it is never guessed from UI.
On return/relaunch, replay reconstructs grant, use, target, materiality, and
Receipt truth. The detail says **Ready to continue**, **Needs review**, or the
terminal state; the user must select Continue. Projection delay shows Updating
from committed authority evidence and repairs by replay without retrying the
mutation.

### 6. Compact and external entry

Widget, App Intent, Shortcut, Siri, notification, Live Activity, deep link,
Spotlight, Control Center, and external actor requests cannot include or consume
an authority claim. They may open the in-app grant detail or ordinary Capture
consequence preview after full target/authorization revalidation. Apple
`requestConfirmation` is platform confirmation evidence, not scoped authority,
and does not commit a v1 granted mutation.

### 7. Inspect result and Undo

You's existing **Privacy & automation** destination gains an Active/Needs review/
Ended list rather than a new root. Detail shows scope, remaining uses, rolling
budget, expiry, last result/block, Receipts, and Pause/Revoke. A use Receipt links
to the current Capture owner for supported Undo. Undo is a separate user command;
it neither restores a consumed use nor reactivates authority.

## States and recovery

### Grant and binding state

`ScopedAutomationGrantState` is `active`, `pausedByUser`, `held`, `expired`,
`exhausted`, `revoked`, or `superseded`. Draft is non-durable review state.
`ScopedAutomationHoldReason` distinguishes `policyChanged`, `targetStale`,
`targetMissing`, `targetProtected`, `privacyChanged`, `principalChanged`,
`payloadChanged`, `sourceOrActorDenied`, `foregroundUnavailable`,
`aggregateMateriality`, `clockRollback`, `schemaUnsupported`, and
`authorityUnavailable`.

Each `ScopedAutomationTargetBinding` is `pending`, `preparing`, `consumed`,
`blocked`, `stale`, or `missing`. Preparing is transient UI derived from a
preparation ID; only committed authority events make Consumed durable. A blocked
binding retains the prior target and use count.

### Use and failure state

`ScopedAutomationUseResult` is `committed`, `unchangedDuplicate`, `blocked`, or
`failedSafely`. Block/failure stores a bounded reason and recovery, not target
content. Store unreadable/corrupt, unsupported schema, clock rollback, stale
revision, materiality race, commit failure, or replay mismatch holds the grant
and makes no target mutation. Retry reuses the same use ID only when inspection
proves no accepted transaction; otherwise replay/reconciliation resolves truth.

The effective clock is `max(currentWallClock, lastDurableAuthorityObservation)`.
A backward wall-clock change cannot extend or revive authority; it creates a
clock hold requiring review. Expiry is terminal for the revision. Forward clock
movement can expire but never skip a committed Receipt.

### Recovery invariants

- Grant activation failure leaves no active grant.
- Use acceptance is all-or-nothing across grant count, materiality count,
  Capture mutation, Event, Receipt, and replay input.
- A projection failure after accepted authority never causes command retry; it
  shows Updating and replays the accepted event.
- Corrupt/future grant data is quarantined/held with targets unchanged.
- Revoked, expired, exhausted, and superseded revisions cannot be resumed by
  replay, restore, import, compaction, downgrade, or policy recovery.
- Manual confirmation remains available from freshly resolved owner truth.

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
- Experience authority: Task 7 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Canonical models

Add local runtime types under
`Native/Ambitions/Core/LocalRuntimeOS/AutomationAuthority/`:

- `ScopedAutomationGrantModels.swift`: identifiers, grant/revision/state/hold,
  target binding, exact Waiting payload, policy fingerprint, timestamps, limits;
- `ScopedAutomationUseModels.swift`: typed authority claim, deterministic use
  identity, result/reason/recovery, and minimized receipt input;
- `ScopedAutomationAuthorityPolicy.swift`: the exact v1 allowlist and all
  hard-ceiling/scope/foreground/source/actor/payload checks;
- `ScopedAutomationAuthorityRepository.swift`: canonical query interface and
  in-memory test repository;
- `ScopedAutomationAuthorityCoordinator.swift`: user-started sequential run,
  interruption, Pause/Revoke invalidation, and no-auto-resume behavior; and
- `ScopedAutomationAuthorityProjection.swift`: active/held/ended lists and
  privacy-safe detail state for Capture, You, and Trust.

`ScopedAutomationGrant` stores schema version, stable grant ID, revision,
action kind, one-to-five bindings, activation/expiry, max/successful uses,
state/hold, Safe Automation and owner-policy fingerprints, and last durable
observation. A binding stores stable Capture ID, expected revision, one-use
status, and for Mark Waiting the exact local waiting-on/optional-note payload and
digest. Target display names are resolved from current Capture projections, not
copied into receipts or diagnostics.

`ScopedAutomationMaterialityState` is one local singleton aggregate containing
only successful use IDs, action codes, and timestamps needed for the rolling
24-hour window. Compaction retains enough ordered evidence to reproduce the
window exactly; it cannot reset the count early.

### Commands and authority integration

Add typed grant lifecycle operations (`activate`, `pause`, `resumeAsNewRevision`,
`revoke`) and an optional `ScopedAutomationAuthorityClaim` to the versioned
runtime command envelope. The claim contains grant ID/revision, binding ID, use
ID, action kind, target ID/revision, payload digest, and policy fingerprint; it
contains no wildcard or external bearer capability.

`SafeAutomationProposedAction.fromCommand` remains the action/target adapter.
For actor `.system`, a Capture archive/waiting mutation is denied unless an exact
claim is present and current; actor `.user` remains ordinary explicit control;
actor `.externalSurface` is denied. The static evaluator must pass before grant
evaluation. The Capture owner reducer then proves archive/waiting semantics and
creates a complete read/write set.

`RuntimeMutationPreparationService` reads the grant, target, and materiality
aggregate revisions into one preparation. `RuntimePreparationAuthorizer`
validates the claim and records the exact authorization reasons. Submission to
the existing mutation authority atomically accepts:

1. one grant-use event and updated grant projection;
2. one rolling-materiality event/projection;
3. one existing typed Capture mutation event/projection;
4. one automatic system Receipt/History lineage; and
5. replay/idempotency evidence keyed by the deterministic use ID.

If the current authority transaction cannot coordinate all five, the use is
unsupported rather than partially implemented. Direct `CaptureRepository`
writes, `DefaultCaptureService` pre-authority mutation, metadata-string claims,
and a grant-aware `PolicyGuardedCommandExecutor` are prohibited.

### UI ownership

- `CaptureComposerSurface` owns target selection and the full grant review/run
  entry because the only v1 targets are Captures.
- `CaptureViewModel` requests previews/commands through a scoped authority
  client; it never changes grant or target repositories directly.
- You's existing `.automationTrust` route owns searchable aggregate control and
  inspection. `YouFeatureServicePolicyCenterProjection` incorporates the local
  authority projection without turning You into an activity dashboard.
- Trust/Receipt inspection presents each committed use or safe block and routes
  Undo to Capture. It is not a grant store or mutation owner.
- App/extension routing strips/rejects authority claims and foregrounds the
  in-app owner context.

### Persistence, migration, export, and deletion

Add grant/materiality aggregate families, semantic event kinds, projection
records, command codec fields, atomic transaction rows, replay reducers, store
invariant checks, and the next canonical runtime storage generation. New install
starts empty. No AutomationLevel, policy decision, SideEffectLedger record,
command history, context grant, or prior confirmation migrates.

Unknown/future/corrupt records are quarantined or held. Import/export may carry
minimized documentary history only and always imports it terminal/inactive; it
cannot carry a live claim. Revocation is not deletion. Explicit local-data purge
removes Waiting payloads and grant/use detail under owning retention law while
retaining only non-reactivating tombstone/Receipt lineage required for honest
history. No CloudKit, account, Source Atlas, R2, or external store participates.

## Privacy and accessibility

Grant records use the same protected local storage and private-data boundary as
Captures. Waiting-on values/notes never enter diagnostics, telemetry, model
context, crash output, notification text, Spotlight, widget/App Intent payloads,
or app-switcher previews. Logs contain only schema, action/state/reason codes,
coarse counts, and redacted fingerprints. No network permission or account is
requested; offline behavior is complete.

Creation and detail semantics read in this order: authority state; action;
targets/current status; exact Waiting payload; consequence/unchanged facts;
expiry; per-target/use and global budget; source boundary; Undo/recovery;
Activate/Run/Pause/Revoke. Target lists reflow vertically at largest Dynamic
Type. VoiceOver announces progress and terminal result without stealing focus
from the active row. Voice Control, Switch Control, keyboard, and named buttons
provide parity; no swipe, color, icon, position, timing, or animation is required.
Reduced Motion uses immediate state replacement. RTL mirrors layout but not
semantic order. Errors focus the first exact blocking fact; success focuses the
committed result. Revoke uses an explicit destructive-style label for the grant
only and never implies Capture deletion.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Static evaluator first; owner/material/privacy/principal ceilings rechecked at commit |
| REQ-002 | Exact two-action Capture allowlist and operation-specific reducer constraints |
| REQ-003 | Full Capture-owned in-app review; activation commits grant only |
| REQ-004 | No inference inputs; every bound-field change creates inactive new revision |
| REQ-005 | Typed one-action grant with 1–5 exact revision/payload bindings |
| REQ-006 | Seven-day expiry, one use per target, deterministic exhaustion/no renewal |
| REQ-007 | User-started foreground run; external claim rejection and in-app routing |
| REQ-008 | Grant/target/policy/materiality/privacy/source read set and commit revalidation |
| REQ-009 | Singleton rolling materiality aggregate and one-target sequential commands |
| REQ-010 | Runtime preparation/atomic authority transaction; no second executor/write |
| REQ-011 | Revision-linearized Pause, reviewed resume revision, terminal Revoke |
| REQ-012 | Explicit state/hold enums and no automatic recovery-to-active transition |
| REQ-013 | Use/block Receipt projection with minimized system-proof semantics |
| REQ-014 | Fail-safe outcomes, stable idempotency, replay instead of uncertain retry |
| REQ-015 | Protected local storage, redacted observability, inactive documentary export |
| REQ-016 | Ordered native semantics, AT parity, focus and Dynamic Type contracts |
| REQ-017 | Empty migration, version quarantine, terminal replay/restore/import rules |
| REQ-018 | Default-off enablement and independent source/build/runtime/a11y/device gates |

## Verification design

- **Automated:** exhaustive action-kind/policy/owner matrix; grant bounds;
  deterministic IDs; expiry/use/materiality windows; inference canaries; command
  codec; repository; reducer; atomic commit; fault injection; idempotency;
  pause/revoke races; replay/compaction; external-source denial; Undo linkage.
- **Build:** changed-scope iOS build and focused test target after implementation;
  this document supplies no passing build evidence.
- **Runtime/UI:** simulator inspection of create/cancel/activate/run/continue/
  pause/resume/revoke, all holds, grouped fallback, projection delay, relaunch,
  no-auto-resume, and ordinary user-command parity.
- **Accessibility:** automated identifiers/labels plus VoiceOver, Voice Control,
  Switch Control, keyboard, largest Dynamic Type, Reduced Motion, RTL, non-color,
  focus, and privacy-announcement review on simulator and device.
- **Privacy/security:** private canaries, network deny, logs/crashes/diagnostics/
  model/compact payload scans, claim tampering, actor/source spoofing, clock
  rollback, schema corruption, command/grant splitting, and race attacks.
- **Migration/replay:** empty install, next-generation migration, restart,
  projection rebuild, compaction during a rolling window, restore/import,
  deletion terminality, future schema, corruption, and downgrade.
- **Performance:** bounded five-target preparation and 24-hour materiality lookup
  measurements; no main-thread storage/crypto work, unbounded event scan, or
  progress animation required for correctness.
- **Device/direct user:** physical-device protected-data/background/foreground
  behavior and direct-user comprehension of scope, five/24-hour aggregate,
  Pause/Revoke, blocks, and ordinary confirmation. No release claim until every
  affected category is evidenced independently.

## Open decisions

None. The execution trigger, eligible actions, target/payload scope, numeric
limits, state machine, linearization, sanctioned authority path, migration,
privacy, accessibility, compact/external behavior, and enablement gates are
resolved. If direct-user evidence shows insufficient value, the resolved action
is to keep v1 unavailable or remove it, not widen authority.

Review verdict: **PASS** after confirming the exact two-action allowlist,
foreground user-started trigger, current-revision revalidation, atomic grant/
materiality/target transaction, Pause/Revoke linearization, fail-closed replay,
private local storage, external-surface denial, accessibility, and independent
enablement gates. The existing `.createReminder` adapter drift remains an
explicit unrelated baseline blocker and cannot be treated as proof for this
initiative. Devan delegated phase approval; Design approved 2026-08-05.
