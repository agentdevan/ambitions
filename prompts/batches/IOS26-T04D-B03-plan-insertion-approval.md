<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B03 - Plan insertion approval

## Objective
Convert scheduled capture text into a Time/Plan insertion candidate with approval.

## Why this exists
Scheduled capture text can be valuable, but it must never silently mutate schedule or calendar state. Ambitions must propose a Time item, show impact, require approval, preserve Decide later, and write a receipt for the decision.

## Dependencies
IOS26-T04D-B01, IOS26-T04D-B02, TRAIN_03, TRAIN_04, TRAIN_04A, TRAIN_04B, TRAIN_04C, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- Runtime
- Goal compiler
- Recommendation engine
- Source Atlas runtime bridge
- Life Context
- Time
- Goals
- Today
- You
- Persistence
- Receipts
- Replay
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- Preview fixtures

## Exact changes allowed
- Add or connect `PlanInsertionCandidate`.
- Convert scheduled capture text into a proposed Time item.
- Require explicit user approval for Ambitions-created schedule changes.
- Require explicit permission and confirmation for calendar writes.
- Detect conflicts and protected time.
- Preserve Add to Time, Attach to goal, Save as context, Decide later, Change time, and Do not use for planning.
- Add tests and `build/reports/capture-runtime-bridge/plan-insertion-approval.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no hidden profiling
- no silent calendar mutation
- no silent schedule mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required runtime objects
`PlanInsertionCandidate` fields:
- captureID
- title
- proposedStart
- proposedEnd
- timeConfidence
- scheduleImpact
- conflictStatus
- affectsProtectedTime
- requiresCalendarPermission
- requiresUserApproval
- approvalOptions

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect Time/Plan compatibility seams, schedule services, EventKit boundaries, protected time, and receipts.
3. Define plan insertion candidate contract.
4. Convert "play pickleball at 8 next Tuesday" into a proposed Time item, not a committed mutation.
5. Surface ambiguity, conflict, protected time, and calendar permission requirements before commit.
6. Preserve Decide later and Save as context when scheduling is declined.
7. Record the user decision in a receipt.

## Tests to add/update
- Plan insertion candidate is created for scheduled capture text.
- Date/time ambiguity asks clarification.
- No silent schedule mutation.
- No calendar write without permission and confirmation.
- Conflict/protected time is surfaced.
- User approval is required for schedule changes.
- Receipt records decision.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B03 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B03 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/plan-insertion-approval.md`

## Accessibility requirements
Schedule impact, conflict state, and approval controls must be VoiceOver-readable, Dynamic Type-safe, Reduce Motion-safe, and not color-only.

## Privacy/local-first requirements
Schedule candidates remain local-first. Calendar writes require explicit user permission and confirmation. Sensitive context must not be logged.

## iOS 26 API verification requirements
Any iOS 26 API, EventKit, or calendar-related API use must be verified against deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: candidate is created; no silent mutation; conflicts/protected time are surfaced; approval is required; receipt records decision.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: schedule/calendar mutates silently or calendar write occurs without explicit confirmation.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B03 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Plan insertion proof:
Approval proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next batch:
```
