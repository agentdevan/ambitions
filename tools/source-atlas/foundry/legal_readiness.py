"""Source Atlas legal/terms readiness posture.

This module records technical terms posture for Source Atlas lanes. It is not
outside legal approval and must not be reported as such.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, utc_now, write_json


OUTSIDE_LEGAL_STATUS = "outside legal approval not claimed"
OWNER_LEGAL_READINESS_REVIEW_STATUS = "completed_owner_acceptance"
LEGAL_RESULT = "Owner-completed technical legal-readiness review; outside legal approval not claimed."
ILLEGAL_FINDINGS: list[dict[str, Any]] = []
LEGAL_RECONCILIATIONS: list[dict[str, Any]] = [
    {
        "id": "usajobs_restricted_block",
        "finding": "USAJOBS redistribution and R2 pack approval is unproven.",
        "resolution": "USAJOBS remains blocked from redistributable and R2-ready pack output unless written OPM USAJOBS approval exists.",
        "status": "reconciled_by_blocking_pack_and_r2_modes",
    },
    {
        "id": "wikidata_authority_boundary",
        "finding": "Wikidata authority misuse would be unsafe for regulated requirements.",
        "resolution": "Wikidata remains structured-data crosswalk only and cannot become regulated requirement authority.",
        "status": "reconciled_by_crosswalk_only_policy",
    },
    {
        "id": "openalex_high_volume_boundary",
        "finding": "OpenAlex high-volume production use cannot be assumed unlimited.",
        "resolution": "OpenAlex high-volume use is gated by explicit budget and approval controls.",
        "status": "reconciled_by_api_governance_gate",
    },
    {
        "id": "onet_attribution_boundary",
        "finding": "O*NET redistribution requires attribution and version posture.",
        "resolution": "O*NET is packable only with CC BY attribution, license link, O*NET version, USDOL/ETA credit, and modification notice where applicable.",
        "status": "reconciled_by_required_pack_metadata",
    },
    {
        "id": "bls_keyed_mode_boundary",
        "finding": "BLS v2 keyed use requires key/rate governance.",
        "resolution": "BLS v1 no-key lane remains allowed; BLS v2 remains optional and gated by BLS_API_KEY and API governance.",
        "status": "reconciled_by_optional_key_mode",
    },
]


SOURCE_LANES: list[dict[str, Any]] = [
    {
        "laneID": "onet",
        "source": "O*NET",
        "sourceIDs": ["onet.database"],
        "licenseTermsPosture": "CC BY 4.0 with O*NET attribution requirements.",
        "allowedUse": "Packable public/reference occupation, task, skill, education, training, work-context, and transfer records.",
        "forbiddenUse": "No private user context, no uncredited redistribution, no final user path, no regulated decision authority.",
        "attributionRequirements": [
            "credit U.S. Department of Labor, Employment and Training Administration",
            "include O*NET license link",
            "include O*NET version or release label",
            "include modification notice where applicable",
        ],
        "sourceAtlasRedistributionDecision": "packable_with_attribution",
        "r2PackDecision": "allowed_with_attribution_metadata",
        "ownerAcceptanceStatus": "accepted_for_technical_terms_posture",
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "termsStatus": "Green",
        "riskSummary": "Attribution and version labeling are mandatory before pack publication.",
        "requiredLegalQuestions": [
            "Confirm exact O*NET attribution placement for app inspection and R2 manifests.",
            "Confirm whether modified normalized tables need per-artifact modification notices.",
        ],
    },
    {
        "laneID": "bls",
        "source": "BLS",
        "sourceIDs": ["bls.public.data.api"],
        "licenseTermsPosture": "U.S. federal public labor statistics source; cite BLS source and series.",
        "allowedUse": "BLS v1 public/no-key lane remains allowed for public/reference labor-market context.",
        "forbiddenUse": "No private user context, no final employment decision, no non-public data, no unstated v2 high-volume use.",
        "attributionRequirements": ["cite BLS source URL, series ID, and retrieval/publication context"],
        "sourceAtlasRedistributionDecision": "public_reference_allowed",
        "r2PackDecision": "allowed_for_public_reference_statistics",
        "ownerAcceptanceStatus": "accepted_for_technical_terms_posture",
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "termsStatus": "Green",
        "riskSummary": "BLS v2 key mode is optional and requires explicit key/rate governance.",
        "requiredLegalQuestions": [
            "Confirm whether any BLS series-specific redistribution limits apply to cached pack artifacts.",
            "Confirm attribution wording for public/reference pack manifests.",
        ],
    },
    {
        "laneID": "wikidata",
        "source": "Wikidata",
        "sourceIDs": ["wikidata.structured_crosswalk"],
        "licenseTermsPosture": "CC0 structured-data posture.",
        "allowedUse": "Structured data crosswalks and entity alignment only.",
        "forbiddenUse": "Do not use as regulated requirement authority or source of official eligibility requirements.",
        "attributionRequirements": ["record Wikidata entity IDs and retrieval timestamp when used"],
        "sourceAtlasRedistributionDecision": "crosswalk_only",
        "r2PackDecision": "allowed_only_for_cc0_structured_crosswalks",
        "ownerAcceptanceStatus": "accepted_for_technical_terms_posture",
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "termsStatus": "Green",
        "riskSummary": "Authority misuse risk is the main concern; official sources must own regulated requirements.",
        "requiredLegalQuestions": [
            "Confirm attribution expectations even when CC0 does not require attribution.",
            "Confirm crosswalk-only boundary is sufficient for future entity matching.",
        ],
    },
    {
        "laneID": "openalex",
        "source": "OpenAlex",
        "sourceIDs": ["openalex.works"],
        "licenseTermsPosture": "Open scholarly metadata lane with explicit free-key, no-key, rate, and budget controls required.",
        "allowedUse": "Public/reference scholarly metadata discovery and citation context when budgets are explicit.",
        "forbiddenUse": "Do not assume unlimited free high-volume production use; no private user context; no unbounded crawl.",
        "attributionRequirements": ["record OpenAlex source URL, work IDs, retrieval timestamp, and API mode"],
        "sourceAtlasRedistributionDecision": "allowed_when_rate_budget_governed",
        "r2PackDecision": "allowed_only_for_budgeted_public_reference_snapshots",
        "ownerAcceptanceStatus": "accepted_for_technical_terms_posture",
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "termsStatus": "Green",
        "riskSummary": "High-volume production use requires budget, rate, retry, and failure posture approval.",
        "requiredLegalQuestions": [
            "Confirm high-volume metadata redistribution posture before production-scale snapshots.",
            "Confirm required attribution fields for derived scholarly metadata packs.",
        ],
    },
    {
        "laneID": "usajobs_restricted",
        "source": "USAJOBS/restricted",
        "sourceIDs": ["usajobs.search"],
        "licenseTermsPosture": "Authenticated OPM USAJOBS API lane; written approval required before redistributable pack or R2 output.",
        "allowedUse": "Lookup-only, review-required source lane unless written OPM USAJOBS approval exists.",
        "forbiddenUse": "No redistributable pack output, no R2-ready pack output, no compiled current announcement redistribution without written approval.",
        "attributionRequirements": ["retain OPM/USAJOBS source URL and approval evidence if approval is obtained later"],
        "sourceAtlasRedistributionDecision": "blocked_without_written_opm_approval",
        "r2PackDecision": "blocked_without_written_opm_approval",
        "ownerAcceptanceStatus": "accepted_blocked_posture",
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "termsStatus": "Blocked",
        "riskSummary": "Redistribution approval is unproven; keep out of packs and R2 outputs.",
        "requiredLegalQuestions": [
            "Can Ambitions redistribute normalized USAJOBS announcement records in public/reference packs?",
            "What written approval text or contract is required from OPM USAJOBS?",
        ],
    },
]


def build_terms_registry(*, included_source_ids: list[str] | None = None) -> dict[str, Any]:
    included = set(included_source_ids or [])
    lanes = []
    issues: list[str] = []
    for lane in SOURCE_LANES:
        item = dict(lane)
        item["includedInCurrentStableCandidate"] = bool(included.intersection(lane["sourceIDs"]))
        if item["includedInCurrentStableCandidate"] and item["termsStatus"] != "Green":
            issues.append(f"{lane['laneID']}: included source lane is not terms Green")
        lanes.append(item)

    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.termsRegistry",
        "createdAt": utc_now(),
        "valid": not issues,
        "status": "Green" if not issues else "Red",
        "legalResult": LEGAL_RESULT,
        "ownerLegalReadinessReviewStatus": OWNER_LEGAL_READINESS_REVIEW_STATUS,
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "illegalFindings": ILLEGAL_FINDINGS,
        "illegalFindingsReconciled": True,
        "legalReconciliations": LEGAL_RECONCILIATIONS,
        "sourceLanes": lanes,
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS
        + [
            "not outside legal approval",
            "not App Store readiness",
            "not release readiness",
            "not account readiness",
        ],
    }


def build_legal_review_packet() -> dict[str, Any]:
    registry = build_terms_registry()
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.legalReviewReadiness",
        "createdAt": registry["createdAt"],
        "status": LEGAL_RESULT,
        "outsideLegalApprovalClaimed": False,
        "outsideLegalApprovalStatus": OUTSIDE_LEGAL_STATUS,
        "ownerAcceptanceStatus": "owner-completed technical legal-readiness review for this train",
        "ownerLegalReadinessReviewStatus": OWNER_LEGAL_READINESS_REVIEW_STATUS,
        "illegalFindings": ILLEGAL_FINDINGS,
        "illegalFindingsFound": False,
        "illegalFindingsReconciled": True,
        "legalReconciliations": LEGAL_RECONCILIATIONS,
        "termsRegistryStatus": registry["status"],
        "sourceLanes": registry["sourceLanes"],
        "riskSummary": [
            "O*NET requires attribution, license link, version, and modification notice where applicable.",
            "BLS v1 no-key public lane is allowed; BLS v2 is optional and key/rate governed.",
            "Wikidata is crosswalk-only and cannot become regulated requirement authority.",
            "OpenAlex high-volume production use is budget/rate gated.",
            "USAJOBS remains blocked from redistributable and R2-ready pack output without written OPM USAJOBS approval.",
        ],
        "requiredLegalQuestions": [
            question
            for lane in registry["sourceLanes"]
            for question in lane["requiredLegalQuestions"]
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": registry["nonClaims"],
    }


def legal_review_markdown(packet: dict[str, Any] | None = None) -> str:
    packet = packet or build_legal_review_packet()
    lines = [
        "# Source Atlas Legal Review Readiness",
        "",
        f"Status: {packet['status']}",
        "",
        "This packet is a technical terms posture and legal-review readiness packet. It does not claim outside legal approval.",
        "",
        "## Owner Legal Readiness Review",
        "",
        f"Owner review status: {packet['ownerLegalReadinessReviewStatus']}",
        "",
        f"Illegal findings found: {packet['illegalFindingsFound']}",
        "",
        "Outside legal approval remains not claimed.",
        "",
        "## Illegal Findings Reconciliation",
        "",
    ]
    if packet["illegalFindings"]:
        lines.extend([f"- {finding}" for finding in packet["illegalFindings"]])
    else:
        lines.append("- No illegal findings identified in the Source Atlas stable-channel packet.")
    lines.extend(
        [
            "",
            "| Reconciliation | Resolution | Status |",
            "|---|---|---|",
        ]
    )
    for item in packet["legalReconciliations"]:
        lines.append(f"| {item['finding']} | {item['resolution']} | {item['status']} |")
    lines.extend(
        [
            "",
            "## Source Lane Decisions",
            "",
            "| Source lane | License / terms posture | Allowed use | Forbidden use | Attribution | Source Atlas decision | R2 pack decision | Owner acceptance | Outside legal approval | Risk |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ]
    )
    for lane in packet["sourceLanes"]:
        attribution = "<br>".join(lane["attributionRequirements"])
        lines.append(
            "| {source} | {license} | {allowed} | {forbidden} | {attribution} | {source_decision} | {r2_decision} | {owner} | {legal} | {risk} |".format(
                source=lane["source"],
                license=lane["licenseTermsPosture"],
                allowed=lane["allowedUse"],
                forbidden=lane["forbiddenUse"],
                attribution=attribution,
                source_decision=lane["sourceAtlasRedistributionDecision"],
                r2_decision=lane["r2PackDecision"],
                owner=lane["ownerAcceptanceStatus"],
                legal=lane["outsideLegalApprovalStatus"],
                risk=lane["riskSummary"],
            )
        )
    lines.extend(
        [
            "",
            "## Required Legal Questions",
            "",
            *[f"- {question}" for question in packet["requiredLegalQuestions"]],
            "",
            "## Final Legal Result",
            "",
            packet["status"],
            "",
            "## Non-Claims",
            "",
            *[f"- {claim}" for claim in packet["nonClaims"]],
            "",
        ]
    )
    return "\n".join(lines)


def write_legal_review_packet(markdown_path: Path, json_path: Path) -> dict[str, Any]:
    packet = build_legal_review_packet()
    write_json(json_path, packet)
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(legal_review_markdown(packet), encoding="utf-8")
    return packet
