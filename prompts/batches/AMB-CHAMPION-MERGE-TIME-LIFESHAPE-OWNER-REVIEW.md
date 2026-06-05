<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CHAMPION-MERGE-TIME-LIFESHAPE-OWNER-REVIEW

Status target: accepted Yellow or Green

## Mission

Complete the minimal owner-review governance unblock for Time/Plan/LifeShape lock scope so AMB-515 can proceed without weakening the parallel concept lock policy.

Use `docs/truth/PRODUCT_DESIGN_TRUTH.md` as active product/design authority.

Do not modify Time source surfaces, runtime behavior, tests, previews, app settings, privacy manifests, or app targets.

## Inspect First

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`
- `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md`
- `prompts/batches/AMB-515.md`
- `build/reports/parallel-implementation-guard/AMB-515-pre.md`
- `scripts/ambitions-parallel-implementation-guard.py`

## Required outcomes

1. Narrowly authorize AMB-515 for `time_plan_lifeshape` without removing the concept lock.
   - Keep `time_plan_lifeshape` in `docs/codex/concept-lock-registry.yml`.
   - Keep `blocked_status` non-final (do not mark as final or globally cleared).
   - Add the minimal owner-review allowance so AMB-515 is explicitly allowed.
2. Preserve Time hard constraints.
   - No calendar-grid, no agenda clone, no free/busy primary model, no heatmap analytics, no productivity rating, no calendar-density rating, no AI scheduling rating, no resource allocation chart, no red warning system.
3. Repair AMB-515 prompt score-language.
   - Replace legacy score wording in packet scope with rating-style wording.
   - Keep the packet aligned to Capacity/Preview Reflow/Receipt behavior from active product truth.
4. Record the owner-review boundary.
   - Add/update a minimal entry in `CHAMPION_MERGE_QUEUE.md` documenting this owner-review unblock and scope.

## Validation

- Run parallel implementation guard pre for this owner-review batch.
- Run parallel implementation guard pre for `AMB-515` with the repaired prompt.
- If available, run champion coverage validation for the owner-review batch context.
- Run `git diff --check`.

## Non-Goals

- Do not run Time implementation work.
- Do not run simulator/device tests.
- Do not claim screenshot, accessibility traversal, performance, privacy/legal, TestFlight, App Store, CI, or release proof.
