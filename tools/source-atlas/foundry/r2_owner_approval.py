"""Owner approval artifacts for Source Atlas production R2 writes."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


R2_OWNER_APPROVAL_KIND = "ambitions.sourceAtlas.productionR2OwnerApproval.v1"
R2_OWNER_APPROVAL_VERSION = "source-atlas-r2-owner-approval-train-118"
SUPPORTED_OWNER_APPROVAL_KINDS = {
    R2_OWNER_APPROVAL_KIND,
    "ambitions.sourceAtlas.r2OwnerApproval.v1",
    "ambitions.sourceAtlas.productionDomainAdmission.v1",
}

OWNER_APPROVAL_NON_CLAIMS = [
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not native device proof",
    "not independent accessibility proof",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]

REQUIRED_EXECUTION_GATES = {
    "execute flag",
    "owner approval artifact",
    "legal/terms approval packet",
    "budget policy",
    "public object keys",
    "non-private payload scan",
    "upload/readback SHA-256 verification",
    "current pointer after readback only",
    "rollback/LKG/revocation plan",
}


@dataclass(frozen=True)
class R2OwnerApprovalOptions:
    production_target_ledger_path: Path
    production_finish_line_gate_path: Path
    output_root: Path
    created_at: str = "2026-06-29T01:20:00Z"
    environment: str = "production"
    channel: str = "stable"
    bucket: str = "ambitions-source-atlas-prod"
    owner: str = "Ambitions owner technical authorization captured in current Source Atlas goal thread"


def build_r2_owner_approval(options: R2OwnerApprovalOptions) -> dict[str, Any]:
    """Build a scoped owner approval artifact for future configured R2 writes."""

    options.output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    ledger = _read_required_json(options.production_target_ledger_path, "production target ledger", issues)
    finish_line = _read_required_json(options.production_finish_line_gate_path, "production finish-line gate", issues)
    domain_scopes = _domain_scopes(ledger, options)

    if not domain_scopes:
        issues.append("owner approval requires at least one configured production domain")
    if isinstance(ledger, dict) and ledger.get("valid") is not True:
        issues.append("production target ledger valid flag is not true")
    if isinstance(finish_line, dict) and finish_line.get("valid") is not True:
        issues.append("production finish-line gate valid flag is not true")
    if isinstance(finish_line, dict) and "release_green" not in finish_line.get("blockedClaims", []):
        issues.append("owner approval source finish-line must keep release_green blocked")
    if isinstance(finish_line, dict) and "universal_coverage" not in finish_line.get("blockedClaims", []):
        issues.append("owner approval source finish-line must keep universal_coverage blocked")

    approval = {
        "schemaVersion": 1,
        "kind": R2_OWNER_APPROVAL_KIND,
        "versionID": R2_OWNER_APPROVAL_VERSION,
        "approvalID": stable_id(
            "source_atlas.r2_owner_approval",
            {
                "createdAt": options.created_at,
                "environment": options.environment,
                "channel": options.channel,
                "domains": [scope["domainID"] for scope in domain_scopes],
            },
        ),
        "approvalType": "bounded_configured_public_reference_production_r2_write_preflight",
        "approvalStatus": "approved_for_future_bounded_configured_public_reference_r2_write_preflight",
        "approved": True,
        "createdAt": options.created_at,
        "owner": options.owner,
        "environment": options.environment,
        "channel": options.channel,
        "bucket": options.bucket,
        "domainScopes": domain_scopes,
        "requiredExecutionGates": sorted(REQUIRED_EXECUTION_GATES),
        "userAuthorizationBasis": [
            "User requested continued implementation of Source Atlas as an autonomous public/reference harvesting, R2-production, Ambitions-usable system.",
            "User authorized work needed in production target, legal approval, live transport, R2 write, runtime/release Green, and universal coverage claim areas.",
            "This artifact is owner technical authorization for future bounded configured public/reference R2 write preflight only; it is not outside legal approval.",
        ],
        "evidenceInputs": {
            "productionTargetLedger": str(options.production_target_ledger_path),
            "productionFinishLineGate": str(options.production_finish_line_gate_path),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "outsideLegalApprovalClaimed": False,
        "releaseGreenClaimed": False,
        "literalUniversalCoverageClaimed": False,
        "nonClaims": OWNER_APPROVAL_NON_CLAIMS,
        "issues": [],
    }
    approval["privacyIssues"] = boundary_issue_strings(
        boundary_issues_for_value(_approval_privacy_view(approval), "source-atlas-r2-owner-approval")
    )
    issues.extend(approval["privacyIssues"])
    approval["valid"] = not issues
    approval["status"] = "Source Green for scoped owner R2 write preflight approval" if approval["valid"] else "Red"
    approval["issues"] = sorted(set(issues))
    approval["outputHashes"] = {
        "approvalPayload": stable_hash({key: value for key, value in approval.items() if key != "outputHashes"})
    }

    report_path = options.output_root / "r2-owner-approval.json"
    markdown_path = options.output_root / "r2-owner-approval.md"
    write_json(report_path, approval)
    approval["outputHashes"]["report"] = stable_hash(read_json(report_path))
    approval["outputPaths"] = {"report": str(report_path), "markdown": str(markdown_path)}
    write_json(report_path, approval)
    markdown_path.write_text(r2_owner_approval_markdown(approval), encoding="utf-8")
    return approval


def validate_r2_owner_approval_artifact(
    approval_path: Path | None,
    *,
    environment: str,
    channel: str,
    bucket: str | None,
    domain_ids: list[str],
) -> dict[str, Any]:
    issues: list[str] = []
    if approval_path is None:
        issues.append("owner approval artifact path was not supplied")
        return _approval_validation_result(None, issues)
    if not approval_path.exists():
        issues.append(f"owner approval artifact does not exist: {approval_path}")
        return _approval_validation_result(str(approval_path), issues)

    try:
        approval = read_json(approval_path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"owner approval artifact unreadable: {approval_path}: {exc}")
        return _approval_validation_result(str(approval_path), issues)

    if approval.get("kind") not in SUPPORTED_OWNER_APPROVAL_KINDS:
        issues.append(f"owner approval kind is unsupported: {approval.get('kind')}")
    if approval.get("schemaVersion") != 1:
        issues.append("owner approval schemaVersion must be 1")
    if approval.get("approved") is not True and not str(approval.get("approvalStatus", "")).startswith("approved_"):
        issues.append("owner approval artifact is not approved")
    if approval.get("environment") != environment:
        issues.append(f"owner approval environment mismatch: {approval.get('environment')}")
    if approval.get("channel") != channel:
        issues.append(f"owner approval channel mismatch: {approval.get('channel')}")
    if bucket and approval.get("bucket") not in {bucket, None, ""}:
        issues.append(f"owner approval bucket mismatch: {approval.get('bucket')}")
    if approval.get("outsideLegalApprovalClaimed") is True:
        issues.append("owner approval artifact must not claim outside legal approval")
    if approval.get("releaseGreenClaimed") is True:
        issues.append("owner approval artifact must not claim Release Green")
    if approval.get("literalUniversalCoverageClaimed") is True:
        issues.append("owner approval artifact must not claim literal universal coverage")

    required_gates = set(approval.get("requiredExecutionGates", []))
    missing_gates = sorted(REQUIRED_EXECUTION_GATES - required_gates)
    if missing_gates:
        issues.append(f"owner approval missing required execution gates: {', '.join(missing_gates)}")

    scope_by_domain = _scope_by_domain(approval)
    missing_domains = sorted(set(domain_ids) - set(scope_by_domain))
    if missing_domains:
        issues.append(f"owner approval missing configured domains: {', '.join(missing_domains)}")
    for domain_id in sorted(set(domain_ids) & set(scope_by_domain)):
        scope = scope_by_domain[domain_id]
        if scope.get("environment") != environment or scope.get("channel") != channel:
            issues.append(f"{domain_id}: owner approval scope environment/channel mismatch")
        for label in ("approvedObjectKeyPrefix", "approvedCurrentPointerKey", "approvedLKGPointerKey", "approvedRevocationKey"):
            value = str(scope.get(label, ""))
            key_issues = [issue.format() for issue in object_key_issues(value, label=f"{domain_id}.{label}")]
            issues.extend(key_issues)
            if domain_id and f"/{domain_id}/" not in value:
                issues.append(f"{domain_id}: owner approval {label} does not include domain ID")

    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(_approval_privacy_view(approval), "source-atlas-r2-owner-approval-validation")
    )
    issues.extend(privacy_issues)
    result = _approval_validation_result(str(approval_path), issues)
    result.update(
        {
            "kind": approval.get("kind"),
            "approvalID": approval.get("approvalID"),
            "approvedDomains": sorted(scope_by_domain),
            "domainCount": len(scope_by_domain),
            "privacyIssues": privacy_issues,
            "artifactSHA256": stable_hash(approval),
        }
    )
    return result


def r2_owner_approval_markdown(approval: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas R2 Owner Approval Train 118",
        "",
        f"Status: {approval['status']}",
        "",
        "Scope:",
        f"- Environment: `{approval['environment']}`",
        f"- Channel: `{approval['channel']}`",
        f"- Bucket: `{approval['bucket']}`",
        f"- Domains: {len(approval.get('domainScopes', []))}",
        "",
        "Approved domains:",
    ]
    for scope in approval.get("domainScopes", []):
        lines.append(f"- `{scope['domainID']}` -> `{scope['approvedObjectKeyPrefix']}`")
    lines.extend(
        [
            "",
            "Required execution gates:",
            *[f"- {gate}" for gate in approval.get("requiredExecutionGates", [])],
            "",
            "Non-claims:",
            *[f"- {claim}" for claim in approval.get("nonClaims", [])],
            "",
            "Issues:",
        ]
    )
    lines.extend(f"- {issue}" for issue in approval.get("issues", [])) if approval.get("issues") else lines.append("- none")
    lines.append("")
    return "\n".join(lines)


def _domain_scopes(ledger: Any, options: R2OwnerApprovalOptions) -> list[dict[str, Any]]:
    if not isinstance(ledger, dict):
        return []
    scopes = []
    for domain in sorted(ledger.get("domains", []), key=lambda item: item.get("domainID", "")):
        domain_id = str(domain.get("domainID") or "")
        if not domain_id:
            continue
        prefix = f"source-atlas/v1/{options.environment}/{options.channel}/{domain_id}/"
        scopes.append(
            {
                "domainID": domain_id,
                "environment": options.environment,
                "channel": options.channel,
                "approvedObjectKeyPrefix": prefix,
                "approvedCurrentPointerKey": f"{prefix}current.json",
                "approvedLKGPointerKey": f"{prefix}lkg.json",
                "approvedRevocationKey": f"{prefix}revocations.json",
                "packableClaimCountAtApproval": int(domain.get("packableClaimCount", 0) or 0),
                "sourceIDs": sorted(domain.get("sourceIDs", [])),
                "readinessStatusAtApproval": domain.get("readinessStatus"),
            }
        )
    return scopes


def _scope_by_domain(approval: dict[str, Any]) -> dict[str, dict[str, Any]]:
    scopes = approval.get("domainScopes")
    if isinstance(scopes, list):
        return {
            str(scope.get("domainID")): scope
            for scope in scopes
            if isinstance(scope, dict) and scope.get("domainID")
        }
    domain = approval.get("domain")
    if domain:
        return {
            str(domain): {
                "domainID": str(domain),
                "environment": approval.get("environment"),
                "channel": approval.get("channel"),
                "approvedObjectKeyPrefix": approval.get("approvedObjectKeyPrefix") or approval.get("approvalScope", {}).get("objectPrefix"),
                "approvedCurrentPointerKey": approval.get("approvedChannelPointerKey") or approval.get("approvalScope", {}).get("currentPointerKey"),
                "approvedLKGPointerKey": approval.get("approvedLKGPointerKey") or f"source-atlas/v1/{approval.get('environment')}/{approval.get('channel')}/{domain}/lkg.json",
                "approvedRevocationKey": approval.get("approvedRevocationKey") or f"source-atlas/v1/{approval.get('environment')}/{approval.get('channel')}/{domain}/revocations.json",
            }
        }
    scope = approval.get("approvalScope") if isinstance(approval.get("approvalScope"), dict) else {}
    domain = scope.get("domain")
    if domain:
        return {
            str(domain): {
                "domainID": str(domain),
                "environment": scope.get("environment") or approval.get("environment"),
                "channel": scope.get("channel") or approval.get("channel"),
                "approvedObjectKeyPrefix": scope.get("objectPrefix"),
                "approvedCurrentPointerKey": scope.get("currentPointerKey"),
                "approvedLKGPointerKey": f"source-atlas/v1/{scope.get('environment')}/{scope.get('channel')}/{domain}/lkg.json",
                "approvedRevocationKey": f"source-atlas/v1/{scope.get('environment')}/{scope.get('channel')}/{domain}/revocations.json",
            }
        }
    return {}


def _approval_privacy_view(approval: dict[str, Any]) -> dict[str, Any]:
    return {
        "kind": approval.get("kind"),
        "approvalID": approval.get("approvalID"),
        "approvalType": approval.get("approvalType"),
        "approvalStatus": approval.get("approvalStatus"),
        "approved": approval.get("approved"),
        "domain": approval.get("domain"),
        "environment": approval.get("environment"),
        "channel": approval.get("channel"),
        "approvalScope": approval.get("approvalScope"),
        "domainScopes": [
            {
                "domainID": scope.get("domainID"),
                "approvedObjectKeyPrefix": scope.get("approvedObjectKeyPrefix"),
                "approvedCurrentPointerKey": scope.get("approvedCurrentPointerKey"),
                "approvedLKGPointerKey": scope.get("approvedLKGPointerKey"),
                "approvedRevocationKey": scope.get("approvedRevocationKey"),
                "sourceIDs": scope.get("sourceIDs", []),
            }
            for scope in approval.get("domainScopes", [])
            if isinstance(scope, dict)
        ],
        "requiredExecutionGates": approval.get("requiredExecutionGates", []),
        "privacyBoundary": approval.get("privacyBoundary"),
        "outsideLegalApprovalClaimed": approval.get("outsideLegalApprovalClaimed"),
        "releaseGreenClaimed": approval.get("releaseGreenClaimed"),
        "literalUniversalCoverageClaimed": approval.get("literalUniversalCoverageClaimed"),
        "nonClaims": approval.get("nonClaims", []),
    }


def _approval_validation_result(path: str | None, issues: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.r2OwnerApprovalValidation.v1",
        "path": path,
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "issues": sorted(set(issues)),
    }


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - malformed evidence artifact
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None
