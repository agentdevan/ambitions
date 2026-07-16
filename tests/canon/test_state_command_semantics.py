import json
import re
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.parser import parse_canon_document


ROOT = Path(__file__).resolve().parents[2]
SPECIFICATIONS = (
    "app/deep-linking.md",
    "app/degraded-states.md",
    "app/launch-and-setup.md",
    "app/permissions.md",
    "app/shell.md",
    "global/capture.md",
    "global/search.md",
    "global/trust-inspection.md",
    "journeys/external-calendar-import.md",
    "surfaces/goals.md",
    "surfaces/time.md",
    "surfaces/today.md",
    "surfaces/you.md",
    "systems/diagnostics.md",
    "systems/notifications.md",
    "systems/sync-and-continuity.md",
)
class StateCommandSemanticTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.contracts = {}
        for relative in SPECIFICATIONS:
            path = ROOT / "docs/canon/specifications" / relative
            document = parse_canon_document(path, path.read_text(encoding="utf-8"))
            for contract in document.state_command_contracts:
                cls.contracts[contract.state_id] = contract

    def command(self, state_id, label):
        return next(
            command
            for command in self.contracts[state_id].commands
            if command.label == label
        )

    def semantic_text(self, command):
        return " ".join(
            (
                *command.preconditions,
                command.destination,
                command.effect,
                command.success_focus,
                command.failure_focus,
                command.commit_boundary,
                command.rollback_undo,
                command.privacy_egress,
            )
        ).casefold()

    def assert_semantics(self, command, *phrases):
        text = self.semantic_text(command)
        for phrase in phrases:
            with self.subTest(command=command.command_id, phrase=phrase):
                self.assertIn(phrase.casefold(), text)

    def test_normative_command_contract_specs_have_no_malformed_prose(self):
        repeated_space_artifacts = []
        disallowed_prose_slashes = []
        locked_trust_heading = (
            "## SPEC-GLOBAL-TRUST-INSPECTION-001 — Contextual Proof / Source / "
            "Privacy / History / Receipts"
        )
        for relative in SPECIFICATIONS:
            path = ROOT / "docs/canon/specifications" / relative
            text = path.read_text(encoding="utf-8")
            document = parse_canon_document(path, text)
            for contract in document.state_command_contracts:
                semantic_strings = (
                    contract.transition_exit,
                    contract.durable_effect,
                    contract.recovery_rollback,
                    contract.offline_behavior,
                    contract.accessibility_focus,
                    *(
                        value
                        for command in contract.commands
                        for value in (
                            *command.preconditions,
                            command.destination,
                            command.effect,
                            command.success_focus,
                            command.failure_focus,
                            command.commit_boundary,
                            command.rollback_undo,
                            command.privacy_egress,
                        )
                    ),
                )
                for value in semantic_strings:
                    repeated_space_artifacts.extend(
                        (relative, contract.state_id, value)
                        for _ in range(value.count(", or  "))
                    )

            for line_number, line in enumerate(text.splitlines(), start=1):
                if line == locked_trust_heading:
                    continue
                search_from = 0
                while (index := line.find(" / ", search_from)) >= 0:
                    if not line[:index].endswith("explicit state contract"):
                        disallowed_prose_slashes.append(
                            (relative, line_number, line)
                        )
                    search_from = index + len(" / ")

        self.assertEqual(
            (len(repeated_space_artifacts), len(disallowed_prose_slashes)),
            (0, 0),
            msg=(
                "malformed normative prose: "
                f"repeated-space={len(repeated_space_artifacts)}, "
                f"disallowed-slash={len(disallowed_prose_slashes)}"
            ),
        )

    def test_all_433_contracts_reject_self_referential_template_semantics(self):
        commands = [
            command
            for contract in self.contracts.values()
            for command in contract.commands
        ]
        self.assertEqual(len(self.contracts), 433)
        self.assertEqual(len(commands), 520)
        banned = (
            "command review for ux-state-variant-",
            "truthful status for ux-state-variant-",
            "preserves current canonical state for ux-state-variant-",
        )
        for contract in self.contracts.values():
            state_text = " ".join(
                (
                    contract.durable_effect,
                    contract.recovery_rollback,
                    contract.offline_behavior,
                    contract.accessibility_focus,
                )
            ).casefold()
            self.assertNotIn(contract.state_id.casefold(), state_text)
            signatures = set()
            for command in contract.commands:
                command_text = self.semantic_text(command)
                self.assertNotIn(contract.state_id.casefold(), command_text)
                self.assertFalse(any(value in command_text for value in banned))
                self.assertRegex(
                    command.commit_boundary,
                    r"^(Non-mutating|Mutation|External-result):",
                )
                signature = (
                    command.destination,
                    command.effect,
                    command.success_focus,
                    command.commit_boundary,
                    command.rollback_undo,
                )
                self.assertNotIn(signature, signatures)
                signatures.add(signature)

    def test_shell_restores_exact_origin_and_uses_canonical_fallback(self):
        close = self.command(
            "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-COMPACT-MODAL", "Close"
        )
        self.assert_semantics(
            close,
            "origin route",
            "origin object",
            "origin focus",
            "Today root",
            "no durable mutation",
            "no Receipt",
        )
        retry = self.command(
            "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE",
            "Try again",
        )
        returned = self.command(
            "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-UNAVAILABLE-ROUTE", "Return"
        )
        self.assert_semantics(retry, "idempotent", "current revision", "route")
        self.assert_semantics(returned, "canonical owner root", "Today root")
        self.assertNotEqual(retry.destination, returned.destination)

    def test_today_commands_name_conflict_recovery_destructive_loading_permission_and_focus_law(self):
        conflict = self.command("UX-STATE-VARIANT-TODAY-ROOT-CONFLICT", "Review")
        destructive = self.command(
            "UX-STATE-VARIANT-TODAY-ROOT-DESTRUCTIVE-CONFIRMATION", "Not needed"
        )
        loading = self.command("UX-STATE-VARIANT-TODAY-ROOT-LOADING", "Cancel")
        permission = self.command(
            "UX-STATE-VARIANT-TODAY-ROOT-PERMISSION-DENIED",
            "Review calendar access",
        )
        settings = self.command(
            "UX-STATE-VARIANT-TODAY-ROOT-PERMISSION-DENIED", "Open Settings"
        )
        recovery = self.command(
            "UX-STATE-VARIANT-TODAY-ROOT-RECOVERY", "Review recovery"
        )
        restored = self.command(
            "UX-STATE-VARIANT-TODAY-ROOT-RESTORED", "Open step"
        )
        self.assert_semantics(conflict, "Time conflict review", "placement", "Today return")
        self.assert_semantics(
            destructive, "typed Step closure", "Not needed", "Receipt", "History"
        )
        self.assert_semantics(
            loading, "optional", "retained projection", "accepted mutation"
        )
        self.assert_semantics(permission, "calendar permission", "affected Today status")
        self.assert_semantics(settings, "system Settings", "affected Today status")
        self.assertNotEqual(permission.destination, settings.destination)
        self.assert_semantics(
            recovery, "Move it", "Blocked", "Waiting", "Still counts", "Not needed"
        )
        self.assert_semantics(restored, "stable Step", "Start here", "Now heading")

    def test_capture_commands_distinguish_attachment_proposal_dictation_routing_save_scan_and_restore(self):
        state = "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED"
        retry = self.command(state, "Retry")
        replace_attachment = self.command(state, "Replace")
        remove = self.command(state, "Remove")
        self.assert_semantics(retry, "staged attachment identity", "idempotency key")
        self.assert_semantics(replace_attachment, "failed record", "replacement is staged")
        self.assert_semantics(remove, "detach", "explicit", "draft text")
        self.assertEqual(
            len({retry.effect, replace_attachment.effect, remove.effect}),
            3,
        )

        proposal = self.command(
            "UX-STATE-VARIANT-CAPTURE-PROPOSAL-PROPOSAL-CONFLICT", "Review"
        )
        dictation = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-DICTATING", "Stop dictation"
        )
        routing = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-PARTIAL-ROUTING", "Retry routing"
        )
        saving = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVING", "Cancel"
        )
        scanning = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-SCAN-IMPORTING", "Cancel"
        )
        restoring = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-RESTORING", "Cancel"
        )
        undo = self.command(
            "UX-STATE-VARIANT-CAPTURE-COMPOSER-SAVED-UNDO-ELIGIBLE", "Undo"
        )
        self.assert_semantics(proposal, "Goal", "Step", "Reminder", "Event", "Proof", "Note")
        self.assert_semantics(dictation, "transcript", "insertion point", "raw audio")
        self.assert_semantics(routing, "failed route", "draft revision", "duplicate")
        self.assert_semantics(saving, "accepted mutation", "pending Receipt")
        self.assert_semantics(scanning, "camera imagery", "draft")
        self.assert_semantics(restoring, "checkpoint", "restored field")
        self.assert_semantics(undo, "saved Capture result", "reversing event", "Receipt")

    def test_goals_commands_name_activation_archive_delete_end_path_pause_proof_and_repair_boundaries(self):
        activation = self.command(
            "UX-STATE-VARIANT-GOALS-DETAIL-READY-TO-ACTIVATE", "Review activation"
        )
        archive = self.command(
            "UX-STATE-VARIANT-GOALS-DETAIL-ARCHIVED", "Open archive"
        )
        active = self.command(
            "UX-STATE-VARIANT-GOALS-DETAIL-ACTIVE", "Open Goal"
        )
        path = self.command(
            "UX-STATE-VARIANT-GOALS-PATH-NEEDS-ATTENTION", "Review recovery"
        )
        proof = self.command(
            "UX-STATE-VARIANT-GOALS-RECOVERY-PROOF-TRANSFERRING", "Open Goal"
        )
        repair = self.command(
            "UX-STATE-VARIANT-GOALS-RECOVERY-NEEDS-ATTENTION", "Review recovery"
        )
        conflict = self.command(
            "UX-STATE-VARIANT-GOALS-RECOVERY-SCHEDULE-CONFLICT", "Review conflict"
        )
        self.assert_semantics(
            activation, "Life Area", "initial path", "next Step", "proof rule", "non-mutating"
        )
        self.assert_semantics(archive, "archived Goal", "History", "no durable mutation")
        self.assert_semantics(
            active,
            "Pause",
            "End Goal",
            "Archive Goal",
            "Move to Trash",
            "path update",
        )
        self.assert_semantics(path, "path revision", "Restore previous path", "Keep unresolved")
        self.assert_semantics(
            proof, "same Proof identity", "never duplicates evidence or marks", "complete"
        )
        self.assert_semantics(repair, "Clarify", "Retry path", "Edit manually")
        self.assert_semantics(conflict, "Time", "schedule placement", "Goal return")

    def test_time_commands_distinguish_view_navigation_direct_manipulation_import_conflict_and_degraded_gates(self):
        selected = self.command("UX-STATE-VARIANT-TIME-WEEK-SELECTED", "Select")
        today = self.command("UX-STATE-VARIANT-TIME-MONTH-EMPTY", "Today")
        move = self.command("UX-STATE-VARIANT-TIME-DAY-EDITING", "Move")
        start = self.command("UX-STATE-VARIANT-TIME-DAY-EDITING", "Change start")
        duration = self.command("UX-STATE-VARIANT-TIME-DAY-EDITING", "Change duration")
        resolve = self.command("UX-STATE-VARIANT-TIME-DAY-CONFLICTING", "Resolve conflict")
        importing = self.command("UX-STATE-VARIANT-TIME-DAY-IMPORTING", "Cancel")
        external = self.command(
            "UX-STATE-VARIANT-TIME-DEGRADED-EXTERNAL-WRITE-FAILURE",
            "Retry external update",
        )
        local_store = self.command(
            "UX-STATE-VARIANT-TIME-DEGRADED-LOCAL-STORE-DEGRADATION",
            "Retry local store",
        )
        permission = self.command(
            "UX-STATE-VARIANT-TIME-DEGRADED-PERMISSION-DENIED",
            "Review calendar access",
        )
        continuity = self.command(
            "UX-STATE-VARIANT-TIME-DEGRADED-SYNC-CONFLICT", "Review conflict"
        )
        self.assert_semantics(selected, "compact detail", "ephemeral selection", "no Receipt")
        self.assert_semantics(today, "current local date", "preferred view")
        self.assert_semantics(move, "placement preview", "object identity", "current revision")
        self.assert_semantics(start, "start boundary", "placement preview")
        self.assert_semantics(duration, "duration boundary", "placement preview")
        self.assertEqual(len({move.destination, start.destination, duration.destination}), 3)
        self.assert_semantics(
            resolve, "revision-bound Time conflict comparison", "protected", "fixed"
        )
        self.assert_semantics(importing, "pending import", "accepted import")
        self.assert_semantics(external, "outbox", "never replay", "local mutation")
        self.assert_semantics(local_store, "last verified projection", "no saved-success")
        self.assert_semantics(permission, "local Time", "calendar permission")
        self.assert_semantics(
            continuity, "SYSTEM-CONTINUITY-DISABLED-001", "no enable", "merge"
        )
        self.assertEqual(
            self.contracts["UX-STATE-VARIANT-TIME-DEGRADED-SYNC-CONFLICT"].activation_posture,
            "future_gated",
        )

    def test_you_commands_distinguish_account_continuity_privacy_export_reset_diagnostics_notifications_and_settings(self):
        account = self.command(
            "UX-STATE-VARIANT-YOU-ROOT-ACCOUNT-SIGNED-IN", "Open settings"
        )
        continuity = self.command(
            "UX-STATE-VARIANT-YOU-ROOT-CONTINUITY-DISABLED",
            "Review continuity status",
        )
        privacy = self.command(
            "UX-STATE-VARIANT-YOU-SETTINGS-PRIVACY-REVIEW", "Open settings"
        )
        export = self.command(
            "UX-STATE-VARIANT-YOU-DATA-EXPORT-PREVIEW", "Export Data"
        )
        reset = self.command(
            "UX-STATE-VARIANT-YOU-DATA-RESET-REVIEW", "Reset preferences"
        )
        diagnostics = self.command(
            "UX-STATE-VARIANT-YOU-DATA-DIAGNOSTICS-REDACTED", "Open diagnostics"
        )
        notifications = self.command(
            "UX-STATE-VARIANT-YOU-SETTINGS-NOTIFICATION-CONTROLS", "Open settings"
        )
        app_lock = self.command(
            "UX-STATE-VARIANT-YOU-SETTINGS-APP-LOCK-DISABLED", "Turn on App Lock"
        )
        self.assert_semantics(account, "account identity", "entitlement", "private life graph")
        self.assert_semantics(
            continuity, "SYSTEM-CONTINUITY-DISABLED-001", "no enable", "local use"
        )
        self.assert_semantics(privacy, "classification", "egress", "retention")
        self.assert_semantics(export, "scope", "format", "destination", "egress Receipt")
        self.assert_semantics(reset, "preferences only", "private graph", "Receipt")
        self.assert_semantics(diagnostics, "redacted", "no private titles")
        self.assert_semantics(notifications, "notification", "pending edit", "accepted value")
        self.assert_semantics(app_lock, "local authentication", "App Lock setting", "Receipt")

    def test_trust_commands_distinguish_inspect_correct_save_history_receipt_undo_and_privacy(self):
        state = "UX-STATE-VARIANT-TRUST-DEEP-CORRECTING"
        correct = self.command(state, "Correct")
        save = self.command(state, "Save correction")
        history = self.command(
            "UX-STATE-VARIANT-TRUST-DEEP-HISTORY-POPULATED", "History"
        )
        receipt = self.command(
            "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED", "Review"
        )
        undo = self.command(
            "UX-STATE-VARIANT-TRUST-RECEIPT-RECEIPT-COMMITTED-UNDO-ELIGIBLE",
            "Undo",
        )
        privacy = self.command(
            "UX-STATE-VARIANT-TRUST-DEEP-PRIVACY-BOUNDARY-REVIEW",
            "Review privacy",
        )
        self.assert_semantics(correct, "before", "current", "proposed", "non-mutating")
        self.assert_semantics(save, "typed correction", "canonical-owner", "Receipt", "History")
        self.assertNotEqual(correct.destination, save.destination)
        self.assertNotEqual(correct.effect, save.effect)
        self.assert_semantics(
            history, "object-scoped history", "stable History IDs", "non-mutating"
        )
        self.assert_semantics(receipt, "stable Receipt ID", "local inspection", "non-mutating")
        self.assert_semantics(undo, "reversing event", "resulting status", "Receipt")
        self.assert_semantics(privacy, "classification", "destination", "retention", "deny")

    def test_terminal_delete_trash_and_correction_states_only_dismiss_without_mutation(self):
        cases = (
            (
                "UX-STATE-VARIANT-YOU-DATA-PERMANENT-DELETE-IRREVERSIBLE",
                "the surviving You data root",
                "the Data and Storage heading and irreversible result",
                ("Delete local data permanently",),
                ("deletion command", "append", "restore"),
            ),
            (
                "UX-STATE-VARIANT-YOU-DATA-TRASH-EMPTY",
                "the You Data and Storage root",
                "the Trash entry control",
                ("Restore",),
                ("restore command", "append", "trashed object identity"),
            ),
            (
                "UX-STATE-VARIANT-TRUST-DEEP-CORRECTION-COMPLETE",
                "the initiating object or fact inspection",
                "the corrected value and correction Receipt",
                ("Correct", "Save correction"),
                ("typed correction", "append", "proposed correction field"),
            ),
            (
                "UX-STATE-VARIANT-TRUST-DEEP-CORRECTION-REQUIRED",
                "the initiating object or fact inspection",
                "the conflicting claim and evidence",
                ("Correct", "Save correction"),
                ("typed correction", "append", "proposed correction field"),
            ),
        )

        for state_id, destination, focus, impossible_labels, forbidden in cases:
            with self.subTest(state=state_id):
                commands = self.contracts[state_id].commands
                labels = {command.label for command in commands}
                for label in impossible_labels:
                    self.assertNotIn(label, labels)
                self.assertEqual(labels, {"Done"})
                if labels != {"Done"}:
                    continue
                done = commands[0]
                self.assertIn(destination, done.destination)
                self.assertIn(focus, done.success_focus)
                self.assertTrue(done.commit_boundary.startswith("Non-mutating:"))
                self.assertIn("no canonical commit", done.commit_boundary)
                self.assertIn("No durable mutation occurs", done.effect)
                self.assertIn("no Receipt is created", done.effect)
                self.assertIn("No Undo is required", done.rollback_undo)
                semantic_text = self.semantic_text(done)
                for phrase in forbidden:
                    self.assertNotIn(phrase.casefold(), semantic_text)

    def test_review_cited_malformed_prose_is_absent_from_owning_specs(self):
        cases = (
            (
                "app/shell.md",
                "Capture, Search, / Trust inspection",
            ),
            (
                "surfaces/time.md",
                "store, objects, / last verified projection",
            ),
        )
        for relative, malformed in cases:
            with self.subTest(path=relative):
                text = (
                    ROOT / "docs/canon/specifications" / relative
                ).read_text(encoding="utf-8")
                self.assertNotIn(malformed, text)

    def test_parser_rejects_generic_state_id_interpolation(self):
        path = ROOT / "docs/canon/specifications/app/shell.md"
        text = path.read_text(encoding="utf-8")
        state_id = "UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-COMPACT-MODAL"
        text = re.sub(
            r'destination = "[^"]+"',
            f'destination = "Command review for {state_id}"',
            text,
            count=1,
        )
        with self.assertRaisesRegex(CanonError, "generic or self-referential"):
            parse_canon_document(path, text)

    def test_specification_schema_matches_parser_uniqueness_and_no_disclosure_exception(self):
        schema = json.loads(
            (ROOT / "docs/canon/schemas/specification.schema.json").read_text(
                encoding="utf-8"
            )
        )
        contracts = schema["properties"]["state_command_contracts"]
        self.assertTrue(contracts["uniqueItems"])
        contract = contracts["items"]
        commands = contract["properties"]["commands"]
        self.assertTrue(commands["uniqueItems"])
        conditional = contract["allOf"]
        self.assertEqual(len(conditional), 1)
        exception = conditional[0]
        self.assertEqual(
            exception["if"]["patternProperties"]["^state_id$"]["const"],
            "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE",
        )
        self.assertEqual(
            exception["then"]["patternProperties"]["^commands$"]["maxItems"], 0
        )
        self.assertEqual(
            exception["else"]["patternProperties"]["^commands$"]["minItems"], 1
        )

    def test_global_cross_spec_duplicate_command_id_is_rejected(self):
        from tools.ambitions_canon import ux_blueprint

        first = next(iter(self.contracts.values()))
        command = first.commands[0]
        second = replace(
            first,
            state_id="UX-STATE-VARIANT-APP-SHELL-DRILLDOWN-GLOBAL-DUPLICATE",
            commands=(replace(command),),
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / "one.md").write_text("one", encoding="utf-8")
            (root / "two.md").write_text("two", encoding="utf-8")
            records = (
                {"source_path": "one.md"},
                {"source_path": "two.md"},
            )
            documents = iter(
                (
                    SimpleNamespace(state_command_contracts=(first,)),
                    SimpleNamespace(state_command_contracts=(second,)),
                )
            )
            with patch.object(ux_blueprint, "_requirement_records", return_value=records):
                with patch.object(
                    ux_blueprint,
                    "parse_canon_document",
                    side_effect=lambda *_: next(documents),
                ):
                    with self.assertRaisesRegex(
                        ux_blueprint.UXBlueprintError,
                        "duplicate canonical command ID",
                    ):
                        ux_blueprint.load_state_command_contracts(root)


if __name__ == "__main__":
    unittest.main()
