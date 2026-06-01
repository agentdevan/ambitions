# AFEP-011 Accessibility Spatial Equivalence Matrix

Status: Source-backed packet
Batch: AFEP-011
Date: 2026-06-01

## Matrix

| Surface | Spatial behavior | Equivalent non-spatial behavior | Evidence |
| --- | --- | --- | --- |
| Goals Life Areas overview | Constellation Atlas groups Goals by canonical Life Area. | Life Area list order exposes the same canonical Life Area meaning. | `LifeAreaDefinition.canonical` drives `LifeAreaAtlasProjector.atlas(from:)`. |
| Life Area summary | Counts, next focus, and relationship hooks represent the Life Area object. | Accessibility label/value/hint describe the same Life Area and do not require motion. | `LifeAreaSummary.accessibilityProjection`. |
| Goals overview card | Map view names Constellation Atlas and keeps list fallback. | Accessibility hint says the map has a list fallback and Reduce Motion keeps ordered meaning. | `GoalsFeatureService.makeLifeAreasOverview`. |
| Proof and receipt hooks | Spatial continuity can connect Life Area, goal-thread path, proof, and receipt objects. | Ordered relationship hook arrays expose the same object lineage without spatial movement. | `LifeAreaRelationshipHooks` and `LifeAreaAtlasProjectorTests`. |

## Validation Evidence

- `make xcode-focused-test BATCH=AFEP-011 TEST=AmbitionsTests/LifeAreaAtlasProjectorTests` passed.
- `make xcode-focused-test BATCH=AFEP-011 TEST=AmbitionsTests/GoalsOverviewAtlasTests` passed.
- `make xcode-focused-test BATCH=AFEP-011 TEST=AmbitionsTests/YouFeatureServiceTests/testSourceAtlasRowsStayDeterministicAcrossGoalsPlansAndSteps` passed.

## Boundaries

- Not verified: VoiceOver runtime traversal, Dynamic Type screenshots, Reduce Motion runtime capture, accessibility audit, or device testing.
- Yellow item: full `AmbitionsTests/YouFeatureServiceTests` still returns nonzero at the wrapper boundary because `testPersonalRuntimeLearningSignalProjectionAddsInspectAndControlRowsInWhatAmbitionsKnows` restarts before assertions; the new AFEP-011 deterministic source-atlas test passes in isolation.
