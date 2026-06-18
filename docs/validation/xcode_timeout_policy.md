# Xcode Timeout Policy

Status: Active validation policy
Owner: Ambitions repo validation infrastructure
Scope: Xcode build, unit-test, and UI screenshot validation runs

## Required Wrapper

Codex and other agents must run long-running Xcode validation through:

```bash
scripts/ambitions-bounded-xcodebuild.sh --timeout <duration> --kill-after 60s -- <xcodebuild args>
```

The wrapper:

- detects `gtimeout`, then `timeout`, then a no-timeout fallback;
- prefers `gtimeout` on macOS;
- defaults to `15m` timeout and `60s` kill-after;
- passes through arbitrary `xcodebuild` arguments after `--`;
- echoes the command, destination, timeout, kill-after, log path, and result bundle path when present;
- writes combined stdout/stderr to `--log` when provided;
- preserves normal `xcodebuild` exit status when the process does not time out;
- returns `124` for timeout;
- prints process-inspection guidance on timeout;
- does not kill unrelated `xcodebuild` processes globally;
- performs only targeted timeout cleanup for processes whose command line matches the result bundle path, when a result bundle path is provided.

If neither `gtimeout` nor `timeout` is installed, the wrapper prints a warning and runs the command without a wall-clock bound. Long-running validation from that fallback must not be treated as Green release or screenshot proof.

## Timeout Values

- Focused unit tests: `15m`.
- Build-for-testing: `30m`.
- AMB-962 / UI screenshot matrix: `20m`.
- Kill-after: `60s`.
- UI screenshot matrix retry count: maximum `1`.

The retained wrappers route through `scripts/ambitions-bounded-xcodebuild.sh`:

- `scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>` uses `30m` by default.
- `scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>` uses `15m` by default.

## UI Screenshot Timeout Policy

The AMB-962 helper is:

```bash
scripts/ambitions-run-ui-screenshot-matrix.sh --batch <BATCH>
```

The helper uses:

- destination: `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5`;
- test: `AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix`;
- result bundle: `.codex/xcode-results/<batch>/<timestamp>-AMB962.xcresult`;
- extraction: `scripts/ambitions-xcode-result-extract.sh --result <bundle> --output-dir <extract-dir>`;
- bounded execution: `scripts/ambitions-bounded-xcodebuild.sh`;
- retry behavior: retry once only after `xcrun simctl shutdown all`, and only when the first attempt times out.

If the first UI screenshot matrix run times out, extract the partial result bundle if it exists and record the attempt as an infrastructure timeout. Then retry once after simulator shutdown.

If the retry times out or fails, close the train Yellow. Do not continue rerunning.

If a UI screenshot matrix passes only after exceeding the timeout policy, it is not acceptable proof for Green.

## Local Xcode Timeout Flags

The installed local Xcode reports support for:

- `-test-timeouts-enabled YES|NO`
- `-default-test-execution-time-allowance SECONDS`
- `-maximum-test-execution-time-allowance SECONDS`

The AMB-962 helper detects these flags from `xcodebuild -help` and adds them when available. These flags are per-test execution allowances; they do not replace the wrapper's wall-clock timeout.
