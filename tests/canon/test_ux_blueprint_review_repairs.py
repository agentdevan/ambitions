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
TAXONOMY_FIELDS = {
    "applicability",
    "generic_kind",
    "rationale",
    "variant_ids",
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
        self.assertEqual(len(dispositions), 449)
        self.assertEqual(
            [item["requirement_id"] for item in dispositions],
            sorted(item["requirement_id"] for item in dispositions),
        )
        self.assertEqual(
            len({item["requirement_id"] for item in dispositions}), 449
        )
        for item in dispositions:
            self.assertEqual(
                set(item),
                {
                    "blueprint_ids",
                    "disposition",
                    "rationale",
                    "requirement_text_sha256",
                    "requirement_id",
                    "source_path",
                    "state_blueprint_ids",
                },
            )
            self.assertIn(
                item["disposition"],
                {"visual_mapping_required", "nonvisual_with_rationale"},
            )
            self.assertGreaterEqual(len(item["rationale"].split()), 8)
            if item["disposition"] == "visual_mapping_required":
                self.assertTrue(item["blueprint_ids"] or item["state_blueprint_ids"])
            else:
                self.assertEqual(item["blueprint_ids"], [])
                self.assertEqual(item["state_blueprint_ids"], [])

        by_id = {item["requirement_id"]: item for item in dispositions}
        fixtures = {
            "CODEX-DEPT-002": ("nonvisual_with_rationale", []),
            "SECURITY-003": (
                "visual_mapping_required",
                [
                    "UX-CROSS-SENSITIVE-EXPOSURE-CHANNELS",
                    "UX-SCREEN-ACCOUNT-SIGN-IN",
                    "UX-SCREEN-APP-SHELL-ROOT",
                    "UX-SCREEN-CAPTURE-ATTACHMENT",
                    "UX-SCREEN-CAPTURE-COMPOSER",
                    "UX-SCREEN-CAPTURE-PROPOSAL",
                    "UX-SCREEN-PERMISSIONS-NOTIFICATIONS",
                    "UX-SCREEN-SEARCH-ROOT",
                    "UX-SCREEN-TRUST-DEEP",
                    "UX-SCREEN-YOU-DATA",
                    "UX-SCREEN-YOU-SETTINGS",
                    "UX-SECURITY-CHANNEL-APP-SWITCHER",
                    "UX-SECURITY-CHANNEL-CAPTURE",
                    "UX-SECURITY-CHANNEL-CLIPBOARD",
                    "UX-SECURITY-CHANNEL-DIAGNOSTICS",
                    "UX-SECURITY-CHANNEL-EXPORT",
                    "UX-SECURITY-CHANNEL-NOTIFICATIONS",
                    "UX-SECURITY-CHANNEL-SPOTLIGHT",
                    "UX-SECURITY-CHANNEL-SUPPORT",
                    "UX-SECURITY-CHANNEL-WIDGETS",
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
                    "UX-SCREEN-YOU-CONTINUITY-CONTROL",
                    "UX-SCREEN-YOU-DATA",
                ],
            ),
        }
        for requirement_id, expected in fixtures.items():
            self.assertEqual(by_id[requirement_id]["disposition"], expected[0])
            self.assertEqual(by_id[requirement_id]["blueprint_ids"], expected[1])

        summary = module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(summary.disposition_count, 449)

    def test_each_screen_has_nine_fail_closed_taxonomy_dispositions(self):
        module = self._module()
        payload = self._payload()
        screen_ids = {item["blueprint_id"] for item in payload["screens"]}

        self.assertEqual(len(payload["state_models"]), len(screen_ids))
        self.assertEqual(
            {item["screen_id"] for item in payload["state_models"]}, screen_ids
        )
        for model in payload["state_models"]:
            variants_by_kind = {}
            for variant in model["variants"]:
                variants_by_kind.setdefault(variant["generic_kind"], []).append(
                    variant["blueprint_id"]
                )
            self.assertEqual(
                {item["generic_kind"] for item in model["taxonomy"]}, STATE_KINDS
            )
            self.assertEqual(len(model["taxonomy"]), 9)
            for disposition in model["taxonomy"]:
                self.assertEqual(set(disposition), TAXONOMY_FIELDS)
                self.assertTrue(disposition["rationale"])
                expected = sorted(
                    variants_by_kind.get(disposition["generic_kind"], [])
                )
                if expected:
                    self.assertEqual(disposition["applicability"], "applicable")
                    self.assertEqual(disposition["variant_ids"], expected)
                else:
                    self.assertEqual(
                        disposition["applicability"], "not_applicable"
                    )
                    self.assertEqual(disposition["variant_ids"], [])

        summary = module.validate_ux_blueprint(REPO_ROOT, payload)
        self.assertEqual(summary.state_model_count, 47)
        self.assertEqual(summary.state_taxonomy_count, 423)

    def test_state_validator_rejects_taxonomy_omission_mutation_and_orphaning(self):
        module = self._module()

        missing = self._payload()
        del missing["state_models"][0]["taxonomy"][0]["variant_ids"]
        with self.assertRaisesRegex(module.UXBlueprintError, "state taxonomy fields"):
            module.validate_ux_blueprint(REPO_ROOT, missing)

        duplicate = self._payload()
        duplicate["state_models"][0]["taxonomy"][0]["generic_kind"] = duplicate[
            "state_models"
        ][0]["taxonomy"][1]["generic_kind"]
        with self.assertRaisesRegex(module.UXBlueprintError, "taxonomy variant disposition"):
            module.validate_ux_blueprint(REPO_ROOT, duplicate)

        orphaned = self._payload()
        applicable = next(
            item
            for item in orphaned["state_models"][0]["taxonomy"]
            if item["applicability"] == "applicable"
        )
        applicable["variant_ids"] = []
        with self.assertRaisesRegex(module.UXBlueprintError, "taxonomy variant disposition"):
            module.validate_ux_blueprint(REPO_ROOT, orphaned)

    def test_renderer_includes_complete_state_contracts(self):
        module = self._module()
        payload = self._payload()
        rendered = module.render_ux_blueprint_markdown(payload, REPO_ROOT).decode()

        self.assertIn("## State taxonomy dispositions", rendered)
        self.assertIn("## Canonical named state variants", rendered)
        for field in ("Generic kind", "Applicability", "Named variant IDs"):
            self.assertIn(field, rendered)
        self.assertIn("`UX-STATE-VARIANT-ACCOUNT-BOUNDARY-LOCAL-ONLY`", rendered)

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
            payload["sensitive_exposure_channels"],
        )
        for group in groups:
            for record in group:
                self.assertEqual(record["implementation_status"], "design_input_only")
                self.assertEqual(record["proof_ceiling"], module.RECORD_PROOF_CEILING)
        for model in payload["state_models"]:
            for variant in model["variants"]:
                self.assertEqual(variant["implementation_status"], "design_input_only")
                self.assertEqual(variant["proof_ceiling"], module.RECORD_PROOF_CEILING)

        overclaim = self._payload()
        overclaim["journeys"][0]["proof_ceiling"] = "Runtime Green"
        with self.assertRaisesRegex(module.UXBlueprintError, "record proof ceiling"):
            module.validate_ux_blueprint(REPO_ROOT, overclaim)

    def test_declared_sources_are_digest_bound_and_git_source_is_reviewed_commit(self):
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
                ["git", "cat-file", "-e", f"{source_sha}^{{commit}}"],
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
