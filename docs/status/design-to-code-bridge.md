<!-- markdownlint-disable MD013 -->

# Design To Code Bridge

Status: Active design-to-code constraint map  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/PRODUCT_DESIGN_TRUTH.md` and live source

This bridge maps active design truth into implementation constraints. It is not
implementation proof and does not authorize SwiftUI redesign work by itself.

## 1. Bridge Rule

Before Codex changes UI/source, it must translate the requested change through:

1. product object
2. golden path
3. SwiftUI primitive
4. state contract
5. accessibility/motion requirement
6. validation/proof requirement

If any step is missing, Codex must stop or classify the gap before editing.

## 2. Design Truth To Code Constraints

| Design truth | Code constraint | Validation route |
| --- | --- | --- |
| Today / Goals / Capture / Time / You | Do not add sixth tab or revive obsolete top-level IA | product drift scan, source owner review |
| One primary object per top-level surface | Avoid top-level card piles and equal-weight module stacks | visual proof and primitive contract |
| Local-first inspectable intelligence | No external LLM/cloud/backend dependency for core behavior | privacy/trust scan and source review |
| Trust Seam explains why/source/control | Recommendation or automation UI must expose source/reason/control | source tests, copy scan, accessibility review |
| Receipts preserve proof | Meaningful state changes need receipt/proof path when scoped | source tests and golden-path proof |
| Recovery is non-shaming | Copy must avoid blame/overdue/streak pressure | forbidden-claim/copy scan |
| Motion clarifies state | Animation must have Reduce Motion equivalent | accessibility/motion pack |
| Visual atmosphere does product work | Decorative particles/glow cannot replace content/state | visual QA and performance budget |
| Native iPhone quality | Safe areas, Dynamic Type, gestures, touch targets, platform conventions | UI/accessibility proof |

## 3. Surface Bridge

| Surface | Product object | Code expectation | Proof expectation |
| --- | --- | --- | --- |
| Today | Reality Meridian + Start Here | dominant current-state/action primitive, not task list | state fixtures, screenshot if UI changes |
| Goals | Constellation Atlas | relationship/detail object, not KPI dashboard | source tests and visual proof when layout changes |
| Capture | Atmosphere Composer | quiet input plus route reveal, not notes feed | routing tests and keyboard/accessibility proof |
| Time | LifeShape Field | capacity/horizon canvas, not calendar clone | projection proof and visual/accessibility check |
| You | User System Profile | trust/defaults/control groups, not social profile | privacy/control proof and copy review |

## 4. Compatibility Bridge

Current implementation may contain compatibility names:

- `PlanScreen`
- `.plan`
- `planNavigation()`
- `ProfileScreen`
- `profile`
- `captures`

Code may preserve these as internal seams when truth files allow it. Codex must
not promote them as active user-facing top-level IA.

## 5. Implementation Checklist

Before editing UI/source, answer:

- What product object owns the change?
- Which golden path is affected?
- Which primitive contract applies?
- Which source owner files are allowed?
- Which compatibility seams are touched?
- What non-ideal states are covered?
- What accessibility/motion gates apply?
- What performance budget applies?
- What proof is required before any claim?
- What rollback restores the prior state?

## 6. Design Red Conditions

Stop on:

- blocked generic task/calendar/habit/dashboard/chatbot implementation pattern
- sixth tab or obsolete top-level IA
- visual-only state
- fake certainty or model-language UI
- silent mutation without receipt/control
- source edit without owner seam and validation plan

## 7. Phase 12 Gate Result

Phase 12 result: Green.

Validation:

- docs-only design-to-code bridge
- no SwiftUI/source files touched
- no visual, accessibility, performance, implementation, or release proof
  claimed
