<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`BACKEND-FINAL-FORM-GREEN-REPAIR-01`

This prompt is intended to run through `scripts/ambitions-codex-train.sh` or `make batch`. Do not paste this directly into Codex unless the owner explicitly says: `bypass the Ambitions runner`.

# Objective

Repair the rejected Yellow result from `BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01` and finish the backend/human-code final-form standard.

The prior batch made useful backend progress but did not satisfy the owner standard because:

- it closed as `Status: YELLOW` instead of `STATUS: GREEN` or `STATUS: HARD RED`;
- the human-code-quality gate still reported 317 warnings;
- oversized/module-boundary files were treated as review items instead of final-form repairs;
- the human-senior-code claim was not yet credible.

This batch must not stop until the human senior final-form claim is credible, or until an unrecoverable Hard Red makes that impossible without violating safety, truth, or scope.

Green means the app source and tests no longer look batch/prompt/Codex-built under normal senior iOS code review. The codebase should read as if it was maintained by a world-class human senior native iOS/backend team.

# Non-Negotiable Owner Requirement

Resolve all 317 prior human-code-quality warnings with highest-quality solutions.

Resolving means one of:

1. repair the source/test issue directly;
2. extract/refactor the file or module safely;
3. update the human-code-quality gate so a previous false-positive no longer appears because the gate now encodes a precise, documented, non-warning exception;
4. document a generated-source exception in the gate and suppress it from warning output, not merely leave it as a warning;
5. convert a real blocker into a Hard Red if it cannot be fixed safely in this batch.

Do not leave known warnings as advisory backlog. For this batch, final Green requires:

```text
blocking_findings: 0
warnings: 0
```

for `scripts/ambitions-human-code-quality-gate.py` over its configured app/test/source roots.

# Dirty Worktree Policy

The owner is working multiple tasks at once. A dirty worktree is not by itself a blocker for this batch.

Rules:

- Preserve unrelated dirty/untracked work.
- Do not revert or clean unrelated files.
- Do not use global hard reset.
- Exact-path stage/commit only this batch's files if committing.
- Final Green may be reached with unrelated dirty worktree present, provided this batch's own changed paths are known, validated, and path-limited.
- If unrelated dirty files prevent validation from running, identify the exact files and either avoid them safely or classify as Hard Red only if there is no safe path.

# Active Source Truth To Inspect First

Read before editing:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
project.yml
Package.swift
prompts/batches/BACKEND-FINAL-FORM-LOCAL-FIRST-HUMAN-01.md
docs/audits/backend-final-form-local-first-human-01-report.md
docs/audits/backend-final-form-human-code-review.md
scripts/ambitions-human-code-quality-gate.py
docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md
.codex/state/active-batch.yml
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
Native/Ambitions/
Native/AmbitionsTests/
Native/AmbitionsWidgetExtension/
Native/AmbitionsShareExtension/
Sources/
AppUI/Sources/
```

Live source/project/test evidence wins over stale docs and prior batch reports.

# Facts To Preserve

- Active top-level IA is exactly `Today / Goals / Capture / Time / You`.
- Plan is not a top-level destination.
- Internal Plan/Profile/Captures compatibility seams may remain only when current source needs them and they do not leak as user-facing drift.
- Core backend remains local-first and SwiftData-backed.
- Core intelligence remains deterministic, inspectable, privacy-safe, and local-first.
- External/cloud LLMs are not core architecture.
- No custom hosted personal-data backend is allowed.
- Current sync posture remains local-only / unavailable.
- CloudKit is future optional Apple-native sync only; do not enable it.
- SA18 remains complete / Accepted Yellow / do-not-rerun.
- SA19 remains next eligible unless live source proves newer completed state.
- Release, device, accessibility, performance, privacy/legal, App Store, and TestFlight claims require current proof.

# Required End State

This batch is Green only if all are true:

1. `backend-final-form-local-first-human-01-report.md` no longer leaves final status as Yellow. It is superseded by this repair report.
2. `docs/audits/backend-final-form-green-repair-01-report.md` exists and says `STATUS: GREEN` or `STATUS: HARD RED`.
3. `docs/audits/backend-final-form-human-code-review.md` is updated with the repaired verdict.
4. `scripts/ambitions-human-code-quality-gate.py` returns exit 0.
5. The human-code-quality gate output reports `blocking_findings: 0` and `warnings: 0`.
6. Large-file/module-boundary findings from the prior report are either fixed by extraction/refactor or eliminated by precise generated/owned exceptions that do not appear as warnings.
7. Prompt/process/Codex residue is absent from app runtime source and app tests unless it is a precise, justified test fixture and not reported by the gate.
8. Stale user-facing Plan/Profile wording is repaired or moved behind a precise compatibility exception that does not report as warning.
9. Generated-source comments are handled as known generated-source exceptions and do not report as warnings.
10. Forbidden backend/provider terms are absent from runtime source or suppressed only as precise guardrail exceptions with zero warnings.
11. No new overbroad generic abstractions are introduced.
12. No tests are deleted or weakened to pass.
13. Backend validation from the prior final-form pass remains intact or is rerun if touched.
14. CloudKit remains unimplemented.
15. Unrelated dirty worktree is preserved and not used as a false Yellow excuse.

# Operating Loop

Run repair cycles until Green:

1. Record baseline branch, HEAD, and dirty paths.
2. Run `python3 scripts/ambitions-human-code-quality-gate.py` and capture every warning/blocker.
3. Classify each finding:
   - true source defect;
   - true test defect;
   - file-size/module-boundary defect;
   - generated-source false positive;
   - compatibility-seam false positive;
   - forbidden-term guardrail false positive;
   - stale gate logic;
   - unsafe-to-fix Hard Red.
4. Repair true defects with source/test changes.
5. Repair stale gate logic with precise rule improvements, not blanket ignores.
6. Extract/refactor oversized/module-confused files when the warning is real.
7. Rerun the gate.
8. Repeat until `warnings: 0` and `blocking_findings: 0`.
9. Rerun relevant focused tests for every touched source/test area.
10. Update reports.
11. Stop only on Green or Hard Red.

Do not stop at audit-only findings. Repair them.

# Allowed Scope

## Phase 0 — Baseline and Prior Yellow Review

Record:

```bash
git status --short --branch
git rev-parse HEAD
```

Read and explicitly audit:

```text
docs/audits/backend-final-form-local-first-human-01-report.md
docs/audits/backend-final-form-human-code-review.md
scripts/ambitions-human-code-quality-gate.py
```

Create:

```text
docs/audits/backend-final-form-green-repair-01-report.md
```

The report must be updated throughout the run.

## Phase 1 — Human-Code-Quality Gate Redesign

Upgrade `scripts/ambitions-human-code-quality-gate.py` so it is suitable for final-form review.

Requirements:

- Gate must end with zero warnings and zero blockers to pass.
- Gate must not use warning backlog as a success condition.
- Gate must distinguish:
  - app runtime source;
  - app tests;
  - generated source;
  - preview-only source;
  - compatibility tests;
  - guardrail constants;
  - docs outside scan roots.
- Gate must include precise path/category exceptions for generated token files and known compatibility seams only when those exceptions are documented in the script/report.
- Gate must not blanket-ignore whole directories unless they are truly generated/non-runtime and documented.
- Gate must fail on new high-signal process residue.
- Gate must fail on direct SwiftData leakage outside allowed persistence/test persistence boundaries.
- Gate must fail on forbidden backend/provider runtime dependencies.
- Gate must fail on unowned TODO/FIXME/HACK in app runtime source.
- Gate must fail on oversized files above the fail threshold unless that file is in a documented generated-source exception.
- Gate must be deterministic and readable.

Expected output format must include:

```text
scanned_files: <n>
blocking_findings: 0
warnings: 0
GREEN: no human-code-quality findings
```

## Phase 2 — Resolve All Existing Warnings

Run the gate and repair every finding until none remain.

Known prior warning classes:

- file-size concentration;
- product prompt terminology false positives;
- stale Plan/Profile wording in tests/compatibility seams;
- generated comments;
- process words such as batch/runner/Codex in runtime/test source;
- guardrail strings for CloudKit/iCloud/provider terms;
- generic type/file naming;
- direct SwiftData import scan boundaries;
- oversized app/domain/test files.

Repair principles:

- Prefer source extraction/refactor for real oversized/module-boundary problems.
- Prefer clearer names over allowlists for generic naming problems.
- Prefer deleting or rewriting process-language comments/strings where they are not product/runtime truth.
- Prefer test renaming or fixture clarification where test names read prompt-built.
- Prefer gate exceptions only for precise generated/compatibility/guardrail cases.
- Do not use broad suppressions that hide future regressions.

## Phase 3 — Module-Boundary/File-Size Final Form

The prior report listed large files as accepted review items. This batch must not leave them as unresolved warnings.

At minimum inspect and resolve:

```text
Native/Ambitions/Domain/ActionClosureReceiptModels.swift
Native/Ambitions/Domain/AmbitionGraphModels.swift
Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift
Native/Ambitions/App/AppShellView.swift
Sources/Accessibility/AccessibilityNutrition.swift
Sources/Theme/AmbitionTheme.swift
```

Resolution options:

1. Extract into smaller, coherent, human-named files with focused tests.
2. Move generated/token source into a generated-source exception and suppress it from warning output if it is truly generated/token-like.
3. Split tests/helpers if the warning is test fixture concentration.
4. If extraction is unsafe because of active unrelated work, create a Hard Red rather than closing Yellow.

Do not merely document as future work if the gate still reports a warning.

## Phase 4 — Runtime/Test Language Cleanup

Remove or repair any app runtime/test language that makes the repo look prompt-built.

Forbidden in app runtime source unless part of a documented guardrail exception and not emitted as a warning:

```text
Codex
batch
prompt
runner
closeout
Accepted Yellow
Green closeout
Phase 01
Phase 02
Phase 03
Phase 04
```

Repair by:

- rewriting comments to product/engineering language;
- renaming test helpers to domain terms;
- moving process trace language out of app/test source and into docs/audits only;
- using precise compatibility naming where necessary.

## Phase 5 — Compatibility Copy Cleanup

Repair stale user-facing Plan/Profile copy wherever current product truth requires Time/You.

Allowed internal compatibility terms may remain only when:

- path/type/route compatibility requires them;
- they are not user-facing copy;
- they are not reported by the gate;
- the report documents why they remain.

If tests intentionally assert compatibility seams, name them as compatibility tests and suppress only those precise findings.

## Phase 6 — Backend/CloudKit Guardrail Cleanup

Ensure forbidden backend/provider terms are handled correctly.

- No Supabase/Firebase/Postgres/OpenAI/ChatGPT/LLM/analytics/telemetry runtime dependency.
- No CloudKit implementation.
- No CKContainer / NSUbiquitous runtime usage.
- CloudKit/iCloud may appear only in the architecture readiness gate, no-claim docs, or precise guardrail tests/scripts.
- App runtime source must not import or instantiate CloudKit.

Run scans and repair until zero gate warnings remain.

## Phase 7 — Test And Build Revalidation

Run relevant tests for each touched area.

At minimum:

```bash
git diff --check
xcodegen generate
make batch-self-check
make prompt-audit
python3 scripts/ambitions-source-atlas-title-check.py --strict
python3 scripts/ambitions-human-code-quality-gate.py
```

If backend/runtime source or tests were touched, rerun affected focused tests.

Required if any touched files overlap prior final-form backend areas:

```bash
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/PersistenceRepositoryTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/EventLedgerRepositoryTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/StorageSchemaVersionLedgerTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/StorageMigrationPlanScaffoldTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/PreMigrationBackupTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/PortableRestoreRollbackTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/PortableSnapshotServiceTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/SyncCapabilityTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/AmbitionsCommandModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/SafeAutomationPolicyModelsTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/PolicyGuardedCommandExecutorTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/AmbitionsCommandExecutorTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/TodayDerivedReadModelCacheTests
scripts/ambitions-xcode-validate.sh --batch BACKEND-FINAL-FORM-GREEN-REPAIR-01 --lane focused-test --test AmbitionsTests/ProfileFeatureServiceTests
```

If shell `xcodebuild` is blocked by the environment, use available repo wrapper or XcodeBuildMCP, and record the exact proof path. Do not use environment policy as a Yellow excuse if an available proof path exists.

## Phase 8 — Report Final Human-Senior Verdict

Update:

```text
docs/audits/backend-final-form-human-code-review.md
docs/audits/backend-final-form-green-repair-01-report.md
```

The reports must include:

- starting commit;
- branch;
- dirty worktree policy and unrelated dirty preservation;
- warning categories found;
- every category's resolution;
- files extracted/refactored;
- generated-source exceptions;
- compatibility exceptions;
- guardrail exceptions;
- final gate output with `warnings: 0` and `blocking_findings: 0`;
- validation commands and exit codes;
- tests run;
- claims not made;
- rollback path;
- final status.

# Forbidden Scope

- Do not replace SwiftData.
- Do not add Realm, GRDB, raw SQLite, manual Core Data replacement, Supabase, Firebase, Postgres, or hosted backend.
- Do not enable CloudKit.
- Do not add iCloud entitlements.
- Do not add CloudKit container config.
- Do not add external/cloud LLM runtime.
- Do not add OpenAI/API dependency.
- Do not add analytics, telemetry, crash SDK, or user-data server.
- Do not change top-level IA.
- Do not restore Plan as a user-facing top-level tab.
- Do not broad-rename Plan/Profile compatibility seams without migration proof.
- Do not delete tests to pass.
- Do not weaken tests to pass.
- Do not hide compile errors.
- Do not fake build/test/device/accessibility/performance/privacy/legal/release proof.
- Do not close Yellow.
- Do not claim CloudKit sync works.
- Do not claim global train completion.
- Do not claim App Store/TestFlight readiness.
- Do not claim physical-device validation.
- Do not claim public accessibility conformance.
- Do not use broad gate allowlists to hide real defects.
- Do not use unrelated dirty worktree as a reason to stop Yellow.

# Hard Red Stop Conditions

Stop only if unrecoverable after bounded repair attempts:

- a warning cannot be resolved without unsafe broad rewrite;
- extraction would conflict with unrelated dirty owner work and no safe path exists;
- tests must be weakened or deleted to pass;
- CloudKit/iCloud sync would need to be enabled to satisfy a finding;
- schema mutation would be required without migration/backup/restore proof;
- top-level IA would need to change;
- a required validation cannot run through any available proof path;
- source cannot build because of an external toolchain problem that cannot be repaired in repo;
- continuing would risk data loss or unrelated user work loss.

If Hard Red occurs, report exact cause, touched files, rollback, and why Green is impossible safely.

# Required Final Status Language

The final repair report must say exactly one of:

```text
STATUS: GREEN
```

or:

```text
STATUS: HARD RED
```

Do not close Yellow.

# Rollback Expectations

Use path-limited rollback only.

Record this before edits:

```bash
git status --short --branch
git rev-parse HEAD
```

Never use hard reset unless explicitly authorized.

Never discard unrelated user work.

# Runner Command

```bash
scripts/ambitions-codex-train.sh BACKEND-FINAL-FORM-GREEN-REPAIR-01 prompts/batches/BACKEND-FINAL-FORM-GREEN-REPAIR-01.md
```

or:

```bash
make batch BATCH=BACKEND-FINAL-FORM-GREEN-REPAIR-01 PROMPT=prompts/batches/BACKEND-FINAL-FORM-GREEN-REPAIR-01.md
```
