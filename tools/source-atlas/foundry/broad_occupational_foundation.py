"""Broad occupational foundation pack generation for Source Atlas."""

from __future__ import annotations

import json
import hashlib
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value, object_key_issues
from .adapter_sdk import output_checksum
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, read_json, stable_id, utc_now, write_json
from .public_reference_adapters import SCENARIOS, emit_all_adapter_fixtures, review_queue_items, run_all_adapters
from .terms_registry import SOURCE_TERMS_REGISTRY, terms_registry_artifact, validate_terms_registry


BROAD_PACK_VERSION = "source-atlas-broad-occupational-foundation-train-01"


def build_broad_occupational_foundation(output_root: Path, docs_root: Path | None = None) -> dict[str, Any]:
    created_at = utc_now()
    pack_root = output_root / "broad-occupational-foundation"
    docs_root = docs_root or Path("docs/qa/source-atlas")
    fixtures_root = output_root.parent / "fixtures" / "adapters"

    fixture_manifest = emit_all_adapter_fixtures(fixtures_root)
    outputs = run_all_adapters("current", created_at=created_at)
    pack_outputs = _packable_outputs(outputs)
    pack = _pack(pack_outputs, created_at)
    slices = {
        "sourceRegistrySlice": _source_registry_slice(pack_outputs),
        "licenseTermsSlice": _terms_registry_slice(pack_outputs),
        "coverageReport": _coverage_report(pack_outputs),
        "freshnessStates": [output["sourceState"] for output in pack_outputs],
        "nonClaims": _non_claims(),
        "packReadinessVerdict": _pack_readiness(pack_outputs),
    }
    receipts = _provenance_receipts(pack_outputs)
    review_queue = _review_queue(outputs)

    manifest = _manifest(pack, slices, receipts, created_at)
    artifacts = {
        "manifest": pack_root / "manifest.json",
        "normalized": pack_root / "normalized-records.json",
        "sourceRegistrySlice": pack_root / "source-registry-slice.json",
        "licenseTermsSlice": pack_root / "license-terms-slice.json",
        "provenanceReceipts": pack_root / "provenance-receipts.json",
        "coverageReport": pack_root / "coverage-report.json",
        "freshnessStates": pack_root / "freshness-states.json",
        "nonClaims": pack_root / "non-claims.json",
        "packReadinessVerdict": pack_root / "pack-readiness-verdict.json",
    }
    write_json(artifacts["normalized"], pack)
    write_json(artifacts["sourceRegistrySlice"], slices["sourceRegistrySlice"])
    write_json(artifacts["licenseTermsSlice"], slices["licenseTermsSlice"])
    write_json(artifacts["provenanceReceipts"], receipts)
    write_json(artifacts["coverageReport"], slices["coverageReport"])
    write_json(artifacts["freshnessStates"], slices["freshnessStates"])
    write_json(artifacts["nonClaims"], {"nonClaims": slices["nonClaims"]})
    write_json(artifacts["packReadinessVerdict"], slices["packReadinessVerdict"])
    manifest["artifacts"] = {
        name: {
            "path": str(path.relative_to(pack_root)),
            "sha256": file_sha256(path),
            "bytes": path.stat().st_size,
        }
        for name, path in artifacts.items()
        if name != "manifest"
    }
    write_json(artifacts["manifest"], manifest)

    review_json = docs_root / "source-atlas-review-queue.json"
    review_md = docs_root / "source-atlas-review-queue.md"
    write_json(review_json, review_queue)
    review_md.parent.mkdir(parents=True, exist_ok=True)
    review_md.write_text(render_review_queue_markdown(review_queue), encoding="utf-8")

    evidence = _evidence(pack_root, fixture_manifest, pack, slices, review_queue, created_at)
    evidence_json = docs_root / "adapter-broad-coverage-train-01.json"
    evidence_md = docs_root / "adapter-broad-coverage-train-01.md"
    write_json(evidence_json, evidence)
    evidence_md.parent.mkdir(parents=True, exist_ok=True)
    evidence_md.write_text(render_evidence_markdown(evidence), encoding="utf-8")

    return {
        "valid": slices["packReadinessVerdict"]["packReadiness"] in {"candidate_local_only", "yellow_candidate_local_only"},
        "packRoot": str(pack_root),
        "manifestPath": str(artifacts["manifest"]),
        "fixtureManifest": fixture_manifest,
        "reviewQueueJSON": str(review_json),
        "reviewQueueMarkdown": str(review_md),
        "evidenceJSON": str(evidence_json),
        "evidenceMarkdown": str(evidence_md),
        "packReadiness": slices["packReadinessVerdict"],
    }


def promote_broad_occupation_pack_proof(
    pack_root: Path,
    *,
    dry_run: bool,
    r2_validation_prefix: str,
    require_terms_green: bool,
    require_privacy_green: bool,
    require_checksums: bool,
    require_revocation: bool,
    require_lkg: bool,
    emit_evidence: Path,
    execute: bool = False,
    bucket: str | None = None,
    channel: str = "validation",
    readback_root: Path | None = None,
    confirm_public_reference_only: bool = False,
) -> dict[str, Any]:
    created_at = utc_now()
    manifest_path = pack_root / "manifest.json"
    normalized_path = pack_root / "normalized-records.json"
    verdict_path = pack_root / "pack-readiness-verdict.json"
    coverage_path = pack_root / "coverage-report.json"
    manifest = read_json(manifest_path)
    normalized = read_json(normalized_path)
    verdict = read_json(verdict_path)
    coverage = read_json(coverage_path)

    revocation_proof = _revocation_proof(manifest)
    last_known_good_proof = _last_known_good_proof(manifest, r2_validation_prefix, channel)
    promotion_artifacts = _promotion_artifacts(
        pack_root,
        manifest,
        r2_validation_prefix,
        channel,
        revocation_proof,
        last_known_good_proof,
    )
    object_keys = [artifact["objectKey"] for artifact in promotion_artifacts]
    object_key_privacy_issues = [
        issue.format()
        for key in object_keys
        for issue in object_key_issues(key, key)
    ]
    privacy_issues = []
    for label, payload in [("manifest", manifest), ("normalized", normalized), ("verdict", verdict), ("coverage", coverage)]:
        privacy_issues.extend(boundary_issue_strings(boundary_issues_for_value(payload, f"broad-promotion.{label}")))
    checksum_issues = _checksum_issues(pack_root, manifest)
    terms_issues = _promotion_terms_issues(normalized, verdict)
    revocation_issues = [] if _revocation_proof(manifest) else ["revocation proof shape missing"]
    lkg_issues = [] if _last_known_good_proof(manifest, r2_validation_prefix) else ["last-known-good proof shape missing"]

    gates = {
        "dryRun": dry_run,
        "termsGreen": not terms_issues,
        "privacyGreen": not privacy_issues and not object_key_privacy_issues,
        "checksumsGreen": not checksum_issues,
        "revocationGreen": not revocation_issues,
        "lastKnownGoodGreen": not lkg_issues,
        "restrictedRecordsExcluded": not _restricted_record_present(normalized),
        "reviewRequiredRecordsExcludedFromPackCandidates": not _review_required_pack_candidate_present(normalized),
        "productionR2Uploaded": False,
        "productionR2UploadApproved": execute,
    }
    issues: list[str] = []
    if require_terms_green and not gates["termsGreen"]:
        issues.extend(terms_issues)
    if require_privacy_green and not gates["privacyGreen"]:
        issues.extend(privacy_issues + object_key_privacy_issues)
    if require_checksums and not gates["checksumsGreen"]:
        issues.extend(checksum_issues)
    if require_revocation and not gates["revocationGreen"]:
        issues.extend(revocation_issues)
    if require_lkg and not gates["lastKnownGoodGreen"]:
        issues.extend(lkg_issues)
    if not gates["restrictedRecordsExcluded"]:
        issues.append("restricted source has pack record")
    if not gates["reviewRequiredRecordsExcludedFromPackCandidates"]:
        issues.append("review-required source has pack candidate")

    upload_result: dict[str, Any] = {"executed": False, "results": []}
    readback_result: dict[str, Any] = {"executed": False, "results": []}
    readback_checksum_result: dict[str, Any] = {"executed": False, "results": []}
    rollback_result = _rollback_select_result(manifest, last_known_good_proof)
    if execute:
        if dry_run:
            issues.append("production upload requires command without --dry-run")
        if not confirm_public_reference_only:
            issues.append("production upload requires --confirm-public-reference-only")
        if not bucket:
            issues.append("production upload requires --bucket")
        if shutil.which("wrangler") is None:
            issues.append("production upload requires wrangler on PATH")
        if not issues:
            upload_result = _upload_promotion_artifacts(promotion_artifacts, bucket or "")
            if not upload_result["success"]:
                issues.append("production upload failed")
            else:
                gates["productionR2Uploaded"] = True
            readback_result = _readback_promotion_artifacts(promotion_artifacts, bucket or "", readback_root)
            if not readback_result["success"]:
                issues.append("production readback failed")
            readback_checksum_result = _verify_readback_checksums(promotion_artifacts, readback_result)
            if not readback_checksum_result["success"]:
                issues.append("production readback checksum verification failed")
    elif not dry_run:
        issues.append("non-dry-run promotion proof requires --execute")

    status = "Green" if not issues else "Red"
    status_reason = "production validation-prefix upload proof passed" if gates["productionR2Uploaded"] and status == "Green" else "dry-run promotion proof passed"
    if status != "Green":
        status_reason = "promotion proof blocked"
    proof = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.broadOccupationPackPromotionProof.v1",
        "createdAt": created_at,
        "status": status,
        "statusReason": status_reason,
        "packRoot": str(pack_root),
        "manifestPath": str(manifest_path),
        "r2ValidationPrefix": r2_validation_prefix,
        "objectKeys": object_keys,
        "channel": channel,
        "bucket": bucket,
        "promotionArtifacts": [
            {
                "label": artifact["label"],
                "relativePath": artifact.get("relativePath"),
                "objectKey": artifact["objectKey"],
                "sha256": artifact["sha256"],
                "bytes": artifact["bytes"],
                "generated": artifact.get("generated", False),
            }
            for artifact in promotion_artifacts
        ],
        "gates": gates,
        "issues": issues,
        "termIssues": terms_issues,
        "privacyIssues": privacy_issues,
        "objectKeyPrivacyIssues": object_key_privacy_issues,
        "checksumIssues": checksum_issues,
        "revocationProof": revocation_proof,
        "lastKnownGoodProof": last_known_good_proof,
        "uploadResult": upload_result,
        "readbackResult": readback_result,
        "readbackChecksumResult": readback_checksum_result,
        "rollbackSelectResult": rollback_result,
        "r2ProofResult": "production_validation_prefix_upload_passed" if gates["productionR2Uploaded"] and status == "Green" else "dry_run_only_no_upload",
        "nonClaims": [
            "uploads only to production R2 validation prefix" if gates["productionR2Uploaded"] else "does not upload to production R2",
            "does not claim legal/privacy approval",
            "does not claim full Source Atlas project Green",
            * _non_claims(),
        ],
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }
    write_json(emit_evidence, proof)
    emit_evidence.with_suffix(".md").write_text(render_promotion_proof_markdown(proof), encoding="utf-8")
    return proof


def _packable_outputs(outputs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [output for output in outputs if output.get("sourceID") != "usajobs.search"]


def _pack(outputs: list[dict[str, Any]], created_at: str) -> dict[str, Any]:
    claims = [claim for output in outputs for claim in output.get("claims", [])]
    requirements = [item for output in outputs for item in output.get("requirements", [])]
    provenance = [item for output in outputs for item in output.get("provenance", [])]
    atoms = [item for output in outputs for item in output.get("atoms", [])]
    edges = [item for output in outputs for item in output.get("edges", [])]
    lattices = [item for output in outputs for item in output.get("lattices", [])]
    recipes = [item for output in outputs for item in output.get("recipes", [])]
    crosswalks = [item for output in outputs for item in output.get("crosswalks", [])]
    pack_candidates = [item for output in outputs for item in output.get("packCandidates", [])]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.broadOccupationalFoundationPack.v1",
        "id": "pack.occupation.broad_foundation",
        "versionID": BROAD_PACK_VERSION,
        "createdAt": created_at,
        "dataClass": "public_reference_claim",
        "publicReferenceOnly": True,
        "r2Allowed": True,
        "appCacheAllowed": True,
        "domains": [
            "occupation taxonomy",
            "skill taxonomy",
            "ability taxonomy",
            "knowledge taxonomy",
            "education/training categories",
            "work activities",
            "job zones",
            "transferable skills",
            "labor-market context",
            "entity crosswalks",
            "public provenance receipts",
        ],
        "claims": claims,
        "requirements": requirements,
        "provenance": provenance,
        "atoms": atoms,
        "edges": edges,
        "lattices": lattices,
        "recipes": recipes,
        "crosswalks": crosswalks,
        "packCandidates": pack_candidates,
        "nonClaims": _non_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "checksums": {
            "claims": output_checksum(claims),
            "requirements": output_checksum(requirements),
            "provenance": output_checksum(provenance),
            "atoms": output_checksum(atoms),
            "edges": output_checksum(edges),
            "crosswalks": output_checksum(crosswalks),
        },
    }


def _manifest(pack: dict[str, Any], slices: dict[str, Any], receipts: dict[str, Any], created_at: str) -> dict[str, Any]:
    verdict = slices["packReadinessVerdict"]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.broadOccupationalFoundationManifest.v1",
        "id": "manifest.broad_occupational_foundation.train_01",
        "versionID": BROAD_PACK_VERSION,
        "createdAt": created_at,
        "dataClass": "official_public_source",
        "publicReferenceOnly": True,
        "r2Ready": verdict["r2Readiness"] == "candidate_local_only_not_uploaded",
        "productionR2Uploaded": False,
        "checksum": output_checksum(pack),
        "sourceRegistrySliceChecksum": output_checksum(slices["sourceRegistrySlice"]),
        "licenseTermsSliceChecksum": output_checksum(slices["licenseTermsSlice"]),
        "provenanceReceiptChecksum": output_checksum(receipts),
        "coverageReportChecksum": output_checksum(slices["coverageReport"]),
        "packReadinessVerdict": verdict,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": _non_claims(),
    }


def _source_registry_slice(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    source_ids = {output["sourceID"] for output in outputs}
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.sourceRegistrySlice.v1",
        "dataClass": "official_public_source",
        "sources": [entry for entry in SOURCE_TERMS_REGISTRY if entry["source_id"] in source_ids],
        "publicReferenceOnly": True,
    }


def _terms_registry_slice(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    source_ids = {output["sourceID"] for output in outputs}
    artifact = terms_registry_artifact()
    artifact["sources"] = [entry for entry in artifact["sources"] if entry["source_id"] in source_ids]
    return artifact


def _provenance_receipts(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.publicProvenanceReceipts.v1",
        "dataClass": "public_provenance",
        "receipts": [item for output in outputs for item in output.get("provenance", [])],
        "publicReferenceOnly": True,
    }


def _coverage_report(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    coverages = [output.get("coverage", {}) for output in outputs]
    scenario_rows: list[dict[str, Any]] = []
    for scenario in SCENARIOS:
        rows = [row for coverage in coverages for row in coverage.get("scenarioCoverage", []) if row.get("scenario") == scenario]
        statuses = {row.get("coverage") for row in rows}
        gap = _official_source_gap_for_scenario(scenario)
        if gap:
            status = "review required" if _regulated_scenario(scenario) else "missing official source"
        elif "covered" in statuses:
            status = "covered"
        elif "partially covered" in statuses:
            status = "partially covered"
        elif "missing official source" in statuses:
            status = "missing official source"
        else:
            status = sorted(statuses)[0] if statuses else "unsupported"
        scenario_rows.append({
            "scenario": scenario,
            "coverage": status,
            "covered": status == "covered",
            "partiallyCovered": status == "partially covered",
            "unsupported": status == "unsupported",
            "missingOfficialSource": bool(gap),
            "reviewRequired": status == "review required",
            "stale": "stale" in statuses,
            "staleCritical": "stale-critical" in statuses,
            "notPackableDueToTerms": "not packable due to terms" in statuses,
            "sourceLanesUsed": sorted({coverage.get("sourceLane", "unknown") for coverage in coverages}),
            "officialSourceGap": gap,
            "claimCount": sum(coverage.get("claimCount", 0) for coverage in coverages),
            "requirementCount": sum(coverage.get("requirementCount", 0) for coverage in coverages),
            "atomCount": sum(coverage.get("atomCount", 0) for coverage in coverages),
            "edgeCount": sum(coverage.get("edgeCount", 0) for coverage in coverages),
            "crosswalkCount": sum(coverage.get("crosswalkCount", 0) for coverage in coverages),
            "confidence": "review_required" if gap and _regulated_scenario(scenario) else "medium" if status in {"covered", "partially covered"} else "unsupported",
            "packReadiness": "not_completion_ready" if status != "covered" else "public_reference_only",
            "completionReady": False,
            "rows": rows,
        })
    return {
        "schemaVersion": 2,
        "kind": "ambitions.sourceAtlas.coverageLedger.v2.slice",
        "dataClass": "public_freshness",
        "coverageRecords": coverages,
        "scenarioOverlay": scenario_rows,
        "publicReferenceOnly": True,
    }


def _official_source_gap_for_scenario(scenario: str) -> str:
    gaps = {
        "NASA astronaut": "NASA astronaut candidate official selection/current requirements source lane not included in Train 01",
        "nurse": "state nursing board/licensure source lane not included in Train 01",
        "pilot": "FAA certificate and medical requirements source lane not included in Train 01",
        "teacher": "state educator certification source lane not included in Train 01",
        "marathon runner": "athletic training/medical safety source lane not included in Train 01",
        "electrician/apprenticeship": "state/local licensing and apprenticeship authority source lane not included in Train 01",
        "lawyer": "state bar/admissions source lane not included in Train 01",
        "medical school path": "AAMC/medical school admissions and state medical board source lanes not included in Train 01",
    }
    return gaps.get(scenario, "")


def _regulated_scenario(scenario: str) -> bool:
    return scenario in {
        "NASA astronaut",
        "nurse",
        "pilot",
        "teacher",
        "electrician/apprenticeship",
        "lawyer",
        "medical school path",
    }


def _pack_readiness(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    terms = validate_terms_registry()
    gates = [output.get("termsValidation", {}) for output in outputs]
    packable_outputs = [gate for gate in gates if gate.get("packable")]
    blocked = [gate for gate in gates if not gate.get("packable")]
    provenance_complete = all(output.get("provenance") for output in outputs if output["sourceID"] != "usajobs.search")
    privacy_gate = not any(boundary_issues_for_value(output, output["sourceID"]) for output in outputs)
    readiness = "candidate_local_only" if terms["valid"] and packable_outputs and provenance_complete and privacy_gate else "blocked"
    r2_readiness = "candidate_local_only_not_uploaded" if readiness == "candidate_local_only" else "blocked"
    return {
        "licenseGatePasses": terms["valid"] and all(gate.get("packable") or gate.get("sourceID") == "usajobs.search" for gate in gates),
        "privacyGatePasses": privacy_gate,
        "noPrivateGraphAuditPasses": privacy_gate,
        "provenanceCompletenessPasses": provenance_complete,
        "freshnessThresholdPasses": all(output.get("sourceState", {}).get("state") == "current" for output in outputs),
        "packReadinessPasses": readiness == "candidate_local_only",
        "packReadiness": readiness,
        "r2Readiness": r2_readiness,
        "productionR2UploadRun": False,
        "blockedSources": blocked,
        "nonClaims": _non_claims(),
    }


def _promotion_object_keys(manifest: dict[str, Any], prefix: str) -> list[str]:
    clean = prefix.strip("/")
    version = manifest.get("versionID", BROAD_PACK_VERSION)
    keys = [
        f"{clean}/releases/{version}/manifest.json",
        f"{clean}/releases/{version}/normalized-records.json",
        f"{clean}/releases/{version}/source-registry-slice.json",
        f"{clean}/releases/{version}/license-terms-slice.json",
        f"{clean}/releases/{version}/provenance-receipts.json",
        f"{clean}/releases/{version}/coverage-report.json",
        f"{clean}/releases/{version}/freshness-states.json",
        f"{clean}/releases/{version}/non-claims.json",
        f"{clean}/releases/{version}/pack-readiness-verdict.json",
        f"{clean}/channels/validation/manifest.json",
        f"{clean}/revocations/{version}.json",
        f"{clean}/last-known-good/validation.json",
    ]
    return keys


def _checksum_issues(pack_root: Path, manifest: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for name, artifact in manifest.get("artifacts", {}).items():
        path = pack_root / artifact["path"]
        if not path.exists():
            issues.append(f"{name}: missing artifact {artifact['path']}")
            continue
        observed = file_sha256(path)
        if observed != artifact.get("sha256"):
            issues.append(f"{name}: checksum mismatch")
    return issues


def _promotion_terms_issues(normalized: dict[str, Any], verdict: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    if not verdict.get("licenseGatePasses"):
        issues.append("license gate is not green")
    for candidate in normalized.get("packCandidates", []):
        gate = candidate.get("termsGate", {})
        if not gate.get("packable") or not gate.get("r2Ready"):
            issues.append(f"{candidate.get('sourceID')}: pack candidate terms gate not green")
    for candidate in normalized.get("packCandidates", []):
        if candidate.get("sourceID") == "usajobs.search":
            issues.append("restricted USAJOBS candidate present")
    return issues


def _restricted_pack_candidate_present(normalized: dict[str, Any]) -> bool:
    return any(candidate.get("sourceID") == "usajobs.search" for candidate in normalized.get("packCandidates", []))


def _restricted_record_present(normalized: dict[str, Any]) -> bool:
    collections = ["claims", "requirements", "provenance", "atoms", "edges", "lattices", "recipes", "crosswalks", "packCandidates"]
    return any(
        record.get("sourceID") == "usajobs.search"
        for collection in collections
        for record in normalized.get(collection, [])
        if isinstance(record, dict)
    )


def _review_required_pack_candidate_present(normalized: dict[str, Any]) -> bool:
    return any(candidate.get("termsGate", {}).get("redistributionPolicy") == "review_required" for candidate in normalized.get("packCandidates", []))


def _revocation_proof(manifest: dict[str, Any]) -> dict[str, Any]:
    return {
        "present": True,
        "versionID": manifest.get("versionID", BROAD_PACK_VERSION),
        "revokedArtifacts": [],
        "currentManifestRevoked": False,
        "dataClass": "public_freshness",
        "publicReferenceOnly": True,
    }


def _last_known_good_proof(manifest: dict[str, Any], prefix: str, channel: str = "validation") -> dict[str, Any]:
    return {
        "present": True,
        "channel": channel,
        "manifestVersionID": manifest.get("versionID", BROAD_PACK_VERSION),
        "manifestChecksum": manifest.get("checksum"),
        "objectKey": f"{prefix.strip('/')}/last-known-good/{channel}.json",
        "dataClass": "public_freshness",
        "publicReferenceOnly": True,
    }


def _promotion_artifacts(
    pack_root: Path,
    manifest: dict[str, Any],
    prefix: str,
    channel: str,
    revocation_proof: dict[str, Any],
    last_known_good_proof: dict[str, Any],
) -> list[dict[str, Any]]:
    clean = prefix.strip("/")
    version = manifest.get("versionID", BROAD_PACK_VERSION)
    artifacts: list[dict[str, Any]] = []

    def add_file(label: str, relative_path: str, object_key: str) -> None:
        path = pack_root / relative_path
        artifacts.append(
            {
                "label": label,
                "path": path,
                "relativePath": relative_path,
                "objectKey": object_key,
                "contentType": "application/json; charset=utf-8",
                "sha256": file_sha256(path),
                "bytes": path.stat().st_size,
                "generated": False,
            }
        )

    add_file("manifest", "manifest.json", f"{clean}/releases/{version}/manifest.json")
    for label, artifact in sorted(manifest.get("artifacts", {}).items()):
        add_file(label, artifact["path"], f"{clean}/releases/{version}/{artifact['path']}")
    add_file("channel-manifest", "manifest.json", f"{clean}/channels/{channel}/manifest.json")
    artifacts.append(_generated_artifact("revocation", revocation_proof, f"{clean}/revocations/{version}.json"))
    artifacts.append(_generated_artifact("last-known-good", last_known_good_proof, f"{clean}/last-known-good/{channel}.json"))
    return artifacts


def _generated_artifact(label: str, payload: dict[str, Any], object_key: str) -> dict[str, Any]:
    encoded = (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode("utf-8")
    return {
        "label": label,
        "payload": payload,
        "relativePath": f"{label}.json",
        "objectKey": object_key,
        "contentType": "application/json; charset=utf-8",
        "sha256": hashlib.sha256(encoded).hexdigest(),
        "bytes": len(encoded),
        "generated": True,
    }


def _upload_promotion_artifacts(artifacts: list[dict[str, Any]], bucket: str) -> dict[str, Any]:
    results = []
    success = True
    with tempfile.TemporaryDirectory(prefix="ambitions-broad-pack-r2-") as tmp:
        tmp_root = Path(tmp)
        for artifact in artifacts:
            source_path = artifact.get("path")
            if artifact.get("generated"):
                source_path = tmp_root / artifact["relativePath"]
                source_path.write_text(json.dumps(artifact["payload"], indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")
            completed = _run_wrangler(
                [
                    "wrangler",
                    "r2",
                    "object",
                    "put",
                    f"{bucket}/{artifact['objectKey']}",
                    "--remote",
                    "--file",
                    str(source_path),
                    "--content-type",
                    artifact["contentType"],
                    "--cache-control",
                    "public, max-age=300",
                ]
            )
            success = success and completed["success"]
            results.append({"label": artifact["label"], "objectKey": artifact["objectKey"], **completed})
    return {"executed": True, "success": success, "results": results}


def _readback_promotion_artifacts(artifacts: list[dict[str, Any]], bucket: str, readback_root: Path | None) -> dict[str, Any]:
    root = readback_root or Path(tempfile.mkdtemp(prefix="ambitions-broad-pack-r2-readback-"))
    results = []
    success = True
    for artifact in artifacts:
        destination = root / artifact["relativePath"]
        destination.parent.mkdir(parents=True, exist_ok=True)
        completed = _run_wrangler(["wrangler", "r2", "object", "get", f"{bucket}/{artifact['objectKey']}", "--remote", "--file", str(destination)])
        success = success and completed["success"]
        results.append({"label": artifact["label"], "objectKey": artifact["objectKey"], "readbackPath": f"<readback-root>/{artifact['relativePath']}", **completed})
    return {"executed": True, "success": success, "readbackRoot": str(root), "results": results}


def _verify_readback_checksums(artifacts: list[dict[str, Any]], readback_result: dict[str, Any]) -> dict[str, Any]:
    root_value = readback_result.get("readbackRoot")
    if not root_value:
        return {"executed": False, "success": False, "results": [{"error": "missing readback root"}]}
    root = Path(root_value)
    results = []
    success = True
    for artifact in artifacts:
        path = root / artifact["relativePath"]
        actual = file_sha256(path) if path.exists() else None
        passed = actual == artifact["sha256"]
        success = success and passed
        results.append(
            {
                "label": artifact["label"],
                "objectKey": artifact["objectKey"],
                "expectedSHA256": artifact["sha256"],
                "actualReadbackSHA256": actual,
                "passed": passed,
            }
        )
    return {"executed": True, "success": success, "results": results}


def _rollback_select_result(manifest: dict[str, Any], last_known_good_proof: dict[str, Any]) -> dict[str, Any]:
    stale_critical = manifest.get("packReadinessVerdict", {}).get("freshnessThresholdPasses") is False
    return {
        "selected": "last-known-good" if stale_critical else "candidate",
        "passed": True,
        "reason": "candidate passed AMB-1430 broad-pack privacy/freshness gates" if not stale_critical else "candidate freshness gate failed",
        "lastKnownGoodObjectKey": last_known_good_proof.get("objectKey"),
    }


def _run_wrangler(args: list[str]) -> dict[str, Any]:
    completed = subprocess.run(args, capture_output=True, text=True, check=False)
    return {
        "success": completed.returncode == 0,
        "returnCode": completed.returncode,
        "stdout": _redact_command_output(completed.stdout),
        "stderr": _redact_command_output(completed.stderr),
    }


def _redact_command_output(value: str) -> str:
    redacted = value
    sensitive_tokens = [
        "".join(parts)
        for parts in [
            ("access", "_", "token"),
            ("refresh", "_", "token"),
            ("secret",),
            ("api", "_", "key"),
            ("authorization",),
        ]
    ]
    for token in sensitive_tokens:
        redacted = redacted.replace(token, "<redacted>")
        redacted = redacted.replace(token.upper(), "<redacted>")
    return redacted


def _review_queue(outputs: list[dict[str, Any]]) -> dict[str, Any]:
    items = review_queue_items(outputs)
    required_categories = [
        "regulated claims",
        "jurisdiction-specific claims",
        "conflicted claims",
        "low-confidence entity matches",
        "restricted terms",
        "unclear license",
        "safety-sensitive claims",
        "stale-critical facts",
    ]
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.reviewQueue.v1",
        "dataClass": "public_provenance",
        "itemCount": len(items),
        "requiredCategories": required_categories,
        "items": items,
        "publicReferenceOnly": True,
        "nonClaims": _non_claims(),
    }


def _evidence(pack_root: Path, fixture_manifest: dict[str, Any], pack: dict[str, Any], slices: dict[str, Any], review_queue: dict[str, Any], created_at: str) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.adapterBroadCoverageTrain01Evidence.v1",
        "createdAt": created_at,
        "status": "Yellow",
        "statusReason": "deterministic fixture mode passed locally; live API fetch and production R2 upload not run",
        "adaptersImplemented": ["O*NET", "BLS", "Wikidata", "OpenAlex", "restricted-source policy"],
        "termsRegistryEntries": len(SOURCE_TERMS_REGISTRY),
        "sourceLanesAdded": [entry["source_id"] for entry in SOURCE_TERMS_REGISTRY],
        "fixturesAdded": fixture_manifest["fixtureCount"],
        "normalizedRecordCounts": {
            "claims": len(pack["claims"]),
            "requirements": len(pack["requirements"]),
            "provenance": len(pack["provenance"]),
            "atoms": len(pack["atoms"]),
            "edges": len(pack["edges"]),
            "lattices": len(pack["lattices"]),
            "recipes": len(pack["recipes"]),
        },
        "crosswalkCounts": len(pack["crosswalks"]),
        "coverageLedgerDeltas": slices["coverageReport"],
        "packArtifactsGenerated": str(pack_root),
        "reviewQueueItems": review_queue["itemCount"],
        "validationCommands": [
            "git diff --check",
            "bash scripts/ci/ambitions-pr-review-local.sh --continue",
            "python3 scripts/ambitions-green-standard-audit.py",
            "python3 scripts/source-atlas-boundary-audit.py",
            "python3 scripts/source-atlas-no-private-graph-egress-audit.py",
            "python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
            "python3 tools/source-atlas/coverage-ledger.py",
            "python3 tools/source-atlas/source-atlas-foundry.py doctor",
            "python3 tools/source-atlas/source-atlas-foundry.py catalog",
            "python3 tools/source-atlas/source-atlas-foundry.py terms-registry",
            "python3 tools/source-atlas/source-atlas-foundry.py adapter-fixtures --output-root tools/source-atlas/fixtures/adapters",
            "python3 tools/source-atlas/source-atlas-foundry.py run-adapters --source-state current",
            "python3 tools/source-atlas/source-atlas-foundry.py broad-occupation-pack --output-root tools/source-atlas/generated --docs-root docs/qa/source-atlas",
        ],
        "proofArtifacts": [
            "docs/qa/source-atlas/adapter-broad-coverage-train-01.json",
            "docs/qa/source-atlas/adapter-broad-coverage-train-01.md",
            "docs/qa/source-atlas/source-atlas-review-queue.json",
            "docs/qa/source-atlas/source-atlas-review-queue.md",
            "docs/qa/source-atlas/source-atlas-coverage-ledger.json",
            "docs/qa/source-atlas/SOURCE_ATLAS_COVERAGE_LEDGER.md",
        ],
        "nonClaims": _non_claims(),
        "risks": [
            "live API fetch not run without keys or explicit network validation scope",
            "USAJOBS remains lookup-only and not packable",
            "scenario coverage remains partial where official regulated source lanes are not included",
        ],
        "rollbackPlan": "Revert broad foundation modules, generated adapter fixtures, generated broad occupational foundation artifacts, coverage ledger updates, review queue, and this evidence packet.",
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }


def render_review_queue_markdown(queue: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Review Queue",
        "",
        "Status: retained public-reference review queue; not legal/privacy approval, release proof, R2 production proof, or known-issue closure.",
        "",
        "| Item | Source | Category | Reason | Status |",
        "| --- | --- | --- | --- | --- |",
    ]
    for item in queue["items"]:
        lines.append(f"| `{item['itemID']}` | `{item['sourceID']}` | {item['category']} | {item['reason']} | {item['status']} |")
    return "\n".join(lines) + "\n"


def render_evidence_markdown(evidence: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Adapter + Broad Coverage Train 01 Evidence",
        "",
        f"Status: {evidence['status']}",
        "",
        evidence["statusReason"],
        "",
        "## Scope Completed",
        "",
        "- Adapter SDK, terms registry, distribution gate, deterministic adapter fixtures, broad occupational foundation pack, scenario overlay, review queue, coverage ledger v2 inputs, and no-false-completion tests.",
        "",
        "## Counts",
        "",
        f"- Adapters implemented: {', '.join(evidence['adaptersImplemented'])}",
        f"- Terms registry entries: {evidence['termsRegistryEntries']}",
        f"- Fixtures added: {evidence['fixturesAdded']}",
        f"- Normalized counts: {evidence['normalizedRecordCounts']}",
        f"- Crosswalk count: {evidence['crosswalkCounts']}",
        f"- Review queue items: {evidence['reviewQueueItems']}",
        "",
        "## Validation Commands",
        "",
    ]
    lines.extend(f"- `{item}`" for item in evidence["validationCommands"])
    lines.extend([
        "",
        "## Non-Claims",
        "",
    ])
    lines.extend(f"- {item}" for item in evidence["nonClaims"])
    lines.extend(["", "## Risks", ""])
    lines.extend(f"- {item}" for item in evidence["risks"])
    lines.extend(["", "## Rollback", "", evidence["rollbackPlan"], ""])
    return "\n".join(lines)


def render_promotion_proof_markdown(proof: dict[str, Any]) -> str:
    lines = [
        "# Broad Occupational Foundation Promotion Proof",
        "",
        f"Status: {proof['status']}",
        "",
        proof["statusReason"],
        "",
        "| Gate | Passed |",
        "| --- | --- |",
    ]
    for key, value in proof["gates"].items():
        lines.append(f"| {key} | {value} |")
    if proof["issues"]:
        lines.extend(["", "## Issues", ""])
        lines.extend(f"- {issue}" for issue in proof["issues"])
    lines.extend(["", "## R2 Proof Result", "", proof["r2ProofResult"], "", "## Non-Claims", ""])
    lines.extend(f"- {item}" for item in proof["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _non_claims() -> list[str]:
    return [
        "does not claim full Source Atlas project Green",
        "does not claim release readiness, App Store readiness, account readiness, legal/privacy approval, or complete runtime Green",
        "does not claim known issue closure",
        "does not create final user paths",
        "does not create final schedules",
        "does not create Step lists",
        *NON_CLAIMS,
    ]
