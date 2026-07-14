# Ambitions Canonical UX Blueprint

> Shadow, non-authoritative visual-rebaseline design input.
> It does not change product law, implementation state, or release proof.

- Blueprint ID: `AMB-UX-BLUEPRINT-REBASELINE-001`
- Canon revision: `1`
- Canon content SHA: `85094c7a431d4331f4168740725a1e6b8647115ec1fd9f21a4d80131f3c0dabf`
- Source SHA: `002fd07b795173c1c8590c0be986fc1e31569416`
- Authority state: `shadow`
- Requirement dispositions: `441` total; `364` visual; `77` nonvisual; SHA-256 `18976b9cf8bdb629d26c8853ab44dce7bf0543fb0546d8a67d2d1c22bba0f5cc`
- Claim ceiling: Visual design input only; no source, runtime, rendered-app, accessibility, device, privacy/legal, distribution, or release claim.

## Screens and presentations

| Blueprint ID | Scope | Screen / state owner | Presentation | Requirements |
| --- | --- | --- | --- | --- |
| `UX-SCREEN-ACCOUNT-BOUNDARY` | `account` | Account and continuity boundary | native drilldown | `APP-ACCOUNT-LAUNCH-001`, `SPEC-SURFACE-YOU-PRIVACY-DATA-BOUNDARY-001`, `SPEC-SURFACE-YOU-PROFILE-001` |
| `UX-SCREEN-ACCOUNT-SIGN-IN` | `account` | Optional sign in | native sheet | `APP-ACCOUNT-LAUNCH-001`, `APP-SETUP-PROGRESSIVE-FIRST-USE-001`, `SPEC-SURFACE-YOU-PROFILE-001` |
| `UX-SCREEN-ACCOUNT-STATUS` | `account` | Account and Sync status | native drilldown | `SPEC-SURFACE-YOU-DEPTH-001`, `SPEC-SURFACE-YOU-FIRST-VIEWPORT-001`, `SPEC-SURFACE-YOU-PROFILE-001` |
| `UX-SCREEN-APP-SHELL-DRILLDOWN` | `app-shell` | Drilldown containment | native push or sheet | `APP-NAVIGATION-RESTORATION-001`, `SPEC-APP-NAVIGATION-PRESENTATION-001`, `SPEC-APP-SHELL-ROOT-NAVIGATION-001` |
| `UX-SCREEN-APP-SHELL-ROOT` | `app-shell` | Root app shell | root stage | `SPEC-APP-NAVIGATION-IA-MAP-001`, `SPEC-APP-SHELL-FIRST-VIEWPORT-001`, `SPEC-APP-SHELL-ROOT-NAVIGATION-001` |
| `UX-SCREEN-APP-SHELL-SEARCH-CAPTURE` | `app-shell` | Global action placement | full-screen non-root presentation | `SPEC-APP-SHELL-GLOBAL-ACTIONS-001`, `SPEC-GLOBAL-SEARCH-PLACEMENT-001`, `SPEC-GLOBAL-CAPTURE-CLOSE-BEHAVIOR-001` |
| `UX-SCREEN-CAPTURE-ATTACHMENT` | `capture` | Capture attachment intake | native picker, scanner, or bounded sheet | `OBJ-ATTACHMENT-IDENTITY-001`, `SPEC-GLOBAL-CAPTURE-ATTACHMENT-INTAKE-001`, `SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001` |
| `UX-SCREEN-CAPTURE-COMPOSER` | `capture` | Capture composer | full-screen composer | `SPEC-GLOBAL-CAPTURE-IDENTITY-001`, `SPEC-GLOBAL-CAPTURE-KEYBOARD-001`, `SPEC-GLOBAL-CAPTURE-CLASSIFICATION-001` |
| `UX-SCREEN-CAPTURE-PROPOSAL` | `capture` | Capture proposal and placement | adaptive full-screen step or native sheet | `SPEC-GLOBAL-CAPTURE-PROPOSAL-FLOW-001`, `SPEC-SURFACE-TIME-CREATION-ROUTES-001`, `CONTROL-MATERIAL-CONFIRMATION-001` |
| `UX-SCREEN-CAPTURE-SAVED-FOR-LATER` | `capture` | Saved for Later | contextual collection or detail | `OBJ-CAPTURE-DRAFT-IDENTITY-001`, `SPEC-GLOBAL-CAPTURE-SAVED-FOR-LATER-001`, `JOURNEY-SAVED-FOR-LATER-001` |
| `UX-SCREEN-GOALS-CLOSURE` | `goals` | Goal closure | dedicated native closure surface | `OBJ-CLOSURE-IDENTITY-001`, `SPEC-SURFACE-GOALS-CLOSURE-001`, `JOURNEY-STEP-CLOSURE-001` |
| `UX-SCREEN-GOALS-DETAIL` | `goals` | Goal detail | native object operating page | `OBJ-GOAL-IDENTITY-001`, `SPEC-SURFACE-GOAL-DETAIL-VIEWPORT-001`, `SPEC-SURFACE-GOALS-DETAIL-001` |
| `UX-SCREEN-GOALS-LIFE-AREA` | `goals` | Life Area detail | native drilldown | `OBJ-LIFE-AREA-IDENTITY-001`, `SPEC-SURFACE-GOALS-PURPOSE-001`, `SPEC-SURFACE-GOALS-SCREEN-INVENTORY-001` |
| `UX-SCREEN-GOALS-PATH` | `goals` | Full Goal Path | native path rail with ordered semantic counterpart | `OBJ-GOAL-PATH-ACCESSIBILITY-001`, `SPEC-SURFACE-GOALS-PATH-INTERACTION-001`, `SPEC-SURFACE-GOALS-PATH-VISUAL-001` |
| `UX-SCREEN-GOALS-RECOVERY` | `goals` | Goal recovery packet | native recovery sheet or drilldown | `JOURNEY-RECOVERY-001`, `OBJ-RECOVERY-SEGMENT-IDENTITY-001`, `SPEC-SURFACE-GOALS-REVIEWS-001` |
| `UX-SCREEN-GOALS-ROOT` | `goals` | Goals root | root surface | `SPEC-SURFACE-GOALS-FIRST-VIEWPORT-001`, `SPEC-SURFACE-GOALS-IDENTITY-001`, `SPEC-SURFACE-GOALS-ROOT-VIEWPORT-001` |
| `UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH` | `offline-degraded` | Scoped degraded state | narrowest contextual banner, row, or surface state | `APP-DEGRADED-FAILURE-TAXONOMY-001`, `APP-DEGRADED-PRESENTATION-001`, `APP-DEGRADED-STATE-001` |
| `UX-SCREEN-OFFLINE-DEGRADED-REPAIR` | `offline-degraded` | Recovery and repair | native repair drilldown | `APP-DEGRADED-PRESERVE-001`, `APP-DEGRADED-RECOVERY-001`, `APP-LAUNCH-RECOVERY-001` |
| `UX-SCREEN-PERMISSIONS-CALENDAR` | `permissions` | Calendar permission | contextual pre-permission sheet followed by system prompt | `APP-PERMISSIONS-CONTRACT-001`, `APP-PERMISSION-DENIAL-001`, `JOURNEY-CALENDAR-DIFF-001` |
| `UX-SCREEN-PERMISSIONS-NOTIFICATIONS` | `permissions` | Notification permission | contextual pre-permission sheet followed by system prompt | `APP-PERMISSIONS-CONTRACT-001`, `APP-PERMISSION-RECOVERY-001`, `OBJ-NOTIFICATION-RULE-IDENTITY-001` |
| `UX-SCREEN-SEARCH-RESULTS` | `search` | Search results | full-screen result list | `SPEC-GLOBAL-SEARCH-ACTIONS-001`, `SPEC-GLOBAL-SEARCH-FIRST-VIEWPORT-001`, `SPEC-GLOBAL-SEARCH-INDEX-001` |
| `UX-SCREEN-SEARCH-ROOT` | `search` | Search entry | full-screen non-root search | `SPEC-GLOBAL-SEARCH-IDENTITY-001`, `SPEC-GLOBAL-SEARCH-PLACEMENT-001`, `SPEC-GLOBAL-SEARCH-FIRST-VIEWPORT-001` |
| `UX-SCREEN-SETUP-FIRST-USE` | `setup` | Progressive first use | progressive native first-use flow | `APP-LAUNCH-READINESS-001`, `APP-SETUP-PROGRESSIVE-FIRST-USE-001`, `APP-SETUP-STATE-001` |
| `UX-SCREEN-SETUP-RESUME` | `setup` | Setup interruption and resume | contextual resume card or native sheet | `APP-SETUP-PROGRESS-001`, `APP-SETUP-RESUME-001`, `APP-SETUP-STATE-001` |
| `UX-SCREEN-TIME-DAY` | `time` | Time Day | vertical day grid with semantic list equivalence | `SPEC-SURFACE-TIME-DAY-001`, `SPEC-SURFACE-TIME-FIRST-VIEWPORT-001`, `SPEC-SURFACE-TIME-VISUAL-GEOMETRY-001` |
| `UX-SCREEN-TIME-DETAIL` | `time` | Time object detail | compact native detail or full destination when depth requires | `OBJ-EVENT-TIME-ZONE-001`, `SPEC-SURFACE-TIME-OBJECT-DETAIL-001`, `SPEC-SURFACE-TIME-STEP-MEMBERSHIP-001` |
| `UX-SCREEN-TIME-IMPORT` | `time` | External calendar review | impact-grouped native review flow | `JOURNEY-CALENDAR-CANDIDATE-001`, `JOURNEY-CALENDAR-DIFF-GROUPING-001`, `SPEC-SURFACE-TIME-IMPORTED-SOURCE-001` |
| `UX-SCREEN-TIME-LIST` | `time` | Time List | chronological semantic list | `A11Y-002`, `SPEC-SURFACE-TIME-LIST-001`, `SPEC-SURFACE-TIME-VIEWS-001` |
| `UX-SCREEN-TIME-MONTH` | `time` | Time Month | native month grid with semantic summaries | `A11Y-002`, `SPEC-SURFACE-TIME-MONTH-001`, `SPEC-SURFACE-TIME-VIEW-SWITCHING-001` |
| `UX-SCREEN-TIME-WEEK` | `time` | Time Week | native week grid with semantic alternatives | `SPEC-SURFACE-TIME-VISUAL-GEOMETRY-001`, `SPEC-SURFACE-TIME-VIEWS-001`, `SPEC-SURFACE-TIME-WEEK-001` |
| `UX-SCREEN-TIME-YEAR` | `time` | Time Year | annual semantic overview | `A11Y-002`, `SPEC-SURFACE-TIME-VIEWS-001`, `SPEC-SURFACE-TIME-YEAR-001` |
| `UX-SCREEN-TODAY-DETAIL` | `today` | Today object detail | compact detail or owner drilldown | `SPEC-GLOBAL-TRUST-LAYERS-001`, `SPEC-SURFACE-TODAY-ROW-001`, `SPEC-SURFACE-TODAY-SCREEN-INVENTORY-001` |
| `UX-SCREEN-TODAY-ROOT` | `today` | Today Reality Window | root surface | `SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001`, `SPEC-SURFACE-TODAY-PURPOSE-001`, `SPEC-SURFACE-TODAY-TEMPORAL-RAIL-001` |
| `UX-SCREEN-TODAY-START-HERE` | `today` | Start here | primary object with compact action expansion | `SPEC-SURFACE-TODAY-ELIGIBILITY-001`, `SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001`, `JOURNEY-STEP-START-COMPLETE-001` |
| `UX-SCREEN-TRUST-DEEP` | `trust` | Deep Trust inspection | smallest native deep inspection | `SPEC-GLOBAL-TRUST-INSPECTION-001`, `SPEC-GLOBAL-TRUST-LAYERS-001`, `SPEC-GLOBAL-TRUST-PROPORTIONAL-RECEIPTS-001` |
| `UX-SCREEN-TRUST-INLINE` | `trust` | Inline and compact Trust | object-subordinate marker or compact row | `SPEC-GLOBAL-TRUST-INSPECTION-001`, `SPEC-GLOBAL-TRUST-LAYERS-001`, `SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001` |
| `UX-SCREEN-TRUST-RECEIPT` | `trust` | Receipt and Undo | lightweight confirmation or contextual detail | `OBJ-RECEIPT-IDENTITY-001`, `SPEC-GLOBAL-TRUST-PROPORTIONAL-RECEIPTS-001`, `CONTROL-UNDO-RECOVERY-001` |
| `UX-SCREEN-YOU-DATA` | `you` | Data and Storage | native settings drilldown | `JOURNEY-DELETE-RESTORE-001`, `SPEC-SURFACE-YOU-DATA-CONTROLS-001`, `SPEC-SURFACE-YOU-PRIVACY-DATA-BOUNDARY-001` |
| `UX-SCREEN-YOU-ROOT` | `you` | You root | root command center | `SPEC-SURFACE-YOU-FIRST-VIEWPORT-001`, `SPEC-SURFACE-YOU-IDENTITY-001`, `SPEC-SURFACE-YOU-SCREEN-INVENTORY-001` |
| `UX-SCREEN-YOU-SETTINGS` | `you` | You settings drilldown | native settings drilldown | `SPEC-SURFACE-YOU-APPEARANCE-001`, `SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001`, `SPEC-SURFACE-YOU-TIME-PREFERENCES-001` |

## Complete state models

Each model covers resting, loading, transitional, empty, degraded, failure, recovery, rollback, and interruption states.

| Blueprint ID | Applies to | Recovery contract | Requirements |
| --- | --- | --- | --- |
| `UX-STATE-ACCOUNT` | `UX-SCREEN-ACCOUNT-BOUNDARY`, `UX-SCREEN-ACCOUNT-SIGN-IN`, `UX-SCREEN-ACCOUNT-STATUS` | Continue local-only, retry the optional service, review conflict, or return to the prior You context. | `APP-ACCOUNT-LAUNCH-001`, `APP-DEGRADED-PRESERVE-001` |
| `UX-STATE-APP-SHELL` | `UX-SCREEN-APP-SHELL-DRILLDOWN`, `UX-SCREEN-APP-SHELL-ROOT`, `UX-SCREEN-APP-SHELL-SEARCH-CAPTURE` | Restore the nearest safe root or exact prior route without adding a root or losing accepted object state. | `APP-SHELL-FAILURE-001`, `APP-SHELL-STATE-001` |
| `UX-STATE-CAPTURE-COMPOSER` | `UX-SCREEN-CAPTURE-COMPOSER` | Retry, edit, remove only failed input, keep draft, Save for Later, or confirmed discard. | `SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001`, `SPEC-GLOBAL-CAPTURE-KEYBOARD-001` |
| `UX-STATE-CAPTURE-ROUTING` | `UX-SCREEN-CAPTURE-ATTACHMENT`, `UX-SCREEN-CAPTURE-PROPOSAL`, `UX-SCREEN-CAPTURE-SAVED-FOR-LATER` | Return to the durable composer, retry the bounded failure, edit the proposal, or preserve unresolved input. | `APP-DEGRADED-PRESERVE-001`, `SPEC-GLOBAL-CAPTURE-PROPOSAL-FLOW-001` |
| `UX-STATE-GOALS-DETAIL` | `UX-SCREEN-GOALS-CLOSURE`, `UX-SCREEN-GOALS-DETAIL`, `UX-SCREEN-GOALS-RECOVERY` | Preserve the Goal and current path, refresh facts, edit a bounded proposal, retry, or return without a silent material change. | `OBJ-STATE-AXES-001`, `SPEC-SURFACE-GOALS-DETAIL-001` |
| `UX-STATE-GOALS-PATH` | `UX-SCREEN-GOALS-PATH` | Use the last valid path version, show bounded stale state, refresh deterministically, or return to Goal detail. | `OBJ-GOAL-PATH-ACCESSIBILITY-001`, `OBJ-GOAL-PATH-IDENTITY-001` |
| `UX-STATE-GOALS-ROOT` | `UX-SCREEN-GOALS-LIFE-AREA`, `UX-SCREEN-GOALS-ROOT` | Retain last valid local projection, rebuild from canonical objects, or offer Capture and exact owner actions. | `SPEC-SURFACE-GOALS-FIRST-VIEWPORT-001`, `SPEC-SURFACE-GOALS-ROOT-VIEWPORT-001` |
| `UX-STATE-LOCAL-DEGRADED` | `UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH`, `UX-SCREEN-OFFLINE-DEGRADED-REPAIR` | Offer only class-valid retry, review, quarantine, export, rollback, repair preview, or separately confirmed reset. | `APP-DEGRADED-FAILURE-TAXONOMY-001`, `APP-DEGRADED-RECOVERY-001` |
| `UX-STATE-PERMISSIONS-SETUP` | `UX-SCREEN-PERMISSIONS-CALENDAR`, `UX-SCREEN-PERMISSIONS-NOTIFICATIONS`, `UX-SCREEN-SETUP-FIRST-USE`, `UX-SCREEN-SETUP-RESUME` | Continue locally, open exact Settings when requested, retry in context, or defer the optional capability. | `APP-PERMISSION-STATE-001`, `APP-SETUP-RESUME-001` |
| `UX-STATE-SEARCH` | `UX-SCREEN-SEARCH-RESULTS`, `UX-SCREEN-SEARCH-ROOT` | Preserve query and last valid results, repair scope, rebuild locally, re-resolve the object, or return to exact origin. | `SPEC-GLOBAL-SEARCH-FIRST-VIEWPORT-001`, `SPEC-GLOBAL-SEARCH-INDEX-001` |
| `UX-STATE-TIME-CALENDAR` | `UX-SCREEN-TIME-DAY`, `UX-SCREEN-TIME-LIST`, `UX-SCREEN-TIME-MONTH`, `UX-SCREEN-TIME-WEEK`, `UX-SCREEN-TIME-YEAR` | Keep local Time usable, retain last valid range, rebuild projection, return Today, or open a scoped classified recovery. | `SPEC-SURFACE-TIME-VIEWS-001`, `SPEC-SURFACE-TIME-VIEW-SWITCHING-001` |
| `UX-STATE-TIME-DETAIL-IMPORT` | `UX-SCREEN-TIME-DETAIL`, `UX-SCREEN-TIME-IMPORT` | Preserve the native object or candidate, refresh source facts, edit scope, retry safely, or leave review unchanged. | `JOURNEY-CALENDAR-DIFF-001`, `SPEC-SURFACE-TIME-OBJECT-DETAIL-001` |
| `UX-STATE-TODAY` | `UX-SCREEN-TODAY-DETAIL`, `UX-SCREEN-TODAY-ROOT`, `UX-SCREEN-TODAY-START-HERE` | Preserve current local objects, refresh projection, hand off to Time for complex scheduling, or show Capture, Time, and Goals without backlog fill. | `SPEC-SURFACE-TODAY-STATES-001`, `SPEC-SURFACE-TODAY-MISSED-CONTINUITY-001` |
| `UX-STATE-TRUST` | `UX-SCREEN-TRUST-DEEP`, `UX-SCREEN-TRUST-INLINE`, `UX-SCREEN-TRUST-RECEIPT` | Retain the originating object and known local evidence, retry bounded work, correct, export, inspect diagnostics, or dismiss safely. | `SPEC-GLOBAL-TRUST-INSPECTION-001`, `SPEC-GLOBAL-TRUST-LAYERS-001` |
| `UX-STATE-YOU-DATA` | `UX-SCREEN-YOU-DATA` | Cancel before commit, retry validation, quarantine invalid input, export safe content, restore, or return to unchanged local data. | `JOURNEY-DELETE-RESTORE-001`, `SPEC-SURFACE-YOU-DATA-CONTROLS-001` |
| `UX-STATE-YOU-ROOT` | `UX-SCREEN-YOU-ROOT`, `UX-SCREEN-YOU-SETTINGS` | Keep last accepted value, retry or revert the bounded setting, open exact permission recovery, or continue unaffected local work. | `SPEC-SURFACE-YOU-FIRST-VIEWPORT-001`, `SPEC-SURFACE-YOU-SETTINGS-DRILLDOWN-001` |

## Canonical object boundaries

| Object | Presentation boundary | Delete / restore | Requirements |
| --- | --- | --- | --- |
| `attachment` | Inline chip or preview, native preview/detail, and Capture intake; never a root library. | Removal is scoped to the attachment relationship or local blob and preserves parent identity and history. | `OBJ-ATTACHMENT-IDENTITY-001`, `SPEC-GLOBAL-CAPTURE-ATTACHMENT-INTAKE-001` |
| `closure` | Compact completion for simple Steps and dedicated Goal closure for meaningful dependent consequences. | Closure is corrected or undone through history; it is not silently deleted as if it never occurred. | `OBJ-CLOSURE-IDENTITY-001`, `OBJ-CLOSURE-SEPARATION-001` |
| `event` | Time is primary; Today shows execution-relevant projection; Goals and Search link context without duplicate identity. | Delete uses Trash or explicit recurring scope; source unlink is distinct from native deletion. | `OBJ-EVENT-IDENTITY-001`, `SPEC-SURFACE-TIME-OBJECT-DETAIL-001` |
| `goal` | Goals owns full detail; Today, Time, Search, and Trust project bounded context. | End, archive, Trash, restore, and permanent deletion are distinct and preview dependent objects. | `OBJ-GOAL-IDENTITY-001`, `SPEC-SURFACE-GOALS-DETAIL-001` |
| `goal-path` | Goals owns full path; Today shows one execution fit and Trust exposes evidence without becoming the path. | Path versions are superseded or recovered with lineage; Goal lifecycle controls govern destructive scope. | `OBJ-GOAL-PATH-ACCESSIBILITY-001`, `OBJ-GOAL-PATH-IDENTITY-001` |
| `history-event` | Contextual sequence under Trust and You; never a social feed or root activity dashboard. | History is retained according to governed deletion and cannot be selectively erased to misstate accepted change. | `OBJ-HISTORY-EVENT-IDENTITY-001`, `SPEC-GLOBAL-TRUST-LAYERS-001` |
| `import-diff-record` | Time review surface and contextual source inspection; never rendered as a native Event before import. | Reject, ignore, reviewed, and removed-source lineage are preserved according to source-review policy. | `JOURNEY-CALENDAR-CANDIDATE-001`, `OBJ-IMPORT-DIFF-RECORD-IDENTITY-001` |
| `life-area` | Goals root and Life Area detail; You may expose settings but does not own the object. | Hide, restore, archive influence, and governed deletion stay distinct from Goal deletion. | `OBJ-LIFE-AREA-IDENTITY-001`, `SPEC-SURFACE-GOALS-ROOT-VIEWPORT-001` |
| `note` | Owning object detail, Search, and Capture history; never a root notes feed. | Trash and restore preserve links and history; conversion is explicit. | `OBJ-NOTE-IDENTITY-001`, `OBJ-TYPE-BOUNDARY-001` |
| `notification-rule` | Object detail and You Notifications; notifications are projections and actions route to owners. | Disable, remove, restore, and system-permission denial stay distinct. | `OBJ-NOTIFICATION-RULE-IDENTITY-001`, `SPEC-SURFACE-YOU-FIRST-VIEWPORT-001` |
| `proof` | Inline status, object detail, proof intake, and deep Trust; never a score or gallery root. | Removal or correction previews closure impact and preserves history; sensitive export is separately reviewed. | `OBJ-PROOF-IDENTITY-001`, `SPEC-GLOBAL-TRUST-INSPECTION-001` |
| `receipt` | Lightweight confirmation, contextual Trust detail, and You archive; never global ambient chrome. | Append-only evidence follows governed retention and cannot be removed to fabricate state. | `OBJ-RECEIPT-IDENTITY-001`, `SPEC-GLOBAL-TRUST-PROPORTIONAL-RECEIPTS-001` |
| `recovery-segment` | Goals path and recovery packet with bounded Today or Time handoff; never a failure dashboard. | Correction or path supersession preserves segment lineage; it is not erased as failure. | `JOURNEY-RECOVERY-001`, `OBJ-RECOVERY-SEGMENT-IDENTITY-001` |
| `reminder` | Today and Time project trigger context; owner detail retains type; no independent capacity unless converted. | Trash, restore, recurring scope, and notification disablement remain distinct. | `OBJ-REMINDER-IDENTITY-001`, `OBJ-REMINDER-REPLACEMENT-TARGET-001` |
| `saved-for-later-draft` | Capture history, Search, or contextual collection; never root, inbox, tab, or Today backlog. | Discard or Trash is explicit; promotion preserves original lineage and Receipt. | `OBJ-CAPTURE-DRAFT-IDENTITY-001`, `SPEC-GLOBAL-CAPTURE-SAVED-FOR-LATER-001` |
| `schedule-placement` | Time owns full manipulation; Today shows execution context; object detail exposes bounded placement facts. | Unschedule, move, restore, and delete owner object remain distinct; change sets are atomic. | `OBJ-SCHEDULE-PLACEMENT-ATOMICITY-001`, `OBJ-SCHEDULE-PLACEMENT-IDENTITY-001` |
| `source-reference` | Inspection-level marker and Trust detail; Source Atlas remains invisible by default and never receives private graph context. | Unlink, unavailable source, native object deletion, and external source deletion remain distinct. | `OBJ-SOURCE-REFERENCE-IDENTITY-001`, `SPEC-GLOBAL-TRUST-LAYERS-001` |
| `step` | Today, Goals, Time, Search, widgets, and Trust are projections; detail and mutation resolve the same canonical owner. | Completion, Not needed, archive influence, Trash, restore, and permanent deletion remain distinct. | `OBJ-DELETION-RESTORE-001`, `OBJ-STEP-IDENTITY-001` |

## Principal journeys

| Blueprint ID | Journey | Commit boundary | Recovery / rollback | Requirements |
| --- | --- | --- | --- | --- |
| `UX-JOURNEY-BACKUP-RESTORE` | Backup, restore, Trash, reset, and permanent deletion | The separately confirmed restore, Trash, reset, or permanent-delete command is the only mutation boundary. | Retry validation, quarantine invalid records, export safe data, or return to current local state. Restore reverses Trash; accepted reset or permanent deletion follows its predeclared irreversible boundary and rollback reference. | `JOURNEY-DELETE-RESTORE-001`, `OBJ-DELETION-RESTORE-001` |
| `UX-JOURNEY-CAPTURE-PLACEMENT` | Capture intent to canonical placement | Save or confirmed placement issues the canonical command; inference and preview are non-mutating. | Retry a failed attachment or placement, remove only the failed attachment, edit the proposal, or keep a safe unresolved draft. Undo a safe recent save or use the created object's owning edit or Trash flow; original Capture evidence remains receipted. | `JOURNEY-CAPTURE-PLACEMENT-001`, `SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001` |
| `UX-JOURNEY-CLOSURE-PROOF` | Closure and proof | Closure commits only after the current proof rule and selected closure meaning validate. | Retry proof storage, edit proof, choose a truthful non-completion closure, or return to the active Step. Undo restores the prior lifecycle where safe and appends correction history rather than erasing the closure fact. | `JOURNEY-STEP-CLOSURE-001`, `OBJ-CLOSURE-SEPARATION-001` |
| `UX-JOURNEY-EXTERNAL-CALENDAR` | External calendar migration and diff review | Only the confirmed bounded change set creates or links native state and its Receipt. | Retry scan, narrow range, edit before import, keep external capacity, quarantine partial input, or leave review unchanged. Undo or Trash an imported native object through its owner; external-source operations use separately receipted reconciliation. | `JOURNEY-CALENDAR-DIFF-001`, `JOURNEY-CALENDAR-IMPORT-COMMIT-001` |
| `UX-JOURNEY-FIRST-USE` | Progressive first use | Each accepted setup preference or account action commits separately; opening the local core requires no account commit. | Repair local readiness, retry the optional step, or continue local-only. Optional settings can be changed later; sign-out retains local data unless deletion is separately confirmed. | `APP-SETUP-PROGRESSIVE-FIRST-USE-001`, `JOURNEY-FIRST-USE-001` |
| `UX-JOURNEY-GOAL-ACTIVATION` | Goal creation and activation | Activation confirmation atomically creates the active Goal, accepted path, accepted placements, and Receipt. | Edit intent, regenerate a bounded route, save draft, remove invalid proposals, or retry atomic activation. Undo activation when safe or pause, end, archive, or Trash through explicit Goal lifecycle controls with history. | `JOURNEY-GOAL-ACTIVATION-001`, `OBJ-GOAL-CREATION-FAILURE-001` |
| `UX-JOURNEY-MISSED-RECOVERY` | Missed work recovery | Only a confirmed material recovery change set mutates schedule or Goal Path. | Retry against refreshed local facts, choose a smaller non-destructive action, or leave the object needing attention. Undo restores prior placement where safe and records the correction in history. | `JOURNEY-RECOVERY-001`, `OBJ-RECOVERY-SEGMENT-IDENTITY-001` |
| `UX-JOURNEY-OFFLINE-CREATE` | Offline local creation | The validated local command commits before any optional external write. | Retry or cancel an optional effect, correct the object, or inspect the durable Receipt. Undo or Trash the local object through its owner; reconcile any already-attempted external effect separately. | `JOURNEY-OFFLINE-CREATE-001`, `APP-DEGRADED-PRESERVE-001` |
| `UX-JOURNEY-SAVED-FOR-LATER` | Saved for Later recovery and promotion | Save for Later creates one durable unresolved draft and Receipt; later promotion is a separate confirmed mutation. | Retry save, edit the draft, remove a failed attachment, or leave it unresolved safely. Undo a recent promotion where safe or return the item to unresolved state with history preserved. | `JOURNEY-SAVED-FOR-LATER-001`, `SPEC-GLOBAL-CAPTURE-SAVED-FOR-LATER-001` |
| `UX-JOURNEY-SCHEDULE-REFLOW` | Schedule direct manipulation and reflow | A valid direct change or confirmed material change set commits atomically through scheduling authority. | Refresh current facts, choose an alternative, reduce scope, or keep the original schedule. Undo re-applies the prior valid placement when safe and records the correction. | `JOURNEY-TIME-DIRECT-MANIPULATION-001`, `OBJ-SCHEDULE-PLACEMENT-ATOMICITY-001` |
| `UX-JOURNEY-SEARCH` | Search Find / Act / Inspect | Search and inspection are non-mutating; an action commits only after owner re-resolution, validation, and material confirmation. | Repair query, clear filters, rebuild from canonical projections, or open a safe owning context. Accepted action Undo belongs to the canonical owner; Search returns to refreshed results. | `JOURNEY-SEARCH-FIND-ACT-INSPECT-001`, `SPEC-GLOBAL-SEARCH-ACTIONS-001` |
| `UX-JOURNEY-STEP-EXECUTION` | Start and complete a Step | Start and completion are separate canonical mutations with separate current-state validation. | Retry validation, keep in progress, move, mark Blocked or Waiting, or return without false completion. Undo restores the prior safe lifecycle and appends correction evidence. | `JOURNEY-STEP-START-COMPLETE-001`, `OBJ-STEP-IDENTITY-001` |

## Cross-cutting design contracts

| Facet | Contract | Variants | Requirements |
| --- | --- | --- | --- |
| `dynamic-type` | Every compact, regular, and accessibility-size layout preserves object identity, full consequence copy, and all actions without horizontal scrolling or semantic truncation. | accessibility sizes, default sizes, long values | `A11Y-DYNAMIC-TYPE-001`, `STANDARD-TYPOGRAPHY-001` |
| `focus-keyboard` | Keyboard, Switch Control, and focus movement follow native order; dismissal, mutation, recovery, and resumed interruption restore focus to the originating object or next truthful state. | external keyboard, focus restoration, switch control | `A11Y-INPUT-EQUIVALENCE-001`, `STD-INTERACTION-FOCUS-001` |
| `light-dark` | System, light, and dark appearances use semantic tokens and preserve hierarchy, privacy, contrast, and state meaning; appearance never changes product behavior. | dark, light, system | `DESIGN-002`, `DESIGN-003` |
| `localization-long-copy` | Copy expands, wraps, pluralizes, and mirrors for locale without hiding object meaning, time semantics, consequences, controls, or trust context. | expanded copy, plural forms, right-to-left | `LOCALIZATION-001`, `LOCALIZATION-003` |
| `motion-haptics` | Motion communicates continuity, route depth, accepted mutation, reflow, closure, and recovery; restrained haptics confirm meaningful selection, snap, success, conflict, or destructive confirmation and never carry meaning alone. | conflict, continuity, selection, success | `SPEC-GLOBAL-MOTION-STATE-CONTINUITY-001`, `STD-INTERACTION-NATIVE-EQUIVALENCE-001` |
| `non-color-semantics` | Shape, label, value, hierarchy, and accessible state carry every status; color, material, motion, and spatial position remain supporting cues only. | differentiate without color, high contrast, monochrome | `A11Y-002`, `A11Y-STATUS-ERRORS-001` |
| `reduce-motion` | Object transforms, rail movement, reflow previews, disclosure, and completion use immediate state changes or restrained fades while preserving announcements, causal order, and focus. | immediate, restrained fade, static equivalent | `A11Y-REDUCED-EFFECTS-001`, `SPEC-GLOBAL-MOTION-ACCESSIBILITY-001` |
| `reduce-transparency` | Materials become opaque semantic surfaces with equivalent grouping, depth, selection, warning, and contrast; no state relies on blur or translucency. | opaque hierarchy, reduced material, solid selection | `A11Y-REDUCED-EFFECTS-001`, `DESIGN-003` |
| `swiftui-anatomy` | Design anatomy assumes native NavigationStack, sheets, full-screen covers, controls, lists, grids, scroll views, focus APIs, accessibility actions, and semantic design-system components; custom rendering requires a semantic native equivalent. | compact presentation, full-screen presentation, native drilldown | `FRONTEND-005`, `STD-INTERACTION-NATIVE-EQUIVALENCE-001` |
| `voiceover-reading-order` | Reading order begins with destination and primary object, then current state and consequence, followed by actions and contextual Trust; custom actions mirror every gesture and focus returns predictably. | actions, headings and rotor, ordered content | `A11Y-002`, `A11Y-READING-FOCUS-001` |

## Authority and proof boundary

The primary Linear V3 document remains unchanged migration corpus. Legacy Figma may be used only as provenance, exploration, failure evidence, implementation history, or a unique-content source pending extraction. It is rejected as the final visual target. Destructive actions remain withheld for Gate C.

This projection does not assert source UI implementation, runtime behavior, rendered-app Visual Green, Accessibility Green, device readiness, privacy/legal approval, TestFlight readiness, App Store readiness, or Release Green.
