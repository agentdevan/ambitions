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
| FET01 | Frontend Operating System Source Truth | docs/governance | Reconcile FET with AFI/FCP/FVQ/SI/PD/PFC/AOS/LDI source truth and explain the difference between feature completion and frontend composition completion. | Stop on source-truth conflict affecting active IA, route compatibility, or release claims. |
| FET02 | Screenshot Evidence Pipeline | docs/tooling | Define screenshot location, naming, baseline/after packets, dark mode, Dynamic Type, Reduce Motion, what counts as visual proof, and what does not. | Stop if the standard implies human/device/release proof. |
| FET03 | First Viewport Budget Gate | docs/tooling | Formalize one-primary-object, support-object, chip, copy-line, floating-control, bottom-nav, nested-content, and architecture-copy budgets. | Stop if budget weakens current FET Red conditions. |
| FET04 | Shell / Bottom Chrome Ownership Gate | docs/tooling | Lock native tab bar, custom rail, FAB, toolbar, receipt overlay, header, and bottom safe-area ownership rules. | Stop on route/raw-value or shell behavior implementation without approval. |
| FET05 | Top-Level Surface Composition Gate | docs/governance | Define the one-thesis composition gate for Today, Goals, Capture, Time, and You. | Stop if it changes active top-level IA. |
| FET06 | Primitive Misuse And Density Gate | docs/tooling | Map signature objects to constrained anatomy and reject generic rounded-card, chip-grid, nested-panel, and unlimited-content drift. | Stop if it invents new product IA or weakens SI. |
| FET07 | Copy Compression And Product-Language Gate | docs/tooling | Lock root copy budgets, user-value language, internal-architecture suppression, and AI-theater bans. | Stop on product strategy rewrite or release overclaim. |
| FET08 | Accessibility / Dynamic Type / Reduce Motion Gate | docs/tooling | Require Dynamic Type, VoiceOver, touch target, contrast, non-color, Reduce Motion, and cognitive-load evidence beyond identifiers. | Stop if public accessibility approval is claimed. |
| FET09 | Motion / Haptics / Interaction Believability Gate | docs/governance | Require motion and haptics to orient, confirm, or reduce uncertainty with Reduce Motion equivalents. | Stop if it approves decorative/gimmicky motion or device proof without evidence. |
| FET10 | Visual QA Scorecard And Review Packet | docs/tooling | Harden the 1-100 scorecard, review packet, screenshot reviewer, and readiness gate. | Stop if scripts mutate source, require network, signing, hosted CI, or secrets. |
| FET11 | UI Regression Stop Protocol | docs/planning | Define when visual regressions stop continuation, enter repair loops, and block build-passed overrides. | Stop if it implements app UI or claims current UI is approved. |
| FET12 | Resume Global Train With Frontend Council Enforcement | docs/handoff | Close the train with inherited gate map, unresolved Yellow owners, rollback paths, and next eligible implementation prompt. | Stop on unclassified Red or unsafe dirty state. |

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

## Completion Note

FET01-FET12 may be marked complete only when the per-batch reports and final train report exist, the FET scripts validate as present/executable, global gate docs inherit FET, and no unsupported UI repair or release/readiness claim is introduced.
