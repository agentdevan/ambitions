STATUS: GREEN
# Step Candidate Simulation Gauntlet Proof

Batch: `IOS26-T04B-B05`
Date: `2026-05-23`

## Red/Yellow/Green Summary
- Green checks: 20
- Yellow checks: 0
- Red checks: 0

## Coverage
- Goal archetypes: 1/25
- Context profiles: 10/10
- Schedule realities: 10/10
- Rejection reasons: 10/10
- Deadline pressure levels: 5/5
- Access/facility states: 5/5
- Historical context states: 5/5

## Verification
- Scenario checks: 20
- Total candidates generated: 300
- Multi-candidate scenarios: 20
- Replay deterministic scenarios: 20/20
- Accepted alternative receipt checks: 20/20
- Impossible scenarios surfaced honestly: 2
- Privacy scan: passed (20/20)
- iOS 26 API note: no iOS 26-only APIs were introduced; the harness uses Foundation, XCTest, and local model constructors only.

## Deadline Pressure Surface
compressed: 24, delayed: 2, impossible: 30, preserved: 104, requires_deadline_review: 80, threatens_protected_time: 60

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