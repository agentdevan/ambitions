#!/usr/bin/env python3
"""Validate existing-code champion coverage.

Bootstrap mode may create initial coverage artifacts for the guard-install
batch, but incomplete implementation coverage remains Yellow and never Green.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT_DIR = ROOT / "docs/audits/intelligence-consolidation"
REPORT_DIR = ROOT / "build/reports/intelligence-consolidation"
COVERAGE_YML = ROOT / "docs/codex/existing-code-champion-coverage.yml"
COVERAGE_JSON = REPORT_DIR / "existing-code-champion-coverage.json"
COVERAGE_MD = AUDIT_DIR / "EXISTING_CODE_CHAMPION_COVERAGE.md"
OWNER_MAP_MD = AUDIT_DIR / "CANONICAL_OWNER_MAP.md"
OWNER_MAP_YML = ROOT / "docs/codex/canonical-owner-map.yml"
RESCUE = AUDIT_DIR / "BEST_CODE_RESCUE_LEDGER.md"
SUPERSESSION = AUDIT_DIR / "SUPERSESSION_LEDGER.md"
REPORT_MD = REPORT_DIR / "champion-coverage-check.md"
REPORT_JSON = REPORT_DIR / "champion-coverage-check.json"
BOOTSTRAP_BATCH = "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01"
ROOTS = [
    "Native/Ambitions",
    "Native/AmbitionsTests",
    "Native/AmbitionsUITests",
    "Native/AmbitionsWidgetExtension",
    "Native/AmbitionsShareExtension",
    "Sources",
    "AppUI/Sources",
]
DECL_RE = re.compile(r"\b(?:struct|class|actor|enum|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)")


def swift_files() -> list[Path]:
    files: list[Path] = []
    for root in ROOTS:
        base = ROOT / root
        if base.exists():
            files.extend(sorted(base.rglob("*.swift")))
    return sorted(set(files))


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def yaml_quote(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    text = str(value).replace('"', '\\"')
    return f'"{text}"'


def membership(rel: str) -> str:
    if rel.startswith("Native/AmbitionsTests/"):
        return "Unit tests"
    if rel.startswith("Native/AmbitionsUITests/"):
        return "UI tests"
    if rel.startswith("Native/AmbitionsWidgetExtension/"):
        return "Widget"
    if rel.startswith("Native/AmbitionsShareExtension/"):
        return "Share Extension"
    if rel.startswith("Sources/"):
        return "DesignSystem package"
    if rel.startswith("AppUI/Sources/"):
        return "WidgetUI package"
    if rel.startswith("Native/Ambitions/"):
        return "App"
    return "Unknown"


def concept_area(rel: str, text: str) -> str:
    hay = f"{rel}\n{text}".lower()
    for area, terms in {
        "today": ["today", "realitymeridian", "start here"],
        "capture": ["capture", "smartattachment", "atmosphere"],
        "goals": ["goal", "ambition", "constellation"],
        "time": ["time", "lifeshape", "schedule", "calendar"],
        "you": ["you", "profile", "personal runtime"],
        "runtime": ["runtime", "recommendation", "compiler", "candidate"],
        "proof_receipt_replay": ["proof", "receipt", "replay", "closure", "recovery"],
        "design_system": ["token", "material", "motion", "haptic", "accessibility"],
    }.items():
        if any(term in hay for term in terms):
            return area
    return "unknown"


def owner_for(area: str) -> str:
    mapping = {
        "today": "today_root",
        "capture": "capture_root",
        "goals": "goals_root",
        "time": "time_root",
        "you": "you_root",
        "runtime": "private_life_runtime",
        "proof_receipt_replay": "proof_receipt_replay",
        "design_system": "design_system",
    }
    return mapping.get(area, "unknown_owner")


def classification(rel: str, member: str, area: str) -> str:
    if member in {"Unit tests", "UI tests"}:
        return "TEST_ONLY"
    if "Preview" in rel or "/Previews/" in rel:
        return "PREVIEW_ONLY_REFERENCE"
    if member in {"DesignSystem package", "WidgetUI package"}:
        return "PACKAGE_ONLY_CANDIDATE"
    if area == "unknown":
        return "UNKNOWN_REQUIRES_OWNER_REVIEW"
    return "CANONICAL_HELPER"


def generated_entries() -> list[dict[str, object]]:
    entries: list[dict[str, object]] = []
    corpus = "\n".join(read(path) for path in swift_files())
    for path in swift_files():
        rel = str(path.relative_to(ROOT))
        text = read(path)
        decls = DECL_RE.findall(text)
        member = membership(rel)
        area = concept_area(rel, text)
        klass = classification(rel, member, area)
        refs = sum(corpus.count(name) for name in decls) if decls else 0
        entries.append(
            {
                "path": rel,
                "target_membership": member,
                "declared_types": decls,
                "reachability": "Referenced by active target" if refs > len(decls) else "Unknown",
                "concept_area": area,
                "canonical_owner_id": owner_for(area),
                "classification": klass,
                "evidence": f"membership={member}; declared_types={len(decls)}; text_reference_signal={refs}",
                "action_required": "Owner review required" if klass == "UNKNOWN_REQUIRES_OWNER_REVIEW" else "Keep under canonical owner review",
                "owner_review_needed": klass == "UNKNOWN_REQUIRES_OWNER_REVIEW",
            }
        )
    return entries


def write_coverage(entries: list[dict[str, object]]) -> None:
    AUDIT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    lines = ["files:"]
    for entry in entries:
        lines.append(f"  - path: {yaml_quote(entry['path'])}")
        for key in ("target_membership", "reachability", "concept_area", "canonical_owner_id", "classification", "evidence", "action_required", "owner_review_needed"):
            lines.append(f"    {key}: {yaml_quote(entry[key])}")
        lines.append("    declared_types:")
        for item in entry["declared_types"]:
            lines.append(f"      - {yaml_quote(item)}")
    COVERAGE_YML.write_text("\n".join(lines) + "\n", encoding="utf-8")
    COVERAGE_JSON.write_text(json.dumps({"files": entries}, indent=2), encoding="utf-8")
    md = [
        "# Existing Code Champion Coverage",
        "",
        "Status: Bootstrap Yellow until every active product/runtime implementation is owner-reviewed.",
        "",
        "| Path | Target membership | Declared types | Reachability | Concept area | Canonical owner | Classification | Evidence | Action required | Owner review needed |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for entry in entries:
        md.append(
            f"| `{entry['path']}` | {entry['target_membership']} | {', '.join(entry['declared_types']) or '-'} | {entry['reachability']} | {entry['concept_area']} | {entry['canonical_owner_id']} | {entry['classification']} | {entry['evidence']} | {entry['action_required']} | {entry['owner_review_needed']} |"
        )
    COVERAGE_MD.write_text("\n".join(md) + "\n", encoding="utf-8")


def parse_coverage_yml() -> list[dict[str, object]]:
    if not COVERAGE_YML.exists():
        return []
    entries: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    in_declared = False
    for raw in read(COVERAGE_YML).splitlines():
        line = raw.rstrip()
        if line.startswith("  - path:"):
            if current:
                entries.append(current)
            current = {"path": line.split(":", 1)[1].strip().strip('"'), "declared_types": []}
            in_declared = False
        elif current and line.strip() == "declared_types:":
            in_declared = True
        elif current and in_declared and line.strip().startswith("- "):
            current.setdefault("declared_types", []).append(line.strip()[2:].strip('"'))
        elif current and ":" in line and line.startswith("    "):
            key, value = line.strip().split(":", 1)
            value = value.strip().strip('"')
            if value in {"true", "false"}:
                current[key] = value == "true"
            else:
                current[key] = value
            in_declared = False
    if current:
        entries.append(current)
    return entries


def write_report(status: str, defects: list[str], warnings: list[str], entries: list[dict[str, object]]) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    payload = {"status": status, "defects": defects, "warnings": warnings, "total_files": len(entries), "report": str(REPORT_MD.relative_to(ROOT))}
    REPORT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = [
        "# Champion Coverage Check",
        "",
        f"Status: {status}",
        "",
        f"Total files covered: {len(entries)}",
        "",
        "## Defects",
        *(f"- {item}" for item in defects or ["none"]),
        "",
        "## Warnings",
        *(f"- {item}" for item in warnings or ["none"]),
    ]
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bootstrap-install", action="store_true")
    parser.add_argument("--batch", default="MANUAL")
    args = parser.parse_args()
    bootstrap_allowed = args.bootstrap_install and args.batch == BOOTSTRAP_BATCH
    if args.bootstrap_install and not bootstrap_allowed:
        print("STATUS: RED")
        print("--bootstrap-install is allowed only for AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01")
        return 1
    if bootstrap_allowed:
        write_coverage(generated_entries())
    entries = parse_coverage_yml()
    defects: list[str] = []
    warnings: list[str] = []
    swift_paths = {str(path.relative_to(ROOT)) for path in swift_files()}
    covered = {str(entry.get("path", "")) for entry in entries}
    missing = sorted(swift_paths - covered)
    if missing:
        (warnings if bootstrap_allowed else defects).extend(f"unclassified Swift file: {path}" for path in missing[:50])
    for entry in entries:
        klass = str(entry.get("classification", ""))
        member = str(entry.get("target_membership", ""))
        owner = str(entry.get("canonical_owner_id", ""))
        path = str(entry.get("path", ""))
        if not klass:
            defects.append(f"{path}: missing classification")
        if owner in {"", "unknown_owner"} and member == "App" and klass not in {"PREVIEW_ONLY_REFERENCE", "TEST_ONLY"}:
            defects.append(f"{path}: active product/runtime implementation lacks canonical owner")
        if klass == "UNKNOWN_REQUIRES_OWNER_REVIEW":
            if member in {"Unit tests", "UI tests", "DesignSystem package", "WidgetUI package"} or "Preview" in path:
                warnings.append(f"{path}: Yellow UNKNOWN allowed only with owner review boundary")
            else:
                (warnings if bootstrap_allowed else defects).append(f"{path}: app/runtime UNKNOWN_REQUIRES_OWNER_REVIEW")
        if klass in {"RESCUE_AND_MERGE", "LEGACY_BETTER_THAN_ACTIVE"} and path not in read(RESCUE):
            defects.append(f"{path}: rescue classification missing from BEST_CODE_RESCUE_LEDGER.md")
        if klass == "SUPERSEDED_RETIRE_LATER" and path not in read(SUPERSESSION):
            defects.append(f"{path}: superseded classification missing from SUPERSESSION_LEDGER.md")
    champion_by_owner: dict[str, list[str]] = {}
    for entry in entries:
        if entry.get("classification") == "CANONICAL_CHAMPION":
            champion_by_owner.setdefault(str(entry.get("canonical_owner_id")), []).append(str(entry.get("path")))
    for owner, paths in champion_by_owner.items():
        if len(paths) > 1:
            defects.append(f"{owner}: multiple CANONICAL_CHAMPION files: {paths}")
    if not OWNER_MAP_MD.exists() or not OWNER_MAP_YML.exists():
        (warnings if bootstrap_allowed else defects).append("canonical owner map missing")
    status = "RED" if defects else ("YELLOW" if warnings else "GREEN")
    if bootstrap_allowed and status == "GREEN":
        status = "YELLOW"
        warnings.append("bootstrap install emits bounded Yellow until owner review completes")
    write_report(status, defects, warnings, entries)
    print(f"STATUS: {status}")
    print(f"Report: {REPORT_MD}")
    return {"GREEN": 0, "YELLOW": 2, "RED": 1}[status]


if __name__ == "__main__":
    raise SystemExit(main())
