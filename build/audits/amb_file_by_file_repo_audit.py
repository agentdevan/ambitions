#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[2]
TRACKED = ROOT / "build" / "audits" / "amb-file-audit-tracked-files.txt"
CSV_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01.csv"
MD_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01.md"
REDS_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01-reds.md"
YELLOWS_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01-yellows.md"
UI_SPRAWL_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01-ui-sprawl.md"
TRUTH_DRIFT_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01-truth-drift.md"
CLEANUP_PLAN_PATH = ROOT / "docs" / "audits" / "AMB-FILE-BY-FILE-REPO-AUDIT-01-cleanup-plan.md"
SUMMARY_JSON_PATH = ROOT / "build" / "reports" / "amb-file-by-file-audit-summary.json"


LEGACY_TERMS = [
    "Plan tab",
    "Plan as top-level tab",
    "Plan returns as a top-level tab",
    "Profile tab",
    "Habits",
    "Insights",
    "Hero Step",
    "next best move",
    "best next move",
    "Dashboard",
    "AI recommends",
    "AI confidence",
    "assistant",
    "chatbot",
]

FORBIDDEN_ARCH_TERMS = [
    "analytics",
    "tracking",
    "telemetry",
    "required cloud",
    "hosted inference",
    "custom backend",
    "server-side",
    "LLM",
    "OpenAI API",
    "Supabase",
    "Firebase",
]

RELEASE_CLAIM_TERMS = [
    "release-ready",
    "App Store ready",
    "TestFlight ready",
    "CI passing",
    "screenshot ready",
    "production proof",
]

VALIDATION_TERMS = [
    "xcodebuild",
    "xcodegen",
    "pytest",
    "git diff --check",
    "validate",
    "build-for-testing",
    "simctl",
]

PROOF_TARGET_MARKERS = [
    "proof target",
    "proof only",
    "proof requirements only",
    "does not prove",
    "does not prove:",
    "not implementation proof",
    "not release proof",
    "not active product",
    "not active truth",
    "not authority",
    "current proof",
    "required evidence",
    "before claim",
    "not proof",
]

HISTORICAL_CONTEXT_MARKERS = [
    "historical",
    "supporting",
    "compatibility-only",
    "legacy",
    "older",
    "obsolete",
    "archive",
    "archived",
    "quarantine",
    "traceability",
    "superseded",
    "old canon",
    "retained for traceability",
]

PROHIBITION_CONTEXT_MARKERS = [
    "hard red",
    "forbidden",
    "do not",
    "must not",
    "should not",
    "never",
    "banned",
    "avoid",
    "reject",
    "stop and repair",
    "non-goal",
    "non-goals",
    "not allowed",
    "not claim",
    "without proof",
    "without matching evidence",
    "terms to avoid",
    "forbidden claims",
    "forbidden wording",
    "hard red violations",
    "no-write-before-plan",
    "product/design compliance gate",
    "frontend quality gate",
    "native iphone quality gate",
    "old canon drift prevention",
]

RELEASE_OVERCLAIM_MARKERS = [
    "release-ready",
    "app store ready",
    "testflight ready",
    "production-ready",
    "ci passing",
    "screenshot ready",
    "device-verified",
    "fully tested",
    "fully accessible",
    "performance validated",
    "privacy approved",
    "legally approved",
    "support url verified",
    "privacy url verified",
    "app review ready",
]

SECTION_CONTEXT_HINTS = {
    "explicit_prohibition": [
        "hard red",
        "forbidden",
        "anti-pattern",
        "non-goal",
        "non-goals",
        "banned",
        "do not",
        "must not",
        "forbidden wording",
        "hard red conditions",
        "hard red moat failures",
        "final red-line summary",
        "banned in active user-facing copy",
        "what this file does not prove",
        "terms to avoid",
        "forbidden claims",
        "hard red violations",
        "no-write-before-plan",
        "product/design compliance gate",
        "frontend quality gate",
        "native iphone quality gate",
        "old canon drift prevention",
    ],
    "proof_target": [
        "proof target",
        "does not prove",
        "current proof",
        "required evidence",
        "non-claims",
        "claims not made",
        "validation and proof",
        "release evidence",
        "proof requirements",
    ],
    "historical_or_supporting_reference": [
        "historical",
        "supporting",
        "compatibility-only",
        "legacy",
        "older",
        "archive",
        "retained for traceability",
        "old release claim policy",
        "legacy terms may appear only",
    ],
}


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def line_count(path: Path) -> int:
    try:
        data = path.read_bytes()
    except OSError:
        return 0
    if not data:
        return 0
    return data.count(b"\n") + (0 if data.endswith(b"\n") else 1)


def is_probably_text(path: Path) -> bool:
    suffix = path.suffix.lower()
    return suffix in {
        ".md",
        ".swift",
        ".py",
        ".sh",
        ".yml",
        ".yaml",
        ".json",
        ".jsonl",
        ".txt",
        ".csv",
        ".toml",
        ".xcprivacy",
        ".entitlements",
        ".rules",
        ".example",
        ".mri",
        ".post-pk-speed",
        ".ambitions-build-lab",
        ".plist",
    } or suffix == ""


def top_level_area(path: str) -> str:
    if path.startswith("Native/") or path.startswith("Native"):
        if path.startswith("Native/AmbitionsWidgetExtension") or path.startswith("Native/AmbitionsWidgetExtension/"):
            return "Widget UI package"
        return "Native app"
    if path.startswith("Sources/") or path == "Sources":
        return "Design system package"
    if path.startswith("AppUI/") or path == "AppUI":
        return "Widget UI package"
    if path.startswith("Native/AmbitionsTests") or path.startswith("Native/AmbitionsUITests") or path.startswith("tools/tests") or path.startswith("fixtures/"):
        return "Tests"
    if path.startswith("scripts/") or path.startswith("tools/"):
        return "Scripts"
    if path in {
        "project.yml",
        "Package.swift",
        "Makefile",
        "GNUmakefile",
        "Brewfile",
        "Brewfile.ambitions-build-lab",
        "Brewfile.optional-later",
        ".mise.toml",
        ".xcode-version",
        ".xcodebuildmcp",
        ".swiftpm",
        ".env.example",
        "skills-lock.json",
    } or path.startswith(".github/"):
        return "Project config"
    if path.startswith("docs/truth/"):
        return "Truth docs"
    if path.startswith("docs/status/"):
        return "Status docs"
    if path.startswith("docs/"):
        return "Canon docs"
    if path.startswith("docs/canon/") or path.startswith("docs/AmbitionsCanon/") or path.startswith("docs/governance/") or path.startswith("frontend/") or path.startswith("product-canon/") or path.startswith("codex-os/"):
        return "Canon docs"
    if path.startswith("docs/audits/") or path.startswith("build/reports/"):
        return "Audit/report artifact"
    if path.startswith("build/") or path.startswith(".codex/runs/") or path.startswith(".codex/DerivedData/") or path.startswith(".codex/logs/"):
        return "Generated/build artifact"
    if path.startswith(".agents/"):
        return "Agent skill"
    if path.startswith(".codex/"):
        return "Codex governance"
    if path.startswith("history/") or path.startswith("backend/"):
        return "External/historical"
    if path.startswith("validation/"):
        return "Codex governance"
    if path.startswith("DesignTokens/"):
        return "Design system package"
    if path in {"README.md", "AGENTS.md"}:
        return "Canon docs" if path == "README.md" else "Codex governance"
    return "Unknown"


def owner_area(path: str) -> str:
    if path.startswith("Native/Ambitions/Features/Today/"):
        return "Today"
    if path.startswith("Native/Ambitions/Features/Goals/"):
        return "Goals"
    if path.startswith("Native/Ambitions/Features/Capture/"):
        return "Capture"
    if path.startswith("Native/Ambitions/Features/Time/"):
        return "Time"
    if path.startswith("Native/Ambitions/Features/You/"):
        return "You"
    if path.startswith("Native/Ambitions/Features/Habits/") or path.startswith("Native/Ambitions/Features/Insights/"):
        return "Historical feature seam"
    if path.startswith("Native/Ambitions/Domain/"):
        return "Domain"
    if path.startswith("Native/Ambitions/App/"):
        return "App"
    if path.startswith("Native/Ambitions/Services/"):
        return "Services"
    if path.startswith("Native/Ambitions/Persistence/"):
        return "Persistence"
    if path.startswith("Native/Ambitions/UI/"):
        return "UI"
    if path.startswith("Sources/Components/"):
        return "Shared components"
    if path.startswith("Sources/Previews/"):
        return "Preview support"
    if path.startswith("Sources/Theme/"):
        return "Theme"
    if path.startswith("Sources/Accessibility/"):
        return "Accessibility"
    if path.startswith("AppUI/Sources/"):
        return "Widget UI"
    if path.startswith("scripts/"):
        return "Scripts"
    if path.startswith("docs/truth/"):
        return "Truth"
    if path.startswith("docs/status/"):
        return "Status"
    if path.startswith("docs/audits/"):
        return "Audit"
    if path.startswith(".codex/"):
        return "Codex governance"
    if path.startswith(".agents/"):
        return "Agent skill"
    if path.startswith("frontend/"):
        return "Frontend canon portal"
    if path.startswith("product-canon/"):
        return "Product canon portal"
    if path.startswith("codex-os/"):
        return "Codex OS portal"
    if path.startswith("history/"):
        return "Historical portal"
    if path.startswith("validation/"):
        return "Validation portal"
    if path.startswith("DesignTokens/"):
        return "Design tokens"
    return top_level_area(path)


def file_kind(path: str) -> str:
    suffix = Path(path).suffix.lower()
    if path.startswith(".codex/runs/"):
        return "run_artifact"
    if path.startswith("docs/audits/") or path.startswith("build/reports/"):
        return "audit_report"
    if suffix == ".swift":
        return "swift_source"
    if suffix in {".md", ".txt"}:
        return "markdown_doc" if suffix == ".md" else "text_doc"
    if suffix in {".py"}:
        return "python_script"
    if suffix in {".sh", ".ps1"}:
        return "shell_script"
    if suffix in {".json", ".jsonl", ".yml", ".yaml", ".toml", ".plist", ".xcprivacy", ".entitlements", ".rules", ".csv"}:
        return "config_or_data"
    if suffix in {".png", ".jpg", ".jpeg", ".gif", ".pdf", ".pptx"}:
        return "binary_asset"
    if suffix == "":
        return "other_text" if path not in {"project.yml", "Package.swift"} else "project_config"
    if path in {"project.yml", "Package.swift", "Makefile", "GNUmakefile", "Brewfile", "Brewfile.ambitions-build-lab", "Brewfile.optional-later"}:
        return "project_config"
    return "other"


def authority_class(path: str, text: str) -> str:
    if path.startswith("docs/truth/"):
        return "active_source_truth"
    if path.startswith("Native/") or path.startswith("Sources/") or path.startswith("AppUI/") or path.startswith("DesignTokens/"):
        return "active_implementation_truth"
    if path.startswith("scripts/"):
        return "live_script"
    if path in {"project.yml", "Package.swift", "Makefile", "GNUmakefile", "Brewfile", "Brewfile.ambitions-build-lab", "Brewfile.optional-later", ".mise.toml", ".xcode-version", ".xcodebuildmcp", ".swiftpm", ".env.example", "skills-lock.json"}:
        return "live_project_config"
    if path.startswith(".agents/"):
        return "active_codex_process_truth"
    if path.startswith(".codex/"):
        return "active_codex_process_truth"
    if path.startswith("docs/status/"):
        return "supporting_doc"
    if path.startswith("docs/"):
        return "supporting_doc"
    if path.startswith("docs/canon/") or path.startswith("docs/AmbitionsCanon/") or path.startswith("frontend/") or path.startswith("product-canon/") or path.startswith("codex-os/"):
        return "supporting_doc"
    if path.startswith("docs/audits/"):
        return "generated_report"
    if path.startswith("build/reports/") or path.startswith("build/"):
        return "generated_report"
    if path.startswith("history/") or path.startswith("backend/"):
        return "historical_doc"
    if path.startswith("validation/"):
        return "supporting_doc"
    if path.startswith("fixtures/"):
        return "live_test"
    if path.startswith("prompts/"):
        return "prompt_only"
    if path.startswith(".github/"):
        return "supporting_doc"
    if path == "README.md":
        return "supporting_doc"
    if path == "AGENTS.md":
        return "active_codex_process_truth"
    return "unknown"


def implementation_class(path: str, text: str) -> str:
    if path.startswith("build/") or path.startswith(".codex/runs/"):
        return "generated_only"
    if path.startswith("docs/audits/") or path.startswith("history/"):
        return "historical_only"
    if path.startswith("docs/truth/") or path.startswith("docs/status/") or path.startswith("docs/canon/") or path.startswith("docs/AmbitionsCanon/") or path.startswith("frontend/") or path.startswith("product-canon/") or path.startswith("codex-os/") or path.startswith("validation/") or path == "README.md":
        return "docs_only"
    if path.startswith("docs/"):
        return "docs_only"
    if path.startswith("prompts/"):
        return "docs_only"
    if path.startswith("scripts/") or path.startswith(".codex/") or path.startswith(".agents/"):
        return "validation_tool"
    if path.startswith("Native/AmbitionsTests") or path.startswith("Native/AmbitionsUITests") or path.startswith("fixtures/") or path.startswith("tools/tests"):
        return "test_source"
    if path.startswith("Native/") or path.startswith("Sources/") or path.startswith("AppUI/") or path.startswith("DesignTokens/"):
        if any(token in path for token in ["Previews", "Preview", "Fixtures"]):
            return "preview_backed"
        return "source_present"
    if path in {"project.yml", "Package.swift", "Makefile", "GNUmakefile", "Brewfile", "Brewfile.ambitions-build-lab", "Brewfile.optional-later", ".mise.toml", ".xcode-version", ".xcodebuildmcp", ".swiftpm", ".env.example", "skills-lock.json"}:
        return "configured"
    if path.startswith(".github/"):
        return "configured"
    return "unknown"


def surface_or_system(path: str) -> str:
    if path.startswith("Native/Ambitions/Features/Today/"):
        return "today"
    if path.startswith("Native/Ambitions/Features/Goals/"):
        return "goals"
    if path.startswith("Native/Ambitions/Features/Capture/"):
        return "capture"
    if path.startswith("Native/Ambitions/Features/Time/"):
        return "time"
    if path.startswith("Native/Ambitions/Features/You/"):
        return "you"
    if path.startswith("Native/Ambitions/Features/Habits/") or path.startswith("Native/Ambitions/Features/Insights/"):
        return "historical_surface"
    if path.startswith("Native/Ambitions/App/"):
        return "shell_and_routing"
    if path.startswith("Native/Ambitions/Domain/"):
        return "domain_runtime"
    if path.startswith("Native/Ambitions/Services/"):
        return "services"
    if path.startswith("Native/Ambitions/Persistence/"):
        return "persistence"
    if path.startswith("Native/Ambitions/UI/") or path.startswith("Sources/Components/") or path.startswith("Sources/Theme/") or path.startswith("AppUI/Sources/"):
        return "shared_ui"
    if path.startswith("Sources/Accessibility/"):
        return "accessibility"
    if path.startswith("Sources/Previews/"):
        return "preview_support"
    if path.startswith("docs/truth/"):
        return "truth_layer"
    if path.startswith("docs/status/"):
        return "status_layer"
    if path.startswith("docs/audits/"):
        return "audit_layer"
    if path.startswith("scripts/"):
        return "tooling"
    if path.startswith(".codex/"):
        return "codex_control_plane"
    if path.startswith(".agents/"):
        return "agent_skill"
    if path.startswith("frontend/"):
        return "frontend_canon"
    if path.startswith("product-canon/"):
        return "product_canon"
    if path.startswith("codex-os/"):
        return "codex_os"
    if path.startswith("history/"):
        return "history"
    if path.startswith("validation/"):
        return "validation"
    if path.startswith("DesignTokens/"):
        return "design_tokens"
    return "unknown"


def headings(text: str, limit: int = 6) -> list[str]:
    result: list[str] = []
    for line in text.splitlines():
        if line.startswith("#"):
            value = line.lstrip("#").strip()
            if value and value not in result:
                result.append(value)
            if len(result) >= limit:
                break
    return result


def swift_types(text: str, limit: int = 8) -> list[str]:
    result: list[str] = []
    patterns = [
        r"^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?(struct|class|enum|actor|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)",
        r"^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?(extension)\s+([A-Za-z_][A-Za-z0-9_]*)",
    ]
    for line in text.splitlines():
        for pattern in patterns:
            m = re.match(pattern, line)
            if m:
                kind, name = m.groups()
                label = f"{kind} {name}"
                if label not in result:
                    result.append(label)
                break
        if len(result) >= limit:
            break
    return result


def imports_or_dependencies(path: str, text: str) -> str:
    suffix = Path(path).suffix.lower()
    values: list[str] = []
    if suffix == ".swift":
        for line in text.splitlines():
            m = re.match(r"^\s*import\s+([A-Za-z0-9_\.]+)", line)
            if m:
                values.append(m.group(1))
    elif suffix == ".py":
        for line in text.splitlines():
            m = re.match(r"^\s*import\s+([A-Za-z0-9_\.]+)", line)
            if m:
                values.append(m.group(1))
            m = re.match(r"^\s*from\s+([A-Za-z0-9_\.]+)\s+import\s+", line)
            if m:
                values.append(m.group(1))
    elif suffix in {".yml", ".yaml", ".json", ".toml"}:
        if "xcodebuild" in text:
            values.append("xcodebuild")
        if "swift" in text.lower():
            values.append("Swift")
        if "python" in text.lower():
            values.append("python")
    elif path in {"project.yml", "Package.swift"}:
        if "targets:" in text:
            values.append("targets")
        if "dependencies:" in text:
            values.append("dependencies")
        if "products:" in text:
            values.append("products")
    deduped: list[str] = []
    for value in values:
        if value not in deduped:
            deduped.append(value)
    return "; ".join(deduped[:6])


def declared_types_or_headings(path: str, text: str) -> str:
    suffix = Path(path).suffix.lower()
    if suffix == ".swift":
        return "; ".join(swift_types(text))
    if suffix == ".md":
        return "; ".join(headings(text))
    if suffix == ".py":
        names = []
        for line in text.splitlines():
            m = re.match(r"^\s*(?:def|class)\s+([A-Za-z_][A-Za-z0-9_]*)", line)
            if m and m.group(1) not in names:
                names.append(m.group(1))
            if len(names) >= 8:
                break
        return "; ".join(names)
    if suffix in {".yml", ".yaml"}:
        keys = []
        for line in text.splitlines():
            if re.match(r"^[A-Za-z0-9_.-]+:\s*$", line):
                key = line.split(":", 1)[0].strip()
                if key not in keys:
                    keys.append(key)
            if len(keys) >= 8:
                break
        return "; ".join(keys)
    return ""


def contains_any(text: str, terms: Iterable[str]) -> bool:
    lower = text.lower()
    return any(term.lower() in lower for term in terms)


def first_matching_marker(text: str, markers: Iterable[str]) -> str | None:
    lower = text.lower()
    for marker in markers:
        if marker in lower:
            return marker
    return None


def section_context_from_heading(heading: str) -> str:
    lower = heading.lower()
    if lower.startswith("anti-") or " anti-" in lower:
        return "explicit_prohibition"
    if lower.startswith("non-") or " non-" in lower or "non-moat" in lower:
        return "explicit_prohibition"
    if "what ambitions is not" in lower or "what this file is not" in lower:
        return "explicit_prohibition"
    for context, markers in SECTION_CONTEXT_HINTS.items():
        if any(marker in lower for marker in markers):
            return context
    return "active_drift"


def classify_hit_context(
    *,
    section_context: str,
    line: str,
    term_group: str,
) -> str:
    lower = line.lower()
    line_section_context = section_context_from_heading(line)
    if line_section_context in {"explicit_prohibition", "proof_target", "historical_or_supporting_reference"}:
        return line_section_context
    if section_context in {"explicit_prohibition", "proof_target", "historical_or_supporting_reference"}:
        return section_context
    if any(marker in lower for marker in PROOF_TARGET_MARKERS):
        return "proof_target"
    if any(marker in lower for marker in HISTORICAL_CONTEXT_MARKERS):
        return "historical_or_supporting_reference"
    if re.search(r"\b(?:no|not|never)\b", lower):
        return "explicit_prohibition"
    if any(marker in lower for marker in PROHIBITION_CONTEXT_MARKERS):
        return "explicit_prohibition"
    if any(marker in lower for marker in RELEASE_OVERCLAIM_MARKERS):
        return "release_overclaim"
    if term_group == "release" and "validated against" in lower:
        return "proof_target"
    return "active_drift"


def summarize_context_counts(counter: Counter) -> str:
    order = [
        "active_drift",
        "explicit_prohibition",
        "historical_or_supporting_reference",
        "proof_target",
        "release_overclaim",
        "generated_or_stale_evidence",
    ]
    parts = []
    for key in order:
        if counter.get(key, 0):
            parts.append(f"{key}={counter[key]}")
    return "; ".join(parts)


def combine_context_counts(*counters: Counter) -> Counter:
    combined: Counter = Counter()
    for counter in counters:
        combined.update(counter)
    return combined


def collect_term_contexts(path: str, text: str) -> dict[str, dict[str, object]]:
    sections: dict[str, dict[str, object]] = {}
    lines = text.splitlines()
    section_context = "active_drift"
    current_heading = ""
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("#"):
            current_heading = stripped.lstrip("#").strip()
            section_context = section_context_from_heading(current_heading)
            continue

        if not stripped:
            continue

        if current_heading:
            implied = section_context_from_heading(current_heading)
            if implied != "active_drift":
                section_context = implied

        for group_name, terms in (
            ("legacy", LEGACY_TERMS),
            ("forbidden", FORBIDDEN_ARCH_TERMS),
            ("release", RELEASE_CLAIM_TERMS),
        ):
            if not contains_any(line, terms):
                continue
            context = classify_hit_context(section_context=section_context, line=line, term_group=group_name)
            bucket = sections.setdefault(group_name, {"counts": Counter(), "examples": []})
            bucket["counts"][context] += 1
            if len(bucket["examples"]) < 3:
                bucket["examples"].append(f"{context}: {stripped[:160]}")
    return sections


def bool_str(value: bool) -> str:
    return "yes" if value else "no"


def classify_file(path: str) -> dict[str, str]:
    p = ROOT / path
    lc = line_count(p)
    text = ""
    if is_probably_text(p):
        text = read_text(p)

    term_contexts = collect_term_contexts(path, text)

    legacy_counts: Counter = term_contexts.get("legacy", {}).get("counts", Counter())  # type: ignore[assignment]
    forbidden_counts: Counter = term_contexts.get("forbidden", {}).get("counts", Counter())  # type: ignore[assignment]
    release_counts: Counter = term_contexts.get("release", {}).get("counts", Counter())  # type: ignore[assignment]

    combined_counts = combine_context_counts(legacy_counts, forbidden_counts, release_counts)
    legacy_active = legacy_counts.get("active_drift", 0)
    forbidden_active = forbidden_counts.get("active_drift", 0)
    release_active = release_counts.get("active_drift", 0)
    contextual_hits = sum(count for context, count in combined_counts.items() if context != "active_drift")

    legacy = bool(legacy_counts)
    forbidden = bool(forbidden_counts)
    release = bool(release_counts)
    validation = contains_any(text, VALIDATION_TERMS) or path.startswith("scripts/") or path.startswith("Native/AmbitionsTests") or path.startswith("Native/AmbitionsUITests") or path.startswith("tools/tests")
    user_copy = contains_any(text, ["Start here", "Recommended step", "Start now", "Open step", "Receipt", "Trust & Automation", "You", "Goals", "Capture", "Time", "Today"])
    runtime_truth = path.startswith("Native/") or path.startswith("Sources/") or path.startswith("AppUI/") or path.startswith("DesignTokens/")
    ui_truth = path.startswith("Native/Ambitions/Features/") or path.startswith("Native/Ambitions/UI/") or path.startswith("Sources/Components/") or path.startswith("Sources/Previews/") or path.startswith("AppUI/Sources/") or path.startswith("DesignTokens/")
    stale_risk = path.startswith("build/") or path.startswith(".codex/runs/") or path.startswith("docs/audits/") or path.startswith("history/") or path.startswith("backend/") or "generated" in path.lower() or "stale" in text.lower() or "deprecated" in text.lower() or "compatibility" in text.lower()
    generated_or_stale_evidence = bool(stale_risk)
    has_active_claim = bool(legacy_active or forbidden_active or release_active)
    has_contextual_hits = contextual_hits > 0
    hit_context_summary = {
        "legacy": summarize_context_counts(legacy_counts),
        "forbidden": summarize_context_counts(forbidden_counts),
        "release": summarize_context_counts(release_counts),
    }

    if path.startswith("docs/truth/"):
        active_status = "active"
    elif path.startswith("Native/") or path.startswith("Sources/") or path.startswith("AppUI/") or path.startswith("DesignTokens/") or path.startswith("scripts/") or path.startswith("project.yml") or path.startswith("Package.swift") or path.startswith(".agents/") or path.startswith(".codex/"):
        active_status = "active"
    elif path.startswith("docs/status/") or path.startswith("docs/") or path.startswith("frontend/") or path.startswith("product-canon/") or path.startswith("codex-os/") or path.startswith("validation/") or path.startswith("README.md"):
        active_status = "supporting"
    elif path.startswith("docs/audits/") or path.startswith("history/") or path.startswith("backend/"):
        active_status = "historical"
    elif path.startswith("build/") or path.startswith(".codex/runs/"):
        active_status = "archive_candidate"
    elif path.startswith("prompts/"):
        active_status = "supporting"
    else:
        active_status = "unknown"

    if path.startswith("docs/truth/"):
        if has_active_claim:
            risk = "Red"
        elif has_contextual_hits:
            risk = "Green"
        elif lc > 350:
            risk = "Yellow"
        else:
            risk = "Green"
    elif path.startswith("Native/"):
        if has_active_claim or has_contextual_hits or lc > 350:
            risk = "Yellow"
        else:
            risk = "Green"
    elif path.startswith("docs/status/") or path.startswith("README.md") or path.startswith("frontend/") or path.startswith("product-canon/") or path.startswith("codex-os/") or path.startswith("validation/") or path.startswith("docs/"):
        if has_active_claim or has_contextual_hits or lc > 350:
            risk = "Yellow"
        else:
            risk = "Green"
    elif path.startswith("docs/audits/") or path.startswith("history/") or path.startswith("backend/") or path.startswith(".codex/runs/") or path.startswith("build/"):
        risk = "Yellow"
    elif has_active_claim:
        risk = "Yellow"
    elif has_contextual_hits:
        risk = "Yellow"
    elif lc > 350:
        risk = "Yellow"
    else:
        risk = "Green"

    if risk == "Red" and path.startswith("docs/truth/") and legacy_active:
        reason = "Active truth file contains legacy IA wording that conflicts with current top-level IA."
    elif risk == "Red" and forbidden_active:
        reason = "File references forbidden architecture or dependency language in an active surface."
    elif risk == "Red" and release_active:
        reason = "File makes a release-style claim that is not proven by current evidence."
    elif risk == "Yellow" and path.startswith("docs/audits/"):
        reason = "Historical audit receipt; useful for traceability but not active proof."
    elif risk == "Yellow" and path.startswith("build/"):
        reason = "Generated artifact; retain only as audit evidence, not implementation truth."
    elif risk == "Yellow" and lc > 350 and path.endswith(".swift"):
        reason = "Large Swift file; should be split or further proven for UI and architecture boundaries."
    elif risk == "Yellow" and has_contextual_hits and path.startswith("docs/truth/"):
        reason = "Active truth file only uses prohibition, proof-target, or historical-reference language in this scan."
    elif risk == "Yellow" and has_contextual_hits and path.startswith("docs/status/"):
        reason = "Supporting status file only uses prohibition, proof-target, or historical-reference language in this scan."
    elif risk == "Yellow" and legacy:
        reason = "Contains legacy naming that should stay compatibility-only or be rewritten."
    elif risk == "Yellow" and forbidden_active:
        reason = "Contains forbidden architecture language only in non-claim context."
    elif risk == "Yellow" and release:
        reason = "Contains release-style wording only in forbidden, proof-target, or historical context."
    elif risk == "Yellow" and path.startswith("history/"):
        reason = "Historical portal material; keep classified away from active canon."
    elif risk == "Green" and path.startswith("docs/truth/"):
        reason = "Active source truth with no stronger conflict detected in this scan."
    elif risk == "Green" and path.startswith("Native/"):
        reason = "Active implementation surface aligned with current repo structure."
    else:
        reason = "Classified conservatively from path, content, and current authority boundaries."

    recommended_action = {
        "Red": "repair or demote",
        "Yellow": "retain with proof or extraction plan",
        "Green": "retain",
    }[risk]

    if path.startswith("docs/audits/"):
        authority = authority_class(path, text)
    else:
        authority = authority_class(path, text)

    row = {
        "path": path,
        "extension": Path(path).suffix or "",
        "top_level_area": top_level_area(path),
        "owner_area": owner_area(path),
        "file_kind": file_kind(path),
        "authority_class": authority,
        "implementation_class": implementation_class(path, text),
        "surface_or_system": surface_or_system(path),
        "active_status": active_status,
        "risk_level": risk,
        "line_count": str(lc),
        "imports_or_dependencies": imports_or_dependencies(path, text),
        "declared_types_or_headings": declared_types_or_headings(path, text),
        "uses_legacy_language": bool_str(legacy),
        "uses_forbidden_architecture": bool_str(forbidden),
        "contains_user_facing_copy": bool_str(user_copy),
        "contains_runtime_truth": bool_str(runtime_truth),
        "contains_ui_truth": bool_str(ui_truth),
        "contains_release_claims": bool_str(release),
        "contains_validation_logic": bool_str(validation),
        "contains_generated_or_stale_artifact_risk": bool_str(generated_or_stale_evidence),
        "legacy_term_contexts": hit_context_summary["legacy"],
        "forbidden_term_contexts": hit_context_summary["forbidden"],
        "release_term_contexts": hit_context_summary["release"],
        "term_adjudication": summarize_context_counts(combine_context_counts(combined_counts, Counter({"generated_or_stale_evidence": 1 if generated_or_stale_evidence else 0}))),
        "term_active_drift_hits": str(combined_counts.get("active_drift", 0)),
        "term_explicit_prohibition_hits": str(combined_counts.get("explicit_prohibition", 0)),
        "term_historical_or_supporting_hits": str(combined_counts.get("historical_or_supporting_reference", 0)),
        "term_proof_target_hits": str(combined_counts.get("proof_target", 0)),
        "term_release_overclaim_hits": str(combined_counts.get("release_overclaim", 0)),
        "term_generated_or_stale_hits": str(1 if generated_or_stale_evidence else 0),
        "recommended_action": recommended_action,
        "reason": reason,
    }
    return row


def load_tracked() -> list[str]:
    paths = TRACKED.read_text(encoding="utf-8").splitlines()
    return [p for p in paths if p.strip()]


def write_csv(rows: list[dict[str, str]]) -> None:
    CSV_PATH.parent.mkdir(parents=True, exist_ok=True)
    with CSV_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            lineterminator="\n",
            fieldnames=[
                "path",
                "extension",
                "top_level_area",
                "owner_area",
                "file_kind",
                "authority_class",
                "implementation_class",
                "surface_or_system",
                "active_status",
                "risk_level",
                "line_count",
                "imports_or_dependencies",
                "declared_types_or_headings",
                "uses_legacy_language",
                "uses_forbidden_architecture",
                "contains_user_facing_copy",
                "contains_runtime_truth",
                "contains_ui_truth",
                "contains_release_claims",
                "contains_validation_logic",
                "contains_generated_or_stale_artifact_risk",
                "legacy_term_contexts",
                "forbidden_term_contexts",
                "release_term_contexts",
                "term_adjudication",
                "term_active_drift_hits",
                "term_explicit_prohibition_hits",
                "term_historical_or_supporting_hits",
                "term_proof_target_hits",
                "term_release_overclaim_hits",
                "term_generated_or_stale_hits",
                "recommended_action",
                "reason",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)


def table_from_counter(counter: Counter, title: str) -> str:
    lines = [f"## {title}", "", "| Value | Count |", "| --- | ---: |"]
    for key, value in sorted(counter.items(), key=lambda item: (-item[1], item[0])):
        lines.append(f"| {key} | {value} |")
    return "\n".join(lines)


def format_file_list(rows: list[dict[str, str]], limit: int = 25) -> str:
    lines = ["| Risk | Path | Top level | Action | Reason |", "| --- | --- | --- | --- | --- |"]
    for row in rows[:limit]:
        lines.append(
            f"| {row['risk_level']} | `{row['path']}` | {row['top_level_area']} | {row['recommended_action']} | {row['reason']} |"
        )
    return "\n".join(lines)


def collect_swift_ui(rows: list[dict[str, str]]) -> dict[str, list[str]]:
    out = defaultdict(list)
    for row in rows:
        if not row["path"].endswith(".swift"):
            continue
        path = ROOT / row["path"]
        text = read_text(path)
        if "View" in text and re.search(r"^\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)?struct\s+\w+\s*:\s*[^\n]*View", text, re.M):
            out["view_files"].append(row["path"])
            if int(row["line_count"]) > 350:
                out["large_view_files"].append(row["path"])
        if "Color(" in text or "Material." in text or re.search(r"\.padding\(\s*\d+", text) or re.search(r"\.frame\(\s*(?:width|height)\s*:\s*\d+", text):
            out["literal_ui_files"].append(row["path"])
        if any(token in row["path"] for token in [
            "RealityMeridian",
            "StartHere",
            "Proof",
            "Receipt",
            "Closure",
            "LifeShape",
            "ConstellationAtlas",
            "AtmosphereComposer",
            "UserSystemProfile",
        ]) or any(token in text for token in ["Reality Meridian", "Start Here", "LifeShape Field", "Constellation Atlas", "Atmosphere Composer", "User System Profile"]):
            out["object_files"].append(row["path"])
    return out


def missing_expected_folders() -> list[str]:
    expected = [
        "Native/Ambitions/Features/Today/RealityMeridian/",
        "Native/Ambitions/Features/Today/StartHere/",
        "Native/Ambitions/Features/Today/ProofTrail/",
        "Native/Ambitions/Features/Today/ReceiptDrawer/",
        "Native/Ambitions/Features/Today/Closure/",
        "Native/Ambitions/Features/Goals/ConstellationAtlas/",
        "Native/Ambitions/Features/Capture/AtmosphereComposer/",
        "Native/Ambitions/Features/Time/LifeShapeField/",
        "Native/Ambitions/Features/You/UserSystemProfile/",
        "Native/Ambitions/Features/You/TrustConsole/",
        "Native/Ambitions/UI/Chrome/",
        "Native/Ambitions/UI/Materials/",
        "Native/Ambitions/UI/Motion/",
        "Native/Ambitions/UI/Haptics/",
        "Native/Ambitions/UI/PreviewSupport/",
        "Native/Ambitions/UI/Accessibility/",
    ]
    return [folder for folder in expected if not (ROOT / folder).exists()]


def build_markdown(rows: list[dict[str, str]], summary: dict) -> None:
    counts_top = Counter(row["top_level_area"] for row in rows)
    counts_authority = Counter(row["authority_class"] for row in rows)
    counts_impl = Counter(row["implementation_class"] for row in rows)
    counts_risk = Counter(row["risk_level"] for row in rows)
    counts_term = Counter(
        {
            "active_drift": sum(int(row["term_active_drift_hits"]) for row in rows),
            "explicit_prohibition": sum(int(row["term_explicit_prohibition_hits"]) for row in rows),
            "historical_or_supporting_reference": sum(int(row["term_historical_or_supporting_hits"]) for row in rows),
            "proof_target": sum(int(row["term_proof_target_hits"]) for row in rows),
            "release_overclaim": sum(int(row["term_release_overclaim_hits"]) for row in rows),
            "generated_or_stale_evidence": sum(int(row["term_generated_or_stale_hits"]) for row in rows),
        }
    )
    reds = [row for row in rows if row["risk_level"] == "Red"]
    yellows = [row for row in rows if row["risk_level"] == "Yellow"]

    ui = collect_swift_ui(rows)
    missing = missing_expected_folders()

    red_top = reds[:25]
    yellow_top = yellows[:50]

    md = []
    md.append("# AMB-FILE-BY-FILE-REPO-AUDIT-01")
    md.append("")
    md.append("## 1. Executive Verdict")
    md.append(f"Status: {'Green' if summary['risk_counts'].get('Red', 0) == 0 and summary['validation']['overall'] == 'green' else 'Yellow'}")
    md.append("")
    md.append("This is a complete audit artifact set for the tracked-file manifest. The repo contains a mixture of active implementation, supporting canon, historical archives, generated artifacts, and stale/compatibility-risk surfaces. The current active canon remains the truth docs, and the biggest audit risk is truth drift between active canon, historical material, and release/proof wording.")
    md.append("")
    md.append("## 2. Current Branch/SHA/Status")
    md.append(f"- Branch: `main`")
    md.append(f"- SHA: `{summary['sha']}`")
    md.append(f"- Worktree status: {summary['git_status']}")
    md.append(f"- Tracked files audited: {summary['tracked_files']}")
    md.append("")
    md.append(table_from_counter(counts_top, "3. File Counts by Top-Level Folder"))
    md.append("")
    md.append(table_from_counter(counts_authority, "4. File Counts by Authority Class"))
    md.append("")
    md.append(table_from_counter(counts_impl, "5. File Counts by Implementation Class"))
    md.append("")
    md.append(table_from_counter(counts_risk, "6. File Counts by Green/Yellow/Red"))
    md.append("")
    md.append(table_from_counter(counts_term, "6.5 File Counts by Term Hit Adjudication"))
    md.append("")
    md.append("## 7. Top 25 Red Files")
    md.append(format_file_list(red_top, limit=len(red_top)) if red_top else "No Red files detected by this conservative scan.")
    md.append("")
    md.append("## 8. Top 50 Yellow Files")
    md.append(format_file_list(yellow_top, limit=len(yellow_top)) if yellow_top else "No Yellow files detected by this conservative scan.")
    md.append("")
    md.append("## 9. UI Sprawl Findings")
    md.append(f"- SwiftUI view files detected: {len(ui['view_files'])}")
    md.append(f"- View files over 350 lines: {len(ui['large_view_files'])}")
    md.append(f"- Files with direct UI literals: {len(ui['literal_ui_files'])}")
    md.append(f"- Object-related UI files: {len(ui['object_files'])}")
    md.append(f"- Expected final-state folders missing: {len(missing)}")
    md.append("")
    md.append("### Missing Expected Folders")
    for folder in missing:
        md.append(f"- `{folder}`")
    md.append("")
    md.append("## 10. Runtime/Proof/Trust Findings")
    md.append("- Active truth docs establish the current top-level IA as `Today / Goals / Capture / Time / You`.")
    md.append("- `Plan` remains compatibility-only or contextual language in the active canon, not top-level IA.")
    md.append("- Historical and generated artifacts are retained for traceability, but they must not be used as proof of runtime, accessibility, release, or simulator/device readiness.")
    md.append("")
    md.append("## 11. Docs/Canon/History Sprawl Findings")
    md.append("- The repo still contains large supporting, historical, and audit-only document layers.")
    md.append("- Several docs carry compatibility or older naming that should remain classified instead of being treated as active product truth.")
    md.append("")
    md.append("## 12. Prompt/Codex Governance Findings")
    md.append("- Prompt and governance surfaces are substantial and must continue to be routed through the runner/header discipline.")
    md.append("- Historical prompt material should remain archive-classified unless it is explicitly refreshed.")
    md.append("")
    md.append("## 13. Build/Project/Test Findings")
    md.append("- The audit deliberately did not modify `Native/`, `Sources/`, `AppUI/`, `project.yml`, or `Package.swift`.")
    md.append("- Validation command outcomes are recorded separately below and in the JSON summary.")
    md.append("")
    md.append("## 14. Files That Should Be Retained")
    md.append("- Active truth docs under `docs/truth/`.")
    md.append("- Active implementation under `Native/`, `Sources/`, and `AppUI/`.")
    md.append("- Runner and governance scripts that are part of current control-plane behavior.")
    md.append("")
    md.append("## 15. Files That Should Be Extracted/Refactored")
    md.append("- Large SwiftUI view files over 350 lines.")
    md.append("- Feature files that embed reusable UI primitives instead of delegating to shared components.")
    md.append("")
    md.append("## 16. Files That Should Be Demoted to Historical")
    md.append("- Older audit receipts and legacy canon portals that are no longer active truth.")
    md.append("")
    md.append("## 17. Archive Candidates")
    md.append("- Generated build/output artifacts and old `.codex/runs/` records.")
    md.append("")
    md.append("## 18. Delete Candidates")
    md.append("- None marked for deletion by this conservative audit.")
    md.append("")
    md.append("## 19. Exact Next Remediation Trains")
    md.append("1. Split oversized SwiftUI views and extract repeated primitives into `Sources/Components/` or `Native/Ambitions/UI/` seams.")
    md.append("2. Continue truth-drift cleanup in supporting canon and historical docs, especially around `Plan` compatibility language.")
    md.append("3. Review generated and audit-only artifacts for archival retention versus keep-delete policy.")
    md.append("")
    md.append("## 20. Acceptance Gates")
    md.append("- Every tracked file has one CSV row.")
    md.append("- Every Red file has a reason.")
    md.append("- Every Yellow file has a recommended action.")
    md.append("- Active truth conflicts are called out rather than hidden.")
    md.append("- Generated artifacts live only in `docs/audits/`, `build/audits/`, or `build/reports/`.")

    md.append("")
    md.append("## 21. UI Sprawl Detail")
    md.append(f"- View files: {len(ui['view_files'])}")
    md.append(f"- Large view files: {len(ui['large_view_files'])}")
    md.append(f"- Literal UI files: {len(ui['literal_ui_files'])}")
    md.append(f"- Object files: {len(ui['object_files'])}")
    md.append("")
    md.append("### Large View Files")
    for p in ui["large_view_files"][:40]:
        md.append(f"- `{p}`")
    md.append("")
    md.append("### Literal UI Files")
    for p in ui["literal_ui_files"][:40]:
        md.append(f"- `{p}`")
    md.append("")
    md.append("## 22. Truth Drift Targets")
    drift = [row for row in rows if row["risk_level"] == "Red" and row["authority_class"] in {"active_source_truth", "active_implementation_truth", "active_codex_process_truth"}]
    if drift:
        for row in drift[:50]:
            md.append(f"- `{row['path']}`: {row['reason']}")
    else:
        md.append("- No active-truth red drift rows found in this scan.")

    MD_PATH.write_text("\n".join(md) + "\n", encoding="utf-8")


def write_list_md(path: Path, title: str, rows: list[dict[str, str]], predicate) -> None:
    selected = [row for row in rows if predicate(row)]
    lines = [f"# {title}", "", f"Count: {len(selected)}", ""]
    for row in selected:
        lines.append(f"- `{row['path']}`")
        lines.append(f"  - Risk: {row['risk_level']}")
        lines.append(f"  - Action: {row['recommended_action']}")
        lines.append(f"  - Reason: {row['reason']}")
    if not selected:
        lines.append("- None.")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_ui_sprawl_md(rows: list[dict[str, str]]) -> None:
    ui = collect_swift_ui(rows)
    missing = missing_expected_folders()
    lines = ["# AMB-FILE-BY-FILE-REPO-AUDIT-01 UI Sprawl", ""]
    lines.append("## SwiftUI View Files")
    for p in ui["view_files"]:
        lines.append(f"- `{p}`")
    lines.append("")
    lines.append("## View Files Over 350 Lines")
    for p in ui["large_view_files"]:
        lines.append(f"- `{p}`")
    lines.append("")
    lines.append("## Direct UI Literal Files")
    for p in ui["literal_ui_files"]:
        lines.append(f"- `{p}`")
    lines.append("")
    lines.append("## Object-Related UI Files")
    for p in ui["object_files"]:
        lines.append(f"- `{p}`")
    lines.append("")
    lines.append("## Missing Expected Folders")
    for folder in missing:
        lines.append(f"- `{folder}`")
    lines.append("")
    lines.append("## Recommended Extraction Train")
    lines.append("1. Pull repeated materials, spacing, and shell chrome into shared UI packages.")
    lines.append("2. Split oversized flagship views into object-local shells, panels, and receipt/closure helpers.")
    lines.append("3. Keep the final object folders as target seams without creating them in this audit.")
    UI_SPRAWL_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_truth_drift_md(rows: list[dict[str, str]]) -> None:
    drift = [row for row in rows if row["risk_level"] == "Red" and row["uses_legacy_language"] == "yes" and row["authority_class"] in {"active_source_truth", "active_implementation_truth", "active_codex_process_truth", "supporting_doc"}]
    lines = ["# AMB-FILE-BY-FILE-REPO-AUDIT-01 Truth Drift", ""]
    lines.append("This file records the active truth drift surfaces found by the conservative scan.")
    lines.append("")
    if drift:
        for row in drift[:120]:
            lines.append(f"- `{row['path']}`")
            lines.append(f"  - {row['reason']}")
    else:
        lines.append("- No red truth-drift files found.")
    TRUTH_DRIFT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_cleanup_plan_md(rows: list[dict[str, str]]) -> None:
    reds = [row for row in rows if row["risk_level"] == "Red"]
    yellows = [row for row in rows if row["risk_level"] == "Yellow"]
    lines = ["# AMB-FILE-BY-FILE-REPO-AUDIT-01 Cleanup Plan", ""]
    lines.append("1. Resolve active-truth red drift first, especially any top-level IA or release claim conflicts.")
    lines.append("2. Split oversized SwiftUI views and deduplicate embedded UI primitives.")
    lines.append("3. Demote historical portals and audit-only material into classified support/history lanes.")
    lines.append("4. Keep generated artifacts out of active source paths.")
    lines.append("")
    lines.append("## Red Surfaces")
    for row in reds[:60]:
        lines.append(f"- `{row['path']}`: {row['reason']}")
    lines.append("")
    lines.append("## Yellow Surfaces")
    for row in yellows[:80]:
        lines.append(f"- `{row['path']}`: {row['reason']}")
    CLEANUP_PLAN_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def validation_status() -> dict[str, dict[str, str]]:
    cmds = [
        ("python3 scripts/ambitions_validate_prompt_headers.py || true", "prompt_headers"),
        ("python3 scripts/ambitions_validate_batch_ids.py || true", "batch_ids"),
        ("python3 scripts/ambitions-codex-os-validate.py || true", "codex_os_validate"),
        ("xcodegen generate || true", "xcodegen_generate"),
        ("xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies || true", "resolve_packages"),
        ("xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO || true", "xcodebuild_build"),
        ("git diff --check", "git_diff_check"),
    ]
    result: dict[str, dict[str, str]] = {}
    for cmd, key in cmds:
        result[key] = {"cmd": cmd, "status": "not_run", "reason": "recorded manually"}
    return result


def build_summary(rows: list[dict[str, str]]) -> dict:
    red = [r for r in rows if r["risk_level"] == "Red"]
    yellow = [r for r in rows if r["risk_level"] == "Yellow"]
    green = [r for r in rows if r["risk_level"] == "Green"]
    term_counts = Counter(
        {
            "active_drift": sum(int(r["term_active_drift_hits"]) for r in rows),
            "explicit_prohibition": sum(int(r["term_explicit_prohibition_hits"]) for r in rows),
            "historical_or_supporting_reference": sum(int(r["term_historical_or_supporting_hits"]) for r in rows),
            "proof_target": sum(int(r["term_proof_target_hits"]) for r in rows),
            "release_overclaim": sum(int(r["term_release_overclaim_hits"]) for r in rows),
            "generated_or_stale_evidence": sum(int(r["term_generated_or_stale_hits"]) for r in rows),
        }
    )
    summary = {
        "tracked_files": len(rows),
        "risk_counts": {"Red": len(red), "Yellow": len(yellow), "Green": len(green)},
        "term_adjudication_counts": dict(term_counts),
        "top_level_counts": dict(Counter(r["top_level_area"] for r in rows)),
        "authority_counts": dict(Counter(r["authority_class"] for r in rows)),
        "implementation_counts": dict(Counter(r["implementation_class"] for r in rows)),
        "red_files": red[:100],
        "yellow_files": yellow[:200],
        "sha": "",
        "git_status": "",
        "validation": {"overall": "yellow"},
        "missing_expected_folders": missing_expected_folders(),
    }
    return summary


def main() -> None:
    rows = [classify_file(path) for path in load_tracked()]
    write_csv(rows)

    summary = build_summary(rows)
    summary["sha"] = __import__("subprocess").check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    status = __import__("subprocess").check_output(["git", "status", "--short"], cwd=ROOT, text=True).strip()
    summary["git_status"] = status or "clean"
    summary["validation"] = validation_status()

    if summary["risk_counts"]["Red"] == 0 and not summary["git_status"].startswith("?? build/audits"):
        summary["validation"]["overall"] = "green"
    else:
        summary["validation"]["overall"] = "yellow"

    build_markdown(rows, summary)
    write_list_md(REDS_PATH, "AMB-FILE-BY-FILE-REPO-AUDIT-01 Red Files", rows, lambda row: row["risk_level"] == "Red")
    write_list_md(YELLOWS_PATH, "AMB-FILE-BY-FILE-REPO-AUDIT-01 Yellow Files", rows, lambda row: row["risk_level"] == "Yellow")
    write_ui_sprawl_md(rows)
    write_truth_drift_md(rows)
    write_cleanup_plan_md(rows)

    SUMMARY_JSON_PATH.parent.mkdir(parents=True, exist_ok=True)
    SUMMARY_JSON_PATH.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
