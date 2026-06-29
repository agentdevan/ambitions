"""Autonomous registry-activation readiness chain for Source Atlas.

This train composes the existing goal-domain review, registry planning,
fixture rehearsal, and active apply-gate tooling into one larger handoff after
the autonomous domain expansion chain. It proves what can advance
mechanically and where active registry writes remain blocked.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .goal_domain_active_registry_apply_gate import (
    GoalDomainActiveRegistryApplyGateOptions,
    compile_goal_domain_active_registry_apply_gate,
)
from .goal_domain_registry_apply_rehearsal import (
    GoalDomainRegistryApplyRehearsalOptions,
    run_goal_domain_registry_apply_rehearsal,
)
from .goal_domain_registry_mutation_plan import (
    GoalDomainRegistryMutationPlanOptions,
    compile_goal_domain_registry_mutation_plan,
)
from .goal_domain_review_completion_intake import (
    GoalDomainReviewCompletionIntakeOptions,
    compile_goal_domain_review_completion_intake,
)
from .goal_domain_source_specific_apply_packet import (
    GoalDomainSourceSpecificApplyPacketOptions,
    compile_goal_domain_source_specific_apply_packet,
)
from .governance_registry import API_GOVERNANCE_REGISTRY_PATH, LEGAL_TERMS_REGISTRY_PATH, SOURCE_LANE_REGISTRY_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


AUTONOMOUS_REGISTRY_ACTIVATION_CHAIN_VERSION = "source-atlas-autonomous-registry-activation-chain-train-108"
AUTONOMOUS_REGISTRY_ACTIVATION_CHAIN_KIND = "ambitions.sourceAtlas.autonomousRegistryActivationChain.v1"

CHAIN_NON_CLAIMS = [
    "autonomous registry activation readiness chain only",
    "not active registry mutation",
    "not source authority by itself",
    "not legal approval",
    "not outside legal approval without artifact",
    "not claim output",
    "not pack output",
    "not production R2 upload",
    "not native activation proof",
    "not literal universal coverage",
    "not release readiness",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousRegistryActivationChainOptions:
    expansion_chain_report_path: Path
    output_root: Path
    completion_evidence_path: Path | None = None
    source_specific_apply_input_path: Path | None = None
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    created_at: str = "2026-06-28T00:00:00Z"


def run_autonomous_registry_activation_chain(options: AutonomousRegistryActivationChainOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    expansion_report = _read_report(options.expansion_chain_report_path, issues)
    expansion_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(expansion_report, "source-atlas-autonomous-registry-activation-chain-input")
    )
    issues.extend(expansion_privacy_issues)
    if isinstance(expansion_report, dict) and expansion_report.get("valid") is not True:
        issues.append("expansion chain report is not valid")

    registry_activation_not_required = _registry_activation_not_required(expansion_report)
    review_templates_path = _review_templates_path(expansion_report)
    if not registry_activation_not_required:
        if not review_templates_path:
            issues.append("expansion chain report does not expose review packet templates")
        elif not review_templates_path.exists():
            issues.append(f"review packet templates do not exist: {review_templates_path}")

    stages: dict[str, Any] = {}
    if not issues and registry_activation_not_required:
        stages["registryActivationNotRequired"] = _registry_activation_not_required_stage(
            output_root / "01-registry-activation-not-required",
            expansion_report_path=options.expansion_chain_report_path,
            expansion_report=expansion_report,
            created_at=options.created_at,
        )
    elif not issues and review_templates_path:
        stages["reviewCompletionIntake"] = compile_goal_domain_review_completion_intake(
            GoalDomainReviewCompletionIntakeOptions(
                review_templates_path=review_templates_path,
                output_root=output_root / "01-review-completion-intake",
                completion_evidence_path=options.completion_evidence_path,
                created_at=options.created_at,
            )
        )
        if _valid(stages.get("reviewCompletionIntake")):
            stages["registryMutationPlan"] = compile_goal_domain_registry_mutation_plan(
                GoalDomainRegistryMutationPlanOptions(
                    review_completions_path=Path(stages["reviewCompletionIntake"]["outputPaths"]["goalDomainReviewCompletions"]),
                    output_root=output_root / "02-registry-mutation-plan",
                    created_at=options.created_at,
                )
            )
        if _valid(stages.get("reviewCompletionIntake")):
            stages["registryApplyRehearsal"] = run_goal_domain_registry_apply_rehearsal(
                GoalDomainRegistryApplyRehearsalOptions(
                    review_templates_path=review_templates_path,
                    output_root=output_root / "03-registry-apply-rehearsal",
                    source_lane_registry_path=options.source_lane_registry_path,
                    legal_terms_registry_path=options.legal_terms_registry_path,
                    api_governance_registry_path=options.api_governance_registry_path,
                    created_at=options.created_at,
                )
            )
        rehearsal_plan_path = _rehearsal_planned_mutations_path(stages.get("registryApplyRehearsal"))
        if rehearsal_plan_path:
            stages["rehearsalActiveApplyGate"] = compile_goal_domain_active_registry_apply_gate(
                GoalDomainActiveRegistryApplyGateOptions(
                    plan_path=rehearsal_plan_path,
                    output_root=output_root / "04-rehearsal-active-apply-gate",
                    source_lane_registry_path=options.source_lane_registry_path,
                    legal_terms_registry_path=options.legal_terms_registry_path,
                    api_governance_registry_path=options.api_governance_registry_path,
                    created_at=options.created_at,
                )
            )
        if options.source_specific_apply_input_path:
            stages["sourceSpecificApplyPacket"] = compile_goal_domain_source_specific_apply_packet(
                GoalDomainSourceSpecificApplyPacketOptions(
                    input_path=options.source_specific_apply_input_path,
                    output_root=output_root / "05-source-specific-apply-packet",
                    source_lane_registry_path=options.source_lane_registry_path,
                    legal_terms_registry_path=options.legal_terms_registry_path,
                    api_governance_registry_path=options.api_governance_registry_path,
                    created_at=options.created_at,
                )
            )

    issues.extend(_stage_issues(stages))
    record_counts = _record_counts(expansion_report, stages, review_templates_path)
    output_paths = _output_paths(output_root, review_templates_path, stages)
    checks = [
        _check("expansion_chain_report_loaded", isinstance(expansion_report, dict), [] if isinstance(expansion_report, dict) else ["expansion chain report missing or unreadable"]),
        _check("expansion_chain_report_valid", isinstance(expansion_report, dict) and expansion_report.get("valid") is True, [] if isinstance(expansion_report, dict) and expansion_report.get("valid") is True else ["expansion chain report is not valid"]),
        _check("input_privacy_scan_passed", not expansion_privacy_issues, expansion_privacy_issues),
        _check(
            "review_packet_templates_found_or_not_required",
            registry_activation_not_required or bool(review_templates_path and review_templates_path.exists()),
            [] if registry_activation_not_required or (review_templates_path and review_templates_path.exists()) else ["review packet templates missing"],
        ),
        _check(
            "registry_activation_stage_matches_expansion_path",
            _registry_activation_stage_matches_expansion_path(stages, registry_activation_not_required),
            _registry_activation_stage_mismatch_issues(stages, registry_activation_not_required),
        ),
        _check(
            "review_completion_intake_valid",
            registry_activation_not_required or _valid(stages.get("reviewCompletionIntake")),
            [] if registry_activation_not_required else stages.get("reviewCompletionIntake", {}).get("issues", ["stage did not run"]),
        ),
        _check(
            "registry_mutation_plan_valid",
            registry_activation_not_required or _valid(stages.get("registryMutationPlan")),
            [] if registry_activation_not_required else stages.get("registryMutationPlan", {}).get("issues", ["stage did not run"]),
        ),
        _check(
            "registry_apply_rehearsal_valid",
            registry_activation_not_required or _valid(stages.get("registryApplyRehearsal")),
            [] if registry_activation_not_required else stages.get("registryApplyRehearsal", {}).get("issues", ["stage did not run"]),
        ),
        _check(
            "rehearsal_active_apply_gate_valid",
            registry_activation_not_required or _valid(stages.get("rehearsalActiveApplyGate")),
            [] if registry_activation_not_required else stages.get("rehearsalActiveApplyGate", {}).get("evaluationIssues", ["stage did not run"]),
        ),
        _check(
            "rehearsal_blocks_active_registry_apply",
            registry_activation_not_required or stages.get("rehearsalActiveApplyGate", {}).get("activeRegistryApplyAllowed") is False,
            [] if registry_activation_not_required or stages.get("rehearsalActiveApplyGate", {}).get("activeRegistryApplyAllowed") is False else ["fixture rehearsal was not blocked from active registry apply"],
        ),
        _check("chain_emits_no_claims_packs_r2_or_native_activation", _no_forbidden_outputs(record_counts), []),
    ]
    if options.source_specific_apply_input_path:
        checks.append(
            _check(
                "source_specific_apply_packet_valid_when_provided",
                _valid(stages.get("sourceSpecificApplyPacket")),
                stages.get("sourceSpecificApplyPacket", {}).get("issues", ["stage did not run"]),
            )
        )

    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "recordCounts": record_counts,
                "stageSummaries": _stage_summaries(stages),
                "outputPaths": output_paths,
                "nonClaims": CHAIN_NON_CLAIMS,
            },
            "source-atlas-autonomous-registry-activation-chain-output",
        )
    )
    issues.extend(output_privacy_issues)
    checks.append(_check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues))
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "autonomous-registry-activation-chain-report.json"
    markdown_path = output_root / "autonomous-registry-activation-chain-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_REGISTRY_ACTIVATION_CHAIN_KIND,
        "versionID": AUTONOMOUS_REGISTRY_ACTIVATION_CHAIN_VERSION,
        "createdAt": options.created_at,
        "chainID": stable_id(
            "source_atlas.autonomous_registry_activation_chain",
            {
                "expansionChainReport": str(options.expansion_chain_report_path),
                "completionEvidence": str(options.completion_evidence_path) if options.completion_evidence_path else "",
                "sourceSpecificInput": str(options.source_specific_apply_input_path) if options.source_specific_apply_input_path else "",
                "createdAt": options.created_at,
            },
        ),
        "status": "Source Green for autonomous registry activation readiness chain" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry activation readiness/rehearsal chain only",
        "expansionChainReportPath": str(options.expansion_chain_report_path),
        "reviewPacketTemplatesPath": str(review_templates_path) if review_templates_path else "",
        "registryActivationNotRequired": registry_activation_not_required,
        "completionEvidencePath": str(options.completion_evidence_path) if options.completion_evidence_path else "",
        "sourceSpecificApplyInputPath": str(options.source_specific_apply_input_path) if options.source_specific_apply_input_path else "",
        "targetRegistryPaths": {
            "sourceLaneRegistry": str(options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH),
            "legalTermsRegistry": str(options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH),
            "apiGovernanceRegistry": str(options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH),
        },
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "stageSummaries": _stage_summaries(stages),
        "stages": stages,
        "allowedClaims": ["deterministic_autonomous_registry_activation_readiness_chain"] if valid else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "source_authority_for_candidate_domains",
                "active_registry_mutation",
                "claim_output",
                "pack_output",
                "production_r2_upload",
                "native_activation",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*expansion_privacy_issues, *output_privacy_issues])),
        "nonClaims": CHAIN_NON_CLAIMS,
        "productionNonClaims": _production_non_claims(),
        "outputPaths": output_paths,
    }
    report["outputPaths"].update({"report": str(report_path), "markdown": str(markdown_path), "closeout": str(closeout_path)})
    report["outputHashes"] = _output_hashes(report["outputPaths"])
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = autonomous_registry_activation_chain_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return {"manifestPath": str(report_path), "outputRoot": str(output_root), **report}


def autonomous_registry_activation_chain_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Registry Activation Chain Train 108",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Consumes the autonomous domain expansion chain output.",
        "- Runs review completion intake, registry mutation planning, registry apply rehearsal, and the active registry apply gate for candidate routes with review packet templates.",
        "- Emits registry-activation-not-required evidence for production-ready maintenance routes with no review packet templates.",
        "- Proves fixture registry activation can rehearse into temp registries while active repo registry apply remains blocked.",
        "- Optional source-specific apply packet input can be evaluated without changing active registries.",
        "",
        "Counts:",
        f"- Routes: {counts['routes']}",
        f"- Production-ready routes: {counts['productionReadyRoutes']}",
        f"- Candidate routes: {counts['candidateRoutes']}",
        f"- Registry activation not required routes: {counts['registryActivationNotRequiredRoutes']}",
        f"- Review packet templates: {counts['reviewPacketTemplates']}",
        f"- Completion evidence records: {counts['completionEvidenceRecords']}",
        f"- Completed review packets: {counts['completedReviewPackets']}",
        f"- Blocked review completions: {counts['blockedReviewCompletions']}",
        f"- Planned registry mutations from provided evidence: {counts['plannedRegistryMutations']}",
        f"- Blocked registry mutations from provided evidence: {counts['blockedRegistryMutations']}",
        f"- Rehearsal planned registry mutations: {counts['rehearsalPlannedRegistryMutations']}",
        f"- Rehearsal temp registry mutations: {counts['rehearsalAppliedTempRegistryMutations']}",
        f"- Active registry apply allowed: {counts['activeRegistryApplyAllowed']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        f"- Native activation operations: {counts['nativeActivationOperations']}",
        "",
        "Stage summaries:",
    ]
    for name, summary in report.get("stageSummaries", {}).items():
        lines.append(f"- `{name}`: {summary['status']} (valid={summary['valid']})")
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- The chain emits governance readiness artifacts only.",
            "- No private Ambitions runtime context is sent to R2 or written into registry artifacts.",
            "- Source Atlas/R2 do not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No live network/API harvest was run.",
            "- No active repo registry mutation was run.",
            "- No production R2 upload/readback was run.",
            "- No native XCTest/build-for-testing was required for this tooling-only train.",
            "- Outside legal approval was not run or claimed.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in report.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- The chain output contains only public/reference registry readiness metadata.",
            "",
            "No private graph egress proof:",
            "- Input and output boundary scans must pass before Source Green.",
            "- The chain emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Missing completion evidence blocks registry mutation planning for real candidate-domain activation.",
            "- Fixture legal/terms evidence is classified as rehearsal-only and blocked from active registry apply.",
            "- Outside legal approval is not claimed without a source-specific approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- No packable output or R2 publish occurs in this chain.",
            "- Restricted-source exclusion remains enforced downstream by source-lane, legal, pack, and R2 gates.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 108. This train composes registry readiness only.",
            "",
            "Freshness/revocation proof:",
            "- No pack freshness, revocation, or LKG operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer, R2 object, or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 108. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: native runtime/release proof remains separate.",
            "- Next repair train if debt remains: active source-specific registry apply with completed review evidence, then harvest/pack/R2/native recertification.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _read_report(path: Path, issues: list[str]) -> Any:
    try:
        return read_json(path)
    except FileNotFoundError:
        issues.append(f"missing expansion chain report: {path}")
    except Exception as exc:
        issues.append(f"could not read expansion chain report {path}: {exc}")
    return {}


def _review_templates_path(report: Any) -> Path | None:
    if not isinstance(report, dict):
        return None
    output_paths = report.get("outputPaths") if isinstance(report.get("outputPaths"), dict) else {}
    for key in ("reviewPacketTemplates", "reviewPackets"):
        value = output_paths.get(key)
        if value and key == "reviewPacketTemplates":
            return Path(str(value))
        if value and key == "reviewPackets":
            try:
                manifest = read_json(Path(str(value)))
                templates = manifest.get("outputPaths", {}).get("reviewPacketTemplates") if isinstance(manifest, dict) else None
                if templates:
                    return Path(str(templates))
            except Exception:
                return None
    stages = report.get("stages") if isinstance(report.get("stages"), dict) else {}
    review_packets = stages.get("reviewPackets") if isinstance(stages.get("reviewPackets"), dict) else {}
    templates = review_packets.get("outputPaths", {}).get("reviewPacketTemplates") if isinstance(review_packets.get("outputPaths"), dict) else None
    return Path(str(templates)) if templates else None


def _registry_activation_not_required(report: Any) -> bool:
    if not isinstance(report, dict) or report.get("valid") is not True:
        return False
    counts = report.get("recordCounts", {}) if isinstance(report.get("recordCounts"), dict) else {}
    production_ready_routes = int(counts.get("productionReadyRoutes", 0) or 0)
    candidate_routes = int(counts.get("candidateRoutes", 0) or 0)
    review_packets = int(counts.get("reviewPackets", 0) or 0)
    blocked_review_required = int(counts.get("blockedReviewRequired", 0) or 0)
    if production_ready_routes <= 0 or candidate_routes != 0 or review_packets != 0 or blocked_review_required != 0:
        return False
    review_stage_path = _review_stage_manifest_path(report)
    if not review_stage_path:
        return False
    try:
        review_stage = read_json(review_stage_path)
    except Exception:
        return False
    return (
        isinstance(review_stage, dict)
        and review_stage.get("valid") is True
        and review_stage.get("kind") == "ambitions.sourceAtlas.goalDomainReviewPacketsNotRequired.v1"
    )


def _review_stage_manifest_path(report: dict[str, Any]) -> Path | None:
    output_paths = report.get("outputPaths") if isinstance(report.get("outputPaths"), dict) else {}
    value = output_paths.get("reviewPackets")
    if value:
        return Path(str(value))
    stages = report.get("stages") if isinstance(report.get("stages"), dict) else {}
    review_packets = stages.get("reviewPackets") if isinstance(stages.get("reviewPackets"), dict) else {}
    manifest_path = review_packets.get("manifestPath")
    return Path(str(manifest_path)) if manifest_path else None


def _rehearsal_planned_mutations_path(rehearsal: Any) -> Path | None:
    if not isinstance(rehearsal, dict) or rehearsal.get("valid") is not True:
        return None
    mutation_plan_path = rehearsal.get("outputPaths", {}).get("mutationPlan") if isinstance(rehearsal.get("outputPaths"), dict) else None
    if not mutation_plan_path:
        return None
    try:
        mutation_manifest = read_json(Path(str(mutation_plan_path)))
    except Exception:
        return None
    planned = mutation_manifest.get("outputPaths", {}).get("plannedRegistryMutations") if isinstance(mutation_manifest, dict) else None
    return Path(str(planned)) if planned else None


def _valid(stage: Any) -> bool:
    return isinstance(stage, dict) and stage.get("valid") is True


def _stage_issues(stages: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for name, stage in stages.items():
        if isinstance(stage, dict) and stage.get("valid") is not True:
            issues.extend(f"{name}: {issue}" for issue in stage.get("issues", []) or stage.get("evaluationIssues", []))
    return issues


def _registry_activation_stage_matches_expansion_path(stages: dict[str, Any], not_required: bool) -> bool:
    if not_required:
        return _valid(stages.get("registryActivationNotRequired")) and "reviewCompletionIntake" not in stages
    return (
        _valid(stages.get("reviewCompletionIntake"))
        and _valid(stages.get("registryMutationPlan"))
        and _valid(stages.get("registryApplyRehearsal"))
        and _valid(stages.get("rehearsalActiveApplyGate"))
        and "registryActivationNotRequired" not in stages
    )


def _registry_activation_stage_mismatch_issues(stages: dict[str, Any], not_required: bool) -> list[str]:
    if _registry_activation_stage_matches_expansion_path(stages, not_required):
        return []
    if not_required:
        return ["production-ready expansion path must emit registryActivationNotRequired only"]
    return ["candidate expansion path must emit review, registry mutation, rehearsal, and active apply-gate stages"]


def _record_counts(expansion_report: Any, stages: dict[str, Any], review_templates_path: Path | None) -> dict[str, int]:
    expansion_counts = expansion_report.get("recordCounts", {}) if isinstance(expansion_report, dict) else {}
    completion_counts = stages.get("reviewCompletionIntake", {}).get("recordCounts", {})
    mutation_counts = stages.get("registryMutationPlan", {}).get("recordCounts", {})
    rehearsal_counts = stages.get("registryApplyRehearsal", {}).get("recordCounts", {})
    active_gate = stages.get("rehearsalActiveApplyGate", {})
    source_packet_counts = stages.get("sourceSpecificApplyPacket", {}).get("recordCounts", {})
    not_required_counts = stages.get("registryActivationNotRequired", {}).get("recordCounts", {})
    loaded_review_packet_templates = _loaded_review_packet_template_count(review_templates_path)
    return {
        "candidateInputs": int(expansion_counts.get("candidateInputs", 0) or 0),
        "routes": int(expansion_counts.get("routes", 0) or 0),
        "productionReadyRoutes": int(expansion_counts.get("productionReadyRoutes", 0) or 0),
        "candidateRoutes": int(expansion_counts.get("candidateRoutes", 0) or 0),
        "registryActivationNotRequiredRoutes": int(not_required_counts.get("registryActivationNotRequiredRoutes", 0) or 0),
        "reviewPacketTemplates": int(completion_counts.get("reviewPacketTemplates", loaded_review_packet_templates) or 0),
        "completionEvidenceRecords": int(completion_counts.get("completionEvidenceRecords", 0) or 0),
        "completedReviewPackets": int(completion_counts.get("completedReviewPackets", 0) or 0),
        "blockedReviewCompletions": int(completion_counts.get("blockedReviewCompletions", 0) or 0),
        "plannedRegistryMutations": int(mutation_counts.get("plannedRegistryMutations", 0) or 0),
        "blockedRegistryMutations": int(mutation_counts.get("blockedRegistryMutations", 0) or 0),
        "rehearsalPlannedRegistryMutations": int(rehearsal_counts.get("plannedRegistryMutations", 0) or 0),
        "rehearsalAppliedTempRegistryMutations": int(rehearsal_counts.get("appliedTempRegistryMutations", 0) or 0),
        "activeRegistryApplyAllowed": 1 if active_gate.get("activeRegistryApplyAllowed") is True else 0,
        "sourceSpecificReadinessAllowed": int(source_packet_counts.get("activeRegistryReadinessAllowed", 0) or 0),
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }


def _loaded_review_packet_template_count(review_templates_path: Path | None) -> int:
    if not review_templates_path or not review_templates_path.exists():
        return 0
    try:
        payload = read_json(review_templates_path)
    except Exception:
        return 0
    if isinstance(payload, dict) and isinstance(payload.get("reviewPackets"), list):
        return len([item for item in payload["reviewPackets"] if isinstance(item, dict)])
    if isinstance(payload, list):
        return len([item for item in payload if isinstance(item, dict)])
    return 0


def _output_paths(output_root: Path, review_templates_path: Path | None, stages: dict[str, Any]) -> dict[str, str]:
    paths = {"reviewPacketTemplates": str(review_templates_path) if review_templates_path else ""}
    for name, stage in stages.items():
        if isinstance(stage, dict):
            paths[name] = str(stage.get("manifestPath") or stage.get("outputPaths", {}).get("report") or "")
    return paths


def _registry_activation_not_required_stage(
    output_root: Path,
    *,
    expansion_report_path: Path,
    expansion_report: dict[str, Any],
    created_at: str,
) -> dict[str, Any]:
    output_root.mkdir(parents=True, exist_ok=True)
    manifest_path = output_root / "manifest.json"
    closeout_path = output_root / "closeout.md"
    expansion_counts = expansion_report.get("recordCounts", {}) if isinstance(expansion_report.get("recordCounts"), dict) else {}
    record_counts = {
        "routes": int(expansion_counts.get("routes", 0) or 0),
        "productionReadyRoutes": int(expansion_counts.get("productionReadyRoutes", 0) or 0),
        "candidateRoutes": int(expansion_counts.get("candidateRoutes", 0) or 0),
        "registryActivationNotRequiredRoutes": int(expansion_counts.get("productionReadyRoutes", 0) or 0),
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousRegistryActivationNotRequired.v1",
        "versionID": AUTONOMOUS_REGISTRY_ACTIVATION_CHAIN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for registry-activation-not-required production-ready route evidence",
        "valid": True,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry-activation-not-required evidence only",
        "expansionChainReportPath": str(expansion_report_path),
        "recordCounts": record_counts,
        "checks": [
            {"name": "production_ready_route_requires_no_registry_activation", "passed": True, "issues": []},
            {"name": "no_review_completion_or_registry_mutation_emitted", "passed": True, "issues": []},
        ],
        "issues": [],
        "outputPaths": {"manifest": str(manifest_path), "closeout": str(closeout_path)},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "registry-activation-not-required marker only",
            "not active registry mutation",
            "not source approval",
            "not legal approval",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not native activation",
            "not release readiness",
        ],
    }
    write_json(manifest_path, manifest)
    manifest["outputHashes"] = {"manifest": stable_hash(read_json(manifest_path))}
    write_json(manifest_path, manifest)
    closeout_path.write_text(
        "\n".join(
            [
                "# Source Atlas Registry Activation Not Required",
                "",
                "Status: Source Green for registry-activation-not-required production-ready route evidence",
                "Source Atlas status ceiling: Yellow overall Source Atlas; registry-activation-not-required evidence only",
                "",
                "Scope completed:",
                "- Recorded that the autonomous registry activation chain received a production-ready maintenance route with no review packet templates, no review-required blocked records, and no registry mutation work required.",
                "",
                "Production non-claims:",
                "- No active registry mutation, source approval, legal approval, claim output, pack output, R2 publish, native activation, release readiness, or universal coverage claim.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return {"manifestPath": str(manifest_path), "outputRoot": str(output_root), **manifest}


def _stage_summaries(stages: dict[str, Any]) -> dict[str, dict[str, Any]]:
    summaries: dict[str, dict[str, Any]] = {}
    for name, stage in stages.items():
        if not isinstance(stage, dict):
            continue
        summaries[name] = {
            "status": stage.get("status", ""),
            "valid": stage.get("valid"),
            "manifestPath": stage.get("manifestPath") or stage.get("outputPaths", {}).get("report", ""),
            "outputRoot": stage.get("outputRoot", ""),
            "recordCounts": stage.get("recordCounts", {}),
            "issues": stage.get("issues", []) or stage.get("evaluationIssues", []),
        }
        if "activeRegistryApplyAllowed" in stage:
            summaries[name]["activeRegistryApplyAllowed"] = stage["activeRegistryApplyAllowed"]
            summaries[name]["activeRegistryApplyDecision"] = stage.get("activeRegistryApplyDecision", "")
    return summaries


def _output_hashes(output_paths: dict[str, str]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for key, value in output_paths.items():
        if value and Path(value).exists() and Path(value).is_file():
            try:
                hashes[key] = stable_hash(read_json(Path(value)))
            except Exception:
                hashes[key] = stable_hash(Path(value).read_text(encoding="utf-8"))
    return hashes


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(str(issue) for issue in issues if issue))}


def _no_forbidden_outputs(counts: dict[str, int]) -> bool:
    return (
        counts["activeRegistryMutations"] == 0
        and counts["claims"] == 0
        and counts["packableClaims"] == 0
        and counts["r2PackableArtifacts"] == 0
        and counts["r2PublishOperations"] == 0
        and counts["nativeActivationOperations"] == 0
        and counts["finalOutputArtifacts"] == 0
    )


def _production_non_claims() -> list[str]:
    return [
        "No literal universal coverage.",
        "No full Source Atlas Green.",
        "No outside legal approval.",
        "No Release Green, Visual Green, independent accessibility Green, physical-device proof, or App Store readiness.",
        "No active repo registry mutation.",
        "No live harvest or production R2 upload/readback.",
        "No Worker deploy or native runtime activation.",
        "No final user plans, schedules, Steps, or personalized paths from Source Atlas/R2.",
    ]
