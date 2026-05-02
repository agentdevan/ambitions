# ME07 PlanScreen Extraction Prompt

Status: Queued Ambitions 4.0 maintainability/extraction batch; not started; not implemented; blocked pending `Start ME Train`.

## Batch Identity

- Batch ID: `ME07`
- Name: PlanScreen Extraction
- Mode: extraction only
- Owner file or files: `Native/Ambitions/Features/Plan/PlanScreen.swift`
- Extraction target: Extract Plan screen composition without redesign.

## Purpose

Reduce known large-file and ownership risk without changing Ambitions product behavior, visible copy, accessibility identifiers, routes, raw values, persistence, dependencies, workflows, release posture, or platform claims.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/codex/batch-trains/ME01_ME12_MAINTAINABILITY_EXTRACTION_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/skills/large-file-extraction-architect.md`
- `.codex/skills/faang-staff-ios-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `wc -l Native/Ambitions/Features/Plan/PlanScreen.swift` when the owner path is concrete
- `rg -n "TODO|compat|route|accessibilityIdentifier|Start here|What Ambitions Knows|failed|Profile|You" Native/Ambitions/Features/Plan/PlanScreen.swift || true` when the owner path is concrete

Stop if the branch is not `main`, the owner file has unclassified user changes, predecessor ME gates are not Green, or the mode does not match this batch.

## Allowed Files

- The owner file(s) named above, only when the mode permits code edits.
- New helper/projector/state files directly extracted from the owner file, with names recorded before edits.
- Focused tests proving behavior preservation.
- `docs/**` and `.codex/**` for reports, traceability, and evidence.

## Forbidden Files

- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project release config, persistence/schema files
- Route/raw-value compatibility changes unless a CS train owns them
- Product behavior expansion, visual redesign, copy changes outside documented preservation needs
- Accessibility identifier changes without explicit replacement tests
- New top-level navigation, AOS behavior, release claims, platform integration, backend/sync/account/model/runtime work

## Implementation Boundary

Map current responsibilities first. Extract only one responsibility family at a time. Preserve public behavior and test contracts before moving code. Do not combine cleanup with behavior work. Keep the diff-size budget explicit; if the planned diff becomes broad or touches multiple feature owners, stop and split.

## Required Non-Goals

No opportunistic cleanup, no visual redesign, no new behavior, no dependency/workflow changes, no compatibility seam retirement, no route/raw-value changes, no release-readiness language.

## Required Validation Commands

- `git status --short`
- Focused tests for the owner file's existing product contract
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/build-local.sh || true` when app code changed
- `git diff --check`

## Required Evidence Outputs

- ME batch report with owner file, responsibilities moved, behavior-preservation evidence, rollback path, diff-size summary, and residual risk
- Updated registry/context/run-state after evidence
- Test impact matrix update
- Maintainability review result
- Compatibility review result if routes/raw values/import-export/persistence/external payloads are even mentioned

## Green / Yellow / Red Criteria

Green: owner and extracted files are named, behavior-preservation proof passes, copy/accessibility/route compatibility remain stable, and architecture scan does not reveal new unowned growth.

Yellow: advisory doc/tooling backlog, optional tool absence, or known large-file debt remains but is classified and not worsened.

Red: behavior changed unintentionally, tests weakened, broad cleanup mixed in, owner uncertainty, route/raw-value drift, accessibility identifier mismatch, dependency/workflow change, release overclaim, or unclassified validation failure.

## Stop Conditions

Stop on Red, owner ambiguity, diff-size budget breach, unowned target files, missing focused proof, route/persistence/external compatibility uncertainty, or pressure to combine multiple ME batches.

## Rollback / Repair Expectations

Keep a rollback plan that can restore the owner file to pre-batch behavior. Preserve failing logs and open ME11 only after the failure is classified. Do not delete tests without retired-expectation documentation.

## What This Batch Must Not Claim

It must not claim product depth, AmbitionsOS implementation, release readiness, App Store/TestFlight/device/accessibility readiness, or compatibility seam retirement.

## What This Batch Does Not Prove

It does not prove future AOS safety, public accessibility conformance, physical-device behavior, platform integration, or release readiness.

## Commit Message Recommendation

`Run ME07 PlanScreen Extraction`

## Next Safe Prompt / Next Gate

Continue only to the next ME batch after Green evidence is recorded, committed, and pushed. Yellow or Red requires a repair or user decision prompt.
