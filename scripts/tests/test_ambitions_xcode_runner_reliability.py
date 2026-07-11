import json
import os
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


if __name__ == "__main__":
    unittest.main()
