# Frontend Screenshot Evidence Standard

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active FET standard
Date: 2026-05-09
Batch: FET02

## Purpose

UI-touching Ambitions work needs rendered visual evidence. Build logs, source-contract tests, preview declarations, accessibility identifiers, and docs are not visual proof.

## Evidence Location

Use one packet directory per UI-touching batch:

```text
docs/audits/screenshots/<batch-id>/
```

If the batch is docs-only or tooling-only, the report must state that no rendered UI claim is made.

## Required Names

Use lowercase batch IDs and surface names:

```text
<batch-id>-shell-baseline-dark.png
<batch-id>-today-after-dark.png
<batch-id>-goals-after-dark.png
<batch-id>-capture-after-dark.png
<batch-id>-time-after-dark.png
<batch-id>-you-after-dark.png
<batch-id>-today-dynamic-type-after-dark.png
<batch-id>-reduce-motion-notes.md
```

Baseline screenshots are required when the batch repairs existing UI or changes a shared primitive/chrome. After screenshots are required for every touched visible surface.

## Required Surfaces

Top-level UI batches require Shell, Today, Goals, Capture, Time, and You evidence unless the scope names a narrower touched-surface set and proves the others are not touched.

## What Counts

- Fresh simulator screenshots.
- Preview screenshots captured from deterministic SwiftUI previews.
- Rendered visual evidence from an approved local visual QA harness.
- A screenshot packet that includes date, simulator/device class, color scheme, Dynamic Type status, Reduce Motion status, touched surfaces, limitations, and non-claims.

## What Does Not Count

- Build success.
- Unit/UI test success without rendered output.
- Source screenshots from a design tool detached from the app.
- Preview source files with no rendered capture.
- Old screenshots with no freshness note.
- Human-readable descriptions without artifacts.

## Evidence Requirements

- Dark mode is required for top-level Ambitions UI work.
- Dynamic Type stress evidence is required when root surfaces, shell/chrome, or primary objects change.
- Reduce Motion notes are required when motion, transition, haptics, rail movement, composer reveal, receipt toast, or object continuity changes.
- Accessibility evidence must be recorded separately from visual evidence.

## Non-Claims

Simulator and preview evidence are not physical-device proof, signed archive proof, TestFlight proof, App Store proof, public accessibility conformance, legal/privacy signoff, or human release approval.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
