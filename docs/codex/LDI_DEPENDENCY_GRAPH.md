# LDI Dependency Graph

<!-- markdownlint-disable MD013 -->

Status: Future dependency graph. No LDI runtime is claimed.

## Placement

LDI01 starts after AOS30 by default. A future explicit user decision may move an individual LDI gate earlier only after dependency review.

## Required Predecessors

- SI must expose reusable handling lane, source state, receipt, privacy, degraded-state, and review primitives where relevant.
- PD must provide owned drill-down homes for LDI review surfaces where relevant.
- AOS must create kernel contracts and local runtime boundaries before LDI deepens implementation.
- AOS24 UI integration must not expose LDI user-facing intelligence without relevant SI/PD/AOS/LDI gates.
- PD runtime-touching batches must stop if LDI/AOS source truth, proof trust, recommendation, privacy, or recompiler gates are not ready.

## Serial Dependencies

LDI01 -> LDI02 -> LDI03 -> LDI04 -> LDI05 -> LDI06 -> LDI07 -> LDI08 -> LDI09 -> LDI10 -> LDI11 -> LDI12 -> LDI13 -> LDI14 -> LDI15 -> LDI16 -> LDI17 -> LDI18 -> LDI19 -> LDI20 -> LDI21 -> LDI22.

## Cross-Train Hooks

SI handles visual primitives, PD handles drill-down homes, AOS handles foundational contracts, LDI handles dream intelligence implementation depth. No train may claim another train's work without evidence.
