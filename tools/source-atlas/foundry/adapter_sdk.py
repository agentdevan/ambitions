"""Source Atlas public-reference adapter SDK.

The SDK is intentionally small and deterministic. Adapters own source discovery,
fetch/fixture selection, normalization, terms validation, provenance, coverage,
fixture, and pack-candidate emission. Policy gates live here so no adapter can
declare packable output without registry-backed distribution permission.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any

from .boundary import FORBIDDEN_DATA_CLASSES, boundary_issue_strings, boundary_issues_for_value
from .model import PRIVACY_BOUNDARY, stable_hash, utc_now, write_json


ADAPTER_SDK_VERSION = "source-atlas-adapter-sdk-v1"


class DistributionPolicy(str, Enum):
    REDISTRIBUTABLE = "redistributable"
    REDISTRIBUTABLE_WITH_ATTRIBUTION = "redistributable_with_attribution"
    METADATA_ONLY = "metadata_only"
    LOOKUP_ONLY_NOT_PACKABLE = "lookup_only_not_packable"
    REVIEW_REQUIRED = "review_required"
    BLOCKED = "blocked"


class R2PackPolicy(str, Enum):
    R2_PACK_ALLOWED = "r2_pack_allowed"
    R2_METADATA_ONLY = "r2_metadata_only"
    R2_BLOCKED = "r2_blocked"
    R2_REVIEW_REQUIRED = "r2_review_required"


AUTHORITY_TIERS = {
    "official_regulator",
    "official_government",
    "official_dataset",
    "standards_body",
    "educational_institution",
    "open_knowledge_graph",
    "public_reference",
    "derived_crosswalk",
    "unverified",
    "restricted",
}

CONFIDENCE_STATES = {
    "high",
    "medium",
    "low",
    "conflicted",
    "review_required",
    "unsupported",
}

SOURCE_STATES = [
    "current",
    "unavailable",
    "stale",
    "stale-critical",
    "conflicted",
    "revoked",
    "unsupported",
    "malformed",
    "rate-limited",
    "terms-blocked",
    "missing-provenance",
    "private-field-injected",
]


@dataclass(frozen=True)
class AdapterRunContext:
    source_state: str = "current"
    fixture_mode: bool = True
    limit: int = 25
    created_at: str = ""

    def resolved_at(self) -> str:
        return self.created_at or utc_now()


class SourceAdapter(ABC):
    """Required adapter contract.

    Concrete adapters must implement each method with deterministic behavior.
    The base class only supplies common orchestration and output checks.
    """

    source_id: str
    adapter_id: str
    domain: str

    @abstractmethod
    def discover(self, context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def fetch(self, discovered: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def parse(self, fetched: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def normalize(self, parsed: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def validate_terms(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def emit_provenance(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    def emit_coverage(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def emit_fixtures(self, output_root: Path) -> list[dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    def emit_pack_candidates(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        raise NotImplementedError

    def run(self, context: AdapterRunContext) -> dict[str, Any]:
        discovered = self.discover(context)
        fetched = self.fetch(discovered, context)
        parsed = self.parse(fetched, context)
        normalized = self.normalize(parsed, context)
        terms = self.validate_terms(normalized, context)
        provenance = self.emit_provenance(normalized, context)
        normalized["provenance"] = provenance
        normalized["coverage"] = self.emit_coverage(normalized, context)
        normalized["packCandidates"] = self.emit_pack_candidates(normalized, context)
        normalized["termsValidation"] = terms
        normalized["adapterSDKVersion"] = ADAPTER_SDK_VERSION
        normalized["privacyBoundary"] = PRIVACY_BOUNDARY
        return normalized


def validate_distribution_policy(
    entry: dict[str, Any],
    output: dict[str, Any],
    review_evidence: dict[str, Any] | None = None,
    *,
    require_approval_packet: bool = False,
) -> dict[str, Any]:
    """Hard gate before normalized data can enter a Source Atlas pack."""

    issues: list[str] = []
    for field in ["license", "terms_url", "redistribution_policy", "r2_pack_policy"]:
        if not entry.get(field):
            issues.append(f"{entry.get('source_id', '<source>')}: missing {field}")
    if entry.get("attribution_required") not in {True, False}:
        issues.append(f"{entry.get('source_id', '<source>')}: attribution requirement unresolved")

    redistribution = entry.get("redistribution_policy")
    r2_policy = entry.get("r2_pack_policy")
    if redistribution == DistributionPolicy.LOOKUP_ONLY_NOT_PACKABLE.value:
        issues.append(f"{entry.get('source_id')}: lookup_only_not_packable blocks pack output")
    if redistribution == DistributionPolicy.BLOCKED.value:
        issues.append(f"{entry.get('source_id')}: blocked redistribution policy")
    approval_validation: dict[str, Any] | None = None
    if review_evidence or require_approval_packet:
        from .terms_approval_packet import validate_terms_approval_packet

        approval_validation = validate_terms_approval_packet(
            review_evidence,
            terms_entry=entry,
            requested_artifact_classes=artifact_classes(output) or {"public_reference_claim"},
        )
        if not approval_validation["valid"]:
            issues.extend(approval_validation["issues"])
    if redistribution == DistributionPolicy.REVIEW_REQUIRED.value and not review_evidence:
        issues.append(f"{entry.get('source_id')}: review_required without review evidence")
    if r2_policy in {R2PackPolicy.R2_BLOCKED.value, R2PackPolicy.R2_REVIEW_REQUIRED.value}:
        issues.append(f"{entry.get('source_id')}: {r2_policy} blocks R2-ready pack output")

    allowed_classes = set(entry.get("allowed_artifact_classes", []))
    forbidden_classes = set(entry.get("forbidden_artifact_classes", [])) | FORBIDDEN_DATA_CLASSES
    observed_classes = artifact_classes(output)
    forbidden_observed = sorted(observed_classes & forbidden_classes)
    if forbidden_observed:
        issues.append(f"{entry.get('source_id')}: forbidden artifact classes present: {', '.join(forbidden_observed)}")
    unsupported_classes = sorted(observed_classes - allowed_classes) if allowed_classes else []
    unsupported_classes = [item for item in unsupported_classes if item not in {"synthetic_fixture"}]
    if unsupported_classes:
        issues.append(f"{entry.get('source_id')}: artifact classes not allowed by terms registry: {', '.join(unsupported_classes)}")

    boundary_issues = boundary_issue_strings(boundary_issues_for_value(output, entry.get("source_id", "adapter-output")))
    if boundary_issues:
        issues.extend(boundary_issues)

    return {
        "sourceID": entry.get("source_id"),
        "packable": not issues,
        "r2Ready": not issues and r2_policy == R2PackPolicy.R2_PACK_ALLOWED.value,
        "issues": issues,
        "redistributionPolicy": redistribution,
        "r2PackPolicy": r2_policy,
        "approvalPacketValidation": approval_validation,
    }


def artifact_classes(value: Any) -> set[str]:
    classes: set[str] = set()

    def walk(item: Any) -> None:
        if isinstance(item, dict):
            data_class = item.get("dataClass") or item.get("data_class")
            if isinstance(data_class, str):
                classes.add(data_class)
            for child in item.values():
                walk(child)
        elif isinstance(item, list):
            for child in item:
                walk(child)

    walk(value)
    return classes


def output_checksum(value: Any) -> str:
    return stable_hash(value)


def write_fixture(path: Path, payload: dict[str, Any], expected_valid: bool = True, expected_issue_codes: list[str] | None = None) -> dict[str, Any]:
    wrapped = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.adapterFixture.v1",
        "expectedValid": expected_valid,
        "expectedIssueCodes": expected_issue_codes or [],
        "payload": payload,
    }
    write_json(path, wrapped)
    return {
        "path": str(path),
        "sourceID": payload.get("sourceID"),
        "adapterID": payload.get("adapterID"),
        "sourceState": payload.get("sourceState", {}).get("state"),
        "expectedValid": expected_valid,
        "checksum": output_checksum(wrapped),
    }
