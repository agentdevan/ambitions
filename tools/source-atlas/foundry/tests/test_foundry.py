from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.cli import doctor
from foundry.compiler import compile_bundle
from foundry.model import privacy_findings_for_value, read_json
from foundry.publisher import build_r2_plan
from foundry.validator import validate_bundle, validate_pack


def test_doctor_reports_source_and_pathway_counts():
    result = doctor()

    assert result["sourceCount"] >= 7
    assert result["pathwaySeedCount"] == 2
    assert result["r2Posture"]["default"] == "staging plan only"


def test_compile_bundle_validates_presidency_and_astronaut_packs(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-v1", "staging")
    bundle_root = Path(result["bundleRoot"])

    validation = validate_bundle(bundle_root)
    assert validation["valid"], validation["issues"]
    assert validation["packCount"] == 2

    president = read_json(bundle_root / "packs" / "pack.civic.us_president.json")
    astronaut = read_json(bundle_root / "packs" / "pack.career.nasa_astronaut.json")

    assert any(item["structuredRule"].get("type") == "minimum_age" and item["structuredRule"].get("years") == 35 for item in president["requirements"])
    assert any(path["id"] == "alternate.governor" for path in president["pathways"][0]["alternatePaths"])
    assert any(item["structuredRule"].get("type") == "education_or_equivalent" for item in astronaut["requirements"])
    assert any(path["id"] == "alternate.aerospace_engineer" for path in astronaut["pathways"][0]["alternatePaths"])
    assert "systems_engineering" in astronaut["transferGraph"]["skillAtoms"]


def test_pack_validator_rejects_private_context(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-v2", "staging")
    bundle_root = Path(result["bundleRoot"])
    pack = read_json(bundle_root / "packs" / "pack.career.nasa_astronaut.json")
    pack["claims"][0]["text"] = "My goal is private and my email is person@example.com."

    issues = validate_pack(pack, "mutated")

    assert any("email_address" in issue for issue in issues)
    assert any("first_person_private_context" in issue for issue in issues)


def test_r2_plan_is_validation_backed_and_contains_no_credentials(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-v3", "staging")
    bundle_root = Path(result["bundleRoot"])

    plan = build_r2_plan(bundle_root, "ambitions-source-atlas", "source-atlas/v1", "staging")
    encoded = json.dumps(plan)

    assert plan["validForUpload"], plan
    assert len(plan["objects"]) >= 5
    assert "Authorization-Key" not in encoded
    assert "CLOUDFLARE_R2_SECRET_ACCESS_KEY" not in encoded
    assert any(obj["objectKey"].endswith("/channels/staging/manifest.json") for obj in plan["objects"])


def test_privacy_boundary_lines_are_not_false_positives():
    findings = privacy_findings_for_value(
        {
            "privacyBoundary": "public/reference/freshness only; no private life graph or private user context",
            "nonClaim": "not private life graph storage",
        },
        "boundary",
    )

    assert findings == []
