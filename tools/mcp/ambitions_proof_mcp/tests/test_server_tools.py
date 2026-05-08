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
    assert "arbitrary_command" not in names
    assert "no arbitrary shell" in result["hard_boundaries"]


def test_policy_rejects_unknown_validation():
    result = server.tool_check_validation_policy({"name": "curl_secrets"})
    assert result["allowed"] is False


def test_generate_packet_writes_under_proof_root(tmp_path, monkeypatch):
    monkeypatch.setattr(server, "REPO_ROOT", tmp_path)
    monkeypatch.setattr(server, "LOG_ROOT", tmp_path / ".codex" / "logs")
    monkeypatch.setattr(server, "PROOF_ROOT", tmp_path / ".codex" / "logs" / "proof")
    monkeypatch.setattr(server, "MCP_LOG_ROOT", tmp_path / ".codex" / "logs" / "mcp")
    result = server.tool_generate_proof_packet({"title": "Test Packet", "validations": ["git_status_summary"]})
    assert result["packet_path"].startswith(".codex/logs/proof/")
    assert (tmp_path / result["packet_path"]).exists()
