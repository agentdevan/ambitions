import json
import os
import re
import signal
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
BUILD_FOR_TESTING = REPO_ROOT / "scripts/ambitions-xcode-build-for-testing.sh"
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
        self.xcparse_log = self.root / "xcparse.log"
        self.booted_marker = self.root / "booted"
        self._write_executable(
            "xcrun",
            r"""#!/bin/sh
set -eu
printf '%s\n' "$*" >> "$FAKE_XCRUN_LOG"
if [ "${1:-}" != "simctl" ]; then
  if [ "${1:-}" = "xcresulttool" ]; then
    printf '%s\n' "${FAKE_XCRESULT_TESTS_JSON:?}"
    exit "${FAKE_XCRESULT_EXIT:-0}"
  fi
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
  terminate\ *)
    exit 0
    ;;
  shutdown\ *)
    exit "${FAKE_SHUTDOWN_EXIT:-0}"
    ;;
  erase\ *)
    exit "${FAKE_ERASE_EXIT:-0}"
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

    def test_health_uses_one_simctl_device_inventory(self):
        devices = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.health_env(devices)

        result, payload = self.run_health(env)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        inventory_calls = [
            line
            for line in self.xcrun_log.read_text(encoding="utf-8").splitlines()
            if line.startswith("simctl list devices")
        ]
        self.assertEqual(inventory_calls, ["simctl list devices"])

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

    def test_erase_selected_shutdowns_before_erasing_and_rebooting(self):
        before = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        after = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.health_env(before)
        env["AMBITIONS_SIM_UDID"] = MCP_UDID
        env["FAKE_ALL_DEVICES_AFTER_BOOT"] = after

        result, payload = self.run_health(env, "--repair", "--erase-selected", "--timeout", "2s")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        calls = self.xcrun_log.read_text(encoding="utf-8").splitlines()
        shutdown_index = calls.index(f"simctl shutdown {MCP_UDID}")
        erase_index = calls.index(f"simctl erase {MCP_UDID}")
        boot_index = calls.index(f"simctl boot {MCP_UDID}")
        self.assertLess(shutdown_index, erase_index)
        self.assertLess(erase_index, boot_index)
        self.assertTrue(payload["erase_selected"])

    def test_erase_selected_reports_erase_failure(self):
        devices = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.health_env(devices)
        env["AMBITIONS_SIM_UDID"] = MCP_UDID
        env["FAKE_ERASE_EXIT"] = "9"

        result, payload = self.run_health(env, "--repair", "--erase-selected", "--timeout", "2s")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(payload["failure_category"], "simulator_erase_failure")

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

    def install_signal_process_tree(self) -> tuple[dict[str, str], list[Path]]:
        pid_files = [self.root / f"owned-{name}.pid" for name in ("root", "child", "grandchild")]
        env = self.install_fake_timeout_and_xcodebuild(
            r'''printf '%s\n' "$$" > "$FAKE_OWNED_ROOT_PID_FILE"
(
  grandchild_pid=""
  cleanup_child() {
    if [ -n "$grandchild_pid" ]; then
      kill -TERM "$grandchild_pid" 2>/dev/null || true
      wait "$grandchild_pid" 2>/dev/null || true
    fi
    exit 0
  }
  trap cleanup_child INT TERM
  sleep 30 &
  grandchild_pid=$!
  printf '%s\n' "$grandchild_pid" > "$FAKE_OWNED_GRANDCHILD_PID_FILE"
  wait "$grandchild_pid"
) &
child_pid=$!
printf '%s\n' "$child_pid" > "$FAKE_OWNED_CHILD_PID_FILE"
trap 'exit 0' INT TERM
wait "$child_pid"
'''
        )
        env["FAKE_OWNED_ROOT_PID_FILE"] = str(pid_files[0])
        env["FAKE_OWNED_CHILD_PID_FILE"] = str(pid_files[1])
        env["FAKE_OWNED_GRANDCHILD_PID_FILE"] = str(pid_files[2])
        return env, pid_files

    @staticmethod
    def pid_is_live(pid: int) -> bool:
        try:
            os.kill(pid, 0)
        except ProcessLookupError:
            return False
        return True

    def assert_signal_cleans_owned_tree(
        self,
        sig: signal.Signals,
        expected_status: int,
        *,
        monitor_test_launch: bool = False,
    ):
        env, pid_files = self.install_signal_process_tree()
        sentinel = subprocess.Popen(["/bin/sleep", "30"])
        monitor_args = ["--test-launch-timeout", "30s"] if monitor_test_launch else []
        runner = subprocess.Popen(
            [
                "bash",
                str(BOUNDED_XCODEBUILD),
                "--timeout",
                "30s",
                "--kill-after",
                "1s",
                *monitor_args,
                "--",
                "test-without-building",
            ],
            cwd=REPO_ROOT,
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        owned_pids: list[int] = []
        try:
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline and not all(path.exists() for path in pid_files):
                time.sleep(0.01)
            self.assertTrue(all(path.exists() for path in pid_files), "fake owned process tree did not start")
            owned_pids = [int(path.read_text(encoding="utf-8")) for path in pid_files]

            os.kill(runner.pid, sig)
            self.assertEqual(runner.wait(timeout=3), expected_status)

            deadline = time.monotonic() + 1
            while time.monotonic() < deadline and any(self.pid_is_live(pid) for pid in owned_pids):
                time.sleep(0.01)
            self.assertEqual(
                [pid for pid in owned_pids if self.pid_is_live(pid)],
                [],
                "owned runner descendants survived signal cleanup",
            )
            self.assertIsNone(sentinel.poll(), "unrelated sentinel process was terminated")
        finally:
            for pid in reversed(owned_pids):
                try:
                    os.kill(pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            if runner.poll() is None:
                runner.kill()
            try:
                runner.wait(timeout=2)
            except subprocess.TimeoutExpired:
                pass
            if sentinel.poll() is None:
                sentinel.terminate()
            try:
                sentinel.wait(timeout=2)
            except subprocess.TimeoutExpired:
                sentinel.kill()
                sentinel.wait(timeout=2)

    def test_sigint_terminates_and_reaps_only_owned_runner_descendants(self):
        self.assert_signal_cleans_owned_tree(signal.SIGINT, 130, monitor_test_launch=True)

    def test_sigterm_terminates_and_reaps_only_owned_runner_descendants(self):
        self.assert_signal_cleans_owned_tree(signal.SIGTERM, 143)

    def focused_env(self) -> dict[str, str]:
        devices = device_listing(("iPhone 17 Pro Max", MCP_UDID, "Booted"))
        env = self.install_fake_timeout_and_xcodebuild(
            r'''printf 'CALL\n' >> "$FAKE_XCODEBUILD_LOG"
call_count="$(grep -c '^CALL$' "$FAKE_XCODEBUILD_LOG")"
result_bundle=""
previous=""
for argument in "$@"; do
  printf 'ARG=%s\n' "$argument" >> "$FAKE_XCODEBUILD_LOG"
  if [ "$previous" = "-resultBundlePath" ]; then
    result_bundle="$argument"
  fi
  previous="$argument"
done
launch_failure=0
if [ "${FAKE_ALWAYS_LAUNCH_FAILURE:-0}" = "1" ] || { [ "${FAKE_FIRST_LAUNCH_FAILURE:-0}" = "1" ] && [ "$call_count" = "1" ]; }; then
  launch_failure=1
fi
if [ -n "$result_bundle" ] && [ "${FAKE_SKIP_RESULT_BUNDLE:-0}" != "1" ]; then
  mkdir -p "$result_bundle"
  if [ "$launch_failure" != "1" ] && [ "${FAKE_CORRUPT_RESULT_BUNDLE:-0}" != "1" ]; then
    : > "$result_bundle/Info.plist"
  fi
fi
if [ "$launch_failure" = "1" ]; then
  echo 'XCODEBUILD_TEST_LAUNCH_TIMEOUT=1'
  exit 124
fi
echo 'Testing started'
echo "Executed ${FAKE_EXECUTED_TESTS:-2} tests, with 0 failures (0 unexpected) in 0.001 (0.002) seconds"
if [ "${FAKE_TEST_FAILURE:-0}" = "1" ]; then
  echo 'Testing failed:'
fi
exit "${FAKE_XCODEBUILD_EXIT:-0}"
'''
        )
        self._write_executable("xcodegen", "#!/bin/sh\nexit 0\n")
        self._write_executable("xcbeautify", "#!/bin/sh\ncat\n")
        self._write_executable(
            "xcparse",
            "#!/bin/sh\nset -eu\nprintf '%s\\n' \"$*\" >> \"$FAKE_XCPARSE_LOG\"\n",
        )
        env.update(self.health_env(devices))
        env["PATH"] = str(self.bin) + os.pathsep + os.environ["PATH"]
        env["AMBITIONS_SIM_UDID"] = MCP_UDID
        env["AMBITIONS_SIM_HEALTH_ALLOW_ACTIVE_XCODE"] = "1"
        env["AMBITIONS_XCODE_LANE_ROOT"] = str(self.root / "focused-lane")
        env["FAKE_XCODEBUILD_LOG"] = str(self.xcodebuild_log)
        env["FAKE_XCPARSE_LOG"] = str(self.xcparse_log)
        return env

    def run_focused(self, env: dict[str, str], batch: str, *filter_args: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        selected = [
            filter_args[index + 1]
            for index, value in enumerate(filter_args[:-1])
            if value in {"--only-testing", "--test"}
        ]
        bundles: dict[str, dict[str, list[str]]] = {}
        for test_filter in selected:
            parts = test_filter.split("/")
            target = parts[0]
            suite = parts[1] if len(parts) > 1 else "TargetWideTests"
            method = parts[2] if len(parts) > 2 else "testOne"
            bundles.setdefault(target, {}).setdefault(suite, []).append(method)
        test_bundles = []
        for target, suites in bundles.items():
            suite_nodes = []
            for suite, methods in suites.items():
                suite_nodes.append({
                    "name": suite,
                    "nodeType": "Test Suite",
                    "children": [
                        {
                            "name": f"{method}()",
                            "nodeIdentifier": f"{suite}/{method}()",
                            "nodeType": "Test Case",
                            "result": "Passed",
                        }
                        for method in methods
                    ],
                })
            test_bundles.append({
                "name": target,
                "nodeType": "UI test bundle" if target.endswith("UITests") else "Unit test bundle",
                "children": suite_nodes,
            })
        if env.get("FAKE_XCRESULT_TESTS_JSON_LOCKED") != "1":
            env["FAKE_XCRESULT_TESTS_JSON"] = json.dumps({
                "devices": [{"deviceId": MCP_UDID}],
                "testNodes": [{"name": "Ambitions", "nodeType": "Test Plan", "children": test_bundles}],
            })
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

    def test_batched_focused_run_requires_every_selector_in_xcresult(self):
        env = self.focused_env()
        env["FAKE_XCRESULT_TESTS_JSON"] = json.dumps({
            "devices": [{"deviceId": MCP_UDID}],
            "testNodes": [{
                "name": "Ambitions",
                "nodeType": "Test Plan",
                "children": [{
                    "name": "AmbitionsTests",
                    "nodeType": "Unit test bundle",
                    "children": [{
                        "name": "FirstTests",
                        "nodeType": "Test Suite",
                        "children": [{
                            "name": "testOne()",
                            "nodeIdentifier": "FirstTests/testOne()",
                            "nodeType": "Test Case",
                            "result": "Passed",
                        }],
                    }],
                }],
            }],
        })
        env["FAKE_XCRESULT_TESTS_JSON_LOCKED"] = "1"

        result, payload = self.run_focused(
            env,
            "SELECTOR-PROOF",
            "--scheme",
            "AmbitionsUnitTests",
            "--only-testing",
            "AmbitionsTests/FirstTests",
            "--only-testing",
            "AmbitionsTests/MissingTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(payload["failure_category"], "test_selector_not_executed")
        extraction = json.loads(Path(payload["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["matched_test_filters"], ["AmbitionsTests/FirstTests"])
        self.assertEqual(extraction["missing_test_filters"], ["AmbitionsTests/MissingTests"])

    def xcodebuild_calls(self) -> list[list[str]]:
        calls: list[list[str]] = []
        for line in self.xcodebuild_log.read_text(encoding="utf-8").splitlines() if self.xcodebuild_log.exists() else []:
            if line == "CALL":
                calls.append([])
            elif line.startswith("ARG=") and calls:
                calls[-1].append(line.removeprefix("ARG="))
        return calls

    def xcparse_calls(self) -> list[str]:
        return self.xcparse_log.read_text(encoding="utf-8").splitlines() if self.xcparse_log.exists() else []

    def run_build_for_testing(self, env: dict[str, str], batch: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        result = subprocess.run(
            [
                "bash",
                str(BUILD_FOR_TESTING),
                "--batch",
                batch,
                "--scheme",
                "AmbitionsUnitTests",
                "--results-dir",
                str(self.root / "results"),
                "--logs-dir",
                str(self.root / "logs"),
                "--summaries-dir",
                str(self.root / "summaries"),
                "--timeout",
                "10s",
            ],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=12,
        )
        summaries = sorted((self.root / "summaries" / batch).glob("*/build-for-testing-summary.json"))
        payload = json.loads(summaries[-1].read_text(encoding="utf-8")) if summaries else {}
        return result, payload

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

    def test_launch_timeout_marker_survives_late_pipeline_log_flush(self):
        env = self.install_fake_timeout_and_xcodebuild("sleep 4\nexit 0\n")
        self._write_executable(
            "tee",
            r'''#!/bin/sh
set -eu
if [ "${1:-}" = "-a" ]; then
  exec /usr/bin/tee "$@"
fi
target="${1:?missing log path}"
trap 'printf "late pipeline flush\n" > "$target"; exit 143' TERM
while :; do
  sleep 0.05
done
''',
        )
        log = self.root / "late-pipeline-flush.log"

        result, elapsed = self.run_bounded(env, log, "1s")

        self.assertEqual(result.returncode, 124, result.stdout + result.stderr)
        self.assertLess(elapsed, 3.0)
        log_text = log.read_text(encoding="utf-8")
        self.assertIn("late pipeline flush", log_text)
        self.assertIn("XCODEBUILD_TEST_LAUNCH_TIMEOUT=1", log_text)
        self.assertNotIn("XCODEBUILD_TIMEOUT_NO_TEST_LOG=1", log_text)
        classified = subprocess.run(
            ["python3", str(CLASSIFIER), "--log", str(log), "--json"],
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
        prebuild = BUILD_FOR_TESTING.read_text(encoding="utf-8")

        self.assertIn(f"derivedDataPath: {canonical}", config)
        self.assertNotIn("output/DerivedData-XcodeBuildMCP", config)
        self.assertIn('DERIVED_DATA="$REPO_ROOT/.codex/DerivedData/Ambitions"', focused)
        self.assertIn('--test-launch-timeout "$TEST_LAUNCH_TIMEOUT"', focused)
        self.assertIn("-skipPackageUpdates", focused)
        self.assertIn("-skipPackageUpdates", prebuild)

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

    def test_focused_retry_isolates_initial_launcher_failure_artifacts(self):
        env = self.focused_env()
        env["FAKE_FIRST_LAUNCH_FAILURE"] = "1"

        result, summary = self.run_focused(
            env,
            "isolated-launch-retry",
            "--test",
            "AmbitionsModuleTests/RetryArtifactTests",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(self.xcodebuild_calls()), 2)
        self.assertTrue(summary["retry_performed"])
        self.assertEqual(summary["initial_failure_category"], "simulator_launcher_failure")
        initial_log = Path(summary["initial_log_file"])
        initial_result = Path(summary["initial_result_bundle"])
        final_result = Path(summary["result_bundle"])
        self.assertIn("XCODEBUILD_TEST_LAUNCH_TIMEOUT=1", initial_log.read_text(encoding="utf-8"))
        self.assertTrue(initial_result.exists())
        self.assertFalse((initial_result / "Info.plist").exists())
        self.assertTrue((final_result / "Info.plist").exists())
        self.assertEqual(summary["failure_category"], "passed")

    def test_repeated_launcher_failure_retains_precise_classification(self):
        env = self.focused_env()
        env["FAKE_ALWAYS_LAUNCH_FAILURE"] = "1"

        result, summary = self.run_focused(
            env,
            "repeated-launch-failure",
            "--test",
            "AmbitionsModuleTests/RepeatedLauncherFailureTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(len(self.xcodebuild_calls()), 2)
        self.assertTrue(summary["retry_performed"])
        self.assertEqual(summary["initial_failure_category"], "simulator_launcher_failure")
        self.assertEqual(summary["failure_category"], "simulator_launcher_failure")
        self.assertEqual(summary["executed_tests"], 0)

    def test_launcher_retry_boot_failure_retains_repair_classification(self):
        env = self.focused_env()
        env["FAKE_FIRST_LAUNCH_FAILURE"] = "1"
        env["FAKE_BOOTSTATUS_EXIT"] = "9"

        result, summary = self.run_focused(
            env,
            "launch-retry-boot-failure",
            "--test",
            "AmbitionsModuleTests/RetryBootFailureTests",
        )

        self.assertEqual(result.returncode, 22, result.stdout + result.stderr)
        self.assertEqual(len(self.xcodebuild_calls()), 1)
        self.assertTrue(summary["retry_performed"])
        self.assertEqual(summary["initial_failure_category"], "simulator_launcher_failure")
        self.assertEqual(summary["failure_category"], "simulator_boot_failure")
        self.assertEqual(summary["executed_tests"], 0)

    def test_focused_runner_auto_extraction_is_metadata_for_fast_lanes_and_full_for_ui(self):
        env = self.focused_env()
        cases = (
            ("module-auto-extract", "AmbitionsModuleTests/MetadataAutoTests", "metadata", 0),
            ("unit-auto-extract", "AmbitionsTests/MetadataAutoTests", "metadata", 0),
            ("ui-auto-extract", "AmbitionsUITests/FullAutoTests", "full", 4),
        )

        for batch, test_filter, expected_mode, expected_calls in cases:
            with self.subTest(batch=batch):
                self.xcparse_log.unlink(missing_ok=True)
                result, summary = self.run_focused(env, batch, "--test", test_filter)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(summary["requested_result_extraction_mode"], "auto")
                self.assertEqual(summary["result_extraction_mode"], expected_mode)
                self.assertEqual(len(self.xcparse_calls()), expected_calls)
                self.assertTrue(Path(summary["result_bundle"]).exists())
                extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
                self.assertEqual(extraction["extraction_mode"], expected_mode)
                self.assertTrue(extraction["result_bundle_retained"])

    def test_focused_runner_honors_explicit_metadata_and_full_extraction_overrides(self):
        env = self.focused_env()
        cases = (
            ("ui-metadata-override", "AmbitionsUITests/MetadataOverrideTests", "metadata", 0),
            ("module-full-override", "AmbitionsModuleTests/FullOverrideTests", "full", 4),
        )

        for batch, test_filter, mode, expected_calls in cases:
            with self.subTest(batch=batch):
                self.xcparse_log.unlink(missing_ok=True)
                result, summary = self.run_focused(
                    env,
                    batch,
                    "--result-extraction",
                    mode,
                    "--test",
                    test_filter,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(summary["requested_result_extraction_mode"], mode)
                self.assertEqual(summary["result_extraction_mode"], mode)
                self.assertEqual(len(self.xcparse_calls()), expected_calls)

    def test_failed_auto_focused_run_upgrades_to_full_extraction_for_diagnostics(self):
        env = self.focused_env()
        env["FAKE_TEST_FAILURE"] = "1"

        result, summary = self.run_focused(
            env,
            "failed-auto-extract",
            "--test",
            "AmbitionsModuleTests/FailedAutoExtractionTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["requested_result_extraction_mode"], "auto")
        self.assertEqual(summary["result_extraction_mode"], "full")
        self.assertEqual(len(self.xcparse_calls()), 4)
        extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["extraction_mode"], "full")

    def test_failed_explicit_metadata_focused_run_does_not_escalate_extraction(self):
        env = self.focused_env()
        env["FAKE_TEST_FAILURE"] = "1"

        result, summary = self.run_focused(
            env,
            "failed-explicit-metadata-extract",
            "--result-extraction",
            "metadata",
            "--test",
            "AmbitionsModuleTests/FailedExplicitMetadataExtractionTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["requested_result_extraction_mode"], "metadata")
        self.assertEqual(summary["result_extraction_mode"], "metadata")
        self.assertEqual(self.xcparse_calls(), [])
        extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["extraction_mode"], "metadata")

    def test_focused_success_requires_a_valid_retained_result_bundle(self):
        cases = (
            ("missing", "FAKE_SKIP_RESULT_BUNDLE", "missing_xcresult", False),
            ("corrupt", "FAKE_CORRUPT_RESULT_BUNDLE", "corrupt_xcresult", True),
        )

        for label, environment_key, expected_category, expected_retained in cases:
            with self.subTest(label=label):
                env = self.focused_env()
                env[environment_key] = "1"
                self.xcparse_log.unlink(missing_ok=True)

                result, summary = self.run_focused(
                    env,
                    f"focused-{label}-result-bundle",
                    "--test",
                    "AmbitionsModuleTests/ResultBundleRequiredTests",
                )

                self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
                self.assertEqual(summary["status"], "failed")
                self.assertEqual(summary["failure_category"], expected_category)
                self.assertEqual(summary["executed_tests"], 2)
                self.assertEqual(summary["result_bundle_retained"], expected_retained)
                self.assertEqual(self.xcparse_calls(), [])

    def test_build_for_testing_success_requires_a_valid_retained_result_bundle(self):
        cases = (
            ("missing", "FAKE_SKIP_RESULT_BUNDLE", "missing_xcresult", False),
            ("corrupt", "FAKE_CORRUPT_RESULT_BUNDLE", "corrupt_xcresult", True),
        )

        for label, environment_key, expected_category, expected_retained in cases:
            with self.subTest(label=label):
                env = self.focused_env()
                env[environment_key] = "1"
                self.xcparse_log.unlink(missing_ok=True)

                result, summary = self.run_build_for_testing(env, f"prebuild-{label}-result-bundle")

                self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
                self.assertEqual(summary["status"], "failed")
                self.assertEqual(summary["failure_category"], expected_category)
                self.assertEqual(summary["result_extraction_mode"], "full")
                self.assertEqual(summary["result_bundle_retained"], expected_retained)
                self.assertEqual(self.xcparse_calls(), [])

    def test_successful_build_for_testing_uses_metadata_extraction(self):
        env = self.focused_env()

        result, summary = self.run_build_for_testing(env, "successful-prebuild-extract")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(summary["result_extraction_mode"], "metadata")
        self.assertEqual(self.xcparse_calls(), [])
        self.assertTrue(Path(summary["result_bundle"]).exists())
        extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["extraction_mode"], "metadata")
        self.assertTrue(extraction["result_bundle_retained"])

    def test_failed_build_for_testing_uses_full_extraction_for_diagnostics(self):
        env = self.focused_env()
        env["FAKE_XCODEBUILD_EXIT"] = "65"

        result, summary = self.run_build_for_testing(env, "failed-prebuild-extract")

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["result_extraction_mode"], "full")
        self.assertEqual(len(self.xcparse_calls()), 4)
        self.assertTrue(Path(summary["result_bundle"]).exists())
        extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["extraction_mode"], "full")
        self.assertTrue(extraction["result_bundle_retained"])

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
        self.assertEqual(summary["requested_result_extraction_mode"], "auto")
        self.assertEqual(summary["result_extraction_mode"], "full")
        self.assertTrue(summary["result_bundle_retained"])
        self.assertEqual(len(self.xcparse_calls()), 4)
        extraction = json.loads(Path(summary["result_extraction_summary"]).read_text(encoding="utf-8"))
        self.assertEqual(extraction["extraction_mode"], "full")
        self.assertTrue(extraction["result_bundle_retained"])
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
            (
                "invalid-result-extraction",
                ("--result-extraction", "quick", "--test", "AmbitionsTests/OneTests"),
                "unsupported result extraction mode",
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
