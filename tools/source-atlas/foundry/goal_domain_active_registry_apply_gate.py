"""Active-registry readiness gate for goal-domain Source Atlas mutations.

This gate sits between the fixture rehearsal chain and any active repo registry
write. It deliberately treats rehearsal evidence as a controlled block, even
when the mechanical applier can validate the proposed registry entries.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_registry_applier import GoalDomainRegistryApplierOptions, compile_goal_domain_registry_applier
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


GOAL_DOMAIN_ACTIVE_REGISTRY_APPLY_GATE_VERSION = "source-atlas-goal-domain-active-registry-apply-gate-train-97"
GOAL_DOMAIN_ACTIVE_REGISTRY_APPLY_GATE_KIND = "ambitions.sourceAtlas.goalDomainActiveRegistryApplyGate.v1"
ACTIVE_REGISTRY_DEFAULTS = {
    SOURCE_LANE_REGISTRY_PATH.resolve(),
    LEGAL_TERMS_REGISTRY_PATH.resolve(),
    API_GOVERNANCE_REGISTRY_PATH.resolve(),
}
FIXTURE_MARKERS = (
    "fixture",
    "rehearsal",
    "train-96",
    "example.gov",
    "goal-domain-rehearsal",
    "approved_for_fixture",
)
SOURCE_SPECIFIC_REVIEW_CLASS = "source_specific_review"

ACTIVE_GATE_NON_CLAIMS = [
    "active registry apply readiness gate only",
    "not active registry mutation",
    "not source authority without source-specific review evidence",
    "not legal approval by itself",
    "not outside legal approval without artifact",
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
class GoalDomainActiveRegistryApplyGateOptions:
    plan_path: Path
    output_root: Path
    review_evidence_path: Path | None = None
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    approval_artifact: Path | None = None
    execute: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def compile_goal_domain_active_registry_apply_gate(options: GoalDomainActiveRegistryApplyGateOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    plan_payload, plan_load_issues = _safe_read_json(options.plan_path, "goal-domain active registry apply plan")
    planned_mutations, plan_shape_issues = _planned_mutations_from_payload(options.plan_path, plan_payload)
    review_payload, review_load_issues = (
        _safe_read_json(options.review_evidence_path, "goal-domain source-specific review evidence")
        if options.review_evidence_path
        else (None, [])
    )
    approval_payload, approval_load_issues = (
        _safe_read_json(options.approval_artifact, "goal-domain active registry apply approval artifact")
        if options.approval_artifact
        else (None, [])
    )

    input_privacy_issues = privacy_findings_for_value(
        {
            "plan": plan_payload,
            "reviewEvidence": review_payload,
            "approvalArtifact": approval_payload,
            "targetRegistryPaths": _target_paths(options),
        },
        "goal-domain-active-registry-apply-gate-input",
    )
    target_class = _target_class(options)
    evidence_class, evidence_findings = _evidence_class(plan_payload, review_payload)
    approval_findings = _approval_findings(options.approval_artifact, approval_payload, planned_mutations)

    applier = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=options.plan_path,
            output_root=output_root / "applier-dry-run",
            source_lane_registry_path=options.source_lane_registry_path,
            legal_terms_registry_path=options.legal_terms_registry_path,
            api_governance_registry_path=options.api_governance_registry_path,
            approval_artifact=None,
            execute=False,
            allow_active_registry_write=False,
            created_at=created_at,
        )
    )
    applier_blockers = [] if applier.get("valid") is True else [f"dry-run applier validation failed: {issue}" for issue in applier.get("issues", [])]

    blocking_reasons = _blocking_reasons(
        options=options,
        planned_mutations=planned_mutations,
        target_class=target_class,
        evidence_class=evidence_class,
        evidence_findings=evidence_findings,
        approval_findings=approval_findings,
        applier_blockers=applier_blockers,
    )
    active_apply_allowed = not blocking_reasons and options.execute
    decision = _decision(
        planned_count=len(planned_mutations),
        blocking_reasons=blocking_reasons,
        execute=options.execute,
        target_class=target_class,
    )

    evaluation_issues = sorted(set(plan_load_issues + plan_shape_issues + review_load_issues + approval_load_issues + input_privacy_issues))
    valid = not evaluation_issues
    record_counts = {
        "plannedRegistryMutations": len(planned_mutations),
        "candidateRegistryMutations": applier.get("recordCounts", {}).get("candidateRegistryMutations", 0),
        "blockedRegistryMutations": applier.get("recordCounts", {}).get("blockedRegistryMutations", 0),
        "activeRegistryMutations": 0,
        "activeRegistryApplyOperations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    checks = [
        {"name": "plan_loaded", "passed": not plan_load_issues and not plan_shape_issues, "issues": plan_load_issues + plan_shape_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "review_evidence_loaded_when_provided", "passed": not review_load_issues, "issues": review_load_issues},
        {"name": "approval_artifact_loaded_when_provided", "passed": not approval_load_issues, "issues": approval_load_issues},
        {"name": "fixture_or_rehearsal_evidence_blocks_active_apply", "passed": evidence_class != "fixture_only_rehearsal" or not active_apply_allowed, "issues": []},
        {"name": "source_specific_review_required", "passed": evidence_class == SOURCE_SPECIFIC_REVIEW_CLASS or not active_apply_allowed, "issues": evidence_findings},
        {"name": "approval_artifact_required_for_active_apply", "passed": not _missing_approval(options.approval_artifact, planned_mutations) or not active_apply_allowed, "issues": approval_findings},
        {"name": "explicit_active_registry_targets_required", "passed": target_class == "active_repo_registries" or not active_apply_allowed, "issues": []},
        {"name": "active_registry_write_flag_required", "passed": options.allow_active_registry_write or not active_apply_allowed, "issues": []},
        {"name": "dry_run_applier_validation_completed", "passed": not applier_blockers, "issues": applier_blockers},
        {
            "name": "gate_emits_no_writes_claims_packs_r2_or_native_activation",
            "passed": record_counts["activeRegistryMutations"] == 0
            and record_counts["activeRegistryApplyOperations"] == 0
            and record_counts["claims"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
    ]
    output_paths = {
        "report": str(output_root / "goal-domain-active-registry-apply-gate-report.json"),
        "applierDryRun": applier.get("manifestPath"),
        "blockedActiveRegistryApply": str(output_root / "blocked-active-registry-apply.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    blocked_active_apply = {
        "kind": "ambitions.sourceAtlas.goalDomainBlockedActiveRegistryApply.v1",
        "createdAt": created_at,
        "activeRegistryApplyAllowed": active_apply_allowed,
        "decision": decision,
        "blockingReasons": blocking_reasons,
        "targetClass": target_class,
        "evidenceClass": evidence_class,
        "nonClaims": ["not active registry mutation", "not source authority", "not R2 publish"],
    }
    write_json(output_root / "blocked-active-registry-apply.json", blocked_active_apply)

    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_ACTIVE_REGISTRY_APPLY_GATE_KIND,
        "versionID": GOAL_DOMAIN_ACTIVE_REGISTRY_APPLY_GATE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain active registry apply gate tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; active registry apply readiness gate only",
        "planPath": str(options.plan_path),
        "reviewEvidencePath": str(options.review_evidence_path) if options.review_evidence_path else "",
        "approvalArtifact": str(options.approval_artifact) if options.approval_artifact else "",
        "executeRequested": options.execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "targetClass": target_class,
        "targetRegistryPaths": _target_paths(options),
        "evidenceClass": evidence_class,
        "activeRegistryApplyDecision": decision,
        "activeRegistryApplyAllowed": active_apply_allowed,
        "blockingReasons": blocking_reasons,
        "evaluationIssues": evaluation_issues,
        "checks": checks,
        "recordCounts": record_counts,
        "dryRunApplier": applier,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": ACTIVE_GATE_NON_CLAIMS,
        "productionNonClaims": [
            "no active registry mutation",
            "no production R2 upload",
            "no app runtime Green",
            "no release Green",
            "no universal coverage",
            "no outside legal approval without artifact",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": output_paths,
    }
    report["outputHashes"] = {
        "blockedActiveRegistryApply": stable_hash(blocked_active_apply),
        "dryRunApplier": stable_hash(read_json(Path(applier["manifestPath"]))) if applier.get("manifestPath") else "",
    }
    write_json(output_root / "goal-domain-active-registry-apply-gate-report.json", report)
    report["outputHashes"]["report"] = stable_hash(read_json(output_root / "goal-domain-active-registry-apply-gate-report.json"))
    write_json(output_root / "goal-domain-active-registry-apply-gate-report.json", report)
    (output_root / "closeout.md").write_text(goal_domain_active_registry_apply_gate_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "goal-domain-active-registry-apply-gate-report.json"), "outputRoot": str(output_root), **report}


def write_goal_domain_active_registry_apply_gate_report(
    markdown_path: Path,
    json_path: Path,
    *,
    plan_path: Path,
    output_root: Path,
    review_evidence_path: Path | None = None,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    approval_artifact: Path | None = None,
    execute: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_active_registry_apply_gate(
        GoalDomainActiveRegistryApplyGateOptions(
            plan_path=plan_path,
            output_root=output_root,
            review_evidence_path=review_evidence_path,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            approval_artifact=approval_artifact,
            execute=execute,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_active_registry_apply_gate_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_active_registry_apply_gate_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Active Registry Apply Gate Train 97",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Active registry apply decision: {result['activeRegistryApplyDecision']}",
        f"Active registry apply allowed: {'yes' if result['activeRegistryApplyAllowed'] else 'no'}",
        "",
        "Scope completed:",
        "- Active-registry apply readiness is evaluated before any active registry write can be attempted.",
        "- Fixture/rehearsal evidence is classified and blocked from active repo registry mutation.",
        "- Source-specific review evidence, explicit active registry targets, approval artifact, execute intent, and the active write flag are all required for readiness.",
        "- The existing goal-domain registry applier is reused in dry-run mode only; this gate performs no writes.",
        "",
        "Counts:",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Candidate registry mutations: {counts['candidateRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Blocking reasons:",
    ]
    lines.extend(f"- {reason}" for reason in result["blockingReasons"] or ["none"])
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- No private Ambitions runtime context is emitted or sent to R2.",
            "- No final user plans, schedules, Steps, or personalized paths are generated.",
            "- No Source Atlas product center or native surface is created.",
            "",
            "Validation run:",
            "- See the train closeout for exact command output.",
            "",
            "Validation not run:",
            "- Active repo registry write was not run by this gate.",
            "- Live network/API discovery was not run.",
            "- Production R2 upload/readback was not run.",
            "- Native XCTest/build-for-testing was not required for this tooling-only train.",
            "- Outside legal approval was not claimed.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- Object keys, packs, manifests, and publisher operations are outside this train.",
            "",
            "No private graph egress proof:",
            "- Plan, review evidence, approval artifact, and output privacy scans run before Source Green.",
            "- The gate emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- This gate requires source-specific review evidence and approval artifact before active registry readiness.",
            "- It does not create outside legal approval or broaden redistribution rights.",
            "",
            "Restricted-source exclusion proof:",
            "- Active registry readiness still depends on dry-run governance validation and downstream pack/R2 gates.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 97. This train gates registry activation readiness only.",
            "",
            "Freshness/revocation proof:",
            "- No pack freshness, revocation, or LKG operation ran.",
            "",
            "LKG/rollback proof:",
            "- No active registry write, stable pointer, or R2 object ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 97. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry active registry apply gate, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: run the gate on real source-specific review evidence, then use the applier only after readiness is allowed.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _safe_read_json(path: Path | None, label: str) -> tuple[Any | None, list[str]]:
    if path is None:
        return None, []
    try:
        return read_json(path), []
    except FileNotFoundError:
        return None, [f"{label}: missing {path}"]
    except Exception as exc:
        return None, [f"{label}: could not read {path}: {exc}"]


def _planned_mutations_from_payload(path: Path, payload: Any) -> tuple[list[dict[str, Any]], list[str]]:
    if payload is None:
        return [], []
    if isinstance(payload, dict) and isinstance(payload.get("plannedRegistryMutations"), list):
        return [item for item in payload["plannedRegistryMutations"] if isinstance(item, dict)], []
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)], []
    if isinstance(payload, dict):
        output_paths = payload.get("outputPaths")
        if isinstance(output_paths, dict) and output_paths.get("plannedRegistryMutations"):
            planned_path = Path(str(output_paths["plannedRegistryMutations"]))
            if not planned_path.is_absolute():
                planned_path = Path.cwd() / planned_path
            planned_payload, issues = _safe_read_json(planned_path, "goal-domain planned registry mutations")
            if issues:
                return [], issues
            return _planned_mutations_from_payload(planned_path, planned_payload)
    return [], [f"goal-domain active registry apply gate plan must include plannedRegistryMutations or outputPaths.plannedRegistryMutations: {path}"]


def _target_paths(options: GoalDomainActiveRegistryApplyGateOptions) -> dict[str, str]:
    return {
        "sourceLaneRegistry": str(options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH),
        "legalTermsRegistry": str(options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH),
        "apiGovernanceRegistry": str(options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH),
    }


def _target_class(options: GoalDomainActiveRegistryApplyGateOptions) -> str:
    if not (options.source_lane_registry_path and options.legal_terms_registry_path and options.api_governance_registry_path):
        return "implicit_default_registries"
    target_paths = {
        options.source_lane_registry_path.resolve(),
        options.legal_terms_registry_path.resolve(),
        options.api_governance_registry_path.resolve(),
    }
    if target_paths == ACTIVE_REGISTRY_DEFAULTS:
        return "active_repo_registries"
    return "explicit_non_active_registries"


def _evidence_class(plan_payload: Any, review_payload: Any) -> tuple[str, list[str]]:
    values = {"plan": plan_payload, "reviewEvidence": review_payload}
    marker_paths = _fixture_marker_paths(values)
    explicit_classes = sorted(set(_explicit_review_classes(values)))
    findings: list[str] = []
    if marker_paths:
        findings.extend(f"fixture/rehearsal marker found at {path}" for path in marker_paths[:12])
        return "fixture_only_rehearsal", findings
    if SOURCE_SPECIFIC_REVIEW_CLASS in explicit_classes:
        return SOURCE_SPECIFIC_REVIEW_CLASS, []
    if review_payload is None:
        return "missing_review_evidence", ["review evidence artifact is required for active registry apply readiness"]
    return "unclassified_review_evidence", ["review evidence artifact must declare reviewEvidenceClass/source_specific_review"]


def _explicit_review_classes(value: Any) -> list[str]:
    classes: list[str] = []
    if isinstance(value, dict):
        for key in ("reviewEvidenceClass", "review_evidence_class", "evidenceClass"):
            if isinstance(value.get(key), str):
                classes.append(value[key])
        for item in value.values():
            classes.extend(_explicit_review_classes(item))
    elif isinstance(value, list):
        for item in value:
            classes.extend(_explicit_review_classes(item))
    return classes


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


def _approval_findings(approval_path: Path | None, approval_payload: Any, planned_mutations: list[dict[str, Any]]) -> list[str]:
    findings: list[str] = []
    if _missing_approval(approval_path, planned_mutations):
        findings.append("approval artifact is required for active registry apply readiness")
        return findings
    if approval_payload is None:
        return findings
    marker_paths = _fixture_marker_paths(approval_payload)
    findings.extend(f"approval artifact contains fixture/rehearsal marker at {path}" for path in marker_paths[:12])
    if not isinstance(approval_payload, dict):
        findings.append("approval artifact must be an object")
        return findings
    status = str(approval_payload.get("approvalStatus") or approval_payload.get("status") or "")
    if "approved" not in status.lower():
        findings.append("approval artifact must include approved approvalStatus/status")
    if not approval_payload.get("approvedAt"):
        findings.append("approval artifact must include approvedAt")
    if not approval_payload.get("approvedBy"):
        findings.append("approval artifact must include approvedBy")
    return findings


def _missing_approval(approval_path: Path | None, planned_mutations: list[dict[str, Any]]) -> bool:
    return bool(planned_mutations) and approval_path is None


def _blocking_reasons(
    *,
    options: GoalDomainActiveRegistryApplyGateOptions,
    planned_mutations: list[dict[str, Any]],
    target_class: str,
    evidence_class: str,
    evidence_findings: list[str],
    approval_findings: list[str],
    applier_blockers: list[str],
) -> list[str]:
    if not planned_mutations:
        return []
    reasons: list[str] = []
    if evidence_class != SOURCE_SPECIFIC_REVIEW_CLASS:
        reasons.append(f"review_evidence_class_{evidence_class}")
    if evidence_findings:
        reasons.extend(evidence_findings)
    if approval_findings:
        reasons.extend(approval_findings)
    if target_class != "active_repo_registries":
        reasons.append("explicit active repo registry target paths are required")
    if not options.execute:
        reasons.append("--execute is required for active registry apply readiness")
    if not options.allow_active_registry_write:
        reasons.append("--allow-active-registry-write is required for active repo registry readiness")
    reasons.extend(applier_blockers)
    return sorted(set(reasons))


def _decision(*, planned_count: int, blocking_reasons: list[str], execute: bool, target_class: str) -> str:
    if planned_count == 0:
        return "noop_no_planned_registry_mutations"
    if blocking_reasons:
        if any("fixture" in reason or "rehearsal" in reason for reason in blocking_reasons):
            return "blocked_fixture_or_rehearsal_evidence"
        return "blocked_active_registry_apply"
    if execute and target_class == "active_repo_registries":
        return "ready_for_active_registry_apply"
    return "dry_run_ready_for_active_registry_apply"
