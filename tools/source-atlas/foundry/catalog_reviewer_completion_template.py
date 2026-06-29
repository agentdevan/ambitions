"""Build reviewer completion packet templates for catalog approval inputs.

The templates produced here are intentionally blocked. They are shaped for the
Train 67 completion intake, but they do not complete source-lane, legal/terms,
or API governance review.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_reviewer_completion_intake import REVIEW_PACKET_COLLECTION_KIND
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REVIEWER_COMPLETION_TEMPLATE_VERSION = "source-atlas-catalog-reviewer-completion-template-train-68"
CATALOG_REVIEWER_COMPLETION_TEMPLATE_KIND = "ambitions.sourceAtlas.catalogReviewerCompletionTemplate.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

TEMPLATE_NON_CLAIMS = [
    "reviewer completion packet templates only",
    "not completed reviewer packets",
    "not legal approval",
    "not outside legal approval",
    "not source authority",
    "not active registry mutation",
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
class CatalogReviewerCompletionTemplateOptions:
    decision_inputs_path: Path
    output_root: Path
    reviewer: str = ""
    created_at: str | None = None


def compile_catalog_reviewer_completion_template(options: CatalogReviewerCompletionTemplateOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.decision_inputs_path)
    packets = _decision_input_packets(payload)
    input_schema_issues = _input_schema_issues(payload, packets)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-reviewer-completion-template-input")
    templates = [_template_for_packet(packet, created_at, reviewer=options.reviewer) for packet in packets]
    templates = sorted(templates, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    collection = {
        "kind": REVIEW_PACKET_COLLECTION_KIND,
        "createdAt": created_at,
        "sourceReviewCompletionPackets": templates,
        "nonClaims": [
            "template collection only",
            "not source/legal/API review completion",
            "not approval",
            "not claim output",
            "not pack output",
        ],
    }

    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_REVIEWER_COMPLETION_TEMPLATE_KIND,
        "versionID": CATALOG_REVIEWER_COMPLETION_TEMPLATE_VERSION,
        "createdAt": created_at,
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewer": options.reviewer,
        "sourceReviewCompletionPacketTemplates": templates,
        "completedReviewCompletions": [],
        "activeRegistryMutations": [],
        "recordCounts": {
            "decisionInputPackets": len(packets),
            "sourceReviewCompletionPacketTemplates": len(templates),
            "completedReviewCompletions": 0,
            "completedDecisionArtifacts": 0,
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TEMPLATE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-reviewer-completion-template")
    collection_privacy_issues = privacy_findings_for_value(collection, "catalog-reviewer-completion-template-collection")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "templates_are_blocked_not_completed",
            "passed": all(item["completion_status"] == "blocked_review_required" for item in templates)
            and artifact["recordCounts"]["completedReviewCompletions"] == 0,
            "issues": [],
        },
        {
            "name": "templates_emit_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues and not collection_privacy_issues, "issues": artifact_privacy_issues + collection_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(collection_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogReviewerCompletionTemplateManifest.v1",
        "versionID": CATALOG_REVIEWER_COMPLETION_TEMPLATE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog reviewer completion template tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; reviewer completion templates only",
        "decisionInputsPath": str(options.decision_inputs_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogReviewerCompletionTemplate": str(output_root / "catalog-reviewer-completion-template.json"),
            "sourceReviewCompletionPackets": str(output_root / "source-review-completion-packets.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TEMPLATE_NON_CLAIMS,
    }

    write_json(output_root / "catalog-reviewer-completion-template.json", artifact)
    write_json(output_root / "source-review-completion-packets.json", collection)
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogReviewerCompletionTemplate": stable_hash(read_json(output_root / "catalog-reviewer-completion-template.json")),
        "sourceReviewCompletionPackets": stable_hash(read_json(output_root / "source-review-completion-packets.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_reviewer_completion_template_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_reviewer_completion_template_report(
    markdown_path: Path,
    json_path: Path,
    *,
    decision_inputs_path: Path,
    output_root: Path,
    reviewer: str = "",
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_reviewer_completion_template(
        CatalogReviewerCompletionTemplateOptions(
            decision_inputs_path=decision_inputs_path,
            output_root=output_root,
            reviewer=reviewer,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_reviewer_completion_template_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_reviewer_completion_template_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Reviewer Completion Template Train 68",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic blocked reviewer completion packet templates from decision input packets.",
        "- Template collection shaped for Train 67 completion intake.",
        "- Templates remain blocked_review_required and cannot emit approvals.",
        "",
        "Counts:",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Source review completion packet templates: {counts['sourceReviewCompletionPacketTemplates']}",
        f"- Completed reviewer completions: {counts['completedReviewCompletions']}",
        f"- Completed decision artifacts: {counts['completedDecisionArtifacts']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Templates require source-specific reviewer completion before Train 67 can emit a completion artifact.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by these templates.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _decision_input_packets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("decisionInputPackets"), list):
        return [item for item in payload["decisionInputPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogApprovalDecisionInputs"), dict):
        return _decision_input_packets(payload["catalogApprovalDecisionInputs"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog reviewer completion template input must be an object or array")
    if not packets:
        issues.append("catalog reviewer completion template input must include decision input packets")
    for index, packet in enumerate(packets):
        for field in ("decision_input_id", "proposal_id", "intake_id", "candidate_id", "source_id", "domain_guess"):
            if not packet.get(field):
                issues.append(f"decisionInputPackets[{index}].{field} required")
    return issues


def _template_for_packet(packet: dict[str, Any], created_at: str, *, reviewer: str) -> dict[str, Any]:
    proposal_id = str(packet.get("proposal_id") or "")
    intake_id = str(packet.get("intake_id") or "")
    required_actions = [str(item) for item in packet.get("required_reviewer_actions", []) if isinstance(item, str)]
    return {
        "schema_version": "1.0.0",
        "completion_packet_id": stable_id("catalog_source_review_completion_template", {"proposal_id": proposal_id, "intake_id": intake_id}),
        "proposal_id": proposal_id,
        "intake_id": intake_id,
        "candidate_id": str(packet.get("candidate_id") or ""),
        "domain_guess": str(packet.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(packet.get("source_id") or ""),
        "source_name": str(packet.get("source_name") or ""),
        "created_at": created_at,
        "completion_status": "blocked_review_required",
        "review_owner": reviewer,
        "reviewed_at": "",
        "required_reviewer_actions": required_actions,
        "source_lane_review": {
            "status": "review_required",
            "required_fields": [
                "source_id",
                "source_name",
                "source_class",
                "authority_class",
                "jurisdiction",
                "review_status",
                "freshness_sla",
                "allowed_artifact_classes",
                "forbidden_artifact_classes",
            ],
            "source_lane_entry": {},
            "non_claims": ["source lane template only", "not source authority"],
        },
        "legal_terms_review": {
            "status": "review_required",
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
            "required_fields": [
                "license_id",
                "license_url",
                "terms_url",
                "rights_url",
                "redistribution_allowed",
                "pack_output_allowed",
                "review_required",
                "expires_at",
            ],
            "legal_terms_entry": {},
            "non_claims": ["legal terms template only", "not legal approval", "not outside legal approval"],
        },
        "api_governance_review": {
            "status": "review_required",
            "required_fields": [
                "api_policy_id",
                "api_mode",
                "key_required",
                "rate_limit_per_second",
                "daily_budget_limit",
                "max_records_per_run",
                "live_flag_required",
                "execute_flag_required",
                "secret_redaction_required",
            ],
            "api_policy_entry": {},
            "non_claims": ["API governance template only", "not live API approval"],
        },
        "non_claims": [
            "reviewer completion template only",
            "not a completed review packet",
            "not approval",
            "not claim output",
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
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "required_reviewer_actions"}
        )
    return False
