import importlib.util
import json
import signal
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
    def _write_job_fixture(
        self,
        root: Path,
        *,
        job_id: str = "xcode-20260723T014000Z-deadbeef",
        status: str = "running",
        worker_pid: int = 4321,
        worker_pgid: int = 4321,
        result: dict | None = None,
    ) -> tuple[str, Path]:
        job_dir = root / job_id
        job_dir.mkdir(parents=True)
        log_path = job_dir / "job.log"
        log_path.write_text("build progress\n", encoding="utf-8")
        result_path = job_dir / "result.json"
        state = {
            "schema_version": 1,
            "job_id": job_id,
            "status": status,
            "validation": "xcode_validate_build",
            "batch_id": "RESUME-SMOKE-01",
            "args": ["--batch", "RESUME-SMOKE-01"],
            "command": [
                "scripts/ambitions-xcode-validate.sh",
                "--lane",
                "build",
                "--json",
                "--batch",
                "RESUME-SMOKE-01",
            ],
            "source": {"branch": "main", "sha": "abc123", "status": ""},
            "created_at": "2026-07-23T01:40:00+00:00",
            "started_at": "2026-07-23T01:40:01+00:00",
            "finished_at": None,
            "worker_pid": worker_pid,
            "worker_pgid": worker_pgid,
            "command_pid": None,
            "log_path": str(log_path),
            "result_path": str(result_path),
            "cancel_requested_at": None,
        }
        (job_dir / "job.json").write_text(json.dumps(state), encoding="utf-8")
        if result is not None:
            result_path.write_text(json.dumps(result), encoding="utf-8")
        return job_id, job_dir

    def test_registers_resumable_xcode_job_tools(self):
        expected = {
            "xcode_job_submit",
            "xcode_job_status",
            "xcode_job_result",
            "xcode_job_cancel",
        }
        self.assertTrue(expected.issubset(server.TOOLS))

    def test_xcode_job_submit_persists_source_and_returns_job_id(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(
                    server,
                    "_git_context",
                    return_value={"branch": "main", "sha": "abc123", "status": ""},
                    create=True,
                ),
                mock.patch.object(server, "_spawn_xcode_job_worker", return_value=4321, create=True) as spawn,
            ):
                result = server.tool_xcode_job_submit(
                    {
                        "validation": "xcode_validate_build",
                        "args": ["--batch", "RESUME-SMOKE-01"],
                    }
                )

            self.assertEqual(result["status"], "queued")
            self.assertEqual(result["source"]["sha"], "abc123")
            self.assertEqual(result["batch_id"], "RESUME-SMOKE-01")
            self.assertEqual(result["worker_pid"], 4321)
            self.assertTrue((job_root / result["job_id"] / "job.json").exists())
            spawn.assert_called_once_with(result["job_id"])

    def test_xcode_job_submit_rejects_non_xcode_validation(self):
        with self.assertRaisesRegex(ValueError, "Xcode Build Lab"):
            server.tool_xcode_job_submit({"validation": "git_status_summary", "args": []})

    def test_xcode_job_status_is_resumable_and_returns_log_tail(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, _ = self._write_job_fixture(job_root)
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(server, "_job_process_matches", return_value=True, create=True),
            ):
                result = server.tool_xcode_job_status({"job_id": job_id})

            self.assertEqual(result["status"], "running")
            self.assertTrue(result["active"])
            self.assertTrue(result["resumable"])
            self.assertIn("build progress", result["output_tail"])

    def test_xcode_job_result_reports_pending_then_returns_terminal_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, job_dir = self._write_job_fixture(job_root)
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(server, "_job_process_matches", return_value=True, create=True),
            ):
                pending = server.tool_xcode_job_result({"job_id": job_id})
                self.assertFalse(pending["ready"])

                state_path = job_dir / "job.json"
                state = json.loads(state_path.read_text(encoding="utf-8"))
                state["status"] = "succeeded"
                state["finished_at"] = "2026-07-23T01:41:00+00:00"
                state_path.write_text(json.dumps(state), encoding="utf-8")
                terminal_result = {
                    "job_id": job_id,
                    "status": "succeeded",
                    "passed": True,
                    "exit_code": 0,
                }
                (job_dir / "result.json").write_text(json.dumps(terminal_result), encoding="utf-8")
                completed = server.tool_xcode_job_result({"job_id": job_id})

            self.assertTrue(completed["ready"])
            self.assertEqual(completed["result"], terminal_result)

    def test_xcode_job_result_does_not_trust_terminal_state_without_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, _ = self._write_job_fixture(job_root, status="succeeded")
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(
                    server,
                    "_git_context",
                    return_value={"branch": "main", "sha": "abc123", "status": ""},
                ),
                mock.patch.object(server, "_latest_xcode_summary", return_value=None),
            ):
                completed = server.tool_xcode_job_result({"job_id": job_id})

            self.assertTrue(completed["ready"])
            self.assertEqual(completed["job"]["status"], "interrupted")
            self.assertEqual(completed["result"]["failure_category"], "terminal_result_missing")

    def test_xcode_job_cancel_targets_only_the_owned_worker_group(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, job_dir = self._write_job_fixture(job_root, worker_pid=4321, worker_pgid=8765)
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(server, "_job_process_matches", return_value=True, create=True),
                mock.patch.object(server.os, "getpgid", return_value=8765),
                mock.patch.object(server.os, "killpg") as killpg,
            ):
                result = server.tool_xcode_job_cancel({"job_id": job_id})

            self.assertTrue(result["cancellation_requested"])
            killpg.assert_called_once_with(8765, signal.SIGTERM)
            state = json.loads((job_dir / "job.json").read_text(encoding="utf-8"))
            self.assertEqual(state["status"], "cancelling")
            self.assertIsNotNone(state["cancel_requested_at"])

    def test_xcode_job_cancel_rejects_changed_process_group(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, _ = self._write_job_fixture(job_root, worker_pid=4321, worker_pgid=8765)
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(server, "_job_process_matches", return_value=True, create=True),
                mock.patch.object(server.os, "getpgid", return_value=9999),
                mock.patch.object(server.os, "killpg") as killpg,
            ):
                with self.assertRaisesRegex(RuntimeError, "process-group ownership"):
                    server.tool_xcode_job_cancel({"job_id": job_id})

            killpg.assert_not_called()

    def test_xcode_job_worker_persists_successful_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            job_root = Path(tmp) / "xcode-jobs"
            job_id, job_dir = self._write_job_fixture(job_root, status="queued", worker_pid=0, worker_pgid=0)
            validation = server.VALIDATIONS["xcode_validate_build"]
            command = [sys.executable, "-c", "print('job-ok')"]
            with (
                mock.patch.object(server, "XCODE_JOB_ROOT", job_root, create=True),
                mock.patch.object(
                    server,
                    "_prepare_xcode_job_request",
                    return_value=(validation, command, "RESUME-SMOKE-01"),
                    create=True,
                ),
                mock.patch.object(
                    server,
                    "_git_context",
                    return_value={"branch": "main", "sha": "abc123", "status": ""},
                    create=True,
                ),
                mock.patch.object(
                    server,
                    "_latest_xcode_summary",
                    return_value={
                        "found": True,
                        "batch": "RESUME-SMOKE-01",
                        "summary": {"status": "passed", "failure_category": "passed", "exit_code": 0},
                    },
                ),
            ):
                exit_code = server._run_xcode_job(job_id)

            self.assertEqual(exit_code, 0)
            state = json.loads((job_dir / "job.json").read_text(encoding="utf-8"))
            result = json.loads((job_dir / "result.json").read_text(encoding="utf-8"))
            self.assertEqual(state["status"], "succeeded")
            self.assertTrue(result["passed"])
            self.assertEqual(result["source"]["start"]["sha"], "abc123")
            self.assertIn("job-ok", (job_dir / "job.log").read_text(encoding="utf-8"))

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
                mock.patch.object(server, "XCODE_JOB_ROOT", tmp_path / ".codex" / "xcode-jobs"),
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
