#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TRUTH_FILE = ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md"

FINAL_TREE_HEADER = "## 17. Final Architecture Tree"
FINAL_TREE_ROOT = "Native/Ambitions"

IMPLEMENTED = "implemented"
MISSING = "missing"
OBSOLETE_OWNER_PRESENT = "obsolete-owner-present"
DUPLICATE_OWNER_PRESENT = "duplicate-owner-present"
EXCLUDED_FROM_BUILD = "excluded-from-build"
PLACEHOLDER_ONLY = "placeholder-only"
TEST_ONLY = "test-only"
GENERATED_APPROVED_EXCEPTION = "generated/approved-exception"

BLOCKING_STATUSES = {
    MISSING,
    OBSOLETE_OWNER_PRESENT,
    DUPLICATE_OWNER_PRESENT,
    EXCLUDED_FROM_BUILD,
    PLACEHOLDER_ONLY,
}

FINAL_TOP_LEVEL_OWNERS = {
    "App",
    "Stage",
    "Core",
    "Projection",
    "Language",
    "Trust",
    "Interaction",
    "Rendering",
    "DesignSystem",
    "Surfaces",
    "Composer",
    "Scenarios",
    "Diagnostics",
    "Quality",
}

OBSOLETE_OWNER_DIRS = {
    "Native/Ambitions/AppIntents",
    "Native/Ambitions/Copy",
    "Native/Ambitions/Domain",
    "Native/Ambitions/ExternalSnapshots",
    "Native/Ambitions/Features",
    "Native/Ambitions/Integrations",
    "Native/Ambitions/Notifications",
    "Native/Ambitions/Persistence",
    "Native/Ambitions/Runtime",
    "Native/Ambitions/Services",
    "Native/Ambitions/UI",
}

EXPLICIT_FORBIDDEN_PATHS = {
    "Native/Ambitions/RootTab.swift",
    "Native/Ambitions/Surfaces/Capture",
    "Native/Ambitions/Surfaces/Motion",
    "Native/Ambitions/Projection/SurfaceLenses/MotionLens.swift",
    "Native/Ambitions/Projection/StageScenes/MotionStageScene.swift",
    "Native/Ambitions/Scenarios/MotionScenarios.swift",
}

TRANSITIONAL_TERMS = re.compile(
    r"\b(adapter|shim|transitional|temporary|compatibility|legacy)\b",
    flags=re.IGNORECASE,
)


@dataclass(frozen=True)
class InventoryEntry:
    required_path: str
    status: str
    owner: str
    current_file: str
    migration_action: str
    risk: str
    test_coverage: str
    proof_status: str
    build_included: bool


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def final_tree_block(truth_file: Path) -> str:
    text = read_text(truth_file)
    if FINAL_TREE_HEADER not in text:
        raise ValueError(f"{FINAL_TREE_HEADER} not found in {truth_file}")
    after_header = text.split(FINAL_TREE_HEADER, 1)[1]
    fences = after_header.split("```")
    if len(fences) < 3:
        raise ValueError("Final Architecture Tree code fence not found")
    for block in fences[1::2]:
        if block.strip().startswith("Ambitions/"):
            return block
    raise ValueError("Final Architecture Tree code fence beginning with Ambitions/ not found")


def canonical_file_paths(truth_file: Path) -> list[str]:
    block = final_tree_block(truth_file)
    stack: list[str] = []
    files: list[str] = []

    for raw_line in block.splitlines():
        if not raw_line.strip():
            continue
        indent = len(raw_line) - len(raw_line.lstrip(" "))
        name = raw_line.strip()
        if name == "Ambitions/":
            stack = []
            continue

        level = indent // 2
        if level == 1:
            stack = []
        elif level > 1:
            stack = stack[: level - 1]

        if name.endswith("/"):
            directory = name[:-1]
            stack = stack[: level - 1] + [directory]
        else:
            files.append("/".join(stack + [name]))

    return files


def production_swift_files(root: Path) -> list[Path]:
    roots = [
        root / "Native" / "Ambitions",
        root / "Native" / "AmbitionsWidgetExtension",
        root / "Native" / "AmbitionsShareExtension",
        root / "Sources",
        root / "AppUI" / "Sources",
        root / "Packages" / "AmbitionsExperienceKernel" / "Sources",
    ]
    ignored_parts = {".build", "DerivedData", "Resources", "PreviewSupport", "Previews"}
    files: list[Path] = []
    for source_root in roots:
        if not source_root.exists():
            continue
        for path in source_root.rglob("*.swift"):
            relative_parts = set(path.relative_to(root).parts)
            if relative_parts & ignored_parts:
                continue
            if any(part.endswith(".xcodeproj") for part in relative_parts):
                continue
            files.append(path)
    return sorted(files)


def relative(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def is_build_included(root: Path, path: Path) -> bool:
    rel = relative(root, path)
    if rel.startswith("Native/Ambitions/"):
        return "/Resources/" not in rel and not rel.endswith("Support/Info.plist")
    if rel.startswith("Native/AmbitionsWidgetExtension/"):
        return True
    if rel.startswith("Native/AmbitionsShareExtension/"):
        return True
    if rel.startswith("Packages/AmbitionsDesignSystem/Sources/"):
        return True
    if rel.startswith("Packages/AmbitionsDesignSystem/AppUI/Sources/"):
        return True
    if rel.startswith("Packages/AmbitionsExperienceKernel/Sources/"):
        return True
    return False


def has_placeholder_only_contract(path: Path) -> bool:
    text = read_text(path)
    lowered = text.lower()
    if "placeholder-only" in lowered or "placeholder only" in lowered:
        return True
    meaningful_lines = [
        line.strip()
        for line in text.splitlines()
        if line.strip()
        and not line.strip().startswith("//")
        and not line.strip().startswith("/*")
        and not line.strip().startswith("*")
        and not line.strip().startswith("import ")
    ]
    if not meaningful_lines:
        return True
    declaration_pattern = re.compile(
        r"\b(struct|enum|class|actor|protocol|extension|func|let|var|typealias)\b"
    )
    return not any(declaration_pattern.search(line) for line in meaningful_lines)


def owner_for(canonical_path: str) -> str:
    return canonical_path.split("/", 1)[0] if "/" in canonical_path else canonical_path


def risk_for(owner: str) -> str:
    if owner in {"App", "Stage", "Core", "Projection"}:
        return "high"
    if owner in {"Surfaces", "Composer", "Trust", "Quality"}:
        return "medium"
    return "low"


def tests_covering(root: Path, stem: str, owner: str) -> str:
    test_roots = [root / "Native" / "AmbitionsTests", root / "Native" / "AmbitionsUITests"]
    haystack = f"{stem} {owner}".lower()
    matches = 0
    for test_root in test_roots:
        if not test_root.exists():
            continue
        for path in test_root.rglob("*.swift"):
            rel = relative(root, path).lower()
            if stem.lower() in rel or owner.lower() in rel:
                matches += 1
                continue
            text = read_text(path).lower()
            if stem.lower() in text or haystack in text:
                matches += 1
    return "covered-by-current-tests" if matches else "not-found"


def canonical_entry(
    *,
    root: Path,
    canonical_path: str,
    files_by_basename: dict[str, list[Path]],
) -> InventoryEntry:
    required = f"{FINAL_TREE_ROOT}/{canonical_path}"
    path = root / required
    owner = owner_for(canonical_path)
    basename = Path(canonical_path).name
    duplicates = [
        candidate
        for candidate in files_by_basename.get(basename, [])
        if candidate != path
    ]

    if path.exists():
        build_included = is_build_included(root, path)
        if has_placeholder_only_contract(path):
            status = PLACEHOLDER_ONLY
            migration_action = "rewrite with functional contract"
            proof_status = "source-present-unproven"
        elif not build_included:
            status = EXCLUDED_FROM_BUILD
            migration_action = "include in production target or move to approved test/generated owner"
            proof_status = "not-compiled"
        elif duplicates:
            status = DUPLICATE_OWNER_PRESENT
            migration_action = "merge duplicate ownership then delete obsolete owner"
            proof_status = "duplicate-source-unproven"
        else:
            status = IMPLEMENTED
            migration_action = "none"
            proof_status = "source-present"
        current_file = required
    elif duplicates:
        status = OBSOLETE_OWNER_PRESENT
        current_file = relative(root, duplicates[0])
        migration_action = f"move or rewrite {current_file} to {required}"
        build_included = is_build_included(root, duplicates[0])
        proof_status = "noncanonical-source-present"
    else:
        status = MISSING
        current_file = ""
        migration_action = f"create {required} with production responsibility"
        build_included = False
        proof_status = "absent"

    return InventoryEntry(
        required_path=required,
        status=status,
        owner=owner,
        current_file=current_file,
        migration_action=migration_action,
        risk=risk_for(owner),
        test_coverage=tests_covering(root, Path(canonical_path).stem, owner),
        proof_status=proof_status,
        build_included=build_included,
    )


def obsolete_entries(root: Path, canonical_required: set[str]) -> list[InventoryEntry]:
    entries: list[InventoryEntry] = []
    for path in production_swift_files(root):
        rel = relative(root, path)
        if rel in canonical_required:
            continue
        owner = rel.split("/")[2] if rel.startswith("Native/Ambitions/") and len(rel.split("/")) > 2 else rel.split("/", 1)[0]
        forbidden_path = any(rel == forbidden or rel.startswith(f"{forbidden}/") for forbidden in EXPLICIT_FORBIDDEN_PATHS)
        obsolete_owner = any(rel.startswith(f"{obsolete}/") for obsolete in OBSOLETE_OWNER_DIRS)
        text = read_text(path)
        transitional = TRANSITIONAL_TERMS.search(text) is not None
        if not (forbidden_path or obsolete_owner or transitional):
            continue
        if forbidden_path:
            action = "delete forbidden removed architecture after responsibility is migrated"
            proof = "forbidden-obsolete-path"
        elif obsolete_owner:
            action = "migrate responsibility into final architecture tree and delete old owner"
            proof = "obsolete-owner-source-present"
        else:
            action = "remove transitional ownership wording or migrate/delete transitional source"
            proof = "transitional-source-present"
        entries.append(
            InventoryEntry(
                required_path=rel,
                status=OBSOLETE_OWNER_PRESENT,
                owner=owner,
                current_file=rel,
                migration_action=action,
                risk="high" if forbidden_path or obsolete_owner else "medium",
                test_coverage=tests_covering(root, path.stem, owner),
                proof_status=proof,
                build_included=is_build_included(root, path),
            )
        )
    return entries


def build_inventory(root: Path, truth_file: Path) -> dict[str, object]:
    canonical_paths = canonical_file_paths(truth_file)
    production_files = production_swift_files(root)
    files_by_basename: dict[str, list[Path]] = {}
    for path in production_files:
        files_by_basename.setdefault(path.name, []).append(path)

    canonical_entries = [
        canonical_entry(root=root, canonical_path=path, files_by_basename=files_by_basename)
        for path in canonical_paths
    ]
    canonical_required = {entry.required_path for entry in canonical_entries}
    all_entries = canonical_entries + obsolete_entries(root, canonical_required)

    counts: dict[str, int] = {}
    for entry in all_entries:
        counts[entry.status] = counts.get(entry.status, 0) + 1

    blocking = sum(counts.get(status, 0) for status in BLOCKING_STATUSES)
    return {
        "summary": {
            "truth_file": relative(root, truth_file) if truth_file.is_relative_to(root) else truth_file.as_posix(),
            "final_tree_root": FINAL_TREE_ROOT,
            "canonical_required_files": len(canonical_entries),
            "entries": len(all_entries),
            "blocking_entries": blocking,
            "counts": counts,
            "green": blocking == 0,
        },
        "entries": [asdict(entry) for entry in all_entries],
    }


def print_summary(inventory: dict[str, object]) -> None:
    summary = inventory["summary"]
    assert isinstance(summary, dict)
    print("ambitions-architecture-inventory")
    print(f"truth_file={summary['truth_file']}")
    print(f"canonical_required_files={summary['canonical_required_files']}")
    print(f"entries={summary['entries']}")
    print(f"blocking_entries={summary['blocking_entries']}")
    counts = summary["counts"]
    assert isinstance(counts, dict)
    for status in sorted(counts):
        print(f"{status}={counts[status]}")
    print("GREEN final-tree parity achieved" if summary["green"] else "RED final-tree parity not achieved")


def run_self_test() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        truth = root / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md"
        truth.parent.mkdir(parents=True)
        truth.write_text(
            "\n".join(
                [
                    "## 17. Final Architecture Tree",
                    "```",
                    "Ambitions/",
                    "  App/",
                    "    AmbitionsApp.swift",
                    "  Stage/",
                    "    AmbitionsSurface.swift",
                    "  Surfaces/",
                    "    Today/",
                    "      TodaySurface.swift",
                    "```",
                ]
            ),
            encoding="utf-8",
        )

        app = root / "Native" / "Ambitions" / "App"
        stage = root / "Native" / "Ambitions" / "Stage"
        today = root / "Native" / "Ambitions" / "Surfaces" / "Today"
        app.mkdir(parents=True)
        stage.mkdir(parents=True)
        today.mkdir(parents=True)
        (app / "AmbitionsApp.swift").write_text("struct AmbitionsApp {}\n", encoding="utf-8")
        (stage / "AmbitionsSurface.swift").write_text("enum AmbitionsSurface { case today }\n", encoding="utf-8")

        missing_inventory = build_inventory(root, truth)
        statuses = {entry["required_path"]: entry["status"] for entry in missing_inventory["entries"]}
        assert statuses["Native/Ambitions/Surfaces/Today/TodaySurface.swift"] == MISSING

        (today / "TodaySurface.swift").write_text("// placeholder only\n", encoding="utf-8")
        placeholder_inventory = build_inventory(root, truth)
        statuses = {entry["required_path"]: entry["status"] for entry in placeholder_inventory["entries"]}
        assert statuses["Native/Ambitions/Surfaces/Today/TodaySurface.swift"] == PLACEHOLDER_ONLY

        (today / "TodaySurface.swift").write_text("struct TodaySurface {}\n", encoding="utf-8")
        (root / "Native" / "Ambitions" / "Features" / "Today").mkdir(parents=True)
        (root / "Native" / "Ambitions" / "Features" / "Today" / "TodayScreen.swift").write_text(
            "struct TodayScreen {}\n",
            encoding="utf-8",
        )
        obsolete_inventory = build_inventory(root, truth)
        obsolete_statuses = [
            entry["status"]
            for entry in obsolete_inventory["entries"]
            if entry["required_path"].endswith("Features/Today/TodayScreen.swift")
        ]
        assert obsolete_statuses == [OBSOLETE_OWNER_PRESENT]

        clean_feature = root / "Native" / "Ambitions" / "Features"
        for path in sorted(clean_feature.rglob("*.swift"), reverse=True):
            path.unlink()
        valid_inventory = build_inventory(root, truth)
        assert valid_inventory["summary"]["green"] is True

    print("ambitions-architecture-inventory self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Emit final-canon architecture inventory for Ambitions.")
    parser.add_argument("--json", action="store_true", help="Emit JSON inventory.")
    parser.add_argument("--root", type=Path, default=ROOT, help="Repository root.")
    parser.add_argument("--truth-file", type=Path, default=TRUTH_FILE, help="Product design truth file.")
    parser.add_argument("--self-test", action="store_true", help="Run inventory self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    root = args.root.resolve()
    truth_file = args.truth_file.resolve()
    inventory = build_inventory(root, truth_file)
    if args.json:
        print(json.dumps(inventory, indent=2))
    else:
        print_summary(inventory)

    return 0 if inventory["summary"]["green"] else 1


if __name__ == "__main__":
    sys.exit(main())
