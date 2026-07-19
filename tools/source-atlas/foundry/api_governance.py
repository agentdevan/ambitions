"""API key, rate, budget, and failure-posture governance for Source Atlas."""

from __future__ import annotations

import copy
import json
import os
from pathlib import Path
from typing import Any

from .certification import ADAPTER_CERTIFICATIONS
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, utc_now, write_json


DEFAULT_CONFIG_PATH = Path(__file__).resolve().parents[1] / "config" / "source_api_governance.json"
APPROVAL_TRUE_VALUES = {"1", "true", "yes", "approved"}


def load_api_governance_config(path: Path | None = None) -> dict[str, Any]:
    return read_json(path or DEFAULT_CONFIG_PATH)


def validate_api_governance(
    config_path: Path | None = None,
    env: dict[str, str] | None = None,
    output_path: Path | None = None,
) -> dict[str, Any]:
    runtime_env = os.environ if env is None else env
    config = load_api_governance_config(config_path)
    issues: list[str] = []
    adapters = config.get("adapters", {})
    if not isinstance(adapters, dict):
        issues.append("adapters: missing object")
        adapters = {}

    for adapter_id in sorted(ADAPTER_CERTIFICATIONS):
        adapter = adapters.get(adapter_id)
        if not isinstance(adapter, dict):
            issues.append(f"{adapter_id}: missing API governance config")
            continue
        issues.extend(_validate_adapter(adapter_id, adapter, runtime_env))

    for adapter_id in sorted(set(adapters) - set(ADAPTER_CERTIFICATIONS)):
        issues.append(f"{adapter_id}: config exists for unknown adapter")

    evidence = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.apiRateGovernanceValidation",
        "createdAt": utc_now(),
        "configPath": str(config_path or DEFAULT_CONFIG_PATH),
        "status": "Green",
        "valid": True,
        "adapterCount": len(adapters),
        "certifiedAdapterCount": len(ADAPTER_CERTIFICATIONS),
        "issues": issues,
        "modeEvidence": _mode_evidence(adapters, runtime_env),
        "redaction": {"passed": True, "issues": []},
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS
        + [
            "not release readiness",
            "not App Store readiness",
            "not outside legal approval",
            "not unbounded high-volume production approval",
        ],
    }
    evidence["redaction"] = _secret_redaction_check(evidence, adapters, runtime_env)
    if evidence["issues"] or not evidence["redaction"]["passed"]:
        evidence["valid"] = False
        evidence["status"] = "Red"
    if output_path:
        write_json(output_path, evidence)
    return evidence


def api_governance_markdown(result: dict[str, Any] | None = None, config_path: Path | None = None) -> str:
    result = result or validate_api_governance(config_path)
    rows = []
    for row in result.get("modeEvidence", []):
        rows.append(
            "| {adapter} | {source_ids} | {budget} | {timeout} | {backoff} | {missing_key} | {rate} |".format(
                adapter=row["adapterID"],
                source_ids=", ".join(row.get("sourceIDs", [])),
                budget=row.get("budgetSummary", ""),
                timeout=row.get("timeoutSeconds"),
                backoff=row.get("retryBackoff"),
                missing_key=row.get("missingKeyBehavior"),
                rate=row.get("rateLimitSummary", ""),
            )
        )
    lines = [
        "# Source Atlas API Rate Governance",
        "",
        f"Status: {result['status']}",
        "",
        "This packet governs live Source Atlas adapters. It does not approve unbounded high-volume production use.",
        "",
        "| Adapter | Source IDs | Budget | Timeout | Retry/backoff | Missing-key behavior | Rate-limit handling |",
        "|---|---|---|---|---|---|---|",
        *rows,
        "",
        "## Non-Claims",
        "",
        *[f"- {claim}" for claim in result["nonClaims"]],
        "",
    ]
    if result.get("issues"):
        lines.extend(["## Issues", "", *[f"- {issue}" for issue in result["issues"]], ""])
    return "\n".join(lines)


def write_api_governance_report(markdown_path: Path, json_path: Path, config_path: Path | None = None) -> dict[str, Any]:
    result = validate_api_governance(config_path, output_path=json_path)
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(api_governance_markdown(result, config_path), encoding="utf-8")
    return result


def _validate_adapter(adapter_id: str, adapter: dict[str, Any], env: dict[str, str]) -> list[str]:
    issues: list[str] = []
    if not adapter.get("sourceIDs"):
        issues.append(f"{adapter_id}: sourceIDs required")
    if "envVars" not in adapter or not isinstance(adapter.get("envVars"), list):
        issues.append(f"{adapter_id}: env var documentation required")
    else:
        for item in adapter["envVars"]:
            if not isinstance(item, dict) or not item.get("name") or not item.get("requiredFor") or item.get("loggedAs") != "env_var_name_only":
                issues.append(f"{adapter_id}: env var entries require name, requiredFor, loggedAs=env_var_name_only")

    request_budget = adapter.get("requestBudget", {})
    if not _positive_int(request_budget.get("daily")) or not _positive_int(request_budget.get("perRun")):
        issues.append(f"{adapter_id}: positive daily and perRun requestBudget required")
    if not _positive_int(adapter.get("timeoutSeconds")):
        issues.append(f"{adapter_id}: positive timeoutSeconds required")
    retry = adapter.get("retry", {})
    if not _positive_int(retry.get("maxAttempts")) or not retry.get("backoff"):
        issues.append(f"{adapter_id}: retry maxAttempts and backoff required")
    rate = adapter.get("rateLimitHandling", {})
    if not isinstance(rate.get("captureHeaders"), bool) or not isinstance(rate.get("backoffOn429"), bool):
        issues.append(f"{adapter_id}: rateLimitHandling captureHeaders and backoffOn429 booleans required")
    if rate.get("backoffOn429") is not True:
        issues.append(f"{adapter_id}: 429 responses must back off")
    secret_policy = adapter.get("secretPolicy", {})
    if secret_policy.get("noSecretLogging") is not True:
        issues.append(f"{adapter_id}: noSecretLogging must be true")
    if not adapter.get("missingKeyBehavior"):
        issues.append(f"{adapter_id}: missingKeyBehavior required")

    if adapter_id == "official_bls_public_api":
        v1 = adapter.get("v1NoKeyMode", {})
        v2 = adapter.get("v2KeyMode", {})
        if v1.get("allowed") is not True:
            issues.append("official_bls_public_api: v1 no-key mode must be allowed")
        if v2.get("optional") is not True or v2.get("envVar") != "BLS_API_KEY":
            issues.append("official_bls_public_api: v2 key mode must be optional with BLS_API_KEY")
        if adapter.get("missingKeyBehavior") != "fallback_to_v1_no_key":
            issues.append("official_bls_public_api: missing BLS_API_KEY must fall back to v1 no-key mode")

    if adapter_id == "official_wikidata_entity_crosswalk":
        if adapter.get("use") != "structured_crosswalk_only":
            issues.append("official_wikidata_entity_crosswalk: use must be structured_crosswalk_only")
        if adapter.get("regulatedAuthorityAllowed") is not False:
            issues.append("official_wikidata_entity_crosswalk: regulated authority use must be false")

    if adapter_id == "official_openalex_api":
        budgets = adapter.get("budgets", {})
        for mode in ["noKey", "freeKey"]:
            budget = budgets.get(mode, {})
            if not _positive_int(budget.get("daily")) or not _positive_int(budget.get("perRun")):
                issues.append(f"official_openalex_api: {mode} daily and perRun budgets required")
        if adapter.get("optionalApiKeyEnvVar") != "OPENALEX_API_KEY":
            issues.append("official_openalex_api: optional API key env var must be OPENALEX_API_KEY")
        if adapter.get("rateLimitHandling", {}).get("captureHeaders") is not True:
            issues.append("official_openalex_api: rate-limit headers must be captured")
        high_volume = adapter.get("highVolume", {})
        approval_env = str(high_volume.get("approvalEnvVar", "SOURCE_ATLAS_OPENALEX_HIGH_VOLUME_APPROVED"))
        requested = high_volume.get("productionRunPlanned") is True or env.get("SOURCE_ATLAS_OPENALEX_HIGH_VOLUME_REQUESTED", "").lower() in APPROVAL_TRUE_VALUES
        approved = high_volume.get("approved") is True or env.get(approval_env, "").lower() in APPROVAL_TRUE_VALUES
        if high_volume.get("requiresExplicitApproval") is not True:
            issues.append("official_openalex_api: high-volume use must require explicit approval")
        if requested and not approved:
            issues.append("official_openalex_api: high-volume production run requested without explicit approval")

    if adapter_id == "official_usajobs_authenticated_search":
        if adapter.get("packModeAllowed") is not False:
            issues.append("official_usajobs_authenticated_search: pack mode must be blocked")
        if adapter.get("r2ModeAllowed") is not False:
            issues.append("official_usajobs_authenticated_search: R2 mode must be blocked")
        if adapter.get("blockedWithoutWrittenApproval") is not True:
            issues.append("official_usajobs_authenticated_search: written approval gate required")

    return issues


def _mode_evidence(adapters: dict[str, Any], env: dict[str, str]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for adapter_id, adapter in sorted(adapters.items()):
        env_names = [item.get("name") for item in adapter.get("envVars", []) if isinstance(item, dict) and item.get("name")]
        row = {
            "adapterID": adapter_id,
            "sourceIDs": adapter.get("sourceIDs", []),
            "envVars": [{"name": name, "present": bool(env.get(name))} for name in env_names],
            "budgetSummary": _budget_summary(adapter),
            "timeoutSeconds": adapter.get("timeoutSeconds"),
            "retryBackoff": adapter.get("retry", {}).get("backoff"),
            "missingKeyBehavior": adapter.get("missingKeyBehavior"),
            "rateLimitSummary": _rate_summary(adapter.get("rateLimitHandling", {})),
        }
        if adapter_id == "official_bls_public_api":
            row["v1NoKeyAllowed"] = adapter.get("v1NoKeyMode", {}).get("allowed") is True
            row["v2KeyPresent"] = bool(env.get("BLS_API_KEY"))
        if adapter_id == "official_openalex_api":
            approval_env = adapter.get("highVolume", {}).get("approvalEnvVar", "SOURCE_ATLAS_OPENALEX_HIGH_VOLUME_APPROVED")
            row["highVolumeApproved"] = env.get(approval_env, "").lower() in APPROVAL_TRUE_VALUES or adapter.get("highVolume", {}).get("approved") is True
            row["highVolumeRequiresExplicitApproval"] = adapter.get("highVolume", {}).get("requiresExplicitApproval") is True
        if adapter_id == "official_wikidata_entity_crosswalk":
            row["regulatedAuthorityAllowed"] = adapter.get("regulatedAuthorityAllowed")
        if adapter_id == "official_usajobs_authenticated_search":
            row["packModeAllowed"] = adapter.get("packModeAllowed")
            row["r2ModeAllowed"] = adapter.get("r2ModeAllowed")
        rows.append(row)
    return rows


def _budget_summary(adapter: dict[str, Any]) -> str:
    budget = adapter.get("requestBudget", {})
    pieces = [f"daily={budget.get('daily')}", f"perRun={budget.get('perRun')}"]
    if adapter.get("budgets"):
        for name, item in sorted(adapter["budgets"].items()):
            pieces.append(f"{name}:daily={item.get('daily')},perRun={item.get('perRun')}")
    return "; ".join(pieces)


def _rate_summary(rate: dict[str, Any]) -> str:
    return "captureHeaders={capture}; backoffOn429={backoff}; respectRetryAfter={retry_after}".format(
        capture=rate.get("captureHeaders"),
        backoff=rate.get("backoffOn429"),
        retry_after=rate.get("respectRetryAfter"),
    )


def _secret_redaction_check(evidence: dict[str, Any], adapters: dict[str, Any], env: dict[str, str]) -> dict[str, Any]:
    sanitized = copy.deepcopy(evidence)
    sanitized.pop("redaction", None)
    encoded = json.dumps(sanitized, sort_keys=True, ensure_ascii=False)
    issues: list[str] = []
    for name in _secret_env_names(adapters):
        value = env.get(name)
        if value and len(value) >= 8 and value in encoded:
            issues.append(f"secret value leaked for {name}")
    return {"passed": not issues, "issues": issues}


def _secret_env_names(adapters: dict[str, Any]) -> set[str]:
    names: set[str] = set()
    for adapter in adapters.values():
        for item in adapter.get("envVars", []):
            if isinstance(item, dict) and isinstance(item.get("name"), str):
                name = item["name"]
                if any(marker in name.lower() for marker in ["key", "token", "password", "secret", "authorization"]):
                    names.add(name)
    return names


def _positive_int(value: Any) -> bool:
    return isinstance(value, int) and value > 0
