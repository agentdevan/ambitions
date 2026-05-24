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
