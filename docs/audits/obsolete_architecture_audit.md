# Obsolete Architecture Audit

Status: Train 1 generated audit artifact  
Scope: Findings are classification targets only; no files were deleted or migrated in Train 0/1.

## Search Summary

- Command used: `rg -n -i --glob !docs/audits/design_truth_readback.md --glob !docs/audits/design_truth_refraction_audit.md --glob !docs/audits/file_by_file_truth_ledger.md --glob !docs/audits/obsolete_architecture_audit.md --glob !docs/audits/large_swift_file_discipline_audit.md --glob !docs/audits/stub_adapter_retirement_audit.md --glob !docs/audits/forbidden_language_audit.md RootTab|MainTab|TabRoot|RootTabView|MainTabView|AmbitionsTabView|TabShell|RootShell|Surfaces/Motion|MotionSurface|MotionView|MotionTab|MotionStageScene|MotionLens|MotionRoot|Surfaces/Capture|CaptureTab|CaptureRoot|CaptureDestination|CaptureScreenShellMode|topLevelCapture|captureInbox|openCapturesInbox Native Sources AppUI docs prompts scripts tools Package.swift project.yml AGENTS.md README.md`
- Hit count: 257
- File count: 63
- Raw output bytes: 31608
- Raw log replaced with summary: False

## Sample Findings

- Native/Ambitions/App/AmbitionsRootView.swift:202:                case .captureInbox:
- Native/Ambitions/App/AppBootstrapper.swift:221:        case .captureInbox, .none:
- Native/Ambitions/App/AppBootstrapper.swift:223:                .openTimeRoute(.captureInbox),
- Native/Ambitions/App/AppExternalRouting.swift:115:            objectKind: .rootTab,
- Native/Ambitions/App/AppExternalRouting.swift:142:            objectKind: .rootTab,
- Native/Ambitions/App/AppExternalRouting.swift:151:            objectKind: .rootTab,
- Native/Ambitions/App/AppExternalRouting.swift:17:        case rootTab
- Native/Ambitions/App/AppExternalRouting.swift:404:            return ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox)
- Native/Ambitions/App/AppExternalRouting.swift:416:            case .captureInbox:
- Native/Ambitions/App/AppExternalRouting.swift:417:                return ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox)
- Native/Ambitions/App/AppExternalRouting.swift:44:            owningTab == (target == .captureInbox ? .today : .time)
- Native/Ambitions/App/AppExternalRouting.swift:486:            return token.captureID == nil ? .openTab(fallbackTab) : .openTimeRoute(.captureInbox)
- Native/Ambitions/App/AppExternalRouting.swift:524:            case .captureInbox:
- Native/Ambitions/App/AppExternalRouting.swift:526:                    surface: .captureInbox,
- Native/Ambitions/App/AppExternalRouting.swift:543:                surface: .captureInbox,
- Native/Ambitions/App/AppExternalRouting.swift:600:            case .captureInbox:
- Native/Ambitions/App/AppExternalRouting.swift:603:                    surface: .captureInbox,
- Native/Ambitions/App/AppExternalRouting.swift:70:            objectKind: .rootTab,
- Native/Ambitions/App/AppExternalRouting.swift:805:            if target == .captureInbox {
- Native/Ambitions/App/AppExternalRouting.swift:806:                navigation.openCapturesInbox(source: entrySource)

## Top Hit Files

| File | Hits |
| --- | --- |
| scripts/ambitions-design-truth-refraction-audit.py | 28 |
| Native/Ambitions/App/AppExternalRouting.swift | 19 |
| Native/Ambitions/Features/Capture/CaptureScreen.swift | 19 |
| Native/Ambitions/Domain/CaptureModels.swift | 13 |
| Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift | 12 |
| Native/Ambitions/Features/Time/TimeFeatureService.swift | 12 |
| Native/AmbitionsTests/App/ExternalRoutingTests.swift | 10 |
| Native/AmbitionsTests/App/ShellCommandRouterTests.swift | 8 |
| docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md | 8 |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | 8 |
| Native/Ambitions/App/AppNavigation.swift | 5 |
| Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift | 5 |
| Native/Ambitions/PreviewSupport/PreviewTimeScenarios.swift | 5 |
| Native/Ambitions/Runtime/DedicatedDevicePrototypeRuntime.swift | 5 |
| Native/Ambitions/Services/AmbitionsCommandExecutor.swift | 5 |
| Native/Ambitions/Services/ExternalActionCommandService.swift | 5 |
| Native/AmbitionsTests/App/AppShellNavigationTests.swift | 5 |
| Native/Ambitions/App/ShellCommandModels.swift | 4 |
| Native/AmbitionsTests/App/AppIntentRoutingTests.swift | 4 |
| Native/AmbitionsTests/Capture/CaptureViewModelTests.swift | 4 |

## Classified Architecture Findings

| File | Classification | Design Truth issue | Recommendation | Proof needed | Status |
| --- | --- | --- | --- | --- | --- |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | obsolete architecture | none | replace | architecture conformance scan<br>authority readback<br>forbidden language scan | Red |
| docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md | obsolete canon | Format backup is obsolete supporting canon and must not override active truth. | delete | authority readback<br>forbidden language scan | Delete |
| Native/Ambitions/Features/Motion/MotionCurrentScreen.swift | obsolete architecture | Motion feature file remains outside Stage/Motion behavior ownership. | replace | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan | Red |
| docs/truth/HISTORICAL_POLICY.md | obsolete canon | Historical policy says active IA includes Motion; PRODUCT_DESIGN_TRUTH wins with Today / Goals / Time / You. | delete | authority readback<br>forbidden language scan | Delete |
| Native/Ambitions/Features/Capture/CaptureScreen.swift | preview-only | CaptureScreen still exposes topLevelCapture shell mode for compatibility/previews. | split | build<br>focused tests<br>forbidden language scan | Red |
| Native/Ambitions/App/ShellCommandModels.swift | oversized | Motion-named shell command source remains as compatibility vocabulary for audit review. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>large file audit | Red |
| Native/Ambitions/App/AmbitionsRootView.swift | needs split | Root shell still uses technical TabView; native tab chrome is hidden but StageRoot guard is not yet formalized. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>large file audit | Red |
| Native/Ambitions/App/AppNavigation.swift | needs split | Capture inbox compatibility route remains and must be validated as overlay/global composer, not root destination. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>large file audit | Red |
| Native/Ambitions/Features/Motion/MotionCurrentAction.swift | obsolete architecture | Motion feature file remains outside Stage/Motion behavior ownership. | replace | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan | Red |
| scripts/ambitions-historical-baseline-train-guard.py | obsolete canon | none | delete | not applicable | Delete |
| scripts/governance/ambitions-historical-registry-extract.py | obsolete canon | none | delete | not applicable | Delete |
| PURGE_HISTORICAL_MANIFEST_20260616T230124.txt | obsolete canon | none | delete | authority readback | Delete |
