# AFI07 — Goals Constellation Atlas

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
Scope: Goals top-level object language, first-screen contract, focused Goals/app
contracts, batch state, reports

## Purpose

Align Goals with the active AFI object model:

```text
Goals = Your Direction / Constellation Atlas + Orbital Lens
```

Goals must answer "What is my life pointed at?" with orientation. Life areas
must be visible without system ranking, scoreboards, KPI posture, habit rings,
or astrology-like metaphor drift. Mission Control remains valid inside Goal
Detail and internal compatibility seams only; it must not present as the
top-level Goals object.

## Result

Accepted Yellow.

AFI07 updated top-level Goals copy and contracts to Your Direction,
Constellation Atlas, and Orbital Lens. The existing Goals mechanics remain
intact, while visible top-level object labels, screen-contract content,
composition primitives, motion/degraded-state object titles, preview fixtures,
and focused tests now assert the AFI Goals object language.

Internal Mission Control type names and Goal Detail Mission Control surfaces
remain compatibility seams. AFI07 does not rename route raw values, persistence
models, or historical/internal test identifiers.

## Validation

- `xcodegen generate` passed.
- Focused Goals/App contract tests passed on rerun with 41 selected tests, 0
  failures. Raw log:
  `.codex/logs/2026-05-08T12-afi07-focused-tests-rerun.raw.log`.
- `scripts/build-local.sh` passed. Raw log:
  `output/logs/build-local-20260508-123100.log`.
- ACX quick, impact, docs, batch-closeout, and build-triage bundles ran. Docs
  and batch-closeout returned Green with advisory Yellow scan findings;
  build-triage returned informational Yellow because it prints discovered
  build/test docs only.
- Focused Goals/App contract tests prove:
  - Goals hero uses Your Direction.
  - Constellation Atlas is top-level Goals object language.
  - Orbital Lens keeps one thread connected to Today.
  - Life areas remain equal-weight and list-fallback capable.
  - Mission Control does not appear in top-level Goals first-screen copy.
  - No KPI/dashboard/ranked score/habit-ring/astrology drift appears in focused
    top-level copy.
- `git diff --check` passed.

## Yellow Carry

Rendered screenshots, full UI test suite, manual accessibility traversal, and
complete internal Mission Control identifier retirement remain unclaimed.

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
