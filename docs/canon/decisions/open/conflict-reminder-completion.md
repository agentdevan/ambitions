+++
schema_version = 1
conflict_id = "CONFLICT-REMINDER-COMPLETION"
status = "unresolved"
severity = "P0_BLOCKER"
priority = "P0"
concepts = ["object.boundary.completion", "object.reminder.lifecycle-completion"]
scopes = ["object.reminder.lifecycle", "object.step-event-reminder-note"]
recommendation = "reject_both"
recommendation_rationale = "The extracted opposition is provenance-corrupted and neither side fully distinguishes acknowledgement, linked-Step completion, Reminder transition, or recurrence scope."
stronger_composition = "Define Reminder identity, Step linkage/conversion, notification acknowledgement, occurrence/series scope, receipts, undo, and rescheduling separately."
proposed_canonical_law = "A Reminder MUST NOT independently complete user work unless canonical law defines its relationship to a Step; notification acknowledgement, linked-Step completion, Reminder state, and recurrence scope MUST remain distinct transitions."
artifacts_to_supersede = ["LINEAR-CANON-V3:line:324", "REPO-AA88FA58EEA6FBA9BAB10270:line:2405"]
target_requirement_status = "planned_uncreated"
target_requirement_id = ""
owner_decision = ""
allowed_resolutions = ["keep_a", "keep_b", "compose", "reject_both"]
affected_task_scopes = ["object.reminder", "object.step"]
nonclaims = "No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made."
claim_ceiling = "Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization."

[[claims]]
claim_id = "CLAIM-OBJ-020"
source_id = "LINEAR-CANON-V3"
source_location = "line:324"
concept = "object.boundary.completion"
scope = "object.step-event-reminder-note"
modality = "MUST NOT"
normalized_value = "reminder is not independently completable unless linked to a step."
evidence_sha256 = "0f566e71e2da0b5f946cbff76c9ecdda5b33b5d6871c63c8a62c93ba282bc044"
owner_approval = "owner-approved:linear-v3"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[claims]]
claim_id = "CLAIM-OBJ-060"
source_id = "REPO-AA88FA58EEA6FBA9BAB10270"
source_location = "line:2405"
concept = "object.reminder.lifecycle-completion"
scope = "object.reminder.lifecycle"
modality = "MUST"
normalized_value = "creation, completion, and rescheduling."
evidence_sha256 = "cb4f68e395fe0740f4a62d01ede7ffada491944d45f636d9505ddc6a7fbad7f5"
owner_approval = "active-repo-authority:PRODUCT_EXPERIENCE_CANON.md"
owner_evidence_text_sha256 = ""
owner_evidence_rationale_sha256 = ""

[[impacts]]
dimension = "repo"
analysis = "Repair the reminder-like Step scenario interpretation and then centralize Reminder/Step boundary law."

[[impacts]]
dimension = "linear"
analysis = "The v3 object-boundary row remains an unresolved side pending owner choice."

[[impacts]]
dimension = "figma"
analysis = "Alert/action flows need distinct Complete, Still counts, Not needed, link/convert, and recurrence-scope states."

[[impacts]]
dimension = "production_source"
analysis = "ReminderModels contains source-present states; repository and EventKit paths do not prove a production completion flow."

[[impacts]]
dimension = "tests"
analysis = "Later require command, recurrence, notification cancellation, receipt/history/undo, reload, linkage, and UI tests with current results."

[[impacts]]
dimension = "proof"
analysis = "Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven."

[[impacts]]
dimension = "privacy"
analysis = "Reminder text in notifications/EventKit must be minimized and redacted according to permission and lock state."

[[impacts]]
dimension = "accessibility"
analysis = "Actions and consequences must be distinct, announced, and available without gesture-only controls."

[[impacts]]
dimension = "migration_rollback"
analysis = "Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag."
+++

# CONFLICT-REMINDER-COMPLETION

> Shadow migration decision docket. It is non-authoritative and remains unresolved until the owner records a decision.

## Competing conceptual claims

| Claim | Normalized value | Modality | Scope | Source provenance | Evidence SHA-256 |
| --- | --- | --- | --- | --- | --- |
| `CLAIM-OBJ-020` | reminder is not independently completable unless linked to a step. | `MUST NOT` | object.step-event-reminder-note | `LINEAR-CANON-V3:line:324` | `0f566e71e2da0b5f946cbff76c9ecdda5b33b5d6871c63c8a62c93ba282bc044` |
| `CLAIM-OBJ-060` | creation, completion, and rescheduling. | `MUST` | object.reminder.lifecycle | `REPO-AA88FA58EEA6FBA9BAB10270:line:2405` | `cb4f68e395fe0740f4a62d01ede7ffada491944d45f636d9505ddc6a7fbad7f5` |

## User consequences

A notification can disappear without completing intended work, or Reminder and Step can both complete and emit duplicate receipts or recurrence changes.

## Compatibility analysis

The scenario behind CLAIM-OBJ-060 actually proves only a reminder-like Step, not independent Reminder completion. Live ReminderState contains completion-like cases but no proven first-class completion command/UI.

## Recommendation

**Reject both and introduce a stronger third law.** The extracted opposition is provenance-corrupted and neither side fully distinguishes acknowledgement, linked-Step completion, Reminder transition, or recurrence scope.

This is a recommendation for Gate A, not an owner decision.

## Stronger composition option

Define Reminder identity, Step linkage/conversion, notification acknowledgement, occurrence/series scope, receipts, undo, and rescheduling separately.

## Proposed canonical law

A Reminder MUST NOT independently complete user work unless canonical law defines its relationship to a Step; notification acknowledgement, linked-Step completion, Reminder state, and recurrence scope MUST remain distinct transitions.

## Impact analysis

| Dimension | Impact |
| --- | --- |
| repo | Repair the reminder-like Step scenario interpretation and then centralize Reminder/Step boundary law. |
| Linear | The v3 object-boundary row remains an unresolved side pending owner choice. |
| Figma | Alert/action flows need distinct Complete, Still counts, Not needed, link/convert, and recurrence-scope states. |
| production source | ReminderModels contains source-present states; repository and EventKit paths do not prove a production completion flow. |
| tests | Later require command, recurrence, notification cancellation, receipt/history/undo, reload, linkage, and UI tests with current results. |
| proof | Current source files, broad prefix maps, historical tests, screenshots, or retained proof are impact candidates only; exact requirement traceability and current passing/rendered/device evidence remain unproven. |
| privacy | Reminder text in notifications/EventKit must be minimized and redacted according to permission and lock state. |
| accessibility | Actions and consequences must be distinct, announced, and available without gesture-only controls. |
| migration / rollback | Task 12 changes no product data or active authority. After owner approval, Task 13 must create the target requirement and supersession entry atomically; before cutover, rollback is the scoped Git revert/tag. |

## Artifacts to supersede

- `LINEAR-CANON-V3:line:324`
- `REPO-AA88FA58EEA6FBA9BAB10270:line:2405`

## Target requirement

- Status: `planned_uncreated`
- Requirement ID: not created; it becomes mandatory only after owner resolution.

## Owner decision

- Status: unresolved
- Decision: blank
- Allowed values: `keep_a`, `keep_b`, `compose`, `reject_both`

## Explicit nonclaims and claim ceiling

- Nonclaims: No conflict is resolved; no final Constitution or Atlas law is approved; no source, test, product, runtime, visual, accessibility, privacy, device, CloudKit, TestFlight, App Store, or release Green claim is made.
- Claim ceiling: Task 12 shadow conflict provenance, recommendation, and impact analysis only for the reviewed claims and base SHA; no source-edit or cutover authorization.
