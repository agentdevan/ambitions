# FET01-FET12 FAANG Frontend Excellence Train

<!-- markdownlint-disable MD013 -->

Status: Queued Codex OS / frontend excellence train; no app UI implementation starts by this document
Date: 2026-05-09
Parent: CQS25 / FET00

## Purpose

FET01-FET12 converts the FET operating system into durable source truth, evidence packets, preview/screenshot discipline, and repair sequencing before further visible top-level UI expansion. It prevents future frontend batches from closing Green because SwiftUI compiled while the simulator still looks generic, dense, explanatory, or visually interchangeable.

## Ordering Rule

FET01-FET12 must run before any further visible top-level UI expansion. Future FCP, AFI, DAV, PD, SI, AOS UI, LDI UI, Source Atlas UI, and PFC external-surface UI work inherits FET gates immediately, even before the train completes.

## Train

| Batch | Title | Type | Purpose | Stop rule |
| --- | --- | --- | --- | --- |
| FET01 | Frontend Operating System Source Truth | docs/governance | Reconcile FET with AFI/FCP/FVQ/SI/PD/PFC/AOS/LDI source truth and remove ambiguity about UI-touching gates. | Stop on source-truth conflict affecting active IA, route compatibility, or release claims. |
| FET02 | Screenshot Evidence Packet Standard | docs/tooling | Define screenshot naming, freshness, simulator metadata, preview fallback, evidence directory layout, and non-claims. | Stop if the standard implies human/device/release proof. |
| FET03 | First Viewport Budget Protocol | docs/tooling | Formalize primary-object, chip, copy-line, hero-depth, and nested-content budgets. | Stop if budget weakens current FET Red conditions. |
| FET04 | Bottom Chrome Ownership Protocol | docs/tooling | Lock native tab bar, custom rail, FAB, toolbar, receipt overlay, and bottom safe-area rules. | Stop on route/raw-value or shell behavior implementation without approval. |
| FET05 | Primitive Identity And Anti-Card-Stack Protocol | docs/tooling | Map signature objects to allowed anatomy and reject generic rounded-card drift. | Stop if it invents new product IA or weakens SI. |
| FET06 | Copy Compression And Product Language Protocol | docs/tooling | Lock root copy budgets, user-value language, internal-architecture suppression, and AI-theater bans. | Stop on product strategy rewrite or release overclaim. |
| FET07 | Accessibility Evidence Packet Upgrade | docs/tooling | Require Dynamic Type, VoiceOver, touch target, contrast, non-color, Reduce Motion, and cognitive-load evidence beyond identifiers. | Stop if public accessibility approval is claimed. |
| FET08 | SwiftUI Composition And Maintainability Protocol | docs/tooling | Require state matrices, previewable components, owner-file budgets, extraction triggers, and no giant view accumulation. | Stop if production Swift changes are attempted. |
| FET09 | Surface Distinction Rubric | docs/governance | Define how Today, Goals, Capture, Time, and You must differ at first glance without changing route/raw values. | Stop if it changes active top-level IA. |
| FET10 | Visual QA Reviewer Packet Automation | tooling | Harden read-only scanners and report templates for FET evidence packets. | Stop if scripts mutate source, require network, signing, hosted CI, or secrets. |
| FET11 | Interface Recovery Batch Plan | docs/planning | Create IR repair sequencing for current UI debt without claiming fixes. | Stop if it implements app UI or claims current UI is approved. |
| FET12 | Frontend Excellence Handoff And Continuation Gate | docs/handoff | Close the train with inherited gate map, unresolved Yellow owners, rollback paths, and next eligible batch selection. | Stop on unclassified Red or unsafe dirty state. |

## Required Validation Baseline

```bash
git status --short
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
scripts/fet-readiness-gate.sh || true
scripts/fet-first-viewport-budget-scan.sh || true
scripts/fet-bottom-chrome-conflict-scan.sh || true
scripts/fet-primitive-density-scan.sh || true
scripts/fet-copy-density-scan.sh || true
scripts/fet-visual-qa-packet-check.sh || true
```

## Non-Claims

This train does not implement or fix current app UI by itself. It does not approve current visual quality, accessibility, device behavior, App Store screenshots, TestFlight, release readiness, legal/privacy readiness, or human visual approval.
