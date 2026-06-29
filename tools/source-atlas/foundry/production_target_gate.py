"""Reusable enforcement gate for Source Atlas production target ledgers."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .model import PRIVACY_BOUNDARY, read_json


PRODUCTION_TARGET_READY_CLAIM = "bounded_production_target_for_configured_frontiers"
PRODUCTION_TARGET_PER_FRONTIER_CLAIM = "bounded_production_target_per_ready_frontier"


def validate_production_target_ledger_gate(
    *,
    ledger_path: Path | None,
    requested_domains: list[str],
    required: bool,
) -> dict[str, Any]:
    """Validate that requested domains are ready in a production target ledger."""

    normalized_domains = sorted(set(domain for domain in requested_domains if domain))
    issues: list[str] = []
    ledger: dict[str, Any] | None = None
    if ledger_path is None:
        if required:
            issues.append("production target ledger is required for this activation path")
        return _gate_payload(
            ledger_path=ledger_path,
            requested_domains=normalized_domains,
            ready_domains=[],
            required=required,
            issues=issues,
            ledger=None,
        )
    if not ledger_path.exists():
        issues.append(f"production target ledger does not exist: {ledger_path}")
        return _gate_payload(
            ledger_path=ledger_path,
            requested_domains=normalized_domains,
            ready_domains=[],
            required=required,
            issues=issues,
            ledger=None,
        )

    try:
        loaded = read_json(ledger_path)
    except Exception as exc:  # pragma: no cover - defensive; read_json platform messages vary.
        issues.append(f"production target ledger is unreadable: {ledger_path}: {exc}")
        return _gate_payload(
            ledger_path=ledger_path,
            requested_domains=normalized_domains,
            ready_domains=[],
            required=required,
            issues=issues,
            ledger=None,
        )
    if not isinstance(loaded, dict):
        issues.append(f"production target ledger is not an object: {ledger_path}")
        return _gate_payload(
            ledger_path=ledger_path,
            requested_domains=normalized_domains,
            ready_domains=[],
            required=required,
            issues=issues,
            ledger=None,
        )
    ledger = loaded
    if ledger.get("valid") is not True:
        issues.append("production target ledger is not valid")
    if ledger.get("kind") != "ambitions.sourceAtlas.productionTargetLedger.v1":
        issues.append("production target ledger kind is unsupported")
    allowed_claims = set(_list_value(ledger, "allowedClaims"))
    if PRODUCTION_TARGET_READY_CLAIM not in allowed_claims:
        issues.append(f"production target ledger is missing `{PRODUCTION_TARGET_READY_CLAIM}`")
    ready_domains = sorted(
        domain.get("domainID")
        for domain in ledger.get("domains", [])
        if isinstance(domain, dict)
        and domain.get("readinessStatus") == "bounded_production_target_ready"
        and isinstance(domain.get("domainID"), str)
    )
    missing_domains = sorted(set(normalized_domains) - set(ready_domains))
    for domain in missing_domains:
        issues.append(f"{domain}: not bounded production target ready in production target ledger")
    if ledger.get("orphanProductionDomains"):
        issues.append("production target ledger contains orphan production domains")
    if ledger.get("configuredDomainsNotReady"):
        issues.append("production target ledger contains configured domains that are not ready")

    return _gate_payload(
        ledger_path=ledger_path,
        requested_domains=normalized_domains,
        ready_domains=ready_domains,
        required=required,
        issues=issues,
        ledger=ledger,
    )


def domain_id_from_pack_id(pack_id: str) -> str:
    marker = "source-atlas/v1/domain/"
    if marker not in pack_id:
        return ""
    return pack_id.split(marker, 1)[1].split("/", 1)[0]


def domain_ids_from_publisher_reports(paths: list[Path]) -> list[str]:
    domains: list[str] = []
    for path in paths:
        try:
            report = read_json(path)
        except Exception:
            continue
        domain = domain_id_from_pack_id(str(report.get("packID", "")))
        if domain:
            domains.append(domain)
    return sorted(set(domains))


def _gate_payload(
    *,
    ledger_path: Path | None,
    requested_domains: list[str],
    ready_domains: list[str],
    required: bool,
    issues: list[str],
    ledger: dict[str, Any] | None,
) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedgerActivationGate.v1",
        "required": required,
        "valid": not issues,
        "ledgerPath": str(ledger_path) if ledger_path else None,
        "ledgerID": ledger.get("ledgerID") if isinstance(ledger, dict) else None,
        "overallReadinessStatus": ledger.get("overallReadinessStatus") if isinstance(ledger, dict) else None,
        "requestedDomains": requested_domains,
        "readyDomains": ready_domains,
        "missingDomains": sorted(set(requested_domains) - set(ready_domains)),
        "allowedClaims": _list_value(ledger, "allowedClaims"),
        "issues": issues,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": [
            "not literal universal coverage",
            "not full Source Atlas Green",
            "not Release Green",
            "not outside legal approval",
            "not final user plans, schedules, or Steps",
        ],
    }


def _list_value(container: dict[str, Any] | None, key: str) -> list[str]:
    if not isinstance(container, dict):
        return []
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float))]
