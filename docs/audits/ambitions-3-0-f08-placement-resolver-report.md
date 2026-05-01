# Ambitions 3.0 F08 Placement Resolver Report

Date: 2026-04-30
Result: Green with accepted background Yellow

## Scope

F08 strengthened the existing Smart Attachment placement resolver by adding an explicit placement preview contract. The batch focused on making destination, object ownership, Today impact, consequence, and privacy posture visible before confirmation. It did not start F09 Grow into Goal or any broad Goals/Plan work.

## Changes

- Added `SmartAttachmentPlacementPreview`.
- Threaded placement preview data through `SmartAttachmentCaptureDecision`.
- Capture draft previews now carry original text, object type, appearance destination, consequence, Today impact, and privacy label.
- `CaptureDraftRoutePreviewCard` renders placement consequence and privacy label.
- Added focused Smart Attachment and Capture tests for Ready/Needs-a-Place placement preview behavior.
- Extracted placement preview logic into its own 139-line domain file after a temporary `SmartAttachmentModels.swift` line-count warning during implementation.

## Explicit Non-Goals

- No Grow into Goal behavior was implemented.
- No Goal Mission Control behavior was implemented.
- No Plan Life Suite behavior was implemented.
- No Shell/Meridian work was performed.
- No global legacy identifier migration was performed.
- No `.github/workflows` files, runtime dependencies, paid services, persistence contracts, release claims, or FAANG handoff claims were changed.

## Validation

- `xcodegen generate` PASS.
- `scripts/build-local.sh` PASS on `iPhone 17`.
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests -only-testing:AmbitionsTests/CapturesViewModelTests` PASS, 21 tests.
- `scripts/swiftui-architecture-scan.sh` PASS/advisory. Final current-scope files stayed in responsibility review: `SmartAttachmentModels.swift` 572 lines, `CapturesScreen.swift` 606 lines.
- Touched-path copy guard found only internal taxonomy, negative test assertions, and existing no-calendar-change safety copy.
- `git diff --check` PASS.
- `.github/workflows` remained untouched.

## Gate Classification

Green:

- Build passed.
- Focused Capture and Smart Attachment tests passed.
- Touched-path copy guard introduced no user-facing inbox/backlog/chat/assistant/fake-AI language.
- Privacy/accessibility posture remained local, visible, and confirmation-based.
- Temporary architecture warning introduced during implementation was repaired by extraction before closeout.
- Report and tracking docs were updated.

Accepted background Yellow, unchanged:

- Doc QA advisory backlog.
- Known full UI smoke failures outside current focused scope.
- Known legacy/internal identifier backlog outside F08.
- Known large files outside current touched scope.
- Known markdown/link backlog.

New Yellow/Red:

- None remaining after repair.

## Next Batch

F09 Capture-to-Goal / Grow into Goal should implement the explicit capture-to-goal handoff without building full Goal Mission Control or broad Goals architecture.
