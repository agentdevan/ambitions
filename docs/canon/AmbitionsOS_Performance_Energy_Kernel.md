# AmbitionsOS Performance Energy Kernel

Status: Future canon under Ambitions Beyond 3.0; not current app implementation truth

## Owns

- Work Budget System
- Energy-Aware Scheduler
- Projection Cache
- Incremental Graph Updates
- Hot/Warm/Cold Memory
- Animation Budget
- Loading Gate
- Performance Regression Harness
- Query Budget Engine
- App Size Budget Engine
- Asset Governance Engine
- Model Invocation Budget
- Thermal State Governor
- Memory Pressure Governor
- Background Work Policy

## States / Classes / Required Lists

- no full graph recomputation on every screen
- no language model call for deterministic work
- no heavy work on the main thread
- no always-running background intelligence
- no looping heavy animation
- no source research blocking UI
- no large bundled model by default
- no app launch dependency on model inference
- no navigation dependency on internet

## Laws And Gates

- Hot: Today, active step, current day; Warm: active goals, current week; Cold: archived receipts/proof; Compressed: summarized old history; Purgeable: generated projections, thumbnails, cached research drafts.

## Required Source Stack

- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md`
- `docs/canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md`

## Implementation Boundary

This document is future-canon guidance. It does not claim current app behavior, release readiness, App Store readiness, TestFlight readiness, physical-device verification, public accessibility conformance, signed archive validation, rendered platform proof, backend capability, sync, hosted AI, telemetry, or platform integration support.

Do not use this document to start implementation automatically. Future work must pass the named train gates, preserve Ambitions 3.0 source truth, and record evidence before claims.
