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

SOURCE_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.json"
REMAINING_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/remaining-canon-collapse-resolution.json"
CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"

OUT_MD = ROOT / "docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json"

OWNER = "CANON-COLLAPSE-002"
LINEAR_ISSUE = "AMB-291"

HEADER_BEGIN = "<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->"
HEADER_END = "<!-- AMB-291-CANON-HYGIENE-HEADER: END -->"
AUTH_BEGIN = "<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->"
AUTH_END = "<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->"
NONCLAIM_BEGIN = "<!-- AMB-291-NON-CLAIMS: BEGIN -->"
NONCLAIM_END = "<!-- AMB-291-NON-CLAIMS: END -->"

AUTHORITY_FILES = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/ops/change-protocol/change-request-template.md",
    "docs/ops/change-protocol/change-impact-check.md",
    "docs/ops/change-protocol/implementation-prompt-template.md",
    "docs/ops/change-protocol/post-implementation-proof-reconciliation.md",
]

TARGET_PREFIXES = (
    "docs/codex/",
    "prompts/batches/",
    "docs/canon/",
)

EXCLUDE_PREFIXES = (
    "docs/ops/",
    "docs/truth/",
    "docs/proof/",
    "docs/audits/",
    "build/",
    ".codex/",
    ".linear-sync/",
    "Native/",
    "Sources/",
    "Tests/",
)

APP_SOURCE_PREFIXES = (
    "Native/",
    "Sources/",
    "Tests/",
)

APP_SOURCE_SUFFIXES = (
    ".swift",
    ".xcodeproj",
    ".xcworkspace",
    ".xcconfig",
)

RETIRED_REPLACEMENTS = [
    (r"\bPlan tab\b", "Time surface"),
    (r"\bplan tab\b", "Time surface"),
    (r"\bProfile tab\b", "You surface"),
    (r"\bprofile tab\b", "You surface"),
    (r"\bCaptures tab\b", "Capture surface"),
    (r"\bcaptures tab\b", "Capture surface"),
    (r"\bInsights tab\b", "proof inspection surface"),
    (r"\binsights tab\b", "proof inspection surface"),
    (r"\bHabits tab\b", "goal/step routine surface"),
    (r"\bhabits tab\b", "goal/step routine surface"),
    (r"\bMomentum tab\b", "proof/progress surface"),
    (r"\bmomentum tab\b", "proof/progress surface"),
    (r"\bbest next move\b", "Recommended step"),
    (r"\bBest next move\b", "Recommended step"),
    (r"\bnext best move\b", "Recommended step"),
    (r"\bNext best move\b", "Recommended step"),
    (r"\bBegin Focus\b", "Start now"),
    (r"\bbegin focus\b", "Start now"),
    (r"\bStart Focus\b", "Start now"),
    (r"\bstart focus\b", "Start now"),
    (r"\boverdue\b", "needs closure"),
    (r"\bOverdue\b", "Needs closure"),
    (r"\bfailed\b", "needs review"),
    (r"\bFailed\b", "Needs review"),
    (r"\bstreaks\b", "proof threads"),
    (r"\bStreaks\b", "Proof threads"),
    (r"\bstreak\b", "proof thread"),
    (r"\bStreak\b", "Proof thread"),
    (r"\bproductivity score\b", "proof signal"),
    (r"\bProductivity score\b", "Proof signal"),
    (r"(?<![-_/A-Za-z0-9])dashboard(?![-_/A-Za-z0-9])", "surface"),
    (r"(?<![-_/A-Za-z0-9])Dashboard(?![-_/A-Za-z0-9])", "Surface"),
]

RETIRED_SCAN_PATTERNS = [
    r"\bPlan tab\b",
    r"\bProfile tab\b",
    r"\bCaptures tab\b",
    r"\bInsights tab\b",
    r"\bHabits tab\b",
    r"\bMomentum tab\b",
    r"\bnext best move\b",
    r"\bbest next move\b",
    r"\bBegin Focus\b",
    r"\bStart Focus\b",
    r"\boverdue\b",
    r"\bfailed\b",
    r"\bstreak\b",
    r"\bstreaks\b",
    r"\bproductivity score\b",
    r"(?<![-_/A-Za-z0-9])dashboard(?![-_/A-Za-z0-9])",
]


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
    )


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        return {}
    return json.loads(text)


def is_allowed_content_path(path: str) -> bool:
    if not path.endswith(".md"):
        return False
    if path.startswith(EXCLUDE_PREFIXES):
        return False
    return path.startswith(TARGET_PREFIXES)


def is_app_source_path(path: str) -> bool:
    return path.startswith(APP_SOURCE_PREFIXES) or path.endswith(APP_SOURCE_SUFFIXES)


def collect_candidate_paths() -> dict[str, dict[str, Any]]:
    path_info: dict[str, dict[str, Any]] = defaultdict(
        lambda: {
            "classes": set(),
            "dispositions": set(),
            "candidate_ids": set(),
            "conflict_types": set(),
            "reasons": set(),
        }
    )

    for payload_path in [SOURCE_RESOLUTION_JSON, REMAINING_RESOLUTION_JSON]:
        payload = load_json(payload_path)
        for item in payload.get("dispositions", []):
            candidate_id = item.get("candidate_id", "unknown")
            conflict_type = item.get("conflict_type", payload.get("resolved_conflict_type", "unknown"))
            resolution_class = item.get("resolution_class", item.get("bundle_id", "unknown"))
            disposition = item.get("disposition", "unknown")
            next_action = item.get("next_action", "not specified")

            raw_paths: list[str] = []

            if item.get("repo_path"):
                raw_paths.append(item["repo_path"])

            for path in item.get("repo_paths", []) or []:
                raw_paths.append(path)

            for involved in item.get("involved", []) or []:
                if involved.get("repo_path"):
                    raw_paths.append(involved["repo_path"])

            for raw_path in raw_paths:
                if not is_allowed_content_path(raw_path):
                    continue

                info = path_info[raw_path]
                info["classes"].add(resolution_class)
                info["dispositions"].add(disposition)
                info["candidate_ids"].add(candidate_id)
                info["conflict_types"].add(conflict_type)
                info["reasons"].add(next_action)

    return path_info


def content_status(path: str, info: dict[str, Any]) -> tuple[str, str]:
    classes = set(info["classes"])
    dispositions = set(info["dispositions"])

    if path.startswith("docs/canon/"):
        return (
            "historical-canon-reference",
            "This legacy canon file is retained for traceability and must not override active truth in docs/truth.",
        )

    if path.startswith("docs/codex/batches/") or path.startswith("prompts/batches/"):
        if "merge-overlap" in classes or "merge-overlap-before-proof" in classes:
            return (
                "execution-work-order-needs-sequencing",
                "This batch/prompt is a work-order artifact and must be sequenced before execution.",
            )
        if "authority-rewrite" in classes or "rewrite-authority-before-proof" in classes:
            return (
                "execution-work-order-needs-authority-check",
                "This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.",
            )
        if "terminology-quarantine" in classes or "quarantine-or-rewrite-terminology" in dispositions:
            return (
                "execution-work-order-needs-language-check",
                "This batch/prompt may contain legacy language residue and must follow current canonical terminology before use.",
            )
        return (
            "execution-work-order",
            "This batch/prompt is an execution artifact, not product truth.",
        )

    if path.startswith("docs/codex/"):
        if "status-expedite" in classes or "manual-triage" in classes:
            return (
                "codex-reference-needs-owner-triage",
                "This Codex reference is retained but requires owner/status clarification before it drives implementation.",
            )
        return (
            "codex-reference",
            "This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.",
        )

    return (
        "reference-doc",
        "This document is a repo reference, not standalone product truth.",
    )


def build_header(path: str, info: dict[str, Any]) -> str:
    status, note = content_status(path, info)
    classes = ", ".join(sorted(info["classes"])) or "none"
    dispositions = ", ".join(sorted(info["dispositions"])) or "none"

    return "\n".join(
        [
            HEADER_BEGIN,
            "",
            f"> Canon hygiene status: **{status}**",
            f"> AMB-291 note: {note}",
            "> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.",
            "> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.",
            f"> Resolution classes: {classes}",
            f"> Dispositions: {dispositions}",
            "",
            HEADER_END,
            "",
        ]
    )


def build_authority_block() -> str:
    lines = [
        "",
        "## Source-of-truth references",
        "",
        AUTH_BEGIN,
        "",
        "This file must not be treated as standalone active canon. Current authority must be resolved through:",
        "",
    ]

    for path in AUTHORITY_FILES:
        lines.append(f"- `{path}`")

    lines.extend(
        [
            "",
            AUTH_END,
            "",
        ]
    )
    return "\n".join(lines)


def build_non_claims_block() -> str:
    return "\n".join(
        [
            "",
            "## Non-claims",
            "",
            NONCLAIM_BEGIN,
            "",
            "- This file does not prove implementation.",
            "- This file does not prove build success.",
            "- This file does not prove test success.",
            "- This file does not prove accessibility validation.",
            "- This file does not prove performance validation.",
            "- This file does not prove device validation.",
            "- This file does not prove privacy/legal approval.",
            "- This file does not prove TestFlight readiness.",
            "- This file does not prove App Store readiness.",
            "- This file does not prove release readiness.",
            "- Linear status is not repo truth.",
            "",
            NONCLAIM_END,
            "",
        ]
    )


def insert_after_title(text: str, block: str) -> str:
    if HEADER_BEGIN in text:
        return text

    lines = text.splitlines()
    if lines and lines[0].startswith("# "):
        return "\n".join([lines[0], "", block.rstrip(), *lines[1:]]) + "\n"

    return block + text


def replace_retired_terms(text: str) -> tuple[str, dict[str, int]]:
    counts: dict[str, int] = {}
    new_text = text

    for pattern, replacement in RETIRED_REPLACEMENTS:
        new_text, count = re.subn(pattern, replacement, new_text, flags=re.IGNORECASE)
        if count:
            counts[pattern] = count

    return new_text, counts


def scan_retired_terms(text: str) -> dict[str, int]:
    counts = {}
    for pattern in RETIRED_SCAN_PATTERNS:
        count = len(re.findall(pattern, text, flags=re.IGNORECASE))
        if count:
            counts[pattern] = count
    return counts


def rewrite_file(path: str, info: dict[str, Any]) -> dict[str, Any]:
    full = ROOT / path
    before = full.read_text(encoding="utf-8", errors="ignore")
    before_retired = scan_retired_terms(before)

    after = before
    after, replacements = replace_retired_terms(after)

    if HEADER_BEGIN not in after:
        after = insert_after_title(after, build_header(path, info))

    if AUTH_BEGIN not in after:
        after = after.rstrip() + "\n" + build_authority_block()

    if NONCLAIM_BEGIN not in after:
        after = after.rstrip() + "\n" + build_non_claims_block()

    after_retired = scan_retired_terms(after)

    changed = after != before
    if changed:
        full.write_text(after, encoding="utf-8")

    return {
        "path": path,
        "changed": changed,
        "safety_class": content_status(path, info)[0],
        "classes": sorted(info["classes"]),
        "dispositions": sorted(info["dispositions"]),
        "candidate_ids": sorted(info["candidate_ids"]),
        "conflict_types": sorted(info["conflict_types"]),
        "reason_count": len(info["reasons"]),
        "replacements": replacements,
        "retired_patterns_before": before_retired,
        "retired_patterns_after": after_retired,
    }


def git_changed_files() -> list[str]:
    proc = run(["git", "diff", "--name-only"], check=True)
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def validate_no_app_source_changes() -> list[str]:
    return [path for path in git_changed_files() if is_app_source_path(path)]


def main() -> int:
    candidates = collect_candidate_paths()

    if not candidates:
        raise SystemExit("No editable candidate docs/prompts found from resolution manifests.")

    rewrites = []
    missing = []

    for path, info in sorted(candidates.items()):
        full = ROOT / path
        if not full.exists():
            missing.append(path)
            continue
        rewrites.append(rewrite_file(path, info))

    changed_content_files = [item for item in rewrites if item["changed"]]
    remaining_retired = {
        item["path"]: item["retired_patterns_after"]
        for item in rewrites
        if item["retired_patterns_after"]
    }

    app_source_changes = validate_no_app_source_changes()

    status = "GREEN"
    validation_errors = []

    if not changed_content_files:
        status = "YELLOW"
        validation_errors.append("No actual docs/prompts changed.")

    if app_source_changes:
        status = "RED"
        validation_errors.append("App/source file changes detected: " + ", ".join(app_source_changes))

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": status,
        "target_file_count": len(candidates),
        "changed_content_file_count": len(changed_content_files),
        "missing_file_count": len(missing),
        "missing_files": missing,
        "app_source_changes": app_source_changes,
        "remaining_retired_patterns_in_target_files": remaining_retired,
        "summary": {
            "by_safety_class": dict(sorted(Counter(item["safety_class"] for item in rewrites).items())),
            "by_changed": dict(sorted(Counter(str(item["changed"]) for item in rewrites).items())),
            "by_conflict_type": dict(sorted(Counter(ct for item in rewrites for ct in item["conflict_types"]).items())),
            "by_disposition": dict(sorted(Counter(d for item in rewrites for d in item["dispositions"]).items())),
        },
        "rewrites": rewrites,
        "validation_errors": validation_errors,
        "non_claims": [
            "This rewrite pass modifies docs/prompts only.",
            "This rewrite pass does not modify Swift/app source.",
            "This rewrite pass does not prove implementation.",
            "This rewrite pass does not prove build success.",
            "This rewrite pass does not prove test success.",
            "This rewrite pass does not prove accessibility validation.",
            "This rewrite pass does not prove performance validation.",
            "This rewrite pass does not prove device validation.",
            "This rewrite pass does not prove privacy/legal approval.",
            "This rewrite pass does not prove TestFlight readiness.",
            "This rewrite pass does not prove App Store readiness.",
            "This rewrite pass does not prove release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Actual Canon Content and Hygiene Rewrite",
        "",
        f"Status: {status}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Purpose",
        "",
        "This pass performs actual docs/prompts hygiene rewrites based on prior canon-collapse disposition artifacts.",
        "",
        "It adds explicit status/authority/non-claim blocks and rewrites known retired terminology where safe.",
        "",
        "## Summary",
        "",
        f"- Target files: {payload['target_file_count']}",
        f"- Changed docs/prompts: {payload['changed_content_file_count']}",
        f"- Missing files: {payload['missing_file_count']}",
        f"- App/source changes detected: {len(app_source_changes)}",
        "",
        "### Changed files",
        "",
    ]

    for item in changed_content_files:
        lines.append(f"- `{item['path']}`")
        lines.append(f"  - Safety class: `{item['safety_class']}`")
        lines.append(f"  - Conflict types: `{', '.join(item['conflict_types'])}`")
        lines.append(f"  - Dispositions: `{', '.join(item['dispositions'])}`")
        if item["replacements"]:
            lines.append(f"  - Retired terminology replacements: `{sum(item['replacements'].values())}`")

    if not changed_content_files:
        lines.append("- None")

    lines.extend(["", "## Remaining retired patterns in target files", ""])

    if remaining_retired:
        for path, patterns in remaining_retired.items():
            lines.append(f"### `{path}`")
            for pattern, count in patterns.items():
                lines.append(f"- `{pattern}`: `{count}`")
    else:
        lines.append("- None detected in target files.")

    lines.extend(["", "## Validation errors", ""])

    if validation_errors:
        for error in validation_errors:
            lines.append(f"- {error}")
    else:
        lines.append("- None")

    lines.extend(["", "## Non-claims", ""])

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"wrote {rel(OUT_MD)}")
    print(f"wrote {rel(OUT_JSON)}")
    print(f"status: {status}")
    print(f"target_file_count: {payload['target_file_count']}")
    print(f"changed_content_file_count: {payload['changed_content_file_count']}")
    print(f"app_source_changes: {len(app_source_changes)}")

    if validation_errors:
        for error in validation_errors:
            print(f"VALIDATION: {error}")
        return 1 if status == "RED" else 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
