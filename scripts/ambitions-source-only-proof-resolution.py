#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

BUNDLES_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-bundles.json"
CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"

OUT_MD = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.json"

READINESS_MD = ROOT / "docs/ops/canon-collapse/source-code-readiness.md"
READINESS_JSON = ROOT / "docs/ops/canon-collapse/source-code-readiness.json"

OWNER = "CANON-COLLAPSE-002"
LINEAR_ISSUE = "AMB-289"

DISPOSITIONS = {
    "finish-real-source-proof": {
        "disposition": "proof-readiness",
        "status": "bounded-follow-up",
        "meaning": "Candidate may need real local proof, but is no longer a canon-collapse blocker once tracked as a proof-readiness lane.",
        "next_action": "Run source-code readiness analysis and select only candidates with real runnable commands.",
    },
    "merge-overlap-before-proof": {
        "disposition": "merge-before-proof",
        "status": "bounded-future-bundle",
        "meaning": "Candidate needs ownership or sequence merge before proof can be trusted.",
        "next_action": "Handle through one future merge/sequencing bundle, not candidate-by-candidate proof work.",
    },
    "rewrite-authority-before-proof": {
        "disposition": "rewrite-authority-before-proof",
        "status": "bounded-future-bundle",
        "meaning": "Candidate needs source-of-truth authority cleanup before proof work is meaningful.",
        "next_action": "Handle through one future authority-rewrite bundle.",
    },
    "manual-triage-remainder": {
        "disposition": "manual-triage",
        "status": "bounded-future-bundle",
        "meaning": "Candidate is ambiguous and requires owner triage before proof or rewrite.",
        "next_action": "Handle through one small manual triage bundle.",
    },
    "keep-planned-proof-later": {
        "disposition": "keep-planned",
        "status": "deferred",
        "meaning": "Candidate remains planned and is not an active proof blocker.",
        "next_action": "Keep planned until selected by active sequence.",
    },
    "retire-or-quarantine-stale-proof-debt": {
        "disposition": "retire-or-quarantine",
        "status": "bounded-future-bundle",
        "meaning": "Candidate looks stale and should be retired or quarantined before proof work.",
        "next_action": "Handle through a retirement/quarantine bundle.",
    },
}


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"missing {rel(path)}")
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        raise ValueError(f"empty {rel(path)}")
    return json.loads(text)


def command_class(candidate: dict[str, Any]) -> str:
    commands = candidate.get("validation_commands") or []
    touched_files = candidate.get("touched_files") or []
    repo_path = candidate.get("repo_path", "")

    blob = "\n".join(commands + touched_files + [repo_path]).lower()

    if "xcodebuild" in blob or "xcode-" in blob:
        return "xcode-build-or-test"
    if "python" in blob or repo_path.endswith(".py") or any(path.endswith(".py") for path in touched_files):
        return "python-validator"
    if ".sh" in blob or "bash" in blob or any(path.endswith(".sh") for path in touched_files):
        return "shell-validator"
    if "make " in blob:
        return "make-target"
    if repo_path.startswith("docs/"):
        return "docs-process-proof"
    return "manual-proof-triage"


def blocker_for(candidate: dict[str, Any]) -> str:
    bundle_id = candidate.get("bundle_id", "manual-triage-remainder")
    command = command_class(candidate)
    source_docs = candidate.get("source_of_truth_docs") or []

    if bundle_id == "merge-overlap-before-proof":
        return "overlapping ownership must be merged or sequenced before proof"
    if bundle_id == "rewrite-authority-before-proof":
        return "missing or weak source-of-truth authority must be rewritten before proof"
    if bundle_id == "manual-triage-remainder":
        return "ambiguous evidence requires owner triage"
    if command == "xcode-build-or-test":
        return "requires local Xcode validation environment before Green proof"
    if command == "docs-process-proof" and not source_docs:
        return "docs/process proof needs explicit authority references"
    return "no immediate canon-collapse blocker after disposition"


def proof_command_for(candidate: dict[str, Any]) -> str:
    commands = candidate.get("validation_commands") or []
    if commands:
        first = commands[0]
        if len(first) > 240:
            return "manual review required: candidate contains non-command validation text"
        return first

    command = command_class(candidate)

    if command == "python-validator":
        return "python3 -m py_compile <candidate-script>"
    if command == "shell-validator":
        return "bash -n <candidate-script>"
    if command == "make-target":
        return "make <candidate-target>"
    if command == "docs-process-proof":
        return "git diff --check -- <candidate-doc>"
    if command == "xcode-build-or-test":
        return "make xcode-build-for-testing BATCH=<batch-id>"

    return "manual proof command required"


def disposition_record(candidate: dict[str, Any]) -> dict[str, Any]:
    bundle_id = candidate.get("bundle_id", "manual-triage-remainder")
    bundle = DISPOSITIONS.get(bundle_id, DISPOSITIONS["manual-triage-remainder"])

    return {
        "candidate_id": candidate.get("candidate_id", "unknown"),
        "stable_id": candidate.get("stable_id", "unknown"),
        "repo_path": candidate.get("repo_path", "unknown"),
        "bundle_id": bundle_id,
        "disposition": bundle["disposition"],
        "disposition_status": bundle["status"],
        "disposition_meaning": bundle["meaning"],
        "next_action": bundle["next_action"],
        "proof_command_class": command_class(candidate),
        "suggested_proof_command": proof_command_for(candidate),
        "blocker": blocker_for(candidate),
        "implementation_status": candidate.get("implementation_status", "unknown"),
        "proof_state": candidate.get("proof_state", "unknown"),
        "path_kind": candidate.get("path_kind", "unknown"),
        "touched_surfaces": candidate.get("touched_surfaces", []),
        "touched_systems": candidate.get("touched_systems", []),
        "related_conflict_types": candidate.get("related_conflict_types", []),
        "non_claim": "This disposition does not prove implementation or completion.",
    }


def source_code_readiness(dispositions: list[dict[str, Any]]) -> dict[str, Any]:
    proof_ready = [
        item for item in dispositions
        if item["bundle_id"] == "finish-real-source-proof"
    ]

    xcode_items = [
        item for item in proof_ready
        if item["proof_command_class"] == "xcode-build-or-test"
    ]

    script_items = [
        item for item in proof_ready
        if item["proof_command_class"] in {"python-validator", "shell-validator", "make-target"}
    ]

    docs_items = [
        item for item in proof_ready
        if item["proof_command_class"] == "docs-process-proof"
    ]

    manual_items = [
        item for item in proof_ready
        if item["proof_command_class"] == "manual-proof-triage"
    ]

    source_code_ready = bool(xcode_items or script_items)

    if xcode_items:
        next_lane = "xcode-validation-lane"
        next_reason = "At least one candidate names an Xcode build/test command, so the next source-ready action is environment-aware Xcode validation."
    elif script_items:
        next_lane = "script-validator-lane"
        next_reason = "Candidates reference scripts or validators that can be checked locally before app-source work."
    elif docs_items:
        next_lane = "docs-process-proof-lane"
        next_reason = "Only docs/process proof candidates remain in the immediate proof lane."
    else:
        next_lane = "manual-triage-lane"
        next_reason = "No candidate has enough command evidence for source-code work."

    return {
        "source_code_ready": source_code_ready,
        "next_source_work_lane": next_lane,
        "next_source_work_reason": next_reason,
        "proof_ready_candidate_count": len(proof_ready),
        "xcode_candidate_count": len(xcode_items),
        "script_candidate_count": len(script_items),
        "docs_candidate_count": len(docs_items),
        "manual_candidate_count": len(manual_items),
        "xcode_candidates": xcode_items,
        "script_candidates": script_items,
        "docs_candidates": docs_items,
        "manual_candidates": manual_items,
        "non_claims": [
            "Source-code readiness is not source-code implementation.",
            "Source-code readiness is not build proof.",
            "Source-code readiness is not test proof.",
            "Linear status is not repo truth.",
        ],
    }


def write_resolution_markdown(payload: dict[str, Any]) -> None:
    summary = payload["summary"]

    lines = [
        "# Source-Only / Missing-Proof Resolution",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Purpose",
        "",
        "This artifact accounts for all source-only / missing-proof candidates from AMB-288 and assigns explicit repo-owned dispositions.",
        "",
        "It clears this class as a canon-collapse blocker without claiming the underlying work is implemented or proven.",
        "",
        "## Summary",
        "",
        f"- Total candidates resolved: {summary['total_candidates']}",
        f"- Bundles resolved: {summary['bundle_count']}",
        f"- Candidate accounting complete: {summary['candidate_accounting_complete']}",
        "",
        "### Candidates by disposition",
        "",
    ]

    for key, value in summary["by_disposition"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "### Candidates by bundle", ""])

    for key, value in summary["by_bundle"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "### Candidates by proof command class", ""])

    for key, value in summary["by_proof_command_class"].items():
        lines.append(f"- {key}: {value}")

    lines.extend(["", "## Disposition rules", ""])

    for bundle_id, definition in DISPOSITIONS.items():
        lines.append(f"### {bundle_id}")
        lines.append(f"- Disposition: {definition['disposition']}")
        lines.append(f"- Status: {definition['status']}")
        lines.append(f"- Meaning: {definition['meaning']}")
        lines.append(f"- Next action: {definition['next_action']}")
        lines.append("")

    lines.extend(["", "## Resolved candidates", ""])

    for item in payload["dispositions"][:360]:
        lines.append(f"- {item['candidate_id']} — {item['stable_id']} — {item['repo_path']}")
        lines.append(f"  - Bundle: {item['bundle_id']}")
        lines.append(f"  - Disposition: {item['disposition']}")
        lines.append(f"  - Proof command class: {item['proof_command_class']}")
        lines.append(f"  - Blocker: {item['blocker']}")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_readiness_markdown(payload: dict[str, Any]) -> None:
    lines = [
        "# Source Code Readiness",
        "",
        f"Status: {payload['status']}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Summary",
        "",
        f"- Source-code-ready: {payload['source_code_ready']}",
        f"- Next source work lane: {payload['next_source_work_lane']}",
        f"- Reason: {payload['next_source_work_reason']}",
        f"- Proof-ready candidates: {payload['proof_ready_candidate_count']}",
        f"- Xcode candidates: {payload['xcode_candidate_count']}",
        f"- Script candidates: {payload['script_candidate_count']}",
        f"- Docs candidates: {payload['docs_candidate_count']}",
        f"- Manual candidates: {payload['manual_candidate_count']}",
        "",
        "## Xcode candidates",
        "",
    ]

    if payload["xcode_candidates"]:
        for item in payload["xcode_candidates"]:
            lines.append(f"- {item['candidate_id']} — {item['repo_path']}")
            lines.append(f"  - Suggested command: {item['suggested_proof_command']}")
    else:
        lines.append("- None")

    lines.extend(["", "## Script candidates", ""])

    if payload["script_candidates"]:
        for item in payload["script_candidates"]:
            lines.append(f"- {item['candidate_id']} — {item['repo_path']}")
            lines.append(f"  - Suggested command: {item['suggested_proof_command']}")
    else:
        lines.append("- None")

    lines.extend(["", "## Docs/process candidates", ""])

    if payload["docs_candidates"]:
        for item in payload["docs_candidates"]:
            lines.append(f"- {item['candidate_id']} — {item['repo_path']}")
            lines.append(f"  - Suggested command: {item['suggested_proof_command']}")
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Non-claims",
            "",
        ]
    )

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    READINESS_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def validate(resolution: dict[str, Any], readiness: dict[str, Any], source_candidates: list[dict[str, Any]]) -> list[str]:
    errors = []

    if len(source_candidates) != 321:
        errors.append(f"expected 321 candidates from AMB-288, found {len(source_candidates)}")

    if resolution["summary"]["total_candidates"] != len(source_candidates):
        errors.append("resolution does not account for all source candidates")

    candidate_ids = [item["candidate_id"] for item in source_candidates]
    disposition_ids = [item["candidate_id"] for item in resolution["dispositions"]]

    if set(candidate_ids) != set(disposition_ids):
        errors.append("candidate ID set mismatch between AMB-288 and resolution")

    if len(disposition_ids) != len(set(disposition_ids)):
        errors.append("duplicate candidate IDs in resolution")

    if not readiness["next_source_work_lane"]:
        errors.append("missing next source work lane")

    for path in [OUT_MD, OUT_JSON, READINESS_MD, READINESS_JSON]:
        if not path.exists():
            errors.append(f"missing output artifact: {path.relative_to(ROOT)}")

    return errors


def main() -> int:
    bundles = load_json(BUNDLES_JSON)
    source_candidates = bundles.get("all_candidates", [])

    dispositions = [disposition_record(candidate) for candidate in source_candidates]

    by_disposition = Counter(item["disposition"] for item in dispositions)
    by_bundle = Counter(item["bundle_id"] for item in dispositions)
    by_command_class = Counter(item["proof_command_class"] for item in dispositions)

    summary = {
        "total_candidates": len(dispositions),
        "bundle_count": len(by_bundle),
        "candidate_accounting_complete": len(dispositions) == len(source_candidates),
        "by_disposition": dict(sorted(by_disposition.items())),
        "by_bundle": dict(sorted(by_bundle.items())),
        "by_proof_command_class": dict(sorted(by_command_class.items())),
    }

    resolution = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": "GREEN",
        "summary": summary,
        "dispositions": dispositions,
        "resolved_conflict_ids": sorted({item["candidate_id"] for item in dispositions}),
        "resolved_conflict_type": "source_only_implementation_missing_proof",
        "resolution_scope": "canon-collapse-blocker-disposition",
        "non_claims": [
            "This resolution does not prove implementation.",
            "This resolution does not prove build success.",
            "This resolution does not prove test success.",
            "This resolution does not mark source-only work complete.",
            "This resolution does not modify source code.",
            "This resolution does not modify product truth.",
            "Linear status is not repo truth.",
        ],
    }

    readiness_base = source_code_readiness(dispositions)
    readiness = {
        "schema_version": 1,
        "generated_utc": resolution["generated_utc"],
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": "GREEN",
        **readiness_base,
    }

    OUT_JSON.write_text(json.dumps(resolution, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    READINESS_JSON.write_text(json.dumps(readiness, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    write_resolution_markdown(resolution)
    write_readiness_markdown(readiness)

    errors = validate(resolution, readiness, source_candidates)
    if errors:
        resolution["status"] = "RED"
        resolution["validation_errors"] = errors
        OUT_JSON.write_text(json.dumps(resolution, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        write_resolution_markdown(resolution)
        print("AMB-289 source-only proof resolution failed.")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"wrote {OUT_MD.relative_to(ROOT)}")
    print(f"wrote {OUT_JSON.relative_to(ROOT)}")
    print(f"wrote {READINESS_MD.relative_to(ROOT)}")
    print(f"wrote {READINESS_JSON.relative_to(ROOT)}")
    print("status: GREEN")
    print(f"candidate_count: {summary['total_candidates']}")
    print(f"next_source_work_lane: {readiness['next_source_work_lane']}")
    print("AMB-289 source-only proof resolution passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
