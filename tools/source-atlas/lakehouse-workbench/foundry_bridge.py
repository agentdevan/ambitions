"""Compile lakehouse clean records into Foundry candidate handoff artifacts."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


PRIVACY_BOUNDARY = (
    "candidate public/reference seed data only; no private life graph, goals, captures, "
    "calendar data, proof, receipts, personalization, behavior history, or private user context"
)

NON_CLAIMS = [
    "not a production Source Atlas pack",
    "not a stable R2 channel",
    "not official source truth",
    "not step generation authority",
    "not private user-data storage",
    "not release readiness",
]


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def stable_hash(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def file_sha256(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def _read_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    records: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                records.append(json.loads(line))
    return records


def _load_domains(domains_file: Path) -> dict[str, Any]:
    if not domains_file.exists():
        return {}
    with domains_file.open("r", encoding="utf-8") as handle:
        raw = json.load(handle)
    domains = raw.get("domains", raw) if isinstance(raw, dict) else raw
    if not isinstance(domains, list):
        return {}
    return {
        item["code"]: {
            "title": item.get("title", item["code"]),
            "description": item.get("description", ""),
            "categories": item.get("categories", []),
        }
        for item in domains
        if isinstance(item, dict) and item.get("code")
    }


def _candidate_record(record: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": record["id"],
        "domain": record["domain"],
        "category": record["category"],
        "intentPhrase": record["intent_phrase"],
        "runtimeEligible": record["runtime_eligible"],
        "runtimeRole": record["runtime_role"],
        "blockedForStepGeneration": record["blocked_for_step_generation"],
        "evidenceQuality": record["evidence_quality"],
        "sourceFreshness": record["source_freshness"],
        "riskLevel": record["risk_level"],
        "reviewState": "candidate",
        "foundryRole": "intent_seed_candidate",
    }


def _coverage_matrix(candidates: list[dict[str, Any]], domains: dict[str, Any]) -> dict[str, Any]:
    domain_counts = {code: 0 for code in domains}
    category_counts: dict[str, int] = {}
    risk_counts: dict[str, int] = {}
    for item in candidates:
        domain = item["domain"]
        category = f"{domain}/{item['category']}"
        domain_counts[domain] = domain_counts.get(domain, 0) + 1
        category_counts[category] = category_counts.get(category, 0) + 1
        risk = item["riskLevel"]
        risk_counts[risk] = risk_counts.get(risk, 0) + 1

    return {
        "domainCoverage": domain_counts,
        "categoryCoverage": dict(sorted(category_counts.items())),
        "riskCoverage": dict(sorted(risk_counts.items())),
        "coverageGaps": [
            {"domain": code, "title": data.get("title", code), "candidateCount": count}
            for code, data in domains.items()
            if (count := domain_counts.get(code, 0)) < 5
        ],
    }


def compile_foundry_candidate_bundle(run_dir: Path, domains_file: Path, version_id: str | None = None) -> dict[str, Any]:
    version = version_id or run_dir.name
    created_at = utc_now()
    output_dir = run_dir / "publish" / "source-atlas" / "v1" / "candidates" / version
    output_dir.mkdir(parents=True, exist_ok=True)

    records = [
        *_read_jsonl(run_dir / "clean" / "domain_intents.jsonl"),
        *_read_jsonl(run_dir / "clean" / "grammar_intents.jsonl"),
    ]
    candidates = [_candidate_record(record) for record in records]
    domains = _load_domains(domains_file)

    candidate_index_path = output_dir / "candidate-intent-index.jsonl"
    with candidate_index_path.open("w", encoding="utf-8") as handle:
        for item in candidates:
            handle.write(json.dumps(item, sort_keys=True, ensure_ascii=False) + "\n")

    domain_index_path = output_dir / "candidate-domain-index.json"
    with domain_index_path.open("w", encoding="utf-8") as handle:
        json.dump(domains, handle, indent=2, sort_keys=True, ensure_ascii=False)
        handle.write("\n")

    coverage = _coverage_matrix(candidates, domains)
    coverage_path = output_dir / "candidate-coverage-matrix.json"
    with coverage_path.open("w", encoding="utf-8") as handle:
        json.dump(coverage, handle, indent=2, sort_keys=True, ensure_ascii=False)
        handle.write("\n")

    handoff = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.lakehouseFoundryHandoff",
        "versionID": version,
        "createdAt": created_at,
        "candidateCount": len(candidates),
        "domainCount": len(domains),
        "promotionState": "candidate_only",
        "requiredNextGate": "official-source review before reviewed or stable Source Atlas promotion",
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
        "candidateHash": stable_hash(candidates),
        "coverageHash": stable_hash(coverage),
    }
    handoff_path = output_dir / "foundry-handoff.json"
    with handoff_path.open("w", encoding="utf-8") as handle:
        json.dump(handoff, handle, indent=2, sort_keys=True, ensure_ascii=False)
        handle.write("\n")

    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.lakehouseCandidateManifest",
        "versionID": version,
        "createdAt": created_at,
        "channel": "candidate",
        "artifacts": {
            "candidate-intent-index.jsonl": file_sha256(candidate_index_path),
            "candidate-domain-index.json": file_sha256(domain_index_path),
            "candidate-coverage-matrix.json": file_sha256(coverage_path),
            "foundry-handoff.json": file_sha256(handoff_path),
        },
        "stats": {
            "candidateCount": len(candidates),
            "domainCount": len(domains),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": NON_CLAIMS,
    }
    manifest_path = output_dir / "candidate-manifest.json"
    with manifest_path.open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2, sort_keys=True, ensure_ascii=False)
        handle.write("\n")

    return {
        "candidateRoot": str(output_dir),
        "candidateManifestPath": str(manifest_path),
        "foundryHandoffPath": str(handoff_path),
        "candidateCount": len(candidates),
        "domainCount": len(domains),
        "manifestSHA256": file_sha256(manifest_path),
    }
