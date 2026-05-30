# Codex Batch Prompt — T-E: Trust, Accessibility, Release Lock

## Objective

Lock accessibility, privacy, performance, release, and repo-governance gates with device proof.

## Scope

### AMB-FR-020 — Accessibility proof matrix and gates

Severity: Critical
Priority: P0
Labels: accessibility, qa, release
Dependencies: AMB-FR-001, AMB-FR-004

Affected files:
- `Sources/Accessibility`
- `Native/Ambitions/Features`
- `Native/AmbitionsUITests`

Problem: Accessibility needs device-backed proof across real surfaces.

Implementation: Create proof matrix for VoiceOver labels/order, Dynamic Type, Reduce Motion, Increase Contrast, tap targets, non-color meaning, and cognitive clarity.

Acceptance: Accessibility status is evidence-backed for all five tabs and key flows.

Validation: Accessibility UI tests, manual audit packet, screenshot proof.

Rollback: Block release if any P0 accessibility gate is red.

### AMB-FR-021 — Device-truth QA and release candidate packet

Severity: Critical
Priority: P0
Labels: qa, release, device
Dependencies: AMB-FR-020, AMB-FR-023

Affected files:
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- `docs/launch`
- `docs/audits`

Problem: Readiness proof must come from device and binary behavior.

Implementation: Create an RC packet requiring build output, simulator/device matrix, screenshots, accessibility evidence, migration proof, privacy manifest proof, and known limitation log.

Acceptance: No release can be green without device-backed evidence.

Validation: RC packet, UI tests, migration tests.

Rollback: Release remains blocked until packet is green.

### AMB-FR-022 — Privacy manifest and App Store declaration alignment

Severity: High
Priority: P0
Labels: privacy, app-store, release, trust
Dependencies: AMB-FR-010, AMB-FR-016

Affected files:
- `Native/Ambitions`
- `docs/launch`
- `docs/privacy`

Problem: Privacy claims must match binary behavior, permissions, logs, indexing, and continuity choices.

Implementation: Audit permissions, network calls, logs, indexing, analytics/crash behavior, export/sync behavior, and generate privacy readiness artifact.

Acceptance: App Store privacy claims, privacy manifest, and code behavior are consistent.

Validation: Privacy lint, no-network runtime test, manifest review.

Rollback: Remove or gate any feature that cannot be honestly declared.

### AMB-FR-023 — Local observability and performance baselines

Severity: High
Priority: P1
Labels: performance, observability, privacy, release
Dependencies: AMB-FR-007, AMB-FR-009

Affected files:
- `Native/Ambitions/App`
- `Native/Ambitions/Services`
- `Native/Ambitions/Persistence`
- `Native/Ambitions/Runtime`

Problem: A local-first flagship needs measurable performance without leaking private data.

Implementation: Add local redacted logging, launch-time budget, repository query budget, runtime projection budget, and local diagnostic export.

Acceptance: Performance and diagnostics proof exists without private analytics collection.

Validation: Performance baseline script, log redaction tests, launch budget artifact.

Rollback: Diagnostics disabled by default until privacy review passes.

### AMB-FR-024 — Repo authority collapse and Codex automation manifest

Severity: High
Priority: P1
Labels: repo-hygiene, codex, governance, docs
Dependencies: None

Affected files:
- `AGENTS.md`
- `.codex`
- `docs`
- `prompts`
- `scripts`

Problem: Repo governance is strong but heavy; Codex needs fewer sharper authority paths.

Implementation: Create authority map, stale-doc detector, active batch manifest, train runner instructions, and Green/Yellow/Red proof reporting.

Acceptance: Codex can identify source truth, batch order, validation commands, proof artifacts, and rollback behavior.

Validation: Authority lint, stale-doc scan, manifest validation script.

Rollback: Never delete historical docs without archiving or explicit stale classification.

## Batch rules

- Keep the batch scoped to listed issues.
- Do not use generic task-manager terminology.
- Do not use cloud/external LLMs as core runtime architecture.
- Add or update tests before declaring Green.
- Add proof artifacts under `docs/audits/flagship-remediation/`.
- End with summary, files changed, validation, proof artifacts, risks, rollback path, and Green / Yellow / Red status.
