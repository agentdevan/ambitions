# Accessibility and content-stress review

Device ceiling: iPhone 17 Pro Simulator only. Direct-device proof remains open.

| Requirement | Evidence | Result / ceiling |
| --- | --- | --- |
| Standard Dynamic Type | F01–F04, F06–F10, UI suite | No essential truncation or overlap; review commit and cancel are visible before scrolling. |
| Accessibility Dynamic Type | F05, J03, accessibility-review UI test | Adaptive passage recomposes navigation; review actions remain reachable by natural scrolling. |
| VoiceOver order/actions | Semantic source order, identifiers, labels, UI queries | Distinct human action names and logical order; physical spoken-order/focus proof remains open. |
| Increased Contrast | S06 and review hierarchy test | Current and proposed truth retain label, symbol, hierarchy, and border/spacing distinctions without hue alone. |
| Differentiate Without Color | Labels, symbols, selected trait/checkmark | Meaning and selected Today do not rely on color. Physical setting review remains open. |
| Reduce Transparency | Opaque content and authored opaque functional chrome | No glass content panel; physical setting verification remains open. |
| Reduce Motion | System environment and native transitions | Authored return animation respects the environment; physical vestibular review remains open. |
| Genuine RTL | S05, Arabic UI test | `ar-SA` Arabic, leading/trailing alignment, mirrored Back, localized time/numerals, mixed-direction proper noun, logical query order. Not production localization proof. |
| Long localization | Arabic long consequence in S05 | Wraps without losing meaning; natural scroll remains available. |
| Target size | Full UI suite | Required buttons, dock, and navigation commands meet at least 44×44 points. |
| Keyboard | No editable input | Not applicable to this slice. |
| One-handed reach | Bottom review actions and dock | Simulator geometry only; physical reach remains open. |
| Low-brightness Dark | Dark frame family | No glow; physical inspection remains open. |
| Back gesture | Native NavigationStack | No custom replacement; physical edge competition remains open. |

The Arabic translation is marked evaluation-only and does not claim linguistic
completeness. Voice Control names are distinct: Continue nursery setup, Still
counts, Record progress, Not now, View history, Return to Today, Continue where
you left off, and Leave this for later.

Open device obligations: VoiceOver speech and focus restoration, Switch
Control, Full Keyboard Access, Voice Control, physical reach, system-edge
competition, low-brightness Dark, Reduce Motion, Reduce Transparency, multiple
device safe areas, and assistive-input timing.
