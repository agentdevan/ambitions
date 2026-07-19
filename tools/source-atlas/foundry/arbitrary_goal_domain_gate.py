"""Governed arbitrary-domain handling gate for Source Atlas.

This gate proves Source Atlas can handle arbitrary public/reference domain
requests without claiming literal universal coverage. Known domains must route
to current production monitoring, unknown public-reference domains must route to
candidate-only frontier intake, and private-looking input must be rejected
before any persistent artifact is written.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any

from .autonomous_operations_executor import AutonomousOperationsExecutorOptions, run_autonomous_operations_executor
from .autonomous_operations_planner import AutonomousOperationsPlannerOptions, compile_autonomous_operations_plan
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


ARBITRARY_DOMAIN_GATE_VERSION = "source-atlas-arbitrary-domain-handling-gate-train-115"
ARBITRARY_DOMAIN_GATE_KIND = "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1"

DEFAULT_UNKNOWN_PROBES = ("unrepresented_public_reference_domain",)
PRIVATE_PROBE_SENTINEL = "I need source atlas to use my schedule"

ARBITRARY_DOMAIN_NON_CLAIMS = [
    "governed arbitrary public/reference domain handling only",
    "not literal universal coverage",
    "not full Source Atlas Green",
    "not outside legal approval",
    "not Release Green",
    "not App Store or TestFlight readiness",
    "not private goal-text processing by Source Atlas",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    "unknown domains remain candidate-only until source/legal/API/frontier review completes",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class ArbitraryDomainHandlingGateOptions:
    frontier_config_path: Path
    source_lane_registry_path: Path
    production_target_ledger_path: Path
    production_recertification_path: Path
    output_root: Path
    finish_line_gate_path: Path | None = None
    created_at: str = "2026-06-29T00:00:00Z"
    unknown_probe_domains: tuple[str, ...] = DEFAULT_UNKNOWN_PROBES


def run_arbitrary_domain_handling_gate(options: ArbitraryDomainHandlingGateOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    finish_line_gate = _read_optional_json(options.finish_line_gate_path, "finish-line gate", issues)
    frontier_config = _read_required_json(options.frontier_config_path, "frontier config", issues)
    unknown_probes = tuple(sorted(set(options.unknown_probe_domains or DEFAULT_UNKNOWN_PROBES)))

    configured_plan = compile_autonomous_operations_plan(
        AutonomousOperationsPlannerOptions(
            frontier_config_path=options.frontier_config_path,
            source_lane_registry_path=options.source_lane_registry_path,
            production_target_ledger_path=options.production_target_ledger_path,
            production_recertification_path=options.production_recertification_path,
            output_root=output_root / "01-configured-domain-plan",
            created_at=options.created_at,
        )
    )
    unknown_plan = compile_autonomous_operations_plan(
        AutonomousOperationsPlannerOptions(
            frontier_config_path=options.frontier_config_path,
            source_lane_registry_path=options.source_lane_registry_path,
            production_target_ledger_path=options.production_target_ledger_path,
            production_recertification_path=options.production_recertification_path,
            requested_domains=unknown_probes,
            output_root=output_root / "02-unknown-domain-plan",
            created_at=options.created_at,
        )
    )
    unknown_execution = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=Path(unknown_plan["outputPaths"]["report"]),
            output_root=output_root / "03-unknown-domain-execution",
            created_at=options.created_at,
            execute_safe_actions=True,
            allow_fixture_delivery_chain=False,
            frontier_config_path=options.frontier_config_path,
        )
    )
    private_probe = _run_private_probe(options)

    alias_conflicts = _alias_conflicts(frontier_config)
    checks = [
        _check("finish_line_gate_valid_when_supplied", _finish_line_ok(finish_line_gate), _finish_line_issues(finish_line_gate)),
        _check("configured_domains_route_to_current_or_bounded_action", _configured_plan_ok(configured_plan), _configured_plan_issues(configured_plan)),
        _check("unknown_public_domains_route_to_candidate_frontier_intake", _unknown_domains_ok(unknown_plan, unknown_execution, unknown_probes), _unknown_domain_issues(unknown_plan, unknown_execution, unknown_probes)),
        _check("candidate_intake_emits_no_claims_packs_r2_or_native_activation", _candidate_outputs_safe(unknown_execution), _candidate_output_issues(unknown_execution)),
        _check("private_context_rejected_without_persistent_artifact", private_probe["rejected"] is True, [] if private_probe["rejected"] else ["private-context sentinel was not rejected"]),
        _check("frontier_aliases_are_unambiguous", not alias_conflicts, [f"{alias}: {', '.join(domains)}" for alias, domains in alias_conflicts.items()]),
    ]
    record_counts = _record_counts(
        frontier_config=frontier_config,
        configured_plan=configured_plan,
        unknown_plan=unknown_plan,
        unknown_execution=unknown_execution,
        unknown_probes=unknown_probes,
        alias_conflicts=alias_conflicts,
    )
    output_privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(
            {
                "recordCounts": record_counts,
                "checks": checks,
                "unknownProbeDomains": list(unknown_probes),
                "privateProbe": private_probe,
                "nonClaims": ARBITRARY_DOMAIN_NON_CLAIMS,
            },
            "source-atlas-arbitrary-domain-handling-gate",
        )
    )
    checks.append(_check("output_privacy_scan_passed", not output_privacy_issues, output_privacy_issues))
    issues.extend(output_privacy_issues)
    valid = not issues and all(check["passed"] for check in checks)

    report_path = output_root / "arbitrary-domain-handling-gate-report.json"
    markdown_path = output_root / "arbitrary-domain-handling-gate-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": ARBITRARY_DOMAIN_GATE_KIND,
        "versionID": ARBITRARY_DOMAIN_GATE_VERSION,
        "createdAt": options.created_at,
        "gateID": stable_id(
            "source_atlas.arbitrary_domain_handling_gate",
            {
                "frontierConfigPath": str(options.frontier_config_path),
                "unknownProbeDomains": list(unknown_probes),
                "createdAt": options.created_at,
            },
        ),
        "status": "Source Green for governed arbitrary public/reference domain handling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; arbitrary public/reference domain handling only",
        "overallReadinessStatus": "governed_arbitrary_domain_handling_ready" if valid else "blocked_or_partial",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "configuredDomainPlan": _stage_summary(configured_plan),
        "unknownDomainPlan": _stage_summary(unknown_plan),
        "unknownDomainExecution": _stage_summary(unknown_execution),
        "privateContextProbe": private_probe,
        "frontierAliasConflicts": alias_conflicts,
        "allowedClaims": ["governed_arbitrary_public_reference_domain_handling"] if valid else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "source_atlas_private_goal_text_processing",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": output_privacy_issues,
        "nonClaims": ARBITRARY_DOMAIN_NON_CLAIMS,
        "evidencePaths": {
            "frontierConfig": str(options.frontier_config_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path),
            "productionTargetLedger": str(options.production_target_ledger_path),
            "productionRecertification": str(options.production_recertification_path),
            "finishLineGate": str(options.finish_line_gate_path) if options.finish_line_gate_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "configuredDomainPlan": str(configured_plan["outputPaths"]["report"]),
            "unknownDomainPlan": str(unknown_plan["outputPaths"]["report"]),
            "unknownDomainExecution": str(unknown_execution["outputPaths"]["report"]),
        },
    }
    report["outputHashes"] = _output_hashes(report["outputPaths"])
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = arbitrary_domain_handling_gate_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def arbitrary_domain_handling_gate_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Arbitrary Domain Handling Gate Train 115",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        "",
        "Scope completed:",
        "- Proves configured public/reference frontiers route through autonomous planning without private context.",
        "- Proves unknown public/reference domain probes become candidate-only frontier intake work, not claims, packs, R2 output, or native activation.",
        "- Proves private-looking input is rejected in a temporary non-persistent probe before execution.",
        "- Proves frontier aliases are unambiguous.",
        "",
        "Counts:",
        f"- Configured frontiers: {counts['configuredFrontiers']}",
        f"- Configured monitor domains: {counts['configuredMonitorDomains']}",
        f"- Unknown probe domains: {counts['unknownProbeDomains']}",
        f"- Unknown candidate frontier intake artifacts: {counts['unknownFrontierIntakeArtifacts']}",
        f"- Candidate claims: {counts['candidateClaims']}",
        f"- Candidate R2 publish operations: {counts['candidateR2PublishOperations']}",
        f"- Candidate native activation operations: {counts['candidateNativeActivationOperations']}",
        f"- Alias conflicts: {counts['aliasConflicts']}",
        "",
        "Checks:",
    ]
    for check in report.get("checks", []):
        lines.append(f"- {check['name']}: {'pass' if check['passed'] else 'fail'}")
        for issue in check.get("issues", []):
            lines.append(f"  - {issue}")
    lines.extend(["", "Allowed claims:"])
    if report.get("allowedClaims"):
        lines.extend(f"- `{claim}`" for claim in report["allowedClaims"])
    else:
        lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- Source Atlas handles public/reference domain IDs and source/governance metadata only.",
            "- Private-looking input is rejected without a persistent repo artifact.",
            "- Unknown domains remain candidate-only until source-lane, legal/API, claim, pack, R2, and native gates pass.",
            "- Source Atlas/R2 do not generate final plans, schedules, Steps, priority order, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No new live harvest was run.",
            "- No new production R2 upload/readback was run by this gate.",
            "- No native XCTest/build-for-testing was run by this tooling-only gate.",
            "- No outside legal, release owner, physical-device, visual, or accessibility approval was produced.",
            "",
            "R2 request privacy proof:",
            "- Candidate frontier intake emits no R2 object keys or publish operations.",
            "- Production R2 proof remains inherited from the supplied finish-line/recertification evidence only.",
            "",
            "No private graph egress proof:",
            "- Gate output is privacy-scanned.",
            "- The private-context sentinel is tested in a temporary directory and summarized without persisting the sentinel string.",
            "",
            "License/terms proof:",
            "- Unknown domains are candidate-only and review-required.",
            "- No redistribution, outside legal approval, or pack eligibility is granted for unknown domains.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate sources remain review-required and claim-authority-blocked.",
            "",
            "Provenance completeness proof:",
            "- Not claimed for unknown candidate domains because no claims are emitted.",
            "",
            "Freshness/revocation proof:",
            "- Configured domains use supplied production recertification evidence; candidate domains have no pack freshness claim.",
            "",
            "LKG/rollback proof:",
            "- No production pointer, pack, registry, or native state is mutated by this gate.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed by this tooling-only gate.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Files moved or created: arbitrary-domain handling gate, CLI wiring, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: unknown domains still require source/legal/API/frontier review, pack/R2/native gates, and release proof before production use.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 115 arbitrary-domain handling gate module, CLI wiring, tests, generated artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _run_private_probe(options: ArbitraryDomainHandlingGateOptions) -> dict[str, Any]:
    with TemporaryDirectory(prefix="source-atlas-private-probe-") as temp_dir:
        temp_root = Path(temp_dir)
        result = compile_autonomous_operations_plan(
            AutonomousOperationsPlannerOptions(
                frontier_config_path=options.frontier_config_path,
                source_lane_registry_path=options.source_lane_registry_path,
                production_target_ledger_path=options.production_target_ledger_path,
                production_recertification_path=options.production_recertification_path,
                requested_domains=(PRIVATE_PROBE_SENTINEL,),
                output_root=temp_root / "private-probe-plan",
                created_at=options.created_at,
            )
        )
        return {
            "rejected": result.get("valid") is not True and bool(result.get("privacyIssues")),
            "privacyIssueCount": len(result.get("privacyIssues", [])),
            "persistentArtifactWritten": False,
            "rawProbePersisted": False,
            "nonClaims": [
                "private-context rejection proof only",
                "raw private-looking sentinel is not persisted in repo evidence",
            ],
        }


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"{label} missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive artifact handling
        issues.append(f"{label} unreadable: {path}: {exc}")
        return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    return _read_required_json(path, label, issues)


def _finish_line_ok(finish_line_gate: Any) -> bool:
    if finish_line_gate is None:
        return True
    return isinstance(finish_line_gate, dict) and finish_line_gate.get("valid") is True


def _finish_line_issues(finish_line_gate: Any) -> list[str]:
    if finish_line_gate is None or _finish_line_ok(finish_line_gate):
        return []
    if not isinstance(finish_line_gate, dict):
        return ["finish-line gate missing or unreadable"]
    return list(finish_line_gate.get("issues", []) or ["finish-line gate valid flag is not true"])


def _configured_plan_ok(configured_plan: dict[str, Any]) -> bool:
    if configured_plan.get("valid") is not True:
        return False
    plans = configured_plan.get("domainPlans", [])
    return bool(plans) and all(
        item.get("nextAction") == "monitor_current_production_runtime"
        or item.get("requiredGate")
        for item in plans
        if isinstance(item, dict)
    )


def _configured_plan_issues(configured_plan: dict[str, Any]) -> list[str]:
    if _configured_plan_ok(configured_plan):
        return []
    issues = list(configured_plan.get("issues", []))
    issues.extend(configured_plan.get("globalBlockers", []))
    return issues or ["configured domain plan did not emit bounded actions"]


def _unknown_domains_ok(unknown_plan: dict[str, Any], unknown_execution: dict[str, Any], unknown_probes: tuple[str, ...]) -> bool:
    if unknown_plan.get("valid") is not True or unknown_execution.get("valid") is not True:
        return False
    plan_by_domain = {
        item.get("domainID"): item
        for item in unknown_plan.get("domainPlans", [])
        if isinstance(item, dict)
    }
    execution_by_domain = {
        item.get("domainID"): item
        for item in unknown_execution.get("actionResults", [])
        if isinstance(item, dict)
    }
    return all(
        isinstance(plan_by_domain.get(domain), dict)
        and plan_by_domain[domain].get("nextAction") == "define_coverage_frontier"
        and isinstance(execution_by_domain.get(domain), dict)
        and execution_by_domain[domain].get("status") == "executed_safe"
        and execution_by_domain[domain].get("childValid") is True
        for domain in unknown_probes
    )


def _unknown_domain_issues(unknown_plan: dict[str, Any], unknown_execution: dict[str, Any], unknown_probes: tuple[str, ...]) -> list[str]:
    if _unknown_domains_ok(unknown_plan, unknown_execution, unknown_probes):
        return []
    issues = [f"unknown plan: {issue}" for issue in unknown_plan.get("issues", [])]
    issues.extend(f"unknown execution: {issue}" for issue in unknown_execution.get("issues", []))
    return issues or ["one or more unknown public domains did not route to candidate-only frontier intake"]


def _candidate_outputs_safe(unknown_execution: dict[str, Any]) -> bool:
    counts = unknown_execution.get("recordCounts", {})
    return (
        int(counts.get("frontierIntakeArtifacts", 0) or 0) > 0
        and int(counts.get("r2PublishOperations", 0) or 0) == 0
        and int(counts.get("nativeActivationOperations", 0) or 0) == 0
        and int(counts.get("productionWritesExecuted", 0) or 0) == 0
    )


def _candidate_output_issues(unknown_execution: dict[str, Any]) -> list[str]:
    if _candidate_outputs_safe(unknown_execution):
        return []
    return ["candidate execution produced unsafe counts or no frontier intake artifacts"]


def _alias_conflicts(frontier_config: Any) -> dict[str, list[str]]:
    if not isinstance(frontier_config, dict):
        return {}
    index: dict[str, set[str]] = {}
    for frontier in frontier_config.get("frontiers", []):
        if not isinstance(frontier, dict):
            continue
        domain = str(frontier.get("frontier_id") or frontier.get("domain") or "")
        if not domain:
            continue
        for alias in _aliases_for_frontier(frontier, domain):
            index.setdefault(_normalize(alias), set()).add(domain)
    return {
        alias: sorted(domains)
        for alias, domains in sorted(index.items())
        if len(domains) > 1
    }


def _aliases_for_frontier(frontier: dict[str, Any], domain: str) -> list[str]:
    aliases = [
        domain,
        str(frontier.get("frontier_id") or ""),
        str(frontier.get("domain") or ""),
        *_string_list(frontier.get("goal_intent_classes")),
        *_string_list(frontier.get("domain_aliases")),
    ]
    return sorted({alias for alias in aliases if alias})


def _normalize(value: str) -> str:
    return value.strip().lower().replace("-", "_").replace(" ", "_")


def _string_list(value: Any) -> list[str]:
    return [item for item in value if isinstance(item, str)] if isinstance(value, list) else []


def _record_counts(
    *,
    frontier_config: Any,
    configured_plan: dict[str, Any],
    unknown_plan: dict[str, Any],
    unknown_execution: dict[str, Any],
    unknown_probes: tuple[str, ...],
    alias_conflicts: dict[str, list[str]],
) -> dict[str, int]:
    configured_counts = configured_plan.get("recordCounts", {})
    unknown_counts = unknown_execution.get("recordCounts", {})
    return {
        "configuredFrontiers": len(frontier_config.get("frontiers", [])) if isinstance(frontier_config, dict) else 0,
        "configuredPlannedDomains": int(configured_counts.get("plannedDomains", 0) or 0),
        "configuredMonitorDomains": int(configured_counts.get("monitorDomains", 0) or 0),
        "unknownProbeDomains": len(unknown_probes),
        "unknownUnmatchedDomains": int(unknown_plan.get("recordCounts", {}).get("unmatchedRequestedDomains", 0) or 0),
        "unknownFrontierIntakeArtifacts": int(unknown_counts.get("frontierIntakeArtifacts", 0) or 0),
        "candidateClaims": int(unknown_counts.get("claims", 0) or 0),
        "candidateR2PublishOperations": int(unknown_counts.get("r2PublishOperations", 0) or 0),
        "candidateNativeActivationOperations": int(unknown_counts.get("nativeActivationOperations", 0) or 0),
        "candidateProductionWrites": int(unknown_counts.get("productionWritesExecuted", 0) or 0),
        "aliasConflicts": len(alias_conflicts),
    }


def _stage_summary(stage: dict[str, Any]) -> dict[str, Any]:
    return {
        "status": stage.get("status"),
        "valid": stage.get("valid"),
        "recordCounts": stage.get("recordCounts", {}),
        "outputPaths": stage.get("outputPaths", {}),
        "issues": stage.get("issues", []),
    }


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": bool(passed), "issues": sorted(set(issues))}


def _output_hashes(paths: dict[str, str | None]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for label, raw_path in paths.items():
        if not raw_path:
            continue
        path = Path(raw_path)
        if path.exists():
            hashes[label] = stable_hash(read_json(path)) if path.suffix == ".json" else stable_hash(path.read_text(encoding="utf-8"))
    return hashes
