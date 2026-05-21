#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
from collections import Counter, defaultdict
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "docs" / "audits" / "amb-repo-green-flagship-reset-master-01-t17-final-ia-scan.md"
JSON_PATH = ROOT / "docs" / "audits" / "AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.json"

BATCH_ID = "AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN"

SCAN_PREFIXES = (
    "README.md",
    "AGENTS.md",
    "docs/",
    ".codex/",
    ".agents/",
    "Native/",
    "Sources/",
    "AppUI/",
    "scripts/",
    "tools/",
    "prompts/",
    "project.yml",
    "Package.swift",
    "frontend/visual-encyclopedia/",
    "build/audits/",
)

TEXT_SUFFIXES = {
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
    ".rules",
    ".xcprivacy",
    ".entitlements",
    ".plist",
    ".xcconfig",
    ".lock",
    ".m",
    ".mm",
    ".graphql",
}

TERM_REGEX = re.compile(
    r"\b(?P<term>Plan|plan|Profile|profile|Habits|habits|Insights|insights|Capture|capture|Captures|captures)\b"
)

ACTIVE_IA_PHRASE = re.compile(r"today\s*/\s*goals\s*/\s*capture\s*/\s*time\s*/\s*you", re.I)

ACCESSIBILITY_ID_RE = re.compile(
    r"\b(?:plan|profile|you|habits|insights|capture|captures)\.[A-Za-z0-9_.-]+\b"
)

TEST_FILE_RE = re.compile(r"(?:Tests?|UITests?)\.(?:swift|py|md)$|(?:Tests?|UITests?)/", re.I)

ROOT_CONTEXT_RE = re.compile(
    r"\b(top[- ]level|user[- ]facing|root\s+ia|active\s+ia|tab|destination|surface|screen|"
    r"route\s+to|routes\s+to|routingHint|fallbackTab|owningRoute|activeTopLevelSurfaces|surfaceProofs)\b",
    re.I,
)

CONTEXTUAL_NOUN_RE = re.compile(
    r"\b(current|starter|native|micro|initial|living|believable|unchanged|recompile|planning|"
    r"begin\s+with\s+a\s+plan|plan\s+first|fuller\s+plan|"
    r"plan\s+history|plan\s+work|plan\s+context|plan\s+data|plan\s+item|plan\s+blocks|"
    r"plan\s+mutation|plan\s+change|plan\s+fit|plan\s+quality|plan\s+material|"
    r"open\s+captures|captures\s+are|captures\s+stay|captures\s+remain|captures\s+need|"
    r"goals\s+and\s+captures|goals,\s+captures|captures,\s+and|captures\s+that|captures\s+or|"
    r"captures\s+feature|captures\s+model|capture\s+model|"
    r"profile\s+header|user\s+system\s+profile|brain\.head\.profile)\b",
    re.I,
)

COMPATIBILITY_RE = re.compile(
    r"\b(compatibility|legacy|historical|historically|internal|support|supporting|alias|migration|migrate|raw value|raw-value|hidden|retained|old|compatibility-only|contextual)\b",
    re.I,
)

SOURCE_COMPATIBILITY_RE = re.compile(
    r"("
    r"fallbackTab|routingHint|surfaceProofs|activeTopLevelSurfaces|open-captures-inbox|captures-inbox|"
    r"ambitions://tab/plan|ambitions://tab/profile|ambitions://tab/habits|ambitions://tab/insights|"
    r"plan tab|profile tab|habits tab|insights tab|captures tab|"
    r"Plan destination|existing Plan destination|Open Time|Open Capture|plan correction|"
    r"surface:\s*\.tab|surface:\s*\.goalDetail|"
    r"\.plan\b|\.profile\b|\.habits\b|\.insights\b|\.captures\b"
    r")",
    re.I,
)

TEST_CONTEXT_RE = re.compile(
    r"\b(xctassert|assert|expect|expectation|should|test|smoke|snapshot|ui test|ui-test|automation)\b",
    re.I,
)

ORDINARY_RE = re.compile(
    r"\b(plan|profile|capture|insights|habits)\b",
    re.I,
)

FORBIDDEN_ROOT_RE = re.compile(
    r"\b(Plan|Profile|Habits|Insights|Captures)\b",
)

NEGATIVE_GUARDRAIL_RE = re.compile(
    r"\b(do not|don't|never|forbid(?:den|s)?|ban(?:ned)?|avoid|reject|red stop|hard red|"
    r"does not|not active|not an active|not a top[- ]level|not restore|prevent|guard(?:rail)?|drift|"
    r"reviv(?:e|ed|es|ing)|reintroduc(?:e|ed|es|ing))\b",
    re.I,
)


@dataclass(frozen=True)
class Hit:
    file: str
    line: int
    term: str
    excerpt: str
    classification: str
    reason: str
    path_role: str
    repair_train: str | None


def git_tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=False,
    )
    files = []
    for raw in result.stdout.split(b"\0"):
        if not raw:
            continue
        files.append(ROOT / raw.decode("utf-8"))
    return files


def path_role(path: Path) -> str:
    rel = path.relative_to(ROOT).as_posix()
    if rel.startswith("docs/truth/"):
        return "truth"
    if rel.startswith("docs/audits/") or rel.startswith("prompts/") or rel.startswith("docs/AmbitionsCanon/") or rel.startswith("docs/canon/") or rel.startswith("docs/archive/") or rel.startswith("docs/handoff/") or rel.startswith(".codex/runs/"):
        return "historical"
    if rel in {"README.md", "AGENTS.md", "docs/README.md"} or rel.startswith("docs/status/") or rel.startswith("docs/codex/") or rel.startswith("docs/governance/") or rel.startswith("docs/proof/") or rel.startswith("docs/review/") or rel.startswith("docs/permissions-") or rel.startswith(".codex/") or rel.startswith(".agents/") or rel.startswith("scripts/") or rel.startswith("tools/") or rel.startswith("build/audits/") or rel.startswith("build/reports/") or rel.startswith("frontend/visual-encyclopedia/"):
        return "supporting"
    if rel.startswith("Native/") or rel.startswith("Sources/") or rel.startswith("AppUI/") or rel == "project.yml" or rel == "Package.swift":
        return "source"
    return "other"


def should_scan(path: Path) -> bool:
    rel = path.relative_to(ROOT).as_posix()
    return any(rel == prefix.rstrip("/") or rel.startswith(prefix) for prefix in SCAN_PREFIXES)


def is_text(path: Path) -> bool:
    rel = path.relative_to(ROOT).as_posix()
    if path.is_dir():
        return False
    if rel in {"README.md", "AGENTS.md", "project.yml", "Package.swift"}:
        return True
    if path.suffix.lower() in TEXT_SUFFIXES:
        return True
    return False


def repair_train_for(term: str) -> str | None:
    normalized = term.lower()
    if normalized == "plan":
        return "Time / Plan compatibility seam"
    if normalized == "profile":
        return "You / Personal System Center compatibility seam"
    if normalized == "habits":
        return "Time / Rituals compatibility seam"
    if normalized == "insights":
        return "You / contextual intelligence compatibility seam"
    if normalized == "captures":
        return "Capture singularization / compatibility seam"
    if normalized == "capture":
        return "Capture / Atmosphere Composer active surface"
    return None


def is_root_claim(line: str) -> bool:
    lower = line.lower()
    if ACTIVE_IA_PHRASE.search(lower):
        return False
    if "compatibility" in lower or "historical" in lower or "legacy" in lower or "internal" in lower or "support" in lower or "contextual" in lower or "alias" in lower or "retained" in lower or "old " in lower:
        return False
    return bool(ROOT_CONTEXT_RE.search(lower))


def is_forbidden_root_claim(line: str, term: str) -> bool:
    normalized = term.lower()
    if normalized not in {"plan", "profile", "habits", "insights", "captures"}:
        return False
    if not is_root_claim(line):
        return False
    if CONTEXTUAL_NOUN_RE.search(line):
        return False
    if re.search(r"\b(no|not|avoid|ban(?:ned)?|forbid(?:den)?|never)\b", line, re.I):
        return False
    return True


def classify_hit(path: Path, line: str, term: str) -> tuple[str, str]:
    role = path_role(path)
    lower = line.lower()
    has_accessibility_id = bool(ACCESSIBILITY_ID_RE.search(line))
    has_test_context = bool(TEST_CONTEXT_RE.search(line))
    has_compatibility = bool(COMPATIBILITY_RE.search(line))
    has_source_compatibility = bool(SOURCE_COMPATIBILITY_RE.search(line))
    term_is_forbidden_root = is_forbidden_root_claim(line, term)
    has_negative_guardrail = bool(NEGATIVE_GUARDRAIL_RE.search(line) or "forbidden" in lower)
    has_forbidden_root = term_is_forbidden_root and is_root_claim(line)
    has_active_truth_phrase = bool(ACTIVE_IA_PHRASE.search(line))
    is_test_file = bool(TEST_FILE_RE.search(path.name) or "Tests" in path.as_posix() or "UITests" in path.as_posix())

    if has_forbidden_root and has_negative_guardrail:
        return "active_truth_allowed", "line states a truth-consistent prohibition against stale top-level vocabulary"

    if role == "truth":
        return "active_truth_allowed", "active truth file states an allowed product/IA rule"

    if has_accessibility_id:
        return "accessibility_identifier", "line defines or references a stable accessibility identifier"

    if is_test_file or has_test_context:
        if has_forbidden_root or re.search(r"\b(top[- ]level|visible|surface|screen|route|tab)\b", lower):
            return "test_expectation", "test or automation expectation references a surface name"

    if has_active_truth_phrase:
        return "active_truth_allowed", "line restates the active top-level IA"

    if has_compatibility:
        if role in {"historical", "supporting"}:
            return role, f"{role} material preserves compatibility or legacy context"
        return "internal_compatibility", "line describes a compatibility seam, alias, or migration surface"

    if role == "historical":
        return "historical", "historical material preserves prior vocabulary or provenance"

    if role == "supporting":
        if ORDINARY_RE.search(line):
            return "ordinary_language", "supporting material uses the term in ordinary prose"
        return "supporting", "supporting material references the term without making active-product claims"

    if role == "source" and has_source_compatibility:
        return "internal_compatibility", "source line preserves an active compatibility seam or route alias"

    if has_forbidden_root and role == "source":
        return "active_forbidden_root", "current source text frames a forbidden root as active or visible"

    if term.lower() == "captures" and role == "source":
        return "ordinary_language", "source uses captures as plural Capture-item data, not a root surface claim"

    if ORDINARY_RE.search(line):
        return "ordinary_language", "term is used in ordinary prose or a non-root context"

    if role == "source":
        return "needs_owner_review", "source line matched the vocabulary set but did not land cleanly in a policy bucket"

    if role == "other":
        return "needs_owner_review", "unclassified repository material requires owner review"

    return "needs_owner_review", "unclassified repository material requires owner review"


def scan_files(paths: Iterable[Path]) -> tuple[list[Hit], int]:
    hits: list[Hit] = []
    scanned = 0
    for path in paths:
        if not should_scan(path):
            continue
        if not is_text(path):
            continue
        scanned += 1
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        rel = path.relative_to(ROOT).as_posix()
        for line_no, line in enumerate(text.splitlines(), start=1):
            for match in TERM_REGEX.finditer(line):
                term = match.group("term")
                classification, reason = classify_hit(path, line, term)
                hits.append(
                    Hit(
                        file=rel,
                        line=line_no,
                        term=term,
                        excerpt=line.strip(),
                        classification=classification,
                        reason=reason,
                        path_role=path_role(path),
                        repair_train=repair_train_for(term),
                    )
                )
    hits.sort(key=lambda hit: (hit.file, hit.line, hit.term, hit.classification))
    return hits, scanned


def safe_excerpt(text: str, limit: int = 180) -> str:
    text = " ".join(text.split())
    return text if len(text) <= limit else text[: limit - 1] + "…"


def group_counts(hits: list[Hit]) -> Counter[str]:
    counts: Counter[str] = Counter()
    for hit in hits:
        counts[hit.classification] += 1
    return counts


def build_report(hits: list[Hit]) -> dict:
    counts = group_counts(hits)
    files_with_hits = sorted({hit.file for hit in hits})
    forbidden_active = [
        hit for hit in hits
        if hit.classification == "active_forbidden_root" and hit.path_role in {"truth", "supporting", "source"}
    ]
    owner_review = [hit for hit in hits if hit.classification == "needs_owner_review"]

    by_term = Counter(hit.term for hit in hits)
    by_file = Counter(hit.file for hit in hits)
    by_role = Counter(hit.path_role for hit in hits)

    unique_forbidden_trains = []
    seen_trains = set()
    for hit in forbidden_active:
        if hit.repair_train and hit.repair_train not in seen_trains:
            seen_trains.add(hit.repair_train)
            unique_forbidden_trains.append(hit.repair_train)

    return {
        "batch_id": BATCH_ID,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "branch": subprocess.run(["git", "branch", "--show-current"], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip(),
        "sha": subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip(),
        "scan_roots": list(SCAN_PREFIXES),
        "files_scanned": None,
        "files_with_hits": len(files_with_hits),
        "total_hits": len(hits),
        "counts_by_classification": dict(counts),
        "counts_by_term": dict(by_term),
        "counts_by_path_role": dict(by_role),
        "top_files_by_hit_count": [
            {"file": file, "hits": count}
            for file, count in by_file.most_common(25)
        ],
        "forbidden_active_ownership_hits": [asdict(hit) for hit in forbidden_active],
        "forbidden_active_owner_trains": unique_forbidden_trains,
        "yellow_owner_review_hits": [asdict(hit) for hit in owner_review],
        "allowed_hit_policy": {
            "active_truth_allowed": "Current truth files and current truth-consistent statements are allowed and do not imply implementation proof.",
            "internal_compatibility": "Compatibility seams, aliases, raw values, and migration surfaces are retained until a scoped owner proves retirement.",
            "accessibility_identifier": "Stable automation identifiers are compatibility surfaces and should be frozen, aliased, or retired only with proof.",
            "test_expectation": "Tests may assert current compatibility or visible labels; do not rewrite them blindly during a vocabulary audit.",
            "historical": "Historical material stays labeled as history and is not cleanup proof.",
            "supporting": "Supporting material is non-authority and may retain compatibility language when clearly classified.",
            "ordinary_language": "Ordinary prose uses of the words are allowed and should not be rewritten without need.",
            "needs_owner_review": "Ambiguous hits require a human or scoped owner decision before any cleanup or rename.",
        },
        "non_claims": [
            "No source, test, or product behavior was changed by this scan.",
            "No zero-hit claim is made for the vocabulary families.",
            "No implementation, accessibility, performance, privacy, or release readiness claim is made.",
            "No blind replacement or mass rename was performed.",
        ],
    }


def render_markdown(report: dict) -> str:
    def table(headers: list[str], rows: list[list[str]]) -> str:
        lines = ["| " + " | ".join(headers) + " |"]
        lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
        for row in rows:
            lines.append("| " + " | ".join(row) + " |")
        return "\n".join(lines)

    counts = report["counts_by_classification"]
    forbidden = [Hit(**item) for item in report["forbidden_active_ownership_hits"]]
    owner_review = [Hit(**item) for item in report["yellow_owner_review_hits"]]

    lines = [
        f"# {BATCH_ID} Surface Vocabulary Ledger",
        "",
        "Status: Classification ledger for stale IA/surface vocabulary.",
        f"Date: {report['generated_at']}",
        "",
        "## Scope",
        "- Scanned tracked files under the batch-approved documentation, source, test, prompt, and governance roots.",
        "- Classified each vocabulary hit without performing replacements or renames.",
        "- Preserved compatibility, historical, supporting, and ordinary-language hits as classified evidence.",
        "",
        "## Summary Counts",
        table(
            ["classification", "count"],
            [[k, str(counts.get(k, 0))] for k in [
                "active_truth_allowed",
                "active_forbidden_root",
                "internal_compatibility",
                "accessibility_identifier",
                "test_expectation",
                "historical",
                "supporting",
                "ordinary_language",
                "needs_owner_review",
            ]],
        ),
        "",
        f"Total hits: `{report['total_hits']}`",
        f"Files with hits: `{report['files_with_hits']}`",
        "",
        "## Forbidden Active Ownership Map",
    ]

    if forbidden:
        rows = []
        for hit in forbidden[:200]:
            rows.append([
                f"`{hit.term}`",
                f"`{hit.file}:{hit.line}`",
                f"`{safe_excerpt(hit.excerpt)}`",
                f"`{hit.repair_train or 'needs owner review'}`",
            ])
        lines.append(table(["term", "location", "excerpt", "repair train"], rows))
        if len(forbidden) > 200:
            lines.append("")
            lines.append(f"Additional forbidden active ownership hits omitted from markdown: `{len(forbidden) - 200}`")
    else:
        lines.append("- None")

    lines.extend([
        "",
        "## Yellow Owner-Review List",
    ])
    if owner_review:
        rows = []
        for hit in owner_review[:100]:
            rows.append([
                f"`{hit.file}:{hit.line}`",
                f"`{hit.term}`",
                f"`{hit.classification}`",
                f"`{safe_excerpt(hit.reason)}`",
            ])
        lines.append(table(["location", "term", "classification", "reason"], rows))
        if len(owner_review) > 100:
            lines.append("")
            lines.append(f"Additional owner-review hits omitted from markdown: `{len(owner_review) - 100}`")
    else:
        lines.append("- None")

    lines.extend([
        "",
        "## Allowed Hit Policy",
    ])
    for classification, policy in report["allowed_hit_policy"].items():
        lines.append(f"- `{classification}`: {policy}")

    lines.extend([
        "",
        "## Non-Claims",
    ])
    for item in report["non_claims"]:
        lines.append(f"- {item}")

    lines.extend([
        "",
        "## Notes",
        f"- JSON detail: `{JSON_PATH.relative_to(ROOT).as_posix()}`",
        "- This ledger is classification evidence only; it does not justify blind cleanup or zero-hit claims.",
    ])

    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the IA surface vocabulary ledger.")
    parser.add_argument("--write", action="store_true", help="Write the markdown and JSON ledger files.")
    args = parser.parse_args()

    tracked = git_tracked_files()
    hits, files_scanned = scan_files(tracked)
    report = build_report(hits)
    report["files_scanned"] = files_scanned
    markdown = render_markdown(report)

    print(f"# {BATCH_ID}")
    print(f"files_scanned={report['files_scanned']} files_with_hits={report['files_with_hits']} total_hits={report['total_hits']}")
    for key in [
        "active_truth_allowed",
        "active_forbidden_root",
        "internal_compatibility",
        "accessibility_identifier",
        "test_expectation",
        "historical",
        "supporting",
        "ordinary_language",
        "needs_owner_review",
    ]:
        print(f"{key}={report['counts_by_classification'].get(key, 0)}")

    if args.write:
        JSON_PATH.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        MD_PATH.write_text(markdown, encoding="utf-8")
        print(f"wrote {JSON_PATH.relative_to(ROOT).as_posix()}")
        print(f"wrote {MD_PATH.relative_to(ROOT).as_posix()}")
    else:
        print(markdown)

    if report["counts_by_classification"].get("active_forbidden_root", 0) or report["counts_by_classification"].get("needs_owner_review", 0):
        print("YELLOW: forbidden-root or owner-review hits remain")
        return 0

    print("GREEN: all hits classified with no active forbidden-root hits")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
