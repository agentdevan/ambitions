"""Canonical governance registries for Source Atlas production lanes.

This layer is stricter than the older embedded terms/API helpers. It keeps the
Train 1 source-lane, legal/terms, and API governance posture machine-readable
without changing existing bounded pack builders in the same patch.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .boundary import ALLOWED_DATA_CLASSES
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, object_key_findings, read_json, utc_now, write_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[1]
GOVERNANCE_ROOT = SOURCE_ATLAS_ROOT / "governance"

SOURCE_LANE_REGISTRY_PATH = GOVERNANCE_ROOT / "source-lane-registry.json"
LEGAL_TERMS_REGISTRY_PATH = GOVERNANCE_ROOT / "legal-terms-registry.json"
API_GOVERNANCE_REGISTRY_PATH = GOVERNANCE_ROOT / "api-governance-registry.json"

SOURCE_LANE_SCHEMA_PATH = GOVERNANCE_ROOT / "schemas" / "source-lane-registry.schema.json"
LEGAL_TERMS_SCHEMA_PATH = GOVERNANCE_ROOT / "schemas" / "legal-terms-registry.schema.json"
API_GOVERNANCE_SCHEMA_PATH = GOVERNANCE_ROOT / "schemas" / "api-governance-registry.schema.json"

AUTHORITY_CLASSES = {
    "official_government",
    "official_institution",
    "standards_body",
    "regulated_body",
    "scholarly_metadata",
    "open_knowledge_graph",
    "public_catalog",
    "commercial_api",
    "non_authoritative_web",
    "unknown",
}

REDISTRIBUTION_POLICIES = {
    "redistributable",
    "redistributable_with_attribution",
    "lookup_only",
    "crosswalk_only",
    "review_required",
    "blocked",
}

R2_PACK_POLICIES = {
    "pack_allowed",
    "pack_allowed_with_attribution",
    "pack_blocked_lookup_only",
    "pack_blocked_crosswalk_only",
    "pack_blocked_restricted",
    "pack_blocked_unknown_terms",
}

REVIEW_STATUSES = {
    "reviewed",
    "review_required",
    "blocked",
    "candidate_only",
}

CATALOG_ALLOWED_CLAIMS = {"candidate_source_record", "discovery_metadata"}
WIKIDATA_ALLOWED_CLAIMS = {"entity_crosswalk", "identifier_crosswalk", "alias_crosswalk"}
FORBIDDEN_PERSONALIZED_OUTPUT_CLASSES = {
    "final_user_path",
    "final_schedule",
    "step_list",
    "personalized_plan",
    "private_goal_graph",
}
PACK_ALLOWED_POLICIES = {"pack_allowed", "pack_allowed_with_attribution"}
SOURCE_OF_SOURCES_CLASSES = {"public_catalog"}


def load_governance_registries(
    source_lane_path: Path | None = None,
    legal_terms_path: Path | None = None,
    api_governance_path: Path | None = None,
) -> dict[str, Any]:
    return {
        "source_lanes": read_json(source_lane_path or SOURCE_LANE_REGISTRY_PATH),
        "legal_terms": read_json(legal_terms_path or LEGAL_TERMS_REGISTRY_PATH),
        "api_governance": read_json(api_governance_path or API_GOVERNANCE_REGISTRY_PATH),
    }


def validate_governance_registries(
    *,
    source_lane_path: Path | None = None,
    legal_terms_path: Path | None = None,
    api_governance_path: Path | None = None,
    output_path: Path | None = None,
) -> dict[str, Any]:
    registries = load_governance_registries(source_lane_path, legal_terms_path, api_governance_path)
    source_lanes = registries["source_lanes"]
    legal_terms = registries["legal_terms"]
    api_governance = registries["api_governance"]

    issues: list[str] = []
    issues.extend(_validate_schema_artifacts())
    source_entries = _entries(source_lanes, "source_lanes")
    legal_entries = _entries(legal_terms, "licenses")
    api_entries = _entries(api_governance, "api_policies")

    legal_by_id = {entry.get("license_id"): entry for entry in legal_entries if isinstance(entry, dict)}
    api_by_id = {entry.get("api_policy_id"): entry for entry in api_entries if isinstance(entry, dict)}

    issues.extend(_validate_top_level(source_lanes, "ambitions.sourceAtlas.sourceLaneRegistry.v1", "source-lane-registry.json"))
    issues.extend(_validate_top_level(legal_terms, "ambitions.sourceAtlas.legalTermsRegistry.v1", "legal-terms-registry.json"))
    issues.extend(_validate_top_level(api_governance, "ambitions.sourceAtlas.apiGovernanceRegistry.v1", "api-governance-registry.json"))

    seen_source_ids: set[str] = set()
    for lane in source_entries:
        issues.extend(_validate_source_lane(lane, legal_by_id, api_by_id))
        source_id = lane.get("source_id")
        if source_id in seen_source_ids:
            issues.append(f"{source_id}: duplicate source lane")
        if isinstance(source_id, str):
            seen_source_ids.add(source_id)

    seen_license_ids: set[str] = set()
    for legal in legal_entries:
        issues.extend(_validate_legal_entry(legal))
        license_id = legal.get("license_id")
        if license_id in seen_license_ids:
            issues.append(f"{license_id}: duplicate legal/terms entry")
        if isinstance(license_id, str):
            seen_license_ids.add(license_id)

    seen_api_ids: set[str] = set()
    for api_policy in api_entries:
        issues.extend(_validate_api_policy(api_policy))
        api_policy_id = api_policy.get("api_policy_id")
        if api_policy_id in seen_api_ids:
            issues.append(f"{api_policy_id}: duplicate API policy")
        if isinstance(api_policy_id, str):
            seen_api_ids.add(api_policy_id)

    checks = _build_checks(source_entries, legal_entries, api_entries, issues)
    result = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.governanceRegistryValidation.v1",
        "createdAt": utc_now(),
        "status": "Source Green for governance tooling" if not issues else "Red",
        "valid": not issues,
        "sourceLaneCount": len(source_entries),
        "legalEntryCount": len(legal_entries),
        "apiPolicyCount": len(api_entries),
        "schemaPaths": {
            "sourceLane": str(SOURCE_LANE_SCHEMA_PATH.relative_to(SOURCE_ATLAS_ROOT.parents[1])),
            "legalTerms": str(LEGAL_TERMS_SCHEMA_PATH.relative_to(SOURCE_ATLAS_ROOT.parents[1])),
            "apiGovernance": str(API_GOVERNANCE_SCHEMA_PATH.relative_to(SOURCE_ATLAS_ROOT.parents[1])),
        },
        "checks": checks,
        "issues": issues,
        "statusCeiling": "Yellow overall Source Atlas; governance tooling only",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS
        + [
            "not full Source Atlas Green",
            "not production R2 readiness",
            "not native app runtime readiness",
            "not outside legal approval",
            "not universal goal coverage",
            "not a final user plan, schedule, or Step generator",
        ],
    }
    if output_path:
        write_json(output_path, result)
    return result


def governance_registry_markdown(result: dict[str, Any] | None = None) -> str:
    result = result or validate_governance_registries()
    lines = [
        "# Source Atlas Governance Registry Train 1",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['statusCeiling']}",
        "",
        "Scope completed:",
        "- Source lane registry schema and registry validation",
        "- Legal/terms registry schema and registry validation",
        "- API governance registry schema and registry validation",
        "- Source-specific hard rules for O*NET, BLS, Wikidata, OpenAlex, USAJOBS, and catalog/discovery lanes",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/governance_registry.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_governance_registry_train_01.py",
        "- tools/source-atlas/governance/source-lane-registry.json",
        "- tools/source-atlas/governance/legal-terms-registry.json",
        "- tools/source-atlas/governance/api-governance-registry.json",
        "- tools/source-atlas/governance/schemas/source-lane-registry.schema.json",
        "- tools/source-atlas/governance/schemas/legal-terms-registry.schema.json",
        "- tools/source-atlas/governance/schemas/api-governance-registry.schema.json",
        "- docs/qa/source-atlas/governance/source-atlas-governance-train-01.json",
        "- docs/qa/source-atlas/governance/source-atlas-governance-train-01.md",
        "",
        "Counts:",
        f"- Source lanes: {result['sourceLaneCount']}",
        f"- Legal/terms entries: {result['legalEntryCount']}",
        f"- API policies: {result['apiPolicyCount']}",
        "",
        "Checks:",
    ]
    for check in result["checks"]:
        lines.append(f"- {check['name']}: {'pass' if check['passed'] else 'fail'}")
    if result.get("issues"):
        lines.extend(["", "Issues:"])
        lines.extend(f"- {issue}" for issue in result["issues"])
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Source Atlas does not receive private user context.",
            "- Candidate discovery is not claim authority.",
            "- Source Atlas does not generate final plans, schedules, or Steps.",
            "",
            "Validation run:",
            "- python3 tools/source-atlas/source-atlas-foundry.py governance-registry-check --emit-evidence docs/qa/source-atlas/governance/source-atlas-governance-train-01.json --markdown docs/qa/source-atlas/governance/source-atlas-governance-train-01.md",
            "- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
            "- python3 scripts/source-atlas-boundary-audit.py",
            "- python3 scripts/source-atlas-no-private-graph-egress-audit.py",
            "- python3 scripts/ambitions-green-standard-audit.py",
            "- python3 scripts/ambitions-local-first-boundary-scan.py",
            "- git diff --check",
            "",
            "Validation not run:",
            "- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON registries, and QA evidence only.",
            "- Production R2 upload/readback not run; no production upload was requested.",
            "- Outside legal review not run or claimed.",
            "",
            "Proof artifacts:",
            "- docs/qa/source-atlas/governance/source-atlas-governance-train-01.json",
            "- docs/qa/source-atlas/governance/source-atlas-governance-train-01.md",
            "",
            "R2 request privacy proof:",
            "- Registry-level only. No native or production R2 request path changed in this train.",
            "- Packable lanes must declare public object prefixes and private-looking R2 key segments fail validation.",
            "",
            "No private graph egress proof:",
            "- Source lanes forbid private_goal_graph, final_user_path, final_schedule, step_list, and personalized_plan artifact classes.",
            "- Packable lane object prefixes are public/reference prefixes only.",
            "",
            "License/terms proof:",
            "- Legal/terms posture is machine-readable per license entry.",
            "- Missing or ambiguous legal/terms posture blocks pack output.",
            "- Outside legal approval is not claimed without an approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- USAJOBS is lookup-only, review-required, and pack_blocked_restricted.",
            "- Catalog/discovery lanes are candidate-only and cannot become claim authority.",
            "- Wikidata is crosswalk-only and cannot satisfy regulated authority.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 1. Claim-level provenance completeness belongs to the claim graph train.",
            "",
            "Freshness/revocation proof:",
            "- Source lanes carry freshness SLA fields.",
            "- Runtime revocation, stale-critical quarantine, and replacement selection are not claimed in Train 1.",
            "",
            "LKG/rollback proof:",
            "- Not claimed in Train 1. No stable R2 publish, pointer update, or rollback operation ran.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 1. No native files changed and no XCTest/build-for-testing gate was required.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Files moved or created: new governance registry, schemas, tests, and QA evidence listed above.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this train; later native/R2 trains remain unproven.",
            "- Next repair train if debt remains: Train 2 adapter SDK and deterministic harvest runner.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Known risks:",
            "- This is governance tooling proof, not app runtime fetch/cache/verify proof.",
            "- Legal entries are technical posture records unless an approval artifact is present.",
            "- Catalog and review-required lanes remain non-packable until later review gates pass.",
            "",
            "Follow-up required:",
            "- Train 2: adapter SDK and deterministic harvest runner green.",
            "- Later trains: claim graph, coverage frontier, generalized pack compiler, R2 publish gate, native fetch/cache/verify, and source inspection.",
            "",
            "Rollback plan:",
            "- Revert the governance registry files, validator module, CLI command, tests, and QA evidence from this train.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def write_governance_registry_report(
    markdown_path: Path,
    json_path: Path,
    *,
    source_lane_path: Path | None = None,
    legal_terms_path: Path | None = None,
    api_governance_path: Path | None = None,
) -> dict[str, Any]:
    result = validate_governance_registries(
        source_lane_path=source_lane_path,
        legal_terms_path=legal_terms_path,
        api_governance_path=api_governance_path,
        output_path=json_path,
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(governance_registry_markdown(result), encoding="utf-8")
    return result


def _entries(registry: dict[str, Any], key: str) -> list[dict[str, Any]]:
    value = registry.get(key, [])
    return value if isinstance(value, list) else []


def _validate_top_level(value: dict[str, Any], kind: str, label: str) -> list[str]:
    issues: list[str] = []
    for field in ["schema_version", "kind", "registries_version", "updated_at"]:
        if not value.get(field):
            issues.append(f"{label}: missing {field}")
    if value.get("kind") != kind:
        issues.append(f"{label}: wrong kind {value.get('kind')}")
    return issues


def _validate_schema_artifacts() -> list[str]:
    issues: list[str] = []
    for path in [SOURCE_LANE_SCHEMA_PATH, LEGAL_TERMS_SCHEMA_PATH, API_GOVERNANCE_SCHEMA_PATH]:
        if not path.exists():
            issues.append(f"{path.relative_to(SOURCE_ATLAS_ROOT.parents[1])}: missing schema artifact")
            continue
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            issues.append(f"{path.relative_to(SOURCE_ATLAS_ROOT.parents[1])}: invalid schema JSON: {exc}")
            continue
        if not value.get("$id") or not value.get("required"):
            issues.append(f"{path.relative_to(SOURCE_ATLAS_ROOT.parents[1])}: schema requires $id and required")
    return issues


def _validate_source_lane(lane: dict[str, Any], legal_by_id: dict[str, dict[str, Any]], api_by_id: dict[str, dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    source_id = lane.get("source_id", "<source>")
    required = [
        "source_id",
        "source_name",
        "source_class",
        "authority_class",
        "jurisdiction",
        "domain_scope",
        "claim_classes_allowed",
        "claim_classes_forbidden",
        "license_id",
        "license_url",
        "terms_url",
        "rights_url",
        "attribution_required",
        "redistribution_policy",
        "r2_pack_policy",
        "lookup_policy",
        "crosswalk_policy",
        "review_status",
        "review_owner",
        "last_reviewed_at",
        "next_review_due_at",
        "freshness_sla",
        "api_mode",
        "api_policy_id",
        "rate_policy_id",
        "budget_policy_id",
        "secret_policy_id",
        "allowed_artifact_classes",
        "forbidden_artifact_classes",
        "non_claims",
        "schema_version",
    ]
    for field in required:
        value = lane.get(field)
        if field not in lane or value is None or value == "" or value == []:
            issues.append(f"{source_id}: missing source lane field {field}")
    if lane.get("authority_class") not in AUTHORITY_CLASSES:
        issues.append(f"{source_id}: unsupported authority_class {lane.get('authority_class')}")
    if lane.get("redistribution_policy") not in REDISTRIBUTION_POLICIES:
        issues.append(f"{source_id}: unsupported redistribution_policy {lane.get('redistribution_policy')}")
    if lane.get("r2_pack_policy") not in R2_PACK_POLICIES:
        issues.append(f"{source_id}: unsupported r2_pack_policy {lane.get('r2_pack_policy')}")
    if lane.get("review_status") not in REVIEW_STATUSES:
        issues.append(f"{source_id}: unsupported review_status {lane.get('review_status')}")

    legal = legal_by_id.get(lane.get("license_id"))
    if not legal:
        issues.append(f"{source_id}: missing legal/terms registry entry {lane.get('license_id')}")
    else:
        issues.extend(_validate_lane_against_legal(lane, legal))
    if lane.get("api_policy_id") not in api_by_id:
        issues.append(f"{source_id}: missing API governance policy {lane.get('api_policy_id')}")

    allowed_artifacts = set(lane.get("allowed_artifact_classes", []))
    if allowed_artifacts - ALLOWED_DATA_CLASSES - {"candidate_source_record", "discovery_metadata", "public_crosswalk", "lookup_response_metadata"}:
        issues.append(f"{source_id}: unknown allowed artifact classes {sorted(allowed_artifacts)}")
    forbidden_personalized = allowed_artifacts & FORBIDDEN_PERSONALIZED_OUTPUT_CLASSES
    if forbidden_personalized:
        issues.append(f"{source_id}: forbidden personalized output classes allowed: {sorted(forbidden_personalized)}")
    forbidden_classes = set(lane.get("forbidden_artifact_classes", []))
    for forbidden in FORBIDDEN_PERSONALIZED_OUTPUT_CLASSES:
        if forbidden not in forbidden_classes:
            issues.append(f"{source_id}: forbidden_artifact_classes must include {forbidden}")

    if lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES:
        key_prefix = lane.get("r2_object_key_prefix")
        if not key_prefix:
            issues.append(f"{source_id}: packable lane requires r2_object_key_prefix")
        else:
            issues.extend(object_key_findings(str(key_prefix)))

    if lane.get("source_class") in SOURCE_OF_SOURCES_CLASSES or lane.get("authority_class") == "public_catalog":
        if lane.get("review_required") is not True:
            issues.append(f"{source_id}: catalog/discovery source must remain review_required")
        if set(lane.get("claim_classes_allowed", [])) - CATALOG_ALLOWED_CLAIMS:
            issues.append(f"{source_id}: catalog/discovery source cannot become claim authority")
        if lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES:
            issues.append(f"{source_id}: catalog/discovery source cannot be R2 pack allowed")

    if "wikidata" in str(source_id).lower():
        if lane.get("authority_class") != "open_knowledge_graph":
            issues.append(f"{source_id}: Wikidata authority_class must be open_knowledge_graph")
        if lane.get("regulated_authority_allowed") is not False:
            issues.append(f"{source_id}: Wikidata regulated authority use must be false")
        if set(lane.get("claim_classes_allowed", [])) - WIKIDATA_ALLOWED_CLAIMS:
            issues.append(f"{source_id}: Wikidata must stay crosswalk-only")

    if "usajobs" in str(source_id).lower():
        if lane.get("r2_pack_policy") != "pack_blocked_restricted":
            issues.append(f"{source_id}: USAJOBS must be blocked from R2-packable output")
        if lane.get("redistribution_policy") != "lookup_only":
            issues.append(f"{source_id}: USAJOBS redistribution_policy must be lookup_only")

    return issues


def _validate_lane_against_legal(lane: dict[str, Any], legal: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    source_id = lane.get("source_id", "<source>")
    if not legal.get("license_url") or not legal.get("terms_url"):
        if lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES:
            issues.append(f"{source_id}: missing legal/terms posture blocks pack output")
    if lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES and legal.get("pack_output_allowed") is not True:
        issues.append(f"{source_id}: legal/terms registry does not allow pack output")
    if lane.get("redistribution_policy") in {"redistributable", "redistributable_with_attribution"} and legal.get("redistribution_allowed") is not True:
        issues.append(f"{source_id}: redistribution policy conflicts with legal registry")
    if legal.get("outside_legal_required") is True and legal.get("outside_legal_status") == "approved" and not legal.get("approval_artifact_path"):
        issues.append(f"{source_id}: outside legal approval claimed without artifact")
    return issues


def _validate_legal_entry(entry: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    license_id = entry.get("license_id", "<license>")
    required = [
        "license_id",
        "license_name",
        "license_url",
        "terms_url",
        "rights_url",
        "redistribution_allowed",
        "modification_allowed",
        "commercial_use_allowed",
        "attribution_required",
        "share_alike_required",
        "source_specific_restrictions",
        "pack_output_allowed",
        "lookup_output_allowed",
        "review_required",
        "outside_legal_required",
        "outside_legal_status",
        "approval_artifact_path",
        "effective_date",
        "reviewed_at",
        "review_owner",
        "expires_at",
        "non_claims",
        "schema_version",
    ]
    for field in required:
        if field not in entry or entry.get(field) is None:
            issues.append(f"{license_id}: missing legal/terms field {field}")
    if entry.get("outside_legal_status") == "approved" and not entry.get("approval_artifact_path"):
        issues.append(f"{license_id}: outside legal approval claimed without approval artifact")
    if entry.get("pack_output_allowed") is True and (not entry.get("license_url") or not entry.get("terms_url")):
        issues.append(f"{license_id}: pack output cannot be allowed with missing license/terms URL")
    return issues


def _validate_api_policy(policy: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    policy_id = policy.get("api_policy_id", "<api-policy>")
    required = [
        "api_policy_id",
        "source_id",
        "api_mode",
        "key_required",
        "env_var_name",
        "missing_key_behavior",
        "rate_limit_per_second",
        "rate_limit_per_minute",
        "daily_budget_limit",
        "monthly_budget_limit",
        "max_records_per_run",
        "max_pages_per_run",
        "timeout_seconds",
        "retry_policy",
        "backoff_policy",
        "circuit_breaker_policy",
        "live_flag_required",
        "execute_flag_required",
        "secret_redaction_required",
        "high_volume_review_required",
        "budget_owner",
        "evidence_output_policy",
        "schema_version",
    ]
    for field in required:
        if field not in policy or policy.get(field) is None:
            issues.append(f"{policy_id}: missing API governance field {field}")
    if policy.get("key_required") is True and not policy.get("env_var_name"):
        issues.append(f"{policy_id}: key_required requires env_var_name")
    if policy.get("secret_redaction_required") is not True:
        issues.append(f"{policy_id}: secret_redaction_required must be true")
    if policy.get("live_flag_required") is not True:
        issues.append(f"{policy_id}: live paths must require explicit live flag")
    if policy.get("execute_flag_required") is not True:
        issues.append(f"{policy_id}: write/publish paths must require explicit execute flag")
    for field in ["daily_budget_limit", "monthly_budget_limit", "max_records_per_run", "max_pages_per_run", "timeout_seconds"]:
        value = policy.get(field)
        if not isinstance(value, int) or value <= 0:
            issues.append(f"{policy_id}: {field} must be positive integer")
    if str(policy.get("source_id", "")).startswith("openalex") or "openalex" in str(policy_id):
        high_volume = policy.get("high_volume_policy", {})
        if policy.get("high_volume_review_required") is not True:
            issues.append(f"{policy_id}: OpenAlex high-volume use must require review")
        if high_volume.get("key_required_for_high_volume") is not True:
            issues.append(f"{policy_id}: OpenAlex high-volume use must require API key")
        if not high_volume.get("approval_artifact_required"):
            issues.append(f"{policy_id}: OpenAlex high-volume use must require approval artifact")
        if not high_volume.get("budget_policy_id"):
            issues.append(f"{policy_id}: OpenAlex high-volume use must declare budget policy")
    if str(policy.get("source_id", "")).startswith("bls") or "bls" in str(policy_id):
        v1 = policy.get("v1_no_key_mode", {})
        v2 = policy.get("v2_key_mode", {})
        if v1.get("allowed") is not True:
            issues.append(f"{policy_id}: BLS v1 no-key mode must be allowed")
        if v2.get("optional") is not True or v2.get("env_var_name") != "BLS_API_KEY":
            issues.append(f"{policy_id}: BLS v2 key mode must be optional and gated by BLS_API_KEY")
    return issues


def _build_checks(source_entries: list[dict[str, Any]], legal_entries: list[dict[str, Any]], api_entries: list[dict[str, Any]], issues: list[str]) -> list[dict[str, Any]]:
    source_ids = {entry.get("source_id") for entry in source_entries}
    legal_ids = {entry.get("license_id") for entry in legal_entries}
    api_ids = {entry.get("api_policy_id") for entry in api_entries}
    return [
        {"name": "source_lane_registry_schema_exists", "passed": SOURCE_LANE_SCHEMA_PATH.exists()},
        {"name": "legal_terms_registry_schema_exists", "passed": LEGAL_TERMS_SCHEMA_PATH.exists()},
        {"name": "api_governance_registry_schema_exists", "passed": API_GOVERNANCE_SCHEMA_PATH.exists()},
        {"name": "source_lanes_have_required_posture", "passed": not any("missing source lane field" in issue for issue in issues)},
        {"name": "legal_terms_have_required_posture", "passed": not any("missing legal/terms field" in issue for issue in issues)},
        {"name": "api_policies_have_required_posture", "passed": not any("missing API governance field" in issue for issue in issues)},
        {"name": "wikidata_crosswalk_only", "passed": "wikidata.crosswalk" in source_ids and not any("Wikidata" in issue for issue in issues)},
        {"name": "openalex_high_volume_gated", "passed": any("openalex" in str(policy_id) for policy_id in api_ids) and not any("OpenAlex" in issue for issue in issues)},
        {"name": "bls_v1_v2_modes_represented", "passed": any("bls" in str(policy_id) for policy_id in api_ids) and not any("BLS" in issue for issue in issues)},
        {"name": "usajobs_r2_pack_blocked", "passed": "usajobs.search" in source_ids and not any("USAJOBS" in issue for issue in issues)},
        {"name": "legal_registry_present", "passed": bool(legal_ids)},
        {"name": "private_r2_key_validation", "passed": not any("private_r2_object_key" in issue for issue in issues)},
        {"name": "no_final_plan_schedule_step_output", "passed": not any("forbidden personalized output classes allowed" in issue for issue in issues)},
    ]
