import importlib.util
import sys
from pathlib import Path

SERVER_PATH = Path(__file__).resolve().parents[1] / "server.py"
spec = importlib.util.spec_from_file_location("ambitions_repo_mcp_server", SERVER_PATH)
server = importlib.util.module_from_spec(spec)
sys.modules["ambitions_repo_mcp_server"] = server
assert spec.loader is not None
spec.loader.exec_module(server)


def test_get_active_batch_parses_current_state():
    result = server.tool_get_active_batch({})
    assert result["current"]["batch"]
    assert result["current"]["next_eligible_batch"]
    assert result["efc_overlay_active"] is True


def test_efc_applicability_triggers_for_user_facing_swift():
    result = server.tool_check_efc_applicability(
        {"changed_files": ["Native/Ambitions/Features/Today/TodayView.swift"]}
    )
    assert result["efc_required"] is True
    assert "accessibility_proof" in result["required_proof"]
    assert result["likely_owner"] == "AFI/FCP/FVQ"


def test_changed_file_impact_routes_persistence_to_pk():
    result = server.tool_changed_file_impact(
        {"changed_files": ["Native/Ambitions/Persistence/SwiftDataStore.swift"]}
    )
    impact = result["impacts"][0]
    assert impact["category"] == "persistence"
    assert "privacy_proof" in impact["efc_required_proof"]


def test_forbidden_claim_scan_finds_claims_in_temp_file(tmp_path, monkeypatch):
    fake_repo = tmp_path
    claim_file = fake_repo / "claim.md"
    claim_file.write_text("This is App Store ready and production-ready.\n", encoding="utf-8")
    monkeypatch.setattr(server, "REPO_ROOT", fake_repo)
    result = server.tool_detect_forbidden_claims({"paths": ["claim.md"]})
    assert result["finding_count"] >= 2


def test_closeout_shape_requires_efc_status(tmp_path, monkeypatch):
    fake_repo = tmp_path
    report = fake_repo / "report.md"
    report.write_text(
        "# Report\n\n"
        "## Files Changed\n\n"
        "## Validation\n\n"
        "## EFC Flagship Proof Overlay\n\n"
        "EFC applicability: invoked.\n\n"
        "## Non-Claims\n\n"
        "## Next Eligible Batch\n\n"
        "## Rollback Path\n",
        encoding="utf-8",
    )
    monkeypatch.setattr(server, "REPO_ROOT", fake_repo)
    result = server.tool_check_batch_closeout_shape({"report_path": "report.md"})
    assert result["valid_shape"] is True


def test_autonomy_tools_are_registered():
    required = {
        "autonomy_preflight",
        "required_validation_plan",
        "continuation_oracle",
        "resolve_active_truth",
        "obsolete_authority_scan",
        "batch_prompt_preflight",
        "latest_run_summary",
        "queue_next_action",
    }
    assert required.issubset(set(server.TOOLS))


def test_required_validation_plan_routes_app_source_to_xcode_build():
    tool = server.TOOLS["required_validation_plan"].handler
    result = tool({"changed_files": ["Native/Ambitions/Features/Today/TodayView.swift"]})
    assert "xcode_validate_build" in result["required_validations"]
    assert result["release_claim_allowed"] is False
    assert result["xcode_lane"] == "build"


def test_required_validation_plan_routes_persistence_to_focused_test():
    tool = server.TOOLS["required_validation_plan"].handler
    result = tool({"changed_files": ["Native/Ambitions/Persistence/SwiftDataStore.swift"]})
    assert "xcode_validate_focused_test" in result["required_validations"]
    assert result["xcode_lane"] == "focused-test"


def test_obsolete_authority_scan_flags_plan_top_level(tmp_path, monkeypatch):
    fake_repo = tmp_path
    doc = fake_repo / "doc.md"
    doc.write_text("Top-level tabs: Today / Goals / Capture / Plan / You\n", encoding="utf-8")
    monkeypatch.setattr(server, "REPO_ROOT", fake_repo)
    tool = server.TOOLS["obsolete_authority_scan"].handler
    result = tool({"paths": ["doc.md"]})
    assert result["finding_count"] >= 1
    assert any(item["id"] == "plan_top_level_tab" for item in result["findings"])


def test_batch_prompt_preflight_requires_runner_markers(tmp_path, monkeypatch):
    fake_repo = tmp_path
    prompt = fake_repo / "prompt.md"
    prompt.write_text("# Prompt\n\nBatch ID: TEST\n", encoding="utf-8")
    monkeypatch.setattr(server, "REPO_ROOT", fake_repo)
    tool = server.TOOLS["batch_prompt_preflight"].handler
    result = tool({"prompt_path": "prompt.md"})
    assert result["valid"] is False
    assert "AMBITIONS_RUNNER_REQUIRED: true" in result["missing_markers"]


def test_continuation_oracle_routes_green_to_continue():
    tool = server.TOOLS["continuation_oracle"].handler
    result = tool({"status": "GREEN"})
    assert result["decision"] == "CONTINUE"


def test_continuation_oracle_routes_red_to_repair():
    tool = server.TOOLS["continuation_oracle"].handler
    result = tool({"status": "RED"})
    assert result["decision"] == "REPAIR_PROMPT_REQUIRED"


def test_latest_run_summary_handles_empty_repo(tmp_path, monkeypatch):
    monkeypatch.setattr(server, "REPO_ROOT", tmp_path)
    tool = server.TOOLS["latest_run_summary"].handler
    result = tool({})
    assert result["found"] is False