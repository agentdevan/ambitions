# Architecture Remediation Accepted Yellow Misuse Audit

Status: active Green-only remediation control audit. This is not architecture completion proof.
Generated: 2026-07-02
Repo head inspected: `74ea1319910ef00276663da4f44ae1321ef4bfcb`
Project: Architecture Simplification + Flagship Readiness Remediation

Linear repair applied: AMB-1666, AMB-1667, AMB-1668, and AMB-1719 were moved to `Needs Repair`; AMB-1730, AMB-1731, and AMB-1732 were created as blocking repair leaves for AMB-1669 and AMB-1670.

## Core Rule

Accepted Yellow is forbidden for incomplete required source/runtime/test remediation scope.

If an issue acceptance requires source changes, deletion/quarantine, runtime enforcement, direct-write removal, command/rejection receipt behavior, migration proof, projection safety, or executable tests, then audits, classifications, docs, plans, or partial proof cannot close it as Accepted Yellow. The issue must remain `In Progress`, move to `Needs Repair`, or move to `Ready For Review` only after implementation and proof exist.

Accepted Yellow may describe bounded docs/control-plane scope or owner-accepted risk outside the issue requirement. It must not count as parent/milestone completion and must not support any Green-equivalent claim.

## Context Compaction Guard

On resume or context compaction, newest user instruction wins over summaries, memory, older Linear comments, and earlier task variants. Before editing, tracker mutation, commit, or closeout, a resumed Codex run must:

- Read the latest user-visible task request and confirm it is not continuing a superseded task variant.
- Run `git status --short --branch` and inspect the current diff.
- Run `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json`.
- Refresh Linear statuses for AMB-1666, AMB-1667, AMB-1668, AMB-1719, AMB-1730, AMB-1731, and AMB-1732 before tracker claims.
- Stop rather than continue M03, broad M08, M09, M10, M11, M12, or M13 work from a compacted summary unless the newest user request explicitly asks for it.

## Read-First File Findings

All required read-first files named by the task existed locally at the start of this audit. No named read-first file was missing.

## Evidence Snapshot

- Legacy runtime: `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json` now reports `currentLegacyRuntimeFiles=87` and `legacyRuntimeFileCeiling=87` after the AMB-1730 standalone PlanningEngine, goal clarification/contradiction, and TimeEngine owner-move batches. M02 administrative completion does not mean legacy runtime authority is gone.
- Persistence direct writes: `python3 scripts/ambitions-runtime-direct-write-audit.py --json` reported `19` unsafe rows and `1` unknown row. A classified unsafe direct write is not rejection proof.
- Migration safety: `docs/audits/persistence-existing-data-migration-proof-plan.md` is a proof plan, not executable migration proof.
- External adapters: current evidence contains contract/audit/local redaction proof, but not full device/lifecycle/terminated-app/system-surface proof and not complete command/rejection receipt coverage for every mutating entry point.
- Source Atlas: boundary/no-private-graph audits pass locally for current scope, but AMB-1729 is still `In Progress`; production R2, release, device, privacy/legal, entitlement, TestFlight, and App Store proof are not proven.

## M02 Correction

M02 Runtime Strangler is not Green. Any M02 100% or completed wording is administrative/invalid as Green unless it is adjacent to this correction: legacy runtime authority, persistence direct writes, and external adapter mutation enforcement still require repair work and executable proof.

M02 may not unlock downstream architecture Green until:

- `Native/Ambitions/Core/Runtime` no longer contains live production authority except approved adapter/test-only support.
- Persistence direct writes are removed, routed through LocalRuntimeOS command/event/receipt flow, or blocked with executable rejection behavior.
- External adapters route mutating paths through command/outbox/rejection receipts and read only sanitized projections.
- Focused tests and current local proof artifacts exist.

## Accepted Yellow Classification

| Linear | Current status | Classification | Required correction |
|---|---|---|---|
| AMB-1665 | Accepted Yellow | `valid_accepted_yellow` | M01 map scope only; no runtime Green claim. |
| AMB-1708 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Inventory only; AMB-1668 still needs implementation/proof. |
| AMB-1709 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Inventory only; AMB-1667 still needs implementation/proof. |
| AMB-1710 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Inventory only; AMB-1666 still needs implementation/proof. |
| AMB-1666 | Needs Repair | `invalid_required_scope_incomplete` | Repair through AMB-1730; eliminate remaining legacy runtime production authority. AMB-1730 reduced the count from `111` to `87`, but remaining live authority still blocks Green. |
| AMB-1713 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Classification only; parent remains repair-required. |
| AMB-1714 | Accepted Yellow | `valid_accepted_yellow` | Bounded replacement slice only; parent remains repair-required. |
| AMB-1715 | Accepted Yellow | `valid_accepted_yellow` | Guard slice only; parent remains repair-required. |
| AMB-1716 | Accepted Yellow | `valid_accepted_yellow` | First quarantine slice only; parent remains repair-required. |
| AMB-1667 | Needs Repair | `invalid_required_scope_incomplete` | Repair through AMB-1731; remove/block direct writes and prove migration safety. |
| AMB-1717 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Classification only; parent remains repair-required. |
| AMB-1718 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Owner map only; parent remains repair-required. |
| AMB-1719 | Needs Repair | `invalid_required_scope_incomplete` | Repair through AMB-1731; classification of unsafe writes is not rejection proof. |
| AMB-1720 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Proof plan only; migration safety still needs executable fixtures. |
| AMB-1668 | Needs Repair | `invalid_required_scope_incomplete` | Repair through AMB-1732; implement external command/rejection receipt coverage. |
| AMB-1721 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Contract only; parent remains repair-required. |
| AMB-1722 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Audit only; parent remains repair-required. |
| AMB-1723 | Accepted Yellow | `docs_only_leaf_valid_but_parent_must_remain_open` | Audit only; EventKit/Reminders proof remains repair-required. |
| AMB-1724 | Accepted Yellow | `external_proof_deferred_to_release_or_device` | Local redaction slice only; device/lifecycle and parent proof still block Green. |
| AMB-1725 | Accepted Yellow | `valid_accepted_yellow` | Source Atlas ADR scope only; AMB-1729 still required. |
| AMB-1726 | Accepted Yellow | `valid_accepted_yellow` | Growth guard scope only; AMB-1729 still required. |
| AMB-1727 | Accepted Yellow | `valid_accepted_yellow` | Denylist scope only; AMB-1729 still required. |
| AMB-1728 | Accepted Yellow | `valid_accepted_yellow` | Local test scope only; production R2/release/device/privacy/legal proof remains absent. |

The machine-readable source is `docs/audits/architecture-remediation-accepted-yellow-misuse-audit.json`.

## Required Repair Leaves

- AMB-1730 Legacy runtime remaining authority elimination: owner AMB-1666; blocks AMB-1669 and AMB-1670 until remaining live `Core/Runtime` authority is moved, deleted, quarantined, or converted to approved adapter/test-only support. Current count after the AMB-1730 PlanningEngine, goal clarification/contradiction, and TimeEngine batches is `87`.
- AMB-1731 Persistence direct-write elimination and migration fixture proof: owner AMB-1667; blocks AMB-1669 and AMB-1670 until unsafe/unknown direct writes are zero or explicitly allowlisted as non-production/test-only and migration fixtures prove replay/idempotency.
- AMB-1732 External adapter command/rejection receipt implementation and tests: owner AMB-1668; blocks AMB-1669 and AMB-1670 until mutating external entry points route through command/outbox/rejection receipts or explicit release/device blockers.
- Source Atlas stale-file deletion inventory: owner AMB-1680/AMB-1729; remains the narrow M08 exception only and must not broaden into production R2 or release readiness.

## Non-Claims

This audit does not claim architecture fixed, M02 Green, LocalRuntimeOS complete, Release Green, Visual Green, accessibility conformance, privacy/legal approval, production R2 readiness, production CloudKit readiness, TestFlight readiness, App Store readiness, or device readiness.
