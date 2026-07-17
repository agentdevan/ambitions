import copy
import json
import unittest
from dataclasses import replace
from pathlib import Path

from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import (
    CanonError,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandRollbackPosture,
)
from tools.ambitions_canon.parser import parse_canon_document
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.task_pack import TaskIntake, build_task_pack


ROOT = Path(__file__).resolve().parents[2]


class CommandResolutionRegistryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        manifest = load_manifest(ROOT)
        cls.canon = build_registry(manifest, load_documents(ROOT, manifest))
        cls.commands = {
            command.command_id: (document, contract, command)
            for document in cls.canon.documents
            for contract in document.state_command_contracts
            for command in contract.commands
        }

    def api(self):
        try:
            from tools.ambitions_canon import command_resolution_registry
        except ImportError as error:
            self.fail(f"command-resolution registry API is missing: {error}")
        return command_resolution_registry

    def loaded(self):
        api = self.api()
        registry = api.load_command_resolution_registry(ROOT)
        return api, registry

    def rehash_record(self, api, record, **changes):
        candidate = replace(record, record_sha256="", **changes)
        return replace(
            candidate,
            record_sha256=api.command_resolution_record_sha256(candidate),
        )

    def record_map(self, registry):
        return {record.resolution_id: record for record in registry.records}

    def state_command_record_map(self, registry):
        return {
            record.command.command_id: record
            for record in registry.state_command_records
        }

    def rehash_state_command_record(self, api, record, **changes):
        candidate = replace(record, record_sha256="", **changes)
        return replace(
            candidate,
            record_sha256=api.state_command_resolution_record_sha256(candidate),
        )

    def test_complete_registry_resolves_every_machine_identity_independently(self):
        api, registry = self.loaded()
        api.validate_command_resolution_bindings(registry, self.canon)
        records = self.record_map(registry)

        expected_ids = set()
        for _, _, command in self.commands.values():
            expected_ids.update(
                {
                    command.destination_id,
                    command.success_focus_id,
                    command.failure_focus_id,
                    command.recovery_id,
                }
            )
            expected_ids.update(
                identifier
                for identifier in (
                    command.inverse_command_id,
                    command.checkpoint_id,
                    command.recovery_handoff_command_id,
                    command.irreversible_confirmation_id,
                    command.irreversible_receipt_id,
                )
                if identifier is not None
            )

        recovery_commands = [
            recovery.command
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for recovery in contract.recovery_commands
        ]
        for command in recovery_commands:
            expected_ids.update(
                {
                    command.destination_id,
                    command.success_focus_id,
                    command.failure_focus_id,
                    command.recovery_id,
                }
            )

        self.assertEqual(len(expected_ids), 2554)
        self.assertEqual(set(records), expected_ids)
        self.assertEqual(len(registry.records), len(expected_ids))
        self.assertTrue(all(item.record_sha256 for item in registry.records))
        self.assertTrue(all(item.behavior_binding.behavior_sha256 for item in registry.records))

    def test_inverse_and_handoff_ids_resolve_to_actual_state_commands(self):
        api, registry = self.loaded()
        records = self.record_map(registry)
        inverse = []
        handoff = []
        for document, contract, command in self.commands.values():
            if command.inverse_command_id is not None:
                inverse.append(
                    (
                        document,
                        contract,
                        command,
                        records[command.inverse_command_id],
                        registry.state_command_records_by_id[
                            command.inverse_command_id
                        ],
                    )
                )
            if command.recovery_handoff_command_id is not None:
                handoff.append(
                    (
                        document,
                        contract,
                        command,
                        records[command.recovery_handoff_command_id],
                        registry.state_command_records_by_id[
                            command.recovery_handoff_command_id
                        ],
                    )
                )

        self.assertEqual(len(inverse), 36)
        self.assertEqual(len(handoff), 12)
        for kind, rows in (("inverse_command", inverse), ("recovery_handoff_command", handoff)):
            for document, contract, source, resolution, referent in rows:
                with self.subTest(kind=kind, command_id=source.command_id):
                    self.assertEqual(resolution.resolution_kind, "recovery_command")
                    self.assertEqual(resolution.mechanism_kind, kind)
                    self.assertIsInstance(referent, StateCommand)
                    self.assertEqual(referent.command_id, resolution.resolution_id)
                    self.assertEqual(referent.canonical_owner, source.recovery_owner)
                    self.assertNotEqual(referent.destination, source.rollback_undo)
                    preconditions = " ".join(referent.preconditions).casefold()
                    self.assertIn(source.command_id.casefold(), preconditions)
                    self.assertIn("exact trigger receipt", preconditions)
                    self.assertIn("current", preconditions)
                    self.assertEqual(
                        resolution.state_command_record_sha256,
                        self.state_command_record_map(registry)[
                            referent.command_id
                        ].record_sha256,
                    )
        api.validate_command_resolution_bindings(registry, self.canon)

    def test_inverse_recovery_redo_is_machine_bound_to_original_trigger(self):
        inverse_records = [
            (document, contract, recovery)
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for recovery in contract.recovery_commands
            if recovery.mechanism_kind == "inverse_command"
        ]
        self.assertEqual(len(inverse_records), 36)
        for _, _, recovery in inverse_records:
            with self.subTest(command_id=recovery.command.command_id):
                self.assertEqual(
                    getattr(recovery, "redo_command_id", None),
                    recovery.trigger_command_id,
                )
                self.assertEqual(
                    getattr(recovery, "redo_preconditions", ()),
                    (
                        "current inverse Receipt",
                        "current revision",
                        "fresh task authorization",
                    ),
                )
                self.assertIsNone(recovery.command.inverse_command_id)

        document, contract, recovery = inverse_records[0]
        source = document.source_path.read_text(encoding="utf-8")
        current = (
            f'redo_command_id = "{recovery.trigger_command_id}"'
        )
        invalid = 'redo_command_id = "CMD-UNRELATED-REDO-001"'
        if current in source:
            mutated = source.replace(current, invalid, 1)
        else:
            marker = f'command_id = "{recovery.command.command_id}"'
            self.assertIn(marker, source)
            mutated = source.replace(marker, f"{marker}\n{invalid}", 1)
        with self.assertRaisesRegex(
            CanonError,
            "redo command must bind original trigger",
        ):
            parse_canon_document(document.source_path, mutated)

    def test_setup_skip_inverses_clear_marker_and_commit_supplied_answer_atomically(self):
        expected = {
            "CMD-SETUP-FIRST-USE-IN-PROGRESS-004-INVERSE": "chapter",
            "CMD-SETUP-FIRST-USE-IN-PROGRESS-005-INVERSE": "question",
        }
        actual = {
            recovery.command.command_id: recovery.command
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for recovery in contract.recovery_commands
            if recovery.command.command_id in expected
        }
        self.assertEqual(set(actual), set(expected))
        for command_id, scope in expected.items():
            command = actual[command_id]
            effect = command.effect.casefold()
            commit = command.commit_boundary.casefold()
            with self.subTest(command_id=command_id):
                self.assertIn(f"clears the exact {scope} skip marker", effect)
                self.assertIn("commits the supplied answer", effect)
                self.assertIn("atomically", effect)
                self.assertIn("supplied answer", commit)
                self.assertIn("exact skip marker", commit)

    def test_recovery_commands_are_separate_from_primary_ui_commands(self):
        primary = {
            command.command_id
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for command in contract.commands
        }
        recovery = {
            record.command.command_id: record
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for record in contract.recovery_commands
        }
        references = {
            identifier
            for _, _, command in self.commands.values()
            for identifier in (
                command.inverse_command_id,
                command.recovery_handoff_command_id,
            )
            if identifier is not None
        }

        self.assertEqual(len(primary), 575)
        self.assertEqual(len(recovery), 48)
        self.assertTrue(primary.isdisjoint(recovery))
        self.assertEqual(set(recovery), references)
        for identifier, record in recovery.items():
            with self.subTest(command_id=identifier):
                self.assertEqual(record.command.command_id, identifier)
                self.assertIn(
                    record.mechanism_kind,
                    {"inverse_command", "recovery_handoff_command"},
                )
                self.assertIn(record.trigger_command_id, primary)

    def test_recovery_command_corpus_rejects_generic_behavior_templates(self):
        recovery = [
            record
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for record in contract.recovery_commands
        ]
        self.assertEqual(len(recovery), 48)
        forbidden_exact = {
            (
                "The command reverses only the exact proven trigger effect by "
                "appending a reversing Event, updating the Projection, and "
                "creating a new inverse Receipt and History entry; the original "
                "trigger Receipt and History remain intact."
            ),
            (
                "No durable mutation occurs and no Receipt is created; the exact "
                "trigger Receipt and scope route only to {owner}; canonical "
                "state, Projection, Receipt, and History remain unchanged."
            ),
        }
        semantic_signatures = set()
        for record in recovery:
            command = record.command
            with self.subTest(command_id=command.command_id):
                normalized_effect = command.effect.replace(
                    command.canonical_owner,
                    "{owner}",
                )
                self.assertNotIn(normalized_effect, forbidden_exact)
                self.assertNotIn(
                    "the owning presentation for the exact",
                    command.destination.casefold(),
                )
                self.assertNotIn(
                    "recovery presentation scoped only to the exact trigger receipt",
                    command.destination.casefold(),
                )
                signature = (
                    command.destination,
                    command.effect,
                    command.success_focus,
                    command.failure_focus,
                )
                self.assertNotIn(signature, semantic_signatures)
                semantic_signatures.add(signature)

    def test_parser_rejects_formulaic_recovery_behavior_even_when_safety_words_match(self):
        path = ROOT / "docs/canon/specifications/global/capture.md"
        source = path.read_text(encoding="utf-8")
        contract = next(
            item
            for item in parse_canon_document(path, source).state_command_contracts
            if item.state_id
            == "UX-STATE-VARIANT-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED"
        )
        recovery = next(
            item.command
            for item in contract.recovery_commands
            if item.trigger_command_id
            == "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001"
        )
        generic = (
            "The command reverses only the exact proven trigger effect by "
            "appending a reversing Event, updating the Projection, and creating "
            "a new inverse Receipt and History entry; the original trigger "
            "Receipt and History remain intact."
        )
        mutated = source.replace(
            f'effect = "{recovery.effect}"',
            f'effect = "{generic}"',
            1,
        )
        with self.assertRaisesRegex(
            CanonError,
            "generic recovery command behavior",
        ):
            parse_canon_document(path, mutated)

    def test_recovery_command_nested_identities_are_current_and_independently_resolved(self):
        _, registry = self.loaded()
        records = self.record_map(registry)
        recovery_commands = [
            record.command
            for document in self.canon.documents
            for contract in document.state_command_contracts
            for record in contract.recovery_commands
        ]
        nested_ids = {
            identifier
            for command in recovery_commands
            for identifier in (
                command.destination_id,
                command.success_focus_id,
                command.failure_focus_id,
                command.recovery_id,
            )
        }
        self.assertEqual(len(nested_ids), 192)
        for command in recovery_commands:
            for identifier in (
                command.destination_id,
                command.success_focus_id,
                command.failure_focus_id,
                command.recovery_id,
            ):
                with self.subTest(command_id=command.command_id, identifier=identifier):
                    record = records[identifier]
                    self.assertEqual(record.command_id, command.command_id)
                    self.assertEqual(record.owner_concept, command.canonical_owner)
                    self.assertEqual(record.posture, "current")

    def test_missing_duplicate_wrong_owner_and_behavior_drift_fail_closed(self):
        api, registry = self.loaded()
        state_records = self.state_command_record_map(registry)
        sample = next(iter(state_records.values()))

        missing = replace(
            registry,
            state_command_records=tuple(
                item
                for item in registry.state_command_records
                if item.command.command_id != sample.command.command_id
            ),
        )
        with self.assertRaisesRegex(CanonError, "state command record is missing"):
            api.validate_command_resolution_bindings(missing, self.canon)

        duplicate = replace(
            registry,
            state_command_records=(*registry.state_command_records, sample),
        )
        with self.assertRaisesRegex(CanonError, "duplicate state command record"):
            api.validate_command_resolution_bindings(duplicate, self.canon)

        wrong_owner_command = replace(
            sample.command,
            canonical_owner="wrong.owner",
            recovery_owner="wrong.owner",
        )
        wrong_owner = self.rehash_state_command_record(
            api,
            sample,
            command=wrong_owner_command,
        )
        wrong_owner_registry = replace(
            registry,
            state_command_records=tuple(
                wrong_owner
                if item.command.command_id == sample.command.command_id
                else item
                for item in registry.state_command_records
            ),
        )
        with self.assertRaisesRegex(CanonError, "state command owner binding"):
            api.validate_command_resolution_bindings(wrong_owner_registry, self.canon)

        drifted_command = replace(
            sample.command,
            privacy_egress=f"{sample.command.privacy_egress} Drifted.",
        )
        drifted = self.rehash_state_command_record(
            api,
            sample,
            command=drifted_command,
        )
        drifted_registry = replace(
            registry,
            state_command_records=tuple(
                drifted
                if item.command.command_id == sample.command.command_id
                else item
                for item in registry.state_command_records
            ),
        )
        with self.assertRaisesRegex(CanonError, "state command behavior binding"):
            api.validate_command_resolution_bindings(drifted_registry, self.canon)

    def test_state_command_record_hash_commits_non_prose_fields(self):
        api, registry = self.loaded()
        sample = registry.state_command_records[0]
        posture = (
            StateCommandActivationPosture.FUTURE_GATED
            if sample.command.activation_posture
            is StateCommandActivationPosture.ACTIVE
            else StateCommandActivationPosture.ACTIVE
        )
        mutated = replace(
            sample,
            command=replace(sample.command, activation_posture=posture),
        )
        candidate = replace(
            registry,
            state_command_records=(mutated, *registry.state_command_records[1:]),
        )
        with self.assertRaisesRegex(CanonError, "state command record hash"):
            api.validate_command_resolution_bindings(candidate, self.canon)

    def test_missing_resolution_and_wrong_owner_fail_closed(self):
        api, registry = self.loaded()
        destination = next(
            record
            for record in registry.records
            if record.resolution_kind == "destination"
        )
        missing = replace(
            registry,
            records=tuple(
                record
                for record in registry.records
                if record.resolution_id != destination.resolution_id
            ),
        )
        with self.assertRaisesRegex(CanonError, "resolution record is missing"):
            api.validate_command_resolution_bindings(missing, self.canon)

        wrong_owner = self.rehash_record(
            api,
            destination,
            owner_concept="wrong.owner",
        )
        malformed = replace(
            registry,
            records=tuple(
                wrong_owner
                if record.resolution_id == destination.resolution_id
                else record
                for record in registry.records
            ),
        )
        with self.assertRaisesRegex(CanonError, "resolution owner binding"):
            api.validate_command_resolution_bindings(malformed, self.canon)

    def test_machine_identity_is_registry_allocated_not_command_formula(self):
        api, registry = self.loaded()
        document, contract, command = self.commands[
            "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001"
        ]
        records = self.record_map(registry)
        old_record = records[command.destination_id]
        independent_id = "DEST-INDEPENDENT-RESOLUTION-TEST-001"
        independent = self.rehash_record(
            api,
            old_record,
            resolution_id=independent_id,
        )
        candidate_registry = replace(
            registry,
            records=tuple(
                independent
                if record.resolution_id == old_record.resolution_id
                else record
                for record in registry.records
            ),
        )
        candidate_command = replace(command, destination_id=independent_id)

        api.resolve_state_command_machine_contract(
            candidate_registry,
            document.source_path,
            contract,
            candidate_command,
        )

        source = document.source_bytes.decode("utf-8")
        parsed = parse_canon_document(
            document.source_path,
            source.replace(
                f'destination_id = "{command.destination_id}"',
                f'destination_id = "{independent_id}"',
                1,
            ),
        )
        self.assertEqual(
            next(
                item.destination_id
                for state in parsed.state_command_contracts
                for item in state.commands
                if item.command_id == command.command_id
            ),
            independent_id,
        )

    def test_resolution_cache_does_not_expose_shared_mutable_projection(self):
        api, registry = self.loaded()
        document, contract, command = self.commands[
            "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001"
        ]
        first = api.resolve_state_command_machine_contract(
            registry,
            document.source_path,
            contract,
            command,
        )
        first["destination"]["resolution_record"][
            "resolution_id"
        ] = "DEST-CACHE-POISON"

        second = api.resolve_state_command_machine_contract(
            registry,
            document.source_path,
            contract,
            command,
        )

        self.assertIsNot(first, second)
        self.assertEqual(
            second["destination"]["resolution_record"]["resolution_id"],
            command.destination_id,
        )

    def test_all_eight_reviewed_prose_contradictions_break_governed_binding(self):
        api, registry = self.loaded()
        cases = (
            (
                "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001",
                "destination",
                "The destination will emerge after a later implementation.",
            ),
            (
                "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001",
                "success_focus",
                "Focus will be wired in a subsequent change.",
            ),
            (
                "CMD-CAPTURE-ATTACHMENT-ATTACHMENT-FAILED-001",
                "rollback_undo",
                "A typed inverse command is planned for a later iteration.",
            ),
            (
                "CMD-CAPTURE-COMPOSER-DISCARD-REVIEW-001",
                "rollback_undo",
                "A checkpoint restore is planned for the next iteration.",
            ),
            (
                "CMD-ACCOUNT-STATUS-SIGNED-IN-001",
                "rollback_undo",
                "A recovery handoff is planned after launch.",
            ),
            (
                "CMD-TIME-DETAIL-VIEWING-003",
                "rollback_undo",
                (
                    "The change is irreversible; confirmation is planned after "
                    "launch; a Receipt records scope."
                ),
            ),
            (
                "CMD-ACCOUNT-BOUNDARY-ACCOUNT-IDENTITY-ONLY-001",
                "rollback_undo",
                (
                    "On failure, the command is expected to preserve the prior "
                    "view once wiring lands."
                ),
            ),
            (
                "CMD-ACCOUNT-SIGN-IN-CANCELLED-001",
                "rollback_undo",
                (
                    "On cancellation, the external flow is expected to leave "
                    "local state unchanged after wiring lands."
                ),
            ),
        )
        for command_id, field, value in cases:
            document, contract, command = self.commands[command_id]
            with self.subTest(command_id=command_id, field=field):
                with self.assertRaisesRegex(
                    CanonError,
                    "behavior/source binding",
                ):
                    api.resolve_state_command_machine_contract(
                        registry,
                        document.source_path,
                        contract,
                        replace(command, **{field: value}),
                    )

    def test_all_mechanism_kinds_have_equivalent_declared_records(self):
        api, registry = self.loaded()
        records = self.record_map(registry)
        expected = {
            StateCommandRollbackPosture.INVERSE_COMMAND: (
                "inverse_command_id",
                "recovery_command",
                "inverse_command",
            ),
            StateCommandRollbackPosture.CHECKPOINT_RESTORE: (
                "checkpoint_id",
                "checkpoint",
                "checkpoint_restore",
            ),
            StateCommandRollbackPosture.OWNER_RECOVERY_HANDOFF: (
                "recovery_handoff_command_id",
                "recovery_command",
                "recovery_handoff_command",
            ),
            StateCommandRollbackPosture.CONFIRMED_IRREVERSIBLE: (
                "irreversible_confirmation_id",
                "confirmation",
                "irreversible_confirmation",
            ),
        }
        for _, _, command in self.commands.values():
            if command.rollback_posture not in expected:
                continue
            field, kind, mechanism = expected[command.rollback_posture]
            resolution = records[getattr(command, field)]
            with self.subTest(command_id=command.command_id, field=field):
                self.assertEqual(resolution.resolution_kind, kind)
                self.assertEqual(resolution.mechanism_kind, mechanism)
        receipt_records = [
            records[command.irreversible_receipt_id]
            for _, _, command in self.commands.values()
            if command.irreversible_receipt_id is not None
        ]
        self.assertEqual(len(receipt_records), 2)
        self.assertTrue(
            all(item.resolution_kind == "receipt" for item in receipt_records)
        )

    def test_full_structured_behavior_digest_rejects_non_prose_mutations(self):
        api, registry = self.loaded()
        document, contract, command = self.commands[
            "CMD-APP-DEEP-LINK-INTAKE-CONSUMED-001"
        ]
        cases = (
            ("label", f"{command.label} changed"),
            ("preconditions", (*command.preconditions, "A synthetic condition.")),
            ("effect", f"{command.effect} Changed."),
            ("commit_boundary", f"{command.commit_boundary} Changed."),
            ("privacy_egress", f"{command.privacy_egress} Changed."),
            ("verification_ids", (*command.verification_ids, "SYNTHETIC-VERIFY")),
            ("gate_requirement_ids", (*command.gate_requirement_ids, "APP-001")),
            ("recovery_owner", f"{command.recovery_owner}.changed"),
        )
        for field, value in cases:
            with self.subTest(field=field):
                with self.assertRaisesRegex(CanonError, "behavior/source binding"):
                    api.resolve_state_command_machine_contract(
                        registry,
                        document.source_path,
                        contract,
                        replace(command, **{field: value}),
                    )

        inverse_document, inverse_contract, inverse_command = next(
            value
            for value in self.commands.values()
            if value[2].inverse_command_id is not None
        )
        with self.assertRaises(CanonError):
            api.resolve_state_command_machine_contract(
                registry,
                inverse_document.source_path,
                inverse_contract,
                replace(
                    inverse_command,
                    inverse_command_id="CMD-INDEPENDENT-RECOVERY-TEST-001",
                ),
            )

    def test_task_pack_consumes_resolved_record_references(self):
        _, registry = self.loaded()
        intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "VISUAL-R1-RESOLUTION-REFERENCE",
                "task_type": "release",
                "scope": ["account.command-contract"],
                "changed_files": ["docs/canon/specifications/app/account.md"],
                "claim_type": "governance",
                "known_issue_ids": [],
            }
        )
        pack = build_task_pack(self.canon, intake, "repo-sha", ())
        machine = pack.command_authorizations[0]["machine_contract"]
        self.assertEqual(
            machine["resolution_registry"]["registry_id"],
            registry.registry_id,
        )
        reference = machine["destination"]["resolution_record"]
        self.assertEqual(set(reference), {"record_sha256", "resolution_id"})
        self.assertEqual(
            reference["record_sha256"],
            self.record_map(registry)[reference["resolution_id"]].record_sha256,
        )

    def test_task_pack_projects_full_recovery_command_behavior(self):
        intake = TaskIntake.from_json(
            {
                "schema_version": 1,
                "issue_id": "VISUAL-R1-RECOVERY-BEHAVIOR",
                "task_type": "release",
                "scope": ["APP-LAUNCH-SETUP-COMMAND-CONTRACT-001"],
                "changed_files": [
                    "docs/canon/specifications/app/launch-and-setup.md"
                ],
                "claim_type": "governance",
                "known_issue_ids": [],
            }
        )
        pack = build_task_pack(self.canon, intake, "repo-sha", ())
        record = next(
            item
            for item in pack.command_authorizations
            if item["command_id"] == "CMD-SETUP-FIRST-USE-IN-PROGRESS-004"
        )
        recovery = record["machine_contract"]["recovery"]
        self.assertIn("mechanism_commands", recovery)
        mechanisms = recovery["mechanism_commands"]
        self.assertEqual(len(mechanisms), 1)
        mechanism = mechanisms[0]
        behavior = mechanism["behavior"]
        self.assertEqual(
            mechanism["trigger_command_id"],
            record["command_id"],
        )
        self.assertEqual(mechanism["mechanism_kind"], "inverse_command")
        self.assertEqual(
            mechanism["redo"],
            {
                "authorization_posture": "fresh_task_authorization_required",
                "command_id": record["command_id"],
                "receipt_posture": "current_inverse_receipt_required",
                "revision_posture": "current_revision_required",
            },
        )
        self.assertEqual(
            set(behavior),
            {
                "activation_posture",
                "canonical_owner",
                "command_id",
                "commit_boundary",
                "effect",
                "failure_focus",
                "gate_dependency_ids",
                "gate_requirement_ids",
                "label",
                "preconditions",
                "presentation",
                "privacy_egress",
                "recovery_id",
                "recovery_owner",
                "recovery_posture",
                "rollback_undo",
                "verification_ids",
            },
        )
        self.assertTrue(behavior["preconditions"])
        self.assertIn("reversing Event", behavior["effect"])
        self.assertTrue(behavior["commit_boundary"].startswith("Inverse mutation:"))
        self.assertIn("unsafe", behavior["failure_focus"])
        self.assertIn("off device", behavior["privacy_egress"])
        self.assertTrue(behavior["verification_ids"])
        self.assertEqual(
            set(behavior["presentation"]),
            {
                "destination",
                "destination_id",
                "destination_posture",
                "failure_focus_id",
                "failure_focus_posture",
                "success_focus",
                "success_focus_id",
                "success_focus_posture",
            },
        )

    def test_durable_report_has_exact_bounded_candidate_rollback(self):
        report = (
            ROOT / ".superpowers/sdd/visual-command-contract-amendment-report.md"
        ).read_text(encoding="utf-8")
        base = "57943fd21a3afa268ef5ad680b28f0d1efd085eb"
        self.assertIn(f"`{base}..HEAD`", report)
        self.assertIn(f"git revert --no-commit {base}..HEAD", report)
        self.assertIn("Broader historical rollback", report)

    def test_blueprint_consumes_resolved_records_not_bare_formula_ids(self):
        _, registry = self.loaded()
        records = self.record_map(registry)
        blueprint = json.loads(
            (ROOT / "docs/canon/migration/ux-blueprint.json").read_text(
                encoding="utf-8"
            )
        )
        projections = [
            command
            for model in blueprint["state_models"]
            for variant in model["variants"]
            for command in variant["machine_command_contracts"]
        ]
        self.assertEqual(len(projections), 575)
        for projection in projections:
            with self.subTest(command_id=projection["command_id"]):
                self.assertEqual(
                    projection["resolution_registry"]["registry_id"],
                    registry.registry_id,
                )
                self.assertRegex(
                    projection["resolution_registry"]["source_sha256"],
                    r"^[0-9a-f]{64}$",
                )
                self.assertIn("resolution_record", projection["destination"])
                self.assertIn("resolution_record", projection["success_focus"])
                self.assertIn("resolution_record", projection["failure_focus"])
                self.assertIn("resolution_record", projection["recovery"])
                self.assertIn("mechanism_records", projection["recovery"])
                for field in (
                    "destination",
                    "success_focus",
                    "failure_focus",
                    "recovery",
                ):
                    reference = projection[field]["resolution_record"]
                    self.assertEqual(
                        set(reference),
                        {"record_sha256", "resolution_id"},
                    )
                    self.assertEqual(
                        reference["record_sha256"],
                        records[reference["resolution_id"]].record_sha256,
                    )


if __name__ == "__main__":
    unittest.main()
