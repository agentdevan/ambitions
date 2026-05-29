#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs/ops/batch-ledger/batch-ledger.json"
CONFLICT_JSON = ROOT / "docs/ops/batch-ledger/conflict-report.json"
CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"

OUT_DIR = ROOT / "docs/ops/canon-collapse"
BUNDLE_DIR = OUT_DIR / "bundles"
OUT_MD = OUT_DIR / "source-only-proof-bundles.md"
OUT_JSON = OUT_DIR / "source-only-proof-bundles.json"

LINEAR_ISSUE = "AMB-288"
OWNER = "CANON-COLLAPSE-002"

ACTIVE_ITEM_TYPES = {"batch", "prompt", "train"}
NON_ACTIVE_CURRENT_STATUSES = {"canceled", "retired", "superseded", "historical"}
NON_ACTIVE_IMPLEMENTATION_STATUSES = {"canceled", "retired", "superseded"}

SOURCE_SUFFIXES = (".swift", ".py", ".sh", ".rb", ".m", ".mm", ".h", ".json", ".yml", ".yaml")
SOURCE_PREFIXES = ("Native/", "Sources/", "Tests/", "scripts/", "tools/")

REQUIRED_READ_ORDER = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/conflict-action-workflow.md",
    "docs/ops/canon-collapse/active-canon-collapse-candidates.md",
    "docs/ops/canon-collapse/active-canon-collapse-candidates.json",
    "docs/ops/change-protocol/change-request-template.md",
    "docs/ops/change-protocol/change-impact-check.md",
    "docs/ops/change-protocol/implementation-prompt-template.md",
    "docs/ops/change-protocol/post-implementation-proof-reconciliation.md",
]

BUNDLE_DEFS = {
    "finish-real-source-proof": {
        "title": "Finish proof for source-bound implementation candidates",
        "recommended_disposition": "Finish proof",
        "proof_requirement": "Run or document the narrowest applicable build/test/proof command for items that reference source, test, scripts, or validation commands.",
        "next_action": "Create one proof-finish implementation issue only for candidates that can be proven with current local commands.",
    },
    "merge-overlap-before-proof": {
        "title": "Merge or sequence overlapping candidates before proof",
        "recommended_disposition": "Merge",
        "proof_requirement": "Resolve overlapping batch/source/surface ownership before proof can be trusted.",
        "next_action": "Create one merge/sequencing issue for duplicate or overlapping active work.",
    },
    "rewrite-authority-before-proof": {
        "title": "Rewrite authority references before proof",
        "recommended_disposition": "Rewrite",
        "proof_requirement": "Add exact source-of-truth references or remove stale authority before implementation proof is meaningful.",
        "next_action": "Create one rewrite issue for active prompts/batches missing source-of-truth authority.",
    },
    "retire-or-quarantine-stale-proof-debt": {
        "title": "Retire or quarantine stale proof debt",
        "recommended_disposition": "Retire",
        "proof_requirement": "Do not prove stale or obsolete work; first decide whether it should remain active.",
        "next_action": "Create one retirement/quarantine issue for stale docs, old batch prompts, and audit residue.",
    },
    "keep-planned-proof-later": {
        "title": "Keep planned work planned until selected by sequence",
        "recommended_disposition": "Keep planned",
        "proof_requirement": "No proof required until the item becomes active implementation work.",
        "next_action": "Keep these in planned state and prevent them from blocking source implementation.",
    },
    "manual-triage-remainder": {
        "title": "Manual triage remainder",
        "recommended_disposition": "Expedite",
        "proof_requirement": "Owner decision required because evidence is ambiguous.",
        "next_action": "Create one manual triage issue only if this bucket remains non-empty after the other bundles.",
    },
}


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"missing required artifact: {rel(path)}")
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"empty required artifact: {rel(path)}")
    return json.loads(text)


def active_item(item: dict[str, Any]) -> bool:
    if not item:
        return False
    if item.get("item_type") not in ACTIVE_ITEM_TYPES:
        return False
    if item.get("current_status") in NON_ACTIVE_CURRENT_STATUSES:
        return False
    if item.get("implementation_status") in NON_ACTIVE_IMPLEMENTATION_STATUSES:
        return False
    return True


def ledger_index(ledger: dict[str, Any]) -> dict[tuple[str, str], dict[str, Any]]:
    index = {}
    for item in ledger.get("items", []):
        stable_id = item.get("stable_id", "")
        repo_path = item.get("repo_path", "")
        if stable_id or repo_path:
            index[(stable_id, repo_path)] = item
    return index


def lookup_item(index: dict[tuple[str, str], dict[str, Any]], involved: dict[str, Any]) -> dict[str, Any]:
    sid = involved.get("stable_id", "")
    path = involved.get("repo_path", "")

    exact = index.get((sid, path))
    if exact:
        return exact

    if sid:
        for (stable_id, _), item in index.items():
            if stable_id == sid:
                return item

    if path:
        for (_, repo_path), item in index.items():
            if repo_path == path:
                return item

    return {}


def item_key(item: dict[str, Any]) -> tuple[str, str]:
    return (item.get("stable_id", "unknown"), item.get("repo_path", "unknown"))


def source_bound(item: dict[str, Any]) -> bool:
    touched = item.get("touched_files") or []
    validation = item.get("validation_commands") or []
    proof_paths = item.get("proof_paths") or []

    for path in touched:
        if path.startswith(SOURCE_PREFIXES) or path.endswith(SOURCE_SUFFIXES):
            return True

    if validation:
        return True

    for path in proof_paths:
        if "xcodebuild" in path.lower() or "test" in path.lower() or "build" in path.lower():
            return True

    return False


def path_kind(repo_path: str) -> str:
    if repo_path.startswith("prompts/batches/"):
        return "prompt_batch"
    if repo_path.startswith("docs/codex/batches/"):
        return "codex_batch_doc"
    if repo_path.startswith("docs/codex/"):
        return "codex_doc"
    if repo_path.startswith("docs/audits/"):
        return "audit_doc"
    if repo_path.startswith("build/reports/"):
        return "build_report"
    if repo_path.startswith("Native/") or repo_path.startswith("Sources/") or repo_path.startswith("Tests/"):
        return "source_or_test"
    if repo_path.startswith("scripts/") or repo_path.startswith("tools/"):
        return "script_or_tool"
    return "other"


def stale_like(item: dict[str, Any]) -> bool:
    repo_path = item.get("repo_path", "")
    stable_id = item.get("stable_id", "")
    status = item.get("implementation_status", "unknown")
    proof_state = item.get("amb27_proof_state", item.get("proof_state", "none"))
    touched_files = item.get("touched_files") or []

    if path_kind(repo_path) in {"audit_doc", "build_report"}:
        return True
    if "repo-audit" in repo_path.lower() or "baseline" in repo_path.lower():
        return True
    if repo_path.startswith("docs/codex/batches/BATCH-") and not touched_files and proof_state in {"audit", "none", "source-only"}:
        return True
    if status == "unknown" and proof_state in {"audit", "none"} and not touched_files:
        return True
    if "pre-phase" in repo_path.lower() or "legacy" in repo_path.lower() or "old" in repo_path.lower():
        return True
    if "FINALIZE" in stable_id or "REPAIR" in stable_id:
        return False

    return False


def planned_like(item: dict[str, Any]) -> bool:
    current = item.get("current_status", "")
    impl = item.get("implementation_status", "")
    repo_path = item.get("repo_path", "")
    proof_state = item.get("amb27_proof_state", item.get("proof_state", "none"))

    if current in {"planned", "installed_not_run"}:
        return True
    if impl == "planned":
        return True
    if repo_path.startswith("prompts/batches/") and proof_state == "none":
        return True
    return False


def conflict_index_by_item(conflicts: list[dict[str, Any]]) -> dict[tuple[str, str], set[str]]:
    index: dict[tuple[str, str], set[str]] = defaultdict(set)
    for conflict in conflicts:
        ctype = conflict.get("conflict_type", "unknown")
        for involved in conflict.get("involved", []):
            sid = involved.get("stable_id", "unknown")
            path = involved.get("repo_path", "unknown")
            index[(sid, path)].add(ctype)
    return index


def related_conflicts_for_item(item: dict[str, Any], related_index: dict[tuple[str, str], set[str]]) -> set[str]:
    direct = related_index.get(item_key(item), set())
    if direct:
        return set(direct)

    sid, path = item_key(item)
    found = set()

    for (other_sid, other_path), conflicts in related_index.items():
        if sid != "unknown" and sid == other_sid:
            found.update(conflicts)
        if path != "unknown" and path == other_path:
            found.update(conflicts)

    return found


def classify_bundle(item: dict[str, Any], related_conflicts: set[str]) -> tuple[str, str]:
    if related_conflicts.intersection(
        {
            "duplicate_stable_id",
            "same_source_file_targeted_by_multiple_active_batches",
            "same_surface_multiple_active_batches",
        }
    ):
        return (
            "merge-overlap-before-proof",
            "Candidate also participates in duplicate or overlapping active work, so proof must wait until ownership is merged or sequenced.",
        )

    if source_bound(item):
        return (
            "finish-real-source-proof",
            "Candidate references source/test/script/proof commands, so it may need real proof rather than canon cleanup.",
        )

    source_docs = item.get("source_of_truth_docs") or []
    item_conflicts = set(item.get("conflicts") or [])
    if (
        not source_docs
        or "missing_source_of_truth_reference" in related_conflicts
        or "retired_ia_or_terminology_reference" in related_conflicts
        or "old_ia_language" in item_conflicts
        or "old_canon_language" in item_conflicts
    ):
        return (
            "rewrite-authority-before-proof",
            "Candidate lacks exact authority or carries stale language, so rewrite/authority cleanup comes before proof.",
        )

    if stale_like(item):
        return (
            "retire-or-quarantine-stale-proof-debt",
            "Candidate looks like stale audit/batch/proof debt and should be retired or quarantined before proof work.",
        )

    if planned_like(item):
        return (
            "keep-planned-proof-later",
            "Candidate should remain planned until selected by the active sequence.",
        )

    return (
        "manual-triage-remainder",
        "Candidate needs owner triage because proof/disposition evidence is ambiguous.",
    )


def build_candidate_records(ledger: dict[str, Any], conflict_payload: dict[str, Any]) -> list[dict[str, Any]]:
    index = ledger_index(ledger)
    conflicts = conflict_payload.get("conflicts", [])
    related_index = conflict_index_by_item(conflicts)

    records = []

    for conflict in conflicts:
        if conflict.get("conflict_type") != "source_only_implementation_missing_proof":
            continue

        active_items = []
        for involved in conflict.get("involved", []):
            item = lookup_item(index, involved)
            if active_item(item):
                active_items.append(item)

        if not active_items:
            continue

        for item in active_items:
            related_conflicts = related_conflicts_for_item(item, related_index)
            bundle_id, reason = classify_bundle(item, related_conflicts)

            record = {
                "candidate_id": conflict.get("conflict_id", "unknown"),
                "conflict_type": conflict.get("conflict_type", "unknown"),
                "severity": conflict.get("severity", "unknown"),
                "source_conflict_title": conflict.get("title", ""),
                "stable_id": item.get("stable_id", "unknown"),
                "repo_path": item.get("repo_path", "unknown"),
                "path_kind": path_kind(item.get("repo_path", "")),
                "item_type": item.get("item_type", "unknown"),
                "current_status": item.get("current_status", "unknown"),
                "implementation_status": item.get("implementation_status", "unknown"),
                "proof_state": item.get("amb27_proof_state", item.get("proof_state", "unknown")),
                "touched_surfaces": item.get("touched_surfaces", []),
                "touched_systems": item.get("touched_systems", []),
                "touched_files": item.get("touched_files", []),
                "source_of_truth_docs": item.get("source_of_truth_docs", []),
                "proof_paths": item.get("proof_paths", []),
                "validation_commands": item.get("validation_commands", []),
                "related_conflict_types": sorted(related_conflicts),
                "bundle_id": bundle_id,
                "classification_reason": reason,
            }
            records.append(record)

    records.sort(key=lambda r: (r["bundle_id"], r["repo_path"], r["candidate_id"]))
    return records


def bundle_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        grouped[record["bundle_id"]].append(record)

    bundles = []
    for bundle_id, members in grouped.items():
        definition = BUNDLE_DEFS[bundle_id]
        surfaces = Counter()
        systems = Counter()
        path_kinds = Counter()
        proof_states = Counter()

        for member in members:
            for surface in member.get("touched_surfaces") or ["unknown"]:
                surfaces[surface] += 1
            for system in member.get("touched_systems") or ["unknown"]:
                systems[system] += 1
            path_kinds[member["path_kind"]] += 1
            proof_states[member["proof_state"]] += 1

        bundles.append(
            {
                "bundle_id": bundle_id,
                "title": definition["title"],
                "recommended_disposition": definition["recommended_disposition"],
                "proof_requirement": definition["proof_requirement"],
                "next_action": definition["next_action"],
                "candidate_count": len(members),
                "candidate_ids": [m["candidate_id"] for m in members],
                "repo_paths": sorted({m["repo_path"] for m in members}),
                "top_surfaces": dict(surfaces.most_common(12)),
                "top_systems": dict(systems.most_common(12)),
                "path_kinds": dict(sorted(path_kinds.items())),
                "proof_states": dict(sorted(proof_states.items())),
                "candidates": members,
            }
        )

    bundle_order = {
        "finish-real-source-proof": 0,
        "merge-overlap-before-proof": 1,
        "rewrite-authority-before-proof": 2,
        "retire-or-quarantine-stale-proof-debt": 3,
        "keep-planned-proof-later": 4,
        "manual-triage-remainder": 5,
    }

    bundles.sort(key=lambda b: (bundle_order.get(b["bundle_id"], 99), b["bundle_id"]))
    return bundles


def choose_next_bundle(bundles: list[dict[str, Any]]) -> dict[str, Any]:
    if not bundles:
        return {
            "bundle_id": "none",
            "title": "No source-only proof bundle required",
            "recommended_disposition": "Keep planned",
            "candidate_count": 0,
            "reason": "No active source-only / missing-proof candidates found.",
        }

    for wanted in [
        "finish-real-source-proof",
        "merge-overlap-before-proof",
        "rewrite-authority-before-proof",
        "retire-or-quarantine-stale-proof-debt",
        "keep-planned-proof-later",
        "manual-triage-remainder",
    ]:
        for bundle in bundles:
            if bundle["bundle_id"] == wanted and bundle["candidate_count"] > 0:
                return {
                    "bundle_id": bundle["bundle_id"],
                    "title": bundle["title"],
                    "recommended_disposition": bundle["recommended_disposition"],
                    "candidate_count": bundle["candidate_count"],
                    "reason": bundle["next_action"],
                    "repo_paths": bundle["repo_paths"],
                }

    return {
        "bundle_id": bundles[0]["bundle_id"],
        "title": bundles[0]["title"],
        "recommended_disposition": bundles[0]["recommended_disposition"],
        "candidate_count": bundles[0]["candidate_count"],
        "reason": bundles[0]["next_action"],
        "repo_paths": bundles[0]["repo_paths"],
    }


def write_bundle_files(bundles: list[dict[str, Any]]) -> list[str]:
    written = []

    for bundle in bundles:
        path = BUNDLE_DIR / f"{bundle['bundle_id']}.md"
        lines = [
            f"# {bundle['title']}",
            "",
            f"Bundle ID: {bundle['bundle_id']}",
            f"Recommended disposition: {bundle['recommended_disposition']}",
            f"Candidate count: {bundle['candidate_count']}",
            "",
            "## Proof requirement",
            "",
            bundle["proof_requirement"],
            "",
            "## Next action",
            "",
            bundle["next_action"],
            "",
            "## Summary",
            "",
            "### Path kinds",
            "",
        ]

        for key, value in bundle["path_kinds"].items():
            lines.append(f"- {key}: {value}")

        lines.extend(["", "### Proof states", ""])

        for key, value in bundle["proof_states"].items():
            lines.append(f"- {key}: {value}")

        lines.extend(["", "### Top surfaces", ""])

        for key, value in bundle["top_surfaces"].items():
            lines.append(f"- {key}: {value}")

        lines.extend(["", "### Top systems", ""])

        for key, value in bundle["top_systems"].items():
            lines.append(f"- {key}: {value}")

        lines.extend(["", "## Candidates", ""])

        for member in bundle["candidates"][:200]:
            lines.append(f"- {member['candidate_id']} — {member['stable_id']} — {member['repo_path']}")
            lines.append(f"  - Proof state: {member['proof_state']}")
            lines.append(f"  - Implementation status: {member['implementation_status']}")
            lines.append(f"  - Reason: {member['classification_reason']}")

        if len(bundle["candidates"]) > 200:
            lines.append(f"- ... {len(bundle['candidates']) - 200} more in source-only-proof-bundles.json")

        lines.extend(
            [
                "",
                "## Non-claims",
                "",
                "- This bundle does not prove implementation.",
                "- This bundle does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
                "- Linear status is not repo truth.",
                "",
            ]
        )

        path.write_text("\n".join(lines), encoding="utf-8")
        written.append(rel(path))

    return written


def write_markdown(payload: dict[str, Any]) -> None:
    next_bundle = payload["next_bounded_action_bundle"]

    lines = [
        "# Source-Only / Missing-Proof Bundle Analysis",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Purpose",
        "",
        "This report accounts for all active source-only / missing-proof candidates and groups them into bounded action bundles.",
        "",
        "It does not modify source code, product truth, prompts, or trains.",
        "",
        "## Required read order",
        "",
    ]

    for path in REQUIRED_READ_ORDER:
        lines.append(f"- {path}")

    summary = payload["summary"]

    lines.extend(
        [
            "",
            "## Summary",
            "",
            f"- Total source-only / missing-proof candidates: {summary['candidate_count']}",
            f"- Bundle count: {summary['bundle_count']}",
            f"- Maximum bundle limit: 7",
            "",
            "### Candidates by bundle",
            "",
        ]
    )

    for key, value in summary["candidates_by_bundle"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "### Candidates by path kind", ""])

    for key, value in summary["candidates_by_path_kind"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "### Candidates by proof state", ""])

    for key, value in summary["candidates_by_proof_state"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(
        [
            "",
            "## Next bounded action bundle",
            "",
            f"- Bundle ID: {next_bundle['bundle_id']}",
            f"- Title: {next_bundle['title']}",
            f"- Recommended disposition: {next_bundle['recommended_disposition']}",
            f"- Candidate count: {next_bundle['candidate_count']}",
            f"- Reason: {next_bundle['reason']}",
            "",
            "## Bundle files",
            "",
        ]
    )

    for path in payload["bundle_files"]:
        lines.append(f"- {path}")

    lines.extend(["", "## Bundles", ""])

    for bundle in payload["bundles"]:
        lines.append(f"### {bundle['title']}")
        lines.append("")
        lines.append(f"- Bundle ID: {bundle['bundle_id']}")
        lines.append(f"- Recommended disposition: {bundle['recommended_disposition']}")
        lines.append(f"- Candidate count: {bundle['candidate_count']}")
        lines.append(f"- Proof requirement: {bundle['proof_requirement']}")
        lines.append(f"- Next action: {bundle['next_action']}")
        lines.append("")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines), encoding="utf-8")


def validate_payload(payload: dict[str, Any], raw_candidates: list[dict[str, Any]]) -> list[str]:
    errors = []

    for path in [LEDGER_JSON, CONFLICT_JSON, CANDIDATES_JSON, OUT_MD, OUT_JSON]:
        if not path.exists():
            errors.append(f"missing required artifact: {path.relative_to(ROOT)}")

    bundle_count = len(payload.get("bundles", []))
    if bundle_count < 1 or bundle_count > 7:
        errors.append(f"bundle count must be 1..7, found {bundle_count}")

    source_candidate_ids = [c["candidate_id"] for c in raw_candidates]
    bundled_ids = []
    for bundle in payload.get("bundles", []):
        bundled_ids.extend(bundle.get("candidate_ids", []))
        if not bundle.get("repo_paths"):
            errors.append(f"{bundle.get('bundle_id', 'unknown')}: missing repo paths")
        if not bundle.get("proof_requirement"):
            errors.append(f"{bundle.get('bundle_id', 'unknown')}: missing proof requirement")
        if not bundle.get("next_action"):
            errors.append(f"{bundle.get('bundle_id', 'unknown')}: missing next action")

    if len(bundled_ids) != len(source_candidate_ids):
        errors.append(f"candidate accounting mismatch: bundled {len(bundled_ids)} source {len(source_candidate_ids)}")

    if set(bundled_ids) != set(source_candidate_ids):
        errors.append("candidate ID set mismatch between source and bundles")

    duplicate_ids = [cid for cid, count in Counter(bundled_ids).items() if count > 1]
    if duplicate_ids:
        errors.append(f"duplicate candidate IDs across bundles: {duplicate_ids[:20]}")

    for bundle_file in payload.get("bundle_files", []):
        if not (ROOT / bundle_file).exists():
            errors.append(f"missing bundle file: {bundle_file}")

    if not payload.get("next_bounded_action_bundle", {}).get("bundle_id"):
        errors.append("missing next bounded action bundle")

    return errors


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    BUNDLE_DIR.mkdir(parents=True, exist_ok=True)

    ledger = load_json(LEDGER_JSON)
    conflict_payload = load_json(CONFLICT_JSON)
    load_json(CANDIDATES_JSON)

    records = build_candidate_records(ledger, conflict_payload)
    bundles = bundle_records(records)
    bundle_files = write_bundle_files(bundles)
    next_bundle = choose_next_bundle(bundles)

    summary = {
        "candidate_count": len(records),
        "bundle_count": len(bundles),
        "candidates_by_bundle": dict(sorted(Counter(r["bundle_id"] for r in records).items())),
        "candidates_by_path_kind": dict(sorted(Counter(r["path_kind"] for r in records).items())),
        "candidates_by_proof_state": dict(sorted(Counter(r["proof_state"] for r in records).items())),
        "candidates_by_implementation_status": dict(sorted(Counter(r["implementation_status"] for r in records).items())),
    }

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": "GREEN",
        "required_read_order": REQUIRED_READ_ORDER,
        "summary": summary,
        "next_bounded_action_bundle": next_bundle,
        "bundle_files": bundle_files,
        "bundles": bundles,
        "all_candidates": records,
        "non_claims": [
            "This analysis does not modify source code.",
            "This analysis does not modify product truth.",
            "This analysis does not modify prompts or trains.",
            "This analysis does not mark source-only work complete.",
            "This analysis does not create one issue per candidate.",
            "This analysis does not prove implementation, build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_markdown(payload)

    errors = validate_payload(payload, records)
    if errors:
        payload["status"] = "RED"
        payload["validation_errors"] = errors
        OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        write_markdown(payload)
        print("AMB-288 source-only proof bundle analysis failed.")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"wrote {OUT_MD.relative_to(ROOT)}")
    print(f"wrote {OUT_JSON.relative_to(ROOT)}")
    for path in bundle_files:
        print(f"wrote {path}")
    print(f"status: GREEN")
    print(f"candidate_count: {summary['candidate_count']}")
    print(f"bundle_count: {summary['bundle_count']}")
    print(f"next_bundle: {next_bundle['bundle_id']}")
    print("AMB-288 source-only proof bundle analysis passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
