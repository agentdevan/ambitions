<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-duplicate_stable_id-50777356, AMB28-same_source_file_targeted_by_multiple_active_batches-11451796, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-35842317, AMB28-same_source_file_targeted_by_multiple_active_batches-81952898, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01

Operate in `agentdevan/ambitions` on `main`. This is the master installer for a staged, evidence-bound repo reset toward controlled Green. Do not create branches. Do not commit automatically unless runner/session policy explicitly allows it. Do not claim release/build/test/accessibility/performance proof without current evidence.

## Product Truth

Ambitions is a premium native iPhone-first, local-first Personal Life OS. It is not a task app, habit tracker, calendar clone, chatbot, generic surface, generic AI app, generic productivity UI, SaaS admin panel, or SwiftUI demo.

Locked top-level IA is exactly:

```text
Today / Goals / Capture / Time / You
```

Primary top-level objects are exactly:

```text
Today   -> Reality Meridian
Goals   -> Constellation Atlas
Capture -> Atmosphere Composer
Time    -> LifeShape Field
You     -> User System Profile
```

Core moat: the Private Life Runtime locally and deterministically converts goals/intent into personalized, inspectable, capacity-aware daily steps, then adapts through time reality, closure, proof, and recovery.

External/cloud LLMs and custom hosted personal-data backends are not core architecture. R2 may only be public, non-personal, read-only freshness/reference material if explicitly scoped later. Apple-native sync may be a future user-owned exception if explicitly scoped later.

## Required Read Order

Before planning, editing, moving, deleting, or generating child prompts, inspect:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`

Then inspect the current audit/proof state if present:

```text
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.csv
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-reds.md
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-yellows.md
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-truth-drift.md
docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-cleanup-plan.md
build/reports/amb-file-by-file-audit-summary.json
build/audits/amb-file-audit-tracked-files.txt
build/audits/amb_file_by_file_repo_audit.py
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/performance-budgets.md
```

If any file is absent, record absence. Do not invent evidence.

## Baseline Commands

Run and record:

```bash
git status --short
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
find scripts build/audits -maxdepth 2 -type f | sort
rg -n "ambitions_codex_os_validate|validate_prompt_headers|validate_batch_ids|forbidden-claim|claim-scan" scripts build docs .codex .agents prompts || true
python3 -m json.tool build/reports/amb-file-by-file-audit-summary.json >/tmp/amb-file-by-file-audit-summary.json || true
```

Run validators if present:

```bash
python3 scripts/ambitions_validate_prompt_headers.py
python3 scripts/ambitions_validate_batch_ids.py
python3 scripts/ambitions_codex_os_validate.py
```

Always run after each train:

```bash
git diff --check
git status --short
```

Run `xcodegen generate` after source/project config changes. Run package/build validation when the environment allows, and treat timeouts as Yellow/unproven.

## Work Model

Use train-sized changes. Do not attempt an unsafe mega-diff. Each train must record:

```text
train id
goal
scope
non-goals
files likely touched
files explicitly not touched
risk level
source/proof required
validation commands
rollback behavior
Green/Yellow/Red outcome criteria
closeout artifact
```

If a train hits Red, stop, isolate or rollback that train diff, and report. If a train hits accepted Yellow, record owner, reason, risk, next gate, and non-claim boundary before continuing.

## Context-Aware Vocabulary Reset

This is not a zero-token purge. `plan`, `habit`, `profile`, `insight`, and `capture` may remain when used as ordinary domain/user/model language. They must not remain as active IA, destination, route, feature owner, folder owner, shell navigation, top-level surface, visual recipe surface ID, or Codex batch/train owner.

Classify hits as:

```text
allowed_domain_language
allowed_user_copy
allowed_model_or_data_language
allowed_primary_object_language
forbidden_top_level_IA
forbidden_destination_owner
forbidden_route_owner
forbidden_feature_folder
forbidden_screen_type
forbidden_shell_navigation
forbidden_accessibility_identifier
forbidden_test_surface_name
forbidden_doc_front_door
forbidden_visual_surface_recipe
forbidden_codex_batch_owner
historical_reference_needs_rewrite_or_archive
```

Forbidden active ownership terms:

```text
Plan
Profile
Habits
Insights
Captures when used as active top-level/surface ownership instead of Capture
```

Allowed examples include `adjust plan`, `execution plan`, `planning model`, `habit pattern`, `habit history`, `user profile`, `profile data`, `User System Profile`, `personal insight`, and `proof insight`.

## Required Master Outputs

Create or update:

```text
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-train-manifest.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-ia-surface-vocabulary-ledger.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-authority-map.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-source-refactor-map.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-validation-proof.md
docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-final-green-report.md
build/reports/amb-repo-green-flagship-reset-master-01.json
```

The JSON must parse with:

```bash
python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-green-reset.json
```

The master report must separate: `source-present`, `configured`, `wired`, `scaffolded`, `preview-backed`, `tested`, `validated`, `unproven`, `not found`, `historical`, `supporting`, `deleted`, `moved`, `renamed`, and `deferred`.

## Required Train Sequence

Execute as far as the environment safely allows:

0. Snapshot, authority read, and train manifest.
1. Audit calibration and validator repair.
2. Active truth and authority repair.
3. Final IA/surface vocabulary ledger.
4. IA/surface vocabulary and route refactor.
5. Repo architecture organization map.
6. Codex OS governance baked-in reset.
7. Shared design system and UI primitive organization.
8. Today object extraction: Reality Meridian / Start Here / Closure / Receipts.
9. Goals object extraction: Constellation Atlas.
10. Capture object extraction: Atmosphere Composer.
11. Time object extraction: LifeShape Field.
12. You object extraction: User System Profile / Trust / Data Controls.
13. Private Life Runtime source/proof alignment.
14. Tests, previews, accessibility, and identifier repair.
15. Docs, visual encyclopedia, status, and historical pruning.
16. Validation harness and proof hardening.
17. Final tracked-file IA/surface scan.
18. Final repo Green report.

Split any train further if the diff becomes too broad. Do not start with a visual rewrite. Do not delete historical material unless `docs/truth/HISTORICAL_POLICY.md` extract/archive/delete gates are satisfied.

## Final JSON Shape

```json
{
  "batch_id": "AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01",
  "branch": "",
  "sha": "",
  "final_status": "",
  "trains_completed": [],
  "trains_yellow": [],
  "trains_red": [],
  "files_changed_count": 0,
  "files_moved_count": 0,
  "files_deleted_count": 0,
  "forbidden_paths_touched_unexpectedly": [],
  "surface_vocabulary": {
    "forbidden_surface_owner_hits_remaining": 0,
    "allowed_context_hits_remaining": 0,
    "ledger_path": "docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-ia-surface-vocabulary-ledger.md"
  },
  "validation": {
    "prompt_header_validator": "",
    "batch_id_validator": "",
    "codex_os_validator": "",
    "xcodegen_generate": "",
    "package_resolution": "",
    "simulator_build": "",
    "unit_tests": "",
    "ui_tests": "",
    "git_diff_check": "",
    "json_parse": ""
  },
  "non_claims": [
    "no release readiness claimed unless current proof exists",
    "no TestFlight readiness claimed unless current proof exists",
    "no App Store readiness claimed unless current proof exists",
    "no physical-device validation claimed unless current proof exists",
    "no public accessibility conformance claimed unless current proof exists",
    "no performance readiness claimed unless current proof exists",
    "no privacy/legal approval claimed unless current proof exists",
    "no complete Private Life Runtime proof claimed unless scenario tests pass"
  ]
}
```

## Stop Rules

Hard Red stop conditions include stale surface name remaining as active tab/route/feature/screen/shell/visual surface ID, active truth weakened, source changed without validation/rollback, build failure due refactor, tests deleted to hide failure, external/cloud LLM or custom backend introduced, release/build/test/accessibility/performance proof overclaimed, required validator missing while still expected, or missing/invalid JSON report.

Final output must be a controlled Green / accepted Yellow / Red report with exact evidence and non-claims.

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
