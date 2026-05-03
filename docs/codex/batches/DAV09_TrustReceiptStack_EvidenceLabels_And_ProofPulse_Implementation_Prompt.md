# DAV09 TrustReceiptStack EvidenceLabels And ProofPulse Implementation Prompt
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV09
- Name: TrustReceiptStack EvidenceLabels And ProofPulse Implementation
- Global order: 063
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in trust/receipt visual owners.
## Purpose
Implement TrustReceiptStack, EvidenceLabel, SourceFreshness label, Undo/correction affordance visuals, proof pulse, and audit clarity.
## Affected Surfaces
Trust Center, Receipts/Audit Trail, shared proof surfaces.
## Allowed Production Swift Files
Sources/Components/**, Native/Ambitions/Features/Profile/**, Native/Ambitions/PreviewSupport/**, owned receipt UI files if present.
## Forbidden Files
Export/delete behavior, persistence/schema, legal/privacy claims, routes/raw values, dependencies.
## Required Visual Primitives
EvidenceLabel, ProofPulse, AdaptiveModuleChrome, QuietCommandSurface.
## Motion Rules
Receipt settle and proof pulse only.
## Reduce Motion Equivalent
Static proof state.
## Dynamic Type Requirements
Receipt text wraps.
## VoiceOver Requirements
Action, source, undo/correction controls in order.
## Preview Fixture Requirements
No receipts, proof saved, correction, undo, stale source.
## Product-Experience Before/After Notes
Record audit clarity and no release/privacy overclaim.
## Validation Commands
`git diff --check`; DAV scans; focused build/tests.
## Green/Yellow/Red Criteria
Green: trust visuals compile and claims remain bounded. Yellow: behavior deferred. Red: unsupported privacy/release claim.
## Stop Conditions
Stop on export/delete or legal/privacy claim drift.
## Commit Message
`Implement Trust receipt dynamic screen`
## Next Safe Path
DAV10 motion.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, Transformative Motion QA if proof/receipt motion is affected, accessibility evidence, Reduce Motion evidence, preview evidence, and photo-reference evidence.
