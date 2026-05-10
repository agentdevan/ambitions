<!-- markdownlint-disable MD013 -->

# Visual Proof Ledger

Status: Active visual QA proof ledger  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*`, `docs/status/golden-path-contracts.md`, and current raw visual evidence

This ledger defines how Codex records visual proof. It does not contain current
visual approval by itself and does not prove public accessibility conformance,
performance, device validation, release readiness, or implementation
completeness.

## 1. Visual Proof Rule

If Codex claims a visual change is correct, polished, non-overlapping,
responsive, accessible, or motion-safe, the claim must cite current proof:
screenshots, previews, simulator evidence, visual diff output, or a recorded
manual QA checklist tied to the current commit.

## 2. Required Evidence Fields

Every visual proof entry must include:

- date
- branch and commit
- surface or primitive
- golden path
- device/simulator/preview source
- viewport or Dynamic Type size
- Reduce Motion state if motion is involved
- screenshot or artifact path
- command or manual procedure
- pass/fail result
- what the evidence proves
- what the evidence does not prove
- reviewer/owner department

## 3. Ledger Template

| Date | Commit | Surface | Primitive | Evidence | Result | Non-claims | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| _none current_ | _none_ | _none_ | _none_ | No current visual proof entered by this setup pass | Not proven | No release, device, accessibility, or performance claim | Design/QA |

## 4. Screenshot Expectations

For UI changes, capture:

- default state
- one non-ideal state
- one Dynamic Type stress state when text/layout changes
- Reduce Motion equivalent when animation/motion changes
- before/after pair when repairing a visual defect

Screenshot evidence must not be reused across commits for current claims unless
the source and environment are unchanged and the report explicitly says so.

## 5. Visual Diff Expectations

Visual diffs are required when:

- changing top-level shell layout
- changing reusable primitives
- touching navigation chrome
- changing dense text/layout surfaces
- repairing overlap, clipping, contrast, or state visibility defects

Acceptable diff closeout:

- expected differences described
- unexpected differences triaged
- screenshots archived or path-recorded
- accessibility/motion non-claims preserved

## 6. Visual QA Checklist

Check:

- no overlapping text or controls
- no clipped labels at supported Dynamic Type sizes claimed
- no color-only state
- touch targets remain usable
- primary object remains dominant
- no generic dashboard/card-stack drift
- visible alternative for gestures
- copy fits and remains non-shaming
- visual state maps to VoiceOver semantics where claimed

## 7. Red Conditions

Stop on:

- blank or unrendered primary view
- clipped primary action
- visual-only meaning for critical state
- nonfunctional navigation or blocked return path
- screenshots from stale build/commit used as current proof
- release/accessibility/performance claim without matching evidence

## 8. Current Status

Current visual proof status: not proven by this setup pass.

This pass creates the ledger and proof standard only. It does not run the app,
capture screenshots, perform visual diffs, validate real hardware, or certify
accessibility.

## 9. Phase 5 Gate Result

Phase 5 result: Green.

Validation:

- docs-only visual proof ledger
- no SwiftUI/source files touched
- no screenshot, visual approval, device, accessibility, performance, or release
  proof claimed

