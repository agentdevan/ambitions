#!/usr/bin/env python3
"""AMB-1715/AMB-1716 guard for legacy Core/Runtime production use.

This is a retained audit guard, not runtime proof. It preserves the active
Yellow baseline while reporting new production owner growth under
Native/Ambitions/Core/Runtime and blocked reintroduction of retired owners.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEGACY_RUNTIME_ROOT = ROOT / "Native" / "Ambitions" / "Core" / "Runtime"
LEGACY_RUNTIME_PREFIX = "Native/Ambitions/Core/Runtime/"
CLASSIFICATION_DOC = ROOT / "docs" / "audits" / "legacy-runtime-strangler-classification.md"
MAX_LEGACY_RUNTIME_PRODUCTION_FILES = 111

AMB_1714_RETIRED_LEGACY_PATHS = {
    "Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift",
    "Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift",
    "Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift",
}

AMB_1716_RETIRED_LEGACY_PATHS = {
    "Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift",
}

RETIRED_LEGACY_RUNTIME_PATHS = AMB_1714_RETIRED_LEGACY_PATHS | AMB_1716_RETIRED_LEGACY_PATHS

PRODUCTION_SWIFT_ROOTS = (
    "Native/Ambitions/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
    "Sources/",
    "AppUI/Sources/",
    "Packages/AmbitionsExperienceKernel/Sources/",
)

TEST_OR_PREVIEW_PREFIXES = (
    "Native/AmbitionsTests/",
    "Native/AmbitionsUITests/",
    "Native/Ambitions/PreviewSupport/",
)

LEGACY_RUNTIME_REFERENCE_PATTERNS = (
    r"Native/Ambitions/Core/Runtime",
    r"\bCore/Runtime\b",
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


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def run_git(args: list[str]) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


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


def is_test_or_preview_path(path: str) -> bool:
    return path.startswith(TEST_OR_PREVIEW_PREFIXES) or "/Tests/" in path


def is_production_swift(path: str) -> bool:
    if not is_swift(path):
        return False
    if is_test_or_preview_path(path):
        return False
    return path.startswith(PRODUCTION_SWIFT_ROOTS)


def baseline_legacy_runtime_paths() -> set[str]:
    text = CLASSIFICATION_DOC.read_text(encoding="utf-8", errors="replace")
    paths = set(
        re.findall(
            r"\|\s*`(Native/Ambitions/Core/Runtime/[^`]+\.swift)`\s*\|",
            text,
        )
    )
    return paths - RETIRED_LEGACY_RUNTIME_PATHS


def current_legacy_runtime_paths() -> set[str]:
    if not LEGACY_RUNTIME_ROOT.exists():
        return set()
    return {
        rel(path)
        for path in LEGACY_RUNTIME_ROOT.rglob("*.swift")
        if path.is_file()
    }


def contains_legacy_runtime_reference(text: str) -> bool:
    return any(re.search(pattern, text) for pattern in LEGACY_RUNTIME_REFERENCE_PATTERNS)


def reference_finding_for_path_text(path: str, text: str) -> Finding | None:
    if not text or not contains_legacy_runtime_reference(text):
        return None
    if is_test_or_preview_path(path):
        return None
    if is_production_swift(path) and not path.startswith(LEGACY_RUNTIME_PREFIX):
        return Finding(
            "new-production-core-runtime-reference",
            path,
            "new production Swift lines explicitly reference Core/Runtime; route through LocalRuntimeOS or a named test-only support path",
        )
    return None


def explicit_reference_findings(changed: list[ChangedPath], base: str | None) -> tuple[list[Finding], list[str]]:
    findings: list[Finding] = []
    allowed_test_or_preview_paths: list[str] = []

    for item in changed:
        path = item.path
        if not is_swift(path):
            continue
        text = "\n".join(added_lines(path, base, item.untracked))
        if not text or not contains_legacy_runtime_reference(text):
            continue
        if is_test_or_preview_path(path):
            allowed_test_or_preview_paths.append(path)
            continue
        finding = reference_finding_for_path_text(path, text)
        if finding:
            findings.append(finding)

    return findings, sorted(set(allowed_test_or_preview_paths))


def legacy_owner_findings(baseline: set[str], current: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    if len(baseline) > MAX_LEGACY_RUNTIME_PRODUCTION_FILES:
        findings.append(
            Finding(
                "legacy-runtime-baseline-growth",
                str(CLASSIFICATION_DOC.relative_to(ROOT)),
                f"parsed baseline has {len(baseline)} files; active legacy runtime ceiling is {MAX_LEGACY_RUNTIME_PRODUCTION_FILES}",
            )
        )

    if len(current) > MAX_LEGACY_RUNTIME_PRODUCTION_FILES:
        findings.append(
            Finding(
                "legacy-runtime-count-increase",
                LEGACY_RUNTIME_PREFIX,
                f"current legacy runtime file count is {len(current)}; active legacy runtime ceiling is {MAX_LEGACY_RUNTIME_PRODUCTION_FILES}",
            )
        )

    for path in sorted(current - baseline):
        findings.append(
            Finding(
                "new-legacy-runtime-owner",
                path,
                "new production Swift under Core/Runtime is blocked by AMB-1715; move to LocalRuntimeOS or test-only support",
            )
        )

    for path in sorted(current & RETIRED_LEGACY_RUNTIME_PATHS):
        findings.append(
            Finding(
                "retired-legacy-runtime-owner-reintroduced",
                path,
                "AMB-1714 or AMB-1716 retired this legacy owner path; reintroduction is blocked",
            )
        )

    return findings


def guard_findings(changed: list[ChangedPath], base: str | None) -> tuple[list[Finding], list[str], set[str], set[str]]:
    findings: list[Finding] = []
    try:
        baseline = baseline_legacy_runtime_paths()
    except FileNotFoundError:
        return (
            [
                Finding(
                    "legacy-runtime-baseline-missing",
                    str(CLASSIFICATION_DOC.relative_to(ROOT)),
                    "AMB-1713 legacy runtime classification baseline is missing",
                )
            ],
            [],
            set(),
            current_legacy_runtime_paths(),
        )

    current = current_legacy_runtime_paths()
    if not baseline:
        findings.append(
            Finding(
                "legacy-runtime-baseline-empty",
                str(CLASSIFICATION_DOC.relative_to(ROOT)),
                "AMB-1715 guard could not parse the AMB-1713 baseline table",
            )
        )

    findings.extend(legacy_owner_findings(baseline, current))

    reference_findings, allowed_test_or_preview_paths = explicit_reference_findings(changed, base)
    findings.extend(reference_findings)
    return findings, allowed_test_or_preview_paths, baseline, current


def self_test() -> int:
    assert is_production_swift("Native/Ambitions/App/AmbitionsApp.swift")
    assert not is_production_swift("Native/AmbitionsTests/Runtime/RuntimeTests.swift")
    assert not is_production_swift("Native/Ambitions/PreviewSupport/PreviewRuntime.swift")
    assert contains_legacy_runtime_reference("Native/Ambitions/Core/Runtime/Foo.swift")
    assert contains_legacy_runtime_reference("Core/Runtime")
    assert not contains_legacy_runtime_reference("Core/LocalRuntimeOS")
    baseline = baseline_legacy_runtime_paths()
    assert "Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift" not in baseline
    assert "Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift" not in baseline
    assert len(baseline) <= MAX_LEGACY_RUNTIME_PRODUCTION_FILES
    synthetic_findings = legacy_owner_findings(
        {"Native/Ambitions/Core/Runtime/ExistingRuntime.swift"},
        {
            "Native/Ambitions/Core/Runtime/ExistingRuntime.swift",
            "Native/Ambitions/Core/Runtime/NewRuntime.swift",
            "Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift",
        },
    )
    assert any(finding.rule == "new-legacy-runtime-owner" for finding in synthetic_findings)
    assert any(finding.rule == "retired-legacy-runtime-owner-reintroduced" for finding in synthetic_findings)
    assert reference_finding_for_path_text(
        "Native/Ambitions/App/NewProductionUse.swift",
        "let legacyPath = \"Native/Ambitions/Core/Runtime/CaptureService.swift\"",
    )
    assert not reference_finding_for_path_text(
        "Native/AmbitionsTests/Runtime/NewRuntimeTest.swift",
        "let legacyPath = \"Native/Ambitions/Core/Runtime/CaptureService.swift\"",
    )
    print("ambitions-legacy-runtime-production-use-guard self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Guard AMB-1715 legacy Core/Runtime production-use baseline.")
    parser.add_argument("--base", help="Optional base commit/ref for branch-style validation.")
    parser.add_argument("--no-untracked", action="store_true", help="Ignore untracked files.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    changed = diff_changed_paths(args.base, not args.no_untracked)
    findings, allowed_test_or_preview_paths, baseline, current = guard_findings(changed, args.base)
    payload = {
        "valid": not findings,
        "findingCount": len(findings),
        "findings": [asdict(finding) for finding in findings],
        "baselineLegacyRuntimeFiles": len(baseline),
        "currentLegacyRuntimeFiles": len(current),
        "legacyRuntimeFileCeiling": MAX_LEGACY_RUNTIME_PRODUCTION_FILES,
        "allowedTestOrPreviewReferencePaths": allowed_test_or_preview_paths,
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
        return 0 if payload["valid"] else 1

    print("ambitions-legacy-runtime-production-use-guard")
    print(f"baseline_legacy_runtime_files={payload['baselineLegacyRuntimeFiles']}")
    print(f"current_legacy_runtime_files={payload['currentLegacyRuntimeFiles']}")
    print(f"legacy_runtime_file_ceiling={payload['legacyRuntimeFileCeiling']}")
    if allowed_test_or_preview_paths:
        print("allowed_test_or_preview_reference_paths:")
        for path in allowed_test_or_preview_paths:
            print(f"  {path}")
    if findings:
        print(f"RED {len(findings)} legacy runtime production-use finding(s)")
        for finding in findings:
            print(f"[{finding.rule}] {finding.path}: {finding.detail}")
        return 1

    print("GREEN legacy runtime production-use guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
