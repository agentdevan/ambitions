import importlib.util
import sys
import tempfile
import unittest
from unittest import mock
from pathlib import Path

SERVER_PATH = Path(__file__).resolve().parents[1] / "server.py"
spec = importlib.util.spec_from_file_location("ambitions_proof_mcp_server", SERVER_PATH)
server = importlib.util.module_from_spec(spec)
sys.modules["ambitions_proof_mcp_server"] = server
assert spec.loader is not None
spec.loader.exec_module(server)


class ProofMCPServerToolTests(unittest.TestCase):
    def test_lists_allowlisted_validations_only(self):
        result = server.tool_list_available_validations({})
        names = {item["name"] for item in result["validations"]}
        self.assertIn("mcp01_self_test", names)
        self.assertIn("focused_tests", names)
        self.assertIn("xcode_validate_build", names)
        self.assertIn("xcode_validate_build_for_testing", names)
        self.assertIn("xcode_validate_focused_test", names)
        self.assertIn("xcode_validate_test_plan", names)
        self.assertNotIn("arbitrary_command", names)
        self.assertIn("no arbitrary shell", result["hard_boundaries"])

    def test_policy_rejects_unknown_validation(self):
        result = server.tool_check_validation_policy({"name": "unknown_validation"})
        self.assertFalse(result["allowed"])

    def test_policy_prefers_wrapper_native_xcode_validations(self):
        result = server.tool_check_validation_policy({})
        self.assertIn("xcode_validate_focused_test", result["preferred_xcode_validations"])
        self.assertIn("focused_tests", result["deprecated_xcode_validations"])

    def test_xcode_focused_validation_uses_wrapper_timeout_and_lane(self):
        validation = server.VALIDATIONS["xcode_validate_focused_test"]
        self.assertEqual(validation.xcode_wrapper_lane, "focused-test")
        self.assertEqual(validation.timeout_seconds, 1800)
        self.assertEqual(validation.command[0], "scripts/ambitions-xcode-validate.sh")

    def test_xcode_wrapper_args_allow_batch_and_test_only(self):
        validation = server.VALIDATIONS["xcode_validate_focused_test"]
        args = server._validated_xcode_extra_args(
            validation,
            ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"],
        )
        self.assertEqual(args, ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"])

    def test_xcode_wrapper_args_reject_unexpected_flags(self):
        validation = server.VALIDATIONS["xcode_validate_focused_test"]
        with self.assertRaisesRegex(ValueError, "unsupported xcode wrapper argument"):
            server._validated_xcode_extra_args(
                validation,
                ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused", "--unexpected", "Other"],
            )

    def test_generate_packet_writes_under_proof_root(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            with (
                mock.patch.object(server, "REPO_ROOT", tmp_path),
                mock.patch.object(server, "LOG_ROOT", tmp_path / ".codex" / "logs"),
                mock.patch.object(server, "PROOF_ROOT", tmp_path / ".codex" / "logs" / "proof"),
                mock.patch.object(server, "MCP_LOG_ROOT", tmp_path / ".codex" / "logs" / "mcp"),
                mock.patch.object(server, "XCODE_LOG_ROOT", tmp_path / ".codex" / "xcode-logs"),
                mock.patch.object(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries"),
            ):
                result = server.tool_generate_proof_packet({"title": "Test Packet", "validations": ["git_status_summary"]})
                self.assertTrue(result["packet_path"].startswith(".codex/logs/proof/"))
                self.assertTrue((tmp_path / result["packet_path"]).exists())

    def test_xcode_latest_summary_reads_latest_batch_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            with (
                mock.patch.object(server, "REPO_ROOT", tmp_path),
                mock.patch.object(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries"),
            ):
                summary_dir = tmp_path / ".codex" / "xcode-summaries" / "MCP-SMOKE-01" / "20260518T120000Z"
                summary_dir.mkdir(parents=True)
                summary_file = summary_dir / "validate-summary.json"
                summary_file.write_text(
                    '{"batch":"MCP-SMOKE-01","status":"passed","failure_category":"passed","exit_code":0}',
                    encoding="utf-8",
                )
                result = server.tool_xcode_latest_summary({"batch_id": "MCP-SMOKE-01"})
                self.assertTrue(result["found"])
                self.assertEqual(result["summary"]["status"], "passed")

    def test_xcode_latest_summary_reads_lane_named_summary(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            with (
                mock.patch.object(server, "REPO_ROOT", tmp_path),
                mock.patch.object(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries"),
            ):
                summary_dir = tmp_path / ".codex" / "xcode-summaries" / "MCP-SMOKE-01" / "20260518T120000Z"
                summary_dir.mkdir(parents=True)
                summary_file = summary_dir / "focused-test-summary.json"
                summary_file.write_text(
                    '{"batch":"MCP-SMOKE-01","status":"passed","failure_category":"passed","exit_code":0}',
                    encoding="utf-8",
                )
                result = server.tool_xcode_latest_summary({"batch_id": "MCP-SMOKE-01"})
                self.assertTrue(result["found"])
                self.assertTrue(result["path"].endswith("focused-test-summary.json"))
                self.assertEqual(result["summary"]["status"], "passed")

    def test_xcode_failure_classification_includes_log_tail(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            with (
                mock.patch.object(server, "REPO_ROOT", tmp_path),
                mock.patch.object(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries"),
                mock.patch.object(server, "XCODE_LOG_ROOT", tmp_path / ".codex" / "xcode-logs"),
            ):
                summary_dir = tmp_path / ".codex" / "xcode-summaries" / "MCP-SMOKE-01" / "20260518T120000Z"
                log_dir = tmp_path / ".codex" / "xcode-logs" / "MCP-SMOKE-01" / "20260518T120000Z"
                summary_dir.mkdir(parents=True)
                log_dir.mkdir(parents=True)
                (summary_dir / "validate-summary.json").write_text(
                    '{"batch":"MCP-SMOKE-01","status":"failed","failure_category":"simulator_boot_failure","exit_code":22}',
                    encoding="utf-8",
                )
                (log_dir / "focused-test.log").write_text("simulator issue\n", encoding="utf-8")
                result = server.tool_xcode_failure_classification({"batch_id": "MCP-SMOKE-01"})
                self.assertEqual(result["failure_category"], "simulator_boot_failure")
                self.assertIn("simulator issue", result["latest_log"]["tail"])

    def test_run_named_validation_exposes_command_exit_log_and_non_claims(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)

            class DummyProc:
                stdout = "validation ok\n"
                returncode = 0

            with (
                mock.patch.object(server, "REPO_ROOT", tmp_path),
                mock.patch.object(server, "PROOF_ROOT", tmp_path / ".codex" / "logs" / "proof"),
                mock.patch.object(server, "_latest_xcode_summary_for_command", return_value={"found": False}),
                mock.patch.object(server.subprocess, "run", return_value=DummyProc()),
            ):
                validation = server.VALIDATIONS["git_status_summary"]
                result = server._run(validation)

                self.assertEqual(result["command"], ["git", "status", "--short"])
                self.assertEqual(result["exit_code"], 0)
                self.assertTrue(result["log_path"].startswith(".codex/logs/proof/"))
                self.assertEqual(result["failure_category"], "passed")
                self.assertEqual(result["timeout_seconds"], validation.timeout_seconds)
                self.assertIn("not release proof", result["non_claims"])
                self.assertIn("not legal/privacy signoff", result["non_claims"])

    def test_xctest_recovery_state_marks_timeout_for_retry(self):
        result = server._xctest_recovery_state(
            validation_name="xcode_validate_focused_test",
            classification="test_timeout",
            status="failed",
            exit_code=25,
            log_tail="focused test timed out in the simulator",
        )
        self.assertTrue(result["previous_attempt_timed_out"])
        self.assertEqual(result["recommended_retry_validation"], "xcode_validate_focused_test")
        self.assertEqual(result["continuation_status"], "RETRY_XCODE_WRAPPER_PROOF")


if __name__ == "__main__":
    unittest.main()
