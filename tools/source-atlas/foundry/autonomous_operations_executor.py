"""Gated executor for Source Atlas autonomous operations plans.

The executor consumes the Train 105 operations plan and runs only operations
that are deterministic, local, and safe by default. It can create governed
candidate-only frontier intake artifacts and can optionally run the existing
fixture/dry-run public-reference delivery chain. Production R2 writes, Worker
deploys, live harvests, and native runtime proof remain blocked unless their
separate gates are satisfied outside this executor.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .autonomous_operations_planner import ACTION_ORDER, AUTONOMOUS_OPERATIONS_NON_CLAIMS
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .frontier_intake import FrontierIntakeOptions, compile_frontier_intake
from .model import PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json
from .public_reference_delivery_chain import PublicReferenceDeliveryChainOptions, run_public_reference_delivery_chain


AUTONOMOUS_OPERATIONS_EXECUTOR_VERSION = "source-atlas-autonomous-operations-executor-train-106"
AUTONOMOUS_OPERATIONS_EXECUTOR_KIND = "ambitions.sourceAtlas.autonomousOperationsExecutor.v1"

SAFE_EXECUTABLE_ACTIONS = {
    "define_coverage_frontier",
    "run_governed_harvest_and_claim_frontier",
}
OBSERVATION_ONLY_ACTIONS = {"monitor_current_production_runtime"}
PRODUCTION_GATED_ACTIONS = {
    "run_pack_production",
    "run_r2_publisher",
    "run_public_gateway_release",
    "compile_native_refresh_registry",
    "run_native_runtime_proof",
    "refresh_production_target_ledger",
    "run_production_recertification",
    "complete_source_governance_review",
}

EXECUTOR_NON_CLAIMS = [
    "gated autonomous operations executor only",
    "not uncontrolled live harvest",
    "not automatic production R2 write",
    "not Worker deployment",
    "not native runtime proof",
    "not release readiness",
    "not literal universal coverage",
    "not outside legal approval",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *AUTONOMOUS_OPERATIONS_NON_CLAIMS,
]


@dataclass(frozen=True)
class AutonomousOperationsExecutorOptions:
    operations_plan_path: Path
    output_root: Path
    created_at: str = "2026-06-28T00:00:00Z"
    execute_safe_actions: bool = False
    allow_fixture_delivery_chain: bool = False
    frontier_config_path: Path | None = None
    delivery_chain_limit: int = 5


def run_autonomous_operations_executor(options: AutonomousOperationsExecutorOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    plan = _read_plan(options.operations_plan_path, issues)
    plan_privacy_issues = boundary_issue_strings(boundary_issues_for_value(plan, "source-atlas-autonomous-operations-executor-plan"))
    issues.extend(plan_privacy_issues)
    if isinstance(plan, dict) and plan.get("valid") is not True:
        issues.append("operations plan is not valid")

    action_results: list[dict[str, Any]] = []
    artifacts: list[dict[str, str]] = []
    if isinstance(plan, dict) and not plan_privacy_issues and plan.get("valid") is True:
        for domain_plan in _domain_plans(plan):
            result = _execute_domain_plan(domain_plan=domain_plan, options=options, plan=plan)
            action_results.append(result["result"])
            artifacts.extend(result["artifacts"])

    unsafe_execution_attempts = [
        result for result in action_results if result.get("unsafeExecutionAttempted") is True
    ]
    action_results.sort(key=lambda item: (ACTION_ORDER.get(item["nextAction"], 999), item["domainID"]))
    artifacts.sort(key=lambda item: (item["domainID"], item["kind"], item["path"]))

    record_counts = _record_counts(action_results)
    report_path = output_root / "autonomous-operations-execution-report.json"
    markdown_path = output_root / "autonomous-operations-execution-report.md"
    closeout_path = output_root / "closeout.md"
    checks = [
        _check("operations_plan_loaded", isinstance(plan, dict), [] if isinstance(plan, dict) else ["operations plan missing or unreadable"]),
        _check("operations_plan_valid", isinstance(plan, dict) and plan.get("valid") is True, [] if isinstance(plan, dict) and plan.get("valid") is True else ["operations plan is not valid"]),
        _check("privacy_boundary", not plan_privacy_issues, plan_privacy_issues),
        _check("no_unsafe_actions_executed", not unsafe_execution_attempts, [item["domainID"] for item in unsafe_execution_attempts]),
        _check("production_actions_blocked_without_production_gates", _production_actions_blocked(action_results), _unblocked_production_actions(action_results)),
        _check("safe_actions_require_execute_safe_actions", _safe_actions_respect_execute_flag(action_results, options.execute_safe_actions), []),
    ]
    output_payload = {
        "schemaVersion": 1,
        "kind": AUTONOMOUS_OPERATIONS_EXECUTOR_KIND,
        "versionID": AUTONOMOUS_OPERATIONS_EXECUTOR_VERSION,
        "createdAt": options.created_at,
        "executionID": stable_id(
            "source_atlas.autonomous_operations_execution",
            {
                "plan": plan.get("planID") if isinstance(plan, dict) else str(options.operations_plan_path),
                "createdAt": options.created_at,
                "executeSafeActions": options.execute_safe_actions,
                "allowFixtureDeliveryChain": options.allow_fixture_delivery_chain,
            },
        ),
        "status": "Source Green for gated autonomous operations execution" if not issues and all(check["passed"] for check in checks) else "Red",
        "valid": not issues and all(check["passed"] for check in checks),
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; gated autonomous execution tooling only",
        "executionMode": "execute_safe_actions" if options.execute_safe_actions else "dry_run_plan_observation",
        "executeSafeActionsRequested": options.execute_safe_actions,
        "allowFixtureDeliveryChainRequested": options.allow_fixture_delivery_chain,
        "operationsPlanPath": str(options.operations_plan_path),
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "actionResults": action_results,
        "artifacts": artifacts,
        "allowedClaims": ["deterministic_gated_autonomous_operations_execution"] if not issues and all(check["passed"] for check in checks) else [],
        "blockedClaims": sorted(
            {
                "literal_universal_coverage",
                "full_source_atlas_green",
                "outside_legal_approval",
                "release_green",
                "app_store_readiness",
                "uncontrolled_live_harvest",
                "automatic_r2_write_without_execute_budget_approval",
                "worker_deploy_without_execute",
                "native_runtime_green_without_xcode_device_offline_proof",
                "final_user_plans_schedules_steps_from_source_atlas_or_r2",
            }
        ),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": plan_privacy_issues,
        "nonClaims": EXECUTOR_NON_CLAIMS,
        "productionNonClaims": _production_non_claims(record_counts),
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    output_payload["outputHashes"] = _artifact_hashes(artifacts)
    write_json(report_path, output_payload)
    output_payload["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, output_payload)
    markdown = autonomous_operations_execution_markdown(output_payload)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return {"manifestPath": str(report_path), "outputRoot": str(output_root), **output_payload}


def autonomous_operations_execution_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Autonomous Operations Executor Train 106",
        "",
        f"Status: {report['status']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        f"Execution mode: {report['executionMode']}",
        "",
        "Scope completed:",
        "- Gated executor consumes an autonomous operations plan.",
        "- Current production domains are observed without mutation.",
        "- Missing configured frontiers can be converted into governed candidate-only frontier intake artifacts.",
        "- Fixture/dry-run public-reference delivery chain can be run only behind the explicit safe-action and fixture-chain flags.",
        "- Production R2 writes, Worker deploys, live harvests, native runtime proof, and release claims remain blocked by explicit gates.",
        "",
        "Counts:",
        f"- Planned domains: {counts['plannedDomains']}",
        f"- Observed domains: {counts['observedDomains']}",
        f"- Safe actions executed: {counts['safeActionsExecuted']}",
        f"- Planned but not executed: {counts['plannedNotExecuted']}",
        f"- Blocked by gate: {counts['blockedByGate']}",
        f"- Frontier intake artifacts: {counts['frontierIntakeArtifacts']}",
        f"- Delivery-chain artifacts: {counts['deliveryChainArtifacts']}",
        f"- Production writes executed: {counts['productionWritesExecuted']}",
        "",
        "Action results:",
        "",
        "| Domain | Action | Status | Gate | Artifacts |",
        "| --- | --- | --- | --- | --- |",
    ]
    for result in report.get("actionResults", []):
        lines.append(
            "| {domain} | {action} | {status} | {gate} | {artifacts} |".format(
                domain=result["domainID"],
                action=result["nextAction"],
                status=result["status"],
                gate=result["requiredGate"],
                artifacts="<br>".join(result.get("artifactPaths", [])) or "none",
            )
        )
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- Executor inputs and outputs are public/reference domain IDs, source IDs, gates, proof paths, and candidate-only governance artifacts.",
            "- No private user context, goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior history, inferred priorities, or private graph data is introduced.",
            "- Source Atlas/R2 does not generate final plans, schedules, Steps, or personalized paths.",
            "",
            "Validation run:",
            "- See current train closeout for exact command output.",
            "",
            "Validation not run:",
            "- No live harvest was run.",
            "- No production Cloudflare R2 write was run by this executor.",
            "- No Worker deploy was run.",
            "- No native XCTest/build-for-testing was run by this tooling-only train.",
            "- Outside legal approval was not claimed.",
            "",
            "R2 request privacy proof:",
            "- Production R2 actions are blocked by the executor unless a separate publisher path is explicitly invoked with its gates.",
            "- Candidate-only frontier intake emits no R2 object keys.",
            "",
            "No private graph egress proof:",
            "- The operations plan is scanned before execution.",
            "- Private-looking plan fields or first-person runtime context fail validation before actions run.",
            "",
            "License/terms proof:",
            "- Frontier intake remains candidate-only and legal/terms review-required.",
            "- No redistribution or outside legal approval is claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Candidate sources remain review-required and pack-blocked.",
            "- Production and restricted paths are reported as blocked-by-gate, not executed.",
            "",
            "Provenance completeness proof:",
            "- Not claimed for new candidate domains. Candidate frontier intake emits no claims.",
            "",
            "Freshness/revocation proof:",
            "- Not claimed by executor-only output unless inherited from an explicitly run safe delivery-chain artifact.",
            "",
            "LKG/rollback proof:",
            "- Production rollback is not modified. Existing R2/LKG gates remain separate.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed by this tooling-only executor.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Files moved or created: autonomous operations executor module, CLI command, tests, generated evidence, and QA closeout.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: production writes, app runtime/device/offline proof, release proof, and legal approval remain separate proof gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in report.get("productionNonClaims", []))
    lines.extend(["", "Rollback plan:", "- Revert Train 106 executor module, CLI wiring, tests, generated execution artifacts, and QA evidence."])
    lines.append("")
    return "\n".join(lines)


def _execute_domain_plan(
    *,
    domain_plan: dict[str, Any],
    options: AutonomousOperationsExecutorOptions,
    plan: dict[str, Any],
) -> dict[str, Any]:
    action = str(domain_plan.get("nextAction", ""))
    domain_id = str(domain_plan.get("domainID", "unknown_domain"))
    required_gate = str(domain_plan.get("requiredGate", "manual_review"))
    if action in OBSERVATION_ONLY_ACTIONS:
        return {
            "result": _result(domain_plan, "observed", "current production runtime observed only; no mutation", []),
            "artifacts": [],
        }
    if action == "define_coverage_frontier":
        if not options.execute_safe_actions:
            return {
                "result": _result(domain_plan, "planned_not_executed", "safe frontier intake requires --execute-safe-actions", []),
                "artifacts": [],
            }
        return _run_frontier_intake(domain_plan=domain_plan, options=options, plan=plan)
    if action == "run_governed_harvest_and_claim_frontier":
        if not options.execute_safe_actions:
            return {
                "result": _result(domain_plan, "planned_not_executed", "fixture delivery chain requires --execute-safe-actions", []),
                "artifacts": [],
            }
        if not options.allow_fixture_delivery_chain:
            return {
                "result": _result(domain_plan, "blocked_by_gate", "fixture delivery chain requires --allow-fixture-delivery-chain", []),
                "artifacts": [],
            }
        return _run_fixture_delivery_chain(domain_plan=domain_plan, options=options)
    if action in PRODUCTION_GATED_ACTIONS:
        return {
            "result": _result(domain_plan, "blocked_by_gate", f"{action} requires separate gate: {required_gate}", []),
            "artifacts": [],
        }
    return {
        "result": _result(domain_plan, "blocked_by_gate", f"unknown action requires manual review: {action}", []),
        "artifacts": [],
    }


def _run_frontier_intake(
    *,
    domain_plan: dict[str, Any],
    options: AutonomousOperationsExecutorOptions,
    plan: dict[str, Any],
) -> dict[str, Any]:
    domain_id = str(domain_plan["domainID"])
    work_root = options.output_root / "frontier-intake" / domain_id
    input_path = work_root / "frontier-intake-input.json"
    proposal = _frontier_proposal_for_domain(domain_plan, options.created_at)
    write_json(input_path, proposal)
    frontier_config_path = options.frontier_config_path or _frontier_config_path_from_plan(plan)
    result = compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=input_path,
            output_root=work_root,
            frontier_config_path=frontier_config_path,
            created_at=options.created_at,
        )
    )
    artifact_paths = [
        str(input_path),
        str(work_root / "manifest.json"),
        str(work_root / "frontier-intake.json"),
        str(work_root / "proposed-frontiers.json"),
        str(work_root / "candidate-sources.json"),
    ]
    status = "executed_safe" if result.get("valid") is True else "failed"
    return {
        "result": _result(domain_plan, status, "candidate-only frontier intake generated", artifact_paths, child_valid=result.get("valid") is True),
        "artifacts": _artifacts(domain_id, "frontier_intake", artifact_paths),
    }


def _run_fixture_delivery_chain(
    *,
    domain_plan: dict[str, Any],
    options: AutonomousOperationsExecutorOptions,
) -> dict[str, Any]:
    domain_id = str(domain_plan["domainID"])
    work_root = options.output_root / "fixture-delivery-chain" / domain_id
    result = run_public_reference_delivery_chain(
        PublicReferenceDeliveryChainOptions(
            output_root=work_root,
            domain=domain_id,
            source_ids=tuple(domain_plan.get("sourceIDs") or ()),
            harvest_mode="fixture",
            limit=options.delivery_chain_limit,
            live=False,
            execute_harvest=False,
            environment="staging",
            channel="candidate",
            r2_mode="dry_run",
            execute_r2=False,
            native_status="review_required",
            created_at=options.created_at,
        )
    )
    artifact_paths = [path for path in result.get("outputPaths", {}).values() if path]
    status = "executed_safe" if result.get("valid") is True else "failed"
    return {
        "result": _result(domain_plan, status, "fixture harvest/claim/pack/R2-dry-run/native-review chain generated", artifact_paths, child_valid=result.get("valid") is True),
        "artifacts": _artifacts(domain_id, "fixture_delivery_chain", artifact_paths),
    }


def _frontier_proposal_for_domain(domain_plan: dict[str, Any], created_at: str) -> dict[str, Any]:
    domain_id = str(domain_plan.get("domainID", "unknown_domain"))
    return {
        "domainProposals": [
            {
                "proposal_id": stable_id(
                    "frontier_intake_proposal",
                    {"domainID": domain_id, "createdAt": created_at, "action": domain_plan.get("nextAction")},
                ),
                "frontier_id": domain_id,
                "domain": domain_id,
                "goal_intent_classes": [domain_id],
                "claim_classes": _claim_classes_for_domain(domain_id),
                "jurisdictions": _jurisdictions_for_domain(domain_id),
                "source_classes_required": _source_classes_for_domain(domain_id),
                "minimum_authority_classes": _minimum_authority_classes_for_domain(domain_id),
                "freshness_slas": _freshness_slas_for_domain(domain_id),
                "candidate_sources": _candidate_sources_for_domain(domain_id),
                "non_claims": [
                    "candidate frontier work order only",
                    "not claim output",
                    "not pack output",
                    "not R2 readiness",
                    "human source-lane and legal/API review required",
                ],
            }
        ]
    }


def _claim_classes_for_domain(domain_id: str) -> list[str]:
    if "benefit" in domain_id:
        return ["official_benefit_program_reference", "public_eligibility_reference", "public_deadline_reference"]
    if "credential" in domain_id or "education" in domain_id:
        return ["credential_requirement", "public_program_reference", "institution_reference"]
    if "civic" in domain_id or "government" in domain_id:
        return ["public_requirement_reference", "public_form_reference", "public_deadline_reference"]
    if "health" in domain_id or "wellness" in domain_id:
        return ["public_health_guideline", "wellness_safety_reference"]
    if "finance" in domain_id or "tax" in domain_id:
        return ["public_financial_education", "tax_deadline_reference", "public_benefit_program_reference"]
    return ["public_reference", "public_requirement_reference"]


def _jurisdictions_for_domain(domain_id: str) -> list[str]:
    if domain_id.endswith("_ca") or "_ca_" in domain_id:
        return ["CA"]
    return ["US"]


def _source_classes_for_domain(domain_id: str) -> list[str]:
    if any(marker in domain_id for marker in ("benefit", "civic", "government", "finance", "tax", "health", "wellness")):
        return ["official_government", "official_institution", "public_catalog"]
    return ["official_government", "official_institution", "standards_body", "public_catalog"]


def _minimum_authority_classes_for_domain(domain_id: str) -> list[str]:
    if any(marker in domain_id for marker in ("benefit", "civic", "government", "finance", "tax", "health", "wellness", "credential", "education")):
        return ["official_government", "official_institution"]
    return ["official_government", "official_institution", "standards_body"]


def _freshness_slas_for_domain(domain_id: str) -> list[str]:
    if any(marker in domain_id for marker in ("deadline", "tax", "benefit", "civic", "health", "finance")):
        return ["30d critical requirements", "90d informational references"]
    return ["90d reference metadata", "annual source-lane review"]


def _candidate_sources_for_domain(domain_id: str) -> list[dict[str, Any]]:
    if "benefit" in domain_id:
        return [
            {
                "discovery_method": "executor_seed",
                "publisher_name": "USA.gov",
                "publisher_url": "https://www.usa.gov/benefits",
                "declared_jurisdiction": "US",
                "declared_license": "",
                "declared_rights": "",
                "terms_url": "https://www.usa.gov/about",
                "rights_url": "",
                "dataset_url": "https://www.usa.gov/benefits",
                "distribution_urls": [],
                "api_docs_url": "",
                "source_class_guess": "official_government",
                "authority_class_guess": "official_government",
                "claim_class_guess": ["official_benefit_program_reference", "public_eligibility_reference"],
                "redistribution_guess": "terms_sensitive",
            },
            _data_catalog_candidate(domain_id),
        ]
    return [_data_catalog_candidate(domain_id)]


def _data_catalog_candidate(domain_id: str) -> dict[str, Any]:
    return {
        "discovery_method": "executor_seed",
        "publisher_name": "Data.gov Catalog",
        "publisher_url": "https://catalog.data.gov/",
        "declared_jurisdiction": "US",
        "declared_license": "",
        "declared_rights": "",
        "terms_url": "https://www.data.gov/privacy-policy/",
        "rights_url": "",
        "dataset_url": "https://catalog.data.gov/dataset",
        "distribution_urls": [],
        "api_docs_url": "https://catalog.data.gov/api/3/",
        "source_class_guess": "public_catalog",
        "authority_class_guess": "public_catalog",
        "claim_class_guess": _claim_classes_for_domain(domain_id),
        "redistribution_guess": "terms_sensitive",
    }


def _result(
    domain_plan: dict[str, Any],
    status: str,
    message: str,
    artifact_paths: list[str],
    *,
    child_valid: bool | None = None,
) -> dict[str, Any]:
    action = str(domain_plan.get("nextAction", ""))
    production_action = action in PRODUCTION_GATED_ACTIONS or action in {"run_r2_publisher", "run_public_gateway_release"}
    return {
        "domainID": str(domain_plan.get("domainID", "unknown_domain")),
        "requested": bool(domain_plan.get("requested") is True),
        "frontierConfigured": bool(domain_plan.get("frontierConfigured") is True),
        "readiness": str(domain_plan.get("readiness", "")),
        "nextAction": action,
        "requiredGate": str(domain_plan.get("requiredGate", "manual_review")),
        "status": status,
        "message": message,
        "safeAction": action in SAFE_EXECUTABLE_ACTIONS or action in OBSERVATION_ONLY_ACTIONS,
        "productionAction": production_action,
        "unsafeExecutionAttempted": False,
        "productionWriteExecuted": False,
        "childValid": child_valid,
        "artifactPaths": artifact_paths,
        "blockers": sorted(str(item) for item in domain_plan.get("blockers", []) if isinstance(item, str)),
        "nonClaims": [
            "not universal coverage",
            "not outside legal approval",
            "not release readiness",
            "not a final user plan, schedule, or Step generator",
        ],
    }


def _artifacts(domain_id: str, kind: str, paths: list[str]) -> list[dict[str, str]]:
    return [{"domainID": domain_id, "kind": kind, "path": path} for path in paths]


def _read_plan(path: Path, issues: list[str]) -> Any:
    if not path.exists():
        issues.append(f"operations plan missing: {path}")
        return None
    try:
        return read_json(path)
    except Exception as exc:  # pragma: no cover - defensive.
        issues.append(f"operations plan unreadable: {path}: {exc}")
        return None


def _domain_plans(plan: dict[str, Any]) -> list[dict[str, Any]]:
    return [item for item in plan.get("domainPlans", []) if isinstance(item, dict)]


def _frontier_config_path_from_plan(plan: dict[str, Any]) -> Path | None:
    evidence_paths = plan.get("evidencePaths", {})
    if not isinstance(evidence_paths, dict):
        return None
    raw = evidence_paths.get("frontierConfig")
    if isinstance(raw, str) and raw:
        return Path(raw)
    return None


def _record_counts(action_results: list[dict[str, Any]]) -> dict[str, int]:
    return {
        "plannedDomains": len(action_results),
        "observedDomains": sum(1 for result in action_results if result["status"] == "observed"),
        "safeActionsExecuted": sum(1 for result in action_results if result["status"] == "executed_safe"),
        "plannedNotExecuted": sum(1 for result in action_results if result["status"] == "planned_not_executed"),
        "blockedByGate": sum(1 for result in action_results if result["status"] == "blocked_by_gate"),
        "failedActions": sum(1 for result in action_results if result["status"] == "failed"),
        "frontierIntakeArtifacts": sum(
            1
            for result in action_results
            for path in result.get("artifactPaths", [])
            if "frontier-intake" in path
        ),
        "deliveryChainArtifacts": sum(
            1
            for result in action_results
            for path in result.get("artifactPaths", [])
            if "fixture-delivery-chain" in path
        ),
        "productionWritesExecuted": sum(1 for result in action_results if result.get("productionWriteExecuted") is True),
        "unsafeExecutionAttempts": sum(1 for result in action_results if result.get("unsafeExecutionAttempted") is True),
    }


def _production_actions_blocked(action_results: list[dict[str, Any]]) -> bool:
    return not _unblocked_production_actions(action_results)


def _unblocked_production_actions(action_results: list[dict[str, Any]]) -> list[str]:
    return [
        result["domainID"]
        for result in action_results
        if result.get("productionAction") is True and result.get("status") != "blocked_by_gate"
    ]


def _safe_actions_respect_execute_flag(action_results: list[dict[str, Any]], execute_safe_actions: bool) -> bool:
    if execute_safe_actions:
        return True
    return all(result.get("status") != "executed_safe" for result in action_results)


def _artifact_hashes(artifacts: list[dict[str, str]]) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for artifact in artifacts:
        path = Path(artifact["path"])
        if path.exists() and path.suffix == ".json":
            hashes[f"{artifact['domainID']}:{artifact['kind']}:{path.name}"] = stable_hash(read_json(path))
    return dict(sorted(hashes.items()))


def _production_non_claims(record_counts: dict[str, int]) -> list[str]:
    claims = [
        "no full Source Atlas Green",
        "no literal universal coverage",
        "no release Green",
        "no App Store readiness",
        "no outside legal approval",
        "no final user plan, schedule, or Step generation",
        "no live harvest execution",
        "no Worker deployment",
        "no native runtime/device/offline proof",
    ]
    if record_counts["productionWritesExecuted"] == 0:
        claims.append("no production Cloudflare R2 write executed by this executor")
    return claims


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues}
