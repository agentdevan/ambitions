"""Owner-review packet for Source Atlas source terms and distribution posture."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, utc_now, write_json
from .terms_registry import SOURCE_TERMS_REGISTRY, validate_terms_registry


TERMS_REVIEW_VERSION = "source-atlas-terms-distribution-review-v1"


TERMS_EVIDENCE: dict[str, dict[str, Any]] = {
    "onet.database": {
        "allowedUse": "Public O*NET database and taxonomy records may be redistributed with required attribution under the recorded Creative Commons Attribution 4.0 International posture.",
        "restrictedUse": "Do not omit O*NET attribution or license notices; do not imply legal, hiring, admissions, or regulated-pathway authority.",
        "evidenceSummary": "O*NET public database pages identify O*NET data as available under Creative Commons Attribution 4.0 International and require attribution.",
        "decision": "packable_with_attribution",
        "unresolvedRisk": "Owner/legal approval of final attribution copy is not claimed by this packet.",
        "requiredAttributionText": "This product uses information from the O*NET Database by the U.S. Department of Labor, Employment and Training Administration (USDOL/ETA), used under CC BY 4.0. O*NET is a trademark of USDOL/ETA.",
    },
    "bls.public.data.api": {
        "allowedUse": "Official BLS public data may be used for public labor-market context with BLS attribution and API rate-limit compliance.",
        "restrictedUse": "Do not exceed API limits; do not present BLS public data as personalized employment, wage, legal, or regulated requirement advice.",
        "evidenceSummary": "BLS Public Data API terms document no-key v1 access, registered-key v2 access, request limits, and attribution/terms requirements.",
        "decision": "packable_with_attribution",
        "unresolvedRisk": "Series-specific publication and citation wording require owner review before production distribution copy is finalized.",
        "requiredAttributionText": "Source: U.S. Bureau of Labor Statistics public data.",
    },
    "wikidata.crosswalk": {
        "allowedUse": "Wikidata structured data is available under CC0 and may support entity labels, aliases, and crosswalk candidates.",
        "restrictedUse": "Do not use Wikidata as sole authority for regulated requirements; route conflicts and low-confidence matches to review.",
        "evidenceSummary": "Wikidata licensing pages identify database content under the Creative Commons CC0 public domain dedication.",
        "decision": "packable_crosswalk_support",
        "unresolvedRisk": "Community-edited data can be wrong or conflicted; authority tier remains open_knowledge_graph.",
        "requiredAttributionText": "No attribution required by CC0; Source Atlas may still cite Wikidata as provenance.",
    },
    "openalex.dataset": {
        "allowedUse": "OpenAlex data is available under CC0 and may support research topics, fields, institutions, and scholarly-source context.",
        "restrictedUse": "Do not use OpenAlex as regulated pathway authority; observe API rate limits and polite-pool guidance.",
        "evidenceSummary": "OpenAlex documentation describes CC0 dataset posture, free API access, optional authentication/polite-pool behavior, and snapshot access.",
        "decision": "packable_public_reference",
        "unresolvedRisk": "OpenAlex topic/institution matching remains contextual and can require review for ambiguous entities.",
        "requiredAttributionText": "No attribution required by CC0; Source Atlas may still cite OpenAlex as provenance.",
    },
    "usajobs.search": {
        "allowedUse": "Policy lane only. USAJOBS may be represented as restricted/lookup-only until explicit written approval for redistribution exists.",
        "restrictedUse": "Do not fetch, store, redistribute, package, or promote USAJOBS API content into R2-ready Source Atlas packs without explicit written approval.",
        "evidenceSummary": "USAJOBS developer terms include restrictions that require prior written approval for redistribution/republication and support lookup-only policy treatment.",
        "decision": "blocked_from_pack_output",
        "unresolvedRisk": "Terms remain unverified for redistributable pack use; owner/legal review would be required for any future use beyond policy metadata.",
        "requiredAttributionText": "No redistributable USAJOBS pack attribution is emitted because the source lane is blocked from packs.",
    },
}


def build_terms_distribution_review(output_path: Path, reviewer: str = "Codex evidence preparation; owner/legal approval not claimed") -> dict[str, Any]:
    created_at = utc_now()
    registry_result = validate_terms_registry()
    sources = []
    for entry in SOURCE_TERMS_REGISTRY:
        evidence = TERMS_EVIDENCE[entry["source_id"]]
        sources.append({
            "sourceID": entry["source_id"],
            "sourceName": entry["source_name"],
            "publisher": entry["publisher"],
            "termsURL": entry["terms_url"],
            "sourceURL": entry["source_url"],
            "license": entry["license"],
            "licenseVersion": entry["license_version"],
            "allowedUse": evidence["allowedUse"],
            "restrictedUse": evidence["restrictedUse"],
            "attribution": {
                "required": entry["attribution_required"],
                "text": evidence["requiredAttributionText"],
            },
            "redistributionPolicy": entry["redistribution_policy"],
            "r2PackPolicy": entry["r2_pack_policy"],
            "apiKeyPosture": entry["api_key_required"],
            "reviewedDate": created_at.split("T", 1)[0],
            "reviewer": reviewer,
            "evidenceSummary": evidence["evidenceSummary"],
            "decision": evidence["decision"],
            "unresolvedRisk": evidence["unresolvedRisk"],
            "authorityTier": entry["authority_tier"],
            "reviewRequired": entry["review_required"],
            "dataClass": "public_provenance",
            "publicReferenceOnly": True,
        })
    owner_review_complete = False
    blocked_sources = [source for source in sources if source["r2PackPolicy"] == "r2_blocked" or source["redistributionPolicy"] == "lookup_only_not_packable"]
    payload = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.termsDistributionReview.v1",
        "versionID": TERMS_REVIEW_VERSION,
        "createdAt": created_at,
        "status": "Yellow",
        "statusReason": "owner/legal approval is not claimed; evidence packet is ready for owner review",
        "registryValidation": registry_result,
        "ownerReviewComplete": owner_review_complete,
        "productionDistributionDecision": "approved_sources_packable_by_policy; restricted_sources_blocked; owner/legal approval_not_claimed",
        "sources": sources,
        "blockedSources": [source["sourceID"] for source in blocked_sources],
        "nonClaims": [
            "not legal approval",
            "not privacy approval",
            "not release readiness",
            "not complete Source Atlas project Green",
            *NON_CLAIMS,
        ],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }
    write_json(output_path, payload)
    markdown_path = output_path.with_suffix(".md")
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(render_terms_review_markdown(payload), encoding="utf-8")
    return payload


def render_terms_review_markdown(payload: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Terms Distribution Review",
        "",
        f"Status: {payload['status']}",
        "",
        payload["statusReason"],
        "",
        "| Source | License | Redistribution | R2 policy | Decision | Unresolved risk |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for source in payload["sources"]:
        lines.append(
            f"| `{source['sourceID']}` | {source['license']} | {source['redistributionPolicy']} | {source['r2PackPolicy']} | {source['decision']} | {source['unresolvedRisk']} |"
        )
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {item}" for item in payload["nonClaims"])
    lines.append("")
    return "\n".join(lines)
