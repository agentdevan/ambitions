# AmbitionsOS AOS Traceability Matrix
<!-- markdownlint-disable MD013 -->

Status: Active AOS traceability matrix
Date: 2026-05-06

| Batch | Requirement | Owner | Evidence | Known gaps | Claim status |
| --- | --- | --- | --- | --- | --- |
| AOS01 | Runtime contract blocks all later AOS work. | Governance Kernel / Runtime Contract | `docs/canon/AmbitionsOS_Runtime_Contract.md`; AOS01 report. | Runtime behavior remains future-owned. | Contract only; no implementation claim. |
| AOS01 | HPS inheritance is imported before AOS runtime work. | Governance Kernel / Runtime Contract | HPS inheritance section in runtime contract. | Typed HPS behavior remains later AOS/FCP/PFC/LDI-owned. | Source truth only. |
| AOS01 | Source Atlas inheritance is imported where source-dependent behavior appears. | Governance Kernel / Runtime Contract | Source Atlas inheritance section in runtime contract. | Source pack runtime, source review UI, and source fixtures remain later-owned. | Source truth only. |
| AOS01 | No-claim and gate locks are explicit before AOS02. | Governance Kernel / Runtime Contract | Runtime contract locks and AOS01 report. | Future batches must prove their own validation. | No release/platform claim. |
| AOS02 | Human Progress Graph nodes carry family, privacy, source, freshness, review, timestamps, and receipts. | Life Graph Kernel | `Native/Ambitions/Domain/LifeGraphEventLogModels.swift`; `LifeGraphEventLogModelsTests`. | No persistence or graph store. | Typed contract only. |
| AOS02 | Life Graph event log entries are local-only and review-gated by default. | Life Graph Kernel | `LifeGraphEventLogModelsTests.testKernelProposalEventStaysLocalOnlyAndReviewGated`. | No runtime event writer. | Domain proof only. |
| AOS02 | Graph deltas are proposal-first and include rollback hints before mutation. | Life Graph Kernel | `HumanProgressGraphDelta`; focused delta test. | AOS03 owns projection/review store. | No silent mutation claim. |
| AOS03 | Graph deltas require a review record before projection. | Life Graph Kernel / Runtime Contract | `Native/Ambitions/Domain/LifeGraphDeltaReviewModels.swift`; `LifeGraphDeltaReviewModelsTests`. | No persistence or graph store runtime. | Typed contract only. |
| AOS03 | Projection eligibility requires approval, no inferred risks, and at least one receipt. | Life Graph Kernel / Runtime Contract | `LifeGraphDeltaReviewModelsTests.testApprovedRecordRequiresReceiptAndNoRisksBeforeProjection`. | No runtime projector. | No silent mutation claim. |
| AOS03 | Projection store separates pending review records from projectable records. | Life Graph Kernel / Runtime Contract | `LifeGraphDeltaReviewProjectionStore`; focused projection-store test. | No UI or external projection. | Domain proof only. |
