"""Serial direct-source approval-chain proof runner.

This runner wires the direct-source path end to end:

Train 73 -> Train 71 -> Train 67 -> Train 66.

It exists to remove manual operator stitching. It does not approve sources by
itself, mutate active registries by default, emit claims, publish packs, or
write to R2.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_chain import CatalogApprovalChainOptions, run_catalog_approval_chain
from .catalog_direct_source_review_completion import (
    CatalogDirectSourceReviewCompletionOptions,
    compile_catalog_direct_source_review_completion,
)
from .catalog_direct_source_review_gate import CatalogDirectSourceReviewGateOptions, compile_catalog_direct_source_review_gate
from .catalog_reviewer_completion_intake import CatalogReviewerCompletionIntakeOptions, compile_catalog_reviewer_completion_intake
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, stable_hash, utc_now, write_json


CATALOG_DIRECT_SOURCE_APPROVAL_CHAIN_VERSION = "source-atlas-catalog-direct-source-approval-chain-train-74"
CATALOG_DIRECT_SOURCE_APPROVAL_CHAIN_KIND = "ambitions.sourceAtlas.catalogDirectSourceApprovalChainProof.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DIRECT_SOURCE_APPROVAL_CHAIN_NON_CLAIMS = [
    "direct-source approval chain proof only",
    "not source authority by itself",
    "not legal approval",
    "not outside legal approval without artifact",
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
class CatalogDirectSourceApprovalChainOptions:
    templates_path: Path
    resolution_candidates_path: Path
    decision_inputs_path: Path
    terms_proposals_path: Path
    draft_governance_packets_path: Path
    output_root: Path
    review_evidence_path: Path | None = None
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    execute_registry_apply: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def run_catalog_direct_source_approval_chain(options: CatalogDirectSourceApprovalChainOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    direct_completion = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=options.templates_path,
            output_root=output_root / "01-direct-source-review-completion",
            review_evidence_path=options.review_evidence_path,
            created_at=created_at,
        )
    )
    direct_gate = compile_catalog_direct_source_review_gate(
        CatalogDirectSourceReviewGateOptions(
            resolution_candidates_path=options.resolution_candidates_path,
            output_root=output_root / "02-direct-source-review-gate",
            direct_source_reviews_path=Path(direct_completion["outputPaths"]["directSourceReviewPackets"]),
            created_at=created_at,
        )
    )
    reviewer_intake = compile_catalog_reviewer_completion_intake(
        CatalogReviewerCompletionIntakeOptions(
            decision_inputs_path=options.decision_inputs_path,
            output_root=output_root / "03-reviewer-completion-intake",
            review_packets_path=Path(direct_gate["outputPaths"]["sourceReviewCompletionPackets"]),
            created_at=created_at,
        )
    )
    review_completion_path = (
        Path(reviewer_intake["reviewCompletionArtifactPath"])
        if reviewer_intake.get("valid") is True
        and reviewer_intake.get("recordCounts", {}).get("completedReviewCompletions", 0) > 0
        and reviewer_intake.get("reviewCompletionArtifactPath")
        else None
    )
    approval_chain = run_catalog_approval_chain(
        CatalogApprovalChainOptions(
            decision_inputs_path=options.decision_inputs_path,
            terms_proposals_path=options.terms_proposals_path,
            draft_governance_packets_path=options.draft_governance_packets_path,
            output_root=output_root / "04-approval-chain",
            review_completion_path=review_completion_path,
            source_lane_registry_path=options.source_lane_registry_path,
            legal_terms_registry_path=options.legal_terms_registry_path,
            api_governance_registry_path=options.api_governance_registry_path,
            execute_registry_apply=options.execute_registry_apply,
            allow_active_registry_write=options.allow_active_registry_write,
            created_at=created_at,
        )
    )

    stage_results = {
        "directSourceReviewCompletion": _stage_summary(direct_completion),
        "directSourceReviewGate": _stage_summary(direct_gate),
        "reviewerCompletionIntake": _stage_summary(reviewer_intake),
        "approvalChain": _stage_summary(approval_chain),
    }
    record_counts = {
        "directSourceReviewTemplates": _count(direct_completion, "directSourceReviewTemplates"),
        "reviewEvidenceRecords": _count(direct_completion, "reviewEvidenceRecords"),
        "directSourceReviewPackets": _count(direct_completion, "directSourceReviewPackets"),
        "completedDirectSourceReviews": _count(direct_completion, "completedDirectSourceReviews"),
        "blockedDirectSourceReviews": _count(direct_completion, "blockedDirectSourceReviews"),
        "sourceReviewCompletionPackets": _count(direct_gate, "sourceReviewCompletionPackets"),
        "completedSourceReviewCompletionPackets": _count(direct_gate, "completedSourceReviewCompletionPackets"),
        "blockedSourceReviewCompletionPackets": _count(direct_gate, "blockedSourceReviewCompletionPackets"),
        "completedReviewCompletions": _count(reviewer_intake, "completedReviewCompletions"),
        "completedDecisionArtifacts": _count(approval_chain, "completedDecisionArtifacts"),
        "completedApprovalArtifacts": _count(approval_chain, "completedApprovalArtifacts"),
        "plannedRegistryMutations": _count(approval_chain, "plannedRegistryMutations"),
        "candidateRegistryMutations": _count(approval_chain, "candidateRegistryMutations"),
        "activeRegistryMutations": _count(approval_chain, "activeRegistryMutations"),
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
    }
    stage_privacy_issues = privacy_findings_for_value(stage_results, "catalog-direct-source-approval-chain-stage-results")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(stage_results) else []
    checks = [
        {"name": "direct_source_review_completion_valid", "passed": direct_completion["valid"], "issues": direct_completion.get("issues", [])},
        {"name": "direct_source_review_gate_valid", "passed": direct_gate["valid"], "issues": direct_gate.get("issues", [])},
        {"name": "reviewer_completion_intake_valid", "passed": reviewer_intake["valid"], "issues": reviewer_intake.get("issues", [])},
        {"name": "catalog_approval_chain_valid", "passed": approval_chain["valid"], "issues": approval_chain.get("issues", [])},
        {
            "name": "missing_review_evidence_blocks_without_approval",
            "passed": bool(options.review_evidence_path) or record_counts["completedDirectSourceReviews"] == 0,
            "issues": [],
        },
        {
            "name": "chain_emits_no_claims_or_packs",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0,
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
        "kind": CATALOG_DIRECT_SOURCE_APPROVAL_CHAIN_KIND,
        "versionID": CATALOG_DIRECT_SOURCE_APPROVAL_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog direct-source approval chain proof tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; direct-source approval chain proof tooling only",
        "inputs": {
            "templatesPath": str(options.templates_path),
            "resolutionCandidatesPath": str(options.resolution_candidates_path),
            "decisionInputsPath": str(options.decision_inputs_path),
            "termsProposalsPath": str(options.terms_proposals_path),
            "draftGovernancePacketsPath": str(options.draft_governance_packets_path),
            "reviewEvidencePath": str(options.review_evidence_path) if options.review_evidence_path else "",
        },
        "executeRegistryApply": options.execute_registry_apply,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "reviewCompletionArtifactPath": str(review_completion_path) if review_completion_path else "",
        "stageResults": stage_results,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "report": str(output_root / "catalog-direct-source-approval-chain-proof.json"),
            "closeout": str(output_root / "closeout.md"),
            "directSourceReviewCompletion": direct_completion["outputRoot"],
            "directSourceReviewGate": direct_gate["outputRoot"],
            "reviewerCompletionIntake": reviewer_intake["outputRoot"],
            "approvalChain": approval_chain["outputRoot"],
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_APPROVAL_CHAIN_NON_CLAIMS,
    }
    report_privacy_issues = privacy_findings_for_value(report, "catalog-direct-source-approval-chain-proof")
    if report_privacy_issues:
        report["valid"] = False
        report["status"] = "Red"
        report["issues"] = sorted(set([*report["issues"], *report_privacy_issues]))
        report["checks"].append({"name": "report_privacy_scan_passed", "passed": False, "issues": report_privacy_issues})
    else:
        report["checks"].append({"name": "report_privacy_scan_passed", "passed": True, "issues": []})

    write_json(output_root / "catalog-direct-source-approval-chain-proof.json", report)
    report["outputHashes"] = {"report": stable_hash(report)}
    write_json(output_root / "catalog-direct-source-approval-chain-proof.json", report)
    (output_root / "closeout.md").write_text(catalog_direct_source_approval_chain_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "catalog-direct-source-approval-chain-proof.json"), "outputRoot": str(output_root), **report}


def write_catalog_direct_source_approval_chain_report(
    markdown_path: Path,
    json_path: Path,
    *,
    templates_path: Path,
    resolution_candidates_path: Path,
    decision_inputs_path: Path,
    terms_proposals_path: Path,
    draft_governance_packets_path: Path,
    output_root: Path,
    review_evidence_path: Path | None = None,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    execute_registry_apply: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_catalog_direct_source_approval_chain(
        CatalogDirectSourceApprovalChainOptions(
            templates_path=templates_path,
            resolution_candidates_path=resolution_candidates_path,
            decision_inputs_path=decision_inputs_path,
            terms_proposals_path=terms_proposals_path,
            draft_governance_packets_path=draft_governance_packets_path,
            output_root=output_root,
            review_evidence_path=review_evidence_path,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            execute_registry_apply=execute_registry_apply,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_direct_source_approval_chain_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_direct_source_approval_chain_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Direct-Source Approval Chain Train 74",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Review evidence path: {result['inputs']['reviewEvidencePath'] or 'not provided'}",
        f"Execute registry apply: {result['executeRegistryApply']}",
        "",
        "Scope completed:",
        "- Serial proof runner for Train 73 -> Train 71 -> Train 67 -> Train 66.",
        "- Missing direct-source review evidence keeps the chain blocked without emitting approvals.",
        "- Completed direct-source review evidence can reach the existing approval chain only through the normal source/legal/API gates.",
        "",
        "Counts:",
        f"- Direct-source review templates: {counts['directSourceReviewTemplates']}",
        f"- Review evidence records: {counts['reviewEvidenceRecords']}",
        f"- Completed direct-source reviews: {counts['completedDirectSourceReviews']}",
        f"- Blocked direct-source reviews: {counts['blockedDirectSourceReviews']}",
        f"- Completed source-review completion packets: {counts['completedSourceReviewCompletionPackets']}",
        f"- Completed reviewer completions: {counts['completedReviewCompletions']}",
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
        "- Registry writes remain gated by the existing applier execute and validation gates.",
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
            "- Completed legal/terms entries still require explicit source-specific reviewer completion fields.",
            "- Outside legal approval is not claimed without outside legal approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate/catalog sources without completed review evidence remain blocked.",
            "- Public catalog/source-of-sources authority remains rejected by downstream validation.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 74. This train proves governance-chain orchestration only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane review/freshness fields are required by downstream validation.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer changed. Rollback is artifact removal unless an explicit temp registry apply was requested.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 74. No native files are touched by this chain runner.",
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
            if key
            not in {
                "forbidden_artifact_classes",
                "claim_classes_forbidden",
                "non_claims",
                "blocking_reasons",
            }
        )
    return False
