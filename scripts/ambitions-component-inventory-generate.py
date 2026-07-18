#!/usr/bin/env python3
"""Generate candidate Swift component and path inventories for VSP provenance.

The generated files are source inventory only. They are not SwiftUI render proof,
device proof, accessibility proof, Figma proof, or owner approval.
"""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "docs" / "design" / "provenance" / "generated"
COMPONENT_OUTPUT = OUTPUT_DIR / "swift-component-inventory.generated.json"
PATH_OUTPUT = OUTPUT_DIR / "source-path-inventory.generated.json"
DETERMINISTIC_GENERATED_AT = "deterministic-from-current-source-inputs"

SCAN_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Sources",
    ROOT / "Native" / "AmbitionsTests",
]

SUPPORTING_DOC_PATHS = [
    "docs/qa/vsp-review/VSP01-VSP10-review-analysis.md",
    "docs/qa/evidence/2026-06-29-vsp-north-star-figma/manifest.json",
    "docs/qa/evidence/2026-06-29-vsp-north-star-figma/authority-map.md",
    "docs/qa/evidence/2026-06-29-vsp-north-star-figma/screenshot-index.md",
    "docs/qa/evidence/2026-06-29-vsp-north-star-figma/visual-audit-ledger.md",
    "docs/qa/evidence/2026-06-29-vsp-code-connect-readiness/manifest.json",
    "docs/canon/migration/legacy-semantic-migration.json",
    "docs/canon/migration/legacy-semantic-migration.json",
    "docs/canon/migration/legacy-semantic-migration.json",
    "docs/canon/migration/legacy-semantic-migration.json",
    "docs/canon/migration/legacy-semantic-migration.json",
    "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md",
    "docs/qa/KNOWN_ISSUES.md",
    "scripts/ambitions-green-standard-audit.py",
    "scripts/ambitions-architecture-inventory.py",
    "scripts/ambitions-quality-gate.py",
]

VIEW_RE = re.compile(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*View\b")
BUTTON_STYLE_RE = re.compile(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*ButtonStyle\b")
VIEW_MODIFIER_RE = re.compile(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*ViewModifier\b")
TEST_RE = re.compile(r"\bfinal\s+class\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*XCTestCase\b")


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def candidate_vsp_ids(relative_path: str, text: str) -> list[str]:
    haystack = f"{relative_path}\n{text[:8000]}".lower()
    ids: list[str] = []
    checks = [
        ("VSP-01", ["stage/", "app/", "shell", "dock", "surface shell", "context crown"]),
        ("VSP-02", ["today", "start here", "reality meridian", "reality window"]),
        ("VSP-03", ["goals", "constellation", "lifearea", "life area", "directionfield"]),
        ("VSP-04", ["time", "lifeshape", "life shape", "protected placement", "calendar"]),
        ("VSP-05", ["composer/capture", "capture", "atmosphere composer"]),
        ("VSP-06", ["surfaces/you", "personal system", "user system", "yourootsurface"]),
        ("VSP-07", ["trust", "proof", "receipt", "privacy", "history", "sourceinspection"]),
        ("VSP-08", ["sourceatlas", "source atlas", "r2", "account", "offline", "private graph"]),
        ("VSP-09", ["motion", "accessibility", "dynamic type", "reducemotion", "reduce motion", "haptic", "contrast", "transparency", "voiceover"]),
        ("VSP-10", ["sources/components", "sources/previews", "native/ambitions/quality", "component", "preview", "quality"]),
    ]
    for vsp_id, terms in checks:
        if any(term in haystack for term in terms):
            ids.append(vsp_id)
    return sorted(set(ids))


def path_kind(path: Path) -> str:
    relative = rel(path)
    if relative.startswith("Native/AmbitionsTests/"):
        return "test"
    if relative.startswith("Packages/AmbitionsDesignSystem/Sources/Previews/"):
        return "preview"
    if relative.startswith("Packages/AmbitionsDesignSystem/Sources/Accessibility/"):
        return "accessibility"
    if relative.startswith("Packages/AmbitionsDesignSystem/Sources/Components/"):
        return "design_system_component"
    if relative.startswith("Native/Ambitions/Quality/"):
        return "quality"
    if relative.startswith("Native/Ambitions/"):
        return "native_source"
    if relative.startswith("docs/"):
        return "doc"
    if relative.startswith("scripts/"):
        return "script"
    return "other"


def inspect_swift_file(path: Path) -> dict[str, object] | None:
    text = read(path)
    view_names = VIEW_RE.findall(text)
    button_styles = BUTTON_STYLE_RE.findall(text)
    view_modifiers = VIEW_MODIFIER_RE.findall(text)
    test_cases = TEST_RE.findall(text)
    preview_count = text.count("#Preview")
    has_preview_provider = "PreviewProvider" in text

    is_candidate = bool(view_names or button_styles or view_modifiers or preview_count or has_preview_provider or test_cases)
    relative = rel(path)
    if not is_candidate and not relative.startswith("Native/AmbitionsTests/"):
        return None

    return {
        "path": relative,
        "kind": path_kind(path),
        "candidate_inventory_only": True,
        "view_structs": sorted(set(view_names)),
        "button_styles": sorted(set(button_styles)),
        "view_modifiers": sorted(set(view_modifiers)),
        "test_cases": sorted(set(test_cases)),
        "preview_count": preview_count,
        "has_preview_provider": has_preview_provider,
        "line_count": text.count("\n") + 1,
        "candidate_vsp_ids": candidate_vsp_ids(relative, text),
        "proof_status": "source_inventory_only",
    }


def iter_swift_files() -> list[Path]:
    files: list[Path] = []
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        files.extend(sorted(root.rglob("*.swift")))
    return sorted(set(files))


def generate_component_inventory() -> dict[str, object]:
    entries = [entry for path in iter_swift_files() if (entry := inspect_swift_file(path)) is not None]
    return {
        "schema_version": 1,
        "generated_at": DETERMINISTIC_GENERATED_AT,
        "generator": "scripts/ambitions-component-inventory-generate.py",
        "claim_boundary": "Candidate source inventory only; not render proof, visual proof, accessibility proof, device proof, or owner approval.",
        "scan_roots": [rel(root) for root in SCAN_ROOTS if root.exists()],
        "entry_count": len(entries),
        "entries": entries,
    }


def generate_path_inventory() -> dict[str, object]:
    paths: list[dict[str, object]] = []
    for path in iter_swift_files():
        text = read(path)
        paths.append(
            {
                "path": rel(path),
                "kind": path_kind(path),
                "exists": True,
                "line_count": text.count("\n") + 1,
                "candidate_vsp_ids": candidate_vsp_ids(rel(path), text),
                "inventory_only": True,
            }
        )

    for relative in SUPPORTING_DOC_PATHS:
        path = ROOT / relative
        if not path.exists():
            continue
        text = read(path)
        paths.append(
            {
                "path": relative,
                "kind": path_kind(path),
                "exists": True,
                "line_count": text.count("\n") + 1,
                "candidate_vsp_ids": candidate_vsp_ids(relative, text),
                "inventory_only": True,
            }
        )

    paths.sort(key=lambda item: item["path"])
    return {
        "schema_version": 1,
        "generated_at": DETERMINISTIC_GENERATED_AT,
        "generator": "scripts/ambitions-component-inventory-generate.py",
        "claim_boundary": "Source path inventory only; listed paths do not prove implementation, visual acceptance, accessibility conformance, or release readiness.",
        "entry_count": len(paths),
        "entries": paths,
    }


def write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main() -> int:
    component_inventory = generate_component_inventory()
    path_inventory = generate_path_inventory()
    write_json(COMPONENT_OUTPUT, component_inventory)
    write_json(PATH_OUTPUT, path_inventory)
    print(f"Wrote {COMPONENT_OUTPUT.relative_to(ROOT)} ({component_inventory['entry_count']} entries)")
    print(f"Wrote {PATH_OUTPUT.relative_to(ROOT)} ({path_inventory['entry_count']} entries)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
