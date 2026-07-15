from __future__ import annotations

import json
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
            "0ac3656f1f55c0514ada19da8b36b8a090628e4fa1648a6aaee3f660a3ed27bb",
        )
        self.assertEqual(snapshot.figma_file_key, "Oik7612LSTUHWsNRFoTlTJ")
        self.assertEqual(snapshot.authority_node_count, 147)
        self.assertEqual(snapshot.screen_count, 47)
        self.assertEqual(len(snapshot.visual_requirement_ids), 324)
        self.assertEqual(len(snapshot.eligible_state_ids), 263)
        self.assertEqual(len(snapshot.future_state_ids), 4)
        self.assertEqual(len(snapshot.gap_blocked_state_ids), 166)
        self.assertEqual(snapshot.legacy_node_count, 15)
        self.assertEqual(snapshot.destructive_actions, ())

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
        self.assertTrue(any("figma:Oik7612LSTUHWsNRFoTlTJ:51:100" in item for item in selected))
        self.assertFalse(any("SWtHm9ouHTPbEFfNrrtZwv" in item for item in selected))

    def test_future_gap_and_stale_canon_fail_closed(self) -> None:
        green = replace(self.snapshot, gate_b_state="green")
        cases = (
            (
                ("UX-STATE-VARIANT-TIME-DEGRADED-SYNC-PENDING",),
                green.canon_content_sha,
                "VISUAL_AUTHORITY_FUTURE_GATED",
            ),
            (
                ("UX-STATE-VARIANT-ACCOUNT-BOUNDARY-LOCAL-ONLY",),
                green.canon_content_sha,
                "VISUAL_AUTHORITY_GAP_BLOCKED",
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
