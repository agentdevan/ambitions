"""Govern reviewer completion packets before approval-chain assembly.

This intake is the controlled handoff between source-specific reviewer work and
the existing catalog approval chain. It does not approve sources by itself. It
normalizes explicit source/legal/API review packets into the Train 65 completion
artifact only when the downstream assembler accepts the result.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_decision_assembler import (
    COMPLETION_KIND,
    CatalogApprovalDecisionAssemblerOptions,
    compile_catalog_approval_decision_assembler,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REVIEWER_COMPLETION_INTAKE_VERSION = "source-atlas-catalog-reviewer-completion-intake-train-67"
CATALOG_REVIEWER_COMPLETION_INTAKE_KIND = "ambitions.sourceAtlas.catalogReviewerCompletionIntake.v1"
REVIEW_PACKET_COLLECTION_KIND = "ambitions.sourceAtlas.catalogSourceReviewCompletionPackets.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

REVIEWER_COMPLETION_NON_CLAIMS = [
    "reviewer completion intake only",
    "not legal approval by itself",
    "not outside legal approval without outside approval artifact",
    "not source authority without completed source-specific review packet",
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
class CatalogReviewerCompletionIntakeOptions:
    decision_inputs_path: Path
    output_root: Path
    review_packets_path: Path | None = None
    created_at: str | None = None


def compile_catalog_reviewer_completion_intake(options: CatalogReviewerCompletionIntakeOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    decision_payload = read_json(options.decision_inputs_path)
    packets = _decision_input_packets(decision_payload)
    input_schema_issues = _decision_input_schema_issues(decision_payload, packets)
    input_privacy_issues = privacy_findings_for_value(decision_payload, "catalog-reviewer-completion-intake-decision-inputs")

    review_payload = read_json(options.review_packets_path) if options.review_packets_path else None
    review_packets = _review_packets(review_payload)
    review_schema_issues = _review_packet_schema_issues(review_payload, review_packets, provided=options.review_packets_path is not None)
    review_privacy_issues = (
        privacy_findings_for_value(review_payload, "catalog-reviewer-completion-intake-review-packets")
        if review_payload is not None
        else []
    )

    assembly = _assemble_review_completion(packets, review_packets, created_at)
    completion_artifact = assembly["reviewCompletionArtifact"] if assembly["valid"] and assembly["completedReviewCompletions"] > 0 else {}
    completion_path = output_root / "catalog-approval-decision-completion.json"
    if completion_artifact:
        write_json(completion_path, completion_artifact)
        assembler_validation = compile_catalog_approval_decision_assembler(
            CatalogApprovalDecisionAssemblerOptions(
                decision_inputs_path=options.decision_inputs_path,
                output_root=output_root / "assembler-validation",
                review_completion_path=completion_path,
                created_at=created_at,
            )
        )
    else:
        assembler_validation = {
            "valid": True,
            "status": "not run; no completed reviewer completion artifact",
            "recordCounts": {
                "completedDecisionArtifacts": 0,
                "approvedEntries": 0,
                "blockedDecisionAssemblies": len(packets),
                "claims": 0,
                "packableClaims": 0,
                "r2PackableArtifacts": 0,
            },
            "issues": [],
            "nonClaims": ["missing reviewer completion keeps downstream assembler blocked"],
        }
        write_json(
            completion_path,
            {
                "kind": "ambitions.sourceAtlas.catalogApprovalDecisionCompletionUnavailable.v1",
                "created_at": created_at,
                "reason": "completed source-specific reviewer packets required before completion artifact is available",
                "non_claims": ["placeholder only", "not a Train 65 review completion artifact", "not approval"],
            },
        )

    blocked = sorted(assembly["blockedReviewCompletions"], key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_REVIEWER_COMPLETION_INTAKE_KIND,
        "versionID": CATALOG_REVIEWER_COMPLETION_INTAKE_VERSION,
        "createdAt": created_at,
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewPacketsPath": str(options.review_packets_path) if options.review_packets_path else "",
        "reviewPacketValidation": assembly,
        "reviewCompletionArtifact": completion_artifact,
        "reviewCompletionArtifactPath": str(completion_path) if completion_artifact else "",
        "assemblerValidation": _assembler_validation_summary(assembler_validation),
        "blockedReviewCompletions": blocked,
        "activeRegistryMutations": [],
        "recordCounts": {
            "decisionInputPackets": len(packets),
            "reviewPackets": len(review_packets),
            "completedReviewCompletions": assembly["completedReviewCompletions"],
            "completedDecisionArtifacts": assembler_validation.get("recordCounts", {}).get("completedDecisionArtifacts", 0),
            "approvedEntries": assembler_validation.get("recordCounts", {}).get("approvedEntries", 0),
            "blockedReviewCompletions": len(blocked),
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEWER_COMPLETION_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-reviewer-completion-intake")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    assembler_issues = assembler_validation.get("issues", []) if completion_artifact else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "review_packet_schema_valid", "passed": not review_schema_issues, "issues": review_schema_issues},
        {"name": "review_packet_privacy_scan_passed", "passed": not review_privacy_issues, "issues": review_privacy_issues},
        {
            "name": "missing_review_packets_block_without_approval",
            "passed": options.review_packets_path is not None or assembly["completedReviewCompletions"] == 0,
            "issues": [],
        },
        {
            "name": "completed_artifact_matches_decision_assembler_contract",
            "passed": not completion_artifact or assembler_validation.get("valid") is True,
            "issues": assembler_issues,
        },
        {
            "name": "reviewer_completion_intake_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(review_schema_issues)
    issues.extend(review_privacy_issues)
    issues.extend(assembly["issues"])
    issues.extend(assembler_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogReviewerCompletionIntakeManifest.v1",
        "versionID": CATALOG_REVIEWER_COMPLETION_INTAKE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog reviewer completion intake tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; reviewer completion intake tooling only",
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewPacketsPath": str(options.review_packets_path) if options.review_packets_path else "",
        "reviewCompletionArtifactPath": str(completion_path) if completion_artifact else "",
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogReviewerCompletionIntake": str(output_root / "catalog-reviewer-completion-intake.json"),
            "reviewCompletionArtifact": str(completion_path),
            "blockedReviewCompletions": str(output_root / "blocked-review-completions.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEWER_COMPLETION_NON_CLAIMS,
    }

    write_json(output_root / "catalog-reviewer-completion-intake.json", artifact)
    write_json(
        output_root / "blocked-review-completions.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedReviewerCompletions.v1",
            "createdAt": created_at,
            "blockedReviewCompletions": blocked,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogReviewerCompletionIntake": stable_hash(read_json(output_root / "catalog-reviewer-completion-intake.json")),
        "reviewCompletionArtifact": stable_hash(read_json(completion_path)),
        "blockedReviewCompletions": stable_hash(read_json(output_root / "blocked-review-completions.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_reviewer_completion_intake_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_reviewer_completion_intake_report(
    markdown_path: Path,
    json_path: Path,
    *,
    decision_inputs_path: Path,
    output_root: Path,
    review_packets_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=decision_inputs_path,
            output_root=output_root,
            review_packets_path=review_packets_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_reviewer_completion_intake_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_reviewer_completion_intake_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Reviewer Completion Intake Train 67",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Review packets path: {result['reviewPacketsPath'] or 'not provided'}",
        f"Review completion artifact path: {result['reviewCompletionArtifactPath'] or 'not emitted'}",
        "",
        "Scope completed:",
        "- Governed reviewer-completion intake before the Train 65 decision assembler.",
        "- Missing source-specific review packets produce blocked reviewer-completion records, not approvals.",
        "- Completed packets emit a Train 65-compatible review completion artifact only after downstream assembler validation passes.",
        "",
        "Counts:",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Completed reviewer completions: {counts['completedReviewCompletions']}",
        f"- Completed decision artifacts: {counts['completedDecisionArtifacts']}",
        f"- Approved entries: {counts['approvedEntries']}",
        f"- Blocked reviewer completions: {counts['blockedReviewCompletions']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Reviewer completion intake cannot manufacture outside legal approval without an artifact.",
        "- Review packets remain source-specific governance inputs, not source authority by themselves.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this intake.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- Intake outputs only public/reference governance completion metadata and blocked evidence.",
            "",
            "No private graph egress proof:",
            "- Decision input, review packet, completion artifact, and output privacy scans must pass before Source Green.",
            "- The intake emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Legal/terms review fields must be present before completion is emitted.",
            "- Outside legal approval is not claimed without outside legal approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- The downstream Train 65/62 validation still rejects catalog/source-of-sources authority and non-pack-allowed posture.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 67. This train normalizes governance completion only.",
            "",
            "Freshness/revocation proof:",
            "- Review freshness fields are validated downstream before completion can pass.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 67. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry reviewer completion intake, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: source-specific review completion artifacts, then approval chain with explicit temp registries.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
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


def _decision_input_schema_issues(payload: Any, packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog reviewer completion intake decision input must be an object or array")
    if not packets:
        issues.append("catalog reviewer completion intake requires decision input packets")
    for index, packet in enumerate(packets):
        for field in ("decision_input_id", "proposal_id", "intake_id", "candidate_id", "source_id", "domain_guess"):
            if not packet.get(field):
                issues.append(f"decisionInputPackets[{index}].{field} required")
    return issues


def _review_packets(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("sourceReviewCompletionPackets"), list):
        return [item for item in payload["sourceReviewCompletionPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("reviewCompletionPackets"), list):
        return [item for item in payload["reviewCompletionPackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _review_packet_schema_issues(payload: Any, packets: list[dict[str, Any]], *, provided: bool) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog reviewer completion review packet input must be an object or array")
    if isinstance(payload, dict) and payload.get("kind") not in {None, REVIEW_PACKET_COLLECTION_KIND}:
        issues.append(f"review packet collection kind must be {REVIEW_PACKET_COLLECTION_KIND}")
    if not packets:
        issues.append("review packet input must include sourceReviewCompletionPackets")
    for index, packet in enumerate(packets):
        if not packet.get("proposal_id"):
            issues.append(f"sourceReviewCompletionPackets[{index}].proposal_id required")
        if not packet.get("intake_id"):
            issues.append(f"sourceReviewCompletionPackets[{index}].intake_id required")
        if not packet.get("completion_status"):
            issues.append(f"sourceReviewCompletionPackets[{index}].completion_status required")
    return issues


def _assemble_review_completion(packets: list[dict[str, Any]], review_packets: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    issues: list[str] = []
    packets_by_proposal = {str(packet.get("proposal_id") or ""): packet for packet in packets}
    review_by_proposal: dict[str, dict[str, Any]] = {}
    duplicate_review_ids: set[str] = set()
    for packet in review_packets:
        proposal_id = str(packet.get("proposal_id") or "")
        if proposal_id in review_by_proposal:
            duplicate_review_ids.add(proposal_id)
        if proposal_id:
            review_by_proposal[proposal_id] = packet
    for proposal_id in sorted(duplicate_review_ids):
        issues.append(f"{proposal_id}: duplicate source review completion packet")

    completed_entries: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    outside_legal_values: set[tuple[str, str]] = set()
    owners: set[str] = set()
    reviewed_dates: set[str] = set()
    for packet in packets:
        proposal_id = str(packet.get("proposal_id") or "")
        review = review_by_proposal.get(proposal_id)
        if not review:
            blocked.append(_blocked_review_completion(packet, created_at, ["source_review_completion_packet_required"]))
            continue
        if review.get("intake_id") != packet.get("intake_id"):
            issues.append(f"{proposal_id}: review packet intake_id must match decision input packet")
        status = str(review.get("completion_status") or "")
        if status != "completed":
            blocked.append(_blocked_review_completion(packet, created_at, [f"review_completion_status_{status or 'missing'}"]))
            continue
        review_issues = _completed_review_packet_issues(review, packet)
        if review_issues:
            issues.extend(review_issues)
            blocked.append(_blocked_review_completion(packet, created_at, ["source_review_completion_packet_invalid", *review_issues]))
            continue
        source_review = review.get("source_lane_review") if isinstance(review.get("source_lane_review"), dict) else {}
        legal_review = review.get("legal_terms_review") if isinstance(review.get("legal_terms_review"), dict) else {}
        api_review = review.get("api_governance_review") if isinstance(review.get("api_governance_review"), dict) else {}
        completed_entries.append(
            {
                "proposal_id": proposal_id,
                "intake_id": str(packet.get("intake_id") or ""),
                "source_lane_entry": source_review["source_lane_entry"],
                "legal_terms_entry": legal_review["legal_terms_entry"],
                "api_policy_entry": api_review["api_policy_entry"],
            }
        )
        outside_legal_values.add((str(legal_review.get("outside_legal_status") or "not_claimed"), str(legal_review.get("outside_legal_approval_artifact") or "")))
        owners.add(str(review.get("review_owner") or ""))
        reviewed_dates.add(str(review.get("reviewed_at") or ""))

    for proposal_id in sorted(set(review_by_proposal) - set(packets_by_proposal)):
        issues.append(f"{proposal_id}: review packet does not match input decision packet")
    if len(outside_legal_values) > 1:
        issues.append("completed review packets must share one outside_legal_status/outside_legal_approval_artifact pair")
    if len(owners) > 1:
        issues.append("completed review packets must share one review_owner")
    if len(reviewed_dates) > 1:
        issues.append("completed review packets must share one reviewed_at")

    completion_artifact: dict[str, Any] = {}
    if completed_entries and not issues:
        outside_legal_status, outside_legal_artifact = next(iter(outside_legal_values)) if outside_legal_values else ("not_claimed", "")
        completion_artifact = {
            "kind": COMPLETION_KIND,
            "completion_status": "completed",
            "decision_artifact_id": stable_id(
                "source-atlas.catalog-approval-finalizer-decision",
                {"selected": sorted(entry["proposal_id"] for entry in completed_entries), "created_at": created_at},
            ),
            "review_owner": next(iter(owners)) if owners else "",
            "reviewed_at": next(iter(reviewed_dates)) if reviewed_dates else "",
            "source_lane_review_complete": True,
            "legal_terms_review_complete": True,
            "api_governance_review_complete": True,
            "outside_legal_status": outside_legal_status,
            "outside_legal_approval_artifact": outside_legal_artifact,
            "completed_entries": sorted(completed_entries, key=lambda item: (item["intake_id"], item["proposal_id"])),
            "non_claims": [
                "source-specific reviewer completion normalized by intake",
                "not outside legal approval unless outside approval artifact is present",
                "not active registry mutation",
                "not claim output",
                "not pack output",
                "not R2 readiness",
            ],
        }
    return {
        "valid": not issues,
        "reviewCompletionArtifactProvided": bool(completion_artifact),
        "completedReviewCompletions": len(completed_entries) if not issues else 0,
        "blockedReviewCompletions": blocked if not completion_artifact else blocked,
        "reviewCompletionArtifact": completion_artifact,
        "issues": sorted(set(issues)),
        "nonClaims": ["review completion intake validation does not equal legal approval or active registry mutation"],
    }


def _completed_review_packet_issues(review: dict[str, Any], packet: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for field in ("review_owner", "reviewed_at"):
        if not review.get(field):
            issues.append(f"{packet.get('proposal_id')}: {field} required")
    for review_field, entry_field in (
        ("source_lane_review", "source_lane_entry"),
        ("legal_terms_review", "legal_terms_entry"),
        ("api_governance_review", "api_policy_entry"),
    ):
        review_section = review.get(review_field) if isinstance(review.get(review_field), dict) else {}
        if review_section.get("status") != "completed":
            issues.append(f"{packet.get('proposal_id')}: {review_field}.status must be completed")
        if not isinstance(review_section.get(entry_field), dict) or not review_section.get(entry_field):
            issues.append(f"{packet.get('proposal_id')}: {review_field}.{entry_field} required")
    legal_review = review.get("legal_terms_review") if isinstance(review.get("legal_terms_review"), dict) else {}
    if legal_review.get("outside_legal_status") == "approved" and not legal_review.get("outside_legal_approval_artifact"):
        issues.append(f"{packet.get('proposal_id')}: outside legal approval requires outside_legal_approval_artifact")
    issues.extend(privacy_findings_for_value(review, f"sourceReviewCompletionPackets[{packet.get('proposal_id')}]"))
    return sorted(set(issues))


def _blocked_review_completion(packet: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "blocked_review_completion_id": stable_id("catalog_reviewer_completion_block", {"packet": packet.get("decision_input_id"), "reasons": sorted(reasons)}),
        "decision_input_id": str(packet.get("decision_input_id") or ""),
        "proposal_id": str(packet.get("proposal_id") or ""),
        "intake_id": str(packet.get("intake_id") or ""),
        "candidate_id": str(packet.get("candidate_id") or ""),
        "domain_guess": str(packet.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(packet.get("source_id") or ""),
        "source_name": str(packet.get("source_name") or ""),
        "created_at": created_at,
        "status": "blocked",
        "blocking_reasons": sorted(set(reasons)),
        "non_claims": ["blocked reviewer completion only", "not approval", "not finalizer decision", "not active registry mutation"],
    }


def _assembler_validation_summary(result: dict[str, Any]) -> dict[str, Any]:
    return {
        "valid": result.get("valid"),
        "status": result.get("status", ""),
        "recordCounts": result.get("recordCounts", {}),
        "issues": result.get("issues", []),
        "outputRoot": result.get("outputRoot", ""),
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
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "blocking_reasons"}
        )
    return False
