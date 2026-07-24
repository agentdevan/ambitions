"""Validation for the non-normative Ambitions capability taxonomy."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

from tools.capability_atlas.classification_pipeline import classify_compilation
from tools.capability_atlas.discover import DiscoveryCompilation
from tools.capability_atlas.model import (
    CapabilityDiscoveryError,
    canonical_json,
    load_json_object,
)


TAXONOMY_PATH = Path("docs/capabilities/capability-taxonomy.json")
TAXONOMY_VALIDATION_PATH = Path("docs/capabilities/taxonomy-validation.json")
REQUIRED_DOMAIN_FIELDS = frozenset(
    {
        "domain_id",
        "name",
        "purpose",
        "owns",
        "does_not_own",
        "anti_overlap_rule",
    }
)
REQUIRED_ASSIGNMENT_FIELDS = frozenset(
    {
        "candidate_id",
        "candidate_name",
        "primary_domain_id",
        "secondary_domain_ids",
        "assignment_rationale",
    }
)


@dataclass(frozen=True, slots=True)
class TaxonomyValidation:
    payload: dict[str, object]
    errors: tuple[str, ...]

    @property
    def is_valid(self) -> bool:
        return not self.errors

    def render(self) -> str:
        return canonical_json(self.payload)

    def require_valid(self) -> None:
        if self.errors:
            raise CapabilityDiscoveryError(
                "taxonomy validation failed: " + "; ".join(self.errors)
            )


def _require_mapping(value: object, label: str) -> Mapping[str, Any]:
    if not isinstance(value, Mapping):
        raise CapabilityDiscoveryError(f"{label} must be an object")
    return value


def _require_list(value: object, label: str) -> Sequence[object]:
    if not isinstance(value, list):
        raise CapabilityDiscoveryError(f"{label} must be a list")
    return value


def _nonempty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def validate_taxonomy(
    repository_root: Path,
    compilation: DiscoveryCompilation,
) -> TaxonomyValidation:
    """Validate taxonomy structure and exact qualified-candidate coverage."""

    path = repository_root / TAXONOMY_PATH
    taxonomy = load_json_object(path)
    classified = classify_compilation(compilation)
    qualified = {
        item.candidate_id: item
        for item in classified.candidates
        if item.qualification_status == "qualified"
    }

    errors: list[str] = []
    domains_payload = _require_list(taxonomy.get("domains"), "domains")
    assignments_payload = _require_list(taxonomy.get("assignments"), "assignments")
    rules = _require_mapping(taxonomy.get("governing_rules"), "governing_rules")

    maximum_secondary = rules.get("maximum_secondary_domains", 3)
    if not isinstance(maximum_secondary, int) or maximum_secondary < 0:
        errors.append("maximum_secondary_domains must be a non-negative integer")
        maximum_secondary = 3

    domain_ids: list[str] = []
    domain_names: list[str] = []
    malformed_domain_indexes: list[int] = []
    for index, raw_domain in enumerate(domains_payload):
        if not isinstance(raw_domain, Mapping):
            malformed_domain_indexes.append(index)
            continue
        missing = REQUIRED_DOMAIN_FIELDS - set(raw_domain)
        if missing:
            errors.append(
                f"domain[{index}] missing fields: {', '.join(sorted(missing))}"
            )
        domain_id = raw_domain.get("domain_id")
        name = raw_domain.get("name")
        if _nonempty_string(domain_id):
            domain_ids.append(str(domain_id))
        else:
            errors.append(f"domain[{index}] has invalid domain_id")
        if _nonempty_string(name):
            domain_names.append(str(name))
        else:
            errors.append(f"domain[{index}] has invalid name")
        for field in ("purpose", "anti_overlap_rule"):
            if not _nonempty_string(raw_domain.get(field)):
                errors.append(f"domain[{index}] has invalid {field}")
        for field in ("owns", "does_not_own"):
            values = raw_domain.get(field)
            if not isinstance(values, list) or not values or not all(
                _nonempty_string(item) for item in values
            ):
                errors.append(f"domain[{index}] has invalid {field}")

    duplicate_domain_ids = sorted(
        item for item, count in Counter(domain_ids).items() if count > 1
    )
    duplicate_domain_names = sorted(
        item for item, count in Counter(domain_names).items() if count > 1
    )
    if duplicate_domain_ids:
        errors.append("duplicate domain ids: " + ", ".join(duplicate_domain_ids))
    if duplicate_domain_names:
        errors.append("duplicate domain names: " + ", ".join(duplicate_domain_names))
    known_domains = set(domain_ids)

    assigned_ids: list[str] = []
    unknown_candidate_ids: list[str] = []
    unknown_domain_ids: set[str] = set()
    over_broad_candidate_ids: list[str] = []
    primary_in_secondary_ids: list[str] = []
    duplicate_secondary_ids: list[str] = []
    malformed_assignment_indexes: list[int] = []

    for index, raw_assignment in enumerate(assignments_payload):
        if not isinstance(raw_assignment, Mapping):
            malformed_assignment_indexes.append(index)
            continue
        missing = REQUIRED_ASSIGNMENT_FIELDS - set(raw_assignment)
        if missing:
            errors.append(
                f"assignment[{index}] missing fields: {', '.join(sorted(missing))}"
            )
        candidate_id = raw_assignment.get("candidate_id")
        candidate_name = raw_assignment.get("candidate_name")
        primary = raw_assignment.get("primary_domain_id")
        secondaries = raw_assignment.get("secondary_domain_ids")
        rationale = raw_assignment.get("assignment_rationale")

        if not _nonempty_string(candidate_id):
            errors.append(f"assignment[{index}] has invalid candidate_id")
            continue
        candidate_id = str(candidate_id)
        assigned_ids.append(candidate_id)
        if candidate_id not in qualified:
            unknown_candidate_ids.append(candidate_id)
        if not _nonempty_string(candidate_name):
            errors.append(f"assignment[{index}] has invalid candidate_name")
        if not _nonempty_string(rationale):
            errors.append(f"assignment[{index}] has invalid assignment_rationale")
        if not _nonempty_string(primary):
            errors.append(f"assignment[{index}] has invalid primary_domain_id")
            primary = ""
        primary = str(primary)
        if primary and primary not in known_domains:
            unknown_domain_ids.add(primary)
        if not isinstance(secondaries, list) or not all(
            _nonempty_string(item) for item in secondaries
        ):
            errors.append(f"assignment[{index}] has invalid secondary_domain_ids")
            secondaries = []
        secondary_ids = [str(item) for item in secondaries]
        unknown_domain_ids.update(
            item for item in secondary_ids if item not in known_domains
        )
        if len(secondary_ids) > maximum_secondary:
            over_broad_candidate_ids.append(candidate_id)
        if primary in secondary_ids:
            primary_in_secondary_ids.append(candidate_id)
        if len(secondary_ids) != len(set(secondary_ids)):
            duplicate_secondary_ids.append(candidate_id)

    duplicate_primary_assignments = sorted(
        item for item, count in Counter(assigned_ids).items() if count > 1
    )
    assigned_set = set(assigned_ids)
    qualified_set = set(qualified)
    unassigned_candidate_ids = sorted(qualified_set - assigned_set)
    unexpected_candidate_ids = sorted(assigned_set - qualified_set)

    if malformed_domain_indexes:
        errors.append(
            "malformed domain indexes: "
            + ", ".join(str(item) for item in malformed_domain_indexes)
        )
    if malformed_assignment_indexes:
        errors.append(
            "malformed assignment indexes: "
            + ", ".join(str(item) for item in malformed_assignment_indexes)
        )
    if duplicate_primary_assignments:
        errors.append(
            "duplicate primary assignments: "
            + ", ".join(duplicate_primary_assignments)
        )
    if unassigned_candidate_ids:
        errors.append(
            "unassigned qualified candidates: " + ", ".join(unassigned_candidate_ids)
        )
    if unexpected_candidate_ids:
        errors.append(
            "unknown candidate assignments: " + ", ".join(unexpected_candidate_ids)
        )
    if unknown_domain_ids:
        errors.append("unknown domain ids: " + ", ".join(sorted(unknown_domain_ids)))
    if over_broad_candidate_ids:
        errors.append(
            "over-broad assignments: " + ", ".join(sorted(over_broad_candidate_ids))
        )
    if primary_in_secondary_ids:
        errors.append(
            "primary repeated as secondary: "
            + ", ".join(sorted(primary_in_secondary_ids))
        )
    if duplicate_secondary_ids:
        errors.append(
            "duplicate secondary domains: "
            + ", ".join(sorted(duplicate_secondary_ids))
        )

    expectations = taxonomy.get("validation_expectations")
    if isinstance(expectations, Mapping):
        expected_qualified = expectations.get("qualified_candidate_count")
        expected_assignments = expectations.get("assignment_count")
        if expected_qualified != len(qualified):
            errors.append(
                f"expected qualified_candidate_count {expected_qualified!r}, got {len(qualified)}"
            )
        if expected_assignments != len(assignments_payload):
            errors.append(
                f"expected assignment_count {expected_assignments!r}, got {len(assignments_payload)}"
            )

    primary_domain_counts = Counter()
    for raw_assignment in assignments_payload:
        if isinstance(raw_assignment, Mapping) and _nonempty_string(
            raw_assignment.get("primary_domain_id")
        ):
            primary_domain_counts[str(raw_assignment["primary_domain_id"])] += 1

    payload: dict[str, object] = {
        "authority": "non_normative_phase_c_taxonomy_validation",
        "baseline_ref": compilation.baseline_ref,
        "errors": sorted(set(errors)),
        "is_valid": not errors,
        "repository": compilation.repository,
        "schema_version": 1,
        "summary": {
            "assignment_count": len(assignments_payload),
            "domain_count": len(domains_payload),
            "qualified_candidate_count": len(qualified),
        },
        "coverage": {
            "duplicate_primary_assignments": duplicate_primary_assignments,
            "duplicate_secondary_candidate_ids": sorted(duplicate_secondary_ids),
            "over_broad_candidate_ids": sorted(over_broad_candidate_ids),
            "primary_repeated_as_secondary_candidate_ids": sorted(
                primary_in_secondary_ids
            ),
            "unassigned_candidate_ids": unassigned_candidate_ids,
            "unknown_candidate_ids": sorted(set(unknown_candidate_ids)),
            "unknown_domain_ids": sorted(unknown_domain_ids),
        },
        "primary_domain_counts": dict(sorted(primary_domain_counts.items())),
        "taxonomy_path": TAXONOMY_PATH.as_posix(),
    }
    return TaxonomyValidation(payload=payload, errors=tuple(sorted(set(errors))))
