# VSP-05 Part 01 Global Capture Composer Options R2

Status: Yellow exploration evidence / VSP-05/F direction owner-approved
VSP: VSP-05 Capture Open Field Composer
Figma file: `SWtHm9ouHTPbEFfNrrtZwv`
Board frame: `207:93`
Frame name: `EXPLORATION - VSP-05 - PART 01 - global Capture composer options - R2`

## Claim Boundary

This frame is exploration evidence for owner direction selection. The owner approved `F - Quiet Placement Review` as the direction to take forward on 2026-06-30. This is direction approval only; it is not a complete VSP-05 candidate package, Visual Green, source implementation, SwiftUI parity proof, device proof, runtime proof, accessibility conformance, release proof, or Done.

R1 at Figma node `206:93` was renamed `FAILURE_EVIDENCE - VSP-05 - PART 01 - R1 oversized typography and board density` after screenshot inspection showed oversized typography, text collision, and weak board density. R2 is the repaired reviewable exploration board.

## Shell Boundary

All six options treat Capture as a full-screen global Stage composer/overlay. They do not introduce:

- a Capture tab or root surface
- an inbox, notes feed, category wall, or chatbot
- a persistent floating plus/Capture affordance
- dock, tab bar, root navigation, Context Crown, or Search placement
- route depth or status bar approximation
- shell safe-area/chrome mutation
- Motion as destination
- Proof / Source / Privacy / History / Receipts as persistent root surfaces

## Options

| Option | Frame node | Direction | Primary read |
|---|---:|---|---|
| A | `207:98` | Living Draft Field | Draft-first, route-later. The text object grows into local placement hints. |
| B | `207:137` | Route Bloom Composer | Distinctive route preview around the draft without category-wall UI. |
| C | `207:176` | Proof-First Capture | Best when files, proof, and receipts are the capture payload. |
| D | `207:215` | Native Keyboard Composer | Most native and keyboard-safe; strongest implementation baseline. |
| E | `207:254` | Constraint Thread Field | Best for fixed points, protected time, and messy reality changes. |
| F | `207:293` | Quiet Placement Review | Safest Codex bridge: draft, route preview, static proof step. |

## Production Gate Review

- Shell contamination: pass for exploration. No VSP-05 option invents VSP-01 shell chrome or persistent root navigation.
- Product law: pass for exploration. Today / Goals / Time / You remain the only root surfaces; Capture remains global composer; Motion remains behavior; trust details stay inspection-only.
- Capture drift gate: pass after R2 repairs. No option uses tab, inbox, category-wall, chatbot, or generic notes-app UI.
- Typography/spatial gate: repaired after export inspection. R1 was demoted to failure evidence. R2 repaired oversized text, bottom keyboard clipping, option D title collision, and B/F keyboard-control overlaps.
- SwiftUI plausibility: Yellow. The options are plausible as `Composer/Capture` + Stage overlay work with custom SwiftUI/Canvas primitives, but no source implementation or parity proof exists.
- Accessibility: Yellow. The board records required acceptance only; no VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, or haptic proof exists.
- iOS 26 component kit: Yellow. Apple iOS 26 library components were discoverable, but current Figma tool permissions did not allow importing those library nodes into this file, so proof uses native-shaped fallback primitives and records the limitation.

## Durable Screenshot Proof

- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r2/vsp-05-part-01-options-board-r2.png`
- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r2/vsp-05-part-01-option-b-route-bloom-composer-r2.png`
- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r2/vsp-05-part-01-option-d-keyboard-native-stage-composer-r2.png`
- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r2/vsp-05-part-01-option-f-quiet-placement-review-r2.png`
- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r1/vsp-05-part-01-options-board-r1.png`

## Recommended Selection Read

My current read:

- F is the safest Codex implementation bridge because it preserves draft, route preview, review, save, and static proof step without becoming a category wall.
- D is the strongest Apple-native keyboard/focus baseline and should strongly influence any selected direction.
- B is the most distinctive Ambitions-native option, but it has higher implementation and accessibility risk.

Owner-approved direction lock: use F as the primary direction for the complete VSP-05 candidate package. D may inform keyboard/focus implementation expectations, but the selected direction remains F and is not a B/D/F synthesis.

## Next Required Packet

Next, build:

- `CANDIDATE - VSP-05 - [selected direction] hero - R1`
- `CANDIDATE - VSP-05 - [selected direction] state matrix - R1`
- `CANDIDATE - VSP-05 - [selected direction] accessibility matrix - R1`
- `CANDIDATE - VSP-05 - [selected direction] SwiftUI anatomy - R1`
- `MARKETING_RENDER - VSP-05 - [selected direction] presentation crop - R1`
- non-claims frame

Acceptance for that packet must include global composer behavior, keyboard-safe layout, dictation/attachment states, route preview, save/review controls, receipt/proof state, static Reduce Motion equivalent, and no shell/root/tab drift.
