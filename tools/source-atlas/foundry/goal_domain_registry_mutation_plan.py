"""Plan goal-domain registry mutations from completed review bundles.

This planner is the dry-run handoff after Train 93 review completion intake.
It converts fully completed goal-domain review bundles into source-lane,
legal/terms, and API registry mutation plans. It never writes active
registries and never emits claims, packs, R2 objects, native activations, or
user plans.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .goal_domain_review_completion_intake import (
    GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND,
    GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_VERSION,
    EXPECTED_REVIEW_LANES,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_REGISTRY_MUTATION_PLAN_VERSION = "source-atlas-goal-domain-registry-mutation-plan-train-94"
GOAL_DOMAIN_REGISTRY_MUTATION_PLAN_KIND = "ambitions.sourceAtlas.goalDomainRegistryMutationPlan.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}

REGISTRY_MUTATION_PLAN_NON_CLAIMS = [
    "goal-domain registry mutation planning only",
    "not active registry mutation",
    "not source authority by itself",
    "not legal approval",
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
class GoalDomainRegistryMutationPlanOptions:
    review_completions_path: Path
    output_root: Path
    execute: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def compile_goal_domain_registry_mutation_plan(options: GoalDomainRegistryMutationPlanOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = _read_review_completions_payload(options.review_completions_path)
    collection = _completion_collection(payload)
    completed_packets = _completed_packets(collection)
    review_bundles = _review_bundles(collection)
    input_schema_issues = _input_schema_issues(payload, collection, completed_packets, review_bundles)
    input_privacy_issues = privacy_findings_for_value(payload, "goal-domain-registry-mutation-plan-input")

    planned_mutations, blocked_mutations, planning_issues = _plan_registry_mutations(completed_packets, review_bundles, created_at)
    record_counts = {
        "reviewBundles": len(review_bundles),
        "completedReviewPackets": len(completed_packets),
        "plannedRegistryMutations": len(planned_mutations),
        "blockedRegistryMutations": len(blocked_mutations),
        "activeRegistryMutations": 0,
        "plannedSourceLaneEntries": len(planned_mutations),
        "plannedLegalTermsEntries": len(planned_mutations),
        "plannedApiPolicyEntries": len(planned_mutations),
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_REGISTRY_MUTATION_PLAN_KIND,
        "versionID": GOAL_DOMAIN_REGISTRY_MUTATION_PLAN_VERSION,
        "compatibleReviewCompletionIntakeVersionID": GOAL_DOMAIN_REVIEW_COMPLETION_INTAKE_VERSION,
        "createdAt": created_at,
        "reviewCompletionsPath": str(options.review_completions_path),
        "executeRequested": options.execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "plannedRegistryMutations": planned_mutations,
        "blockedRegistryMutations": blocked_mutations,
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REGISTRY_MUTATION_PLAN_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "goal-domain-registry-mutation-plan")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    execute_issues = []
    if options.execute and not options.allow_active_registry_write:
        execute_issues.append("--execute requires --allow-active-registry-write and a separate registry apply train")
    if options.allow_active_registry_write:
        execute_issues.append("active registry writes are not implemented by goal-domain registry mutation planning")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(review_bundles), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "completed_bundles_required_for_planned_mutations",
            "passed": all(item["completionStatus"] == "completed_review_ready_for_registry_apply_planning" for item in planned_mutations),
            "issues": [],
        },
        {
            "name": "incomplete_bundles_block_without_mutation",
            "passed": len(planned_mutations) + len(blocked_mutations) == len(review_bundles),
            "issues": [],
        },
        {
            "name": "execute_requires_separate_active_apply_gate",
            "passed": not execute_issues,
            "issues": execute_issues,
        },
        {
            "name": "planned_mutations_are_dry_run_only",
            "passed": all(item["activeRegistryWritten"] is False and item["status"] == "dry_run_ready_for_separate_registry_apply" for item in planned_mutations),
            "issues": [],
        },
        {
            "name": "no_active_registry_mutations_written",
            "passed": record_counts["activeRegistryMutations"] == 0 and artifact["activeRegistryMutations"] == [],
            "issues": [],
        },
        {
            "name": "registry_mutation_plan_emits_no_claims_packs_r2_or_native_activation",
            "passed": record_counts["claims"] == 0
            and record_counts["packableClaims"] == 0
            and record_counts["r2PackableArtifacts"] == 0
            and record_counts["r2PublishOperations"] == 0
            and record_counts["nativeActivationOperations"] == 0,
            "issues": [],
        },
        {"name": "planning_fields_valid", "passed": not planning_issues, "issues": planning_issues},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(planning_issues)
    issues.extend(execute_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    output_paths = {
        "goalDomainRegistryMutationPlan": str(output_root / "goal-domain-registry-mutation-plan.json"),
        "plannedRegistryMutations": str(output_root / "planned-registry-mutations.json"),
        "blockedRegistryMutations": str(output_root / "blocked-registry-mutations.json"),
        "activeRegistryMutations": str(output_root / "active-registry-mutations.json"),
        "manifest": str(output_root / "manifest.json"),
        "closeout": str(output_root / "closeout.md"),
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainRegistryMutationPlanManifest.v1",
        "versionID": GOAL_DOMAIN_REGISTRY_MUTATION_PLAN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain registry mutation planning" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry mutation planning only",
        "reviewCompletionsPath": str(options.review_completions_path),
        "executeRequested": options.execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": output_paths,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REGISTRY_MUTATION_PLAN_NON_CLAIMS,
    }

    write_json(output_root / "goal-domain-registry-mutation-plan.json", artifact)
    write_json(
        output_root / "planned-registry-mutations.json",
        {"kind": "ambitions.sourceAtlas.goalDomainPlannedRegistryMutations.v1", "createdAt": created_at, "plannedRegistryMutations": planned_mutations},
    )
    write_json(
        output_root / "blocked-registry-mutations.json",
        {"kind": "ambitions.sourceAtlas.goalDomainBlockedRegistryMutations.v1", "createdAt": created_at, "blockedRegistryMutations": blocked_mutations},
    )
    write_json(
        output_root / "active-registry-mutations.json",
        {"kind": "ambitions.sourceAtlas.goalDomainActiveRegistryMutations.v1", "createdAt": created_at, "activeRegistryMutations": []},
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "goalDomainRegistryMutationPlan": stable_hash(read_json(output_root / "goal-domain-registry-mutation-plan.json")),
        "plannedRegistryMutations": stable_hash(read_json(output_root / "planned-registry-mutations.json")),
        "blockedRegistryMutations": stable_hash(read_json(output_root / "blocked-registry-mutations.json")),
        "activeRegistryMutations": stable_hash(read_json(output_root / "active-registry-mutations.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(goal_domain_registry_mutation_plan_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_goal_domain_registry_mutation_plan_report(
    markdown_path: Path,
    json_path: Path,
    *,
    review_completions_path: Path,
    output_root: Path,
    execute: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_registry_mutation_plan(
        GoalDomainRegistryMutationPlanOptions(
            review_completions_path=review_completions_path,
            output_root=output_root,
            execute=execute,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_registry_mutation_plan_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_registry_mutation_plan_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Registry Mutation Plan Train 94",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Execute requested: {result['executeRequested']}",
        f"Allow active registry write: {result['allowActiveRegistryWrite']}",
        "",
        "Scope completed:",
        "- Dry-run registry mutation planner for completed goal-domain review bundles.",
        "- Missing or partial review bundles produce blocked mutation records, not source authority.",
        "- Planned registry mutation records remain dry-run only; active registry mutation output is empty.",
        "",
        "Counts:",
        f"- Review bundles: {counts['reviewBundles']}",
        f"- Completed review packets: {counts['completedReviewPackets']}",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Planned source-lane entries: {counts['plannedSourceLaneEntries']}",
        f"- Planned legal/terms entries: {counts['plannedLegalTermsEntries']}",
        f"- Planned API-policy entries: {counts['plannedApiPolicyEntries']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- No active registries are written by this planner.",
        "- No claims, packs, R2 objects, native activations, final plans, schedules, or Steps are emitted.",
        "- Completed reviews become planning inputs only; later registry apply remains a separate gate.",
        "",
        "Validation run:",
        "- See current train closeout for exact commands.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
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
            "- Registry mutation plans contain public/reference governance metadata only.",
            "",
            "No private graph egress proof:",
            "- Input and output privacy scans must pass before Source Green.",
            "- The planner emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Legal/terms entries are planned only from completed legal review packets.",
            "- Outside legal approval is not claimed without an approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- This planner emits no packable output. Restricted-source exclusion remains enforced downstream by source-lane, legal, pack, and R2 gates.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 94. This train plans registry mutations only.",
            "",
            "Freshness/revocation proof:",
            "- No pack freshness, revocation, or LKG operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer, R2 object, or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 94. No native files are touched by this tooling train.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry registry mutation planner, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: explicit registry apply gate from dry-run plans, still blocking active writes without owner approval.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _read_review_completions_payload(path: Path) -> Any:
    payload = read_json(path)
    if isinstance(payload, dict) and isinstance(payload.get("outputPaths"), dict) and payload["outputPaths"].get("goalDomainReviewCompletions"):
        candidate = Path(str(payload["outputPaths"]["goalDomainReviewCompletions"]))
        if candidate.exists():
            return read_json(candidate)
    return payload


def _completion_collection(payload: Any) -> dict[str, Any]:
    if isinstance(payload, dict) and payload.get("kind") == GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND:
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("goalDomainReviewCompletions"), dict):
        return _completion_collection(payload["goalDomainReviewCompletions"])
    return {}


def _completed_packets(collection: dict[str, Any]) -> list[dict[str, Any]]:
    if isinstance(collection.get("completedReviewPackets"), list):
        return [item for item in collection["completedReviewPackets"] if isinstance(item, dict)]
    return []


def _review_bundles(collection: dict[str, Any]) -> list[dict[str, Any]]:
    if isinstance(collection.get("reviewBundles"), list):
        return [item for item in collection["reviewBundles"] if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, collection: dict[str, Any], completed_packets: list[dict[str, Any]], review_bundles: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, dict):
        issues.append("goal-domain registry mutation plan input must be an object")
    if not collection:
        issues.append("goal-domain registry mutation plan input must include goal-domain review completions")
    if collection and collection.get("kind") != GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND:
        issues.append(f"goal-domain review completions kind must be {GOAL_DOMAIN_REVIEW_COMPLETION_COLLECTION_KIND}")
    if not review_bundles:
        issues.append("goal-domain registry mutation plan input must include reviewBundles")
    for index, bundle in enumerate(review_bundles):
        for field in ("bundleID", "requestID", "completionStatus", "requiredReviewLanes"):
            if not bundle.get(field):
                issues.append(f"reviewBundles[{index}].{field} required")
    for index, packet in enumerate(completed_packets):
        for field in ("packetID", "requestID", "reviewLane", "completionStatus", "reviewFields"):
            if not packet.get(field):
                issues.append(f"completedReviewPackets[{index}].{field} required")
        if packet.get("completionStatus") != "completed":
            issues.append(f"completedReviewPackets[{index}].completionStatus must be completed")
    return sorted(set(issues))


def _plan_registry_mutations(
    completed_packets: list[dict[str, Any]],
    review_bundles: list[dict[str, Any]],
    created_at: str,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[str]]:
    issues: list[str] = []
    packets_by_request: dict[str, dict[str, dict[str, Any]]] = {}
    for packet in completed_packets:
        packets_by_request.setdefault(str(packet.get("requestID") or ""), {})[str(packet.get("reviewLane") or "")] = packet

    planned: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    for bundle in review_bundles:
        request_id = str(bundle.get("requestID") or "")
        lanes = packets_by_request.get(request_id, {})
        if bundle.get("registryMutationPlanningReady") is not True or bundle.get("completionStatus") != "completed_review_ready_for_registry_mutation_planning":
            blocked.append(_blocked_mutation(bundle, created_at, ["completed_review_bundle_required", *[str(item) for item in bundle.get("missingReviewLanes", [])]]))
            continue
        missing_lanes = sorted(EXPECTED_REVIEW_LANES - set(lanes))
        if missing_lanes:
            blocked.append(_blocked_mutation(bundle, created_at, ["completed_review_packets_missing", *missing_lanes]))
            continue
        plan_issues = _completed_bundle_issues(bundle, lanes)
        if plan_issues:
            issues.extend(plan_issues)
            blocked.append(_blocked_mutation(bundle, created_at, ["completed_review_bundle_invalid", *plan_issues]))
            continue
        planned.append(_planned_mutation(bundle, lanes, created_at))
    return (
        sorted(planned, key=lambda item: (item["matchedDomainID"] or item["requestedDomain"], item["requestID"])),
        sorted(blocked, key=lambda item: (item["matchedDomainID"] or item["requestedDomain"], item["requestID"])),
        sorted(set(issues)),
    )


def _completed_bundle_issues(bundle: dict[str, Any], lanes: dict[str, dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    request_id = str(bundle.get("requestID") or "")
    direct_fields = _fields(lanes["direct_source_authority_resolution"])
    source_fields = _fields(lanes["source_lane_governance"])
    legal_fields = _fields(lanes["legal_terms_review"])
    api_fields = _fields(lanes["api_governance_review"])
    for label, fields, required in (
        (
            "source_lane_governance",
            source_fields,
            (
                "source_id",
                "source_class",
                "authority_class",
                "jurisdiction",
                "claim_classes_allowed",
                "claim_classes_forbidden",
                "redistribution_policy",
                "r2_pack_policy",
                "r2_object_key_prefix",
                "allowed_artifact_classes",
                "forbidden_artifact_classes",
                "review_status",
                "next_review_due_at",
                "rate_policy_id",
                "budget_policy_id",
                "secret_policy_id",
            ),
        ),
        (
            "legal_terms_review",
            legal_fields,
            (
                "license_id",
                "license_url",
                "terms_url",
                "rights_url",
                "redistribution_allowed",
                "attribution_required",
                "pack_output_allowed",
                "outside_legal_required",
                "outside_legal_status",
                "expires_at",
            ),
        ),
        (
            "api_governance_review",
            api_fields,
            (
                "api_policy_id",
                "api_mode",
                "key_required",
                "missing_key_behavior",
                "rate_limit_per_second",
                "rate_limit_per_minute",
                "daily_budget_limit",
                "monthly_budget_limit",
                "max_records_per_run",
                "max_pages_per_run",
                "timeout_seconds",
                "retry_policy",
                "backoff_policy",
                "circuit_breaker_policy",
                "live_flag_required",
                "execute_flag_required",
                "secret_redaction_required",
                "high_volume_review_required",
                "budget_owner",
            ),
        ),
    ):
        for field in required:
            if field not in fields or fields.get(field) in (None, "", [], {}):
                if isinstance(fields.get(field), bool):
                    continue
                issues.append(f"{request_id}: {label}.{field} required")
    if source_fields.get("source_class") == "public_catalog" or source_fields.get("authority_class") == "public_catalog":
        issues.append(f"{request_id}: completed source lane cannot remain public_catalog source-of-sources")
    if str(source_fields.get("r2_pack_policy") or "").startswith("pack_blocked"):
        issues.append(f"{request_id}: completed source lane cannot use blocked r2_pack_policy")
    if legal_fields.get("pack_output_allowed") is True and legal_fields.get("redistribution_allowed") is not True:
        issues.append(f"{request_id}: pack_output_allowed requires redistribution_allowed")
    if legal_fields.get("outside_legal_status") == "approved" and not legal_fields.get("approval_artifact_path"):
        issues.append(f"{request_id}: outside legal approval requires approval_artifact_path")
    if api_fields.get("live_flag_required") is not True or api_fields.get("execute_flag_required") is not True:
        issues.append(f"{request_id}: API policy must require live and execute flags")
    if api_fields.get("secret_redaction_required") is not True:
        issues.append(f"{request_id}: API policy must require secret redaction")
    if not direct_fields.get("publisher_identity"):
        issues.append(f"{request_id}: direct_source_authority_resolution.publisher_identity required")
    return sorted(set(issues))


def _planned_mutation(bundle: dict[str, Any], lanes: dict[str, dict[str, Any]], created_at: str) -> dict[str, Any]:
    direct = lanes["direct_source_authority_resolution"]
    source = lanes["source_lane_governance"]
    legal = lanes["legal_terms_review"]
    api = lanes["api_governance_review"]
    direct_fields = _fields(direct)
    source_fields = _fields(source)
    legal_fields = _fields(legal)
    api_fields = _fields(api)
    source_id = str(source_fields.get("source_id") or "")
    source_lane_entry = {
        "source_id": source_id,
        "source_name": str(direct_fields.get("publisher_identity") or source_id),
        "source_class": source_fields.get("source_class"),
        "authority_class": source_fields.get("authority_class"),
        "jurisdiction": source_fields.get("jurisdiction"),
        "domain_scope": [item for item in [bundle.get("matchedDomainID") or bundle.get("requestedDomain")] if item],
        "claim_classes_allowed": source_fields.get("claim_classes_allowed", []),
        "claim_classes_forbidden": source_fields.get("claim_classes_forbidden", []),
        "license_id": legal_fields.get("license_id"),
        "license_url": legal_fields.get("license_url"),
        "terms_url": legal_fields.get("terms_url"),
        "rights_url": legal_fields.get("rights_url"),
        "attribution_required": legal_fields.get("attribution_required"),
        "redistribution_policy": source_fields.get("redistribution_policy"),
        "r2_pack_policy": source_fields.get("r2_pack_policy"),
        "lookup_policy": "lookup_allowed_public_reference_only",
        "crosswalk_policy": "not_crosswalk_source",
        "review_status": source_fields.get("review_status"),
        "review_required": False,
        "review_owner": source.get("reviewOwner"),
        "last_reviewed_at": source.get("reviewedAt"),
        "next_review_due_at": source_fields.get("next_review_due_at"),
        "freshness_sla": "review_required_before_pack_output",
        "api_mode": api_fields.get("api_mode"),
        "api_policy_id": api_fields.get("api_policy_id"),
        "rate_policy_id": source_fields.get("rate_policy_id"),
        "budget_policy_id": source_fields.get("budget_policy_id"),
        "secret_policy_id": source_fields.get("secret_policy_id"),
        "allowed_artifact_classes": source_fields.get("allowed_artifact_classes", []),
        "forbidden_artifact_classes": source_fields.get("forbidden_artifact_classes", []),
        "non_claims": ["planned source-lane entry only", "not active registry mutation", "not legal approval"],
        "schema_version": "1.0.0",
        "r2_object_key_prefix": source_fields.get("r2_object_key_prefix"),
    }
    legal_terms_entry = {
        "license_id": legal_fields.get("license_id"),
        "license_name": str(legal_fields.get("license_id") or "planned public reference terms"),
        "license_url": legal_fields.get("license_url"),
        "terms_url": legal_fields.get("terms_url"),
        "rights_url": legal_fields.get("rights_url"),
        "redistribution_allowed": legal_fields.get("redistribution_allowed"),
        "modification_allowed": False,
        "commercial_use_allowed": False,
        "attribution_required": legal_fields.get("attribution_required"),
        "share_alike_required": False,
        "source_specific_restrictions": ["planned registry entry requires separate registry apply review"],
        "pack_output_allowed": legal_fields.get("pack_output_allowed"),
        "lookup_output_allowed": True,
        "review_required": False,
        "outside_legal_required": legal_fields.get("outside_legal_required"),
        "outside_legal_status": legal_fields.get("outside_legal_status"),
        "approval_artifact_path": legal_fields.get("approval_artifact_path", ""),
        "effective_date": legal.get("reviewedAt"),
        "reviewed_at": legal.get("reviewedAt"),
        "review_owner": legal.get("reviewOwner"),
        "expires_at": legal_fields.get("expires_at"),
        "non_claims": ["planned legal/terms entry only", "not legal approval by itself", "not outside legal approval without artifact"],
        "schema_version": "1.0.0",
    }
    api_policy_entry = {
        "api_policy_id": api_fields.get("api_policy_id"),
        "source_id": source_id,
        "api_mode": api_fields.get("api_mode"),
        "key_required": api_fields.get("key_required"),
        "env_var_name": api_fields.get("env_var_name", ""),
        "missing_key_behavior": api_fields.get("missing_key_behavior"),
        "rate_limit_per_second": api_fields.get("rate_limit_per_second"),
        "rate_limit_per_minute": api_fields.get("rate_limit_per_minute"),
        "daily_budget_limit": api_fields.get("daily_budget_limit"),
        "monthly_budget_limit": api_fields.get("monthly_budget_limit"),
        "max_records_per_run": api_fields.get("max_records_per_run"),
        "max_pages_per_run": api_fields.get("max_pages_per_run"),
        "timeout_seconds": api_fields.get("timeout_seconds"),
        "retry_policy": api_fields.get("retry_policy"),
        "backoff_policy": api_fields.get("backoff_policy"),
        "circuit_breaker_policy": api_fields.get("circuit_breaker_policy"),
        "live_flag_required": api_fields.get("live_flag_required"),
        "execute_flag_required": api_fields.get("execute_flag_required"),
        "secret_redaction_required": api_fields.get("secret_redaction_required"),
        "high_volume_review_required": api_fields.get("high_volume_review_required"),
        "budget_owner": api_fields.get("budget_owner"),
        "evidence_output_policy": "public_reference_metadata_only",
        "schema_version": "1.0.0",
    }
    return {
        "mutationID": stable_id("source_atlas_goal_domain_registry_mutation", {"bundleID": bundle.get("bundleID"), "sourceID": source_id}),
        "bundleID": bundle.get("bundleID"),
        "requestID": bundle.get("requestID"),
        "requestedDomain": bundle.get("requestedDomain"),
        "matchedDomainID": bundle.get("matchedDomainID"),
        "createdAt": created_at,
        "completionStatus": "completed_review_ready_for_registry_apply_planning",
        "status": "dry_run_ready_for_separate_registry_apply",
        "activeRegistryWritten": False,
        "sourceLaneEntry": source_lane_entry,
        "legalTermsEntry": legal_terms_entry,
        "apiPolicyEntry": api_policy_entry,
        "blockingReasons": ["planner_does_not_write_active_registries", "separate_registry_apply_required"],
        "claimOutputAllowed": False,
        "packOutputAllowed": False,
        "r2PublishAllowed": False,
        "nativeActivationAllowed": False,
        "publicReferenceOnly": True,
        "nonClaims": ["planned registry mutation only", "not active registry mutation", "not claim output", "not R2 publish"],
    }


def _blocked_mutation(bundle: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "blockedMutationID": stable_id("source_atlas_goal_domain_registry_mutation_block", {"bundleID": bundle.get("bundleID"), "reasons": sorted(reasons)}),
        "bundleID": str(bundle.get("bundleID") or ""),
        "requestID": str(bundle.get("requestID") or ""),
        "requestedDomain": str(bundle.get("requestedDomain") or ""),
        "matchedDomainID": bundle.get("matchedDomainID"),
        "createdAt": created_at,
        "status": "blocked",
        "activeRegistryWritten": False,
        "blockingReasons": sorted(set(reason for reason in reasons if reason)),
        "nonClaims": ["blocked registry mutation only", "not active registry mutation", "not source authority", "not claim output"],
    }


def _fields(packet: dict[str, Any]) -> dict[str, Any]:
    fields = packet.get("reviewFields")
    return fields if isinstance(fields, dict) else {}


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
                "nonClaims",
                "non_claims",
                "blockingReasons",
                "blocking_reasons",
            }
        )
    return False
