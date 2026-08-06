# Implementation Plan

## Outcome and boundary

Install a final adaptive-skills-and-pathways integration contract after the
focused portfolio implementations. The change adds one canon journey map and
test-only acceptance fixtures. It adds no production owner, persistence,
migration, surface, route, visual asset, copy, score, hosted join, automatic
mutation, or external action.

## Affected components and exact files

- Add `docs/canon/specifications/journeys/adaptive-skills-and-pathways.md` and
  update `docs/canon/MANIFEST.toml` through the normal canon build.
- Add
  `Native/AmbitionsTests/Support/AdaptiveSkillsPathwaysJourneyFixture.swift`
  for deterministic split public/private fixtures using child-owned types.
- Add
  `Native/AmbitionsTests/Runtime/AdaptiveSkillsPathwaysIntegrationTests.swift`
  for typed handoff, degradation, correction, deletion, concurrency, and replay.
- Add
  `Native/AmbitionsTests/LocalRuntimeOS/Boundary/AdaptiveSkillsPathwaysAuthorityBoundaryTests.swift`
  and extend the existing no-private-graph/static audits.
- Add `Native/AmbitionsUITests/AdaptiveSkillsPathwaysJourneyUITests.swift` only
  after child visual gates and focused UI tests pass. It navigates existing
  routes and introduces no application source.

## Interfaces and data flow

The canon owner matrix is the integration interface index. Production data
flows directly between child-approved typed outputs and receiving services.
The test fixture supplies deterministic IDs, revisions, clocks, public source
artifacts, private state, corrections, and failures. The integration test calls
those services directly; there is no umbrella production coordinator.

Each receiver revalidates identity, revision, provenance, sensitivity,
authority, lifecycle, freshness, and confirmation scope. Invalid inputs produce
the child-defined unavailable or review state and never a fallback mutation.

## Persistence, migration, concurrency, and replay

N/A for integration-owned persistence and migration because no production store
is added. Child migrations and stores remain authoritative. Tests inject stale
revisions, cancellation, duplicate delivery, concurrent correction/deletion,
crash/relaunch, and replay at every handoff. The fixture and harness retain no
state that production recovery depends on.

## Dependencies and implementation order

The project is last in the portfolio. Runtime Tasks 2–6 require the applicable
child implementations and focused proof to be complete; Task 1 may establish
the canon matrix earlier because it references approved contracts. Implement
canon/traceability, fixture, handoff/degradation tests, privacy/replay tests,
existing-surface UI acceptance, then the complete evidence matrix.

Hard dependencies include capability continuity, public reference and corpus
owners, recommendation domains, destination adoption, Goal Path generation and
comparison, context-quality scheduling/local learning, credential/profile
inputs, generative proposal safety, simulations, Life Branch reconciliation,
privacy, persistence, external-action, and CloudKit continuity contracts. A
missing or incompatible child blocks the affected integration lane; this
project never implements around it.

## Rollout and non-claims

The canon map and tests land without a runtime feature flag because they add no
production behavior. End-to-end UI/device verification runs only after every
child visual gate is approved. Passing source tests does not prove rendered UI,
accessibility, device behavior, external acceptance, release, or App Store
readiness.
