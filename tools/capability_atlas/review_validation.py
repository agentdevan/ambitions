from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path
from typing import Any

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]

CAPABILITIES_ROOT = Path("docs/capabilities")
TAXONOMY_PATH = CAPABILITIES_ROOT / "capability-taxonomy.json"
RECONCILIATION_PATH = CAPABILITIES_ROOT / "reconciliation-register.json"
ATLAS_PATH = CAPABILITIES_ROOT / "draft-capability-atlas.json"
TRACEABILITY_PATH = CAPABILITIES_ROOT / "draft-capability-traceability.json"
GAPS_PATH = CAPABILITIES_ROOT / "draft-capability-gaps.json"
OWNER_DECISIONS_PATH = CAPABILITIES_ROOT / "owner-decisions.json"
VALIDATION_PATH = CAPABILITIES_ROOT / "review-validation.json"

REQUIRED_MARKDOWN_PATHS = (
    CAPABILITIES_ROOT / "CAPABILITY_RECONCILIATION.md",
    CAPABILITIES_ROOT / "DRAFT_CAPABILITY_ATLAS.md",
    CAPABILITIES_ROOT / "DRAFT_CAPABILITY_TRACEABILITY.md",
    CAPABILITIES_ROOT / "DRAFT_CAPABILITY_GAP_REPORT.md",
    CAPABILITIES_ROOT / "OWNER_DECISION_PACKET.md",
)

REQUIRED_CAPABILITY_FIELDS = (
    "capability_id",
    "name",
    "primary_domain_id",
    "secondary_domain_ids",
    "source_candidate_ids",
    "product_promise",
    "user_outcome",
    "why_it_exists",
    "example_experience",
    "non_goals",
    "required_context",
    "privacy_and_data",
    "user_controls",
    "supporting_canon_sources",
    "supporting_systems",
    "unresolved_decision_ids",
    "authority_status",
    "specification_maturity",
    "implementation_status",
    "verification_status",
)

ALLOWED_GAP_SEVERITIES = {"blocker", "high", "medium", "low"}
ALLOWED_GAP_STATES = {
    "missing",
    "partial",
    "unverified",
    "deferred",
    "prohibited",
    "not_applicable",
}


def load_json(root: Path, relative_path: Path) -> dict[str, Any]:
    path = root / relative_path
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ValueError(f"missing required file: {relative_path}") from exc
    except json.JSONDecodeError as exc:
        raise ValueError(f"invalid JSON in {relative_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError(f"top-level JSON must be an object: {relative_path}")
    return payload


def duplicates(values: list[str]) -> list[str]:
    counts = Counter(values)
    return sorted(value for value, count in counts.items() if count > 1)


def canonical_json(payload: dict[str, Any]) -> str:
    return json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def build_validation(root: Path) -> dict[str, Any]:
    errors: list[str] = []

    try:
        taxonomy = load_json(root, TAXONOMY_PATH)
        reconciliation = load_json(root, RECONCILIATION_PATH)
        atlas = load_json(root, ATLAS_PATH)
        traceability = load_json(root, TRACEABILITY_PATH)
        gaps = load_json(root, GAPS_PATH)
        owner_decisions = load_json(root, OWNER_DECISIONS_PATH)
    except ValueError as exc:
        return {
            "authority": "non_normative_capability_review_validation",
            "errors": [str(exc)],
            "is_valid": False,
            "repository": "agentdevan/ambitions",
            "schema_version": 1,
            "summary": {},
        }

    for relative_path in REQUIRED_MARKDOWN_PATHS:
        if not (root / relative_path).is_file():
            errors.append(f"missing readable projection: {relative_path}")

    taxonomy_domains = {
        item.get("domain_id")
        for item in taxonomy.get("domains", [])
        if isinstance(item, dict) and isinstance(item.get("domain_id"), str)
    }
    taxonomy_candidate_ids = [
        item.get("candidate_id")
        for item in taxonomy.get("assignments", [])
        if isinstance(item, dict) and isinstance(item.get("candidate_id"), str)
    ]

    groups = reconciliation.get("capability_groups", [])
    atlas_capabilities = atlas.get("capabilities", [])
    traceability_capabilities = traceability.get("capabilities", [])
    capability_gap_records = gaps.get("capability_gaps", [])
    decisions = owner_decisions.get("decisions", [])

    if not all(isinstance(items, list) for items in (
        groups,
        atlas_capabilities,
        traceability_capabilities,
        capability_gap_records,
        decisions,
    )):
        errors.append("one or more review collections are not arrays")
        groups = groups if isinstance(groups, list) else []
        atlas_capabilities = atlas_capabilities if isinstance(atlas_capabilities, list) else []
        traceability_capabilities = traceability_capabilities if isinstance(traceability_capabilities, list) else []
        capability_gap_records = capability_gap_records if isinstance(capability_gap_records, list) else []
        decisions = decisions if isinstance(decisions, list) else []

    group_ids = [
        item.get("proposed_capability_id")
        for item in groups
        if isinstance(item, dict) and isinstance(item.get("proposed_capability_id"), str)
    ]
    atlas_ids = [
        item.get("capability_id")
        for item in atlas_capabilities
        if isinstance(item, dict) and isinstance(item.get("capability_id"), str)
    ]
    trace_ids = [
        item.get("capability_id")
        for item in traceability_capabilities
        if isinstance(item, dict) and isinstance(item.get("capability_id"), str)
    ]
    gap_capability_ids = [
        item.get("capability_id")
        for item in capability_gap_records
        if isinstance(item, dict) and isinstance(item.get("capability_id"), str)
    ]
    decision_ids = [
        item.get("decision_id")
        for item in decisions
        if isinstance(item, dict) and isinstance(item.get("decision_id"), str)
    ]

    for label, values in (
        ("reconciliation capability IDs", group_ids),
        ("atlas capability IDs", atlas_ids),
        ("traceability capability IDs", trace_ids),
        ("gap capability IDs", gap_capability_ids),
        ("owner decision IDs", decision_ids),
        ("taxonomy candidate IDs", taxonomy_candidate_ids),
    ):
        duplicate_values = duplicates(values)
        if duplicate_values:
            errors.append(f"duplicate {label}: {', '.join(duplicate_values)}")

    canonical_ids = sorted(group_ids)
    for label, values in (
        ("atlas", atlas_ids),
        ("traceability", trace_ids),
        ("gap", gap_capability_ids),
    ):
        if sorted(values) != canonical_ids:
            missing = sorted(set(canonical_ids) - set(values))
            extra = sorted(set(values) - set(canonical_ids))
            if missing:
                errors.append(f"{label} missing capability IDs: {', '.join(missing)}")
            if extra:
                errors.append(f"{label} has unknown capability IDs: {', '.join(extra)}")

    expected_candidate_ids = set(
        reconciliation.get("candidate_coverage", {}).get(
            "expected_qualified_candidate_ids", []
        )
    )
    covered_candidate_ids = set(
        reconciliation.get("candidate_coverage", {}).get("covered_candidate_ids", [])
    )
    disposed_candidate_ids: list[str] = []
    unresolved_decision_ids: set[str] = set()

    for group in groups:
        if not isinstance(group, dict):
            errors.append("reconciliation group must be an object")
            continue
        primary_domain_id = group.get("primary_domain_id")
        if primary_domain_id not in taxonomy_domains:
            errors.append(
                f"unknown reconciliation primary domain {primary_domain_id!r} for "
                f"{group.get('proposed_capability_id')}"
            )
        for secondary_domain_id in group.get("secondary_domain_ids", []):
            if secondary_domain_id not in taxonomy_domains:
                errors.append(
                    f"unknown reconciliation secondary domain {secondary_domain_id!r} for "
                    f"{group.get('proposed_capability_id')}"
                )
        for source in group.get("source_candidates", []):
            if isinstance(source, dict) and isinstance(source.get("candidate_id"), str):
                disposed_candidate_ids.append(source["candidate_id"])
        for decision in group.get("owner_decisions", []):
            if isinstance(decision, dict) and isinstance(decision.get("decision_id"), str):
                unresolved_decision_ids.add(decision["decision_id"])

    if expected_candidate_ids != covered_candidate_ids:
        errors.append("reconciliation expected and covered candidate sets differ")
    if set(disposed_candidate_ids) != expected_candidate_ids:
        missing = sorted(expected_candidate_ids - set(disposed_candidate_ids))
        extra = sorted(set(disposed_candidate_ids) - expected_candidate_ids)
        if missing:
            errors.append(f"candidate dispositions missing: {', '.join(missing)}")
        if extra:
            errors.append(f"candidate dispositions include unknown IDs: {', '.join(extra)}")
    duplicate_dispositions = duplicates(disposed_candidate_ids)
    if duplicate_dispositions:
        errors.append(
            "candidates disposed more than once: " + ", ".join(duplicate_dispositions)
        )
    if expected_candidate_ids != set(taxonomy_candidate_ids):
        errors.append("reconciliation candidate set differs from taxonomy assignment set")

    atlas_by_id = {
        item.get("capability_id"): item
        for item in atlas_capabilities
        if isinstance(item, dict) and isinstance(item.get("capability_id"), str)
    }
    for capability_id, capability in atlas_by_id.items():
        for field in REQUIRED_CAPABILITY_FIELDS:
            if field not in capability:
                errors.append(f"{capability_id} missing atlas field: {field}")
        if capability.get("authority_status") != "proposed":
            errors.append(f"{capability_id} authority_status must remain proposed")
        if capability.get("implementation_status") != "not_assessed":
            errors.append(
                f"{capability_id} implementation_status must remain not_assessed"
            )
        if capability.get("verification_status") != "not_assessed":
            errors.append(
                f"{capability_id} verification_status must remain not_assessed"
            )
        if capability.get("primary_domain_id") not in taxonomy_domains:
            errors.append(f"{capability_id} has unknown primary domain")
        for secondary_domain_id in capability.get("secondary_domain_ids", []):
            if secondary_domain_id not in taxonomy_domains:
                errors.append(
                    f"{capability_id} has unknown secondary domain: {secondary_domain_id}"
                )
        for source_path in capability.get("supporting_canon_sources", []):
            if not (root / source_path).is_file():
                errors.append(
                    f"{capability_id} supporting canon source does not exist: {source_path}"
                )
        unresolved_decision_ids.update(capability.get("unresolved_decision_ids", []))

    for record in traceability_capabilities:
        if not isinstance(record, dict):
            errors.append("traceability record must be an object")
            continue
        capability_id = record.get("capability_id")
        specifications = record.get("specifications", [])
        if not specifications:
            errors.append(f"{capability_id} has no traceability specifications")
        for specification in specifications:
            if not isinstance(specification, dict):
                errors.append(f"{capability_id} specification link must be an object")
                continue
            source_path = specification.get("path")
            if not isinstance(source_path, str) or not (root / source_path).is_file():
                errors.append(
                    f"{capability_id} traceability source does not exist: {source_path}"
                )
        for evidence_kind in ("runtime_evidence", "tests_and_proof"):
            for evidence in record.get(evidence_kind, []):
                if not isinstance(evidence, dict):
                    errors.append(
                        f"{capability_id} {evidence_kind} entry must be an object"
                    )
                    continue
                evidence_path = evidence.get("path")
                if not isinstance(evidence_path, str) or not (root / evidence_path).exists():
                    errors.append(
                        f"{capability_id} evidence path does not exist: {evidence_path}"
                    )
                if not evidence.get("claim_ceiling"):
                    errors.append(
                        f"{capability_id} evidence entry lacks claim_ceiling: {evidence_path}"
                    )
        assessment = record.get("implementation_assessment")
        if not isinstance(assessment, dict) or not assessment.get("status") or not assessment.get("rationale"):
            errors.append(f"{capability_id} lacks implementation assessment")

    gap_ids: list[str] = []
    portfolio_gaps = gaps.get("portfolio_gaps", [])
    for gap in [*portfolio_gaps, *[
        child
        for record in capability_gap_records
        if isinstance(record, dict)
        for child in record.get("gaps", [])
    ]]:
        if not isinstance(gap, dict):
            errors.append("gap entry must be an object")
            continue
        gap_id = gap.get("gap_id")
        if isinstance(gap_id, str):
            gap_ids.append(gap_id)
        else:
            errors.append("gap entry missing gap_id")
        if gap.get("severity") not in ALLOWED_GAP_SEVERITIES:
            errors.append(f"{gap_id} has invalid severity: {gap.get('severity')}")
        if gap.get("state") not in ALLOWED_GAP_STATES:
            errors.append(f"{gap_id} has invalid state: {gap.get('state')}")
        if not gap.get("summary") or not gap.get("closeout"):
            errors.append(f"{gap_id} lacks summary or closeout")
    duplicate_gap_ids = duplicates(gap_ids)
    if duplicate_gap_ids:
        errors.append("duplicate gap IDs: " + ", ".join(duplicate_gap_ids))

    required_decision_ids = unresolved_decision_ids | {"DEC-ATLAS-IDENTITIES-001"}
    available_decision_ids = set(decision_ids)
    missing_decisions = sorted(required_decision_ids - available_decision_ids)
    if missing_decisions:
        errors.append(
            "owner packet missing decision IDs: " + ", ".join(missing_decisions)
        )
    for decision in decisions:
        if not isinstance(decision, dict):
            errors.append("owner decision must be an object")
            continue
        option_ids = [
            option.get("option_id")
            for option in decision.get("options", [])
            if isinstance(option, dict) and isinstance(option.get("option_id"), str)
        ]
        if not option_ids:
            errors.append(f"{decision.get('decision_id')} has no options")
        if decision.get("recommended_option_id") not in option_ids:
            errors.append(
                f"{decision.get('decision_id')} recommended option is not declared"
            )
        if decision.get("status") != "pending" or decision.get("selected_option_id") is not None:
            errors.append(
                f"{decision.get('decision_id')} must remain pending and unselected"
            )

    summary = {
        "atlas_capability_count": len(atlas_ids),
        "gap_capability_record_count": len(gap_capability_ids),
        "gap_count": len(gap_ids),
        "owner_decision_count": len(decision_ids),
        "qualified_candidate_count": len(expected_candidate_ids),
        "reconciliation_group_count": len(group_ids),
        "taxonomy_domain_count": len(taxonomy_domains),
        "traceability_record_count": len(trace_ids),
        "unresolved_scope_decision_count": len(unresolved_decision_ids),
    }

    return {
        "authority": "non_normative_capability_review_validation",
        "coverage": {
            "atlas_capability_ids": sorted(atlas_ids),
            "candidate_ids": sorted(expected_candidate_ids),
            "gap_capability_ids": sorted(gap_capability_ids),
            "owner_decision_ids": sorted(decision_ids),
            "reconciliation_capability_ids": sorted(group_ids),
            "traceability_capability_ids": sorted(trace_ids),
        },
        "errors": sorted(errors),
        "is_valid": not errors,
        "repository": "agentdevan/ambitions",
        "schema_version": 1,
        "summary": summary,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("build", "check"), nargs="?", default="check")
    args = parser.parse_args(argv)

    validation = build_validation(REPOSITORY_ROOT)
    rendered = canonical_json(validation)
    validation_path = REPOSITORY_ROOT / VALIDATION_PATH

    if args.command == "build":
        validation_path.write_text(rendered, encoding="utf-8")
    else:
        try:
            existing = validation_path.read_text(encoding="utf-8")
        except FileNotFoundError:
            print(f"CAPABILITY_REVIEW_DRIFT missing {VALIDATION_PATH}", file=sys.stderr)
            return 1
        if existing != rendered:
            print(f"CAPABILITY_REVIEW_DRIFT {VALIDATION_PATH}", file=sys.stderr)
            return 1

    if validation["errors"]:
        for error in validation["errors"]:
            print(f"CAPABILITY_REVIEW_ERROR {error}", file=sys.stderr)
        return 1

    print(
        "Capability review valid: "
        f"{validation['summary']['atlas_capability_count']} capabilities, "
        f"{validation['summary']['qualified_candidate_count']} candidates, "
        f"{validation['summary']['gap_count']} gaps, "
        f"{validation['summary']['owner_decision_count']} owner decisions."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
