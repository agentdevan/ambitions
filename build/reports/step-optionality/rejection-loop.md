# IOS26-T04B-B02 Rejection Loop Proof

## Scope
- Added a local rejection reason domain for Today recommendations.
- Wired `Not this` on Start Here to a compact local reason sheet.
- Persisted rejection receipts through the existing local action receipt history repository.
- Fed local rejection history back into Today snapshot loading so future recommendations can learn from it.
- Extended step candidate generation to suppress the recently rejected candidate for the same context fingerprint and to shift ranking with reason-specific weighting.

## Privacy Boundary
- Sensitive and custom reason text stays out of `StepCandidateField`, `CandidateRankingTrace`, and encoded candidate-trace payloads.
- The runtime uses redacted reason labels in ranking traces and public summaries.
- The persisted receipt is local-only and can be redacted by projection for external surfaces.
- Custom text is not echoed into ranking traces or log-like surfaces.

## iOS 26 API Note
- The sheet uses standard SwiftUI presentation and accessibility APIs: `NavigationStack`, `.sheet`, `FocusState`, `TextEditor`, `dynamicTypeSize`, and accessibility identifiers.
- No iOS 26-only API was introduced for the rejection loop.
- Accessibility behavior is intentionally state-driven with non-color-only selection markers and a compact save/skip path.

## Validation
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests/Domain/StepCandidateFieldModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests/Domain/ActionClosureReceiptModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsTests/Today/TodayViewModelTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsUITests`
- `make xcode-focused-test BATCH=IOS26-T04B-B02 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapTodayStartHereNotThisOpensReasonSheet`

## Validation Result
- Domain, runtime, persistence, and Today service lanes returned `xcode validation passed`.
- The UI wrapper returned success, but the compiled log did not surface the newly added `TodayStartHereNotThis` smoke by name, so I am not treating the UI path as fully proven from that run alone.

## No-Claim Boundaries
- Do not claim full UI Green from this batch.
- Do not claim accessibility proof beyond the implemented structure and the wrapper run.
- Do not claim release readiness or broader product completion.
- Do not claim the new UI smoke was observed in the compiled bundle from the current wrapper output.

## Rollback Notes
- Revert only the IOS26-T04B-B02 owned source, test, and proof paths if needed.
- Leave unrelated dirty proof JSON files in `docs/proof/amb-fe-be/moat-scenario-proof-98/` untouched.
