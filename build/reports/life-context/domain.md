# Life Context Domain

Batch: `IOS26-T04A-B01`
Status: draft proof note

## What Changed

- Added value-model-first Life Context domain types in `Native/Ambitions/Domain/LifeContextModels.swift`.
- Added a local SwiftData bundle repository in `Native/Ambitions/Persistence/LifeContextPersistence.swift`.
- Added a new SwiftData record model in `Native/Ambitions/Persistence/SwiftDataModels.swift`.
- Wired the repository into `AppRepositories` and `AppContainerFactory`.

## Domain Shape

- `LifeContextProfile` carries local context, travel constraints, recovery constraints, and accessibility needs.
- `LifeContextEligibilityPathway` carries a typed pathway model with source and freshness.
- `OpportunityContext` carries access and verification shape for local facilities and exposure.
- `HistoricalContextFact` carries sensitivity, runtime-use permission, freshness, and pause/delete state.
- `LifeContextSource` carries provenance and edit controls.
- `LifeContextRuntimeProjection` is built deterministically from typed inputs and excludes deleted or paused facts.

## Local-First Invariants

- Persistence is local SwiftData only.
- No cloud AI, hosted backend, analytics SDK, or tracking code was added.
- Sensitive facts are excluded from runtime projection unless `runtimeUseAllowed == true`.
- Deleted or paused facts never enter runtime projection.
- Sensitive values are not logged by the repository path.

## Fixture Profiles

- 14-year-old varsity football goal with parent transportation and YMCA access.
- 16-year-old varsity football goal with compressed timeline and school weight room access.
- Woman pursuing professional basketball with a WNBA pathway.
- Adult mountain biking goal with no nearby trails and a limited travel radius.
- Empty-context profile with no historical context yet.

## Proof Boundaries

- This file documents the domain and persistence slice only.
- Build, test, and repository validation are not proven here.
- Accessibility, privacy approval, device proof, and release readiness are not proven here.
