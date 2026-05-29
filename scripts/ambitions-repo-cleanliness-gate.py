#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

CANDIDATES_JSON = ROOT / "docs/ops/canon-collapse/active-canon-collapse-candidates.json"
REMAINING_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/remaining-canon-collapse-resolution.json"
SOURCE_RESOLUTION_JSON = ROOT / "docs/ops/canon-collapse/source-only-proof-resolution.json"
SOURCE_READINESS_JSON = ROOT / "docs/ops/canon-collapse/source-code-readiness.json"

OUT_MD = ROOT / "docs/ops/canon-collapse/repo-cleanliness-gate.md"
OUT_JSON = ROOT / "docs/ops/canon-collapse/repo-cleanliness-gate.json"

OWNER = "CANON-COLLAPSE-002"
LINEAR_ISSUE = "AMB-290"


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.strip():
        return {}
    return json.loads(text)


def main() -> int:
    candidates = load_json(CANDIDATES_JSON)
    remaining_resolution = load_json(REMAINING_RESOLUTION_JSON)
    source_resolution = load_json(SOURCE_RESOLUTION_JSON)
    source_readiness = load_json(SOURCE_READINESS_JSON)

    active_count = candidates.get("summary", {}).get("active_candidate_count", None)
    if active_count is None:
        active_count = len(candidates.get("active_candidates", []))

    source_code_ready = bool(source_readiness.get("source_code_ready", False))
    next_source_lane = source_readiness.get("next_source_work_lane", "unknown")

    canon_collapse_clean = active_count == 0
    resolutions_green = (
        remaining_resolution.get("status") == "GREEN"
        and source_resolution.get("status") == "GREEN"
    )

    status = "GREEN" if canon_collapse_clean and resolutions_green else "YELLOW"

    payload = {
        "schema_version": 1,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "owner": OWNER,
        "linear_issue": LINEAR_ISSUE,
        "status": status,
        "canon_collapse_clean": canon_collapse_clean,
        "active_canon_collapse_blockers": active_count,
        "source_code_ready": source_code_ready,
        "next_source_work_lane": next_source_lane,
        "source_code_gate": "xcode-validation-required" if next_source_lane == "xcode-validation-lane" else next_source_lane,
        "resolutions_green": resolutions_green,
        "required_next_step": "Run source-code readiness validation lane before claiming build/test/source implementation proof.",
        "artifact_inputs": [
            "docs/ops/canon-collapse/active-canon-collapse-candidates.json",
            "docs/ops/canon-collapse/source-only-proof-resolution.json",
            "docs/ops/canon-collapse/remaining-canon-collapse-resolution.json",
            "docs/ops/canon-collapse/source-code-readiness.json",
        ],
        "non_claims": [
            "This gate does not prove source implementation.",
            "This gate does not prove build success.",
            "This gate does not prove test success.",
            "This gate does not prove accessibility validation.",
            "This gate does not prove performance validation.",
            "This gate does not prove device validation.",
            "This gate does not prove privacy/legal approval.",
            "This gate does not prove TestFlight readiness.",
            "This gate does not prove App Store readiness.",
            "This gate does not prove release readiness.",
            "Linear status is not repo truth.",
        ],
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Repo Cleanliness Gate",
        "",
        f"Status: {status}",
        f"Generated UTC: {payload['generated_utc']}",
        f"Owner: {OWNER}",
        f"Linear issue: {LINEAR_ISSUE}",
        "",
        "## Gate result",
        "",
        f"- Canon-collapse clean: {canon_collapse_clean}",
        f"- Active canon-collapse blockers: {active_count}",
        f"- Source-code ready: {source_code_ready}",
        f"- Next source work lane: {next_source_lane}",
        f"- Source-code gate: {payload['source_code_gate']}",
        f"- Resolutions Green: {resolutions_green}",
        "",
        "## Required next step",
        "",
        payload["required_next_step"],
        "",
        "## Artifact inputs",
        "",
    ]

    for path in payload["artifact_inputs"]:
        lines.append(f"- {path}")

    lines.extend(["", "## Non-claims", ""])

    for claim in payload["non_claims"]:
        lines.append(f"- {claim}")

    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"wrote {rel(OUT_MD)}")
    print(f"wrote {rel(OUT_JSON)}")
    print(f"status: {status}")
    print(f"active_canon_collapse_blockers: {active_count}")
    print(f"source_code_ready: {source_code_ready}")
    print(f"next_source_work_lane: {next_source_lane}")

    return 0 if status == "GREEN" else 2


if __name__ == "__main__":
    raise SystemExit(main())
