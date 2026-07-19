import copy
import json
import re
import unittest
from pathlib import Path
from unittest.mock import patch


REPO_ROOT = Path(__file__).resolve().parents[2]
GAP_COPY_FIXTURE = (
    REPO_ROOT
    / "tests/canon/fixtures/ux-blueprint-gap-blocked-copy-fixtures.json"
)

EXPECTED_PLAIN_COPY = {
    ("UX-SCREEN-ACCOUNT-BOUNDARY", "continuity-disabled"): "Continuity is off. This device keeps the latest saved information available.",
    ("UX-SCREEN-ACCOUNT-BOUNDARY", "local-only"): "Ambitions works without an account. Goals, Captures, time, and preferences stay on this device.",
    ("UX-SCREEN-ACCOUNT-STATUS", "signed-in"): "You are signed in. Your account details are current, and saved personal information remains available on this device.",
    ("UX-SCREEN-APP-SHELL-ROOT", "goals-selected"): "Goals is selected. The chosen Life Area and its Goals remain in view.",
    ("UX-SCREEN-APP-SHELL-ROOT", "time-selected"): "Time is selected. The chosen date range remains in view.",
    ("UX-SCREEN-APP-SHELL-ROOT", "today-selected"): "Today is selected. Start here and the current day remain in view.",
    ("UX-SCREEN-APP-SHELL-ROOT", "you-selected"): "You is selected. The current settings section remains in view.",
    ("UX-SCREEN-APP-SHELL-SEARCH-CAPTURE", "capture-presented"): "Capture is open above the current screen. Anything already entered remains in the composer.",
    ("UX-SCREEN-APP-SHELL-SEARCH-CAPTURE", "search-presented"): "Search is open above the current screen. The current query and results remain private on this device.",
    ("UX-SCREEN-SEARCH-RESULTS", "action-complete"): "The selected item now shows the completed change and its recorded result.",
    ("UX-SCREEN-SEARCH-RESULTS", "results"): "Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted.",
    ("UX-SCREEN-SEARCH-ROOT", "rebuilding"): "Search is rebuilding its local list. Matches may be incomplete until the list is ready.",
    ("UX-SCREEN-SEARCH-ROOT", "recent"): "Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged.",
    ("UX-SCREEN-SETUP-RESUME", "revalidating"): "Ambitions is checking the saved setup point against current permissions and optional services. Earlier choices remain saved.",
    ("UX-SCREEN-TODAY-START-HERE", "recovery-needed"): "A started Step was interrupted. Its last saved progress remains visible while recovery choices are shown.",
    ("UX-SCREEN-TRUST-DEEP", "correction-complete"): "The correction is complete. The earlier value and the reason for the change remain visible in History.",
    ("UX-SCREEN-TRUST-DEEP", "history-paginating"): "More History is loading from this device. The entries already shown remain in their recorded order.",
    ("UX-SCREEN-TRUST-DEEP", "history-populated"): "History shows recorded changes in order, with related results and corrections linked.",
    ("UX-SCREEN-TRUST-DEEP", "source-current"): "This source was checked within its stated freshness period, so its information is current.",
    ("UX-SCREEN-TRUST-RECEIPT", "absent-receipt-detail"): "Details for this recorded change are unavailable. The missing information is shown clearly.",
    ("UX-SCREEN-TRUST-RECEIPT", "receipt-committed"): "This change is recorded. Its item and lasting result are available for inspection.",
    ("UX-SCREEN-TRUST-RECEIPT", "receipt-external-failed"): "The Ambitions change is saved, but the related outside update did not finish. Both outcomes remain visible.",
    ("UX-SCREEN-TRUST-RECEIPT", "receipt-pending"): "This change is still being recorded. Its result is not shown as complete yet.",
    ("UX-SCREEN-TRUST-RECEIPT", "receipt-undone"): "The earlier value has been restored. History keeps both the original change and the restoration.",
    ("UX-SCREEN-YOU-CONTINUITY-CONTROL", "enabled-idle"): "Continuity is on and up to date. This device has no changes waiting to be shared.",
    ("UX-SCREEN-YOU-CONTINUITY-CONTROL", "migrating"): "Continuity settings are being updated. Saved information remains available on this device.",
    ("UX-SCREEN-YOU-CONTINUITY-CONTROL", "uploading"): "An encrypted copy is being sent to the user’s continuity storage. Saved information remains available on this device.",
    ("UX-SCREEN-YOU-DATA", "export-failed"): "The file could not be created. Saved information is unchanged, and no incomplete file is offered.",
    ("UX-SCREEN-YOU-DIAGNOSTICS", "unknown"): "The health check does not have a reliable result yet. Saved information remains available.",
    ("UX-SCREEN-YOU-ENTITLEMENT", "supported-sharing"): "Supported purchase sharing is active. Goals, Captures, time, and personal settings are not shared.",
    ("UX-SCREEN-YOU-ROOT", "account-signed-in"): "You are signed in for account services. Goals, Captures, time, and personal settings remain available on this device.",
    ("UX-SCREEN-YOU-ROOT", "continuity-disabled"): "Continuity is off. Saved Goals, Captures, time, and preferences remain available on this device.",
    ("UX-SCREEN-YOU-ROOT", "continuity-pending"): "Continuity setup has not finished. This device still shows the latest saved information.",
    ("UX-SCREEN-YOU-ROOT", "diagnostics-healthy"): "The checked areas show no detected issue. This result covers only the health checks listed here.",
    ("UX-SCREEN-YOU-ROOT", "normal"): "You shows account, permissions, appearance, privacy, data, and support settings.",
    ("UX-SCREEN-YOU-SETTINGS", "appearance-dark"): "Dark appearance is active. Text, controls, and status labels keep their contrast and hierarchy.",
    ("UX-SCREEN-YOU-SETTINGS", "appearance-light"): "Light appearance is active. Text, controls, and status labels keep their contrast and hierarchy.",
    ("UX-SCREEN-YOU-SETTINGS", "automation-policy"): "Automation uses the permission level shown here. Existing settings retain their saved values.",
}

BANNED_FULL_CORPUS_LANGUAGE = re.compile(
    r"CloudKit|private[- ](?:life )?graph|\bbackend\b|\bactive root\b|"
    r"\bfifth root\b|durable event (?:order|sequence)|\bsuccess claim\b|"
    r"command and receipt commit|committed command|canonical (?:data|object)|"
    r"release or product-completeness proof|private runtime taxonomy|"
    r"semantic[- ]tokens?|\blocal graph\b|\blocal authority\b|"
    r"authoritative local copy|private query scope|product objects|"
    r"primary object precedes|global actions and navigation|"
    r"checkpoint is being revalidated|optional-service state|last durable state|"
    r"corrective event|receipt committed|durable consequence|"
    r"declared external effect|full success|continuity metadata|healthy claim|"
    r"continuity authority|approved transition commits|declared confirmation policy",
    re.IGNORECASE,
)


class UXBlueprintFullCorpusReviewTests(unittest.TestCase):
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

    def test_exact_38_internal_language_records_are_plain_user_consequences(self):
        self.assertEqual(len(EXPECTED_PLAIN_COPY), 38)
        states = self._states(self._payload())
        for owner, expected in EXPECTED_PLAIN_COPY.items():
            with self.subTest(owner=owner):
                self.assertEqual(states[owner]["visible_content_copy"], expected)
                self.assertIsNone(BANNED_FULL_CORPUS_LANGUAGE.search(expected))

    def test_internal_language_ban_covers_the_full_review_docket(self):
        pattern = self._module().BANNED_VISIBLE_INTERNAL_LANGUAGE
        examples = (
            "CloudKit continuity is off.",
            "The private graph remains local.",
            "Private-graph backend ownership is unchanged.",
            "Today is the active root.",
            "Capture is not a fifth root.",
            "History follows durable event sequence.",
            "History is loading in durable event order.",
            "No success claim is inferred.",
            "The command and receipt commit together.",
            "The result reflects the committed command.",
            "Canonical data is unchanged.",
            "Results use canonical object types.",
            "This is not release or product-completeness proof.",
            "Private runtime taxonomy is hidden.",
            "Dark semantic tokens are active.",
            "The local graph remains authoritative.",
            "Local authority remains primary.",
            "This device is the authoritative local copy.",
            "Private query scope remains intact.",
            "Product objects remain unchanged.",
            "The primary object precedes global actions and navigation.",
            "The checkpoint is being revalidated against optional-service state.",
            "Recovery begins from the last durable state.",
            "History preserves the corrective event.",
            "Receipt committed with a durable consequence.",
            "The declared external effect did not finish, so full success is withheld.",
            "Continuity metadata preserves continuity authority.",
            "No healthy claim is shown.",
            "The approved transition commits later.",
            "Automation follows its declared confirmation policy.",
        )
        for example in examples:
            with self.subTest(example=example):
                self.assertIsNotNone(pattern.search(example))

    def test_exact_21_copy_fixtures_preserve_state_condition_and_consequence(self):
        fixture = json.loads(GAP_COPY_FIXTURE.read_text())["states"]
        self.assertEqual(len(fixture), 21)
        owners = {(item["screen_id"], item["variant_key"]) for item in fixture}
        self.assertEqual(len(owners), 21)
        states = self._states(self._payload())
        for item in fixture:
            owner = (item["screen_id"], item["variant_key"])
            with self.subTest(owner=owner):
                state = states[owner]
                self.assertIn(
                    state["behavior_authority_posture"],
                    {"exploratory_blocked_by_specification_gap", "requirement_backed"},
                )
                self.assertEqual(
                    state["visible_content_copy"], item["visible_content_copy"]
                )

    def test_copy_action_implication_detector_is_grammar_aware(self):
        module = self._module()
        implied_actions = (
            "Review the affected scope before anything changes.",
            "Undo removes eligible items while the source stays unchanged.",
            "Try different words while saved items stay unchanged.",
            "Remove a filter to see more matches.",
            "Confirm deletion after checking the scope.",
            "Restore returns the item to its collection.",
            "Enabling continuity sends a protected copy.",
            "Export creates a redacted file.",
            "Run repair against the verified snapshot.",
        )
        for value in implied_actions:
            with self.subTest(value=value):
                self.assertTrue(module.gap_blocked_copy_implies_action(value))

        neutral_conditions = (
            "The review is incomplete; saved information remains unchanged.",
            "Undo history is unavailable; imported items remain unchanged.",
            "The export is incomplete; saved information remains unchanged.",
            "Continuity is not enabled; saved information remains on this device.",
            "Repair is running against a verified snapshot. The last valid copy remains protected.",
        )
        for value in neutral_conditions:
            with self.subTest(value=value):
                self.assertFalse(module.gap_blocked_copy_implies_action(value))

        state_id = "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-RECOVERABLE"
        contracts_without_state = tuple(
            contract
            for contract in module.load_state_command_contracts(REPO_ROOT)
            if contract.state_id != state_id
        )

        def synthetic_future_gap(visible_copy):
            payload = copy.deepcopy(self._payload())
            payload["specification_gaps"] = [
                {
                    "affected_screen_families": ["app-deep-link-intake"],
                    "affected_state_ids": [state_id],
                    "authority_consequence": (
                        "The state is not eligible for visual authority until an exact "
                        "command contract resolves this future gap."
                    ),
                    "blocked_fields": [
                        "material-action focus",
                        "safe fallback destination",
                        "user controls by rejection class",
                        "user controls by source class",
                    ],
                    "gap_id": "GAP-UX-COMMAND-CONTRACT-DEEP-LINK-001",
                    "source_rationale": (
                        "Synthetic regression coverage preserves fail-closed behavior when "
                        "a future command gap is explicitly reintroduced."
                    ),
                }
            ]
            state = next(
                variant
                for model in payload["state_models"]
                for variant in model["variants"]
                if variant["blueprint_id"] == state_id
            )
            state["allowed_commands"] = []
            state["future_gated_commands"] = []
            state["machine_command_contracts"] = []
            state["behavior_authority_evidence"] = []
            state["behavior_authority_posture"] = (
                "exploratory_blocked_by_specification_gap"
            )
            state["behavior_authority_rationale"] = (
                "No exact command authorized by current canon; future ownership remains "
                "blocked by the explicit specification gap."
            )
            state["behavior_requirement_ids"] = []
            state["specification_gap_ids"] = [
                "GAP-UX-COMMAND-CONTRACT-DEEP-LINK-001"
            ]
            state["visible_content_copy"] = visible_copy
            state["transition_exit"] = (
                "No exact command authorized by current canon; no transition is available."
            )
            state["durable_effect"] = (
                "No exact command authorized by current canon; saved local data remains "
                "unchanged."
            )
            state["recovery_rollback"] = (
                "No exact command authorized by current canon; no rollback is available."
            )
            state["offline_behavior"] = (
                "No exact command authorized by current canon; local read-only context "
                "remains available offline."
            )
            state["accessibility_focus"] = (
                "No exact command authorized by current canon; focus remains on the "
                "explained unavailable state."
            )
            return payload

        with patch.object(
            module,
            "load_state_command_contracts",
            return_value=contracts_without_state,
        ):
            with self.assertRaisesRegex(
                module.UXBlueprintError,
                "gap-blocked visible copy implies an unauthorized action",
            ):
                module.validate_ux_blueprint(
                    REPO_ROOT,
                    synthetic_future_gap(implied_actions[0]),
                )
            module.validate_ux_blueprint(
                REPO_ROOT,
                synthetic_future_gap(neutral_conditions[0]),
            )

if __name__ == "__main__":
    unittest.main()
