# AMB-AOM-01B — Root Shell Routing and Compatibility Fallbacks

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `8ceff04edc271ee08911bf23494f85848a030b49`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=25m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 4 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01B/20260617T132826Z/gates/xcodebuild.log` |

## Changed files

- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `artifacts/object-stage-mega-train/train-state.json`
