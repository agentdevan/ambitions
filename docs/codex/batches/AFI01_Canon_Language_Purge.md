# AFI01 — Canon Language Purge

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: docs/canon, docs/codex, reports, helper scans

## Purpose

Remove compatibility names from active canon, active prompts, visual QA, and
global train language. Preserve legacy terms only when they are clearly marked
as Archive, Migration, historical evidence, compatibility debt, or explicit
hard-Red guardrails.

## Required Source Truth

- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/01A_Product_Canon_Flagship_Amendment.md`
- `docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`
- `docs/audits/afi-stash-reconciliation-report.md`

## Result

Accepted Yellow.

Active AFI language now names the top-level interface as:

```text
Today / Goals / Capture / Time / You
```

`Plan` is not a top-level destination. It remains valid as contextual/action
language such as Adjust plan, Shape week, Review pressure, or compatibility
history.

## Allowed Changes

- Canon language corrections.
- Global-order and run-state corrections.
- Helper-scan banned-term updates.
- Closeout/report updates.

## Forbidden Changes

- Production Swift changes.
- Route/raw-value/persistence/schema changes.
- New app feature behavior.
- Visual Green, accessibility conformance, device, release, App Store,
  TestFlight, privacy/legal, or production-readiness claims.

## Validation

- Banned-name scan over active AFI/governance files.
- `bash -n` for touched helper scripts.
- `git diff --check`.
- ACX quick/docs/batch-closeout bundles.

## Yellow Carry

Historical docs and old batch evidence may still contain Plan-era terminology.
Those are not active canon. AFI02 must lock the hierarchy and continue reducing
any remaining ambiguity where old evidence is not explicitly historical.
