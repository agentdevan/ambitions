# AQOS Repair Batch Generator Protocol
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

Repair batches must be narrower than the failed batch.

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
