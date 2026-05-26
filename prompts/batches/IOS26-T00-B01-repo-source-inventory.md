<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T00-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T00-B01`

## Train ID and title
`TRAIN_00` - Repo truth, audit, validation baseline

## Batch role in train
Batch 1 of 3 in TRAIN_00

## Upstream dependencies
- none

## Downstream dependencies
- `TRAIN_01`
- `TRAIN_03`
- `TRAIN_15`

## Objective
Create a current source inventory and underdevelopment baseline.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## Accessibility constraints
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.

## Allowed files/directories
docs/audits/ios26-underdevelopment-source-baseline.md; build/reports/ios26-baseline/README.md

## Forbidden files/directories
No Swift/source/project/package/runtime/persistence/test edits.

## Exact implementation steps
Record branch/SHA/date; inspect required paths; classify each area using the approved labels; separate source proof from release proof; list underdeveloped areas; do not infer build/test success.

## Validation commands
```bash
git status --short
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
find . -maxdepth 3 -type f | sort
```

## Proof artifacts to write
docs/audits/ios26-underdevelopment-source-baseline.md
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/frontend-object-purity/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: scoped changes complete, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: forbidden source/runtime/project mutation outside scope, unverified API adoption, privacy/local-first breach, release/readiness overclaim, or missing required truth-file read.

## Rollback behavior
Revert only files touched by this batch. Do not use broad reset or discard unrelated work. Delete malformed generated reports if this is docs/proof only.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
