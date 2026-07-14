import copy
import json
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
FIXTURE_PATH = (
    REPO_ROOT
    / "tests/canon/fixtures/ux-blueprint-final-all-corpus-copy-fixtures.json"
)


class UXBlueprintAllCorpusReviewTests(unittest.TestCase):
    def _module(self):
        from tools.ambitions_canon import ux_blueprint

        return ux_blueprint

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text()
        )

    def _states(self, payload):
        return {
            (model["screen_id"], variant["variant_key"]): variant
            for model in payload["state_models"]
            for variant in model["variants"]
        }

    def _fixture(self):
        return json.loads(FIXTURE_PATH.read_text())["states"]

    def test_exact_18_reviewed_records_are_bound_to_plain_user_consequences(self):
        fixture = self._fixture()
        self.assertEqual(len(fixture), 18)
        owners = {(item["screen_id"], item["variant_key"]) for item in fixture}
        self.assertEqual(len(owners), 18)
        states = self._states(self._payload())
        gap_blocked = 0
        backed = 0
        for item in fixture:
            owner = (item["screen_id"], item["variant_key"])
            with self.subTest(owner=owner):
                state = states[owner]
                self.assertEqual(
                    state["behavior_authority_posture"],
                    item["behavior_authority_posture"],
                )
                self.assertEqual(
                    state["visible_content_copy"], item["visible_content_copy"]
                )
                self.assertFalse(
                    self._module().all_corpus_visible_copy_exposes_internal_language(
                        state["blueprint_id"], state["visible_content_copy"]
                    )
                )
                if state["behavior_authority_posture"] == "requirement_backed":
                    backed += 1
                else:
                    gap_blocked += 1
                    self.assertEqual(state["allowed_commands"], [])
                    self.assertTrue(state["specification_gap_ids"])
        self.assertEqual((gap_blocked, backed), (18, 0))

    def test_internal_language_detection_is_boundary_aware_and_permutation_proof(self):
        module = self._module()
        variant_id = "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED"
        internal_examples = (
            "The authoritative saved local copy remains unchanged.",
            "The local copy remains authoritative.",
            "Current saved information remains the authority.",
            "The authority for saved information remains current.",
            "A duplicate owner controls this presentation.",
            "The presentation has a duplicate owner.",
            "Capture and Search remain global actions while no overlay is shown.",
            "Focus returns to the originating object control.",
            "The Capture route selected a local object type.",
            "Stale completion is not replayed.",
            "Active Execution says execution is active.",
            "The closure consequence follows the closure contract.",
            "Recovery begins from the durable Step state.",
            "The trust state is matched to the current subject.",
            "Corrective receipts preserve semantic grouping.",
        )
        for value in internal_examples:
            with self.subTest(value=value):
                self.assertTrue(
                    module.all_corpus_visible_copy_exposes_internal_language(
                        variant_id, value
                    )
                )

        legitimate_route_copy = (
            "The Goal Path route is visible. The selected Goal remains unchanged."
        )
        self.assertFalse(
            module.all_corpus_visible_copy_exposes_internal_language(
                variant_id, legitimate_route_copy
            )
        )

        payload = self._payload()
        forged = copy.deepcopy(payload)
        state = self._states(forged)[
            ("UX-SCREEN-ACCOUNT-BOUNDARY", "continuity-conflicted")
        ]
        state["visible_content_copy"] = internal_examples[1]
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "all-corpus visible copy exposes internal language",
        ):
            module.validate_ux_blueprint(REPO_ROOT, forged)

    def test_prior_copy_guards_remain_closed(self):
        payload = self._payload()
        states = self._states(payload)
        final_review = {
            state["blueprint_id"]
            for state in states.values()
            if state["visible_content_copy"]
        }
        self.assertEqual(len(final_review), 432)

        prior_gap_fixture = json.loads(
            (
                REPO_ROOT
                / "tests/canon/fixtures/ux-blueprint-gap-blocked-copy-fixtures.json"
            ).read_text()
        )["states"]
        self.assertEqual(len(prior_gap_fixture), 21)
        for item in prior_gap_fixture:
            owner = (item["screen_id"], item["variant_key"])
            self.assertEqual(
                states[owner]["visible_content_copy"], item["visible_content_copy"]
            )


if __name__ == "__main__":
    unittest.main()
