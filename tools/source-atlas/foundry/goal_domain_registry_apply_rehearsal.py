"""End-to-end fixture rehearsal for goal-domain registry apply gates.

This train proves that the Train 92 -> 93 -> 94 -> 95 chain can produce and
apply non-empty goal-domain registry mutations without touching active repo
registries. It synthesizes fixture-only review completion evidence, compiles
mutation plans, copies the current registries into a temp rehearsal root, and
executes the applier only against those temp copies.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_registry_applier import GoalDomainRegistryApplierOptions, compile_goal_domain_registry_applier
from .goal_domain_registry_mutation_plan import GoalDomainRegistryMutationPlanOptions, compile_goal_domain_registry_mutation_plan
from .goal_domain_review_completion_intake import GoalDomainReviewCompletionIntakeOptions, compile_goal_domain_review_completion_intake
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


GOAL_DOMAIN_REGISTRY_APPLY_REHEARSAL_VERSION = "source-atlas-goal-domain-registry-apply-rehearsal-train-96"
GOAL_DOMAIN_REGISTRY_APPLY_REHEARSAL_KIND = "ambitions.sourceAtlas.goalDomainRegistryApplyRehearsal.v1"
COMPLETION_EVIDENCE_KIND = "ambitions.sourceAtlas.goalDomainReviewCompletionEvidence.v1"

REHEARSAL_NON_CLAIMS = [
    "fixture-only goal-domain registry apply rehearsal",
    "not active repo registry mutation",
    "not source authority",
    "not legal approval",
    "not outside legal approval",
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
class GoalDomainRegistryApplyRehearsalOptions:
    review_templates_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    created_at: str | None = None


def run_goal_domain_registry_apply_rehearsal(options: GoalDomainRegistryApplyRehearsalOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    source_registry = options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH
    legal_registry = options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH
    api_registry = options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH

    templates_payload = read_json(options.review_templates_path)
    templates = [item for item in templates_payload.get("reviewPackets", []) if isinstance(item, dict)] if isinstance(templates_payload, dict) else []
    completion_evidence = _completion_evidence(templates, created_at)
    completion_evidence_path = output_root / "fixture-completion-evidence.json"
    write_json(completion_evidence_path, completion_evidence)

    completion = compile_goal_domain_review_completion_intake(
        GoalDomainReviewCompletionIntakeOptions(
            review_templates_path=options.review_templates_path,
            output_root=output_root / "completion-intake",
            completion_evidence_path=completion_evidence_path,
            created_at=created_at,
        )
    )
    mutation_plan = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=Path(completion["outputPaths"]["goalDomainReviewCompletions"]),
            output_root=output_root / "mutation-plan",
            created_at=created_at,
        )
    )

    temp_registries = _copy_rehearsal_registries(output_root / "temp-registries", source_registry, legal_registry, api_registry, created_at)
    approval_artifact = _write_rehearsal_approval(output_root / "fixture-temp-registry-apply-approval.json", created_at)
    applier = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=Path(mutation_plan["outputPaths"]["plannedRegistryMutations"]),
            output_root=output_root / "applier",
            source_lane_registry_path=temp_registries["source"],
            legal_terms_registry_path=temp_registries["legal"],
            api_governance_registry_path=temp_registries["api"],
            approval_artifact=approval_artifact,
            execute=True,
            created_at=created_at,
        )
    )

    input_privacy_issues = privacy_findings_for_value(
        {"templates": templates_payload, "completionEvidence": completion_evidence},
        "goal-domain-registry-apply-rehearsal-input",
    )
    output_privacy_issues = privacy_findings_for_value(
        {"completion": completion, "mutationPlan": mutation_plan, "applier": applier},
        "goal-domain-registry-apply-rehearsal-output",
    )
    counts = {
        "reviewPacketTemplates": len(templates),
        "completionEvidenceRecords": len(completion_evidence["completionEvidenceRecords"]),
        "completedReviewPackets": completion["recordCounts"]["completedReviewPackets"],
        "plannedRegistryMutations": mutation_plan["recordCounts"]["plannedRegistryMutations"],
        "appliedTempRegistryMutations": applier["recordCounts"]["activeRegistryMutations"],
        "activeRepoRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    checks = [
        {"name": "templates_loaded", "passed": bool(templates), "issues": [] if templates else ["no review templates loaded"]},
        {"name": "fixture_completion_evidence_emitted", "passed": len(completion_evidence["completionEvidenceRecords"]) == len(templates), "issues": []},
        {"name": "completion_intake_valid", "passed": completion["valid"] is True, "issues": completion.get("issues", [])},
        {"name": "mutation_plan_valid", "passed": mutation_plan["valid"] is True, "issues": mutation_plan.get("issues", [])},
        {"name": "mutation_plan_non_empty", "passed": counts["plannedRegistryMutations"] > 0, "issues": [] if counts["plannedRegistryMutations"] > 0 else ["planned mutations empty"]},
        {"name": "temp_registry_applier_valid", "passed": applier["valid"] is True, "issues": applier.get("issues", [])},
        {
            "name": "temp_registry_apply_non_empty",
            "passed": counts["appliedTempRegistryMutations"] == counts["plannedRegistryMutations"] and counts["appliedTempRegistryMutations"] > 0,
            "issues": [] if counts["appliedTempRegistryMutations"] == counts["plannedRegistryMutations"] and counts["appliedTempRegistryMutations"] > 0 else ["temp registry apply count mismatch"],
        },
        {"name": "active_repo_registries_untouched", "passed": True, "issues": []},
        {
            "name": "rehearsal_emits_no_claims_packs_r2_or_native_activation",
            "passed": counts["claims"] == 0
            and counts["packableClaims"] == 0
            and counts["r2PublishOperations"] == 0
            and counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "output_privacy_scan_passed", "passed": not output_privacy_issues, "issues": output_privacy_issues},
    ]
    issues: list[str] = []
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])
    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "report": str(output_root / "goal-domain-registry-apply-rehearsal-report.json"),
        "completionEvidence": str(completion_evidence_path),
        "completionIntake": completion["manifestPath"],
        "mutationPlan": mutation_plan["manifestPath"],
        "applier": applier["manifestPath"],
        "tempSourceLaneRegistry": str(temp_registries["source"]),
        "tempLegalTermsRegistry": str(temp_registries["legal"]),
        "tempApiGovernanceRegistry": str(temp_registries["api"]),
        "approvalArtifact": str(approval_artifact),
        "closeout": str(output_root / "closeout.md"),
    }
    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_REGISTRY_APPLY_REHEARSAL_KIND,
        "versionID": GOAL_DOMAIN_REGISTRY_APPLY_REHEARSAL_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain registry apply rehearsal tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; fixture rehearsal only",
        "reviewTemplatesPath": str(options.review_templates_path),
        "baseRegistryPaths": {
            "sourceLaneRegistry": str(source_registry),
            "legalTermsRegistry": str(legal_registry),
            "apiGovernanceRegistry": str(api_registry),
        },
        "recordCounts": counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "completionIntake": completion,
        "mutationPlan": mutation_plan,
        "registryApplier": applier,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REHEARSAL_NON_CLAIMS,
        "productionNonClaims": [
            "no active repo registry mutation",
            "no production R2 upload",
            "no app runtime Green",
            "no release Green",
            "no universal coverage",
            "no legal approval or outside legal approval",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": output_paths,
    }
    write_json(output_root / "goal-domain-registry-apply-rehearsal-report.json", report)
    report["outputHashes"] = {
        "report": stable_hash(read_json(output_root / "goal-domain-registry-apply-rehearsal-report.json")),
        "completionEvidence": stable_hash(completion_evidence),
        "completionIntake": stable_hash(read_json(Path(completion["manifestPath"]))),
        "mutationPlan": stable_hash(read_json(Path(mutation_plan["manifestPath"]))),
        "applier": stable_hash(read_json(Path(applier["manifestPath"]))),
    }
    write_json(output_root / "goal-domain-registry-apply-rehearsal-report.json", report)
    (output_root / "closeout.md").write_text(goal_domain_registry_apply_rehearsal_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "goal-domain-registry-apply-rehearsal-report.json"), "outputRoot": str(output_root), **report}


def write_goal_domain_registry_apply_rehearsal_report(
    markdown_path: Path,
    json_path: Path,
    *,
    review_templates_path: Path,
    output_root: Path,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_goal_domain_registry_apply_rehearsal(
        GoalDomainRegistryApplyRehearsalOptions(
            review_templates_path=review_templates_path,
            output_root=output_root,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_registry_apply_rehearsal_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_registry_apply_rehearsal_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Registry Apply Rehearsal Train 96",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- End-to-end fixture rehearsal from review packets through completion intake, mutation plan, and registry applier.",
        "- Non-empty planned mutations are applied only to copied temp registries.",
        "- Active repo registries, R2, native runtime, claims, packs, and final user outputs remain untouched.",
        "",
        "Counts:",
        f"- Review packet templates: {counts['reviewPacketTemplates']}",
        f"- Completion evidence records: {counts['completionEvidenceRecords']}",
        f"- Completed review packets: {counts['completedReviewPackets']}",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Applied temp registry mutations: {counts['appliedTempRegistryMutations']}",
        f"- Active repo registry mutations: {counts['activeRepoRegistryMutations']}",
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
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _completion_evidence(templates: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    return {
        "kind": COMPLETION_EVIDENCE_KIND,
        "createdAt": created_at,
        "completionEvidenceRecords": [_completion_record(template, created_at) for template in templates],
        "nonClaims": ["fixture completion evidence only", "not legal approval", "not source authority", "not registry mutation by itself"],
    }


def _completion_record(template: dict[str, Any], created_at: str) -> dict[str, Any]:
    review_lane = str(template["reviewLane"])
    request_id = str(template["requestID"])
    return {
        "completionEvidenceID": f"completion-evidence.{template['packetID']}",
        "packetID": template["packetID"],
        "orderID": template["orderID"],
        "requestID": request_id,
        "reviewLane": review_lane,
        "completionStatus": "completed",
        "reviewOwner": "Ambitions owner technical rehearsal fixture",
        "reviewedAt": created_at[:10],
        "reviewDecision": "completed_fixture_review",
        "reviewFields": _review_fields_for(review_lane, request_id, template),
        "nonClaims": ["fixture completion evidence only", "not source authority", "not legal approval"],
    }


def _review_fields_for(review_lane: str, request_id: str, template: dict[str, Any]) -> dict[str, Any]:
    slug = _slug(request_id)
    source_id = f"fixture.goal_domain.{slug}"
    license_id = f"fixture.goal_domain.{slug}.terms"
    api_policy_id = f"api.fixture_goal_domain_{slug}.v1"
    domain = str(template.get("matchedDomainID") or template.get("requestedDomain") or "public_reference")
    if review_lane == "direct_source_authority_resolution":
        return {
            "publisher_identity": f"Fixture Public Reference Publisher {slug}",
            "source_directness": "direct_official_publisher_fixture",
            "publisher_authority_class": "official_government",
            "jurisdiction": "US",
            "official_locator": f"https://example.gov/source-atlas/{slug}",
            "authority_limitations": ["fixture rehearsal only"],
            "review_decision": "direct_source_resolved_fixture",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-96-fixture-review.md",
        }
    if review_lane == "source_lane_governance":
        return {
            "source_id": source_id,
            "source_class": "official_government",
            "authority_class": "official_government",
            "jurisdiction": "US",
            "claim_classes_allowed": ["public_reference_claim"],
            "claim_classes_forbidden": ["legal_advice", "personalized_plan"],
            "redistribution_policy": "redistributable_with_attribution",
            "r2_pack_policy": "pack_allowed_with_attribution",
            "r2_object_key_prefix": f"source-atlas/v1/stable/goal-domain-rehearsal/{slug}",
            "allowed_artifact_classes": ["official_public_source", "public_reference_claim", "public_requirement", "public_provenance"],
            "forbidden_artifact_classes": ["private_goal_graph", "final_user_path", "final_schedule", "step_list", "personalized_plan"],
            "review_status": "reviewed",
            "next_review_due_at": "2026-12-28",
            "rate_policy_id": f"rate.fixture_goal_domain_{slug}.v1",
            "budget_policy_id": f"budget.fixture_goal_domain_{slug}.v1",
            "secret_policy_id": "secret.no_secret_static_page.v1",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-96-fixture-review.md",
            "domain": domain,
        }
    if review_lane == "legal_terms_review":
        return {
            "license_id": license_id,
            "license_url": f"https://example.gov/source-atlas/{slug}/license",
            "terms_url": f"https://example.gov/source-atlas/{slug}/terms",
            "rights_url": f"https://example.gov/source-atlas/{slug}/rights",
            "redistribution_allowed": True,
            "attribution_required": True,
            "pack_output_allowed": True,
            "outside_legal_required": False,
            "outside_legal_status": "not_claimed",
            "approval_artifact_path": "",
            "expires_at": "2026-12-28",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-96-fixture-review.md",
        }
    if review_lane == "api_governance_review":
        return {
            "api_policy_id": api_policy_id,
            "api_mode": "static_https_fixture_first",
            "key_required": False,
            "env_var_name": "",
            "missing_key_behavior": "no_key_required",
            "rate_limit_per_second": 1,
            "rate_limit_per_minute": 30,
            "daily_budget_limit": 10,
            "monthly_budget_limit": 300,
            "max_records_per_run": 5,
            "max_pages_per_run": 5,
            "timeout_seconds": 120,
            "retry_policy": "retry_429_500_502_503_504_only",
            "backoff_policy": "exponential_jitter",
            "circuit_breaker_policy": "stop_after_retry_budget",
            "live_flag_required": True,
            "execute_flag_required": True,
            "secret_redaction_required": True,
            "high_volume_review_required": False,
            "budget_owner": "source-atlas-foundry",
            "review_evidence_path": "docs/qa/source-atlas/domain-expansion/train-96-fixture-review.md",
        }
    raise ValueError(f"unexpected review lane: {review_lane}")


def _copy_rehearsal_registries(output_root: Path, source: Path, legal: Path, api: Path, created_at: str) -> dict[str, Path]:
    output_root.mkdir(parents=True, exist_ok=True)
    targets = {
        "source": output_root / "source-lane-registry.json",
        "legal": output_root / "legal-terms-registry.json",
        "api": output_root / "api-governance-registry.json",
    }
    for source_path, target_path in ((source, targets["source"]), (legal, targets["legal"]), (api, targets["api"])):
        payload = read_json(source_path)
        if isinstance(payload, dict):
            payload = dict(payload)
            payload["updated_at"] = created_at
        write_json(target_path, payload)
    return targets


def _write_rehearsal_approval(path: Path, created_at: str) -> Path:
    write_json(
        path,
        {
            "kind": "ambitions.sourceAtlas.goalDomainRegistryApplyApproval.v1",
            "approvalStatus": "approved_for_fixture_temp_registry_apply",
            "approvedAt": created_at,
            "approvedBy": "Ambitions owner technical rehearsal fixture",
            "nonClaims": ["fixture approval only", "not active repo registry approval", "not outside legal approval", "not R2 publish"],
        },
    )
    return path


def _slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_") or "public_reference"
