<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# QUEUE-INTEL-CODEXOS-UPGRADE-01 — Remaining Batch Inventory, Global Sequence, And Codex OS Upgrade

## Batch ID

QUEUE-INTEL-CODEXOS-UPGRADE-01

## Runner command

```bash
scripts/ambitions-codex-train.sh QUEUE-INTEL-CODEXOS-UPGRADE-01 prompts/batches/QUEUE-INTEL-CODEXOS-UPGRADE-01.md
```

Equivalent:

```bash
make batch BATCH=QUEUE-INTEL-CODEXOS-UPGRADE-01 PROMPT=prompts/batches/QUEUE-INTEL-CODEXOS-UPGRADE-01.md
```

## Objective

Create an authoritative, easy-reference, in-repo remaining-batch inventory and peak global batch train sequence for Ambitions, then upgrade Codex OS where the repo proves gaps in queue authority, stale mirrors, proof packets, Yellow debt control, EFC/FET enforcement, and runner/prompt hygiene.

This is a governance/Codex OS/data-reference batch. It must not implement product behavior.

## Active source truth to inspect

Read these first, in this order:

1. `.codex/state/active-batch.yml`
2. `.codex/reports/current-batch-train-state.md`
3. `.codex/reports/current-run-state.md`
4. `.codex/state/global-train-attempt-ledger.md`
5. `docs/codex/BATCH_REGISTRY.md`
6. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
7. `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
8. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
9. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
10. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
11. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
12. `docs/codex/global-train-supervisor.md`
13. `docs/codex/ambitions-hybrid-runner.md`
14. All active batch-train manifests under `docs/codex/batch-trains/`, especially PK, SA, AOS, LDI, FCP, PFC, and RHC.

## Allowed scope

- `docs/codex/**` for queue reference docs, queue schema, global sequence recommendations, Codex OS operating docs, and proof closeout requirements.
- `docs/audits/**` for a final audit report.
- `.codex/reports/current-run-state.md` and `.codex/reports/current-batch-train-state.md` only if needed to repair stale mirrors while preserving active truth.
- `.codex/state/active-batch.yml` only if a narrow mirror/status correction is required and supported by evidence.
- `scripts/**` only for non-mutating read-only validators/resolvers. Do not weaken existing validators.
- `prompts/batches/**` only if creating follow-up runner-compatible prompts for STATE-MIRROR-RECONCILE-01, IR-01, or QUEUE-SCHEMA-2.

## Forbidden scope

- No production Swift app behavior changes.
- No route/raw-value, deep-link, App Intent, widget, notification, persistence/schema, dependency, signing, entitlement, workflow, generated-project, StoreKit, CloudKit, hosted AI, telemetry, analytics, or user-data-server changes.
- Do not rerun PK15.
- Do not start standalone AIR or broad standalone EFC implementation trains.
- Do not retire CS compatibility seams without named owner proof.
- Do not delete historical docs or prompt artifacts based on name smell alone.
- Do not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility conformance, legal/privacy compliance, sync/cloud readiness, backend completion, or global train completion.

## Required deliverables

1. `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md`
   - Full remaining batch inventory grouped by train.
   - For each entry: ID, title, classification, active/queued/blocked/deferred status, owner train, source path, dependency gate, risk class, proof class, EFC/AIR/surface inheritance, consolidation posture, and next action.

2. `docs/codex/AMB_REMAINING_BATCH_REFERENCE.json`
   - Machine-readable version of the inventory.
   - Must include source paths and generated timestamp.
   - Must preserve canonical IDs; do not renumber historical batches.

3. `docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md`
   - Peak optimized sequence from current live state.
   - Must start with PK16 unless active-state evidence changes.
   - Must include macro-epochs and hard gates: PK16; PK17-PK21; PK22-PK28; PK29-PK31; PK32-PK34; PK35-PK37; PK38-PK41; IR-01 before visible UI expansion; SA; FCP/AOS/LDI tails; PFC terminal; EFC16-EFC18; RHC; DPTG00 terminal-only proof.

4. `docs/audits/queue-intel-codexos-upgrade-report.md`
   - What changed.
   - Authority conflicts found.
   - Codex OS gaps found.
   - What was not claimed.
   - Validation evidence.
   - Next eligible batch.

5. Optional read-only script if useful:
   - `scripts/ambitions-queue-snapshot.sh` or equivalent.
   - It must not mutate repo state; it should print current next-safe-action, stale mirror warnings, and queue counts.

## Validation expectations

Run or record why not run:

```bash
git status --short
git diff --check
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/dev/null
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
make prompt-audit || true
make batch-self-check || true
```

If a read-only script is added, run it and include output in the audit report.

## Visual proof expectations

No visual proof required because this batch must not change UI. If any UI-facing guidance is edited, record that rendered proof is not claimed and that IR-01/FVQ/FET own future screenshot proof.

## Hard Red stop conditions

Stop immediately if:

- Active batch authority changes away from PK16 without clear evidence.
- Any product Swift, schema, route/raw-value, dependency, signing, workflow, entitlement, or generated-project file is touched.
- Queue data would require inventing unknown batch state.
- The batch would weaken validators or remove evidence history.
- A stale mirror cannot be reconciled without ambiguous authority.
- The repo has dirty user-authored work that cannot be classified.
- A serious privacy/security/release overclaim appears and cannot be narrowly repaired.

## Rollback expectations

Prefer forward repair for docs/schema mistakes. Revert only current-batch changes if the inventory or sequence cannot be made accurate. Never discard user-authored dirty work, historical evidence, migration findings, Yellow owner notes, or run artifacts. Leave a rollback command in the final audit report.

## Continuation / next batch rule

After this batch, the next implementation batch remains PK16 Trust History Query unless fresh active-state evidence proves a different unresolved active batch must close first. Do not mark global train complete.

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
