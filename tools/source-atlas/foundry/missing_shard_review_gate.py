"""Review/legal/API gate for Source Atlas missing-shard queue events.

This compiler defines the only dry-run path from a durable missing-shard queue
item to a registry mutation plan. It never mutates active registries, never
emits claims/packs/R2 objects/native activations, and stores only
public/reference governance metadata.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .governance_registry import (
    API_GOVERNANCE_REGISTRY_PATH,
    LEGAL_TERMS_REGISTRY_PATH,
    SOURCE_LANE_REGISTRY_PATH,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_MISSING_SHARD_REVIEW_GATE_KIND = "ambitions.sourceAtlas.missingShardReviewGate.v1"
SOURCE_ATLAS_MISSING_SHARD_REVIEW_GATE_VERSION = "source-atlas-missing-shard-review-gate-lff-m04-l02"
MISSING_SHARD_REVIEW_APPROVAL_KIND = "ambitions.sourceAtlas.missingShardReviewApproval.v1"

APPROVED_STATUS = "approved_for_registry_mutation_planning"
BLOCKED_PENDING_APPROVAL_STATUS = "blocked_pending_review_legal_api_approval"
BLOCKED_INVALID_APPROVAL_STATUS = "blocked_invalid_approval_artifact"
BLOCKED_NOT_SELECTED_STATUS = "blocked_not_selected_by_approval_artifact"

REQUIRED_GATE_DECISIONS = {
    "publicReferenceClassification": "passed",
    "sourceLaneReview": "approved",
    "legalTermsReview": "approved",
    "apiPolicyReview": "approved",
    "noPrivateDataScan": "passed",
}

FORBIDDEN_REVIEW_GATE_CLAIMS = {
    "active_registry_mutation",
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "release_green",
    "outside_legal_approval",
    "r2_promotion_proof",
    "native_activation_proof",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "private_life_graph_in_source_atlas_or_r2",
}

REVIEW_GATE_NON_CLAIMS = [
    "review/legal/API gate and dry-run mutation planning only",
    "not active registry mutation",
    "not source authority without a later active registry apply train",
    "not outside legal approval unless an outside legal artifact is present",
    "not claim output",
    "not pack output",
    "not harvest execution",
    "not R2 publication or promotion proof",
    "not native activation proof",
    "not launch-floor complete",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class MissingShardReviewGateOptions:
    missing_shard_queue_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    approval_artifact_path: Path | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    execute: bool = False
    allow_active_registry_write: bool = False
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"


def compile_missing_shard_review_gate(options: MissingShardReviewGateOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    queue_payload, queue_load_issues = _read_required(options.missing_shard_queue_path, "missing-shard queue")
    approval_payload, approval_load_issues = _read_optional(options.approval_artifact_path, "missing-shard review approval")
    source_registry, source_registry_issues = _read_required(
        options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH,
        "source-lane registry",
    )
    legal_registry, legal_registry_issues = _read_required(
        options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH,
        "legal/terms registry",
    )
    api_registry, api_registry_issues = _read_required(
        options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH,
        "API governance registry",
    )

    queue_events = _queue_events(queue_payload)
    queue_shape_issues = _queue_shape_issues(queue_payload, queue_events)
    queue_event_issues_by_id = {
        str(event.get("eventID")): _queue_event_issues(event, index)
        for index, event in enumerate(queue_events)
        if isinstance(event, dict) and event.get("eventID")
    }
    input_privacy_issues = privacy_findings_for_value(
        {
            "missingShardQueue": queue_payload,
            "approvalArtifact": approval_payload,
            "registryPaths": _target_paths(options),
        },
        "missing-shard-review-gate-input",
    )
    approval_privacy_issues = (
        privacy_findings_for_value(approval_payload, "missing-shard-review-approval")
        if approval_payload is not None
        else []
    )
    approval_validation = _validate_approval(approval_payload, queue_events, options.approval_artifact_path)
    if approval_privacy_issues and approval_validation["approvalArtifactProvided"]:
        approval_validation = {
            **approval_validation,
            "valid": False,
            "issues": sorted(set([*approval_validation.get("issues", []), *approval_privacy_issues])),
        }
    approval_global_issues = (
        approval_validation["issues"]
        if approval_validation["approvalArtifactProvided"] and not approval_validation["valid"]
        else []
    )

    approval_entries_by_event = {
        entry["eventID"]: entry
        for entry in approval_validation.get("approvedEvents", [])
        if isinstance(entry, dict) and isinstance(entry.get("eventID"), str)
    }
    gate_decisions: list[dict[str, Any]] = []
    planned_mutations: list[dict[str, Any]] = []
    blocked_mutations: list[dict[str, Any]] = []
    rejected_events: list[dict[str, Any]] = []

    for event in queue_events:
        event_id = str(event.get("eventID") or "")
        event_issues = queue_event_issues_by_id.get(event_id, [])
        approval_entry = approval_entries_by_event.get(event_id)
        entry_issues = approval_validation.get("entryIssuesByEventID", {}).get(event_id, [])
        decision = _gate_decision(
            event=event,
            event_issues=event_issues,
            approval_entry=approval_entry,
            entry_issues=entry_issues,
            approval_validation=approval_validation,
            created_at=options.created_at,
        )
        gate_decisions.append(decision)
        if decision["gateStatus"] == APPROVED_STATUS and approval_entry is not None:
            planned_mutations.append(_planned_mutation(event, approval_entry, created_at=options.created_at))
        else:
            blocked_mutations.append(_blocked_mutation(event, decision, created_at=options.created_at))
        if decision["gateStatus"] == "rejected_lawful_no_public_source":
            rejected_events.append(_rejected_event(event, decision, created_at=options.created_at))

    active_registry_mutations: list[dict[str, Any]] = []
    active_write_issues = []
    if options.execute:
        active_write_issues.append("missing-shard review gate never executes active registry writes; use a later active apply train")
    if options.allow_active_registry_write:
        active_write_issues.append("allow_active_registry_write is ignored by missing-shard review gate")

    record_counts = {
        "queuedEvents": len(queue_events),
        "gateDecisions": len(gate_decisions),
        "approvedEvents": sum(1 for item in gate_decisions if item["gateStatus"] == APPROVED_STATUS),
        "blockedEvents": sum(1 for item in gate_decisions if item["gateStatus"].startswith("blocked")),
        "rejectedEvents": len(rejected_events),
        "plannedRegistryMutations": len(planned_mutations),
        "blockedRegistryMutations": len(blocked_mutations),
        "activeRegistryMutations": len(active_registry_mutations),
        "coverageCounterMutations": 0,
        "sourceLaneReviewsApproved": sum(1 for item in gate_decisions if item["gateDecisions"].get("sourceLaneReview") == "approved"),
        "legalTermsReviewsApproved": sum(1 for item in gate_decisions if item["gateDecisions"].get("legalTermsReview") == "approved"),
        "apiPolicyReviewsApproved": sum(1 for item in gate_decisions if item["gateDecisions"].get("apiPolicyReview") == "approved"),
        "noPrivateDataScansPassed": sum(1 for item in gate_decisions if item["gateDecisions"].get("noPrivateDataScan") == "passed"),
        "finalOutputArtifacts": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
    }
    output_paths = {
        "report": str(output_root / "missing-shard-review-gate.json"),
        "gateDecisions": str(output_root / "gate-decisions.json"),
        "plannedRegistryMutations": str(output_root / "planned-registry-mutations.json"),
        "blockedRegistryMutations": str(output_root / "blocked-registry-mutations.json"),
        "rejectedEvents": str(output_root / "rejected-events.json"),
        "activeRegistryMutations": str(output_root / "active-registry-mutations.json"),
        "approvalTemplate": str(output_root / "approval-template.json"),
        "closeout": str(output_root / "closeout.md"),
        "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
        "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
    }
    approval_template = _approval_template(queue_events, options.created_at)
    checks = _checks(
        queue_load_issues=queue_load_issues,
        queue_shape_issues=queue_shape_issues,
        queue_event_issues_by_id=queue_event_issues_by_id,
        registry_issues=source_registry_issues + legal_registry_issues + api_registry_issues,
        input_privacy_issues=input_privacy_issues,
        approval_privacy_issues=approval_privacy_issues,
        approval_global_issues=approval_global_issues,
        active_write_issues=active_write_issues,
        record_counts=record_counts,
        planned_mutations=planned_mutations,
    )
    issues: list[str] = []
    issues.extend(queue_load_issues)
    issues.extend(queue_shape_issues)
    issues.extend(source_registry_issues)
    issues.extend(legal_registry_issues)
    issues.extend(api_registry_issues)
    issues.extend(input_privacy_issues)
    issues.extend(approval_privacy_issues)
    issues.extend(approval_global_issues)
    issues.extend(active_write_issues)
    for event_issues in queue_event_issues_by_id.values():
        issues.extend(event_issues)
    artifact = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_MISSING_SHARD_REVIEW_GATE_KIND,
        "versionID": SOURCE_ATLAS_MISSING_SHARD_REVIEW_GATE_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "gateID": stable_id(
            "source_atlas.missing_shard_review_gate",
            {
                "queue": str(options.missing_shard_queue_path),
                "approval": str(options.approval_artifact_path) if options.approval_artifact_path else "",
                "recordCounts": record_counts,
            },
        ),
        "valid": False,
        "status": "Red",
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; review/legal/API gate only",
        "missingShardQueuePath": str(options.missing_shard_queue_path),
        "approvalArtifactPath": str(options.approval_artifact_path) if options.approval_artifact_path else "",
        "approvalValidation": approval_validation,
        "executeRequested": options.execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "activeRegistryApplyAllowed": False,
        "targetRegistryPaths": _target_paths(options),
        "recordCounts": record_counts,
        "gateDecisions": gate_decisions,
        "plannedRegistryMutations": planned_mutations,
        "blockedRegistryMutations": blocked_mutations,
        "rejectedEvents": rejected_events,
        "activeRegistryMutations": active_registry_mutations,
        "approvalTemplate": approval_template,
        "lffM00Counters": {
            "missingShardEventsWithReviewGateDecision": len(gate_decisions),
            "missingShardEventsApprovedForMutationPlanning": record_counts["approvedEvents"],
            "missingShardEventsBlockedOrRejectedWithoutCoverageCredit": record_counts["blockedEvents"] + record_counts["rejectedEvents"],
            "coverageCounterMutations": 0,
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *approval_privacy_issues])),
        "allowedClaims": _allowed_claims(record_counts),
        "blockedClaims": sorted(FORBIDDEN_REVIEW_GATE_CLAIMS),
        "nonClaims": REVIEW_GATE_NON_CLAIMS,
        "evidencePaths": {
            "missingShardQueue": str(options.missing_shard_queue_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH),
            "legalTermsRegistry": str(options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH),
            "apiGovernanceRegistry": str(options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH),
            "approvalArtifact": str(options.approval_artifact_path) if options.approval_artifact_path else None,
        },
        "outputPaths": output_paths,
    }
    artifact_privacy_issues = privacy_findings_for_value(
        {
            "gateDecisions": gate_decisions,
            "plannedRegistryMutations": planned_mutations,
            "blockedRegistryMutations": blocked_mutations,
            "rejectedEvents": rejected_events,
            "approvalTemplate": approval_template,
        },
        "missing-shard-review-gate-output",
    )
    artifact["privacyIssues"] = sorted(set([*artifact["privacyIssues"], *artifact_privacy_issues]))
    artifact["issues"] = sorted(set([*artifact["issues"], *artifact_privacy_issues]))
    valid = not artifact["issues"] and all(check["passed"] for check in artifact["checks"])
    artifact["valid"] = valid
    artifact["status"] = _status(valid, record_counts)

    write_json(output_root / "gate-decisions.json", {"kind": "ambitions.sourceAtlas.missingShardGateDecisions.v1", "createdAt": options.created_at, "gateDecisions": gate_decisions})
    write_json(output_root / "planned-registry-mutations.json", {"kind": "ambitions.sourceAtlas.missingShardPlannedRegistryMutations.v1", "createdAt": options.created_at, "plannedRegistryMutations": planned_mutations})
    write_json(output_root / "blocked-registry-mutations.json", {"kind": "ambitions.sourceAtlas.missingShardBlockedRegistryMutations.v1", "createdAt": options.created_at, "blockedRegistryMutations": blocked_mutations})
    write_json(output_root / "rejected-events.json", {"kind": "ambitions.sourceAtlas.missingShardRejectedEvents.v1", "createdAt": options.created_at, "rejectedEvents": rejected_events})
    write_json(output_root / "active-registry-mutations.json", {"kind": "ambitions.sourceAtlas.missingShardActiveRegistryMutations.v1", "createdAt": options.created_at, "activeRegistryMutations": active_registry_mutations})
    write_json(output_root / "approval-template.json", approval_template)
    write_json(output_root / "missing-shard-review-gate.json", artifact)
    artifact["outputHashes"] = {
        "gateDecisions": stable_hash(read_json(output_root / "gate-decisions.json")),
        "plannedRegistryMutations": stable_hash(read_json(output_root / "planned-registry-mutations.json")),
        "blockedRegistryMutations": stable_hash(read_json(output_root / "blocked-registry-mutations.json")),
        "rejectedEvents": stable_hash(read_json(output_root / "rejected-events.json")),
        "activeRegistryMutations": stable_hash(read_json(output_root / "active-registry-mutations.json")),
        "approvalTemplate": stable_hash(read_json(output_root / "approval-template.json")),
        "report": stable_hash(read_json(output_root / "missing-shard-review-gate.json")),
    }
    markdown = missing_shard_review_gate_markdown(artifact)
    artifact["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(output_root / "missing-shard-review-gate.json", artifact)
    (output_root / "closeout.md").write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, artifact)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return artifact


def missing_shard_review_gate_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Missing-Shard Review Gate LFF-M04-L02",
        "",
        f"Status: {report['status']}",
        f"Valid: {str(report['valid']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Execute requested: {report['executeRequested']}",
        f"Allow active registry write: {report['allowActiveRegistryWrite']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Queue events reviewed: {counts['queuedEvents']}",
        f"- Gate decisions: {counts['gateDecisions']}",
        f"- Approved for dry-run registry mutation planning: {counts['approvedEvents']}",
        f"- Blocked events: {counts['blockedEvents']}",
        f"- Rejected events: {counts['rejectedEvents']}",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Coverage counter mutations: {counts['coverageCounterMutations']}",
        f"- Claims/packs/R2/native activations: {counts['claims']}/{counts['packableClaims']}/{counts['r2PublishOperations']}/{counts['nativeActivationOperations']}",
        "",
        "## Checks",
        "",
    ]
    for check in report["checks"]:
        lines.append(f"- `{check['name']}`: {'PASS' if check['passed'] else 'FAIL'}")
    lines.extend(["", "## Product Law Preserved", ""])
    lines.extend(
        [
            "- Active registries are not mutated by this gate.",
            "- Candidate events stay blocked until public/reference, source-lane, legal/terms, API, no-private-data, and required owner gates pass.",
            "- Blocked or rejected events do not affect launch-floor coverage counters.",
            "- Source Atlas/R2 receive no private goals, captures, schedules, proof, receipts, personalization, behavior history, account IDs, device IDs, or private life graph.",
            "- No claims, packs, R2 objects, native activations, final plans, schedules, or Steps are emitted.",
        ]
    )
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    if report["issues"]:
        lines.extend(["", "## Issues", ""])
        lines.extend(f"- {issue}" for issue in report["issues"])
    return "\n".join(lines) + "\n"


def _queue_events(queue_payload: Any) -> list[dict[str, Any]]:
    if not isinstance(queue_payload, dict):
        return []
    events = queue_payload.get("events") or []
    if not isinstance(events, list):
        return []
    return [event for event in events if isinstance(event, dict)]


def _queue_shape_issues(queue_payload: Any, queue_events: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(queue_payload, dict):
        issues.append("missing-shard queue must be a JSON object")
    elif queue_payload.get("kind") != "ambitions.sourceAtlas.missingShardEventQueue.v1":
        issues.append("missing-shard queue kind must be ambitions.sourceAtlas.missingShardEventQueue.v1")
    if not queue_events:
        issues.append("missing-shard queue must include events")
    return issues


def _queue_event_issues(event: dict[str, Any], index: int) -> list[str]:
    issues: list[str] = []
    for field in ("eventID", "queueItemID", "workItemID", "domainID", "subdomainID", "sourceIntentID", "sourceAuditProvenance"):
        if not event.get(field):
            issues.append(f"events[{index}].{field} required")
    if event.get("publicReferenceOnly") is not True:
        issues.append(f"{event.get('eventID', f'events[{index}]')}: publicReferenceOnly must be true")
    if event.get("privateContextPresent") is not False:
        issues.append(f"{event.get('eventID', f'events[{index}]')}: privateContextPresent must be false")
    if event.get("privateContextAllowed") is not False:
        issues.append(f"{event.get('eventID', f'events[{index}]')}: privateContextAllowed must be false")
    if event.get("finalOutputAllowed") is not False:
        issues.append(f"{event.get('eventID', f'events[{index}]')}: finalOutputAllowed must be false")
    if event.get("lawfulIntent") is not True:
        issues.append(f"{event.get('eventID', f'events[{index}]')}: lawfulIntent must be true")
    if event.get("expansionState") != "queued":
        issues.append(f"{event.get('eventID', f'events[{index}]')}: expansionState must be queued")
    if event.get("candidateState") != "candidate_only_until_approved":
        issues.append(f"{event.get('eventID', f'events[{index}]')}: candidateState must be candidate_only_until_approved")
    return issues


def _validate_approval(approval: Any, queue_events: list[dict[str, Any]], approval_path: Path | None) -> dict[str, Any]:
    if approval is None:
        return {
            "valid": False,
            "approvalArtifactProvided": False,
            "approvalArtifactPath": "",
            "approvedEvents": [],
            "selectedEventIDs": [],
            "entryIssuesByEventID": {},
            "issues": ["approval artifact not provided; all queue events remain blocked"],
            "nonClaims": ["missing approval is expected for blocked dry-run gate reports"],
        }
    issues: list[str] = []
    if not isinstance(approval, dict):
        issues.append("approval artifact must be an object")
        approval = {}
    if approval.get("kind") != MISSING_SHARD_REVIEW_APPROVAL_KIND:
        issues.append(f"approval artifact kind must be {MISSING_SHARD_REVIEW_APPROVAL_KIND}")
    if approval.get("approvalStatus") != APPROVED_STATUS:
        issues.append(f"approvalStatus must be {APPROVED_STATUS}")
    for field in ("approvalArtifactID", "reviewOwner", "reviewedAt"):
        if not approval.get(field):
            issues.append(f"{field} required")
    selected = approval.get("selectedEventIDs", [])
    if not isinstance(selected, list) or not selected or not all(isinstance(item, str) and item for item in selected):
        issues.append("selectedEventIDs must be a non-empty string list")
        selected = []
    approved_events = approval.get("approvedEvents", [])
    if not isinstance(approved_events, list):
        issues.append("approvedEvents must be a list")
        approved_events = []
    queue_ids = {str(event.get("eventID") or "") for event in queue_events}
    approved_ids: set[str] = set()
    entry_issues_by_id: dict[str, list[str]] = {}
    for index, entry in enumerate(approved_events):
        if not isinstance(entry, dict):
            issues.append(f"approvedEvents[{index}] must be an object")
            continue
        event_id = str(entry.get("eventID") or "")
        if not event_id:
            issues.append(f"approvedEvents[{index}].eventID required")
            continue
        if event_id not in queue_ids:
            issues.append(f"{event_id}: approved event does not match queue")
        approved_ids.add(event_id)
        entry_issues = _approval_entry_issues(entry, f"approvedEvents[{index}]")
        entry_issues_by_id[event_id] = entry_issues
        issues.extend(entry_issues)
    for event_id in selected:
        if event_id not in queue_ids:
            issues.append(f"{event_id}: selected event does not match queue")
        if event_id not in approved_ids:
            issues.append(f"{event_id}: selected event missing approvedEvents entry")
    return {
        "valid": not issues,
        "approvalArtifactProvided": True,
        "approvalArtifactPath": str(approval_path) if approval_path else "",
        "approvalArtifactID": str(approval.get("approvalArtifactID") or ""),
        "reviewOwner": str(approval.get("reviewOwner") or ""),
        "reviewedAt": str(approval.get("reviewedAt") or ""),
        "outsideLegalStatus": str(approval.get("outsideLegalStatus") or "not_claimed"),
        "selectedEventIDs": sorted(selected),
        "approvedEvents": [entry for entry in approved_events if isinstance(entry, dict)],
        "entryIssuesByEventID": entry_issues_by_id,
        "issues": sorted(set(issues)),
        "nonClaims": [
            "approval artifact validation does not equal active registry mutation",
            "outside legal approval is not claimed unless an outside legal artifact is present",
            "review gate does not write active registries",
        ],
    }


def _approval_entry_issues(entry: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    gate_decisions = entry.get("gateDecisions")
    if not isinstance(gate_decisions, dict):
        issues.append(f"{label}.gateDecisions required")
        gate_decisions = {}
    for gate, expected in REQUIRED_GATE_DECISIONS.items():
        if gate_decisions.get(gate) != expected:
            issues.append(f"{label}.gateDecisions.{gate} must be {expected}")
    if gate_decisions.get("ownerApproval") not in {"approved", "not_required"}:
        issues.append(f"{label}.gateDecisions.ownerApproval must be approved or not_required")
    source_lane = entry.get("sourceLaneEntry")
    legal_terms = entry.get("legalTermsEntry")
    api_policy = entry.get("apiPolicyEntry")
    if not isinstance(source_lane, dict):
        issues.append(f"{label}.sourceLaneEntry required")
        source_lane = {}
    if not isinstance(legal_terms, dict):
        issues.append(f"{label}.legalTermsEntry required")
        legal_terms = {}
    if not isinstance(api_policy, dict):
        issues.append(f"{label}.apiPolicyEntry required")
        api_policy = {}
    issues.extend(_source_lane_issues(source_lane, label))
    issues.extend(_legal_terms_issues(legal_terms, label))
    issues.extend(_api_policy_issues(api_policy, label))
    if source_lane.get("license_id") and legal_terms.get("license_id") and source_lane.get("license_id") != legal_terms.get("license_id"):
        issues.append(f"{label}: sourceLaneEntry.license_id must match legalTermsEntry.license_id")
    if source_lane.get("api_policy_id") and api_policy.get("api_policy_id") and source_lane.get("api_policy_id") != api_policy.get("api_policy_id"):
        issues.append(f"{label}: sourceLaneEntry.api_policy_id must match apiPolicyEntry.api_policy_id")
    if source_lane.get("source_id") and api_policy.get("source_id") and source_lane.get("source_id") != api_policy.get("source_id"):
        issues.append(f"{label}: sourceLaneEntry.source_id must match apiPolicyEntry.source_id")
    return issues


def _source_lane_issues(entry: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    for field in (
        "source_id",
        "source_name",
        "source_class",
        "authority_class",
        "jurisdiction",
        "domain_scope",
        "license_id",
        "api_policy_id",
        "review_status",
        "r2_pack_policy",
        "allowed_artifact_classes",
        "forbidden_artifact_classes",
    ):
        if not entry.get(field):
            issues.append(f"{label}.sourceLaneEntry.{field} required")
    if entry.get("review_status") != "reviewed":
        issues.append(f"{label}: sourceLaneEntry.review_status must be reviewed")
    if str(entry.get("r2_pack_policy") or "").startswith("pack_blocked"):
        issues.append(f"{label}: sourceLaneEntry.r2_pack_policy cannot be blocked")
    return issues


def _legal_terms_issues(entry: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    for field in ("license_id", "license_name", "license_url", "terms_url", "rights_url", "review_owner", "reviewed_at"):
        if not entry.get(field):
            issues.append(f"{label}.legalTermsEntry.{field} required")
    if entry.get("redistribution_allowed") is not True:
        issues.append(f"{label}: legalTermsEntry.redistribution_allowed must be true")
    if entry.get("pack_output_allowed") is not True:
        issues.append(f"{label}: legalTermsEntry.pack_output_allowed must be true")
    if entry.get("review_required") is not False:
        issues.append(f"{label}: legalTermsEntry.review_required must be false")
    if entry.get("outside_legal_status") == "approved" and not entry.get("approval_artifact_path"):
        issues.append(f"{label}: outside legal approval requires approval_artifact_path")
    return issues


def _api_policy_issues(entry: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    for field in (
        "api_policy_id",
        "source_id",
        "api_mode",
        "missing_key_behavior",
        "retry_policy",
        "backoff_policy",
        "circuit_breaker_policy",
        "budget_owner",
        "evidence_output_policy",
    ):
        if not entry.get(field):
            issues.append(f"{label}.apiPolicyEntry.{field} required")
    if entry.get("live_flag_required") is not True:
        issues.append(f"{label}: apiPolicyEntry.live_flag_required must be true")
    if entry.get("execute_flag_required") is not True:
        issues.append(f"{label}: apiPolicyEntry.execute_flag_required must be true")
    if entry.get("secret_redaction_required") is not True:
        issues.append(f"{label}: apiPolicyEntry.secret_redaction_required must be true")
    return issues


def _gate_decision(
    *,
    event: dict[str, Any],
    event_issues: list[str],
    approval_entry: dict[str, Any] | None,
    entry_issues: list[str],
    approval_validation: dict[str, Any],
    created_at: str,
) -> dict[str, Any]:
    event_id = str(event.get("eventID") or "")
    if event_issues:
        gate_status = BLOCKED_INVALID_APPROVAL_STATUS
        blocking_reasons = ["queue_event_schema_invalid", *event_issues]
        gate_decisions = _default_gate_decisions()
    elif not approval_validation["approvalArtifactProvided"]:
        gate_status = BLOCKED_PENDING_APPROVAL_STATUS
        blocking_reasons = [
            "approval_artifact_required",
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_policy_review_required",
            "no_private_data_scan_required",
        ]
        gate_decisions = _default_gate_decisions()
    elif not approval_validation["valid"]:
        gate_status = BLOCKED_INVALID_APPROVAL_STATUS
        blocking_reasons = ["approval_artifact_invalid", *approval_validation["issues"]]
        gate_decisions = _default_gate_decisions()
    elif approval_entry is None:
        gate_status = BLOCKED_NOT_SELECTED_STATUS
        blocking_reasons = ["not_selected_by_approval_artifact"]
        gate_decisions = _default_gate_decisions()
    elif entry_issues:
        gate_status = BLOCKED_INVALID_APPROVAL_STATUS
        blocking_reasons = ["approval_entry_invalid", *entry_issues]
        gate_decisions = _default_gate_decisions()
    else:
        gate_status = APPROVED_STATUS
        blocking_reasons = ["separate_active_registry_apply_train_required"]
        gate_decisions = dict(approval_entry["gateDecisions"])
    return {
        "eventID": event_id,
        "queueItemID": event.get("queueItemID"),
        "workItemID": event.get("workItemID"),
        "domainID": event.get("domainID"),
        "subdomainID": event.get("subdomainID"),
        "sourceIntentID": event.get("sourceIntentID"),
        "createdAt": created_at,
        "gateStatus": gate_status,
        "gateDecisions": gate_decisions,
        "candidateState": event.get("candidateState"),
        "coverageCountersAffected": False,
        "activeRegistryWritten": False,
        "blockingReasons": sorted(set(blocking_reasons)),
        "approvalArtifactID": approval_validation.get("approvalArtifactID", ""),
        "nonClaims": ["gate decision only", "not active registry mutation", "not source authority", "not final user output"],
    }


def _planned_mutation(event: dict[str, Any], approval_entry: dict[str, Any], *, created_at: str) -> dict[str, Any]:
    source_lane_entry = approval_entry["sourceLaneEntry"]
    legal_terms_entry = approval_entry["legalTermsEntry"]
    api_policy_entry = approval_entry["apiPolicyEntry"]
    return {
        "mutationID": stable_id(
            "source_atlas.missing_shard_registry_mutation",
            {"eventID": event.get("eventID"), "sourceLaneEntry": source_lane_entry},
        ),
        "eventID": event.get("eventID"),
        "queueItemID": event.get("queueItemID"),
        "workItemID": event.get("workItemID"),
        "domainID": event.get("domainID"),
        "subdomainID": event.get("subdomainID"),
        "createdAt": created_at,
        "status": "dry_run_ready_for_separate_registry_apply",
        "activeRegistryWritten": False,
        "coverageCountersAffected": False,
        "sourceLaneEntry": source_lane_entry,
        "legalTermsEntry": legal_terms_entry,
        "apiPolicyEntry": api_policy_entry,
        "reversalPlan": {
            "rollbackMode": "discard_plan_before_active_apply",
            "activeRegistryRollbackRequired": False,
            "activeRegistryWritten": False,
            "sourceEventID": event.get("eventID"),
        },
        "blockingReasons": ["separate_active_registry_apply_train_required"],
        "nonClaims": ["dry-run mutation plan only", "not active registry mutation", "not R2 publish", "not native activation"],
    }


def _blocked_mutation(event: dict[str, Any], decision: dict[str, Any], *, created_at: str) -> dict[str, Any]:
    return {
        "eventID": event.get("eventID"),
        "queueItemID": event.get("queueItemID"),
        "workItemID": event.get("workItemID"),
        "domainID": event.get("domainID"),
        "subdomainID": event.get("subdomainID"),
        "createdAt": created_at,
        "status": decision["gateStatus"],
        "activeRegistryWritten": False,
        "coverageCountersAffected": False,
        "blockingReasons": decision["blockingReasons"],
        "nonClaims": ["blocked mutation only", "not active registry mutation", "not source authority", "not coverage credit"],
    }


def _rejected_event(event: dict[str, Any], decision: dict[str, Any], *, created_at: str) -> dict[str, Any]:
    return {
        "eventID": event.get("eventID"),
        "createdAt": created_at,
        "status": "rejected_lawful_no_public_source",
        "domainID": event.get("domainID"),
        "subdomainID": event.get("subdomainID"),
        "rationale": decision["blockingReasons"],
        "coverageCountersAffected": False,
        "nonClaims": ["lawful rejection only", "not coverage credit", "not active registry mutation"],
    }


def _approval_template(queue_events: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "kind": MISSING_SHARD_REVIEW_APPROVAL_KIND,
        "approvalArtifactID": stable_id("source_atlas.missing_shard_review_approval_template", {"createdAt": created_at, "events": len(queue_events)}),
        "approvalStatus": "template_not_approved",
        "reviewOwner": "",
        "reviewedAt": "",
        "outsideLegalStatus": "not_claimed",
        "selectedEventIDs": [],
        "approvedEvents": [
            {
                "eventID": event.get("eventID"),
                "domainID": event.get("domainID"),
                "subdomainID": event.get("subdomainID"),
                "requiredGateDecisions": {
                    **REQUIRED_GATE_DECISIONS,
                    "ownerApproval": "approved_or_not_required",
                },
                "requiredEntries": ["sourceLaneEntry", "legalTermsEntry", "apiPolicyEntry"],
                "candidateStateBeforeApproval": event.get("candidateState"),
            }
            for event in queue_events
        ],
        "nonClaims": ["template only", "not approval", "not registry mutation"],
    }


def _checks(
    *,
    queue_load_issues: list[str],
    queue_shape_issues: list[str],
    queue_event_issues_by_id: dict[str, list[str]],
    registry_issues: list[str],
    input_privacy_issues: list[str],
    approval_privacy_issues: list[str],
    approval_global_issues: list[str],
    active_write_issues: list[str],
    record_counts: dict[str, int],
    planned_mutations: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    queue_event_issues = [issue for issues in queue_event_issues_by_id.values() for issue in issues]
    return [
        _check("queue_loaded", not queue_load_issues and not queue_shape_issues, queue_load_issues + queue_shape_issues, "red"),
        _check("queue_events_schema_valid", not queue_event_issues, queue_event_issues, "red"),
        _check("governance_registries_loaded", not registry_issues, registry_issues, "red"),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues, "red"),
        _check("approval_privacy_scan_passed", not approval_privacy_issues, approval_privacy_issues, "red"),
        _check("approval_artifact_valid_when_provided", not approval_global_issues, approval_global_issues, "red"),
        _check(
            "approval_required_for_planned_registry_mutations",
            record_counts["plannedRegistryMutations"] == 0 or not approval_global_issues,
            approval_global_issues,
            "red",
        ),
        _check(
            "planned_mutations_are_dry_run_only",
            all(item.get("activeRegistryWritten") is False and item.get("status") == "dry_run_ready_for_separate_registry_apply" for item in planned_mutations),
            [],
            "red",
        ),
        _check("active_registry_writes_blocked", record_counts["activeRegistryMutations"] == 0 and not active_write_issues, active_write_issues, "red"),
        _check("blocked_or_rejected_events_do_not_affect_coverage", record_counts["coverageCounterMutations"] == 0, ["coverage counter mutation emitted"], "red"),
        _check("no_claims_packs_r2_native_or_final_outputs", record_counts["claims"] == 0 and record_counts["packableClaims"] == 0 and record_counts["r2PublishOperations"] == 0 and record_counts["nativeActivationOperations"] == 0 and record_counts["finalOutputArtifacts"] == 0, ["forbidden output emitted"], "red"),
    ]


def _check(name: str, passed: bool, issues: list[str], severity: str) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else sorted(set(issues)), "severity": severity}


def _default_gate_decisions() -> dict[str, str]:
    return {
        "publicReferenceClassification": "passed",
        "sourceLaneReview": "queued",
        "legalTermsReview": "queued",
        "apiPolicyReview": "queued",
        "noPrivateDataScan": "passed",
        "ownerApproval": "not_required_for_queue",
    }


def _allowed_claims(record_counts: dict[str, int]) -> list[str]:
    claims = ["missing_shard_review_gate_tooling_green", "candidate_events_blocked_until_all_gates_pass"]
    if record_counts["plannedRegistryMutations"]:
        claims.append("approved_events_have_dry_run_registry_mutation_plan")
    return claims


def _status(valid: bool, record_counts: dict[str, int]) -> str:
    if not valid:
        return "Red: missing-shard review gate failed validation"
    if record_counts["plannedRegistryMutations"]:
        return "Source Green for missing-shard review/legal/API gate / dry-run mutation plans emitted"
    return "Source Green for missing-shard review/legal/API gate / all current events blocked pending approval"


def _target_paths(options: MissingShardReviewGateOptions) -> dict[str, str]:
    return {
        "sourceLaneRegistry": str(options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH),
        "legalTermsRegistry": str(options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH),
        "apiGovernanceRegistry": str(options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH),
    }


def _read_required(path: Path, label: str) -> tuple[Any, list[str]]:
    if not path.exists():
        return None, [f"{label} missing at {path}"]
    value = read_json(path)
    if not isinstance(value, dict):
        return value, [f"{label} at {path} is not a JSON object"]
    return value, []


def _read_optional(path: Path | None, label: str) -> tuple[Any, list[str]]:
    if path is None:
        return None, []
    if not path.exists():
        return None, [f"{label} configured but missing at {path}"]
    value = read_json(path)
    if not isinstance(value, dict):
        return value, [f"{label} at {path} is not a JSON object"]
    return value, []
