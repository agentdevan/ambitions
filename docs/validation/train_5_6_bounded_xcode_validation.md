# Train 5.6 - Bounded Xcode Validation

Date: 2026-06-18
Baseline commit: `bd382be1a95b2fb153d40b3b0b4b8ff06797e1b1`
Scope: validation infrastructure only

## Why This Train Exists

Train 5.5 AMB-962 screenshot validation consumed roughly 55 minutes before finishing, and an earlier screenshot-service failure left `xcodebuild` alive after a failed result. That makes future train proof vulnerable to unbounded validation time and stale process state.

Train 5.6 adds a bounded Xcode execution path and a specific AMB-962 helper so future screenshot proof cannot silently exceed the train timeout policy.

## Product Code Changed

No product code changed in Train 5.6.

Existing uncommitted Train 5 and Train 5.5 product/test changes remain in the worktree. Train 5.6 added validation scripts and docs only.

## Timeout Values Selected

- Focused unit tests: `15m`.
- Build-for-testing: `30m`, unless the retained build wrapper has an equivalent bound.
- AMB-962 / UI screenshot matrix: `20m`.
- Kill-after: `60s`.
- UI screenshot matrix retry count: `1`.

## Wrapper Behavior

`scripts/ambitions-bounded-xcodebuild.sh`:

- detects `/usr/local/bin/gtimeout` first on this machine;
- falls back to `timeout` if `gtimeout` is unavailable;
- has a no-timeout fallback with an explicit warning;
- accepts xcodebuild arguments after `--`;
- echoes command metadata, destination, result bundle, timeout, kill-after, and log path;
- writes combined output to `--log`;
- preserves normal `xcodebuild` exit status;
- returns `124` on timeout;
- prints process-inspection guidance on timeout;
- limits targeted cleanup to processes matching the provided result bundle path.

The retained build-for-testing and focused-test wrappers now call this bounded wrapper:

- `scripts/ambitions-xcode-build-for-testing.sh` defaults to `30m`.
- `scripts/ambitions-xcode-test-focused.sh` defaults to `15m`.

## AMB-962 Helper

`scripts/ambitions-run-ui-screenshot-matrix.sh` runs:

```bash
scripts/ambitions-run-ui-screenshot-matrix.sh --batch <BATCH>
```

The helper uses destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5` and does not hardcode a simulator UDID.

It writes fresh results under:

```text
.codex/xcode-results/<batch>/<timestamp>-AMB962.xcresult
.codex/xcode-summaries/<batch>/<timestamp>-AMB962/extract
.codex/xcode-logs/<batch>/<timestamp>-AMB962.log
```

If the first AMB-962 attempt times out, the helper extracts any partial bundle, runs `xcrun simctl shutdown all`, and retries once. It does not retry non-timeout failures.

## gtimeout Availability

Available:

```text
/usr/local/bin/gtimeout
```

`timeout` is also available at `/usr/local/bin/timeout`, but the wrapper selects `gtimeout` first.

## Local Xcode Timeout Flag Support

Checked with:

```bash
xcodebuild -help | rg -n -i "timeout|time allowance|allowance|maximum-test|test-time"
```

Local Xcode supports:

- `-test-timeouts-enabled YES|NO`
- `-default-test-execution-time-allowance SECONDS`
- `-maximum-test-execution-time-allowance SECONDS`

The AMB-962 helper adds those flags when detected. They are inner per-test allowances only; the outer wrapper remains the authoritative wall-clock bound.

## Commands Tested

```bash
bash -n scripts/ambitions-bounded-xcodebuild.sh
bash -n scripts/ambitions-run-ui-screenshot-matrix.sh
bash -n scripts/ambitions-xcode-build-for-testing.sh
bash -n scripts/ambitions-xcode-test-focused.sh
scripts/ambitions-bounded-xcodebuild.sh --help
scripts/ambitions-run-ui-screenshot-matrix.sh --help
scripts/ambitions-xcode-build-for-testing.sh --help
scripts/ambitions-xcode-test-focused.sh --help
scripts/ambitions-bounded-xcodebuild.sh --timeout 1m --kill-after 10s --log .codex/xcode-logs/DESIGN_TRUTH_TRAIN_05_6/xcodebuild-version.log -- -version
scripts/ambitions-bounded-xcodebuild.sh --timeout 1m --kill-after 10s --log .codex/xcode-logs/DESIGN_TRUTH_TRAIN_05_6/xcodebuild-version-post-wrapper-route.log -- -version
```

The bounded lightweight command returned:

```text
timeout_tool=/usr/local/bin/gtimeout
command: xcodebuild -version
Xcode 26.3
Build version 17C529
```

Full AMB-962 was not rerun in Train 5.6 because current Train 5.5 screenshot proof already exists at:

```text
.codex/xcode-results/DESIGN_TRUTH_TRAIN_05_5/20260618T230657Z-AmbitionsUITests-AmbitionsUITests-testAMB962TodayReconstructionScreenshotMatrix.xcresult
.codex/xcode-summaries/DESIGN_TRUTH_TRAIN_05_5/20260618T230657Z-AmbitionsUITests-AmbitionsUITests-testAMB962TodayReconstructionScreenshotMatrix/extract/screenshots
```

## Future AMB-962 Invocation

Future Codex prompts must invoke AMB-962 through:

```bash
scripts/ambitions-run-ui-screenshot-matrix.sh --batch <BATCH>
```

Do not call raw `xcodebuild test ... testAMB962TodayReconstructionScreenshotMatrix` for train proof. A screenshot matrix that exceeds the 20-minute wrapper timeout is not Green proof.

## Train 5.5 Commit Readiness

Train 5.5 has current screenshot proof after the viewport fix, but manual VoiceOver, Increase Contrast, and Reduce Transparency proof remained not run in that train. Train 5.5 can be committed only as an honest Yellow closeout unless those manual checks are later completed and documented.

Train 5.6 itself does not add product risk and can be committed together with Train 5 + 5.5 if an acceptable Yellow commit is desired.

## Validation Result

Passed:

- `bash -n scripts/ambitions-bounded-xcodebuild.sh`
- `bash -n scripts/ambitions-run-ui-screenshot-matrix.sh`
- `bash -n scripts/ambitions-xcode-build-for-testing.sh`
- `bash -n scripts/ambitions-xcode-test-focused.sh`
- `scripts/ambitions-bounded-xcodebuild.sh --help`
- `scripts/ambitions-run-ui-screenshot-matrix.sh --help`
- `scripts/ambitions-xcode-build-for-testing.sh --help`
- `scripts/ambitions-xcode-test-focused.sh --help`
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 1m --kill-after 10s --log .codex/xcode-logs/DESIGN_TRUTH_TRAIN_05_6/xcodebuild-version.log -- -version`
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 1m --kill-after 10s --log .codex/xcode-logs/DESIGN_TRUTH_TRAIN_05_6/xcodebuild-version-post-wrapper-route.log -- -version`
- `git diff --check`
- `scripts/canon-language-drift-scan.sh` changed-file result: Green; existing backlog hits reported separately
- `scripts/release-claim-safety-scan.sh`
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/validation docs/README.md scripts/ambitions-bounded-xcodebuild.sh scripts/ambitions-run-ui-screenshot-matrix.sh scripts/ambitions-xcode-build-for-testing.sh scripts/ambitions-xcode-test-focused.sh`
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`

Operator correction:

- `python3 scripts/ambitions-copy-contract-lint.py --include-shared` failed because this repo script exposes `--include-components`, not `--include-shared`; the corrected command above passed.

Not run:

- Full AMB-962 was not rerun in Train 5.6 because Train 5.5 already has current screenshot proof and this train is validation infrastructure only.
