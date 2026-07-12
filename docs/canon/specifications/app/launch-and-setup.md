+++
spec_id = "APP-LAUNCH-SETUP"
title = "Launch and Progressive Setup"
kind = "app"
status = "normative"
owner_domain = "app-launch-setup"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "account.launch-commitment",
  "app.launch.readiness",
  "app.launch.recovery",
  "app.setup.interruption-resume",
  "app.setup.progressive-first-use",
  "app.setup.state",
  "app.setup.progress",
]
inherits = [
  "MISSION-LAUNCH-BAR-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "LAW-ACCOUNT-BOUNDARY-001",
  "CONTROL-FORCE-NOTHING-001",
  "LAW-RUNTIME-DURABLE-SUCCESS-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/DesignSystem/StagePrimitives/SharedUI/",
  "Native/Ambitions/Core/LocalRuntimeOS/Boundary/",
  "Native/Ambitions/Core/LocalRuntimeOS/Repair/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
+++

# Launch and Progressive Setup



## APP-ACCOUNT-LAUNCH-001 — Optional account support ships at launch

- **Concept:** `account.launch-commitment`
- **Modality:** `MUST`
- **Scope:** Launch account availability and no-account product entry
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-ACCOUNT-OPTIONAL-001`
- **Supersedes:** none

Ambitions Account support MUST be available at launch while remaining optional. The user MUST be able to enter and use the complete local core without creating or signing into an account; account availability does not weaken the local-authority, private-data, or network boundaries.

Ambitions Account MAY support Sign in with Apple, Google Sign-In, identity, entitlement, approved recovery/support, and future approved services.

Ambitions Account MAY support continuity, sync, and account-backed capabilities but MUST NOT gate the local core.

Ambitions Account MUST NOT gate Today, Goals, Time, Capture, Search, or local data.

Ambitions Account MUST NOT gate the local core or become the private-graph backend.

Ambitions Account MAY support identity, entitlements, approved recovery or support, and non-sensitive service state.

Account status and sign-out consequences MUST be explicit.

## APP-SETUP-PROGRESSIVE-FIRST-USE-001 — Local core precedes optional setup

- **Concept:** `app.setup.progressive-first-use`
- **Modality:** `MUST`
- **Scope:** First launch and later setup continuation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-FIRST-USE-001`, `SCENARIO-APP-SETUP-SKIP-001`
- **Supersedes:** none

First use MUST open a useful local core before account sign-in or optional network access. Setup asks only for context that improves the next useful action, saves each accepted answer durably, permits every nonessential question to be skipped, and keeps skipped work reachable later through the owning You setup surface. Account, notification, calendar, reminders, speech, health, and other optional integrations are requested only when their value is contextual and their denied fallback is already defined.

Setup may encourage a first Goal and may preview a first Path when enough information exists; it cannot require either before the local app becomes usable. It must not present a long mandatory permission wall, chatbot center, or static completion checklist as the product.

Ambitions MUST open to usable product value immediately and MUST prompt setup only when needed.

Onboarding SHOULD be a conversational guided interview.

Onboarding MUST use chapters.

Onboarding SHOULD recommend adding a first goal but allow skipping.

Ambitions SHOULD ask questions that quickly improve pathing.

## APP-LAUNCH-READINESS-001 — Launch gate protects durable local readiness

- **Concept:** `app.launch.readiness`
- **Modality:** `MUST`
- **Scope:** Cold launch, warm launch, relaunch, and restored local session
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-LAUNCH-READY-001`, `SCENARIO-APP-LAUNCH-DEGRADED-001`
- **Supersedes:** none

Launch MUST establish enough local readiness to avoid presenting a false usable state: readable local authority, a valid app/navigation root, and a safe path for pending repair or recovery. Optional account, sync, R2, Source Atlas, permission, and external-source checks cannot block entry to the healthy local core. A launch indicator may communicate real bounded work;

Skipping onboarding MUST NOT block the app.

## APP-LAUNCH-RECOVERY-001 — Launch failure offers repair without destructive reset

- **Concept:** `app.launch.recovery`
- **Modality:** `MUST`
- **Scope:** Local-store unavailability, migration failure, replay failure, incomplete setup recovery, and interrupted launch
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-LAUNCH-REPAIR-001`, `PROOF-APP-LAUNCH-NO-DATA-LOSS-001`
- **Supersedes:** none

When safe local readiness cannot be established, launch MUST distinguish retryable delay, repairable local degradation, quarantined data, and a stop-ship risk of silent loss. It preserves accepted data and setup progress, offers bounded retry, repair preview, export, or diagnostics as applicable, and never defaults to destructive reset. A reproducible silent-loss path remains governed by `LAW-DATA-LOSS-STOP-SHIP-001`.

## APP-SETUP-RESUME-001 — Setup interruption never loses accepted progress

- **Concept:** `app.setup.interruption-resume`
- **Modality:** `MUST`
- **Scope:** Skip, cancellation, app interruption, crash, relaunch, and later continuation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SETUP-RESUME-001`, `SCENARIO-APP-SETUP-PARTIAL-001`
- **Supersedes:** none

Each accepted setup answer MUST persist before the next question is presented. Interruption restores the last durable setup state and preserves already entered context. Skip records no invented answer and leaves core use available. Later edits identify affected settings or paths and route material consequences through confirmation and the constitutional mutation sequence.

## APP-SETUP-STATE-001 — Setup progress reflects useful context

- **Concept:** `app.setup.state`
- **Modality:** `MUST`
- **Scope:** Setup chapter availability, progress, completion, and revision
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SETUP-PROGRESS-001`, `AUDIT-APP-SETUP-NONCOERCION-001`
- **Supersedes:** none

Setup state MUST distinguish not started, in progress, skipped, sufficient for local use, and revisitable. Any displayed progress reflects the weighted usefulness of durable accepted context rather than pressuring completion through raw question count. Completion does not grant permissions, create an account, enable continuity, or prove that a first path was generated unless the owning flow separately commits and proves that result.

## APP-SETUP-PROGRESS-001 — Setup progress

- **Concept:** `app.setup.progress`
- **Modality:** `MUST`
- **Scope:** First-use setup
- **Status:** `normative`
- **Verification:** `SCENARIO-SETUP-PROGRESS-001`
- **Supersedes:** none

Setup MUST disclose bounded progress for work that is not immediate, remain resumable, and never block useful local entry on network availability.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Launch and setup have bounded owners with no authority over product objects or external services.

Launch owns local readiness gating and entry to safe recovery. Progressive setup owns skippable context collection, durable progress, and later continuation. Neither owns account policy, permission decisions, canonical Goal/path behavior, persistence implementation, or release status.

<!-- canon-section: inputs-outputs -->
Launch inputs are local-store readiness, replay/migration result, route readiness, pending repair, and interruption state. Setup inputs are explicit user answers, skips, and owning-system status. Outputs are a valid local entry or honest recovery state, plus durable setup progress and a next optional question.

<!-- canon-section: authority-boundary -->
The Constitution owns offline/no-account, force-nothing, durable-success, data-loss, and account boundaries. Setup references later surface and system owners and cannot silently enable, mutate, or claim their behavior.

<!-- canon-section: data-classification -->
Setup answers may be private life context and remain local private data by default. Launch telemetry and diagnostics use minimum necessary redacted state. Account or public-reference services receive no setup answers or private graph context under this specification.

<!-- canon-section: state-model -->
Launch and setup retain separate state machines linked only by explicit local readiness facts.

Launch states are checking local readiness, ready, retryable delay, repair required, quarantined, and stop-ship data-risk. Setup states are not started, in progress, skipped, sufficient, and revisitable, with each accepted answer carrying its own durable commit state.

<!-- canon-section: failure-recovery -->
Interrupted setup resumes from durable progress. Launch failure offers retry, repair preview, quarantine inspection, export, or diagnostics according to the failure class. Destructive reset is never an automatic recovery path.

<!-- canon-section: local-network-boundary -->
Launch and useful core entry are local and do not await sign-in, sync, entitlement, R2, Source Atlas, or any external permission. Optional network-dependent setup is deferred or degraded without blocking local use.

<!-- canon-section: determinism -->
Given the same durable readiness facts, launch chooses the same ready or recovery class. Given the same accepted setup answers and skips, setup resumes at the same next useful point without synthesizing private context.

<!-- canon-section: observability -->
Scoped evidence records launch phase, local-readiness decision, failure class, recovery offered, setup progress state, accepted-answer durability, and resume result with private values redacted. Current instrumentation must be inspected before claiming this proof exists.

<!-- canon-section: source-ownership -->
`App/` owns launch assembly, the shared LaunchGate view presents readiness, LocalRuntimeOS Boundary and Repair own their underlying decisions, You owns later Setup & Personalization, and `Quality/` owns verification. These mappings do not promote present source to compliance proof.

<!-- canon-section: tests-proof -->
Required proof covers cold/warm/offline launch, no-account entry, optional-service outage, migration/replay failure, non-destructive repair, crash/interruption resume, skip behavior, durable per-answer save, accessibility focus/order/actions, Dynamic Type, Reduce Motion, and private diagnostic redaction.

<!-- canon-section: performance-resource-constraints -->
On the oldest supported physical iPhone in an optimized build with 10,000 canonical objects, 50,000 events, and 5,000 receipts, a healthy cold launch MUST present the first useful local frame within 1.5 seconds at P95 across 20 launches; warm entry MUST complete within 500 ms at P95. The readiness decision itself MUST complete within 250 ms at P95 and read no more than 16 MiB before first useful presentation. An operation exceeding 2 seconds MUST expose truthful progress and yield the main actor at least every 50 ms. A setup-answer commit MUST complete within 100 ms at P95 and use one local transaction; resume decision MUST complete within 250 ms at P95. Launch/readiness memory growth MUST remain at or below 40 MiB, make zero network calls, and perform no polling after readiness.
