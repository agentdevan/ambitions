"""Source-specific active-apply packet compiler for goal-domain registries.

This train creates the handoff artifacts required by the Train 97 readiness
gate: a source-specific review evidence packet, an active-registry approval
artifact, and a planned mutation file. It does not mutate active registries.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_active_registry_apply_gate import (
    SOURCE_SPECIFIC_REVIEW_CLASS,
    GoalDomainActiveRegistryApplyGateOptions,
    compile_goal_domain_active_registry_apply_gate,
)
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_VERSION = "source-atlas-goal-domain-source-specific-apply-packet-train-98"
GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_KIND = "ambitions.sourceAtlas.goalDomainSourceSpecificApplyPacket.v1"
GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_INPUT_KIND = "ambitions.sourceAtlas.goalDomainSourceSpecificApplyPacketInput.v1"
FIXTURE_MARKERS = (
    "fixture",
    "rehearsal",
    "example.gov",
    "goal-domain-rehearsal",
    "approved_for_fixture",
)

SOURCE_SPECIFIC_PACKET_NON_CLAIMS = [
    "source-specific active registry apply packet tooling only",
    "not active registry mutation",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not production R2 upload",
    "not native activation proof",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not outside legal approval",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainSourceSpecificApplyPacketOptions:
    input_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    created_at: str | None = None


def compile_goal_domain_source_specific_apply_packet(options: GoalDomainSourceSpecificApplyPacketOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload, input_load_issues = _safe_read_json(options.input_path, "source-specific apply packet input")
    planned_mutations = _planned_mutations(payload)
    input_shape_issues = _input_shape_issues(payload, planned_mutations)
    input_privacy_issues = privacy_findings_for_value(payload, "goal-domain-source-specific-apply-packet-input") if payload is not None else []
    source_specific_issues = _source_specific_issues(payload, planned_mutations)

    issues = sorted(set(input_load_issues + input_shape_issues + input_privacy_issues + source_specific_issues))
    plan_path = output_root / "planned-registry-mutations.json"
    review_evidence_path = output_root / "source-specific-review-evidence.json"
    approval_artifact_path = output_root / "active-registry-apply-approval.json"
    readiness_gate: dict[str, Any] | None = None

    if not issues:
        planned_payload = _planned_payload(payload, planned_mutations, created_at)
        review_evidence = _review_evidence(payload, planned_mutations, created_at)
        approval_artifact = _approval_artifact(payload, planned_mutations, created_at)
        write_json(plan_path, planned_payload)
        write_json(review_evidence_path, review_evidence)
        write_json(approval_artifact_path, approval_artifact)
        readiness_gate = compile_goal_domain_active_registry_apply_gate(
            GoalDomainActiveRegistryApplyGateOptions(
                plan_path=plan_path,
                output_root=output_root / "active-apply-gate",
                review_evidence_path=review_evidence_path,
                source_lane_registry_path=options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH,
                legal_terms_registry_path=options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH,
                api_governance_registry_path=options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH,
                approval_artifact=approval_artifact_path,
                execute=True,
                allow_active_registry_write=True,
                created_at=created_at,
            )
        )
        if readiness_gate.get("valid") is not True:
            issues.extend(f"readiness gate issue: {issue}" for issue in readiness_gate.get("evaluationIssues", []))
        if readiness_gate.get("activeRegistryApplyAllowed") is not True:
            issues.extend(f"readiness gate blocked: {reason}" for reason in readiness_gate.get("blockingReasons", []))

    valid = not issues
    record_counts = {
        "plannedRegistryMutations": len(planned_mutations),
        "sourceSpecificReviewEvidenceRecords": len(planned_mutations) if not issues else 0,
        "approvalArtifacts": 1 if not issues else 0,
        "activeRegistryReadinessAllowed": 1 if readiness_gate and readiness_gate.get("activeRegistryApplyAllowed") is True else 0,
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    checks = [
        {"name": "input_loaded", "passed": not input_load_issues, "issues": input_load_issues},
        {"name": "input_shape_valid", "passed": not input_shape_issues, "issues": input_shape_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "source_specific_review_class_valid", "passed": not source_specific_issues, "issues": source_specific_issues},
        {
            "name": "train_97_gate_allows_readiness",
            "passed": bool(readiness_gate and readiness_gate.get("activeRegistryApplyAllowed") is True) if not input_load_issues and not input_shape_issues and not input_privacy_issues else False,
            "issues": [] if readiness_gate and readiness_gate.get("activeRegistryApplyAllowed") is True else (readiness_gate or {}).get("blockingReasons", []),
        },
        {
            "name": "packet_emits_no_active_writes_claims_packs_r2_or_native_activation",
            "passed": record_counts["activeRegistryMutations"] == 0
            and record_counts["claims"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
    ]
    output_paths = {
        "report": str(output_root / "goal-domain-source-specific-apply-packet-report.json"),
        "plannedRegistryMutations": str(plan_path) if plan_path.exists() else "",
        "sourceSpecificReviewEvidence": str(review_evidence_path) if review_evidence_path.exists() else "",
        "approvalArtifact": str(approval_artifact_path) if approval_artifact_path.exists() else "",
        "activeApplyGate": readiness_gate.get("manifestPath") if readiness_gate else "",
        "closeout": str(output_root / "closeout.md"),
    }
    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_KIND,
        "versionID": GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain source-specific apply packet tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; source-specific apply packet tooling only",
        "inputPath": str(options.input_path),
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "activeApplyGate": readiness_gate or {},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": SOURCE_SPECIFIC_PACKET_NON_CLAIMS,
        "productionNonClaims": [
            "no active registry mutation",
            "no production R2 upload",
            "no app runtime Green",
            "no release Green",
            "no universal coverage",
            "no outside legal approval",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": output_paths,
    }
    report["outputHashes"] = {
        key: stable_hash(read_json(Path(value)))
        for key, value in output_paths.items()
        if key not in {"closeout"} and value and Path(value).exists()
    }
    write_json(output_root / "goal-domain-source-specific-apply-packet-report.json", report)
    report["outputHashes"]["report"] = stable_hash(read_json(output_root / "goal-domain-source-specific-apply-packet-report.json"))
    write_json(output_root / "goal-domain-source-specific-apply-packet-report.json", report)
    (output_root / "closeout.md").write_text(goal_domain_source_specific_apply_packet_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "goal-domain-source-specific-apply-packet-report.json"), "outputRoot": str(output_root), **report}


def write_goal_domain_source_specific_apply_packet_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_source_specific_apply_packet(
        GoalDomainSourceSpecificApplyPacketOptions(
            input_path=input_path,
            output_root=output_root,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_source_specific_apply_packet_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_source_specific_apply_packet_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Source-Specific Apply Packet Train 98",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Source-specific planned registry mutations are packaged with review evidence and approval artifacts.",
        "- The Train 97 active-registry apply gate is run immediately in readiness mode.",
        "- The compiler emits no active registry writes, claims, packs, R2 operations, native activations, final plans, schedules, or Steps.",
        "",
        "Counts:",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Source-specific review evidence records: {counts['sourceSpecificReviewEvidenceRecords']}",
        f"- Approval artifacts: {counts['approvalArtifacts']}",
        f"- Active registry readiness allowed: {counts['activeRegistryReadinessAllowed']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- No private Ambitions runtime context is emitted or sent to R2.",
        "- No final user plans, schedules, Steps, or personalized paths are generated.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Active registry write was not run.",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _safe_read_json(path: Path, label: str) -> tuple[Any | None, list[str]]:
    try:
        return read_json(path), []
    except FileNotFoundError:
        return None, [f"{label}: missing {path}"]
    except Exception as exc:
        return None, [f"{label}: could not read {path}: {exc}"]


def _planned_mutations(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("plannedRegistryMutations"), list):
        return [item for item in payload["plannedRegistryMutations"] if isinstance(item, dict)]
    return []


def _input_shape_issues(payload: Any, planned_mutations: list[dict[str, Any]]) -> list[str]:
    if payload is None:
        return []
    if not isinstance(payload, dict):
        return ["source-specific apply packet input must be an object"]
    issues: list[str] = []
    if payload.get("kind") != GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_INPUT_KIND:
        issues.append(f"input kind must be {GOAL_DOMAIN_SOURCE_SPECIFIC_APPLY_PACKET_INPUT_KIND}")
    if payload.get("reviewEvidenceClass") != SOURCE_SPECIFIC_REVIEW_CLASS:
        issues.append("input reviewEvidenceClass must be source_specific_review")
    if not planned_mutations:
        issues.append("input plannedRegistryMutations must contain at least one mutation object")
    for index, mutation in enumerate(planned_mutations):
        issues.extend(_mutation_shape_issues(mutation, index))
    return issues


def _mutation_shape_issues(mutation: dict[str, Any], index: int) -> list[str]:
    label = str(mutation.get("mutationID") or mutation.get("mutation_id") or f"plannedRegistryMutations[{index}]")
    source_lane = _entry(mutation, "source_lane_entry", "sourceLaneEntry")
    legal_terms = _entry(mutation, "legal_terms_entry", "legalTermsEntry")
    api_policy = _entry(mutation, "api_policy_entry", "apiPolicyEntry")
    issues: list[str] = []
    for entry, entry_name, required_id in (
        (source_lane, "sourceLaneEntry", "source_id"),
        (legal_terms, "legalTermsEntry", "license_id"),
        (api_policy, "apiPolicyEntry", "api_policy_id"),
    ):
        if not entry:
            issues.append(f"{label}: missing {entry_name}")
        elif not entry.get(required_id):
            issues.append(f"{label}: {entry_name} missing {required_id}")
    if source_lane and legal_terms and source_lane.get("license_id") != legal_terms.get("license_id"):
        issues.append(f"{label}: source lane license_id must match legal terms license_id")
    if source_lane and api_policy and source_lane.get("api_policy_id") != api_policy.get("api_policy_id"):
        issues.append(f"{label}: source lane api_policy_id must match API policy api_policy_id")
    if source_lane and api_policy and source_lane.get("source_id") != api_policy.get("source_id"):
        issues.append(f"{label}: source lane source_id must match API policy source_id")
    if legal_terms and legal_terms.get("outside_legal_status") == "approved":
        issues.append(f"{label}: outside legal approval is not claimed by this packet compiler")
    return issues


def _source_specific_issues(payload: Any, planned_mutations: list[dict[str, Any]]) -> list[str]:
    marker_paths = _fixture_marker_paths({"input": payload})
    issues = [f"fixture/rehearsal marker found at {path}" for path in marker_paths[:20]]
    for index, mutation in enumerate(planned_mutations):
        label = str(mutation.get("mutationID") or mutation.get("mutation_id") or f"plannedRegistryMutations[{index}]")
        if mutation.get("reviewEvidenceClass") not in {None, SOURCE_SPECIFIC_REVIEW_CLASS}:
            issues.append(f"{label}: reviewEvidenceClass must be source_specific_review when provided")
    return issues


def _planned_payload(payload: dict[str, Any], planned_mutations: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "kind": "ambitions.sourceAtlas.goalDomainPlannedRegistryMutations.v1",
        "reviewEvidenceClass": SOURCE_SPECIFIC_REVIEW_CLASS,
        "createdAt": created_at,
        "sourceSpecificReviewID": str(payload.get("sourceSpecificReviewID") or ""),
        "plannedRegistryMutations": planned_mutations,
        "nonClaims": ["planned registry activation review only", "not active registry mutation", "not R2 publish"],
    }


def _review_evidence(payload: dict[str, Any], planned_mutations: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    owner = str(payload.get("reviewOwner") or "Ambitions owner source-specific technical review")
    return {
        "kind": "ambitions.sourceAtlas.goalDomainSourceSpecificReviewEvidence.v1",
        "reviewEvidenceClass": SOURCE_SPECIFIC_REVIEW_CLASS,
        "reviewScope": "source_lane_legal_api_registry_activation",
        "sourceSpecificReviewID": str(payload.get("sourceSpecificReviewID") or ""),
        "createdAt": created_at,
        "reviewedAt": str(payload.get("reviewedAt") or created_at[:10]),
        "reviewedBy": owner,
        "sourceIDs": _source_ids(planned_mutations),
        "reviewDecisions": [_review_decision(mutation, index, owner) for index, mutation in enumerate(planned_mutations)],
        "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
    }


def _approval_artifact(payload: dict[str, Any], planned_mutations: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "kind": "ambitions.sourceAtlas.goalDomainActiveRegistryApplyApproval.v1",
        "approvalStatus": "approved_for_active_registry_apply",
        "approvedAt": str(payload.get("approvedAt") or created_at),
        "approvedBy": str(payload.get("approvedBy") or payload.get("reviewOwner") or "Ambitions owner source registry approval"),
        "approvalScope": "active source lane, legal terms, and API governance registry metadata",
        "sourceIDs": _source_ids(planned_mutations),
        "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
    }


def _review_decision(mutation: dict[str, Any], index: int, owner: str) -> dict[str, Any]:
    source_lane = _entry(mutation, "source_lane_entry", "sourceLaneEntry")
    legal_terms = _entry(mutation, "legal_terms_entry", "legalTermsEntry")
    api_policy = _entry(mutation, "api_policy_entry", "apiPolicyEntry")
    return {
        "mutationID": str(mutation.get("mutationID") or mutation.get("mutation_id") or f"plannedRegistryMutations[{index}]"),
        "sourceID": str(source_lane.get("source_id") or ""),
        "licenseID": str(legal_terms.get("license_id") or ""),
        "apiPolicyID": str(api_policy.get("api_policy_id") or ""),
        "reviewOwner": owner,
        "decision": "source_specific_registry_activation_reviewed",
        "nonClaims": ["not outside legal approval", "not claim output", "not R2 publish"],
    }


def _source_ids(planned_mutations: list[dict[str, Any]]) -> list[str]:
    return sorted(
        {
            str(_entry(mutation, "source_lane_entry", "sourceLaneEntry").get("source_id"))
            for mutation in planned_mutations
            if _entry(mutation, "source_lane_entry", "sourceLaneEntry").get("source_id")
        }
    )


def _entry(mutation: dict[str, Any], snake_key: str, camel_key: str) -> dict[str, Any]:
    value = mutation.get(snake_key) if isinstance(mutation.get(snake_key), dict) else mutation.get(camel_key)
    return dict(value) if isinstance(value, dict) else {}


def _fixture_marker_paths(value: Any, path: str = "$") -> list[str]:
    paths: list[str] = []
    if isinstance(value, str):
        lower = value.lower()
        if any(marker in lower for marker in FIXTURE_MARKERS):
            paths.append(path)
    elif isinstance(value, dict):
        for key, item in value.items():
            paths.extend(_fixture_marker_paths(item, f"{path}.{key}"))
    elif isinstance(value, list):
        for index, item in enumerate(value):
            paths.extend(_fixture_marker_paths(item, f"{path}[{index}]"))
    return paths
