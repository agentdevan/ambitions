import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
RESULT_EXTRACTOR = REPO_ROOT / "scripts/ambitions-xcode-result-extract.sh"


class XcodeResultExtractorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.calls = self.root / "xcparse-calls.log"
        self.result = self.root / "focused-test.xcresult"
        self.result.mkdir()
        (self.result / "Info.plist").write_text("fixture\n", encoding="utf-8")
        self.output = self.root / "extract"
        xcparse = self.bin / "xcparse"
        xcparse.write_text(
            "#!/bin/sh\nset -eu\nprintf '%s\\n' \"$*\" >> \"$FAKE_XCPARSE_CALLS\"\n",
            encoding="utf-8",
        )
        xcparse.chmod(0o755)
        self.env = os.environ.copy()
        self.env["PATH"] = str(self.bin) + os.pathsep + self.env["PATH"]
        self.env["FAKE_XCPARSE_CALLS"] = str(self.calls)
        xcrun = self.bin / "xcrun"
        xcrun.write_text(
            "#!/bin/sh\n"
            "set -eu\n"
            "if [ \"${1:-}\" = xcresulttool ]; then\n"
            "  printf '%s\\n' \"${FAKE_XCRESULT_TESTS_JSON:?}\"\n"
            "  exit \"${FAKE_XCRESULT_EXIT:-0}\"\n"
            "fi\n"
            "exit 2\n",
            encoding="utf-8",
        )
        xcrun.chmod(0o755)
        self.env["FAKE_XCRESULT_TESTS_JSON"] = json.dumps(
            {
                "devices": [{"deviceId": "SIM-ONE"}],
                "testNodes": [
                    {
                        "name": "Ambitions",
                        "nodeType": "Test Plan",
                        "children": [
                            {
                                "name": "AmbitionsTests",
                                "nodeType": "Unit test bundle",
                                "children": [
                                    {
                                        "name": "FirstTests",
                                        "nodeType": "Test Suite",
                                        "children": [
                                            {
                                                "name": "testOne()",
                                                "nodeIdentifier": "FirstTests/testOne()",
                                                "nodeType": "Test Case",
                                                "result": "Passed",
                                            }
                                        ],
                                    }
                                ],
                            }
                        ],
                    }
                ],
            }
        )

    def tearDown(self):
        self.temp.cleanup()

    def run_extract(self, *args: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        result = subprocess.run(
            [
                "bash",
                str(RESULT_EXTRACTOR),
                "--result",
                str(self.result),
                "--output-dir",
                str(self.output),
                *args,
            ],
            cwd=REPO_ROOT,
            env=self.env,
            capture_output=True,
            text=True,
        )
        summary_path = self.output / "summary.json"
        summary = json.loads(summary_path.read_text(encoding="utf-8")) if summary_path.exists() else {}
        return result, summary

    def xcparse_calls(self) -> list[str]:
        return self.calls.read_text(encoding="utf-8").splitlines() if self.calls.exists() else []

    def test_metadata_mode_retains_result_and_skips_all_rich_artifact_passes(self):
        result, summary = self.run_extract("--mode", "metadata")

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.result.exists())
        self.assertEqual(self.xcparse_calls(), [])
        self.assertEqual(summary["extraction_mode"], "metadata")
        self.assertTrue(summary["result_bundle_retained"])
        self.assertTrue(summary["xcparse_available"])
        self.assertFalse(summary["xcparse_invoked"])
        self.assertEqual(summary["xcparse_pass_count"], 0)
        self.assertEqual(summary["xcparse_success_count"], 0)
        self.assertFalse(summary["rich_artifacts_requested"])
        self.assertFalse(summary["rich_artifacts_extracted"])
        self.assertIsNone(summary["attachments"])
        self.assertIsNone(summary["screenshots"])
        self.assertIsNone(summary["logs"])
        self.assertIsNone(summary["coverage"])

    def test_default_full_mode_preserves_four_rich_artifact_passes(self):
        result, summary = self.run_extract()

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.result.exists())
        calls = self.xcparse_calls()
        self.assertEqual(len(calls), 4, calls)
        self.assertEqual([call.split()[0] for call in calls], ["attachments", "screenshots", "logs", "coverage"])
        self.assertEqual(summary["extraction_mode"], "full")
        self.assertTrue(summary["result_bundle_retained"])
        self.assertTrue(summary["xcparse_available"])
        self.assertTrue(summary["xcparse_invoked"])
        self.assertEqual(summary["xcparse_pass_count"], 4)
        self.assertEqual(summary["xcparse_success_count"], 4)
        self.assertTrue(summary["rich_artifacts_requested"])
        self.assertTrue(summary["rich_artifacts_extracted"])
        for key in ("attachments", "screenshots", "logs", "coverage"):
            self.assertIsInstance(summary[key], str)

    def test_invalid_mode_fails_before_xcparse_or_output_creation(self):
        result, summary = self.run_extract("--mode", "quick")

        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        self.assertEqual(summary, {})
        self.assertEqual(self.xcparse_calls(), [])
        self.assertIn("unsupported extraction mode", result.stderr)

    def test_corrupt_metadata_bundle_reports_failure_without_losing_the_bundle(self):
        (self.result / "Info.plist").unlink()

        result, summary = self.run_extract("--mode", "metadata")

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertTrue(self.result.exists())
        self.assertEqual(self.xcparse_calls(), [])
        self.assertEqual(summary["status"], "failed")
        self.assertEqual(summary["failure_category"], "corrupt_xcresult")
        self.assertEqual(summary["extraction_mode"], "metadata")
        self.assertTrue(summary["result_bundle_retained"])
        self.assertTrue(summary["xcparse_available"])
        self.assertFalse(summary["xcparse_invoked"])
        self.assertEqual(summary["xcparse_pass_count"], 0)
        self.assertEqual(summary["xcparse_success_count"], 0)
        self.assertFalse(summary["rich_artifacts_requested"])
        self.assertFalse(summary["rich_artifacts_extracted"])
        self.assertIsNone(summary["attachments"])
        self.assertIsNone(summary["screenshots"])
        self.assertIsNone(summary["logs"])
        self.assertIsNone(summary["coverage"])

    def test_expected_selector_is_proved_from_xcresult_test_nodes(self):
        result, summary = self.run_extract(
            "--mode",
            "metadata",
            "--expected-test-filter",
            "AmbitionsTests/FirstTests/testOne",
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(summary["test_results_validated"])
        self.assertEqual(summary["expected_test_filters"], ["AmbitionsTests/FirstTests/testOne"])
        self.assertEqual(summary["matched_test_filters"], ["AmbitionsTests/FirstTests/testOne"])
        self.assertEqual(summary["missing_test_filters"], [])
        self.assertEqual(summary["executed_test_identifiers"], ["AmbitionsTests/FirstTests/testOne"])
        self.assertEqual(summary["simulator_udids"], ["SIM-ONE"])

    def test_missing_selector_fails_even_when_another_selector_executed(self):
        result, summary = self.run_extract(
            "--mode",
            "metadata",
            "--expected-test-filter",
            "AmbitionsTests/FirstTests",
            "--expected-test-filter",
            "AmbitionsTests/MissingTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["status"], "failed")
        self.assertEqual(summary["failure_category"], "test_selector_not_executed")
        self.assertEqual(summary["matched_test_filters"], ["AmbitionsTests/FirstTests"])
        self.assertEqual(summary["missing_test_filters"], ["AmbitionsTests/MissingTests"])

    def test_xcresulttool_failure_is_not_accepted_as_selector_proof(self):
        self.env["FAKE_XCRESULT_EXIT"] = "9"

        result, summary = self.run_extract(
            "--mode",
            "metadata",
            "--expected-test-filter",
            "AmbitionsTests/FirstTests",
        )

        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertEqual(summary["status"], "failed")
        self.assertEqual(summary["failure_category"], "xcresult_test_results_unavailable")
        self.assertFalse(summary["test_results_validated"])


if __name__ == "__main__":
    unittest.main()
