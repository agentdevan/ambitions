#!/usr/bin/env python3
from __future__ import annotations

import fnmatch
import re
import subprocess
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / ".linear-sync" / "ambitions-linear-sync.yml"
REPORT = ROOT / ".linear-sync" / "reports" / "latest-dry-run.md"

TEXT_SUFFIXES = {
    ".md",
    ".swift",
    ".py",
    ".sh",
    ".yml",
    ".yaml",
    ".json",
    ".txt",
    ".rb",
    ".plist",
    ".xcprivacy",
}

STALE_TERMS = [
    ("Today / Goals / Capture / " + "Plan / You", "legacy IA with Plan"),
    ("Plan" + " tab", "legacy Plan tab"),
    ("Profile" + " tab", "legacy Profile tab"),
    ("AI recommends", "AI recommendation framing"),
    ("best next move", "legacy move language"),
    ("next " + "best move", "legacy next-move language"),
    ("over" + "due", "deprecated urgency term"),
    ("failed", "failure-state language"),
    ("streak", "streak-pressure language"),
    ("score", "score-pressure language"),
]

SAMPLE_REDACTIONS = [
    ("Begin " + "Focus", "legacy focus CTA"),
    ("next " + "move", "legacy move language"),
    ("top-level " + "Plan", "legacy Plan placement"),
]


@dataclass
class Rule:
    id: str
    kind: str
    classification: str = "unknown"
    include: bool = True
    create_work_items: bool = False
    sync_status_only: bool = False
    project: str = ""
    labels: list[str] = field(default_factory=list)
    paths: list[str] = field(default_factory=list)
    exclude_paths: list[str] = field(default_factory=list)
    priority_rules: dict[str, str] = field(default_factory=dict)
    reason: str = ""


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def clean(value: str) -> str:
    value = value.strip()
    if value in {"true", "false"}:
        return value
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value


def bool_value(value: str) -> bool:
    return clean(value).lower() == "true"


def load_rules() -> tuple[list[Rule], list[Rule]]:
    if not MANIFEST.exists():
        raise SystemExit(f"missing manifest: {rel(MANIFEST)}")

    include_rules: list[Rule] = []
    exclude_rules: list[Rule] = []
    current: Rule | None = None
    section: str | None = None
    active_list: str | None = None
    in_priority = False

    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        if raw.startswith("include_rules:"):
            section = "include"
            current = None
            continue
        if raw.startswith("exclude_rules:"):
            section = "exclude"
            current = None
            continue
        if raw and not raw.startswith(" ") and not raw.startswith("-"):
            if raw.endswith(":"):
                section = raw[:-1]
            active_list = None
            in_priority = False
            continue
        if section not in {"include", "exclude"}:
            continue

        line = raw.rstrip()
        if line.startswith("  - id:"):
            current = Rule(id=clean(line.split(":", 1)[1]), kind=section)
            (include_rules if section == "include" else exclude_rules).append(current)
            active_list = None
            in_priority = False
            continue
        if current is None:
            continue

        stripped = line.strip()
        if stripped in {"paths:", "exclude_paths:", "labels:"}:
            active_list = stripped[:-1]
            in_priority = False
            continue
        if stripped == "priority_rules:":
            active_list = None
            in_priority = True
            continue
        if line.startswith("      - ") and active_list:
            getattr(current, active_list).append(clean(line.split("- ", 1)[1]))
            continue
        if line.startswith("      ") and in_priority and ":" in stripped:
            key, value = stripped.split(":", 1)
            current.priority_rules[clean(key)] = clean(value)
            continue
        if line.startswith("    ") and ":" in stripped:
            key, value = stripped.split(":", 1)
            key = clean(key)
            value = clean(value)
            active_list = None
            in_priority = False
            if key == "class":
                current.classification = value
            elif key == "include":
                current.include = bool_value(value)
            elif key == "create_work_items":
                current.create_work_items = bool_value(value)
            elif key == "sync_status_only":
                current.sync_status_only = bool_value(value)
            elif key == "project":
                current.project = value
            elif key == "reason":
                current.reason = value

    return include_rules, exclude_rules


def git_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=True,
    )
    return sorted(line for line in result.stdout.splitlines() if line)


def matches(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, pattern) for pattern in patterns)


def classify(path: str, include_rules: list[Rule], exclude_rules: list[Rule]) -> Rule | None:
    for rule in exclude_rules:
        if matches(path, rule.paths):
            return rule
    for rule in include_rules:
        if matches(path, rule.exclude_paths):
            continue
        if matches(path, rule.paths):
            return rule
    return None


def is_text_file(path: str) -> bool:
    full = ROOT / path
    if not full.is_file():
        return False
    if full.suffix in TEXT_SUFFIXES:
        return True
    return full.name in {"Makefile", "AGENTS.md", "README.md"}


def scan_markers(paths: list[str]) -> tuple[Counter, list[tuple[str, int, str]]]:
    counts: Counter = Counter()
    samples: list[tuple[str, int, str]] = []
    pattern = re.compile(r"\b(TODO|FIXME)\b", re.IGNORECASE)
    for path in paths:
        if not is_text_file(path):
            continue
        try:
            lines = (ROOT / path).read_text(encoding="utf-8", errors="ignore").splitlines()
        except OSError:
            continue
        for number, line in enumerate(lines, 1):
            match = pattern.search(line)
            if not match:
                continue
            counts[match.group(1).upper()] += 1
            if len(samples) < 30:
                samples.append((path, number, line.strip()[:180]))
    return counts, samples


def scan_stale_terms(paths: list[str]) -> tuple[Counter, list[tuple[str, int, str, str]]]:
    counts: Counter = Counter()
    samples: list[tuple[str, int, str, str]] = []
    lowered_terms = [(pattern, label, pattern.lower()) for pattern, label in STALE_TERMS]
    for path in paths:
        if not is_text_file(path):
            continue
        try:
            lines = (ROOT / path).read_text(encoding="utf-8", errors="ignore").splitlines()
        except OSError:
            continue
        for number, line in enumerate(lines, 1):
            lowered = line.lower()
            for pattern, label, lowered_term in lowered_terms:
                if lowered_term not in lowered:
                    continue
                counts[label] += 1
                if len(samples) < 40:
                    snippet = line.strip()
                    for redact_pattern, redact_label in [*STALE_TERMS, *SAMPLE_REDACTIONS]:
                        snippet = re.sub(re.escape(redact_pattern), redact_label, snippet, flags=re.IGNORECASE)
                    samples.append((path, number, label, snippet[:180]))
    return counts, samples


def bullet_paths(paths: list[str], limit: int = 20) -> list[str]:
    if not paths:
        return ["- None"]
    lines = [f"- `{path}`" for path in paths[:limit]]
    if len(paths) > limit:
        lines.append(f"- ... {len(paths) - limit} more")
    return lines


def render_mapping(rule: Rule) -> str:
    labels = ", ".join(f"`{label}`" for label in rule.labels) or "`none`"
    priorities = ", ".join(f"{key}={value}" for key, value in rule.priority_rules.items()) or "none"
    return (
        f"- `{rule.id}` -> class `{rule.classification}`, project `{rule.project or 'none'}`, "
        f"labels {labels}, create_work_items={str(rule.create_work_items).lower()}, "
        f"sync_status_only={str(rule.sync_status_only).lower()}, priorities {priorities}"
    )


def main() -> int:
    include_rules, exclude_rules = load_rules()
    files = git_files()
    by_class: dict[str, list[str]] = defaultdict(list)
    by_rule: dict[str, list[str]] = defaultdict(list)
    unknown: list[str] = []

    for path in files:
        rule = classify(path, include_rules, exclude_rules)
        if rule is None:
            by_class["unknown"].append(path)
            unknown.append(path)
            continue
        target_class = "ignored" if rule.kind == "exclude" else rule.classification
        by_class[target_class].append(path)
        by_rule[rule.id].append(path)

    active_paths = (
        by_class.get("active_truth", [])
        + by_class.get("active_work", [])
        + by_class.get("source", [])
        + by_class.get("test", [])
        + by_class.get("proof", [])
    )
    marker_counts, marker_samples = scan_markers(active_paths)
    stale_counts, stale_samples = scan_stale_terms(files)

    active_canon = by_rule.get("active_truth", [])
    decisions = by_rule.get("future_decisions_specs_traceability", [])
    active_decisions = [p for p in decisions if p.startswith("docs/decisions/")]
    active_specs = [p for p in decisions if p.startswith("docs/specs/")]
    active_traceability = [p for p in decisions if p.startswith("docs/traceability/")]
    active_batch_prompts = by_rule.get("ios26_batch_prompts", [])
    proof_artifacts = by_rule.get("proof_paths", [])

    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    lines: list[str] = [
        "# Linear Sync Dry Run",
        "",
        "Status: dry_run_only",
        f"Generated UTC: {now}",
        f"Manifest: `{rel(MANIFEST)}`",
        "Linear writes: none",
        "",
        "## Summary",
    ]
    for key, count in sorted((key, len(value)) for key, value in by_class.items()):
        lines.append(f"- {key}: {count}")
    lines.extend(
        [
            f"- total scanned paths: {len(files)}",
            "",
            "## Proposed Linear Mappings",
            *(render_mapping(rule) for rule in include_rules),
            "",
            "## Exclusions",
            *(f"- `{rule.id}` -> class `ignored`, reason: {rule.reason or 'ignored by manifest'}" for rule in exclude_rules),
            "",
            "## Active Canon Files",
            *bullet_paths(active_canon),
            "",
            "## Active Decision Records",
            *bullet_paths(active_decisions),
            "",
            "## Active Specs",
            *bullet_paths(active_specs),
            "",
            "## Active Traceability",
            *bullet_paths(active_traceability),
            "",
            "## Active Batch Prompts",
            *bullet_paths(active_batch_prompts),
            "",
            "## Proof Artifacts",
            *bullet_paths(proof_artifacts),
            "",
            "## Historical Paths",
            *bullet_paths(by_class.get("historical_reference", [])),
            "",
            "## Ignored Paths",
            *bullet_paths(by_class.get("ignored", [])),
            "",
            "## Unknown Paths",
            *bullet_paths(unknown),
            "",
            "## TODO/FIXME Markers",
        ]
    )
    if marker_counts:
        for key, count in sorted(marker_counts.items()):
            lines.append(f"- {key}: {count}")
    else:
        lines.append("- None found in active classes")
    lines.append("")
    lines.append("### Marker Samples")
    if marker_samples:
        lines.extend(f"- `{path}:{number}` {text}" for path, number, text in marker_samples)
    else:
        lines.append("- None")

    lines.extend(["", "## Stale/Deprecated Canon Terms"])
    if stale_counts:
        for term, count in sorted(stale_counts.items()):
            lines.append(f"- `{term}`: {count}")
    else:
        lines.append("- None")
    lines.append("")
    lines.append("### Stale Term Samples")
    if stale_samples:
        lines.extend(f"- `{path}:{number}` `{term}` - {text}" for path, number, term, text in stale_samples)
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Non-Claims",
            "- This dry run does not write to Linear.",
            "- This dry run does not prove implementation completeness.",
            "- This dry run does not prove build, test, accessibility, performance, device, TestFlight, App Store, privacy, legal, or release readiness.",
            "- Historical paths remain historical unless repo truth explicitly promotes them.",
            "",
        ]
    )

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {rel(REPORT)}")
    print("linear writes: none")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
