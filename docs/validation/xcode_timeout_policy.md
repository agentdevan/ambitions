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
- performs only targeted timeout cleanup for processes whose command line matches the result bundle or derived data path, when either path is provided.

If neither `gtimeout` nor `timeout` is installed, the wrapper prints a warning and runs the command without a wall-clock bound. Long-running validation from that fallback must not be treated as Green release or screenshot proof.

## Timeout Values

- Focused unit tests: `15m`.
- Build-for-testing and validate build prebuilds: `45m`.
- Xcode test-plan execution after prebuild: `45m`.
- AMB-962 / UI screenshot matrix: `20m`.
- UI screenshot matrix prebuild: `45m`.
- Kill-after: `60s`.
- UI screenshot matrix retry count: maximum `1`.

The retained wrappers route through `scripts/ambitions-bounded-xcodebuild.sh`:

- `scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>` uses `45m` by default and writes Xcode's build timing summary to the retained log.
- `scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>` uses `15m` by default.
- `scripts/ambitions-xcode-test-plan.sh --batch <BATCH> --test-plan <PLAN_NAME>` uses `45m` by default and must run against a prior build-for-testing artifact.
- `scripts/ambitions-xcode-validate.sh --lane build` uses the bounded wrapper instead of direct `xcodebuild`.
- `scripts/ambitions-xcode-validate.sh --lane test-plan` defaults to `Smoke` on `AmbitionsSmoke`.
- `scripts/ambitions-xcode-validate.sh --lane ui-proof` defaults to `Screenshots` on `AmbitionsScreenshots`.
- `scripts/ambitions-xcode-validate.sh --lane terminal-device-proof` defaults to `ReleaseCandidate` on `AmbitionsReleaseCandidate`.
- `scripts/ambitions-xcode-validate.sh` prebuilds the matching scheme before any test-plan lane, then runs `test-without-building` for the plan execution.
- `scripts/ci/strict_build_launch.sh` uses bounded `xcodebuild` phases for list, package resolution, and simulator build.
- `scripts/ci/strict_build_launch.sh` defaults to `SIMULATOR_NAME=iPhone 17 Pro Max` through the same simulator family used by the standalone health gate and the repo XcodeBuildMCP profile.

Local retained Xcode runners pass `-skipPackagePluginValidation` and
`-skipMacroValidation` because this repo pins trusted local project/package
inputs and validation proof should not spend repeated wall-clock time on those
checks. Do not add `-skipPackageSignatureValidation` to proof lanes without a
separate security review.

The timeout values are environment-tunable without editing scripts:

```bash
AMBITIONS_XCODE_BUILD_FOR_TESTING_TIMEOUT=60m scripts/ambitions-xcode-build-for-testing.sh --batch LOCAL
AMBITIONS_XCODE_VALIDATE_TEST_PLAN_TIMEOUT=60m scripts/ambitions-xcode-validate.sh --batch LOCAL --lane ui-proof
```

Increasing the wall-clock budget is allowed when the build is actively compiling
and producing current proof artifacts. It must not be used to relabel a hung
test, simulator failure, corrupt result bundle, or missing test discovery as
Green proof.

## Focused Test Throughput Gate

The focused test-speed target is evaluated from exactly three comparable warm
samples after one successful build-for-testing prebuild for the measured
scheme. Wrap the same focused-runner command three times with one batch, one
lane, and explicit `--state warm`, then gate only those three benchmark
summaries:

```bash
python3 scripts/ambitions-build-benchmark-report.py \
  sample-1.json sample-2.json sample-3.json \
  --target-seconds 30 \
  --require-samples 3 \
  --fail-on-miss \
  --output report.json
```

Gate evidence is valid only when all samples form one warm or cold cohort and
have the same nonempty `commit`, `package_path`, `package_identity`, and
`derived_data` values. The retained `lane`, `command`, and `scenario` fields
must also be nonempty and identical, and every sample must carry a distinct
nonempty `run_id` or `timestamp_utc`; duplicate sample evidence is rejected.
Missing or mixed identity, mixed warm/cold state, replayed evidence, or mixed
cohort fields is invalid evidence and exits `2`. Missing/unreadable files,
malformed JSON, non-object sample entries, and any `exit_code` that is not an
exact JSON integer are also invalid evidence; fractional or boolean exit values
must never be coerced to zero. A sample-count miss, any exact-integer nonzero
command exit, or a median above the target writes the report and exits `1`. A
met gate exits `0`. `--fail-on-miss` requires `--require-samples`; omitting
both options keeps the reporter's informative warm/cold aggregation behavior.

The median is the binding speed threshold. The report also records every
duration and exit plus the worst duration for diagnosis. For example,
`20, 30, 90` meets a 30-second median target while still reporting the
90-second outlier. Each benchmark sample must also link to the corresponding
focused-runner summary showing at least one executed test; the timing report
does not replace executed-test proof.

Cache-invalidated build-for-testing is a separate optimization lane. Do not
mix the measured 439-second cold rebuild or any other cold/cache-invalidated
sample into a warm focused-test cohort. Prebuild duration, cold rebuild
duration, warm module-test duration, and warm hosted-test duration remain
separate reports with separate claims.

## Simulator Preflight Contention Policy

`scripts/ambitions-xcode-sim-health.sh --json` is a strict preflight. It must
fail with `failure_category: "xcode_process_active"` when an Ambitions-owned
Xcode lane is already active. A preflight that reports active Ambitions
`xcodebuild`, XcodeBuildMCP, strict-build, Swift compiler, or XCTest processes
must not be treated as Green simulator/tooling health.

Use this only for explicit cleanup of repo-owned validation lanes:

```bash
scripts/ambitions-xcode-sim-health.sh --repair --kill-active-xcode --json --timeout 30s
```

That repair path terminates matching Ambitions Xcode process trees, shuts down
extra booted simulators, terminates the Ambitions app in booted simulators, and
boots the selected simulator. It is intentionally scoped to Ambitions/Xcode
commands and should not be generalized to unrelated user builds.

## XcodeBuildMCP Transport Policy

Codex XcodeBuildMCP transport for this repo must launch through:

```bash
scripts/ambitions-xcodebuildmcp-stdio.sh
```

The wrapper pins `xcodebuildmcp@2.6.2`, starts from the Ambitions repo root so
`.xcodebuildmcp/config.yaml` is loaded, uses `/Applications/Xcode.app`, and
excludes the invalid `logging` workflow from the Build iOS Apps plugin manifest.
Startup must never perform peer cleanup. Transport startup is a stdio contract:
the wrapper may install the pinned package if missing, then it must exec the MCP
server without killing sibling processes. Explicit maintenance cleanup is:

```bash
scripts/ambitions-xcodebuildmcp-stdio.sh --cleanup-peers-and-exit
```

That maintenance mode may only target exact `xcodebuildmcp` executable process
shapes, not arbitrary shell command lines that happen to mention
`xcodebuildmcp`. Do not run it while an active Codex host is expected to keep
using an already-open `xcodebuildmcp` client; restart/reload the host after
intentional cleanup.

The expected transport proof is a direct JSON-RPC `tools/call` for
`session_show_defaults` returning the `ambitions-ios` profile with
`iPhone 17 Pro Max` and the active `simulatorId` from `.xcodebuildmcp/config.yaml`.

Use this probe for current repo proof:

```bash
scripts/ambitions-xcodebuildmcp-probe.py --json
```

If the in-process Codex tool namespace still reports `Transport closed` after
the wrapper and manifests are patched, treat that as a running-host stale
transport until the Codex app-server reloads. Do not treat the stale live
namespace as evidence that the repo wrapper command is invalid.

Do not use XcodeBuildMCP `build` or `test` tool calls as the primary proof lane
for broad Ambitions validation. The MCP call can return a tool-level timeout
while its child `xcodebuild` continues compiling. Broad build and test proof must
come from the retained shell wrappers above, which own wall-clock bounds, logs,
result bundles, summaries, failure classification, and targeted cleanup. Use
XcodeBuildMCP for simulator/session defaults, install/launch, screenshots,
runtime UI inspection, and focused UI automation where the tool call itself is
the intended interaction proof.

## UI Screenshot Timeout Policy

The AMB-962 helper is:

```bash
scripts/ambitions-run-ui-screenshot-matrix.sh --batch <BATCH>
```

The helper uses:

- destination: the `scripts/ambitions-xcode-sim-health.sh` selected simulator UDID by default, or an explicit `--destination` override;
- test: `AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix`;
- result bundle: `.codex/xcode-results/<batch>/<timestamp>-AMB962.xcresult`;
- extraction: `scripts/ambitions-xcode-result-extract.sh --result <bundle> --output-dir <extract-dir>`;
- bounded execution: `scripts/ambitions-bounded-xcodebuild.sh`;
- retry behavior: retry once only after `xcrun simctl shutdown all`, and only when the first attempt times out.

Local `.codex` result and screenshot paths are local working evidence for
validation triage. They are not visual acceptance by themselves.

If the first UI screenshot matrix run times out, extract the partial result bundle if it exists and record the attempt as an infrastructure timeout. Then retry once after simulator shutdown.

If the retry times out or fails, close the train Yellow. Do not continue rerunning.

If a UI screenshot matrix passes only after exceeding the timeout policy, it is not acceptable proof for Green.

## Local Xcode Timeout Flags

The installed local Xcode reports support for:

- `-test-timeouts-enabled YES|NO`
- `-default-test-execution-time-allowance SECONDS`
- `-maximum-test-execution-time-allowance SECONDS`

The AMB-962 helper detects these flags from `xcodebuild -help` and adds them when available. These flags are per-test execution allowances; they do not replace the wrapper's wall-clock timeout.
