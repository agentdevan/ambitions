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
| AOS05 | Additive Starting Position Kernel contract and focused tests | No app behavior, persistence, profile store, intake runtime, Life Graph mutation, external projection, or UI change | `AmbitionsOSStartingPositionModelsTests`, XcodeGen | Green; 7 focused tests passed. |
| AOS06 | Additive Goal Path Kernel contract and focused tests | No app behavior, persistence, local pack runtime, path activation, Life Graph mutation, external projection, or UI change | `AmbitionsOSGoalPathCompilerModelsTests`, XcodeGen | Green; 6 focused tests passed. |
| AOS07 | Additive Local Goal Pack requirement-slot contract and focused tests | No app behavior, persistence, local pack runtime loader, executable pack logic, path activation, Life Graph mutation, external projection, or UI change | `AmbitionsOSLocalGoalPackModelsTests`, XcodeGen | Green; repaired helper argument order, then 7 focused tests passed. |
| AOS10 | Additive Commitment Time Kernel contract and focused tests | No app behavior, platform calendar implementation, schedule write, persistence, external projection, or UI change | `AmbitionsOSCommitmentTimeModelsTests`, diff check, XcodeGen | Green; repaired helper argument order, then 7 focused tests passed. |
| AOS12 | Additive Proof Trust Kernel contract and focused tests | No app behavior, persistence, Life Graph mutation, source runtime, external projection, or UI change | `AmbitionsOSProofTrustModelsTests`, diff check, XcodeGen | Green; 6 focused tests passed. |
| AOS13 | Additive Source Truth Kernel contract and focused tests | No app behavior, persistence, source import/runtime, Life Graph mutation, external projection, or UI change | `AmbitionsOSSourceTruthModelsTests`, diff check, XcodeGen | Green; repaired helper argument order, then 8 focused tests passed. |
