"""Launch-floor domain taxonomy validation for Source Atlas.

The taxonomy is a public/reference routing universe. It is not a shard corpus,
not R2 production proof, not legal approval, and not a source of final plans,
schedules, or Steps. Accepted taxonomy domains may count toward the launch-floor
domain/subdomain universe only when every accepted record is explicitly
public/reference, mapped to source-lane coverage, and blocked from pack/R2/native
activation unless separate production evidence exists.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .boundary import boundary_issues_for_value, is_boundary_line
from .claim_frontier import SOURCE_ATLAS_ROOT
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_KIND = "ambitions.sourceAtlas.launchFloorDomainTaxonomy.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_REPORT_KIND = "ambitions.sourceAtlas.launchFloorDomainTaxonomyReport.v1"
SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_VERSION = "source-atlas-launch-floor-domain-taxonomy-lff-m01"
DEFAULT_LAUNCH_FLOOR_TAXONOMY_PATH = SOURCE_ATLAS_ROOT / "frontier" / "launch-floor-domain-taxonomy.json"

ACCEPTED_STATE = "accepted"
CANDIDATE_ONLY_STATE = "candidate_only"
BLOCKED_PRIVATE_STATE = "blocked_private"
UNLAWFUL_OUT_OF_SCOPE_STATE = "unlawful_out_of_scope"
CONFIGURED_READY = "configured_ready"
CONFIGURED_NOT_READY = "configured_not_ready"
SOURCE_LANE_REVIEW_REQUIRED = "source_lane_review_required"
PRODUCTION_READY_STATUS = "bounded_production_target_ready"
REQUIRED_STATE_DEFINITIONS = {
    ACCEPTED_STATE,
    CANDIDATE_ONLY_STATE,
    BLOCKED_PRIVATE_STATE,
    UNLAWFUL_OUT_OF_SCOPE_STATE,
    CONFIGURED_READY,
    CONFIGURED_NOT_READY,
}
FINAL_OUTPUT_FORBIDDEN = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}

LAUNCH_FLOOR_TAXONOMY_NON_CLAIMS = [
    "not a shard corpus",
    "not proof of 1M public/reference shards",
    "not proof of 50,000 golden intents",
    "not proof of <5% source-needed fallback",
    "not R2 production promotion proof",
    "not outside legal approval",
    "not Release Green, App Store readiness, or TestFlight readiness",
    "not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2",
    "accepted taxonomy records that are configured-not-ready are routeable coverage targets only",
    "candidate-only backlog records are not counted as launch-floor covered domains or subdomains",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class LaunchFloorDomainTaxonomyOptions:
    taxonomy_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    production_target_ledger_path: Path | None = None
    created_at: str = "2026-07-01T00:00:00Z"
    run_label: str = "current"
    emit_evidence_path: Path | None = None
    markdown_path: Path | None = None


def compile_launch_floor_domain_taxonomy(options: LaunchFloorDomainTaxonomyOptions) -> dict[str, Any]:
    """Validate the canonical launch-floor taxonomy and write audit evidence."""

    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    taxonomy = _read_required_json(options.taxonomy_path, "launch-floor domain taxonomy")
    source_lane_registry = _read_optional_json(options.source_lane_registry_path, "source lane registry")
    production_ledger = _read_optional_json(options.production_target_ledger_path, "production target ledger")

    summary = launch_floor_domain_taxonomy_summary(
        taxonomy,
        created_at=options.created_at,
        source_lane_registry=source_lane_registry,
        production_target_ledger=production_ledger,
    )
    input_privacy_issues = _privacy_issues(
        {
            "taxonomyPath": str(options.taxonomy_path),
            "sourceLaneRegistryPath": str(options.source_lane_registry_path) if options.source_lane_registry_path else None,
            "productionTargetLedgerPath": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
            "runLabel": options.run_label,
        },
        "source-atlas-launch-floor-taxonomy-input",
    )
    artifact_privacy_issues = _privacy_issues(taxonomy, "source-atlas-launch-floor-taxonomy-source")
    issues = sorted(set([*summary["issues"], *input_privacy_issues, *artifact_privacy_issues]))

    expanded_domain_index_path = output_root / "expanded-domain-index.json"
    candidate_backlog_path = output_root / "candidate-review-backlog.json"
    report_path = output_root / "launch-floor-domain-taxonomy-report.json"
    markdown_path = output_root / "launch-floor-domain-taxonomy-report.md"
    closeout_path = output_root / "closeout.md"
    expanded_index = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorExpandedDomainIndex.v1",
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_VERSION,
        "createdAt": options.created_at,
        "taxonomyPath": str(options.taxonomy_path),
        "domains": summary["domains"],
        "subdomains": summary["subdomains"],
        "nonClaims": LAUNCH_FLOOR_TAXONOMY_NON_CLAIMS,
    }
    candidate_backlog = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.launchFloorCandidateReviewBacklog.v1",
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_VERSION,
        "createdAt": options.created_at,
        "taxonomyPath": str(options.taxonomy_path),
        "candidateOnlyBacklog": summary["candidateOnlyBacklog"],
        "sourceLaneReviewBacklog": summary["sourceLaneReviewBacklog"],
        "nonClaims": [
            "candidate-only backlog records are not counted as launch-floor covered domains or subdomains",
            "review backlog records cannot emit claims, packs, R2 writes, native activation, final plans, schedules, or Steps",
        ],
    }
    write_json(expanded_domain_index_path, expanded_index)
    write_json(candidate_backlog_path, candidate_backlog)

    valid = not issues and summary["launchFloorTargets"]["goalDomains500"] and summary["launchFloorTargets"]["subdomains5000"]
    report = {
        "schemaVersion": 1,
        "kind": SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_REPORT_KIND,
        "versionID": SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "taxonomyReportID": stable_id(
            "source_atlas.launch_floor_domain_taxonomy",
            {
                "taxonomyHash": stable_hash(taxonomy),
                "recordCounts": summary["recordCounts"],
                "createdAt": options.created_at,
                "runLabel": options.run_label,
            },
        ),
        "status": "Source Green for launch-floor taxonomy tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": (
            "Yellow overall Source Atlas; taxonomy coverage is routeable public/reference universe, not shard/R2/release proof"
        ),
        "overallReadinessStatus": "taxonomy_launch_floor_met" if valid else "taxonomy_launch_floor_blocked",
        "launchFloorTargetStatus": summary["launchFloorTargets"],
        "recordCounts": summary["recordCounts"],
        "checks": _checks(summary, input_privacy_issues, artifact_privacy_issues),
        "issues": issues,
        "allowedClaims": _allowed_claims(valid),
        "blockedClaims": _blocked_claims(),
        "productLaw": {
            "publicReferenceOnly": True,
            "privateContextAllowed": False,
            "finalPersonalizedOutputsAllowed": False,
            "r2PublishAllowedByTaxonomy": False,
            "sourceAtlasGeneratesFinalPlansSchedulesSteps": False,
            "candidateOnlyBacklogCountsAsLaunchFloorCovered": False,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": sorted(set([*input_privacy_issues, *artifact_privacy_issues])),
        "nonClaims": LAUNCH_FLOOR_TAXONOMY_NON_CLAIMS,
        "evidencePaths": {
            "taxonomy": str(options.taxonomy_path),
            "sourceLaneRegistry": str(options.source_lane_registry_path) if options.source_lane_registry_path else None,
            "productionTargetLedger": str(options.production_target_ledger_path) if options.production_target_ledger_path else None,
        },
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
            "expandedDomainIndex": str(expanded_domain_index_path),
            "candidateReviewBacklog": str(candidate_backlog_path),
            "emitEvidence": str(options.emit_evidence_path) if options.emit_evidence_path else None,
            "emitMarkdown": str(options.markdown_path) if options.markdown_path else None,
        },
    }
    report["outputHashes"] = {
        "expandedDomainIndex": stable_hash(read_json(expanded_domain_index_path)),
        "candidateReviewBacklog": stable_hash(read_json(candidate_backlog_path)),
        "reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"}),
    }
    markdown = launch_floor_domain_taxonomy_markdown(report)
    report["outputHashes"]["markdownPayload"] = stable_hash(markdown)
    write_json(report_path, report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    if options.markdown_path:
        options.markdown_path.parent.mkdir(parents=True, exist_ok=True)
        options.markdown_path.write_text(markdown, encoding="utf-8")
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    if options.emit_evidence_path:
        write_json(options.emit_evidence_path, report)
    return report


def launch_floor_domain_taxonomy_summary(
    taxonomy: Any,
    *,
    created_at: str = "2026-07-01T00:00:00Z",
    source_lane_registry: Any = None,
    production_target_ledger: Any = None,
) -> dict[str, Any]:
    """Return expanded counts and fail-closed validation issues for taxonomy data."""

    issues: list[str] = []
    if not isinstance(taxonomy, dict):
        return _empty_summary(["launch-floor domain taxonomy must be a JSON object"])
    if taxonomy.get("kind") != SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_KIND:
        issues.append(f"taxonomy kind must be {SOURCE_ATLAS_LAUNCH_FLOOR_TAXONOMY_KIND}")

    state_definitions = {
        str(item.get("stateID"))
        for item in taxonomy.get("stateDefinitions", [])
        if isinstance(item, dict) and item.get("stateID")
    }
    missing_state_definitions = sorted(REQUIRED_STATE_DEFINITIONS - state_definitions)
    if missing_state_definitions:
        issues.append(f"taxonomy missing state definitions: {', '.join(missing_state_definitions)}")

    source_lane_profiles = _source_lane_profiles(taxonomy)
    if not source_lane_profiles:
        issues.append("taxonomy must define sourceLaneProfiles")
    known_source_lane_ids = _source_lane_ids(source_lane_registry)
    if not known_source_lane_ids:
        issues.append("source lane registry is required to verify taxonomy source-lane profiles")
    issues.extend(_source_lane_profile_mapping_issues(source_lane_profiles, known_source_lane_ids))
    production_ready_domains = _production_ready_domains(production_target_ledger)
    domains = _expanded_domains(taxonomy)
    subdomains = _expanded_subdomains(taxonomy, domains)
    candidate_backlog = _candidate_backlog(taxonomy)
    source_lane_review_backlog = _source_lane_review_backlog(domains, subdomains)

    domain_ids = [domain["domainID"] for domain in domains]
    subdomain_ids = [subdomain["subdomainID"] for subdomain in subdomains]
    _extend_duplicate_issues(issues, domain_ids, "domainID")
    _extend_duplicate_issues(issues, subdomain_ids, "subdomainID")
    for domain in domains:
        issues.extend(_domain_issues(domain, source_lane_profiles, known_source_lane_ids, production_ready_domains))
    for subdomain in subdomains:
        issues.extend(_subdomain_issues(subdomain, source_lane_profiles))
    candidate_issues, stale_candidate_count = _candidate_backlog_issues(candidate_backlog, created_at)
    issues.extend(candidate_issues)
    issues.extend(_final_output_issues(taxonomy))

    accepted_domains = [domain for domain in domains if domain["launchFloorState"] == ACCEPTED_STATE]
    accepted_subdomains = [subdomain for subdomain in subdomains if subdomain["launchFloorState"] == ACCEPTED_STATE]
    configured_ready_domains = [domain for domain in accepted_domains if domain["readinessState"] == CONFIGURED_READY]
    configured_not_ready_domains = [domain for domain in accepted_domains if domain["readinessState"] == CONFIGURED_NOT_READY]
    source_lane_covered_domains = [
        domain
        for domain in accepted_domains
        if domain.get("sourceLaneCoverageState") in {CONFIGURED_READY, SOURCE_LANE_REVIEW_REQUIRED}
        and domain.get("sourceLaneProfileIDs")
    ]
    source_lane_covered_subdomains = [
        subdomain
        for subdomain in accepted_subdomains
        if subdomain.get("sourceLaneCoverageState") in {CONFIGURED_READY, SOURCE_LANE_REVIEW_REQUIRED}
        and subdomain.get("sourceLaneProfileIDs")
    ]
    record_counts = {
        "domainFamilies": len(taxonomy.get("domainFamilies", [])) if isinstance(taxonomy.get("domainFamilies"), list) else 0,
        "sourceLaneProfiles": len(source_lane_profiles),
        "sourceLaneProfilesMappedToRegistry": sum(
            1 for profile in source_lane_profiles.values() if _profile_registry_ids(profile)
        ),
        "sourceLaneRegistryLinks": sum(len(_profile_registry_ids(profile)) for profile in source_lane_profiles.values()),
        "acceptedGoalDomains": len(accepted_domains),
        "acceptedSubdomains": len(accepted_subdomains),
        "configuredReadyDomains": len(configured_ready_domains),
        "configuredNotReadyDomains": len(configured_not_ready_domains),
        "candidateOnlyBacklogItems": len(candidate_backlog),
        "staleCandidateOnlyBacklogItems": stale_candidate_count,
        "sourceLaneReviewBacklogItems": len(source_lane_review_backlog),
        "domainsWithSourceLaneCoverage": len(source_lane_covered_domains),
        "subdomainsWithSourceLaneCoverage": len(source_lane_covered_subdomains),
        "productionReadyDomainsBackedByLedger": sum(1 for domain in configured_ready_domains if domain["domainID"] in production_ready_domains),
        "referencedSourceLaneRegistryIDs": len(known_source_lane_ids),
        "claims": 0,
        "packableClaims": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    launch_targets = {
        "goalDomains500": record_counts["acceptedGoalDomains"] >= 500,
        "subdomains5000": record_counts["acceptedSubdomains"] >= 5_000,
        "candidateOnlyBacklogExcludedFromCounts": True,
        "sourceLaneCoverageComplete": (
            record_counts["domainsWithSourceLaneCoverage"] == record_counts["acceptedGoalDomains"]
            and record_counts["subdomainsWithSourceLaneCoverage"] == record_counts["acceptedSubdomains"]
        ),
    }
    if not launch_targets["goalDomains500"]:
        issues.append("accepted goal-domain count is below 500")
    if not launch_targets["subdomains5000"]:
        issues.append("accepted subdomain count is below 5,000")
    if not launch_targets["sourceLaneCoverageComplete"]:
        issues.append("not every accepted domain and subdomain has source-lane coverage")
    return {
        "recordCounts": record_counts,
        "launchFloorTargets": launch_targets,
        "domains": domains,
        "subdomains": subdomains,
        "candidateOnlyBacklog": candidate_backlog,
        "sourceLaneReviewBacklog": source_lane_review_backlog,
        "sourceLaneProfiles": source_lane_profiles,
        "issues": sorted(set(issues)),
    }


def launch_floor_taxonomy_domain_index(taxonomy: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(taxonomy, dict):
        return {}
    return {domain["domainID"]: domain for domain in _expanded_domains(taxonomy)}


def launch_floor_domain_taxonomy_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Launch-Floor Domain Taxonomy LFF-M01",
        "",
        f"Status: {report['status']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Source Atlas status ceiling: {report['sourceAtlasStatusCeiling']}",
        "",
        "## Current Proved Capability",
        "",
        f"- Accepted public/reference domains: {counts['acceptedGoalDomains']}",
        f"- Accepted public/reference subdomains: {counts['acceptedSubdomains']}",
        f"- Configured-ready domains backed by production ledger: {counts['productionReadyDomainsBackedByLedger']}",
        f"- Configured-not-ready accepted domains: {counts['configuredNotReadyDomains']}",
        f"- Source-lane coverage profiles: {counts['sourceLaneProfiles']}",
        f"- Source-lane profiles mapped to governance registry: {counts['sourceLaneProfilesMappedToRegistry']}",
        f"- Source-lane governance registry links: {counts['sourceLaneRegistryLinks']}",
        f"- Source-lane review backlog items: {counts['sourceLaneReviewBacklogItems']}",
        f"- Candidate-only backlog items: {counts['candidateOnlyBacklogItems']}",
        f"- Stale candidate-only backlog items: {counts['staleCandidateOnlyBacklogItems']}",
        "",
        "## Launch-Floor Taxonomy Targets",
        "",
        f"- 500+ accepted public/reference domains: {'met' if report['launchFloorTargetStatus']['goalDomains500'] else 'not met'}",
        f"- 5,000+ accepted public/reference subdomains: {'met' if report['launchFloorTargetStatus']['subdomains5000'] else 'not met'}",
        f"- Source-lane coverage on every accepted domain/subdomain: {'met' if report['launchFloorTargetStatus']['sourceLaneCoverageComplete'] else 'not met'}",
        f"- Candidate-only backlog excluded from launch-floor counts: {'met' if report['launchFloorTargetStatus']['candidateOnlyBacklogExcludedFromCounts'] else 'not met'}",
        "",
        "## Checks",
        "",
    ]
    for check in report["checks"]:
        lines.append(f"- `{check['name']}`: {'pass' if check['passed'] else 'fail'}")
        for issue in check.get("issues", []):
            lines.append(f"  - {issue}")
    lines.extend(["", "## Allowed Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["allowedClaims"]) if report["allowedClaims"] else lines.append("- None")
    lines.extend(["", "## Blocked Claims", ""])
    lines.extend(f"- `{claim}`" for claim in report["blockedClaims"])
    lines.extend(
        [
            "",
            "## Product Law Preserved",
            "",
            "- Source Atlas/R2 remain public/reference/freshness infrastructure only.",
            "- Taxonomy records are public/reference route targets, not private user intent records.",
            "- Configured-not-ready taxonomy records emit review backlog, not claims, packs, R2 writes, or native activation.",
            "- Candidate-only backlog records are not counted as launch-floor covered domains or subdomains.",
            "- Source Atlas does not generate final personalized plans, schedules, or Steps.",
            "",
            "## Non-Claims",
            "",
        ]
    )
    lines.extend(f"- {claim}" for claim in report["nonClaims"])
    lines.extend(
        [
            "",
            "## Closeout",
            "",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: Source Atlas Foundry tooling, Source Atlas frontier taxonomy, and Source Atlas QA evidence only.",
            "- App behavior mutated: no.",
            "- Compatibility shims left behind: none.",
            "- Placeholder proof introduced: none.",
            "",
        ]
    )
    return "\n".join(lines)


def _expanded_domains(taxonomy: dict[str, Any]) -> list[dict[str, Any]]:
    domains: list[dict[str, Any]] = []
    for family in taxonomy.get("domainFamilies", []):
        if not isinstance(family, dict):
            continue
        family_id = str(family.get("familyID") or "unnamed_family")
        for record in family.get("domainRecords", []):
            if not isinstance(record, dict):
                continue
            domain_id = str(record.get("domainID") or "").strip()
            if not domain_id:
                continue
            source_lane_coverage = record.get("sourceLaneCoverage") if isinstance(record.get("sourceLaneCoverage"), dict) else {}
            domains.append(
                {
                    "domainID": domain_id,
                    "label": str(record.get("label") or domain_id),
                    "familyID": family_id,
                    "familyLabel": str(family.get("label") or family_id),
                    "launchFloorState": str(record.get("launchFloorState") or ACCEPTED_STATE),
                    "readinessState": str(record.get("readinessState") or CONFIGURED_NOT_READY),
                    "publicReferenceOnly": record.get("publicReferenceOnly") is True,
                    "privateContextAllowed": record.get("privateContextAllowed") is True,
                    "finalOutputAllowed": record.get("finalOutputAllowed") is True,
                    "packOutputAllowed": record.get("packOutputAllowed") is True,
                    "r2PublishAllowed": record.get("r2PublishAllowed") is True,
                    "nativeActivationAllowed": record.get("nativeActivationAllowed") is True,
                    "productionTargetDomainID": record.get("productionTargetDomainID"),
                    "sourceLaneCoverageState": str(source_lane_coverage.get("state") or SOURCE_LANE_REVIEW_REQUIRED),
                    "sourceLaneProfileIDs": _string_list(source_lane_coverage, "profileIDs"),
                    "claimClasses": _string_list(record, "claimClasses"),
                    "intentClasses": _string_list(record, "intentClasses"),
                    "jurisdictions": _string_list(record, "jurisdictions"),
                    "freshnessSLA": str(record.get("freshnessSLA") or family.get("freshnessSLA") or "review_required"),
                    "reviewSLA": str(record.get("reviewSLA") or "30d"),
                }
            )
    return sorted(domains, key=lambda item: item["domainID"])


def _expanded_subdomains(taxonomy: dict[str, Any], domains: list[dict[str, Any]]) -> list[dict[str, Any]]:
    global_archetypes = _subdomain_archetypes(taxonomy.get("subdomainArchetypes", []))
    by_family = {
        str(family.get("familyID")): _subdomain_archetypes(family.get("subdomainArchetypes", []))
        for family in taxonomy.get("domainFamilies", [])
        if isinstance(family, dict)
    }
    subdomains: list[dict[str, Any]] = []
    for domain in domains:
        archetypes = by_family.get(domain["familyID"]) or global_archetypes
        for archetype in archetypes:
            subdomain_id = f"{domain['domainID']}__{archetype['subdomainID']}"
            subdomains.append(
                {
                    "subdomainID": subdomain_id,
                    "parentDomainID": domain["domainID"],
                    "familyID": domain["familyID"],
                    "label": f"{domain['label']} - {archetype['label']}",
                    "subdomainArchetypeID": archetype["subdomainID"],
                    "launchFloorState": domain["launchFloorState"],
                    "readinessState": domain["readinessState"],
                    "publicReferenceOnly": domain["publicReferenceOnly"],
                    "privateContextAllowed": domain["privateContextAllowed"],
                    "finalOutputAllowed": domain["finalOutputAllowed"],
                    "packOutputAllowed": domain["packOutputAllowed"],
                    "r2PublishAllowed": domain["r2PublishAllowed"],
                    "nativeActivationAllowed": domain["nativeActivationAllowed"],
                    "sourceLaneCoverageState": domain["sourceLaneCoverageState"],
                    "sourceLaneProfileIDs": list(domain["sourceLaneProfileIDs"]),
                    "freshnessSLA": domain["freshnessSLA"],
                    "reviewSLA": domain["reviewSLA"],
                }
            )
    return sorted(subdomains, key=lambda item: item["subdomainID"])


def _subdomain_archetypes(value: Any) -> list[dict[str, str]]:
    if not isinstance(value, list):
        return []
    archetypes = []
    for item in value:
        if not isinstance(item, dict):
            continue
        subdomain_id = str(item.get("subdomainID") or "").strip()
        if subdomain_id:
            archetypes.append({"subdomainID": subdomain_id, "label": str(item.get("label") or subdomain_id)})
    return archetypes


def _source_lane_profiles(taxonomy: dict[str, Any]) -> dict[str, dict[str, Any]]:
    profiles = {}
    for profile in taxonomy.get("sourceLaneProfiles", []):
        if isinstance(profile, dict) and profile.get("profileID"):
            profiles[str(profile["profileID"])] = profile
    return profiles


def _source_lane_ids(source_lane_registry: Any) -> set[str]:
    if not isinstance(source_lane_registry, dict):
        return set()
    lanes = source_lane_registry.get("source_lanes", [])
    return {str(lane.get("source_id")) for lane in lanes if isinstance(lane, dict) and lane.get("source_id")}


def _source_lane_profile_mapping_issues(
    source_lane_profiles: dict[str, dict[str, Any]],
    known_source_lane_ids: set[str],
) -> list[str]:
    issues = []
    for profile_id, profile in sorted(source_lane_profiles.items()):
        registry_ids = _profile_registry_ids(profile)
        if not registry_ids:
            issues.append(f"{profile_id}: sourceLaneProfile must list sourceLaneRegistryIDs")
            continue
        for registry_id in registry_ids:
            if registry_id not in known_source_lane_ids:
                issues.append(f"{profile_id}: unknown sourceLaneRegistryID {registry_id}")
    return issues


def _profile_registry_ids(profile: dict[str, Any]) -> list[str]:
    return _string_list(profile, "sourceLaneRegistryIDs")


def _production_ready_domains(production_target_ledger: Any) -> set[str]:
    if not isinstance(production_target_ledger, dict):
        return set()
    domains = production_target_ledger.get("domains", [])
    return {
        str(domain.get("domainID"))
        for domain in domains
        if isinstance(domain, dict) and domain.get("readinessStatus") == PRODUCTION_READY_STATUS
    }


def _candidate_backlog(taxonomy: dict[str, Any]) -> list[dict[str, Any]]:
    items = taxonomy.get("candidateOnlyBacklog", [])
    if not isinstance(items, list):
        return []
    return sorted([item for item in items if isinstance(item, dict)], key=lambda item: str(item.get("candidateID", "")))


def _source_lane_review_backlog(domains: list[dict[str, Any]], subdomains: list[dict[str, Any]]) -> list[dict[str, Any]]:
    backlog = []
    for domain in domains:
        if domain["launchFloorState"] == ACCEPTED_STATE and domain["readinessState"] == CONFIGURED_NOT_READY:
            backlog.append(
                {
                    "workItemID": f"source-lane-review.{domain['domainID']}",
                    "domainID": domain["domainID"],
                    "state": SOURCE_LANE_REVIEW_REQUIRED,
                    "reviewSLA": domain["reviewSLA"],
                    "countsTowardLaunchFloorCovered": False,
                    "emitsClaims": False,
                    "emitsPack": False,
                    "r2PublishAllowed": False,
                    "nativeActivationAllowed": False,
                }
            )
    return sorted(backlog, key=lambda item: item["workItemID"])


def _domain_issues(
    domain: dict[str, Any],
    source_lane_profiles: dict[str, dict[str, Any]],
    known_source_lane_ids: set[str],
    production_ready_domains: set[str],
) -> list[str]:
    issues = []
    label = domain["domainID"]
    if domain["launchFloorState"] != ACCEPTED_STATE:
        return issues
    if not domain["publicReferenceOnly"]:
        issues.append(f"{label}: accepted domain must be publicReferenceOnly")
    if domain["privateContextAllowed"]:
        issues.append(f"{label}: accepted domain must not allow local-only context in taxonomy")
    if domain["finalOutputAllowed"]:
        issues.append(f"{label}: accepted domain must not allow final outputs")
    if domain["readinessState"] not in {CONFIGURED_READY, CONFIGURED_NOT_READY}:
        issues.append(f"{label}: accepted domain readinessState must be configured_ready or configured_not_ready")
    if domain["readinessState"] == CONFIGURED_READY and domain["domainID"] not in production_ready_domains:
        issues.append(f"{label}: configured_ready domain must be backed by production target ledger")
    if domain["readinessState"] == CONFIGURED_NOT_READY and (
        domain["packOutputAllowed"] or domain["r2PublishAllowed"] or domain["nativeActivationAllowed"]
    ):
        issues.append(f"{label}: configured_not_ready domain cannot emit packs, R2 writes, or native activation")
    if not domain["sourceLaneProfileIDs"]:
        issues.append(f"{label}: accepted domain must list sourceLaneCoverage.profileIDs")
    for profile_id in domain["sourceLaneProfileIDs"]:
        if profile_id not in source_lane_profiles:
            issues.append(f"{label}: unknown source lane profile {profile_id}")
    if domain["readinessState"] == CONFIGURED_READY and domain["productionTargetDomainID"] not in production_ready_domains:
        issues.append(f"{label}: productionTargetDomainID must point to a ready production target")
    if domain["sourceLaneCoverageState"] not in {CONFIGURED_READY, SOURCE_LANE_REVIEW_REQUIRED}:
        issues.append(f"{label}: invalid sourceLaneCoverage.state {domain['sourceLaneCoverageState']}")
    return issues


def _subdomain_issues(subdomain: dict[str, Any], source_lane_profiles: dict[str, dict[str, Any]]) -> list[str]:
    issues = []
    label = subdomain["subdomainID"]
    if subdomain["launchFloorState"] != ACCEPTED_STATE:
        return issues
    if not subdomain["publicReferenceOnly"]:
        issues.append(f"{label}: accepted subdomain must be publicReferenceOnly")
    if subdomain["privateContextAllowed"] or subdomain["finalOutputAllowed"]:
        issues.append(f"{label}: accepted subdomain must not allow local-only context or final outputs")
    if subdomain["readinessState"] == CONFIGURED_NOT_READY and (
        subdomain["packOutputAllowed"] or subdomain["r2PublishAllowed"] or subdomain["nativeActivationAllowed"]
    ):
        issues.append(f"{label}: configured_not_ready subdomain cannot emit packs, R2 writes, or native activation")
    if not subdomain["sourceLaneProfileIDs"]:
        issues.append(f"{label}: accepted subdomain must list sourceLaneProfileIDs")
    for profile_id in subdomain["sourceLaneProfileIDs"]:
        if profile_id not in source_lane_profiles:
            issues.append(f"{label}: unknown source lane profile {profile_id}")
    return issues


def _candidate_backlog_issues(backlog: list[dict[str, Any]], created_at: str) -> tuple[list[str], int]:
    issues = []
    stale_count = 0
    now = _parse_date(created_at)
    for index, item in enumerate(backlog):
        item_id = str(item.get("candidateID") or f"candidateOnlyBacklog[{index}]")
        if item.get("countsTowardLaunchFloorCovered") is True:
            issues.append(f"{item_id}: candidate-only backlog item cannot count toward launch-floor coverage")
        if item.get("packOutputAllowed") is True or item.get("r2PublishAllowed") is True or item.get("nativeActivationAllowed") is True:
            issues.append(f"{item_id}: candidate-only backlog cannot emit packs, R2 writes, or native activation")
        due_at = str(item.get("reviewDueAt") or "")
        if not due_at:
            issues.append(f"{item_id}: candidate-only backlog item must include reviewDueAt")
            continue
        due = _parse_date(due_at)
        if due and now and due < now:
            stale_count += 1
            issues.append(f"{item_id}: candidate-only backlog reviewDueAt is stale")
    return issues, stale_count


def _final_output_issues(value: Any) -> list[str]:
    found: set[str] = set()

    def walk(item: Any) -> None:
        if isinstance(item, str) and item in FINAL_OUTPUT_FORBIDDEN:
            found.add(item)
        elif isinstance(item, list):
            for child in item:
                walk(child)
        elif isinstance(item, dict):
            for child in item.values():
                walk(child)

    walk(value)
    return [f"taxonomy contains forbidden final-output marker: {item}" for item in sorted(found)]


def _extend_duplicate_issues(issues: list[str], values: list[str], label: str) -> None:
    seen: set[str] = set()
    duplicates: set[str] = set()
    for value in values:
        if value in seen:
            duplicates.add(value)
        seen.add(value)
    for duplicate in sorted(duplicates):
        issues.append(f"duplicate {label}: {duplicate}")


def _checks(summary: dict[str, Any], input_privacy_issues: list[str], artifact_privacy_issues: list[str]) -> list[dict[str, Any]]:
    counts = summary["recordCounts"]
    return [
        _check("input_privacy_scan_passed", not input_privacy_issues, input_privacy_issues),
        _check("taxonomy_privacy_scan_passed", not artifact_privacy_issues, artifact_privacy_issues),
        _check("accepted_goal_domains_at_least_500", counts["acceptedGoalDomains"] >= 500, [f"acceptedGoalDomains={counts['acceptedGoalDomains']}"]),
        _check("accepted_subdomains_at_least_5000", counts["acceptedSubdomains"] >= 5_000, [f"acceptedSubdomains={counts['acceptedSubdomains']}"]),
        _check(
            "source_lane_coverage_complete",
            summary["launchFloorTargets"]["sourceLaneCoverageComplete"],
            [
                f"domainsWithSourceLaneCoverage={counts['domainsWithSourceLaneCoverage']}",
                f"subdomainsWithSourceLaneCoverage={counts['subdomainsWithSourceLaneCoverage']}",
            ],
        ),
        _check("configured_ready_domains_backed_by_ledger", counts["configuredReadyDomains"] == counts["productionReadyDomainsBackedByLedger"], []),
        _check("candidate_only_backlog_excluded_from_counts", summary["launchFloorTargets"]["candidateOnlyBacklogExcludedFromCounts"], []),
        _check("candidate_backlog_not_stale", counts["staleCandidateOnlyBacklogItems"] == 0, [f"staleCandidateOnlyBacklogItems={counts['staleCandidateOnlyBacklogItems']}"]),
        _check("taxonomy_emits_no_claims_packs_r2_or_native_activation", counts["claims"] == 0 and counts["packableClaims"] == 0 and counts["r2PublishOperations"] == 0 and counts["nativeActivationOperations"] == 0, []),
        _check("taxonomy_emits_no_final_outputs", counts["finalOutputArtifacts"] == 0, []),
    ]


def _check(name: str, passed: bool, issues: list[str]) -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": [] if passed else issues}


def _allowed_claims(valid: bool) -> list[str]:
    if not valid:
        return []
    return [
        "source_atlas_launch_floor_taxonomy_tooling_green",
        "launch_floor_goal_domain_taxonomy_500_met",
        "launch_floor_subdomain_taxonomy_5000_met",
        "candidate_only_backlog_excluded_from_launch_floor_counts",
    ]


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "source_atlas_launch_floor_ready",
            "launch_floor_complete",
            "literal_universal_coverage",
            "public_reference_shards_1m",
            "golden_intents_50000",
            "source_needed_fallback_under_5_percent",
            "continuous_missing_shard_expansion",
            "r2_production_ready",
            "release_green",
            "app_store_readiness",
            "testflight_readiness",
            "outside_legal_approval",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _privacy_issues(value: Any, label: str) -> list[str]:
    return [
        issue.format()
        for issue in boundary_issues_for_value(value, label)
        if not is_boundary_line(issue.detail)
    ]


def _read_required_json(path: Path, label: str) -> Any:
    if not path.exists():
        return {"kind": "missing", "issues": [f"{label} missing at {path}"]}
    return read_json(path)


def _read_optional_json(path: Path | None, label: str) -> Any:
    if path is None:
        return None
    if not path.exists():
        return {"kind": "missing", "issues": [f"{label} missing at {path}"]}
    return read_json(path)


def _parse_date(value: str) -> datetime | None:
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _empty_summary(issues: list[str]) -> dict[str, Any]:
    return {
        "recordCounts": {
            "domainFamilies": 0,
            "sourceLaneProfiles": 0,
            "sourceLaneProfilesMappedToRegistry": 0,
            "sourceLaneRegistryLinks": 0,
            "acceptedGoalDomains": 0,
            "acceptedSubdomains": 0,
            "configuredReadyDomains": 0,
            "configuredNotReadyDomains": 0,
            "candidateOnlyBacklogItems": 0,
            "staleCandidateOnlyBacklogItems": 0,
            "sourceLaneReviewBacklogItems": 0,
            "domainsWithSourceLaneCoverage": 0,
            "subdomainsWithSourceLaneCoverage": 0,
            "productionReadyDomainsBackedByLedger": 0,
            "referencedSourceLaneRegistryIDs": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PublishOperations": 0,
            "nativeActivationOperations": 0,
            "finalOutputArtifacts": 0,
        },
        "launchFloorTargets": {
            "goalDomains500": False,
            "subdomains5000": False,
            "candidateOnlyBacklogExcludedFromCounts": True,
            "sourceLaneCoverageComplete": False,
        },
        "domains": [],
        "subdomains": [],
        "candidateOnlyBacklog": [],
        "sourceLaneReviewBacklog": [],
        "sourceLaneProfiles": {},
        "issues": issues,
    }
