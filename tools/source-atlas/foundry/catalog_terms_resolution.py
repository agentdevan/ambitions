"""Advisory terms-resolution proposals for catalog approval requests.

Catalog metadata often arrives with short license aliases such as ``cc-by`` or
``ca-ogl-lgo`` and without explicit terms/rights URLs. This train resolves
known aliases into reviewable URL proposals while preserving the approval gate:
templates remain draft-only and no source lane, legal entry, claim, pack, or R2
artifact is approved here.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_TERMS_RESOLUTION_VERSION = "source-atlas-catalog-terms-resolution-train-61"
CATALOG_TERMS_RESOLUTION_KIND = "ambitions.sourceAtlas.catalogTermsResolution.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

TERMS_RESOLUTION_NON_CLAIMS = [
    "not an approval artifact",
    "not legal approval",
    "not outside legal approval",
    "not active registry mutation",
    "not source authority",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]

KNOWN_LICENSE_RESOLUTIONS: dict[str, dict[str, Any]] = {
    "cc-by": {
        "canonical_license_id": "cc-by-4.0",
        "license_name": "Creative Commons Attribution 4.0 International",
        "license_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        "terms_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        "rights_url": "https://creativecommons.org/licenses/by/4.0/",
        "attribution_required": True,
        "suggested_redistribution_allowed": True,
        "suggested_modification_allowed": True,
        "suggested_commercial_use_allowed": True,
        "suggested_share_alike_required": False,
        "resolution_source_urls": [
            "https://creativecommons.org/licenses/by/4.0/",
            "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        ],
        "review_notes": [
            "Resolve the specific distribution version and attribution text before approval.",
            "Do not approve pack output until source-specific terms and publisher authority are reviewed.",
        ],
    },
    "cc-by-4.0": {
        "canonical_license_id": "cc-by-4.0",
        "license_name": "Creative Commons Attribution 4.0 International",
        "license_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        "terms_url": "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        "rights_url": "https://creativecommons.org/licenses/by/4.0/",
        "attribution_required": True,
        "suggested_redistribution_allowed": True,
        "suggested_modification_allowed": True,
        "suggested_commercial_use_allowed": True,
        "suggested_share_alike_required": False,
        "resolution_source_urls": [
            "https://creativecommons.org/licenses/by/4.0/",
            "https://creativecommons.org/licenses/by/4.0/legalcode.en",
        ],
        "review_notes": [
            "Resolve the specific distribution version and attribution text before approval.",
            "Do not approve pack output until source-specific terms and publisher authority are reviewed.",
        ],
    },
    "ca-ogl-lgo": {
        "canonical_license_id": "canada-open-government-licence",
        "license_name": "Open Government Licence - Canada",
        "license_url": "https://open.canada.ca/en/open-government-licence-canada",
        "terms_url": "https://open.canada.ca/en/open-government-licence-canada",
        "rights_url": "https://open.canada.ca/en/open-government-licence-canada",
        "attribution_required": True,
        "suggested_redistribution_allowed": True,
        "suggested_modification_allowed": True,
        "suggested_commercial_use_allowed": True,
        "suggested_share_alike_required": False,
        "resolution_source_urls": [
            "https://open.canada.ca/en/open-government-licence-canada",
        ],
        "review_notes": [
            "Confirm the source distribution is actually governed by the Canada Open Government Licence before approval.",
            "Do not approve pack output until source-specific terms and publisher authority are reviewed.",
        ],
    },
}


@dataclass(frozen=True)
class CatalogTermsResolutionOptions:
    input_path: Path
    output_root: Path
    created_at: str | None = None


def compile_catalog_terms_resolution(options: CatalogTermsResolutionOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.input_path)
    approval_requests = _approval_requests(payload)
    input_schema_issues = _input_schema_issues(payload, approval_requests)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-terms-resolution-input")

    proposals: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    for request in approval_requests:
        proposal = _proposal_for_request(request, created_at)
        if proposal["status"] == "terms_resolution_proposed":
            proposals.append(proposal)
        else:
            blocked.append(proposal)

    proposals = sorted(proposals, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    blocked = sorted(blocked, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_TERMS_RESOLUTION_KIND,
        "versionID": CATALOG_TERMS_RESOLUTION_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "termsResolutionProposals": proposals,
        "blockedTermsResolutions": blocked,
        "completedApprovalArtifacts": [],
        "activeRegistryMutations": [],
        "recordCounts": {
            "approvalRequests": len(approval_requests),
            "termsResolutionProposals": len(proposals),
            "blockedTermsResolutions": len(blocked),
            "completedApprovalArtifacts": 0,
            "activeRegistryMutations": 0,
            "approvedSourceLanes": 0,
            "approvedLegalEntries": 0,
            "approvedApiPolicies": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TERMS_RESOLUTION_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-terms-resolution")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(approval_requests), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "known_aliases_resolved_or_blocked",
            "passed": len(proposals) + len(blocked) == len(approval_requests),
            "issues": [],
        },
        {
            "name": "resolution_templates_are_not_approvals",
            "passed": all(proposal["resolved_approval_artifact_template"]["approval_status"] == "draft_not_approved" for proposal in proposals)
            and artifact["recordCounts"]["completedApprovalArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "terms_resolution_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "no_active_registry_mutations",
            "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0,
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogTermsResolutionManifest.v1",
        "versionID": CATALOG_TERMS_RESOLUTION_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog terms-resolution proposal tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; advisory terms-resolution proposals only",
        "inputPath": str(options.input_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogTermsResolution": str(output_root / "catalog-terms-resolution.json"),
            "termsResolutionProposals": str(output_root / "terms-resolution-proposals.json"),
            "blockedTermsResolutions": str(output_root / "blocked-terms-resolutions.json"),
            "completedApprovalArtifacts": str(output_root / "completed-approval-artifacts.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": TERMS_RESOLUTION_NON_CLAIMS,
    }

    write_json(output_root / "catalog-terms-resolution.json", artifact)
    write_json(output_root / "terms-resolution-proposals.json", {"kind": "ambitions.sourceAtlas.catalogTermsResolutionProposals.v1", "createdAt": created_at, "termsResolutionProposals": proposals})
    write_json(output_root / "blocked-terms-resolutions.json", {"kind": "ambitions.sourceAtlas.catalogBlockedTermsResolutions.v1", "createdAt": created_at, "blockedTermsResolutions": blocked})
    write_json(output_root / "completed-approval-artifacts.json", {"kind": "ambitions.sourceAtlas.catalogCompletedApprovalArtifacts.v1", "createdAt": created_at, "completedApprovalArtifacts": []})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogTermsResolution": stable_hash(read_json(output_root / "catalog-terms-resolution.json")),
        "termsResolutionProposals": stable_hash(read_json(output_root / "terms-resolution-proposals.json")),
        "blockedTermsResolutions": stable_hash(read_json(output_root / "blocked-terms-resolutions.json")),
        "completedApprovalArtifacts": stable_hash(read_json(output_root / "completed-approval-artifacts.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_terms_resolution_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_terms_resolution_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_terms_resolution(CatalogTermsResolutionOptions(input_path=input_path, output_root=output_root, created_at=created_at))
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_terms_resolution_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_terms_resolution_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Terms Resolution Train 61",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Advisory terms-resolution proposals for catalog approval request templates.",
        "- Known license aliases can be resolved into reviewable license, terms, and rights URLs.",
        "- Resolved templates remain draft_not_approved and emit no completed approval artifacts.",
        "",
        "Counts:",
        f"- Approval requests: {counts['approvalRequests']}",
        f"- Terms resolution proposals: {counts['termsResolutionProposals']}",
        f"- Blocked terms resolutions: {counts['blockedTermsResolutions']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Terms resolution proposals are not approvals.",
        "- No active registries, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Source/legal/API review remains required before mutation planning or registry application.",
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


def _approval_requests(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("approvalRequests"), list):
        return [item for item in payload["approvalRequests"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogRegistryApprovalRequest"), dict):
        return _approval_requests(payload["catalogRegistryApprovalRequest"])
    if isinstance(payload, dict) and isinstance(payload.get("approvalRequests"), dict):
        return _approval_requests(payload["approvalRequests"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, approval_requests: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("terms resolution input must be an object or array")
    if not approval_requests:
        issues.append("terms resolution input must include approval requests")
    return issues


def _proposal_for_request(request: dict[str, Any], created_at: str) -> dict[str, Any]:
    template = request.get("approval_artifact_template") if isinstance(request.get("approval_artifact_template"), dict) else {}
    entries = template.get("approved_entries") if isinstance(template.get("approved_entries"), list) else []
    first_entry = next((entry for entry in entries if isinstance(entry, dict)), {})
    legal_terms = first_entry.get("legal_terms_entry") if isinstance(first_entry.get("legal_terms_entry"), dict) else {}
    alias = _license_alias(legal_terms)
    resolution = KNOWN_LICENSE_RESOLUTIONS.get(alias)
    base = {
        "schema_version": "1.0.0",
        "proposal_id": stable_id("catalog_terms_resolution", {"request": request.get("request_id"), "alias": alias}),
        "request_id": str(request.get("request_id") or ""),
        "intake_id": str(request.get("intake_id") or first_entry.get("intake_id") or ""),
        "candidate_id": str(request.get("candidate_id") or ""),
        "domain_guess": str(request.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(first_entry.get("source_lane_entry", {}).get("source_id") or ""),
        "source_name": str(first_entry.get("source_lane_entry", {}).get("source_name") or ""),
        "created_at": created_at,
        "detected_license_alias": alias,
    }
    if not resolution:
        return {
            **base,
            "status": "blocked",
            "blocking_reasons": sorted({"missing_terms_url", "unresolved_license_alias", "human_terms_review_required"}),
            "non_claims": [
                "blocked terms resolution only",
                "not an approval",
                "not legal approval",
                "not source authority",
            ],
        }

    resolved_template = _resolved_template(template, first_entry, resolution)
    return {
        **base,
        "status": "terms_resolution_proposed",
        "terms_resolution": resolution,
        "resolved_approval_artifact_template": resolved_template,
        "blocking_reasons": [
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_governance_review_required",
            "approval_artifact_still_required",
        ],
        "non_claims": [
            "terms resolution proposal only",
            "not an approval",
            "not legal approval",
            "not outside legal approval",
            "not active registry mutation",
        ],
    }


def _license_alias(legal_terms: dict[str, Any]) -> str:
    for field in ("license_url", "license_id", "license_name"):
        value = str(legal_terms.get(field) or "").strip().lower()
        if value:
            return value.rstrip("/")
    return ""


def _resolved_template(template: dict[str, Any], first_entry: dict[str, Any], resolution: dict[str, Any]) -> dict[str, Any]:
    resolved = dict(template)
    resolved["approval_status"] = "draft_not_approved"
    resolved["source_lane_review_complete"] = False
    resolved["legal_terms_review_complete"] = False
    resolved["api_governance_review_complete"] = False
    resolved["outside_legal_status"] = "not_claimed"
    entries = [dict(entry) for entry in template.get("approved_entries", []) if isinstance(entry, dict)]
    if entries:
        entry = dict(entries[0])
    else:
        entry = dict(first_entry)
    legal = dict(entry.get("legal_terms_entry", {}))
    legal.update(
        {
            "license_name": resolution["license_name"],
            "license_url": resolution["license_url"],
            "terms_url": resolution["terms_url"],
            "rights_url": resolution["rights_url"],
            "review_required": True,
            "redistribution_allowed": False,
            "pack_output_allowed": False,
            "outside_legal_status": "not_claimed",
        }
    )
    entry["legal_terms_entry"] = legal
    entries = [entry] + entries[1:]
    resolved["approved_entries"] = entries
    return resolved


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
