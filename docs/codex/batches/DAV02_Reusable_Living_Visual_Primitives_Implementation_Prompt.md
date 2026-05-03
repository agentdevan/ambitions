# DAV02 Reusable Living Visual Primitives Implementation Prompt
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

