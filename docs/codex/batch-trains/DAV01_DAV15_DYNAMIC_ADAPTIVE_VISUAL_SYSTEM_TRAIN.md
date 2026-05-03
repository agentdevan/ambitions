# DAV01-DAV15 Dynamic Adaptive Visual System Train

<!-- markdownlint-disable MD013 -->

Status: Active Ambitions 4.0 implementation train after EB32; production SwiftUI allowed only inside each batch boundary.
Date: 2026-05-03

## Purpose

DAV makes Ambitions visually alive without making it loud, generic, heavy, unreadable, or over-animated. It implements native SwiftUI visual primitives, surface upgrades, previews, motion, accessibility, performance, and product-experience QA before UI-heavy External Brain implementation can claim Green.

## Train Order

- 055: DAV01 Dynamic Visual Source Truth And Surface Map. Status: complete as docs/source map only; no production Swift or app behavior.
- 056: DAV02 Reusable Living Visual Primitives Implementation. Status: complete as shared SwiftUI primitives; not wired into top-level surfaces yet.
- 057: DAV03 Today DayTimelineRail And HeroStepPanel Implementation. Status: active next. Boundary: Today visual composition only.
- 058: DAV04 Capture AtmosphereComposer And RoutingReceipts Implementation. Status: queued. Boundary: Capture visual composition only.
- 059: DAV05 Plan LifeShapeMap And CapacityVisuals Implementation. Status: queued. Boundary: Plan visual composition only.
- 060: DAV06 Goals MissionControlLanes Implementation. Status: queued. Boundary: Goals visual composition only.
- 061: DAV07 You SystemProfilePanel And GroupedNavigation Implementation. Status: queued. Boundary: You/Profile visual composition only.
- 062: DAV08 Memory ContextRecall And MemoryConstellation Implementation. Status: queued. Boundary: memory/recall visual prototypes or owned surfaces only; no durable memory behavior.
- 063: DAV09 TrustReceiptStack EvidenceLabels And ProofPulse Implementation. Status: queued. Boundary: trust/receipt visual primitives only.
- 064: DAV10 AdaptiveMotion ReduceMotion And StateTransitions. Status: queued. Boundary: motion/reduce-motion closeout.
- 065: DAV11 DynamicType VoiceOver And VisualAccessibility Closeout. Status: queued. Boundary: accessibility evidence closeout.
- 066: DAV12 SurfacePreviewFixtures And ScenarioGallery. Status: queued. Boundary: preview fixtures/scenario gallery.
- 067: DAV13 VisualPerformance Rendering And BatteryRisk. Status: queued. Boundary: rendering/performance risk evidence.
- 068: DAV14 VisualRegression And ProductExperience QA. Status: queued. Boundary: visual QA and PXEQ scorecard.
- 069: DAV15 Dynamic Adaptive Visual System Closeout. Status: queued. Boundary: closeout/handoff; no release readiness claim.

## Hard Rules

- Preserve `Today / Goals / Capture / Plan / You`.
- No route/raw value, enum/raw value, persistence/schema, dependency, network/sync, signing, TestFlight, App Store, workflow, or compatibility removal changes.
- Use native SwiftUI and existing design system/package structure.
- Every UI batch must include Reduce Motion, Dynamic Type, VoiceOver, preview/fixture, and PXEQ evidence.
- No third-party visual dependencies.
