<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01

## Batch ID

`XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01`

## Runner Command

```bash
scripts/ambitions-codex-train.sh XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01 prompts/batches/XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01.md
```

## Objective

Repair the final-gate defects from `XCODE-BUILD-SYSTEM-MAX-01` without changing app product behavior, queue order, release posture, signing, hosted CI, generated Xcode projects, or production Swift source.

## Source Truth

Inspect:

- `docs/truth/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.codex/state/active-batch.yml`
- `docs/audits/xcode-build-system-max-report.md`
- `scripts/ambitions-xcode-validate.sh`
- `scripts/ambitions-xcode-build-for-testing.sh`
- `scripts/ambitions-xcode-test-focused.sh`
- `scripts/ambitions-xcode-test-plan.sh`
- `Makefile`

## Required Repairs

1. Fix `scripts/ambitions-xcode-validate.sh` so the primary wrapper passes base artifact roots to child wrappers:
   - `--results-dir .codex/xcode-results`
   - `--logs-dir .codex/xcode-logs`
   - `--summaries-dir .codex/xcode-summaries`

   The child wrappers must remain responsible for writing:

   ```text
   .codex/xcode-results/<BATCH_ID>/<timestamp>/*.xcresult
   .codex/xcode-logs/<BATCH_ID>/<timestamp>/*.log
   .codex/xcode-summaries/<BATCH_ID>/<timestamp>/*.json
   ```

   Do not allow nested paths like:

   ```text
   .codex/xcode-results/<BATCH_ID>/<outer-timestamp>/<BATCH_ID>/<inner-timestamp>/
   ```

2. Fix the Makefile Xcode targets so they honor `BATCH`, not only `XCODE_BATCH`:

   ```make
   xcode-validate:
   	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane $(LANE) $(ARGS)

   xcode-focused-test:
   	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane focused-test --test $(TEST)

   xcode-build-for-testing:
   	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane build-for-testing

   xcode-test-plan:
   	./scripts/ambitions-xcode-validate.sh --batch $(BATCH) --lane test-plan --test-plan $(TEST_PLAN)
   ```

3. Update `docs/audits/xcode-build-system-max-report.md` with the repair evidence.

## Allowed Scope

- `scripts/ambitions-xcode-validate.sh`
- `Makefile`
- `docs/audits/xcode-build-system-max-report.md`
- this repair prompt

## Forbidden Scope

- Production app source
- `project.yml`
- `Package.swift`
- `.github/**`
- signing, entitlements, release automation
- queue ID/order changes
- PK18 completion claims
- release, TestFlight, App Store, device, accessibility, performance, privacy/legal, or full-suite pass claims

## Validation

Run:

```bash
git diff --check
bash -n scripts/ambitions-xcode-validate.sh
bash -n scripts/ambitions-xcode-build-for-testing.sh
bash -n scripts/ambitions-xcode-test-focused.sh
bash -n scripts/ambitions-xcode-test-plan.sh
python3 -m py_compile scripts/ambitions-xcode-failure-classifier.py
make batch-self-check || true
make prompt-audit || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-final-report-gate.py docs/audits/xcode-build-system-max-report.md --strict || true
scripts/ambitions-xcode-validate.sh --batch XCODE-BUILD-SYSTEM-MAX-01 --lane none
```

Also verify by inspection or script output that the primary wrapper no longer passes timestamped artifact roots to child wrappers.

## Closeout

Close Green only if both final-gate defects are repaired and validation is honestly recorded. PK17 must remain complete on origin/main, and PK18 must remain the next product implementation batch.
