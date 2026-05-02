# AmbitionsOS Interoperability Kernel

Status: Future canon under Ambitions Beyond 3.0; not current app implementation truth

## Owns

- EventKit Bridge planning
- App Intents Bridge planning
- Shortcut Action Engine
- ShareLink Bridge
- Local Notifications
- Widget Projection
- Live Activity Readiness
- Import / Export
- CloudKit Readiness
- Permission Degradation
- Compatibility Snapshot Adapter
- External Route Migration Guard

## States / Classes / Required Lists

- App Intents are privacy-projected
- Widgets are privacy-projected
- Local notifications are preferred over remote push by default
- EventKit is optional and permissioned
- CloudKit is future-readiness only unless explicitly approved
- Permission denied must leave the app useful

## Laws And Gates

- Platform capability claims are source-sensitive and require current Apple Developer documentation before implementation.

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
