# Private Life Runtime Proof Alignment

Status: evidence map, not product canon.

Authority:

- `docs/truth/*`
- `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`
- `Native/AmbitionsTests/Domain/AmbitionsMoatScenarioProof98Tests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift`

This map records the current proof boundary for the Private Life Runtime target. It separates focused source/test proof from runtime, release, device, and product-completion claims.

## Core proof target

The repo currently has focused source/test proof for the claim that the same intent can produce different inspectable execution output when local context differs.

That proof is still bounded to source and tests. It does not prove device behavior, release readiness, or production completion.

## Scenario status map

| Scenario | Current status | Evidence | Remaining non-claim |
| --- | --- | --- | --- |
| Same intent, different local context | Proven at focused source/test level | `AmbitionsMoatScenarioProof98Tests.testSameIntentDifferentLocalContextsProduceDifferentStartHereProofAndReplayStable` | Not runtime, device, or release proof |
| Inspectable reason/source/control/receipt path | Proven at focused source/test level | `AmbitionsMoatScenarioProof98Tests` and `AmbitionsOSRecommendationStartHereModelsTests` cover recommendation explanations, source claims, user controls, and receipt behavior | Not a UI proof or user-study proof |
| Relaunch replay stability | Proven at focused source/test level | `AmbitionsMoatScenarioProof98Tests` writes replay output and asserts replay stability for repeated runs | Not a persistence crash-resume proof beyond the focused scenario |
| Closure/recovery adaptation | Proven at focused source/test level | `AmbitionsMoatScenarioProof98Tests` checks recovery-aware recommendation differences and closure evidence | Not a full runtime lifecycle proof |
| Early completion optional reflow | Unproven in this patch set | No focused test in the approved slice exercises a source-backed optional reflow prompt | Still requires source-backed scenario proof if it becomes active truth |
| User correction/reset/learning influence | Partially proven at focused source/test level | `AmbitionsOSRecommendationStartHereModelsTests.testStartHereRecommendationCanCreateStructuredRejectCorrectionWithoutMutation` covers correction records and learning influence shape | Not a full end-to-end runtime adaptation proof |

## What is now safe to say

- The Private Life Runtime proof spec has focused source/test alignment.
- The repo can point to concrete tests for the core proof target and several scenario slices.
- Correction records and replay artifacts are inspectable in the focused proof path.

## What is still not proven

- The app runtime as shipped end-to-end.
- Device validation.
- Accessibility conformance.
- Performance validation.
- Release readiness.
- Any claim that the Private Life Runtime moat behavior is complete.
- Any claim that every scenario in `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` is fully proven in production.
