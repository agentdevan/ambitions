# LDI08 Requirement Graph Runtime Report

Date: 2026-05-07
Status: Green with non-blocking Yellow advisories

## Source Truth Read

- `README.md`
- `AGENTS.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batches/LDI08_Requirement_Graph_Runtime_Prompt.md`
- `docs/canon/AmbitionsOS_Living_Dream_System_Map.md`
- `docs/canon/AmbitionsOS_Living_Plan_Recompiler.md`
- `.codex/skills/living-dream-architect.md`
- `.codex/skills/source-claim-graph-architect.md`
- `.codex/skills/pack-supply-chain-security-reviewer.md`
- `.codex/review-boards/source-claim-pack-security-review-board.md`

## Owner Map

- Production owner file: `Native/Ambitions/Domain/AmbitionsOSLivingDreamRequirementGraphModels.swift`
- Test owner file: `Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamRequirementGraphModelsTests.swift`
- Audit owner file: `docs/audits/ldi08-requirement-graph-runtime-report.md`
- Status owners: README, current state, registry, context, global order, and LDI train docs updated to point from LDI08 complete to LDI09 next.

## Files Changed

- `Native/Ambitions/Domain/AmbitionsOSLivingDreamRequirementGraphModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamRequirementGraphModelsTests.swift`
- `docs/audits/ldi08-requirement-graph-runtime-report.md`
- `README.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `docs/codex/LDI_DEPENDENCY_GRAPH.md`
- `docs/codex/LDI_BATCH_GATE_MATRIX.md`
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md`
- `docs/codex/AMBITIONSOS_AOS_RELEASE_CLAIM_BOUNDARY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Implementation Evidence

LDI08 adds a local value-model requirement graph contract for hard, soft,
blocker, dependency, proof-needed, source-needed, and review requirements. The
validator blocks malformed or duplicate requirements, missing or unsatisfied
dependencies, missing source claims, invalid source-claim graphs, untrusted
pack-security envelopes, unsatisfied hard requirements, open blockers, missing
proof, professional-boundary review gaps, non-value-model runtime boundaries,
user-data-server use, and activation.

The evaluation output remains non-activating and non-mutating. It can identify
ready requirements, blockers, and proof-needed nodes, but it does not create,
schedule, or change user commitments.

## Validation

- `git status --short` before edits: clean except LDI08 untracked owner files.
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/ambitions-ldi08-proof -only-testing:AmbitionsTests/AmbitionsOSLivingDreamRequirementGraphModelsTests`
- Focused test result: 6 tests, 0 failures.
- Proof artifact: `/tmp/ambitions-ldi08-proof/Logs/Test/Test-Ambitions-2026.05.07_13-30-26--0400.xcresult`

Final gate checks are recorded in the commit closeout and current run-state after this report is staged.

Additional local checks:

- `git status --short`: expected LDI08 owner/status files changed before commit.
- `test ! -d .github/workflows`: passed.
- `git diff --check`: passed.
- `scripts/ldi-gate-check.sh || true`: passed.
- `scripts/ldi-release-claim-scan.sh || true`: passed.
- `scripts/ldi-handling-lane-scan.sh || true`: passed.
- `python3 scripts/ldi-source-pack-schema-check.py || true`: passed.
- `python3 scripts/ldi-safety-redteam-fixture-check.py || true`: passed.
- `python3 scripts/ldi-pack-supply-chain-scan.py || true`: passed.
- `scripts/global-train-next-batch.sh || true`: selected LDI09.
- `scripts/run-doc-qa.sh || true`: completed with existing advisory
  stale-guidance, deprecated-language, markdownlint, and one-redirect lychee
  findings; no LDI08-specific hard Red was introduced.
- `scripts/batch-train-gate-check.sh || true`: advisory working-tree hint before
  commit; no hard gate failure.

## Claim Boundary

This batch does not claim UI integration, route or raw-value changes,
persistence/schema changes, sync/cloud behavior, hosted AI, user-data server,
professional advice, official requirement verification, source-pack
certification, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility proof, legal/privacy compliance, or
full Living Dream runtime behavior.

## Hosted Workflow Proof

`.github/workflows` remains absent. No workflow YAML, hosted CI dependency,
GitHub Actions proof, Actions artifact proof, or hosted-CI validation was added
or used. Validation evidence is local/Codex-operated only.

## Yellow Advisories

- Owner: LDI09 implementer. Reason: eligibility, deadline, age/date/window, and
  minimum-lead-time logic are the next batch and are not proven by LDI08.
  Follow-up: run LDI09 from its prompt. Recheck condition: LDI09 local contracts
  and focused tests pass and the registry/current-state docs point onward.
- Owner: Codex local machine. Reason: local disk space remains tight after
  Xcode proof generation. Follow-up: remove `/tmp/ambitions-ldi08-proof` after
  commit/push. Recheck condition: `df -h /` shows enough free space for the
  next focused proof run.

## Red Repairs

None.

## Rollback Path

Revert only the LDI08 owner files, this report, and the narrow status-pointer
updates. Preserve LDI01-LDI07 completed history and the FIO01/PFC05A/DPTG00
hosted-workflow removal and terminal-device governance overlay.

## Next Eligible Batch

LDI09 Eligibility And Deadline Runtime.
