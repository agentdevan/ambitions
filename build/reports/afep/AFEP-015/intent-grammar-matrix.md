# AFEP-015 Intent Grammar Matrix

Batch: AFEP-015
Status: Green after source patch and wrapper validation

## Canonical Root Grammar

| Surface | App Intent destination | Shortcut phrase family | Route URL | Notes |
| --- | --- | --- | --- | --- |
| Today | `today` | Open Today / Show Today | `ambitions://tab/today?origin=app_intent` | Exact root reopen |
| Goals | `goals` | Open Goals / Show Goals | `ambitions://tab/goals?origin=app_intent` | Exact root reopen |
| Capture | `captureInbox` | Open Capture / Show Capture | `ambitions://captures/inbox?origin=app_intent` | Exact root reopen |
| Time | `time` | Open Time / Show Time | `ambitions://tab/time?origin=app_intent` | Exact root reopen |
| You | `you` | Open You / Show You | `ambitions://tab/you?origin=app_intent` | Exact root reopen |

## Compatibility And Action Grammar

| Destination | Purpose | Route behavior | Confirmation / receipt |
| --- | --- | --- | --- |
| `command` | Open quiet add sheet | `ambitions://overlay/quiet-command-sheet?origin=app_intent` | No mutation by itself |
| `memoryLens` | Open What Ambitions Knows | `ambitions://overlay/memory-lens?intent=memory_lens&origin=app_intent` | Inspection only |
| `startNextStep` | Start here | `ambitions://tab/today?context=focus&origin=app_intent` | No silent mutation |
| `markDone` | Close the loop | `ambitions://tab/today?context=focus&origin=app_intent` | Requires in-app confirmation and produces a receipt |
| `saveTheDay` | Recovery posture | `ambitions://tab/today?context=recovery&origin=app_intent` | Requires in-app confirmation and produces a receipt |
| `quickRecovery` | Recovery posture | `ambitions://tab/today?context=recovery&origin=app_intent` | Requires in-app confirmation and produces a receipt |
| `quickFocus` | Focus posture | `ambitions://tab/today?context=focus&origin=app_intent` | No silent mutation |
| `quickTimePatch` | Time root fallback | `ambitions://tab/time?origin=app_intent` | No silent mutation |

## Validation Evidence

- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-015`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/AppIntentRoutingTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ExternalRoutingTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ExternalActionCommandServiceTests`
- `make xcode-focused-test BATCH=AFEP-015 TEST=AmbitionsTests/ShellCommandRouterTests`
- `git diff --check`
