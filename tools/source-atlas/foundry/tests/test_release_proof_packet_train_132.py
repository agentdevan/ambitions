from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.model import write_json  # noqa: E402
from foundry.release_proof_packet import (  # noqa: E402
    SourceAtlasReleaseProofPacketOptions,
    run_source_atlas_release_proof_packet,
)


CREATED_AT = "2026-06-29T05:15:00Z"


def test_release_proof_packet_proves_source_inputs_without_release_green(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["sourceAtlasReleaseInputsReady"] is True
    assert result["releaseReviewPacketReady"] is False
    assert result["releaseGreenClaimAllowed"] is False
    assert "source_atlas_release_inputs_current" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert result["recordCounts"]["sourceValidationGatesPassed"] == result["recordCounts"]["sourceValidationGates"]
    assert result["recordCounts"]["missingExternalReleaseArtifacts"] == 7
    assert "physical_device_proof" in result["missingExternalReleaseGateIDs"]
    assert result["privacyIssues"] == []


def test_release_proof_packet_can_be_ready_for_owner_review_but_still_not_self_certify_release_green(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    external = _external_artifacts(tmp_path)

    result = _run(tmp_path, paths, **external)

    assert result["valid"], result["issues"]
    assert result["releaseReviewPacketReady"] is True
    assert result["releaseGreenClaimAllowed"] is False
    assert "source_atlas_release_review_packet_ready_for_owner_review" in result["allowedClaims"]
    assert result["missingExternalReleaseGateIDs"] == []
    assert "app_store_readiness" in result["blockedClaims"]


def test_release_proof_packet_blocks_failed_source_validation(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(
        tmp_path,
        paths,
        source_atlas_pytest_result="FAIL",
        source_atlas_pytest_passed=501,
        source_atlas_pytest_failed=1,
    )

    assert not result["valid"]
    assert result["sourceAtlasReleaseInputsReady"] is False
    assert any(gate["gateID"] == "source_atlas_pytest" and gate["passed"] is False for gate in result["sourceValidationGates"])
    assert result["allowedClaims"] == []


def _run(tmp_path: Path, paths: dict[str, Path], **overrides: object) -> dict:
    defaults = {
        "source_atlas_pytest_result": "PASS",
        "source_atlas_pytest_passed": 502,
        "source_atlas_pytest_failed": 0,
        "boundary_audit_result": "PASS",
        "no_private_egress_result": "PASS",
        "green_standard_result": "GREEN",
        "local_first_result": "GREEN",
        "git_diff_check_result": "PASS",
        "build_for_testing_result": "PASSED",
        "focused_native_result": "SUCCEEDED",
        "focused_native_passed": 72,
        "focused_native_failed": 0,
        "focused_native_skipped": 0,
    }
    defaults.update(overrides)
    return run_source_atlas_release_proof_packet(
        SourceAtlasReleaseProofPacketOptions(
            native_runtime_report_path=paths["native"],
            build_summary_path=paths["build_summary"],
            output_root=tmp_path / f"release-proof-{len(list(tmp_path.glob('release-proof-*')))}",
            created_at=CREATED_AT,
            run_label="test-release-proof",
            branch="main",
            commit_sha="abcdef123456",
            environment="local-test",
            **defaults,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    native = root / "native-runtime.json"
    build_summary = root / "build-summary.json"
    write_json(
        native,
        {
            "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
            "valid": True,
            "status": "Native Runtime Green for configured Source Atlas public-pack runtime / Yellow overall Source Atlas",
            "xcodeBuildMCP": {"result": "SUCCEEDED", "passed": 72, "failed": 0, "skipped": 0},
            "proofSummary": {
                "r2RequestPrivacyProof": "Public manifest/object requests contain public object keys only.",
                "noPrivateGraphEgressProof": "No private graph fields leave the local boundary.",
                "lkgRollbackProof": "LKG fallback works without blocking local planning.",
                "nativeOfflineNoAccountProof": "Offline/no-account focused suite passed.",
            },
            "privacyIssues": [],
            "issues": [],
        },
    )
    write_json(
        build_summary,
        {
            "result_bundle": ".codex/xcode-results/test/build-for-testing.xcresult",
            "logs": ".codex/xcode-summaries/test/logs",
        },
    )
    return {"native": native, "build_summary": build_summary}


def _external_artifacts(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "external"
    root.mkdir(parents=True, exist_ok=True)
    paths = {
        "physical_device_proof_path": root / "physical-device-proof.json",
        "accessibility_proof_path": root / "accessibility-proof.json",
        "visual_review_proof_path": root / "visual-review-proof.json",
        "app_store_connect_proof_path": root / "app-store-connect-proof.json",
        "testflight_proof_path": root / "testflight-proof.json",
        "privacy_legal_release_signoff_path": root / "privacy-legal-release-signoff.json",
        "owner_release_approval_path": root / "owner-release-approval.json",
    }
    for name, path in paths.items():
        write_json(path, {"kind": f"test.{name}", "status": "attached", "valid": True})
    return paths
