"""Draft governance intake packets for catalog candidate review packets.

This compiler prepares source-lane/legal/API draft records for human review. It
does not mutate active registries and does not approve source authority,
redistribution, live harvest, pack output, or R2 output.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_candidate_review import FORBIDDEN_ARTIFACT_CLASSES
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_GOVERNANCE_INTAKE_VERSION = "source-atlas-catalog-governance-intake-train-57"
CATALOG_GOVERNANCE_INTAKE_KIND = "ambitions.sourceAtlas.catalogGovernanceIntake.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

GOVERNANCE_INTAKE_NON_CLAIMS = [
    "not active source registry mutation",
    "not source authority",
    "not legal approval",
    "not outside legal approval",
    "not API approval",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class CatalogGovernanceIntakeOptions:
    input_path: Path
    output_root: Path
    created_at: str | None = None


def compile_catalog_governance_intake(options: CatalogGovernanceIntakeOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.input_path)
    review_packets = _review_packets(payload)
    input_schema_issues = _input_schema_issues(payload, review_packets)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-governance-intake-input")

    issues: list[str] = list(input_schema_issues)
    draft_packets: list[dict[str, Any]] = []
    registry_mutations: list[dict[str, Any]] = []
    for index, packet in enumerate(review_packets):
        packet_issues = _review_packet_issues(packet, index)
        issues.extend(packet_issues)
        draft_packets.append(_draft_governance_packet(packet, created_at, packet_issues))

    draft_packets = sorted(draft_packets, key=lambda item: (item["domain_guess"], item["candidate_id"], item["intake_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_GOVERNANCE_INTAKE_KIND,
        "versionID": CATALOG_GOVERNANCE_INTAKE_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "draftGovernancePackets": draft_packets,
        "activeRegistryMutations": registry_mutations,
        "recordCounts": {
            "reviewPackets": len(review_packets),
            "draftGovernancePackets": len(draft_packets),
            "activeRegistryMutations": len(registry_mutations),
            "approvedSourceLanes": 0,
            "approvedLegalEntries": 0,
            "approvedApiPolicies": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": GOVERNANCE_INTAKE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-governance-intake")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(review_packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "governance_intake_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "no_active_registry_mutations",
            "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0
            and all(packet["active_registry_mutation_allowed"] is False for packet in draft_packets),
            "issues": [],
        },
        {
            "name": "all_drafts_review_required",
            "passed": all(packet["review_status"] == "review_required" for packet in draft_packets),
            "issues": [],
        },
        {
            "name": "legal_entries_not_approved",
            "passed": all(packet["legal_terms_draft"]["redistribution_allowed"] is False and packet["legal_terms_draft"]["pack_output_allowed"] is False for packet in draft_packets),
            "issues": [],
        },
        {
            "name": "api_live_harvest_blocked",
            "passed": all(packet["api_governance_draft"]["live_harvest_allowed"] is False for packet in draft_packets),
            "issues": [],
        },
        {
            "name": "pack_and_r2_output_blocked",
            "passed": all(packet["source_lane_draft"]["r2_pack_policy"].startswith("pack_blocked") for packet in draft_packets),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    issues.extend(input_privacy_issues)
    issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogGovernanceIntakeManifest.v1",
        "versionID": CATALOG_GOVERNANCE_INTAKE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog governance intake draft tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; draft governance intake only",
        "inputPath": str(options.input_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogGovernanceIntake": str(output_root / "catalog-governance-intake.json"),
            "draftGovernancePackets": str(output_root / "draft-governance-packets.json"),
            "activeRegistryMutations": str(output_root / "active-registry-mutations.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": GOVERNANCE_INTAKE_NON_CLAIMS,
    }

    write_json(output_root / "catalog-governance-intake.json", artifact)
    write_json(output_root / "draft-governance-packets.json", {"draftGovernancePackets": draft_packets, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogGovernanceDraftPackets.v1"})
    write_json(output_root / "active-registry-mutations.json", {"activeRegistryMutations": registry_mutations, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogGovernanceActiveRegistryMutations.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogGovernanceIntake": stable_hash(read_json(output_root / "catalog-governance-intake.json")),
        "draftGovernancePackets": stable_hash(read_json(output_root / "draft-governance-packets.json")),
        "activeRegistryMutations": stable_hash(read_json(output_root / "active-registry-mutations.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_governance_intake_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_governance_intake_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_governance_intake(
        CatalogGovernanceIntakeOptions(
            input_path=input_path,
            output_root=output_root,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_governance_intake_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_governance_intake_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Governance Intake Train 57",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Draft source-lane, legal/terms, and API governance intake packets from catalog review packets.",
        "- Active registry mutation output that remains empty until explicit approval and separate mutation tooling exists.",
        "- Blocked pack/R2/live-harvest posture for all draft packets.",
        "",
        "Counts:",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Draft governance packets: {counts['draftGovernancePackets']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Approved source lanes: {counts['approvedSourceLanes']}",
        f"- Approved legal entries: {counts['approvedLegalEntries']}",
        f"- Approved API policies: {counts['approvedApiPolicies']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Governance intake does not mutate active registries.",
        "- No source authority, legal approval, API approval, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "",
        "Validation run:",
        "- See current train closeout for exact commands.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _review_packets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("reviewPackets"), list):
        return [item for item in payload["reviewPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("draftGovernancePackets"), list):
        return [item for item in payload["draftGovernancePackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, review_packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("governance intake input must be an object or array")
    if not review_packets:
        issues.append("governance intake input must include review packets")
    return issues


def _review_packet_issues(packet: dict[str, Any], index: int) -> list[str]:
    label = str(packet.get("packet_id") or f"reviewPacket[{index}]")
    issues: list[str] = []
    if not packet.get("packet_id"):
        issues.append(f"{label}: packet_id required")
    if not packet.get("candidate_id"):
        issues.append(f"{label}: candidate_id required")
    if packet.get("review_required") is not True:
        issues.append(f"{label}: review packet must remain review_required")
    if packet.get("active_source_lane_emitted") is not False:
        issues.append(f"{label}: review packet cannot emit active source lane")
    if packet.get("claim_authority_allowed") is not False:
        issues.append(f"{label}: review packet cannot allow claim authority")
    if packet.get("pack_output_allowed") is not False:
        issues.append(f"{label}: review packet cannot allow pack output")
    blocking_reasons = set(packet.get("blocking_reasons") or [])
    for required_reason in {
        "catalog_metadata_not_claim_authority",
        "source_lane_review_required",
        "legal_terms_review_required",
        "api_policy_review_required",
        "pack_output_blocked_until_review",
    }:
        if required_reason not in blocking_reasons:
            issues.append(f"{label}: missing blocking reason {required_reason}")
    return issues


def _draft_governance_packet(packet: dict[str, Any], created_at: str, packet_issues: list[str]) -> dict[str, Any]:
    candidate_id = str(packet.get("candidate_id") or stable_id("catalog_candidate_missing_id", packet))
    intake_id = stable_id("catalog_governance_intake", {"candidate_id": candidate_id, "packet_hash": stable_hash(packet)})
    source_id = f"catalog.candidate.{stable_hash({'candidate_id': candidate_id})[:12]}"
    domain_guess = str(packet.get("domain_guess") or "unclassified_public_reference")
    r2_pack_policy = str(packet.get("r2_pack_policy") or "pack_blocked_unknown_terms")
    if not r2_pack_policy.startswith("pack_blocked"):
        r2_pack_policy = "pack_blocked_unknown_terms"
    blocking_reasons = sorted(
        {
            "draft_governance_intake_only",
            "active_registry_mutation_blocked",
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_policy_review_required",
            "pack_output_blocked_until_review",
            "r2_output_blocked_until_review",
            *[str(reason) for reason in packet.get("blocking_reasons", [])],
        }
    )
    return {
        "schema_version": "1.0.0",
        "intake_id": intake_id,
        "packet_id": str(packet.get("packet_id") or ""),
        "candidate_id": candidate_id,
        "created_at": created_at,
        "domain_guess": domain_guess,
        "review_status": "review_required",
        "active_registry_mutation_allowed": False,
        "source_lane_draft": {
            "source_id": source_id,
            "source_name": str(packet.get("publisher_name") or packet.get("dataset_url") or "Unreviewed catalog candidate"),
            "source_class": "public_catalog",
            "authority_class": str(packet.get("authority_class_guess") or "unknown"),
            "jurisdiction": str(packet.get("declared_jurisdiction") or "unknown"),
            "domain_scope": [domain_guess],
            "claim_classes_allowed": [],
            "claim_classes_forbidden": ["regulated_requirement", "legal_advice", "medical_advice", "financial_advice", *FORBIDDEN_ARTIFACT_CLASSES],
            "redistribution_policy": "review_required",
            "r2_pack_policy": r2_pack_policy,
            "lookup_policy": "review_required",
            "crosswalk_policy": "review_required",
            "review_status": "review_required",
            "allowed_artifact_classes": ["candidate_source_record", "discovery_metadata"],
            "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASSES,
            "active_registry_entry": False,
        },
        "legal_terms_draft": {
            "license_id": f"review_required.{source_id}",
            "license_url": str(packet.get("declared_license") or ""),
            "terms_url": str(packet.get("terms_url") or ""),
            "rights_url": str(packet.get("rights_url") or ""),
            "review_required": True,
            "redistribution_allowed": False,
            "modification_allowed": False,
            "commercial_use_allowed": False,
            "attribution_required": "review_required",
            "pack_output_allowed": False,
            "outside_legal_required": True,
            "outside_legal_status": "not_claimed",
            "approval_artifact_path": "",
        },
        "api_governance_draft": {
            "api_policy_id": f"review_required.{source_id}",
            "api_mode": "review_required_before_live_harvest",
            "credential_posture": "review_required",
            "rate_policy_required": True,
            "budget_policy_required": True,
            "live_harvest_allowed": False,
            "execute_allowed": False,
            "evidence_output_policy": "candidate_metadata_only_until_review",
        },
        "required_decisions": [
            "confirm publisher authority and jurisdiction",
            "review source-specific terms and redistribution posture",
            "decide lookup-only, crosswalk-only, blocked, or pack-eligible policy",
            "create API rate, budget, retry, and credential policy before live harvest",
            "approve artifact classes before any registry mutation",
        ],
        "blocking_reasons": blocking_reasons,
        "packet_issues": sorted(packet_issues),
        "non_claims": [
            "draft governance intake only",
            "not active registry mutation",
            "not legal approval",
            "not API approval",
            "not source authority",
            "not pack output",
        ],
    }


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims"}
        )
    return False
