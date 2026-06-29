from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_review_packets import (
    GoalDomainReviewPacketOptions,
    compile_goal_domain_review_packets,
    write_goal_domain_review_packets_report,
)
from foundry.model import read_json


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
EXECUTOR_MANIFEST = SOURCE_ATLAS_ROOT / "generated" / "goal-domain-work-order-executor" / "train-90-fixture" / "manifest.json"
CREATED_AT = "2026-06-28T00:00:00Z"


def test_goal_domain_review_packets_compile_blocked_review_templates(tmp_path: Path):
    result = compile_goal_domain_review_packets(
        GoalDomainReviewPacketOptions(
            executor_manifest_path=EXECUTOR_MANIFEST,
            output_root=tmp_path / "review-packets",
            reviewer="source-atlas-reviewer",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain review packet template tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; review packet templates only"
    assert result["recordCounts"]["inputExecutionRecords"] == 30
    assert result["recordCounts"]["selectedBlockedReviewRecords"] == 8
    assert result["recordCounts"]["reviewPackets"] == 8
    assert result["recordCounts"]["completedReviewPackets"] == 0
    assert result["recordCounts"]["approvalArtifactsEmitted"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert result["recordCounts"]["finalOutputArtifacts"] == 0

    summary_by_lane = {item["reviewLane"]: item for item in result["reviewSummary"]}
    assert set(summary_by_lane) == {
        "api_governance_review",
        "direct_source_authority_resolution",
        "legal_terms_review",
        "source_lane_governance",
    }
    assert all(item["packetCount"] == 2 for item in summary_by_lane.values())

    artifact = read_json(Path(result["outputPaths"]["reviewPacketReport"]))
    packets = artifact["reviewPackets"]
    assert {packet["stage"] for packet in packets} == {
        "direct_source_resolution",
        "source_lane_review",
        "legal_terms_review",
        "api_governance_review",
    }
    assert {packet["requestID"] for packet in packets} == {
        "ambiguous-public-program-reference",
        "new-language-learning-public-reference",
    }
    assert all(packet["completionStatus"] == "blocked_review_required" for packet in packets)
    assert all(packet["manualReviewRequired"] is True for packet in packets)
    assert all(packet["requiredReviewerFields"] for packet in packets)
    assert all(packet["candidateSourceIDs"] for packet in packets)
    assert all(packet["approvalArtifactEmitted"] is False for packet in packets)
    assert all(packet["registryMutationAllowed"] is False for packet in packets)
    assert all(packet["claimOutputAllowed"] is False for packet in packets)
    assert all(packet["packOutputAllowed"] is False for packet in packets)
    assert all(packet["r2PublishAllowed"] is False for packet in packets)
    assert all(packet["nativeActivationAllowed"] is False for packet in packets)
    assert all(packet["liveAllowed"] is False and packet["executeAllowed"] is False for packet in packets)
    assert "final_user_path" not in json.dumps(artifact)
    assert "personalized_plan" not in json.dumps(artifact)

    checks = {check["name"]: check for check in result["checks"]}
    assert checks["only_blocked_review_required_records_selected"]["passed"]
    assert checks["every_review_packet_requires_manual_review"]["passed"]
    assert checks["review_packets_emit_no_approval_or_registry_mutations"]["passed"]
    assert checks["review_packets_emit_no_claims_packs_r2_or_native_activation"]["passed"]
    assert checks["privacy_scan_passed"]["passed"]


def test_goal_domain_review_packets_report_writer_emits_markdown_and_json(tmp_path: Path):
    markdown_path = tmp_path / "source-atlas-goal-domain-review-packets-train-92.md"
    json_path = tmp_path / "source-atlas-goal-domain-review-packets-train-92.json"

    result = write_goal_domain_review_packets_report(
        markdown_path,
        json_path,
        executor_manifest_path=EXECUTOR_MANIFEST,
        output_root=tmp_path / "review-packets",
        reviewer="source-atlas-reviewer",
        created_at=CREATED_AT,
    )

    assert result["valid"], result["issues"]
    assert markdown_path.exists()
    assert json_path.exists()
    assert "Source Atlas Goal-Domain Review Packets Train 92" in markdown_path.read_text(encoding="utf-8")
    persisted = read_json(json_path)
    assert persisted["recordCounts"]["reviewPackets"] == 8
    assert persisted["recordCounts"]["approvalArtifactsEmitted"] == 0
