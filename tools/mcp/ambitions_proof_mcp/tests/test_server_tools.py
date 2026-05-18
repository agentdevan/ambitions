import importlib.util
import sys
from pathlib import Path

SERVER_PATH = Path(__file__).resolve().parents[1] / "server.py"
spec = importlib.util.spec_from_file_location("ambitions_proof_mcp_server", SERVER_PATH)
server = importlib.util.module_from_spec(spec)
sys.modules["ambitions_proof_mcp_server"] = server
assert spec.loader is not None
spec.loader.exec_module(server)


def test_lists_allowlisted_validations_only():
    result = server.tool_list_available_validations({})
    names = {item["name"] for item in result["validations"]}
    assert "mcp01_self_test" in names
    assert "focused_tests" in names
    assert "xcode_validate_build" in names
    assert "xcode_validate_build_for_testing" in names
    assert "xcode_validate_focused_test" in names
    assert "xcode_validate_test_plan" in names
    assert "arbitrary_command" not in names
    assert "no arbitrary shell" in result["hard_boundaries"]


def test_policy_rejects_unknown_validation():
    result = server.tool_check_validation_policy({"name": "unknown_validation"})
    assert result["allowed"] is False


def test_policy_prefers_wrapper_native_xcode_validations():
    result = server.tool_check_validation_policy({})
    assert "xcode_validate_focused_test" in result["preferred_xcode_validations"]
    assert "focused_tests" in result["deprecated_xcode_validations"]


def test_xcode_focused_validation_uses_wrapper_timeout_and_lane():
    validation = server.VALIDATIONS["xcode_validate_focused_test"]
    assert validation.xcode_wrapper_lane == "focused-test"
    assert validation.timeout_seconds == 1800
    assert validation.command[0] == "scripts/ambitions-xcode-validate.sh"


def test_xcode_wrapper_args_allow_batch_and_test_only():
    validation = server.VALIDATIONS["xcode_validate_focused_test"]
    args = server._validated_xcode_extra_args(
        validation,
        ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"],
    )
    assert args == ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused"]


def test_xcode_wrapper_args_reject_unexpected_flags():
    validation = server.VALIDATIONS["xcode_validate_focused_test"]
    try:
        server._validated_xcode_extra_args(
            validation,
            ["--batch", "MCP-SMOKE-01", "--test", "AmbitionsTests/Focused", "--unexpected", "Other"],
        )
    except ValueError as exc:
        assert "unsupported xcode wrapper argument" in str(exc)
    else:
        raise AssertionError("unexpected xcode wrapper flag was accepted")


def test_generate_packet_writes_under_proof_root(tmp_path, monkeypatch):
    monkeypatch.setattr(server, "REPO_ROOT", tmp_path)
    monkeypatch.setattr(server, "LOG_ROOT", tmp_path / ".codex" / "logs")
    monkeypatch.setattr(server, "PROOF_ROOT", tmp_path / ".codex" / "logs" / "proof")
    monkeypatch.setattr(server, "MCP_LOG_ROOT", tmp_path / ".codex" / "logs" / "mcp")
    monkeypatch.setattr(server, "XCODE_LOG_ROOT", tmp_path / ".codex" / "xcode-logs")
    monkeypatch.setattr(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries")
    result = server.tool_generate_proof_packet({"title": "Test Packet", "validations": ["git_status_summary"]})
    assert result["packet_path"].startswith(".codex/logs/proof/")
    assert (tmp_path / result["packet_path"]).exists()


def test_xcode_latest_summary_reads_latest_batch_summary(tmp_path, monkeypatch):
    monkeypatch.setattr(server, "REPO_ROOT", tmp_path)
    monkeypatch.setattr(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries")
    summary_dir = tmp_path / ".codex" / "xcode-summaries" / "MCP-SMOKE-01" / "20260518T120000Z"
    summary_dir.mkdir(parents=True)
    summary_file = summary_dir / "validate-summary.json"
    summary_file.write_text('{"batch":"MCP-SMOKE-01","status":"passed","failure_category":"passed","exit_code":0}', encoding="utf-8")
    result = server.tool_xcode_latest_summary({"batch_id": "MCP-SMOKE-01"})
    assert result["found"] is True
    assert result["summary"]["status"] == "passed"


def test_xcode_failure_classification_includes_log_tail(tmp_path, monkeypatch):
    monkeypatch.setattr(server, "REPO_ROOT", tmp_path)
    monkeypatch.setattr(server, "XCODE_SUMMARY_ROOT", tmp_path / ".codex" / "xcode-summaries")
    monkeypatch.setattr(server, "XCODE_LOG_ROOT", tmp_path / ".codex" / "xcode-logs")
    summary_dir = tmp_path / ".codex" / "xcode-summaries" / "MCP-SMOKE-01" / "20260518T120000Z"
    log_dir = tmp_path / ".codex" / "xcode-logs" / "MCP-SMOKE-01" / "20260518T120000Z"
    summary_dir.mkdir(parents=True)
    log_dir.mkdir(parents=True)
    (summary_dir / "validate-summary.json").write_text('{"batch":"MCP-SMOKE-01","status":"failed","failure_category":"simulator_boot_failure","exit_code":22}', encoding="utf-8")
    (log_dir / "focused-test.log").write_text("simulator issue\n", encoding="utf-8")
    result = server.tool_xcode_failure_classification({"batch_id": "MCP-SMOKE-01"})
    assert result["failure_category"] == "simulator_boot_failure"
    assert "simulator issue" in result["latest_log"]["tail"]