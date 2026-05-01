# Ambitions 3.0 F07 Capture Composer Cleanup Report

Date: 2026-04-30
Result: Green with accepted background Yellow

## Scope

F07 cleaned up the Capture composer around Ambitions 3.0 placement language. The batch kept Capture composer-driven, preserved the top-level Capture destination, and prepared the visible preview for later Needs a Place / Ready to Place / Grow into Goal routing without implementing F08 or F09 behavior.

## Changes

- Added post-input placement state titles to `CaptureDraftRoutePreview`: `Suggested Place`, `Needs a Decision`, and `Needs a Place`.
- Added canonical preview command labels: `Place it`, `Change`, and `Decide later`.
- Updated the Capture screen contract snapshot and registry requirement from `Recent captures` to `Ready to Place`.
- Removed user-facing inbox framing from touched Capture copy.
- Extracted `CaptureDraftRoutePreviewCard.swift` from `CapturesScreen.swift` after the screen briefly crossed the architecture threshold during implementation.

## Explicit Non-Goals

- No Placement Resolver behavior was implemented.
- No Grow into Goal behavior was implemented.
- No Plan Life Suite behavior was implemented.
- No Shell/Meridian work was performed.
- No global legacy identifier migration was performed.
- No `.github/workflows` files, runtime dependencies, paid services, persistence contracts, release claims, or FAANG handoff claims were changed.

## Validation

- `xcodegen generate` PASS.
- `scripts/build-local.sh` PASS on `iPhone 17`.
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CapturesViewModelTests` PASS, 11 tests.
- `scripts/swiftui-architecture-scan.sh` PASS/advisory. `CapturesScreen.swift` finished at 606 lines, down from 680 pre-batch lines.
- Touched-path copy guard found only guardrail copy, negative test assertions, and internal `triage` / failure-state taxonomy.
- `git diff --check` PASS.
- `.github/workflows` remained untouched.

## Gate Classification

Green:

- Build passed.
- Focused Capture tests passed.
- Touched-path copy guard introduced no user-facing inbox/backlog/chat/assistant/fake-AI language.
- Privacy/accessibility posture remained local and visible; no account, sync, calendar, hidden personalization, or silent automation behavior was added.
- Architecture warning introduced during implementation was repaired by extraction before closeout.
- Report and tracking docs were updated.

Accepted background Yellow, unchanged:

- Doc QA advisory backlog.
- Known full UI smoke failures outside current focused scope.
- Known legacy/internal identifier backlog outside F07.
- Known large files outside current touched scope.
- Known markdown/link backlog.

New Yellow/Red:

- None remaining after repair. The stale `Recent captures` screen-contract mismatch and temporary `CapturesScreen.swift` line-count threshold crossing were corrected before the gate.

## Next Batch

F08 Placement Resolver should strengthen the Capture placement resolver and object lifecycle checks without starting F09 Grow into Goal or broad Goals/Plan work.
