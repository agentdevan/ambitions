#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

LEDGER_JSON = ROOT / "docs" / "ops" / "batch-ledger" / "batch-ledger.json"
TOUCHPOINT_REPORT = ROOT / "docs" / "ops" / "batch-ledger" / "touchpoint-report.md"

REQUIRED_SURFACES = ["Today", "Goals", "Time", "Motion", "You", "Capture"]

REQUIRED_SYSTEMS = [
    "IA",
    "chrome",
    "shell",
    "frontend",
    "runtime",
    "privacy",
    "accessibility",
    "monetization",
    "branding",
    "proof",
]

TRUTH_DOCS = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/truth/PRODUCT_UPGRADES_VISION.md",
    "AGENTS.md",
    "README.md",
]

AUTHORITY_DOCS = [
    "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md",
    "docs/codex/LINEAR_CONTROL_PLANE.md",
    "docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md",
]

SURFACE_PATTERNS: dict[str, list[str]] = {
    "Today": [
        r"\bToday\b",
        r"Reality Meridian",
        r"Reality Current",
        r"Start Here",
        r"Start here",
        r"DayTimelineRail",
        r"TodayScreen",
        r"Hero Step",
    ],
    "Goals": [
        r"\bGoals\b",
        r"Constellation Atlas",
        r"Goal Detail",
        r"Goal Path",
        r"GoalScreen",
        r"Mission Control",
    ],
    "Time": [
        r"\bTime\b",
        r"LifeShape",
        r"Life Shape",
        r"Calendar",
        r"Schedule",
        r"Availability",
        r"Free time",
        r"TimeScreen",
    ],
    "Motion": [
        r"\bMotion\b",
        r"Motion Current",
        r"proof progress",
        r"progress surface",
        r"inspection surface",
        r"proof surface",
        r"recovery surface",
    ],
    "You": [
        r"\bYou\b",
        r"User System Profile",
        r"Profile",
        r"Personal System",
        r"Settings",
        r"YouScreen",
    ],
    "Capture": [
        r"\bCapture\b",
        r"Atmosphere Composer",
        r"CaptureScreen",
        r"Quick Capture",
        r"Global Capture",
        r"Composer",
        r"intake",
    ],
}

SYSTEM_PATTERNS: dict[str, list[str]] = {
    "IA": [
        r"\bIA\b",
        r"information architecture",
        r"top-level",
        r"tab",
        r"navigation",
        r"surface hierarchy",
    ],
    "chrome": [
        r"\bchrome\b",
        r"Living Chrome",
        r"shell chrome",
        r"navigation chrome",
        r"contextual chrome",
    ],
    "shell": [
        r"\bshell\b",
        r"root shell",
        r"app shell",
        r"native shell",
        r"AmbitionsRootView",
    ],
    "frontend": [
        r"frontend",
        r"SwiftUI",
        r"view",
        r"screen",
        r"component",
        r"visual",
        r"design system",
        r"preview",
    ],
    "runtime": [
        r"runtime",
        r"Private Life Runtime",
        r"kernel",
        r"service",
        r"repository",
        r"compiler",
        r"recommendation",
        r"local-first",
    ],
    "privacy": [
        r"privacy",
        r"local-only",
        r"local first",
        r"CloudKit",
        r"iCloud",
        r"permission",
        r"private",
        r"data boundary",
    ],
    "accessibility": [
        r"accessibility",
        r"VoiceOver",
        r"Dynamic Type",
        r"Reduce Motion",
        r"contrast",
        r"assistive",
        r"AX",
    ],
    "monetization": [
        r"monetization",
        r"StoreKit",
        r"subscription",
        r"paywall",
        r"entitlement",
        r"free loop",
        r"paid engine",
    ],
    "branding": [
        r"brand",
        r"branding",
        r"logo",
        r"wordmark",
        r"icon",
        r"typography",
        r"North Star",
    ],
    "proof": [
        r"proof",
        r"receipt",
        r"evidence",
        r"validation",
        r"test",
        r"build log",
        r"screenshot",
        r"release claim",
    ],
}

CANON_CONFLICT_PATTERNS: list[tuple[str, str]] = [
    (r"\bPlan tab\b", "old_ia_language"),
    (r"\bProfile tab\b", "old_ia_language"),
    (r"\bCaptures tab\b", "old_ia_language"),
    (r"\bCapture tab\b", "old_ia_language"),
    (r"\bPulse\b", "old_ia_language"),
    (r"\bnext best move\b", "old_canon_language"),
    (r"\bbest next move\b", "old_canon_language"),
    (r"\bBegin Focus\b", "old_canon_language"),
    (r"\boverdue\b", "old_canon_language"),
    (r"\bstreak\b", "old_canon_language"),
    (r"\bproductivity score\b", "old_canon_language"),
    (r"\bDashboard\b", "old_canon_language"),
    (r"\brelease ready\b", "release_overclaim"),
    (r"\bproduction ready\b", "release_overclaim"),
    (r"\bApp Store ready\b", "release_overclaim"),
    (r"\bTestFlight ready\b", "release_overclaim"),
    (r"\bfully validated\b", "release_overclaim"),
    (r"\bfully tested\b", "release_overclaim"),
]

PATH_RE = re.compile(
    r"(?:(?:Native|Tests|docs|prompts|scripts|build|\.codex|\.linear-sync|Ambitions)/[A-Za-z0-9_./@+-]+)"
)

BACKTICK_PATH_RE = re.compile(r"`([^`]+)`")

VALIDATION_COMMAND_RE = re.compile(
    r"(?im)^\s*(?:"
    r"make\s+[A-Za-z0-9_.:/@+=,-]+(?:\s+[A-Za-z0-9_.:/@+=,-]+)*"
    r"|xcodebuild\b[^\n]*"
    r"|swift\s+test\b[^\n]*"
    r"|python3?\s+(?:scripts|\.linear-sync|source-atlas)/[^\n]+"
    r"|bash\s+scripts/[^\n]+"
    r"|scripts/[A-Za-z0-9_./-]+\.sh\b[^\n]*"
    r")\s*$"
)

PROOF_PATH_PREFIXES = (
    "build/reports/",
    "docs/audits/",
    ".codex/logs/",
    ".codex/runs/",
    "screenshots/",
    "docs/ops/",
)


def run(cmd: list[str], *, check: bool = True) -> str:
    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if check and proc.returncode != 0:
        raise RuntimeError(
            f"command failed: {' '.join(cmd)}\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    return proc.stdout.strip()


def git_files() -> set[str]:
    out = run(["git", "ls-files"])
    return {line.strip() for line in out.splitlines() if line.strip()}


def read_text(repo_path: str) -> str:
    path = ROOT / repo_path
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def load_ledger() -> dict[str, Any]:
    if not LEDGER_JSON.exists():
        raise FileNotFoundError(f"missing {LEDGER_JSON.relative_to(ROOT)}; run make batch-ledger-inventory first")
    text = LEDGER_JSON.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"{LEDGER_JSON.relative_to(ROOT)} is empty; rerun make batch-ledger-inventory")
    payload = json.loads(text)
    if "items" not in payload or not isinstance(payload["items"], list):
        raise ValueError("batch-ledger.json is missing items[]")
    return payload


def normalize_path(candidate: str) -> str:
    candidate = candidate.strip().strip(".,);:]}")
    candidate = candidate.strip("'\"")
    while candidate.startswith("./"):
        candidate = candidate[2:]
    return candidate


def detect_paths(text: str, known_files: set[str]) -> list[str]:
    found: set[str] = set()

    for match in PATH_RE.findall(text):
        found.add(normalize_path(match))

    for match in BACKTICK_PATH_RE.findall(text):
        candidate = normalize_path(match)
        if "/" in candidate and not candidate.startswith("http"):
            found.add(candidate)

    # Keep exact known paths, and also keep proof-like generated paths that may not be tracked.
    kept = set()
    for candidate in found:
        if candidate in known_files:
            kept.add(candidate)
        elif candidate.startswith(PROOF_PATH_PREFIXES):
            kept.add(candidate)
        elif candidate.startswith(("Native/", "Tests/", "docs/", "prompts/", "scripts/", "build/", ".codex/", ".linear-sync/")):
            kept.add(candidate)

    return sorted(kept)


def detect_source_files(paths: list[str]) -> list[str]:
    prefixes = ("Native/", "Tests/", "scripts/", "Ambitions/")
    suffixes = (".swift", ".py", ".sh", ".rb", ".json", ".yml", ".yaml", ".plist")
    return sorted({p for p in paths if p.startswith(prefixes) and p.endswith(suffixes)})


def detect_truth_docs(text: str, paths: list[str]) -> list[str]:
    found = set()
    hay = text
    for doc in TRUTH_DOCS + AUTHORITY_DOCS:
        if doc in hay or doc in paths:
            found.add(doc)
    return sorted(found)


def detect_proof_paths(text: str, paths: list[str]) -> list[str]:
    found = set()
    for path in paths:
        lower = path.lower()
        if path.startswith(PROOF_PATH_PREFIXES) or "proof" in lower or "report" in lower or "log" in lower:
            found.add(path)
    return sorted(found)


def detect_validation_commands(text: str) -> list[str]:
    commands = []
    for match in VALIDATION_COMMAND_RE.findall(text):
        command = " ".join(match.strip().split())
        if command and command not in commands:
            commands.append(command)
    return commands


def detect_from_patterns(text: str, patterns: dict[str, list[str]], allowed: list[str]) -> list[str]:
    found = set()
    for label, regexes in patterns.items():
        for pattern in regexes:
            if re.search(pattern, text, flags=re.IGNORECASE):
                found.add(label)
                break
    ordered = [label for label in allowed if label in found]
    return ordered if ordered else ["unknown"]


def detect_conflicts(text: str, existing: list[str], surfaces: list[str], item: dict[str, Any]) -> list[str]:
    conflicts = set(existing or [])

    for pattern, conflict in CANON_CONFLICT_PATTERNS:
        if re.search(pattern, text, flags=re.IGNORECASE):
            conflicts.add(conflict)

    status = item.get("current_status", "unknown")
    proof_state = item.get("proof_state", "none")
    if status in {"implemented", "validated", "green"} and proof_state in {"none", "source_only", "audit", "historical_only"}:
        conflicts.add("proof_missing")

    surface_set = [s for s in surfaces if s != "unknown"]
    if len(surface_set) >= 3 and item.get("item_type") in {"batch", "prompt", "train"}:
        conflicts.add("multi_surface_scope")

    if surfaces == ["unknown"] and item.get("item_type") in {"batch", "prompt", "train"}:
        conflicts.add("unknown_surface")

    return sorted(conflicts)


def active_item(item: dict[str, Any]) -> bool:
    status = item.get("current_status", "unknown")
    if status in {"canceled", "retired", "superseded", "historical"}:
        return False
    return item.get("item_type") in {"batch", "prompt", "train"}


def build_overlap_reports(items: list[dict[str, Any]]) -> dict[str, Any]:
    surface_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)
    system_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)
    file_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)
    stable_id_to_items: dict[str, list[dict[str, Any]]] = defaultdict(list)

    for item in items:
        if not active_item(item):
            continue

        stable_id_to_items[item.get("stable_id", "unknown")].append(item)

        for surface in item.get("touched_surfaces", ["unknown"]):
            surface_to_items[surface].append(item)

        for system in item.get("touched_systems", ["unknown"]):
            system_to_items[system].append(item)

        for touched_file in item.get("touched_files", []):
            file_to_items[touched_file].append(item)

    duplicate_stable_ids = {
        stable_id: [entry["repo_path"] for entry in entries]
        for stable_id, entries in stable_id_to_items.items()
        if stable_id != "unknown" and len(entries) > 1
    }

    repeated_files = {
        path: [entry["repo_path"] for entry in entries]
        for path, entries in file_to_items.items()
        if len(entries) > 1
    }

    multi_surface_items = [
        {
            "stable_id": item.get("stable_id"),
            "repo_path": item.get("repo_path"),
            "touched_surfaces": item.get("touched_surfaces", []),
        }
        for item in items
        if active_item(item)
        and len([s for s in item.get("touched_surfaces", []) if s != "unknown"]) >= 3
    ]

    unknown_surface_items = [
        {
            "stable_id": item.get("stable_id"),
            "repo_path": item.get("repo_path"),
        }
        for item in items
        if active_item(item) and item.get("touched_surfaces") == ["unknown"]
    ]

    return {
        "surface_counts": dict(sorted((k, len(v)) for k, v in surface_to_items.items())),
        "system_counts": dict(sorted((k, len(v)) for k, v in system_to_items.items())),
        "duplicate_stable_ids": duplicate_stable_ids,
        "repeated_touched_files": repeated_files,
        "multi_surface_items": multi_surface_items,
        "unknown_surface_items": unknown_surface_items,
    }


def write_report(payload: dict[str, Any], overlap: dict[str, Any]) -> None:
    items = payload["items"]
    counts = payload.setdefault("counts", {})
    amb26 = payload.get("amb26_touchpoints", {})
    generated = payload.get("generated_utc", "unknown")

    lines = [
        "# Batch Ledger Touchpoint Report",
        "",
        f"Generated UTC: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}",
        "Owner: BATCH-LEDGER-001",
        "Linear issue: AMB-26",
        f"Ledger generated UTC: {generated}",
        "",
        "## Status",
        "",
        f"- Validation: `{amb26.get('status', 'unknown')}`",
        f"- Total ledger items: `{len(items)}`",
        f"- Items with unknown surface: `{amb26.get('unknown_surface_count', 0)}`",
        f"- Items with unknown system: `{amb26.get('unknown_system_count', 0)}`",
        f"- Items with validation commands: `{amb26.get('validation_command_item_count', 0)}`",
        f"- Items with proof paths: `{amb26.get('proof_path_item_count', 0)}`",
        "",
        "## Surface counts for active batch/prompt/train items",
        "",
    ]

    for surface, count in overlap.get("surface_counts", {}).items():
        lines.append(f"- `{surface}`: `{count}`")

    lines.extend(["", "## System counts for active batch/prompt/train items", ""])

    for system, count in overlap.get("system_counts", {}).items():
        lines.append(f"- `{system}`: `{count}`")

    lines.extend(["", "## Potential double work: duplicate stable IDs", ""])

    duplicates = overlap.get("duplicate_stable_ids", {})
    if duplicates:
        for stable_id, paths in list(sorted(duplicates.items()))[:80]:
            lines.append(f"- `{stable_id}`")
            for path in paths[:12]:
                lines.append(f"  - `{path}`")
            if len(paths) > 12:
                lines.append(f"  - ... {len(paths) - 12} more")
    else:
        lines.append("- None detected.")

    lines.extend(["", "## Potential double work: repeated touched files", ""])

    repeated_files = overlap.get("repeated_touched_files", {})
    if repeated_files:
        sorted_files = sorted(repeated_files.items(), key=lambda kv: (-len(kv[1]), kv[0]))
        for touched_file, owners in sorted_files[:80]:
            lines.append(f"- `{touched_file}` touched by `{len(owners)}` active items")
            for owner in owners[:10]:
                lines.append(f"  - `{owner}`")
            if len(owners) > 10:
                lines.append(f"  - ... {len(owners) - 10} more")
    else:
        lines.append("- None detected.")

    lines.extend(["", "## Potential conflicting surface ownership: multi-surface active items", ""])

    multi_surface_items = overlap.get("multi_surface_items", [])
    if multi_surface_items:
        for entry in multi_surface_items[:120]:
            surfaces = ", ".join(f"`{s}`" for s in entry["touched_surfaces"])
            lines.append(f"- `{entry['stable_id']}` -> {surfaces} — `{entry['repo_path']}`")
        if len(multi_surface_items) > 120:
            lines.append(f"- ... {len(multi_surface_items) - 120} more")
    else:
        lines.append("- None detected.")

    lines.extend(["", "## Unknown surface active items", ""])

    unknown_surface_items = overlap.get("unknown_surface_items", [])
    if unknown_surface_items:
        for entry in unknown_surface_items[:120]:
            lines.append(f"- `{entry['stable_id']}` — `{entry['repo_path']}`")
        if len(unknown_surface_items) > 120:
            lines.append(f"- ... {len(unknown_surface_items) - 120} more")
    else:
        lines.append("- None.")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
            "- Touchpoint detection is heuristic.",
            "- Touchpoint detection does not prove implementation, build, test, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "- Linear status is not repo truth.",
            "",
        ]
    )

    TOUCHPOINT_REPORT.write_text("\n".join(lines), encoding="utf-8")


def validate(payload: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for index, item in enumerate(payload["items"]):
        path = item.get("repo_path", f"index:{index}")

        surfaces = item.get("touched_surfaces")
        systems = item.get("touched_systems")

        if not isinstance(surfaces, list) or not surfaces:
            errors.append(f"{path}: missing touched_surfaces")
        if not isinstance(systems, list) or not systems:
            errors.append(f"{path}: missing touched_systems")

        for surface in surfaces or []:
            if surface not in REQUIRED_SURFACES and surface != "unknown":
                errors.append(f"{path}: invalid surface {surface}")

        for system in systems or []:
            if system not in REQUIRED_SYSTEMS and system != "unknown":
                errors.append(f"{path}: invalid system {system}")

        for field in ["touched_files", "source_of_truth_docs", "validation_commands", "proof_paths", "conflicts"]:
            if field not in item or not isinstance(item[field], list):
                errors.append(f"{path}: missing list field {field}")

    return errors


def main() -> int:
    known_files = git_files()
    payload = load_ledger()

    items = payload["items"]
    unknown_surface_count = 0
    unknown_system_count = 0
    validation_command_item_count = 0
    proof_path_item_count = 0

    for item in items:
        repo_path = item.get("repo_path", "")
        text = read_text(repo_path)
        detection_blob = "\n".join(
            [
                repo_path,
                item.get("title", ""),
                item.get("stable_id", ""),
                text[:60000],
            ]
        )

        paths = detect_paths(detection_blob, known_files)
        touched_files = detect_source_files(paths)
        truth_docs = detect_truth_docs(detection_blob, paths)
        proof_paths = detect_proof_paths(detection_blob, paths)
        validation_commands = detect_validation_commands(detection_blob)

        surfaces = detect_from_patterns(detection_blob, SURFACE_PATTERNS, REQUIRED_SURFACES)
        systems = detect_from_patterns(detection_blob, SYSTEM_PATTERNS, REQUIRED_SYSTEMS)

        item["touched_surfaces"] = surfaces
        item["touched_systems"] = systems
        item["touched_files"] = touched_files
        item["source_of_truth_docs"] = truth_docs
        item["validation_commands"] = validation_commands
        item["proof_paths"] = sorted(set((item.get("proof_paths") or []) + proof_paths))
        item["conflicts"] = detect_conflicts(detection_blob, item.get("conflicts") or [], surfaces, item)

        item["touchpoint_detection"] = {
            "linear_issue": "AMB-26",
            "status": "detected" if surfaces != ["unknown"] or systems != ["unknown"] else "unknown",
            "missing_or_ambiguous_surface": surfaces == ["unknown"],
            "missing_or_ambiguous_system": systems == ["unknown"],
        }

        if surfaces == ["unknown"]:
            unknown_surface_count += 1
        if systems == ["unknown"]:
            unknown_system_count += 1
        if validation_commands:
            validation_command_item_count += 1
        if item["proof_paths"]:
            proof_path_item_count += 1

    overlap = build_overlap_reports(items)
    errors = validate(payload)

    payload["amb26_touchpoints"] = {
        "status": "green" if not errors else "red",
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "linear_issue": "AMB-26",
        "required_surfaces": REQUIRED_SURFACES,
        "required_systems": REQUIRED_SYSTEMS,
        "unknown_surface_count": unknown_surface_count,
        "unknown_system_count": unknown_system_count,
        "validation_command_item_count": validation_command_item_count,
        "proof_path_item_count": proof_path_item_count,
        "potential_double_work": {
            "duplicate_stable_ids": len(overlap["duplicate_stable_ids"]),
            "repeated_touched_files": len(overlap["repeated_touched_files"]),
        },
        "potential_conflicting_surface_ownership": {
            "multi_surface_items": len(overlap["multi_surface_items"]),
            "unknown_surface_items": len(overlap["unknown_surface_items"]),
        },
        "validation_errors": errors,
    }

    # Preserve top-level validation but add AMB-26 detail.
    payload.setdefault("validation", {})
    if errors:
        payload["validation"]["status"] = "red"
        payload["validation"]["errors"] = sorted(set((payload["validation"].get("errors") or []) + errors))

    LEDGER_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_report(payload, overlap)

    print(f"wrote {LEDGER_JSON.relative_to(ROOT)}")
    print(f"wrote {TOUCHPOINT_REPORT.relative_to(ROOT)}")
    print(f"items: {len(items)}")
    print(f"amb26 validation: {payload['amb26_touchpoints']['status']}")
    print(f"unknown surfaces: {unknown_surface_count}")
    print(f"unknown systems: {unknown_system_count}")
    print(f"validation command items: {validation_command_item_count}")
    print(f"proof path items: {proof_path_item_count}")
    print(f"duplicate stable ids: {len(overlap['duplicate_stable_ids'])}")
    print(f"repeated touched files: {len(overlap['repeated_touched_files'])}")
    print(f"multi-surface active items: {len(overlap['multi_surface_items'])}")

    if errors:
        for error in errors[:100]:
            print(f"ERROR: {error}")
        if len(errors) > 100:
            print(f"... {len(errors) - 100} more errors")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
