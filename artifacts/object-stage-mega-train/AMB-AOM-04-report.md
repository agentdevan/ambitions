# AMB-AOM-04 — Capture Global Composer

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `32484b183d8d61eba6f6168449b3f5248d0dca37`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=35m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 2 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-04/20260617T142754Z/gates/xcodebuild.log` |

## Changed files

- `artifacts/object-stage-mega-train/AMB-AOM-04-report.md`
- `artifacts/object-stage-mega-train/train-state.json`
