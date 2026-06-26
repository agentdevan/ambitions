from __future__ import annotations

import json
import sys
import zipfile
from io import BytesIO
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.adapters import FetchResult, harvest_sources
from foundry.boundary import boundary_issues_for_value, object_key_issues
from foundry.certification import certify_registry
from foundry.cli import doctor
from foundry.compiler import compile_bundle
from foundry.coverage_benchmark import coverage_diff, run_golden_benchmarks
from foundry.model import privacy_findings_for_value, read_json
from foundry.publisher import build_r2_plan
from foundry.r2_contracts import (
    build_last_known_good_manifest,
    build_revocation_manifest,
    object_layout,
    release_manifest_schema,
    validate_promotion_gate,
)
from foundry.validator import validate_bundle, validate_pack
from foundry.workbench import build_workbench


def test_doctor_reports_source_and_pathway_counts():
    result = doctor()

    assert result["sourceCount"] >= 7
    assert result["pathwaySeedCount"] == 2
    assert result["r2Posture"]["default"] == "staging plan only"


def test_registry_certification_requires_public_reference_adapter_contracts():
    result = certify_registry()

    assert result["valid"], result["issues"]
    assert result["sourceCount"] >= 8
    assert result["adapterCount"] >= 6
    assert all(source["privacyExpectations"]["rejectsPrivateUserContext"] for source in result["sources"])
    assert all(source["fixtureExpectationIDs"] for source in result["sources"])
    assert all(source["driftCheckIDs"] for source in result["sources"])


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
    assert any(entry["id"] == "source-certification" for entry in manifest_registry_entries(bundle_root))
    assert any(entry["id"] == "entity-registry" for entry in manifest_registry_entries(bundle_root))
    assert any(entry["id"] == "coverage-manifest" for entry in manifest_registry_entries(bundle_root))


def test_workbench_preserves_claim_provenance_and_blocks_silent_conflicts(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-workbench", "staging")
    bundle_root = Path(result["bundleRoot"])

    workbench = build_workbench(bundle_root)

    assert workbench["valid"], workbench["issues"]
    assert workbench["entityCount"] > 0
    assert workbench["claimCount"] > 0
    assert workbench["conflictCount"] == 0
    assert all(claim["provenanceIDs"] for claim in workbench["extractedClaims"])
    assert all(item["silentWinnerSelectionAllowed"] is False for item in workbench["adjudications"])


def test_coverage_diff_and_golden_benchmarks_are_candidate_only(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-coverage", "staging")
    bundle_root = Path(result["bundleRoot"])

    diff = coverage_diff(bundle_root)
    benchmarks = run_golden_benchmarks(bundle_root)

    assert diff["valid"], diff
    assert diff["productionCoverageClaimed"] is False
    assert diff["benchmarkReadiness"] == "candidate_only_not_production_coverage"
    assert benchmarks["valid"], benchmarks
    assert benchmarks["criticalFailureCount"] == 0
    assert benchmarks["productionCoverageClaimed"] is False


def test_r2_manifest_freshness_lkg_and_promotion_gate_are_dry_run_only(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-r2-contracts", "staging")
    bundle_root = Path(result["bundleRoot"])
    plan_path = tmp_path / "r2-plan.json"
    plan = build_r2_plan(bundle_root, "ambitions-source-atlas-staging", "source-atlas/v1", "staging")
    plan_path.write_text(json.dumps(plan, indent=2, sort_keys=True), encoding="utf-8")

    layout = object_layout()
    manifest_schema = release_manifest_schema()
    revocation = build_revocation_manifest(bundle_root)
    lkg = build_last_known_good_manifest(bundle_root, "staging")
    gate = validate_promotion_gate(bundle_root, plan_path, channel="staging")

    assert layout["publicReferenceOnly"] is True
    assert "checksums" in manifest_schema["promotionRequiredChecks"]
    assert revocation["valid"], revocation["issues"]
    assert lkg["valid"], lkg["issues"]
    assert gate["dryRunOnly"] is True
    assert gate["wouldUpload"] is False
    assert gate["validForPromotion"], gate["issues"]


def test_promotion_gate_fails_private_key_missing_checksum_and_revoked_use(tmp_path: Path):
    result = compile_bundle(tmp_path, "test-foundry-r2-negative", "staging")
    bundle_root = Path(result["bundleRoot"])
    plan = build_r2_plan(bundle_root, "ambitions-source-atlas-staging", "source-atlas/v1", "staging")
    plan["objects"][0]["objectKey"] = "source-atlas/v1/users/user-1234/goal/manifest.json"
    plan["objects"][1].pop("sha256")
    plan_path = tmp_path / "bad-r2-plan.json"
    plan_path.write_text(json.dumps(plan, indent=2, sort_keys=True), encoding="utf-8")
    revocation_path = tmp_path / "revocation.json"
    first_pack_path = read_json(bundle_root / "manifest.json")["packIndex"][0]["path"]
    revoked = build_revocation_manifest(bundle_root, revoked_artifact_ids=[first_pack_path])
    revocation_path.write_text(json.dumps(revoked, indent=2, sort_keys=True), encoding="utf-8")

    gate = validate_promotion_gate(bundle_root, plan_path, revocation_path=revocation_path, channel="staging")

    assert gate["validForPromotion"] is False
    encoded_issues = json.dumps(gate["issues"])
    assert "private_r2_object_key_segment" in encoded_issues
    assert "checksums" in encoded_issues
    assert "revoked artifact referenced" in encoded_issues


def test_r2_dry_run_privacy_fixtures_cover_positive_and_negative_shapes():
    fixture_root = Path(__file__).resolve().parents[2] / "fixtures" / "r2"
    valid = read_json(fixture_root / "valid" / "public-reference-r2-plan.json")
    valid_codes = r2_plan_fixture_issue_codes(valid["payload"])
    assert valid_codes == []

    for path in sorted((fixture_root / "invalid").glob("*.json")):
        fixture = read_json(path)
        codes = r2_plan_fixture_issue_codes(fixture["payload"])
        missing = [code for code in fixture["expectedIssueCodes"] if code not in codes]
        assert not missing, (path, missing, codes)


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

    plan = build_r2_plan(bundle_root, "ambitions-source-atlas-staging", "source-atlas/v1", "staging")
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


def test_harvest_sources_normalizes_public_sources_and_blocks_missing_auth(tmp_path: Path):
    result = harvest_sources(
        tmp_path,
        "test-harvest-run",
        source_ids=[
            "nara.constitution.presidency",
            "nasa.astronaut.requirements",
            "data.gov.catalog",
            "college-scorecard.api",
            "usajobs.search",
        ],
        limit=2,
        fetcher=fake_fetch,
        env={},
    )
    run_root = Path(result["runRoot"])
    manifest = read_json(run_root / "manifest.json")

    assert result["harvestedCount"] == 4
    assert result["blockedCount"] == 1
    assert result["privacyScan"]["passed"], result["privacyScan"]
    assert any(item["sourceID"] == "usajobs.search" for item in manifest["blockedSources"])

    datagov = read_json(run_root / "normalized" / "data.gov.catalog.json")
    encoded = json.dumps(datagov)
    assert "person@example.gov" not in encoded
    assert "redacted" in encoded
    assert datagov["records"][0]["publisher"] == "NASA"


def test_compile_bundle_includes_harvest_summary_without_raw_snapshots(tmp_path: Path):
    harvest = harvest_sources(
        tmp_path / "harvest",
        "test-harvest-compile",
        source_ids=["nara.constitution.presidency", "nasa.astronaut.requirements", "usajobs.search"],
        limit=2,
        fetcher=fake_fetch,
        env={},
    )
    result = compile_bundle(tmp_path / "bundles", "test-foundry-harvested", "staging", harvest_root=Path(harvest["runRoot"]))
    bundle_root = Path(result["bundleRoot"])

    validation = validate_bundle(bundle_root)
    assert validation["valid"], validation["issues"]
    manifest = read_json(bundle_root / "manifest.json")
    assert any(entry["id"] == "harvest-summary" for entry in manifest["registryIndex"])

    summary = read_json(bundle_root / "registries" / "harvest-summary.json")
    encoded = json.dumps(summary)
    assert "snapshots/" not in encoded
    assert "USAJOBS_AUTHORIZATION_KEY" in encoded


def test_onet_adapter_normalizes_downloadable_text_database(tmp_path: Path):
    result = harvest_sources(
        tmp_path,
        "test-onet-run",
        source_ids=["onet.database"],
        limit=2,
        fetcher=fake_fetch,
        env={},
    )
    run_root = Path(result["runRoot"])
    onet = read_json(run_root / "normalized" / "onet.database.json")

    assert result["harvestedCount"] == 1
    assert onet["status"] == "harvested"
    assert any(record["recordType"] == "onet_table_summary" and record["file"] == "Occupation Data.txt" for record in onet["records"])
    assert any(record["recordType"] == "onet_table_summary" and record["file"] == "Transferable Skills.txt" for record in onet["records"])
    assert any(record["recordType"] == "onet_career_cluster_crosswalk" and record["careerClusterCount"] == 1 for record in onet["records"])
    assert any(record["recordType"] == "onet_transfer_surface_map" and len(record["surfaces"]) >= 6 for record in onet["records"])
    assert any("Aerospace Engineers" in json.dumps(record) for record in onet["records"])


def manifest_registry_entries(bundle_root: Path) -> list[dict[str, object]]:
    return read_json(bundle_root / "manifest.json")["registryIndex"]


def r2_plan_fixture_issue_codes(plan: dict[str, object]) -> list[str]:
    codes = [issue.code for issue in boundary_issues_for_value(plan, "r2-plan")]
    for obj in plan.get("objects", []):
        if isinstance(obj, dict):
            codes.extend(issue.code for issue in object_key_issues(str(obj.get("objectKey", ""))))
            if "sha256" not in obj:
                codes.append("missing_sha256")
            if "bytes" not in obj:
                codes.append("missing_bytes")
            args = obj.get("wranglerArgs", [])
            if isinstance(args, list) and args and "--remote" not in args:
                codes.append("missing_remote_flag")
    return sorted(set(codes))


def fake_fetch(url: str, headers: dict[str, str] | None, max_bytes: int) -> FetchResult:
    del max_bytes
    if "archives.gov" in url:
        return FetchResult(url, 200, "text/html", b"<html>thirty five natural born fourteen years</html>")
    if "astronaut-requirements" in url:
        body = b"<html>U.S. citizen master's degree two years 1,000 pilot physical</html>"
        return FetchResult(url, 200, "text/html", body)
    if "astronaut-selection" in url:
        return FetchResult(url, 200, "text/html", b"<html>candidate selection training interview</html>")
    if "datagov/v4/search" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            json.dumps(
                {
                    "results": [
                        {
                            "dcat": {
                                "identifier": "nasa-dataset",
                                "title": "NASA dataset",
                                "accessLevel": "public",
                                "publisher": {"name": "NASA"},
                                "modified": "2026-01-01",
                                "landingPage": "https://example.gov/nasa",
                                "contactPoint": {"hasEmail": "mailto:person@example.gov"},
                                "distribution": [{"downloadURL": "https://example.gov/data.csv"}],
                            }
                        }
                    ]
                }
            ).encode("utf-8"),
        )
    if "collegescorecard" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            json.dumps(
                {
                    "metadata": {"total": 1},
                    "results": [
                        {
                            "id": 166683,
                            "school.name": "Massachusetts Institute of Technology",
                            "school.state": "MA",
                            "latest.cost.tuition.in_state": 62396,
                            "latest.completion.rate_suppressed.overall": 0.9624,
                        }
                    ],
                }
            ).encode("utf-8"),
        )
    if "bls.gov" in url:
        return FetchResult(
            url,
            200,
            "application/json",
            b'{"status":"REQUEST_SUCCEEDED","message":[],"Results":{"series":[{"seriesID":"OEUN000000000000000000001","data":[{"year":"2025","period":"A01","value":"155495730"}]}]}}',
        )
    if url.endswith("database.html"):
        return FetchResult(url, 200, "text/html", b'<html>O*NET 30.3 Database <a href="/dl_files/database/db_30_3_text.zip">Text</a></html>')
    if url.endswith("db_30_3_text.zip"):
        return FetchResult(url, 200, "application/zip", fake_onet_zip())
    if "onetonline.org/find/career" in url:
        return FetchResult(
            url,
            200,
            "text/html",
            b'''<html><table><tbody>
<tr><td data-title="Career Cluster"><a href="/find/career?c=010100">Advanced Manufacturing</a></td><td data-title="Sub-Cluster"><a href="/find/career?c=010101">Engineering</a></td><td data-title="Code">17-2011.00</td><td data-title="Occupation"><a href="https://www.onetonline.org/link/summary/17-2011.00">Aerospace Engineers</a></td></tr>
<tr><td data-title="Career Cluster"><a href="/find/career?c=010100">Advanced Manufacturing</a></td><td data-title="Sub-Cluster"><a href="/find/career?c=010104">Robotics</a></td><td data-title="Code">17-2199.08</td><td data-title="Occupation"><a href="https://www.onetonline.org/link/summary/17-2199.08">Robotics Engineers</a></td></tr>
</tbody></table></html>''',
        )
    raise AssertionError(f"unexpected fake fetch URL: {url}")


def fake_onet_zip() -> bytes:
    buffer = BytesIO()
    table = "O*NET-SOC Code\tTitle\tDescription\n17-2011.00\tAerospace Engineers\tPerform engineering duties in designing aircraft.\n"
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("Occupation Data.txt", table)
        archive.writestr("Occupation Level Metadata.txt", "O*NET-SOC Code\tItem\n17-2011.00\tData-level\n")
        archive.writestr("Skills.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tSystems Analysis\t4.5\n")
        archive.writestr("Essential Skills.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tActive Learning\t4.1\n")
        archive.writestr("Transferable Skills.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tCritical Thinking\t4.6\n")
        archive.writestr("Knowledge.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tEngineering and Technology\t4.7\n")
        archive.writestr("Abilities.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tDeductive Reasoning\t4.4\n")
        archive.writestr("Work Activities.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tAnalyzing Data or Information\t4.6\n")
        archive.writestr("Work Styles.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tDependability\t4.2\n")
        archive.writestr("Work Context.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tTeamwork\t4.0\n")
        archive.writestr("Task Statements.txt", "Task ID\tTask\n1\tAnalyze aerospace systems.\n")
        archive.writestr("Tasks to DWAs.txt", "Task ID\tDWA ID\n1\tDWA:1\n")
        archive.writestr("Related Occupations.txt", "O*NET-SOC Code\tRelated O*NET-SOC Code\tTitle\n17-2011.00\t17-2199.00\tEngineers, All Other\n")
        archive.writestr("Job Titles.txt", "O*NET-SOC Code\tReported Job Title\n17-2011.00\tAerospace Engineer\n")
        archive.writestr("Sample of Reported Titles.txt", "O*NET-SOC Code\tReported Job Title\n17-2011.00\tAerospace Engineer\n")
        archive.writestr("Job Zones.txt", "O*NET-SOC Code\tJob Zone\n17-2011.00\t4\n")
        archive.writestr("Job Zone Reference.txt", "Job Zone\tName\n4\tConsiderable Preparation Needed\n")
        archive.writestr("Education.txt", "O*NET-SOC Code\tCategory\tData Value\n17-2011.00\tBachelor's degree\t70\n")
        archive.writestr("Training and Experience.txt", "O*NET-SOC Code\tCategory\tData Value\n17-2011.00\tRelated work experience\t4\n")
        archive.writestr("Career Interest Types.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tInvestigative\t5\n")
        archive.writestr("Specific Interest Areas.txt", "O*NET-SOC Code\tElement Name\tData Value\n17-2011.00\tEngineering\t5\n")
        archive.writestr("Specific Interest Areas to Career Interest Types.txt", "Specific Interest Area\tCareer Interest Type\nEngineering\tInvestigative\n")
        archive.writestr("Interests Illustrative Occupations.txt", "Career Interest Type\tO*NET-SOC Code\tTitle\nInvestigative\t17-2011.00\tAerospace Engineers\n")
        archive.writestr("Software Skills.txt", "O*NET-SOC Code\tExample\tCommodity Title\n17-2011.00\tCAD\tComputer aided design CAD software\n")
        archive.writestr("Essential Skills to Work Activities.txt", "Element Name\tWork Activity\nActive Learning\tAnalyzing Data or Information\n")
        archive.writestr("Transferable Skills to Work Activities.txt", "Element Name\tWork Activity\nCritical Thinking\tAnalyzing Data or Information\n")
    return buffer.getvalue()
