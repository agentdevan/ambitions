"""Source registry and adapter certification contracts for Foundry."""

from __future__ import annotations

from typing import Any

from .adapters import ADAPTER_VERSION
from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, stable_id, utc_now
from .registry import SOURCE_REGISTRY


def _privacy_expectations() -> dict[str, Any]:
    return {
        "publicReferenceOnly": True,
        "rejectsPrivateUserContext": True,
        "credentialPolicy": "environment_names_only; never compiled into bundle, manifest, plan, logs, or fixtures",
        "logPolicy": "metadata_only",
        "r2Posture": "public/reference artifacts only",
    }


ADAPTER_CERTIFICATIONS: dict[str, dict[str, Any]] = {
    "official_static_page": {
        "adapterID": "official_static_page",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["official_static_page"],
        "fixtureExpectations": ["positive_static_page_markers", "negative_private_context_rejection"],
        "driftChecks": ["http_status", "marker_presence", "content_hash"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_onet_text_database": {
        "adapterID": "official_onet_text_database",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["official_downloadable_database"],
        "fixtureExpectations": ["positive_zip_table_parse", "negative_missing_zip_block"],
        "driftChecks": ["release_label", "table_presence", "row_count_floor", "content_hash"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_bls_public_api": {
        "adapterID": "official_bls_public_api",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["official_public_api"],
        "fixtureExpectations": ["positive_public_api_response", "negative_private_context_rejection"],
        "driftChecks": ["api_status", "series_presence", "publication_cadence"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_wikidata_entity_crosswalk": {
        "adapterID": "official_wikidata_entity_crosswalk",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["structured_data_crosswalk_api"],
        "fixtureExpectations": ["positive_entity_lookup_crosswalk", "negative_regulated_authority_rejection"],
        "driftChecks": ["entity_schema", "query_cap", "timeout", "retry_after_or_429_backoff"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_openalex_api": {
        "adapterID": "official_openalex_api",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["scholarly_metadata_api"],
        "fixtureExpectations": ["positive_work_metadata_response", "negative_key_redaction"],
        "driftChecks": ["response_schema", "rate_limit_headers", "daily_budget", "per_run_cap", "429_backoff"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_usajobs_authenticated_search": {
        "adapterID": "official_usajobs_authenticated_search",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["authenticated_public_api"],
        "fixtureExpectations": ["positive_auth_block_reason", "negative_secret_redaction"],
        "driftChecks": ["auth_env_presence", "response_schema", "modified_date"],
        "unavailableSourceBehavior": "block_source_with_missing_env_names_only",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_datagov_v4_search": {
        "adapterID": "official_datagov_v4_search",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["source_catalog_metadata_api"],
        "fixtureExpectations": ["positive_catalog_metadata", "negative_contact_redaction"],
        "driftChecks": ["metadata_schema", "dataset_modified_date", "source_url_redaction"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
    "official_college_scorecard_api": {
        "adapterID": "official_college_scorecard_api",
        "adapterVersion": ADAPTER_VERSION,
        "sourceTypes": ["official_public_api"],
        "fixtureExpectations": ["positive_public_api_response", "negative_key_redaction"],
        "driftChecks": ["api_status", "metadata_total", "data_release_date"],
        "unavailableSourceBehavior": "block_source_and_preserve_reason",
        "privacyExpectations": _privacy_expectations(),
    },
}

SOURCE_CERTIFICATION_PROFILES: dict[str, dict[str, Any]] = {
    "nara.constitution.presidency": {
        "sourceType": "official_static_page",
        "jurisdiction": "US federal",
        "licenseTermsPosture": "public federal source; cite authoritative URL",
        "fixtureExpectationIDs": ["nara.constitution.presidency.static-markers"],
        "driftCheckIDs": ["constitutional_text_marker_presence", "source_url_hash"],
    },
    "nasa.astronaut.requirements": {
        "sourceType": "official_static_page",
        "jurisdiction": "US federal program",
        "licenseTermsPosture": "NASA public web source; cite authoritative URL",
        "fixtureExpectationIDs": ["nasa.astronaut.requirements.static-markers"],
        "driftCheckIDs": ["selection_cycle_requirement_markers", "source_url_hash"],
    },
    "nasa.astronaut.selection": {
        "sourceType": "official_static_page",
        "jurisdiction": "US federal program",
        "licenseTermsPosture": "NASA public web source; cite authoritative URL",
        "fixtureExpectationIDs": ["nasa.astronaut.selection.static-markers"],
        "driftCheckIDs": ["selection_program_markers", "source_url_hash"],
    },
    "onet.database": {
        "sourceType": "official_downloadable_database",
        "jurisdiction": "US federal occupational data",
        "licenseTermsPosture": "CC BY 4.0 with O*NET attribution requirements",
        "fixtureExpectationIDs": ["onet.database.text-zip-and-crosswalk"],
        "driftCheckIDs": ["onet_release_label", "required_table_presence", "career_cluster_crosswalk"],
    },
    "bls.public.data.api": {
        "sourceType": "official_public_api",
        "jurisdiction": "US federal labor statistics",
        "licenseTermsPosture": "public federal source; cite BLS source",
        "fixtureExpectationIDs": ["bls.public.data.api.series-response"],
        "driftCheckIDs": ["series_response_status", "publication_schedule_watch"],
    },
    "wikidata.structured_crosswalk": {
        "sourceType": "structured_data_crosswalk_api",
        "jurisdiction": "global structured data",
        "licenseTermsPosture": "CC0 structured-data posture; crosswalk only; not a regulated requirement authority",
        "fixtureExpectationIDs": ["wikidata.structured_crosswalk.entity-lookup"],
        "driftCheckIDs": ["entity_lookup_schema", "crosswalk_only_guard", "rate_limit_backoff"],
    },
    "openalex.works": {
        "sourceType": "scholarly_metadata_api",
        "jurisdiction": "global scholarly metadata",
        "licenseTermsPosture": "public scholarly metadata; high-volume use requires key, rate, and budget governance",
        "fixtureExpectationIDs": ["openalex.works.metadata-response"],
        "driftCheckIDs": ["work_response_schema", "rate_limit_headers", "budget_gate"],
    },
    "usajobs.search": {
        "sourceType": "authenticated_public_api",
        "jurisdiction": "US federal job announcements",
        "licenseTermsPosture": "public announcement API; credentials never compiled into artifacts",
        "fixtureExpectationIDs": ["usajobs.search.auth-block"],
        "driftCheckIDs": ["required_env_names_only", "announcement_modified_date"],
    },
    "data.gov.catalog": {
        "sourceType": "source_catalog_metadata_api",
        "jurisdiction": "US federal source catalog",
        "licenseTermsPosture": "dataset-specific; catalog metadata is discovery only",
        "fixtureExpectationIDs": ["data.gov.catalog.metadata-redaction"],
        "driftCheckIDs": ["metadata_schema", "dataset_modified_date"],
    },
    "college-scorecard.api": {
        "sourceType": "official_public_api",
        "jurisdiction": "US federal education data",
        "licenseTermsPosture": "public Department of Education data; cite source",
        "fixtureExpectationIDs": ["college-scorecard.api.public-response"],
        "driftCheckIDs": ["metadata_total", "release_date_watch"],
    },
}


def certified_source_records(sources: list[dict[str, Any]] | None = None) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for source in sources or SOURCE_REGISTRY:
        adapter = ADAPTER_CERTIFICATIONS.get(source.get("adapter", ""))
        profile = SOURCE_CERTIFICATION_PROFILES.get(source.get("id", ""))
        record = dict(source)
        if adapter:
            record["adapterCertification"] = adapter
        if profile:
            record.update(profile)
            record["cadence"] = source.get("freshnessCadence")
            record["unavailableSourceBehavior"] = adapter.get("unavailableSourceBehavior") if adapter else None
            record["privacyExpectations"] = adapter.get("privacyExpectations") if adapter else _privacy_expectations()
            record["certificationID"] = stable_id("cert.source_atlas", {"sourceID": source["id"], "adapter": source.get("adapter"), "profile": profile})
            record["certifiedAt"] = utc_now()
        records.append(record)
    return records


def certify_registry(sources: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    records = certified_source_records(sources)
    issues: list[str] = []
    required_source_fields = [
        "id",
        "title",
        "publisher",
        "url",
        "authorityTier",
        "license",
        "freshnessCadence",
        "sourceType",
        "cadence",
        "jurisdiction",
        "licenseTermsPosture",
        "unavailableSourceBehavior",
        "fixtureExpectationIDs",
        "driftCheckIDs",
        "privacyExpectations",
        "adapterCertification",
    ]
    for record in records:
        label = record.get("id", "<source>")
        for field in required_source_fields:
            if not record.get(field):
                issues.append(f"{label}: missing certification field {field}")
        adapter_id = record.get("adapter")
        adapter = record.get("adapterCertification", {})
        if adapter_id not in ADAPTER_CERTIFICATIONS:
            issues.append(f"{label}: missing adapter certification for {adapter_id}")
        elif record.get("sourceType") not in adapter.get("sourceTypes", []):
            issues.append(f"{label}: sourceType {record.get('sourceType')} not allowed for adapter {adapter_id}")
        privacy = record.get("privacyExpectations", {})
        if privacy.get("publicReferenceOnly") is not True:
            issues.append(f"{label}: privacyExpectations.publicReferenceOnly must be true")
        if privacy.get("rejectsPrivateUserContext") is not True:
            issues.append(f"{label}: privacyExpectations.rejectsPrivateUserContext must be true")
        if not record.get("fixtureExpectationIDs"):
            issues.append(f"{label}: fixture expectations required")
        if not record.get("driftCheckIDs"):
            issues.append(f"{label}: drift checks required")
        issues.extend(boundary_issue_strings(boundary_issues_for_value(record, label)))
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.sourceRegistryCertification",
        "dataClass": "official_public_source",
        "r2Allowed": True,
        "appCacheAllowed": True,
        "logAllowed": "metadata_only",
        "fixtureAllowed": "public_synthetic_only",
        "valid": not issues,
        "sourceCount": len(records),
        "adapterCount": len(ADAPTER_CERTIFICATIONS),
        "issues": issues,
        "sources": records,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
