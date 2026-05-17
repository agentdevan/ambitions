# Ambitions Batch Reconciliation And Proof Authority Plan

## Purpose

This document defines the reconciliation strategy for restoring a single authoritative execution and proof model across Ambitions.

The repo has evolved through multiple implementation eras, train overlays, canon migrations, proof systems, and execution waves. The current registry and execution documents contain:

- duplicate state declarations
- append-only historical drift
- conflicting queue declarations
- incomplete proof normalization
- mixed canon/execution/proof responsibilities
- superseded train ambiguity
- incomplete implementation evidence mapping

This document defines the required normalization model.

---

# Authority Hierarchy

## 1. Canon Truth

Location:

- docs/canon/

Purpose:

- Defines product truth
- Defines IA truth
- Defines system truth
- Defines naming truth
- Defines flagship direction
- Defines active product language

Canon does NOT determine implementation completion.

Canon only defines intended truth.

---

## 2. Execution Truth

Primary operational authority:

- docs/codex/BATCH_REGISTRY.md

This registry must become:

- normalized
- deduplicated
- proof-backed
- machine-readable
- conflict-free

The registry must NOT function as:

- historical dumping ground
- append-only narrative log
- duplicate canon store
- speculative roadmap prose

---

## 3. Proof Truth

A batch may only be marked Complete when ALL required proof exists.

Required proof categories:

- implementation exists
- implementation committed
- implementation paths identified
- evidence/audit exists
- test evidence exists when applicable
- no unresolved Red gates
- not superseded by newer authority
- no contradictory registry state

Missing proof automatically downgrades status.

---

## 4. Remaining Work Truth

Primary execution ordering authority:

- GLOBAL_FULL_STACK_COMPLETION_ORDER.md

This order must be reconciled against:

- implemented work
- superseded trains
- blocked trains
- historical trains
- registry state
- canon overrides

No orphan queue declarations are allowed.

---

# Required Status Model

Every train/batch must resolve into exactly one primary state.

Allowed states:

- COMPLETE_GREEN
- COMPLETE_ACCEPTED_YELLOW
- PARTIAL
- ACTIVE
- QUEUED
- BLOCKED
- SUPERSEDED
- HISTORICAL
- INVALIDATED
- NEEDS_RECONCILIATION

Multiple simultaneous states are forbidden.

---

# Required Reconciliation Audit

The reconciliation pass must:

1. Scan all prompts/batches
2. Scan all registry entries
3. Scan all reports/audits
4. Scan implementation evidence
5. Scan commits
6. Detect conflicting states
7. Detect orphan prompts
8. Detect false completion claims
9. Detect superseded but active trains
10. Detect implemented-but-untracked work
11. Detect stale next-batch declarations
12. Detect canon conflicts
13. Detect duplicate ownership declarations
14. Detect release-claim violations

---

# Required Output Artifacts

The reconciliation system must ultimately produce:

- ACTIVE_EXECUTION_GRAPH.md
- VERIFIED_COMPLETED_BATCHES.md
- REMAINING_WORK_GRAPH.md
- BLOCKED_AND_DEFERRED_BATCHES.md
- SUPERSEDED_AND_ARCHIVE_BATCHES.md
- PROOF_INTEGRITY_AUDIT.md
- REGISTRY_CONFLICT_REPORT.md
- AUTHORITY_HIERARCHY.md
- FINAL_RECONCILED_BATCH_REGISTRY.md

---

# Registry Normalization Rules

## Forbidden

- duplicate batch declarations
- conflicting statuses
- speculative completion
- prose-only completion claims
- unresolved queue ambiguity
- historical drift mixed into active queue
- append-only execution updates

## Required

- exact status ownership
- exact proof references
- exact blocking reasons
- exact successor/predecessor mapping
- exact supersession mapping
- exact historical/archive mapping

---

# Release Claim Safety

No batch may imply:

- release readiness
- TestFlight readiness
- App Store readiness
- legal compliance
- accessibility certification
- device proof
- platform completion
- sync completion
- AI/runtime completion

Unless explicit proof exists.

---

# Immediate Known Conflict

Known current registry conflict:

- PD16 and PD17 appear simultaneously complete and queued/deferred in separate registry sections.

This confirms the registry currently behaves as append-only historical narrative instead of reconciled operational truth.

---

# Immediate Next Step

The next governance execution pass should:

1. inventory all active prompts
2. inventory all referenced trains
3. map all implementation proof
4. build normalized train graph
5. downgrade unsupported completion claims
6. isolate superseded/historical material
7. regenerate BATCH_REGISTRY.md from normalized truth

This governance reconciliation pass outranks additional feature expansion until operational truth integrity is restored.
