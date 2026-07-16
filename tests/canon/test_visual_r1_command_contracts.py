import copy
import json
import re
import unittest
from dataclasses import replace
from pathlib import Path

from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.parser import (
    _validate_state_command_semantics,
    parse_canon_document,
)
from tools.ambitions_canon.task_pack import require_pack_authorization_current
from tools.ambitions_canon.ux_blueprint import (
    UXBlueprintError,
    load_state_command_contracts,
    validate_ux_blueprint,
)


ROOT = Path(__file__).resolve().parents[2]
BLUEPRINT_PATH = ROOT / "docs/canon/migration/ux-blueprint.json"

APPROVED_REQUIREMENT_OWNERS = {
    "APP-ACCOUNT-COMMAND-CONTRACT-001": "app/launch-and-setup.md",
    "APP-DEEP-LINK-COMMAND-CONTRACT-001": "app/deep-linking.md",
    "APP-DEGRADED-COMMAND-CONTRACT-001": "app/degraded-states.md",
    "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001": "app/launch-and-setup.md",
    "APP-PERMISSIONS-COMMAND-CONTRACT-001": "app/permissions.md",
    "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001": "journeys/external-calendar-import.md",
    "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001": "global/search.md",
    "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001": "surfaces/time.md",
    "SPEC-SURFACE-YOU-ENTITLEMENT-COMMAND-CONTRACT-001": "surfaces/you.md",
    "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001": "systems/sync-and-continuity.md",
    "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001": "systems/diagnostics.md",
    "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001": "systems/notifications.md",
}

SCREEN_REQUIREMENT_OWNERS = {
    "UX-SCREEN-ACCOUNT-BOUNDARY": "APP-ACCOUNT-COMMAND-CONTRACT-001",
    "UX-SCREEN-ACCOUNT-SIGN-IN": "APP-ACCOUNT-COMMAND-CONTRACT-001",
    "UX-SCREEN-ACCOUNT-STATUS": "APP-ACCOUNT-COMMAND-CONTRACT-001",
    "UX-SCREEN-APP-DEEP-LINK-INTAKE": "APP-DEEP-LINK-COMMAND-CONTRACT-001",
    "UX-SCREEN-APP-LAUNCH-GATE": "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001",
    "UX-SCREEN-OFFLINE-DEGRADED-LOCAL-HEALTH": "APP-DEGRADED-COMMAND-CONTRACT-001",
    "UX-SCREEN-OFFLINE-DEGRADED-REPAIR": "APP-DEGRADED-COMMAND-CONTRACT-001",
    "UX-SCREEN-PERMISSIONS-CALENDAR": "APP-PERMISSIONS-COMMAND-CONTRACT-001",
    "UX-SCREEN-PERMISSIONS-NOTIFICATIONS": "APP-PERMISSIONS-COMMAND-CONTRACT-001",
    "UX-SCREEN-SEARCH-RESULTS": "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001",
    "UX-SCREEN-SEARCH-ROOT": "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001",
    "UX-SCREEN-SETUP-FIRST-USE": "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001",
    "UX-SCREEN-SETUP-RESUME": "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001",
    "UX-SCREEN-TIME-DETAIL": "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001",
    "UX-SCREEN-TIME-IMPORT": "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001",
    "UX-SCREEN-YOU-CONTINUITY-CONTROL": "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001",
    "UX-SCREEN-YOU-DIAGNOSTICS": "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001",
    "UX-SCREEN-YOU-ENTITLEMENT": "SPEC-SURFACE-YOU-ENTITLEMENT-COMMAND-CONTRACT-001",
    "UX-SCREEN-YOU-NOTIFICATIONS": "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001",
}


class VisualR1CommandContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.blueprint = json.loads(BLUEPRINT_PATH.read_text(encoding="utf-8"))
        cls.contracts = {
            contract.state_id: contract
            for contract in load_state_command_contracts(ROOT)
        }

    def test_approved_requirements_live_in_exact_existing_owners(self):
        for requirement_id, relative in APPROVED_REQUIREMENT_OWNERS.items():
            with self.subTest(requirement_id=requirement_id):
                path = ROOT / "docs/canon/specifications" / relative
                document = parse_canon_document(
                    path, path.read_text(encoding="utf-8")
                )
                self.assertIn(
                    requirement_id,
                    {item.requirement_id for item in document.requirements},
                )

    def test_all_twelve_gap_records_are_removed_by_structured_ownership(self):
        self.assertEqual(self.blueprint["specification_gaps"], [])
        models = {
            item["screen_id"]: item for item in self.blueprint["state_models"]
        }
        for screen_id, requirement_id in SCREEN_REQUIREMENT_OWNERS.items():
            for variant in models[screen_id]["variants"]:
                with self.subTest(state_id=variant["blueprint_id"]):
                    self.assertEqual(
                        variant["behavior_authority_posture"], "requirement_backed"
                    )
                    self.assertEqual(variant["specification_gap_ids"], [])
                    self.assertEqual(
                        variant["behavior_requirement_ids"], [requirement_id]
                    )
                    contract = self.contracts[variant["blueprint_id"]]
                    self.assertEqual(contract.requirement_id, requirement_id)
                    self.assertEqual(
                        variant["allowed_commands"],
                        [command.label for command in contract.commands],
                    )

    def test_empty_gap_inventory_cannot_bypass_missing_contract_ownership(self):
        payload = copy.deepcopy(self.blueprint)
        self.assertEqual(payload["specification_gaps"], [])
        time_detail = next(
            variant
            for model in payload["state_models"]
            if model["screen_id"] == "UX-SCREEN-TIME-DETAIL"
            for variant in model["variants"]
            if variant["blueprint_id"]
            == "UX-STATE-VARIANT-TIME-DETAIL-VIEWING"
        )
        time_detail["requirement_ids"].remove(
            "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
        )
        with self.assertRaisesRegex(
            UXBlueprintError,
            "unsupported behavior authority",
        ):
            validate_ux_blueprint(ROOT, payload)

    def test_continuity_is_fail_closed_except_status_review(self):
        prefix = "UX-STATE-VARIANT-YOU-CONTINUITY-CONTROL-"
        continuity = {
            state_id: contract
            for state_id, contract in self.contracts.items()
            if state_id.startswith(prefix)
        }
        self.assertEqual(len(continuity), 16)
        expected = {
            prefix + "BLOCKED": ["Review Continuity Status"],
            prefix + "CONFLICTED-QUARANTINED": ["Review Conflict"],
            prefix + "DISABLED": ["Review Continuity Status"],
            prefix + "ELIGIBLE-NOT-ENABLED": ["Enable Continuity"],
            prefix + "ENABLED-IDLE": ["Turn Off Continuity"],
            prefix + "INELIGIBLE": ["Review Continuity Status"],
            prefix + "LOCAL-PENDING": ["Pause Continuity"],
            prefix + "MERGING": ["Review Conflict"],
            prefix + "MIGRATING": ["Review Migration"],
            prefix + "PAUSED": ["Resume Continuity"],
            prefix + "REMOTE-PENDING": ["Review Conflict"],
            prefix + "RESTORING": ["Review Restore"],
            prefix + "RETRYING": ["Try Again"],
            prefix + "SIGNED-OUT": ["Review Continuity Status"],
            prefix + "UNAVAILABLE": ["Try Again"],
            prefix + "UPLOADING": ["Pause Continuity"],
        }
        self.assertEqual(set(continuity), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                self.assertEqual(
                    [command.label for command in continuity[state_id].commands],
                    labels,
                )
        disabled = continuity[prefix + "DISABLED"]
        self.assertEqual(disabled.activation_posture.value, "active")
        self.assertEqual(
            [command.label for command in disabled.commands],
            ["Review Continuity Status"],
        )
        for state_id, contract in continuity.items():
            if state_id == prefix + "DISABLED":
                continue
            with self.subTest(state_id=state_id):
                self.assertEqual(contract.activation_posture.value, "future_gated")
                self.assertIn(
                    "SYSTEM-CONTINUITY-DISABLED-001",
                    contract.gate_requirement_ids,
                )
                for command in contract.commands:
                    preconditions = " ".join(command.preconditions).casefold()
                    for gate_fact in (
                        "explicit consent",
                        "verified backup",
                        "local source authority",
                        "eligible icloud",
                        "stable schema",
                        "causal identity",
                        "privacy/security gate",
                        "dry run",
                        "rollback",
                        "last-writer-wins",
                    ):
                        self.assertIn(gate_fact, preconditions)

    def test_no_non_disabled_continuity_state_is_active_anywhere(self):
        continuity = {
            state_id: contract
            for state_id, contract in self.contracts.items()
            if "CONTINUITY" in state_id
        }
        self.assertTrue(continuity)
        for state_id, contract in continuity.items():
            with self.subTest(state_id=state_id):
                if state_id.endswith("-DISABLED"):
                    self.assertEqual(contract.activation_posture.value, "active")
                    self.assertEqual(contract.gate_requirement_ids, ())
                else:
                    self.assertEqual(
                        contract.activation_posture.value, "future_gated"
                    )
                    self.assertIn(
                        "SYSTEM-CONTINUITY-DISABLED-001",
                        contract.gate_requirement_ids,
                    )

    def test_account_continuity_conflict_remains_future_gated(self):
        contract = self.contracts[
            "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-CONTINUITY-CONFLICTED"
        ]
        self.assertEqual(contract.activation_posture.value, "future_gated")
        self.assertIn(
            "SYSTEM-CONTINUITY-DISABLED-001",
            contract.gate_requirement_ids,
        )

    def test_deep_link_owner_has_six_complete_contracts(self):
        path = ROOT / "docs/canon/specifications/app/deep-linking.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id == "APP-DEEP-LINK-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED": ["Dismiss"],
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-PRESENTED": ["Dismiss"],
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-QUEUED": ["Dismiss"],
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-RECOVERABLE": [
                "Dismiss",
                "Try Again",
            ],
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-REJECTED": ["Dismiss"],
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-RESOLVING": ["Dismiss"],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(contract.activation_posture.value, "active")
                self.assertEqual(contract.gate_requirement_ids, ())
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )

    def test_time_detail_owner_has_six_complete_contracts(self):
        path = ROOT / "docs/canon/specifications/surfaces/time.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-TIME-DETAIL-CONFLICT-REVIEW": ["Cancel"],
            "UX-STATE-VARIANT-TIME-DETAIL-EDITING": ["Cancel", "Save"],
            "UX-STATE-VARIANT-TIME-DETAIL-SAVED": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-UNDO-ELIGIBLE": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-UNDO-UNAVAILABLE": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-VIEWING": ["Edit", "Move to Trash"],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(contract.activation_posture.value, "active")
                self.assertEqual(contract.gate_requirement_ids, ())
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )
                for command in contract.commands:
                    joined = " ".join(command.preconditions).casefold()
                    self.assertIn("current revision", joined)
                    self.assertIn("ownership", joined)

    def test_time_import_owner_has_ten_complete_contracts(self):
        path = (
            ROOT
            / "docs/canon/specifications/journeys/external-calendar-import.md"
        )
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-TIME-IMPORT-COMMITTING-IMPORT": ["Done"],
            "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED": ["Done"],
            "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-WRITE-FAILURE": [
                "Retry Failed Items"
            ],
            "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-FAILED": [
                "Retry Failed Items"
            ],
            "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE": ["Done"],
            "UX-STATE-VARIANT-TIME-IMPORT-NATIVE-IMPORT-UNDO": [
                "Undo Imported Items"
            ],
            "UX-STATE-VARIANT-TIME-IMPORT-PARTIAL-IMPORT": [
                "Retry Failed Items"
            ],
            "UX-STATE-VARIANT-TIME-IMPORT-RECONCILING": ["Review Selected"],
            "UX-STATE-VARIANT-TIME-IMPORT-RESTORED": ["Done"],
            "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF": [
                "Import Selected",
                "Review Selected",
            ],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(contract.activation_posture.value, "active")
                self.assertEqual(contract.gate_requirement_ids, ())
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )

    def test_diagnostics_owner_has_ten_observational_contracts(self):
        path = ROOT / "docs/canon/specifications/systems/diagnostics.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-BLOCKED": ["Review Repair"],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-DEGRADED": ["Inspect"],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-DIAGNOSIS-READY": [
                "Inspect",
                "Preview Diagnostic Export",
            ],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-EXPORT-FAILED": ["Try Again"],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-EXPORT-PREVIEW": [
                "Cancel",
                "Create Diagnostic File",
            ],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-HEALTHY": ["Done"],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-QUARANTINED": [
                "Review Quarantine"
            ],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-RECOVERABLE": [
                "Review Repair"
            ],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-REPAIR-PREVIEW": [
                "Cancel",
                "Quarantine Affected Data",
                "Run Repair",
            ],
            "UX-STATE-VARIANT-YOU-DIAGNOSTICS-UNKNOWN": ["Run Health Check"],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                commands = contracts[state_id].commands
                self.assertEqual([command.label for command in commands], labels)
                self.assertFalse(
                    any(
                        command.commit_boundary.startswith("Mutation:")
                        for command in commands
                    )
                )
        artifact_commands = [
            command
            for contract in contracts.values()
            for command in contract.commands
            if command.label == "Create Diagnostic File"
        ]
        self.assertEqual(len(artifact_commands), 1)
        artifact = artifact_commands[0]
        self.assertTrue(artifact.commit_boundary.startswith("External-result:"))
        self.assertIn("no local canonical mutation", artifact.effect.casefold())
        self.assertIn("never uploads automatically", artifact.privacy_egress.casefold())

    def test_entitlement_owner_has_eleven_fail_closed_contracts(self):
        path = ROOT / "docs/canon/specifications/surfaces/you.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "SPEC-SURFACE-YOU-ENTITLEMENT-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-ACTIVE": ["Manage Subscription"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-EXPIRED": ["Restore Purchases"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-GRACE": ["Manage Subscription"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-MISMATCH": ["Review Account"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-OFFLINE-CACHED": ["Done"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-RESTORED": ["Done"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-RETRY": ["Check Again"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-REVOKED": ["Restore Purchases"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-SUPPORTED-SHARING": ["Done"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-TRIAL": ["View Plans"],
            "UX-STATE-VARIANT-YOU-ENTITLEMENT-UNKNOWN": ["Check Again"],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(contract.activation_posture.value, "active")
                self.assertEqual(contract.gate_requirement_ids, ())
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )
                self.assertNotIn(
                    "Purchase", [command.label for command in contract.commands]
                )

    def test_notifications_owner_has_eleven_local_first_contracts(self):
        path = ROOT / "docs/canon/specifications/systems/notifications.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-ACTED": ["Done"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DELIVERED": ["Done"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DISABLED": ["Open Settings"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-EXTERNALLY-FAILED": [
                "Try Again"
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-ALLOWED": [
                "Create Rule"
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-DENIED": [
                "Open Settings"
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-PERMISSION-NOT-REQUESTED": [
                "Open Settings"
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-RECONCILED": ["Done"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-REMOVED": ["Done"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-SCHEDULED": [
                "Edit Rule",
                "Remove Rule",
                "Turn Off",
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-SUPERSEDED": ["Edit Rule"],
        }
        self.assertEqual(set(contracts), set(expected))
        mutations = {"Create Rule", "Edit Rule", "Remove Rule", "Turn Off"}
        external = {"Open Settings", "Try Again"}
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                commands = contracts[state_id].commands
                self.assertEqual([command.label for command in commands], labels)
                for command in commands:
                    if command.label in mutations:
                        self.assertTrue(
                            command.commit_boundary.startswith("Mutation:")
                        )
                    elif command.label in external:
                        self.assertTrue(
                            command.commit_boundary.startswith("External-result:")
                        )
        remove = next(
            command
            for contract in contracts.values()
            for command in contract.commands
            if command.label == "Remove Rule"
        )
        self.assertIn("does not delete", remove.effect.casefold())
        delivered = contracts[
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DELIVERED"
        ]
        self.assertIn("does not complete", delivered.durable_effect.casefold())

    def test_degraded_owner_has_seventeen_classified_contracts(self):
        path = ROOT / "docs/canon/specifications/app/degraded-states.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id == "APP-DEGRADED-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT": [
                "Review Conflict"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING": [
                "Review Continuity Status"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-EXTERNAL-WRITE-FAILURE": [
                "Retry External Update",
                "Review Details",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-IMPORT-FAILURE": [
                "Retry Failed Items",
                "Review Partial Import",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-LOCAL-STORE-DEGRADATION": [
                "Open Diagnostics"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY": [
                "Review Details"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-PARTIAL-OPERATION": [
                "Retry Failed Items",
                "Review Partial Import",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-PROTECTED-DATA-UNAVAILABLE": [
                "Unlock and Retry"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-STALE-EXTERNAL-SOURCE": [
                "Refresh Source",
                "Review Source",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-STORAGE-PRESSURE": [
                "Export Data",
                "Review Storage",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-UNAVAILABLE-PERMISSION": [
                "Open Settings",
                "Review Access",
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-EXPORT-ONLY": [
                "Export Data"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-QUARANTINE-INSPECTION": [
                "Review Details"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-AVAILABLE": [
                "Review Details"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-COMPLETE": [
                "Review Details"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-FAILED": [
                "Open Diagnostics"
            ],
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-REPAIR-REPAIR-RUNNING": [
                "Review Details"
            ],
        }
        self.assertEqual(set(contracts), set(expected))
        continuity_states = {
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-CONFLICT",
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-CONTINUITY-PENDING",
        }
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )
                if state_id in continuity_states:
                    self.assertEqual(
                        contract.activation_posture.value, "future_gated"
                    )
                    self.assertIn(
                        "SYSTEM-CONTINUITY-DISABLED-001",
                        contract.gate_requirement_ids,
                    )
                else:
                    self.assertEqual(contract.activation_posture.value, "active")
                    self.assertEqual(contract.gate_requirement_ids, ())
                self.assertIn(
                    "you → data & storage → review reset",
                    contract.recovery_rollback.casefold(),
                )
                self.assertNotIn(
                    "Reset", [command.label for command in contract.commands]
                )
        offline = contracts[
            "UX-STATE-VARIANT-OFFLINE-DEGRADED-LOCAL-HEALTH-OFFLINE-HEALTHY"
        ]
        self.assertEqual([command.label for command in offline.commands], ["Review Details"])

    def test_search_owner_has_twenty_four_nonmutating_contracts(self):
        path = ROOT / "docs/canon/specifications/global/search.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
        }
        expected = {
            "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE": [
                "Inspect Receipt"
            ],
            "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE": [
                "Undo"
            ],
            "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE": [
                "Inspect History"
            ],
            "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-PREVIEW": [
                "Inspect Source"
            ],
            "UX-STATE-VARIANT-SEARCH-RESULTS-FILTERED": ["Clear Filters"],
            "UX-STATE-VARIANT-SEARCH-RESULTS-NO-RESULTS": ["Clear Search"],
            "UX-STATE-VARIANT-SEARCH-RESULTS-RESULTS": ["Filters"],
            "UX-STATE-VARIANT-SEARCH-RESULTS-SELECTED": ["Inspect Source"],
            "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-MUTATING": ["Inspect History"],
            "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-REJECTED": ["Clear Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-VALIDATING": [
                "Inspect Source"
            ],
            "UX-STATE-VARIANT-SEARCH-ROOT-CORRUPT-INDEX": ["Rebuild Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-EMPTY-QUERY": ["Filters"],
            "UX-STATE-VARIANT-SEARCH-ROOT-INSPECTION-HANDOFF": [
                "Inspect Privacy"
            ],
            "UX-STATE-VARIANT-SEARCH-ROOT-OFFLINE-HEALTHY": ["Clear Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-PARTIAL-RESULTS": ["Inspect Source"],
            "UX-STATE-VARIANT-SEARCH-ROOT-PERMISSION-DENIED": [
                "Inspect Privacy"
            ],
            "UX-STATE-VARIANT-SEARCH-ROOT-PRIVACY-SUPPRESSED": [
                "Inspect Privacy"
            ],
            "UX-STATE-VARIANT-SEARCH-ROOT-QUERYING": ["Clear Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-REBUILDING": ["Cancel Rebuild"],
            "UX-STATE-VARIANT-SEARCH-ROOT-RECENT": ["Clear Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-RESTORED": ["Filters"],
            "UX-STATE-VARIANT-SEARCH-ROOT-STALE-INDEX": ["Rebuild Search"],
            "UX-STATE-VARIANT-SEARCH-ROOT-UNAVAILABLE-PROJECTION": [
                "Rebuild Search"
            ],
        }
        self.assertEqual(set(contracts), set(expected))
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                contract = contracts[state_id]
                self.assertEqual(
                    [command.label for command in contract.commands], labels
                )
                self.assertFalse(
                    any(
                        command.commit_boundary.startswith("Mutation:")
                        for command in contract.commands
                    )
                )
        rebuilds = [
            command
            for contract in contracts.values()
            for command in contract.commands
            if command.label == "Rebuild Search"
        ]
        self.assertTrue(rebuilds)
        for command in rebuilds:
            self.assertIn("prior valid index", command.effect.casefold())
            self.assertIn("quarantined", command.effect.casefold())
        undo = next(
            command
            for contract in contracts.values()
            for command in contract.commands
            if command.label == "Undo"
        )
        self.assertIn("resolved object owner", undo.destination.casefold())

    def test_permissions_owner_has_twenty_six_contextual_contracts(self):
        path = ROOT / "docs/canon/specifications/app/permissions.md"
        document = parse_canon_document(path, path.read_text(encoding="utf-8"))
        contracts = {
            contract.state_id: contract
            for contract in document.state_command_contracts
            if contract.requirement_id
            == "APP-PERMISSIONS-COMMAND-CONTRACT-001"
        }
        state_labels = {
            "AUTHORIZED": ["Done"],
            "DENIED": ["Open Settings", "Use Local Only"],
            "ELIGIBILITY-CHECK": ["Check Again"],
            "LIMITED": ["Review Access"],
            "LOCAL-FALLBACK": ["Use Local Only"],
            "NOT-DETERMINED": None,
            "PARTIAL-EXTERNAL-ACCESS": ["Review Access"],
            "RECONCILING": ["Check Again"],
            "REQUEST-FAILED": ["Check Again", "Use Local Only"],
            "RESTRICTED": ["Use Local Only"],
            "REVOKED": ["Open Settings", "Use Local Only"],
            "SETTINGS-RETURN-FAILED": ["Check Again"],
            "UNAVAILABLE": ["Use Local Only"],
        }
        expected = {}
        for capability, allow_label in (
            ("CALENDAR", "Allow Calendar Access"),
            ("NOTIFICATIONS", "Allow Notifications"),
        ):
            for suffix, labels in state_labels.items():
                expected[
                    f"UX-STATE-VARIANT-PERMISSIONS-{capability}-{suffix}"
                ] = (
                    [allow_label, "Not Now"]
                    if labels is None
                    else labels
                )
        self.assertEqual(set(contracts), set(expected))
        external_labels = {
            "Allow Calendar Access",
            "Allow Notifications",
            "Check Again",
            "Open Settings",
        }
        for state_id, labels in expected.items():
            with self.subTest(state_id=state_id):
                commands = contracts[state_id].commands
                self.assertEqual([command.label for command in commands], labels)
                self.assertFalse(
                    any(
                        command.commit_boundary.startswith("Mutation:")
                        for command in commands
                    )
                )
                for command in commands:
                    if command.label in external_labels:
                        self.assertTrue(
                            command.commit_boundary.startswith("External-result:")
                        )
                    if command.label.startswith("Allow "):
                        preconditions = " ".join(command.preconditions).casefold()
                        for fact in (
                            "explicit user intent",
                            "feature relevance",
                            "request eligibility",
                            "plain scope",
                            "local fallback",
                        ):
                            self.assertIn(fact, preconditions)

    def test_entitlement_never_authorizes_purchase_without_product_registry(self):
        product_registries = sorted(
            path
            for path in (ROOT / "docs/canon").rglob("*")
            if path.is_file()
            and "storekit" in path.name.casefold()
            and "product" in path.name.casefold()
        )
        self.assertEqual(product_registries, [])
        contracts = (
            contract
            for state_id, contract in self.contracts.items()
            if state_id.startswith("UX-STATE-VARIANT-YOU-ENTITLEMENT-")
        )
        labels = {command.label for contract in contracts for command in contract.commands}
        self.assertNotIn("Purchase", labels)

    def test_import_confirmation_is_bound_to_current_source_fingerprint(self):
        contracts = (
            contract
            for state_id, contract in self.contracts.items()
            if state_id.startswith("UX-STATE-VARIANT-TIME-IMPORT-")
        )
        import_commands = [
            command
            for contract in contracts
            for command in contract.commands
            if command.label in {"Import Selected", "Retry Failed Items"}
        ]
        self.assertTrue(import_commands)
        for command in import_commands:
            preconditions = " ".join(command.preconditions).casefold()
            for freshness_key in (
                "source identity",
                "source fingerprint",
                "diff revision",
                "local revision",
            ):
                with self.subTest(
                    command_id=command.command_id,
                    freshness_key=freshness_key,
                ):
                    self.assertIn(freshness_key, preconditions)
        import_contracts = [
            contract
            for state_id, contract in self.contracts.items()
            if state_id.startswith("UX-STATE-VARIANT-TIME-IMPORT-")
        ]
        self.assertTrue(import_contracts)
        for contract in import_contracts:
            with self.subTest(state_id=contract.state_id):
                recovery = contract.recovery_rollback.casefold()
                self.assertIn("changed source fingerprint", recovery)
                self.assertIn("invalidates confirmation", recovery)

    def test_parser_rejects_closed_field_id_label_and_owner_mutations(self):
        path = ROOT / "docs/canon/specifications/app/deep-linking.md"
        source = path.read_text(encoding="utf-8")
        state_ids = re.findall(r'^state_id = "([^"]+)"$', source, re.MULTILINE)
        command_ids = re.findall(
            r'^command_id = "([^"]+)"$', source, re.MULTILINE
        )
        cases = (
            (
                "missing closed field",
                re.sub(r"^privacy_egress = .+\n", "", source, count=1, flags=re.MULTILINE),
                "state command fields are closed",
            ),
            (
                "duplicate state ID",
                source.replace(
                    f'state_id = "{state_ids[1]}"',
                    f'state_id = "{state_ids[0]}"',
                    1,
                ),
                "sorted with unique state IDs",
            ),
            (
                "duplicate command ID",
                source.replace(
                    f'command_id = "{command_ids[1]}"',
                    f'command_id = "{command_ids[0]}"',
                    1,
                ),
                "duplicate command ID",
            ),
            (
                "duplicate command label",
                source.replace('label = "Try Again"', 'label = "Dismiss"', 1),
                "duplicate command label",
            ),
            (
                "unresolved owner",
                source.replace(
                    'canonical_owner = "app.deep-linking.command-contract"',
                    'canonical_owner = "unresolved.owner"',
                    1,
                ),
                "command owner concept mismatch",
            ),
        )
        for label, mutated, expected in cases:
            with self.subTest(label=label):
                with self.assertRaisesRegex(CanonError, expected):
                    parse_canon_document(path, mutated)

    def test_unresolved_route_or_focus_is_rejected(self):
        contract = self.contracts[
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED"
        ]
        for field, value in (
            ("destination", "unresolved route"),
            ("success_focus", "unresolved focus"),
            ("failure_focus", "unresolved focus"),
        ):
            with self.subTest(field=field):
                command = replace(contract.commands[0], **{field: value})
                with self.assertRaisesRegex(
                    CanonError,
                    "unresolved command route or focus",
                ):
                    _validate_state_command_semantics(
                        Path("fixture.md"),
                        contract.state_id,
                        contract.durable_effect,
                        contract.recovery_rollback,
                        contract.offline_behavior,
                        contract.accessibility_focus,
                        [command],
                    )

    def test_mutation_without_actionable_rollback_is_rejected(self):
        contract = self.contracts["UX-STATE-VARIANT-TIME-DETAIL-EDITING"]
        commands = [
            replace(
                command,
                rollback_undo="No rollback or Undo is declared.",
            )
            if command.label == "Save"
            else command
            for command in contract.commands
        ]
        with self.assertRaisesRegex(
            CanonError,
            "mutation command omits actionable rollback",
        ):
            _validate_state_command_semantics(
                Path("fixture.md"),
                contract.state_id,
                contract.durable_effect,
                contract.recovery_rollback,
                contract.offline_behavior,
                contract.accessibility_focus,
                commands,
            )

    def test_stale_task_pack_inputs_fail_closed(self):
        current = {
            "authority_state": "shadow",
            "canon_revision": 1,
            "canon_sha": "a" * 64,
            "changed_files": ["docs/canon/specifications/app/deep-linking.md"],
            "claim_ceiling": "governance only",
            "claim_type": "governance",
            "compiler_version": "0.2.0",
            "intake_path": ".codex/intake/AMB-VISUAL-R1.json",
            "intake_sha": "b" * 64,
            "issue_id": "AMB-VISUAL-R1",
            "known_issue_ids": [],
            "known_risks": [],
            "open_conflicts": [],
            "repository_sha": "c" * 40,
            "required_proof": ["exact command-contract proof"],
            "required_tests": ["focused command-contract tests"],
            "required_validation": ["canon build --check"],
            "scope": ["app.deep-linking.command-contract"],
            "source_owners": ["docs/canon/specifications/app/deep-linking.md"],
            "task_type": "docs",
            "visual_authority": ["candidate only"],
        }
        for field, value, code in (
            ("canon_sha", "0" * 64, "PACK_CANON_STALE"),
            ("repository_sha", "0" * 40, "PACK_REPOSITORY_STALE"),
            ("intake_sha", "0" * 64, "PACK_INTAKE_STALE"),
            ("visual_authority", ["stale candidate"], "PACK_PROOF_POSTURE_STALE"),
        ):
            with self.subTest(field=field):
                stored = copy.deepcopy(current)
                stored[field] = value
                with self.assertRaises(CanonError) as raised:
                    require_pack_authorization_current(stored, current)
                self.assertEqual(raised.exception.code, code)


if __name__ == "__main__":
    unittest.main()
