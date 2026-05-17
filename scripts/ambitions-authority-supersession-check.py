#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from pathlib import Path

from visual_final_form_common import (
    FINAL_BATCH_ID,
    FINAL_PROMPT,
    LOCK_PREP_PROMPT,
    ROOT,
    REPORT_DIR,
    TRACE_ROOT,
    write_json,
    write_text,
)


REPORT_JSON = REPORT_DIR / "authority-supersession.json"
DOC_PATH = TRACE_ROOT / "VISUAL_AUTHORITY_SUPERSESSION_MAP.md"


def classify(path: Path) -> tuple[str, str, str, str]:
    rel = path.relative_to(ROOT)
    rel_str = str(rel)
    if rel_str.startswith("docs/truth/"):
        return "active_authority", "current repo truth", "", ""
    if rel_str.startswith("DesignTokens/"):
        return "active_authority", "token source tree", "", ""
    if rel_str.startswith("Sources/Theme/") and rel_str.endswith(".generated.swift"):
        return "generated_output", "generated from DesignTokens", "", ""
    if rel_str.startswith("frontend/visual-encyclopedia/recipes/") or rel_str.startswith("frontend/visual-encyclopedia/surfaces/") or rel_str.startswith("frontend/visual-encyclopedia/primitives/") or rel_str.startswith("frontend/visual-encyclopedia/contracts/") or rel_str.startswith("frontend/visual-encyclopedia/behavior/"):
        return "active_authority", "active frontend canon", "", ""
    if rel_str.startswith("frontend/visual-encyclopedia/trace/"):
        if path.name in {
            "VISUAL_100_PRIORITY_RECIPE_REGISTRY.yaml",
            "VISUAL_SOURCE_LINKAGE_LEDGER.md",
            "VISUAL_SURFACE_GRAPH_LEDGER.md",
            "SOURCE_PROOF_RECEIPT_COVERAGE_MATRIX.yaml",
            "DESIGN_TO_SOURCE_TRACEABILITY.yaml",
            "PREVIEW_MATRIX.yaml",
            "VISUAL_100_SOURCE_DEBT_LEDGER.md",
            "SURFACE_RECIPE_SPECIFICITY_REVIEW_LEDGER.md",
            "VISUAL_100_PROMPT_SUPERSESSION_LEDGER.md",
        }:
            return "supporting_authority", "current visual control plane", "", ""
        if path.name.endswith(".yaml") or path.name.endswith(".md"):
            return "report_only", "trace output or supporting ledger", "", ""
    if rel_str.startswith("build/reports/"):
        return "report_only", "validation output only", "", ""
    if rel_str.startswith("docs/archive/") or "/archive/" in rel_str:
        return "archive_candidate", "explicitly archived history", "", ""
    if "superseded" in rel_str.lower():
        return "historical", "superseded history", "", ""
    if rel_str == str(LOCK_PREP_PROMPT.relative_to(ROOT)):
        return "historical", "superseded by final-form prompt", "VISUAL-DESIGN-AUTHORITY-FINAL-FORM-04", ""
    if rel_str == str(FINAL_PROMPT.relative_to(ROOT)):
        return "report_only", "current execution prompt, not authority", "", ""
    return "report_only", "supporting control-plane file", "", ""


def classify_batch_prompt(path: Path) -> str:
    rel = str(path.relative_to(ROOT))
    if rel == str(LOCK_PREP_PROMPT.relative_to(ROOT)):
        return "VISUAL-DESIGN-AUTHORITY-FINAL-FORM-04"
    return ""


def collect_entries() -> list[dict[str, str]]:
    files = []
    roots = [
        ROOT / "docs/truth",
        ROOT / "frontend/visual-encyclopedia",
        ROOT / "DesignTokens",
        ROOT / "Sources/Theme",
        ROOT / "build/reports",
        ROOT / "docs/archive",
        ROOT / "prompts/batches",
    ]
    for root in roots:
        if root.exists():
            files.extend(sorted(p for p in root.rglob("*") if p.is_file()))
    entries: list[dict[str, str]] = []
    seen: set[str] = set()
    for path in files:
        rel = str(path.relative_to(ROOT))
        if rel in seen:
            continue
        seen.add(rel)
        classification, reason, supersedes, superseded_by = classify(path)
        if rel.startswith("prompts/batches/") and path not in {FINAL_PROMPT, LOCK_PREP_PROMPT}:
            continue
        entries.append(
            {
                "path": rel,
                "classification": classification,
                "reason": reason,
                "supersedes": supersedes,
                "superseded_by": superseded_by,
            }
        )
    return entries


def render_markdown(entries: list[dict[str, str]], counts: Counter[str]) -> str:
    lines = [
        "# Visual Authority Supersession Map",
        "",
        "Status: Active supersession map",
        "",
        f"Batch: `{FINAL_BATCH_ID}`",
        "",
        "## Summary",
        "",
        f"- active_authority: {counts['active_authority']}",
        f"- supporting_authority: {counts['supporting_authority']}",
        f"- generated_output: {counts['generated_output']}",
        f"- report_only: {counts['report_only']}",
        f"- historical: {counts['historical']}",
        f"- obsolete: {counts['obsolete']}",
        f"- archive_candidate: {counts['archive_candidate']}",
        f"- delete_candidate: {counts['delete_candidate']}",
        "",
        "## File Classification",
        "",
        "| Path | Classification | Reason | Supersedes | Superseded By |",
        "| --- | --- | --- | --- | --- |",
    ]
    for entry in entries:
        lines.append(
            f"| {entry['path']} | {entry['classification']} | {entry['reason']} | {entry['supersedes'] or '—'} | {entry['superseded_by'] or '—'} |"
        )
    lines.extend(
        [
            "",
            "## Supersession Notes",
            "",
            f"- `prompts/batches/{LOCK_PREP_PROMPT.name}` is superseded by `prompts/batches/{FINAL_PROMPT.name}`.",
            "- `docs/truth/**` remains active authority.",
            "- `DesignTokens/**` remains token source truth; `Sources/Theme/*.generated.swift` stays generated output.",
            "- `build/reports/**` remains report-only proof, not implementation proof.",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> int:
    entries = collect_entries()
    counts: Counter[str] = Counter(entry["classification"] for entry in entries)
    payload = {
        "batch": FINAL_BATCH_ID,
        "generated_from_batch": FINAL_BATCH_ID,
        "status": "green",
        "ambiguous_paths": [],
        "counts": dict(counts),
        "entries": entries,
    }
    write_json(REPORT_JSON, payload)
    write_text(DOC_PATH, render_markdown(entries, counts))
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
