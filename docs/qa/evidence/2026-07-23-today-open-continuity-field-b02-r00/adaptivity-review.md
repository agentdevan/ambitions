# B02 adaptivity review

Status: `PROPOSED`

## Tested environments

| Environment | Simulator | Pixel frame | Result |
| --- | --- | ---: | --- |
| Compact / narrow | iPhone 17e, iOS 26.5 | 1170x2532 | PASS: Start Here, action, timeline entry, and dock remain legible; natural continuation remains available. |
| Standard Pro | VC14 iPhone 17 Pro, iOS 26.5 | 1206x2622 | PASS: primary validation and accessibility matrix device. |
| Wide / Pro Max | B02 iPhone 17 Pro Max, iOS 26.5 | 1320x2868 | PASS: hierarchy expands without fixed-coordinate drift or stretched action anatomy. |
| Accessibility pressure | iPhone 17 Pro, Accessibility 5 | 1206x2622 | PASS: review recomposes vertically; commit and cancel are visible, reachable, and safe-area clear. |
| RTL | iPhone 17 Pro, `ar-SA` | 1206x2622 | PASS: leading/trailing geometry, symbols, rail, dock edge, and localized date/time mirror natively. |
| Long LTR | iPhone 17 Pro | 1206x2622 | PASS: identity wraps naturally; required root action remains available; content continues with native scrolling. |

The compact iPhone is the narrow physical-Simulator proving environment and Pro
Max is the wide physical-Simulator proving environment. The installed CoreSimulator
26.5 runtime exposes no resizable iPhone device type, so iPhone Mirroring/freeform
window-width proof remains open rather than being simulated with a fake frame.
No fixed screenshot-coordinate layout was added. The same package view contract
and fixture family render in all tested environments.

## Layout behavior

- Root, focused object, review, Full Day, settlement, interruption, and recovery
  stay in native vertical scroll containers with visible continuation indicators.
- Safe-area review actions remain in the existing native inset region and never
  flow under the home indicator.
- The compact crown uses its established clamped scroll transform; RTL and
  Accessibility Navigation Passage crowns grow naturally rather than clipping
  localized meaning. Passage command labels remove their two-line cap at
  accessibility sizes and remain available through natural scrolling.
- Timeline identity remains primary, with time and relationship allowed to wrap
  or move vertically instead of being compressed into fixed columns.
- Crowned Edge Dock Peek remains outside the scroll plane. Its visible seam stays
  narrow while the accessibility target remains at least 44 points. A native
  indicator margin reserves a distinct trailing region; the UI geometry test,
  rather than a transient-indicator screenshot claim, verifies nonintersection.
- Native Back remains present at focused depth and Full Day. Native sheet
  dismissal and truthful recovery choices remain unchanged.

## Reach and safe-area review

- The UI test inventories visible custom buttons in the AX5 review and opaque-
  dock pressure surfaces, requires distinct names, and asserts minimum 44 by 44
  geometry. It separately scrolls through and target-checks all six AX5 Adaptive
  Navigation Passage commands.
- Compact, standard, and Pro Max frames show no crown/content or dock/content
  overlap. Required action text is not obscured.
- The right-edge dock remains reachable in Simulator geometry, but actual left-
  hand, right-hand, and one-handed comfort cannot be closed without a device.
- System-edge gesture competition remains a direct-device obligation.

## Environment support matrix

| Mode | Automated proof | Native evidence | Open ceiling |
| --- | --- | --- | --- |
| Accessibility 5 | vertical order, targets, reachability | AX5 review frame | physical reading comfort |
| VoiceOver | labels, values, input labels, focus anchors, semantic order | UI hierarchy inspection | spoken order and rotor behavior |
| Increased Contrast | real Simulator setting readback plus state assertions | contrast review frame | OLED low-brightness comfort |
| Differentiate Without Color | paired nodes, dashed seam, labels | no-color review frame | physical grayscale comfort |
| Reduce Transparency | opaque dock branch and identifier | opaque root frame | physical material appearance |
| Reduce Motion | Task 09 state-policy tests and journey media | M02 recording/frame | physical vestibular comfort |
| Button Shapes / Bold Text | native Buttons and semantic system typography retained; `simctl ui` has no setting for either | ordinary native-control rendering | physical preference comfort |
| RTL `ar-SA` | Arabic-only label guard and logical vertical order | genuine RTL root frame | physical Arabic VoiceOver speech |
| Long LTR | outcome reachability | long-LTR root frame | production localization breadth |
| Compact / Pro / Pro Max | identical package contract; Pro UI matrix plus device-specific native renders | three native device frames | resizable iPhone Mirroring, physical safe areas / call state |
| Voice Control | distinct localized input-label scan | named controls in UI hierarchy | recognition accuracy |
| Switch Control / Full Keyboard Access | native control inventory | not fully exercisable in this pass | physical cadence and traversal |
| Keyboard | not applicable: no editable input exists | none | add only when a real input is authorized |

## Evidence

- `screenshots/task10-accessibility-adaptivity/B02-T10-compact-iphone17e-root.png`
  (`d0343ec52a36b70962d03f973d424b01290a613d26eddce37b849fd11c323dc7`)
- `screenshots/task10-accessibility-adaptivity/B02-T10-pro-max-root.png`
  (`353f7c0bd1279f032d663e390eb9d734c35b036a9abfa06953b4b7925f61e024`)
- `screenshots/task10-accessibility-adaptivity/B02-T10-active-scroll-indicator-dock-clear.png`
  (`3a2d199dbbbb9947bca65ff4021f46b2b1300f81205859a34516f27564ce0c02`)
- Standard, accessibility, locale, and contrast frames are inventoried in
  `accessibility-review.md`.

## Unresolved direct-device obligations

Physical VoiceOver, Voice Control, Switch Control, Full Keyboard Access,
Button Shapes, Bold Text, one-handed reach, left-hand dock use, edge gestures,
touch comfort, Dynamic Island/call-state pressure, low-brightness OLED, physical
Reduce Motion/Transparency, Smart Invert, grayscale, haptics, thermal behavior,
multi-device safe-area comfort, and narrow/wide resizable iPhone Mirroring remain
incomplete.

These Simulator frames are evaluation references, not production baselines.
They do not complete direct-device proof or authorize broader reconstruction.
