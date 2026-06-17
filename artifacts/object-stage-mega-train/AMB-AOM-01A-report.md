# AMB-AOM-01A — Root Surface Contract and AppTab Cleanup

Status: GREEN
Train: `object-stage-mega-train`
Type: `source`
Start SHA: `54064ac802f839eca7fac214345b7f4f4b1cee48`
Commit SHA: `none`
Run dir: `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z`

## Gates

| Gate | Status | Blocking | Summary | Log |
|---|---|---:|---|---|
| prompt_lint | green | true | prompt metadata ok | `` |
| truth_readback | green | true | truth files and product law present | `` |
| codex | green | true | exit=0; timeout=25m | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/codex-output.log` |
| diff_check | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/diff_check.log` |
| allowed_paths | green | true | changed files ok: 20 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/changed-files.json` |
| authority_drift | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/authority_drift.log` |
| local_first_boundary | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/local_first_boundary.log` |
| root_ia_validator | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/root_ia_validator.log` |
| xcodegen | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/xcodegen.log` |
| resolve_packages | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/resolve_packages.log` |
| xcodebuild | green | true | exit=0 | `artifacts/codex-train-v3/runs/object-stage-mega-train/AMB-AOM-01A/20260617T131932Z/gates/xcodebuild.log` |

## Changed files

- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Shared/ActivationContract.swift`
- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/ActivationContractTests.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/ContextualToolbarStateTests.swift`
- `Native/AmbitionsTests/App/CoreReusableInteractionPrimitiveTests.swift`
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`
- `Native/AmbitionsTests/App/FrontendRecoveryGateTests.swift`
- `Native/AmbitionsTests/App/OnboardingAndDegradedStateTests.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`
- `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift`
- `Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift`
- `artifacts/object-stage-mega-train/train-state.json`
