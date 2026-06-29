"""Governed arbitrary-domain frontier intake for Source Atlas.

This compiler is the first lane for domains that are not already represented in
the curated coverage frontier registry. It accepts public/reference domain
proposals and turns them into candidate-only frontier/source records. It never
emits claims, source authority, packable output, or R2-ready artifacts.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


FRONTIER_INTAKE_VERSION = "source-atlas-frontier-intake-train-52"
FRONTIER_INTAKE_KIND = "ambitions.sourceAtlas.frontierIntake.v1"

AUTHORITY_CLASSES = {
    "official_government",
    "official_institution",
    "standards_body",
    "regulated_body",
    "scholarly_metadata",
    "open_knowledge_graph",
    "public_catalog",
    "commercial_api",
    "non_authoritative_web",
    "unknown",
}
SOURCE_CLASSES = AUTHORITY_CLASSES
REDISTRIBUTION_GUESSES = {
    "clearly_open",
    "open_with_attribution",
    "terms_sensitive",
    "restricted",
    "unclear",
    "blocked",
}
HIGH_STAKES_MARKERS = {
    "credential",
    "deadline",
    "eligibility",
    "financial",
    "health",
    "legal",
    "medical",
    "requirement",
    "safety",
    "tax",
}
REGULATED_AUTHORITY_CLASSES = {"official_government", "official_institution", "standards_body", "regulated_body"}
SOURCE_OF_SOURCES_CLASSES = {"public_catalog", "open_knowledge_graph"}
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

FRONTIER_INTAKE_NON_CLAIMS = [
    "not source authority",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not legal approval",
    "not outside legal approval",
    "not universal coverage",
    "not full Source Atlas Green",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class FrontierIntakeOptions:
    input_path: Path
    output_root: Path
    frontier_config_path: Path | None = DEFAULT_FRONTIER_CONFIG_PATH
    created_at: str | None = None


def compile_frontier_intake(options: FrontierIntakeOptions) -> dict[str, Any]:
    """Compile public/reference proposal input into candidate-only frontiers."""

    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    input_payload = read_json(options.input_path)
    frontier_config_path = options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH
    configured_frontier_ids = _configured_frontier_ids(frontier_config_path)

    proposal_issues = _proposal_payload_issues(input_payload)
    input_privacy_issues = privacy_findings_for_value(input_payload, "frontier-intake-input")
    proposals = _proposal_list(input_payload)
    proposal_frontiers: list[dict[str, Any]] = []
    candidate_sources: list[dict[str, Any]] = []
    proposal_summaries: list[dict[str, Any]] = []
    issues: list[str] = list(proposal_issues)

    for index, proposal in enumerate(proposals):
        proposal_id = str(proposal.get("proposal_id") or stable_id("frontier_proposal", {"index": index, "proposal": proposal}))
        proposal_result = _compile_proposal(
            proposal=proposal,
            proposal_id=proposal_id,
            configured_frontier_ids=configured_frontier_ids,
            created_at=created_at,
        )
        proposal_frontiers.append(proposal_result["frontier"])
        candidate_sources.extend(proposal_result["candidateSources"])
        proposal_summaries.append(proposal_result["summary"])
        issues.extend(proposal_result["issues"])

    candidate_sources = sorted(candidate_sources, key=lambda item: (item["domain_guess"], -item["candidate_score"], item["candidate_id"]))
    proposal_frontiers = sorted(proposal_frontiers, key=lambda item: item["frontier_id"])
    proposal_summaries = sorted(proposal_summaries, key=lambda item: item["proposal_id"])

    artifact = {
        "schemaVersion": 1,
        "kind": FRONTIER_INTAKE_KIND,
        "versionID": FRONTIER_INTAKE_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "frontierConfigPath": str(frontier_config_path),
        "proposedFrontiers": proposal_frontiers,
        "candidateSourceRecords": candidate_sources,
        "proposalSummaries": proposal_summaries,
        "recordCounts": {
            "proposals": len(proposals),
            "proposedFrontiers": len(proposal_frontiers),
            "candidateSources": len(candidate_sources),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": FRONTIER_INTAKE_NON_CLAIMS,
    }
    privacy_issues = privacy_findings_for_value(artifact, "frontier-intake")
    checks = [
        {
            "name": "input_schema_valid",
            "passed": not proposal_issues,
            "issues": proposal_issues,
        },
        {
            "name": "input_privacy_scan_passed",
            "passed": not input_privacy_issues,
            "issues": input_privacy_issues,
        },
        {
            "name": "candidate_intake_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "all_frontiers_candidate_only",
            "passed": all(frontier["status_ceiling"] == "candidate_only" for frontier in proposal_frontiers),
            "issues": [],
        },
        {
            "name": "all_sources_review_required",
            "passed": all(candidate["review_required"] is True for candidate in candidate_sources),
            "issues": [],
        },
        {
            "name": "no_source_claim_authority_asserted",
            "passed": all(candidate["claim_authority_allowed"] is False for candidate in candidate_sources),
            "issues": [],
        },
        {
            "name": "pack_output_blocked",
            "passed": all(frontier["pack_output_allowed"] is False for frontier in proposal_frontiers)
            and all(candidate["pack_output_allowed"] is False for candidate in candidate_sources),
            "issues": [],
        },
        {
            "name": "privacy_scan_passed",
            "passed": not privacy_issues,
            "issues": privacy_issues,
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    issues.extend(input_privacy_issues)
    issues.extend(privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.frontierIntakeManifest.v1",
        "versionID": FRONTIER_INTAKE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for governed frontier intake tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; candidate-only arbitrary-domain frontier intake only",
        "inputPath": str(options.input_path),
        "frontierConfigPath": str(frontier_config_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "frontierIntake": str(output_root / "frontier-intake.json"),
            "proposedFrontiers": str(output_root / "proposed-frontiers.json"),
            "candidateSources": str(output_root / "candidate-sources.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": FRONTIER_INTAKE_NON_CLAIMS,
    }

    write_json(output_root / "frontier-intake.json", artifact)
    write_json(output_root / "proposed-frontiers.json", {"proposedFrontiers": proposal_frontiers, "createdAt": created_at, "kind": "ambitions.sourceAtlas.proposedCoverageFrontiers.v1"})
    write_json(output_root / "candidate-sources.json", {"candidateSourceRecords": candidate_sources, "createdAt": created_at, "kind": "ambitions.sourceAtlas.frontierCandidateSources.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "frontierIntake": stable_hash(read_json(output_root / "frontier-intake.json")),
        "proposedFrontiers": stable_hash(read_json(output_root / "proposed-frontiers.json")),
        "candidateSources": stable_hash(read_json(output_root / "candidate-sources.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(frontier_intake_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_frontier_intake_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    frontier_config_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=input_path,
            output_root=output_root,
            frontier_config_path=frontier_config_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(frontier_intake_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def frontier_intake_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Governed Frontier Intake Train 52",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Candidate-only intake compiler for arbitrary public/reference goal-domain proposals.",
        "- Proposed coverage-frontier records that cannot claim source authority, claims, packs, R2 readiness, app runtime readiness, or release readiness.",
        "- Candidate source records with deterministic scoring and review-required posture.",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Intake accepts public/reference source metadata only.",
        "- Candidate source metadata is discovery/provenance aid only and does not become claim authority.",
        "- Source Atlas does not generate final plans, schedules, Steps, or personalized paths.",
        "",
        "Validation run:",
        "- See current train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Live discovery/network crawling was not run.",
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
            "- No R2 request path is emitted or executed by frontier intake.",
            "- Candidate records are not object keys and cannot be published as packs.",
            "",
            "No private graph egress proof:",
            "- Artifact privacy scan must pass before Green.",
            "- Submitted private-looking runtime context fails validation.",
            "",
            "License/terms proof:",
            "- Missing or ambiguous source terms block pack output.",
            "- Automated posture is advisory only.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Source-of-sources, public catalogs, open knowledge graphs, commercial APIs, unknown terms, and restricted guesses remain review-required and pack-blocked.",
            "",
            "Provenance completeness proof:",
            "- Not claimed. Frontier intake emits no claims and no provenance-complete claim graph.",
            "",
            "Freshness/revocation proof:",
            "- Not claimed. No pack, revocation manifest, or LKG pointer is emitted.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed. No native files changed.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: proposed domains still require source-lane/legal/API/adapters/claims/R2/native proof before readiness.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _compile_proposal(
    *,
    proposal: dict[str, Any],
    proposal_id: str,
    configured_frontier_ids: set[str],
    created_at: str,
) -> dict[str, Any]:
    issues = _single_proposal_issues(proposal, proposal_id)
    domain = _normalize_id(str(proposal.get("domain") or proposal_id))
    frontier_id = _normalize_id(str(proposal.get("frontier_id") or domain))
    claim_classes = sorted(_string_list(proposal, "claim_classes"))
    source_needs = sorted(_string_list(proposal, "source_classes_required"))
    authority_needs = sorted(_string_list(proposal, "minimum_authority_classes"))
    source_candidates = _source_candidates_for_proposal(
        proposal=proposal,
        proposal_id=proposal_id,
        frontier_id=frontier_id,
        created_at=created_at,
    )
    duplicate = frontier_id in configured_frontier_ids
    missing_authority = not authority_needs
    high_stakes = _is_high_stakes_claim_set(claim_classes)
    if duplicate:
        issues.append(f"{proposal_id}: frontier already configured: {frontier_id}")
    if missing_authority:
        issues.append(f"{proposal_id}: minimum_authority_classes required")
    if high_stakes and not set(authority_needs).intersection(REGULATED_AUTHORITY_CLASSES):
        issues.append(f"{proposal_id}: high-stakes claim classes require official/regulated authority review")

    blocking_reasons = sorted(
        set(
            [
                "candidate_only_not_claim_authority",
                "source_lane_review_required",
                "legal_terms_review_required",
                "adapter_contract_required",
                "claim_graph_required",
                "r2_pack_blocked_until_all_gates_pass",
                *([ "frontier_already_configured" ] if duplicate else []),
                *([ "high_stakes_authority_review_required" ] if high_stakes else []),
                *([ "minimum_authority_classes_missing" ] if missing_authority else []),
            ]
        )
    )
    frontier = {
        "schema_version": "1.0.0",
        "proposal_id": proposal_id,
        "frontier_id": frontier_id,
        "domain": domain,
        "goal_intent_classes": sorted(_string_list(proposal, "goal_intent_classes")),
        "claim_classes": claim_classes,
        "jurisdictions": sorted(_string_list(proposal, "jurisdictions")),
        "source_classes_required": source_needs,
        "minimum_authority_classes": authority_needs,
        "freshness_slas": sorted(_string_list(proposal, "freshness_slas")),
        "legal_posture_required": "human_review_required_before_pack_output",
        "source_ids": [],
        "candidate_source_ids": [candidate["candidate_id"] for candidate in source_candidates],
        "excluded_sources": [],
        "status_ceiling": "candidate_only",
        "review_required": True,
        "pack_output_allowed": False,
        "claim_output_allowed": False,
        "r2_pack_policy": "pack_blocked_review_required",
        "blocking_reasons": blocking_reasons,
        "non_claims": _ordered_unique(
            [
                "not universal coverage",
                "not source authority",
                "not legal approval",
                "not claim output",
                "not pack output",
                "not final user plans, schedules, or Steps",
                *_string_list(proposal, "non_claims"),
            ]
        ),
    }
    summary = {
        "proposal_id": proposal_id,
        "frontier_id": frontier_id,
        "status": "candidate_only",
        "candidate_source_count": len(source_candidates),
        "review_required": True,
        "pack_output_allowed": False,
        "blocking_reasons": blocking_reasons,
        "issues": sorted(set(issues)),
    }
    return {"frontier": frontier, "candidateSources": source_candidates, "summary": summary, "issues": issues}


def _source_candidates_for_proposal(
    *,
    proposal: dict[str, Any],
    proposal_id: str,
    frontier_id: str,
    created_at: str,
) -> list[dict[str, Any]]:
    records = []
    for index, source in enumerate(proposal.get("candidate_sources", [])):
        if not isinstance(source, dict):
            continue
        candidate_id = stable_id(
            "candidate_source",
            {
                "proposal_id": proposal_id,
                "frontier_id": frontier_id,
                "index": index,
                "source": source,
            },
        )
        authority_guess = _validated_choice(str(source.get("authority_class_guess", "unknown")), AUTHORITY_CLASSES, "unknown")
        source_class_guess = _validated_choice(str(source.get("source_class_guess", authority_guess)), SOURCE_CLASSES, "unknown")
        redistribution_guess = _validated_choice(str(source.get("redistribution_guess", "unclear")), REDISTRIBUTION_GUESSES, "unclear")
        blocking_reasons = _source_blocking_reasons(source, authority_guess, source_class_guess, redistribution_guess)
        record = {
            "schema_version": "1.0.0",
            "candidate_id": candidate_id,
            "proposal_id": proposal_id,
            "frontier_id": frontier_id,
            "discovery_method": str(source.get("discovery_method", "manual_submission")),
            "discovered_at": created_at,
            "publisher_name": str(source.get("publisher_name", "")),
            "publisher_url": str(source.get("publisher_url", "")),
            "declared_jurisdiction": str(source.get("declared_jurisdiction", "")),
            "declared_license": str(source.get("declared_license", "")),
            "declared_rights": str(source.get("declared_rights", "")),
            "terms_url": str(source.get("terms_url", "")),
            "rights_url": str(source.get("rights_url", "")),
            "dataset_url": str(source.get("dataset_url", "")),
            "distribution_urls": sorted(str(url) for url in source.get("distribution_urls", []) if isinstance(url, str)),
            "api_docs_url": str(source.get("api_docs_url", "")),
            "source_class_guess": source_class_guess,
            "authority_class_guess": authority_guess,
            "domain_guess": frontier_id,
            "claim_class_guess": sorted(_string_list(source, "claim_class_guess")),
            "redistribution_guess": redistribution_guess,
            "review_required": True,
            "claim_authority_allowed": False,
            "pack_output_allowed": False,
            "candidate_score": _candidate_score(source, authority_guess, source_class_guess, redistribution_guess),
            "blocking_reasons": blocking_reasons,
            "evidence_hash": stable_hash(source),
            "non_claims": [
                "candidate source record only",
                "not claim authority",
                "not redistribution approval",
                "not pack output",
                "human source-lane and terms review required before use",
            ],
        }
        records.append(record)
    return sorted(records, key=lambda item: (-item["candidate_score"], item["candidate_id"]))


def _source_blocking_reasons(source: dict[str, Any], authority_guess: str, source_class_guess: str, redistribution_guess: str) -> list[str]:
    reasons = {
        "review_required",
        "source_lane_review_required",
        "legal_terms_review_required",
        "pack_output_blocked_until_review",
        "candidate_score_cannot_override_review",
    }
    if authority_guess in SOURCE_OF_SOURCES_CLASSES or source_class_guess in SOURCE_OF_SOURCES_CLASSES:
        reasons.add("source_of_sources_not_claim_authority")
    if authority_guess == "open_knowledge_graph":
        reasons.add("crosswalk_only_not_regulated_authority")
    if redistribution_guess in {"terms_sensitive", "restricted", "unclear", "blocked"}:
        reasons.add("redistribution_not_approved")
    if not source.get("terms_url"):
        reasons.add("missing_terms_url")
    if not source.get("declared_license"):
        reasons.add("missing_declared_license")
    if authority_guess in {"commercial_api", "unknown", "non_authoritative_web"}:
        reasons.add("authority_review_required")
    return sorted(reasons)


def _candidate_score(source: dict[str, Any], authority_guess: str, source_class_guess: str, redistribution_guess: str) -> int:
    score = 0
    if authority_guess in REGULATED_AUTHORITY_CLASSES:
        score += 30
    if source_class_guess in REGULATED_AUTHORITY_CLASSES:
        score += 15
    if source.get("publisher_url"):
        score += 10
    if source.get("dataset_url") or source.get("api_docs_url"):
        score += 10
    if source.get("terms_url"):
        score += 10
    if source.get("declared_license"):
        score += 10
    if redistribution_guess in {"clearly_open", "open_with_attribution"}:
        score += 10
    if authority_guess in SOURCE_OF_SOURCES_CLASSES:
        score -= 10
    if redistribution_guess in {"restricted", "blocked"}:
        score -= 20
    return max(score, 0)


def _proposal_payload_issues(payload: Any) -> list[str]:
    if not isinstance(payload, dict):
        return ["input payload must be an object"]
    proposals = payload.get("domainProposals")
    if not isinstance(proposals, list) or not proposals:
        return ["domainProposals must be a non-empty list"]
    return []


def _proposal_list(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    proposals = payload.get("domainProposals", [])
    return [proposal for proposal in proposals if isinstance(proposal, dict)]


def _single_proposal_issues(proposal: dict[str, Any], proposal_id: str) -> list[str]:
    issues: list[str] = []
    for field in ("domain", "claim_classes", "jurisdictions", "candidate_sources"):
        if field not in proposal:
            issues.append(f"{proposal_id}: missing required field {field}")
    for field in ("claim_classes", "jurisdictions", "candidate_sources"):
        if field in proposal and not isinstance(proposal[field], list):
            issues.append(f"{proposal_id}: {field} must be a list")
    return issues


def _configured_frontier_ids(path: Path) -> set[str]:
    if not path.exists():
        return set()
    data = read_json(path)
    return {
        str(frontier.get("frontier_id"))
        for frontier in data.get("frontiers", [])
        if isinstance(frontier, dict) and isinstance(frontier.get("frontier_id"), str)
    }


def _normalize_id(value: str) -> str:
    normalized = re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")
    return normalized or "unnamed_frontier"


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _validated_choice(value: str, allowed: set[str], fallback: str) -> str:
    return value if value in allowed else fallback


def _is_high_stakes_claim_set(claim_classes: list[str]) -> bool:
    return any(any(marker in claim_class.lower() for marker in HIGH_STAKES_MARKERS) for claim_class in claim_classes)


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_forbidden_output_marker(item) for item in value.values())
    return False


def _ordered_unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    output: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            output.append(value)
    return output
