# Accessibility and adaptivity baseline audit

Status: B01 scaffold usable; B02 reconstruction required. Simulator-testable
findings below are implementation blockers. Direct-device findings remain open.

| ID | Severity | B01 failure | Required B02 transformation |
| --- | --- | --- | --- |
| AX-01 | Critical | Accessibility evidence stops at `.accessibility1`. | Add complete `.accessibility5` journey and natural vertical recomposition. |
| AX-02 | Critical | Review actions remain horizontal at every size. | Use adaptive vertical actions at accessibility pressure; keep both 44+ and reachable. |
| AX-03 | Critical | RTL leaves hard-coded English in product and accessibility copy. | Localize every visible label/hint/value through fixture copy; allow only deliberate mixed-direction identity. |
| AX-04 | Critical | Only iPhone 17 Pro portrait is proven. | Render compact, Pro, Pro Max, narrow resizable, and wider/iPad-compatible widths; remove fixed dock/time widths. |
| AX-05 | High | VoiceOver order is claimed but not inspected. | Define and test machine-inspectable semantic order for every stage; keep physical spoken proof open. |
| AX-06 | High | Saving, settlement, interruption, recovery, return, and dock expansion have no state announcements. | Add restrained platform announcements without repeating whole screens. |
| AX-07 | High | State focus anchors do not prove actual assistive focus restoration. | Add explicit focus for dock, review/recovery dismissal, History close, settlement, and returned object. |
| AX-08 | High | Focused depth uses redundant `Start Here` navigation title. | Remove it; preserve native Back and Today provenance. |
| AX-09 | High | Scroll indicators are blanket-hidden. | Restore native indicators where continuation exists and prevent collision with dock Peek. |
| AX-10 | High | Fixed time/dock widths threaten localization and resizable layout. | Use adaptive alignment and container-relative dock sizing. |
| AX-11 | High | Differentiate Without Color has no authored branch or frame. | Add structural node/seam/text variants and grayscale inspection. |
| AX-12 | High | Increased Contrast leaves muted surfaces/actions nearly unchanged. | Author contrast variants for palette, surfaces, controls, and state regions. |
| AX-13 | High | RTL does not traverse the complete journey or shell. | Run root, dock, focus, review, saving, settlement, return, recovery, and Full Day in `ar-SA`. |
| AX-14 | High | Start Here/focus grouping can duplicate headings and identity. | Use one Today heading, one Start Here group, concise relationships, separate action. |
| AX-15 | High | No truthful custom VoiceOver actions exist. | Add only useful object-level Open Step/Open Full Day actions; retain ordinary buttons. |
| AX-16 | High | Target assertions omit Details, History, Full Day, and future rows. | Inventory and assert every interactive target across size/locale stress. |
| AX-17 | Medium-high | Reduce Motion covers only two local animations. | Centralize motion policy and capture full Reduce Motion journey. |
| AX-18 | Medium-high | Opaque dock fallback is unrendered. | Audit all transient chrome and capture Reduce Transparency proof. |
| AX-19 | Medium-high | Dark relief may vanish at low brightness. | Strengthen geometry/spacing/contrast without glow; retain physical OLED proof. |
| AX-20 | Medium-high | Button Shapes, Bold Text, grayscale, Smart Invert are untested. | Add Simulator-testable checks and document platform gaps. |
| AX-21 | Medium | Voice Control names/hints are not localized or inventoried. | Create distinct localized command-name inventory. |
| AX-22 | Medium | Expanded dock lacks explicit keyboard/focus order proof. | Preserve native buttons, visible focus, and coherent traversal. |
| AX-23 | Medium | Passage rows cap labels at two lines. | Relax line limit at accessibility/localization pressure. |
| AX-24 | Medium | Long LTR expansion exists but was never rendered. | Add independent long-LTR frame. |
| AX-25 | Medium | Timeline rows do not distinguish actionable and read-only semantics. | Use native navigation only for source-backed rows; never imitate controls. |

## Direct-device obligations

Physical VoiceOver speech/custom actions/focus, Switch Control, Full Keyboard
Access, Voice Control recognition, left/right/one-handed dock reach, edge-gesture
competition, haptic character, OLED low-brightness/grayscale, physical Reduce
Motion/Transparency, Dynamic Island/call-state safe areas, touch comfort,
thermal behavior, and real-device performance remain incomplete.

No editable input exists. Keyboard avoidance is not applicable unless B02 adds
a real input, which this specification does not authorize.
