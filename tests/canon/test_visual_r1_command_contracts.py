import copy
import json
import re
import tomllib
import unittest
from dataclasses import replace
from pathlib import Path
from unittest.mock import patch

from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.parser import (
    _validate_state_command_semantics,
    parse_canon_document,
)
from tools.ambitions_canon.task_pack import require_pack_authorization_current
from tools.ambitions_canon.ux_blueprint import (
    UXBlueprintError,
    declared_current_state_commands,
    future_gated_state_commands,
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

APPROVED_LAW_COMMAND_LABELS = {
    "APP-ACCOUNT-COMMAND-CONTRACT-001": {
        "Cancel",
        "Continue Without an Account",
        "Done",
        "Sign Out",
        "Sign in with Apple",
        "Sign in with Google",
        "Try Again",
    },
    "APP-DEEP-LINK-COMMAND-CONTRACT-001": {
        "Dismiss",
        "Try Again",
        "Unlock",
        "Update Ambitions",
    },
    "APP-DEGRADED-COMMAND-CONTRACT-001": {
        "Export Data",
        "Open Diagnostics",
        "Open Settings",
        "Refresh Source",
        "Retry External Update",
        "Retry Failed Items",
        "Review Access",
        "Review Conflict",
        "Review Continuity Status",
        "Review Details",
        "Review Partial Import",
        "Review Source",
        "Review Storage",
        "Unlock and Retry",
    },
    "APP-LAUNCH-SETUP-COMMAND-CONTRACT-001": {
        "Back",
        "Continue",
        "Export Data",
        "Open Diagnostics",
        "Resume Setup",
        "Review Repair",
        "Save and Exit",
        "Skip Setup for Now",
        "Skip This Chapter",
        "Skip This Question",
        "Start Over Setup",
        "Try Again",
    },
    "APP-PERMISSIONS-COMMAND-CONTRACT-001": {
        "Allow Calendar Access",
        "Allow Notifications",
        "Check Again",
        "Done",
        "Not Now",
        "Open Settings",
        "Review Access",
        "Use Local Only",
    },
    "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001": {
        "Clear Selection",
        "Done",
        "Edit before import",
        "Edit notification rules",
        "Ignore",
        "Ignore for planning",
        "Import and reflow",
        "Import into Ambitions",
        "Import Selected",
        "Import with Ambitions notifications",
        "Import without Ambitions notifications",
        "Import without reflow",
        "Keep external",
        "Keep external but reserve time",
        "Link",
        "Reject permanently",
        "Replace",
        "Retry Failed Items",
        "Review Selected",
        "Select All in Group",
        "Select Item",
        "Undo Imported Items",
    },
    "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001": {
        "Apply Filters",
        "Cancel Rebuild",
        "Clear Filters",
        "Clear Search",
        "Filters",
        "Inspect History",
        "Inspect Privacy",
        "Inspect Receipt",
        "Inspect Source",
        "Rebuild Search",
        "Undo",
    },
    "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001": {
        "Cancel",
        "Delete Permanently",
        "Edit",
        "Entire Series",
        "Import into Ambitions",
        "Keep external but reserve time",
        "Link",
        "Move to Trash",
        "Open in Calendar",
        "Restore",
        "Save",
        "This Occurrence",
        "This and Following",
    },
    "SPEC-SURFACE-YOU-ENTITLEMENT-COMMAND-CONTRACT-001": {
        "Check Again",
        "Done",
        "Manage Subscription",
        "Purchase",
        "Restore Purchases",
        "Review Account",
        "View Plans",
    },
    "SYSTEM-CONTINUITY-COMMAND-CONTRACT-001": {
        "Enable Continuity",
        "Keep Other Copy",
        "Keep This Device",
        "Merge Selected Changes",
        "Pause Continuity",
        "Restore Reviewed Copy",
        "Resume Continuity",
        "Review Conflict",
        "Review Continuity Status",
        "Review Migration",
        "Review Restore",
        "Start Migration",
        "Try Again",
        "Turn Off Continuity",
    },
    "SYSTEM-DIAGNOSTICS-COMMAND-CONTRACT-001": {
        "Cancel",
        "Create Diagnostic File",
        "Done",
        "Inspect",
        "Preview Diagnostic Export",
        "Quarantine Affected Data",
        "Review Quarantine",
        "Review Repair",
        "Run Health Check",
        "Run Repair",
        "Try Again",
    },
    "SYSTEM-NOTIFICATIONS-COMMAND-CONTRACT-001": {
        "Add Proof",
        "Complete",
        "Create Rule",
        "Done",
        "Edit Rule",
        "Open Event",
        "Open Settings",
        "Reconcile",
        "Remove Rule",
        "Reschedule",
        "Review Reflow",
        "Snooze",
        "Start",
        "Try Again",
        "Turn Off",
    },
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

    def test_complete_approved_law_command_inventory_is_structured(self):
        parsed = {requirement_id: set() for requirement_id in APPROVED_LAW_COMMAND_LABELS}
        for contract in self.contracts.values():
            if contract.requirement_id in parsed:
                parsed[contract.requirement_id].update(
                    command.label for command in contract.commands
                )
        missing = {
            requirement_id: sorted(expected - parsed[requirement_id])
            for requirement_id, expected in APPROVED_LAW_COMMAND_LABELS.items()
            if expected - parsed[requirement_id]
        }
        unexpected = {
            requirement_id: sorted(parsed[requirement_id] - expected)
            for requirement_id, expected in APPROVED_LAW_COMMAND_LABELS.items()
            if parsed[requirement_id] - expected
        }
        self.assertEqual(sum(len(labels) for labels in missing.values()), 0, missing)
        self.assertEqual(unexpected, {})

    def test_every_approved_law_command_declares_explicit_posture_and_gates(self):
        records = []
        for requirement_id, relative in APPROVED_REQUIREMENT_OWNERS.items():
            path = ROOT / "docs/canon/specifications" / relative
            metadata = tomllib.loads(
                path.read_text(encoding="utf-8").split("+++", 2)[1]
            )
            for contract in metadata["state_command_contracts"]:
                if contract["requirement_id"] != requirement_id:
                    continue
                for command in contract["commands"]:
                    records.append((requirement_id, command))
                    self.assertIn("activation_posture", command)
                    self.assertIn("gate_requirement_ids", command)
        self.assertEqual(len(records), 239)

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
                    active = declared_current_state_commands(contract)
                    future = future_gated_state_commands(contract)
                    self.assertEqual(
                        variant["allowed_commands"],
                        [command.label for command in active],
                    )
                    self.assertEqual(
                        variant["future_gated_commands"], list(future)
                    )
                    for command in contract.commands:
                        if command.activation_posture.value != "future_gated":
                            continue
                        self.assertTrue(command.gate_requirement_ids)
                        self.assertTrue(
                            set(command.gate_requirement_ids)
                            <= {
                                item["requirement_id"]
                                for item in self.blueprint[
                                    "requirement_dispositions"
                                ]
                            }
                        )
                    if contract.activation_posture.value == "future_gated":
                        self.assertEqual(active, ())
                        self.assertTrue(contract.gate_requirement_ids)
                        self.assertTrue(
                            set(contract.gate_requirement_ids)
                            <= {
                                item["requirement_id"]
                                for item in self.blueprint[
                                    "requirement_dispositions"
                                ]
                            }
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
            prefix + "CONFLICTED-QUARANTINED": [
                "Review Conflict",
                "Keep Other Copy",
                "Keep This Device",
                "Merge Selected Changes",
            ],
            prefix + "DISABLED": ["Review Continuity Status"],
            prefix + "ELIGIBLE-NOT-ENABLED": ["Enable Continuity"],
            prefix + "ENABLED-IDLE": ["Turn Off Continuity"],
            prefix + "INELIGIBLE": ["Review Continuity Status"],
            prefix + "LOCAL-PENDING": ["Pause Continuity"],
            prefix + "MERGING": ["Review Conflict"],
            prefix + "MIGRATING": ["Review Migration", "Start Migration"],
            prefix + "PAUSED": ["Resume Continuity"],
            prefix + "REMOTE-PENDING": ["Review Conflict"],
            prefix + "RESTORING": [
                "Review Restore",
                "Restore Reviewed Copy",
            ],
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
                self.assertEqual(declared_current_state_commands(contract), ())
                self.assertEqual(
                    [item["label"] for item in future_gated_state_commands(contract)],
                    expected[state_id],
                )
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
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-REJECTED": [
                "Dismiss",
                "Unlock",
                "Update Ambitions",
            ],
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
            "UX-STATE-VARIANT-TIME-DETAIL-CONFLICT-REVIEW": [
                "Cancel",
                "Entire Series",
                "This Occurrence",
                "This and Following",
            ],
            "UX-STATE-VARIANT-TIME-DETAIL-EDITING": ["Cancel", "Save"],
            "UX-STATE-VARIANT-TIME-DETAIL-SAVED": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-UNDO-ELIGIBLE": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-UNDO-UNAVAILABLE": ["Edit"],
            "UX-STATE-VARIANT-TIME-DETAIL-VIEWING": [
                "Edit",
                "Move to Trash",
                "Delete Permanently",
                "Import into Ambitions",
                "Keep external but reserve time",
                "Link",
                "Open in Calendar",
                "Restore",
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
                for command in contract.commands:
                    with self.subTest(command_id=command.command_id):
                        joined = " ".join(command.preconditions).casefold()
                        self.assertTrue(
                            any(
                                identity_fact in joined
                                for identity_fact in (
                                    "current revision",
                                    "current object revision",
                                    "confirmed source identity",
                                    "current allowlisted external calendar identity",
                                )
                            )
                        )
                        self.assertRegex(joined, r"\b(?:ownership|owned|external)\b")

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
                "Clear Selection",
                "Edit before import",
                "Edit notification rules",
                "Ignore",
                "Ignore for planning",
                "Import and reflow",
                "Import into Ambitions",
                "Import with Ambitions notifications",
                "Import without Ambitions notifications",
                "Import without reflow",
                "Keep external",
                "Keep external but reserve time",
                "Link",
                "Reject permanently",
                "Replace",
                "Select All in Group",
                "Select Item",
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
                    [
                        command.label
                        for command in declared_current_state_commands(contract)
                    ],
                    labels,
                )
                future = future_gated_state_commands(contract)
                if state_id.endswith("-EXPIRED"):
                    self.assertEqual(
                        [item["label"] for item in future], ["Purchase"]
                    )
                    self.assertEqual(
                        future[0]["gate_requirement_ids"],
                        [
                            "ENTITLEMENT-003",
                            "SPEC-SURFACE-YOU-ENTITLEMENT-COMMAND-CONTRACT-001",
                        ],
                    )
                else:
                    self.assertEqual(future, ())

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
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DELIVERED": [
                "Done",
                "Add Proof",
                "Complete",
                "Open Event",
                "Reschedule",
                "Review Reflow",
                "Snooze",
                "Start",
            ],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-DISABLED": ["Open Settings"],
            "UX-STATE-VARIANT-YOU-NOTIFICATIONS-EXTERNALLY-FAILED": [
                "Try Again",
                "Reconcile",
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
            "UX-STATE-VARIANT-SEARCH-RESULTS-RESULTS": [
                "Filters",
                "Apply Filters",
            ],
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

    def test_entitlement_purchase_and_continuity_mutations_remain_future_gated(self):
        product_registries = sorted(
            path
            for path in (ROOT / "docs/canon").rglob("*")
            if path.is_file()
            and path.name == "command-gate-dependencies.json"
        )
        self.assertEqual(
            product_registries,
            [ROOT / "docs/canon/registries/command-gate-dependencies.json"],
        )
        entitlement_contracts = [
            contract
            for state_id, contract in self.contracts.items()
            if state_id.startswith("UX-STATE-VARIANT-YOU-ENTITLEMENT-")
        ]
        purchase = [
            command
            for contract in entitlement_contracts
            for command in contract.commands
            if command.label == "Purchase"
        ]
        self.assertEqual(len(purchase), 1)
        self.assertEqual(purchase[0].activation_posture.value, "future_gated")
        self.assertIn("ENTITLEMENT-003", purchase[0].gate_requirement_ids)
        self.assertEqual(
            purchase[0].gate_dependency_ids,
            ("GATE-STOREKIT-PRODUCT-REGISTRY-001",),
        )

        entitlement_states = {
            variant["blueprint_id"]: variant
            for model in self.blueprint["state_models"]
            if model["screen_id"] == "UX-SCREEN-YOU-ENTITLEMENT"
            for variant in model["variants"]
        }
        self.assertTrue(
            any(
                item["label"] == "Purchase"
                for state in entitlement_states.values()
                for item in state["future_gated_commands"]
            )
        )
        self.assertFalse(
            any(
                "Purchase" in state["allowed_commands"]
                for state in entitlement_states.values()
            )
        )

        continuity_mutations = {
            "Enable Continuity",
            "Keep Other Copy",
            "Keep This Device",
            "Merge Selected Changes",
            "Pause Continuity",
            "Restore Reviewed Copy",
            "Resume Continuity",
            "Start Migration",
            "Turn Off Continuity",
        }
        commands = [
            command
            for state_id, contract in self.contracts.items()
            if "CONTINUITY" in state_id and not state_id.endswith("-DISABLED")
            for command in contract.commands
            if command.label in continuity_mutations
        ]
        self.assertEqual({command.label for command in commands}, continuity_mutations)
        for command in commands:
            with self.subTest(command_id=command.command_id):
                self.assertEqual(command.activation_posture.value, "future_gated")
                self.assertIn(
                    "SYSTEM-CONTINUITY-DISABLED-001",
                    command.gate_requirement_ids,
                )

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
                "command recovery owner is unresolved",
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
            ("destination", "TBD"),
            ("destination", "pending route"),
            ("destination", "destination to be decided"),
            ("destination", "destination is TBD"),
            ("destination", "route remains TBD"),
            ("destination", "target pending"),
            ("destination", "the route will be decided later"),
            ("destination", "the destination will be specified later"),
            ("destination", "unspecified"),
            ("destination", "unknown"),
            ("success_focus", "unresolved focus"),
            ("success_focus", "pending focus target"),
            ("success_focus", "focus to be decided"),
            ("success_focus", "focus is TODO"),
            ("success_focus", "unspecified"),
            ("failure_focus", "unresolved focus"),
            ("failure_focus", "failure target is TBD"),
            ("failure_focus", "unknown"),
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

    def test_equivalent_modal_target_prose_cannot_authorize_resolution(self):
        contract = self.contracts[
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED"
        ]
        adversarial = (
            "destination is pending approval",
            "destination awaits definition",
            "route to be finalized",
            "destination is unknown to the implementation",
        )

        for value in adversarial:
            with self.subTest(value=value):
                command = replace(contract.commands[0], destination=value)
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

    def test_complete_corpus_declares_machine_target_focus_and_recovery_identity(self):
        expected_postures = {"current"}
        for contract in self.contracts.values():
            for command in contract.commands:
                with self.subTest(command_id=command.command_id):
                    self.assertRegex(command.destination_id, r"^DEST-[A-Z0-9-]+$")
                    self.assertIn(command.destination_posture.value, expected_postures)
                    self.assertRegex(command.success_focus_id, r"^FOCUS-[A-Z0-9-]+$")
                    self.assertIn(command.success_focus_posture.value, expected_postures)
                    self.assertRegex(command.failure_focus_id, r"^FOCUS-[A-Z0-9-]+$")
                    self.assertIn(command.failure_focus_posture.value, expected_postures)
                    self.assertRegex(command.recovery_id, r"^RECOVERY-[A-Z0-9-]+$")
                    self.assertIn(command.recovery_posture.value, expected_postures)
                    self.assertEqual(command.recovery_owner, command.canonical_owner)

    def test_blueprint_projects_exact_machine_command_contracts(self):
        variants = {
            variant["blueprint_id"]: variant
            for model in self.blueprint["state_models"]
            for variant in model["variants"]
        }
        for state_id, contract in self.contracts.items():
            with self.subTest(state_id=state_id):
                projected = variants[state_id]["machine_command_contracts"]
                self.assertEqual(
                    [item["command_id"] for item in projected],
                    [item.command_id for item in contract.commands],
                )
                for record, command in zip(projected, contract.commands, strict=True):
                    self.assertEqual(record["destination"]["id"], command.destination_id)
                    self.assertEqual(record["success_focus"]["id"], command.success_focus_id)
                    self.assertEqual(record["failure_focus"]["id"], command.failure_focus_id)
                    self.assertEqual(record["recovery"]["id"], command.recovery_id)

    def test_concrete_named_routes_with_status_words_remain_valid(self):
        contract = self.contracts[
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED"
        ]
        for destination in (
            "the pending route requests list",
            "the unknown route diagnostics",
        ):
            with self.subTest(destination=destination):
                command = replace(contract.commands[0], destination=destination)
                _validate_state_command_semantics(
                    Path("fixture.md"),
                    contract.state_id,
                    contract.durable_effect,
                    contract.recovery_rollback,
                    contract.offline_behavior,
                    contract.accessibility_focus,
                    [command],
                )

    def test_full_document_and_blueprint_reject_placeholder_targets(self):
        from tools.ambitions_canon import ux_blueprint

        path = ROOT / "docs/canon/specifications/app/deep-linking.md"
        source = path.read_text(encoding="utf-8")
        contract = self.contracts[
            "UX-STATE-VARIANT-APP-DEEP-LINK-INTAKE-CONSUMED"
        ]
        placeholders = (
            "destination is TBD",
            "route remains TBD",
            "focus is TODO",
            "target pending",
            "the route will be decided later",
            "the destination will be specified later",
            "failure target is TBD",
        )
        for placeholder in placeholders:
            with self.subTest(placeholder=placeholder, layer="document"):
                mutated_source = re.sub(
                    r'^destination = "[^"]+"$',
                    f'destination = "{placeholder}"',
                    source,
                    count=1,
                    flags=re.MULTILINE,
                )
                with self.assertRaisesRegex(
                    CanonError, "unresolved command route or focus"
                ):
                    parse_canon_document(path, mutated_source)

            malformed = replace(
                contract,
                commands=(replace(contract.commands[0], destination=placeholder),),
            )
            contracts = tuple(
                malformed if item.state_id == malformed.state_id else item
                for item in self.contracts.values()
            )
            with self.subTest(placeholder=placeholder, layer="blueprint"):
                with patch.object(
                    ux_blueprint,
                    "load_state_command_contracts",
                    return_value=contracts,
                ):
                    with self.assertRaisesRegex(
                        (CanonError, UXBlueprintError),
                        "unresolved command route or focus",
                    ):
                        validate_ux_blueprint(ROOT, copy.deepcopy(self.blueprint))

    def test_mutation_without_actionable_rollback_is_rejected(self):
        contract = self.contracts["UX-STATE-VARIANT-TIME-DETAIL-EDITING"]
        mutation = next(
            command for command in contract.commands if command.label == "Save"
        )
        self.assertIn(
            mutation.rollback_posture.value,
            {
                "checkpoint_restore",
                "confirmed_irreversible",
                "inverse_command",
                "owner_recovery_handoff",
            },
        )
        invalid = (
            "Rollback is unavailable.",
            "Undo is unavailable.",
            "Rollback has not been specified.",
            "No recovery is provided.",
            "No safe inverse exists.",
            "Checkpoint restore is not available for this mutation.",
            "Recovery is impossible; owner handoff is named only for completeness.",
            "This is irreversible but no confirmation exists.",
            "TBD",
            (
                "Rollback is unavailable, although inverse command, checkpoint restore, "
                "owner handoff, typed rollback, and Undo are all mentioned."
            ),
        )
        for rollback in invalid:
            commands = [
                replace(command, rollback_undo=rollback)
                if command.command_id == mutation.command_id
                else command
                for command in contract.commands
            ]
            with self.subTest(rollback=rollback):
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

    def test_every_rollback_posture_rejects_deferred_or_negated_execution(self):
        cases = (
            (
                "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED",
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                (
                    "A typed inverse command will be specified later.",
                    "A typed inverse command is TBD.",
                    "A typed inverse command cannot safely restore the prior state.",
                    "A typed inverse command is listed for completeness but cannot be executed.",
                    "A typed inverse command may be available in a future release.",
                ),
            ),
            (
                "UX-STATE-VARIANT-CAPTURE-COMPOSER-DISCARD-REVIEW",
                "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-001",
                (
                    "The checkpoint restore will be specified later.",
                    "The checkpoint restore cannot be executed.",
                ),
            ),
            (
                "UX-STATE-VARIANT-ACCOUNT-STATUS-SIGNED-IN",
                "CMD-ACCOUNT-STATUS-SIGNED-IN-001",
                (
                    "The owner recovery handoff is TBD.",
                    "The owner recovery handoff may be available in a future release.",
                ),
            ),
            (
                "UX-STATE-VARIANT-TIME-DETAIL-VIEWING",
                "CMD-TIME-DETAIL-VIEWING-003",
                (
                    "The irreversible scope, confirmation, and Receipt will be specified later.",
                    "The irreversible scope is confirmed but no Receipt can be produced.",
                ),
            ),
        )
        for state_id, command_id, invalid_values in cases:
            contract = self.contracts[state_id]
            original = next(
                command for command in contract.commands if command.command_id == command_id
            )
            _validate_state_command_semantics(
                Path("fixture.md"),
                contract.state_id,
                contract.durable_effect,
                contract.recovery_rollback,
                contract.offline_behavior,
                contract.accessibility_focus,
                list(contract.commands),
            )
            for rollback in invalid_values:
                commands = [
                    replace(command, rollback_undo=rollback)
                    if command.command_id == original.command_id
                    else command
                    for command in contract.commands
                ]
                with self.subTest(
                    posture=original.rollback_posture.value,
                    rollback=rollback,
                ):
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

    def test_every_recovery_class_rejects_equivalent_modal_execution_prose(self):
        cases = (
            (
                "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED",
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                "A typed inverse command is pending implementation.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED",
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                "A typed inverse command is specified for documentation only.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED",
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                "A typed inverse command may someday exist.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-CAPTURE-COMPOSER-DISCARD-REVIEW",
                "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-001",
                "A checkpoint restore is pending implementation.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-ACCOUNT-STATUS-SIGNED-IN",
                "CMD-ACCOUNT-STATUS-SIGNED-IN-001",
                "A recovery handoff is pending implementation.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-TIME-DETAIL-VIEWING",
                "CMD-TIME-DETAIL-VIEWING-003",
                "The change is irreversible; confirmation remains pending; a Receipt records scope.",
                "mutation command omits actionable rollback",
            ),
            (
                "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY",
                "CMD-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001",
                "On failure, the command might preserve the prior view.",
                "command recovery is unresolved",
            ),
            (
                "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-CANCELLED",
                "CMD-ACCOUNT-SIGN-IN-CANCELLED-001",
                "On cancellation, the external flow may leave local state unchanged.",
                "command recovery is unresolved",
            ),
        )
        for state_id, command_id, rollback, expected in cases:
            contract = self.contracts[state_id]
            commands = [
                replace(command, rollback_undo=rollback)
                if command.command_id == command_id
                else command
                for command in contract.commands
            ]
            with self.subTest(command_id=command_id, rollback=rollback):
                with self.assertRaisesRegex(CanonError, expected):
                    _validate_state_command_semantics(
                        Path("fixture.md"),
                        contract.state_id,
                        contract.durable_effect,
                        contract.recovery_rollback,
                        contract.offline_behavior,
                        contract.accessibility_focus,
                        commands,
                    )

    def test_external_and_non_mutating_commands_reject_unresolved_recovery(self):
        cases = (
            (
                "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-CANCELLED",
                "CMD-ACCOUNT-SIGN-IN-CANCELLED-001",
            ),
            (
                "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY",
                "CMD-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001",
            ),
        )
        invalid_values = (
            "TBD",
            "No recovery is specified.",
            "Cancellation behavior will be specified later.",
            "Recovery may be available in a future release.",
        )
        for state_id, command_id in cases:
            contract = self.contracts[state_id]
            original = next(
                command for command in contract.commands if command.command_id == command_id
            )
            for rollback in invalid_values:
                commands = [
                    replace(command, rollback_undo=rollback)
                    if command.command_id == original.command_id
                    else command
                    for command in contract.commands
                ]
                with self.subTest(
                    commit_boundary=original.commit_boundary,
                    rollback=rollback,
                ):
                    with self.assertRaisesRegex(
                        CanonError,
                        "command recovery is unresolved",
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

    def test_document_and_blueprint_reject_invalid_recovery_for_every_posture(self):
        from tools.ambitions_canon import ux_blueprint

        cases = (
            (
                "global/capture.md",
                "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED",
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                "A typed inverse command will be specified later.",
                "mutation command omits actionable rollback",
            ),
            (
                "global/capture.md",
                "UX-STATE-VARIANT-CAPTURE-COMPOSER-DISCARD-REVIEW",
                "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-001",
                "The checkpoint restore cannot be executed.",
                "mutation command omits actionable rollback",
            ),
            (
                "app/launch-and-setup.md",
                "UX-STATE-VARIANT-ACCOUNT-STATUS-SIGNED-IN",
                "CMD-ACCOUNT-STATUS-SIGNED-IN-001",
                "The owner recovery handoff may be available in a future release.",
                "mutation command omits actionable rollback",
            ),
            (
                "surfaces/time.md",
                "UX-STATE-VARIANT-TIME-DETAIL-VIEWING",
                "CMD-TIME-DETAIL-VIEWING-003",
                "The irreversible scope, confirmation, and Receipt will be specified later.",
                "mutation command omits actionable rollback",
            ),
            (
                "app/launch-and-setup.md",
                "UX-STATE-VARIANT-ACCOUNT-SIGN-IN-CANCELLED",
                "CMD-ACCOUNT-SIGN-IN-CANCELLED-001",
                "No recovery is specified.",
                "command recovery is unresolved",
            ),
            (
                "app/launch-and-setup.md",
                "UX-STATE-VARIANT-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY",
                "CMD-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001",
                "TBD",
                "command recovery is unresolved",
            ),
        )
        for relative, state_id, command_id, invalid, expected in cases:
            path = ROOT / "docs/canon/specifications" / relative
            source = path.read_text(encoding="utf-8")
            contract = self.contracts[state_id]
            command = next(
                item for item in contract.commands if item.command_id == command_id
            )
            original = f'rollback_undo = "{command.rollback_undo}"'
            replacement = f'rollback_undo = "{invalid}"'
            self.assertIn(original, source)
            mutated_source = source.replace(original, replacement, 1)
            with self.subTest(state_id=state_id, layer="document"):
                with self.assertRaisesRegex(CanonError, expected):
                    parse_canon_document(path, mutated_source)

            malformed = replace(
                contract,
                commands=tuple(
                    replace(item, rollback_undo=invalid)
                    if item.command_id == command_id
                    else item
                    for item in contract.commands
                ),
            )
            contracts = tuple(
                malformed if item.state_id == state_id else item
                for item in self.contracts.values()
            )
            with self.subTest(state_id=state_id, layer="blueprint"):
                with patch.object(
                    ux_blueprint,
                    "load_state_command_contracts",
                    return_value=contracts,
                ):
                    with self.assertRaisesRegex(
                        (CanonError, UXBlueprintError),
                        expected,
                    ):
                        validate_ux_blueprint(ROOT, copy.deepcopy(self.blueprint))

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
