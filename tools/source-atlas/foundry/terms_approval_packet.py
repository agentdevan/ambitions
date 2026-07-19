"""Source-specific legal/terms approval packets for Source Atlas.

These packets are internal Source Atlas terms-review artifacts. They can prove
bounded internal legal/terms review for a specific source and artifact class.
They do not prove outside legal approval unless a source-specific outside legal
approval artifact is present and validated.
"""

from __future__ import annotations

from datetime import date
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, stable_hash, utc_now, write_json


TERMS_APPROVAL_PACKET_KIND = "ambitions.sourceAtlas.legalTermsApprovalPacket.v1"
TERMS_APPROVAL_PACKET_VERSION = "source-atlas-legal-terms-approval-packet-v1"
INTERNAL_APPROVAL_STATUS = "approved_internal_terms_review"
REVIEW_REQUIRED_STATUS = "review_required"
BLOCKED_STATUS = "blocked_from_pack_output"

INTERNAL_REVIEW_OWNER = "Codex internal Source Atlas legal/terms review under explicit user authorization"
USER_AUTHORIZATION_SUMMARY = (
    "User authorized extensive internal legal/terms review for bounded Source Atlas Green claims; "
    "this is not outside legal approval."
)
REDISTRIBUTABLE_POLICIES = {"redistributable", "redistributable_with_attribution"}
BLOCKED_REDISTRIBUTION_POLICIES = {"lookup_only_not_packable", "blocked"}
BLOCKED_R2_POLICIES = {"r2_blocked", "r2_review_required"}
R2_PACK_ALLOWED = "r2_pack_allowed"


def build_terms_approval_packet(
    entries: list[dict[str, Any]],
    *,
    output_path: Path | None = None,
    created_at: str | None = None,
    reviewer: str = INTERNAL_REVIEW_OWNER,
) -> dict[str, Any]:
    """Build a deterministic, source-specific approval packet from terms entries."""

    resolved_created_at = created_at or utc_now()
    approvals = [_approval_for_entry(entry, resolved_created_at, reviewer) for entry in entries]
    packet = {
        "schemaVersion": 1,
        "kind": TERMS_APPROVAL_PACKET_KIND,
        "versionID": TERMS_APPROVAL_PACKET_VERSION,
        "packetID": _packet_id(approvals),
        "createdAt": resolved_created_at,
        "reviewType": "internal_source_atlas_legal_terms_review",
        "reviewOwner": reviewer,
        "userAuthorization": USER_AUTHORIZATION_SUMMARY,
        "outsideLegalApprovalClaimed": False,
        "outsideLegalApprovalBoundary": "outside legal approval requires a current source-specific approval artifact",
        "status": "Green" if all(item["reviewStatus"] == INTERNAL_APPROVAL_STATUS for item in approvals) else "Yellow",
        "statusReason": "internal source-specific terms review complete for approved lanes; blocked or review-required lanes remain excluded",
        "sourceApprovals": approvals,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "not outside legal approval",
            "not production R2 readiness",
            "not release readiness",
            "not universal coverage",
            *NON_CLAIMS,
        ],
    }
    if output_path:
        write_json(output_path, packet)
        markdown_path = output_path.with_suffix(".md")
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(terms_approval_packet_markdown(packet), encoding="utf-8")
    return packet


def validate_terms_approval_packet(
    packet: dict[str, Any] | None,
    *,
    terms_entry: dict[str, Any],
    requested_artifact_classes: set[str] | list[str] | tuple[str, ...],
    require_outside_legal: bool = False,
    now_date: str | None = None,
) -> dict[str, Any]:
    """Validate that a packet approves pack use for one source and artifacts."""

    source_id = terms_entry.get("source_id", "<source>")
    issues: list[str] = []
    if not isinstance(packet, dict):
        issues.append(f"{source_id}: missing legal/terms approval packet")
        return _validation_result(source_id, issues, None)

    if packet.get("kind") != TERMS_APPROVAL_PACKET_KIND:
        issues.append(f"{source_id}: approval packet kind must be {TERMS_APPROVAL_PACKET_KIND}")
    if packet.get("schemaVersion") != 1:
        issues.append(f"{source_id}: approval packet schemaVersion must be 1")

    boundary_issues = boundary_issue_strings(boundary_issues_for_value(packet, "terms-approval-packet"))
    issues.extend(boundary_issues)

    approval = _approval_for_source(packet, source_id)
    if not approval:
        issues.append(f"{source_id}: approval packet does not include source approval")
        return _validation_result(source_id, issues, None)

    required_fields = [
        "sourceID",
        "license",
        "licenseURL",
        "termsURL",
        "rightsURL",
        "datasetURL",
        "distributionURL",
        "reviewOwner",
        "reviewedAt",
        "expiresAt",
        "reviewStatus",
        "allowedArtifactClasses",
        "forbiddenArtifactClasses",
        "packOutputAllowed",
        "redistributionPolicy",
        "r2PackPolicy",
        "evidenceHash",
        "nonClaims",
    ]
    for field in required_fields:
        value = approval.get(field)
        if value is None or value == "" or value == []:
            issues.append(f"{source_id}: approval packet missing {field}")

    if approval.get("licenseURL") != terms_entry.get("source_url") and approval.get("licenseURL") != terms_entry.get("terms_url"):
        if approval.get("licenseURL") != terms_entry.get("license_url"):
            issues.append(f"{source_id}: approval licenseURL does not match source terms entry")
    if approval.get("termsURL") != terms_entry.get("terms_url"):
        issues.append(f"{source_id}: approval termsURL does not match source terms entry")
    if approval.get("rightsURL") not in {terms_entry.get("terms_url"), terms_entry.get("source_url")}:
        issues.append(f"{source_id}: approval rightsURL does not match source terms entry")
    if approval.get("redistributionPolicy") != terms_entry.get("redistribution_policy"):
        issues.append(f"{source_id}: approval redistributionPolicy does not match terms entry")
    if approval.get("r2PackPolicy") != terms_entry.get("r2_pack_policy"):
        issues.append(f"{source_id}: approval r2PackPolicy does not match terms entry")

    requested = set(requested_artifact_classes)
    approved = set(approval.get("allowedArtifactClasses", []))
    unsupported = sorted(requested - approved)
    if unsupported:
        issues.append(f"{source_id}: approval packet does not allow artifact classes: {', '.join(unsupported)}")

    if approval.get("reviewStatus") != INTERNAL_APPROVAL_STATUS:
        issues.append(f"{source_id}: approval reviewStatus is not approved_internal_terms_review")
    if approval.get("packOutputAllowed") is not True:
        issues.append(f"{source_id}: approval packet does not allow pack output")
    if terms_entry.get("redistribution_policy") in {
        "lookup_only_not_packable",
        "blocked",
    }:
        issues.append(f"{source_id}: source terms policy blocks redistributable pack output")
    if terms_entry.get("r2_pack_policy") in BLOCKED_R2_POLICIES:
        issues.append(f"{source_id}: source R2 pack policy blocks R2-ready output")

    expires_at = str(approval.get("expiresAt", ""))
    today = now_date or utc_now()[:10]
    if _date_key(expires_at) < _date_key(today):
        issues.append(f"{source_id}: approval packet expired")

    outside_required = require_outside_legal or approval.get("outsideLegalRequired") is True
    outside_status = approval.get("outsideLegalStatus")
    outside_artifact = approval.get("outsideLegalApprovalArtifact")
    outside_artifact_hash = approval.get("outsideLegalApprovalArtifactHash")
    if packet.get("outsideLegalApprovalClaimed") is True or outside_status == "approved":
        if not outside_artifact or not outside_artifact_hash:
            issues.append(f"{source_id}: outside legal approval claimed without artifact and hash")
    if outside_required and (outside_status != "approved" or not outside_artifact or not outside_artifact_hash):
        issues.append(f"{source_id}: outside legal approval required but not proven")

    return _validation_result(source_id, issues, approval)


def validate_terms_approval_packet_for_entries(
    packet: dict[str, Any] | None,
    *,
    terms_entries: list[dict[str, Any]],
    requested_artifact_classes: set[str] | list[str] | tuple[str, ...],
    require_outside_legal: bool = False,
    now_date: str | None = None,
) -> dict[str, Any]:
    validations = [
        validate_terms_approval_packet(
            packet,
            terms_entry=entry,
            requested_artifact_classes=requested_artifact_classes,
            require_outside_legal=require_outside_legal,
            now_date=now_date,
        )
        for entry in terms_entries
    ]
    issues = [
        issue
        for validation in validations
        for issue in validation["issues"]
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalTermsApprovalPacketValidation.v1",
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "sourceIDs": [entry.get("source_id") for entry in terms_entries],
        "requestedArtifactClasses": sorted(set(requested_artifact_classes)),
        "validations": validations,
        "issues": issues,
        "outsideLegalApprovalClaimed": any(validation["outsideLegalApprovalClaimed"] for validation in validations),
        "nonClaims": [
            "not outside legal approval unless an outside approval artifact is validated",
            "not production R2 readiness",
            "not release readiness",
        ],
    }


def terms_approval_packet_markdown(packet: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Legal Terms Approval Packet",
        "",
        f"Status: {packet['status']}",
        "",
        packet["statusReason"],
        "",
        "This is an internal Source Atlas terms-review artifact. It is not outside legal approval.",
        "",
        "| Source | Review status | Pack output | Redistribution | R2 policy | Outside legal | Expires |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for approval in packet["sourceApprovals"]:
        lines.append(
            "| `{source}` | {status} | {pack} | {redistribution} | {r2} | {outside} | {expires} |".format(
                source=approval["sourceID"],
                status=approval["reviewStatus"],
                pack="allowed" if approval["packOutputAllowed"] else "blocked",
                redistribution=approval["redistributionPolicy"],
                r2=approval["r2PackPolicy"],
                outside=approval["outsideLegalStatus"],
                expires=approval["expiresAt"],
            )
        )
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {item}" for item in packet["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _approval_for_entry(entry: dict[str, Any], created_at: str, reviewer: str) -> dict[str, Any]:
    pack_allowed = (
        entry.get("terms_review_status") == "reviewed"
        and entry.get("redistribution_policy") in REDISTRIBUTABLE_POLICIES
        and entry.get("r2_pack_policy") == R2_PACK_ALLOWED
        and entry.get("review_required") is False
    )
    review_status = INTERNAL_APPROVAL_STATUS if pack_allowed else REVIEW_REQUIRED_STATUS
    if entry.get("redistribution_policy") in BLOCKED_REDISTRIBUTION_POLICIES:
        review_status = BLOCKED_STATUS
    if entry.get("r2_pack_policy") == "r2_blocked":
        review_status = BLOCKED_STATUS

    expires_at = _approval_expiry(created_at, review_status)
    evidence = {
        "sourceID": entry.get("source_id"),
        "sourceURL": entry.get("source_url"),
        "termsURL": entry.get("terms_url"),
        "license": entry.get("license"),
        "licenseVersion": entry.get("license_version"),
        "redistributionPolicy": entry.get("redistribution_policy"),
        "r2PackPolicy": entry.get("r2_pack_policy"),
        "reviewedAt": created_at,
        "reviewOwner": reviewer,
    }
    return {
        "sourceID": entry.get("source_id"),
        "sourceName": entry.get("source_name"),
        "publisher": entry.get("publisher"),
        "license": entry.get("license"),
        "licenseVersion": entry.get("license_version"),
        "licenseURL": entry.get("source_url"),
        "termsURL": entry.get("terms_url"),
        "rightsURL": entry.get("terms_url"),
        "datasetURL": entry.get("source_url"),
        "distributionURL": entry.get("source_url"),
        "reviewOwner": reviewer,
        "reviewedAt": created_at[:10],
        "expiresAt": expires_at,
        "reviewStatus": review_status,
        "packOutputAllowed": pack_allowed,
        "lookupOutputAllowed": True,
        "redistributionPolicy": entry.get("redistribution_policy"),
        "r2PackPolicy": entry.get("r2_pack_policy"),
        "outsideLegalRequired": bool(entry.get("review_required")) or not pack_allowed,
        "outsideLegalStatus": "not_claimed",
        "outsideLegalApprovalArtifact": "",
        "outsideLegalApprovalArtifactHash": "",
        "allowedArtifactClasses": entry.get("allowed_artifact_classes", []),
        "forbiddenArtifactClasses": entry.get("forbidden_artifact_classes", []),
        "attributionRequired": entry.get("attribution_required"),
        "attributionText": entry.get("attribution_text", ""),
        "sourceSpecificRestrictions": [
            "source-specific terms still control",
            "R2/offline pack output is public/reference only",
            "do not use as a final personal plan, schedule, or Step generator",
        ],
        "evidenceSources": [
            {"url": entry.get("source_url"), "kind": "source_url", "retrievedAt": created_at},
            {"url": entry.get("terms_url"), "kind": "terms_url", "retrievedAt": created_at},
        ],
        "evidenceHash": stable_hash(evidence),
        "nonClaims": [
            "not outside legal approval",
            "not source endorsement",
            "not legal, medical, financial, admissions, or employment advice",
        ],
    }


def _approval_for_source(packet: dict[str, Any], source_id: str) -> dict[str, Any] | None:
    for approval in packet.get("sourceApprovals", []):
        if isinstance(approval, dict) and approval.get("sourceID") == source_id:
            return approval
    return None


def _validation_result(source_id: str, issues: list[str], approval: dict[str, Any] | None) -> dict[str, Any]:
    return {
        "sourceID": source_id,
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "issues": issues,
        "approvalReviewStatus": approval.get("reviewStatus") if approval else None,
        "outsideLegalApprovalClaimed": approval.get("outsideLegalStatus") == "approved" if approval else False,
        "outsideLegalApprovalArtifact": approval.get("outsideLegalApprovalArtifact") if approval else "",
    }


def _packet_id(approvals: list[dict[str, Any]]) -> str:
    payload = [{"sourceID": item.get("sourceID"), "reviewStatus": item.get("reviewStatus")} for item in approvals]
    return f"source-atlas/legal-terms-approval/{stable_hash(payload)[:16]}"


def _approval_expiry(created_at: str, review_status: str) -> str:
    year, month, day = (int(part) for part in created_at[:10].split("-"))
    if review_status == INTERNAL_APPROVAL_STATUS:
        month += 6
    else:
        month += 3
    while month > 12:
        year += 1
        month -= 12
    max_day = _month_days(year, month)
    return date(year, month, min(day, max_day)).isoformat()


def _month_days(year: int, month: int) -> int:
    if month == 2:
        if year % 400 == 0 or (year % 4 == 0 and year % 100 != 0):
            return 29
        return 28
    if month in {4, 6, 9, 11}:
        return 30
    return 31


def _date_key(value: str) -> tuple[int, int, int]:
    try:
        year, month, day = (int(part) for part in value[:10].split("-"))
        return year, month, day
    except (TypeError, ValueError):
        return (0, 0, 0)
