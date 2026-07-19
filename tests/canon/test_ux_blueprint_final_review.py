import copy
import json
import re
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MATRIX_SHA256 = "f319153d552ab557798f289d7e838e94364a2e21b43903343c672af207dbdbbe"
FIXTURE_PATH = (
    REPO_ROOT
    / "tests/canon/fixtures/ux-blueprint-current-delta-owner-taxonomy.json"
)

REMOVED_VARIANT_REPLACEMENTS = {
    ("UX-SCREEN-ACCOUNT-BOUNDARY", "continuity-enabled"): (
        "UX-SCREEN-YOU-CONTINUITY-CONTROL", "enabled-idle"
    ),
    ("UX-SCREEN-ACCOUNT-STATUS", "continuity-conflicted"): (
        "UX-SCREEN-YOU-CONTINUITY-CONTROL", "conflicted-quarantined"
    ),
    ("UX-SCREEN-ACCOUNT-STATUS", "continuity-pending"): (
        "UX-SCREEN-YOU-CONTINUITY-CONTROL", "local-pending"
    ),
    ("UX-SCREEN-ACCOUNT-STATUS", "entitlement-stale"): (
        "UX-SCREEN-YOU-ENTITLEMENT", "unknown"
    ),
    ("UX-SCREEN-APP-SHELL-DRILLDOWN", "dismissed"): (
        "UX-SCREEN-APP-SHELL-DRILLDOWN", "restoration"
    ),
    ("UX-SCREEN-APP-SHELL-DRILLDOWN", "full-screen"): (
        "UX-SCREEN-APP-SHELL-DRILLDOWN", "full-screen-overlay"
    ),
    ("UX-SCREEN-APP-SHELL-DRILLDOWN", "pushed"): (
        "UX-SCREEN-APP-SHELL-DRILLDOWN", "drilldown"
    ),
    ("UX-SCREEN-APP-SHELL-DRILLDOWN", "restored"): (
        "UX-SCREEN-APP-SHELL-DRILLDOWN", "restoration"
    ),
    ("UX-SCREEN-APP-SHELL-DRILLDOWN", "sheet"): (
        "UX-SCREEN-APP-SHELL-DRILLDOWN", "compact-modal"
    ),
    ("UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH", "degraded-local-store"): (
        "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH", "local-store-degradation"
    ),
    ("UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH", "local-healthy"): (
        "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH", "offline-healthy"
    ),
    ("UX-SCREEN-SETUP-FIRST-USE", "complete"): (
        "UX-SCREEN-SETUP-FIRST-USE", "sufficient-for-local-use"
    ),
    ("UX-SCREEN-SETUP-FIRST-USE", "local-ready"): (
        "UX-SCREEN-SETUP-FIRST-USE", "sufficient-for-local-use"
    ),
    ("UX-SCREEN-TODAY-DETAIL", "stale"): (
        "UX-SCREEN-TODAY-DETAIL", "stale-external-context"
    ),
    ("UX-SCREEN-TODAY-ROOT", "normal"): (
        "UX-SCREEN-TODAY-ROOT", "populated"
    ),
    ("UX-SCREEN-TODAY-ROOT", "offline"): (
        "UX-SCREEN-TODAY-ROOT", "offline-healthy"
    ),
    ("UX-SCREEN-TODAY-ROOT", "permission-conflict"): (
        "UX-SCREEN-TODAY-ROOT", "permission-denied"
    ),
    ("UX-SCREEN-TODAY-ROOT", "stale"): (
        "UX-SCREEN-TODAY-ROOT", "stale-external-context"
    ),
}

BANNED_INTERNAL_LANGUAGE = re.compile(
    r"deep link envelope|application launch readiness gate|stop ship data risk|"
    r"time degraded-state owner|review pressure|shape time|inspect privacy law|"
    r"requirement[- ]backed|gap[- ]blocked|specification gap|proof ceiling|"
    r"current canon|canonical owner|architecture vocabulary|release gate|"
    r"\baffecting\b|the last confirmed information remains unchanged|"
    r"available local work remains open, with the limitation explained in place",
    re.IGNORECASE,
)


class UXBlueprintFinalReviewTests(unittest.TestCase):
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

    def _state(self, payload, screen_id, variant_key):
        return self._states(payload)[(screen_id, variant_key)]

    def test_time_detail_has_exact_owner_and_time_views_cannot_authorize_it(self):
        payload = self._payload()
        module = self._module()
        states = {
            item["variant_key"]: item
            for item in next(
                model
                for model in payload["state_models"]
                if model["screen_id"] == "UX-SCREEN-TIME-DETAIL"
            )["variants"]
        }
        self.assertEqual(
            set(states),
            {
                "conflict-review",
                "editing",
                "saved",
                "undo-eligible",
                "undo-unavailable",
                "viewing",
            },
        )
        for key, state in states.items():
            self.assertEqual(
                state["behavior_authority_posture"],
                "requirement_backed",
                key,
            )
            self.assertTrue(state["allowed_commands"], key)
            self.assertEqual(state["specification_gap_ids"], [], key)
            self.assertEqual(
                state["behavior_requirement_ids"],
                ["SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"],
                key,
            )
            self.assertNotIn(
                "SPEC-SURFACE-TIME-VIEWS-001",
                state["behavior_requirement_ids"],
                key,
            )

        forged = copy.deepcopy(payload)
        viewing = self._state(forged, "UX-SCREEN-TIME-DETAIL", "viewing")
        viewing["behavior_authority_posture"] = "requirement_backed"
        viewing["allowed_commands"] = ["Edit"]
        viewing["specification_gap_ids"] = []
        viewing["behavior_requirement_ids"] = ["SPEC-SURFACE-TIME-VIEWS-001"]
        viewing["transition_exit"] = (
            "Edit => destination: native time-object edit form; effect: preserves "
            "the saved object until confirmation; focus: first editable field."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError,
            "allowed commands drift from structured canon|evidence requirement mismatch|state command contract requirements are not linked|unsupported behavior authority",
        ):
            module.validate_ux_blueprint(REPO_ROOT, forged)

    def test_every_exact_undo_command_is_owned_by_undo_recovery_law(self):
        payload = self._payload()
        undo_states = []
        for state in self._states(payload).values():
            if "Undo" not in state["allowed_commands"]:
                continue
            undo_states.append(state["blueprint_id"])
            self.assertIn("CONTROL-UNDO-RECOVERY-001", state["requirement_ids"])
        self.assertEqual(
            undo_states,
            [
                "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE",
                "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE",
                "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-ELIGIBLE",
            ],
        )

    def test_all_visible_copy_and_backed_command_labels_are_plain_user_language(self):
        payload = self._payload()
        module = self._module()
        signatures = {}
        for (screen_id, key), state in self._states(payload).items():
            copy_value = state["visible_content_copy"]
            if state["blueprint_id"] == "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE":
                self.assertEqual(copy_value, "")
                continue
            self.assertTrue(copy_value.strip(), state["blueprint_id"])
            self.assertIsNone(BANNED_INTERNAL_LANGUAGE.search(copy_value), state["blueprint_id"])
            signature = module.normalized_visible_copy_signature(
                copy_value, screen_id, key, state
            )
            self.assertNotIn(signature, signatures, state["blueprint_id"])
            signatures[signature] = state["blueprint_id"]
            if state["behavior_authority_posture"] == "requirement_backed":
                for command in state["allowed_commands"]:
                    self.assertIsNone(
                        BANNED_INTERNAL_LANGUAGE.search(command),
                        f"{state['blueprint_id']} {command}",
                    )
        self.assertEqual(len(signatures), 432)

        representative = {
            ("UX-SCREEN-APP-DEEP-LINK-INTAKE", "queued"): "open this link",
            ("UX-SCREEN-APP-LAUNCH-GATE", "stop-ship-data-risk"): "local data",
            ("UX-SCREEN-TIME-DEGRADED", "permission-denied"): "calendar access",
            ("UX-SCREEN-YOU-ENTITLEMENT", "expired"): "local data",
            ("UX-SCREEN-GOALS-PATH", "draft"): "draft",
            ("UX-SCREEN-YOU-NOTIFICATIONS", "externally-failed"): "related step",
            ("UX-SCREEN-YOU-DIAGNOSTICS", "recoverable"): "recover",
        }
        for owner, phrase in representative.items():
            self.assertIn(
                phrase,
                self._state(payload, *owner)["visible_content_copy"].casefold(),
                owner,
            )

        forged = copy.deepcopy(payload)
        first = self._state(forged, "UX-SCREEN-APP-DEEP-LINK-INTAKE", "queued")
        second = self._state(forged, "UX-SCREEN-APP-DEEP-LINK-INTAKE", "presented")
        first["visible_content_copy"] = (
            "Queued. We will open this link after its destination and permissions are checked."
        )
        second["visible_content_copy"] = (
            "Presented. We will open this link after its destination and permissions are checked."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "normalized visible-copy skeleton is repeated"
        ):
            module.validate_ux_blueprint(REPO_ROOT, forged)

    def test_visible_copy_semantic_bags_and_clause_frequency_reject_permuted_templates(self):
        payload = self._payload()
        module = self._module()
        semantic_bags = {}
        for (screen_id, key), state in self._states(payload).items():
            copy_value = state["visible_content_copy"]
            if not copy_value:
                continue
            signature = module.visible_copy_semantic_bag_signature(
                copy_value, screen_id, key, state
            )
            self.assertNotIn(signature, semantic_bags, state["blueprint_id"])
            semantic_bags[signature] = state["blueprint_id"]
        self.assertEqual(len(semantic_bags), 432)

        reordered = copy.deepcopy(payload)
        first = self._state(reordered, "UX-SCREEN-ACCOUNT-BOUNDARY", "account-identity-only")
        second = self._state(reordered, "UX-SCREEN-ACCOUNT-BOUNDARY", "local-only")
        first["visible_content_copy"] = (
            "Account identity stays separate; local choices remain available."
        )
        second["visible_content_copy"] = (
            "Local choices remain available; account identity stays separate."
        )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "visible-copy semantic bag is repeated"
        ):
            module.validate_ux_blueprint(REPO_ROOT, reordered)

        repeated_clause = copy.deepcopy(payload)
        owners = (
            ("UX-SCREEN-ACCOUNT-BOUNDARY", "account-identity-only"),
            ("UX-SCREEN-ACCOUNT-BOUNDARY", "local-only"),
            ("UX-SCREEN-ACCOUNT-STATUS", "signed-in"),
            ("UX-SCREEN-ACCOUNT-STATUS", "signed-out"),
        )
        for index, owner in enumerate(owners, start=1):
            self._state(repeated_clause, *owner)["visible_content_copy"] = (
                f"Account consequence {index} is shown. Saved information stays available."
            )
        with self.assertRaisesRegex(
            module.UXBlueprintError, "visible-copy clause is repeated"
        ):
            module.validate_ux_blueprint(REPO_ROOT, repeated_clause)

    def test_explicit_177_row_current_delta_owner_taxonomy_fixture(self):
        payload = self._payload()
        states = self._states(payload)
        fixture = json.loads(FIXTURE_PATH.read_text())
        self.assertEqual(fixture["matrix_sha256"], MATRIX_SHA256)
        rows = fixture["current_delta_owner_taxonomy"]
        self.assertEqual(len(rows), 177)
        self.assertEqual(
            len({(row["screen_id"], row["variant_key"]) for row in rows}), 177
        )
        self.assertTrue(
            {(row["screen_id"], row["variant_key"]) for row in rows}
            <= set(states)
        )
        for row in rows:
            owner = (row["screen_id"], row["variant_key"])
            state = states[owner]
            self.assertEqual(state["generic_kind"], row["generic_kind"], owner)
            self.assertEqual(state["state_axis"], row["state_axis"], owner)
            self.assertEqual(state["operation_phase"], row["operation_phase"], owner)

    def test_18_removed_variants_and_three_setup_content_moves_are_explicit(self):
        payload = self._payload()
        states = self._states(payload)
        self.assertEqual(len(REMOVED_VARIANT_REPLACEMENTS), 18)
        for removed, replacement in REMOVED_VARIANT_REPLACEMENTS.items():
            self.assertNotIn(removed, states)
            self.assertIn(replacement, states)
        content = payload["setup_contract"]["subordinate_content"]
        content_ids = {item["content_id"] for item in content}
        self.assertEqual(
            content_ids, {"optional-account", "permissions-choice", "welcome"}
        )
        for content_id in content_ids:
            self.assertNotIn(("UX-SCREEN-SETUP-FIRST-USE", content_id), states)
        self.assertEqual(277 - 21 + 177, 433)

    def test_owner_taxonomy_negative_mutations_fail_closed(self):
        module = self._module()
        cases = (
            ("UX-SCREEN-APP-DEEP-LINK-INTAKE", "queued", "state_axis", "presentation"),
            ("UX-SCREEN-YOU-ENTITLEMENT", "active", "state_axis", "presentation"),
            ("UX-SCREEN-GOALS-PATH", "draft", "state_axis", "presentation"),
            ("UX-SCREEN-YOU-NOTIFICATIONS", "scheduled", "state_axis", "presentation"),
            ("UX-SCREEN-SETUP-FIRST-USE", "in-progress", "state_axis", "operation"),
            ("UX-SCREEN-TIME-DEGRADED", "sync-conflict", "state_axis", "operation"),
        )
        for screen_id, key, field, wrong_value in cases:
            with self.subTest(screen_id=screen_id, key=key):
                forged = copy.deepcopy(self._payload())
                self._state(forged, screen_id, key)[field] = wrong_value
                with self.assertRaisesRegex(
                    module.UXBlueprintError,
                    "explicit state inventory is incomplete or invented|owner state classification is stale",
                ):
                    module.validate_ux_blueprint(REPO_ROOT, forged)


if __name__ == "__main__":
    unittest.main()
