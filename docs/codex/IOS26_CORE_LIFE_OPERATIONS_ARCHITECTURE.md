# IOS26 Core Life Operations Architecture

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: architecture contract; not implementation proof
Batch: IOS26-CORE-LIFE-OPERATIONS-FOUNDATION-INSTALL-01

## 1. Purpose
Define the implementation-facing architecture for the foundation that lets Ambitions replace Calendar, Reminders, Todoist, Things 3, and Notion user jobs, then layers the Private Life Runtime moat on top.

## 2. Foundation before moat
The replacement foundation must exist before broad Private Life Runtime claims. Time Operations, Commitment Operations, Project/Step Operations, Life Knowledge Operations, unified capture/search/actions, receipts, proof, and replay become the substrate. The moat is proven only when local source-backed context changes recommendation behavior and replay.

## 3. Core object model
Required object model: LifeArea, Ambition, GoalThread, Commitment, Step, ChecklistItem, ScheduledBlock, RecurrenceRule, ReminderTrigger, CaptureItem, ContextEntry, Collection, Template, AttachmentReference, RelationEdge, Proof, SourceRecord, Receipt, SavedView, LocalSearchDocument, ChangeEvent, ReplayTrace.

## 4. Object transformation graph
CaptureItem can become ScheduledBlockCandidate, CommitmentCandidate, StepCandidate, GoalThreadCandidate, ContextEntryCandidate, ProofCandidate, SourceRecordCandidate, ReflectionCandidate, HeldItem, Needs a Place, or Ready to Place.

Time Operations outputs: availability windows, protected time, conflicts, pressure, free time, schedule candidates, EventKit mirror state, schedule receipts.

Commitment Operations outputs: open commitments, due commitments, waiting, blocked, recurring commitments, reminder triggers, saved views, closure events.

Life Knowledge outputs: searchable context, related source records, templates, collections, proof/context links, recommendation source inputs.

Private Life Runtime consumes Time reality, Commitment reality, Goal reality, Capture-derived context, Life knowledge, Proof history, Closure history, Recovery state, Source freshness, Protected time, and User defaults. It outputs Recommended step, multiple paths, why this, why now, source list, uncertainty/review needs, user controls, receipts, and replay trace.

## 5. Repositories
Each durable object family must have a local repository or repository contract with migration, export, delete/reset, deterministic tests, and no hosted personal-data backend requirement.

## 6. Services
Services should be local-first and deterministic: time availability, EventKit mirror, reminder scheduling abstraction, capture routing, saved view projection, local search indexing, relation resolution, source ledger, receipt recording, proof attachment, and replay tracing.

## 7. Runtime adapters
Runtime adapters convert foundation outputs into inspectable source inputs for the Private Life Runtime. Adapters must carry freshness, sensitivity, review state, reset/delete controls, and receipt/replay hooks.

## 8. UI surface ownership
Today owns Reality Meridian and Start Here. Goals owns Constellation Atlas and GoalThread depth. Capture owns Atmosphere Composer and reviewable routing. Time owns LifeShape Field and Time Operations. You owns User System Profile, What Ambitions knows, Trust & Automation, source controls, planning defaults, reset/delete, and privacy state.

## 9. Event/receipt/replay model
Material changes create ChangeEvent, Receipt, and ReplayTrace entries. Schedule, reminder, commitment, project, knowledge, source, recommendation, closure, and reflow changes must be receipt-backed.

## 10. Momentum Reflow runtime objects
Momentum Reflow / Step Time Reallocation is a cross-foundation runtime behavior. It must be modeled as explicit local state so schedule changes, Step/GoalThread changes, receipts, replay, source ledger inputs, future ranking, and You controls all stay inspectable and resettable.

### MomentumReflowCandidate

- id
- originalStepID
- originalGoalThreadID
- originalScheduledBlockID optional
- destinationStepID
- destinationGoalThreadID
- proposedDuration
- reason
- source
- projectedImpact
- requiresApproval
- createdAt

### MomentumReflowDecision

- candidateID
- userDecision
- originalStepDisposition
- destinationStepDisposition
- approvedDuration
- deadlinePolicy
- receiptID
- replayTraceID
- createdAt

### StepReallocationEvent

- id
- fromStepID
- toStepID
- fromGoalThreadID
- toGoalThreadID
- fromScheduledBlockID optional
- durationReallocated
- userReason
- timeContext
- momentumContext
- pressureImpact
- proofImpact
- createdAt

### PersonalRuntimeLearningSignal

- id
- signalType: momentum_reflow
- sourceEventID
- sourceReceiptID
- scope:
  - global
  - lifeArea
  - goalThread
  - stepType
- learnedPreference:
  - prefers_continuing_active_momentum_when_safe
  - avoid_context_switch_when_deep_progress_exists
  - protect_displaced_goal_deadline
- confidenceState:
  - single_observation
  - repeated_pattern
  - disabled
  - reset
- inspectableSummary
- resetRoute
- deleteRoute

## 11. Local search model
LocalSearchDocument indexes local life objects only. Search must expose object type, source/freshness, primary actions, filters, sensitivity/review state, and performance budget.

## 12. Migration/export/delete/reset model
Every replacement foundation object must define migration posture, export shape, delete behavior, reset behavior, and source-use disable behavior before broad claims.

## 13. Performance budgets
Performance proof must cover search, capture routing, recurrence expansion, Start Here computation, object actions, replay, and local persistence. No performance validation claim is allowed without measurements.

## 14. Accessibility obligations
VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, non-color-only state, and 44 pt minimum tap targets must cover replacement flows. Accessibility support in source is not public accessibility verification.

## 15. Privacy/local-first boundaries
No cloud LLM, hosted personal-data backend, external analytics dependency, sensitive silent use, silent schedule mutation, weak forced match, or sensitive logs. EventKit is a permissioned mirror boundary, not silent external mutation.

## 16. Downstream train contracts
T04E installs contract harnesses. T04F implements Time Operations. T04G implements Reminder Operations. T04H implements Project/Step Operations. T04I implements Life Knowledge Operations. T04J implements unified capture/search/commands. T04K integrates the Private Life Runtime over that foundation and gates T05.

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
