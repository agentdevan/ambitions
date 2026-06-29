"""Fixture-first public catalog discovery for Source Atlas.

This lane parses common public catalog metadata shapes into candidate source
records. Catalog metadata is a source-of-sources input only: it never becomes
claim authority, never emits packable claims, and never emits R2-ready output.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_DISCOVERY_VERSION = "source-atlas-catalog-discovery-train-53"
CATALOG_DISCOVERY_KIND = "ambitions.sourceAtlas.catalogDiscovery.v1"

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
REDISTRIBUTION_GUESSES = {
    "clearly_open",
    "open_with_attribution",
    "terms_sensitive",
    "restricted",
    "unclear",
    "blocked",
}
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}
DOMAIN_KEYWORDS = {
    "education_credentialing": {"credential", "education", "school", "training", "program"},
    "health_wellness_reference": {"cdc", "exercise", "health", "wellness"},
    "public_civic_requirements": {"civic", "deadline", "eligibility", "form", "government"},
    "travel_relocation": {"relocation", "travel", "transit", "transportation"},
    "volunteering_public_reference": {"americorps", "service", "volunteer"},
}

CATALOG_NON_CLAIMS = [
    "not source authority",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not legal approval",
    "not outside legal approval",
    "not universal coverage",
    "not live network discovery",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class CatalogDiscoveryOptions:
    input_root: Path
    output_root: Path
    created_at: str | None = None


def run_catalog_discovery(options: CatalogDiscoveryOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    catalog_files = sorted(path for path in options.input_root.rglob("*.json") if path.is_file())
    issues: list[str] = []
    catalog_records: list[dict[str, Any]] = []
    candidates: list[dict[str, Any]] = []
    input_privacy_issues: list[str] = []

    if not options.input_root.exists():
        issues.append(f"input root missing: {options.input_root}")
    if options.input_root.exists() and not catalog_files:
        issues.append(f"input root has no JSON catalog fixtures: {options.input_root}")

    for path in catalog_files:
        try:
            payload = read_json(path)
        except json.JSONDecodeError as exc:
            issues.append(f"{path}: invalid JSON: {exc}")
            continue
        input_privacy_issues.extend(privacy_findings_for_value(payload, f"catalog-discovery-input:{path}"))
        catalog = _catalog_record(path, payload, created_at)
        catalog_records.append(catalog)
        for index, dataset in enumerate(_datasets_for_payload(payload)):
            candidates.append(
                _candidate_from_dataset(
                    dataset=dataset,
                    catalog=catalog,
                    index=index,
                    created_at=created_at,
                )
            )

    catalog_records = sorted(catalog_records, key=lambda item: item["catalog_id"])
    candidates = sorted(candidates, key=lambda item: (item["domain_guess"], -item["candidate_score"], item["candidate_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_DISCOVERY_KIND,
        "versionID": CATALOG_DISCOVERY_VERSION,
        "createdAt": created_at,
        "inputRoot": str(options.input_root),
        "catalogRecords": catalog_records,
        "candidateSourceRecords": candidates,
        "recordCounts": {
            "catalogs": len(catalog_records),
            "candidateSources": len(candidates),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": CATALOG_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-discovery")
    checks = [
        {
            "name": "input_catalogs_valid",
            "passed": not issues and bool(catalog_records),
            "issues": issues,
        },
        {
            "name": "input_privacy_scan_passed",
            "passed": not input_privacy_issues,
            "issues": input_privacy_issues,
        },
        {
            "name": "catalog_discovery_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "all_candidates_review_required",
            "passed": all(candidate["review_required"] is True for candidate in candidates),
            "issues": [],
        },
        {
            "name": "no_candidate_claim_authority",
            "passed": all(candidate["claim_authority_allowed"] is False for candidate in candidates),
            "issues": [],
        },
        {
            "name": "pack_output_blocked",
            "passed": all(candidate["pack_output_allowed"] is False for candidate in candidates),
            "issues": [],
        },
        {
            "name": "catalogs_are_source_of_sources_only",
            "passed": all("catalog_metadata_not_claim_authority" in candidate["blocking_reasons"] for candidate in candidates),
            "issues": [],
        },
        {
            "name": "privacy_scan_passed",
            "passed": not artifact_privacy_issues,
            "issues": artifact_privacy_issues,
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    all_issues = list(issues)
    all_issues.extend(input_privacy_issues)
    all_issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            all_issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not all_issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogDiscoveryManifest.v1",
        "versionID": CATALOG_DISCOVERY_VERSION,
        "createdAt": created_at,
        "status": "Source Green for fixture-backed catalog discovery tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; catalog/source discovery candidates only",
        "inputRoot": str(options.input_root),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(all_issues)),
        "outputPaths": {
            "catalogDiscovery": str(output_root / "catalog-discovery.json"),
            "candidateSources": str(output_root / "candidate-sources.json"),
            "catalogs": str(output_root / "catalogs.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": CATALOG_NON_CLAIMS,
    }

    write_json(output_root / "catalog-discovery.json", artifact)
    write_json(output_root / "candidate-sources.json", {"candidateSourceRecords": candidates, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogCandidateSources.v1"})
    write_json(output_root / "catalogs.json", {"catalogRecords": catalog_records, "createdAt": created_at, "kind": "ambitions.sourceAtlas.discoveryCatalogs.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogDiscovery": stable_hash(read_json(output_root / "catalog-discovery.json")),
        "candidateSources": stable_hash(read_json(output_root / "candidate-sources.json")),
        "catalogs": stable_hash(read_json(output_root / "catalogs.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_discovery_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_discovery_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_root: Path,
    output_root: Path,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = run_catalog_discovery(CatalogDiscoveryOptions(input_root=input_root, output_root=output_root, created_at=created_at))
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_discovery_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_discovery_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Catalog Discovery Train 53",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Fixture-backed parser for DCAT/data.json, CKAN package-search, and schema.org Dataset/DataCatalog metadata.",
        "- Candidate source records that are review-required, claim-authority-blocked, and pack-output-blocked.",
        "- Privacy scans for submitted catalog metadata and emitted artifacts.",
        "",
        "Product law preserved:",
        "- Catalog metadata is discovery/provenance input only.",
        "- No claims, packable claims, R2 artifacts, final plans, schedules, or Steps are emitted.",
        "- R2 remains public/reference/freshness infrastructure only.",
        "",
        "Validation run:",
        "- See current train closeout for exact commands.",
        "",
        "Validation not run:",
        "- Live network catalog crawling was not run.",
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
            "Production non-claims:",
            *[f"- {claim}" for claim in result["nonClaims"]],
            "",
        ]
    )
    return "\n".join(lines)


def _catalog_record(path: Path, payload: Any, created_at: str) -> dict[str, Any]:
    kind = _catalog_kind(payload)
    record = {
        "schema_version": "1.0.0",
        "catalog_id": stable_id("catalog", {"path": str(path), "kind": kind}),
        "catalog_path": str(path),
        "catalog_kind": kind,
        "parsed_at": created_at,
        "dataset_count": len(_datasets_for_payload(payload)),
        "review_required": True,
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
        "blocking_reasons": [
            "catalog_metadata_not_claim_authority",
            "source_lane_review_required",
            "legal_terms_review_required",
            "candidate_score_cannot_override_review",
        ],
        "evidence_hash": stable_hash(payload),
    }
    return record


def _datasets_for_payload(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    if not isinstance(payload, dict):
        return []
    if isinstance(payload.get("dataset"), list):
        return [item for item in payload["dataset"] if isinstance(item, dict)]
    result = payload.get("result")
    if isinstance(result, dict) and isinstance(result.get("results"), list):
        return [item for item in result["results"] if isinstance(item, dict)]
    graph = payload.get("@graph")
    if isinstance(graph, list):
        return [item for item in graph if isinstance(item, dict) and _schema_type_contains(item, "Dataset")]
    if _schema_type_contains(payload, "Dataset"):
        return [payload]
    return []


def _catalog_kind(payload: Any) -> str:
    if isinstance(payload, dict):
        if isinstance(payload.get("dataset"), list):
            return "dcat_data_json"
        if isinstance(payload.get("result"), dict):
            return "ckan_package_search"
        if "@context" in payload or "@graph" in payload or _schema_type_contains(payload, "Dataset"):
            return "schema_org"
    if isinstance(payload, list):
        return "dataset_array"
    return "unknown_catalog"


def _candidate_from_dataset(dataset: dict[str, Any], catalog: dict[str, Any], index: int, created_at: str) -> dict[str, Any]:
    title = _first_text(dataset, ("title", "name"))
    publisher_name, publisher_url = _publisher(dataset)
    declared_license = _license(dataset)
    terms_url = _first_text(dataset, ("terms_url", "termsURL", "termsOfUse"))
    rights_url = _first_text(dataset, ("rights_url", "rights", "rightsURL"))
    dataset_url = _first_text(dataset, ("landingPage", "url", "identifier"))
    if not dataset_url:
        dataset_url = _first_text(dataset, ("notes",))
    distribution_urls = _distribution_urls(dataset)
    api_docs_url = _api_docs_url(dataset)
    authority_guess = _validated_choice(str(dataset.get("authority_class_guess", _authority_guess(publisher_name, publisher_url))), AUTHORITY_CLASSES, "unknown")
    redistribution_guess = _validated_choice(str(dataset.get("redistribution_guess", _redistribution_guess(declared_license, rights_url))), REDISTRIBUTION_GUESSES, "unclear")
    raw_keywords = _keywords(dataset)
    domain_guess = _domain_guess(title, publisher_name, raw_keywords)
    blocking_reasons = _candidate_blocking_reasons(declared_license, terms_url, rights_url)
    candidate = {
        "schema_version": "1.0.0",
        "candidate_id": stable_id("catalog_candidate", {"catalog": catalog["catalog_id"], "index": index, "dataset": dataset}),
        "catalog_id": catalog["catalog_id"],
        "discovery_method": catalog["catalog_kind"],
        "discovered_at": created_at,
        "publisher_name": publisher_name,
        "publisher_url": publisher_url,
        "declared_jurisdiction": _first_text(dataset, ("declared_jurisdiction", "spatial", "bureauCode")),
        "declared_license": declared_license,
        "declared_rights": rights_url or _first_text(dataset, ("rights",)),
        "terms_url": terms_url,
        "rights_url": rights_url,
        "dataset_url": dataset_url,
        "distribution_urls": distribution_urls,
        "api_docs_url": api_docs_url,
        "source_class_guess": "public_catalog",
        "authority_class_guess": authority_guess,
        "domain_guess": domain_guess,
        "claim_class_guess": _claim_class_guess(raw_keywords),
        "redistribution_guess": redistribution_guess,
        "review_required": True,
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
        "candidate_score": _candidate_score(authority_guess, redistribution_guess, dataset_url, distribution_urls, terms_url, declared_license),
        "blocking_reasons": blocking_reasons,
        "evidence_hash": stable_hash(dataset),
        "non_claims": [
            "catalog candidate source record only",
            "catalog metadata is not claim authority",
            "not redistribution approval",
            "not pack output",
            "human source-lane and terms review required before use",
        ],
    }
    return candidate


def _candidate_blocking_reasons(declared_license: str, terms_url: str, rights_url: str) -> list[str]:
    reasons = {
        "review_required",
        "catalog_metadata_not_claim_authority",
        "source_lane_review_required",
        "legal_terms_review_required",
        "pack_output_blocked_until_review",
        "candidate_score_cannot_override_review",
    }
    if not declared_license:
        reasons.add("missing_declared_license")
    if not terms_url:
        reasons.add("missing_terms_url")
    if not rights_url:
        reasons.add("missing_rights_url")
    return sorted(reasons)


def _candidate_score(authority_guess: str, redistribution_guess: str, dataset_url: str, distribution_urls: list[str], terms_url: str, declared_license: str) -> int:
    score = 10
    if authority_guess in {"official_government", "official_institution", "standards_body", "regulated_body"}:
        score += 25
    if dataset_url:
        score += 10
    if distribution_urls:
        score += 10
    if terms_url:
        score += 10
    if declared_license:
        score += 10
    if redistribution_guess in {"clearly_open", "open_with_attribution"}:
        score += 10
    if redistribution_guess in {"restricted", "blocked"}:
        score -= 20
    return max(score, 0)


def _first_text(container: dict[str, Any], keys: tuple[str, ...]) -> str:
    for key in keys:
        value = container.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
        if isinstance(value, list) and value:
            text_items = [str(item) for item in value if isinstance(item, (str, int, float))]
            if text_items:
                return ", ".join(text_items)
        if isinstance(value, dict):
            for nested_key in ("name", "@id", "url"):
                nested = value.get(nested_key)
                if isinstance(nested, str) and nested.strip():
                    return nested.strip()
    return ""


def _publisher(dataset: dict[str, Any]) -> tuple[str, str]:
    publisher = dataset.get("publisher")
    if isinstance(publisher, str):
        return publisher, ""
    if isinstance(publisher, dict):
        return _first_text(publisher, ("name", "title")), _first_text(publisher, ("url", "@id", "homepage"))
    organization = dataset.get("organization")
    if isinstance(organization, dict):
        return _first_text(organization, ("title", "name")), _first_text(organization, ("url", "homepage"))
    return "", ""


def _license(dataset: dict[str, Any]) -> str:
    value = dataset.get("license") or dataset.get("license_id") or dataset.get("license_title")
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        return _first_text(value, ("name", "url", "@id"))
    return ""


def _distribution_urls(dataset: dict[str, Any]) -> list[str]:
    distributions = dataset.get("distribution") or dataset.get("resources") or []
    if isinstance(distributions, dict):
        distributions = [distributions]
    urls: list[str] = []
    if isinstance(distributions, list):
        for distribution in distributions:
            if not isinstance(distribution, dict):
                continue
            for key in ("accessURL", "downloadURL", "contentUrl", "url"):
                value = distribution.get(key)
                if isinstance(value, str) and value.strip():
                    urls.append(value.strip())
    return sorted(set(urls))


def _api_docs_url(dataset: dict[str, Any]) -> str:
    distributions = dataset.get("distribution", [])
    if isinstance(distributions, list):
        for distribution in distributions:
            if isinstance(distribution, dict):
                value = distribution.get("describedBy") or distribution.get("apiDocumentation")
                if isinstance(value, str) and value.strip():
                    return value.strip()
    return _first_text(dataset, ("api_docs_url", "apiDocsURL"))


def _keywords(dataset: dict[str, Any]) -> list[str]:
    keywords = dataset.get("keyword") or dataset.get("tags") or dataset.get("keywords") or []
    if isinstance(keywords, str):
        return [part.strip() for part in re.split(r"[,;]", keywords) if part.strip()]
    if isinstance(keywords, list):
        output: list[str] = []
        for keyword in keywords:
            if isinstance(keyword, str):
                output.append(keyword)
            elif isinstance(keyword, dict):
                value = keyword.get("name") or keyword.get("display_name")
                if isinstance(value, str):
                    output.append(value)
        return sorted(set(output))
    return []


def _domain_guess(title: str, publisher_name: str, keywords: list[str]) -> str:
    haystack = " ".join([title, publisher_name, *keywords]).lower()
    for domain, needles in DOMAIN_KEYWORDS.items():
        if any(needle in haystack for needle in needles):
            return domain
    return "unclassified_public_reference"


def _claim_class_guess(keywords: list[str]) -> list[str]:
    values = {keyword.lower().replace(" ", "_") + "_reference" for keyword in keywords[:4]}
    return sorted(values) or ["public_reference_metadata"]


def _authority_guess(publisher_name: str, publisher_url: str) -> str:
    haystack = f"{publisher_name} {publisher_url}".lower()
    if ".gov" in haystack or "government" in haystack or "department" in haystack:
        return "official_government"
    if ".edu" in haystack or "university" in haystack or "institute" in haystack:
        return "official_institution"
    return "public_catalog"


def _redistribution_guess(license_value: str, rights_url: str) -> str:
    lowered = f"{license_value} {rights_url}".lower()
    if "cc0" in lowered or "public domain" in lowered:
        return "clearly_open"
    if "creative commons" in lowered or "cc-by" in lowered or "attribution" in lowered:
        return "open_with_attribution"
    if "restricted" in lowered:
        return "restricted"
    return "unclear"


def _validated_choice(value: str, allowed: set[str], fallback: str) -> str:
    return value if value in allowed else fallback


def _schema_type_contains(payload: dict[str, Any], expected: str) -> bool:
    raw_type = payload.get("@type")
    if isinstance(raw_type, str):
        return expected.lower() in raw_type.lower()
    if isinstance(raw_type, list):
        return any(isinstance(item, str) and expected.lower() in item.lower() for item in raw_type)
    return False


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_forbidden_output_marker(item) for item in value.values())
    return False
