<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-duplicate_stable_id-46473867, AMB28-same_source_file_targeted_by_multiple_active_batches-11451796, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-35842317, AMB28-same_source_file_targeted_by_multiple_active_batches-81952898, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

# AMB-FILE-BY-FILE-REPO-AUDIT-01

## Batch ID
AMB-FILE-BY-FILE-REPO-AUDIT-01

## Runner command
scripts/ambitions-codex-train.sh AMB-FILE-BY-FILE-REPO-AUDIT-01 prompts/batches/AMB-FILE-BY-FILE-REPO-AUDIT-01.md

## Objective
Perform a complete file-by-file audit of the entire Ambitions repo. This is an audit-only batch. Do not modify product source. Do not delete, rename, refactor, or rewrite implementation files.

The audit must classify every tracked file by role, current authority, implementation value, risk, and recommended action, then write generated audit artifacts under `docs/audits/` and `build/reports/`.

## Prime directive
Audit every tracked file and preserve Ambitions active truth:

- Ambitions is a native iPhone-first Personal Life OS.
- Top-level IA is `Today / Goals / Capture / Time / You`.
- The Private Life Runtime owns decision truth.
- Frontend renders projection truth and must not invent runtime truth.
- External/cloud LLMs are not core architecture.
- Local-first/privacy/trust proof must not be overstated.
- Docs-only plans never prove implementation.
- Green requires evidence, not intent.

## Active source truth to inspect
Inspect in this order before classification:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `docs/status/current-implementation-map.md`
9. `AGENTS.md`
10. `README.md`
11. `project.yml`
12. `Package.swift`
13. `Native/`
14. `Sources/`
15. `AppUI/`
16. `scripts/`
17. `docs/`
18. `prompts/`
19. `.codex/`
20. `.agents/`

## Required first actions
Run or perform equivalent local enumeration:

```bash
git status --short
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
mkdir -p build/audits build/reports docs/audits
git ls-files > build/audits/amb-file-audit-tracked-files.txt
find . -type f \
  -not -path './.git/*' \
  -not -path './build/*' \
  -not -path './output/*' \
  -not -path './DerivedData/*' \
  > build/audits/amb-file-audit-all-files.txt
```

## Allowed scope
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.csv`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-reds.md`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-yellows.md`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-truth-drift.md`
- Create or update `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-cleanup-plan.md`
- Create or update `build/reports/amb-file-by-file-audit-summary.json`
- Create or update generated enumeration files under `build/audits/`
- Add small standard-library audit helper scripts only if necessary to finish complete enumeration.

## Forbidden scope
- Do not modify production source.
- Do not modify Xcode project or package config except for read-only validation side effects caused by existing tools.
- Do not delete, rename, move, or refactor files.
- Do not create new product object folders.
- Do not mark release, accessibility, privacy, build, runtime, simulator, device, CI, TestFlight, or App Store claims Green unless current evidence proves them.
- Do not treat docs-only plans as implementation proof.
- Do not revive `Plan`, `Habits`, `Insights`, or `Profile` as active root IA.
- Do not introduce cloud LLMs, analytics SDKs, custom backend dependencies, or fake proof.
- Do not commit `.codex/runs/` noise.

## Implementation requirements
For every path from `git ls-files`, create one CSV row with these columns:

```text
path
extension
top_level_area
owner_area
file_kind
authority_class
implementation_class
surface_or_system
active_status
risk_level
line_count
imports_or_dependencies
declared_types_or_headings
uses_legacy_language
uses_forbidden_architecture
contains_user_facing_copy
contains_runtime_truth
contains_ui_truth
contains_release_claims
contains_validation_logic
contains_generated_or_stale_artifact_risk
recommended_action
reason
```

Use these `top_level_area` values only:

```text
Native app
Design system package
Widget UI package
Tests
Scripts
Project config
Truth docs
Status docs
Canon docs
Codex governance
Prompts
Audit/report artifact
Generated/build artifact
Agent skill
External/historical
Unknown
```

Use these `authority_class` values only:

```text
active_source_truth
active_product_truth
active_implementation_truth
active_release_truth
active_codex_process_truth
live_source
live_test
live_script
live_project_config
supporting_doc
historical_doc
prompt_only
generated_report
archive_candidate
delete_candidate
unknown
```

Use these `implementation_class` values only:

```text
source_present
configured
wired
scaffolded
preview_backed
validation_tool
test_source
docs_only
historical_only
generated_only
unproven
not_applicable
unknown
```

Use these `active_status` values only:

```text
active
supporting
historical
obsolete
conflicting
archive_candidate
delete_candidate
unknown
```

Use these `risk_level` values only:

```text
Green
Yellow
Red
```

Green means retain and the role is clear. Yellow means useful but needs classification, migration, validation, extraction, or proof. Red means the file risks false claims, architecture drift, forbidden dependencies, active IA drift, release overclaim, duplicated truth, stale implementation guidance, generated artifacts in active paths, or frontend decision truth not bound to runtime/projection contracts.

## Swift file checks
For Swift files:

- list all `struct`, `class`, `enum`, `actor`, and `protocol` declarations
- mark files over 350 lines
- detect SwiftUI `View` files
- detect direct color/material/spacing literals
- detect duplicated UI primitives
- detect user-facing legacy labels: `Plan`, `Profile`, `Habits`, `Insights`, `Hero Step`, `Recommended step`, `Focus`
- detect runtime truth being invented in frontend
- detect external/cloud/backend/LLM dependency risk
- detect TODO/FIXME/temporary compatibility seams
- detect preview-only behavior being treated as implementation

## Docs checks
For docs:

- classify active vs supporting vs historical
- detect claims of implemented, complete, release-ready, validated, App Store ready, TestFlight ready, CI passing, or screenshot ready
- detect old IA language
- detect cloud/server/AI/provider assumptions
- detect duplicate canon or conflicting authority
- detect generated report cruft that should not guide implementation

## Scripts checks
For scripts:

- classify validation, runner, report, migration, cleanup, generation, or support role
- detect duplicate validators
- detect validators that report Green from weak evidence
- detect scripts writing into source unexpectedly
- detect missing exit-code discipline
- detect missing generated artifact path policy

## Prompts checks
For prompts:

- classify active installer, historical prompt, batch prompt, or archive candidate
- detect duplicate batch IDs
- detect missing runner header
- detect prompts that bypass active truth
- detect prompts that ask for fake proof
- detect direct execution drift

## Project/package/config checks
For project/package/config:

- verify source roots match actual folders
- verify targets match project truth
- verify package paths are sane
- verify no accidental generated project source-of-truth inversion
- verify no hidden cloud/backend dependency

## Required output artifacts
Create:

- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.md`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01.csv`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-reds.md`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-yellows.md`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-truth-drift.md`
- `docs/audits/AMB-FILE-BY-FILE-REPO-AUDIT-01-cleanup-plan.md`
- `build/reports/amb-file-by-file-audit-summary.json`

## Required report structure
`AMB-FILE-BY-FILE-REPO-AUDIT-01.md` must include:

1. Executive verdict
2. Current branch/SHA/status
3. File counts by top-level folder
4. File counts by authority class
5. File counts by implementation class
6. File counts by Green/Yellow/Red
7. Top 25 Red files
8. Top 50 Yellow files
9. UI sprawl findings
10. Runtime/proof/trust findings
11. Docs/canon/history sprawl findings
12. Prompt/Codex governance findings
13. Build/project/test findings
14. Files that should be retained
15. Files that should be extracted/refactored
16. Files that should be demoted to historical
17. Files that should be archive candidates
18. Files that are delete candidates, if any
19. Exact next remediation trains
20. Acceptance gates

## UI sprawl sub-audit
Produce `AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md` with:

- all SwiftUI View files
- View files over 350 lines
- reusable primitives embedded in feature files
- direct color/material/spacing literals by file
- Reality Meridian files
- Start Here files
- Receipt/proof files
- Closure files
- LifeShape files
- Constellation Atlas files
- Atmosphere Composer files
- User System Profile files
- missing expected folders
- recommended extraction train

Evaluate these expected final-state object folders without creating them:

```text
Native/Ambitions/Features/Today/RealityMeridian/
Native/Ambitions/Features/Today/StartHere/
Native/Ambitions/Features/Today/ProofTrail/
Native/Ambitions/Features/Today/ReceiptDrawer/
Native/Ambitions/Features/Today/Closure/
Native/Ambitions/Features/Goals/ConstellationAtlas/
Native/Ambitions/Features/Capture/AtmosphereComposer/
Native/Ambitions/Features/Time/LifeShapeField/
Native/Ambitions/Features/You/UserSystemProfile/
Native/Ambitions/Features/You/TrustConsole/
Native/Ambitions/UI/Chrome/
Native/Ambitions/UI/Materials/
Native/Ambitions/UI/Motion/
Native/Ambitions/UI/Haptics/
Native/Ambitions/UI/PreviewSupport/
Native/Ambitions/UI/Accessibility/
```

## Validation expectations
Run as available, and record exact status/reason:

```bash
python3 scripts/ambitions_validate_prompt_headers.py || true
python3 scripts/ambitions_validate_batch_ids.py || true
python3 scripts/ambitions_codex_os_validate.py || true
xcodegen generate || true
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies || true
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO || true
```

If a command is unavailable, record command, status `unavailable`, reason, and next action. Do not fake success.

## Visual proof expectations
This is an audit-only batch. UI sprawl analysis is required, but no UI screenshots are required unless an existing screenshot pipeline is safe and available. Do not mark screenshot readiness Green without screenshot identity and proof.

## Accessibility expectations
Audit accessibility risk and evidence boundaries. Do not mark accessibility Green from intent. Preserve distinction between source-present, preview-backed, validated, and release-proven.

## Privacy / trust expectations
Audit local-first, privacy, trust, receipt, export/delete/reset, memory controls, network dependency, analytics, and cloud AI claim risks. Do not upgrade any claim without evidence.

## Continuity expectations
Audit iCloud/CloudKit, restore, conflict, migration, offline queue, and continuity claim risks. Do not mark sync/restore/continuity complete without conflict/restore/migration/source-freshness proof.

## Hard Red stop conditions
Stop and report Red if:

- complete tracked-file enumeration cannot finish
- generated artifacts cannot be written under allowed paths
- production source would need modification
- a required audit artifact cannot be created
- every tracked file cannot receive a CSV row
- active truth conflict cannot be classified
- validation command results cannot be honestly recorded

If enumeration cannot finish, include the last processed file and resume instructions.

## Rollback expectations
Rollback must be limited to generated audit artifacts, this prompt file if needed, and any optional helper script created for this audit. Do not use destructive reset commands in the final report.

## Acceptance gates
The audit is Green only if:

- every tracked file has a CSV row
- every Red file has a reason
- every Yellow file has a recommended action
- every active truth conflict is called out
- every source-present vs proven distinction is preserved
- UI sprawl is specifically analyzed
- generated artifacts are placed only under `docs/audits`, `build/audits`, or `build/reports`
- no production source is modified
- no release claim is upgraded
- no false Green is reported

## Expected final report format
AMB-FILE-BY-FILE-REPO-AUDIT-01 — Final Report

Status: Green / Yellow / Red

1. Summary
2. Files audited
3. Red count
4. Yellow count
5. Green count
6. Generated artifacts
7. Validation commands run
8. Validation outputs
9. Top 10 highest-risk findings
10. Source truth inspected
11. UI sprawl status
12. Runtime/proof/trust status
13. Prompt/Codex governance status
14. Build/project/test status
15. Files created
16. Files modified
17. Hard Red checks
18. Rollback instructions
19. Known Yellow items
20. Known Red items
21. Next recommended train

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
