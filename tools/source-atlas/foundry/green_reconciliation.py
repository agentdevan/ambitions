"""Evidence packet for Adapter + Broad Coverage Train 01 reconciliation."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, utc_now, write_json


YELLOW_CAUSES = [
    {
        "yellowCause": "Live fetches not run",
        "greenRequirement": "live fetch validated for approved adapters or precise credential blocker recorded",
        "evidenceArtifact": "docs/qa/source-atlas/live-adapter-validation.json and .md",
    },
    {
        "yellowCause": "Production R2 promotion not run",
        "greenRequirement": "broad pack promoted only if terms/privacy/R2 gates are green",
        "evidenceArtifact": "docs/qa/source-atlas/broad-occupation-pack-promotion-proof.json and existing production R2 operations proof",
    },
    {
        "yellowCause": "Scenario coverage partial",
        "greenRequirement": "coverage ledger identifies official-source gaps and no false completion",
        "evidenceArtifact": "docs/qa/source-atlas/source-atlas-coverage-ledger.json",
    },
    {
        "yellowCause": "Terms not owner-reviewed",
        "greenRequirement": "owner-review-grade terms evidence exists or explicit owner acceptance is recorded",
        "evidenceArtifact": "docs/qa/source-atlas/source-terms-distribution-review.json and .md",
    },
]


def build_green_reconciliation(
    output_path: Path,
    *,
    live_evidence_path: Path,
    terms_review_path: Path,
    coverage_ledger_path: Path,
    promotion_proof_path: Path,
    production_r2_proof_path: Path,
) -> dict[str, Any]:
    created_at = utc_now()
    live = _read_if_present(live_evidence_path)
    terms = _read_if_present(terms_review_path)
    coverage = _read_if_present(coverage_ledger_path)
    promotion = _read_if_present(promotion_proof_path)
    production_r2 = _read_if_present(production_r2_proof_path)

    row_results = {
        "Live fetches not run": "Green" if live.get("status") == "Green" else "Yellow",
        "Production R2 promotion not run": "Yellow",
        "Scenario coverage partial": "Green" if _scenario_coverage_honest(coverage) else "Yellow",
        "Terms not owner-reviewed": "Yellow" if not terms.get("ownerReviewComplete") else "Green",
    }
    production_r2_scope = production_r2.get("greenScope", "not run")
    final_status = "Green" if all(result == "Green" for result in row_results.values()) else "Yellow"
    rows = []
    for cause in YELLOW_CAUSES:
        rows.append({
            **cause,
            "owningFileCommandTest": _owner_for(cause["yellowCause"]),
            "result": row_results[cause["yellowCause"]],
            "remainingBlocker": _remaining_blocker(cause["yellowCause"], row_results[cause["yellowCause"]], production_r2_scope),
        })

    payload = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.adapterBroadCoverageGreenReconciliation.v1",
        "createdAt": created_at,
        "status": final_status,
        "statusReason": _status_reason(row_results),
        "yellowCauseRows": rows,
        "liveFetchResult": _live_summary(live),
        "termsReviewResult": {
            "status": terms.get("status", "missing"),
            "ownerReviewComplete": terms.get("ownerReviewComplete", False),
            "blockedSources": terms.get("blockedSources", []),
        },
        "scenarioCoverageResult": _coverage_summary(coverage),
        "broadPackPromotionResult": {
            "status": promotion.get("status", "missing"),
            "r2ProofResult": promotion.get("r2ProofResult", "missing"),
            "issues": promotion.get("issues", []),
        },
        "productionR2ProofResult": {
            "status": production_r2.get("status", "missing"),
            "scope": production_r2_scope,
            "train01PromotionUploadRun": False,
        },
        "nonClaims": [
            "does not claim full Source Atlas project Green",
            "does not claim legal/privacy approval",
            "does not claim App Store readiness",
            "does not claim account readiness",
            "does not claim complete runtime Green",
            "does not claim known issue closure",
            "does not create final user paths",
            "does not create final schedules",
            "does not create Step lists",
            *NON_CLAIMS,
        ],
        "rollbackPlan": "Revert live validation, promotion proof, terms packet, reconciliation evidence, regenerated broad pack/coverage artifacts, and associated tests.",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }
    write_json(output_path, payload)
    output_path.with_suffix(".md").write_text(render_green_reconciliation_markdown(payload), encoding="utf-8")
    return payload


def render_green_reconciliation_markdown(payload: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Adapter + Broad Coverage Green Reconciliation",
        "",
        f"Status: {payload['status']}",
        "",
        payload["statusReason"],
        "",
        "| Yellow cause | Green requirement | Evidence artifact | Result |",
        "| --- | --- | --- | --- |",
    ]
    for row in payload["yellowCauseRows"]:
        lines.append(f"| {row['yellowCause']} | {row['greenRequirement']} | `{row['evidenceArtifact']}` | {row['result']} |")
    lines.extend(["", "## Remaining Blockers", ""])
    blockers = [row for row in payload["yellowCauseRows"] if row["remainingBlocker"]]
    if blockers:
        lines.extend(f"- {row['yellowCause']}: {row['remainingBlocker']}" for row in blockers)
    else:
        lines.append("- none for the scoped reconciliation")
    lines.extend(["", "## Non-Claims", ""])
    lines.extend(f"- {item}" for item in payload["nonClaims"])
    lines.extend(["", "## Rollback", "", payload["rollbackPlan"], ""])
    return "\n".join(lines)


def _read_if_present(path: Path) -> dict[str, Any]:
    return read_json(path) if path.exists() else {"status": "missing"}


def _scenario_coverage_honest(coverage: dict[str, Any]) -> bool:
    scenarios = coverage.get("broadOccupationalFoundation", {}).get("scenario_coverage", [])
    return bool(scenarios) and all(row.get("completionReady") is False for row in scenarios)


def _owner_for(cause: str) -> str:
    owners = {
        "Live fetches not run": "tools/source-atlas/source-atlas-foundry.py run-adapters-live; tools/source-atlas/foundry/tests/test_adapter_broad_coverage_train_01.py",
        "Production R2 promotion not run": "tools/source-atlas/source-atlas-foundry.py broad-occupation-pack promote-proof; docs/qa/source-atlas/production-r2-operations-proof.json",
        "Scenario coverage partial": "tools/source-atlas/coverage-ledger.py; tools/source-atlas/generated/broad-occupational-foundation/coverage-report.json",
        "Terms not owner-reviewed": "docs/qa/source-atlas/source-terms-distribution-review.json; tools/source-atlas/foundry/terms_registry.py",
    }
    return owners[cause]


def _remaining_blocker(cause: str, result: str, production_r2_scope: str) -> str:
    if result == "Green":
        return ""
    if cause == "Production R2 promotion not run":
        return f"Train 01 broad pack production upload was not approved/run; existing R2 proof scope is {production_r2_scope}."
    if cause == "Terms not owner-reviewed":
        return "Owner/legal acceptance is not recorded in repo evidence; packet is ready for review."
    if cause == "Live fetches not run":
        return "Live validation evidence is missing or not Green."
    return "Coverage ledger did not prove deterministic no-false-completion scenario gaps."


def _status_reason(rows: dict[str, str]) -> str:
    if all(value == "Green" for value in rows.values()):
        return "All scoped Yellow causes resolved for Adapter + Broad Coverage Train 01 only."
    yellow = [cause for cause, result in rows.items() if result != "Green"]
    return "Scoped reconciliation remains Yellow: " + ", ".join(yellow)


def _live_summary(live: dict[str, Any]) -> dict[str, Any]:
    return {
        "status": live.get("status", "missing"),
        "summary": live.get("summary", {}),
        "fixtureFallbackHidden": live.get("fixtureFallbackHidden"),
        "results": [
            {
                "adapter": result.get("adapter"),
                "sourceID": result.get("sourceID"),
                "recordsFetched": result.get("recordsFetched"),
                "recordsNormalized": result.get("recordsNormalized"),
                "result": result.get("result"),
                "errors": result.get("errors", []),
            }
            for result in live.get("results", [])
        ],
    }


def _coverage_summary(coverage: dict[str, Any]) -> dict[str, Any]:
    broad = coverage.get("broadOccupationalFoundation", {})
    return {
        "scenarioCount": len(broad.get("scenario_coverage", [])),
        "allCompletionReadyFalse": all(row.get("completionReady") is False for row in broad.get("scenario_coverage", [])),
        "partialOrReviewRequired": [
            {
                "scenario": row.get("scenario"),
                "coverage": row.get("coverage"),
                "officialSourceGap": row.get("officialSourceGap"),
            }
            for row in broad.get("scenario_coverage", [])
            if row.get("coverage") != "covered"
        ],
    }
