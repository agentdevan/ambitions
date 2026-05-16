<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MANIFEST-RERUN-SA28-01 — Repair SA28 Manifest-Faithful Rerun Closeout

## Batch ID

MANIFEST-RERUN-SA28-01

## Objective

Repair and complete SA28 — Pack Diff / Changed Claim Tooling — under the active manifest-rerun directive.

This batch must make SA28 truthful and manifest-faithful before any movement to SA29.

The likely current issue is not SA28 implementation itself. The likely issue is Windows test-harness portability and proof honesty:

- Python is available.
- The prior test failure used `WinError 193`, likely because the test tried to execute `ambitions-pack-diff.py` directly on Windows.
- The test should invoke the script through `sys.executable`.
- Prior SA28 Green is supporting evidence only, not current rerun proof.
- SA28 may close Green only if current validation passes.

## Active source truth to inspect first

Read, in this exact order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `docs/codex/ANTIGRAVITY_MANIFEST_RERUN_START_HERE.md`
9. `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md`
10. `.codex/state/active-batch.yml`
11. `.codex/reports/current-batch-train-state.md`
12. `.codex/reports/current-run-state.md`
13. `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
14. `docs/audits/sa28-batch-closeout-report.md`
15. `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`
16. `tools/source-atlas/ambitions-pack-diff.py`
17. `tools/source-atlas/tests/test_ambitions_pack_diff.py`

## Current hard rule

Do not proceed to SA29.

Do not continue to FCP27.

This batch only repairs and closes SA28 truthfully.

## Allowed scope

You may modify only:

- `tools/source-atlas/tests/test_ambitions_pack_diff.py`
- `tools/source-atlas/ambitions-pack-diff.py` only if the test exposes a real SA28 bug
- `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`
- `docs/audits/sa28-batch-closeout-report.md` only if needed to clarify current rerun evidence
- `.codex/state/active-batch.yml` only if SA28 closes Green and the next eligible batch should become SA29
- `.codex/reports/current-batch-train-state.md` only if SA28 closes Green and the next eligible batch should become SA29
- `.codex/reports/current-run-state.md` only if SA28 closes Green and the next eligible batch should become SA29

## Forbidden scope

Do not modify:

- Swift files
- Swift tests
- `project.yml`
- `.github/workflows/**`
- signing, entitlements, provisioning, release, or App Store files
- frontend encyclopedia files
- unrelated Source Atlas tools
- SA29, SA30, SA31, SA32 implementation files
- LDI files
- AOS files
- FCP files
- broad queue order files unless explicitly necessary and fully justified

Do not delete files.

Do not revert prior commits by default.

Do not run destructive commands.

Do not claim release readiness, device validation, public accessibility conformance, privacy/legal approval, TestFlight readiness, App Store readiness, performance proof, sync/cloud readiness, hosted AI proof, or global train completion.

## Required implementation

### 1. Verify SA28 audit file is tracked or staged

Run:

```bash
git status --short
```

If `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md` is untracked, stage it before closeout:

```bash
git add docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md
```

Do not claim `git diff --check` validates untracked files.

### 2. Repair Windows test harness portability

Inspect:

```text
tools/source-atlas/tests/test_ambitions_pack_diff.py
```

If it executes the script directly, such as:

```python
subprocess.run([str(script), str(old_path), str(new_path)], ...)
```

change it to use the current interpreter:

```python
import sys

subprocess.run(
    [sys.executable, str(script), str(old_path), str(new_path)],
    capture_output=True,
    text=True,
    check=True
)
```

This is required for Windows portability.

Do not treat `WinError 193` as Python unavailable if `python --version` works.

### 3. Re-run SA28 validation

Run:

```bash
git status --short
git diff --check
git diff --cached --check
python --version
python -m unittest tools/source-atlas/tests/test_ambitions_pack_diff.py
scripts/codex-forbidden-claim-scan.sh tools/source-atlas/ambitions-pack-diff.py tools/source-atlas/tests/test_ambitions_pack_diff.py docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md 2>/dev/null || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || python scripts/ambitions-source-atlas-title-check.py --strict
make batch-self-check
```

If `make` or `python3` is unavailable on Windows, use the available Windows equivalent and record the exact command and result.

### 4. Update audit truthfully

Update:

```text
docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md
```

SA28 section must include:

* manifest requirement
* prior SA28 commit/report evidence retained
* prior evidence classification
* files inspected
* files changed
* Windows test-harness portability repair, if made
* validation commands
* validation results
* final status

If the unit test passes, SA28 final status may be:

```text
Green
```

If the unit test still fails, SA28 final status must be:

```text
Accepted Yellow
```

with exact owner/blocker.

Do not say Python is unavailable if Python is available.

### 5. Queue state handling

If and only if SA28 is Green:

Update the active state mirrors so the next eligible batch becomes:

```text
SA29 Hash / Signature / Revocation Tooling
```

Files:

* `.codex/state/active-batch.yml`
* `.codex/reports/current-batch-train-state.md`
* `.codex/reports/current-run-state.md`

Keep FCP27 blocked.

Do not mark SA29 complete.

Do not advance beyond SA29.

If SA28 is Accepted Yellow or Blocked, do not advance queue state.

## Validation expectations

Minimum successful closeout for Green:

```bash
git status --short
git diff --check
git diff --cached --check
python -m unittest tools/source-atlas/tests/test_ambitions_pack_diff.py
scripts/codex-forbidden-claim-scan.sh tools/source-atlas/ambitions-pack-diff.py tools/source-atlas/tests/test_ambitions_pack_diff.py docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md 2>/dev/null || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || python scripts/ambitions-source-atlas-title-check.py --strict
make batch-self-check
```

Green is not allowed if the SA28 unit test fails.

## Visual proof expectations

None. SA28 is tooling-only and does not touch frontend UI.

If any frontend file is unexpectedly touched, stop and classify as scope violation unless explicitly justified.

## Hard Red stop conditions

Stop and do not close Green if:

* SA29 starts before SA28 closes correctly
* FCP27 is started or unblocked
* the audit file remains untracked/unvalidated
* the pack-diff unit test fails
* prior SA28 Green is used as substitute for current validation
* Python availability is misreported
* release/device/App Store/accessibility/privacy/legal/global-completion claims are added
* unrelated files are modified

## Rollback expectations

If the test-harness repair causes issues, rollback only the specific test-file change.

Do not revert prior SA28 implementation commits by default.

Prior SA28 commits are retained as supporting evidence.

## Closeout response format

Return:

```text
Status: Green / Accepted Yellow / Blocked

Files changed:
- ...

Validation:
- command: result
- command: result

SA28 final classification:
- prior evidence:
- current rerun evidence:
- remaining blockers:

Queue state:
- current batch:
- next eligible batch:
- FCP27 blocked: yes/no

Claims not made:
- release readiness
- device validation
- public accessibility conformance
- privacy/legal approval
- TestFlight/App Store readiness
- performance proof
- sync/cloud readiness
- hosted AI proof
- global train completion
```

## Runner command

```bash
scripts/ambitions-codex-train.sh MANIFEST-RERUN-SA28-01 prompts/batches/MANIFEST-RERUN-SA28-01.md
```

or:

```bash
make batch BATCH=MANIFEST-RERUN-SA28-01 PROMPT=prompts/batches/MANIFEST-RERUN-SA28-01.md
```

