# PK00 Current Backend Proof Baseline

<!-- markdownlint-disable MD013 -->

Status: Active next eligible Platform Kernel batch.
Date: 2026-05-08

## Mission

Produce the current backend/platform proof baseline for Ambitions without
production code changes. PK00 establishes what exists, what is missing, and what
must be proven before transaction, migration, sync, side-effect, diagnostics,
intelligence, performance, or package-split work proceeds.

## Required Inspection

- Current backend/framework files in `Native/Ambitions/Persistence/**`,
  `Native/Ambitions/Runtime/**`, `Native/Ambitions/Notifications/**`,
  `Native/Ambitions/Integrations/**`, `Native/Ambitions/ExternalSnapshots/**`,
  `Native/Ambitions/Services/**`, `Native/Ambitions/Domain/**`, `Package.swift`,
  and `project.yml`.
- Current service graph and dependency container wiring.
- Repository write paths and multi-repository mutation risks.
- SwiftData schema, portable snapshots, blobs, preferences, and external
  snapshot storage.
- Migration, recovery, backup, import, export, and rollback gaps.
- Notification, EventKit, widget/share/Live Activity, App Intent, and external
  snapshot side-effect paths.
- Current test coverage and local validation proof.
- Current hosted CI state and explicit absence/presence of workflow proof.

## Required Output

Create or update a baseline report under `docs/audits/` that includes:

- service graph map
- write-path map
- persistence/schema map
- migration/recovery gap map
- side-effect path map
- test/proof map
- PK01-PK41 dependency implications
- Green/Yellow/Red classification
- hard Red blockers, if any
- no-claim boundary

## Forbidden

- No production code changes.
- No project/package split.
- No schema, migration, sync, backup, restore, side-effect, notification,
  EventKit, widget, Live Activity, App Intent, privacy, diagnostic, or
  intelligence runtime changes.
- No readiness claims beyond evidence inspected in the batch.

## Validation

Minimum:

```bash
git status --short
git diff --check
python3 scripts/ai/acx_local.py bundle quick
python3 scripts/ai/acx_impact.py <changed files>
```

Run docs/batch-closeout bundles when the report or control docs change. Run
build/test lanes only if PK00 unexpectedly needs code repair.
