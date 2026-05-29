# AmbitionsOS AOS Test Impact Matrix

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active AOS test impact matrix
Date: 2026-05-07

| Batch | Change type | Runtime impact | Required proof | Result |
| --- | --- | --- | --- | --- |
| AOS01 | Docs/protocol runtime contract lock | None | doc QA, gate check, diff check, targeted scans | Accepted Yellow; no app behavior changed. |
| AOS02 | Additive domain contract and focused tests | No app behavior, persistence, or UI change | `LifeGraphEventLogModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS03 | Additive domain contract and focused tests | No app behavior, persistence, graph-store runtime, external projection, or UI change | `LifeGraphDeltaReviewModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS04 | Additive domain contract and focused tests | No app behavior, model invocation, Life Graph mutation, source-pack runtime, external projection, or UI change | `AmbitionsOSControlPlaneModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS05 | Additive Starting Position Kernel contract and focused tests | No app behavior, persistence, profile store, intake runtime, Life Graph mutation, external projection, or UI change | `AmbitionsOSStartingPositionModelsTests`, XcodeGen | Green; 7 focused tests passed. |
| AOS06 | Additive Goal Path Kernel contract and focused tests | No app behavior, persistence, local pack runtime, path activation, Life Graph mutation, external projection, or UI change | `AmbitionsOSGoalPathCompilerModelsTests`, XcodeGen | Green; 6 focused tests passed. |
| AOS07 | Additive Local Goal Pack requirement-slot contract and focused tests | No app behavior, persistence, local pack runtime loader, executable pack logic, path activation, Life Graph mutation, external projection, or UI change | `AmbitionsOSLocalGoalPackModelsTests`, XcodeGen | Green; repaired helper argument order, then 7 focused tests passed. |
| AOS08 | Additive Alternate Path Kernel path-portfolio contract and focused tests | No app behavior, persistence, alternate-path runtime, recommendation runtime, path mutation, Life Graph mutation, external projection, or UI change | `AmbitionsOSAlternatePathModelsTests`, XcodeGen | Green; focused tests passed. |
| AOS09 | Additive Option Value / North Star contract and focused tests | No app behavior, persistence, option-value runtime, North Star extraction, proof transfer runtime, path mutation, Life Graph mutation, external projection, or UI change | `AmbitionsOSOptionValueModelsTests`, XcodeGen | Green; 8 focused tests passed. |
| AOS10 | Additive Commitment Time Kernel contract and focused tests | No app behavior, platform calendar implementation, schedule write, persistence, external projection, or UI change | `AmbitionsOSCommitmentTimeModelsTests`, diff check, XcodeGen | Green; repaired helper argument order, then 7 focused tests passed. |
| AOS11 | Additive Reality Drift / Bounded Reflow contract and focused tests | No app behavior, reflow runtime, calendar write, persistence, Life Graph mutation, schedule mutation, external projection, or UI change | `AmbitionsOSRealityDriftModelsTests`, XcodeGen | Green; repaired helper argument order, then 7 focused tests passed. |
| AOS12 | Additive Proof Trust Kernel contract and focused tests | No app behavior, persistence, Life Graph mutation, source runtime, external projection, or UI change | `AmbitionsOSProofTrustModelsTests`, diff check, XcodeGen | Green; 6 focused tests passed. |
| AOS13 | Additive Source Truth Kernel contract and focused tests | No app behavior, persistence, source import/runtime, Life Graph mutation, external projection, or UI change | `AmbitionsOSSourceTruthModelsTests`, diff check, XcodeGen | Green; repaired helper argument order, then 8 focused tests passed. |
| AOS14 | Additive Recommendation Start Here Kernel contract and focused tests | No app behavior, recommendation runtime, ranking engine, Start Here rendering, persistence, Life Graph mutation, path/plan mutation, external projection, or UI change | `AmbitionsOSRecommendationStartHereModelsTests`, XcodeGen | Green; 7 focused tests passed. |
| AOS15 | Additive Local Language Kernel planning contract and focused tests | No app behavior, model runtime, adapter runtime, extraction runtime, tool bus, persistence, Life Graph mutation, external projection, or UI change | `AmbitionsOSLocalLanguageModelsTests`, XcodeGen | Green; 7 focused tests passed. |
| AOS16 | Additive Performance Energy Kernel budget and scheduler contract with focused tests | No app behavior, runtime scheduler, background task, telemetry, cache, persistence, Life Graph mutation, external projection runtime, or UI change | `AmbitionsOSPerformanceEnergyModelsTests`, XcodeGen | Green; 7 focused tests passed. |
| AOS17 | Additive Privacy Safety Kernel contract and focused tests | No app behavior, memory permission runtime, durable memory store, source ingestion, external projection runtime, privacy-state mutation, model runtime, tool bus, persistence, Life Graph mutation, or UI change | `AmbitionsOSPrivacySafetyModelsTests`, XcodeGen | Green; 7 focused tests passed with dedicated DerivedData after shared Xcode DB corruption. |
| AOS18 | Additive Evaluation Golden Scenarios contract and focused tests | No app behavior, evaluation runner runtime, generated fixture library, model evaluation system, LDI runtime, source import, persistence, Life Graph mutation, external projection runtime, or UI change | `AmbitionsOSEvaluationModelsTests`, XcodeGen | Green; 8 focused tests passed. |
| AOS19 | Additive Experience Kernel cognitive-load contract and focused tests | No app behavior, UI integration, route change, visual redesign, personalization runtime, recommendation runtime, persistence, Life Graph mutation, external projection runtime, or rendered-proof claim | `AmbitionsOSExperienceModelsTests`, XcodeGen | Green; 9 focused tests passed. |
| AOS20 | Additive Adaptation Kernel local personalization contract and focused tests | No app behavior, personalization runtime, durable memory store, hidden learning, persistence, Life Graph mutation, model runtime, external projection runtime, or UI change | `AmbitionsOSAdaptationModelsTests`, XcodeGen | Green; repaired helper argument order, then focused proof passed in fresh DerivedData after a local build DB lock. |
| AOS21 | Additive Interoperability Kernel planning contract and focused tests | No app behavior, App Intent implementation, EventKit/Reminder writes, platform permission prompt, external invocation, background refresh, persistence, Life Graph mutation, route/raw-value, entitlement/signing/project/dependency, external projection runtime, or UI change | `AmbitionsOSInteroperabilityModelsTests`, XcodeGen | Green; repaired test source-state fixture to existing `.sourceNeeded`, then focused proof passed in fresh DerivedData. |
| AOS22 | Additive Longevity Kernel archive-aging contract and focused tests | No app behavior, archive runtime, restore runtime, persistence/schema migration, sync/cloud or multi-device merge runtime, conflict-resolution runtime, Life Graph mutation, external projection runtime, or UI change | `AmbitionsOSLongevityModelsTests`, XcodeGen | Green; repaired test helper argument order, then focused proof passed in fresh DerivedData. |
| AOS23 | Docs/Codex OS governance registry and train-integrity updates | No app behavior, production Swift, runtime, model, LDI, UI, route, persistence/schema, sync/cloud, platform, signing, dependency, or workflow change | doc QA, batch-train gate check, architecture advisory scan, diff check, hosted-workflow residual scan | Green after local validation; no focused Swift tests required for docs-only batch. |

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
