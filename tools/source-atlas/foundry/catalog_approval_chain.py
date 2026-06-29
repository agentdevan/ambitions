"""Serial proof runner for the catalog approval chain.

This runner wires the reviewer-gated catalog flow end to end:

decision inputs -> decision assembler -> approval finalizer -> mutation planner
-> registry applier.

It is intentionally a proof runner, not a shortcut. Missing reviewer completion
artifacts keep the chain valid-but-blocked, while malformed completions make
the chain Red and prevent downstream approval shortcuts.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_decision_assembler import CatalogApprovalDecisionAssemblerOptions, compile_catalog_approval_decision_assembler
from .catalog_approval_finalizer import CatalogApprovalFinalizerOptions, compile_catalog_approval_finalizer
from .catalog_registry_applier import CatalogRegistryApplierOptions, compile_catalog_registry_applier
from .catalog_registry_mutation_plan import CatalogRegistryMutationPlanOptions, compile_catalog_registry_mutation_plan
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


CATALOG_APPROVAL_CHAIN_VERSION = "source-atlas-catalog-approval-chain-train-66"
CATALOG_APPROVAL_CHAIN_KIND = "ambitions.sourceAtlas.catalogApprovalChainProof.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

CHAIN_NON_CLAIMS = [
    "chain proof only",
    "not legal approval by itself",
    "not outside legal approval without outside approval artifact",
    "not source authority without completed reviewer fields",
    "not production registry mutation",
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
class CatalogApprovalChainOptions:
    decision_inputs_path: Path
    terms_proposals_path: Path
    draft_governance_packets_path: Path
    output_root: Path
    review_completion_path: Path | None = None
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    execute_registry_apply: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def run_catalog_approval_chain(options: CatalogApprovalChainOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    assembler = compile_catalog_approval_decision_assembler(
        CatalogApprovalDecisionAssemblerOptions(
            decision_inputs_path=options.decision_inputs_path,
            output_root=output_root / "01-decision-assembler",
            review_completion_path=options.review_completion_path,
            created_at=created_at,
        )
    )
    finalizer_decision_path = Path(assembler["outputPaths"]["finalizerDecisionArtifact"])
    finalizer_decision = finalizer_decision_path if assembler["recordCounts"]["completedDecisionArtifacts"] > 0 and assembler["valid"] else None

    finalizer = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=options.terms_proposals_path,
            output_root=output_root / "02-approval-finalizer",
            decision_artifact=finalizer_decision,
            created_at=created_at,
        )
    )
    planner_approval_path = Path(finalizer["outputPaths"]["plannerApprovalArtifact"])
    planner_approval = planner_approval_path if finalizer["recordCounts"]["completedApprovalArtifacts"] > 0 and finalizer["valid"] else None

    mutation_plan = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=options.draft_governance_packets_path,
            output_root=output_root / "03-mutation-plan",
            approval_artifact=planner_approval,
            execute=options.execute_registry_apply,
            created_at=created_at,
        )
    )
    applier = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=Path(mutation_plan["outputPaths"]["plannedRegistryMutations"]),
            output_root=output_root / "04-registry-applier",
            source_lane_registry_path=options.source_lane_registry_path,
            legal_terms_registry_path=options.legal_terms_registry_path,
            api_governance_registry_path=options.api_governance_registry_path,
            execute=options.execute_registry_apply,
            allow_active_registry_write=options.allow_active_registry_write,
            created_at=created_at,
        )
    )

    stage_results = {
        "decisionAssembler": _stage_summary(assembler),
        "approvalFinalizer": _stage_summary(finalizer),
        "mutationPlan": _stage_summary(mutation_plan),
        "registryApplier": _stage_summary(applier),
    }
    stage_privacy_issues = privacy_findings_for_value(stage_results, "catalog-approval-chain-stage-results")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(stage_results) else []
    malformed_completion = options.review_completion_path is not None and not assembler["valid"]
    checks = [
        {"name": "decision_assembler_valid", "passed": assembler["valid"], "issues": assembler.get("issues", [])},
        {"name": "approval_finalizer_valid", "passed": finalizer["valid"], "issues": finalizer.get("issues", [])},
        {"name": "mutation_plan_valid", "passed": mutation_plan["valid"], "issues": mutation_plan.get("issues", [])},
        {"name": "registry_applier_valid", "passed": applier["valid"], "issues": applier.get("issues", [])},
        {
            "name": "missing_completion_blocks_without_red",
            "passed": bool(options.review_completion_path)
            or assembler["recordCounts"]["completedDecisionArtifacts"] == 0
            and finalizer["recordCounts"]["completedApprovalArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "provided_completion_must_be_valid",
            "passed": not malformed_completion,
            "issues": assembler.get("issues", []) if malformed_completion else [],
        },
        {
            "name": "chain_emits_no_claims_or_packs",
            "passed": _count(applier, "claims") == 0
            and _count(applier, "packableClaims") == 0
            and _count(applier, "r2PackableArtifacts") == 0
            and _count(mutation_plan, "claims") == 0
            and _count(finalizer, "claims") == 0
            and _count(assembler, "claims") == 0,
            "issues": [],
        },
        {"name": "stage_privacy_scan_passed", "passed": not stage_privacy_issues, "issues": stage_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]
    issues: list[str] = []
    issues.extend(stage_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    report = {
        "schemaVersion": 1,
        "kind": CATALOG_APPROVAL_CHAIN_KIND,
        "versionID": CATALOG_APPROVAL_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog approval chain proof tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; approval chain proof tooling only",
        "inputs": {
            "decisionInputsPath": str(options.decision_inputs_path),
            "termsProposalsPath": str(options.terms_proposals_path),
            "draftGovernancePacketsPath": str(options.draft_governance_packets_path),
            "reviewCompletionPath": str(options.review_completion_path) if options.review_completion_path else "",
        },
        "executeRegistryApply": options.execute_registry_apply,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "stageResults": stage_results,
        "recordCounts": {
            "decisionInputPackets": _count(assembler, "decisionInputPackets"),
            "completedDecisionArtifacts": _count(assembler, "completedDecisionArtifacts"),
            "completedApprovalArtifacts": _count(finalizer, "completedApprovalArtifacts"),
            "plannedRegistryMutations": _count(mutation_plan, "plannedRegistryMutations"),
            "candidateRegistryMutations": _count(applier, "candidateRegistryMutations"),
            "blockedDecisionAssemblies": _count(assembler, "blockedDecisionAssemblies"),
            "blockedApprovalFinalizations": _count(finalizer, "blockedApprovalFinalizations"),
            "blockedRegistryMutations": _count(mutation_plan, "blockedRegistryMutations") + _count(applier, "blockedRegistryMutations"),
            "activeRegistryMutations": _count(applier, "activeRegistryMutations"),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "report": str(output_root / "catalog-approval-chain-proof.json"),
            "closeout": str(output_root / "closeout.md"),
            "decisionAssembler": assembler["outputRoot"],
            "approvalFinalizer": finalizer["outputRoot"],
            "mutationPlan": mutation_plan["outputRoot"],
            "registryApplier": applier["outputRoot"],
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": CHAIN_NON_CLAIMS,
    }
    report_privacy_issues = privacy_findings_for_value(report, "catalog-approval-chain-proof")
    if report_privacy_issues:
        report["valid"] = False
        report["status"] = "Red"
        report["issues"] = sorted(set([*report["issues"], *report_privacy_issues]))
        report["checks"].append({"name": "report_privacy_scan_passed", "passed": False, "issues": report_privacy_issues})
    else:
        report["checks"].append({"name": "report_privacy_scan_passed", "passed": True, "issues": []})

    write_json(output_root / "catalog-approval-chain-proof.json", report)
    report["outputHashes"] = {"report": stable_hash(read_json(output_root / "catalog-approval-chain-proof.json"))}
    write_json(output_root / "catalog-approval-chain-proof.json", report)
    (output_root / "closeout.md").write_text(catalog_approval_chain_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "catalog-approval-chain-proof.json"), "outputRoot": str(output_root), **report}


def write_catalog_approval_chain_report(
    markdown_path: Path,
    json_path: Path,
    *,
    decision_inputs_path: Path,
    terms_proposals_path: Path,
    draft_governance_packets_path: Path,
    output_root: Path,
    review_completion_path: Path | None = None,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    execute_registry_apply: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=decision_inputs_path,
            terms_proposals_path=terms_proposals_path,
            draft_governance_packets_path=draft_governance_packets_path,
            output_root=output_root,
            review_completion_path=review_completion_path,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            execute_registry_apply=execute_registry_apply,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_approval_chain_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_approval_chain_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Approval Chain Train 66",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Execute registry apply: {result['executeRegistryApply']}",
        "",
        "Scope completed:",
        "- Serial proof runner for assembler -> finalizer -> mutation planner -> registry applier.",
        "- Missing reviewer completions keep the chain blocked without emitting approvals.",
        "- Malformed reviewer completions fail the chain before approval shortcuts can occur.",
        "",
        "Counts:",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Completed decision artifacts: {counts['completedDecisionArtifacts']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Candidate registry mutations: {counts['candidateRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Registry writes remain gated by the applier execute and validation gates.",
        "- Outside legal approval is not claimed without outside legal approval artifact.",
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
            "- Chain outputs only public/reference governance evidence.",
            "",
            "No private graph egress proof:",
            "- Stage and report privacy scans must pass before Source Green.",
            "- The chain emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Completed legal/terms entries require explicit source-specific reviewer completion fields.",
            "- Outside legal approval is not claimed without outside legal approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Public catalog/source-of-sources authority remains rejected by finalizer validation.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 66. This train proves governance chain behavior only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane review/freshness fields are required by finalizer validation.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer changed. Rollback is artifact removal unless an explicit temp registry apply was requested.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 66. No native files are touched by this chain runner.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _stage_summary(stage: dict[str, Any]) -> dict[str, Any]:
    return {
        "status": stage.get("status"),
        "valid": stage.get("valid"),
        "recordCounts": stage.get("recordCounts", {}),
        "issues": stage.get("issues", []),
        "outputRoot": stage.get("outputRoot", ""),
        "manifestPath": stage.get("manifestPath", ""),
        "outputPaths": stage.get("outputPaths", {}),
    }


def _count(stage: dict[str, Any], name: str) -> int:
    value = stage.get("recordCounts", {}).get(name, 0)
    return value if isinstance(value, int) else 0


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
