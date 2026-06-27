"""Machine-readable Source Atlas source terms registry."""

from __future__ import annotations

from typing import Any

from .adapter_sdk import DistributionPolicy, R2PackPolicy, validate_distribution_policy
from .model import PRIVACY_BOUNDARY, utc_now


TERMS_REGISTRY_VERSION = "source-atlas-terms-registry-v1"

PUBLIC_PACK_CLASSES = [
    "official_public_source",
    "public_reference_claim",
    "public_requirement",
    "public_provenance",
    "public_ontology",
    "public_atom_edge_lattice",
    "public_recipe",
    "public_freshness",
]

FORBIDDEN_ARTIFACT_CLASS_GROUPS = [
    "non_public_runtime_field",
    "user_supplied_content",
    "account_or_credential_material",
    "personal_behavior_or_history",
    "non_reference_artifact",
]


SOURCE_TERMS_REGISTRY: list[dict[str, Any]] = [
    {
        "source_id": "onet.database",
        "source_name": "O*NET Database and O*NET OnLine public occupational reference data",
        "publisher": "U.S. Department of Labor Employment and Training Administration / National Center for O*NET Development",
        "source_url": "https://www.onetcenter.org/database.html",
        "terms_url": "https://www.onetcenter.org/overview.html#data",
        "license": "Creative Commons Attribution 4.0 International",
        "license_version": "4.0",
        "authority_tier": "official_dataset",
        "domain": "occupation",
        "jurisdiction": "US",
        "language": "en",
        "attribution_required": True,
        "redistribution_policy": DistributionPolicy.REDISTRIBUTABLE_WITH_ATTRIBUTION.value,
        "r2_pack_policy": R2PackPolicy.R2_PACK_ALLOWED.value,
        "derivatives_allowed": True,
        "api_key_required": False,
        "rate_limit_policy": "download release archives politely; fixture tests use local snapshots",
        "freshness_cadence": "track O*NET production database releases and quarterly review",
        "last_terms_reviewed": "2026-06-27",
        "terms_review_status": "reviewed",
        "allowed_artifact_classes": PUBLIC_PACK_CLASSES,
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASS_GROUPS,
        "review_required": False,
        "attribution_text": "O*NET data must retain O*NET attribution and license notice.",
    },
    {
        "source_id": "bls.public.data.api",
        "source_name": "BLS Public Data API",
        "publisher": "U.S. Bureau of Labor Statistics",
        "source_url": "https://www.bls.gov/developers/",
        "terms_url": "https://www.bls.gov/developers/termsOfService.htm",
        "license": "U.S. federal public data; cite BLS as source",
        "license_version": "current public API terms",
        "authority_tier": "official_government",
        "domain": "labor_market",
        "jurisdiction": "US",
        "language": "en",
        "attribution_required": True,
        "redistribution_policy": DistributionPolicy.REDISTRIBUTABLE_WITH_ATTRIBUTION.value,
        "r2_pack_policy": R2PackPolicy.R2_PACK_ALLOWED.value,
        "derivatives_allowed": True,
        "api_key_required": "v1_no_key; v2_key_required_for_registered_high-volume_access",
        "rate_limit_policy": "deterministic fixtures do not require secrets; live v2 requests must respect BLS limits",
        "freshness_cadence": "series-specific publication schedule",
        "last_terms_reviewed": "2026-06-27",
        "terms_review_status": "reviewed",
        "allowed_artifact_classes": PUBLIC_PACK_CLASSES,
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASS_GROUPS,
        "review_required": False,
    },
    {
        "source_id": "wikidata.crosswalk",
        "source_name": "Wikidata entity data",
        "publisher": "Wikimedia Foundation / Wikidata community",
        "source_url": "https://www.wikidata.org/wiki/Wikidata:Main_Page",
        "terms_url": "https://www.wikidata.org/wiki/Wikidata:Licensing",
        "license": "Creative Commons CC0 public domain dedication",
        "license_version": "1.0",
        "authority_tier": "open_knowledge_graph",
        "domain": "entity_crosswalk",
        "jurisdiction": "global",
        "language": "multilingual",
        "attribution_required": False,
        "redistribution_policy": DistributionPolicy.REDISTRIBUTABLE.value,
        "r2_pack_policy": R2PackPolicy.R2_PACK_ALLOWED.value,
        "derivatives_allowed": True,
        "api_key_required": False,
        "rate_limit_policy": "use deterministic fixtures for tests; live lookups must respect Wikidata endpoint etiquette",
        "freshness_cadence": "weekly crosswalk refresh and conflict review",
        "last_terms_reviewed": "2026-06-27",
        "terms_review_status": "reviewed",
        "allowed_artifact_classes": PUBLIC_PACK_CLASSES,
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASS_GROUPS,
        "review_required": False,
    },
    {
        "source_id": "openalex.dataset",
        "source_name": "OpenAlex dataset and API",
        "publisher": "OpenAlex",
        "source_url": "https://openalex.org/",
        "terms_url": "https://docs.openalex.org/download-all-data/openalex-snapshot",
        "license": "Creative Commons CC0 public domain dedication",
        "license_version": "1.0",
        "authority_tier": "official_dataset",
        "domain": "scholarly_reference",
        "jurisdiction": "global",
        "language": "en",
        "attribution_required": False,
        "redistribution_policy": DistributionPolicy.REDISTRIBUTABLE.value,
        "r2_pack_policy": R2PackPolicy.R2_PACK_ALLOWED.value,
        "derivatives_allowed": True,
        "api_key_required": "optional free polite-pool email/API use; fixture tests require no key",
        "rate_limit_policy": "fixture tests offline; live API should use polite pool; bulk snapshot route represented offline",
        "freshness_cadence": "monthly snapshot or API freshness review",
        "last_terms_reviewed": "2026-06-27",
        "terms_review_status": "reviewed",
        "allowed_artifact_classes": PUBLIC_PACK_CLASSES,
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASS_GROUPS,
        "review_required": False,
    },
    {
        "source_id": "usajobs.search",
        "source_name": "USAJOBS current and historic job opportunity APIs",
        "publisher": "U.S. Office of Personnel Management",
        "source_url": "https://developer.usajobs.gov/api-reference/",
        "terms_url": "https://developer.usajobs.gov/",
        "license": "terms not verified for redistributable Source Atlas pack inclusion",
        "license_version": "unverified",
        "authority_tier": "restricted",
        "domain": "public_job_lookup",
        "jurisdiction": "US",
        "language": "en",
        "attribution_required": True,
        "redistribution_policy": DistributionPolicy.LOOKUP_ONLY_NOT_PACKABLE.value,
        "r2_pack_policy": R2PackPolicy.R2_BLOCKED.value,
        "derivatives_allowed": False,
        "api_key_required": True,
        "rate_limit_policy": "credentialed lookup only; no pack output without explicit terms review",
        "freshness_cadence": "lookup-time only",
        "last_terms_reviewed": "2026-06-27",
        "terms_review_status": "restricted_unverified",
        "allowed_artifact_classes": ["official_public_source", "public_provenance"],
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASS_GROUPS,
        "review_required": True,
    },
]


def terms_registry_artifact() -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.termsRegistry.v1",
        "versionID": TERMS_REGISTRY_VERSION,
        "dataClass": "official_public_source",
        "createdAt": utc_now(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "sources": SOURCE_TERMS_REGISTRY,
    }


def terms_entry(source_id: str) -> dict[str, Any]:
    lookup = {entry["source_id"]: entry for entry in SOURCE_TERMS_REGISTRY}
    if source_id not in lookup:
        raise KeyError(f"unknown terms registry source_id: {source_id}")
    return lookup[source_id]


def validate_terms_registry() -> dict[str, Any]:
    issues: list[str] = []
    required = [
        "source_id",
        "source_name",
        "publisher",
        "source_url",
        "terms_url",
        "license",
        "license_version",
        "authority_tier",
        "domain",
        "jurisdiction",
        "language",
        "attribution_required",
        "redistribution_policy",
        "r2_pack_policy",
        "derivatives_allowed",
        "api_key_required",
        "rate_limit_policy",
        "freshness_cadence",
        "last_terms_reviewed",
        "terms_review_status",
        "allowed_artifact_classes",
        "forbidden_artifact_classes",
        "review_required",
    ]
    seen: set[str] = set()
    for entry in SOURCE_TERMS_REGISTRY:
        source_id = entry.get("source_id", "<unknown>")
        if source_id in seen:
            issues.append(f"{source_id}: duplicate source_id")
        seen.add(source_id)
        for field in required:
            value = entry.get(field)
            if field not in entry or value is None or value == "" or value == []:
                issues.append(f"{source_id}: missing {field}")
        if entry.get("redistribution_policy") not in {item.value for item in DistributionPolicy}:
            issues.append(f"{source_id}: unsupported redistribution_policy")
        if entry.get("r2_pack_policy") not in {item.value for item in R2PackPolicy}:
            issues.append(f"{source_id}: unsupported r2_pack_policy")
    return {
        "valid": not issues,
        "issueCount": len(issues),
        "issues": issues,
        "sourceCount": len(SOURCE_TERMS_REGISTRY),
    }


def policy_gate_for_output(source_id: str, output: dict[str, Any], review_evidence: dict[str, Any] | None = None) -> dict[str, Any]:
    return validate_distribution_policy(terms_entry(source_id), output, review_evidence)
