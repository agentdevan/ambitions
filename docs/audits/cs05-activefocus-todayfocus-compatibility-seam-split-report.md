# CS05 ActiveFocus/TodayFocus Compatibility Seam Split Report

<!-- markdownlint-disable MD013 -->

Status: CS05A complete with commit evidence.
Date: 2026-05-03

## Batch

- Formal batch ID: `CS05`
- Internal completed stage: `CS05A`
- Global order number: `044`
- Result: PASS WITH YELLOW.
- Validation strength: Adequate docs/protocol evidence.

## Scope Completed

CS05A repairs the original broad ActiveFocus/TodayFocus retirement prompt into a staged map/prove/retire path:

- CS05A: compatibility map, schema ledger, route/payload ledger, and retirement risk map only.
- CS05B: focused external snapshot/widget/App Intent/Today state compatibility proof only.
- CS05C: narrow retirement only if CS05A and CS05B prove it is safe.

CS05A created:

- `docs/audits/cs05-activefocus-todayfocus-compatibility-seam-inventory.md`
- `docs/audits/cs05-activefocus-todayfocus-compatibility-contract-ledger.md`
- `docs/audits/cs05-activefocus-todayfocus-accessibility-route-payload-ledger.md`
- `docs/audits/cs05-activefocus-todayfocus-retirement-risk-map.md`

CS05A repaired:

- `docs/codex/batches/CS05_ActiveFocus_TodayFocus_Retirement_Prompt.md`

## Source Files Read

- `Native/Ambitions/Domain/CanonicalNowStateModels.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/App/ShellCommandModels.swift`
- `Native/Ambitions/App/ShellCommandRouter.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `AppUI/Sources/WidgetFoundation.swift`
- `AppUI/Sources/WidgetFamiliesPrimary.swift`
- `AppUI/Sources/WidgetPreviews.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `Native/AmbitionsTests/Domain/CanonicalNowStateModelsTests.swift`

## Compatibility Findings

- `activeFocus` is a live schema-like external snapshot field and cannot be renamed or deleted without old-payload proof and a schema-versioned adapter.
- `ExternalSurfaceNowState.activeFocus` and `ExternalSurfaceActionPayload` primary reference fallback are compatibility surfaces.
- `TodayFocus*` is a broad Today model/service seam, not a small local rename.
- `.focus`, `context=focus`, `quick_focus`, and App Intent routes are route/raw compatibility surfaces.
- `focusNow` and `FocusNowWidget` are widget/AppUI compatibility surfaces.
- Current user-facing Today direction can remain Step/Start-now oriented while these internal and external compatibility seams remain intentionally.

## Yellow Advisories

| Advisory | Classification | Owner | Why deferral is safe |
| --- | --- | --- | --- |
| `activeFocus` remains in runtime and external snapshot contracts. | Already Owned by Later Batch | CS05B proof, then CS05C decision | Preserving the field prevents schema break and does not create a user-facing implementation claim. |
| `TodayFocus*` state/service names remain. | Already Owned by Later Batch | CS05C or future PD03 Step Session depth | They are broad Today state seams and current user-facing canon does not require immediate internal rename. |
| `.focus`, `quick_focus`, `focusNow`, and FocusNow widget remain. | Already Owned by Later Batch | CS05B/CS05C/future SI | They protect external routes, commands, App Intents, and widget compatibility. |
| Exact focus-related accessibility identifier aliasing is not fully proven. | Already Owned by Later Batch | CS05B if identifiers are touched | CS05A touches no code or identifiers; freeze policy prevents accidental break. |
| Existing repo-wide docs QA backlog remains. | Existing Repo-Wide Advisory | Docs QA backlog | Not caused by CS05A and not required for prompt/ledger repair. |

## Validation Commands

| Command | Result | Notes |
| --- | --- | --- |
| `git status --short` | PASS WITH YELLOW | Dirty files are expected CS05A docs/status files only. |
| `git diff --check` | PASS | No whitespace errors. |
| changed-file boundary check | PASS | Changed and new files are limited to `docs/**` and `.codex/**`; no `Native/**`, `AppUI/**`, `Sources/**`, tests, routes, schemas, dependencies, or workflows were touched. |
| CS05 grep scans | PASS WITH YELLOW | Hits are expected CS05A ledgers, repaired prompt, status docs, historical logs, and guardrails. |
| Release-claim scan | PASS WITH YELLOW | Hits are forbidden-claim lists, scan commands, historical logs, and explicit non-claims; no active readiness or migration-complete claim introduced. |
| `scripts/run-doc-qa.sh || true` | PASS WITH YELLOW | Existing stale-guidance, deprecated-language, and markdownlint backlog remains advisory; lychee passed with 647 total links and 0 errors. |
| `scripts/batch-train-gate-check.sh || true` | PASS WITH YELLOW | Only expected dirty-tree hint before commit. |

## Claims

CS05A may claim the ActiveFocus/TodayFocus seam has been inventoried, compatibility ledgers exist, retirement risk is mapped, and the original broad prompt has been repaired into a staged compatibility path.

## Non-Claims

CS05A does not claim the activeFocus seam is retired, TodayFocus migration complete, FocusNow widget migration complete, `.focus` route replaced, external snapshot schema migrated, accessibility identifiers renamed, physical-device proof, release readiness, App Store readiness, TestFlight readiness, public accessibility conformance, PXOS implementation, Signature Interface implementation, Product Depth implementation, or AmbitionsOS implementation.

## Rollback

Revert the CS05A docs/control files. No app behavior rollback is required because CS05A does not edit app code, AppUI code, Sources code, or tests.

## Next Safe Path

Run CS05B dry-run. Continue only if `Execution allowed: YES`. CS05C remains blocked/deferred until CS05B proves a narrow retirement is safe.

## Commit SHA

`b74f4644`
