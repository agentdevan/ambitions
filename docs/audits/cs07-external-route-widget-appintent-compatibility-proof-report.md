# CS07 External Route Widget AppIntent Compatibility Proof Report

<!-- markdownlint-disable MD013 -->

Batch ID: CS07  
Global order number: 039  
Batch name: External Route Widget AppIntent Compatibility Proof  
Date: 2026-05-02  
Result: PASS WITH YELLOW  
Validation strength: Strong focused compatibility validation  
Commit SHA: e4c04ff2

## Scope Completed

CS07 proved the existing external route, widget projection, App Intent / Shortcut route, external action command, external snapshot, external-surface checklist, screen-contract, and release-claim boundary lanes with focused simulator tests. It did not retire seams, delete legacy values, edit Swift, edit tests, change routes/raw values, alter persistence/schema, change user-visible copy, change accessibility identifiers, touch workflows/dependencies, or make release/platform claims.

## Dry-Run Selection

- Selected global batch: 039 - CS07 External Route Widget AppIntent Compatibility Proof.
- Batch prompt path: `docs/codex/batches/CS07_External_Route_Widget_AppIntent_Compatibility_Proof_Prompt.md`.
- Train: CS compatibility seam retirement.
- Current status before execution: queued/blocked/not started; direct successor after CS01.
- Approval phrase satisfied: yes, covered by current `Run Global Batch Sequence Until Blocked` global preauthorization.
- Allowed files for this run: docs/status/audit/report files; focused compatibility validation commands.
- Forbidden files: seam deletion/retirement, Swift edits, test edits, workflows, dependencies, signing/project config, persistence/schema changes, route/raw value changes, behavior/copy/accessibility identifier changes, release/platform claims.
- Required gates: CS01 Green/accepted Yellow, source truth, external route/widget/App Intent compatibility proof, release-claim safety, rollback, continuation.
- Expected validation strength: Strong focused compatibility validation.
- Human-proof risk: Low for simulator/unit proof; platform rendering/device proof remains human/platform-owned and not claimed.
- Expected stop condition: external route/widget/App Intent proof fails, legacy payload compatibility is uncertain, or repair requires broad code changes.
- Execution allowed: YES.

## Execution Budget

- Initial budget: 8 touched files, 1 new report, 0 deleted files, Small/Medium diff, app code not intended, tests not intended to edit, no screenshots/previews, no human proof.
- Actual budget: 9 touched docs/status files, 1 new report, 0 deleted files, Medium diff, docs-only status/evidence update.
- Overrun classification: Yellow - Fix Now / accepted docs-only status-truth overrun.
- Rationale: CS07 status truth needs the proof report, compatibility plan, CS train manifest, registry, context, run-state, train-state, global order, and dependency graph updated together so CS08 is selected safely. No production files, tests, workflows, dependencies, or app behavior were touched.

## Source Files Read

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_FAANG_QUALITY_BAR.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/batches/CS07_External_Route_Widget_AppIntent_Compatibility_Proof_Prompt.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `docs/audits/cs01-compatibility-seam-registry-and-risk-map-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/skills/compatibility-migration-architect.md`

## Proof Coverage

| Proof lane | Test class | Result | What it covers |
| --- | --- | --- | --- |
| App Intent and Shortcut routing | `AppIntentRoutingTests` | PASS, 5 tests | Canonical shortcut route URLs, bounded destinations, launch router queue/consume behavior, no silent destructive shortcut actions. |
| External action commands | `ExternalActionCommandServiceTests` | PASS, 9 tests | Widget/App Intent source distinction, open/complete/snooze route dispatch, missing/unsupported command safe failure, generic widget action fallback. |
| External/deep-link routing | `ExternalRoutingTests` | PASS, 28 tests | Canonical tab routes, goal routes, overlay routes, Today entry contexts, legacy tab payload parsing, `capturesInbox`, legacy Habits route, widget/notification payload shapes, old payload keys. |
| External action payloads | `ExternalSurfaceActionPayloadTests` | PASS, 6 tests | Stable canonical URLs, legacy keys, redaction, command/receipt/sensitive-effect boundaries, old next-action fallback. |
| External snapshots and Live Activity payloads | `ExternalSurfaceSnapshotTests` | PASS, 10 tests | Snapshot serialization/decoding, stale/privacy labels, Live Activity content state, old snapshot decode, privacy-safe ritual cue, mutation refresh decorators. |
| External-surface verification checklist | `ExternalSurfaceVerificationChecklistTests` | PASS, 4 tests | External-surface checklist coverage without readiness claims, stale/private/fallback behavior, app-group snapshot container posture. |
| Widget projection | `ExternalWidgetProjectionTests` | PASS, 3 tests | Widget projection contract, private-detail hiding, stale state, missing-snapshot fallback. |
| Release external truth | `ReleaseExternalTruthReadinessPacketTests` | PASS, 5 tests | Unsupported release-claim guardrails, human/device gates, privacy/accessibility claim boundaries, no new top-level surfaces. |
| Screen contracts | `ScreenContractRegistryTests` | PASS, 11 tests | Canonical five-tab shell contract, external-surface contract-only boundaries, old top-level tab/copy guard, screen matrix integrity. |

## Compatibility Findings

- Old external route and payload compatibility remains intentionally preserved.
- `capturesInbox` still routes into canonical Capture and remains a compatibility seam, not a deletion candidate yet.
- Legacy Habits tab payloads still route into canonical destinations and remain a compatibility seam, not a deletion candidate yet.
- Widget and notification payloads continue to share canonical action payload shapes while preserving legacy keys.
- External snapshots still decode older snapshot shapes and preserve privacy/stale fallback posture.
- App Intent and shortcut route tests prove route contract behavior in simulator/unit scope only.

## Yellow Advisories

| Advisory | Classification | Owner | Safe to defer? | Notes |
| --- | --- | --- | --- | --- |
| Initial CS07 test wrapper exited nonzero after tests passed because the shell command used zsh's read-only `status` variable | Tooling/Environment Advisory | CS07 | Yes; fixed by rerun | Same focused test lane was rerun with a bash-safe wrapper and passed with command exit 0. |
| Simulator test logs include `NOT_CODESIGNED` app group lookup messages under `CODE_SIGNING_ALLOWED=NO` | Tooling/Environment Advisory | Human/platform proof lane | Yes | Focused tests passed; this is not physical-device, signed-archive, or App Group entitlement proof. |
| CS07 touched 9 docs/status files instead of the initial 8-file budget | Fix Now / accepted Yellow | CS07 | Yes | Docs-only status-truth overrun required to keep report, registry, context, run-state, global order, and dependency graph aligned. |
| Existing repo-wide doc QA and markdownlint backlog remains | Existing Repo-Wide Advisory | Docs QA backlog | Yes | Not caused by CS07 and not blocking focused compatibility proof. |

## Red Issues

No unresolved Red was found. Focused compatibility tests passed. No code was edited, no tests were edited, no seam was retired, no route/raw-value/persistence behavior changed, and no release/platform claim was introduced.

## Validation Commands Run

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "external|Profile|You|Insights|Habits|activeFocus|TodayFocus|\\.focus|failed|rawValue|deepLink|widget|AppIntent|import|export" Native docs .codex || true`
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/AppIntentRoutingTests -only-testing:AmbitionsTests/ExternalWidgetProjectionTests -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ExternalSurfaceVerificationChecklistTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/ReleaseExternalTruthReadinessPacketTests test CODE_SIGNING_ALLOWED=NO`
- Passing log: `output/logs/cs07-external-compatibility-tests-20260502-135725.log`.
- `git diff --check`: PASS.
- Changed-file boundary check: PASS; dirty files were limited to `docs/**` and `.codex/**`.
- Focused markdownlint on changed CS07 docs/status files: PASS WITH YELLOW; registry/context docs still carry the existing long-line/multiple-blank-line markdownlint backlog.
- Release-claim scan: PASS WITH YELLOW; hits were forbidden-claim lists, scan commands, historical logs, or explicit non-claims only.
- `scripts/run-doc-qa.sh || true`: PASS WITH YELLOW; stale-guidance, deprecated-language, and markdownlint advisory logs remain, while lychee passed with 647 total links and 0 errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW; expected dirty-tree hint before commit only.

## What CS07 Claims

- CS07 claims focused simulator/unit compatibility proof passed for current external route, widget projection, App Intent / Shortcut route, external action command, external snapshot, external-surface checklist, screen-contract, and release-claim boundary lanes.
- CS07 claims old payloads tested in the focused lane still open or fall back safely.
- CS07 claims no seam was retired.

## What CS07 Does Not Claim

- It does not claim all compatibility seams are retired.
- It does not claim external platform rendering, widget display/tap behavior on device, App Shortcuts visibility in the OS, notification delivery, physical-device proof, signed archive validation, App Store Connect validation, TestFlight readiness, public accessibility conformance, legal/privacy signoff, human visual approval, or final release approval.
- It does not claim PXOS, SI, Product Depth, or AmbitionsOS implementation.
- It does not claim import/export or persistence compatibility proof; CS08 owns that lane.

## Rollback Path

Revert the CS07 docs/status/report commit. Because CS07 is evidence/docs-only and no code/persistence/routes/raw values were changed, rollback does not require migration or app repair.

## Next Eligible Batch

If CS07 is committed/pushed and post-commit drift checks remain Green or accepted Yellow, the next global batch is:

`Global Order 040 - CS08 Import Export Persistence Compatibility Proof`
