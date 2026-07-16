from __future__ import annotations

import hashlib
import json
import re
import unittest
from dataclasses import replace
from pathlib import Path

from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.visual_authority import (
    load_visual_authority_rebaseline,
    select_visual_authority,
    validate_visual_authority_payload,
)


ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "docs/canon/migration/visual-authority-rebaseline.json"
HAND_RECORD = ROOT / "docs/canon/migration/VISUAL_AUTHORITY_REBASELINE.md"
R1_NODE_SNAPSHOT = (
    ROOT / "docs/canon/migration/visual-authority-r1-node-snapshot.json"
)


R1_TASK_PACK_TARGETS = {
    "VA-P4-A11Y-CLASS-001": "270:1430",
    "VA-P4-A11Y-CLASS-002": "296:60",
    "VA-P4-A11Y-CLASS-003": "296:84",
    "VA-P4-A11Y-CLASS-004": "327:1603",
    "VA-P4-A11Y-CLASS-005": "329:1635",
    "VA-P4-A11Y-CLASS-006": "327:1648",
    "VA-P4-CANDIDATE-001": "266:1424",
    "VA-P4-CANDIDATE-002": "266:1709",
    "VA-P4-CANDIDATE-003": "272:1424",
    "VA-P4-CANDIDATE-004": "275:1424",
    "VA-P4-CANDIDATE-005": "278:1449",
    "VA-P4-CANDIDATE-006": "281:1465",
    "VA-P4-CANDIDATE-007": "288:41",
    "VA-P4-CANDIDATE-008": "288:156",
    "VA-P4-CANDIDATE-009": "293:23",
    "VA-P4-CANDIDATE-010": "293:141",
    "VA-P4-CANDIDATE-011": "293:164",
    "VA-P4-CANDIDATE-012": "293:83",
}


class VisualAuthorityRebaselineTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.snapshot = load_visual_authority_rebaseline(ROOT)

    def test_frozen_rebaseline_resolves_exact_canon_and_coverage(self) -> None:
        snapshot = self.snapshot

        self.assertEqual(snapshot.canon_revision, 1)
        self.assertEqual(
            snapshot.canon_source_sha,
            "ffd462ab52c0eff798071333388a051d9f3e55f3",
        )
        self.assertEqual(
            snapshot.canon_content_sha,
            "6e836710d8ed26bae3f01f5207438ebba67831b0f90cc7bded7a6368ecb51f67",
        )
        self.assertEqual(snapshot.figma_file_key, "Oik7612LSTUHWsNRFoTlTJ")
        self.assertEqual(snapshot.authority_node_count, 147)
        self.assertEqual(snapshot.screen_count, 47)
        self.assertEqual(len(snapshot.visual_requirement_ids), 336)
        self.assertEqual(len(snapshot.eligible_state_ids), 411)
        self.assertEqual(len(snapshot.future_state_ids), 22)
        self.assertEqual(len(snapshot.gap_blocked_state_ids), 0)
        self.assertEqual(snapshot.legacy_node_count, 15)
        self.assertEqual(snapshot.destructive_actions, ())

    def test_r1_node_snapshot_binds_live_targets_and_shell_contract_without_destruction(self) -> None:
        node_snapshot = json.loads(R1_NODE_SNAPSHOT.read_text(encoding="utf-8"))
        self.assertEqual(node_snapshot["schema_version"], 1)
        self.assertEqual(node_snapshot["file_key"], "Oik7612LSTUHWsNRFoTlTJ")
        self.assertEqual(node_snapshot["page_id"], "215:2")
        self.assertEqual(node_snapshot["authority_state"], "candidate_shadow")
        self.assertEqual(node_snapshot["deleted_node_ids"], [])
        self.assertEqual(node_snapshot["destructive_actions"], [])
        self.assertEqual(
            node_snapshot["figma_write_receipt"],
            {
                "created_node_count": 77,
                "mutated_node_count": 92,
                "deleted_node_ids": [],
                "destructive_actions": [],
            },
        )
        self.assertEqual(
            {
                item["visual_authority_id"]: item["node_id"]
                for item in node_snapshot["task_pack_targets"]
            },
            R1_TASK_PACK_TARGETS,
        )

        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        manifest_targets = {
            item["visual_authority_id"]: item["node_id"]
            for item in manifest["figma"]["authority_nodes"]
            if item["visual_authority_id"] in R1_TASK_PACK_TARGETS
        }
        self.assertEqual(manifest_targets, R1_TASK_PACK_TARGETS)
        self.assertTrue(
            all(
                item["page_id"] == "215:2"
                and item["page_name"] == "CANDIDATE — AV1 · Revision 1"
                and item["frame_version"] == "R1"
                for item in manifest["figma"]["authority_nodes"]
                if item["visual_authority_id"] in R1_TASK_PACK_TARGETS
            )
        )

        viewport_proofs = {
            item["visual_authority_id"]: item["artifacts"]["viewport"]
            for item in manifest["candidate_proofs"]
        }
        snapshot_targets = {
            item["visual_authority_id"]: item
            for item in node_snapshot["task_pack_targets"]
        }
        self.assertEqual(set(viewport_proofs), set(R1_TASK_PACK_TARGETS))
        self.assertTrue(
            all(
                viewport_proofs[authority_id]["node_id"] == target["node_id"]
                and viewport_proofs[authority_id]["path"]
                == target["screenshot_path"]
                and viewport_proofs[authority_id]["sha256"]
                == target["screenshot_sha256"]
                for authority_id, target in snapshot_targets.items()
            )
        )

        roots = {item["frame_id"]: item for item in node_snapshot["root_shell_frames"]}
        expected_roots = {
            "266:1424",
            "266:1486",
            "266:1547",
            "266:1608",
            "266:1669",
            "266:1709",
            "270:1430",
            "272:1424",
            "275:1424",
            "275:1442",
            "275:1460",
            "275:1478",
            "275:1496",
            "278:1449",
        }
        self.assertEqual(set(roots), expected_roots)
        self.assertTrue(
            all(
                item["root_dock_count"] == 1
                and item["search_count"] == 1
                and item["capture_count"] == 1
                and item["bottom_clearance"] >= item["dock_height"]
                for item in roots.values()
            )
        )

        replacement = node_snapshot["pixel_equivalent_replacements"][0]
        self.assertEqual(replacement["frame_id"], "270:1430")
        self.assertEqual(replacement["visible_search_node_ids"], ["359:243"])
        self.assertEqual(replacement["visible_capture_node_ids"], ["359:248"])
        self.assertEqual(
            replacement["old_hidden_node_ids"],
            ["354:2517", "354:2518", "354:2522", "354:2523"],
        )
        self.assertEqual(
            replacement["replacement_node_ids"],
            ["359:242", "359:243", "359:247", "359:248"],
        )
        self.assertTrue(replacement["pixel_equivalent"])
        self.assertTrue(replacement["non_destructive"])
        self.assertEqual(
            replacement["render_proof"],
            {
                "path": (
                    "docs/qa/evidence/2026-07-16-canon-visual-authority-"
                    "r1-shell-repair/screens/task-pack/"
                    "va-p4-a11y-class-001-viewport.png"
                ),
                "sha256": (
                    "311374645649f6bdd851b9e34783599847c94b76d6862d0dbb2d67a473260376"
                ),
            },
        )

        drilldowns = {
            item["frame_id"]: item
            for item in node_snapshot["drilldown_shell_frames"]
        }
        self.assertEqual(
            set(drilldowns),
            {
                "272:1428",
                "272:1432",
                "272:1436",
                "278:1453",
                "278:1457",
                "278:1461",
                "278:1465",
            },
        )
        self.assertTrue(
            all(
                item["root_dock_count"] == 0
                and item["search_count"] == 0
                and item["capture_count"] == 0
                and item["back_count"] == 1
                for item in drilldowns.values()
            )
        )

        metadata = {
            item["visual_authority_id"]: item
            for item in node_snapshot["authority_metadata"]
        }
        self.assertTrue(set(R1_TASK_PACK_TARGETS).issubset(metadata))
        self.assertTrue(
            all(
                item["owner_approval_state"]
                == "candidate_pending_independent_review"
                and item["implementation_status"]
                == "design_authority_candidate_not_source_implementation"
                and item["proof_ceiling"]
                == "visual_design_authority_candidate_only"
                and item["task_pack_eligibility"] == "blocked_until_gate_b_green"
                for item in metadata.values()
            )
        )

    def test_canon_freshness_refresh_changes_only_the_148_sha_bindings(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        expected_sha = payload["canon"]["content_sha"]
        nodes = payload["figma"]["authority_nodes"]

        self.assertEqual(len(nodes), 147)
        self.assertTrue(
            all(node["canon_content_sha"] == expected_sha for node in nodes)
        )
        normalized = json.loads(json.dumps(payload))
        normalized["canon"]["content_sha"] = "<CANON_CONTENT_SHA>"
        for node in normalized["figma"]["authority_nodes"]:
            node["canon_content_sha"] = "<CANON_CONTENT_SHA>"
        non_hash_digest = hashlib.sha256(
            json.dumps(
                normalized,
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            ).encode("utf-8")
        ).hexdigest()
        self.assertEqual(
            non_hash_digest,
            "fc4fcac9f188a5e479e0a5565bd63eb41d1a436569dfad4e22eb8e48d7556df4",
        )

    def test_hand_record_matches_machine_canon_and_coverage_digest(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        hand_record = HAND_RECORD.read_text(encoding="utf-8")

        def groups(pattern: str) -> tuple[int, ...]:
            match = re.search(pattern, hand_record, re.MULTILINE)
            self.assertIsNotNone(match, pattern)
            assert match is not None
            return tuple(int(value) for value in match.groups())

        hand_sha_match = re.search(
            r"^- Canon content SHA: `([0-9a-f]{64})`$",
            hand_record,
            re.MULTILINE,
        )
        self.assertIsNotNone(hand_sha_match)
        assert hand_sha_match is not None

        visual_mapped, visual_total = groups(
            r"^- Visual requirements mapped: `(\d+)/(\d+)`$"
        )
        states_mapped, states_total = groups(r"^- State mappings: `(\d+)/(\d+)`$")
        hand_counts = {
            "authority_nodes": groups(r"^- Exact authority nodes: `(\d+)`$")[0],
            "cross_cutting": groups(r"^- Cross-cutting records: `(\d+)`$")[0],
            "eligible_states": groups(
                r"^- Authority-eligible states after Gate B: `(\d+)`$"
            )[0],
            "future_states": groups(r"^- Future-gated states: `(\d+)`$")[0],
            "gap_blocked_states": groups(r"^- Gap-blocked states: `(\d+)`$")[0],
            "journeys": groups(r"^- Principal journeys: `(\d+)`$")[0],
            "objects": groups(r"^- Canonical object records: `(\d+)`$")[0],
            "screens": groups(r"^- Candidate screen mappings: `(\d+)`$")[0],
            "sensitive_channels": groups(
                r"^- Sensitive exposure channels: `(\d+)`$"
            )[0],
            "states_mapped": states_mapped,
            "states_total": states_total,
            "visual_requirements_mapped": visual_mapped,
            "visual_requirements_total": visual_total,
        }
        coverage = payload["coverage"]
        state_posture = payload["state_posture"]
        machine_counts = {
            "authority_nodes": len(payload["figma"]["authority_nodes"]),
            "cross_cutting": coverage["cross_cutting_count"],
            "eligible_states": len(state_posture["eligible_state_ids"]),
            "future_states": len(state_posture["future_state_ids"]),
            "gap_blocked_states": len(state_posture["gap_blocked_state_ids"]),
            "journeys": coverage["journey_count"],
            "objects": coverage["object_count"],
            "screens": coverage["screen_count"],
            "sensitive_channels": coverage["sensitive_exposure_channel_count"],
            "states_mapped": coverage["state_count"],
            "states_total": sum(
                len(state_posture[key])
                for key in (
                    "eligible_state_ids",
                    "future_state_ids",
                    "gap_blocked_state_ids",
                )
            ),
            "visual_requirements_mapped": coverage["visual_requirement_count"],
            "visual_requirements_total": len(coverage["visual_requirement_ids"]),
        }
        hand_count_digest = hashlib.sha256(
            json.dumps(hand_counts, sort_keys=True, separators=(",", ":")).encode()
        ).hexdigest()
        machine_count_digest = hashlib.sha256(
            json.dumps(machine_counts, sort_keys=True, separators=(",", ":")).encode()
        ).hexdigest()

        self.assertEqual(
            (hand_sha_match.group(1), hand_count_digest),
            (payload["canon"]["content_sha"], machine_count_digest),
        )

    def test_pending_gate_b_cannot_select_candidate_authority(self) -> None:
        with self.assertRaises(CanonError) as raised:
            select_visual_authority(
                self.snapshot,
                scope_ids=("UX-SCREEN-TODAY-START-HERE",),
                requirement_ids=("SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",),
            )

        self.assertEqual(raised.exception.code, "VISUAL_AUTHORITY_GATE_B_NOT_GREEN")

    def test_green_gate_selects_only_new_exact_authority(self) -> None:
        green = replace(self.snapshot, gate_b_state="green")

        selected = select_visual_authority(
            green,
            scope_ids=(
                "UX-SCREEN-TODAY-START-HERE",
                "UX-STATE-VARIANT-TODAY-START-HERE-ACTIVE-EXECUTION",
            ),
            requirement_ids=("SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",),
        )

        self.assertTrue(any("VA-P4-CANDIDATE-002" in item for item in selected))
        self.assertTrue(
            any(
                "figma:Oik7612LSTUHWsNRFoTlTJ:266:1709" in item
                for item in selected
            )
        )
        self.assertFalse(any("SWtHm9ouHTPbEFfNrrtZwv" in item for item in selected))

    def test_future_and_stale_canon_fail_closed(self) -> None:
        green = replace(self.snapshot, gate_b_state="green")
        cases = (
            (
                ("UX-STATE-VARIANT-TIME-DEGRADED-SYNC-PENDING",),
                green.canon_content_sha,
                "VISUAL_AUTHORITY_FUTURE_GATED",
            ),
            (
                ("UX-SCREEN-TODAY-START-HERE",),
                "0" * 64,
                "VISUAL_AUTHORITY_CANON_STALE",
            ),
        )
        for scope_ids, canon_content_sha, code in cases:
            with self.subTest(code=code):
                with self.assertRaises(CanonError) as raised:
                    select_visual_authority(
                        green,
                        scope_ids=scope_ids,
                        requirement_ids=(),
                        canon_revision=green.canon_revision,
                        canon_content_sha=canon_content_sha,
                    )
                self.assertEqual(raised.exception.code, code)

    def test_former_gap_state_selects_only_after_structured_ownership(self) -> None:
        green = replace(self.snapshot, gate_b_state="green")
        selected = select_visual_authority(
            green,
            scope_ids=("UX-STATE-VARIANT-ACCOUNT-BOUNDARY-LOCAL-ONLY",),
            requirement_ids=("APP-ACCOUNT-COMMAND-CONTRACT-001",),
        )
        self.assertTrue(any("VA-P4-CANDIDATE-009" in item for item in selected))

    def test_mixed_or_incomplete_screen_requires_exact_eligible_state_scope(self) -> None:
        green = replace(self.snapshot, gate_b_state="green")
        broad_cases = (
            (
                ("UX-SCREEN-TIME-DEGRADED",),
                (),
            ),
            (
                (),
                ("SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001",),
            ),
            (
                ("UX-SCREEN-ACCOUNT-BOUNDARY",),
                (),
            ),
        )
        for scope_ids, requirement_ids in broad_cases:
            with self.subTest(scope_ids=scope_ids, requirement_ids=requirement_ids):
                with self.assertRaises(CanonError) as raised:
                    select_visual_authority(
                        green,
                        scope_ids=scope_ids,
                        requirement_ids=requirement_ids,
                    )
                self.assertEqual(
                    raised.exception.code,
                    "VISUAL_AUTHORITY_SCOPE_TOO_BROAD",
                )

        selected = select_visual_authority(
            green,
            scope_ids=("UX-STATE-VARIANT-TIME-DEGRADED-OFFLINE-HEALTHY",),
            requirement_ids=("SPEC-SURFACE-TIME-DEGRADED-COMMAND-CONTRACT-001",),
        )
        self.assertTrue(any("VA-P4-CANDIDATE-004" in item for item in selected))

    def test_invalid_fixture_mutations_have_stable_fail_closed_codes(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        fixtures = sorted(
            (ROOT / "tests/canon/fixtures/visual-authority-rebaseline-invalid").glob(
                "*.json"
            )
        )
        self.assertGreaterEqual(len(fixtures), 4)
        for fixture_path in fixtures:
            fixture = json.loads(fixture_path.read_text(encoding="utf-8"))
            mutated = json.loads(json.dumps(payload))
            mutation = fixture["mutation"]
            if mutation == "duplicate_authority_node":
                mutated["figma"]["authority_nodes"].append(
                    mutated["figma"]["authority_nodes"][0]
                )
            elif mutation == "stale_canon_content":
                mutated["canon"]["content_sha"] = "0" * 64
            elif mutation == "destructive_legacy_action":
                mutated["legacy"]["destructive_actions"] = ["delete_node"]
            elif mutation == "overlapping_state_posture":
                state_id = mutated["state_posture"]["eligible_state_ids"][0]
                mutated["state_posture"]["gap_blocked_state_ids"].append(state_id)
                mutated["state_posture"]["gap_blocked_state_ids"].sort()
            else:
                self.fail(f"unknown fixture mutation: {mutation}")
            with self.subTest(fixture=fixture_path.name):
                with self.assertRaises(CanonError) as raised:
                    validate_visual_authority_payload(ROOT, mutated, b"invalid\n")
                self.assertEqual(raised.exception.code, fixture["expected_code"])

    def test_every_authority_node_requires_exact_frozen_metadata(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        nodes = payload["figma"]["authority_nodes"]
        self.assertEqual(len(nodes), 147)
        self.assertTrue(all(node["accessibility_variants"] for node in nodes))
        self.assertEqual(
            [
                node["visual_authority_id"]
                for node in nodes
                if "reconciliation_only" in node["swiftui_plausibility"]
            ],
            ["VA-P4-RECONCILIATION-001"],
        )
        cases = (
            ("empty_accessibility", "VISUAL_AUTHORITY_NODE_METADATA_INVALID"),
            ("stale_node_canon", "VISUAL_AUTHORITY_CANON_STALE"),
            ("reconciliation_plausibility_leak", "VISUAL_AUTHORITY_NODE_METADATA_INVALID"),
        )
        for mutation, code in cases:
            mutated = json.loads(json.dumps(payload))
            node = mutated["figma"]["authority_nodes"][0]
            if mutation == "empty_accessibility":
                node["accessibility_variants"] = []
            elif mutation == "stale_node_canon":
                node["canon_content_sha"] = "0" * 64
            else:
                node["swiftui_plausibility"] = "reconciliation_only_not_runtime_proof"
            with self.subTest(mutation=mutation):
                with self.assertRaises(CanonError) as raised:
                    validate_visual_authority_payload(ROOT, mutated, b"invalid\n")
                self.assertEqual(raised.exception.code, code)

    def test_legacy_task23_receipt_remains_hash_bound_provenance(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        legacy = payload["legacy"]
        prior = ROOT / legacy["prior_reconciliation_path"]
        import hashlib

        self.assertEqual(
            hashlib.sha256(prior.read_bytes()).hexdigest(),
            legacy["prior_reconciliation_sha256"],
        )
        mutated = json.loads(json.dumps(payload))
        mutated["legacy"]["prior_reconciliation_sha256"] = "0" * 64
        with self.assertRaises(CanonError) as raised:
            validate_visual_authority_payload(ROOT, mutated, b"invalid\n")
        self.assertEqual(
            raised.exception.code,
            "VISUAL_AUTHORITY_LEGACY_PROVENANCE_STALE",
        )

    def test_binary_labels_and_failure_evidence_never_authorize(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        screen = next(
            item for item in payload["figma"]["authority_nodes"]
            if item["kind"] == "screen"
            and item["authority_eligible_state_count"] > 0
        )

        unlabeled = json.loads(json.dumps(payload))
        unlabeled_screen = next(
            item for item in unlabeled["figma"]["authority_nodes"]
            if item["visual_authority_id"] == screen["visual_authority_id"]
        )
        unlabeled_screen["name"] = "Generic screen without a binary label"
        with self.assertRaises(CanonError) as raised:
            validate_visual_authority_payload(ROOT, unlabeled, b"invalid\n")
        self.assertEqual(raised.exception.code, "VISUAL_AUTHORITY_LABEL_INVALID")

        rejected = json.loads(json.dumps(payload))
        rejected_screen = next(
            item for item in rejected["figma"]["authority_nodes"]
            if item["visual_authority_id"] == screen["visual_authority_id"]
        )
        rejected_screen["name"] = (
            "FAILURE_EVIDENCE — generic skeleton master — R1"
        )
        snapshot = validate_visual_authority_payload(ROOT, rejected, b"invalid\n")
        green = replace(snapshot, gate_b_state="green")
        selected = select_visual_authority(
            green,
            scope_ids=(screen["blueprint_id"], screen["state_variant_ids"][0]),
            requirement_ids=(),
        )
        self.assertFalse(
            any(screen["visual_authority_id"] in item for item in selected)
        )
        self.assertTrue(any("VA-P4-CANDIDATE-" in item for item in selected))

        ineligible = json.loads(json.dumps(payload))
        ineligible_screen = next(
            item for item in ineligible["figma"]["authority_nodes"]
            if item["visual_authority_id"] == screen["visual_authority_id"]
        )
        ineligible_screen["task_pack_eligible"] = True
        with self.assertRaises(CanonError) as raised:
            validate_visual_authority_payload(ROOT, ineligible, b"invalid\n")
        self.assertEqual(raised.exception.code, "VISUAL_AUTHORITY_LABEL_INVALID")

    def test_candidate_shell_accessibility_and_proof_contract_is_exact(self) -> None:
        payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
        self.assertIn("presentation_matrix", payload)
        self.assertIn("candidate_proofs", payload)

        matrix = payload["presentation_matrix"]
        self.assertEqual(
            matrix["root_navigation_surfaces"],
            ["Goals", "Time", "Today", "You"],
        )
        self.assertEqual(
            matrix["no_root_chrome_surfaces"],
            ["Capture", "Search", "Trust/Proof inspection"],
        )
        self.assertEqual(
            matrix["required_accessibility_variants"],
            [
                "Accessibility Size",
                "Increase Contrast",
                "Large Text",
                "Reduce Motion",
                "Reduce Transparency",
                "Standard",
                "VoiceOver Order",
            ],
        )

        candidate_nodes = [
            item for item in payload["figma"]["authority_nodes"]
            if item.get("kind") == "candidate_master"
        ]
        self.assertGreaterEqual(len(candidate_nodes), 12)
        self.assertTrue(
            all(
                item["name"].startswith("CANDIDATE — ")
                and item["task_pack_eligible"] is True
                and item["presentation_variants"]
                == matrix["required_accessibility_variants"]
                for item in candidate_nodes
            )
        )
        proof_ids = {item["visual_authority_id"] for item in payload["candidate_proofs"]}
        self.assertEqual(
            proof_ids,
            {item["visual_authority_id"] for item in candidate_nodes},
        )
        self.assertTrue(
            all(
                set(item["artifacts"])
                == {"hero", "presentation", "viewport"}
                and item["direct_visual_review_note"]
                for item in payload["candidate_proofs"]
            )
        )

        cases = (
            ("capture_root_chrome", "VISUAL_AUTHORITY_PRESENTATION_MATRIX_INVALID"),
            ("missing_accessibility_variant", "VISUAL_AUTHORITY_ACCESSIBILITY_MATRIX_INVALID"),
            ("missing_master_proof", "VISUAL_AUTHORITY_PROOF_INVALID"),
        )
        for mutation, code in cases:
            mutated = json.loads(json.dumps(payload))
            if mutation == "capture_root_chrome":
                mutated["presentation_matrix"]["root_navigation_surfaces"].append(
                    "Capture"
                )
            elif mutation == "missing_accessibility_variant":
                mutated["presentation_matrix"]["required_accessibility_variants"].remove(
                    "Increase Contrast"
                )
            else:
                mutated["candidate_proofs"].pop()
            with self.subTest(mutation=mutation):
                with self.assertRaises(CanonError) as raised:
                    validate_visual_authority_payload(ROOT, mutated, b"invalid\n")
                self.assertEqual(raised.exception.code, code)


if __name__ == "__main__":
    unittest.main()
