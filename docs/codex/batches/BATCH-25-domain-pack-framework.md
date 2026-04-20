# Batch 25 — Ambitions 2.0 Batch 06 / Domain Pack Framework

## Status

Completed

## Goal

Add the modular domain-pack framework that lets Ambitions enrich compiled paths with domain-specific structural guidance without turning the core compiler into a monolithic domain rule engine.

This batch stayed framework-and-enrichment only. It did not introduce live resources, freshness propagation, energy logic, contradiction logic, explanation surfaces, UI widening, runtime widening, or SwiftData schema changes.

## What Landed

- added the new domain-pack contract layer in `Native/Ambitions/Domain/GoalEngine/GoalDomainPackModels.swift`
- extended `GoalCompiledPath` models in `Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift` so candidates and audit metadata can carry:
  - applied packs
  - requirement hints
  - readiness criteria
  - placeholder-only resource hooks
  - pack audit entries
- kept the core compiler domain-agnostic and left it as the primary path generator
- moved deterministic additive pack enrichment behind the service seam in `Native/Ambitions/Services/GoalPathCompilerService.swift`
- added deterministic pack composition in `Native/Ambitions/Services/GoalDomainPackService.swift`
- added narrow proof packs in `Native/Ambitions/Services/GoalDomainPacks.swift`
  - `CareerGoalDomainPack`
  - `EducationGoalDomainPack`
- kept proof-pack behavior conservative and framework-oriented instead of hardcoding deep real-world domain rules
- preserved core stages, dependencies, branches, assumptions, risks, ambiguity state, and provisional/blocked posture while adding pack contributions
- preserved optional knowledge-context threading without adding live retrieval or resource resolution
- kept orchestration metadata as the persistence path with no SwiftData column changes

## What Did Not Land

- no live resource resolution
- no resource ranking or source ranking logic
- no freshness propagation
- no energy logic
- no contradiction logic
- no explanation surfaces
- no UI widening
- no runtime widening
- no SwiftData schema expansion
- no migration of legacy heuristics out of `GoalEngineIntake.swift` or `DeterministicGoalPlanner.swift`

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - full `AmbitionsTests` run passed with `247` tests and `0` failures

Targeted Batch 25 test selection was unstable / not trustworthy in this repo, so the full `AmbitionsTests` run was treated as the authoritative validation pass.

## Completion Notes

- deterministic additive pack enrichment now runs after the base compile
- domain packs can contribute requirements, dependencies, readiness criteria, narrow risks, placeholder resource hooks, and pack audit metadata without replacing the core compiler
- Batch 25 closed without widening product surfaces or persistence schema

## Next Active Batch

Batch 26 — Ambitions 2.0 Batch 07 / Resource graph and source ranking
