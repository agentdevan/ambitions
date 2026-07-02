#!/usr/bin/env python3
"""Diff-scoped remediation governance guard for architecture cleanup work.

This guard enforces the AMB-1658 freeze rules against newly changed files. It
does not scan the whole repository as if existing AMB-1657 baseline debt were
already fixed.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

PRODUCTION_SWIFT_ROOTS = (
    "Native/Ambitions/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
    "Sources/",
    "AppUI/Sources/",
    "Packages/AmbitionsExperienceKernel/Sources/",
)

NON_RUNTIME_MUTATION_TERMS = (
    "Command",
    "Event",
    "Receipt",
    "Replay",
    "Mutation",
    "Transaction",
    "Ledger",
    "Store",
    "Repository",
    "Persistence",
    "SideEffect",
)

ARCHITECTURE_NOUNS = (
    "Engine",
    "Kernel",
    "System",
    "Runtime",
    "Service",
    "Ledger",
    "Manager",
    "Coordinator",
    "Lens",
    "Scene",
    "OS",
)

MUTATION_WRITE_PATTERNS = (
    r"\bimport\s+SwiftData\b",
    r"\bModelContext\b",
    r"\bFileManager\b",
    r"\bUserDefaults\b",
    r"\.write\s*\(",
    r"\.save\s*\(",
    r"\.insert\s*\(",
    r"\.delete\s*\(",
    r"\btry\s+(?:await\s+)?[A-Za-z0-9_\.]*save\s*\(",
)

CUSTOM_STAGE_PATTERNS = (
    r"\bimport\s+UIKit\b",
    r"\bUIViewRepresentable\b",
    r"\bUIViewControllerRepresentable\b",
    r"\bCALayer\b",
    r"\bCADisplayLink\b",
    r"\bCoreAnimation\b",
)

SOURCE_ATLAS_PATTERNS = (
    r"\bSourceAtlas\b",
    r"\bSource Atlas\b",
    r"\bR2\b",
)

SWIFT_HARD_LINE_CAP = 600
LARGEST_FILE_REPORT_LIMIT = 10


@dataclass(frozen=True)
class ChangedPath:
    status: str
    path: str
    old_path: str | None = None
    untracked: bool = False


@dataclass(frozen=True)
class Finding:
    rule: str
    path: str
    detail: str


def run_git(args: list[str]) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def parse_name_status(output: str) -> list[ChangedPath]:
    changed: list[ChangedPath] = []
    for raw in output.splitlines():
        if not raw.strip():
            continue
        parts = raw.split("\t")
        status = parts[0]
        code = status[0]
        if code in {"R", "C"} and len(parts) >= 3:
            changed.append(ChangedPath(code, parts[2], parts[1]))
        elif len(parts) >= 2:
            changed.append(ChangedPath(code, parts[1]))
    return changed


def diff_changed_paths(base: str | None, include_untracked: bool) -> list[ChangedPath]:
    args = ["diff", "--name-status", "-M", "--diff-filter=ACMRD"]
    if base:
        args.extend([base, "HEAD", "--"])
    else:
        args.extend(["HEAD", "--"])
    changed = parse_name_status(run_git(args))

    if include_untracked:
        for raw in run_git(["ls-files", "--others", "--exclude-standard"]).splitlines():
            if raw:
                changed.append(ChangedPath("A", raw, untracked=True))

    deduped: dict[str, ChangedPath] = {}
    for item in changed:
        deduped[item.path] = item
    return sorted(deduped.values(), key=lambda item: item.path)


def added_lines(path: str, base: str | None, untracked: bool) -> list[str]:
    full_path = ROOT / path
    if untracked:
        if full_path.exists() and full_path.is_file():
            return full_path.read_text(encoding="utf-8", errors="replace").splitlines()
        return []

    args = ["diff", "--unified=0"]
    if base:
        args.extend([base, "HEAD", "--", path])
    else:
        args.extend(["HEAD", "--", path])
    try:
        diff = run_git(args)
    except subprocess.CalledProcessError:
        return []

    lines: list[str] = []
    for raw in diff.splitlines():
        if raw.startswith("+++") or not raw.startswith("+"):
            continue
        lines.append(raw[1:])
    return lines


def is_swift(path: str) -> bool:
    return path.endswith(".swift")


def is_production_swift(path: str) -> bool:
    if not is_swift(path):
        return False
    if "Previews" in Path(path).parts:
        return False
    if "/Tests/" in path or path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/"):
        return False
    if path.startswith("Native/Ambitions/PreviewSupport/"):
        return False
    return path.startswith(PRODUCTION_SWIFT_ROOTS)


def is_local_runtime(path: str) -> bool:
    return path.startswith("Native/Ambitions/Core/LocalRuntimeOS/")


def is_suffix_split_name(name: str) -> bool:
    return any(suffix in name for suffix in ("+02", "+03", "+04"))


def has_any(patterns: tuple[str, ...], text: str) -> bool:
    return any(re.search(pattern, text) for pattern in patterns)


def added_text(item: ChangedPath, base: str | None) -> str:
    return "\n".join(added_lines(item.path, base, item.untracked))


def source_deletion_present(changed: list[ChangedPath]) -> bool:
    for item in changed:
        if item.status == "D" and is_production_swift(item.path):
            return True
        if item.status == "R" and item.old_path and is_production_swift(item.old_path):
            return True
    return False


def production_swift_files() -> list[Path]:
    files: list[Path] = []
    for prefix in PRODUCTION_SWIFT_ROOTS:
        root = ROOT / prefix
        if not root.exists():
            continue
        if root.is_file() and root.suffix == ".swift":
            files.append(root)
            continue
        for path in root.rglob("*.swift"):
            relative = rel(path)
            if is_production_swift(relative):
                files.append(path)
    return sorted(set(files))


def swift_line_count(path: Path) -> int:
    text = path.read_text(encoding="utf-8", errors="replace")
    return text.count("\n") + (0 if text.endswith("\n") else 1)


def source_root(relative: str) -> str:
    parts = Path(relative).parts
    if relative.startswith("Native/Ambitions/") and len(parts) >= 3:
        return "/".join(parts[:3])
    if relative.startswith("Native/AmbitionsWidgetExtension/"):
        return "Native/AmbitionsWidgetExtension"
    if relative.startswith("Native/AmbitionsShareExtension/"):
        return "Native/AmbitionsShareExtension"
    if relative.startswith("AppUI/Sources/"):
        return "AppUI/Sources"
    if relative.startswith("Packages/AmbitionsExperienceKernel/Sources/"):
        return "Packages/AmbitionsExperienceKernel/Sources"
    if relative.startswith("Sources/") and len(parts) >= 2:
        return "Sources" if len(parts) == 2 else "/".join(parts[:2])
    return parts[0] if parts else relative


def is_source_atlas_scope(path: str, text: str) -> bool:
    if path.startswith("docs/adr/"):
        return False
    lowered_path = path.lower()
    if (
        "sourceatlas" in lowered_path
        or "source-atlas" in lowered_path
        or "source_atlas" in lowered_path
        or "SOURCE_ATLAS" in path
    ):
        return True
    return is_production_swift(path) and has_any(SOURCE_ATLAS_PATTERNS, text)


def parse_source_atlas_allowlist(text: str) -> set[str]:
    allowlist: set[str] = set()
    for line in text.splitlines():
        if "Source Atlas growth allowlist:" not in line:
            continue
        _, raw_value = line.split("Source Atlas growth allowlist:", 1)
        raw_value = raw_value.strip()
        if not raw_value:
            continue
        path_match = re.search(r"`([^`]+)`", raw_value)
        value = path_match.group(1) if path_match else raw_value.split()[0]
        allowlist.add(value.rstrip(".,;"))
    return allowlist


def source_atlas_adr_allowlist() -> set[str]:
    allowlist: set[str] = set()
    adr_root = ROOT / "docs" / "adr"
    if not adr_root.exists():
        return allowlist
    for path in sorted(adr_root.glob("*.md")):
        allowlist.update(parse_source_atlas_allowlist(path.read_text(encoding="utf-8", errors="replace")))
    return allowlist


def governance_report(changed: list[ChangedPath]) -> dict[str, object]:
    root_loc: dict[str, dict[str, int]] = {}
    largest: list[dict[str, object]] = []
    naming_counts = {
        "suffixSplitFiles": 0,
        "blockedSuffixSplitFiles": 0,
        "broadModelsFiles": 0,
        "architectureNounFiles": 0,
        "sourceAtlasFiles": 0,
        "overHardLineCapFiles": 0,
    }

    swift_files = production_swift_files()
    for path in swift_files:
        relative = rel(path)
        line_count = swift_line_count(path)
        root = source_root(relative)
        root_entry = root_loc.setdefault(root, {"files": 0, "loc": 0})
        root_entry["files"] += 1
        root_entry["loc"] += line_count

        largest.append({"path": relative, "lines": line_count})

        name = path.name
        if re.search(r"\+\d{2}", name):
            naming_counts["suffixSplitFiles"] += 1
        if is_suffix_split_name(name):
            naming_counts["blockedSuffixSplitFiles"] += 1
        if name == "Models.swift":
            naming_counts["broadModelsFiles"] += 1
        if any(noun in path.stem for noun in ARCHITECTURE_NOUNS):
            naming_counts["architectureNounFiles"] += 1
        if is_source_atlas_scope(relative, path.read_text(encoding="utf-8", errors="replace")):
            naming_counts["sourceAtlasFiles"] += 1
        if line_count > SWIFT_HARD_LINE_CAP:
            naming_counts["overHardLineCapFiles"] += 1

    largest = sorted(largest, key=lambda row: (-int(row["lines"]), str(row["path"])))[:LARGEST_FILE_REPORT_LIMIT]
    sorted_root_loc = {
        root: root_loc[root]
        for root in sorted(root_loc, key=lambda key: (-root_loc[key]["loc"], key))
    }
    return {
        "changedPathCount": len(changed),
        "productionSwiftFileCount": len(swift_files),
        "rootLOC": sorted_root_loc,
        "largestFiles": largest,
        "namingCounts": naming_counts,
        "swiftHardLineCap": SWIFT_HARD_LINE_CAP,
    }


def check_source_atlas_audits() -> list[Finding]:
    findings: list[Finding] = []
    for script in [
        "scripts/source-atlas-boundary-audit.py",
        "scripts/source-atlas-no-private-graph-egress-audit.py",
    ]:
        result = subprocess.run(
            [sys.executable, script],
            cwd=ROOT,
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode != 0:
            output = "\n".join(part for part in [result.stdout, result.stderr] if part).strip()
            findings.append(
                Finding(
                    "source-atlas-boundary",
                    script,
                    output[:300] if output else "Source Atlas boundary audit failed",
                )
            )
    return findings


def source_atlas_growth_guard(
    item: ChangedPath,
    text: str,
    source_atlas_allowlist: set[str],
) -> tuple[bool, Finding | None]:
    if not is_source_atlas_scope(item.path, text):
        return False, None
    if item.status in {"A", "R"} and item.path not in source_atlas_allowlist:
        return True, Finding(
            "source-atlas-growth-adr",
            item.path,
            "new Source Atlas scope requires ADR allowlist line: Source Atlas growth allowlist: `path/to/file`",
        )
    return True, None


def check_legacy_runtime_guard(args: argparse.Namespace) -> list[Finding]:
    command = [sys.executable, "scripts/ambitions-legacy-runtime-production-use-guard.py"]
    if args.base:
        command.extend(["--base", args.base])
    if args.no_untracked:
        command.append("--no-untracked")

    result = subprocess.run(
        command,
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode == 0:
        return []

    output = "\n".join(part for part in [result.stdout, result.stderr] if part).strip()
    return [
        Finding(
            "legacy-runtime-production-use-guard",
            "scripts/ambitions-legacy-runtime-production-use-guard.py",
            output[:300] if output else "legacy runtime production-use guard failed",
        )
    ]


def governance_findings(args: argparse.Namespace) -> list[Finding]:
    changed = diff_changed_paths(args.base, not args.no_untracked)
    findings: list[Finding] = []
    deletion_present = source_deletion_present(changed)
    source_atlas_scope_changed = False
    source_atlas_allowlist = source_atlas_adr_allowlist()

    for item in changed:
        path = item.path
        path_obj = Path(path)
        text = added_text(item, args.base)

        if item.status in {"A", "R"} and is_production_swift(path):
            if is_suffix_split_name(path_obj.name):
                findings.append(
                    Finding(
                        "no-new-suffix-splits",
                        path,
                        "new +02/+03/+04 split files are blocked by AMB-1658/AMB-1662",
                    )
                )

            if path_obj.name == "Models.swift":
                findings.append(
                    Finding(
                        "no-new-broad-models",
                        path,
                        "new broad Models.swift files are blocked by AMB-1658",
                    )
                )

            if any(noun in path_obj.stem for noun in ARCHITECTURE_NOUNS) and not deletion_present:
                findings.append(
                    Finding(
                        "delete-before-naming",
                        path,
                        "new architecture noun in source filename requires deletion/collapse evidence in the same diff",
                    )
                )

            if path.startswith("Native/Ambitions/Projection/SurfaceLenses/") and not args.allow_central_lens:
                findings.append(
                    Finding(
                        "feature-local-projection",
                        path,
                        "new central SurfaceLenses files require explicit canon exception or feature-local projection proof",
                    )
                )

        if is_production_swift(path):
            full_path = ROOT / path
            if item.status != "D" and full_path.exists():
                line_count = swift_line_count(full_path)
                if line_count > SWIFT_HARD_LINE_CAP:
                    findings.append(
                        Finding(
                            "swift-file-size-cap",
                            path,
                            f"{line_count} lines exceeds diff-scoped hard cap {SWIFT_HARD_LINE_CAP}",
                        )
                    )

            if (path.startswith("Native/Ambitions/Stage/") or path.startswith("Native/Ambitions/Surfaces/") or path.startswith("Native/Ambitions/Composer/") or path.startswith("Native/Ambitions/DesignSystem/")) and has_any(CUSTOM_STAGE_PATTERNS, text):
                findings.append(
                    Finding(
                        "swiftui-native-default",
                        path,
                        "new UIKit/custom rendering additions require explicit product-law and Apple-source justification",
                    )
                )

            type_pattern = r"\b(struct|class|actor|enum|protocol)\s+\w*(?:" + "|".join(NON_RUNTIME_MUTATION_TERMS) + r")\w*"
            if not is_local_runtime(path) and (re.search(type_pattern, text) or has_any(MUTATION_WRITE_PATTERNS, text)):
                findings.append(
                    Finding(
                        "no-new-mutation-authority-outside-localruntimeos",
                        path,
                        "new mutation/storage/receipt authority markers outside Core/LocalRuntimeOS require a scoped Yellow exception and follow-up",
                    )
                )

            if "adapter" in path.lower() and has_any(MUTATION_WRITE_PATTERNS, text):
                findings.append(
                    Finding(
                        "adapters-cannot-mutate-canonical-state",
                        path,
                        "adapter changes include write/persistence markers",
                    )
                )

        changed_source_atlas_scope, source_atlas_growth_finding = source_atlas_growth_guard(
            item,
            text,
            source_atlas_allowlist,
        )
        if changed_source_atlas_scope:
            source_atlas_scope_changed = True
        if source_atlas_growth_finding:
            findings.append(source_atlas_growth_finding)

        package_boundary_text = text if path == "project.yml" else path
        project_package_boundary = path == "project.yml" and has_any(
            (
                r"^\s*packages\s*:",
                r"^\s*package\s*:",
                r"\bPackages/",
                r"\bpath:\s*Packages/",
                r"\bproduct\s*:",
            ),
            package_boundary_text,
        )
        if (
            path == "Package.swift"
            or project_package_boundary
            or path.startswith("Packages/")
            or path.startswith("AppUI/Package.swift")
        ) and not args.allow_package_boundary:
            findings.append(
                Finding(
                    "no-package-extraction-theater",
                    path,
                    "package/project boundary changes require a linked package boundary decision and explicit validation",
                )
            )

    if source_atlas_scope_changed:
        findings.extend(check_source_atlas_audits())

    findings.extend(check_legacy_runtime_guard(args))

    return findings


def self_test() -> int:
    assert is_production_swift("Native/Ambitions/App/AmbitionsApp.swift")
    assert not is_production_swift("Native/AmbitionsTests/AppTests.swift")
    assert not is_production_swift("Native/Ambitions/PreviewSupport/PreviewFixtures.swift")
    assert not is_production_swift("Sources/Previews/ThemePreview.swift")
    assert is_local_runtime("Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor.swift")
    assert not is_local_runtime("Native/Ambitions/Core/Runtime/CaptureService.swift")
    assert is_suffix_split_name("SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift")
    assert not is_suffix_split_name("SourceAtlasPackModels+06-SourceAtlasPack.swift")
    allowlist = parse_source_atlas_allowlist("- Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/NewPack.swift`")
    assert "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/NewPack.swift" in allowlist
    source_atlas_new_file = ChangedPath(
        "A",
        "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/NewPack.swift",
        untracked=True,
    )
    changed_scope, finding = source_atlas_growth_guard(
        source_atlas_new_file,
        "struct SourceAtlasNewPack {}",
        set(),
    )
    assert changed_scope
    assert finding is not None
    assert finding.rule == "source-atlas-growth-adr"
    changed_scope, finding = source_atlas_growth_guard(
        source_atlas_new_file,
        "struct SourceAtlasNewPack {}",
        {"Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/NewPack.swift"},
    )
    assert changed_scope
    assert finding is None
    changed_scope, finding = source_atlas_growth_guard(
        ChangedPath("A", "docs/adr/ADR-2099-source-atlas-test.md", untracked=True),
        "Source Atlas growth allowlist: `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/NewPack.swift`",
        set(),
    )
    assert not changed_scope
    assert finding is None
    assert check_legacy_runtime_guard(argparse.Namespace(base=None, no_untracked=True)) == []
    print("ambitions-remediation-governance-check self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Check AMB-1658 remediation governance rules against changed files.")
    parser.add_argument("--base", help="Optional base commit/ref for branch-style validation.")
    parser.add_argument("--no-untracked", action="store_true", help="Ignore untracked files.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--allow-package-boundary", action="store_true", help="Allow package/project boundary changes after a linked decision record.")
    parser.add_argument("--allow-central-lens", action="store_true", help="Allow new central SurfaceLenses files after a canon exception.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    changed = diff_changed_paths(args.base, not args.no_untracked)
    findings = governance_findings(args)
    report = governance_report(changed)
    payload = {
        "valid": not findings,
        "findingCount": len(findings),
        "findings": [asdict(finding) for finding in findings],
        "report": report,
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
        return 0 if payload["valid"] else 1

    print("ambitions-remediation-governance-check")
    print(f"changed_paths={report['changedPathCount']}")
    print(f"production_swift_files={report['productionSwiftFileCount']}")
    print(f"swift_hard_line_cap={report['swiftHardLineCap']}")
    print("root_loc:")
    for root, data in report["rootLOC"].items():
        print(f"  {root}: files={data['files']} loc={data['loc']}")
    print("largest_files:")
    for row in report["largestFiles"]:
        print(f"  {row['lines']} {row['path']}")
    print("naming_counts:")
    for key, value in report["namingCounts"].items():
        print(f"  {key}={value}")
    if findings:
        print(f"RED {len(findings)} remediation governance finding(s)")
        for finding in findings:
            print(f"[{finding.rule}] {finding.path}: {finding.detail}")
        return 1

    print("GREEN remediation governance guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
