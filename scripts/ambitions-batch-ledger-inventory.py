#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

OUT_DIR = ROOT / "docs" / "ops" / "batch-ledger"
OUT_JSON = OUT_DIR / "batch-ledger.json"
OUT_MD = OUT_DIR / "batch-ledger.md"
SCHEMA_PATH = "docs/ops/batch-ledger/schema.md"

TRUTH_DOCS = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

SEQUENCE_DOCS = [
    "docs/codex/GLOBAL_BATCH_SEQUENCE.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md",
]

SCAN_PREFIXES = (
    "prompts/batches/",
    "prompts/trains/",
    "docs/codex/",
    ".codex/",
    "build/reports/",
    "docs/audits/",
)

TEXT_EXTENSIONS = {
    ".md",
    ".txt",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".py",
    ".rb",
}

STATUS_VALUES = {
    "planned",
    "installed_not_run",
    "source_present",
    "partial",
    "implemented",
    "implemented_source_only",
    "validated",
    "accepted_yellow",
    "green",
    "red",
    "unknown",
    "canceled",
    "retired",
    "superseded",
    "historical",
}

PROOF_VALUES = {
    "none",
    "source_only",
    "audit",
    "dry_run",
    "test_log",
    "build_log",
    "screenshot",
    "device",
    "release_packet",
    "current_green",
    "current_yellow",
    "current_red",
    "historical_only",
}

SURFACE_TERMS = {
    "today": "Today",
    "reality meridian": "Today",
    "start here": "Today",
    "goals": "Goals",
    "constellation atlas": "Goals",
    "capture": "Capture",
    "atmosphere composer": "Capture",
    "time": "Time",
    "lifeshape": "Time",
    "you": "You",
    "user system profile": "You",
    "pulse": "Pulse",
}

SYSTEM_TERMS = {
    "runtime": "runtime",
    "private life runtime": "runtime",
    "kernel": "runtime",
    "frontend": "frontend",
    "swiftui": "frontend",
    "design": "frontend",
    "accessibility": "accessibility",
    "voiceover": "accessibility",
    "dynamic type": "accessibility",
    "reduce motion": "accessibility",
    "performance": "performance",
    "instruments": "performance",
    "memory": "performance",
    "privacy": "privacy",
    "release": "release",
    "app store": "release",
    "testflight": "release",
    "proof": "proof",
    "receipt": "proof",
    "codex": "codex",
    "runner": "codex",
    "ios26": "ios26",
    "linear": "linear",
    "sync": "linear",
    "cloudkit": "persistence",
    "icloud": "persistence",
    "persistence": "persistence",
    "migration": "persistence",
}

OLD_CANON_TERMS = [
    ("Plan tab", "old_ia_language"),
    ("Profile tab", "old_ia_language"),
    ("Captures tab", "old_ia_language"),
    ("Dashboard", "old_canon_language"),
    ("AI recommends", "old_canon_language"),
    ("best next move", "old_canon_language"),
    ("next best move", "old_canon_language"),
    ("Begin Focus", "old_canon_language"),
    ("overdue", "old_canon_language"),
    ("failed", "old_canon_language"),
    ("streak", "old_canon_language"),
    ("productivity score", "old_canon_language"),
]

RELEASE_OVERCLAIM_TERMS = [
    "release ready",
    "production ready",
    "app store ready",
    "testflight ready",
    "fully validated",
    "fully tested",
    "device validated",
    "accessibility validated",
]

IOS26_BATCH_RE = re.compile(r"(IOS26-[A-Z0-9]+(?:-[A-Z0-9]+)*|IOS26-T[0-9A-Z]+-B[0-9]+[A-Za-z0-9-]*)")


@dataclass
class LedgerItem:
    stable_id: str
    item_type: str
    repo_path: str
    title: str
    source_authority: str
    current_status: str
    proof_state: str
    initial_added_date: str
    initial_added_commit: str
    touched_surfaces: list[str]
    touched_systems: list[str]
    touched_files: list[str]
    source_of_truth_docs: list[str]
    proof_paths: list[str]
    conflicts: list[str]
    duplicates: list[str]
    blockers: list[str]
    related_linear_issues: list[str]
    runner_command: str
    linear_sync_key: str
    no_claims: list[str]


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


def git_files() -> list[str]:
    out = run(["git", "ls-files"])
    return [line.strip() for line in out.splitlines() if line.strip()]


def first_seen(path: str) -> tuple[str, str]:
    out = run(
        ["git", "log", "--follow", "--reverse", "--date=short", "--format=%H%x09%ad", "--", path],
        check=False,
    )
    for line in out.splitlines():
        if "\t" in line:
            commit, date = line.split("\t", 1)
            return commit.strip() or "unknown", date.strip() or "unknown"
    return "unknown", "unknown"


def read_text(path: str) -> str:
    try:
        return (ROOT / path).read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def is_scannable(path: str) -> bool:
    p = Path(path)
    if p.suffix not in TEXT_EXTENSIONS:
        return False
    return path.startswith(SCAN_PREFIXES)


def first_heading_or_title(path: str, text: str) -> str:
    for line in text.splitlines()[:140]:
        stripped = line.strip()
        if stripped.startswith("# "):
            return stripped[2:].strip()
        if stripped.lower().startswith("title:"):
            return stripped.split(":", 1)[1].strip().strip("\"'")
        if stripped.lower().startswith("name:") and "manifest" in path.lower():
            return stripped.split(":", 1)[1].strip().strip("\"'")
    return Path(path).stem.replace("_", " ").replace("-", " ")


def stable_id_for(path: str, text: str) -> str:
    stem = Path(path).stem
    m = IOS26_BATCH_RE.search(stem)
    if m:
        return m.group(1)

    for pattern in [
        r"(?im)^program_id:\s*([A-Z0-9_-]+)",
        r"(?im)^train_id:\s*([A-Z0-9_-]+)",
        r"(?im)^batch_id:\s*([A-Z0-9_-]+)",
        r"(?im)^id:\s*([A-Z0-9_-]+)",
    ]:
        match = re.search(pattern, text)
        if match:
            return match.group(1).strip()

    return stem


def item_type_for(path: str, text: str) -> str:
    lower = path.lower()

    if lower.startswith("build/reports/") or lower.startswith("docs/audits/"):
        return "proof_artifact"

    if lower.endswith(".sh") or (lower.startswith("scripts/") and lower.endswith(".py")):
        return "runner"

    if lower.startswith("prompts/batches/"):
        return "batch"

    if lower.startswith("prompts/trains/"):
        return "train"

    if "train_manifest" in lower or "manifest" in lower:
        return "train"

    if lower.startswith(".codex/"):
        return "status_mirror"

    if "global_batch_sequence" in lower or "sequence" in lower:
        return "sequence_authority"

    if lower.startswith("docs/codex/"):
        if "train" in lower:
            return "train"
        return "prompt"

    if "historical" in lower or "archive" in lower:
        return "historical_reference"

    return "prompt"


def status_for(path: str, text: str) -> str:
    lower = path.lower()
    hay = (path + "\n" + text[:5000]).lower()

    if "canceled" in hay or "cancelled" in hay:
        return "canceled"
    if "superseded" in hay:
        return "superseded"
    if "retired" in hay:
        return "retired"

    if lower.startswith(".codex/"):
        return "historical"

    if lower.startswith("docs/audits/") or lower.startswith("build/reports/"):
        if re.search(r"(?im)\bstatus:\s*red\b|\bred\b", hay):
            return "red"
        if re.search(r"(?im)\bstatus:\s*yellow\b|\byellow\b", hay):
            return "accepted_yellow"
        if re.search(r"(?im)\bstatus:\s*green\b|\bpassed\b|\bpass\b", hay):
            return "green"
        return "historical"

    if lower.startswith("prompts/batches/ios26"):
        return "installed_not_run"

    if lower.startswith("prompts/batches/") or lower.startswith("prompts/trains/"):
        return "planned"

    if "installed_not_run" in hay:
        return "installed_not_run"

    return "unknown"


def proof_state_for(path: str, text: str) -> str:
    lower = path.lower()
    hay = (path + "\n" + text[:5000]).lower()

    if lower.startswith("build/reports/") or lower.startswith("docs/audits/"):
        if "status: red" in hay or "classification: red" in hay:
            return "current_red"
        if "status: yellow" in hay or "classification: yellow" in hay:
            return "current_yellow"
        if "status: green" in hay or "passed" in hay:
            return "current_green"
        return "audit"

    if "xctest" in hay or "test log" in hay:
        return "test_log"
    if "xcodebuild" in hay or "build log" in hay:
        return "build_log"
    if "screenshot" in hay:
        return "screenshot"
    if "dry run" in hay or "dry-run" in hay:
        return "dry_run"

    return "none"


def source_authority_for(path: str, text: str) -> str:
    lower = path.lower()
    if lower.startswith("prompts/batches/ios26"):
        return "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
    if lower.startswith("docs/codex/"):
        return "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json"
    if lower.startswith("build/reports/") or lower.startswith("docs/audits/"):
        return "docs/truth/RELEASE_TRUTH.md"
    if lower.startswith(".codex/"):
        return "docs/truth/CODEX_PROCESS_TRUTH.md"
    return "docs/truth/HISTORICAL_POLICY.md"


def touched_surfaces_for(path: str, text: str) -> list[str]:
    hay = (path + "\n" + text[:12000]).lower()
    found = {label for term, label in SURFACE_TERMS.items() if term in hay}
    return sorted(found) if found else ["unknown"]


def touched_systems_for(path: str, text: str) -> list[str]:
    hay = (path + "\n" + text[:12000]).lower()
    found = {label for term, label in SYSTEM_TERMS.items() if term in hay}
    return sorted(found) if found else ["unknown"]


def source_truth_docs_for(text: str) -> list[str]:
    return [doc for doc in TRUTH_DOCS + SEQUENCE_DOCS if doc in text]


def referenced_paths_for(text: str) -> list[str]:
    candidates = set()

    for match in re.findall(r"`([^`]+)`", text):
        candidate = match.strip()
        if "/" in candidate and not candidate.startswith("http"):
            candidates.add(candidate)

    for match in re.findall(r"(?:(?:Native|docs|prompts|scripts|build|\.codex|\.linear-sync)/[A-Za-z0-9_./-]+)", text):
        candidates.add(match.strip())

    return sorted(candidates)


def proof_paths_for(text: str) -> list[str]:
    return [
        p
        for p in referenced_paths_for(text)
        if p.startswith("build/reports/")
        or p.startswith("docs/audits/")
        or "proof" in p.lower()
        or "log" in p.lower()
    ]


def conflict_types_for(path: str, text: str, status: str, proof_state: str) -> list[str]:
    conflicts = set()
    hay = (path + "\n" + text[:20000])
    hay_lower = hay.lower()

    for term, conflict in OLD_CANON_TERMS:
        if term.lower() in hay_lower:
            conflicts.add(conflict)

    for term in RELEASE_OVERCLAIM_TERMS:
        if term.lower() in hay_lower:
            conflicts.add("release_overclaim")

    if status in {"implemented", "validated", "green"} and proof_state in {"none", "source_only", "audit", "historical_only"}:
        conflicts.add("proof_missing")

    if status == "unknown":
        conflicts.add("stale_status")

    return sorted(conflicts)


def runner_command_for(path: str, stable_id: str) -> str:
    if path.startswith("prompts/batches/"):
        return f"scripts/ambitions-codex-train.sh {stable_id} {path}"
    return ""


def no_claims_for() -> list[str]:
    return [
        "ledger presence is not implementation proof",
        "source presence is not build proof",
        "source presence is not test proof",
        "audit presence is not current validation proof",
        "Linear status is not repo truth",
        "this ledger does not prove accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness",
    ]


def duplicate_groups(items: list[LedgerItem]) -> dict[str, list[str]]:
    groups: dict[str, list[str]] = defaultdict(list)
    for item in items:
        groups[item.stable_id].append(item.repo_path)
    return {sid: paths for sid, paths in groups.items() if len(paths) > 1}


def mark_duplicates(items: list[LedgerItem]) -> None:
    groups = duplicate_groups(items)
    for item in items:
        paths = groups.get(item.stable_id)
        if not paths:
            continue
        item.duplicates = [p for p in paths if p != item.repo_path]
        item.conflicts = sorted(set(item.conflicts + ["duplicate_batch"]))


def validate_items(items: list[LedgerItem]) -> list[str]:
    errors: list[str] = []
    required_fields = [
        "stable_id",
        "item_type",
        "repo_path",
        "title",
        "source_authority",
        "current_status",
        "proof_state",
        "no_claims",
    ]

    seen_paths = set()
    for index, item in enumerate(items):
        data = asdict(item)
        for field in required_fields:
            value = data.get(field)
            if value in (None, "", []):
                errors.append(f"item {index} missing required field: {field}")

        if item.repo_path in seen_paths:
            errors.append(f"duplicate repo_path row: {item.repo_path}")
        seen_paths.add(item.repo_path)

        if item.current_status not in STATUS_VALUES:
            errors.append(f"{item.repo_path}: invalid status {item.current_status}")

        if item.proof_state not in PROOF_VALUES:
            errors.append(f"{item.repo_path}: invalid proof_state {item.proof_state}")

        if item.current_status == "implemented" and item.proof_state in {"none", "source_only", "audit", "historical_only"}:
            errors.append(f"{item.repo_path}: implemented without complete proof")

        if item.initial_added_date == "":
            errors.append(f"{item.repo_path}: blank initial_added_date")

        if item.initial_added_commit == "":
            errors.append(f"{item.repo_path}: blank initial_added_commit")

    return errors


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    files = [path for path in git_files() if is_scannable(path)]
    items: list[LedgerItem] = []

    for path in sorted(files):
        text = read_text(path)
        stable_id = stable_id_for(path, text)
        commit, date = first_seen(path)
        status = status_for(path, text)
        proof_state = proof_state_for(path, text)
        refs = referenced_paths_for(text)

        item = LedgerItem(
            stable_id=stable_id,
            item_type=item_type_for(path, text),
            repo_path=path,
            title=first_heading_or_title(path, text),
            source_authority=source_authority_for(path, text),
            current_status=status,
            proof_state=proof_state,
            initial_added_date=date,
            initial_added_commit=commit,
            touched_surfaces=touched_surfaces_for(path, text),
            touched_systems=touched_systems_for(path, text),
            touched_files=[
                p for p in refs
                if p.startswith("Native/") or p.startswith("scripts/") or p.startswith("Tests/")
            ],
            source_of_truth_docs=source_truth_docs_for(text),
            proof_paths=proof_paths_for(text),
            conflicts=conflict_types_for(path, text, status, proof_state),
            duplicates=[],
            blockers=[],
            related_linear_issues=sorted(set(re.findall(r"\bAMB-\d+\b", text))),
            runner_command=runner_command_for(path, stable_id),
            linear_sync_key=f"ambitions-batch-ledger:{stable_id}:{path}",
            no_claims=no_claims_for(),
        )
        items.append(item)

    mark_duplicates(items)

    items.sort(
        key=lambda item: (
            item.initial_added_date == "unknown",
            item.initial_added_date,
            item.repo_path,
        )
    )

    errors = validate_items(items)

    counts = {
        "total": len(items),
        "by_item_type": dict(sorted(Counter(item.item_type for item in items).items())),
        "by_status": dict(sorted(Counter(item.current_status for item in items).items())),
        "by_proof_state": dict(sorted(Counter(item.proof_state for item in items).items())),
        "unknown_dates": sum(1 for item in items if item.initial_added_date == "unknown"),
        "duplicate_stable_ids": len(duplicate_groups(items)),
    }

    payload: dict[str, Any] = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": "BATCH-LEDGER-001",
        "linear_issue": "AMB-25",
        "schema_path": SCHEMA_PATH,
        "source_authority": {
            "repo_truth_wins": True,
            "read_first": TRUTH_DOCS,
            "sequence_authority": SEQUENCE_DOCS,
        },
        "counts": counts,
        "validation": {
            "status": "green" if not errors else "red",
            "errors": errors,
        },
        "items": [asdict(item) for item in items],
        "non_claims": [
            "This ledger is an inventory artifact.",
            "It does not prove implementation correctness.",
            "It does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Batch / Prompt / Train Ledger",
        "",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {payload['owner']}",
        f"Linear issue: {payload['linear_issue']}",
        f"Schema: `{SCHEMA_PATH}`",
        "",
        "## Status",
        "",
        f"- Validation: `{payload['validation']['status']}`",
        f"- Total items: `{counts['total']}`",
        f"- Unknown first-added dates: `{counts['unknown_dates']}`",
        f"- Duplicate stable IDs: `{counts['duplicate_stable_ids']}`",
        "",
        "## Counts by item type",
        "",
    ]

    for key, value in counts["by_item_type"].items():
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(["", "## Counts by status", ""])

    for key, value in counts["by_status"].items():
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(["", "## Counts by proof state", ""])

    for key, value in counts["by_proof_state"].items():
        lines.append(f"- `{key}`: `{value}`")

    if errors:
        lines.extend(["", "## Validation errors", ""])
        for error in errors:
            lines.append(f"- {error}")

    lines.extend(
        [
            "",
            "## Ledger",
            "",
            "| First added | Type | Status | Proof | Stable ID | Path |",
            "|---|---|---|---|---|---|",
        ]
    )

    for item in items:
        lines.append(
            f"| {item.initial_added_date} | {item.item_type} | {item.current_status} | "
            f"{item.proof_state} | `{item.stable_id}` | `{item.repo_path}` |"
        )

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
            "- Ledger presence is not implementation proof.",
            "- Source presence is not build or test proof.",
            "- Linear status is not repo truth.",
            "- This ledger does not prove accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "",
        ]
    )

    OUT_MD.write_text("\n".join(lines), encoding="utf-8")

    print(f"wrote {OUT_JSON.relative_to(ROOT)}")
    print(f"wrote {OUT_MD.relative_to(ROOT)}")
    print(f"items: {len(items)}")
    print(f"validation: {payload['validation']['status']}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
