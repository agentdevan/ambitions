# DAV07 You SystemProfilePanel And GroupedNavigation Implementation Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV07
- Name: You SystemProfilePanel And GroupedNavigation Implementation
- Global order: 061
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI allowed in You/Profile visual owners.
## Purpose
Implement SystemProfilePanel and GroupedNavigationSystem sections for Trust, Memory, Planning Setup, and Accessibility.
## Affected Surfaces
You/Profile.
## Allowed Production Swift Files
Native/Ambitions/Features/Profile/**, Sources/Components/**, Native/Ambitions/PreviewSupport/**.
## Forbidden Files
Profile raw value migration, default tab changes, persistence/schema, dependencies, workflows.
## Required Visual Primitives
GroupedNavigationSystem, AdaptiveModuleChrome, EvidenceLabel, StateDrivenMaterialPanel.
## Motion Rules
Grouped reveal only.
## Reduce Motion Equivalent
Static grouping.
## Dynamic Type Requirements
Rows and subtitles wrap.
## VoiceOver Requirements
Section headings and row labels in order.
## Preview Fixture Requirements
No data, trusted, stale, sensitive, correction, high Dynamic Type.
## Product-Experience Before/After Notes
Record personal system center, not settings dump.
## Validation Commands
`git diff --check`; DAV scans; focused You/Profile build/tests.
## Green/Yellow/Red Criteria
Green: You compiles and avoids settings dump. Yellow: polish deferred. Red: Profile compatibility break or admin surface drift.
## Stop Conditions
Stop on compatibility/persistence/default-tab changes.
## Commit Message
`Implement You dynamic adaptive screen`
## Next Safe Path
DAV08 Memory.

## Required Premium Experience Gates
- Inspect `docs/reference/visual-targets/ambitionsos-photo-matched/`.
- Cite Signature Experience and Transformative Motion docs.
- Pass SIG scorecard, PXEQ scorecard, DAV scorecard, accessibility evidence, Reduce Motion evidence, preview evidence, and photo-reference evidence.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
