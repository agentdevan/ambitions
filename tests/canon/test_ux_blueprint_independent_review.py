import copy
import json
import re
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
class UXBlueprintIndependentReviewTests(unittest.TestCase):
    def _module(self):
        from tools.ambitions_canon import ux_blueprint
        return ux_blueprint

    def _payload(self):
        return json.loads((REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text())

    def _state(self, payload, screen_id, key):
        model = next(item for item in payload["state_models"] if item["screen_id"] == screen_id)
        return next(item for item in model["variants"] if item["variant_key"] == key)

    def test_postures_are_mixed_and_directly_grounded_commands_are_restored(self):
        payload = self._payload()
        module = self._module()
        states = [variant for model in payload["state_models"] for variant in model["variants"]]
        backed = [item for item in states if item["behavior_authority_posture"] == "requirement_backed"]
        blocked = [item for item in states if item["behavior_authority_posture"] == "exploratory_blocked_by_specification_gap"]
        eligible_ids = module.authority_eligible_state_variant_ids(payload, REPO_ROOT)
        self.assertGreater(len(backed), 50)
        self.assertGreater(len(blocked), 50)
        expected = {
            ("UX-SCREEN-TODAY-ROOT", "empty"): ["Capture", "Review Goals", "View Time"],
            ("UX-SCREEN-TODAY-ROOT", "populated"): ["Start now", "Open step", "Capture", "View Time"],
            ("UX-SCREEN-TODAY-DETAIL", "viewing"): ["Start now", "Open Trust", "Back"],
            ("UX-SCREEN-TIME-DAY", "populated"): ["Open Time Object", "Create", "Switch Time View"],
            ("UX-SCREEN-TRUST-DEEP", "source-current"): ["Open Source", "Return to Subject"],
            ("UX-SCREEN-TRUST-RECEIPT", "receipt-committed-undo-eligible"): ["Undo", "Keep Change", "Review Receipt"],
            ("UX-SCREEN-CAPTURE-COMPOSER", "blank"): ["Choose Type", "Add Attachment", "Save for Later", "Close Capture"],
            ("UX-SCREEN-CAPTURE-COMPOSER", "discard-review"): ["Keep Editing", "Save for Later", "Discard Draft"],
            ("UX-SCREEN-CAPTURE-PROPOSAL", "proposal-ready"): ["Confirm Proposal", "Edit Proposal", "Save for Later"],
        }
        for owner, commands in expected.items():
            state = self._state(payload, *owner)
            self.assertEqual(state["behavior_authority_posture"], "requirement_backed", owner)
            self.assertEqual(state["allowed_commands"], commands, owner)
            self.assertTrue(state["behavior_requirement_ids"], owner)
            self.assertFalse(state["specification_gap_ids"], owner)
            self.assertIn(state["blueprint_id"], eligible_ids)
        for state in blocked:
            self.assertEqual(state["allowed_commands"], [])
            self.assertTrue(state["specification_gap_ids"])
            self.assertNotIn(state["blueprint_id"], eligible_ids)

    def test_visible_copy_is_user_facing_specific_and_not_governance_prose(self):
        payload = self._payload()
        forbidden = re.compile(r"UX-|GAP-|shows the current consequence|specification-gap|current canon", re.IGNORECASE)
        copies = []
        for model in payload["state_models"]:
            for state in model["variants"]:
                copy_value = state["visible_content_copy"]
                if state["blueprint_id"] == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE":
                    self.assertEqual(copy_value, "")
                    continue
                self.assertIsNone(forbidden.search(copy_value), state["blueprint_id"])
                self.assertGreaterEqual(len(copy_value.split()), 5, state["blueprint_id"])
                copies.append(copy_value)
        self.assertGreater(len(set(copies)), 400)

    def test_new_owner_state_laws_are_exact(self):
        payload = self._payload()
        models = {item["screen_id"]: item["variants"] for item in payload["state_models"]}
        required = {
            "UX-SCREEN-APP-LAUNCH-GATE": {"APP-LAUNCH-READINESS-001"},
            "UX-SCREEN-APP-DEEP-LINK-INTAKE": {"APP-DEEP-LINK-STATE-001"},
            "UX-SCREEN-YOU-ENTITLEMENT": {"ENTITLEMENT-001", "ENTITLEMENT-002"},
            "UX-SCREEN-YOU-CONTINUITY-CONTROL": {"SYSTEM-CONTINUITY-SEPARATION-001", "SYSTEM-CONTINUITY-DISABLED-001", "SYSTEM-CONTINUITY-FAILURE-001"},
            "UX-SCREEN-YOU-DIAGNOSTICS": {"SYSTEM-DIAGNOSTICS-HEALTH-001"},
            "UX-SCREEN-YOU-NOTIFICATIONS": {"SYSTEM-NOTIFICATIONS-EFFECT-001"},
            "UX-SCREEN-TIME-DEGRADED": {"APP-DEGRADED-STATE-001", "APP-DEGRADED-PRESENTATION-001"},
        }
        for screen_id, laws in required.items():
            for state in models[screen_id]:
                self.assertTrue(laws <= set(state["requirement_ids"]), state["blueprint_id"])
        for screen_id in required:
            if screen_id.startswith("UX-SCREEN-YOU-"):
                for state in models[screen_id]:
                    if screen_id not in {"UX-SCREEN-YOU-CONTINUITY-CONTROL"}:
                        self.assertNotIn("SPEC-SURFACE-YOU-PRIVACY-DATA-BOUNDARY-001", state["requirement_ids"])

    def test_disposition_rationale_ids_exactly_match_structured_edges(self):
        payload = self._payload()
        known = {item["blueprint_id"] for group in ("screens", "state_models", "object_boundaries", "journeys", "cross_cutting", "sensitive_exposure_channels") for item in payload[group]}
        known.update(state["blueprint_id"] for model in payload["state_models"] for state in model["variants"])
        for item in payload["requirement_dispositions"]:
            described = set(re.findall(r"UX-[A-Z0-9-]+", item["rationale"]))
            structured = set(item["blueprint_ids"]) | set(item["state_blueprint_ids"])
            self.assertEqual(described, structured, item["requirement_id"])
            self.assertFalse(described - known, item["requirement_id"])

    def test_setup_lifecycle_content_and_resume_checkpoint_mapping_are_separate(self):
        payload = self._payload()
        contract = payload["setup_contract"]
        self.assertEqual(contract["lifecycle_states"], ["in-progress", "not-started", "revisitable", "skipped", "sufficient-for-local-use"])
        self.assertEqual([item["content_id"] for item in contract["subordinate_content"]], ["optional-account", "permissions-choice", "welcome"])
        first_use = {item["variant_key"] for item in next(model for model in payload["state_models"] if model["screen_id"] == "UX-SCREEN-SETUP-FIRST-USE")["variants"]}
        self.assertEqual(first_use, set(contract["lifecycle_states"]))
        resume = next(model for model in payload["state_models"] if model["screen_id"] == "UX-SCREEN-SETUP-RESUME")
        mapping = contract["resume_checkpoint_mapping"]
        self.assertEqual(set(mapping), {item["variant_key"] for item in resume["variants"]})
        self.assertTrue(set(mapping.values()) <= set(contract["lifecycle_states"]))

    def test_all_state_taxonomy_assignments_use_closed_fields(self):
        payload = self._payload()
        rows = []
        for model in payload["state_models"]:
            for state in model["variants"]:
                rows.append([model["screen_id"], state["variant_key"], state["generic_kind"], state["state_axis"], state["operation_phase"]])
        self.assertEqual(len(rows), 433)
        self.assertTrue(all(all(value for value in row) for row in rows))

    def test_authority_eligibility_revalidates_the_whole_blueprint(self):
        payload = self._payload()
        module = self._module()
        state = self._state(payload, "UX-SCREEN-TODAY-ROOT", "empty")
        self.assertTrue(module.state_variant_is_authority_eligible(payload, state["blueprint_id"], REPO_ROOT))

        posture_only = copy.deepcopy(payload)
        blocked = next(v for m in posture_only["state_models"] for v in m["variants"] if v["behavior_authority_posture"] == "exploratory_blocked_by_specification_gap")
        blocked["behavior_authority_posture"] = "requirement_backed"
        self.assertFalse(module.state_variant_is_authority_eligible(posture_only, blocked["blueprint_id"], REPO_ROOT))

        simultaneous = copy.deepcopy(payload)
        backed = next(v for m in simultaneous["state_models"] for v in m["variants"] if v["behavior_authority_posture"] == "requirement_backed")
        backed["specification_gap_ids"] = ["GAP-UX-COMMAND-CONTRACT-TODAY-001"]
        self.assertFalse(module.state_variant_is_authority_eligible(simultaneous, backed["blueprint_id"], REPO_ROOT))

        missing = copy.deepcopy(payload)
        backed = next(v for m in missing["state_models"] for v in m["variants"] if v["behavior_authority_posture"] == "requirement_backed")
        backed["behavior_requirement_ids"] = []
        self.assertFalse(module.state_variant_is_authority_eligible(missing, backed["blueprint_id"], REPO_ROOT))

        stale = copy.deepcopy(payload)
        stale["source_sha"] = "0" * 40
        self.assertFalse(module.state_variant_is_authority_eligible(stale, state["blueprint_id"], REPO_ROOT))
        self.assertFalse(module.state_variant_is_authority_eligible(payload, "UX-STATE-VARIANT-UNKNOWN", REPO_ROOT))


if __name__ == "__main__":
    unittest.main()
