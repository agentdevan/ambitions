import copy
import hashlib
import json
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
FIXTURE_PATH = (
    REPO_ROOT
    / "tests/canon/fixtures/ux-blueprint-semantic-residual-docket.json"
)
EXPECTED_SHA256 = "1db28462d482ee6f4937e3a58ba324d0fc07ec11ef8d6e5c87c0a45e97427640"
PREVIOUSLY_UNCOVERED_GAP_PHRASES = (
    "will not run again",
    "will not repeat a completed action",
    "will open this link after checking its destination and access",
    "until it is finished or dismissed",
    "until the user confirms",
    "for review before it joins the Capture",
    "recovery choices are considered",
    "next review point visible",
    "needs a user review",
    "both choices remain visible",
    "protected for review",
    "whether this permission can be requested",
    "confirmed search action is being applied locally",
    "selected search action was not accepted",
    "selected search action is being checked",
    "opening the selected item’s inspection view",
    "until you resume",
    "can be revisited later",
    "waiting for review before they can alter",
    "until review",
    "Decisions must not treat it as current until refresh succeeds",
    "until the user reviews a safe resolution",
    "can be recovered",
    "proposed repair and its consequences are visible before anything changes",
    "will be validated against current local information",
    "choices remain changeable later",
    "Changes still follow the confirmation choices shown here",
)


class UXBlueprintSemanticResidualDocketTests(unittest.TestCase):
    def _module(self):
        from tools.ambitions_canon import ux_blueprint

        return ux_blueprint

    def _payload(self):
        return json.loads(
            (REPO_ROOT / "docs/canon/migration/ux-blueprint.json").read_text()
        )

    def _states(self, payload):
        return {
            variant["blueprint_id"]: variant
            for model in payload["state_models"]
            for variant in model["variants"]
        }

    def _docket(self):
        return json.loads(FIXTURE_PATH.read_text())

    def test_exact_reviewed_docket_bytes_schema_and_counts_are_frozen(self):
        fixture_bytes = FIXTURE_PATH.read_bytes()
        self.assertEqual(hashlib.sha256(fixture_bytes).hexdigest(), EXPECTED_SHA256)
        docket = json.loads(fixture_bytes)
        self.assertEqual(docket["schema"], "ambitions.ux-blueprint.semantic-residual-docket")
        self.assertEqual(docket["version"], 1)
        self.assertEqual(
            docket["counts"],
            {
                "state_variants_audited": 433,
                "nonempty_visible_copies_audited": 432,
                "intentional_empty_visible_copies": 1,
                "offending_state_variants": 125,
                "internal_language_state_variants": 82,
                "gap_action_implication_state_variants": 46,
                "overlap_state_variants": 3,
            },
        )
        offenders = docket["offenders"]
        self.assertEqual(len(offenders), 125)
        self.assertEqual(len({item["blueprint_id"] for item in offenders}), 125)
        internal = sum("internal_language" in item["category"] for item in offenders)
        gap_action = sum(
            "gap_action_implication" in item["category"] for item in offenders
        )
        overlap = sum(len(item["category"]) == 2 for item in offenders)
        self.assertEqual((internal, gap_action, overlap), (82, 46, 3))

    def test_every_frozen_offender_is_rewritten_and_live_residual_is_empty(self):
        module = self._module()
        payload = self._payload()
        states = self._states(payload)
        docket = self._docket()
        for item in docket["offenders"]:
            with self.subTest(blueprint_id=item["blueprint_id"]):
                state = states[item["blueprint_id"]]
                self.assertNotEqual(state["visible_content_copy"], item["exact_copy"])

        internal_residual = {}
        gap_action_residual = {}
        nonempty = 0
        intentional_empty = 0
        for state in states.values():
            copy_value = state["visible_content_copy"]
            if not copy_value:
                intentional_empty += 1
                continue
            nonempty += 1
            internal_matches = module.semantic_corpus_internal_language_matches(
                copy_value
            )
            if internal_matches:
                internal_residual[state["blueprint_id"]] = internal_matches
            if state["behavior_authority_posture"] == "exploratory_blocked_by_specification_gap":
                gap_matches = module.semantic_corpus_gap_action_implication_matches(
                    copy_value
                )
                if gap_matches:
                    gap_action_residual[state["blueprint_id"]] = gap_matches
        self.assertEqual((len(states), nonempty, intentional_empty), (433, 432, 1))
        self.assertEqual(internal_residual, {})
        self.assertEqual(gap_action_residual, {})

    def test_detectors_are_corpus_wide_permutation_safe_and_keep_neutral_copy(self):
        module = self._module()
        internal_examples = (
            "Current local state remains the authority.",
            "Authority remains with the current local state.",
            "These actions are owned by the selected item type.",
            "The selected item type owns these actions.",
            "A local object remains after the command committed.",
            "This drilldown shows the canonical projection.",
        )
        for value in internal_examples:
            with self.subTest(value=value):
                self.assertTrue(module.semantic_corpus_internal_language_matches(value))

        gap_examples = (
            "Condition. Review the change.",
            "Condition; Review the change.",
            "Condition: Review the change.",
            "Condition — Review the change.",
            "The user can restore the item.",
            "This issue is ready for correction.",
            "Opening the item rechecks its saved value.",
        )
        for value in gap_examples:
            with self.subTest(value=value):
                self.assertTrue(
                    module.semantic_corpus_gap_action_implication_matches(value)
                )

        for value in self._docket()["corpus_wide_validator_recommendations"][
            "neutral_counterexamples"
        ]:
            with self.subTest(neutral=value):
                self.assertFalse(module.semantic_corpus_internal_language_matches(value))
                self.assertFalse(
                    module.semantic_corpus_gap_action_implication_matches(value)
                )

    def test_every_frozen_gap_phrase_and_all_27_generic_misses_are_enforced(self):
        module = self._module()
        gap_offenders = [
            item
            for item in self._docket()["offenders"]
            if "gap_action_implication" in item["category"]
        ]
        self.assertEqual(len(gap_offenders), 46)
        phrase_occurrences = [
            (item["blueprint_id"], phrase)
            for item in gap_offenders
            for phrase in item["exact_offending_phrases"]["gap_action_implication"]
        ]
        self.assertEqual(len(phrase_occurrences), 47)
        for blueprint_id, phrase in phrase_occurrences:
            with self.subTest(blueprint_id=blueprint_id, phrase=phrase):
                self.assertTrue(
                    module.semantic_corpus_gap_action_implication_matches(phrase)
                )

    def test_nonempty_visible_copy_rejects_productivity_score_case_insensitively(self):
        module = self._module()
        payload = self._payload()
        self.assertIsNotNone(
            module.BANNED_VISIBLE_INTERNAL_LANGUAGE.search("PrOdUcTiViTy ScOrE")
        )
        for state in self._states(payload).values():
            copy_value = state["visible_content_copy"]
            if not copy_value:
                continue
            with self.subTest(blueprint_id=state["blueprint_id"]):
                self.assertNotIn("productivity score", copy_value.casefold())

        self.assertTrue(
            any(
                "productivity scores" in item["rationale"].casefold()
                for item in payload["requirement_dispositions"]
            )
        )

        self.assertEqual(len(PREVIOUSLY_UNCOVERED_GAP_PHRASES), 27)
        for phrase in PREVIOUSLY_UNCOVERED_GAP_PHRASES:
            with self.subTest(previously_uncovered=phrase):
                self.assertTrue(
                    module.semantic_corpus_gap_action_implication_matches(phrase)
                )

    def test_validator_enforces_detectors_outside_the_review_fixture(self):
        module = self._module()
        payload = self._payload()
        states = self._states(payload)
        docket_ids = {item["blueprint_id"] for item in self._docket()["offenders"]}

        outside_internal = next(
            state
            for state in states.values()
            if state["blueprint_id"] not in docket_ids
            and state["visible_content_copy"]
        )
        forged_internal = copy.deepcopy(payload)
        self._states(forged_internal)[outside_internal["blueprint_id"]][
            "visible_content_copy"
        ] = "Current local state remains the canonical authority."
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "semantic corpus visible copy exposes internal language",
        ):
            module.validate_ux_blueprint(REPO_ROOT, forged_internal)

        outside_gap = next(
            state
            for state in states.values()
            if state["blueprint_id"] not in docket_ids
            and state["behavior_authority_posture"]
            == "exploratory_blocked_by_specification_gap"
        )
        forged_gap = copy.deepcopy(payload)
        self._states(forged_gap)[outside_gap["blueprint_id"]][
            "visible_content_copy"
        ] = "The condition is visible; Review the change now."
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "semantic corpus gap-blocked copy implies an action",
        ):
            module.validate_ux_blueprint(REPO_ROOT, forged_gap)

        outside_gap_ids = (
            "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY",
            "UX-STATE-VARIANT-APP-LAUNCH-GATE-QUARANTINED",
        )
        reintroduced = ("will not run again", "protected for review")
        for blueprint_id, phrase in zip(outside_gap_ids, reintroduced):
            self.assertNotIn(blueprint_id, docket_ids)
            forged = copy.deepcopy(payload)
            self._states(forged)[blueprint_id]["visible_content_copy"] = (
                f"The condition remains visible. Saved information is {phrase}."
            )
            with self.subTest(blueprint_id=blueprint_id, phrase=phrase):
                with self.assertRaisesRegex(
                    module.UXBlueprintError,
                    "semantic corpus gap-blocked copy implies an action",
                ):
                    module.validate_ux_blueprint(REPO_ROOT, forged)


if __name__ == "__main__":
    unittest.main()
