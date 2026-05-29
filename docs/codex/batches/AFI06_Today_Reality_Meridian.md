# AFI06 — Today Reality Meridian

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-25030685, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Owner: Ambitions Flagship Interface
Scope: Today object naming, Start Here origin proof, focused Today/app contracts,
batch state, reports

## Purpose

Align Today with the active AFI object model:

```text
Today = Reality Meridian + Start Here Surface
```

Today must answer "What should I do now?" with relief and clarity. Start Here
must emerge from the active Meridian state, not sit as a detached task card.

## Result

Accepted Yellow.

AFI06 renamed user-facing Today object language from the older Reality Rail
wording to Reality Meridian across Today presentation copy, screen contracts,
composition primitives, motion policy titles, degraded-state object labels,
preview fixtures, and focused proof tests.

Internal `.realityRail` enum cases, `DayRail*` types, and
`TodayRealityRail*` UI automation identifiers remain compatibility seams so
existing runtime state and UI smoke selectors are not broken by this batch.

## Validation

- `xcodegen generate` passed.
- Focused Today/App contract tests passed on rerun with 63 selected tests, 0
  failures. Raw log:
  `.codex/logs/2026-05-08T11-afi06-focused-tests-rerun.raw.log`.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-120540.log`.
- ACX quick, impact, docs, batch-closeout, and build-triage bundles ran. Docs
  and batch-closeout returned Green with advisory Yellow scan findings;
  build-triage returned informational Yellow because it prints discovered
  build/test docs only.
- Focused Today tests prove:
  - Reality Meridian continuity title.
  - Start Here emerges from the active Meridian node.
  - Now / Next / Later remain connected.
  - Why this? source path remains available through context, time fit, and goal
    thread evidence.
  - Still-counts / closure / receipt proof remains reviewable.
  - No task-list/dashboard/needs closure drift appears in focused visible copy.
- Focused app contract tests prove top-level contract and object-title
  expectations.
- `git diff --check` passed.

## Yellow Carry

Internal Reality Rail identifiers/types remain compatibility seams. AFI06 does
not claim final rendered screenshots, public accessibility conformance, full UI
suite proof, physical-device proof, release readiness, or full Today visual
quality completion.

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
