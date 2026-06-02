STATUS: GREEN
# Step Candidate Simulation Gauntlet Proof

Batch: `IOS26-T04B-B05`
Date: `2026-05-23`

## Red/Yellow/Green Summary
- Green checks: 4
- Yellow checks: 0
- Red checks: 0

## Coverage
- Goal archetypes: 1/25
- Context profiles: 2/10
- Schedule realities: 4/10
- Rejection reasons: 4/10
- Deadline pressure levels: 2/5
- Access/facility states: 4/5
- Historical context states: 4/5

## Verification
- Scenario checks: 4
- Total candidates generated: 60
- Multi-candidate scenarios: 4
- Replay deterministic scenarios: 4/4
- Accepted alternative receipt checks: 4/4
- Impossible scenarios surfaced honestly: 0
- Privacy scan: passed (4/4)
- iOS 26 API note: no iOS 26-only APIs were introduced; the harness uses Foundation, XCTest, and local model constructors only.

## Deadline Pressure Surface
compressed: 6, delayed: 1, preserved: 23, threatens_protected_time: 30

## Top Failing Scenarios
none

## Validation Commands
- `make xcode-build-for-testing BATCH=IOS26-T04B-B05`
- `make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests/testSimulationGauntletCoversDeterministicScenarioMatrixAndWritesProofReport`

## Proof Boundaries
- Deterministic local simulation only.
- No app UI, architecture, dependency, analytics, or cloud changes.
- No sensitive context is emitted in the report or encoded candidate payloads.
- Unrelated dirty proof JSON files in `docs/proof/amb-fe-be/moat-scenario-proof-98/` were not modified by this batch.