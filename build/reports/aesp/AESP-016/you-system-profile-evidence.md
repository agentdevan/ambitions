# AESP-016 Evidence Packet

Linear issue: AMB-438
Commit SHA: pending (set after completion)

## Scope map
- Prompt scope files reviewed:
  - Native/Ambitions/Features/You/YouScreen.swift
  - Native/Ambitions/Features/You/YouRootSurface.swift
  - Native/Ambitions/Features/You/YouViewModel.swift
  - Native/Ambitions/Features/You/YouFeatureService.swift
  - Native/Ambitions/Features/You/YouCrossSurfaceProofReviewCard.swift
  - Native/Ambitions/Features/You/YouTrustHistoryCenterCard.swift
  - Native/Ambitions/Features/You/YouTrustHistoryProjector.swift
  - Native/Ambitions/Features/You/YouPlanningDefaultsSectionCard.swift
  - Native/Ambitions/Features/You/YouAvailabilityCenterCard.swift
  - Native/Ambitions/Tests/You/YouFeatureServiceTests.swift (inspected, no new tests added)

No source edits were required for this issue; the You profile surface was already present on main in the checked-out state.

## Validation
- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-016`
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
  - Status: `GREEN`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-016 --prompt prompts/batches/AESP-016.md --batch-type source-changing --allow-yellow`
  - Status: `GREEN`
- `xcodegen generate`
  - Ran successfully; regenerated `Ambitions.xcodeproj`
- `make xcode-build-for-testing BATCH=AESP-016`
  - Result: `xcode validation passed`
- `make xcode-focused-test BATCH=AESP-016 TEST=AmbitionsTests/YouFeatureServiceTests`
  - Result: `xcode validation passed`
- `make xcode-focused-test BATCH=AESP-016 TEST=AmbitionsTests`
  - Result: `xcode validation passed` (full app test suite)
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-016 --prompt prompts/batches/AESP-016.md --changed-from "$(git rev-parse HEAD)" --batch-type source-changing --allow-yellow`
  - Status: `RED` (global run; working tree currently contains unrelated proof JSON edits)
  - Defect: `changed runtime-affecting files lack SourceRecord`
  - Defect: `changed runtime-affecting files lack ReplayTrace`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-016 --prompt prompts/batches/AESP-016.md --changed-from "$(git rev-parse HEAD)" --batch-type source-changing --allow-yellow --changed-path Native/Ambitions/Features/You --changed-path Native/AmbitionsTests/You`
  - Status: `GREEN` (scoped rerun after dirty-path containment)
- `git diff --check`
  - Clean (no whitespace/formatting issues in diff)
- `git diff --stat`
  - 2 files modified: `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json` and `.../same-intent-context-b.json`
- `git status --short --branch`
  - Branch: `main...origin/main`
  - Dirty files remain only in two local proof JSONs above.

## Accessibility and UI checks
- No UI interaction screenshots were captured in this pass.
- No full-accessibility proof pass was run.
- Existing implementation inspection indicates controls and section surfaces follow established You owner patterns; full rendering/accessibility verification remains a follow-up item.

## Validation matrix
- Verified:
  - champion coverage check green
  - pre-guard green
  - `make xcode-build-for-testing` green
  - focused You service tests green
  - full focused test suite green
- Blocked:
  - Post-guard full-path check is `RED` due non-batch working-tree diff from unrelated proof docs missing runtime terms.
- Not verified:
  - screenshot proof
  - explicit accessibility review capture (VoiceOver/Dynamic Type/Reduce Motion evidence)
  - real-device/manual UI evidence

## Current status for Linear AMB-438
- Scope/claim: verification-only packet from existing state; no runtime source edits were authored in this run.
- Boundary: dirty worktree with pre-existing proof JSON modifications at:
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`
- Result: `YELLOW (contaminated post-guard)` if using required post-guard over full working-tree diff; `GREEN` on scoped rerun over You-owned paths.
- Next step in-place:
  - Either clear/revert unrelated proof-diff before re-running mandatory post-guard, or
  - continue with this batch as verification-only with explicit accepted-yellow boundary.
