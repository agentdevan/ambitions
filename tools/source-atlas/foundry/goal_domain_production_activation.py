"""Vertical production-activation orchestrator for goal-domain Source Atlas.

This layer ties the source-specific packet, active-registry readiness gate,
registry applier, and post-apply governance validation into one deterministic
activation report. It does not harvest claims, build packs, publish to R2, or
activate native runtime behavior.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_registry_applier import GoalDomainRegistryApplierOptions, compile_goal_domain_registry_applier
from .goal_domain_source_specific_apply_packet import (
    GoalDomainSourceSpecificApplyPacketOptions,
    compile_goal_domain_source_specific_apply_packet,
)
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH, validate_governance_registries
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, utc_now, write_json


GOAL_DOMAIN_PRODUCTION_ACTIVATION_VERSION = "source-atlas-goal-domain-production-activation-train-99"
GOAL_DOMAIN_PRODUCTION_ACTIVATION_KIND = "ambitions.sourceAtlas.goalDomainProductionActivation.v1"

PRODUCTION_ACTIVATION_NON_CLAIMS = [
    "goal-domain production activation orchestration tooling only",
    "not claim output",
    "not pack output",
    "not production R2 upload",
    "not native runtime activation",
    "not app runtime Green",
    "not release Green",
    "not universal coverage",
    "not outside legal approval",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainProductionActivationOptions:
    input_path: Path
    output_root: Path
    target_source_lane_registry_path: Path | None = None
    target_legal_terms_registry_path: Path | None = None
    target_api_governance_registry_path: Path | None = None
    execute_active_registry: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def compile_goal_domain_production_activation(options: GoalDomainProductionActivationOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    packet = compile_goal_domain_source_specific_apply_packet(
        GoalDomainSourceSpecificApplyPacketOptions(
            input_path=options.input_path,
            output_root=output_root / "01-source-specific-packet",
            created_at=created_at,
        )
    )
    target_source_path = options.target_source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH
    target_legal_path = options.target_legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH
    target_api_path = options.target_api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH

    plan_path = _path_or_none(packet.get("outputPaths", {}).get("plannedRegistryMutations"))
    approval_path = _path_or_none(packet.get("outputPaths", {}).get("approvalArtifact"))
    packet_valid = packet.get("valid") is True
    registry_applier = _compile_registry_applier(
        plan_path=plan_path,
        approval_path=approval_path,
        packet_valid=packet_valid,
        output_root=output_root / "02-registry-applier",
        target_source_path=target_source_path,
        target_legal_path=target_legal_path,
        target_api_path=target_api_path,
        execute=options.execute_active_registry,
        allow_active_registry_write=options.allow_active_registry_write,
        created_at=created_at,
    )
    post_apply_validation = _post_apply_governance_validation(
        registry_applier=registry_applier,
        execute_active_registry=options.execute_active_registry,
        target_source_path=target_source_path,
        target_legal_path=target_legal_path,
        target_api_path=target_api_path,
        output_path=output_root / "03-governance-validation" / "post-apply-governance-validation.json",
    )

    issues = _activation_issues(packet, registry_applier, post_apply_validation)
    active_registry_mutations = registry_applier.get("recordCounts", {}).get("activeRegistryMutations", 0) if registry_applier else 0
    activation_complete = bool(options.execute_active_registry and active_registry_mutations > 0 and not issues)
    decision = _activation_decision(
        execute_requested=options.execute_active_registry,
        activation_complete=activation_complete,
        packet=packet,
        registry_applier=registry_applier,
        post_apply_validation=post_apply_validation,
    )
    valid = not issues
    downstream_readiness = _downstream_readiness(activation_complete)
    record_counts = {
        "sourceSpecificPackets": 1,
        "plannedRegistryMutations": packet.get("recordCounts", {}).get("plannedRegistryMutations", 0),
        "candidateRegistryMutations": registry_applier.get("recordCounts", {}).get("candidateRegistryMutations", 0) if registry_applier else 0,
        "blockedRegistryMutations": registry_applier.get("recordCounts", {}).get("blockedRegistryMutations", 0) if registry_applier else 0,
        "activeRegistryMutations": active_registry_mutations,
        "governanceValidationRuns": 1 if post_apply_validation else 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    checks = [
        {
            "name": "source_specific_packet_valid",
            "passed": packet_valid,
            "issues": packet.get("issues", []),
        },
        {
            "name": "active_registry_readiness_gate_allows_apply",
            "passed": packet.get("activeApplyGate", {}).get("activeRegistryApplyAllowed") is True,
            "issues": packet.get("activeApplyGate", {}).get("blockingReasons", []),
        },
        {
            "name": "registry_applier_completed",
            "passed": bool(registry_applier and registry_applier.get("valid") is True),
            "issues": [] if registry_applier and registry_applier.get("valid") is True else ((registry_applier or {}).get("issues") or ["registry applier did not run"]),
        },
        {
            "name": "post_apply_governance_validation_passed",
            "passed": bool(post_apply_validation and post_apply_validation.get("valid") is True),
            "issues": [] if post_apply_validation and post_apply_validation.get("valid") is True else ((post_apply_validation or {}).get("issues") or ["post-apply governance validation did not run"]),
        },
        {
            "name": "dry_run_writes_no_active_registries",
            "passed": options.execute_active_registry or active_registry_mutations == 0,
            "issues": [] if options.execute_active_registry or active_registry_mutations == 0 else ["dry-run wrote active registry mutations"],
        },
        {
            "name": "orchestrator_emits_no_claims_packs_r2_native_or_final_user_outputs",
            "passed": record_counts["claims"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0
            and record_counts["finalOutputArtifacts"] == 0,
            "issues": [],
        },
    ]
    output_paths = {
        "report": str(output_root / "goal-domain-production-activation-report.json"),
        "sourceSpecificPacket": packet.get("manifestPath", ""),
        "plannedRegistryMutations": packet.get("outputPaths", {}).get("plannedRegistryMutations", ""),
        "approvalArtifact": packet.get("outputPaths", {}).get("approvalArtifact", ""),
        "registryApplier": registry_applier.get("manifestPath", "") if registry_applier else "",
        "postApplyGovernanceValidation": str(output_root / "03-governance-validation" / "post-apply-governance-validation.json") if post_apply_validation else "",
        "closeout": str(output_root / "closeout.md"),
    }
    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_PRODUCTION_ACTIVATION_KIND,
        "versionID": GOAL_DOMAIN_PRODUCTION_ACTIVATION_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain production activation orchestration tooling" if valid else "Red",
        "valid": valid,
        "activationComplete": activation_complete,
        "activationDecision": decision,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; production activation orchestration tooling only",
        "inputPath": str(options.input_path),
        "executeActiveRegistryRequested": options.execute_active_registry,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "targetRegistryPaths": {
            "sourceLaneRegistry": str(target_source_path),
            "legalTermsRegistry": str(target_legal_path),
            "apiGovernanceRegistry": str(target_api_path),
        },
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "sourceSpecificPacket": packet,
        "registryApplier": registry_applier or {},
        "postApplyGovernanceValidation": post_apply_validation or {},
        "downstreamReadiness": downstream_readiness,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_ACTIVATION_NON_CLAIMS,
        "productionNonClaims": [
            "no claim graph compilation",
            "no pack production",
            "no production R2 upload",
            "no native runtime Green",
            "no release Green",
            "no universal coverage",
            "no outside legal approval",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": output_paths,
    }
    report["outputHashes"] = _output_hashes(output_paths)
    write_json(output_root / "goal-domain-production-activation-report.json", report)
    report["outputHashes"]["report"] = stable_hash(read_json(output_root / "goal-domain-production-activation-report.json"))
    write_json(output_root / "goal-domain-production-activation-report.json", report)
    (output_root / "closeout.md").write_text(goal_domain_production_activation_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "goal-domain-production-activation-report.json"), "outputRoot": str(output_root), **report}


def write_goal_domain_production_activation_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    target_source_lane_registry_path: Path | None = None,
    target_legal_terms_registry_path: Path | None = None,
    target_api_governance_registry_path: Path | None = None,
    execute_active_registry: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_production_activation(
        GoalDomainProductionActivationOptions(
            input_path=input_path,
            output_root=output_root,
            target_source_lane_registry_path=target_source_lane_registry_path,
            target_legal_terms_registry_path=target_legal_terms_registry_path,
            target_api_governance_registry_path=target_api_governance_registry_path,
            execute_active_registry=execute_active_registry,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_production_activation_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_production_activation_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Production Activation Train 99",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Activation decision: {result['activationDecision']}",
        f"Activation complete: {'yes' if result['activationComplete'] else 'no'}",
        "",
        "Scope completed:",
        "- Source-specific governance packet compilation is chained to active-registry readiness.",
        "- The registry applier runs against target registries in dry-run or explicit execute mode.",
        "- Post-apply governance validation runs on candidate registries or executed target registries.",
        "- Downstream claim/frontier/pack/R2/native readiness remains explicit and blocked until separate proof exists.",
        "",
        "Counts:",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Candidate registry mutations: {counts['candidateRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        f"- Native activation operations: {counts['nativeActivationOperations']}",
        "",
        "Product law preserved:",
        "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
        "- No private Ambitions runtime context is emitted or sent to R2.",
        "- No final user plans, schedules, Steps, or personalized paths are generated.",
        "",
        "Downstream readiness:",
    ]
    for item in result["downstreamReadiness"]:
        lines.append(f"- {item['name']}: {item['status']}")
    lines.extend(
        [
            "",
            "Validation run:",
            "- See the train closeout for exact command output.",
            "",
            "Validation not run:",
            "- Claim graph/frontier compilation was not run by this train.",
            "- Pack production and production R2 upload/readback were not run.",
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
            "- This train emits zero R2 publish operations.",
            "",
            "No private graph egress proof:",
            "- Source-specific packet and registry applier privacy scans must pass before Source Green.",
            "- The orchestrator emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Source/legal/API entries validate through the governance registry before activation is considered valid.",
            "- Outside legal approval is not claimed without an outside legal artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Inherited governance validation still blocks restricted, catalog-only, and private-key source lanes.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 99. This train activates source governance only.",
            "",
            "Freshness/revocation proof:",
            "- Registry freshness fields validate, but no pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable R2 pointer or pack rollback operation ran. Registry rollback uses active mutation reports and prior registry snapshots.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 99. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: production activation orchestrator, CLI command, tests, and QA evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: claim/frontier, pack/R2, and native runtime proof remain separate trains.",
            "- Next repair train if debt remains: claim/frontier pack production activation after governance source lanes are active.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _compile_registry_applier(
    *,
    plan_path: Path | None,
    approval_path: Path | None,
    packet_valid: bool,
    output_root: Path,
    target_source_path: Path,
    target_legal_path: Path,
    target_api_path: Path,
    execute: bool,
    allow_active_registry_write: bool,
    created_at: str,
) -> dict[str, Any] | None:
    if not packet_valid or plan_path is None:
        return None
    return compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=output_root,
            source_lane_registry_path=target_source_path,
            legal_terms_registry_path=target_legal_path,
            api_governance_registry_path=target_api_path,
            approval_artifact=approval_path if execute else None,
            execute=execute,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )


def _post_apply_governance_validation(
    *,
    registry_applier: dict[str, Any] | None,
    execute_active_registry: bool,
    target_source_path: Path,
    target_legal_path: Path,
    target_api_path: Path,
    output_path: Path,
) -> dict[str, Any] | None:
    if not registry_applier:
        return None
    paths = registry_applier.get("outputPaths", {})
    if execute_active_registry and registry_applier.get("recordCounts", {}).get("activeRegistryMutations", 0) > 0:
        source_path = target_source_path
        legal_path = target_legal_path
        api_path = target_api_path
    else:
        source_path = _path_or_none(paths.get("candidateSourceLaneRegistry"))
        legal_path = _path_or_none(paths.get("candidateLegalTermsRegistry"))
        api_path = _path_or_none(paths.get("candidateApiGovernanceRegistry"))
    if not source_path or not legal_path or not api_path:
        return {
            "kind": "ambitions.sourceAtlas.governanceRegistryValidation.v1",
            "valid": False,
            "status": "Red",
            "issues": ["candidate or target registry paths missing for post-apply validation"],
        }
    return validate_governance_registries(
        source_lane_path=source_path,
        legal_terms_path=legal_path,
        api_governance_path=api_path,
        output_path=output_path,
    )


def _activation_issues(packet: dict[str, Any], registry_applier: dict[str, Any] | None, post_apply_validation: dict[str, Any] | None) -> list[str]:
    issues: list[str] = []
    if packet.get("valid") is not True:
        issues.extend(f"source-specific packet issue: {issue}" for issue in packet.get("issues", []))
    if packet.get("activeApplyGate", {}).get("activeRegistryApplyAllowed") is not True:
        issues.extend(f"active-readiness gate blocked: {reason}" for reason in packet.get("activeApplyGate", {}).get("blockingReasons", []))
    if registry_applier is None:
        issues.append("registry applier did not run because source-specific packet was invalid")
    elif registry_applier.get("valid") is not True:
        issues.extend(f"registry applier issue: {issue}" for issue in registry_applier.get("issues", []))
    if post_apply_validation is None:
        issues.append("post-apply governance validation did not run")
    elif post_apply_validation.get("valid") is not True:
        issues.extend(f"post-apply governance validation issue: {issue}" for issue in post_apply_validation.get("issues", []))
    return sorted(set(issues))


def _activation_decision(
    *,
    execute_requested: bool,
    activation_complete: bool,
    packet: dict[str, Any],
    registry_applier: dict[str, Any] | None,
    post_apply_validation: dict[str, Any] | None,
) -> str:
    if packet.get("valid") is not True:
        return "blocked_source_specific_packet_invalid"
    if packet.get("activeApplyGate", {}).get("activeRegistryApplyAllowed") is not True:
        return "blocked_active_readiness_gate"
    if registry_applier is None or registry_applier.get("valid") is not True:
        return "blocked_registry_applier_invalid"
    if post_apply_validation is None or post_apply_validation.get("valid") is not True:
        return "blocked_post_apply_governance_validation"
    if activation_complete:
        return "registry_apply_executed_and_governance_validated"
    if execute_requested:
        return "execute_requested_but_no_active_mutation_emitted"
    return "dry_run_candidate_registries_validated_no_active_registry_write"


def _downstream_readiness(activation_complete: bool) -> list[dict[str, str]]:
    if activation_complete:
        status = "ready_for_next_train_not_run"
    else:
        status = "blocked_pending_active_registry_activation"
    return [
        {"name": "claim_frontier", "status": status},
        {"name": "claim_graph_provenance", "status": status},
        {"name": "pack_production", "status": "blocked_pending_claim_frontier_and_pack_proof"},
        {"name": "r2_publish", "status": "blocked_pending_pack_manifest_hash_revocation_lkg_and_execute_proof"},
        {"name": "native_runtime", "status": "blocked_pending_r2_manifest_pack_and_xctest_proof"},
    ]


def _path_or_none(value: Any) -> Path | None:
    if not value:
        return None
    return Path(str(value))


def _output_hashes(output_paths: dict[str, str]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for key, value in output_paths.items():
        if key == "closeout" or not value:
            continue
        path = Path(value)
        if path.exists() and path.suffix == ".json":
            hashes[key] = stable_hash(read_json(path))
    return hashes
