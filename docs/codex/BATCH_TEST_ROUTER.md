# Batch Test Router

Use this router for focused validation selection only. It does **not** replace batch-specific owners.

## Surface-family routing

| File family | Likely focused validation commands | xcodegen needed | xcodebuild test needed | Screenshot/visual proof needed | GPT-5.5 senior judgment required | Full-suite green claim? |
| --- | --- | --- | --- | --- | --- | --- |
| Persistence / SwiftData | focused repository persistence tests for changed owners | Usually no (unless schema file references changed) | Yes, when source changes in storage seam | No | Often yes when data trust/fidelity rules are inferred | No |
| Domain models | focused domain model/unit tests | No | Yes for model contract tests | No | Yes for cross-surface meaning or trust posture | No |
| Services | focused service extraction/integration tests for touched service files | No | Yes if deterministic behavior changed | No | Usually no for small routing changes; yes for behavior-critical branches | No |
| Today feature | focused Today feature tests / fixtures in owner seam | No | Yes if runtime files changed | Usually no unless UI behavior changed | Yes | No |
| Goals feature | focused Goal-related tests and projector tests | No | Yes if behavior contracts touched | No | Yes when evidence boundaries include trust/proof behavior | No |
| Capture feature | focused Capture pipeline tests | No | Yes if capture extraction paths are touched | No | Yes | No |
| Time / Plan compatibility seam | focused extraction tests in compatibility owners + compatibility seam tests | No | Yes for seam regressions | No | Yes for hidden migration/compatibility effects | No |
| You / Profile | focused profile or settings contract tests | No | Yes if profile/test seam changed | No | Yes when trust or onboarding posture is implicated | No |
| External surfaces | focused external-surface checks and platform-specific tests | No | Yes if external-facing behavior changed | No | Yes | No |
| Widgets | focused widget behavior fixture tests + screenshot packet if runtime UI changed | No | Yes if runtime path touched | Possibly | Yes | No |
| Live Activities | focused Live Activity fixture or state contract tests | No | Yes if template/state behavior changed | Sometimes | Yes | No |
| App Intents | focused App Intent unit tests and schema checks | No | Yes if shortcut/intents behavior changed | No | Yes | No |
| Notifications / EventKit / Reminders | focused permission-free state tests and integration stubs | No | Yes if service layer changed | No | Yes | No |
| Codex OS docs/tooling | script output review + `make prompt-audit`, `make batch-self-check` | No | No | No | No (unless queue-state conflict) | No |
| Prompt templates | static template lint plus no-runner metadata audits | No | No | No | No unless claim policy changed | No |
| Repo governance | state/registry reads and schema checks from scripts | No | No | No | No to no-confidence if missing files | No |
| Visual/UI-facing SwiftUI | focused UI tests and fixture checks for changed screens | No | Yes for changed feature tests | Yes | Yes | No |
| Privacy/legal/security docs | document evidence scan and no-claim checks | No | No | No | Yes when claim posture changes | No |
| Release/proof docs | static evidence packet review and prompt-audit + queue-state checks | No | No | No | Yes | No |

Notes:
- “Full-suite green” must never be claimed without a full, passing suite command and explicit evidence.
- Any lane route should include the known-yellow check before execution and route to repair/finalization when relevant.

