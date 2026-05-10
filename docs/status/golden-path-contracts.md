<!-- markdownlint-disable MD013 -->

# Golden Path Contracts

Status: Active Codex execution-excellence contract  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*`

This file defines Ambitions golden paths for validation planning. It is not
implementation proof, test proof, visual proof, accessibility conformance,
performance proof, or release proof.

## 1. Contract Rule

Every implementation or QA batch that touches user-facing behavior must name
the affected golden path, state whether the path is source-present or proven,
and record the validation evidence required before any claim.

## 2. Golden Path Table

| Path | User job | Primary surfaces | Required proof before claiming path works |
| --- | --- | --- | --- |
| Capture to placed object | Capture an idea, clarify it, and place it without losing context | Capture, Today, Goals, Time | Source wiring, placement tests, copy scan, receipt/proof behavior, screenshot or simulator evidence when UI changes |
| Goal to next step | Open a goal and find a grounded recommended step | Goals, Today, Trust Seam | Source/test evidence for projection, source/reason display, no fake certainty, accessibility labels |
| Shape time to action | Understand capacity and choose what fits today | Time, Today | Source/test evidence for capacity state, visual state proof, no calendar-clone drift, Reduce Motion equivalent |
| Start and close a step | Begin work, complete or adjust it, and leave a receipt | Today, Receipt surface, Goals | Source/test evidence for closure state, non-shaming copy, receipt evidence, rollback/recovery path |
| Recover after disruption | Change plan calmly after life changes | Today, Time, You | Source/test evidence for recovery state, no shame language, visible alternatives, no silent mutation |
| Inspect why / trust | Understand why Ambitions suggests or changes something | Trust Seam, You, object details | Source evidence for source/reason/control, privacy/local-only boundary, no opaque model language |
| Review proof | See what happened and what still counts | Goals, You, receipts | Source/test evidence for proof/receipt persistence, no social/gamified drift, accessibility proof when claimed |
| Configure personal system | Adjust defaults, trust, privacy, and controls | You | Source evidence for settings/control state, privacy scan, no backend/provider assumptions |

## 3. Required Contract Fields

For any touched golden path, closeout must include:

- path name
- touched surfaces
- source files changed
- tests or validation run
- visual proof run or not run
- accessibility/motion checks run or not run
- performance check run or not run
- privacy/local-only implications
- false claims not made
- rollback path

## 4. Evidence Hierarchy

Strong evidence:

- current source and focused tests
- current simulator/build logs with exit code
- screenshots tied to current commit/build
- accessibility or performance tool output tied to current commit/build

Weak/supporting evidence:

- docs, design truth, batch plans, old reports, historical screenshots, memory

Weak evidence may guide validation design but must not prove the path.

## 5. Golden Path Stop Conditions

Stop on Red if:

- a path depends on backend/provider/cloud/user-data assumptions not in truth
- a path uses obsolete top-level IA as active user-facing truth
- proof depends on screenshots or logs not tied to current source
- a release, accessibility, performance, or device claim appears without proof
- a primary action is visual-only or inaccessible

## 6. Phase 3 Gate Result

Phase 3 result: Green.

Validation:

- docs-only contract artifact
- no app/source/runtime files touched
- no golden path implementation or release proof claimed

