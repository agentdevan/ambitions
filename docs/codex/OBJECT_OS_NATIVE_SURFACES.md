# Object OS Native Surfaces

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active supporting canon
Parent: docs/codex/AMBITIONS_OBJECT_OS_CANON.md
Runtime impact in this batch: None

## Purpose

This file defines how Ambitions Object OS extends beyond the app through native Apple surfaces without becoming a generic shortcut/task/widget system.

Native surfaces must preserve the Ambitions object loop:

policy guard -> command/event -> side-effect ledger -> receipt -> proof/trust trail

## Native surface principles

1. Native surfaces show Ambitions objects, not generic tasks.
2. Every native-surface mutation must create or reference a receipt.
3. Native surfaces must respect privacy, local-first behavior, and policy guards.
4. Native surfaces should never bypass the app's command/event, side-effect, proof, or trust layers.
5. Native surfaces should be glanceable, not mini dashboards.
6. Native surfaces must degrade cleanly when data is stale, source-needed, blocked, or recovery-active.
7. Native surfaces must not claim cloud sync or hosted intelligence.

## Surface types

### 1. Start Here Widget

Object: Start Here / Action Candidate

Shows:

- recommended step
- ambition thread
- time fit
- proof opportunity
- source/trust state
- start/open action

Forbidden:

- task list widget
- generic motivational quote
- opaque AI suggestion

### 2. Active Commitment Widget

Object: Active Commitment

Shows:

- commitment title
- current state
- closure options
- proof opportunity
- receipt after closure

Allowed actions:

- Open step
- Mark Still Counts
- Add proof
- Mark Blocked
- Move / Waiting if safe

### 3. Recovery Thread Widget

Object: Recovery Thread

Shows:

- last honest point
- what still counts
- smallest re-entry step
- open recovery action

Tone:

- calm
- non-shaming
- precise

### 4. Proof Opportunity Widget

Object: Proof Opportunity

Shows:

- proof-rich action or moment
- linked Ambition / Commitment
- add proof action
- source-needed state if relevant

### 5. LifeShape Pressure Widget

Object: LifeShape / Reality State

Shows:

- pressure state
- open/protected capacity
- recovery window
- next reflow opportunity

Forbidden:

- generic calendar clone
- full event list

### 6. Live Commitment Activity

Object: Active Commitment

Used for:

- active step session
- time-bounded commitment
- recovery window
- proof opportunity

Shows:

- active commitment
- state
- time window
- closure action
- proof/receipt affordance

Must not:

- feel like a timer-first productivity app
- force countdown pressure
- display sensitive private context without user control

### 7. App Intents

Allowed intents:

- Capture thought
- Start current step
- Open Start Here
- Close current step
- Mark Still Counts
- Add proof
- Show why this
- Show active recovery
- Reflow today
- Open Proof Vault

Every mutating App Intent must record:

- command/event
- side-effect policy
- receipt
- proof/trust impact where relevant

### 8. Share Extension

Accepted input types:

- URL
- text
- PDF/file
- image/screenshot
- photo

Routes:

- Source candidate
- Proof candidate
- Constraint candidate
- Reflection candidate
- Goal seed
- Held item

The Share Extension must use the same Meaning Router as Capture.

### 9. Spotlight / Search

Searchable object types:

- Ambition
- Goal Thread
- Commitment
- Proof
- Source
- Recovery Thread
- Receipt

Spotlight results should open object detail, not generic list views.

### 10. Control Center / Action Button candidates

Potential quick actions:

- Capture
- Start Here
- Add proof
- Mark Still Counts
- Open active recovery

These must remain optional and privacy-safe.

## Native surface eligibility

Each object can declare a NativeSurfaceToken:

- widgetEligible
- liveActivityEligible
- appIntentEligible
- shareExtensionEligible
- spotlightEligible
- controlCenterEligible
- sensitive
- privateOnly
- requiresUnlock
- receiptRequired

## Sensitive object handling

Sensitive objects should default to private/unexpanded surface states.

Examples:

- show generic label: Active Commitment
- hide source detail until unlock
- hide proof title if sensitive
- require app open for closure if context is private

## Native state grammar

Every native surface should support:

- current
- stale
- source needed
- blocked
- waiting
- recovery active
- proof opportunity
- low confidence
- permission denied
- offline/local-only

## Integration with MRI

This file is binding for:

- MRI31 Native Apple Surfaces With Receipts
- MRI33 Visual QA Preview Fixtures
- MRI34 Visual Runtime Acceptance
- PFC Widget/App Intent/Live Activity/Share Extension work

## Claims not made

This file does not implement native surfaces or claim widget/Live Activity/App Intent readiness.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
