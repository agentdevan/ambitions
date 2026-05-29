# Batch 01 — Pre-Phase-9 Cleanup And Capture surface

## Status

Completed

## Goal

Complete the pre-Phase-9 cleanup slice and land the first-class Capture surface wiring already defined in the seeded checklist, without pulling later roadmap work forward.

## In Scope

- `README.md` runtime truth cleanup
- `docs/README.md` truth and link cleanup
- `ProfileFeatureService` copy updates
- `PreviewFixtures` connected-features copy updates
- expand `CaptureSourceType`
- add or confirm `AppTab.captures`
- expose `captureService` on `AppContainer`
- wire `captureService` in `AppContainerFactory`
- add or confirm the Capture surface in `AmbitionsRootView`
- ensure `CapturesScreen` compiles against the real container shape
- route `.openCapturesInbox` to `.captures`
- add or update tests for routing and capture source persistence

## Out Of Scope

- Batch 02 legacy runtime deletion
- share extension
- App Intents
- widgets / Live Activities
- sync
- planner engine changes beyond what this batch directly requires
- later roadmap batches

## Current Repo Notes

- Parts of this batch are already present in the native app and should be verified, not rebuilt:
  - `AppTab.captures`
  - `captureService` on `AppContainer`
  - `captureService` wiring in `AppContainerFactory`
  - Capture surface wiring in `AmbitionsRootView`
  - `.openCapturesInbox` routing to `.captures`
  - baseline routing and capture-service tests
- Batch 01 should therefore focus on the remaining cleanup, truth alignment, and persistence/source-type coverage gaps while preserving the existing architecture.

## Exit Criteria

- Repo/runtime copy is truthful to the current native build.
- Captures is a first-class app tab backed by the existing container and routing seams.
- Capture source persistence covers the Batch 01 source set.
- Tests cover the capture source matrix and captures routing behavior.

## Completion Note

- Batch 01 has been completed and validated as a bounded native cleanup/captures pass.
- Batch 02 is the next active repo-truth slice and should focus on deleting remaining dead-path TypeScript/runtime artifacts and stale backend/runtime docs only where they still exist.
