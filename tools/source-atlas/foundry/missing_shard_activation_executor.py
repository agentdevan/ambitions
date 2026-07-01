"""Governed activation executor for Source Atlas missing-shard work.

This compiler turns approved missing-shard registry mutation plans into a
stage-by-stage activation execution contract. It defaults to audit/dry-run
evidence, never writes active registries or R2 objects by itself, and never
emits native activation unless verified public/reference downstream reports are
present and explicitly approved.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import object_key_issues
from .missing_shard_review_gate import APPROVED_STATUS
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_MISSING_SHARD_ACTIVATION_EXECUTOR_KIND = "ambitions.sourceAtlas.missingShardActivationExecutor.v1"
SOURCE_ATLAS_MISSING_SHARD_ACTIVATION_EXECUTOR_VERSION = "source-atlas-missing-shard-activation-executor-lff-m04-l03"
MISSING_SHARD_ACTIVATION_APPROVAL_KIND = "ambitions.sourceAtlas.missingShardActivationApproval.v1"
ACTIVATION_APPROVED_STATUS = "approved_for_activation_execution"

ACTIVATION_STAGES = (
    "harvest",
    "claimExtraction",
    "adjudication",
    "packCompile",
    "r2Promotion",
    "nativeActivation",
)

FORBIDDEN_ACTIVATION_CLAIMS = {
    "active_registry_mutation",
    "source_atlas_launch_floor_ready",
    "launch_floor_complete",
    "release_green",
    "outside_legal_approval",
    "production_r2_write_complete",
    "native_activation_complete",
    "final_user_plans_schedules_steps_from_source_atlas_or_r2",
    "private_life_graph_in_source_atlas_or_r2",
}

ACTIVATION_EXECUTOR_NON_CLAIMS = [
    "missing-shard activation executor and stage contract only",
    "not active registry mutation",
    "not harvest execution without explicit activation approval and downstream stage proof",
    "not claim extraction proof without downstream stage proof",
    "not pack output proof without downstream pack compiler proof",
    "not R2 publication or promotion proof without downstream publisher proof",
    "not native activation proof without downstream native registry proof",
    "not outside legal approval",
    "not launch-floor complete",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class MissingShardActivationExecutorOptions:
    review_gate_path: Path
    output_root: Path
    activation_approval_path: Path | None = None
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None
    execute: bool = False
    allow_r2_write: bool = False
    allow_native_activation: bool = False
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"


def compile_missing_shard_activation_executor(options: MissingShardActivationExecutorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    review_gate, review_gate_load_issues = _read_required(options.review_gate_path, "missing-shard review gate")
    activation_approval, approval_load_issues = _read_optional(
        options.activation_approval_path,
        "missing-shard activation approval",
    )
    input_privacy_issues = privacy_findings_for_value(
        {
            "reviewGatePath": str(options.review_gate_path),
            "activationApprovalPath": str(options.activation_approval_path) if options.activation_approval_path else "",
            "execute": options.execute,
            "allowR2Write": options.allow_r2_write,
            "allowNativeActivation": options.allow_native_activation,
        },
        "missing-shard-activation-executor-input",
    )
    approval_privacy_issues = (
        privacy_findings_for_value(activation_approval, "missing-shard-activation-approval")
        if activation_approval is not None
        else []
    )

    review_gate_issues = _review_gate_issues(review_gate)
    planned_mutations = _planned_mutations(review_gate)
    gate_decisions = _gate_decisions(review_gate)
    activation_approval_validation = _validate_activation_approval(
        activation_approval,
        planned_mutations,
        options.activation_approval_path,
    )
    if approval_privacy_issues and activation_approval_validation["activationApprovalProvided"]:
        activation_approval_validation = {
            **activation_approval_validation,
            "valid": False,
            "issues": sorted(set([*activation_approval_validation.get("issues", []), *approval_privacy_issues])),
        }
    if options.execute and not activation_approval_validation["activationApprovalProvided"]:
        activation_approval_validation = {
            **activation_approval_validation,
            "valid": False,
            "issues": sorted(
                set(
                    [
                        *activation_approval_validation.get("issues", []),
                        "execute mode requires an activation approval artifact",
                    ]
                )
            ),
        }

    selected_mutation_ids = set(activation_approval_validation.get("selectedMutationIDs", []))
    stage_decisions: list[dict[str, Any]] = []
    blocked_stage_work: list[dict[str, Any]] = []
    dry_run_operations: list[dict[str, Any]] = []
    execution_authorizations: list[dict[str, Any]] = []

    planned_by_event = {str(item.get("eventID") or ""): item for item in planned_mutations}
    for decision in gate_decisions:
        event_id = str(decision.get("eventID") or "")
        planned_mutation = planned_by_event.get(event_id)
        for stage in ACTIVATION_STAGES:
            stage_decision = _stage_decision(
                stage=stage,
                review_gate_decision=decision,
                planned_mutation=planned_mutation,
                activation_approval_validation=activation_approval_validation,
                selected_mutation_ids=selected_mutation_ids,
                options=options,
            )
            stage_decisions.append(stage_decision)
            if stage_decision["stageStatus"].startswith("blocked"):
                blocked_stage_work.append(_blocked_stage_work(stage_decision))
            elif stage_decision["stageStatus"] == "dry_run_ready":
                dry_run_operations.append(_stage_operation(stage_decision, planned_mutation, options, execute_authorized=False))
            elif stage_decision["stageStatus"] == "execute_authorized":
                execution_authorizations.append(_stage_operation(stage_decision, planned_mutation, options, execute_authorized=True))

    activation_approval_template = _activation_approval_template(planned_mutations, options.created_at)
    r2_operation_plan = _r2_operation_plan(dry_run_operations, execution_authorizations)
    native_activation_plan = _native_activation_plan(dry_run_operations, execution_authorizations)
    output_privacy_issues = privacy_findings_for_value(
        {
            "stageDecisions": stage_decisions,
            "blockedStageWork": blocked_stage_work,
            "dryRunOperations": dry_run_operations,
            "executionAuthorizations": execution_authorizations,
            "r2OperationPlan": r2_operation_plan,
            "nativeActivationPlan": native_activation_plan,
            "activationApprovalTemplate": activation_approval_template,
        },
        "missing-shard-activation-executor-output",
    )

    r2_object_key_issues = [
        issue.format()
        for operation in [*dry_run_operations, *execution_authorizations]
        for key in operation.get("publicR2ObjectKeys", [])
        for issue in object_key_issues(str(key))
    ]
    activation_approval_report_issues = (
        activation_approval_validation.get("issues", [])
        if activation_approval_validation["activationApprovalProvided"] or options.execute
        else []
    )
    record_counts = _record_counts(
        gate_decisions=gate_decisions,
        planned_mutations=planned_mutations,
        stage_decisions=stage_decisions,
        dry_run_operations=dry_run_operations,
        execution_authorizations=execution_authorizations,
    )
    active_write_issues = _active_write_issues(options, activation_approval_validation, execution_authorizations)
    issues = sorted(
        set(
            [
                *review_gate_load_issues,
                *approval_load_issues,
                *input_privacy_issues,
                *approval_privacy_issues,
                *review_gate_issues,
                *activation_approval_report_issues,
                *output_privacy_issues,
                *r2_object_key_issues,
                *active_write_issues,
            ]
        )
    )
    checks = _checks(
        review_gate_load_issues=review_gate_load_issues,
        approval_load_issues=approval_load_issues,
        input_privacy_issues=input_privacy_issues,
        approval_privacy_issues=approval_privacy_issues,
        review_gate_issues=review_gate_issues,
        activation_approval_validation=activation_approval_validation,
        output_privacy_issues=output_privacy_issues,
        r2_object_key_issues=r2_object_key_issues,
        active_write_issues=active_write_issues,
        record_counts=record_counts,
    )
    valid = not issues and all(check["passed"] for check in checks)

    output_paths = {
        "report": str(output_root / "missing-shard-activation-executor.json"),
        "stageExecutionPlan": str(output_root / "stage-execution-plan.json"),
        "blockedStageWork": str(output_root / "blocked-stage-work.json"),
        "dryRunOperations": str(output_root / "dry-run-operations.json"),
        "executionAuthorizations": str(output_root / "execution-authorizations.json"),
        "r2OperationPlan": str(output_root / "r2-operation-plan.json"),
        "nativeActivationPlan": str(output_root / "native-activation-plan.json"),
        "activationApprovalTemplate": str(output_root / "activation-approval-template.json"),
        "closeout": str(output_root / "closeout.md"),
        "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
        "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_MISSING_SHARD_ACTIVATION_EXECUTOR_KIND,
        "versionID": SOURCE_ATLAS_MISSING_SHARD_ACTIVATION_EXECUTOR_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "executorID": stable_id(
            "source_atlas.missing_shard_activation_executor",
            {
                "reviewGatePath": str(options.review_gate_path),
                "activationApprovalPath": str(options.activation_approval_path) if options.activation_approval_path else "",
                "execute": options.execute,
                "recordCounts": record_counts,
            },
        ),
        "valid": valid,
        "status": _status(valid, record_counts),
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; governed activation executor only",
        "reviewGatePath": str(options.review_gate_path),
        "activationApprovalPath": str(options.activation_approval_path) if options.activation_approval_path else "",
        "executeRequested": options.execute,
        "allowR2Write": options.allow_r2_write,
        "allowNativeActivation": options.allow_native_activation,
        "activationApprovalValidation": activation_approval_validation,
        "recordCounts": record_counts,
        "stageContract": _stage_contract(),
        "stageDecisions": stage_decisions,
        "blockedStageWork": blocked_stage_work,
        "dryRunOperations": dry_run_operations,
        "executionAuthorizations": execution_authorizations,
        "r2OperationPlan": r2_operation_plan,
        "nativeActivationPlan": native_activation_plan,
        "activationApprovalTemplate": activation_approval_template,
        "lffM00Counters": {
            "missingShardActivationStageDecisions": record_counts["stageDecisions"],
            "missingShardActivationBlockedStageDecisions": record_counts["blockedStageDecisions"],
            "missingShardActivationDryRunOperations": record_counts["dryRunOperations"],
            "missingShardActivationExecutionAuthorizations": record_counts["executionAuthorizations"],
            "r2WriteOperations": 0,
            "nativeActivationOperations": 0,
            "coverageCounterMutations": 0,
        },
        "checks": checks,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *approval_privacy_issues, *output_privacy_issues])),
        "allowedClaims": _allowed_claims(valid, record_counts),
        "blockedClaims": sorted(FORBIDDEN_ACTIVATION_CLAIMS),
        "nonClaims": ACTIVATION_EXECUTOR_NON_CLAIMS,
        "outputPaths": output_paths,
    }

    write_json(output_root / "stage-execution-plan.json", {"kind": "ambitions.sourceAtlas.missingShardStageExecutionPlan.v1", "createdAt": options.created_at, "stageDecisions": stage_decisions})
    write_json(output_root / "blocked-stage-work.json", {"kind": "ambitions.sourceAtlas.missingShardBlockedStageWork.v1", "createdAt": options.created_at, "blockedStageWork": blocked_stage_work})
    write_json(output_root / "dry-run-operations.json", {"kind": "ambitions.sourceAtlas.missingShardDryRunOperations.v1", "createdAt": options.created_at, "dryRunOperations": dry_run_operations})
    write_json(output_root / "execution-authorizations.json", {"kind": "ambitions.sourceAtlas.missingShardExecutionAuthorizations.v1", "createdAt": options.created_at, "executionAuthorizations": execution_authorizations})
    write_json(output_root / "r2-operation-plan.json", r2_operation_plan)
    write_json(output_root / "native-activation-plan.json", native_activation_plan)
    write_json(output_root / "activation-approval-template.json", activation_approval_template)
    write_json(output_root / "missing-shard-activation-executor.json", artifact)
    artifact["outputHashes"] = {
        "stageExecutionPlan": stable_hash(read_json(output_root / "stage-execution-plan.json")),
        "blockedStageWork": stable_hash(read_json(output_root / "blocked-stage-work.json")),
        "dryRunOperations": stable_hash(read_json(output_root / "dry-run-operations.json")),
        "executionAuthorizations": stable_hash(read_json(output_root / "execution-authorizations.json")),
        "r2OperationPlan": stable_hash(read_json(output_root / "r2-operation-plan.json")),
        "nativeActivationPlan": stable_hash(read_json(output_root / "native-activation-plan.json")),
        "activationApprovalTemplate": stable_hash(read_json(output_root / "activation-approval-template.json")),
        "report": stable_hash(read_json(output_root / "missing-shard-activation-executor.json")),
    }
    markdown = missing_shard_activation_executor_markdown(artifact)
    artifact["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(output_root / "missing-shard-activation-executor.json", artifact)
    (output_root / "closeout.md").write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, artifact)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    return artifact


def missing_shard_activation_executor_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Missing-Shard Activation Executor LFF-M04-L03",
        "",
        f"Status: {report['status']}",
        f"Valid: {str(report['valid']).lower()}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Execute requested: {report['executeRequested']}",
        f"Allow R2 write: {report['allowR2Write']}",
        f"Allow native activation: {report['allowNativeActivation']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Review-gate decisions consumed: {counts['reviewGateDecisions']}",
        f"- Planned registry mutations consumed: {counts['plannedRegistryMutations']}",
        f"- Activation stage decisions: {counts['stageDecisions']}",
        f"- Blocked stage decisions: {counts['blockedStageDecisions']}",
        f"- Dry-run operations: {counts['dryRunOperations']}",
        f"- Execution authorizations: {counts['executionAuthorizations']}",
        f"- R2 write operations: {counts['r2WriteOperations']}",
        f"- Native activation operations: {counts['nativeActivationOperations']}",
        f"- Coverage counter mutations: {counts['coverageCounterMutations']}",
        f"- Final output artifacts: {counts['finalOutputArtifacts']}",
        "",
        "## Checks",
        "",
    ]
    lines.extend(f"- `{check['name']}`: {'PASS' if check['passed'] else 'FAIL'}" for check in report["checks"])
    lines.extend(["", "## Product Law Preserved", ""])
    lines.extend(
        [
            "- Activation cannot advance from candidate work without explicit approval.",
            "- R2 operations are planned as public/reference object keys with rollback metadata.",
            "- Native activation remains gated by verified public manifests and no-private-egress proof.",
            "- This executor emits no claims, packs, active R2 writes, native activation operations, coverage counter mutations, final plans, schedules, or Steps.",
        ]
    )
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    if report["issues"]:
        lines.extend(["", "## Issues", ""])
        lines.extend(f"- {issue}" for issue in report["issues"])
    return "\n".join(lines) + "\n"


def _stage_contract() -> list[dict[str, str]]:
    return [
        {"stage": "harvest", "requiredProof": "approved public source lane and explicit activation approval"},
        {"stage": "claimExtraction", "requiredProof": "harvest output classified public/reference only"},
        {"stage": "adjudication", "requiredProof": "claim provenance, legal/terms, API, and no-private-data review"},
        {"stage": "packCompile", "requiredProof": "pack compiler manifest, hashes, non-private scan, revocation, LKG, rollback"},
        {"stage": "r2Promotion", "requiredProof": "publisher report with public object keys, readback, rollback, and owner/budget approval"},
        {"stage": "nativeActivation", "requiredProof": "native refresh registry report with verified public manifest and no-private-egress proof"},
    ]


def _review_gate_issues(review_gate: Any) -> list[str]:
    issues: list[str] = []
    if not isinstance(review_gate, dict):
        return ["missing-shard review gate must be a JSON object"]
    if review_gate.get("kind") != "ambitions.sourceAtlas.missingShardReviewGate.v1":
        issues.append("review gate kind must be ambitions.sourceAtlas.missingShardReviewGate.v1")
    if review_gate.get("valid") is not True:
        issues.append("review gate must be valid before activation executor can run")
    counts = review_gate.get("recordCounts") if isinstance(review_gate.get("recordCounts"), dict) else {}
    if counts.get("activeRegistryMutations") not in {0, None}:
        issues.append("review gate input must not contain active registry mutations")
    if counts.get("coverageCounterMutations") not in {0, None}:
        issues.append("review gate input must not contain coverage counter mutations")
    return issues


def _planned_mutations(review_gate: Any) -> list[dict[str, Any]]:
    if not isinstance(review_gate, dict) or not isinstance(review_gate.get("plannedRegistryMutations"), list):
        return []
    return [item for item in review_gate["plannedRegistryMutations"] if isinstance(item, dict)]


def _gate_decisions(review_gate: Any) -> list[dict[str, Any]]:
    if not isinstance(review_gate, dict) or not isinstance(review_gate.get("gateDecisions"), list):
        return []
    return [item for item in review_gate["gateDecisions"] if isinstance(item, dict)]


def _validate_activation_approval(approval: Any, planned_mutations: list[dict[str, Any]], approval_path: Path | None) -> dict[str, Any]:
    if approval is None:
        return {
            "valid": False,
            "activationApprovalProvided": False,
            "activationApprovalPath": "",
            "selectedMutationIDs": [],
            "issues": ["activation approval not provided; all activation stages remain blocked"],
            "nonClaims": ["missing approval is expected for audit-only blocked reports"],
        }
    issues: list[str] = []
    if not isinstance(approval, dict):
        issues.append("activation approval must be a JSON object")
        approval = {}
    if approval.get("kind") != MISSING_SHARD_ACTIVATION_APPROVAL_KIND:
        issues.append(f"activation approval kind must be {MISSING_SHARD_ACTIVATION_APPROVAL_KIND}")
    if approval.get("activationStatus") != ACTIVATION_APPROVED_STATUS:
        issues.append(f"activationStatus must be {ACTIVATION_APPROVED_STATUS}")
    for field in ("activationApprovalID", "reviewOwner", "reviewedAt"):
        if not approval.get(field):
            issues.append(f"{field} required")
    if approval.get("publicReferenceOnly") is not True:
        issues.append("publicReferenceOnly must be true")
    if approval.get("privateContextPresent") is not False:
        issues.append("privateContextPresent must be false")
    if approval.get("finalOutputAllowed") is not False:
        issues.append("finalOutputAllowed must be false")
    if approval.get("coverageCounterMutationAllowed") is not False:
        issues.append("coverageCounterMutationAllowed must be false")
    if approval.get("reversibleActivation") is not True:
        issues.append("reversibleActivation must be true")
    selected = approval.get("selectedMutationIDs", [])
    if not isinstance(selected, list) or not all(isinstance(item, str) and item for item in selected):
        issues.append("selectedMutationIDs must be a string list")
        selected = []
    planned_ids = {str(item.get("mutationID") or "") for item in planned_mutations}
    for mutation_id in selected:
        if mutation_id not in planned_ids:
            issues.append(f"{mutation_id}: selected mutation does not match review-gate planned mutations")
    stage_approvals = approval.get("stageApprovals")
    if not isinstance(stage_approvals, dict):
        issues.append("stageApprovals required")
        stage_approvals = {}
    for stage in ACTIVATION_STAGES:
        if stage_approvals.get(stage) != "approved":
            issues.append(f"stageApprovals.{stage} must be approved")
    r2_write = approval.get("r2WriteApproval") if isinstance(approval.get("r2WriteApproval"), dict) else {}
    native = approval.get("nativeActivationApproval") if isinstance(approval.get("nativeActivationApproval"), dict) else {}
    if r2_write.get("reversible") is not True:
        issues.append("r2WriteApproval.reversible must be true")
    if r2_write.get("publicReferenceOnly") is not True:
        issues.append("r2WriteApproval.publicReferenceOnly must be true")
    if native.get("verifiedPublicManifestRequired") is not True:
        issues.append("nativeActivationApproval.verifiedPublicManifestRequired must be true")
    if native.get("noPrivateEgressRequired") is not True:
        issues.append("nativeActivationApproval.noPrivateEgressRequired must be true")
    return {
        "valid": not issues,
        "activationApprovalProvided": True,
        "activationApprovalPath": str(approval_path) if approval_path else "",
        "activationApprovalID": str(approval.get("activationApprovalID") or ""),
        "reviewOwner": str(approval.get("reviewOwner") or ""),
        "reviewedAt": str(approval.get("reviewedAt") or ""),
        "selectedMutationIDs": sorted(selected),
        "stageApprovals": {stage: str(stage_approvals.get(stage) or "") for stage in ACTIVATION_STAGES},
        "r2WriteApproval": r2_write,
        "nativeActivationApproval": native,
        "issues": sorted(set(issues)),
        "nonClaims": [
            "activation approval does not prove R2 writes occurred",
            "activation approval does not prove native activation occurred",
        ],
    }


def _stage_decision(
    *,
    stage: str,
    review_gate_decision: dict[str, Any],
    planned_mutation: dict[str, Any] | None,
    activation_approval_validation: dict[str, Any],
    selected_mutation_ids: set[str],
    options: MissingShardActivationExecutorOptions,
) -> dict[str, Any]:
    event_id = str(review_gate_decision.get("eventID") or "")
    mutation_id = str(planned_mutation.get("mutationID") or "") if planned_mutation else ""
    if review_gate_decision.get("gateStatus") != APPROVED_STATUS or planned_mutation is None:
        status = "blocked_by_review_gate"
        reasons = list(review_gate_decision.get("blockingReasons", ["review gate did not approve this event"]))
    elif not activation_approval_validation["activationApprovalProvided"]:
        status = "blocked_pending_activation_approval"
        reasons = ["activation_approval_required"]
    elif not activation_approval_validation["valid"]:
        status = "blocked_invalid_activation_approval"
        reasons = list(activation_approval_validation.get("issues", ["activation approval invalid"]))
    elif mutation_id not in selected_mutation_ids:
        status = "blocked_not_selected_by_activation_approval"
        reasons = ["mutation_not_selected_by_activation_approval"]
    elif options.execute:
        status, reasons = _execute_stage_status(stage, activation_approval_validation, options)
    else:
        status = "dry_run_ready"
        reasons = ["execute_flag_not_set", "downstream_stage_runner_required"]
    return {
        "stageDecisionID": stable_id("source_atlas.missing_shard_stage_decision", {"eventID": event_id, "mutationID": mutation_id, "stage": stage, "status": status}),
        "stage": stage,
        "eventID": event_id,
        "mutationID": mutation_id,
        "domainID": review_gate_decision.get("domainID"),
        "subdomainID": review_gate_decision.get("subdomainID"),
        "createdAt": options.created_at,
        "stageStatus": status,
        "activeRegistryWritten": False,
        "r2WritePerformed": False,
        "nativeActivationPerformed": False,
        "coverageCountersAffected": False,
        "finalOutputGenerated": False,
        "blockingReasons": sorted(set(reasons)),
        "activationApprovalID": activation_approval_validation.get("activationApprovalID", ""),
        "nonClaims": ["stage decision only", "not final user output", "not R2 write", "not native activation"],
    }


def _execute_stage_status(stage: str, approval: dict[str, Any], options: MissingShardActivationExecutorOptions) -> tuple[str, list[str]]:
    if stage == "r2Promotion":
        r2_approval = approval.get("r2WriteApproval") if isinstance(approval.get("r2WriteApproval"), dict) else {}
        if options.allow_r2_write and r2_approval.get("allowed") is True:
            return "execute_authorized", ["downstream_r2_publisher_report_still_required_for_write_claim"]
        return "blocked_r2_write_not_explicitly_allowed", ["allow_r2_write_flag_and_r2WriteApproval.allowed_required"]
    if stage == "nativeActivation":
        native_approval = approval.get("nativeActivationApproval") if isinstance(approval.get("nativeActivationApproval"), dict) else {}
        if options.allow_native_activation and native_approval.get("allowed") is True:
            return "execute_authorized", ["downstream_native_refresh_registry_report_still_required_for_activation_claim"]
        return "blocked_native_activation_not_explicitly_allowed", ["allow_native_activation_flag_and_nativeActivationApproval.allowed_required"]
    return "execute_authorized", ["downstream_stage_proof_required_before_claim"]


def _stage_operation(
    stage_decision: dict[str, Any],
    planned_mutation: dict[str, Any] | None,
    options: MissingShardActivationExecutorOptions,
    *,
    execute_authorized: bool,
) -> dict[str, Any]:
    mutation_fingerprint = stable_hash(planned_mutation or stage_decision)[:16]
    object_prefix = f"source-atlas/v1/staging/missing-shard/{stage_decision.get('domainID')}/{mutation_fingerprint}"
    public_keys = [
        f"{object_prefix}/manifest.json",
        f"{object_prefix}/pack.json",
        f"{object_prefix}/claims.json",
        f"{object_prefix}/current.json",
    ]
    return {
        "operationID": stable_id("source_atlas.missing_shard_stage_operation", {"stageDecision": stage_decision, "executeAuthorized": execute_authorized}),
        "stageDecisionID": stage_decision["stageDecisionID"],
        "stage": stage_decision["stage"],
        "eventID": stage_decision["eventID"],
        "mutationID": stage_decision["mutationID"],
        "domainID": stage_decision.get("domainID"),
        "subdomainID": stage_decision.get("subdomainID"),
        "createdAt": options.created_at,
        "operationMode": "execute_authorization" if execute_authorized else "dry_run",
        "status": "execute_authorized_requires_downstream_stage_proof" if execute_authorized else "dry_run_ready",
        "publicReferenceOnly": True,
        "privateContextPresent": False,
        "finalOutputAllowed": False,
        "activeRegistryWritten": False,
        "r2WritePerformed": False,
        "nativeActivationPerformed": False,
        "publicR2ObjectKeys": public_keys if stage_decision["stage"] in {"packCompile", "r2Promotion", "nativeActivation"} else [],
        "rollbackPlan": {
            "rollbackMode": "discard_plan_or_revert_current_pointer_after_verified_publisher_rollback",
            "currentPointerReversible": True,
            "activeRegistryRollbackRequired": False,
            "r2RollbackRequiredIfPublished": stage_decision["stage"] in {"r2Promotion", "nativeActivation"},
            "nativeRefreshTargetRollbackRequiredIfActivated": stage_decision["stage"] == "nativeActivation",
        },
        "requiredDownstreamProof": _stage_required_downstream_proof(stage_decision["stage"]),
        "sourceLaneEntry": planned_mutation.get("sourceLaneEntry") if planned_mutation else None,
        "legalTermsEntry": planned_mutation.get("legalTermsEntry") if planned_mutation else None,
        "apiPolicyEntry": planned_mutation.get("apiPolicyEntry") if planned_mutation else None,
        "nonClaims": ["operation contract only", "not performed write", "not final user output"],
    }


def _stage_required_downstream_proof(stage: str) -> list[str]:
    mapping = {
        "harvest": ["governed harvest report", "public/reference source-lane proof", "no-private-data scan"],
        "claimExtraction": ["claim graph report", "source citation graph", "forbidden claim exclusion"],
        "adjudication": ["adjudication report", "legal/terms review", "API policy review"],
        "packCompile": ["pack-production report", "non-private scan", "manifest hashes", "revocation/LKG/rollback"],
        "r2Promotion": ["R2 publisher report", "readback checksums", "owner/budget approval", "rollback pointer proof"],
        "nativeActivation": ["native refresh registry report", "verified public manifest", "no-private-egress audit"],
    }
    return mapping[stage]


def _blocked_stage_work(stage_decision: dict[str, Any]) -> dict[str, Any]:
    return {
        "stageDecisionID": stage_decision["stageDecisionID"],
        "stage": stage_decision["stage"],
        "eventID": stage_decision["eventID"],
        "mutationID": stage_decision["mutationID"],
        "status": stage_decision["stageStatus"],
        "blockingReasons": stage_decision["blockingReasons"],
        "coverageCountersAffected": False,
        "r2WritePerformed": False,
        "nativeActivationPerformed": False,
    }


def _activation_approval_template(planned_mutations: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "kind": MISSING_SHARD_ACTIVATION_APPROVAL_KIND,
        "activationApprovalID": stable_id("source_atlas.missing_shard_activation_approval_template", {"createdAt": created_at, "plannedMutations": len(planned_mutations)}),
        "activationStatus": "template_not_approved",
        "reviewOwner": "",
        "reviewedAt": "",
        "publicReferenceOnly": True,
        "privateContextPresent": False,
        "finalOutputAllowed": False,
        "coverageCounterMutationAllowed": False,
        "reversibleActivation": True,
        "selectedMutationIDs": [],
        "stageApprovals": {stage: "required" for stage in ACTIVATION_STAGES},
        "r2WriteApproval": {"allowed": False, "publicReferenceOnly": True, "reversible": True},
        "nativeActivationApproval": {"allowed": False, "verifiedPublicManifestRequired": True, "noPrivateEgressRequired": True},
        "plannedMutations": [
            {
                "mutationID": item.get("mutationID"),
                "eventID": item.get("eventID"),
                "domainID": item.get("domainID"),
                "subdomainID": item.get("subdomainID"),
            }
            for item in planned_mutations
        ],
        "nonClaims": ["template only", "not approval", "not R2 write", "not native activation"],
    }


def _r2_operation_plan(dry_runs: list[dict[str, Any]], executions: list[dict[str, Any]]) -> dict[str, Any]:
    operations = [item for item in [*dry_runs, *executions] if item.get("stage") == "r2Promotion"]
    return {
        "kind": "ambitions.sourceAtlas.missingShardR2OperationPlan.v1",
        "publicReferenceOnly": True,
        "operationCount": len(operations),
        "writeOperationsPerformed": 0,
        "operations": operations,
        "rollbackRequiredIfExecuted": bool(operations),
        "nonClaims": ["not R2 publication proof", "not production R2 upload", "not release readiness"],
    }


def _native_activation_plan(dry_runs: list[dict[str, Any]], executions: list[dict[str, Any]]) -> dict[str, Any]:
    operations = [item for item in [*dry_runs, *executions] if item.get("stage") == "nativeActivation"]
    return {
        "kind": "ambitions.sourceAtlas.missingShardNativeActivationPlan.v1",
        "publicReferenceOnly": True,
        "operationCount": len(operations),
        "nativeActivationOperationsPerformed": 0,
        "operations": operations,
        "verifiedPublicManifestRequired": True,
        "noPrivateEgressRequired": True,
        "nonClaims": ["not native activation proof", "not app runtime readiness", "not final user output"],
    }


def _record_counts(
    *,
    gate_decisions: list[dict[str, Any]],
    planned_mutations: list[dict[str, Any]],
    stage_decisions: list[dict[str, Any]],
    dry_run_operations: list[dict[str, Any]],
    execution_authorizations: list[dict[str, Any]],
) -> dict[str, int]:
    return {
        "reviewGateDecisions": len(gate_decisions),
        "plannedRegistryMutations": len(planned_mutations),
        "stageAuditGates": len(ACTIVATION_STAGES),
        "stageDecisions": len(stage_decisions),
        "blockedStageDecisions": sum(1 for item in stage_decisions if str(item.get("stageStatus", "")).startswith("blocked")),
        "dryRunOperations": len(dry_run_operations),
        "executionAuthorizations": len(execution_authorizations),
        "r2WriteOperations": 0,
        "nativeActivationOperations": 0,
        "activeRegistryMutations": 0,
        "coverageCounterMutations": 0,
        "finalOutputArtifacts": 0,
        "privateContextEvents": 0,
        "claims": 0,
        "packableClaims": 0,
    }


def _active_write_issues(
    options: MissingShardActivationExecutorOptions,
    approval: dict[str, Any],
    execution_authorizations: list[dict[str, Any]],
) -> list[str]:
    issues: list[str] = []
    if options.execute and not approval["valid"]:
        issues.append("execute mode blocked because activation approval is invalid or absent")
    if any(item.get("stage") == "r2Promotion" for item in execution_authorizations) and not options.allow_r2_write:
        issues.append("R2 promotion authorization requires allow_r2_write")
    if any(item.get("stage") == "nativeActivation" for item in execution_authorizations) and not options.allow_native_activation:
        issues.append("native activation authorization requires allow_native_activation")
    return issues


def _checks(
    *,
    review_gate_load_issues: list[str],
    approval_load_issues: list[str],
    input_privacy_issues: list[str],
    approval_privacy_issues: list[str],
    review_gate_issues: list[str],
    activation_approval_validation: dict[str, Any],
    output_privacy_issues: list[str],
    r2_object_key_issues: list[str],
    active_write_issues: list[str],
    record_counts: dict[str, int],
) -> list[dict[str, Any]]:
    approval_ok = (
        not activation_approval_validation["activationApprovalProvided"]
        or activation_approval_validation["valid"]
    )
    return [
        _check("review_gate_loaded", not review_gate_load_issues, review_gate_load_issues, "red"),
        _check("activation_approval_loaded_when_configured", not approval_load_issues, approval_load_issues, "red"),
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues, "red"),
        _check("approval_privacy_scan_passed", not approval_privacy_issues, approval_privacy_issues, "red"),
        _check("review_gate_valid_for_activation", not review_gate_issues, review_gate_issues, "red"),
        _check("activation_approval_valid_when_provided", approval_ok, activation_approval_validation.get("issues", []), "red"),
        _check("stage_contract_covers_every_event_and_stage", record_counts["stageDecisions"] == record_counts["reviewGateDecisions"] * len(ACTIVATION_STAGES), ["stage contract incomplete"], "red"),
        _check("r2_object_keys_public_reference_only", not r2_object_key_issues, r2_object_key_issues, "red"),
        _check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues, "red"),
        _check("active_writes_blocked_without_downstream_proof", record_counts["r2WriteOperations"] == 0 and record_counts["nativeActivationOperations"] == 0 and not active_write_issues, active_write_issues, "red"),
        _check("no_final_outputs_or_coverage_counter_mutations", record_counts["finalOutputArtifacts"] == 0 and record_counts["coverageCounterMutations"] == 0, ["forbidden output or counter mutation emitted"], "red"),
    ]


def _check(name: str, passed: bool, issues: list[str], severity: str) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else sorted(set(issues)), "severity": severity}


def _allowed_claims(valid: bool, record_counts: dict[str, int]) -> list[str]:
    if not valid:
        return []
    claims = ["missing_shard_activation_executor_gate_green", "activation_stages_blocked_until_explicit_approval"]
    if record_counts["dryRunOperations"]:
        claims.append("approved_mutations_have_reversible_dry_run_activation_plan")
    if record_counts["executionAuthorizations"]:
        claims.append("approved_mutations_have_stage_execution_authorizations_without_write_claims")
    return claims


def _status(valid: bool, record_counts: dict[str, int]) -> str:
    if not valid:
        return "Red: missing-shard activation executor failed validation"
    if record_counts["dryRunOperations"] or record_counts["executionAuthorizations"]:
        return "Source Green for missing-shard activation executor / approved dry-run stage contract emitted"
    return "Source Green for missing-shard activation executor / all current activation stages blocked pending approval"


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
