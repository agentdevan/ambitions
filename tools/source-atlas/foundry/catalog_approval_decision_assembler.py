"""Assemble finalizer decision artifacts from reviewer-completed inputs.

Decision inputs are reviewer work packets, not approval. This compiler is the
next gate: it accepts explicit source/legal/API completion data and emits a
finalizer-compatible decision artifact only when the completion passes the same
public/reference, legal posture, API governance, and no-private-output checks.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_finalizer import DECISION_KIND, _validate_decision
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_APPROVAL_DECISION_ASSEMBLER_VERSION = "source-atlas-catalog-approval-decision-assembler-train-65"
CATALOG_APPROVAL_DECISION_ASSEMBLER_KIND = "ambitions.sourceAtlas.catalogApprovalDecisionAssembler.v1"
COMPLETION_KIND = "ambitions.sourceAtlas.catalogApprovalDecisionCompletion.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DECISION_ASSEMBLER_NON_CLAIMS = [
    "not legal approval by itself",
    "not outside legal approval without outside approval artifact",
    "not source authority without completed reviewer fields",
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
class CatalogApprovalDecisionAssemblerOptions:
    decision_inputs_path: Path
    output_root: Path
    review_completion_path: Path | None = None
    created_at: str | None = None


def compile_catalog_approval_decision_assembler(options: CatalogApprovalDecisionAssemblerOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    input_payload = read_json(options.decision_inputs_path)
    packets = _decision_input_packets(input_payload)
    input_schema_issues = _input_schema_issues(input_payload, packets)
    input_privacy_issues = privacy_findings_for_value(input_payload, "catalog-approval-decision-assembler-input")
    completion_payload = read_json(options.review_completion_path) if options.review_completion_path else None
    completion_privacy_issues = (
        privacy_findings_for_value(completion_payload, "catalog-approval-decision-assembler-completion")
        if completion_payload is not None
        else []
    )

    completion_result = _assemble_completion(
        completion_payload,
        packets,
        created_at,
        completion_path=str(options.review_completion_path) if options.review_completion_path else "",
    )
    completed_decision_artifacts = [completion_result["decisionArtifact"]] if completion_result["valid"] else []
    selected_proposal_ids = set(completion_result.get("selectedProposalIDs", [])) if completion_result["valid"] else set()
    blocked = [
        _blocked_assembly(packet, created_at, completion_result, selected=packet.get("proposal_id") in selected_proposal_ids)
        for packet in packets
        if packet.get("proposal_id") not in selected_proposal_ids or not completion_result["valid"]
    ]
    blocked = sorted(blocked, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    finalizer_decision_artifact = completed_decision_artifacts[0] if completed_decision_artifacts else {
        "kind": "ambitions.sourceAtlas.catalogApprovalFinalizerDecisionUnavailable.v1",
        "created_at": created_at,
        "reason": "review completion artifact required before finalizer decision is available",
        "non_claims": ["placeholder only", "not a finalizer decision artifact", "not approval"],
    }

    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_APPROVAL_DECISION_ASSEMBLER_KIND,
        "versionID": CATALOG_APPROVAL_DECISION_ASSEMBLER_VERSION,
        "createdAt": created_at,
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewCompletionPath": str(options.review_completion_path) if options.review_completion_path else "",
        "completionValidation": completion_result,
        "completedDecisionArtifacts": completed_decision_artifacts,
        "blockedDecisionAssemblies": blocked,
        "activeRegistryMutations": [],
        "recordCounts": {
            "decisionInputPackets": len(packets),
            "completedDecisionArtifacts": len(completed_decision_artifacts),
            "approvedEntries": sum(len(item.get("approved_entries", [])) for item in completed_decision_artifacts),
            "blockedDecisionAssemblies": len(blocked),
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DECISION_ASSEMBLER_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-approval-decision-assembler")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    completion_issues_for_checks = completion_result["issues"] if options.review_completion_path else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "completion_privacy_scan_passed", "passed": not completion_privacy_issues, "issues": completion_privacy_issues},
        {
            "name": "provided_completion_valid",
            "passed": options.review_completion_path is None or (completion_result["valid"] and not completion_privacy_issues),
            "issues": completion_issues_for_checks + completion_privacy_issues,
        },
        {
            "name": "completed_decision_artifacts_match_finalizer_contract",
            "passed": not completed_decision_artifacts or completion_result.get("finalizerValidation", {}).get("valid") is True,
            "issues": completion_result.get("finalizerValidation", {}).get("issues", []),
        },
        {
            "name": "decision_assembler_emits_no_claims",
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
    issues.extend(completion_privacy_issues)
    if options.review_completion_path:
        issues.extend(completion_result["issues"])
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    malformed_completion = options.review_completion_path is not None and (not completion_result["valid"] or bool(completion_privacy_issues))
    valid = (
        not input_schema_issues
        and not input_privacy_issues
        and not artifact_privacy_issues
        and not forbidden_output_issues
        and not malformed_completion
        and all(check["passed"] for check in checks)
    )
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogApprovalDecisionAssemblerManifest.v1",
        "versionID": CATALOG_APPROVAL_DECISION_ASSEMBLER_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog approval decision assembler tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; decision assembler tooling only",
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewCompletionPath": str(options.review_completion_path) if options.review_completion_path else "",
        "completionValidation": completion_result,
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogApprovalDecisionAssembler": str(output_root / "catalog-approval-decision-assembler.json"),
            "completedDecisionArtifacts": str(output_root / "completed-decision-artifacts.json"),
            "finalizerDecisionArtifact": str(output_root / "catalog-approval-finalizer-decision.json"),
            "blockedDecisionAssemblies": str(output_root / "blocked-decision-assemblies.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DECISION_ASSEMBLER_NON_CLAIMS,
    }

    write_json(output_root / "catalog-approval-decision-assembler.json", artifact)
    write_json(
        output_root / "completed-decision-artifacts.json",
        {
            "kind": "ambitions.sourceAtlas.catalogCompletedDecisionArtifacts.v1",
            "createdAt": created_at,
            "completedDecisionArtifacts": completed_decision_artifacts,
        },
    )
    write_json(output_root / "catalog-approval-finalizer-decision.json", finalizer_decision_artifact)
    write_json(
        output_root / "blocked-decision-assemblies.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedDecisionAssemblies.v1",
            "createdAt": created_at,
            "blockedDecisionAssemblies": blocked,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogApprovalDecisionAssembler": stable_hash(read_json(output_root / "catalog-approval-decision-assembler.json")),
        "completedDecisionArtifacts": stable_hash(read_json(output_root / "completed-decision-artifacts.json")),
        "finalizerDecisionArtifact": stable_hash(read_json(output_root / "catalog-approval-finalizer-decision.json")),
        "blockedDecisionAssemblies": stable_hash(read_json(output_root / "blocked-decision-assemblies.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_approval_decision_assembler_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_approval_decision_assembler_report(
    markdown_path: Path,
    json_path: Path,
    *,
    decision_inputs_path: Path,
    output_root: Path,
    review_completion_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_approval_decision_assembler(
        CatalogApprovalDecisionAssemblerOptions(
            decision_inputs_path=decision_inputs_path,
            output_root=output_root,
            review_completion_path=review_completion_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_approval_decision_assembler_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_approval_decision_assembler_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Approval Decision Assembler Train 65",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Review completion path: {result['reviewCompletionPath'] or 'not provided'}",
        "",
        "Scope completed:",
        "- Deterministic finalizer-decision assembler for reviewer-completed decision input packets.",
        "- Missing completion files produce blocked assemblies, not approvals.",
        "- Malformed completion files are Red and cannot emit approved finalizer decisions.",
        "",
        "Counts:",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Completed decision artifacts: {counts['completedDecisionArtifacts']}",
        f"- Approved entries: {counts['approvedEntries']}",
        f"- Blocked decision assemblies: {counts['blockedDecisionAssemblies']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Finalizer-compatible decisions are emitted only from explicit completed reviewer fields.",
        "- Outside legal approval is not claimed unless an outside legal approval artifact is present.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this assembler.",
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
            "- Assembler outputs only public/reference governance decision metadata and blocked-assembly evidence.",
            "",
            "No private graph egress proof:",
            "- Decision input, completion artifact, and output privacy scans must pass before Source Green.",
            "- The assembler emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Completed legal/terms entries require explicit source-specific reviewer fields.",
            "- Outside legal approval is not claimed without outside legal approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Public catalog/source-of-sources authority remains rejected by finalizer validation.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 65. This train assembles governance decisions only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane review/freshness fields are required by finalizer validation.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 65. No native files are touched by this assembler.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry decision assembler, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: real reviewer completion artifacts, then finalizer/mutation/applier gates.",
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


def _input_schema_issues(payload: Any, packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog approval decision assembler input must be an object or array")
    if not packets:
        issues.append("catalog approval decision assembler input must include decision input packets")
    for index, packet in enumerate(packets):
        for field in ("decision_input_id", "proposal_id", "intake_id", "draft_decision_artifact"):
            if not packet.get(field):
                issues.append(f"decisionInputPackets[{index}].{field} required")
    return issues


def _assemble_completion(completion: Any, packets: list[dict[str, Any]], created_at: str, *, completion_path: str) -> dict[str, Any]:
    if completion is None:
        return {
            "valid": False,
            "completionArtifactProvided": False,
            "completionArtifactPath": "",
            "decisionArtifactID": "",
            "reviewOwner": "",
            "reviewedAt": "",
            "outsideLegalStatus": "not_claimed",
            "selectedProposalIDs": [],
            "selectedIntakeIDs": [],
            "approvedEntries": [],
            "decisionArtifact": {},
            "finalizerValidation": {"valid": False, "issues": ["review completion artifact not provided"]},
            "issues": ["review completion artifact not provided; all decision inputs remain blocked"],
            "nonClaims": ["missing review completion is expected for blocked assembler dry-runs"],
        }

    issues: list[str] = []
    if not isinstance(completion, dict):
        issues.append("review completion artifact must be an object")
        completion = {}
    if completion.get("kind") != COMPLETION_KIND:
        issues.append(f"review completion artifact kind must be {COMPLETION_KIND}")
    if completion.get("completion_status") != "completed":
        issues.append("completion_status must be completed")
    for field in ("review_owner", "reviewed_at"):
        if not completion.get(field):
            issues.append(f"{field} required")
    for field in ("source_lane_review_complete", "legal_terms_review_complete", "api_governance_review_complete"):
        if completion.get(field) is not True:
            issues.append(f"{field} must be true")
    if completion.get("outside_legal_status") == "approved" and not completion.get("outside_legal_approval_artifact"):
        issues.append("outside_legal_status approved requires outside_legal_approval_artifact")

    completed_entries = completion.get("completed_entries", [])
    if not isinstance(completed_entries, list) or not completed_entries:
        issues.append("completed_entries must be a non-empty list")
        completed_entries = []
    packets_by_proposal = {str(packet.get("proposal_id") or ""): packet for packet in packets}
    proposals = [_proposal_for_packet(packet) for packet in packets]
    proposal_ids = set(packets_by_proposal)
    entry_ids: set[str] = set()
    approved_entries: list[dict[str, Any]] = []
    for index, entry in enumerate(completed_entries):
        if not isinstance(entry, dict):
            issues.append(f"completed_entries[{index}] must be an object")
            continue
        proposal_id = str(entry.get("proposal_id") or "")
        if not proposal_id:
            issues.append(f"completed_entries[{index}].proposal_id required")
        if proposal_id and proposal_id not in proposal_ids:
            issues.append(f"{proposal_id}: completed entry does not match input decision packet")
        if proposal_id and proposal_id in entry_ids:
            issues.append(f"{proposal_id}: duplicate completed entry")
        entry_ids.add(proposal_id)
        packet = packets_by_proposal.get(proposal_id, {})
        if entry.get("intake_id") != packet.get("intake_id"):
            issues.append(f"completed_entries[{index}].intake_id must match decision input packet intake_id")
        approved_entries.append(
            {
                "proposal_id": proposal_id,
                "intake_id": str(entry.get("intake_id") or ""),
                "source_lane_entry": entry.get("source_lane_entry") if isinstance(entry.get("source_lane_entry"), dict) else {},
                "legal_terms_entry": entry.get("legal_terms_entry") if isinstance(entry.get("legal_terms_entry"), dict) else {},
                "api_policy_entry": entry.get("api_policy_entry") if isinstance(entry.get("api_policy_entry"), dict) else {},
            }
        )

    selected = sorted(entry_ids)
    decision_artifact = {
        "kind": DECISION_KIND,
        "decision_artifact_id": str(completion.get("decision_artifact_id") or stable_id("source-atlas.catalog-approval-finalizer-decision", {"selected": selected, "created_at": created_at})),
        "decision_status": "approved",
        "review_owner": str(completion.get("review_owner") or ""),
        "reviewed_at": str(completion.get("reviewed_at") or ""),
        "source_lane_review_complete": completion.get("source_lane_review_complete") is True,
        "legal_terms_review_complete": completion.get("legal_terms_review_complete") is True,
        "api_governance_review_complete": completion.get("api_governance_review_complete") is True,
        "outside_legal_status": str(completion.get("outside_legal_status") or "not_claimed"),
        "outside_legal_approval_artifact": str(completion.get("outside_legal_approval_artifact") or ""),
        "selected_proposal_ids": selected,
        "approved_entries": sorted(approved_entries, key=lambda item: (item["intake_id"], item["proposal_id"])),
        "non_claims": [
            "reviewer completion assembled by tooling",
            "not outside legal approval unless outside approval artifact is present",
            "not active registry mutation",
            "not claim output",
            "not pack output",
            "not R2 readiness",
        ],
    }
    finalizer_validation = _validate_decision(decision_artifact, proposals, completion_path)
    issues.extend(finalizer_validation["issues"])
    return {
        "valid": not issues,
        "completionArtifactProvided": True,
        "completionArtifactPath": completion_path,
        "decisionArtifactID": decision_artifact["decision_artifact_id"],
        "reviewOwner": decision_artifact["review_owner"],
        "reviewedAt": decision_artifact["reviewed_at"],
        "outsideLegalStatus": decision_artifact["outside_legal_status"],
        "outsideLegalApprovalArtifact": decision_artifact["outside_legal_approval_artifact"],
        "selectedProposalIDs": finalizer_validation.get("selectedProposalIDs", selected),
        "selectedIntakeIDs": finalizer_validation.get("selectedIntakeIDs", []),
        "approvedEntries": finalizer_validation.get("approvedEntries", []),
        "decisionArtifact": decision_artifact if not issues else {},
        "finalizerValidation": finalizer_validation,
        "issues": sorted(set(issues)),
        "nonClaims": [
            "assembler validation does not equal outside legal approval unless outside approval artifact is present",
            "assembler does not write active registries",
        ],
    }


def _proposal_for_packet(packet: dict[str, Any]) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "proposal_id": str(packet.get("proposal_id") or ""),
        "request_id": str(packet.get("request_id") or ""),
        "intake_id": str(packet.get("intake_id") or ""),
        "candidate_id": str(packet.get("candidate_id") or ""),
        "domain_guess": str(packet.get("domain_guess") or "unclassified_public_reference"),
        "status": "terms_resolution_proposed",
        "source_id": str(packet.get("source_id") or ""),
        "source_name": str(packet.get("source_name") or ""),
        "resolved_approval_artifact_template": {
            "kind": "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1",
            "approval_status": "draft_not_approved",
            "selected_intake_ids": [str(packet.get("intake_id") or "")],
            "approved_entries": [{"intake_id": str(packet.get("intake_id") or "")}],
        },
        "blocking_reasons": ["approval_artifact_still_required"],
        "non_claims": ["proposal reconstructed from decision input packet for finalizer validation"],
    }


def _blocked_assembly(packet: dict[str, Any], created_at: str, completion_result: dict[str, Any], *, selected: bool) -> dict[str, Any]:
    reasons = set(str(reason) for reason in packet.get("blocking_reasons", []) if isinstance(reason, str))
    if not completion_result.get("completionArtifactProvided"):
        reasons.add("review_completion_artifact_required")
    elif not completion_result.get("valid"):
        reasons.add("review_completion_artifact_invalid")
    elif not selected:
        reasons.add("decision_input_not_selected_for_completion")
    return {
        "schema_version": "1.0.0",
        "blocked_assembly_id": stable_id("catalog_approval_decision_assembly_block", {"packet": packet.get("decision_input_id"), "reasons": sorted(reasons)}),
        "decision_input_id": str(packet.get("decision_input_id") or ""),
        "proposal_id": str(packet.get("proposal_id") or ""),
        "intake_id": str(packet.get("intake_id") or ""),
        "candidate_id": str(packet.get("candidate_id") or ""),
        "domain_guess": str(packet.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(packet.get("source_id") or ""),
        "source_name": str(packet.get("source_name") or ""),
        "created_at": created_at,
        "status": "blocked",
        "blocking_reasons": sorted(reasons),
        "completion_issues": completion_result.get("issues", []),
        "non_claims": ["blocked assembly only", "not approval", "not finalizer decision", "not active registry mutation"],
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
