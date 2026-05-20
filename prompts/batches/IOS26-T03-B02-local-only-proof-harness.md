<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T03-B02 — Local-only proof harness

## Batch type
Privacy/runtime proof

## Objective
Add proof fixtures showing the runtime remains local-only and deterministic.

## Why this exists
Local-first claims require source and test evidence.

## Dependencies
IOS26-T03-B01.

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
Native/Ambitions/Runtime/; Native/AmbitionsTests/Runtime/; Native/Ambitions/Persistence/; Native/Ambitions/Resources/PrivacyInfo.xcprivacy.

## Exact changes allowed
Runtime tests, proof harness helpers, docs/reports.

## Exact changes forbidden
No network calls. No dependency additions.

## Implementation steps
Add fixtures for no hosted backend, no remote intelligence, no cloud LLM, local repositories, and no external side effects inside unit-of-work boundaries; record limitations.

## Tests to add/update
Privacy/runtime boundary tests.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```

## Required proof artifacts
build/reports/private-life-runtime/local-only-proof.md

## Accessibility requirements
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## iOS 26 API verification requirements
Privacy manifest remains honest.

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
