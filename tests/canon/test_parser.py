import os
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

from tools.ambitions_canon import parser as parser_module
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.model import CanonError, DocumentKind, Modality
from tools.ambitions_canon.parser import parse_canon_document, parse_front_matter


FIXTURES = Path(__file__).with_name("fixtures")


class ParserTests(unittest.TestCase):
    OBJECT_BOUNDARY = (
        '[object_boundary]\n'
        'executable_completable = "Yes"\n'
        'occupies_duration = "Optional"\n'
        'consumes_capacity = "When scheduled"\n'
        'due_date = "Yes"\n'
        'recurrence = "Repeatable Step series"\n'
        'substeps = "Yes"\n'
        'goal_path_node = "Yes"\n'
        'proof_requirement = "Optional/suggested/required"\n'
        'attendees_rsvp = "No"\n'
        'alerts = "Optional"\n'
        'type_conversion = "Explicit, receipt-backed"\n'
        'laws = { schedule_placement_nonduplication = "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001", future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001", reminder_acknowledgement_noncompletion = "OBJECT-REMINDER-COMPLETION-001", proof_receipt_separation = "OBJECT-PROOF-REQUIREMENT-001" }\n'
    )
    STATE_COMMAND_CONTRACT = (
        '[[state_command_contracts]]\n'
        'state_id = "UX-STATE-VARIANT-TODAY-DETAIL-OPEN"\n'
        'requirement_id = "TODAY-IDENTITY-001"\n'
        'activation_posture = "active"\n'
        'gate_requirement_ids = []\n'
        'transition_exit = "Open step => destination: Step detail; effect: No durable mutation occurs and no Receipt is created; the selected Step opens for inspection; focus: Step heading."\n'
        'durable_effect = "Opening detail is non-mutating and creates no Receipt."\n'
        'recovery_rollback = "Dismissal returns to the initiating Today row; no rollback is required."\n'
        'offline_behavior = "Open step uses current local state without an account or network."\n'
        'accessibility_focus = "VoiceOver announces the Step and focuses the Step heading after navigation."\n'
        '\n'
        '[[state_command_contracts.commands]]\n'
        'command_id = "CMD-TODAY-DETAIL-OPEN-STEP"\n'
        'label = "Open step"\n'
        'canonical_owner = "surface.today.primary-identity"\n'
        'preconditions = ["Current Step identity exists", "Today row revision is current"]\n'
        'destination = "Step detail"\n'
        'effect = "No durable mutation occurs and no Receipt is created; the selected Step opens for inspection"\n'
        'success_focus = "Step heading"\n'
        'failure_focus = "Initiating Today row"\n'
        'commit_boundary = "Non-mutating: navigation completes without a canonical commit."\n'
        'rollback_undo = "Dismissal returns to Today; no Undo is required."\n'
        'privacy_egress = "No private content leaves the device."\n'
        'verification_ids = ["SCENARIO-TODAY-001"]\n'
    )

    def fixture(self, name: str) -> tuple[Path, str]:
        path = FIXTURES / name
        return path, path.read_text(encoding="utf-8")

    def test_front_matter_parses_toml_scalars_arrays_and_body_line(self):
        path, text = self.fixture("valid-surface.md")

        metadata, body, body_start_line = parse_front_matter(text, path)

        self.assertEqual(metadata["spec_id"], "SURFACE-TODAY")
        self.assertEqual(metadata["canon_revision"], 1)
        self.assertEqual(
            metadata["owns_concepts"],
            ["surface.today.primary-identity"],
        )
        self.assertEqual(metadata["inherits"], ["MISSION-001"])
        self.assertEqual(metadata["depends_on"], ["OBJECT-STEP"])
        self.assertEqual(
            metadata["source_owners"],
            ["Native/Ambitions/Surfaces/Today"],
        )
        self.assertEqual(body_start_line, 14)
        self.assertTrue(body.startswith("\n## Purpose and user question\n"))
        self.assertTrue(body.endswith("around now.\n"))

    def test_document_parses_section_requirement_metadata_and_exact_body(self):
        path, text = self.fixture("valid-surface.md")

        document = parse_canon_document(path, text)

        self.assertEqual(document.spec_id, "SURFACE-TODAY")
        self.assertEqual(document.title, "Today")
        self.assertIs(document.kind, DocumentKind.SURFACE)
        self.assertEqual(document.status, "normative")
        self.assertEqual(document.owner_domain, "product")
        self.assertEqual(document.canon_revision, 1)
        self.assertEqual(document.profile, "surface-v1")
        self.assertEqual(
            document.owns_concepts,
            ("surface.today.primary-identity",),
        )
        self.assertEqual(document.inherits, ("MISSION-001",))
        self.assertEqual(document.depends_on, ("OBJECT-STEP",))
        self.assertEqual(
            document.source_owners,
            ("Native/Ambitions/Surfaces/Today",),
        )
        self.assertEqual(document.sections, frozenset({"purpose"}))
        self.assertEqual(document.not_applicable, ())
        self.assertEqual(document.source_path, path)

        self.assertEqual(len(document.requirements), 1)
        requirement = document.requirements[0]
        self.assertEqual(requirement.requirement_id, "TODAY-IDENTITY-001")
        self.assertEqual(requirement.title, "Primary identity")
        self.assertEqual(requirement.concept, "surface.today.primary-identity")
        self.assertIs(requirement.modality, Modality.MUST)
        self.assertEqual(requirement.scope, "Today root at rest")
        self.assertEqual(requirement.status, "normative")
        self.assertEqual(requirement.verification, ("SCENARIO-TODAY-001",))
        self.assertEqual(requirement.supersedes, ("DECISION-044",))
        self.assertEqual(
            requirement.body,
            "Today presents the user’s actionable reality around now.",
        )
        self.assertEqual(requirement.source_path, path)
        self.assertEqual(requirement.line, 20)

    def test_requirement_heading_accepts_global_stable_target_ids(self):
        path, text = self.fixture("valid-surface.md")
        stable_id = "SPEC-PRIVACY-EGRESS-001-EGRESS-REVIEW-5AC00A76"
        text = text.replace("TODAY-IDENTITY-001", stable_id)

        document = parse_canon_document(path, text)

        self.assertEqual(document.requirements[0].requirement_id, stable_id)

    def test_requirement_heading_keeps_numeric_ids_and_rejects_unsafe_ids(self):
        path, valid = self.fixture("valid-surface.md")
        self.assertEqual(
            parse_canon_document(path, valid).requirements[0].requirement_id,
            "TODAY-IDENTITY-001",
        )
        for invalid in ("spec-privacy-001", "SPEC/PRIVACY-001", "SPEC--001"):
            with self.subTest(invalid=invalid):
                text = valid.replace("TODAY-IDENTITY-001", invalid)
                with self.assertRaises(CanonError):
                    parse_canon_document(path, text)

    def test_front_matter_validation_matches_closed_specification_schema(self):
        path, valid = self.fixture("valid-surface.md")
        cases = {
            "unknown-key": valid.replace(
                'title = "Today"\n', 'title = "Today"\nextra = "forbidden"\n'
            ),
            "empty-spec-id": valid.replace(
                'spec_id = "SURFACE-TODAY"', 'spec_id = ""'
            ),
            "whitespace-owner": valid.replace(
                'owner_domain = "product"', 'owner_domain = "   "'
            ),
            "negative-revision": valid.replace(
                "canon_revision = 1", "canon_revision = -1"
            ),
            "empty-profile": valid.replace(
                'profile = "surface-v1"', 'profile = ""'
            ),
            "duplicate-concept": valid.replace(
                'owns_concepts = ["surface.today.primary-identity"]',
                'owns_concepts = ["surface.today.primary-identity", '
                '"surface.today.primary-identity"]',
            ),
            "invalid-concept": valid.replace(
                'owns_concepts = ["surface.today.primary-identity"]',
                'owns_concepts = ["Surface Today"]',
            ),
            "empty-source-owner": valid.replace(
                'source_owners = ["Native/Ambitions/Surfaces/Today"]',
                'source_owners = [" "]',
            ),
            "not-applicable-extra-key": valid.replace(
                "+++\n\n## Purpose",
                '[not_applicable.performance]\n'
                'rationale = "No runtime work."\n'
                'owner = "Product"\n'
                'extra = "forbidden"\n'
                "+++\n\n## Purpose",
                1,
            ),
            "not-applicable-invalid-section": valid.replace(
                "+++\n\n## Purpose",
                '[not_applicable."Performance Work"]\n'
                'rationale = "No runtime work."\n'
                'owner = "Product"\n'
                "+++\n\n## Purpose",
                1,
            ),
        }

        for name, text in cases.items():
            with self.subTest(name=name):
                with self.assertRaises(CanonError) as raised:
                    parse_canon_document(path, text)
                self.assertEqual(raised.exception.code, "CANON_PARSE_FRONT_MATTER")

    def test_valid_not_applicable_contract_is_parsed_deterministically(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "+++\n\n## Purpose",
            '[not_applicable.performance]\n'
            'rationale = "This specification performs no runtime work."\n'
            'owner = "Product"\n'
            "+++\n\n## Purpose",
            1,
        )

        document = parse_canon_document(path, text)

        self.assertEqual(len(document.not_applicable), 1)
        self.assertEqual(document.not_applicable[0].section, "performance")
        self.assertEqual(
            document.not_applicable[0].rationale,
            "This specification performs no runtime work.",
        )
        self.assertEqual(document.not_applicable[0].owner, "Product")

    def test_object_boundary_front_matter_parses_closed_structured_contract(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace('kind = "surface"', 'kind = "object"')
        text = text.replace("+++\n\n## Purpose", self.OBJECT_BOUNDARY + "+++\n\n## Purpose", 1)

        document = parse_canon_document(path, text)

        self.assertEqual(
            dict(document.object_boundary.capabilities),
            {
                "alerts": "Optional",
                "attendees_rsvp": "No",
                "consumes_capacity": "When scheduled",
                "due_date": "Yes",
                "executable_completable": "Yes",
                "goal_path_node": "Yes",
                "occupies_duration": "Optional",
                "proof_requirement": "Optional/suggested/required",
                "recurrence": "Repeatable Step series",
                "substeps": "Yes",
                "type_conversion": "Explicit, receipt-backed",
            },
        )
        self.assertEqual(len(document.object_boundary.laws), 4)

    def test_object_boundary_rejects_missing_extra_and_invalid_capability(self):
        path, valid = self.fixture("valid-surface.md")
        valid = valid.replace('kind = "surface"', 'kind = "object"')
        valid = valid.replace("+++\n\n## Purpose", self.OBJECT_BOUNDARY + "+++\n\n## Purpose", 1)
        cases = {
            "missing": valid.replace('alerts = "Optional"\n', ""),
            "extra": valid.replace('alerts = "Optional"\n', 'alerts = "Optional"\nscore = "forbidden"\n'),
            "invalid": valid.replace('alerts = "Optional"', 'alerts = ""'),
        }

        for name, text in cases.items():
            with self.subTest(name=name):
                with self.assertRaises(CanonError) as raised:
                    parse_canon_document(path, text)
                self.assertEqual(raised.exception.code, "CANON_OBJECT_BOUNDARY_INVALID")

    def test_state_command_contract_parses_closed_immutable_owner_records(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "Today presents the user’s actionable reality around now.",
            "Today presents the user’s actionable reality around now and authorizes Open step.",
        )
        text = text.replace(
            "+++\n\n## Purpose",
            self.STATE_COMMAND_CONTRACT + "+++\n\n## Purpose",
            1,
        )

        document = parse_canon_document(path, text)

        self.assertEqual(len(document.state_command_contracts), 1)
        contract = document.state_command_contracts[0]
        self.assertEqual(contract.state_id, "UX-STATE-VARIANT-TODAY-DETAIL-OPEN")
        self.assertEqual(contract.requirement_id, "TODAY-IDENTITY-001")
        self.assertEqual(contract.activation_posture, "active")
        self.assertEqual(contract.gate_requirement_ids, ())
        self.assertEqual(len(contract.commands), 1)
        command = contract.commands[0]
        self.assertEqual(command.command_id, "CMD-TODAY-DETAIL-OPEN-STEP")
        self.assertEqual(command.label, "Open step")
        self.assertEqual(command.canonical_owner, "surface.today.primary-identity")
        self.assertEqual(
            command.preconditions,
            ("Current Step identity exists", "Today row revision is current"),
        )
        self.assertEqual(command.verification_ids, ("SCENARIO-TODAY-001",))

    def test_unresolved_target_detection_is_exact_and_preserves_named_states(self):
        unresolved = (
            "destination not yet determined",
            "destination is TBD",
            "route remains TBD",
            "focus is TODO",
            "target pending",
            "the route will be decided later",
            "the destination will be specified later",
            "failure target is TBD",
            "route forthcoming",
            "focus has not been defined",
            "destination to be decided",
            "pending route",
            "unresolved focus",
            "TBD",
        )
        resolved = (
            "the owner root primary object within Unavailable Route Unknown Owner",
            "the original route when current-revision route resolution succeeds",
            "the route-failure reason and Try again control",
            "the pending route requests list",
            "the unknown route diagnostics",
        )

        for value in unresolved:
            with self.subTest(unresolved=value):
                self.assertTrue(parser_module._is_unresolved_command_target(value))
        for value in resolved:
            with self.subTest(resolved=value):
                self.assertFalse(parser_module._is_unresolved_command_target(value))

    def test_state_command_contract_rejects_unknown_missing_duplicate_and_unsorted_fields(self):
        path, valid = self.fixture("valid-surface.md")
        valid = valid.replace(
            "Today presents the user’s actionable reality around now.",
            "Today presents the user’s actionable reality around now and authorizes Open step.",
        )
        valid = valid.replace(
            "+++\n\n## Purpose",
            self.STATE_COMMAND_CONTRACT + "+++\n\n## Purpose",
            1,
        )
        cases = {
            "unknown": valid.replace(
                'activation_posture = "active"\n',
                'activation_posture = "active"\nextra = "forbidden"\n',
            ),
            "missing": valid.replace(
                'offline_behavior = "Open step uses current local state without an account or network."\n',
                "",
            ),
            "duplicate-command": valid.replace(
                "[[state_command_contracts.commands]]",
                "[[state_command_contracts.commands]]\n"
                'command_id = "CMD-TODAY-DETAIL-OPEN-STEP"\n'
                'label = "Open step"\n'
                'canonical_owner = "surface.today.primary-identity"\n'
                'preconditions = ["Current Step identity exists"]\n'
                'destination = "Step detail"\n'
                'effect = "preserves current state"\n'
                'success_focus = "Step heading"\n'
                'failure_focus = "Initiating Today row"\n'
                'commit_boundary = "Navigation is non-mutating."\n'
                'rollback_undo = "No Undo is required."\n'
                'privacy_egress = "No private content leaves the device."\n'
                'verification_ids = ["SCENARIO-TODAY-001"]\n\n'
                "[[state_command_contracts.commands]]",
                1,
            ),
            "unsorted-preconditions": valid.replace(
                '["Current Step identity exists", "Today row revision is current"]',
                '["Today row revision is current", "Current Step identity exists"]',
            ),
        }

        for name, text in cases.items():
            with self.subTest(name=name):
                with self.assertRaises(CanonError) as raised:
                    parse_canon_document(path, text)
                self.assertEqual(raised.exception.code, "CANON_STATE_COMMAND_INVALID")

    def test_requirement_contract_rejects_duplicate_unique_array_members(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "`SCENARIO-TODAY-001`",
            "`SCENARIO-TODAY-001`, `SCENARIO-TODAY-001`",
        )

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_FIELD")
        self.assertIn("duplicate", raised.exception.message)

    def test_public_audit_and_build_fail_closed_on_schema_invalid_markdown(self):
        _, valid = self.fixture("valid-surface.md")
        invalid = valid.replace(
            'title = "Today"\n', 'title = "Today"\nextra = "forbidden"\n'
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            canon = root / "docs/canon"
            (canon / "specifications").mkdir(parents=True)
            (canon / "specifications/today.md").write_text(
                invalid, encoding="utf-8"
            )
            (canon / "MANIFEST.toml").write_text(
                "schema_version = 1\n"
                "canon_revision = 1\n"
                'authority_state = "shadow"\n'
                'compiler_version = "0.1.0"\n'
                'normative_files = ["specifications/today.md"]\n'
                "generated_files = []\n",
                encoding="utf-8",
            )
            previous = Path.cwd()
            try:
                os.chdir(root)
                outputs = []
                results = []
                for arguments in (("audit",), ("build", "--check")):
                    output = StringIO()
                    with redirect_stdout(output):
                        results.append(main(arguments))
                    outputs.append(output.getvalue())
            finally:
                os.chdir(previous)

        self.assertEqual(results, [1, 1])
        for output in outputs:
            self.assertIn("CANON_PARSE_FRONT_MATTER", output)
            self.assertIn("unknown field: extra", output)

    def test_literal_none_produces_empty_reference_tuples(self):
        path, text = self.fixture("invalid-modality.md")
        text = text.replace("`REQUIRED`", "`MAY`")

        requirement = parse_canon_document(path, text).requirements[0]

        self.assertEqual(requirement.verification, ())
        self.assertEqual(requirement.supersedes, ())

    def test_missing_front_matter_raises_stable_error(self):
        path, text = self.fixture("missing-front-matter.md")

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_PARSE_FRONT_MATTER")
        self.assertEqual(raised.exception.path, path)
        self.assertEqual(raised.exception.line, 1)

    def test_invalid_modality_raises_stable_error(self):
        path, text = self.fixture("invalid-modality.md")

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_MODALITY")
        self.assertEqual(raised.exception.path, path)
        self.assertEqual(raised.exception.line, 18)

    def test_duplicate_requirement_in_one_file_raises_stable_error(self):
        path, text = self.fixture("duplicate-requirement.md")

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_DUPLICATE")
        self.assertEqual(raised.exception.path, path)
        self.assertEqual(raised.exception.line, 26)

    def test_malformed_backtick_list_is_not_partially_accepted(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "`SCENARIO-TODAY-001`",
            "`SCENARIO-TODAY-001`, malformed",
        )

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_FIELD")
        self.assertEqual(raised.exception.line, 26)

    def test_requirement_body_stops_before_later_level_two_section(self):
        path, text = self.fixture("valid-surface.md")
        text += (
            "\n## Failure and rollback\n"
            "<!-- canon-section: failure-rollback -->\n\n"
            "The user can undo the change.\n"
        )

        document = parse_canon_document(path, text)

        self.assertEqual(
            document.requirements[0].body,
            "Today presents the user’s actionable reality around now.",
        )
        self.assertEqual(
            document.sections,
            frozenset({"purpose", "failure-rollback"}),
        )

    def test_requirement_body_stops_before_later_section_marker(self):
        path, text = self.fixture("valid-surface.md")
        text += (
            "\n<!-- canon-section: failure-rollback -->\n\n"
            "The user can undo the change.\n"
        )

        document = parse_canon_document(path, text)

        self.assertEqual(
            document.requirements[0].body,
            "Today presents the user’s actionable reality around now.",
        )
        self.assertIn("failure-rollback", document.sections)

    def test_duplicate_metadata_after_separator_is_rejected(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "- **Supersedes:** `DECISION-044`\n\n",
            "- **Supersedes:** `DECISION-044`\n\n"
            "- **Verification:** `SCENARIO-TODAY-002`\n\n",
        )

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_FIELD")
        self.assertEqual(raised.exception.path, path)
        self.assertEqual(raised.exception.line, 29)

    def test_misspelled_metadata_after_separator_is_rejected(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "- **Supersedes:** `DECISION-044`\n\n",
            "- **Supersedes:** `DECISION-044`\n\n"
            "- **Verificaton:** `SCENARIO-TODAY-002`\n\n",
        )

        with self.assertRaises(CanonError) as raised:
            parse_canon_document(path, text)

        self.assertEqual(raised.exception.code, "CANON_REQUIREMENT_FIELD")
        self.assertEqual(raised.exception.path, path)
        self.assertEqual(raised.exception.line, 29)

    def test_ordinary_markdown_bullet_remains_requirement_body(self):
        path, text = self.fixture("valid-surface.md")
        text = text.replace(
            "Today presents the user’s actionable reality around now.",
            "- The user can start from Today.",
        )

        document = parse_canon_document(path, text)

        self.assertEqual(
            document.requirements[0].body,
            "- The user can start from Today.",
        )

    def test_invalid_toml_reports_physical_source_line(self):
        path = Path("invalid-known-line.md")
        text = "\n".join(
            (
                "+++",
                'spec_id = "SURFACE-TODAY"',
                'title = "Today"',
                "kind = [bad]",
                "+++",
            )
        )

        with self.assertRaises(CanonError) as raised:
            parse_front_matter(text, path)

        self.assertEqual(
            str(raised.exception),
            "CANON_PARSE_FRONT_MATTER invalid-known-line.md:4 invalid TOML",
        )

    def test_invalid_toml_at_end_reports_last_front_matter_content_line(self):
        path = Path("invalid-end-of-document.md")
        text = "\n".join(
            (
                "+++",
                'spec_id = "SURFACE-TODAY"',
                'title = "Today"',
                "kind = [",
                "+++",
            )
        )

        with self.assertRaises(CanonError) as raised:
            parse_front_matter(text, path)

        self.assertEqual(
            str(raised.exception),
            "CANON_PARSE_FRONT_MATTER invalid-end-of-document.md:4 invalid TOML",
        )


if __name__ == "__main__":
    unittest.main()
