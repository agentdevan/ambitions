import copy
import hashlib
import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
STATE_KINDS = {
    "degraded",
    "empty",
    "failure",
    "interruption",
    "loading",
    "recovery",
    "resting",
    "rollback",
    "transitional",
}
STATE_FIELDS = {
    "accessibility_focus",
    "allowed_commands",
    "blueprint_id",
    "displayed_objects",
    "durable_effect",
    "implementation_status",
    "kind",
    "offline_behavior",
    "proof_ceiling",
    "recovery_rollback",
    "requirement_ids",
    "transition_exit",
    "visible_content_copy",
    "visible_presentation",
}


class UXBlueprintReviewRepairTests(unittest.TestCase):
    def _module(self):
        if importlib.util.find_spec("tools.ambitions_canon.ux_blueprint"):
            from tools.ambitions_canon import ux_blueprint

            return ux_blueprint
        from docs.canon.migration import ux_blueprint_tool

        return ux_blueprint_tool

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text(
                encoding="utf-8"
            )
        )

    def test_requirement_dispositions_are_explicit_individual_and_semantic(self):
        module = self._module()
        payload = self._payload()

        self.assertNotIn("requirement_disposition_policy", payload)
        dispositions = payload["requirement_dispositions"]
        self.assertEqual(len(dispositions), 441)
        self.assertEqual(
            [item["requirement_id"] for item in dispositions],
            sorted(item["requirement_id"] for item in dispositions),
        )
        self.assertEqual(
            len({item["requirement_id"] for item in dispositions}), 441
        )
        for item in dispositions:
            self.assertEqual(
                set(item),
                {
                    "blueprint_ids",
                    "disposition",
                    "rationale",
                    "requirement_id",
                    "source_path",
                },
            )
            self.assertIn(
                item["disposition"],
                {"visual_mapping_required", "nonvisual_with_rationale"},
            )
            self.assertGreaterEqual(len(item["rationale"].split()), 8)
            if item["disposition"] == "visual_mapping_required":
                self.assertTrue(item["blueprint_ids"])
            else:
                self.assertEqual(item["blueprint_ids"], [])

        by_id = {item["requirement_id"]: item for item in dispositions}
        fixtures = {
            "CODEX-DEPT-002": ("nonvisual_with_rationale", []),
            "SECURITY-003": (
                "visual_mapping_required",
                [
                    "UX-SCREEN-CAPTURE-COMPOSER",
                    "UX-SCREEN-YOU-DATA",
                    "UX-SCREEN-YOU-SETTINGS",
                ],
            ),
            "OBJ-EVENT-RECURRENCE-EDIT-001": (
                "visual_mapping_required",
                ["UX-OBJECT-EVENT", "UX-SCREEN-TIME-DETAIL"],
            ),
            "JOURNEY-CALENDAR-DIFF-001": (
                "visual_mapping_required",
                ["UX-JOURNEY-EXTERNAL-CALENDAR", "UX-SCREEN-TIME-IMPORT"],
            ),
            "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001": (
                "visual_mapping_required",
                ["UX-SCREEN-TODAY-ROOT", "UX-SCREEN-TODAY-START-HERE"],
            ),
            "SYSTEM-CONTINUITY-CONTROL-CENTER-001": (
                "visual_mapping_required",
                [
                    "UX-SCREEN-ACCOUNT-BOUNDARY",
                    "UX-SCREEN-ACCOUNT-STATUS",
                    "UX-SCREEN-YOU-DATA",
                ],
            ),
        }
        for requirement_id, expected in fixtures.items():
            self.assertEqual(by_id[requirement_id]["disposition"], expected[0])
            self.assertEqual(by_id[requirement_id]["blueprint_ids"], expected[1])

        summary = module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(summary.disposition_count, 441)

    def test_each_screen_has_nine_complete_explicit_state_records(self):
        module = self._module()
        payload = self._payload()
        screen_ids = {item["blueprint_id"] for item in payload["screens"]}

        self.assertEqual(len(payload["state_models"]), len(screen_ids))
        self.assertEqual(
            {item["screen_id"] for item in payload["state_models"]}, screen_ids
        )
        state_ids = set()
        for model in payload["state_models"]:
            self.assertEqual({item["kind"] for item in model["states"]}, STATE_KINDS)
            self.assertEqual(len(model["states"]), 9)
            for state in model["states"]:
                self.assertEqual(set(state), STATE_FIELDS)
                self.assertTrue(state["visible_presentation"])
                self.assertTrue(state["visible_content_copy"])
                self.assertTrue(state["displayed_objects"])
                self.assertTrue(state["allowed_commands"])
                self.assertTrue(state["transition_exit"])
                self.assertTrue(state["durable_effect"])
                self.assertTrue(state["recovery_rollback"])
                self.assertTrue(state["offline_behavior"])
                self.assertTrue(state["accessibility_focus"])
                self.assertTrue(state["requirement_ids"])
                self.assertNotIn(state["blueprint_id"], state_ids)
                state_ids.add(state["blueprint_id"])

        self.assertEqual(len(state_ids), 360)
        summary = module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(summary.state_model_count, 40)
        self.assertEqual(summary.state_record_count, 360)

    def test_state_validator_rejects_omission_mutation_and_generic_labels(self):
        module = self._module()

        missing = self._payload()
        del missing["state_models"][0]["states"][0]["allowed_commands"]
        with self.assertRaisesRegex(module.UXBlueprintError, "state record fields"):
            module.validate_ux_blueprint(REPO_ROOT, missing)

        duplicate = self._payload()
        duplicate["state_models"][0]["states"][0]["kind"] = duplicate[
            "state_models"
        ][0]["states"][1]["kind"]
        with self.assertRaisesRegex(module.UXBlueprintError, "state taxonomy"):
            module.validate_ux_blueprint(REPO_ROOT, duplicate)

        generic = self._payload()
        generic["state_models"][0]["states"][0]["visible_content_copy"] = "Loading"
        with self.assertRaisesRegex(module.UXBlueprintError, "explicit visible content"):
            module.validate_ux_blueprint(REPO_ROOT, generic)

    def test_renderer_includes_complete_state_contracts(self):
        module = self._module()
        payload = self._payload()
        rendered = module.render_ux_blueprint_markdown(payload, REPO_ROOT).decode()

        self.assertIn("## Explicit screen state contracts", rendered)
        for field in (
            "Visible presentation",
            "Content / copy",
            "Displayed objects",
            "Allowed commands",
            "Transition / exit",
            "Durable effect",
            "Recovery / rollback",
            "Offline behavior",
            "Accessibility / focus",
        ):
            self.assertIn(field, rendered)
        self.assertIn("`UX-STATE-ACCOUNT-BOUNDARY-DEGRADED`", rendered)

    def test_executable_logic_has_canonical_tool_owner_and_docs_are_data_only(self):
        spec = importlib.util.find_spec("tools.ambitions_canon.ux_blueprint")
        self.assertIsNotNone(spec, "UX blueprint executable must be tool-owned")
        python_under_canon = sorted(
            path.relative_to(REPO_ROOT).as_posix()
            for path in (REPO_ROOT / "docs/canon").rglob("*.py")
        )
        self.assertEqual(python_under_canon, [])

    def test_validator_enforces_exact_identity_facet_inventory_and_global_typed_ids(self):
        module = self._module()

        wrong_id = self._payload()
        wrong_id["blueprint_id"] = "AMB-UX-BLUEPRINT-REBASELINE-999"
        with self.assertRaisesRegex(module.UXBlueprintError, "blueprint identity"):
            module.validate_ux_blueprint(REPO_ROOT, wrong_id)

        wrong_title = self._payload()
        wrong_title["title"] = "Similar blueprint"
        with self.assertRaisesRegex(module.UXBlueprintError, "blueprint identity"):
            module.validate_ux_blueprint(REPO_ROOT, wrong_title)

        replaced_facet = self._payload()
        replaced_facet["cross_cutting"][0]["facet"] = "invented-facet"
        with self.assertRaisesRegex(module.UXBlueprintError, "facet inventory"):
            module.validate_ux_blueprint(REPO_ROOT, replaced_facet)

        cross_kind_duplicate = self._payload()
        cross_kind_duplicate["object_boundaries"][0]["blueprint_id"] = (
            cross_kind_duplicate["screens"][0]["blueprint_id"]
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "globally unique typed"):
            module.validate_ux_blueprint(REPO_ROOT, cross_kind_duplicate)

    def test_every_record_is_fail_closed_to_design_input_claim_ceiling(self):
        module = self._module()
        payload = self._payload()
        groups = (
            payload["screens"],
            payload["state_models"],
            payload["object_boundaries"],
            payload["journeys"],
            payload["cross_cutting"],
        )
        for group in groups:
            for record in group:
                self.assertEqual(record["implementation_status"], "design_input_only")
                self.assertEqual(record["proof_ceiling"], module.RECORD_PROOF_CEILING)
        for model in payload["state_models"]:
            for state in model["states"]:
                self.assertEqual(state["implementation_status"], "design_input_only")
                self.assertEqual(state["proof_ceiling"], module.RECORD_PROOF_CEILING)

        overclaim = self._payload()
        overclaim["journeys"][0]["proof_ceiling"] = "Runtime Green"
        with self.assertRaisesRegex(module.UXBlueprintError, "record proof ceiling"):
            module.validate_ux_blueprint(REPO_ROOT, overclaim)

    def test_declared_sources_are_digest_bound_and_git_source_is_current(self):
        module = self._module()
        payload = self._payload()
        sources = payload["source_documents"]
        self.assertEqual(
            [item["path"] for item in sources], sorted(item["path"] for item in sources)
        )
        for item in sources:
            self.assertRegex(item["sha256"], r"^[0-9a-f]{64}$")
        module.validate_source_documents(REPO_ROOT, sources)

        source_sha = payload["source_sha"]
        self.assertEqual(
            subprocess.run(
                ["git", "merge-base", "--is-ancestor", source_sha, "HEAD"],
                cwd=REPO_ROOT,
                check=False,
            ).returncode,
            0,
        )

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source.md"
            source.write_text("approved bytes\n", encoding="utf-8")
            record = {
                "path": "source.md",
                "sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            }
            module.validate_source_documents(root, [record])
            source.write_text("changed bytes\n", encoding="utf-8")
            with self.assertRaisesRegex(module.UXBlueprintError, "source content digest"):
                module.validate_source_documents(root, [record])


if __name__ == "__main__":
    unittest.main()
