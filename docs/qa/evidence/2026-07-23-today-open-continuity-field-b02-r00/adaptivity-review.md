# Accessibility, adaptivity, and device proof matrix

| Mode | Automated Simulator proof | Manual Simulator proof | Physical-only remainder | Evidence |
| --- | --- | --- | --- | --- |
| Standard / Accessibility 5 | identifiers, order, targets, action reach | full journeys, scrolling, no clipping | physical reading comfort | F01-F10, J03 |
| VoiceOver | labels, values, traits, custom actions, expected order metadata | Accessibility Inspector traversal and announcements | spoken order, rotor/custom-action discoverability, focus restoration | accessibility ledger, J03 |
| Increased Contrast | environment variant and state/target assertions | Dark/Light comparison and low-relief inspection | OLED low-brightness comfort | S06, C04 |
| Differentiate Without Color | node-shape/text assertions | grayscale comparison | physical grayscale/vision comfort | A02, C04 |
| Reduce Transparency | opaque-chrome identifier/value | crown/dock and modal chrome inspection | physical material appearance | A01, C04 |
| Reduce Motion | no spatial animation policy tests | complete J05 journey | physical vestibular comfort | J05, C04 |
| Button Shapes / Bold Text | host variants and target/order assertions | action hierarchy inspection | physical preference comfort | C04 diagnostics |
| Smart Invert | host/system variant when Simulator exposes it | image/symbol/material inspection | physical OLED appearance | diagnostic ledger |
| RTL `ar-SA` | no-English guard, order, native Back/chevrons | complete semantic journey and dock | physical VoiceOver speech | S05, J03 diagnostics |
| Long LTR | complete copy fixture and target assertions | wrapping and natural scroll | physical reading comfort | A03, C04 |
| Compact / Pro Max / resizable | launch variants, target/order assertions | full/half/contact inspection | real Dynamic Island/call-state safe areas | CI01, PM01, RS01 |
| Switch Control | semantic group/action inventory | Simulator scan where supported | physical scan cadence and dock use | accessibility ledger |
| Full Keyboard Access | focusable order inventory | Simulator keyboard traversal where supported | physical keyboard behavior | accessibility ledger |
| Voice Control | unique localized command-name scan | Simulator command discoverability where supported | physical recognition accuracy | accessibility ledger |
| Left/one-handed reach | 44-point geometry and dock placement | mirrored screenshots and reach-zone audit | actual reach, accidental activation | adaptivity review |
| Edge gestures | native Back/UI test and edge spacing audit | Simulator swipe Back/dock dismissal | physical right-edge competition | J04, known limitations |
| Status-bar/Dynamic Island pressure | safe-area variants when available | expanded status-bar screenshot | call-state and hardware variations | adaptivity review |
| Low brightness | contrast-role assertions | dimmed Simulator/display inspection | physical OLED verification | L01, known limitations |

Keyboard avoidance is not applicable because B02 contains no editable input.
The branch does not add fake input to manufacture proof.
