<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T00-B01 — Repo source inventory

## Batch type
Read-only audit/proof baseline

## Objective
Create a current source inventory and underdevelopment baseline.

## Why this exists
No source-changing train should run from stale docs, old prompts, or inferred implementation state.

## Dependencies
None.

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
README.md; AGENTS.md; project.yml; Package.swift; docs/truth/*; Native/Ambitions/{App,Runtime,Domain,Services,Persistence,Features,UI}/; Sources/; AppUI/Sources/; widget/share extensions; tests; scripts; docs/codex; docs/audits; build/reports.

## Exact changes allowed
docs/audits/ios26-underdevelopment-source-baseline.md; build/reports/ios26-baseline/README.md

## Exact changes forbidden
No Swift/source/project/package/runtime/persistence/test edits.

## Implementation steps
Record branch/SHA/date; inspect required paths; classify each area using the approved labels; separate source proof from release proof; list underdeveloped areas; do not infer build/test success.

## Tests to add/update
None.

## Commands to run
```bash
git status --short
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
find . -maxdepth 3 -type f | sort
```

## Required proof artifacts
docs/audits/ios26-underdevelopment-source-baseline.md

## Accessibility requirements
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## iOS 26 API verification requirements
Inventory target/platform status only; no unverified API recommendations.

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
