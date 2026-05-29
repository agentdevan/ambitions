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

# Batch ALIGN-01-NAMING: Foundation Alignment (Naming & IA)

## Goal
Align internal source names with the active Product Design Truth IA (`Today / Goals / Capture / Time / You`).

## Truth Files
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Instructions
1. **Phase 1: Tab & Route Alignment**
   - Modify `Native/Ambitions/App/AppTab.swift`:
     - Rename enum cases: `plan` -> `time`, `profile` -> `you`, `captures` -> `capture`.
     - Update all switches and usages within this file.
   - Update `Native/Ambitions/App/AmbitionsRootView.swift` to handle the renamed cases.

2. **Phase 2: Folder & File Migration**
   - Rename:
     - `Native/Ambitions/Features/Plan` -> `Native/Ambitions/Features/Time`
     - `Native/Ambitions/Features/Profile` -> `Native/Ambitions/Features/You`
     - `Native/Ambitions/Features/Captures` -> `Native/Ambitions/Features/Capture`
   - Rename primary screen files:
     - `Native/Ambitions/Features/Plan/PlanScreen.swift` -> `Native/Ambitions/Features/Time/TimeScreen.swift`
     - `Native/Ambitions/Features/Profile/ProfileScreen.swift` -> `Native/Ambitions/Features/You/YouScreen.swift`

3. **Phase 3: Internal Symbol Refactoring**
   - Refactor `PlanScreen` -> `TimeScreen` and `ProfileScreen` -> `YouScreen`.
   - Update all references in the project.

4. **Phase 4: Validation**
   - Run `xcodegen generate` to verify project configuration.
   - Run `scripts/build-local.sh` to ensure the app compiles.
   - Run UI tests to confirm navigation.

## Non-claims
- No claim of full visual completion.
- No claim of performance validation.
- No claim of App Store readiness.

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
