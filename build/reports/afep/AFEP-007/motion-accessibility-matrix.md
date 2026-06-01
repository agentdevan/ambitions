# AFEP-007 Motion and Accessibility Matrix

Batch: `AFEP-007`

This matrix summarizes the deterministic semantic compiler outputs used by the bounded patch.
It is source-derived evidence, not a claim of runtime release readiness.

| Input | Reduced-motion equivalent | Non-color cues | Haptic policy | Accessibility notes |
| --- | --- | --- | --- | --- |
| `startHereRecommendation` | Static recommendation card, selected label, and because line. | recommendation label, because line, selected action | none | Recommendation meaning stays visible without motion or haptics. |
| `routeOrientation` | Immediate destination title, preserved back path, and selected row label. | route label, selected destination, back path preserved | `routeChange` | Route change feedback remains user initiated and subordinate to visible orientation copy. |
| `proofReceipt` | Static receipt or proof label with source and undo or correction text. | receipt title, source label, undo or correction path | `completion` | Proof meaning stays readable even when motion is reduced. |
| `sourceFreshness` | Static source-state label before any commitment can move. | source state label, freshness copy, review affordance | none | Review state remains visual and inspectable without motion. |
| `captureDraft` | Instant capture context with unchanged hierarchy and draft state. | text field focus, draft state, placement after content | none | Capture remains text-first and non-ambient. |
| `lifeShapeReview` | Static capacity and pressure label with review-needed action. | capacity label, pressure text, review-needed action | none | Time review stays review-first instead of calendar-clone-like motion. |
| `recoveryClosure` | Static recovery label and next action without shake or reward motion. | recovery label, next action, reversible choice | `correction` | Recovery stays correction-forward and never uses haptics as the sole signal. |
| `privacyBoundary` | Static privacy label with no private-detail reveal. | private item, boundary copy, no detail reveal | none | Boundary meaning remains explicit without disclosure through animation. |
| `unsafeRedirect` | Static safety redirect label and professional-boundary copy. | safety boundary, alternate action, professional copy | none | Safety meaning remains legible without motion or reward cues. |
| `localOnlySettle` | Static local-only label and unchanged data-boundary text. | local-only label, data boundary, no remote claim | none | Local-only meaning stays inspectable and non-ambiguous. |

## Provenance seam coverage

When runtime provenance is attached, the compiler keeps the following seams explicit:

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `What Ambitions knows`

