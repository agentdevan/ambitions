import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]


class UXBlueprintTests(unittest.TestCase):
    def _module(self):
        spec = importlib.util.find_spec("tools.ambitions_canon.ux_blueprint")
        self.assertIsNotNone(spec, "UX blueprint validator is not implemented")
        from tools.ambitions_canon import ux_blueprint

        return ux_blueprint

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text(
                encoding="utf-8"
            )
        )

    def test_complete_blueprint_is_requirement_linked_and_non_authoritative(self):
        module = self._module()
        blueprint = module.load_ux_blueprint(REPO_ROOT)
        summary = module.validate_ux_blueprint(REPO_ROOT, blueprint)

        self.assertEqual(blueprint["authority_state"], "shadow")
        self.assertEqual(blueprint["status"], "design_input_non_authoritative")
        self.assertEqual(
            blueprint["source_sha"],
            "857f4bce2aee2fba104f74bf08a5623a3debfccc",
        )
        self.assertEqual(summary.screen_count, 47)
        self.assertEqual(summary.state_model_count, 47)
        self.assertEqual(summary.state_taxonomy_count, 423)
        self.assertEqual(summary.object_boundary_count, 18)
        self.assertEqual(summary.journey_count, 12)
        self.assertEqual(summary.cross_cutting_count, 11)
        self.assertGreaterEqual(summary.requirement_link_count, 180)
        self.assertEqual(summary.disposition_count, 441)
        self.assertEqual(
            summary.visual_mapping_count + summary.nonvisual_count,
            441,
        )
        self.assertRegex(summary.disposition_sha256, r"^[0-9a-f]{64}$")
        disposition_projection = json.loads(
            (
                REPO_ROOT
                / "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(disposition_projection["requirement_count"], 441)
        self.assertEqual(len(disposition_projection["dispositions"]), 441)
        self.assertEqual(
            len(
                {
                    item["requirement_id"]
                    for item in disposition_projection["dispositions"]
                }
            ),
            441,
        )
        self.assertEqual(
            disposition_projection["disposition_sha256"],
            summary.disposition_sha256,
        )

    def test_blueprint_covers_required_product_and_accessibility_scope(self):
        module = self._module()
        blueprint = module.load_ux_blueprint(REPO_ROOT)
        summary = module.validate_ux_blueprint(REPO_ROOT, blueprint)

        self.assertEqual(
            set(summary.scope_ids),
            {
                "account",
                "app-shell",
                "capture",
                "goals",
                "offline-degraded",
                "permissions",
                "search",
                "setup",
                "time",
                "today",
                "trust",
                "you",
            },
        )
        self.assertEqual(
            set(summary.state_kinds),
            {
                "degraded",
                "empty",
                "failure",
                "interruption",
                "loading",
                "recovery",
                "resting",
                "rollback",
                "transitional",
            },
        )
        self.assertEqual(
            set(summary.accessibility_facets),
            {
                "dynamic-type",
                "focus-keyboard",
                "light-dark",
                "localization-long-copy",
                "motion-haptics",
                "non-color-semantics",
                "reduce-motion",
                "reduce-transparency",
                "sensitive-exposure-channels",
                "swiftui-anatomy",
                "voiceover-reading-order",
            },
        )
        self.assertEqual(
            set(summary.object_ids),
            {
                "attachment",
                "closure",
                "event",
                "goal",
                "goal-path",
                "history-event",
                "import-diff-record",
                "life-area",
                "note",
                "notification-rule",
                "proof",
                "receipt",
                "recovery-segment",
                "reminder",
                "saved-for-later-draft",
                "schedule-placement",
                "source-reference",
                "step",
            },
        )

    def test_validator_rejects_unknown_requirement_placeholder_and_legacy_final_authority(self):
        module = self._module()
        payload = self._payload()

        unknown = copy.deepcopy(payload)
        unknown["screens"][0]["requirement_ids"].append("UNKNOWN-REQ-001")
        with self.assertRaisesRegex(module.UXBlueprintError, "unknown requirement"):
            module.validate_ux_blueprint(REPO_ROOT, unknown)

        placeholder = copy.deepcopy(payload)
        placeholder["screens"][0]["purpose"] = "Implement later"
        with self.assertRaisesRegex(module.UXBlueprintError, "placeholder"):
            module.validate_ux_blueprint(REPO_ROOT, placeholder)

        legacy = copy.deepcopy(payload)
        legacy["legacy_figma_policy"]["allowed_roles"].append("final_authority")
        legacy["legacy_figma_policy"]["allowed_roles"].sort()
        with self.assertRaisesRegex(module.UXBlueprintError, "legacy Figma"):
            module.validate_ux_blueprint(REPO_ROOT, legacy)

    def test_validator_rejects_duplicate_or_unsorted_blueprint_ids(self):
        module = self._module()
        payload = self._payload()

        duplicate = copy.deepcopy(payload)
        duplicate["screens"][1]["blueprint_id"] = duplicate["screens"][0][
            "blueprint_id"
        ]
        with self.assertRaisesRegex(module.UXBlueprintError, "globally unique typed"):
            module.validate_ux_blueprint(REPO_ROOT, duplicate)

        unsorted = copy.deepcopy(payload)
        unsorted["screens"][0], unsorted["screens"][1] = (
            unsorted["screens"][1],
            unsorted["screens"][0],
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "sorted"):
            module.validate_ux_blueprint(REPO_ROOT, unsorted)

    def test_validator_freezes_canon_linear_and_source_provenance(self):
        module = self._module()
        payload = self._payload()

        active = copy.deepcopy(payload)
        active["authority_state"] = "active"
        with self.assertRaisesRegex(module.UXBlueprintError, "shadow"):
            module.validate_ux_blueprint(REPO_ROOT, active)

        changed_linear = copy.deepcopy(payload)
        changed_linear["primary_linear_v3"]["disposition"] = "rewritten"
        with self.assertRaisesRegex(module.UXBlueprintError, "primary Linear V3"):
            module.validate_ux_blueprint(REPO_ROOT, changed_linear)

        stale_source = copy.deepcopy(payload)
        stale_source["source_sha"] = "0" * 40
        with self.assertRaisesRegex(module.UXBlueprintError, "source SHA"):
            module.validate_ux_blueprint(REPO_ROOT, stale_source)

    def test_validator_rejects_implementation_and_proof_overclaims_or_unknown_sources(self):
        module = self._module()

        implemented = self._payload()
        implemented["screens"][0]["implementation_status"] = "implemented_green"
        with self.assertRaisesRegex(module.UXBlueprintError, "design input only"):
            module.validate_ux_blueprint(REPO_ROOT, implemented)

        overclaim = self._payload()
        overclaim["claim_ceiling"] = "Rendered-app Visual Green"
        with self.assertRaisesRegex(module.UXBlueprintError, "claim ceiling"):
            module.validate_ux_blueprint(REPO_ROOT, overclaim)

        unknown_source = self._payload()
        unknown_source["source_documents"].append(
            {"path": "docs/canon/unknown-source.md", "sha256": "0" * 64}
        )
        unknown_source["source_documents"].sort(key=lambda item: item["path"])
        with self.assertRaisesRegex(module.UXBlueprintError, "source document"):
            module.validate_ux_blueprint(REPO_ROOT, unknown_source)

    def test_requirement_dispositions_fail_closed_for_missing_duplicate_and_unknown_sources(self):
        module = self._module()
        payload = self._payload()

        missing = copy.deepcopy(payload)
        missing["requirement_dispositions"].pop(0)
        with self.assertRaisesRegex(module.UXBlueprintError, "missing requirement disposition"):
            module.validate_ux_blueprint(REPO_ROOT, missing)

        duplicate = copy.deepcopy(payload)
        duplicate["requirement_dispositions"].insert(
            1, copy.deepcopy(duplicate["requirement_dispositions"][0])
        )
        with self.assertRaisesRegex(module.UXBlueprintError, "duplicate requirement disposition"):
            module.validate_ux_blueprint(REPO_ROOT, duplicate)

        unknown = copy.deepcopy(payload)
        unknown["requirement_dispositions"][0]["requirement_id"] = "UNKNOWN-001"
        with self.assertRaisesRegex(module.UXBlueprintError, "unknown requirement disposition"):
            module.validate_ux_blueprint(REPO_ROOT, unknown)

    def test_renderer_is_deterministic_newline_terminated_and_checked_in(self):
        module = self._module()
        blueprint = module.load_ux_blueprint(REPO_ROOT)
        rendered_a = module.render_ux_blueprint_markdown(blueprint)
        rendered_b = module.render_ux_blueprint_markdown(copy.deepcopy(blueprint))

        self.assertEqual(rendered_a, rendered_b)
        self.assertTrue(rendered_a.endswith(b"\n"))
        self.assertNotIn(b"generated_at", rendered_a)
        self.assertEqual(
            rendered_a,
            (REPO_ROOT / "docs/canon/migration/UX_BLUEPRINT.md").read_bytes(),
        )

    def test_json_schema_and_validator_reject_open_or_missing_fields(self):
        module = self._module()
        schema = json.loads(
            (REPO_ROOT / "docs/canon/schemas/ux-blueprint.schema.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertFalse(schema["additionalProperties"])

        payload = self._payload()
        payload["unexpected"] = True
        with self.assertRaisesRegex(module.UXBlueprintError, "top-level fields"):
            module.validate_ux_blueprint(REPO_ROOT, payload)

        payload = self._payload()
        del payload["journeys"][0]["rollback"]
        with self.assertRaisesRegex(module.UXBlueprintError, "journey fields"):
            module.validate_ux_blueprint(REPO_ROOT, payload)

    def test_cli_check_is_offline_and_detects_projection_drift(self):
        module = self._module()
        self.assertEqual(module.check_ux_blueprint(REPO_ROOT), 0)

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for relative in (
                "docs/canon/migration/ux-blueprint.json",
                "docs/canon/generated/canon-index.json",
                "docs/canon/generated/requirement-graph.json",
                "docs/canon/migration/UX_BLUEPRINT.md",
                "docs/canon/migration/ux-blueprint-requirement-dispositions.json",
            ):
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((REPO_ROOT / relative).read_bytes())
            (root / "docs/canon/migration/UX_BLUEPRINT.md").write_text(
                "drift\n", encoding="utf-8"
            )
            self.assertEqual(module.check_ux_blueprint(root), 1)

    def test_canon_cli_exposes_ux_blueprint_check(self):
        from tools.ambitions_canon.cli import main

        self.assertEqual(main(["ux-blueprint", "--check"]), 0)


if __name__ == "__main__":
    unittest.main()
