# Accessibility and content-stress review

Revision: `AVF-TODAY-S10-R01`

Device ceiling: iPhone 17 Pro Simulator evidence only. Direct-device proof is
required and incomplete.

| Requirement | Evidence | Result / ceiling |
| --- | --- | --- |
| Standard Dynamic Type | `TFCS-F01`–`F04`, `F06`–`F10`; UI tests | Large system type renders without essential truncation or overlap. |
| Accessibility Dynamic Type | `TFCS-F05`, `TFCS-J03`; UI test | Accessibility 1 recomposes to the Adaptive Navigation Passage and natural scrolling keeps the journey available. |
| VoiceOver order | Accessibility identifiers/labels and ordered UI queries | Semantic order is inspectable and coherent in the host; direct spoken-order and physical focus proof remain open. |
| VoiceOver actions | Distinct labelled buttons and UI action queries | Required actions expose object-specific names; direct-device rotor/action proof remains open. |
| Increased Contrast | `TFCS-S06` | Current/proposed structure and text contrast survive the Simulator setting. |
| Differentiate Without Color | Labels (`Current · Accepted`, `Proposed · Not yet accepted`), symbols, selection checkmark/trait | Meaning does not depend on hue; physical assistive-input confirmation remains open. |
| Reduce Transparency | Authored opaque dock/crown path keyed to the system environment | No content surface uses glass; direct-device inspection of the opaque functional-chrome branch remains open. |
| Reduce Motion | State transitions suppress authored animation through the system environment | Native motion remains default; direct-device vestibular review remains open. |
| Long copy | `TFCS-S05` | Meaning wraps and scrolls instead of truncating. Copy is fixture stress content, not a translation. |
| RTL | `TFCS-S05` | Layout direction mirrors semantic order and controls without hiding meaning. Locale-quality review remains open. |
| Keyboard present | No editable input exists | Not applicable to this bounded slice; future editors require separate proof. |
| One-handed reach | Native bottom actions and dock targets | Simulator geometry is inspectable; physical reach remains open. |
| Low-brightness Dark | Deep-graphite frames | No glow is present; physical low-brightness inspection remains open. |
| Back gesture | Native `NavigationStack` depth | No custom gesture replaces native Back; physical edge-gesture coexistence remains open. |

## Semantic and target audit

- Navigation commands are ordered Today, Goals, Time, You, Search, Capture.
  The four roots and two global actions are separate accessibility groups.
- Today selection uses text, a checkmark, and the selected trait, not color
  alone.
- Required controls use a minimum 44-point interaction envelope. A focused UI
  test initially measured the primary control at 34.33 points; `.controlSize(.large)`
  corrected the reproducible failure and the test now passes.
- Current truth stays authoritative through review and saving. Proposed and
  settled truth have explicit semantic labels and do not replace one another.
- Voice Control names are distinct and meaningful (`Continue nursery setup`,
  `Still counts`, `Record Still counts`, `Return to Today`, and object-scoped
  recovery choices).
- The crown is pinned above the single native scroll owner. A focused UI test
  confirms it and the dock remain visible while dense Today scrolls.
- No inspected capture contains text or a required control beneath the dock or
  crown. Required off-screen meaning remains reachable by natural scrolling.

## Remaining direct-device obligations

VoiceOver speech/focus restoration, Switch Control, Full Keyboard Access, Voice
Control, physical one-handed reach, system-edge competition, Reduce Motion,
Reduce Transparency, low-brightness Dark, multiple device safe areas, and
assistive-input timing remain incomplete. This report does not close them.
