# AMB-AOM-07 — Shell and Visual Foundation

Status: GREEN
Train: `object-stage-mega-train`
Type: `visual`
Start SHA: `b1baf0df7150c78ff4c7147f0bfe2e9158a313a7`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=35m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 1 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-07/20260617T175230Z/gates/xcodebuild.log` |

## Changed files

- `Sources/Components/NavigationPrimitives.swift`
- `artifacts/object-stage-mega-train/train-state.json`
