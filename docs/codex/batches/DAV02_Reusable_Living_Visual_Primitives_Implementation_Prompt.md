# DAV02 Reusable Living Visual Primitives Implementation Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->
## Batch Identity
- Batch ID: DAV02
- Name: Reusable Living Visual Primitives Implementation
- Global order: 056
## Active 4.0 Status
Active DAV implementation batch; production SwiftUI is allowed inside shared visual primitive owner files.
## Purpose
Implement LivingSurfaceBackground, AdaptiveModuleChrome, EvidenceLabel, PressureGlow, ProofPulse, ContextAtmosphereLayer, QuietCommandSurface, GroupedNavigationSystem, LivingTabContext, and StateDrivenMaterialPanel.
## Affected Surfaces
Shared design system primitives used by Today, Capture, Plan, Goals, You, Memory, Trust/Receipts.
## Allowed Production Swift Files
Sources/Components/**, Sources/Previews/**, Native/Ambitions/PreviewSupport/** if fixtures are needed.
## Forbidden Files
Persistence/schema, routes/raw values, enum/raw values, dependencies, workflows, signing, App Store/TestFlight files.
## Required Visual Primitives
All DAV02 primitives named in Purpose.
## Motion Rules
Subtle state-driven reveal/pulse only; no infinite motion by default, spinning, vortex, neon, or random animation.
## Reduce Motion Equivalent
Every motion helper returns static/opacity/identity behavior when Reduce Motion is true.
## Dynamic Type Requirements
Use theme typography and flexible layout; no fixed text clipping.
## VoiceOver Requirements
Labels and children strategy must be explicit for interactive primitives.
## Preview Fixture Requirements
Provide component previews or scenario-friendly primitives.
## Product-Experience Before/After Notes
Record how shared primitives replace generic card piles with one living visual system.
## Validation Commands
`git diff --check`; `scripts/dav-visual-primitive-inventory.sh || true`; `scripts/dav-reduce-motion-check.sh || true`; focused Swift build/test lane.
## Green/Yellow/Red Criteria
Green: primitives compile and pass DAV scans. Yellow: preview/human visual polish deferred. Red: unreadable, generic, overanimated, or accessibility-blocking primitive.
## Stop Conditions
Stop on dependency request, persistence/route changes, or compile Red.
## Commit Message
`Implement Dynamic Adaptive visual primitives`
## Next Safe Path
DAV03 Today dynamic adaptive screen.

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
