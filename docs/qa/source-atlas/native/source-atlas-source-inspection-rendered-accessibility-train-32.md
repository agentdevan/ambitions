# Source Atlas Train 32 Source Inspection Rendered Accessibility Proof

Status: Green for automated Source Inspection render/accessibility contract / Yellow overall Source Atlas.

Linear: AMB-1518

Created: 2026-06-28T03:22:01Z

## Scope Completed

- Added an automated simulator render proof for the canonical Trust-owned `SourceInspectionView`.
- Rendered a production R2 Train 29 `occupation_foundation` local-reference inspection presentation at regular and accessibility Dynamic Type sizes.
- Verified source, freshness, use, review, privacy, local-only matching, and non-claim copy in the presentation contract.
- Preserved Ambitions runtime ownership of fit, timing, priority, Steps, and schedules.

## Files Changed

- `Native/AmbitionsTests/Trust/SourceInspectionPresentationTests.swift`
- `docs/qa/source-atlas/native/source-atlas-source-inspection-rendered-accessibility-train-32.json`
- `docs/qa/source-atlas/native/source-atlas-source-inspection-rendered-accessibility-train-32.md`

## Proof

`testProductionSourceInspectionViewRendersAccessiblePublicReferenceDetail` renders `SourceInspectionView` at a 390 x 844 point viewport with:

- `DynamicTypeSize.large`
- `DynamicTypeSize.accessibility3`

The test asserts:

- non-transparent rendered pixels exceed the proof threshold in both modes
- rendered color buckets exceed the proof threshold in both modes
- accessibility label is `Source detail, Current`
- accessibility value includes the public source name
- accessibility hint names public source context
- rows are `Reference`, `Freshness`, `Use`, and `Review`
- visible contract excludes private graph, goal text, final plan, final schedule, and Step-generator markers
- Source Atlas does not own final user Steps or schedules

## Validation Run

- Passed: `XcodeBuildMCP test_sim -only-testing:AmbitionsTests/SourceInspectionPresentationTests/testProductionSourceInspectionViewRendersAccessiblePublicReferenceDetail`
  - 1 passed, 0 failed, 0 warnings
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T03-18-17-425Z_pid24471_5c7f5d13.log`
  - xcresult: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T03-18-17-425Z_pid24471_bf864ef8.xcresult`
- Passed: `XcodeBuildMCP test_sim -only-testing:AmbitionsTests/SourceInspectionPresentationTests`
  - 5 passed, 0 failed, 0 warnings
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T03-20-26-532Z_pid24471_951282a8.log`
  - xcresult: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T03-20-26-533Z_pid24471_d1efa59e.xcresult`
- Passed: `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
  - 145 passed
- Passed: `python3 scripts/source-atlas-boundary-audit.py`
  - Source Atlas boundary audit: PASS (40 targets)
- Passed: `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
  - Source Atlas no-private-graph egress audit: PASS
- Passed: `python3 scripts/ambitions-green-standard-audit.py`
  - GREEN: no disallowed architecture-as-UI strings found in active primary UI source
- Passed: `python3 scripts/ambitions-local-first-boundary-scan.py`
  - GREEN: local-first/account/R2/hosted-AI boundary checks passed in active authority files
- Passed: `python3 -m json.tool docs/qa/source-atlas/native/source-atlas-source-inspection-rendered-accessibility-train-32.json >/dev/null`
- Passed: `git diff --check`

## Validation Not Run

- Independent visual review for Visual Green.
- Physical-device accessibility review.
- Full build-for-testing.
- Full native XCTest suite.
- Live native URLSession fetch against public R2 endpoint.
- Release umbrella proof.

## Closeout

Status: Green for automated Source Inspection render/accessibility contract / Yellow overall Source Atlas

Scope completed: Trust-owned Source Inspection rendered proof and accessibility/copy contract.

Product law preserved: yes. Source Atlas remains public/reference-only. R2 remains non-private infrastructure. Local runtime keeps final fit, timing, priority, Steps, and schedules.

Source Atlas status ceiling: Yellow overall. This is not full Source Atlas Green, Visual Green, Release Green, App Store readiness, outside legal approval, entitlement readiness, or universal coverage.

R2 request privacy proof: no R2 request was made in this train. Train 29 and Train 30 remain the current remote R2/no-account request-shape proof.

No private graph egress proof: the new XCTest blocks private graph, goal text, final plan, final schedule, and Step-generator markers in the presentation contract. The standard no-private-egress audit passed.

License/terms proof: no new source/license/pack output was introduced.

Restricted-source exclusion proof: no source registry or pack output changed.

Provenance completeness proof: no new claims were created; the presentation is tied to the Train 29 production pack id.

Freshness/revocation proof: current-state presentation rendered; no new revocation behavior added.

LKG/rollback proof: no R2 object, pointer, rollback, or LKG state changed.

Native offline/no-account proof: no fetch/cache behavior changed; Train 30 remains the current proof.

Known risks: automated render proof is not independent visual acceptance; physical-device accessibility and live native URLSession endpoint behavior remain unproven here.

Rollback plan: remove the new Trust XCTest/render helpers and Train 32 evidence docs. No production R2 rollback is required.
