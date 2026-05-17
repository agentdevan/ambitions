# Ambitions 4.0 External Brain Cross-Kernel Primitives And Dependencies

<!-- markdownlint-disable MD013 -->

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Cross-Kernel Primitive Map

- Source and evidence: MemorySource, RecommendationEvidence, SourceFreshnessReceipt, CaptureReceipt, MemoryReceipt, PrivacyReceipt.
- Control: UndoRecord, CorrectionRecord, MemoryCorrectionAction, CaptureReclassificationAction, UserOverrideHistory, DataExportBundle.
- Privacy: PermissionBoundary, PrivateModeRule, SensitiveAreaControl, SensitiveMemoryBoundary, LocalFirstLabel.
- Accessibility: CognitiveLoadMode, InterfaceDensityLevel, VoiceOverOrderMap, ReducedMotionEquivalent, AccessibleActionAlternative, ScreenExplanation.
- Event and receipt architecture: capture, memory, recommendation, onboarding, audit, undo, correction, export, delete, and privacy actions must emit source-backed receipts when user trust can be affected.

## Dependency Graph

1. Universal Capture depends on Trust, Privacy, And User Control for sensitive capture handling.
2. Life Memory Graph depends on Trust, Privacy, And User Control for memory creation, deletion, confidence, and receipts.
3. Product Maturity And Onboarding depends on Universal Capture for first capture and Trust for privacy setup.
4. Accessibility And Cognitive Load applies to all other kernels.
5. Life Memory Graph must not infer or store durable memory without Trust kernel controls.
6. Universal Capture must not promote captured items into durable memory without source/confidence/permission logic.
7. Onboarding must not force users to expose sensitive life context before value is demonstrated.
8. Trust Center must expose memory, capture, recommendation, privacy, and audit controls.
9. All kernels must support undo, correction, and non-shaming recovery.
10. All user-facing intelligence must distinguish facts, user-entered content, inference, stale memory, and guesses.
11. Recommendations require evidence before surfacing.
12. Durable memory requires source, confidence, edit path, deletion path, and receipt.
13. Ambitions must never silently convert sensitive capture into durable memory.
14. Accessibility and cognitive-load gates apply before implementation closeout.
15. Release claims must lag implementation proof.

## Conflict Resolution Order

1. Ambitions 3.0 source truth and top-level IA.
2. Ambitions 4.0 Execution Program and EB index.
3. Trust/Privacy/User Control kernel for sensitive data and memory control.
4. Accessibility/Cognitive Load kernel for human usability gates.
5. PXOS/SI/Product Depth/AOS docs for their owned layers.
6. Batch registry and global order for status truth only.

## Rollback And Migration Rules

No migration, durable storage, route/raw-value change, persistence/schema change, or compatibility deletion is allowed unless the executing EB prompt names rollback, proof lane, fixture coverage, and release-claim impact. Canon work must not mutate app behavior.

## Minimum Implementation Evidence Per Kernel

Each implementation batch needs exact files, focused tests, privacy scan, accessibility/cognitive-load evidence, fixtures or previews where UI exists, release-claim scan, rollback path, and audit/report updates.
