"""Source Atlas release proof packet compiler.

This packet reconciles current Source Atlas native/R2 validation inputs with
release-facing proof gates. It is intentionally not a release approval engine:
it can prove that Source Atlas release inputs are current, but it keeps
Release Green and App Store/TestFlight claims blocked unless external proof
artifacts are attached and owner review happens outside Codex.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .boundary import boundary_issue_strings, boundary_issues_for_value
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, read_json, stable_hash, stable_id, write_json


RELEASE_PROOF_PACKET_KIND = "ambitions.sourceAtlas.releaseProofPacket.v1"
RELEASE_PROOF_PACKET_VERSION = "source-atlas-release-proof-packet-train-132"

PASS_VALUES = {"PASS", "PASSED", "GREEN", "SUCCEEDED", "SUCCESS", "OK"}
SOURCE_VALIDATION_GATE_IDS = (
    "source_atlas_pytest",
    "source_atlas_boundary_audit",
    "source_atlas_no_private_graph_egress_audit",
    "ambitions_green_standard_audit",
    "ambitions_local_first_boundary_scan",
    "git_diff_check",
    "xcode_build_for_testing",
    "focused_native_source_atlas_suite",
)
EXTERNAL_RELEASE_GATE_IDS = (
    "physical_device_proof",
    "independent_accessibility_proof",
    "independent_visual_review",
    "app_store_connect_validation",
    "testflight_validation",
    "privacy_legal_release_signoff",
    "owner_release_approval",
)

RELEASE_PROOF_NON_CLAIMS = [
    "Source Atlas release proof packet only",
    "not Release Green",
    "not App Store readiness",
    "not TestFlight readiness",
    "not physical-device proof unless an artifact is attached",
    "not independent accessibility or visual approval unless artifacts are attached",
    "not outside legal approval",
    "not literal universal coverage",
    "not final user plans, schedules, Steps, or personalized paths from Source Atlas/R2",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class SourceAtlasReleaseProofPacketOptions:
    native_runtime_report_path: Path
    output_root: Path
    build_summary_path: Path | None = None
    source_atlas_pytest_result: str = "NOT_RUN"
    source_atlas_pytest_passed: int = 0
    source_atlas_pytest_failed: int = 0
    boundary_audit_result: str = "NOT_RUN"
    no_private_egress_result: str = "NOT_RUN"
    green_standard_result: str = "NOT_RUN"
    local_first_result: str = "NOT_RUN"
    git_diff_check_result: str = "NOT_RUN"
    build_for_testing_result: str = "NOT_RUN"
    focused_native_result: str = "NOT_RUN"
    focused_native_passed: int = 0
    focused_native_failed: int = 0
    focused_native_skipped: int = 0
    physical_device_proof_path: Path | None = None
    accessibility_proof_path: Path | None = None
    visual_review_proof_path: Path | None = None
    app_store_connect_proof_path: Path | None = None
    testflight_proof_path: Path | None = None
    privacy_legal_release_signoff_path: Path | None = None
    owner_release_approval_path: Path | None = None
    created_at: str = "2026-06-29T05:15:00Z"
    run_label: str = "current"
    branch: str | None = None
    commit_sha: str | None = None
    environment: str | None = None


def run_source_atlas_release_proof_packet(options: SourceAtlasReleaseProofPacketOptions) -> dict[str, Any]:
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    issues: list[str] = []
    native_runtime = _read_required_json(options.native_runtime_report_path, "native runtime report", issues)
    build_summary = _read_optional_json(options.build_summary_path, "build-for-testing summary", issues)
    external_artifacts = _external_artifacts(options, issues)
    source_gates = _source_validation_gates(options, native_runtime, build_summary)
    external_gates = _external_release_gates(external_artifacts)

    privacy_view = {
        "runLabel": options.run_label,
        "branch": options.branch,
        "sourceGates": source_gates,
        "externalGates": external_gates,
        "nativeRuntimePath": str(options.native_runtime_report_path),
        "buildSummaryPath": str(options.build_summary_path) if options.build_summary_path else None,
    }
    privacy_issues = boundary_issue_strings(
        boundary_issues_for_value(privacy_view, "source-atlas-release-proof-packet")
    )
    source_inputs_ready = all(gate["passed"] for gate in source_gates)
    release_review_ready = source_inputs_ready and all(gate["artifactPresent"] for gate in external_gates)
    release_green_claim_allowed = False

    checks = [
        _check("native_runtime_report_loaded", isinstance(native_runtime, dict), ["native runtime report missing or unreadable"]),
        _check("source_validation_gates_passed", source_inputs_ready, [gate["gateID"] for gate in source_gates if not gate["passed"]]),
        _check("external_release_artifacts_attached", release_review_ready, [gate["gateID"] for gate in external_gates if not gate["artifactPresent"]], severity="yellow"),
        _check("privacy_boundary_scan_passed", not privacy_issues, privacy_issues, severity="red"),
        _check("release_green_not_self_certified", not release_green_claim_allowed, [], severity="red"),
    ]
    issues.extend(privacy_issues)
    issues.extend(issue for check in checks if not check["passed"] and check["severity"] == "red" for issue in check["issues"])
    valid = not privacy_issues and isinstance(native_runtime, dict) and source_inputs_ready

    missing_external = [gate["gateID"] for gate in external_gates if not gate["artifactPresent"]]
    record_counts = {
        "sourceValidationGates": len(source_gates),
        "sourceValidationGatesPassed": sum(1 for gate in source_gates if gate["passed"]),
        "externalReleaseGates": len(external_gates),
        "externalReleaseArtifactsPresent": sum(1 for gate in external_gates if gate["artifactPresent"]),
        "missingExternalReleaseArtifacts": len(missing_external),
        "sourceAtlasPytestPassed": options.source_atlas_pytest_passed,
        "sourceAtlasPytestFailed": options.source_atlas_pytest_failed,
        "focusedNativePassed": options.focused_native_passed,
        "focusedNativeFailed": options.focused_native_failed,
        "focusedNativeSkipped": options.focused_native_skipped,
        "privacyIssues": len(privacy_issues),
    }
    report_path = output_root / "source-atlas-release-proof-packet-report.json"
    markdown_path = output_root / "source-atlas-release-proof-packet-report.md"
    closeout_path = output_root / "closeout.md"
    report = {
        "schemaVersion": 1,
        "kind": RELEASE_PROOF_PACKET_KIND,
        "versionID": RELEASE_PROOF_PACKET_VERSION,
        "createdAt": options.created_at,
        "runLabel": options.run_label,
        "packetID": stable_id(
            "source_atlas.release_proof_packet",
            {
                "createdAt": options.created_at,
                "runLabel": options.run_label,
                "sourceGates": source_gates,
                "externalGates": external_gates,
            },
        ),
        "status": (
            "Source Green for Source Atlas release-input proof packet / Yellow release ceiling"
            if valid
            else "Red: Source Atlas release-input proof packet failed required source gates"
        ),
        "valid": valid,
        "overallReadinessStatus": (
            "source_atlas_release_inputs_current_external_release_gates_missing"
            if valid and not release_review_ready
            else "source_atlas_release_review_packet_ready_owner_external_review_required"
            if valid
            else "source_atlas_release_inputs_blocked"
        ),
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; release approval remains external/human-gated",
        "sourceAtlasReleaseInputsReady": source_inputs_ready,
        "releaseReviewPacketReady": release_review_ready,
        "releaseGreenClaimAllowed": release_green_claim_allowed,
        "releaseGreenClaimBlockedReason": "Codex cannot self-certify Release Green; external device/accessibility/visual/App Store/TestFlight/owner approval proof is required.",
        "sourceValidationGates": source_gates,
        "externalReleaseGates": external_gates,
        "missingExternalReleaseGateIDs": missing_external,
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "allowedClaims": _allowed_claims(valid, release_review_ready),
        "blockedClaims": _blocked_claims(),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "privacyIssues": privacy_issues,
        "productLaw": {
            "r2Role": "public/reference/freshness infrastructure only",
            "privateContextEgressAllowed": False,
            "finalPersonalizedOutputsAllowed": False,
            "sourceAtlasProductCenterAllowed": False,
            "releaseGreenSelfCertificationAllowed": False,
        },
        "evidencePaths": {
            "nativeRuntimeReport": str(options.native_runtime_report_path),
            "buildSummary": str(options.build_summary_path) if options.build_summary_path else None,
            **{gate["gateID"]: gate.get("artifactPath") for gate in external_gates},
        },
        "branch": options.branch,
        "commitSHA": options.commit_sha,
        "environment": options.environment,
        "nonClaims": RELEASE_PROOF_NON_CLAIMS,
        "outputPaths": {
            "report": str(report_path),
            "markdown": str(markdown_path),
            "closeout": str(closeout_path),
        },
    }
    report["outputHashes"] = {"reportPayload": stable_hash({key: value for key, value in report.items() if key != "outputHashes"})}
    write_json(report_path, report)
    report["outputHashes"]["report"] = stable_hash(read_json(report_path))
    write_json(report_path, report)
    markdown = source_atlas_release_proof_packet_markdown(report)
    markdown_path.write_text(markdown, encoding="utf-8")
    closeout_path.write_text(markdown, encoding="utf-8")
    return report


def source_atlas_release_proof_packet_markdown(report: dict[str, Any]) -> str:
    counts = report["recordCounts"]
    lines = [
        "# Source Atlas Release Proof Packet Train 132",
        "",
        f"Status: {report['status']}",
        f"Overall readiness: {report['overallReadinessStatus']}",
        f"Source Atlas release inputs ready: {str(report['sourceAtlasReleaseInputsReady']).lower()}",
        f"Release review packet ready: {str(report['releaseReviewPacketReady']).lower()}",
        f"Release Green claim allowed: {str(report['releaseGreenClaimAllowed']).lower()}",
        "",
        "Scope completed:",
        "- Reconciled current Source Atlas native runtime proof, Python validation, privacy/boundary scans, git diff check, focused native suite, and build-for-testing evidence.",
        "- Emitted explicit external release gate state for physical-device, accessibility, visual, App Store, TestFlight, privacy/legal signoff, and owner approval artifacts.",
        "- Preserved the no self-certified Release Green boundary.",
        "",
        "Counts:",
        f"- Source validation gates: {counts['sourceValidationGatesPassed']}/{counts['sourceValidationGates']}",
        f"- External release artifacts present: {counts['externalReleaseArtifactsPresent']}/{counts['externalReleaseGates']}",
        f"- Missing external release artifacts: {counts['missingExternalReleaseArtifacts']}",
        f"- Source Atlas pytest passed/failed: {counts['sourceAtlasPytestPassed']}/{counts['sourceAtlasPytestFailed']}",
        f"- Focused native passed/failed/skipped: {counts['focusedNativePassed']}/{counts['focusedNativeFailed']}/{counts['focusedNativeSkipped']}",
        f"- Privacy issues: {counts['privacyIssues']}",
        "",
        "Source validation gates:",
        "",
        "| Gate | Passed | Evidence |",
        "| --- | --- | --- |",
    ]
    for gate in report.get("sourceValidationGates", []):
        lines.append(f"| `{gate['gateID']}` | {str(gate['passed']).lower()} | {gate.get('evidence') or 'none'} |")
    lines.extend(["", "External release gates:", "", "| Gate | Artifact Present | Artifact |", "| --- | --- | --- |"])
    for gate in report.get("externalReleaseGates", []):
        lines.append(
            f"| `{gate['gateID']}` | {str(gate['artifactPresent']).lower()} | {gate.get('artifactPath') or 'missing'} |"
        )
    lines.extend(["", "Allowed claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("allowedClaims", [])) if report.get("allowedClaims") else lines.append("- None")
    lines.extend(["", "Blocked claims:"])
    lines.extend(f"- `{claim}`" for claim in report.get("blockedClaims", []))
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in report.get("nonClaims", []))
    lines.extend(
        [
            "",
            "Product law preserved:",
            "- R2 remains public/reference/freshness infrastructure only.",
            "- This packet reads proof artifacts only; it does not run a live harvest, publish R2 objects, deploy Workers, or mutate native runtime state.",
            "- No final plans, schedules, Steps, priority order, recovery paths, or personalized paths are generated.",
            "",
            "Rollback plan:",
            "- Revert the Train 132 proof-packet module, CLI wiring, tests, generated artifacts, and QA evidence.",
            "- Continue using completion audit release gaps directly if the packet regresses.",
            "",
        ]
    )
    return "\n".join(lines)


def _source_validation_gates(options: SourceAtlasReleaseProofPacketOptions, native: Any, build_summary: Any) -> list[dict[str, Any]]:
    xcode = native.get("xcodeBuildMCP", {}) if isinstance(native, dict) else {}
    native_valid = (
        isinstance(native, dict)
        and native.get("valid") is True
        and isinstance(xcode, dict)
        and xcode.get("result") == "SUCCEEDED"
        and int(xcode.get("failed") or 0) == 0
    )
    return [
        _source_gate("source_atlas_pytest", _passed(options.source_atlas_pytest_result) and options.source_atlas_pytest_failed == 0, f"{options.source_atlas_pytest_passed} passed / {options.source_atlas_pytest_failed} failed"),
        _source_gate("source_atlas_boundary_audit", _passed(options.boundary_audit_result), options.boundary_audit_result),
        _source_gate("source_atlas_no_private_graph_egress_audit", _passed(options.no_private_egress_result), options.no_private_egress_result),
        _source_gate("ambitions_green_standard_audit", _passed(options.green_standard_result), options.green_standard_result),
        _source_gate("ambitions_local_first_boundary_scan", _passed(options.local_first_result), options.local_first_result),
        _source_gate("git_diff_check", _passed(options.git_diff_check_result), options.git_diff_check_result),
        _source_gate(
            "xcode_build_for_testing",
            _passed(options.build_for_testing_result) and (build_summary is not None or options.build_summary_path is None),
            str(options.build_summary_path) if options.build_summary_path else options.build_for_testing_result,
        ),
        _source_gate(
            "focused_native_source_atlas_suite",
            _passed(options.focused_native_result) and options.focused_native_failed == 0 and native_valid,
            f"{options.focused_native_passed} passed / {options.focused_native_failed} failed / {options.focused_native_skipped} skipped",
        ),
    ]


def _external_release_gates(artifacts: dict[str, Any]) -> list[dict[str, Any]]:
    labels = {
        "physical_device_proof": "physical-device proof",
        "independent_accessibility_proof": "independent accessibility proof",
        "independent_visual_review": "independent visual review",
        "app_store_connect_validation": "App Store Connect validation",
        "testflight_validation": "TestFlight validation",
        "privacy_legal_release_signoff": "privacy/legal release signoff",
        "owner_release_approval": "owner release approval",
    }
    return [
        {
            "gateID": gate_id,
            "label": labels[gate_id],
            "artifactPresent": artifacts.get(gate_id) is not None,
            "artifactPath": artifacts.get(gate_id, {}).get("path") if isinstance(artifacts.get(gate_id), dict) else None,
            "artifactHash": artifacts.get(gate_id, {}).get("sha256") if isinstance(artifacts.get(gate_id), dict) else None,
        }
        for gate_id in EXTERNAL_RELEASE_GATE_IDS
    ]


def _external_artifacts(options: SourceAtlasReleaseProofPacketOptions, issues: list[str]) -> dict[str, Any]:
    paths = {
        "physical_device_proof": options.physical_device_proof_path,
        "independent_accessibility_proof": options.accessibility_proof_path,
        "independent_visual_review": options.visual_review_proof_path,
        "app_store_connect_validation": options.app_store_connect_proof_path,
        "testflight_validation": options.testflight_proof_path,
        "privacy_legal_release_signoff": options.privacy_legal_release_signoff_path,
        "owner_release_approval": options.owner_release_approval_path,
    }
    return {gate_id: _artifact_reference(path, gate_id, issues) for gate_id, path in paths.items()}


def _artifact_reference(path: Path | None, label: str, issues: list[str]) -> dict[str, Any] | None:
    if path is None:
        return None
    if not path.exists():
        issues.append(f"{label} artifact missing: {path}")
        return None
    if path.is_file():
        return {"path": str(path), "sha256": stable_hash(path.read_text(encoding="utf-8", errors="replace"))}
    return {"path": str(path), "sha256": stable_hash(sorted(str(child.relative_to(path)) for child in path.rglob("*") if child.is_file()))}


def _source_gate(gate_id: str, passed: bool, evidence: str) -> dict[str, Any]:
    return {"gateID": gate_id, "passed": bool(passed), "evidence": evidence}


def _passed(value: str | None) -> bool:
    return str(value or "").strip().upper() in PASS_VALUES


def _check(name: str, passed: bool, issues: list[str], severity: str = "red") -> dict[str, Any]:
    return {"name": name, "passed": passed, "issues": issues if not passed else [], "severity": severity}


def _allowed_claims(valid: bool, release_review_ready: bool) -> list[str]:
    if not valid:
        return []
    claims = [
        "source_atlas_release_proof_packet_green",
        "source_atlas_release_inputs_current",
        "release_overclaim_blocked",
    ]
    if release_review_ready:
        claims.append("source_atlas_release_review_packet_ready_for_owner_review")
    return claims


def _blocked_claims() -> list[str]:
    return sorted(
        {
            "release_green",
            "runtime_release_green",
            "app_store_readiness",
            "testflight_readiness",
            "native_device_green",
            "independent_accessibility_green",
            "outside_legal_approval",
            "literal_universal_coverage",
            "full_source_atlas_green",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        }
    )


def _read_required_json(path: Path, label: str, issues: list[str]) -> Any:
    try:
        return read_json(path)
    except FileNotFoundError:
        issues.append(f"{label} missing: {path}")
    except Exception as exc:  # pragma: no cover - defensive for malformed operator input
        issues.append(f"{label} unreadable: {path}: {exc}")
    return None


def _read_optional_json(path: Path | None, label: str, issues: list[str]) -> Any:
    if path is None:
        return None
    try:
        return read_json(path)
    except FileNotFoundError:
        issues.append(f"optional {label} missing: {path}")
    except Exception as exc:  # pragma: no cover - defensive for malformed operator input
        issues.append(f"optional {label} unreadable: {path}: {exc}")
    return None
