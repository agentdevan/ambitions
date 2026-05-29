<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FE-BE-INTEGRATED-PROOF-99

## Batch Identity

- Batch ID: `AMB-FE-BE-INTEGRATED-PROOF-99`
- Objective: prove the local FE/BE integration themes, including different plans under different local constraints, Start Here and Reality Meridian backend projections, proof/freshness basis, closure receipt, protected-time safety, replay, exact IA, and privacy/local-only posture.
- Stage: docs/handoff

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/batch-trains/amb-fe-be/`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `Native/Ambitions/`
- `Sources/`
- `AppUI/Sources/`

Frontend authority is mandatory for any UI/source-facing proof claim in this batch.
Consume the Encyclopedia Frontend OS before citing SwiftUI, source-facing UI, or surface proof:

- `ENCYCLOPEDIA_TO_FRONTEND_OS`
- `frontend-authority-packet`
- `frontend-authority-preflight`
- `build/reports/frontend-authority-packets`
- `build/reports/frontend-authority-preflight`

Surface ID: `today_root_reality_meridian`
Surface ID: `goals_root_constellation_atlas`
Surface ID: `capture_root_atmosphere_composer`
Surface ID: `time_root_lifeshape_field`
Surface ID: `you_root_user_system_profile`

## Allowed Scope

- Final report and proof-packaging files only.
- No new implementation beyond what earlier batches already own.

## Forbidden Scope

- No release readiness claim without current evidence.
- No device proof claim without device evidence.
- No app-source expansion.

## Expected Changes

- Summarize the local FE/BE integration proof honestly.
- Separate installed, validated, and still-unproven work.
- Record remaining Yellow or Red items precisely.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `make runner-access-check`
- `make batch-self-check`
- `make prompt-audit`
- `scripts/ambitions-codex-train.sh --help`
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`

## Visual Proof Expectations

- If this batch references UI proof, cite the exact preview/screenshot sources used.

## Accessibility Proof Expectations

- If this batch references UI proof, cite the exact accessibility evidence sources used.

## Hard Red Stop Conditions

- The report claims integrated proof that is not actually present.
- The report collapses active vs historical vs unproven status.
- The report weakens local-only or privacy posture.

## Rollback Expectations

- Remove only the report files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  AMB-FE-BE-INTEGRATED-PROOF-99 \
  prompts/batches/amb-fe-be/AMB-FE-BE-INTEGRATED-PROOF-99.md
```

## Final Report Format

- Status
- Summary
- Repo OS / Repo Doctor integration
- Files changed
- Installed train location
- Recommended next runner command
- Full recommended execution order
- Validation
- Classification
- Risks / blockers
- Worktree hygiene
- Rollback
- Next decision needed from user

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
