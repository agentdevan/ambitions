#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"
SOURCE_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.json"

OUT_MD = ROOT / "docs/ops/canon-collapse/remaining-canon-collapse-resolution.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/remaining-canon-collapse-resolution.json"

OWNER = "CANON-COLLAPSE-002"
LINEAR_ISSUE = "AMB-290"

DISPOSITION_BY_CONFLICT_TYPE = {
    "duplicate_stable_id": {
        "class": "merge-overlap",
        "disposition": "merge-or-sequence-authority",
        "status": "bounded-future-bundle",
        "meaning": "Duplicate stable IDs need survivor/namespace decisions before execution authority is clean.",
        "next_action": "Handle through one future merge/sequencing bundle using the candidate IDs preserved here.",
    },
    "same_source_file_targeted_by_multiple_active_batches": {
        "class": "merge-overlap",
        "disposition": "merge-or-sequence-file-ownership",
        "status": "bounded-future-bundle",
        "meaning": "Multiple active items target the same source file; this must become explicit sequence ownership before source work depends on it.",
        "next_action": "Handle through one future merge/sequencing bundle.",
    },
    "same_surface_multiple_active_batches": {
        "class": "merge-overlap",
        "disposition": "merge-or-sequence-surface-ownership",
        "status": "bounded-future-bundle",
        "meaning": "Multiple active items target the same surface; this needs owner/sequence resolution before implementation.",
        "next_action": "Handle through one future merge/sequencing bundle.",
    },
    "missing_source_of_truth_reference": {
        "class": "authority-rewrite",
        "disposition": "rewrite-authority-reference",
        "status": "bounded-future-bundle",
        "meaning": "Candidate lacks exact source-of-truth authority and cannot be used as implementation authority until rewritten.",
        "next_action": "Handle through one future authority-rewrite bundle.",
    },
    "retired_ia_or_terminology_reference": {
        "class": "terminology-quarantine",
        "disposition": "quarantine-or-rewrite-terminology",
        "status": "bounded-future-bundle",
        "meaning": "Candidate contains retired terminology residue but is no longer Red; keep visible for bounded rewrite/quarantine.",
        "next_action": "Handle through one future terminology quarantine/rewrite bundle.",
    },
    "stale_or_unknown_active_status": {
        "class": "status-expedite",
        "disposition": "clarify-status-before-use",
        "status": "bounded-future-bundle",
        "meaning": "Candidate has stale or unknown active status and must not drive implementation until clarified.",
        "next_action": "Handle through one future status clarification bundle.",
    },
}

EXPECTED_CONFLICT_TYPES = set(DISPOSITION_BY_CONFLICT_TYPE.keys())


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"missing {rel(path)}")
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"empty {rel(path)}")
    return json.loads(text)


def disposition_record(candidate: dict[str, Any]) -> dict[str, Any]:
    conflict_type = candidate.get("conflict_type", "unknown")
    rule = DISPOSITION_BY_CONFLICT_TYPE.get(
        conflict_type,
        {
            "class": "manual-triage",
            "disposition": "manual-triage",
            "status": "bounded-future-bundle",
            "meaning": "Candidate requires owner triage because the conflict type was not expected in AMB-290.",
            "next_action": "Handle through a future manual triage bundle.",
        },
    )

    involved = candidate.get("involved") or []
    repo_paths = sorted(
        {
            item.get("repo_path", "unknown")
            for item in involved
            if item.get("repo_path")
        }
    )

    stable_ids = sorted(
        {
            item.get("stable_id", "unknown")
            for item in involved
            if item.get("stable_id")
        }
    )

    return {
        "candidate_id": candidate.get("conflict_id", "unknown"),
        "title": candidate.get("title", "unknown"),
        "conflict_type": conflict_type,
        "severity": candidate.get("severity", "unknown"),
        "recommended_action_before_resolution": candidate.get("recommended_action", "unknown"),
        "resolution_class": rule["class"],
        "disposition": rule["disposition"],
        "disposition_status": rule["status"],
        "disposition_meaning": rule["meaning"],
        "next_action": rule["next_action"],
        "repo_paths": repo_paths,
        "stable_ids": stable_ids,
        "involved": involved,
        "evidence_type": candidate.get("evidence_type", conflict_type),
        "linear_issue_ready_before_resolution": candidate.get("linear_issue_ready", False),
        "auto_resolved": False,
        "non_claim": "This disposition resolves a canon-collapse blocker; it does not prove implementation or completion.",
    }


def future_bundle_records(dispositions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    grouped: dict[str, list[dict[str, Any]]] = {}
    for item in dispositions:
        grouped.setdefault(item["resolution_class"], []).append(item)

    order = {
        "merge-overlap": 0,
        "authority-rewrite": 1,
        "terminology-quarantine": 2,
        "status-expedite": 3,
        "manual-triage": 4,
    }

    bundles = []
    for resolution_class, items in sorted(grouped.items(), key=lambda pair: order.get(pair[0], 99)):
        repo_paths = sorted({path for item in items for path in item.get("repo_paths", [])})
        stable_ids = sorted({sid for item in items for sid in item.get("stable_ids", [])})
        conflict_types = dict(sorted(Counter(item["conflict_type"] for item in items).items()))

        if resolution_class == "merge-overlap":
            title = "Merge or sequence overlapping active work ownership"
            action = "Merge"
            reason = "Overlapping active authority is now explicitly deferred into a bounded merge/sequencing bundle."
        elif resolution_class == "authority-rewrite":
            title = "Rewrite missing source-of-truth authority references"
            action = "Rewrite"
            reason = "Missing authority references are now explicitly deferred into a bounded authority rewrite bundle."
        elif resolution_class == "terminology-quarantine":
            title = "Quarantine or rewrite retired terminology residue"
            action = "Rewrite"
            reason = "Retired terminology residue is now explicitly deferred into a bounded terminology cleanup bundle."
        elif resolution_class == "status-expedite":
            title = "Clarify stale or unknown active status"
            action = "Expedite"
            reason = "Unknown/stale active statuses are now explicitly deferred into a bounded status clarification bundle."
        else:
            title = "Manual triage remainder"
            action = "Expedite"
            reason = "Unexpected evidence requires a bounded owner triage bundle."

        bundles.append(
            {
                "bundle_id": f"canon-collapse-{resolution_class}-bundle",
                "title": title,
                "recommended_action": action,
                "reason": reason,
                "candidate_count": len(items),
                "candidate_ids": [item["candidate_id"] for item in items],
                "repo_paths": repo_paths,
                "stable_ids": stable_ids,
                "conflict_types": conflict_types,
                "status": "bounded-future-bundle",
            }
        )

    return bundles


def write_markdown(payload: dict[str, Any]) -> None:
    summary = payload["summary"]

    lines = [
        "# Remaining Canon-Collapse Resolution",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Purpose",
        "",
        "This artifact resolves all remaining active canon-collapse Yellow candidates into explicit repo-owned dispositions.",
        "",
        "It clears these records as active canon-collapse blockers without claiming the underlying work is implemented, proven, deleted, archived, or complete.",
        "",
        "## Summary",
        "",
        f"- Total candidates resolved: {summary['total_candidates']}",
        f"- Candidate accounting complete: {summary['candidate_accounting_complete']}",
        f"- Future bounded bundles: {summary['future_bundle_count']}",
        f"- Auto-resolved candidates: {summary['auto_resolved_count']}",
        "",
        "### Resolved by conflict type",
        "",
    ]

    for key, value in summary["by_conflict_type"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "### Resolved by disposition", ""])

    for key, value in summary["by_disposition"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "## Future bounded bundles", ""])

    for bundle in payload["future_bundles"]:
        lines.append(f"### {bundle['title']}")
        lines.append("")
        lines.append(f"- Bundle ID: {bundle['bundle_id']}")
        lines.append(f"- Recommended action: {bundle['recommended_action']}")
        lines.append(f"- Candidate count: {bundle['candidate_count']}")
        lines.append(f"- Reason: {bundle['reason']}")
        lines.append(f"- Status: {bundle['status']}")
        lines.append("")

    lines.extend(["", "## Disposition rules", ""])

    for conflict_type, rule in DISPOSITION_BY_CONFLICT_TYPE.items():
        lines.append(f"### {conflict_type}")
        lines.append(f"- Resolution class: {rule['class']}")
        lines.append(f"- Disposition: {rule['disposition']}")
        lines.append(f"- Status: {rule['status']}")
        lines.append(f"- Meaning: {rule['meaning']}")
        lines.append(f"- Next action: {rule['next_action']}")
        lines.append("")

    lines.extend(["", "## Resolved candidates", ""])

    for item in payload["dispositions"][:1600]:
        lines.append(f"- {item['candidate_id']} — {item['conflict_type']} — {item['disposition']}")
        if item["repo_paths"]:
            lines.append(f"  - First path: {item['repo_paths'][0]}")
        lines.append(f"  - Next action: {item['next_action']}")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def validate(payload: dict[str, Any], source_candidates: list[dict[str, Any]]) -> list[str]:
    errors = []

    if not source_candidates:
        errors.append("no source candidates found; AMB-290 expected remaining active candidates")

    source_ids = [item.get("conflict_id", "unknown") for item in source_candidates]
    resolved_ids = [item["candidate_id"] for item in payload["dispositions"]]

    if set(source_ids) != set(resolved_ids):
        errors.append("candidate ID set mismatch")

    if len(source_ids) != len(resolved_ids):
        errors.append(f"candidate count mismatch: source={len(source_ids)} resolved={len(resolved_ids)}")

    if len(resolved_ids) != len(set(resolved_ids)):
        errors.append("duplicate resolved IDs found")

    unexpected = sorted(
        {
            item.get("conflict_type", "unknown")
            for item in source_candidates
            if item.get("conflict_type", "unknown") not in EXPECTED_CONFLICT_TYPES
        }
    )
    if unexpected:
        errors.append(f"unexpected conflict types present: {unexpected}")

    if payload["summary"]["auto_resolved_count"] != 0:
        errors.append("auto-resolved count must remain zero")

    for path in [OUT_MD, OUT_JSON]:
        if not path.exists():
            errors.append(f"missing output artifact: {rel(path)}")

    return errors


def main() -> int:
    candidates_payload = load_json(CANDIDATES_JSON)
    source_candidates = candidates_payload.get("active_candidates", [])

    dispositions = [disposition_record(candidate) for candidate in source_candidates]
    future_bundles = future_bundle_records(dispositions)

    summary = {
        "total_candidates": len(dispositions),
        "candidate_accounting_complete": len(dispositions) == len(source_candidates),
        "future_bundle_count": len(future_bundles),
        "auto_resolved_count": sum(1 for item in dispositions if item.get("auto_resolved")),
        "by_conflict_type": dict(sorted(Counter(item["conflict_type"] for item in dispositions).items())),
        "by_disposition": dict(sorted(Counter(item["disposition"] for item in dispositions).items())),
        "by_resolution_class": dict(sorted(Counter(item["resolution_class"] for item in dispositions).items())),
    }

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": "GREEN",
        "resolution_scope": "remaining-active-canon-collapse-candidates",
        "source_report": "docs/ops/canon-collapse/active-canon-collapse-candidates.json",
        "summary": summary,
        "future_bundles": future_bundles,
        "dispositions": dispositions,
        "resolved_conflict_ids": sorted({item["candidate_id"] for item in dispositions}),
        "non_claims": [
            "This resolution does not modify source code.",
            "This resolution does not modify product truth.",
            "This resolution does not delete or archive files.",
            "This resolution does not prove implementation.",
            "This resolution does not prove build success.",
            "This resolution does not prove test success.",
            "This resolution does not prove accessibility validation.",
            "This resolution does not prove performance validation.",
            "This resolution does not prove device validation.",
            "This resolution does not prove privacy/legal approval.",
            "This resolution does not prove TestFlight readiness.",
            "This resolution does not prove App Store readiness.",
            "This resolution does not prove release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_markdown(payload)

    errors = validate(payload, source_candidates)
    if errors:
        payload["status"] = "RED"
        payload["validation_errors"] = errors
        OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        write_markdown(payload)
        print("AMB-290 remaining canon-collapse resolution failed.")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"wrote {rel(OUT_MD)}")
    print(f"wrote {rel(OUT_JSON)}")
    print("status: GREEN")
    print(f"total_candidates: {summary['total_candidates']}")
    print(f"future_bundle_count: {summary['future_bundle_count']}")
    print("AMB-290 remaining canon-collapse resolution passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
