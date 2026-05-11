<!-- AMBITIONS_RUNNER_REQUIRED: true -->

<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->

<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# XCODE-BUILD-SYSTEM-MAX-01 - Ambitions Build Lab, Xcode Reliability, Validation Acceleration, And Global Train Throughput Upgrade

## Batch ID

XCODE-BUILD-SYSTEM-MAX-01

## Runner Command

```bash
scripts/ambitions-codex-train.sh XCODE-BUILD-SYSTEM-MAX-01 prompts/batches/XCODE-BUILD-SYSTEM-MAX-01.md
```

Equivalent:

```bash
make batch BATCH=XCODE-BUILD-SYSTEM-MAX-01 PROMPT=prompts/batches/XCODE-BUILD-SYSTEM-MAX-01.md
```

## Operating Mode

Run through the Ambitions runner only:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit
```

Direct Codex execution is forbidden unless the user explicitly bypasses the
Ambitions runner.

## Mandatory Precondition

This batch must not run while PK17 is in progress.

Before implementing changes, verify from repo truth that:

- PK17 Today Read Model Extraction is complete / Green or complete / valid
  Accepted Yellow with explicit proceed permission.
- PK17 final report exists.
- PK17 changes are committed.
- PK17 changes are pushed to origin/main.
- Local branch is clean or contains only this batch's newly started runner
  artifacts.
- PK18 remains the next product implementation batch after this tooling
  acceleration batch.

Expected verification commands:

```bash
git status --short --branch
git fetch origin main
git log --oneline -n 5
python3 scripts/ambitions-queue-snapshot.py || true
python3 scripts/ambitions-control-plane-check.py || true
grep -R "PK17" .codex/reports/current-batch-train-state.md docs/codex/BATCH_REGISTRY.md docs/audits 2>/dev/null || true
```

If PK17 is not complete and pushed:

1. Do not implement this batch.
2. Stop Red.
3. Create or update `docs/audits/xcode-build-system-max-report.md` only if
   needed to state that the batch was blocked by unfinished PK17.
4. Do not modify build tooling, prompts, or queue state.
5. Final response must say: `PK17 must close before XCODE-BUILD-SYSTEM-MAX-01 runs.`

## Queue Placement

This is a tooling acceleration batch inserted after PK17 and before PK18.

It must not renumber canonical queue IDs, mark PK18 complete, or change PK18's
product-implementation order.

After this batch closes Green, the next product implementation batch should
remain:

```text
PK18 Today Command Handler Extraction
```

Final report must explicitly state:

```text
PK17 remains complete.
PK18 remains the next product implementation batch.
XCODE-BUILD-SYSTEM-MAX-01 is a tooling acceleration batch inserted after PK17 to improve Xcode validation reliability and global train throughput.
No product behavior changed.
No queue IDs were renumbered.
No completed batches were reactivated.
```

## Objective

Upgrade Ambitions build and validation infrastructure before continuing from
PK18 through the remaining global train.

The system must become:

```text
faster
less simulator-dependent
resumable
diagnosable
locally reproducible
tool-version aware
DerivedData stable
test-plan aware
xcresult-backed
focused-test first
full-suite only at gates
UI/device proof only when required
safe for Codex autonomous execution
safe for ChatGPT planning review
safe for GitHub commit/rebase/push workflow
```

This batch is build-system, tooling, validation, playbook,
prompt-governance, and Codex-control-plane infrastructure only. It must not
change app product behavior.

## Active Source Truth To Inspect First

Inspect at least:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
.codex/state/global-train-attempt-ledger.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json
docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md
docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md
docs/audits/global-remaining-train-blueprint-report.md
docs/audits/pk17-batch-closeout-report.md
prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md
prompts/batches/PK17.md
prompts/batches/PK18.md through prompts/batches/PK41.md
project.yml
Package.swift
Native/**
Native/AmbitionsTests/**
Native/AmbitionsUITests/**
scripts/**
Makefile
.gitignore
```

Also inspect existing Xcode, XcodeGen, simulator, build, test, validation,
prompt-audit, final-report, and control-plane scripts.

## Allowed Scope

This batch may modify:

```text
scripts/**
docs/codex/**
docs/codex/playbooks/**
docs/audits/**
prompts/batches/**
prompts/templates/**
Makefile
Brewfile*
.mise.toml
.xcode-version
.gitignore
project.yml
Package.swift
Native/**/*.xctestplan
Native/**/TestPlans/**
```

Production source and project files are allowed only for build-system/test-plan
wiring when strictly necessary and non-behavioral.

## Forbidden Scope

Do not modify app behavior.

Forbidden unless required only for test-plan/build-lab wiring and explicitly
documented:

```text
Native/Ambitions/**/*.swift
Native/Ambitions/Features/**
Native/Ambitions/Services/**
Native/Ambitions/Persistence/**
Native/Ambitions/Domain/**
AppUI/**
Sources/**
.github/**
entitlements
signing
release artifacts
generated Xcode project files
```

Absolutely forbidden:

```text
top-level IA changes
restoring Plan as top-level destination
external/cloud LLM core behavior
telemetry/analytics addition
network/backend/sync/account behavior
TestFlight/App Store/device proof generation
release/readiness claims
broad repo cleanup
RHC broad cleanup pulled early
DPTG00 non-terminal sequencing
```

## Build-System Principles

Implement a tiered validation model:

```text
L0_NONE - docs/prompts/scripts/governance only; no Xcode.
L1_BUILD - production Swift changed but no simulator behavior required; build only.
L2_BUILD_FOR_TESTING - build test products once, no test execution yet.
L3_FOCUSED_TEST - targeted test class/function/suite with test-without-building where possible.
L4_SEGMENT_TEST - named test plan or train-segment suite after major train sections.
L5_FULL_TEST - full unit/integration suite only at major gates.
L6_UI_PROOF - simulator/UI/screenshot/accessibility proof for UI/FVQ/FET/PX/DPTG gates only.
L7_TERMINAL_DEVICE_PROOF - terminal DPTG/release candidate proof only after all pre-device gates close.
```

Remaining active prompts should not require raw primary:

```bash
xcodegen generate
xcodebuild test
```

They should call the wrapper:

```bash
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane <LANE> [--test <TEST_ID>] [--test-plan <TEST_PLAN>]
```

Raw commands may remain only as explanatory fallback examples in docs/playbooks.

Use repo-local DerivedData:

```text
.codex/DerivedData/Ambitions
```

Do not delete global DerivedData by default. Clear repo-local DerivedData only
when project wiring changed, module cache corruption is detected, or the same
compile failure persists after one non-clean retry.

Every Xcode validation run must write:

```text
.codex/xcode-results/<BATCH_ID>/<timestamp>/*.xcresult
.codex/xcode-logs/<BATCH_ID>/<timestamp>/*.log
.codex/xcode-summaries/<BATCH_ID>/<timestamp>/*.json
```

Do not commit those artifacts unless active repo policy explicitly requires
them. Add/preserve `.gitignore` entries.

Simulator boot is required only for lanes that run simulator-hosted tests or UI
proof.

Test plans are preferred for segment gates. Create physical `.xctestplan` files
only if project structure supports them cleanly; otherwise create protocol docs
and scripts, then defer physical test plans with owner/rationale.

Tool pinning must be documented and non-destructive. Do not require internet
installs during this batch.

Tuist may be evaluated after PK41 only. Do not migrate to Tuist here. Bazel,
Buck2, and Fastlane are deferred. Periphery is optional later hygiene only.

## Required Deliverables

Create or update Build Lab tooling:

```text
Brewfile.ambitions-build-lab
.xcode-version
.mise.toml
scripts/ambitions-build-lab-doctor.sh
scripts/ambitions-xcode-version-check.sh
scripts/ambitions-xcodegen-needed.sh
scripts/ambitions-xcode-sim-health.sh
scripts/ambitions-deriveddata-manager.sh
scripts/ambitions-xcode-build-for-testing.sh
scripts/ambitions-xcode-test-focused.sh
scripts/ambitions-xcode-test-plan.sh
scripts/ambitions-xcode-result-extract.sh
scripts/ambitions-xcode-failure-classifier.py
scripts/ambitions-xcode-validate.sh
```

Create or update Build Lab documentation/playbooks:

```text
docs/codex/XCODE_BUILD_LAB_PROTOCOL.md
docs/codex/XCODE_VALIDATION_LANE_MATRIX.md
docs/codex/XCODE_TOOLCHAIN_PINNING.md
docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md
docs/codex/playbooks/XCODE_SICK_SIMULATOR_PLAYBOOK.md
docs/codex/playbooks/DERIVEDDATA_HYGIENE_PLAYBOOK.md
docs/codex/playbooks/XCODE_TEST_PLAN_OWNERSHIP_PLAYBOOK.md
docs/codex/playbooks/XCODE_FAILURE_CLASSIFICATION_PLAYBOOK.md
docs/codex/playbooks/TUIST_EVALUATION_AFTER_PK41_PLAYBOOK.md
docs/audits/xcode-build-system-max-report.md
```

Update prompt/control-plane surfaces:

```text
prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md
docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json
prompts/batches/PK18.md through prompts/batches/PK41.md
```

Do not reactivate or rewrite PK17 unless active repo truth requires a
historical do-not-run note.

Optional test plans, only if safe:

```text
Native/TestPlans/Ambitions-Focused.xctestplan
Native/TestPlans/Ambitions-Persistence.xctestplan
Native/TestPlans/Ambitions-Services.xctestplan
Native/TestPlans/Ambitions-SideEffects.xctestplan
Native/TestPlans/Ambitions-SourceAtlas.xctestplan
Native/TestPlans/Ambitions-UI.xctestplan
Native/TestPlans/Ambitions-Full.xctestplan
Native/TestPlans/Ambitions-ReleaseProof.xctestplan
```

Do not wire test plans into `project.yml` unless wiring is well-supported and
validated.

## Implementation Details

`Brewfile.ambitions-build-lab` must include at least:

```ruby
tap "xcodesorg/made"
tap "chargepoint/xcparse"

brew "xcodesorg/made/xcodes"
brew "xcodegen"
brew "xcbeautify"
brew "chargepoint/xcparse/xcparse"
brew "swiftlint"
brew "swiftformat"
brew "periphery"
brew "jq"
brew "yq"
brew "coreutils"
brew "watchman"
brew "mise"
brew "tmux"
```

`.xcode-version` must use the current active Xcode version if it can be read.
Do not invent an Xcode version. `.mise.toml` may pin non-Xcode tools only if
safe:

```toml
[tools]
python = "3.12"
node = "22"
ruby = "3.3"
```

`.gitignore` must ignore:

```gitignore
.codex/DerivedData/
.codex/xcode-results/
.codex/xcode-logs/
.codex/xcode-summaries/
.codex/build-cache/
*.xcresult
```

`scripts/ambitions-build-lab-doctor.sh` must be non-mutating and support:

```bash
scripts/ambitions-build-lab-doctor.sh
scripts/ambitions-build-lab-doctor.sh --json
scripts/ambitions-build-lab-doctor.sh --strict
```

It must print Xcode path/version, `xcodebuild` version, XcodeGen,
xcbeautify, xcparse, Tuist if installed, selected simulator runtime/device,
DerivedData path, result/log paths, recommended validation lane, missing
optional tools, and missing required tools.

`scripts/ambitions-xcode-version-check.sh` must verify `xcode-select -p`,
`xcodebuild -version`, read `.xcode-version` if present, warn on mismatch, and
fail only in `--strict`.

`scripts/ambitions-xcodegen-needed.sh` must return:

```text
0 = xcodegen needed
10 = xcodegen not needed
2 = unable to determine
```

and print:

```text
XCODEGEN_NEEDED=1|0|unknown
REASON=<reason>
```

Triggers include `project.yml`, `Package.swift`, `*.xctestplan`, new/deleted
Swift files, resources, asset catalogs, and test target membership risk.

`scripts/ambitions-xcode-sim-health.sh` must choose simulator by
`AMBITIONS_SIM_UDID`, then `AMBITIONS_SIM_NAME`, then repo-standard simulator
only if present. It must boot only when the lane requires simulator, support
`--repair`, and never erase all simulators by default. `--erase-selected` is
required for selected-device erase.

`scripts/ambitions-deriveddata-manager.sh` must support:

```bash
scripts/ambitions-deriveddata-manager.sh path
scripts/ambitions-deriveddata-manager.sh status
scripts/ambitions-deriveddata-manager.sh clean --batch PK18 --reason "module cache corruption"
```

It must default to `.codex/DerivedData/Ambitions` and never delete global
DerivedData.

`scripts/ambitions-xcode-build-for-testing.sh` must run XcodeGen only if
needed, run `xcodebuild build-for-testing`, use repo-local DerivedData, write
result bundle/logs, use xcbeautify when available, preserve raw logs, and
classify failures.

`scripts/ambitions-xcode-test-focused.sh` must support `--test` and
`--only-testing`, run focused `test-without-building` where possible, preboot
simulator only when needed, write result bundle/logs, classify failures, and
retry once only for simulator sickness.

`scripts/ambitions-xcode-test-plan.sh` must support named test plans, fail
clearly when missing, and suggest focused-test fallback.

`scripts/ambitions-xcode-result-extract.sh` must use `xcparse` when available
to extract logs, screenshots, attachments, coverage if available, and summary
JSON. Without xcparse it must preserve the raw `.xcresult` path and print
missing-tool advice.

`scripts/ambitions-xcode-failure-classifier.py` must print JSON and classify:

```text
compile_error
test_failure
test_timeout
simulator_boot_failure
test_discovery_failure
stale_derived_data
xcodegen_project_drift
missing_destination
signing_error
package_resolution_error
result_bundle_error
tool_missing
unknown
```

`scripts/ambitions-xcode-validate.sh` is the primary interface:

```bash
scripts/ambitions-xcode-validate.sh --batch PK18 --lane none
scripts/ambitions-xcode-validate.sh --batch PK18 --lane build
scripts/ambitions-xcode-validate.sh --batch PK18 --lane build-for-testing
scripts/ambitions-xcode-validate.sh --batch PK18 --lane focused-test --test AmbitionsTests/TodayCommandHandlerTests
scripts/ambitions-xcode-validate.sh --batch PK18 --lane test-plan --test-plan Ambitions-Focused
scripts/ambitions-xcode-validate.sh --batch FCP05 --lane ui-proof --test-plan Ambitions-UI
scripts/ambitions-xcode-validate.sh --batch DPTG00 --lane terminal-device-proof --test-plan Ambitions-ReleaseProof
```

It must run doctor, determine XcodeGen need, use repo-local DerivedData,
preboot simulator only where needed, run the lane, save logs/results, extract
when possible, classify failures, retry once for simulator sickness, clean
repo-local DerivedData only for cache/project-drift failures, print summary,
and exit meaningfully:

```text
0 = validation passed
10 = lane none / no Xcode needed
20 = validation failed with test failure
21 = validation failed with compile failure
22 = simulator failure
23 = project generation failure
24 = missing tool
25 = timeout
26 = unknown failure
```

Add or update Makefile targets:

```make
build-lab-doctor:
	./scripts/ambitions-build-lab-doctor.sh

xcode-validate:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane $(LANE) $(ARGS)

xcode-focused-test:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane focused-test --test $(TEST)

xcode-build-for-testing:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane build-for-testing

xcode-test-plan:
	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane test-plan --test-plan $(TEST_PLAN)
```

## Prompt Updates Required

Update active executable prompts so Xcode validation uses the wrapper. Suggested
lanes:

```text
PK18: focused-test
PK19: focused-test
PK20: focused-test
PK21: focused-test
PK22: focused-test
PK23: focused-test
PK24: focused-test
PK25: focused-test
PK26: focused-test
PK27: focused-test
PK28: focused-test
PK29: focused-test
PK30: focused-test
PK31: focused-test
PK32: focused-test
PK33: focused-test
PK34: focused-test
PK35: build-for-testing or focused-test
PK36: build-for-testing or focused-test
PK37: focused-test
PK38: build
PK39: build
PK40: build
PK41: build
```

Each prompt may still require focused Xcode tests if production Swift changes
demand it. The prompt must say Codex should use the wrapper and pick the
narrowest proof lane, not raw full-suite `xcodebuild test`.

## Documentation Requirements

`docs/codex/XCODE_BUILD_LAB_PROTOCOL.md` must explain purpose, lanes, XcodeGen
need, DerivedData strategy, simulator strategy, build-for-testing /
test-without-building strategy, logs/result bundles, failure classification,
retry policy, no-claim policy, train integration, and rollback.

`docs/codex/XCODE_VALIDATION_LANE_MATRIX.md` must map:

```text
Prompt/governance: L0_NONE
Service extraction: L3_FOCUSED_TEST
Persistence/storage: L3_FOCUSED_TEST
Side effects: L3_FOCUSED_TEST
Privacy/data control: L3_FOCUSED_TEST
Source Atlas: L0 or L3 depending source code changes
Intelligence boundary: L3_FOCUSED_TEST
Performance fixture/cache: L2/L3
Package extraction: L1_BUILD plus focused compile validation
UI/FET/FVQ/PX: L6_UI_PROOF
Terminal DPTG: L7_TERMINAL_DEVICE_PROOF
```

`docs/codex/XCODE_TOOLCHAIN_PINNING.md` must explain `.xcode-version`,
`xcodes`, Brewfile, mise, optional tools, missing-tool behavior, and no
mandatory internet install during runner execution.

`docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md` must explain where logs and
`.xcresult` go, when to extract, what to commit, what not to commit, and how
final reports cite local evidence.

Playbooks must be actionable and not generic.

## Validation Requirements

Run:

```bash
git status --short
git diff --check
bash -n scripts/ambitions-build-lab-doctor.sh
bash -n scripts/ambitions-xcode-version-check.sh
bash -n scripts/ambitions-xcodegen-needed.sh
bash -n scripts/ambitions-xcode-sim-health.sh
bash -n scripts/ambitions-deriveddata-manager.sh
bash -n scripts/ambitions-xcode-build-for-testing.sh
bash -n scripts/ambitions-xcode-test-focused.sh
bash -n scripts/ambitions-xcode-test-plan.sh
bash -n scripts/ambitions-xcode-result-extract.sh
bash -n scripts/ambitions-xcode-validate.sh
python3 -m py_compile scripts/ambitions-xcode-failure-classifier.py
python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt
make prompt-audit || true
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-final-report-gate.py docs/audits/xcode-build-system-max-report.md --strict || true
scripts/ambitions-build-lab-doctor.sh || true
scripts/ambitions-xcode-validate.sh --batch XCODE-BUILD-SYSTEM-MAX-01 --lane none
```

Do not run the full test suite in this batch unless all wrappers are already
Green and the local environment is stable.

## Final Report

Create:

```text
docs/audits/xcode-build-system-max-report.md
```

It must include:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Objective
PK17 completion/pushed verification
Queue placement after PK17 and before PK18
Files changed
Files intentionally not changed
Tooling added
Scripts added/updated
Docs/playbooks added/updated
Prompt files updated
Makefile targets updated
Test plans added/deferred
Toolchain pinning result
DerivedData policy result
Simulator policy result
Result-bundle policy result
Failure-classifier result
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Accepted Yellow rationale, if any
Claims made
Claims not made
Rollback notes
Next eligible implementation batch
```

Next eligible product implementation batch should remain:

```text
PK18 Today Command Handler Extraction
```

## Hard Red Conditions

Stop Red if:

- PK17 is not complete/pushed before this batch runs.
- App product behavior is changed.
- Production source is modified outside build/test-plan wiring.
- Queue order changes without evidence.
- Completed batches are reactivated.
- PK18 stops being next product implementation batch without repo evidence.
- PK17-PK41 are collapsed.
- Plan is restored as top-level destination.
- External/cloud LLM core behavior is introduced.
- Telemetry, analytics, network, backend, sync, or account behavior is
  introduced.
- Signing, entitlement, workflow, release, or hosted CI files are modified.
- DPTG00 is made non-terminal.
- Scripts delete global DerivedData by default.
- Scripts erase all simulators by default.
- Scripts run full Xcode suite by default.
- Wrapper hides Xcode failures or returns success on failed validation.
- JSON files become invalid.
- Final report omits validation failures.

## Accepted Yellow Policy

Accepted Yellow is allowed only if:

- PK17 is complete and pushed.
- Scripts are present and syntax-valid.
- Docs/playbooks are present.
- Prompt updates are materially complete.
- PK18 remains next product implementation batch.
- The only missing piece is environment-dependent validation, optional tool
  availability, or deferred test-plan wiring.
- Final report documents the defect, why it is non-blocking, risk, follow-up,
  and next-batch impact.

Accepted Yellow is forbidden if the validation wrapper or failure classifier is
missing, DerivedData policy is unsafe, simulator policy is destructive by
default, prompt updates still require raw full `xcodebuild test` for normal
batches, app source behavior changed, or queue integrity changed.

## Rollback Expectations

Final report must include rollback instructions.

Preferred rollback:

```bash
git revert <commit-sha>
```

Also include manual rollback categories:

```text
remove build-lab scripts
remove build-lab docs/playbooks
revert prompt validation command updates
revert Makefile target additions
revert Brewfile/.mise/.xcode-version additions if needed
remove optional test plans if created
```

Do not delete user-authored build artifacts or global DerivedData.

## Claims Not To Make

Do not claim app behavior changed, permanent Xcode reliability, all tests pass
unless run, full suite Green unless run, simulator proof unless run, device
proof unless run, release/TestFlight/App Store readiness, accessibility
compliance, performance targets met, privacy/legal/security compliance, global
train completed, or PK18 completed.

## Final Response

End with:

```text
Status: Green / Accepted Yellow / Red
PK17 completion verification
Queue placement result
Files changed
Scripts added/updated
Docs/playbooks added/updated
Prompt updates
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Claims not made
Rollback notes
Next eligible implementation batch
```

The expected next eligible product implementation batch remains:

```text
PK18 Today Command Handler Extraction
```
