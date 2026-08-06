+++
initiative = "scoped-automation-authority"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions is meant to adapt, recover, and coordinate useful work while the user
remains the final authority over meaningful consequences. Current Safe
Automation policy can classify a proposed action as suggest-only, draftable,
confirmation-required, locally executable, prohibited, or unsupported. That is
a hard policy ceiling, but it does not answer a separate question: “May
Ambitions perform this exact low-risk local operation for these exact objects,
under a small limit, until I pause or revoke it?”

Without bounded delegation, Ambitions either repeats confirmation for an
equivalent minor operation or relies on broad automation modes that cannot
express action, object, consequence, time, and use boundaries. Repeated prompts
can become reflexive; broad settings can imply more authority than the user
intended. Permission inferred from behavior, silence, prior success, a prior
confirmation, a context-purpose grant, or a global automation level would
violate the product's user-control laws.

The research problem is whether an explicit, local, revocable, tightly scoped
authority can reduce low-value confirmation without becoming a second command
system, widening a static policy decision, hiding aggregate materiality, or
letting compact/system surfaces act with less context than the in-app product.

## Current truth

This Research inspected repository `main` at
`f6d870d6cbbf688b2ead47a34d4381fb75367786`, current canon, live source, tests,
and approved adjacent product-development initiatives.

### Canon and adjacent authority

- `CONTROL-FORCE-NOTHING-001` permits scheduling only within granted authority,
  requires delegated authority to remain withdrawable, and defines automation
  as revocable permission rather than ownership.
- `CONTROL-MATERIAL-CONFIRMATION-001` permits an exception to per-action
  confirmation only for the exact class of change explicitly authorized under a
  clear, revocable rule. Uncertain materiality resolves toward user awareness.
- `CONST-RUNTIME-MUTATION-001`, `RUNTIME-MUTATION-SEQUENCE-001`, and
  `LAW-LOCAL-AUTHORITY-001` require every meaningful automated mutation to use
  the same local `Command -> Event -> Projection -> Receipt -> Replay` authority
  and remain fully functional without hosted decision authority.
- Goal and You canon expose broad automation posture, but no current canon type
  defines a durable grant identity, exact action/target scope, expiry, use
  budget, pause, revocation, or atomic use record.
- Personal Context and Constraint Controls owns purpose-limited permission to
  read context. Its approved Scope explicitly says context never becomes action
  authority.
- External Action Integration Orchestration separates provider/system
  connection from exact action authorization. It does not grant local semantic
  authority, and this initiative does not grant external authority.
- Adaptive Local Learning and Replanning permits evidence to create candidates,
  not active influence or mutation. Behavior therefore cannot create, renew, or
  widen an automation authority.

### Live Safe Automation and command seams

`SafeAutomationPolicyModels.swift` declares 30 action kinds and the fixed
permission, confirmation, safety, Undo, reason, and receipt classifications.
`SafeAutomationProposedAction.swift` maps typed commands to those action kinds.
The evaluator classifies several actions as `executeLocalOnly`, but that result
means only “below the static ceiling”; it is not evidence of a standing grant.

`PolicyGuardedCommandExecutor.swift` demonstrates a policy guard around a base
executor, while `RuntimeMutationPreparationService.swift` and
`RuntimePreparationAuthorizer` provide the newer revision-, actor-, privacy-,
confirmation-, and authority-aware preparation seam. Production container
construction does not instantiate `PolicyGuardedCommandExecutor`, and
`PreparedMutationCommandExecutor` currently prepares without committing an
authority transaction. A future grant must therefore constrain the sanctioned
runtime preparation/commit path rather than rely on the policy wrapper or create
another executor.

Current focused tests establish useful but bounded evidence:

- `SafeAutomationPolicyModelsTests/
  testSafeLocalActionAllowsFutureLocalExecutionAndUndoWithoutExecutingAnything`
  classifies a targeted `.archiveItem` as local, reversible, and below the hard
  ceiling without claiming that anything executed.
- `PolicyGuardedCommandExecutorTests/
  testLocalReversibleMutationDelegatesWithoutPreAuthorityLedgerArtifact` proves
  local archive delegation only at that isolated executor seam.
- `AmbitionsCommandExecutorPolicyTests/
  testRouteCommitmentAndWaitingCommandsUseCaptureRouteModel` proves a user
  command can mutate a Capture into Waiting through the current capture service.
- `SafeAutomationPolicyModelsTests/
  testCommandAdapterMapsExistingCommandKindsToPolicyActions` maps
  `.markWaiting` and `.archiveItem` commands to the corresponding Safe Automation
  action kinds.
- External-source, broad-reflow, Calendar, export, deletion, forgetting,
  attachment, missing-target, and unsupported tests demonstrate fail-closed or
  confirmation-gated boundaries.

The proof ceiling is explicit: `MeaningfulMutationRegistry.swift` still labels
the reachable Capture archive and Waiting paths `unproven`, and labels archived
state without row-specific durable lineage proof. The Safe Automation command
adapter also refers to `.createReminder`, which the current action-kind enum does
not declare. That unrelated baseline drift excludes Reminder from this
initiative and prevents source inspection from being described as build,
runtime, replay, accessibility, device, or release proof.

No current source type represents a durable user-authored automation authority,
its lifecycle, a successful-use budget, or an atomic authority-and-target commit.
A static `executeLocalOnly` result, a system actor, or a prior confirmation is
not reusable authority.

## Evidence

Repository evidence supports both a bounded experiment and a strict safety
boundary:

- canon expressly distinguishes capability from revocable user authority;
- current action policy already separates local/reversible actions from broad,
  external, destructive, privacy-sensitive, and unsupported actions;
- current tests provide two concrete Capture candidates—`.archiveItem` and
  `.markWaiting`—without supporting a broader eligible set;
- command preparation already carries actor, source, privacy, target, expected
  revision, idempotency, confirmation, read-set, and recovery concepts that a
  grant can further constrain; and
- receipts, replay, and current-revision checks provide seams for truthful use,
  stale rejection, and immediate revocation races, although they do not yet
  prove those outcomes for these Capture actions.

Apple's current [`AppIntent`](https://developer.apple.com/documentation/appintents/appintent)
contract makes actions discoverable to Siri, Shortcuts, Apple Intelligence, and
other system experiences and separately provides `requestConfirmation` APIs.
Discoverability is therefore a capability surface, not Ambitions authority.
Apple's [WidgetKit interactivity](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
contract also executes App Intents from a separate compact context. Those
platform capabilities support an in-app-only v1: widgets, App Intents,
notifications, deep links, Shortcuts, Live Activities, and other compact/system
surfaces may route to in-app review or ordinary confirmation, but cannot create
or consume a grant.

NIST SP 800-53 AC-6 provides primary least-privilege evidence for limiting
standing authority to the minimum operation and scope necessary:
<https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final>. Ambitions should apply the
principle without importing enterprise-access-control language into the product.

The minimum useful evaluation is not a schema or unit test alone. It must compare
ordinary confirmation with explicit scoped authority for a tiny eligible set
and measure comprehension, surprise, correction, pause/revoke latency, stale
target rejection, command/grant splitting, aggregate materiality, privacy,
accessibility, and truthful recovery. It must retain the current confirmation
path as the control and fallback.

## Alternatives

1. **Confirm every meaningful action.** This remains the safe fallback and the
   correct behavior whenever authority is absent, stale, paused, revoked,
   exhausted, ambiguous, or above the hard ceiling. It preserves maximum
   awareness but may create avoidable prompt burden for exact minor operations.
2. **Use only global Manual, Guided, or Adaptive posture.** This is easy to
   summarize but cannot bind exact actions, targets, revisions, payloads, time,
   use count, source surface, or aggregate consequence. Reject as authority.
3. **Add explicit, expiring, use-bounded local authority beneath the static
   ceiling.** This can be inspectable and immediately withdrawable while keeping
   ordinary confirmation as fallback. It adds lifecycle, atomicity, and UI cost
   and must remain deliberately small. Recommend for bounded v1 evaluation.
4. **Infer authority from behavior, silence, or prior confirmation.** This may
   reduce prompts but conflicts with canon and the approved learning boundary.
   Evidence may suggest an in-app review; it cannot create, renew, or widen a
   grant. Reject.
5. **Reuse context-purpose grants, platform permission, or App Intent
   discoverability.** These authorize data use or expose capability, not a local
   mutation. Combining them would blur privacy and action authority. Reject.
6. **Build a parallel automation executor or background agent.** This would
   bypass the sanctioned command path and complicate revocation/replay truth.
   Reject.

## Unknowns and risks

- `.archiveItem` and `.markWaiting` are the only current candidates with both
  Safe Automation classification and focused test evidence, but their real
  prompt-reduction value still needs direct-user/runtime evaluation.
- Even individually reversible changes can become material when commands,
  grants, targets, or time windows are split. A single global aggregate budget
  must fail closed rather than evaluating each command in isolation.
- A grant detailed enough to be safe may create more anxiety or administration
  than ordinary confirmation. If comprehension or value fails, the v1 should be
  removed without weakening static policy.
- Pause/revoke concurrent with preparation or commit requires one deterministic
  ordering and atomic revalidation; UI state alone cannot stop an in-flight use.
- Target, grant, policy, privacy, protection, ownership, payload, or app-version
  changes can invalidate authority. Invalidity must never silently recover into
  active authority.
- Authority history is private life data. Diagnostics must not reveal target
  names, waiting metadata, notes, or graph relationships.
- Existing Capture mutation lineage is explicitly unproven. Implementation must
  first establish honest current-revision commit, Receipt, replay, and Undo
  behavior before any automated use is enabled.
- Compact/system surfaces have less context and separate execution semantics.
  Letting them consume an in-app grant would erase the review boundary.
- The current `.createReminder` source mismatch is an implementation-baseline
  concern, not a reason to widen this initiative or include Reminder.

No unresolved product hard fork blocks Scope. The recommended v1 can select an
exact Capture-only eligibility set, conservative numeric limits, in-app-only use,
and confirmation fallback while direct-user value remains an evidence gate.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Composer/Capture/ScopedAutomationReviewSurface.swift`.
- Evidence and unknowns: Repository audit identifies Task 7 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Proceed to Scope with a **scoped automation authority** below every current
Safe Automation and owner policy ceiling and inside the sanctioned local command
path. Scope should evaluate only `.archiveItem` and `.markWaiting`, each against
one current user-owned Capture at a time, because current source and tests do not
support a wider v1 claim.

The authority should be explicitly created in the full in-app experience; bind
action kind, exact Capture identities and revisions, exact consequence payload
where applicable, expiry and successful-use limits; never be inferred, renewed,
or widened; count split commands against one aggregate materiality budget; and
support immediate pause and terminal revocation. Every use must re-evaluate the
static policy, owner invariants, grant revision, target revision, protection,
privacy, actor/source, budget, and aggregate effect immediately before atomic
commit through `Command -> Event -> Projection -> Receipt -> Replay`.

Missing, stale, paused, revoked, exhausted, policy-held, external/compact, broad,
destructive, privacy-sensitive, another-principal, unsupported, or ambiguous
conditions fall back to ordinary in-app preview/confirmation or fail safely.
The grant does not trigger work by itself and is not a model/tool/background
permission. Scope must preserve the explicit implementation and release proof
ceiling.

This Research authorizes no implementation, migration, external execution, or
autonomous behavior.

Review verdict: **PASS** after repair of repository identity, runtime proof
ceiling, current test grounding, aggregate-materiality risk, and in-app-only
platform boundaries. Devan delegated phase approval; Research approved
2026-08-05.
