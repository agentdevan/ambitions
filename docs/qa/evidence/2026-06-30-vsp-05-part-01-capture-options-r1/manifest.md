# VSP-05 Part 01 Capture Composer Options R1 Failure Evidence

Status: Yellow failure evidence
Date: 2026-06-30
Figma file: `SWtHm9ouHTPbEFfNrrtZwv`
Board node: `206:93`
Board name: `FAILURE_EVIDENCE - VSP-05 - PART 01 - R1 oversized typography and board density`

## Scope

This evidence folder records the failed first attempt at VSP-05 Part 01 Capture composer options. It is retained to prevent repeating the typography, density, and spatial defects.

## Proof Files

| File | Node | Purpose |
|---|---:|---|
| `vsp-05-part-01-options-board-r1.png` | `206:93` | Full failed board showing oversized typography and weak board density. |
| `vsp-05-part-01-option-a-living-draft-field-r1.png` | `206:98` | Option A failed crop. |
| `vsp-05-part-01-option-d-keyboard-native-stage-composer-r1.png` | `206:290` | Option D failed crop with oversized text. |
| `vsp-05-part-01-option-f-quiet-placement-review-r1.png` | `206:418` | Option F failed crop with clipped/overlapped controls. |

## Failure Reasons

- Oversized typography from incorrect text sizing in several nodes.
- Text and control collision in multiple options.
- Keyboard/reference controls were clipped or overlapped.
- Board readback became too dense to support owner selection.

## Repair Routing

R2 replaced this board as the reviewable owner-selection artifact:

- `docs/design/provenance/figma-frames/VSP-05-part-01-global-capture-composer-options-R2.md`
- `docs/qa/evidence/2026-06-30-vsp-05-part-01-capture-options-r2/manifest.md`

## Non-Claims

This packet does not prove owner approval, Visual Green, SwiftUI implementation, device behavior, runtime behavior, accessibility conformance, release readiness, or Done.
