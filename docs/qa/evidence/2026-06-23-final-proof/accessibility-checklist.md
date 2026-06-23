# Accessibility Checklist

Status: automated evidence-contract Yellow; manual/device proof pending.

## Automated Evidence

`AmbitionsTests/AccessibilityNutritionChecklistTests` passed after narrow evidence-contract alignment:

- Executed tests: 21
- Result bundle: `.codex/xcode-results/AMB-1199-final-proof/20260623T213925Z-AmbitionsTests-AccessibilityNutritionChecklistTests-2471-6756/focused-test.xcresult`
- Summary: `.codex/xcode-summaries/AMB-1199-final-proof/20260623T213925Z-AmbitionsTests-AccessibilityNutritionChecklistTests-2471-6756/extract/summary.json`

The repair aligned evidence labels with current source truth:

- `Trust & Automation` -> `Privacy & automation`
- D21 Capture evidence row -> `capture-composer`
- Today accessibility owner path -> `Native/Ambitions/Surfaces/Today/TodaySurface.swift`

## Manual Checklist

| Requirement | Status | Evidence | Gap |
|---|---|---|---|
| VoiceOver labels/actions | Yellow | Automated source-contract coverage names required summaries and manual proof gates. | Manual VoiceOver walkthrough not run. |
| Dynamic Type | Yellow | Automated checklist covers Dynamic Type requirements and current root screenshots show default size only. | Large Dynamic Type screenshot matrix not produced in this train. |
| Reduce Motion | Yellow | Automated checklist covers Reduce Motion fallback requirements. | Reduce Motion runtime walkthrough not run. |
| Reduce Transparency | Yellow | Token/design law exists; no AMB-1199 runtime setting proof. | Runtime Reduce Transparency proof missing. |
| Increase Contrast | Yellow | Automated checklist covers non-color support and contrast categories. | Increase Contrast runtime proof missing. |
| Differentiate Without Color | Yellow | Automated checklist covers non-color meaning. | Runtime setting proof missing. |
| Haptics/settings respect | Not available | No AMB-1199 haptic runtime proof produced. | Manual/device haptic preference review required. |
| Keyboard/focus behavior | Yellow | Capture and You tests in repo cover pieces; not rerun as a complete keyboard/focus matrix. | Full keyboard/focus proof missing. |
| Non-gesture alternatives | Yellow | Automated checklist covers gesture alternatives. | Manual route invocation proof missing for shell/search/capture/time. |

No public accessibility conformance, VoiceOver verified, Dynamic Type verified, or accessibility-ready claim is allowed from this package.
