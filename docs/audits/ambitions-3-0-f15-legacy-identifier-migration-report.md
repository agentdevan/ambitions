# Ambitions 3.0 F15 Legacy Identifier Migration Report

Date: 2026-05-01

Result: Green

## Scope

F15 migrated the safe internal identifiers that had replacement contracts after
F04-F14 while preserving persisted, deep-link, App Intent, widget, share
extension, and notification compatibility. The batch did not change user-facing
behavior, did not rename compatibility-only feature folders, did not touch
workflows, did not add dependencies, and did not make release-readiness claims.

## Migration Map

| Legacy identifier | F15 result | Compatibility decision |
| --- | --- | --- |
| `startFocus` | Migrated to `startStepSession` in active command models, App Intent descriptors, Today command mappings, safety policy, and tests. | Raw command wire value remains `start_focus` for external and stored command compatibility. |
| `bestNextMove` | Migrated to `recommendedStep` in Today execution state, projection, panels, compatibility helpers, and tests. | No persisted or external wire value changed. |
| `capturesInbox` | Migrated to `captureInbox` across app routing, external routing, App Intent destination, external snapshots, share extension, command destinations, Plan/Today call sites, previews, and tests. | Existing deep links and payload raw values remain `captures/inbox`, `captures_inbox`, or `captures-inbox` as appropriate. |
| `activeFocus` | Preserved for now. | External snapshot schema compatibility risk; future migration requires schema-versioned adapter work. |
| `Profile` | Preserved for now. | Current code seam still backs the user-facing `You` surface. Renaming folders/types is broad and not required for user-facing copy correctness. |
| `Insights` | Preserved as compatibility/history route. | Legacy insights routes normalize into You/Profile support routes and tests prove it is not a top-level destination. |
| `Habits` | Preserved as compatibility route/service seam. | Legacy habits routes normalize into Plan/Rituals and tests prove it is not a top-level destination. |

## Files Changed

- App routing and shell command compatibility files.
- App Intent destination and command descriptors.
- Command domain models and executor call sites.
- External snapshot, share extension, widget/action payload contracts.
- Today state/projection/panel compatibility files.
- Plan call sites that route to Capture.
- Focused routing, command, external, App Intent, and Today tests.

## Validation

- Build: `scripts/build-local.sh` PASS on iPhone 17.
- Command tests: `AmbitionsCommandModelsTests` and
  `AmbitionsCommandExecutorTests` PASS, 16 tests, 0 failures.
- Routing/App Intent tests: `AppShellNavigationTests`,
  `ExternalRoutingTests`, and `AppIntentRoutingTests` PASS, 46 tests,
  0 failures.
- Today focused tests: `TodayViewModelTests` PASS, 32 tests, 0 failures.
- Migration scan: no remaining `startFocus`, `bestNextMove`, or
  `capturesInbox` hits under `Native` or `project.yml`.
- Architecture scan: advisory only; no new extraction-required file class was
  introduced by F15.
- Copy guard: broad touched-scope scan still finds pre-existing active/domain
  and test vocabulary such as `failed`, `overdue`, and `missed`; F15 introduced
  no new user-facing forbidden copy.
- Diff whitespace: `git diff --check` PASS.

## Gate

F15 gate result: Green with accepted background Yellow.

F16 may proceed.
