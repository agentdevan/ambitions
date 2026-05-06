# AmbitionsOS AOS Test Impact Matrix
<!-- markdownlint-disable MD013 -->

Status: Active AOS test impact matrix
Date: 2026-05-06

| Batch | Change type | Runtime impact | Required proof | Result |
| --- | --- | --- | --- | --- |
| AOS01 | Docs/protocol runtime contract lock | None | doc QA, gate check, diff check, targeted scans | Accepted Yellow; no app behavior changed. |
| AOS02 | Additive domain contract and focused tests | No app behavior, persistence, or UI change | `LifeGraphEventLogModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS03 | Additive domain contract and focused tests | No app behavior, persistence, graph-store runtime, external projection, or UI change | `LifeGraphDeltaReviewModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS04 | Additive domain contract and focused tests | No app behavior, model invocation, Life Graph mutation, source-pack runtime, external projection, or UI change | `AmbitionsOSControlPlaneModelsTests`, CQS scans, doc QA, gate check, architecture scan, diff check | Green; focused tests passed. |
| AOS12 | Additive Proof Trust Kernel contract and focused tests | No app behavior, persistence, Life Graph mutation, source runtime, external projection, or UI change | `AmbitionsOSProofTrustModelsTests`, diff check, XcodeGen | Green; 6 focused tests passed. |
