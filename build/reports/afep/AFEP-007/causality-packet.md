# AFEP-007 Causality Packet

Batch: `AFEP-007`

This packet describes the deterministic semantic compiler added in `Sources/Components/MotionPrimitives.swift`.
It is source-derived design evidence, not release proof.

## Inspection seams

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `What Ambitions knows`

When provenance is referenced, the compiler attaches the following lightweight inspection context:

- `sourceRecordSeamID`: `SourceRecord`
- `receiptSeamID`: `Receipt`
- `replayTraceSeamID`: `ReplayTrace`
- `whatAmbitionsKnowsSeamID`: `What Ambitions knows`
- `inspectionSurfaceLabel`: `What Ambitions knows`

## Deterministic compiler contract

The compiler maps semantic inputs to:

- typography role
- visual state
- color token name
- material role
- SF Symbol name
- motion token
- reduced-motion equivalent
- non-color cues
- haptic policy

Haptics remain reinforcement only. The compiler never treats haptics as the only confirmation path.

## Sample compiled outputs

| Input | Typography | Visual state | Color token | Material role | Symbol | Motion | Haptics |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `startHereRecommendation` | `heroDisplay` | `focus` | `semanticColors.focus` | `hero` | `sparkles` | `panelReveal` | none |
| `routeOrientation` | `title` | `focus` | `semanticColors.focus` | `band` | `arrow.triangle.branch` | `routeOrientation` | `routeChange` |
| `proofReceipt` | `sectionTitle` | `success` | `colors.success` | `elevated` | `checkmark.seal.fill` | `proofConfirm` | `completion` |
| `sourceFreshness` | `bodySecondary` | `review` | `semanticColors.review` | `overlay` | `doc.text.magnifyingglass` | `sourceCheck` | none |
| `captureDraft` | `bodyPrimary` | `capture` | `semanticColors.capture` | `widget` | `tray.and.arrow.down.fill` | `panelReveal` | none |
| `lifeShapeReview` | `titleCompact` | `calendarDerived` | `semanticColors.calendarDerived` | `quietGlass` | `calendar.badge.clock` | `reviewRequired` | none |
| `recoveryClosure` | `bodyEmphasized` | `recovery` | `semanticColors.recovery` | `success` | `arrow.uturn.backward.circle.fill` | `correctionNeeded` | `correction` |
| `privacyBoundary` | `caption` | `protected` | `semanticColors.protected` | `graphiteRecess` | `lock.shield.fill` | `privacyBoundary` | none |
| `unsafeRedirect` | `caption` | `risk` | `semanticColors.risk` | `warning` | `exclamationmark.triangle.fill` | `unsafeRedirect` | none |
| `localOnlySettle` | `micro` | `protected` | `semanticColors.protected` | `canvas` | `lock.fill` | `localOnlySettle` | none |

## Non-color cues

Each output carries explicit non-color cues so meaning does not depend on chroma alone.

Examples:

- recommendation label, because line, selected action
- route label, selected destination, back path preserved
- receipt title, source label, undo or correction path
- source state label, freshness copy, review affordance
- text field focus, draft state, placement after content

