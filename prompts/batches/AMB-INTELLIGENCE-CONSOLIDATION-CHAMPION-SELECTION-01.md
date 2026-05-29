<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01

Batch type: guard-repair

Mission: install mandatory anti-parallel implementation enforcement and existing-code champion coverage for Ambitions.

Allowed scope:

- `scripts/ambitions-parallel-implementation-guard.py`
- `scripts/ambitions-champion-coverage-check.py`
- `scripts/ambitions-active-code-map.py`
- `scripts/ambitions-parallel-implementation-scan.py`
- `scripts/ambitions-champion-scorecard.py`
- `scripts/ambitions-private-runtime-wiring-check.py`
- `scripts/ambitions-codex-train.sh`
- `scripts/ios26-flagship-run-sequential.sh`
- `Makefile`
- `docs/codex/canonical-owner-map.yml`
- `docs/codex/parallel-guard-concept-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `docs/codex/CHAMPION_SELECTION_GATE.md`
- `docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md`
- `docs/audits/intelligence-consolidation/**`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `build/reports/intelligence-consolidation/**`
- `build/reports/parallel-implementation-guard/**`

Forbidden scope:

- Do not delete Swift source.
- Do not rewrite product runtime architecture.
- Do not add a new recommendation engine, capture parser, proof system, receipt system, replay system, source ledger, persistence model, or top-level surface.

Accepted Yellow boundary:

- owner: Ambitions repo/process owner
- reason: this bootstrap batch creates the guard inputs and initial champion coverage artifacts
- no-claim boundary: bootstrap Yellow does not prove all existing Swift code is champion-reviewed, does not prove duplicates are removed, and does not prove runtime consolidation
- follow-up gate: AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02
- canonical owner affected: all canonical owners listed in `docs/codex/canonical-owner-map.yml`
- supersession/rescue ledger entry: required where replacement or better older code is suspected

Required outcome:

- runner-enforced pre/post parallel implementation guard
- champion coverage check before future source-changing batches
- machine-readable owner, concept, and coverage inputs
- human-readable ledgers and gates
- validation reports emitted under `build/reports/`

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
