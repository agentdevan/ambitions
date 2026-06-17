# AMB-AOM-01C — Root IA Tests and Stale Motion Assertions

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `f201641cafdff9c3f9e6af08cc76cd80dacfc415`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=25m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 10 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01C/20260617T133537Z/gates/xcodebuild.log` |

## Changed files

- `Native/AmbitionsTests/DesignSystem/SemanticDesignTokenCatalogTests.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `Native/AmbitionsTests/Runtime/GoldenVerticalSliceRuntimeTests.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/object-stage-mega-train/train-state.json`
- `scripts/ambitions-frontend-authority-preflight.py`
- `scripts/ambitions-frontend-drift-check.py`
- `scripts/ambitions_frontend_authority_common.py`
