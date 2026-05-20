<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T03-B01 — Runtime kernel contracts

## Batch type
Runtime architecture

## Objective
Introduce Private Life Runtime kernel contracts without breaking existing services.

## Why this exists
The moat needs one inspectable deterministic decision boundary.

## Dependencies
Train 0 and Train 1.

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
Native/Ambitions/Runtime/; Native/Ambitions/Domain/; Native/Ambitions/Services/; Native/AmbitionsTests/Runtime/.

## Exact changes allowed
Runtime contracts, adapter models, tests.

## Exact changes forbidden
No cloud/backend/LLM dependencies. No UI changes.

## Implementation steps
Add kernel protocol/equivalent, trace context, decision input/output/record; wrap/adapt existing factory behavior; prove local-only boundary.

## Tests to add/update
Runtime unit tests.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```

## Required proof artifacts
build/reports/private-life-runtime/kernel-contracts.md

## Accessibility requirements
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## iOS 26 API verification requirements
No external AI/backend introduced.

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
