<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T00-B03 — Naming/API drift inventory

## Batch type
Read-only drift/API audit

## Objective
Inventory naming drift and iOS 26 API candidates before source changes.

## Why this exists
Plan/Profile/Captures and unverified iOS 26 APIs are high-risk migration seams.

## Dependencies
IOS26-T00-B01.

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
Native/Ambitions/App/; Native/Ambitions/Features/; Native/Ambitions/AppIntents/; Native/AmbitionsUITests/; Native/AmbitionsTests/; Sources/; AppUI/Sources/; docs/truth/; docs/codex/; docs/audits/.

## Exact changes allowed
docs/audits/ios26-naming-drift-inventory.md; docs/audits/ios26-api-verification-ledger.md

## Exact changes forbidden
No renames, no API adoption.

## Implementation steps
Grep requested terms; classify active occurrences as compatibility/user-facing/test/historical/pre-shell/pre-release; create API ledger with verified/candidate/not applicable; include Liquid Glass, GlassEffectContainer, tab APIs, SwiftData, WidgetKit, ActivityKit, App Intents, Spotlight, BackgroundTasks, accessibility APIs.

## Tests to add/update
None.

## Commands to run
```bash
grep -RIn "plan\|Plan\|profile\|Profile\|captures\|Captures\|habits\|Habits\|insights\|Insights\|DayTimelineRail\|Hero Step\|Mission Control\|Task" Native Sources AppUI docs prompts 2>/dev/null || true
xcrun swift -version || true
xcodebuild -version || true
```

## Required proof artifacts
Drift inventory and API ledger.

## Accessibility requirements
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## iOS 26 API verification requirements
Local SDK unavailable is Yellow; mark candidates needing SDK confirmation.

## Green / Yellow / Red closeout rules
Green: scoped changes complete, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: forbidden source/runtime/project mutation outside scope, unverified API adoption, privacy/local-first breach, release/readiness overclaim, or missing required truth-file read.

## Rollback strategy
Revert only files touched by this batch. Do not use broad reset or discard unrelated work. Delete malformed generated reports if this is docs/proof only.

## Final report format
```text
Status: Green / Yellow / Red
Batch:
Train:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
Passes:
Failures:
Skipped:
Unproven:
Accessibility status:
Privacy/local-first status:
iOS 26 API verification status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
