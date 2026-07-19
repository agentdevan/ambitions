from __future__ import annotations

import json
import importlib.util
import sys
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.boundary import boundary_issues_for_value, object_key_issues, request_shape_issues
from foundry.boundary_audit import audit_fixture_root


FIXTURE_ROOT = Path(__file__).resolve().parents[2] / "fixtures" / "boundary"
REPO_ROOT = Path(__file__).resolve().parents[4]


def _fixture(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def test_valid_boundary_fixtures_pass():
    for path in sorted((FIXTURE_ROOT / "valid").glob("*.json")):
        result = audit_fixture_root(path.parent)
        assert result["valid"], result


def test_invalid_boundary_fixtures_fail_with_expected_codes():
    result = audit_fixture_root(FIXTURE_ROOT / "invalid")
    assert result["valid"], result
    for path in sorted((FIXTURE_ROOT / "invalid").glob("*.json")):
        fixture = _fixture(path)
        issues = [issue.format() for issue in boundary_issues_for_value(fixture, str(path))]
        if "objectKey" in fixture.get("payload", {}):
            issues.extend(issue.format() for issue in object_key_issues(fixture["payload"]["objectKey"], str(path)))
        missing = [code for code in fixture["expectedIssueCodes"] if not any(code in issue for issue in issues)]
        assert not missing, (path, missing, issues)


def test_rejects_goal_capture_schedule_capacity_life_capital_proof_receipt_fields():
    payload = {
        "goalText": "Become a pilot",
        "captureText": "I captured a private note.",
        "schedule": ["Monday 9 AM"],
        "capacity": "two free hours",
        "lifeCapital": {"credential": "private"},
        "proofPayload": {"body": "private proof"},
        "receiptPayload": {"body": "private receipt"},
    }

    issues = [issue.code for issue in boundary_issues_for_value(payload, "payload")]

    assert "goal_text" in issues
    assert "capture_text" in issues
    assert "schedule_or_capacity" in issues
    assert "life_capital" in issues
    assert "proof_or_receipt_payload" in issues


def test_rejects_account_secret_user_id_private_graph_request_shape():
    request = {
        "headers": {
            "Authorization": "Bearer pk-syntheticnotreal12345",
            "X-User-ID": "user-1234",
        },
        "query": {
            "goal_id": "goal-1",
            "api_key": "pk-syntheticnotreal12345",
        },
        "body": {
            "privateLifeGraph": {},
        },
    }

    issues = [issue.code for issue in request_shape_issues(request, "request")]

    assert "forbidden_request_header" in issues
    assert "forbidden_request_query_field" in issues
    assert "account_secret" in issues
    assert "private_life_graph" in issues


def test_accepts_m05_runtime_artifact_request_shape():
    request = _fixture(FIXTURE_ROOT / "valid" / "public-reference-request-shape.json")["payload"]["request"]

    assert request_shape_issues(request, "request") == []


def test_rejects_m05_runtime_artifact_request_private_query_markers():
    request = {
        "headers": {
            "Accept": "application/json"
        },
        "path": "/source-atlas/public/packs",
        "query": {
            "artifact_id": "pack.synthetic.public_reference",
            "artifact_version": "2026-06-public-reference",
            "capture_text": "private capture",
            "goal_id": "goal.private",
            "inferred_priority": "high",
            "life_capital": "relationship",
            "proof_payload": "proof",
            "receipt_payload": "receipt",
            "schedule_capacity": "tonight",
            "user_id": "user-1234",
        },
    }

    issues = [issue.code for issue in request_shape_issues(request, "request")]

    assert "forbidden_request_query_field" in issues
    assert "capture_text" in issues
    assert "goal_text" in issues
    assert "life_capital" in issues
    assert "proof_or_receipt_payload" in issues
    assert "schedule_or_capacity" in issues
    assert "user_identifier" in issues


def test_rejects_private_r2_object_key_segments_and_uuid_like_ids():
    issues = [issue.code for issue in object_key_issues("source-atlas/v1/users/0123456789abcdef01234567/goals/manifest.json")]

    assert "private_r2_object_key_segment" in issues
    assert "possible_user_identifier_in_object_key" in issues


def test_boundary_context_text_does_not_mask_nested_private_payload():
    payload = {
        "runtimeBoundary": {
            "mustNotUploadPrivateContext": True,
            "privateLifeGraph": {
                "goalText": "Private goal"
            },
        }
    }

    issues = [issue.code for issue in boundary_issues_for_value(payload, "payload")]

    assert "private_life_graph" in issues
    assert "goal_text" in issues


def test_local_personalization_required_boolean_is_not_private_payload():
    payload = {
        "metadata": {
            "localPersonalizationRequired": True,
            "sourceAtlasInvisibleByDefault": True,
            "privacyBoundary": "public/reference/freshness only; no private life graph or private user context",
        }
    }

    assert boundary_issues_for_value(payload, "payload") == []


def test_user_mini_pack_shape_is_rejected_for_foundry_or_r2():
    payload = {
        "kind": "ambitions.sourceAtlas.userMiniPack",
        "privacyClass": "privateLife",
        "sourceKind": "userProvided",
    }

    issues = [issue.code for issue in boundary_issues_for_value(payload, "payload")]

    assert "user_mini_pack_forbidden_in_foundry" in issues
    assert "private_privacy_class_forbidden" in issues
    assert "user_provided_source_forbidden" in issues


def _load_no_private_graph_audit():
    script_path = REPO_ROOT / "scripts" / "source-atlas-no-private-graph-egress-audit.py"
    spec = importlib.util.spec_from_file_location("source_atlas_no_private_graph_egress_audit", script_path)
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _run_no_private_graph_audit(args: list[str]) -> int:
    audit = _load_no_private_graph_audit()
    with redirect_stdout(StringIO()):
        return audit.main(args)


def test_no_private_graph_audit_uses_committed_contract_schema_target():
    audit = _load_no_private_graph_audit()

    assert "tools/source-atlas/foundry/contracts" in audit.DEFAULT_TARGETS
    assert "tools/source-atlas/schemas" not in audit.DEFAULT_TARGETS
    assert _run_no_private_graph_audit(["tools/source-atlas/foundry/contracts"]) == 0


def test_no_private_graph_audit_missing_mandatory_target_fails(tmp_path: Path):
    missing = tmp_path / "missing-contracts"

    assert _run_no_private_graph_audit([str(missing)]) == 1


def test_no_private_graph_audit_rejects_private_graph_fields_in_schema_target(tmp_path: Path):
    schema_dir = tmp_path / "schemas"
    schema_dir.mkdir()
    (schema_dir / "bad-schema.json").write_text(
        json.dumps(
            {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.testSchema",
                "privateLifeGraph": {
                    "goalText": "Private goal"
                },
            }
        ),
        encoding="utf-8",
    )

    assert _run_no_private_graph_audit([str(schema_dir)]) == 1
