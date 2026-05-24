#!/usr/bin/env python3
"""Conservative active Swift code map for Ambitions.

This script is intentionally text-based. It reports target membership and
reference signals; it does not claim definitive unused code.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/reports/intelligence-consolidation"
SWIFT_ROOTS = [
    "Native/Ambitions",
    "Native/AmbitionsTests",
    "Native/AmbitionsUITests",
    "Native/AmbitionsWidgetExtension",
    "Native/AmbitionsShareExtension",
    "Sources",
    "AppUI/Sources",
]
DECL_RE = re.compile(r"\b(?:struct|class|actor|enum|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def swift_files() -> list[Path]:
    files: list[Path] = []
    for root in SWIFT_ROOTS:
        base = ROOT / root
        if base.exists():
            files.extend(sorted(base.rglob("*.swift")))
    return sorted(set(files))


def membership(rel: str) -> list[str]:
    labels: list[str] = []
    if rel.startswith("Native/AmbitionsTests/"):
        labels.append("Unit tests")
    elif rel.startswith("Native/AmbitionsUITests/"):
        labels.append("UI tests")
    elif rel.startswith("Native/AmbitionsWidgetExtension/"):
        labels.append("Widget")
    elif rel.startswith("Native/AmbitionsShareExtension/"):
        labels.append("Share Extension")
    elif rel.startswith("Sources/"):
        labels.append("DesignSystem package")
    elif rel.startswith("AppUI/Sources/"):
        labels.append("WidgetUI package")
    elif rel.startswith("Native/Ambitions/ExternalSnapshots/") and Path(rel).name in {
        "ExternalSurfaceSnapshotContracts.swift",
        "ExternalSurfaceContractModels.swift",
        "ExternalWidgetProjection.swift",
        "SharedExternalSnapshotStore.swift",
        "ExternalSurfaceActionPayloads.swift",
        "ExternalSurfaceControlContracts.swift",
        "NextStepActivityAttributes.swift",
    }:
        labels.extend(["App", "Widget"])
        if Path(rel).name in {
            "ExternalCreationContracts.swift",
            "ExternalSurfaceActionPayloads.swift",
            "ExternalSurfaceSnapshotContracts.swift",
            "ExternalSurfaceContractModels.swift",
            "SharedExternalSnapshotStore.swift",
        }:
            labels.append("Share Extension")
    elif rel.startswith("Native/Ambitions/"):
        labels.append("App")
    return sorted(set(labels or ["Unknown"]))


def role(rel: str) -> str:
    parts = rel.split("/")
    if "/Features/" in rel:
        return "UI surface"
    if "/Runtime/" in rel or "/Domain/" in rel:
        return "Runtime" if "/Runtime/" in rel else "Domain model"
    if "/Persistence/" in rel:
        return "Persistence"
    if "/Services/" in rel:
        return "Service"
    if "/Preview" in rel or "Previews/" in rel:
        return "Preview"
    if "Tests/" in rel or "UITests/" in rel:
        return "Test"
    if "/AppIntents/" in rel or "WidgetExtension" in rel or "ShareExtension" in rel:
        return "External surface"
    if len(parts) > 2 and parts[1] == "UI":
        return "UI primitive"
    return "Unknown"


def concept_area(rel: str, text: str) -> str:
    hay = f"{rel}\n{text}".lower()
    checks = [
        ("Today", ["today", "realitymeridian", "start here"]),
        ("Capture", ["capture", "smartattachment", "atmosphere"]),
        ("Goals", ["goal", "ambition", "constellation"]),
        ("Time", ["time", "lifeshape", "calendar", "schedule"]),
        ("You", ["you", "profile", "personal runtime", "what ambitions knows"]),
        ("Runtime", ["runtime", "recommendation", "compiler", "candidate", "sourceatlas"]),
        ("Proof/Receipt/Replay", ["proof", "receipt", "replay", "closure", "recovery"]),
        ("Design System", ["token", "material", "motion", "haptic", "accessibility"]),
    ]
    for area, terms in checks:
        if any(term in hay for term in terms):
            return area
    return "Unknown"


def status_for(rel: str, memberships: list[str], refs: int) -> str:
    if "Unit tests" in memberships or "UI tests" in memberships:
        return "TEST_ONLY"
    if "Preview" in role(rel):
        return "PREVIEW_ONLY"
    if memberships == ["DesignSystem package"] or memberships == ["WidgetUI package"]:
        return "PACKAGE_ONLY"
    if refs <= 1 and "App" in memberships:
        return "ACTIVE_BUT_SUSPECT"
    if "App" in memberships or "Widget" in memberships or "Share Extension" in memberships:
        return "ACTIVE"
    return "UNKNOWN"


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    files = swift_files()
    corpus = "\n".join(read(path) for path in files)
    rows = []
    for path in files:
        rel = str(path.relative_to(ROOT))
        text = read(path)
        decls = DECL_RE.findall(text)
        refs = sum(corpus.count(name) for name in decls) if decls else 0
        memberships = membership(rel)
        rows.append(
            {
                "path": rel,
                "target_membership": memberships,
                "role": role(rel),
                "declared_types": decls,
                "reference_signal": refs,
                "concept_area": concept_area(rel, text),
                "status": status_for(rel, memberships, refs),
                "evidence": [
                    "membership inferred from project.yml/Package.swift path roots",
                    f"declared_types={len(decls)}",
                    f"text_reference_signal={refs}",
                ],
            }
        )
    payload = {"status": "YELLOW", "summary": "Conservative map; text reference signals are not unused-code proof.", "total_swift_files": len(rows), "files": rows}
    (OUT / "active-code-map.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = [
        "# Active Code Map",
        "",
        "Status: Yellow - conservative text scan, not definitive unused-code proof.",
        "",
        f"Total Swift files scanned: {len(rows)}",
        "",
        "| Path | Target membership | Role | Declared types | Reference signal | Concept area | Status | Evidence |",
        "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for row in rows:
        lines.append(
            f"| `{row['path']}` | {', '.join(row['target_membership'])} | {row['role']} | {', '.join(row['declared_types']) or '-'} | {row['reference_signal']} | {row['concept_area']} | {row['status']} | {'; '.join(row['evidence'])} |"
        )
    (OUT / "active-code-map.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("STATUS: YELLOW")
    print(f"Report: {OUT / 'active-code-map.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
