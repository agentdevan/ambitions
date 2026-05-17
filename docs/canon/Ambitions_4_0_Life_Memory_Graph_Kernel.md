# Ambitions 4.0 Life Memory Graph Kernel

<!-- markdownlint-disable MD013 -->

Status: Historical supporting canon; subordinate to `docs/truth/*`

Source-truth relationship: this kernel is part of Ambitions 4.0 External Brain Foundation and obeys Ambitions 3.0 baseline truth, PXOS user-facing canon, AmbitionsOS internal architecture boundaries, Signature Interface gates, Product Depth drill-down rules, and release-claim truth.

## Purpose

Life Memory Graph gives Ambitions durable, user-controlled context across goals, decisions, people, commitments, patterns, life events, and recurring themes. It is the foundation for Ambitions as an external brain.

## User Problem

Users need Ambitions to remember context without feeling like hidden surveillance or unearned certainty.

## User-Visible Outcome

Relevant context appears with source, confidence, edit, delete, stale-review, and receipt paths.

## Owned Primitives

- LifeMemoryNode
- LifeMemoryEdge
- MemorySource
- MemoryConfidenceLabel
- MemoryReceipt
- LifeEventRecord
- DecisionMemoryRecord
- PersonalOperatingManual
- ContextRecallCard
- MemoryCorrectionAction
- TrustDecayRule
- SensitiveMemoryBoundary

## Owned UI Surfaces

- memory graph browser
- context recall card
- memory edit sheet
- memory delete sheet
- personal operating manual
- why remembered this
- memory confidence label
- stale memory review
- rejected memory history

## Owned Data Concepts

- memory node
- memory edge
- source-backed memory
- inferred memory
- user-confirmed memory
- rejected memory
- stale memory
- confidence level
- last confirmed date
- life event record
- decision memory
- personal operating manual
- trust decay
- memory receipt
- sensitive memory boundary

## Privacy Implications

Privacy is architectural. Any implementation must classify sensitive material, identify local-first posture, name source truth, expose permission boundaries, and provide user correction, deletion, export where owned, and receipt paths before claims are made.

## Accessibility Implications

Every surface owned by this kernel must define Dynamic Type, VoiceOver order, Reduce Motion equivalent, non-color meaning, tap target, motor alternative, plain-language, cognitive-load, and overloaded-day expectations before closeout.

## Trust And Receipt Implications

Receipts must record what happened, source, user approval or correction, undo availability, privacy state, stale or confidence status where relevant, and what can be claimed. Recommendation or memory behavior requires evidence before surfacing.

## Relationship To Other Kernels

- Universal Capture provides intake; it cannot create durable memory without Trust controls.
- Life Memory Graph provides durable context; it cannot infer or store sensitive memory without Trust controls.
- Trust, Privacy, And User Control gates memory, capture, recommendation, audit, export, delete, undo, and correction.
- Product Maturity And Onboarding demonstrates value before asking for sensitive setup.
- Accessibility And Cognitive Load applies to this kernel and all EB implementation closeouts.

## Relationship To Today / Goals / Capture / Plan / You

Owned surfaces must stay inside Today, Goals, Capture, Plan, You, or their drill-downs/sheets/history/setup flows. No EB kernel creates a new top-level destination.

Primary owner: You trust controls, Goals/Plan/Today context recall, AmbitionsOS Life Graph boundaries.

## Relationship To SI Primitives

Signature Interface supplies future reusable visual/action/navigation/status primitives. UI work must wait for relevant SI gates or explicitly document why the EB batch owns the narrow UI primitive.

## Relationship To AOS Intelligence

AmbitionsOS may supply internal intelligence contracts. This kernel owns product boundaries, user control, source/evidence expression, and claim safety. AOS does not permit hidden inference or unsupported claims.

## Allowed Implementation Scope

canon, domain primitives, You-owned memory controls, context recall fixtures, focused tests, and receipts named by EB07-EB12.

## Forbidden Implementation Scope

durable memory without Trust controls, unlabeled inference, hidden personalization, forced sensitive memory, deletion without receipt, or memory claims without evidence.

## Green / Yellow / Red Criteria

Green: source truth is read, exact owned files are named, privacy/trust/accessibility/cognitive-load evidence is present, validation passes or advisory-only findings are classified, and no unsupported implementation or release claim is introduced.

Yellow: future implementation remains deferred to a named EB batch, human/platform proof is absent, repo-wide docs QA remains advisory, or dedupe ambiguity is safely referenced without duplicate source truth.

Red: production behavior is claimed without code/test evidence, sensitive data lacks controls, memory lacks source/confidence/edit/delete/receipt paths, capture lacks correction/routing, onboarding forces sensitive setup, accessibility gates are missing, or forbidden files change.

## Evidence Requirements

- Source docs read.
- Allowed and forbidden files named.
- Privacy and trust evidence.
- Accessibility and cognitive-load evidence.
- Focused tests or proof plan where implementation is allowed.
- Preview/fixture evidence where UI is allowed.
- Release-claim scan.
- Rollback and repair path.

## Non-Claims

This kernel does not prove product implementation, release readiness, platform proof, physical-device proof, legal/privacy signoff, public accessibility conformance, market proof, or App Store/TestFlight readiness.

## Maintenance Risk

See `Ambitions_4_0_External_Brain_Maintenance_Complexity_Value_Matrix.md`.

## Implementation Complexity

Implementation complexity is kernel-dependent and must be re-scored in each EB batch against current owner files and validation evidence.

## Product Value

This kernel is app-defining only when implemented with proof. Canon alone is active planned scope, not shipped value.

## Train Mapping

This kernel maps to EB01-EB40 through `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md` and `docs/codex/EB_EXTERNAL_BRAIN_DEPENDENCY_GRAPH.md`.

## Exact Implementation Claim Boundary

A future batch may claim only the exact model, surface, receipt, fixture, validation, or documentation it changes and verifies. No batch may claim the whole External Brain unless EB40 closes with evidence.
