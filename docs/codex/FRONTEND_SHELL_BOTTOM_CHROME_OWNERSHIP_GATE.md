# Frontend Shell Bottom Chrome Ownership Gate

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET04

## Purpose

Ambitions must have one coherent bottom navigation owner. Native tab chrome, a custom Meridian rail, floating global add, toolbar controls, receipt trays, and header actions cannot compete for the same visual job.

## Gate Rules

- Native `TabView` chrome and custom Meridian rail cannot both read as active product navigation.
- Floating global plus cannot conflict with tab navigation, receipt overlay, keyboard/composer, or home indicator.
- Header, search, avatar, and repeated toolbar controls must be justified by the surface.
- Bottom chrome must have a single named owner.
- Global add must be contextual, deeply integrated, or explicitly suppressed when it competes with the active surface.
- Chrome screenshots must prove no overlap, no buried tab, no ambiguous selected state, and no inaccessible bottom controls.

## Required Scan Targets

- `Native/Ambitions/App/AmbitionsRootView.swift`
- app shell/scaffold/chrome files
- tab, nav, Meridian, floating plus, receipt overlay, safe-area, and toolbar usages

## Red

Competing nav systems, visually active double chrome, floating plus over tab/chrome/composer, repeated top controls without purpose, or missing screenshot evidence for shell/chrome changes.

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
