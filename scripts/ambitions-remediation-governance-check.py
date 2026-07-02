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
    if "/Tests/" in path or path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/"):
        return False
    if path.startswith("Native/Ambitions/PreviewSupport/"):
        return False
    return path.startswith(PRODUCTION_SWIFT_ROOTS)


def is_local_runtime(path: str) -> bool:
    return path.startswith("Native/Ambitions/Core/LocalRuntimeOS/")


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


def governance_findings(args: argparse.Namespace) -> list[Finding]:
    changed = diff_changed_paths(args.base, not args.no_untracked)
    findings: list[Finding] = []
    deletion_present = source_deletion_present(changed)
    source_atlas_scope_changed = False

    for item in changed:
        path = item.path
        path_obj = Path(path)
        text = added_text(item, args.base)

        if item.status in {"A", "R"} and is_production_swift(path):
            if "+02" in path_obj.name or "+03" in path_obj.name:
                findings.append(
                    Finding(
                        "no-new-suffix-splits",
                        path,
                        "new +02/+03 split files are blocked by AMB-1658",
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

            if "SourceAtlas" in path or has_any(SOURCE_ATLAS_PATTERNS, text):
                source_atlas_scope_changed = True

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

    return findings


def self_test() -> int:
    assert is_production_swift("Native/Ambitions/App/AmbitionsApp.swift")
    assert not is_production_swift("Native/AmbitionsTests/AppTests.swift")
    assert not is_production_swift("Native/Ambitions/PreviewSupport/PreviewFixtures.swift")
    assert is_local_runtime("Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor.swift")
    assert not is_local_runtime("Native/Ambitions/Core/Runtime/CaptureService.swift")
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

    findings = governance_findings(args)
    payload = {
        "valid": not findings,
        "findingCount": len(findings),
        "findings": [asdict(finding) for finding in findings],
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
        return 0 if payload["valid"] else 1

    print("ambitions-remediation-governance-check")
    if findings:
        print(f"RED {len(findings)} remediation governance finding(s)")
        for finding in findings:
            print(f"[{finding.rule}] {finding.path}: {finding.detail}")
        return 1

    print("GREEN remediation governance guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
