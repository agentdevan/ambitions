#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from datetime import datetime, timezone

GENERATED = Path("docs/governance/generated")
LINEAGE = GENERATED / "train_lineage_graph.json"
OVERRIDES = Path("docs/governance/orphan_prompt_provenance_overrides.json")
OUT_JSON = GENERATED / "orphan_prompt_provenance.json"
OUT_MD = GENERATED / "orphan_prompt_provenance.md"

PROVEN_STATES = {
    "COMPLETE_PROOF_LINKED",
    "COMPLETE_EVIDENCE_ONLY_OR_DOCS_ONLY",
    "DOCS_ONLY_COMPLETE",
    "EVIDENCE_ONLY_COMPLETE",
    "COMPLETE_ACCEPTED_YELLOW",
    "VERIFIED_WITH_RECONCILIATION_PENDING",
}


def load_overrides() -> dict:
    if not OVERRIDES.exists():
        return {"exact": {}, "ranges": []}
    return json.loads(OVERRIDES.read_text(encoding="utf-8"))


def override_for(train_id: str, overrides: dict) -> tuple[str, str] | None:
    exact = overrides.get("exact", {})
    if isinstance(exact, dict) and train_id in exact:
        item = exact[train_id]
        if isinstance(item, dict):
            return str(item.get("classification", "")), str(item.get("reason", ""))

    for item in overrides.get("ranges", []):
        if not isinstance(item, dict):
            continue
        prefix = str(item.get("prefix", ""))
        if not train_id.startswith(prefix):
            continue
        suffix = train_id.removeprefix(prefix)
        if not suffix.isdigit():
            continue
        number = int(suffix)
        start = int(item.get("start", -1))
        end = int(item.get("end", -1))
        if start <= number <= end:
            return str(item.get("classification", "")), str(item.get("reason", ""))
    return None


def classify(train_id: str, record: dict, overrides: dict) -> tuple[str, str]:
    override = override_for(train_id, overrides)
    if override and override[0]:
        return override

    prompt_files = record.get("prompt_files") or []
    commits = record.get("commits") or []
    proof_files = record.get("proof_files") or []
    audit_files = record.get("audit_files") or []
    report_files = record.get("report_files") or []
    implementation_files = record.get("implementation_files") or []
    governance_files = record.get("governance_files") or []
    state = record.get("state", "")

    if not prompt_files:
        return "not_prompt_backed", "No prompt file is linked to this train."

    if commits and implementation_files and (proof_files or audit_files or report_files):
        return "proven_implemented", "Prompt has commit lineage, implementation files, and proof/audit/report linkage."

    if commits and (proof_files or audit_files or report_files):
        return "proven_evidence_or_docs", "Prompt has commit lineage and evidence linkage but no implementation files."

    if state in PROVEN_STATES and (proof_files or audit_files or report_files or governance_files):
        return "proven_by_governance_state", "Prompt state is accepted as proven by governance/evidence classification."

    if governance_files and not implementation_files:
        return "proven_governance_only", "Prompt is linked to governance/canon files and appears docs/governance-only."

    if commits:
        return "partial_commit_lineage", "Prompt has commit lineage but insufficient proof or implementation linkage."

    return "candidate_orphan", "Prompt exists without automatic commit/proof/implementation linkage."


def main() -> int:
    if not LINEAGE.exists():
        print(f"missing {LINEAGE}")
        return 1

    data = json.loads(LINEAGE.read_text(encoding="utf-8"))
    records = data.get("records", {})
    overrides = load_overrides()

    buckets: dict[str, list[dict]] = {}
    for train_id, record in records.items():
        bucket, reason = classify(train_id, record, overrides)
        item = {
            "train_id": train_id,
            "state": record.get("state"),
            "confidence": record.get("confidence"),
            "reason": reason,
            "prompt_files": record.get("prompt_files", []),
            "commit_count": len(record.get("commits", [])),
            "implementation_file_count": len(record.get("implementation_files", [])),
            "proof_file_count": len(record.get("proof_files", [])),
            "governance_file_count": len(record.get("governance_files", [])),
        }
        buckets.setdefault(bucket, []).append(item)

    generated_at = datetime.now(timezone.utc).isoformat()
    payload = {
        "generated_at": generated_at,
        "counts": {key: len(value) for key, value in sorted(buckets.items())},
        "buckets": {key: sorted(value, key=lambda i: i["train_id"]) for key, value in sorted(buckets.items())},
    }
    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = ["# Orphan Prompt Provenance", "", f"Generated: {generated_at}", ""]
    lines += ["## Counts", ""]
    for key, value in payload["counts"].items():
        lines.append(f"- {key}: {value}")
    lines.append("")

    for key, items in payload["buckets"].items():
        lines += [f"## {key}", "", "| Train | State | Commits | Impl | Proof | Governance | Reason |", "|---|---|---:|---:|---:|---:|---|"]
        for item in items[:300]:
            reason = item["reason"].replace("|", "\\|")
            lines.append(f"| {item['train_id']} | {item['state']} | {item['commit_count']} | {item['implementation_file_count']} | {item['proof_file_count']} | {item['governance_file_count']} | {reason} |")
        if len(items) > 300:
            lines.append(f"| ... | truncated | | | | | {len(items) - 300} more entries in JSON |")
        lines.append("")

    OUT_MD.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT_JSON}")
    print(f"wrote {OUT_MD}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
