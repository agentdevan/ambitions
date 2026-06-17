# AMB-AOM-02 — Stage Spine and Motion Behavior

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `0528ff95cb025ef8dbacf37e224ca6c453b68345`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=35m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 5 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-02/20260617T141434Z/gates/xcodebuild.log` |

## Changed files

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/Features/Motion/MotionCurrentAction.swift`
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/Ambitions/Projection/StageMotionProjection.swift`
- `Native/Ambitions/Stage/StageOwner.swift`
- `artifacts/object-stage-mega-train/train-state.json`
