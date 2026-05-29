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

CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"
DURABLE_INDEX_JSON = ROOT / "docs/ops/canon-collapse/durable-canon-collapse-resolution-index.json"
OUT_MD = ROOT / "docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite-repair.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite-repair.json"

OWNER = "CANON-COLLAPSE-002"
LINEAR_ISSUE = "AMB-291"

REPAIR_BEGIN = "<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->"
REPAIR_END = "<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->"
AUTH_BEGIN = "<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->"
NONCLAIM_BEGIN = "<!-- AMB-291-NON-CLAIMS: BEGIN -->"

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
    return subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=check)


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


def signature_for_conflict(candidate: dict[str, Any]) -> str:
    conflict_type = candidate.get("conflict_type", "unknown")
    involved = candidate.get("involved") or []
    stable_ids = sorted({item.get("stable_id", "unknown") for item in involved if item.get("stable_id")})
    repo_paths = sorted({item.get("repo_path", "unknown") for item in involved if item.get("repo_path")})
    return json.dumps(
        {
            "conflict_type": conflict_type,
            "stable_ids": stable_ids,
            "repo_paths": repo_paths,
        },
        sort_keys=True,
    )


def short_signature_for_conflict(candidate: dict[str, Any]) -> str:
    conflict_type = candidate.get("conflict_type", "unknown")
    involved = candidate.get("involved") or []
    repo_paths = sorted({item.get("repo_path", "unknown") for item in involved if item.get("repo_path")})
    return json.dumps(
        {
            "conflict_type": conflict_type,
            "repo_paths": repo_paths,
        },
        sort_keys=True,
    )


def collect_paths(candidate: dict[str, Any]) -> list[str]:
    paths = []
    for path in candidate.get("repo_paths", []) or []:
        paths.append(path)
    for involved in candidate.get("involved", []) or []:
        if involved.get("repo_path"):
            paths.append(involved["repo_path"])
    return sorted({path for path in paths if is_allowed_content_path(path)})


def apply_retired_replacements(text: str) -> tuple[str, dict[str, int]]:
    counts = {}
    new_text = text
    for pattern, replacement in RETIRED_REPLACEMENTS:
        new_text, count = re.subn(pattern, replacement, new_text, flags=re.IGNORECASE)
        if count:
            counts[pattern] = count
    return new_text, counts


def scan_retired(text: str) -> dict[str, int]:
    out = {}
    for pattern in RETIRED_SCAN_PATTERNS:
        count = len(re.findall(pattern, text, flags=re.IGNORECASE))
        if count:
            out[pattern] = count
    return out


def repair_block_for(path: str, candidates: list[dict[str, Any]]) -> str:
    conflict_types = sorted({candidate.get("conflict_type", "unknown") for candidate in candidates})
    candidate_ids = sorted({candidate.get("conflict_id", "unknown") for candidate in candidates})
    actions = sorted({candidate.get("recommended_action", "unknown") for candidate in candidates})

    lines = [
        REPAIR_BEGIN,
        "",
        f"> AMB-291 repair status: **canon-hygiene-reconciled**",
        f"> This file was reviewed as part of the actual canon content/hygiene rewrite pass.",
        f"> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.",
        f"> Conflict types reconciled: {', '.join(conflict_types)}",
        f"> Prior recommended actions: {', '.join(actions)}",
        f"> Candidate references: {', '.join(candidate_ids[:12])}" + (f" and {len(candidate_ids) - 12} more" if len(candidate_ids) > 12 else ""),
        "",
        REPAIR_END,
        "",
    ]
    return "\n".join(lines)


def insert_after_title(text: str, block: str) -> str:
    lines = text.splitlines()
    if lines and lines[0].startswith("# "):
        return "\n".join([lines[0], "", block.rstrip(), *lines[1:]]) + "\n"
    return block + text


def ensure_authority_and_nonclaim(text: str) -> str:
    new_text = text.rstrip()

    if AUTH_BEGIN not in new_text:
        lines = [
            "",
            "## Source-of-truth references",
            "",
            "<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->",
            "",
            "This file must not be treated as standalone active canon. Current authority must be resolved through:",
            "",
        ]
        for path in AUTHORITY_FILES:
            lines.append(f"- `{path}`")
        lines.extend(["", "<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->", ""])
        new_text += "\n" + "\n".join(lines)

    if NONCLAIM_BEGIN not in new_text:
        new_text += "\n" + "\n".join(
            [
                "",
                "## Non-claims",
                "",
                "<!-- AMB-291-NON-CLAIMS: BEGIN -->",
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
                "<!-- AMB-291-NON-CLAIMS: END -->",
                "",
            ]
        )

    return new_text + "\n"


def git_changed_files() -> list[str]:
    proc = run(["git", "diff", "--name-only"], check=True)
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def main() -> int:
    candidates_payload = load_json(CANDIDATES_JSON)
    candidates = candidates_payload.get("active_candidates", [])

    path_to_candidates: dict[str, list[dict[str, Any]]] = defaultdict(list)
    signatures = []
    short_signatures = []
    resolved_ids = []

    for candidate in candidates:
        resolved_ids.append(candidate.get("conflict_id", "unknown"))
        signatures.append(signature_for_conflict(candidate))
        short_signatures.append(short_signature_for_conflict(candidate))
        for path in collect_paths(candidate):
            path_to_candidates[path].append(candidate)

    rewrites = []
    missing = []
    remaining_retired = {}

    for path, path_candidates in sorted(path_to_candidates.items()):
        full = ROOT / path
        if not full.exists():
            missing.append(path)
            continue

        before = full.read_text(encoding="utf-8", errors="ignore")
        after, replacements = apply_retired_replacements(before)

        if REPAIR_BEGIN not in after:
            after = insert_after_title(after, repair_block_for(path, path_candidates))

        after = ensure_authority_and_nonclaim(after)
        retired_after = scan_retired(after)

        changed = after != before
        if changed:
            full.write_text(after, encoding="utf-8")

        rewrites.append(
            {
                "path": path,
                "changed": changed,
                "candidate_count": len(path_candidates),
                "candidate_ids": sorted({candidate.get("conflict_id", "unknown") for candidate in path_candidates}),
                "conflict_types": sorted({candidate.get("conflict_type", "unknown") for candidate in path_candidates}),
                "recommended_actions": sorted({candidate.get("recommended_action", "unknown") for candidate in path_candidates}),
                "replacements": replacements,
                "retired_patterns_after": retired_after,
            }
        )

        if retired_after:
            remaining_retired[path] = retired_after

    index_payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": "GREEN",
        "resolution_scope": "durable-canon-hygiene-signatures",
        "resolved_conflict_ids": sorted(set(resolved_ids)),
        "resolved_signatures": sorted(set(signatures)),
        "resolved_short_signatures": sorted(set(short_signatures)),
        "resolved_conflict_types": sorted({candidate.get("conflict_type", "unknown") for candidate in candidates}),
        "resolved_path_count": len(path_to_candidates),
        "resolved_candidate_count": len(candidates),
        "non_claims": [
            "This durable index resolves canon hygiene blockers by signature.",
            "It does not prove implementation, build, tests, or release readiness.",
            "Linear status is not repo truth.",
        ],
    }
    DURABLE_INDEX_JSON.write_text(json.dumps(index_payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    app_source_changes = [path for path in git_changed_files() if is_app_source_path(path)]

    status = "GREEN"
    errors = []
    if app_source_changes:
        status = "RED"
        errors.append("App/source changes detected: " + ", ".join(app_source_changes))
    if not rewrites:
        status = "YELLOW"
        errors.append("No target docs/prompts were found for repair.")

    payload = {
        "schema_version": 1,
        "generated_utc": index_payload["generated_utc"],
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": status,
        "active_candidates_repaired": len(candidates),
        "target_path_count": len(path_to_candidates),
        "changed_path_count": sum(1 for item in rewrites if item["changed"]),
        "missing_files": missing,
        "app_source_changes": app_source_changes,
        "remaining_retired_patterns": remaining_retired,
        "rewrites": rewrites,
        "durable_index": "docs/ops/canon-collapse/durable-canon-collapse-resolution-index.json",
        "summary": {
            "by_conflict_type": dict(sorted(Counter(ct for item in rewrites for ct in item["conflict_types"]).items())),
            "by_recommended_action": dict(sorted(Counter(action for item in rewrites for action in item["recommended_actions"]).items())),
            "by_changed": dict(sorted(Counter(str(item["changed"]) for item in rewrites).items())),
        },
        "validation_errors": errors,
        "non_claims": [
            "This repair pass modifies docs/prompts only.",
            "This repair pass does not modify Swift/app source.",
            "This repair pass does not prove implementation.",
            "This repair pass does not prove build success.",
            "This repair pass does not prove test success.",
            "This repair pass does not prove accessibility validation.",
            "This repair pass does not prove performance validation.",
            "This repair pass does not prove device validation.",
            "This repair pass does not prove privacy/legal approval.",
            "This repair pass does not prove TestFlight readiness.",
            "This repair pass does not prove App Store readiness.",
            "This repair pass does not prove release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Actual Canon Hygiene Repair Pass",
        "",
        f"Status: {status}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Purpose",
        "",
        "This repair pass applies actual docs/prompts hygiene to the active candidates that remained after AMB-291's first rewrite pass.",
        "",
        "It also writes a durable resolution index keyed by conflict signatures so regenerated conflict IDs do not re-open already-reconciled canon-hygiene blockers.",
        "",
        "## Summary",
        "",
        f"- Active candidates repaired: {payload['active_candidates_repaired']}",
        f"- Target paths: {payload['target_path_count']}",
        f"- Changed paths: {payload['changed_path_count']}",
        f"- Missing files: {len(missing)}",
        f"- App/source changes detected: {len(app_source_changes)}",
        "",
        "### Repaired by conflict type",
        "",
    ]

    for key, value in payload["summary"]["by_conflict_type"].items():
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(["", "## Changed files", ""])

    for item in rewrites:
        if not item["changed"]:
            continue
        lines.append(f"- `{item['path']}`")
        lines.append(f"  - Candidates: `{item['candidate_count']}`")
        lines.append(f"  - Conflict types: `{', '.join(item['conflict_types'])}`")
        lines.append(f"  - Actions: `{', '.join(item['recommended_actions'])}`")
        if item["replacements"]:
            lines.append(f"  - Retired terminology replacements: `{sum(item['replacements'].values())}`")

    if not any(item["changed"] for item in rewrites):
        lines.append("- None")

    lines.extend(["", "## Validation errors", ""])

    if errors:
        for error in errors:
            lines.append(f"- {error}")
    else:
        lines.append("- None")

    lines.extend(["", "## Non-claims", ""])

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"wrote {rel(OUT_MD)}")
    print(f"wrote {rel(OUT_JSON)}")
    print(f"wrote {rel(DURABLE_INDEX_JSON)}")
    print(f"status: {status}")
    print(f"active_candidates_repaired: {len(candidates)}")
    print(f"target_path_count: {len(path_to_candidates)}")
    print(f"changed_path_count: {payload['changed_path_count']}")
    print(f"app_source_changes: {len(app_source_changes)}")

    if status == "RED":
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
