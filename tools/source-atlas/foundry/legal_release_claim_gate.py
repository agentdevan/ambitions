"""Release-claim gate for Source Atlas legal/R2/runtime wording.

This module converts current proof artifacts into explicit allowed and blocked
claims. It intentionally distinguishes bounded Source/transport/R2 proof from
outside legal approval, Release Green, and universal coverage claims.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, stable_hash, utc_now, write_json
from .terms_approval_packet import validate_terms_approval_packet_for_entries
from .terms_registry import terms_entry


LEGAL_RELEASE_CLAIM_GATE_KIND = "ambitions.sourceAtlas.legalReleaseClaimGate.v1"
LEGAL_RELEASE_CLAIM_GATE_VERSION = "source-atlas-legal-release-claim-gate-v1"

DEFAULT_CLAIMS = [
    "source_atlas_terms_gate_green",
    "unqualified_legal_approval",
    "outside_legal_approval",
    "bounded_production_r2_write",
    "bounded_live_native_transport",
    "bounded_production_target",
    "source_atlas_runtime_green",
    "release_green",
    "universal_coverage",
]

REQUESTED_ARTIFACT_CLASSES = {
    "official_public_source",
    "public_freshness",
    "public_provenance",
    "public_reference_claim",
}


def build_legal_release_claim_gate(
    *,
    legal_packet: dict[str, Any] | None,
    source_ids: list[str],
    r2_report: dict[str, Any] | None = None,
    native_transport_report: dict[str, Any] | None = None,
    coverage_report: dict[str, Any] | None = None,
    release_approval_artifact: dict[str, Any] | None = None,
    evidence_paths: dict[str, str] | None = None,
    requested_claims: list[str] | None = None,
    created_at: str | None = None,
    now_date: str | None = None,
    output_path: Path | None = None,
) -> dict[str, Any]:
    """Build a deterministic Source Atlas legal/release claim ledger."""

    created = created_at or utc_now()
    claims = requested_claims or DEFAULT_CLAIMS
    paths = evidence_paths or {}
    terms_validation = _terms_validation(legal_packet, source_ids, now_date or created[:10])
    gate_issues = _gate_issues(
        legal_packet=legal_packet,
        r2_report=r2_report,
        native_transport_report=native_transport_report,
        coverage_report=coverage_report,
        release_approval_artifact=release_approval_artifact,
    )
    evaluations = [
        _evaluate_claim(
            claim,
            terms_validation=terms_validation,
            legal_packet=legal_packet,
            r2_report=r2_report,
            native_transport_report=native_transport_report,
            coverage_report=coverage_report,
            release_approval_artifact=release_approval_artifact,
            evidence_paths=paths,
        )
        for claim in claims
    ]
    allowed_claims = [item["claimID"] for item in evaluations if item["allowed"]]
    blocked_claims = [item["claimID"] for item in evaluations if not item["allowed"]]
    packet = {
        "schemaVersion": 1,
        "kind": LEGAL_RELEASE_CLAIM_GATE_KIND,
        "versionID": LEGAL_RELEASE_CLAIM_GATE_VERSION,
        "gateID": f"source-atlas/legal-release-claim-gate/{stable_hash({'claims': evaluations, 'sourceIDs': source_ids})[:16]}",
        "createdAt": created,
        "status": "Source Green for release-claim gate" if not gate_issues else "Red",
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; see per-claim evaluations",
        "valid": not gate_issues,
        "sourceIDs": sorted(source_ids),
        "requestedClaims": claims,
        "allowedClaims": allowed_claims,
        "blockedClaims": blocked_claims,
        "claimEvaluations": evaluations,
        "termsValidation": terms_validation,
        "gateIssues": gate_issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "not outside legal approval unless an outside approval artifact is validated",
            "not unqualified legal approval",
            "not Release Green",
            "not Visual Green",
            "not App Store readiness",
            "not universal coverage",
            "not entitlement readiness",
            *NON_CLAIMS,
        ],
    }
    if output_path:
        write_json(output_path, packet)
        markdown_path = output_path.with_suffix(".md")
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(legal_release_claim_gate_markdown(packet), encoding="utf-8")
    return packet


def legal_release_claim_gate_markdown(packet: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Legal Release Claim Gate",
        "",
        f"Status: {packet['status']}",
        f"Source Atlas status ceiling: {packet['sourceAtlasStatusCeiling']}",
        "",
        "| Claim | Allowed | Scope | Issues |",
        "| --- | --- | --- | --- |",
    ]
    for item in packet["claimEvaluations"]:
        issues = "<br>".join(item["issues"]) if item["issues"] else ""
        lines.append(
            "| `{claim}` | {allowed} | {scope} | {issues} |".format(
                claim=item["claimID"],
                allowed="yes" if item["allowed"] else "no",
                scope=item["allowedScope"],
                issues=issues,
            )
        )
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in packet["allowedClaims"])
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in packet["blockedClaims"])
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in packet["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _terms_validation(packet: dict[str, Any] | None, source_ids: list[str], now_date: str) -> dict[str, Any]:
    entries: list[dict[str, Any]] = []
    issues: list[str] = []
    for source_id in sorted(set(source_ids)):
        try:
            entries.append(terms_entry(source_id))
        except KeyError:
            issues.append(f"{source_id}: no terms registry entry")
    validation = validate_terms_approval_packet_for_entries(
        None if issues else packet,
        terms_entries=entries,
        requested_artifact_classes=REQUESTED_ARTIFACT_CLASSES,
        now_date=now_date,
    )
    if issues:
        validation["valid"] = False
        validation["status"] = "Red"
        validation["issues"] = issues + validation.get("issues", [])
    return validation


def _gate_issues(
    *,
    legal_packet: dict[str, Any] | None,
    r2_report: dict[str, Any] | None,
    native_transport_report: dict[str, Any] | None,
    coverage_report: dict[str, Any] | None,
    release_approval_artifact: dict[str, Any] | None,
) -> list[str]:
    values = {
        "legal_packet": legal_packet,
        "r2_report": r2_report,
        "native_transport_report": native_transport_report,
        "coverage_report": coverage_report,
        "release_approval_artifact": release_approval_artifact,
    }
    return boundary_issue_strings(boundary_issues_for_value(values, "source-atlas-legal-release-claim-gate"))


def _evaluate_claim(
    claim_id: str,
    *,
    terms_validation: dict[str, Any],
    legal_packet: dict[str, Any] | None,
    r2_report: dict[str, Any] | None,
    native_transport_report: dict[str, Any] | None,
    coverage_report: dict[str, Any] | None,
    release_approval_artifact: dict[str, Any] | None,
    evidence_paths: dict[str, str],
) -> dict[str, Any]:
    if claim_id == "source_atlas_terms_gate_green":
        return _claim(
            claim_id,
            allowed=terms_validation.get("valid") is True and _outside_legal_claimed(legal_packet) is False,
            allowed_scope="bounded internal Source Atlas terms-review gate for listed sources",
            evidence=[evidence_paths.get("legal_packet", "")],
            issues=[] if terms_validation.get("valid") else terms_validation.get("issues", []),
            non_claims=["not outside legal approval", "not release readiness"],
        )
    if claim_id == "unqualified_legal_approval":
        return _claim(
            claim_id,
            allowed=False,
            allowed_scope="blocked; only bounded internal terms-review may be claimed",
            evidence=[evidence_paths.get("legal_packet", "")],
            issues=[
                "unqualified legal approval requires a current source-specific legal/privacy approval artifact and cannot be inferred from internal terms review"
            ],
            non_claims=["internal terms review is not outside legal approval"],
        )
    if claim_id == "outside_legal_approval":
        outside_ok = _outside_legal_proven(legal_packet, terms_validation)
        return _claim(
            claim_id,
            allowed=outside_ok,
            allowed_scope="outside legal approval for the exact listed sources and artifact classes" if outside_ok else "blocked",
            evidence=[evidence_paths.get("legal_packet", "")],
            issues=[] if outside_ok else ["outside legal approval is not proven by a source-specific artifact and hash"],
            non_claims=[] if outside_ok else ["not outside legal approval"],
        )
    if claim_id == "bounded_production_r2_write":
        r2_ok = _production_r2_write_proven(r2_report)
        return _claim(
            claim_id,
            allowed=r2_ok,
            allowed_scope=_bounded_r2_scope(r2_report) if r2_ok else "blocked",
            evidence=[evidence_paths.get("r2_report", "")],
            issues=[] if r2_ok else ["production R2 upload/readback proof is missing or incomplete"],
            non_claims=["not R2 release readiness", "not native runtime readiness"],
        )
    if claim_id == "bounded_live_native_transport":
        live_ok = _live_transport_proven(native_transport_report)
        return _claim(
            claim_id,
            allowed=live_ok,
            allowed_scope=_bounded_live_transport_scope(native_transport_report) if live_ok else "blocked",
            evidence=[evidence_paths.get("native_transport_report", "")],
            issues=[] if live_ok else ["live native transport proof is missing or incomplete"],
            non_claims=["not custom-domain production readiness", "not Release Green"],
        )
    if claim_id == "bounded_production_target":
        production_target_ok = _production_r2_write_proven(r2_report) and _live_transport_proven(native_transport_report)
        return _claim(
            claim_id,
            allowed=production_target_ok,
            allowed_scope=_bounded_production_target_scope(r2_report, native_transport_report)
            if production_target_ok
            else "blocked",
            evidence=[evidence_paths.get("r2_report", ""), evidence_paths.get("native_transport_report", "")],
            issues=[] if production_target_ok else ["bounded production target requires both production R2 write proof and live native transport proof"],
            non_claims=["not universal coverage", "not Release Green"],
        )
    if claim_id == "bounded_configured_runtime_green":
        runtime_ok = _bounded_configured_runtime_proven(native_transport_report)
        return _claim(
            claim_id,
            allowed=runtime_ok,
            allowed_scope=_bounded_configured_runtime_scope(native_transport_report) if runtime_ok else "blocked",
            evidence=[evidence_paths.get("native_transport_report", "")],
            issues=[] if runtime_ok else ["bounded configured runtime proof is missing or incomplete"],
            non_claims=["not full Source Atlas Green", "not Release Green", "not literal universal coverage"],
        )
    if claim_id == "source_atlas_runtime_green":
        return _claim(
            claim_id,
            allowed=False,
            allowed_scope="blocked; requires full runtime scenario proof across Source Atlas composition, offline fallback, inspection, and release gates",
            evidence=[evidence_paths.get("native_transport_report", "")],
            issues=["current evidence proves bounded transport/lifecycle behavior, not broad Source Atlas Runtime Green"],
            non_claims=["not broad Runtime Green", "not Release Green"],
        )
    if claim_id == "release_green":
        release_ok = _release_approval_proven(release_approval_artifact)
        return _claim(
            claim_id,
            allowed=release_ok,
            allowed_scope="release umbrella proof with owner approval" if release_ok else "blocked",
            evidence=[evidence_paths.get("release_approval_artifact", "")],
            issues=[] if release_ok else ["Codex cannot self-certify Release Green; release umbrella/device/accessibility/privacy/legal approval evidence is missing"],
            non_claims=["not Release Green"] if not release_ok else [],
        )
    if claim_id == "universal_coverage":
        coverage_ok = _universal_coverage_proven(coverage_report)
        return _claim(
            claim_id,
            allowed=coverage_ok,
            allowed_scope="governed universal coverage frontier proof" if coverage_ok else "blocked",
            evidence=[evidence_paths.get("coverage_report", "")],
            issues=[] if coverage_ok else ["literal or unbounded universal coverage is not proven; use governed coverage-frontier scope instead"],
            non_claims=["not universal coverage"] if not coverage_ok else [],
        )
    return _claim(
        claim_id,
        allowed=False,
        allowed_scope="blocked",
        evidence=[],
        issues=[f"unsupported Source Atlas release claim: {claim_id}"],
        non_claims=[],
    )


def _claim(
    claim_id: str,
    *,
    allowed: bool,
    allowed_scope: str,
    evidence: list[str],
    issues: list[str],
    non_claims: list[str],
) -> dict[str, Any]:
    return {
        "claimID": claim_id,
        "allowed": allowed,
        "status": "allowed" if allowed else "blocked",
        "allowedScope": allowed_scope,
        "evidence": [item for item in evidence if item],
        "issues": issues,
        "nonClaims": non_claims,
    }


def _outside_legal_claimed(legal_packet: dict[str, Any] | None) -> bool:
    if not isinstance(legal_packet, dict):
        return False
    if legal_packet.get("outsideLegalApprovalClaimed") is True:
        return True
    return any(
        approval.get("outsideLegalStatus") == "approved"
        for approval in legal_packet.get("sourceApprovals", [])
        if isinstance(approval, dict)
    )


def _outside_legal_proven(legal_packet: dict[str, Any] | None, terms_validation: dict[str, Any]) -> bool:
    if not isinstance(legal_packet, dict) or terms_validation.get("valid") is not True:
        return False
    approvals = [item for item in legal_packet.get("sourceApprovals", []) if isinstance(item, dict)]
    return bool(approvals) and all(
        approval.get("outsideLegalStatus") == "approved"
        and bool(approval.get("outsideLegalApprovalArtifact"))
        and bool(approval.get("outsideLegalApprovalArtifactHash"))
        for approval in approvals
    )


def _production_r2_write_proven(r2_report: dict[str, Any] | None) -> bool:
    if not isinstance(r2_report, dict):
        return False
    checks = {item.get("name"): item.get("passed") for item in r2_report.get("checks", []) if isinstance(item, dict)}
    operation = r2_report.get("operation", {}) if isinstance(r2_report.get("operation"), dict) else {}
    return (
        r2_report.get("kind") == "ambitions.sourceAtlas.r2PackPublisherReport.v1"
        and r2_report.get("environment") == "production"
        and r2_report.get("channel") == "stable"
        and r2_report.get("mode") == "remote_r2"
        and r2_report.get("executeRequested") is True
        and r2_report.get("productionR2Uploaded") is True
        and r2_report.get("realR2CredentialsUsed") is True
        and r2_report.get("valid") is True
        and operation.get("success") is True
        and operation.get("remoteR2") is True
        and checks.get("remote_r2_public_reference_transport_only") is True
        and checks.get("upload_readback_checksums") is True
        and checks.get("current_pointer_after_readback_only") is True
    )


def _bounded_r2_scope(r2_report: dict[str, Any] | None) -> str:
    frontier_id = _frontier_id_from_pack_report(r2_report)
    if frontier_id:
        return f"specific production stable {frontier_id} R2 upload/readback proof"
    return "specific production stable R2 upload/readback proof"


def _bounded_live_transport_scope(native_transport_report: dict[str, Any] | None) -> str:
    frontiers = sorted(_native_transport_frontiers(native_transport_report))
    if frontiers:
        return "bounded production stable {frontiers} Worker gateway and native URLSession/lifecycle proof".format(
            frontiers=", ".join(frontiers)
        )
    return "bounded production stable Worker gateway and native URLSession/lifecycle proof"


def _bounded_production_target_scope(
    r2_report: dict[str, Any] | None,
    native_transport_report: dict[str, Any] | None,
) -> str:
    frontier_id = _frontier_id_from_pack_report(r2_report)
    native_frontiers = _native_transport_frontiers(native_transport_report)
    if frontier_id and frontier_id in native_frontiers:
        return f"specific production stable {frontier_id} pack target"
    if frontier_id:
        return f"specific production stable {frontier_id} pack target with bounded native transport proof"
    return "specific production stable pack target"


def _bounded_configured_runtime_proven(native_transport_report: dict[str, Any] | None) -> bool:
    if not isinstance(native_transport_report, dict):
        return False
    runtime_claim = native_transport_report.get("runtimeGreenClaim")
    record_counts = native_transport_report.get("recordCounts", {})
    proof = native_transport_report.get("proofSummary")
    return (
        native_transport_report.get("kind") == "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1"
        and native_transport_report.get("valid") is True
        and "bounded_configured_runtime_green" in native_transport_report.get("allowedClaims", [])
        and isinstance(runtime_claim, dict)
        and runtime_claim.get("allowed") is True
        and int(record_counts.get("configuredDomains", 0)) > 0
        and int(record_counts.get("domainsBlocked", 1)) == 0
        and int(record_counts.get("xcodeFailed", 1)) == 0
        and int(record_counts.get("xcodeSkipped", 1)) == 0
        and isinstance(proof, dict)
        and bool(proof.get("r2RequestPrivacyProof"))
        and bool(proof.get("noPrivateGraphEgressProof"))
        and bool(proof.get("nativeOfflineNoAccountProof"))
        and bool(proof.get("runtimeCompositionProof"))
    )


def _bounded_configured_runtime_scope(native_transport_report: dict[str, Any] | None) -> str:
    frontiers = sorted(_native_transport_frontiers(native_transport_report))
    if frontiers:
        return "bounded configured runtime proof for {frontiers}".format(frontiers=", ".join(frontiers))
    return "bounded configured runtime proof"


def _frontier_id_from_pack_report(report: dict[str, Any] | None) -> str | None:
    if not isinstance(report, dict):
        return None
    return _frontier_id_from_pack_id(str(report.get("packID", "")))


def _frontier_id_from_pack_id(pack_id: str) -> str | None:
    marker = "source-atlas/v1/domain/"
    if marker not in pack_id:
        return None
    remainder = pack_id.split(marker, 1)[1]
    frontier_id = remainder.split("/", 1)[0]
    return frontier_id or None


def _native_transport_frontiers(native_transport_report: dict[str, Any] | None) -> set[str]:
    if not isinstance(native_transport_report, dict):
        return set()
    frontiers: set[str] = set()
    proof = native_transport_report.get("native_runtime_proof", {})
    if isinstance(proof, dict):
        frontiers.update(_native_transport_frontiers_from_proof(proof))
    proof_list = native_transport_report.get("native_runtime_proofs", [])
    if isinstance(proof_list, list):
        for item in proof_list:
            frontiers.update(_native_transport_frontiers_from_proof(item))
    configured_frontiers = native_transport_report.get("configuredFrontiers", [])
    if isinstance(configured_frontiers, list):
        frontiers.update(item for item in configured_frontiers if isinstance(item, str) and item)
    return frontiers


def _native_transport_frontiers_from_proof(proof: Any) -> set[str]:
    if not isinstance(proof, dict):
        return set()
    target_domain = proof.get("target_domain")
    if isinstance(target_domain, str) and target_domain:
        return {target_domain}
    target_pack_id = str(proof.get("target_pack_id", ""))
    frontier_id = _frontier_id_from_pack_id(target_pack_id)
    return {frontier_id} if frontier_id else set()


def _live_transport_proven(native_transport_report: dict[str, Any] | None) -> bool:
    if not isinstance(native_transport_report, dict):
        return False
    if native_transport_report.get("kind") == "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1":
        record_counts = native_transport_report.get("recordCounts", {})
        proof = native_transport_report.get("proofSummary", {})
        xcode = native_transport_report.get("xcodeBuildMCP", {})
        return (
            native_transport_report.get("valid") is True
            and native_transport_report.get("productLawPreserved") is True
            and bool(native_transport_report.get("configuredFrontiers"))
            and int(record_counts.get("configuredDomains", 0)) > 0
            and int(record_counts.get("domainsRuntimeReady", 0)) == int(record_counts.get("configuredDomains", -1))
            and int(record_counts.get("domainsBlocked", 1)) == 0
            and int(record_counts.get("xcodeFailed", 1)) == 0
            and int(record_counts.get("xcodeSkipped", 1)) == 0
            and isinstance(xcode, dict)
            and xcode.get("result") == "SUCCEEDED"
            and bool(xcode.get("testRunnerEnv", {}).get("SOURCE_ATLAS_LIVE_R2_ENDPOINT"))
            and isinstance(proof, dict)
            and bool(proof.get("r2RequestPrivacyProof"))
            and bool(proof.get("noPrivateGraphEgressProof"))
        )
    status = str(native_transport_report.get("status", ""))
    proofs: list[dict[str, Any]] = []
    proof = native_transport_report.get("native_runtime_proof", {})
    if isinstance(proof, dict) and proof:
        proofs.append(proof)
    proof_list = native_transport_report.get("native_runtime_proofs", [])
    if isinstance(proof_list, list):
        proofs.extend(item for item in proof_list if isinstance(item, dict))
    validations = native_transport_report.get("validation_run", [])
    passed = all(item.get("status") == "passed" for item in validations if isinstance(item, dict))
    proof_ready = bool(proofs) and all(
        proof.get("default_app_container_wired") is True
        and bool(proof.get("live_urlsession_test"))
        and bool(proof.get("live_lifecycle_test"))
        for proof in proofs
    )
    return (
        "green_for_bounded" in status
        and "worker_gateway_live_transport" in status
        and native_transport_report.get("product_law_preserved") is True
        and proof_ready
        and passed
    )


def _release_approval_proven(release_approval_artifact: dict[str, Any] | None) -> bool:
    if not isinstance(release_approval_artifact, dict):
        return False
    required = [
        "releaseOwnerApprovalArtifact",
        "deviceProofArtifact",
        "accessibilityProofArtifact",
        "privacyLegalApprovalArtifact",
        "rollbackProofArtifact",
    ]
    return release_approval_artifact.get("status") == "approved_release_green" and all(
        bool(release_approval_artifact.get(field)) for field in required
    )


def _universal_coverage_proven(coverage_report: dict[str, Any] | None) -> bool:
    if not isinstance(coverage_report, dict):
        return False
    frontiers = coverage_report.get("frontiers", [])
    if coverage_report.get("universalCoverageClaimAllowed") is not True or not frontiers:
        return False
    return all(
        isinstance(frontier, dict)
        and frontier.get("status") == "production_ready"
        and frontier.get("legalPostureComplete") is True
        and frontier.get("provenanceComplete") is True
        and frontier.get("appRuntimeProofComplete") is True
        for frontier in frontiers
    )
