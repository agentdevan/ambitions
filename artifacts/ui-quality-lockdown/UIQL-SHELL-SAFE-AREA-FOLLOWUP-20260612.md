# UIQL Shell Safe-Area Follow-Up - 2026-06-12

Status: Green for scoped simulator shell geometry follow-up; Yellow for non-claimed device/live accessibility/release proof.

## Trigger

Owner feedback after UIQL project completion reported that the shell safe-area/header band was still too large and made the app feel too low, with the visible screen not using the full available height.

## Scope

This is a narrow UIQL shell geometry repair connected to the completed AMB-970 red-team repair trail and AMB-969 final package evidence. It does not reopen the real Linear issue order and does not claim new owner approval.

Changed source:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`

Artifact added:

- `artifacts/ui-quality-lockdown/screenshots/shell-safe-area-tightened-20260612.jpg`

## Repair

- Removed the duplicate root-level bottom `safeAreaInset` from `AmbitionsRootView`. The per-surface scaffold already reserves dock clearance, so the root reservation compounded bottom safe area and shortened every root surface.
- Tightened root-only top inset overlap in `AppShellView` from `-36` to `-48` for normal Dynamic Type and from `-20` to `-28` for accessibility Dynamic Type. Pushed/back-button screens still keep normal top safe-area behavior.

## Visual Evidence

Screenshot inspected:

- `artifacts/ui-quality-lockdown/screenshots/shell-safe-area-tightened-20260612.jpg`

Observed result:

- Today content now uses materially more vertical height.
- The first viewport begins near the status area instead of sitting below a tall shell band.
- The Meridian dock remains visible and readable as a compact floating rail.
- The screenshot was visually evaluated; the path alone is not treated as proof.

## Validation

- `git diff --check` passed.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-XcodeBuildMCP build` passed with `** BUILD SUCCEEDED **`.
- Build log: `artifacts/ui-quality-lockdown/script-output/shell-safe-area-tightened-build-20260612T165553Z.log`
- `bash scripts/codex/program-preflight.sh uiql || true` was run before commit and returned Red only because the intended Swift source repair was still dirty.
- Clean-tree rerun after the source repair commit passed Green at `37bb5b9aebba33347b4e47a06ddf3734fc0ab091`.
- Clean preflight log: `artifacts/ui-quality-lockdown/script-output/program-preflight-20260612T130037.log`

## Non-Claims

- No owner approval claimed.
- No release, TestFlight, App Store, or readiness claim.
- No physical-device proof.
- No live VoiceOver traversal proof.
- No public accessibility certification.
- No all-surface visual certification beyond the inspected shell follow-up screenshot.

## Rollback

Rollback is limited to reverting the two source hunks in `AmbitionsRootView.swift` and `AppShellView.swift` plus removing this follow-up artifact/screenshot. No data migration, dependency, project-file, or persistence rollback is involved.
