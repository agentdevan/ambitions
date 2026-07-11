import unittest
from pathlib import Path

from tools.ambitions_canon.model import CanonError, DocumentKind, Modality
from tools.ambitions_canon.parser import parse_canon_document, parse_front_matter


FIXTURES = Path(__file__).with_name("fixtures")


class ParserTests(unittest.TestCase):
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
