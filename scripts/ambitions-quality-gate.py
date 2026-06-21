#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass, asdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

PRODUCTION_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Native" / "AmbitionsWidgetExtension",
    ROOT / "Native" / "AmbitionsShareExtension",
    ROOT / "Sources",
    ROOT / "AppUI" / "Sources",
    ROOT / "Packages" / "AmbitionsExperienceKernel" / "Sources",
]

EXCLUDED_PATH_PARTS = {
    ".build",
    "DerivedData",
    "Resources",
    "PreviewSupport",
    "Previews",
}

REQUIRED_ARCHITECTURE_PATHS = [
    "scripts/ambitions-architecture-inventory.py",
    "scripts/ambitions-master-sequencing-check.py",
    "scripts/lifeshape-linear-control-plane-check.py",
    "Native/Ambitions/Language/ProductCopy.swift",
    "Native/Ambitions/Language/ForbiddenTopLevelTerms.swift",
    "Native/Ambitions/Quality/QualityGateChecklist.swift",
    "Native/Ambitions/Quality/SnapshotMatrix.swift",
    "Native/Ambitions/Quality/AccessibilityAudit.swift",
    "Native/Ambitions/Quality/PerformanceBudgets.swift",
    "Native/Ambitions/Quality/VisualRegressionHarness.swift",
    "Native/Ambitions/Quality/MotionReductionAudit.swift",
    "Native/Ambitions/Quality/ShellChromeAudit.swift",
    "Native/Ambitions/Quality/ForbiddenLanguageAudit.swift",
    "Native/Ambitions/Quality/SafeAreaAudit.swift",
    "Native/Ambitions/Quality/DynamicTypeAudit.swift",
    "Native/Ambitions/Scenarios/RuntimeScenario.swift",
    "Native/Ambitions/Scenarios/ScenarioCatalog.swift",
    "Native/Ambitions/Scenarios/ScenarioMatrix.swift",
    "docs/validation/master_lifeshape_foldin_ledger.md",
    "docs/validation/lifeshape_control_plane_ledger.md",
    "scripts/ambitions-quality-gate.sh",
]

FORBIDDEN_PATHS = [
    "Native/Ambitions/Surfaces/Capture",
    "Native/Ambitions/Surfaces/Motion",
    "Native/Ambitions/Projection/SurfaceLenses/MotionLens.swift",
    "Native/Ambitions/Projection/StageScenes/MotionStageScene.swift",
    "Native/Ambitions/Scenarios/MotionScenarios.swift",
    "Native/Ambitions/RootTab.swift",
]

FINAL_TREE_BLOCKING_STATUSES = {
    "missing",
    "obsolete-owner-present",
    "duplicate-owner-present",
    "excluded-from-build",
    "placeholder-only",
}

FORBIDDEN_ROUTE_PATTERNS = [
    r"ambitions://tab/capture",
    r"ambitions://tab/captures",
    r"ambitions://tab/motion",
    r"ambitions://tab/plan",
    r"ambitions://captures",
    r"ambitions://plan",
    r"captures_inbox",
    r"captures-inbox",
    r"openCapturesInbox",
    r"motionQuickCapture",
    r"capturesScreen",
    r"LegacyIARouteCompatibility",
]

FORBIDDEN_STRING_PATTERNS = [
    r"\bPlan tab\b",
    r"\bPlan screen\b",
    r"\btop-level Plan\b",
    r"\bProfile tab\b",
    r"\bCapture tab\b",
    r"\bMotion tab\b",
    r"\bCaptures tab\b",
    r"\bnext best move\b",
    r"\bbest next move\b",
    r"\bBegin Focus\b",
    r"\bAI confidence\b",
    r"\bproductivity score\b",
    r"\bdebug console\b",
]

TRANSITIONAL_OWNERSHIP_PATTERNS = [
    r"\badapter\b",
    r"\bshim\b",
    r"\btransitional\b",
    r"\btemporary\b",
    r"\bcompatibility\b",
    r"\blegacy\b",
]

DIRECT_TIME_RENDERING_PATTERNS = [
    r"\bDate\s*\(\s*\)",
    r"\bCalendar\.current\b",
    r"\bDateFormatter\s*\(",
]

HOSTED_AI_BACKEND_PATTERNS = [
    r"\bOpenAI\b",
    r"\bChatGPT\b",
    r"\bGPT\b",
    r"\bLLM\b",
    r"\bcloud model\b",
    r"\bhosted AI\b",
    r"\bserver-side profiling\b",
    r"\bprivate life graph backend\b",
    r"\bR2\b.*\b(goals?|captures?|calendar data|receipts?|proof|private life graph)\b",
    r"\b(goals?|captures?|calendar data|receipts?|proof|private life graph)\b.*\bR2\b",
]

RAW_DESIGN_LITERAL_PATTERNS = [
    r"\bColor\s*\(",
    r"\.foregroundColor\s*\(",
    r"\.font\s*\(\s*\.system",
    r"\.cornerRadius\s*\(",
    r"RoundedRectangle\s*\(\s*cornerRadius\s*:",
    r"\.shadow\s*\(",
    r"\.animation\s*\(",
    r"\.spring\s*\(",
    r"\.easeIn",
    r"\.easeOut",
    r"UIImpactFeedbackGenerator",
    r"\.sensoryFeedback\s*\(",
]

SHELL_POLICY_PATTERNS = [
    r"\.ignoresSafeArea\s*\(",
    r"\.safeAreaInset\s*\(",
    r"\.toolbar\s*\(",
    r"@FocusState",
    r"\.focused\s*\(",
    r"\.keyboardShortcut\s*\(",
    r"\.keyboardType\s*\(",
    r"\.submitLabel\s*\(",
    r"dock",
    r"crown",
    r"focus restoration",
]

SURFACE_OWNED_PATH_PREFIXES = (
    "Native/Ambitions/Surfaces/",
    "Native/Ambitions/Composer/",
    "Native/Ambitions/Features/",
)

STAGE_ALLOWED_PREFIXES = (
    "Native/Ambitions/Stage/",
    "Native/Ambitions/App/",
    "Native/Ambitions/DesignSystem/",
    "Sources/",
)

DESIGN_ALLOWED_PREFIXES = (
    "Native/Ambitions/DesignSystem/",
    "Native/Ambitions/Rendering/",
    "Sources/Theme/",
    "Sources/Components/",
)


@dataclass(frozen=True)
class Finding:
    gate: str
    path: str
    detail: str


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run_git(args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        return ""
    return result.stdout


def changed_paths() -> set[str]:
    paths = set(run_git(["diff", "--name-only", "HEAD", "--"]).splitlines())
    status = run_git(["status", "--porcelain"]).splitlines()
    for line in status:
        if not line:
            continue
        candidate = line[3:] if len(line) > 3 else line
        if " -> " in candidate:
            candidate = candidate.split(" -> ", 1)[1]
        paths.add(candidate.strip())
    return {path for path in paths if path}


def is_excluded(path: Path) -> bool:
    relative_parts = set(path.relative_to(ROOT).parts)
    if relative_parts & EXCLUDED_PATH_PARTS:
        return True
    return any(part.endswith(".xcodeproj") for part in relative_parts)


def production_swift_files() -> list[Path]:
    files: list[Path] = []
    for root in PRODUCTION_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.swift"):
            if not is_excluded(path):
                files.append(path)
    return sorted(files)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def swift_enum_case_names(text: str, enum_name: str) -> list[str]:
    enum_match = re.search(rf"\benum\s+{re.escape(enum_name)}\b[^\{{]*\{{", text)
    if enum_match is None:
        return []

    cases: list[str] = []
    depth = 1
    for line in text[enum_match.end():].splitlines():
        stripped = line.split("//", 1)[0].strip()
        if depth == 1:
            case_match = re.match(r"case\s+(.+)$", stripped)
            if case_match is not None:
                for raw_case in case_match.group(1).split(","):
                    name_match = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)", raw_case)
                    if name_match is not None:
                        cases.append(name_match.group(1))
        depth += line.count("{") - line.count("}")
        if depth <= 0:
            break
    return cases


def line_count(text: str) -> int:
    return text.count("\n") + (0 if text.endswith("\n") else 1)


def is_swiftui_rendering_source(text: str) -> bool:
    return (
        "import SwiftUI" in text
        or re.search(r":\s*View\b", text) is not None
        or "some View" in text
    )


def swift_string_literals(text: str) -> list[str]:
    pattern = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
    return [match.group(1) for match in pattern.finditer(text)]


def add_regex_findings(
    findings: list[Finding],
    gate: str,
    path: Path,
    patterns: list[str],
    text: str,
    *,
    string_literals_only: bool = False,
) -> None:
    haystacks = swift_string_literals(text) if string_literals_only else text.splitlines()
    for index, haystack in enumerate(haystacks, start=1):
        for pattern in patterns:
            if re.search(pattern, haystack, flags=re.IGNORECASE):
                detail = f"{pattern} :: {haystack.strip()[:160]}"
                if not string_literals_only:
                    detail = f"line {index}: {detail}"
                findings.append(Finding(gate, rel(path), detail))
                break


def is_centralized_design_token_usage(line: str) -> bool:
    if "theme." not in line and "DAVMotionPreset." not in line:
        return False
    if re.search(r"\.font\s*\(\s*\.system", line):
        return re.search(r"size\s*:\s*theme\.icon\.", line) is not None
    if re.search(r"RoundedRectangle\s*\(\s*cornerRadius\s*:", line):
        return re.search(r"cornerRadius\s*:\s*theme\.radius\.", line) is not None
    if re.search(r"\.animation\s*\(", line):
        return "theme.motion.animation" in line or "DAVMotionPreset." in line
    return False


def add_design_token_findings(findings: list[Finding], path: Path, text: str) -> None:
    for index, line in enumerate(text.splitlines(), start=1):
        if is_centralized_design_token_usage(line):
            continue
        for pattern in RAW_DESIGN_LITERAL_PATTERNS:
            if re.search(pattern, line, flags=re.IGNORECASE):
                detail = f"line {index}: {pattern} :: {line.strip()[:160]}"
                findings.append(Finding("design-token", rel(path), detail))
                break


def check_architecture(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for required in REQUIRED_ARCHITECTURE_PATHS:
        if not (ROOT / required).exists():
            findings.append(Finding("architecture", required, "required quality/scenario/language contract is missing"))

    for forbidden in FORBIDDEN_PATHS:
        path = ROOT / forbidden
        if path.exists():
            findings.append(Finding("architecture", forbidden, "forbidden architecture path exists"))

    feature_files = [path for path in files if rel(path).startswith("Native/Ambitions/Features/")]
    for path in feature_files:
        text = read(path)
        if "AMBITION_FEATURE_SHIM" not in text:
            findings.append(Finding("architecture", rel(path), "legacy Features implementation remains without shim marker"))

    app_tab = ROOT / "Native" / "Ambitions" / "App" / "AppTab.swift"
    if app_tab.exists():
        cases = swift_enum_case_names(read(app_tab), "AppTab")
        if cases != ["today", "goals", "time", "you"]:
            findings.append(Finding("architecture", rel(app_tab), f"AppTab cases must be today/goals/time/you; found {cases}"))

    for path in files:
        relative = rel(path)
        text = read(path)
        if path.name == "RootTab.swift":
            findings.append(Finding("architecture", relative, "RootTab.swift is removed architecture"))
        if relative.startswith("Native/Ambitions/App/") and re.search(r"\bTabView\s*\(", text):
            findings.append(Finding("architecture", relative, "TabView appears in App root shell"))
        add_regex_findings(findings, "architecture", path, FORBIDDEN_ROUTE_PATTERNS, text)

    return findings


def final_tree_inventory_findings(entries: list[dict[str, object]]) -> list[Finding]:
    findings: list[Finding] = []
    for entry in entries:
        status = str(entry.get("status", ""))
        if status not in FINAL_TREE_BLOCKING_STATUSES:
            continue
        required_path = str(entry.get("required_path", "unknown"))
        current_file = str(entry.get("current_file", ""))
        migration_action = str(entry.get("migration_action", ""))
        detail = f"{status}"
        if current_file:
            detail += f"; current_file={current_file}"
        if migration_action:
            detail += f"; action={migration_action}"
        findings.append(Finding("final-tree-inventory", required_path, detail))
    return findings


def check_final_tree_inventory() -> list[Finding]:
    inventory_script = ROOT / "scripts" / "ambitions-architecture-inventory.py"
    if not inventory_script.exists():
        return [
            Finding(
                "final-tree-inventory",
                rel(inventory_script),
                "architecture inventory script is missing",
            )
        ]

    result = subprocess.run(
        [sys.executable, str(inventory_script), "--json"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError:
        return [
            Finding(
                "final-tree-inventory",
                rel(inventory_script),
                f"inventory JSON could not be parsed: {result.stderr.strip()[:240]}",
            )
        ]

    entries = payload.get("entries", [])
    if not isinstance(entries, list):
        return [
            Finding(
                "final-tree-inventory",
                rel(inventory_script),
                "inventory JSON missing entries list",
            )
        ]
    return final_tree_inventory_findings(entries)


def check_file_sizes(files: list[Path], changed: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        text = read(path)
        count = line_count(text)
        if count > 600:
            findings.append(Finding("file-size", relative, f"{count} lines exceeds production maximum 600"))
        if relative in changed and count > 400 and "AMBITIONS-QUALITY-EXTRACTION:" not in text:
            findings.append(Finding("file-size", relative, f"{count} touched lines exceeds 400 without extraction note"))
    return findings


def check_forbidden_language(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        if relative == "Native/Ambitions/Language/ForbiddenTopLevelTerms.swift":
            continue
        add_regex_findings(
            findings,
            "forbidden-language",
            path,
            FORBIDDEN_STRING_PATTERNS,
            read(path),
            string_literals_only=True,
        )
    return findings


def check_transitional_ownership_terms(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        if relative.startswith("Native/Ambitions/Language/ForbiddenTopLevelTerms.swift"):
            continue
        add_regex_findings(
            findings,
            "transitional-ownership",
            path,
            TRANSITIONAL_OWNERSHIP_PATTERNS,
            read(path),
            string_literals_only=False,
        )
    return findings


def check_temporal_rendering(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    allowed = (
        "Native/Ambitions/Core/Time/",
        "Native/Ambitions/Quality/",
        "Native/Ambitions/Scenarios/",
    )
    scanned_prefixes = (
        "Native/Ambitions/Surfaces/Today/",
        "Native/Ambitions/Surfaces/Time/",
        "Native/Ambitions/DesignSystem/ProductObjects/Today",
        "Native/Ambitions/DesignSystem/ProductObjects/Time",
        "Native/Ambitions/Projection/SurfaceLenses/Today",
        "Native/Ambitions/Projection/SurfaceLenses/Time",
    )
    for path in files:
        relative = rel(path)
        if relative.startswith(allowed) or not relative.startswith(scanned_prefixes):
            continue
        add_regex_findings(
            findings,
            "time-rendering",
            path,
            DIRECT_TIME_RENDERING_PATTERNS,
            read(path),
        )
    return findings


def check_hosted_ai_backend_boundaries(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        if relative == "Native/Ambitions/Language/ForbiddenTopLevelTerms.swift":
            continue
        add_regex_findings(
            findings,
            "hosted-ai-backend-boundary",
            path,
            HOSTED_AI_BACKEND_PATTERNS,
            read(path),
            string_literals_only=True,
        )
    return findings


def check_design_tokens(files: list[Path], changed: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        if relative.startswith(DESIGN_ALLOWED_PREFIXES):
            continue
        should_scan = relative.startswith(SURFACE_OWNED_PATH_PREFIXES) or relative in changed
        if should_scan:
            add_design_token_findings(findings, path, read(path))
    return findings


def check_shell_and_accessibility(files: list[Path], changed: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        text = read(path)
        is_rendering_source = is_swiftui_rendering_source(text)
        if relative.startswith(SURFACE_OWNED_PATH_PREFIXES) and is_rendering_source:
            add_regex_findings(findings, "shell-chrome-safe-area", path, SHELL_POLICY_PATTERNS, text)
        if relative in changed and re.search(r"\.animation\s*\(|withAnimation\s*\(", text) and "accessibilityReduceMotion" not in text:
            findings.append(Finding("motion-reduction", relative, "changed animated file lacks local reduce-motion handling"))
        if relative.startswith("Native/Ambitions/Surfaces/") and (
            is_rendering_source
            and
            "accessibility" not in text.lower()
            and not relative.endswith("Accessibility.swift")
        ):
            findings.append(Finding("accessibility", relative, "surface-owned file lacks accessibility semantics or companion reference"))

    for surface in ["Today", "Goals", "Time", "You"]:
        expected = ROOT / "Native" / "Ambitions" / "Surfaces" / surface / f"{surface}Accessibility.swift"
        if not expected.exists():
            findings.append(Finding("accessibility", rel(expected), "canonical surface accessibility mirror is missing"))

    return findings


def check_scenario_and_quality_contracts() -> list[Finding]:
    findings: list[Finding] = []
    required_snippets = {
        "Native/Ambitions/Scenarios/RuntimeScenario.swift": [
            "RuntimeScenarioState",
            "dynamicTypeXXXL",
            "reduceMotion",
            "reduceTransparency",
            "highContrast",
            "keyboardVisible",
            "runtimeMutation",
            "visibleStageMutation",
            "accessibilityAnnouncement",
            "proofArtifact",
        ],
        "Native/Ambitions/Quality/QualityGateChecklist.swift": [
            "architecture",
            "fileSize",
            "forbiddenLanguage",
            "designTokens",
            "shellChrome",
            "safeArea",
            "dynamicType",
            "motionReduction",
            "performanceBudget",
            "visualRegression",
        ],
    }
    for relative, snippets in required_snippets.items():
        path = ROOT / relative
        if not path.exists():
            findings.append(Finding("scenario-quality-contract", relative, "required contract file is missing"))
            continue
        text = read(path)
        for snippet in snippets:
            if snippet not in text:
                findings.append(Finding("scenario-quality-contract", relative, f"missing contract snippet {snippet}"))

    screenshot_script = ROOT / "scripts" / "ambitions-run-ui-screenshot-matrix.sh"
    if not screenshot_script.exists():
        findings.append(Finding("visual-regression", rel(screenshot_script), "screenshot matrix command is missing"))

    return findings


def check_master_lifeshape_foldin_contract() -> list[Finding]:
    script = ROOT / "scripts" / "ambitions-master-sequencing-check.py"
    if not script.exists():
        return [
            Finding(
                "master-lifeshape-foldin",
                rel(script),
                "master LifeShape sequencing check is missing",
            )
        ]

    result = subprocess.run(
        [sys.executable, str(script)],
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
            "master-lifeshape-foldin",
            rel(script),
            output[:300] if output else "master LifeShape sequencing check failed",
        )
    ]


def check_lifeshape_linear_control_plane_contract() -> list[Finding]:
    script = ROOT / "scripts" / "lifeshape-linear-control-plane-check.py"
    if not script.exists():
        return [
            Finding(
                "lifeshape-linear-control-plane",
                rel(script),
                "LifeShape Linear control-plane check is missing",
            )
        ]

    result = subprocess.run(
        [sys.executable, str(script)],
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
            "lifeshape-linear-control-plane",
            rel(script),
            output[:300] if output else "LifeShape Linear control-plane check failed",
        )
    ]


def check_action_mutation_contract(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        relative = rel(path)
        if not relative.startswith(("Native/Ambitions/Surfaces/", "Native/Ambitions/Composer/")):
            continue
        text = read(path)
        if "Button(" in text or ".onTapGesture" in text:
            lowered = text.lower()
            missing = [
                label
                for label in ["mutation", "accessibility", "proof"]
                if label not in lowered
            ]
            if missing:
                findings.append(Finding("action-mutation-proof", relative, f"interactive surface lacks explicit {', '.join(missing)} contract"))
    return findings


def summarize(findings: list[Finding], *, max_per_gate: int) -> dict[str, list[Finding]]:
    grouped: dict[str, list[Finding]] = {}
    for finding in findings:
        grouped.setdefault(finding.gate, []).append(finding)
    return {gate: rows[:max_per_gate] for gate, rows in sorted(grouped.items())}


def run_self_test() -> int:
    entries = [
        {
            "required_path": "Native/Ambitions/App/AmbitionsRootScene.swift",
            "status": "missing",
            "current_file": "",
            "migration_action": "create",
        },
        {
            "required_path": "Native/Ambitions/Stage/AmbitionsStage.swift",
            "status": "placeholder-only",
            "current_file": "Native/Ambitions/Stage/AmbitionsStage.swift",
            "migration_action": "rewrite",
        },
        {
            "required_path": "Native/Ambitions/Features/Today/TodayScreen.swift",
            "status": "obsolete-owner-present",
            "current_file": "Native/Ambitions/Features/Today/TodayScreen.swift",
            "migration_action": "migrate",
        },
        {
            "required_path": "Native/Ambitions/Stage/AmbitionsSurface.swift",
            "status": "implemented",
            "current_file": "Native/Ambitions/Stage/AmbitionsSurface.swift",
            "migration_action": "none",
        },
    ]
    findings = final_tree_inventory_findings(entries)
    assert len(findings) == 3
    assert any("missing" in finding.detail for finding in findings)
    assert any("placeholder-only" in finding.detail for finding in findings)
    assert any("obsolete-owner-present" in finding.detail for finding in findings)

    tab_cases = swift_enum_case_names("enum AppTab { case today, goals, time, you, motion }", "AppTab")
    assert tab_cases == ["today", "goals", "time", "you", "motion"]
    assert tab_cases != ["today", "goals", "time", "you"]

    assert any(re.search(pattern, "ambitions://tab/motion", flags=re.IGNORECASE) for pattern in FORBIDDEN_ROUTE_PATTERNS)
    assert any(re.search(pattern, "TabView { Text(\"Today\") }", flags=re.IGNORECASE) for pattern in [r"\bTabView\b"])
    assert any(re.search(pattern, "TabView(selection: $surface) { Text(\"Today\") }", flags=re.IGNORECASE) for pattern in [r"\bTabView\s*\("])
    assert any(re.search(pattern, "let now = Date()", flags=re.IGNORECASE) for pattern in DIRECT_TIME_RENDERING_PATTERNS)
    assert any(re.search(pattern, "\"GPT\"", flags=re.IGNORECASE) for pattern in HOSTED_AI_BACKEND_PATTERNS)

    print("ambitions-quality-gate self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Strict Ambitions architecture and quality gate.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable findings.")
    parser.add_argument("--max-per-gate", type=int, default=80)
    parser.add_argument("--self-test", action="store_true", help="Run quality gate self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    files = production_swift_files()
    changed = changed_paths()

    findings: list[Finding] = []
    findings.extend(check_final_tree_inventory())
    findings.extend(check_architecture(files))
    findings.extend(check_file_sizes(files, changed))
    findings.extend(check_forbidden_language(files))
    findings.extend(check_transitional_ownership_terms(files))
    findings.extend(check_temporal_rendering(files))
    findings.extend(check_hosted_ai_backend_boundaries(files))
    findings.extend(check_design_tokens(files, changed))
    findings.extend(check_shell_and_accessibility(files, changed))
    findings.extend(check_scenario_and_quality_contracts())
    findings.extend(check_master_lifeshape_foldin_contract())
    findings.extend(check_lifeshape_linear_control_plane_contract())
    findings.extend(check_action_mutation_contract(files))

    grouped = summarize(findings, max_per_gate=args.max_per_gate)
    if args.json:
        print(json.dumps({gate: [asdict(row) for row in rows] for gate, rows in grouped.items()}, indent=2))
    else:
        print("ambitions-quality-gate")
        print(f"production_swift_files={len(files)}")
        print(f"changed_paths={len(changed)}")
        if not findings:
            print("GREEN all strict quality gates passed")
            return 0
        print(f"RED {len(findings)} strict quality gate finding(s)")
        for gate, rows in grouped.items():
            total = sum(1 for finding in findings if finding.gate == gate)
            print(f"\n[{gate}] showing {len(rows)} of {total}")
            for row in rows:
                print(f"{row.path}: {row.detail}")

    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
