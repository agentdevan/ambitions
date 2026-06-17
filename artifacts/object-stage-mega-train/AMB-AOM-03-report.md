# AMB-AOM-03 — Motion Demotion to Behavior

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `29b05a966a08e595c7b037eaff7d1124992d6d59`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=35m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 2 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-03/20260617T142349Z/gates/xcodebuild.log` |

## Changed files

- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `artifacts/object-stage-mega-train/train-state.json`
