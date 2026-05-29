# AQOS Repair Batch Generator Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS repair protocol.
Date: 2026-05-05

## Purpose

When AQOS detects recoverable Red, Codex must not improvise broad repairs or hide the issue as Yellow. It must create a narrow repair batch with explicit ownership, scope, evidence, rollback, and stop conditions.

## Repair Batch Format

Repair batch name:

`<DOMAIN>-<SURFACE>-REPAIR-<short-issue>`

Examples:

- `FVQ-TODAY-REPAIR-scaffold-reality-rail`
- `FVQ-PLAN-REPAIR-dashboard-drift`
- `AXQ-YOU-REPAIR-dynamic-type-truncation`
- `PVQ-WIDGET-REPAIR-sensitive-found-life-leak`
- `ARQ-TODAY-REPAIR-view-file-bloat`
- `PERQ-CAPTURE-REPAIR-starfield-render-cost`
- `DIQ-SCHEMA-REPAIR-migration-gap`

## Required Repair Batch Fields

Every repair batch must define:

- failure observed
- evidence that proved failure
- user impact
- owner surface/domain
- allowed files
- forbidden files
- exact repair goal
- required proof before closure
- tests to run
- screenshots/evidence to produce
- rollback path
- stop conditions
- next batch after repair

## Scope Rule

Repair batches must be narrower than the needs review batch.

Allowed:

- focused Today visual hierarchy repair
- focused Dynamic Type truncation repair
- focused privacy redaction repair
- focused file extraction
- focused migration test addition

Forbidden:

- broad redesign
- unrelated refactor
- new feature scope
- weakening canon
- deleting tests
- hiding evidence
- changing route/raw/persistence/schema unless the repair explicitly owns it

## Closure Rule

A repair batch may close only when:

- original failure is directly addressed
- evidence is durable
- relevant tests pass
- no new domain is affected without classifier update
- Green taxonomy is explicit
- no Hard Red remains

## Escalation

If a repair fails twice:

- split narrower if possible;
- document remaining blocker;
- classify Hard Red if continuation would hide quality failure;
- provide operator resume prompt.

## Yellow Rule

Accepted Yellow is allowed only when:

- failure is not primary-product damaging;
- no sensitive/legal/data-loss/release/visual-hard-red issue remains;
- owner batch is explicit;
- repair path is concrete;
- user-facing claim remains bounded.

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
