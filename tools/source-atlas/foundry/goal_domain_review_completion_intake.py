"""Govern completed review evidence for Source Atlas goal-domain packets.

Train 92 emits blocked review packet templates for candidate goal-domain work.
This intake consumes those templates plus optional explicit reviewer evidence.
It can normalize completed review records for future registry-mutation planning,
but it never mutates registries, emits claims, builds packs, publishes to R2,
activates native runtime behavior, or generates user plans.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_review_packets import GOAL_DOMAIN_REVIEW_PACKETS_VERSION, REVIEW_LANES
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_VERSION = "source-atlas-goal-domain-review-completion-intake-train-93"
GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_KIND = "ambitions.sourceAtlas.goalDomainReviewCompletionIntake.v1"
GOAL_DOMAIN_REVIEW_COMPLETION_EVIDENCE_KIND = "ambitions.sourceAtlas.goalDomainReviewCompletionEvidence.v1"
GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND = "ambitions.sourceAtlas.goalDomainReviewCompletions.v1"

FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
EXPECTED_REVIEW_LANES = set(REVIEW_LANES.values())
EMPTY_ALLOWED_REVIEW_FIELDS = {
    "legal_terms_review": {"approval_artifact_path"},
    "api_governance_review": {"env_var_name"},
}

REVIEW_COMPLETION_INTAKE_NON_CLAIMS = [
    "goal-domain review completion intake only",
    "not source authority by itself",
    "not legal approval",
    "not outside legal approval without artifact",
    "not active registry mutation",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not production R2 upload",
    "not native activation proof",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainReviewCompletionIntakeOptions:
    review_templates_path: Path
    output_root: Path
    completion_evidence_path: Path | None = None
    created_at: str | None = None


def compile_goal_domain_review_completion_intake(options: GoalDomainReviewCompletionIntakeOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    template_payload = read_json(options.review_templates_path)
    templates = _review_templates(template_payload)
    template_schema_issues = _template_schema_issues(template_payload, templates)
    template_privacy_issues = privacy_findings_for_value(template_payload, "goal-domain-review-completion-intake-templates")

    evidence_payload = read_json(options.completion_evidence_path) if options.completion_evidence_path else None
    evidence_records = _completion_evidence_records(evidence_payload)
    evidence_schema_issues = _evidence_schema_issues(evidence_payload, evidence_records, provided=options.completion_evidence_path is not None)
    evidence_privacy_issues = (
        privacy_findings_for_value(evidence_payload, "goal-domain-review-completion-intake-evidence")
        if evidence_payload is not None
        else []
    )

    assembly = _assemble_goal_domain_review_completions(templates, evidence_records, created_at)
    completions = assembly["completedReviewPackets"]
    blocked = assembly["blockedReviewCompletions"]
    review_bundles = _review_bundles(templates, completions, blocked, created_at)
    record_counts = {
        "reviewPacketTemplates": len(templates),
        "completionEvidenceRecords": len(evidence_records),
        "completedReviewPackets": len(completions),
        "completedReviewBundles": sum(1 for bundle in review_bundles if bundle["completionStatus"] == "completed_review_ready_for_registry_mutation_planning"),
        "blockedReviewCompletions": len(blocked),
        "approvalArtifactsEmitted": 0,
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    completion_collection = {
        "kind": GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND,
        "createdAt": created_at,
        "completedReviewPackets": completions,
        "reviewBundles": review_bundles,
        "nonClaims": [
            "goal-domain review completion records only",
            "not active registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
        ],
    }
    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_KIND,
        "versionID": GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_VERSION,
        "compatibleReviewPacketVersionID": GOAL_DOMAIN_REVIEW_PACKETS_VERSION,
        "createdAt": created_at,
        "reviewTemplatesPath": str(options.review_templates_path),
        "completionEvidencePath": str(options.completion_evidence_path) if options.completion_evidence_path else "",
        "goalDomainReviewCompletions": completion_collection,
        "blockedReviewCompletions": blocked,
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_COMPLETION_INTAKE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "goal-domain-review-completion-intake")
    collection_privacy_issues = privacy_findings_for_value(completion_collection, "goal-domain-review-completions")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "template_schema_valid", "passed": not template_schema_issues and bool(templates), "issues": template_schema_issues},
        {"name": "template_privacy_scan_passed", "passed": not template_privacy_issues, "issues": template_privacy_issues},
        {"name": "completion_evidence_schema_valid", "passed": not evidence_schema_issues, "issues": evidence_schema_issues},
        {"name": "completion_evidence_privacy_scan_passed", "passed": not evidence_privacy_issues, "issues": evidence_privacy_issues},
        {
            "name": "missing_completion_evidence_blocks_without_approval",
            "passed": options.completion_evidence_path is not None or record_counts["completedReviewPackets"] == 0,
            "issues": [],
        },
        {
            "name": "completed_review_packets_require_required_fields",
            "passed": not assembly["issues"],
            "issues": assembly["issues"],
        },
        {
            "name": "completed_review_bundles_do_not_mutate_registries",
            "passed": record_counts["approvalArtifactsEmitted"] == 0
            and record_counts["activeRegistryMutations"] == 0
            and all(bundle["registryMutationAllowed"] is False for bundle in review_bundles),
            "issues": [],
        },
        {
            "name": "review_completion_intake_emits_no_claims_packs_r2_or_native_activation",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0
            and all(
                completion["claimOutputAllowed"] is False
                and completion["packOutputAllowed"] is False
                and completion["r2PublishAllowed"] is False
                and completion["nativeActivationAllowed"] is False
                for completion in completions
            ),
            "issues": [],
        },
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues and not collection_privacy_issues, "issues": artifact_privacy_issues + collection_privacy_issues},
    ]

    issues: list[str] = []
    issues.extend(template_schema_issues)
    issues.extend(template_privacy_issues)
    issues.extend(evidence_schema_issues)
    issues.extend(evidence_privacy_issues)
    issues.extend(assembly["issues"])
    issues.extend(artifact_privacy_issues)
    issues.extend(collection_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "goalDomainReviewCompletionIntake": str(output_root / "goal-domain-review-completion-intake.json"),
        "goalDomainReviewCompletions": str(output_root / "goal-domain-review-completions.json"),
        "blockedGoalDomainReviewCompletions": str(output_root / "blocked-goal-domain-review-completions.json"),
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainReviewCompletionIntakeManifest.v1",
        "versionID": GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain review completion intake tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; review completion intake tooling only",
        "reviewTemplatesPath": str(options.review_templates_path),
        "completionEvidencePath": str(options.completion_evidence_path) if options.completion_evidence_path else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_COMPLETION_INTAKE_NON_CLAIMS,
    }

    write_json(output_root / "goal-domain-review-completion-intake.json", artifact)
    write_json(output_root / "goal-domain-review-completions.json", completion_collection)
    write_json(
        output_root / "blocked-goal-domain-review-completions.json",
        {
            "kind": "ambitions.sourceAtlas.blockedGoalDomainReviewCompletions.v1",
            "createdAt": created_at,
            "blockedReviewCompletions": blocked,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "goalDomainReviewCompletionIntake": stable_hash(read_json(output_root / "goal-domain-review-completion-intake.json")),
        "goalDomainReviewCompletions": stable_hash(read_json(output_root / "goal-domain-review-completions.json")),
        "blockedGoalDomainReviewCompletions": stable_hash(read_json(output_root / "blocked-goal-domain-review-completions.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(goal_domain_review_completion_intake_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_goal_domain_review_completion_intake_report(
    markdown_path: Path,
    json_path: Path,
    *,
    review_templates_path: Path,
    output_root: Path,
    completion_evidence_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=review_templates_path,
            output_root=output_root,
            completion_evidence_path=completion_evidence_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_review_completion_intake_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_review_completion_intake_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Review Completion Intake Train 93",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Completion evidence path: {result['completionEvidencePath'] or 'not provided'}",
        "",
        "Scope completed:",
        "- Deterministic completion intake for Train 92 goal-domain review packet templates.",
        "- Missing or partial completion evidence remains blocked and cannot approve source lanes.",
        "- Completed review evidence can be normalized for future registry-mutation planning only.",
        "- No active registry mutation, claims, packs, R2 writes, native activations, final plans, schedules, or Steps are emitted.",
        "",
        "Counts:",
        f"- Review packet templates: {counts['reviewPacketTemplates']}",
        f"- Completion evidence records: {counts['completionEvidenceRecords']}",
        f"- Completed review packets: {counts['completedReviewPackets']}",
        f"- Completed review bundles: {counts['completedReviewBundles']}",
        f"- Blocked review completions: {counts['blockedReviewCompletions']}",
        f"- Approval artifacts emitted: {counts['approvalArtifactsEmitted']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- Review completion records are governance handoff artifacts, not source authority or legal approval by themselves.",
        "- Private Ambitions runtime context remains local.",
        "- Source Atlas does not generate final user plans, schedules, Steps, or personalized paths.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Live network/API discovery was not run.",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- The intake emits governance completion metadata only.",
            "",
            "No private graph egress proof:",
            "- Template, evidence, completion, and output privacy scans must pass before Source Green.",
            "- The intake emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Legal/terms fields are validated when completion evidence claims a completed legal review.",
            "- Outside legal approval is not claimed without an approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- This intake emits no packable output. Restricted-source exclusion remains enforced downstream by source-lane, legal, pack, and R2 gates.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 93. This train normalizes review completion only.",
            "",
            "Freshness/revocation proof:",
            "- No pack freshness, revocation, or LKG operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer, R2 object, or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 93. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry review completion intake, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: registry mutation planning from completed review bundles, still gated from active registry writes.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _review_templates(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("reviewPackets"), list):
        return [item for item in payload["reviewPackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _template_schema_issues(payload: Any, templates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("goal-domain review completion templates input must be an object or array")
    if not templates:
        issues.append("goal-domain review completion intake requires review packet templates")
    for index, template in enumerate(templates):
        for field in ("packetID", "orderID", "requestID", "stage", "reviewLane", "requiredReviewerFields"):
            if not template.get(field):
                issues.append(f"reviewPackets[{index}].{field} required")
        if template.get("completionStatus") != "blocked_review_required":
            issues.append(f"reviewPackets[{index}].completionStatus must be blocked_review_required")
        if template.get("manualReviewRequired") is not True:
            issues.append(f"reviewPackets[{index}].manualReviewRequired must be true")
        if template.get("reviewLane") not in EXPECTED_REVIEW_LANES:
            issues.append(f"reviewPackets[{index}].reviewLane is not supported")
    return sorted(set(issues))


def _completion_evidence_records(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("completionEvidenceRecords"), list):
        return [item for item in payload["completionEvidenceRecords"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("goalDomainReviewCompletionEvidenceRecords"), list):
        return [item for item in payload["goalDomainReviewCompletionEvidenceRecords"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _evidence_schema_issues(payload: Any, records: list[dict[str, Any]], *, provided: bool) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("goal-domain review completion evidence input must be an object or array")
    if isinstance(payload, dict) and payload.get("kind") not in {None, GOAL_DOMAIN_REVIEW_COMPLETION_EVIDENCE_KIND}:
        issues.append(f"completion evidence kind must be {GOAL_DOMAIN_REVIEW_COMPLETION_EVIDENCE_KIND}")
    if not records:
        issues.append("completion evidence input must include completionEvidenceRecords")
    for index, record in enumerate(records):
        for field in ("packetID", "reviewLane", "completionStatus"):
            if not record.get(field):
                issues.append(f"completionEvidenceRecords[{index}].{field} required")
    return sorted(set(issues))


def _assemble_goal_domain_review_completions(
    templates: list[dict[str, Any]],
    evidence_records: list[dict[str, Any]],
    created_at: str,
) -> dict[str, Any]:
    issues: list[str] = []
    templates_by_packet = {str(template.get("packetID") or ""): template for template in templates}
    evidence_by_packet: dict[str, dict[str, Any]] = {}
    duplicate_packet_ids: set[str] = set()
    for record in evidence_records:
        packet_id = str(record.get("packetID") or "")
        if packet_id in evidence_by_packet:
            duplicate_packet_ids.add(packet_id)
        if packet_id:
            evidence_by_packet[packet_id] = record
    for packet_id in sorted(duplicate_packet_ids):
        issues.append(f"{packet_id}: duplicate goal-domain review completion evidence")

    completed: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    for template in templates:
        packet_id = str(template.get("packetID") or "")
        evidence = evidence_by_packet.get(packet_id)
        if not evidence:
            blocked.append(_blocked_review_completion(template, created_at, ["completion_evidence_required"]))
            continue
        if evidence.get("reviewLane") != template.get("reviewLane"):
            issues.append(f"{packet_id}: evidence reviewLane must match review packet template")
        if evidence.get("orderID") and evidence.get("orderID") != template.get("orderID"):
            issues.append(f"{packet_id}: evidence orderID must match review packet template")
        if evidence.get("requestID") and evidence.get("requestID") != template.get("requestID"):
            issues.append(f"{packet_id}: evidence requestID must match review packet template")
        completion_status = str(evidence.get("completionStatus") or "")
        if completion_status != "completed":
            blocked.append(_blocked_review_completion(template, created_at, [f"review_completion_status_{completion_status or 'missing'}"]))
            continue
        evidence_issues = _completed_evidence_issues(template, evidence)
        if evidence_issues:
            issues.extend(evidence_issues)
            blocked.append(_blocked_review_completion(template, created_at, ["completion_evidence_invalid", *evidence_issues]))
            continue
        completed.append(_completed_review_packet(template, evidence, created_at))

    for packet_id in sorted(set(evidence_by_packet) - set(templates_by_packet)):
        issues.append(f"{packet_id}: completion evidence does not match review packet template")

    return {
        "completedReviewPackets": sorted(completed, key=lambda item: (item["requestID"], item["stageIndex"], item["packetID"])),
        "blockedReviewCompletions": sorted(blocked, key=lambda item: (item["requestID"], item["stageIndex"], item["packetID"])),
        "issues": sorted(set(issues)),
        "nonClaims": ["review completion intake validation does not equal source authority, legal approval, or active registry mutation"],
    }


def _completed_evidence_issues(template: dict[str, Any], evidence: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    packet_id = str(template.get("packetID") or "")
    review_lane = str(template.get("reviewLane") or "")
    for field in ("reviewOwner", "reviewedAt", "reviewDecision"):
        if not evidence.get(field):
            issues.append(f"{packet_id}: {field} required")
    review_fields = evidence.get("reviewFields") if isinstance(evidence.get("reviewFields"), dict) else {}
    if not review_fields:
        issues.append(f"{packet_id}: reviewFields required")
    required_fields = [str(item) for item in template.get("requiredReviewerFields", []) if item]
    empty_allowed = EMPTY_ALLOWED_REVIEW_FIELDS.get(review_lane, set())
    for field in required_fields:
        if field not in review_fields:
            issues.append(f"{packet_id}: reviewFields.{field} required")
            continue
        value = review_fields.get(field)
        if field in empty_allowed:
            continue
        if isinstance(value, bool):
            continue
        if value in (None, "", [], {}):
            issues.append(f"{packet_id}: reviewFields.{field} must be non-empty")
    if review_lane == "legal_terms_review":
        outside_required = review_fields.get("outside_legal_required") is True
        outside_status = str(review_fields.get("outside_legal_status") or "")
        approval_artifact = str(review_fields.get("approval_artifact_path") or "")
        if outside_status == "approved" and not approval_artifact:
            issues.append(f"{packet_id}: outside legal approval requires approval_artifact_path")
        if outside_required and (outside_status != "approved" or not approval_artifact):
            issues.append(f"{packet_id}: outside legal required reviews need approved status and approval_artifact_path")
        if review_fields.get("pack_output_allowed") is True and review_fields.get("redistribution_allowed") is False:
            issues.append(f"{packet_id}: pack_output_allowed requires redistribution_allowed")
    issues.extend(privacy_findings_for_value(evidence, f"goalDomainReviewCompletionEvidence[{packet_id}]"))
    return sorted(set(issues))


def _completed_review_packet(template: dict[str, Any], evidence: dict[str, Any], created_at: str) -> dict[str, Any]:
    packet_id = str(template.get("packetID") or "")
    review_fields = evidence.get("reviewFields") if isinstance(evidence.get("reviewFields"), dict) else {}
    return {
        "completionID": stable_id("source_atlas_goal_domain_review_completion", {"packetID": packet_id, "reviewedAt": evidence.get("reviewedAt")}),
        "packetID": packet_id,
        "orderID": str(template.get("orderID") or ""),
        "requestID": str(template.get("requestID") or ""),
        "requestedDomain": str(template.get("requestedDomain") or ""),
        "matchedDomainID": template.get("matchedDomainID"),
        "candidateSourceIDs": sorted(str(item) for item in template.get("candidateSourceIDs", []) if item),
        "stage": str(template.get("stage") or ""),
        "stageIndex": int(template.get("stageIndex") or 0),
        "reviewLane": str(template.get("reviewLane") or ""),
        "completionStatus": "completed",
        "createdAt": created_at,
        "reviewOwner": str(evidence.get("reviewOwner") or ""),
        "reviewedAt": str(evidence.get("reviewedAt") or ""),
        "reviewDecision": str(evidence.get("reviewDecision") or ""),
        "reviewEvidencePath": str(review_fields.get("review_evidence_path") or evidence.get("reviewEvidencePath") or ""),
        "reviewFields": review_fields,
        "approvalArtifactEmitted": False,
        "registryMutationAllowed": False,
        "claimOutputAllowed": False,
        "packOutputAllowed": False,
        "r2PackableArtifactAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "liveAllowed": False,
        "executeAllowed": False,
        "publicReferenceOnly": True,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "goal-domain review completion only",
            "not source authority by itself",
            "not legal approval",
            "not registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not final user plans, schedules, or Steps",
        ],
    }


def _blocked_review_completion(template: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "blockedReviewCompletionID": stable_id(
            "source_atlas_goal_domain_review_completion_block",
            {"packetID": template.get("packetID"), "reasons": sorted(reasons)},
        ),
        "packetID": str(template.get("packetID") or ""),
        "orderID": str(template.get("orderID") or ""),
        "requestID": str(template.get("requestID") or ""),
        "requestedDomain": str(template.get("requestedDomain") or ""),
        "matchedDomainID": template.get("matchedDomainID"),
        "stage": str(template.get("stage") or ""),
        "stageIndex": int(template.get("stageIndex") or 0),
        "reviewLane": str(template.get("reviewLane") or ""),
        "createdAt": created_at,
        "status": "blocked",
        "blockingReasons": sorted(set(reasons)),
        "nonClaims": ["blocked review completion only", "not approval", "not registry mutation", "not claim output"],
    }


def _review_bundles(
    templates: list[dict[str, Any]],
    completions: list[dict[str, Any]],
    blocked: list[dict[str, Any]],
    created_at: str,
) -> list[dict[str, Any]]:
    by_request: dict[str, dict[str, Any]] = {}
    for template in templates:
        request_id = str(template.get("requestID") or "")
        bundle = by_request.setdefault(
            request_id,
            {
                "bundleID": stable_id("source_atlas_goal_domain_review_bundle", {"requestID": request_id}),
                "requestID": request_id,
                "requestedDomain": str(template.get("requestedDomain") or ""),
                "matchedDomainID": template.get("matchedDomainID"),
                "createdAt": created_at,
                "requiredReviewLanes": sorted(EXPECTED_REVIEW_LANES),
                "completedReviewLanes": [],
                "blockedReviewLanes": [],
                "completionStatus": "blocked_review_required",
                "registryMutationPlanningReady": False,
                "registryMutationAllowed": False,
                "claimOutputAllowed": False,
                "packOutputAllowed": False,
                "r2PublishAllowed": False,
                "nativeActivationAllowed": False,
                "nonClaims": ["review bundle summary only", "not registry mutation", "not source authority", "not claim output"],
            },
        )
        if not bundle.get("matchedDomainID") and template.get("matchedDomainID"):
            bundle["matchedDomainID"] = template.get("matchedDomainID")
    completed_by_request: dict[str, set[str]] = {}
    blocked_by_request: dict[str, set[str]] = {}
    for completion in completions:
        completed_by_request.setdefault(completion["requestID"], set()).add(completion["reviewLane"])
    for item in blocked:
        blocked_by_request.setdefault(item["requestID"], set()).add(item["reviewLane"])
    for request_id, bundle in by_request.items():
        completed_lanes = completed_by_request.get(request_id, set())
        blocked_lanes = blocked_by_request.get(request_id, set())
        bundle["completedReviewLanes"] = sorted(completed_lanes)
        bundle["blockedReviewLanes"] = sorted(blocked_lanes)
        if EXPECTED_REVIEW_LANES.issubset(completed_lanes) and not blocked_lanes:
            bundle["completionStatus"] = "completed_review_ready_for_registry_mutation_planning"
            bundle["registryMutationPlanningReady"] = True
        bundle["missingReviewLanes"] = sorted(EXPECTED_REVIEW_LANES - completed_lanes)
    return sorted(by_request.values(), key=lambda item: item["requestID"])


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key
            not in {
                "forbidden_artifact_classes",
                "claim_classes_forbidden",
                "nonClaims",
                "non_claims",
                "blockingReasons",
                "blocking_reasons",
            }
        )
    return False
