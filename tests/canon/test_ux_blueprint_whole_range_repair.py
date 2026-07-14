import copy
import hashlib
import json
import re
import sys
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MATRIX_PATH = REPO_ROOT / "tests/canon/fixtures/visual-blueprint-phase1-repair-matrix.json"
INVENTORY_PATH = REPO_ROOT / "docs/canon/migration/ux-blueprint-state-inventory.json"
TAXONOMY_PATH = REPO_ROOT / "tests/canon/fixtures/ux-blueprint-current-delta-owner-taxonomy.json"
MATRIX_SHA256 = "f319153d552ab557798f289d7e838e94364a2e21b43903343c672af207dbdbbe"
OWNED_FIELDS = {
    "allowed_commands",
    "transition_exit",
    "durable_effect",
    "recovery_rollback",
    "offline_behavior",
    "accessibility_focus",
}


class UXBlueprintWholeRangeRepairTests(unittest.TestCase):
    def _module(self):
        from tools.ambitions_canon import ux_blueprint

        return ux_blueprint

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text()
        )

    def _states(self, payload):
        return [
            state
            for model in payload["state_models"]
            for state in model["variants"]
        ]

    def _requirement(self, requirement_id):
        return next(
            row
            for row in self._module().load_requirement_source_records(REPO_ROOT)
            if row["requirement_id"] == requirement_id
        )

    def _forged_backed_state(self, payload):
        state = next(
            row
            for row in self._states(payload)
            if "CONTROL-UNDO-RECOVERY-001" in row["requirement_ids"]
        )
        requirement = self._requirement("CONTROL-UNDO-RECOVERY-001")
        state["behavior_authority_posture"] = "requirement_backed"
        state["behavior_requirement_ids"] = ["CONTROL-UNDO-RECOVERY-001"]
        state["specification_gap_ids"] = []
        state["allowed_commands"] = ["Undo"]
        state["behavior_authority_evidence"] = [
            {
                "requirement_id": "CONTROL-UNDO-RECOVERY-001",
                "normative_clause": requirement["normative_text"],
                "owned_fields": sorted(OWNED_FIELDS),
            }
        ]
        for gap in payload["specification_gaps"]:
            if state["blueprint_id"] in gap["affected_state_ids"]:
                gap["affected_state_ids"].remove(state["blueprint_id"])
        return state

    def test_approved_matrix_is_exact_and_counted(self):
        raw = MATRIX_PATH.read_bytes()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), MATRIX_SHA256)
        matrix = json.loads(raw)
        self.assertEqual(len(matrix["state_repairs"]), 31)
        self.assertEqual(len(matrix["gaps"]), 20)
        self.assertEqual(len(matrix["false_nonvisual"]), 61)

    def test_explicit_inventory_is_matrix_bound_and_complete(self):
        inventory = json.loads(INVENTORY_PATH.read_text())
        self.assertEqual(
            set(inventory),
            {"matrix_sha256", "schema_version", "setup_subordinate_content", "state_variants"},
        )
        self.assertEqual(inventory["matrix_sha256"], MATRIX_SHA256)
        self.assertEqual(len(inventory["state_variants"]), 433)
        self.assertEqual(
            inventory["state_variants"],
            sorted(
                inventory["state_variants"],
                key=lambda row: (row["screen_id"], row["variant_key"]),
            ),
        )
        self.assertEqual(
            {row["content_id"] for row in inventory["setup_subordinate_content"]},
            {"optional-account", "permissions-choice", "welcome"},
        )
        self._module().validate_ux_blueprint(REPO_ROOT, self._payload())

    def test_taxonomy_is_bound_to_matrix_and_current_inventory(self):
        taxonomy = json.loads(TAXONOMY_PATH.read_text())
        self.assertEqual(taxonomy["matrix_sha256"], MATRIX_SHA256)
        self.assertNotIn("baseline_sha", taxonomy)
        rows = taxonomy["current_delta_owner_taxonomy"]
        self.assertEqual(len(rows), 177)
        current = {
            (row["screen_id"], row["variant_key"])
            for row in json.loads(INVENTORY_PATH.read_text())["state_variants"]
        }
        self.assertTrue(
            {(row["screen_id"], row["variant_key"]) for row in rows} <= current
        )

    def test_all_states_fail_closed_after_exact_clause_reaudit(self):
        payload = self._payload()
        states = self._states(payload)
        self.assertEqual(len(states), 433)
        self.assertEqual(
            {state["behavior_authority_posture"] for state in states},
            {"exploratory_blocked_by_specification_gap"},
        )
        for state in states:
            self.assertEqual(state["behavior_authority_evidence"], [])
            self.assertEqual(state["allowed_commands"], [])
            self.assertEqual(state["behavior_requirement_ids"], [])
            self.assertTrue(state["specification_gap_ids"])

    def test_gap_affected_state_ids_are_exact_and_bidirectional(self):
        payload = self._payload()
        gaps = {gap["gap_id"]: gap for gap in payload["specification_gaps"]}
        expected = {gap_id: [] for gap_id in gaps}
        for state in self._states(payload):
            for gap_id in state["specification_gap_ids"]:
                expected[gap_id].append(state["blueprint_id"])
        for gap_id, gap in gaps.items():
            self.assertEqual(gap["affected_state_ids"], sorted(expected[gap_id]))

        forged = copy.deepcopy(payload)
        forged["specification_gaps"][0]["affected_state_ids"].pop()
        with self.assertRaisesRegex(
            self._module().UXBlueprintError, "gap affected state inventory is stale"
        ):
            self._module().validate_ux_blueprint(REPO_ROOT, forged)

    def test_gap_state_membership_matches_approved_matrix_screen_families(self):
        payload = self._payload()
        matrix = json.loads(MATRIX_PATH.read_text())
        approved = {
            gap["gap_id"]: set(gap["screen_families"])
            for gap in matrix["gaps"]
        }
        state_screens = {
            state["blueprint_id"]: model["screen_id"]
            .removeprefix("UX-SCREEN-")
            .casefold()
            for model in payload["state_models"]
            for state in model["variants"]
        }
        for gap in payload["specification_gaps"]:
            for state_id in gap["affected_state_ids"]:
                self.assertIn(state_screens[state_id], approved[gap["gap_id"]])

        time_degraded = next(
            model
            for model in payload["state_models"]
            if model["screen_id"] == "UX-SCREEN-TIME-DEGRADED"
        )
        for state in time_degraded["variants"]:
            self.assertEqual(
                state["specification_gap_ids"],
                ["GAP-UX-COMMAND-CONTRACT-TIME-DEGRADED-001"],
            )
        dedicated_gap = next(
            row
            for row in payload["specification_gaps"]
            if row["gap_id"] == "GAP-UX-COMMAND-CONTRACT-TIME-DEGRADED-001"
        )
        self.assertEqual(
            dedicated_gap["affected_state_ids"],
            sorted(state["blueprint_id"] for state in time_degraded["variants"]),
        )
        for gap_id in (
            "GAP-UX-COMMAND-CONTRACT-TIME-VIEWS-001",
            "GAP-UX-COMMAND-CONTRACT-TIME-IMPORT-001",
        ):
            gap = next(
                row for row in payload["specification_gaps"] if row["gap_id"] == gap_id
            )
            self.assertFalse(
                any("TIME-DEGRADED" in state_id for state_id in gap["affected_state_ids"])
            )

    def test_time_today_trust_and_capture_reclassification_is_fail_closed(self):
        payload = self._payload()
        by_screen = {
            model["screen_id"]: model["variants"] for model in payload["state_models"]
        }
        time_states = [
            state
            for screen in ("DAY", "LIST", "MONTH", "WEEK", "YEAR")
            for state in by_screen[f"UX-SCREEN-TIME-{screen}"]
        ]
        self.assertEqual(len(time_states), 55)
        for state in time_states:
            self.assertEqual(
                state["specification_gap_ids"],
                ["GAP-UX-COMMAND-CONTRACT-TIME-VIEWS-001"],
            )
        for screen_id, gap_id in (
            ("UX-SCREEN-TODAY-DETAIL", "GAP-UX-COMMAND-CONTRACT-TODAY-001"),
            ("UX-SCREEN-TODAY-START-HERE", "GAP-UX-COMMAND-CONTRACT-TODAY-001"),
            ("UX-SCREEN-TRUST-INLINE", "GAP-UX-COMMAND-CONTRACT-TRUST-001"),
            ("UX-SCREEN-CAPTURE-SAVED-FOR-LATER", "GAP-UX-COMMAND-CONTRACT-CAPTURE-001"),
        ):
            for state in by_screen[screen_id]:
                self.assertIn(gap_id, state["specification_gap_ids"])

    def test_evidence_validation_rejects_nonexact_broad_uncovered_and_unowned_command(self):
        module = self._module()

        nonexact = copy.deepcopy(self._payload())
        state = self._forged_backed_state(nonexact)
        state["behavior_authority_evidence"][0]["normative_clause"] += " invented"
        with self.assertRaisesRegex(module.UXBlueprintError, "non-exact normative clause"):
            module.validate_ux_blueprint(REPO_ROOT, nonexact)

        broad = copy.deepcopy(self._payload())
        state = self._forged_backed_state(broad)
        state["behavior_authority_evidence"][0]["requirement_id"] = next(
            requirement_id
            for requirement_id in state["requirement_ids"]
            if requirement_id != "CONTROL-UNDO-RECOVERY-001"
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "evidence requirement mismatch"):
            module.validate_ux_blueprint(REPO_ROOT, broad)

        uncovered = copy.deepcopy(self._payload())
        state = self._forged_backed_state(uncovered)
        state["behavior_authority_evidence"][0]["owned_fields"].remove("offline_behavior")
        with self.assertRaisesRegex(module.UXBlueprintError, "behavior fields lack exact ownership"):
            module.validate_ux_blueprint(REPO_ROOT, uncovered)

        absent_command = copy.deepcopy(self._payload())
        state = self._forged_backed_state(absent_command)
        state["allowed_commands"] = ["Invented Command"]
        with self.assertRaisesRegex(module.UXBlueprintError, "command lacks exact lexical ownership"):
            module.validate_ux_blueprint(REPO_ROOT, absent_command)

    def test_authority_eligibility_fails_closed_for_invalid_evidence(self):
        payload = copy.deepcopy(self._payload())
        state = self._forged_backed_state(payload)
        state["behavior_authority_evidence"] = []
        self.assertEqual(
            self._module().authority_eligible_state_variant_ids(payload, REPO_ROOT),
            frozenset(),
        )

    def test_self_declared_general_clause_ownership_cannot_confer_authority(self):
        payload = copy.deepcopy(self._payload())
        self._forged_backed_state(payload)
        module = self._module()
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "independent structured canon field ownership",
        ):
            module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(
            module.authority_eligible_state_variant_ids(payload, REPO_ROOT),
            frozenset(),
        )

    def test_tests_and_tooling_are_portable_and_commit_independent(self):
        candidates = [
            path
            for path in (REPO_ROOT / "tests/canon").glob("test_ux_blueprint*.py")
            if path != Path(__file__)
        ]
        candidates.append(REPO_ROOT / "tools/ambitions_canon/ux_blueprint.py")
        text = "\n".join(path.read_text() for path in candidates)
        self.assertNotIn("/Users/devan", text)
        self.assertNotIn("REVIEWED_BASELINE_SHA", text)
        self.assertNotRegex(text, re.compile(r"git[\"']?,?\s*[\"']show"))
        self.assertNotIn("REQUIRED_STATE_VARIANTS", text)
        self.assertNotIn("REQUIRED_STATE_INVENTORY_SHA256", text)
        self.assertNotIn('"merge-base"', text)
        self.assertNotIn('"HEAD"', text)

    def test_source_sha_is_an_immutable_reviewed_commit_object(self):
        module = self._module()
        payload = self._payload()
        self.assertEqual(
            module._validate_source_sha(
                REPO_ROOT,
                payload["source_sha"],
                tuple(row["path"] for row in payload["source_documents"]),
            ),
            payload["source_sha"],
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "reviewed commit object"):
            module._validate_source_sha(REPO_ROOT, "0" * 40, ())

    def test_shadow_validation_standard_owns_canon_tooling(self):
        text = (REPO_ROOT / "docs/canon/standards/validation-and-release.md").read_text()
        front_matter = text.split("+++", 2)[1]
        self.assertIn('"tools/ambitions_canon/"', front_matter)

    def test_primary_python_is_current_interpreter(self):
        self.assertTrue(Path(sys.executable).exists())


if __name__ == "__main__":
    unittest.main()
