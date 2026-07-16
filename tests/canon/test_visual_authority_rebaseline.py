from __future__ import annotations

import hashlib
import json
import re
import unittest
from dataclasses import replace
from pathlib import Path

import tools.ambitions_canon.visual_authority as visual_authority
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
                "created_node_count": 79,
                "mutated_node_count": 105,
                "deleted_node_ids": [],
                "destructive_actions": [],
                "review_repair": {
                    "atomic_write_count": 2,
                    "created_node_ids": ["367:2746", "368:2746"],
                    "failed_atomic_attempt_count": 1,
                    "failed_atomic_debug_uuid": (
                        "fba516e2-f956-4ca1-9563-a52d7e73597b"
                    ),
                    "hidden_retained_node_ids": ["354:2562", "354:2733"],
                    "mutated_node_ids": [
                        "296:84",
                        "329:1635",
                        "329:1695",
                        "329:1698",
                        "327:1648",
                        "354:2733",
                        "I367:2746;249:305",
                        "I367:2746;249:310",
                        "354:2300",
                        "354:2552",
                        "354:2562",
                        "I368:2746;249:305",
                        "I368:2746;249:300",
                    ],
                },
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

    def test_r1_accessibility_classes_are_registry_bound_without_stale_gap_copy(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        node_snapshot = json.loads(R1_NODE_SNAPSHOT.read_text(encoding="utf-8"))
        nodes = {
            item["visual_authority_id"]: item
            for item in manifest["figma"]["authority_nodes"]
        }

        contextual_detail = nodes["VA-P4-A11Y-CLASS-003"]
        trust_candidate = nodes["VA-P4-CANDIDATE-008"]
        self.assertEqual(
            contextual_detail["requirement_ids"],
            trust_candidate["requirement_ids"],
        )
        self.assertEqual(
            contextual_detail["screen_mappings"],
            trust_candidate["screen_mappings"],
        )

        lifecycle = nodes["VA-P4-A11Y-CLASS-005"]
        self.assertTrue(lifecycle["requirement_ids"])
        lifecycle_mappings = {
            item["blueprint_id"]: item for item in lifecycle["screen_mappings"]
        }
        self.assertIn("UX-SCREEN-TIME-DETAIL", lifecycle_mappings)
        self.assertIn("UX-SCREEN-TIME-IMPORT", lifecycle_mappings)
        self.assertIn(
            "UX-STATE-VARIANT-TIME-DETAIL-VIEWING",
            lifecycle_mappings["UX-SCREEN-TIME-DETAIL"]["state_variant_ids"],
        )
        self.assertIn(
            "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF",
            lifecycle_mappings["UX-SCREEN-TIME-IMPORT"]["state_variant_ids"],
        )

        command_registry = json.loads(
            (ROOT / "docs/canon/registries/command-resolution-registry.json").read_text(
                encoding="utf-8"
            )
        )
        current_commands = {
            item["state_id"]: sorted(
                {
                    entry["command_id"]
                    for entry in command_registry["records"]
                    if entry["state_id"] == item["state_id"]
                    and entry["posture"] == "current"
                    and not entry["command_id"].endswith(
                        ("-INVERSE", "-RECOVERY-HANDOFF")
                    )
                }
            )
            for item in node_snapshot["command_registry_bindings"]
        }
        self.assertEqual(
            node_snapshot["command_registry_bindings"],
            [
                {
                    "command_ids": current_commands[
                        "UX-STATE-VARIANT-TIME-DETAIL-VIEWING"
                    ],
                    "figma_text_node_id": "329:1695",
                    "requirement_id": "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001",
                    "state_id": "UX-STATE-VARIANT-TIME-DETAIL-VIEWING",
                },
                {
                    "command_ids": current_commands[
                        "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF"
                    ],
                    "figma_text_node_id": "329:1698",
                    "requirement_id": "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001",
                    "state_id": "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF",
                },
            ],
        )
        serialized = json.dumps(
            {
                "manifest": manifest,
                "node_snapshot": node_snapshot,
            },
            sort_keys=True,
        )
        self.assertNotIn("GAP-UX-COMMAND-CONTRACT-TIME-DETAIL-001", serialized)
        self.assertNotIn("GAP-UX-COMMAND-CONTRACT-TIME-IMPORT-001", serialized)

    def test_r1_presentation_repairs_are_durable_and_task_pack_exact(self) -> None:
        node_snapshot = json.loads(R1_NODE_SNAPSHOT.read_text(encoding="utf-8"))
        repairs = {
            item["visual_authority_id"]: item
            for item in node_snapshot["presentation_repairs"]
        }
        self.assertEqual(
            set(repairs),
            {
                "VA-P4-A11Y-CLASS-006",
                "VA-P4-CANDIDATE-001",
                "VA-P4-CANDIDATE-003",
                "VA-P4-CANDIDATE-005",
            },
        )
        journey = repairs["VA-P4-A11Y-CLASS-006"]
        self.assertEqual(journey["frame_id"], "327:1648")
        self.assertGreater(journey["frame_height"], 80)
        self.assertFalse(journey["clips_consequence_copy"])
        self.assertEqual(journey["visible_consequence_text"], "You can continue offline")

        you = repairs["VA-P4-CANDIDATE-005"]
        self.assertEqual(you["frame_id"], "278:1449")
        self.assertEqual(you["visible_root_dock_glyphs"], ["Goals", "Time", "Today", "You"])
        today = repairs["VA-P4-CANDIDATE-001"]
        goals = repairs["VA-P4-CANDIDATE-003"]
        self.assertGreaterEqual(today["content_bottom_clearance"], today["dock_height"])
        self.assertGreaterEqual(goals["content_bottom_clearance"], goals["dock_height"])
        self.assertEqual(today["preserved_composition"], "rolling_vertical_time_rail")

        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        proofs = {
            item["visual_authority_id"]: item["artifacts"]
            for item in manifest["candidate_proofs"]
        }
        targets = {
            item["visual_authority_id"]: item
            for item in node_snapshot["task_pack_targets"]
        }
        for authority_id in ("VA-P4-CANDIDATE-004", "VA-P4-CANDIDATE-005"):
            with self.subTest(authority_id=authority_id):
                self.assertEqual(
                    proofs[authority_id]["viewport"]["sha256"],
                    targets[authority_id]["screenshot_sha256"],
                )
                self.assertEqual(
                    proofs[authority_id]["viewport"]["path"],
                    targets[authority_id]["screenshot_path"],
                )

    def test_r1_snapshot_rejects_unknown_fields_at_every_nested_record(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        snapshot = json.loads(R1_NODE_SNAPSHOT.read_text(encoding="utf-8"))
        cases = (
            ("canon", snapshot["canon"]),
            ("figma_write_receipt", snapshot["figma_write_receipt"]),
            ("review_repair_receipt", snapshot["figma_write_receipt"]["review_repair"]),
            ("authority_node_binding", snapshot["authority_node_bindings"][0]),
            ("task_pack_target", snapshot["task_pack_targets"][0]),
            ("authority_metadata", snapshot["authority_metadata"][0]),
            ("root_shell_frame", snapshot["root_shell_frames"][0]),
            ("drilldown_shell_frame", snapshot["drilldown_shell_frames"][0]),
            ("pixel_equivalent_replacement", snapshot["pixel_equivalent_replacements"][0]),
            ("render_proof", snapshot["pixel_equivalent_replacements"][0]["after_render"]),
            ("raw_node_pair", snapshot["pixel_equivalent_replacements"][0]["raw_node_pairs"][0]),
            ("normalized_node", snapshot["pixel_equivalent_replacements"][0]["normalized_old_nodes"][0]),
            ("normalized_paint", snapshot["pixel_equivalent_replacements"][0]["normalized_old_nodes"][0]["fill_paints"][0]),
            ("normalized_vector", snapshot["pixel_equivalent_replacements"][0]["normalized_old_nodes"][1]["vectors"][0]),
            ("command_registry", snapshot["command_registry"]),
            ("command_registry_binding", snapshot["command_registry_bindings"][0]),
            ("presentation_repair", snapshot["presentation_repairs"][0]),
            ("support_overlay", snapshot["support_overlay_bindings"][0]),
            ("support_screen_mapping", snapshot["support_overlay_bindings"][0]["screen_mappings"][0]),
        )
        for name, record in cases:
            mutated = json.loads(json.dumps(snapshot))
            target = record
            # Locate the copied record by its unique serialized representation.
            needle = json.dumps(record, sort_keys=True)

            def inject(value: object) -> bool:
                if isinstance(value, dict):
                    if json.dumps(value, sort_keys=True) == needle:
                        value["unexpected_field"] = True
                        return True
                    return any(inject(child) for child in value.values())
                if isinstance(value, list):
                    return any(inject(child) for child in value)
                return False

            self.assertTrue(inject(mutated), name)
            with self.subTest(record=name):
                with self.assertRaises(CanonError) as raised:
                    visual_authority.validate_r1_node_snapshot_payload(
                        ROOT,
                        manifest,
                        mutated,
                    )
                self.assertEqual(
                    raised.exception.code,
                    "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
                )

    def test_r1_pixel_equivalence_is_independently_reproducible(self) -> None:
        snapshot = json.loads(R1_NODE_SNAPSHOT.read_text(encoding="utf-8"))
        node_snapshot = snapshot
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        replacement = snapshot["pixel_equivalent_replacements"][0]
        self.assertEqual(
            replacement["normalized_old_nodes"],
            replacement["normalized_replacement_nodes"],
        )
        normalized_digest = hashlib.sha256(
            json.dumps(
                replacement["normalized_old_nodes"],
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            ).encode("utf-8")
        ).hexdigest()
        self.assertEqual(replacement["normalized_properties_sha256"], normalized_digest)
        before = replacement["before_render"]
        after = replacement["after_render"]
        self.assertNotEqual(before["path"], after["path"])
        self.assertEqual(before["sha256"], after["sha256"])
        for render in (before, after):
            self.assertEqual(
                hashlib.sha256((ROOT / render["path"]).read_bytes()).hexdigest(),
                render["sha256"],
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
            replacement["before_render"]["sha256"],
            "311374645649f6bdd851b9e34783599847c94b76d6862d0dbb2d67a473260376",
        )
        self.assertEqual(replacement["before_render"]["sha256"], replacement["after_render"]["sha256"])

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
            "9384b572533a4a8ac2e2bd0b068e1fa76d427db8417a9668239043707eff0202",
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
