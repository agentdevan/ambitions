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
STATUS_REPORT = ROOT / "docs" / "ops" / "batch-ledger" / "implementation-proof-status-report.md"

IMPLEMENTATION_STATUSES = {
    "planned",
    "implemented",
    "partial_implementation",
    "canceled",
    "retired",
    "superseded",
    "unknown",
}

AMB27_PROOF_STATES = {
    "none",
    "source-only",
    "tests",
    "screenshot",
    "audit",
    "release proof",
}

NON_FORWARD_STATUSES = {"canceled", "retired", "superseded", "historical"}
PLANNED_STATUSES = {"planned", "installed_not_run"}
NON_GREEN_STATUSES = {"red", "accepted_yellow", "unknown"}

TEST_PATTERNS = [
    r"\bXCTest\b",
    r"\bxcodebuild\s+test\b",
    r"\bswift\s+test\b",
    r"\btest_log\b",
    r"\bCoreSurfaceIntegrationScenarioTests\b",
    r"\bTests?/",
    r"\.xcresult\b",
]

SCREENSHOT_PATTERNS = [
    r"\bscreenshot\b",
    r"\bscreenshot diff\b",
    r"\bvisual evidence\b",
    r"\bvisual proof\b",
    r"\.png\b",
    r"\.jpg\b",
    r"\.jpeg\b",
]

RELEASE_PATTERNS = [
    r"\brelease packet\b",
    r"\brelease proof\b",
    r"\bTestFlight\b",
    r"\bApp Store\b",
    r"\bsigned archive\b",
    r"\barchive proof\b",
    r"\bprivacy manifest\b",
    r"\bapp privacy\b",
    r"\blegal review\b",
]

AUDIT_PATTERNS = [
    r"\baudit\b",
    r"\breport\b",
    r"\bproof artifact\b",
    r"\bvalidation report\b",
    r"\bclassification\b",
    r"\bstatus:\s*(green|yellow|red)\b",
]

SOURCE_PATTERNS = [
    r"\bNative/",
    r"\bscripts/",
    r"\bTests?/",
    r"\.swift\b",
    r"\.py\b",
    r"\.sh\b",
    r"\.json\b",
    r"\.yml\b",
    r"\.yaml\b",
]

IMPLEMENTED_LANGUAGE_PATTERNS = [
    r"\bimplemented\b",
    r"\bsource landed\b",
    r"\bwired\b",
    r"\bsource-present\b",
    r"\bsource present\b",
    r"\binstalled\b",
]

PARTIAL_LANGUAGE_PATTERNS = [
    r"\bpartial\b",
    r"\bsource-only\b",
    r"\bsource only\b",
    r"\bmissing proof\b",
    r"\bnot verified\b",
    r"\baccepted yellow\b",
    r"\byellow\b",
]

CANCELED_PATTERNS = [
    r"\bcanceled\b",
    r"\bcancelled\b",
    r"\bdo not run\b",
]

RETIRED_PATTERNS = [
    r"\bretired\b",
    r"\bdeprecated\b",
    r"\bnot runnable\b",
]

SUPERSEDED_PATTERNS = [
    r"\bsuperseded\b",
    r"\breplaced by\b",
    r"\breplaced with\b",
]

RELEASE_OVERCLAIM_PATTERNS = [
    r"\brelease ready\b",
    r"\bproduction ready\b",
    r"\bfully validated\b",
    r"\bfully tested\b",
    r"\bapp store ready\b",
    r"\btestflight ready\b",
]

PATH_FIELDS = [
    "repo_path",
    "touched_files",
    "proof_paths",
    "source_of_truth_docs",
]

STATUS_RANK = {
    "implemented": 0,
    "partial_implementation": 1,
    "planned": 2,
    "unknown": 3,
    "canceled": 4,
    "retired": 5,
    "superseded": 6,
}

PROOF_RANK = {
    "release proof": 0,
    "tests": 1,
    "screenshot": 2,
    "audit": 3,
    "source-only": 4,
    "none": 5,
}


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


def read_text(path: str) -> str:
    try:
        return (ROOT / path).read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def load_ledger() -> dict[str, Any]:
    if not LEDGER_JSON.exists():
        raise FileNotFoundError(f"missing {LEDGER_JSON.relative_to(ROOT)}")
    text = LEDGER_JSON.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"{LEDGER_JSON.relative_to(ROOT)} is empty")
    payload = json.loads(text)
    if "items" not in payload or not isinstance(payload["items"], list):
        raise ValueError("batch-ledger.json missing items[]")
    return payload


def unique(values: list[str]) -> list[str]:
    return sorted({v for v in values if v})


def has_any(patterns: list[str], haystack: str) -> bool:
    return any(re.search(pattern, haystack, flags=re.IGNORECASE) for pattern in patterns)


def evidence_blob(item: dict[str, Any]) -> str:
    parts: list[str] = []

    for field in [
        "stable_id",
        "title",
        "repo_path",
        "current_status",
        "proof_state",
        "source_authority",
        "runner_command",
    ]:
        value = item.get(field)
        if value:
            parts.append(str(value))

    for field in [
        "touched_files",
        "source_of_truth_docs",
        "proof_paths",
        "validation_commands",
        "conflicts",
        "duplicates",
        "blockers",
        "related_linear_issues",
    ]:
        value = item.get(field)
        if isinstance(value, list):
            parts.extend(str(v) for v in value)

    repo_path = item.get("repo_path", "")
    if repo_path:
        parts.append(read_text(repo_path)[:80000])

    return "\n".join(parts)


def classify_proof_state(item: dict[str, Any], haystack: str, known_files: set[str]) -> tuple[str, list[str], str]:
    proof_paths = item.get("proof_paths") or []
    touched_files = item.get("touched_files") or []
    repo_path = item.get("repo_path", "")
    current_proof_state = str(item.get("proof_state", "none"))

    evidence_paths = unique(
        [
            p for p in proof_paths + touched_files + [repo_path]
            if isinstance(p, str) and p
        ]
    )

    lower_paths = "\n".join(evidence_paths).lower()

    if has_any(RELEASE_PATTERNS, haystack) or any(term in lower_paths for term in ["release", "testflight", "app-store", "app_store", "privacy", "legal", "archive"]):
        return "release proof", evidence_paths, "release/privacy/archive proof language or paths detected"

    if has_any(TEST_PATTERNS, haystack) or current_proof_state == "test_log" or any(term in lower_paths for term in ["test", "xctest", "xcresult"]):
        return "tests", evidence_paths, "test command, test path, or test proof detected"

    if has_any(SCREENSHOT_PATTERNS, haystack) or current_proof_state == "screenshot" or any(term in lower_paths for term in ["screenshot", "visual-evidence", ".png", ".jpg", ".jpeg"]):
        return "screenshot", evidence_paths, "screenshot or visual proof detected"

    if (
        item.get("item_type") == "proof_artifact"
        or current_proof_state in {"audit", "current_green", "current_yellow", "current_red", "build_log", "dry_run"}
        or has_any(AUDIT_PATTERNS, haystack)
        or repo_path.startswith("docs/audits/")
        or repo_path.startswith("build/reports/")
    ):
        return "audit", evidence_paths, "audit/report/proof artifact detected"

    if touched_files or has_any(SOURCE_PATTERNS, haystack):
        source_paths = [p for p in touched_files if p in known_files or p.startswith(("Native/", "Tests/", "scripts/"))]
        if not source_paths:
            source_paths = [repo_path] if repo_path else []
        return "source-only", unique(source_paths), "source path or source reference detected without complete proof"

    return "none", [], "no proof evidence detected"


def classify_implementation_status(item: dict[str, Any], amb27_proof_state: str, haystack: str) -> tuple[str, str]:
    current_status = str(item.get("current_status", "unknown"))
    item_type = str(item.get("item_type", "unknown"))
    conflicts = set(item.get("conflicts") or [])
    touched_files = item.get("touched_files") or []
    proof_paths = item.get("proof_paths") or []
    validation_commands = item.get("validation_commands") or []

    if current_status == "canceled" or has_any(CANCELED_PATTERNS, haystack):
        return "canceled", "current status or text marks item canceled"

    if current_status == "retired" or has_any(RETIRED_PATTERNS, haystack):
        return "retired", "current status or text marks item retired/deprecated"

    if current_status == "superseded" or has_any(SUPERSEDED_PATTERNS, haystack):
        return "superseded", "current status or text marks item superseded"

    if item_type in {"batch", "prompt", "train"} and current_status in PLANNED_STATUSES:
        if amb27_proof_state in {"tests", "screenshot", "release proof"} and proof_paths:
            return "implemented", "planned work has strong proof paths attached"
        if touched_files or proof_paths or validation_commands:
            return "partial_implementation", "planned work has source/proof/validation references but not complete proof"
        return "planned", "batch/prompt/train is planned or installed-not-run without proof"

    if current_status in {"green", "validated"}:
        if amb27_proof_state in {"tests", "screenshot", "release proof"}:
            return "implemented", "green/validated item has strong proof"
        return "partial_implementation", "green/validated status lacks strong test/screenshot/release proof in ledger"

    if current_status in {"accepted_yellow", "red"}:
        return "partial_implementation", "non-green proof/status indicates incomplete or blocked work"

    if "release_overclaim" in conflicts or "implementation_overclaim" in conflicts or "proof_missing" in conflicts:
        return "partial_implementation", "conflict indicates missing proof or overclaim"

    if has_any(PARTIAL_LANGUAGE_PATTERNS, haystack):
        return "partial_implementation", "partial/source-only/missing-proof language detected"

    if has_any(IMPLEMENTED_LANGUAGE_PATTERNS, haystack):
        if amb27_proof_state in {"tests", "screenshot", "release proof"}:
            return "implemented", "implementation language and strong proof detected"
        return "partial_implementation", "implementation language detected without complete proof"

    if item_type in {"runner", "sequence_authority", "status_mirror", "proof_artifact"}:
        if amb27_proof_state == "audit":
            return "unknown", "artifact exists but is not implementation proof"
        if amb27_proof_state == "source-only":
            return "unknown", "source mirror/runner existence is not implementation proof"
        return "unknown", "non-work item cannot prove implementation status"

    if amb27_proof_state == "source-only":
        return "partial_implementation", "source-only evidence detected"

    if current_status == "unknown":
        return "unknown", "status remains unknown until evidence exists"

    return "unknown", "insufficient evidence"


def add_or_remove_conflicts(item: dict[str, Any], implementation_status: str, amb27_proof_state: str, haystack: str) -> list[str]:
    conflicts = set(item.get("conflicts") or [])

    for pattern in RELEASE_OVERCLAIM_PATTERNS:
        if re.search(pattern, haystack, flags=re.IGNORECASE):
            conflicts.add("release_overclaim")

    if implementation_status == "implemented" and amb27_proof_state in {"none", "source-only", "audit"}:
        conflicts.add("proof_missing")

    if implementation_status == "unknown":
        conflicts.add("status_unknown")

    if implementation_status == "partial_implementation":
        conflicts.add("partial_implementation_without_complete_proof")

    # If something was previously marked proof_missing but AMB-27 did not classify
    # it as implemented, keep the conflict visible rather than hiding it.
    return sorted(conflicts)


def classify_item(item: dict[str, Any], known_files: set[str]) -> dict[str, Any]:
    haystack = evidence_blob(item)

    amb27_proof_state, evidence_paths, proof_rationale = classify_proof_state(item, haystack, known_files)
    implementation_status, implementation_rationale = classify_implementation_status(item, amb27_proof_state, haystack)
    conflicts = add_or_remove_conflicts(item, implementation_status, amb27_proof_state, haystack)

    item["implementation_status"] = implementation_status
    item["implementation_status_rationale"] = implementation_rationale
    item["amb27_proof_state"] = amb27_proof_state
    item["amb27_proof_rationale"] = proof_rationale
    item["amb27_evidence_paths"] = evidence_paths
    item["conflicts"] = conflicts
    item["amb27_classification"] = {
        "linear_issue": "AMB-27",
        "status": "classified",
        "source_only_is_not_implemented": not (
            implementation_status == "implemented" and amb27_proof_state == "source-only"
        ),
        "unknown_remains_unknown_without_evidence": not (
            implementation_status != "unknown"
            and amb27_proof_state == "none"
            and item.get("current_status") == "unknown"
        ),
    }

    return item


def validate(payload: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    for index, item in enumerate(payload["items"]):
        path = item.get("repo_path", f"index:{index}")
        implementation_status = item.get("implementation_status")
        proof_state = item.get("amb27_proof_state")

        if implementation_status not in IMPLEMENTATION_STATUSES:
            errors.append(f"{path}: invalid implementation_status {implementation_status}")

        if proof_state not in AMB27_PROOF_STATES:
            errors.append(f"{path}: invalid amb27_proof_state {proof_state}")

        if implementation_status == "implemented" and proof_state in {"none", "source-only", "audit"}:
            errors.append(f"{path}: source-only/audit/none cannot be implemented")

        if item.get("current_status") == "unknown" and proof_state == "none" and implementation_status != "unknown":
            errors.append(f"{path}: unknown without evidence must remain unknown")

        for field in [
            "implementation_status_rationale",
            "amb27_proof_rationale",
            "amb27_evidence_paths",
            "amb27_classification",
        ]:
            if field not in item:
                errors.append(f"{path}: missing {field}")

    return errors


def sort_items(payload: dict[str, Any]) -> None:
    payload["items"].sort(
        key=lambda item: (
            STATUS_RANK.get(item.get("implementation_status", "unknown"), 99),
            PROOF_RANK.get(item.get("amb27_proof_state", "none"), 99),
            item.get("initial_added_date", "unknown") == "unknown",
            item.get("initial_added_date", "unknown"),
            item.get("repo_path", ""),
        )
    )


def write_status_report(payload: dict[str, Any]) -> None:
    items = payload["items"]
    amb27 = payload["amb27_status_classification"]

    impl_counts = Counter(item["implementation_status"] for item in items)
    proof_counts = Counter(item["amb27_proof_state"] for item in items)
    type_counts = Counter(item.get("item_type", "unknown") for item in items)

    partials = [item for item in items if item["implementation_status"] == "partial_implementation"]
    unknowns = [item for item in items if item["implementation_status"] == "unknown"]
    implemented = [item for item in items if item["implementation_status"] == "implemented"]
    non_forward = [
        item for item in items
        if item["implementation_status"] in {"canceled", "retired", "superseded"}
    ]

    lines = [
        "# Implementation and Proof Status Report",
        "",
        f"Generated UTC: {amb27['generated_utc']}",
        "Owner: BATCH-LEDGER-001",
        "Linear issue: AMB-27",
        "",
        "## Status",
        "",
        f"- Validation: `{amb27['status']}`",
        f"- Total ledger items: `{len(items)}`",
        f"- Implemented: `{impl_counts.get('implemented', 0)}`",
        f"- Partial implementation: `{impl_counts.get('partial_implementation', 0)}`",
        f"- Planned: `{impl_counts.get('planned', 0)}`",
        f"- Unknown: `{impl_counts.get('unknown', 0)}`",
        f"- Canceled: `{impl_counts.get('canceled', 0)}`",
        f"- Retired: `{impl_counts.get('retired', 0)}`",
        f"- Superseded: `{impl_counts.get('superseded', 0)}`",
        "",
        "## Proof state counts",
        "",
    ]

    for key, value in sorted(proof_counts.items()):
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(["", "## Item type counts", ""])

    for key, value in sorted(type_counts.items()):
        lines.append(f"- `{key}`: `{value}`")

    lines.extend(
        [
            "",
            "## Acceptance gates",
            "",
            f"- Source-only work is not marked implemented: `{amb27['source_only_not_implemented']}`",
            f"- Unknown without evidence remains unknown: `{amb27['unknown_without_evidence_remains_unknown']}`",
            f"- Every ledger item classified: `{amb27['every_item_classified']}`",
            "",
            "## Implemented items",
            "",
        ]
    )

    if implemented:
        for item in implemented[:120]:
            lines.append(
                f"- `{item['stable_id']}` — `{item['repo_path']}` "
                f"({item['amb27_proof_state']}; {item['implementation_status_rationale']})"
            )
        if len(implemented) > 120:
            lines.append(f"- ... {len(implemented) - 120} more")
    else:
        lines.append("- None.")

    lines.extend(["", "## Partial implementation items", ""])

    if partials:
        for item in partials[:160]:
            lines.append(
                f"- `{item['stable_id']}` — `{item['repo_path']}` "
                f"({item['amb27_proof_state']}; {item['implementation_status_rationale']})"
            )
        if len(partials) > 160:
            lines.append(f"- ... {len(partials) - 160} more")
    else:
        lines.append("- None.")

    lines.extend(["", "## Unknown items", ""])

    if unknowns:
        for item in unknowns[:160]:
            lines.append(
                f"- `{item['stable_id']}` — `{item['repo_path']}` "
                f"({item['amb27_proof_state']}; {item['implementation_status_rationale']})"
            )
        if len(unknowns) > 160:
            lines.append(f"- ... {len(unknowns) - 160} more")
    else:
        lines.append("- None.")

    lines.extend(["", "## Canceled / retired / superseded items", ""])

    if non_forward:
        for item in non_forward[:160]:
            lines.append(
                f"- `{item['stable_id']}` — `{item['implementation_status']}` — `{item['repo_path']}`"
            )
        if len(non_forward) > 160:
            lines.append(f"- ... {len(non_forward) - 160} more")
    else:
        lines.append("- None.")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
            "- Classification is evidence-based and conservative.",
            "- Source-only is not implementation proof.",
            "- Audit-only is not current build/test/release proof.",
            "- Linear status is not repo truth.",
            "- This report does not prove build, tests, accessibility, performance, device, privacy, legal, TestFlight, App Store, or release readiness.",
            "",
        ]
    )

    STATUS_REPORT.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    known_files = git_files()
    payload = load_ledger()

    for item in payload["items"]:
        classify_item(item, known_files)

    errors = validate(payload)

    source_only_not_implemented = all(
        not (
            item.get("implementation_status") == "implemented"
            and item.get("amb27_proof_state") == "source-only"
        )
        for item in payload["items"]
    )

    unknown_without_evidence_remains_unknown = all(
        not (
            item.get("current_status") == "unknown"
            and item.get("amb27_proof_state") == "none"
            and item.get("implementation_status") != "unknown"
        )
        for item in payload["items"]
    )

    every_item_classified = all(
        item.get("implementation_status") in IMPLEMENTATION_STATUSES
        and item.get("amb27_proof_state") in AMB27_PROOF_STATES
        for item in payload["items"]
    )

    impl_counts = Counter(item["implementation_status"] for item in payload["items"])
    proof_counts = Counter(item["amb27_proof_state"] for item in payload["items"])

    payload["amb27_status_classification"] = {
        "status": "green" if not errors else "red",
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "linear_issue": "AMB-27",
        "implementation_status_values": sorted(IMPLEMENTATION_STATUSES),
        "proof_state_values": sorted(AMB27_PROOF_STATES),
        "implementation_status_counts": dict(sorted(impl_counts.items())),
        "proof_state_counts": dict(sorted(proof_counts.items())),
        "source_only_not_implemented": source_only_not_implemented,
        "unknown_without_evidence_remains_unknown": unknown_without_evidence_remains_unknown,
        "every_item_classified": every_item_classified,
        "validation_errors": errors,
    }

    # Keep prior AMB-26 details, but update top-level validation if AMB-27 fails.
    payload.setdefault("validation", {})
    if errors:
        payload["validation"]["status"] = "red"
        payload["validation"]["errors"] = sorted(set((payload["validation"].get("errors") or []) + errors))

    sort_items(payload)

    LEDGER_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_status_report(payload)

    print(f"wrote {LEDGER_JSON.relative_to(ROOT)}")
    print(f"wrote {STATUS_REPORT.relative_to(ROOT)}")
    print(f"items: {len(payload['items'])}")
    print(f"amb27 validation: {payload['amb27_status_classification']['status']}")
    print(f"source_only_not_implemented: {source_only_not_implemented}")
    print(f"unknown_without_evidence_remains_unknown: {unknown_without_evidence_remains_unknown}")
    print(f"every_item_classified: {every_item_classified}")
    print("implementation counts:")
    for key, value in sorted(impl_counts.items()):
        print(f"  {key}: {value}")
    print("proof counts:")
    for key, value in sorted(proof_counts.items()):
        print(f"  {key}: {value}")

    if errors:
        for error in errors[:100]:
            print(f"ERROR: {error}")
        if len(errors) > 100:
            print(f"... {len(errors) - 100} more errors")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
