> Supporting note: This file supports Ambitions post-reconstruction polish planning. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Post-Reconstruction Polish Plan

Status: Active supporting governance
Scope: Post-reconstruction primitive, polish, proof, and cleanup sequencing
Owner posture: Plan, not implementation proof

## Current Starting State

The original Active Runtime UI Reconstruction train is not Green. AMB-562 and AMB-563 record a Red aggregate status because AMB-559 found active/runtime UI-adjacent banned-term hits, while AMB-558 and AMB-560 left screenshot and accessibility proof Yellow.

## Priority Order

1. Remove Red blockers.
2. Repair current screenshot proof.
3. Complete live/manual accessibility proof.
4. Install primitive governance.
5. Replace top-level card-like structures with object-first primitives only where source proof identifies them.
6. Promote reusable primitives through the registry and promotion protocol.
7. Re-run final UI quality proof standard.

## Known Follow-Ups

- AMB-604 - regenerate the final screenshot board after simulator recovery.
- AMB-605 - remove active banned-term runtime UI hits and rerun the AMB-559 scan.
- AMB-606 - collect live accessibility screenshots and manual traversal proof.

## Polish Lanes

| Lane | Goal | Gate |
|---|---|---|
| Red blocker repair | Remove active forbidden runtime UI language and stale active patterns | Banned-term/stale-IA scan returns no active/runtime blockers |
| Screenshot proof | Produce current-to-commit screenshot board | Required paths exist and are tied to current source/build evidence |
| Accessibility proof | Validate VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Differentiate Without Color, and tap targets | Automated source proof plus manual/live evidence where required |
| Primitive governance | Keep invention narrow and owner-backed | Registry, taxonomy, Green gate, promotion protocol, polish plan, proof standard installed |
| Primitive promotion | Reuse only proven primitives | Promotion protocol passes |
| Final verdict | Report honest Green/Yellow/Red status | Claims remain inside current evidence |

## Non-Goals

- No top-level IA expansion.
- No Capture tab restoration.
- No generic metric-board, pile-of-panels, chat-transcript, calendar-copy, points, reward-counter, or guilt-pressure polish direction.
- No release, device, public accessibility, privacy/legal, TestFlight, App Store, or product-completion claims without proof.

## Closeout Shape

Post-reconstruction polish issues must close with:

- Scope lane
- Files changed
- Validation run
- Validation not run
- Proof artifacts
- Yellow/Red debt
- Rollback note
- No-readiness-claim boundary
