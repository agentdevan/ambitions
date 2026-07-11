import json
import os
import re
import subprocess
import tempfile
import time
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SIM_HEALTH = REPO_ROOT / "scripts/ambitions-xcode-sim-health.sh"
BOUNDED_XCODEBUILD = REPO_ROOT / "scripts/ambitions-bounded-xcodebuild.sh"
CLASSIFIER = REPO_ROOT / "scripts/ambitions-xcode-failure-classifier.py"
FOCUSED_RUNNER = REPO_ROOT / "scripts/ambitions-xcode-test-focused.sh"
MCP_CONFIG = REPO_ROOT / ".xcodebuildmcp/config.yaml"

MCP_UDID = "DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6"
SECOND_UDID = "11111111-2222-3333-4444-555555555555"


def device_listing(*rows: tuple[str, str, str]) -> str:
    body = ["== Devices ==", "-- iOS 26.0 --"]
    body.extend(f"    {name} ({udid}) ({state})" for name, udid, state in rows)
    return "\n".join(body)


class RunnerReliabilityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.xcrun_log = self.root / "xcrun.log"
        self.xcodebuild_log = self.root / "xcodebuild.log"
        self.booted_marker = self.root / "booted"
        self._write_executable(
            "xcrun",
            r"""#!/bin/sh
set -eu
printf '%s\n' "$*" >> "$FAKE_XCRUN_LOG"
if [ "${1:-}" != "simctl" ]; then
  exit 2
fi
shift
case "$*" in
  "list devices available")
    printf '%s\n' "$FAKE_DEVICES_AVAILABLE"
    ;;
  "list devices")
    if [ -f "$FAKE_BOOTED_MARKER" ] && [ -n "${FAKE_ALL_DEVICES_AFTER_BOOT:-}" ]; then
      printf '%s\n' "$FAKE_ALL_DEVICES_AFTER_BOOT"
    else
      printf '%s\n' "$FAKE_ALL_DEVICES"
    fi
    ;;
  boot\ *)
    : > "$FAKE_BOOTED_MARKER"
    exit "${FAKE_BOOT_EXIT:-0}"
    ;;
  bootstatus\ *)
    exit "${FAKE_BOOTSTATUS_EXIT:-0}"
    ;;
  terminate\ *|shutdown\ *|erase\ *)
    exit 0
    ;;
  *)
    exit 2
    ;;
esac
""",
        )

    def tearDown(self):
        self.temp.cleanup()

    def _write_executable(self, name: str, body: str) -> Path:
        path = self.bin / name
        path.write_text(body, encoding="utf-8")
        path.chmod(0o755)
        return path

    def health_env(self, available: str, all_devices: str | None = None) -> dict[str, str]:
        env = os.environ.copy()
        env["PATH"] = str(self.bin) + os.pathsep + env["PATH"]
        env["FAKE_XCRUN_LOG"] = str(self.xcrun_log)
        env["FAKE_BOOTED_MARKER"] = str(self.booted_marker)
        env["FAKE_DEVICES_AVAILABLE"] = available
        env["FAKE_ALL_DEVICES"] = all_devices or available
        env.pop("AMBITIONS_SIM_UDID", None)
        env.pop("AMBITIONS_SIM_NAME", None)
        return env

    def run_health(self, env: dict[str, str], *args: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        result = subprocess.run(
            ["bash", str(SIM_HEALTH), "--json", "--allow-active-xcode", *args],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=10,
        )
        output_lines = result.stdout.strip().splitlines()
        payload = json.loads(output_lines[-1]) if output_lines else {}
        return result, payload

    def test_explicit_available_udid_wins_across_duplicate_names(self):
        devices = device_listing(
            ("iPhone 17 Pro Max", MCP_UDID, "Shutdown"),
            ("iPhone 17 Pro Max", SECOND_UDID, "Booted"),
        )
        env = self.health_env(devices)
        env["AMBITIONS_SIM_UDID"] = SECOND_UDID

        result, payload = self.run_health(env)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload["udid"], SECOND_UDID)
        self.assertEqual(payload.get("selection_source"), "environment_udid")
        self.assertEqual(payload.get("exact_name_match_count"), 2)

    def test_configured_udid_disambiguates_duplicate_exact_names(self):
        devices = device_listing(
            ("iPhone 17 Pro Max", MCP_UDID, "Booted"),
            ("iPhone 17 Pro Max", SECOND_UDID, "Shutdown"),
        )
        env = self.health_env(devices)

        result, payload = self.run_health(env)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(payload["udid"], MCP_UDID)
        self.assertEqual(payload.get("selection_source"), "mcp_profile_udid")
        self.assertEqual(payload.get("exact_name_match_count"), 2)

    def test_duplicate_exact_name_without_udid_fails_structurally(self):
        devices = device_listing(
            ("iPhone 17", MCP_UDID, "Booted"),
            ("iPhone 17", SECOND_UDID, "Shutdown"),
        )
        env = self.health_env(devices)
        env["AMBITIONS_SIM_NAME"] = "iPhone 17"

        result, payload = self.run_health(env)

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload["failure_category"], "simulator_name_ambiguous")
        self.assertEqual(payload.get("exact_name_match_count"), 2)
        self.assertEqual(payload.get("selection_source"), "environment_name")

    def test_iPhone_17_does_not_match_iPhone_17e(self):
        devices = device_listing(("iPhone 17e", SECOND_UDID, "Booted"))
        env = self.health_env(devices)
        env["AMBITIONS_SIM_NAME"] = "iPhone 17"

        result, payload = self.run_health(env)

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("failure_category"), "simulator_not_available")
        self.assertEqual(payload.get("exact_name_match_count"), 0)

    def test_missing_name_returns_structured_json(self):
        devices = device_listing(("iPhone 17e", SECOND_UDID, "Booted"))
        env = self.health_env(devices)
        env["AMBITIONS_SIM_NAME"] = "Missing iPhone"

        result, payload = self.run_health(env)

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload.get("status"), "failed")
        self.assertEqual(payload.get("failure_category"), "simulator_not_available")
        self.assertEqual(payload.get("sim_name"), "Missing iPhone")
        self.assertEqual(payload.get("selection_source"), "environment_name")

    def test_repair_requires_successful_bounded_bootstatus(self):
        before = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Shutdown"))
        after = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.health_env(before)
        env["FAKE_ALL_DEVICES_AFTER_BOOT"] = after
        env["FAKE_BOOTSTATUS_EXIT"] = "9"

        result, payload = self.run_health(env, "--repair", "--timeout", "2s")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload["failure_category"], "simulator_boot_failure")
        self.assertIn(f"simctl bootstatus {MCP_UDID} -b", self.xcrun_log.read_text())

    def install_fake_timeout_and_xcodebuild(self, xcodebuild_body: str) -> dict[str, str]:
        timeout_body = """#!/bin/sh
set -eu
if [ "${1:-}" = "-k" ]; then
  shift 2
fi
shift
exec "$@"
"""
        self._write_executable("gtimeout", timeout_body)
        self._write_executable("timeout", timeout_body)
        self._write_executable("xcodebuild", "#!/bin/sh\nset -eu\n" + xcodebuild_body)
        env = os.environ.copy()
        env["PATH"] = str(self.bin) + os.pathsep + env["PATH"]
        env["AMBITIONS_XCODE_LANE_ROOT"] = str(self.root / "lane")
        return env

    def focused_env(self) -> dict[str, str]:
        devices = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.install_fake_timeout_and_xcodebuild(
            r'''printf 'CALL\n' >> "$FAKE_XCODEBUILD_LOG"
result_bundle=""
previous=""
for argument in "$@"; do
  printf 'ARG=%s\n' "$argument" >> "$FAKE_XCODEBUILD_LOG"
  if [ "$previous" = "-resultBundlePath" ]; then
    result_bundle="$argument"
  fi
  previous="$argument"
done
if [ -n "$result_bundle" ]; then
  mkdir -p "$result_bundle"
  : > "$result_bundle/Info.plist"
fi
echo 'Testing started'
echo "Executed ${FAKE_EXECUTED_TESTS:-2} tests, with 0 failures (0 unexpected) in 0.001 (0.002) seconds"
'''
        )
        self._write_executable("xcodegen", "#!/bin/sh\nexit 0\n")
        self._write_executable("xcbeautify", "#!/bin/sh\ncat\n")
        self._write_executable("xcparse", "#!/bin/sh\nexit 0\n")
        env.update(self.health_env(devices))
        env["PATH"] = str(self.bin) + os.pathsep + os.environ["PATH"]
        env["AMBITIONS_SIM_UDID"] = MCP_UDID
        env["AMBITIONS_SIM_HEALTH_ALLOW_ACTIVE_XCODE"] = "1"
        env["AMBITIONS_XCODE_LANE_ROOT"] = str(self.root / "focused-lane")
        env["FAKE_XCODEBUILD_LOG"] = str(self.xcodebuild_log)
        return env

    def run_focused(self, env: dict[str, str], batch: str, *filter_args: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        result = subprocess.run(
            [
                "bash",
                str(FOCUSED_RUNNER),
                "--batch",
                batch,
                "--results-dir",
                str(self.root / "results"),
                "--logs-dir",
                str(self.root / "logs"),
                "--summaries-dir",
                str(self.root / "summaries"),
                "--timeout",
                "10s",
                "--test-launch-timeout",
                "3s",
                "--without-building",
                "--skip-prebuild",
                *filter_args,
            ],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=12,
        )
        summaries = sorted((self.root / "summaries" / batch).glob("*/focused-test-summary.json"))
        payload = json.loads(summaries[-1].read_text(encoding="utf-8")) if summaries else {}
        return result, payload

    def xcodebuild_calls(self) -> list[list[str]]:
        calls: list[list[str]] = []
        for line in self.xcodebuild_log.read_text(encoding="utf-8").splitlines() if self.xcodebuild_log.exists() else []:
            if line == "CALL":
                calls.append([])
            elif line.startswith("ARG=") and calls:
                calls[-1].append(line.removeprefix("ARG="))
        return calls

    def run_bounded(self, env: dict[str, str], log: Path, launch_timeout: str) -> tuple[subprocess.CompletedProcess[str], float]:
        started = time.monotonic()
        result = subprocess.run(
            [
                "bash",
                str(BOUNDED_XCODEBUILD),
                "--timeout",
                "10s",
                "--kill-after",
                "1s",
                "--test-launch-timeout",
                launch_timeout,
                "--log",
                str(log),
                "--",
                "test-without-building",
            ],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=8,
        )
        return result, time.monotonic() - started

    def test_missing_test_start_hits_30_second_launcher_deadline(self):
        env = self.install_fake_timeout_and_xcodebuild("sleep 4\nexit 0\n")
        log = self.root / "missing-start.log"

        result, elapsed = self.run_bounded(env, log, "1s")

        self.assertEqual(result.returncode, 124, result.stdout + result.stderr)
        self.assertLess(elapsed, 3.0)
        self.assertIn("XCODEBUILD_TEST_LAUNCH_TIMEOUT=1", log.read_text())
        classified = subprocess.run(
            ["python3", str(CLASSIFIER), "--result", "XCODEBUILD_TEST_LAUNCH_TIMEOUT=1", "--json"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(json.loads(classified.stdout)["classification"], "simulator_launcher_failure")

    def test_launcher_signature_stops_sleeping_owned_build_early(self):
        env = self.install_fake_timeout_and_xcodebuild(
            "echo 'IDELaunchiPhoneSimulatorLauncher: NSMachErrorDomain Code: -308'\n"
            "sleep 5\n"
            "exit 0\n"
        )
        log = self.root / "launcher-signature.log"

        result, elapsed = self.run_bounded(env, log, "5s")

        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertLess(elapsed, 4.0)
        classified = subprocess.run(
            ["python3", str(CLASSIFIER), "--log", str(log), "--json"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(json.loads(classified.stdout)["classification"], "simulator_launcher_failure")

    def test_launcher_signature_after_test_start_stops_owned_build_and_preserves_unrelated_process(self):
        env = self.install_fake_timeout_and_xcodebuild(
            "echo 'Testing started'\n"
            "sleep 0.3\n"
            "echo 'IDELaunchiPhoneSimulatorLauncher: NSMachErrorDomain Code: -308'\n"
            "sleep 5\n"
            "exit 0\n"
        )
        log = self.root / "post-start-launcher-signature.log"
        sentinel = subprocess.Popen(["/bin/sleep", "30"])
        try:
            result, elapsed = self.run_bounded(env, log, "5s")

            self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
            self.assertLess(elapsed, 4.0)
            self.assertIn("XCODEBUILD_SIMULATOR_LAUNCH_FAILURE=1", log.read_text())
            self.assertIsNone(sentinel.poll(), "unrelated sentinel process was terminated")
        finally:
            if sentinel.poll() is None:
                sentinel.terminate()
            try:
                sentinel.wait(timeout=2)
            except subprocess.TimeoutExpired:
                sentinel.kill()
                sentinel.wait(timeout=2)

    def test_mcp_and_retained_runners_use_canonical_cache(self):
        canonical = str(REPO_ROOT / ".codex/DerivedData/Ambitions")
        config = MCP_CONFIG.read_text(encoding="utf-8")
        focused = FOCUSED_RUNNER.read_text(encoding="utf-8")

        self.assertIn(f"derivedDataPath: {canonical}", config)
        self.assertNotIn("output/DerivedData-XcodeBuildMCP", config)
        self.assertIn('DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"', focused)
        self.assertIn('--test-launch-timeout "$TEST_LAUNCH_TIMEOUT"', focused)

    def test_focused_runner_batches_repeated_only_testing_filters_in_one_xcodebuild(self):
        env = self.focused_env()
        filters = [
            "AmbitionsModuleTests/FirstModuleTests",
            "AmbitionsModuleTests/SecondModuleTests/testOne",
            "AmbitionsModuleTests/ThirdModuleTests",
        ]
        args = [item for test_filter in filters for item in ("--only-testing", test_filter)]

        result, summary = self.run_focused(env, "module-batch", *args)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        calls = self.xcodebuild_calls()
        self.assertEqual(len(calls), 1)
        self.assertEqual(
            [arg.removeprefix("-only-testing:") for arg in calls[0] if arg.startswith("-only-testing:")],
            filters,
        )
        self.assertEqual(summary["scheme"], "AmbitionsModuleTests")
        self.assertEqual(summary["proof_scope"], "module-focused-fast")
        self.assertEqual(summary["test"], ",".join(filters))
        self.assertEqual(summary["tests"], filters)
        self.assertEqual(summary["requested_filter_count"], 3)
        self.assertGreater(summary["executed_tests"], 0)

    def test_focused_runner_preserves_single_test_and_only_testing_behavior(self):
        env = self.focused_env()
        cases = (
            ("single-test", "--test", "AmbitionsTests/SingleTestFormTests", "AmbitionsUnitTests"),
            ("single-only", "--only-testing", "AmbitionsUITests/SingleOnlyTestingFormTests", "AmbitionsUITests"),
        )

        for batch, option, test_filter, expected_scheme in cases:
            with self.subTest(option=option):
                result, summary = self.run_focused(env, batch, option, test_filter)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(summary["scheme"], expected_scheme)
                self.assertEqual(summary["test"], test_filter)
                self.assertEqual(summary["tests"], [test_filter])
                self.assertEqual(summary["requested_filter_count"], 1)
                expected_slug = re.sub(r"[^A-Za-z0-9._-]", "-", test_filter)[:80]
                self.assertIn(f"-{expected_slug}-", summary["run_id"])
        self.assertEqual(len(self.xcodebuild_calls()), 2)

    def test_repeated_test_form_uses_order_sensitive_multi_filter_slug(self):
        env = self.focused_env()
        first = "AmbitionsTests/StableFirstTests"
        orders = (
            [first, "AmbitionsTests/SecondTests", "AmbitionsTests/ThirdTests"],
            [first, "AmbitionsTests/ThirdTests", "AmbitionsTests/SecondTests"],
        )
        slugs = []

        for index, filters in enumerate(orders):
            args = [item for test_filter in filters for item in ("--test", test_filter)]
            result, summary = self.run_focused(env, f"ordered-{index}", *args)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(summary["tests"], filters)
            slug_match = re.search(r"-(AmbitionsTests-StableFirstTests-plus-2-[0-9a-f]{10})-", summary["run_id"])
            self.assertIsNotNone(slug_match, summary["run_id"])
            slugs.append(slug_match.group(1))

        self.assertNotEqual(slugs[0], slugs[1])
        self.assertEqual(len(self.xcodebuild_calls()), 2)

    def test_multi_filter_run_still_requires_positive_aggregate_discovery(self):
        env = self.focused_env()
        env["FAKE_EXECUTED_TESTS"] = "0"

        result, summary = self.run_focused(
            env,
            "zero-discovery",
            "--only-testing",
            "AmbitionsTests/FirstTests",
            "--only-testing",
            "AmbitionsTests/SecondTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["failure_category"], "test_discovery_failure")
        self.assertEqual(summary["executed_tests"], 0)
        self.assertEqual(summary["requested_filter_count"], 2)
        self.assertEqual(len(self.xcodebuild_calls()), 1)

    def test_invalid_filter_batches_fail_before_xcodebuild(self):
        env = self.focused_env()
        cases = (
            ("mixed-forms", ("--test", "AmbitionsTests/OneTests", "--only-testing", "AmbitionsTests/TwoTests"), "cannot mix"),
            ("empty-filter", ("--test", ""), "must not be empty"),
            (
                "heterogeneous-auto",
                ("--only-testing", "AmbitionsTests/OneTests", "--only-testing", "AmbitionsUITests/TwoTests"),
                "same test target prefix",
            ),
            (
                "scheme-mismatch",
                ("--scheme", "AmbitionsUnitTests", "--test", "AmbitionsUITests/TwoTests"),
                "does not accept",
            ),
        )

        for batch, args, expected_error in cases:
            with self.subTest(batch=batch):
                result, summary = self.run_focused(env, batch, *args)
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertEqual(summary, {})
                self.assertIn(expected_error, result.stderr)
        self.assertEqual(self.xcodebuild_calls(), [])


if __name__ == "__main__":
    unittest.main()
