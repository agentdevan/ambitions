from __future__ import annotations

from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document, render_document, write_document_atomic
from product_docs.errors import ProductDocsError
from product_docs.markdown import parse_markdown_table


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


class DocumentIOTests(unittest.TestCase):
    def test_templates_round_trip_with_ordered_sections(self) -> None:
        for template_path in TEMPLATE_DIRECTORY.glob("*.md"):
            original = template_path.read_text(encoding="utf-8")
            document = parse_document(template_path, repository_root=SKILL_ROOT.parents[2])

            self.assertEqual([section.heading for section in document.sections][0], "Agent handoff summary")
            self.assertEqual([section.heading for section in document.sections][-1], "Review history")
            self.assertEqual(render_document(document), original)

    def test_parses_markdown_table_into_named_rows(self) -> None:
        rows = parse_markdown_table(
            "| ID | Result |\n|---|---|\n| FIND-001 | Supported |\n"
        )

        self.assertEqual(rows, ({"ID": "FIND-001", "Result": "Supported"},))

    def test_rejects_table_width_mismatch(self) -> None:
        with self.assertRaises(ProductDocsError) as raised:
            parse_markdown_table("| ID | Result |\n|---|---|\n| FIND-001 |\n")

        self.assertEqual(raised.exception.diagnostics[0].code, "table-width-mismatch")

    def test_rejects_duplicate_toml_key(self) -> None:
        contents = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        duplicate = contents.replace("schema_version = 1", "schema_version = 1\nschema_version = 1", 1)

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(duplicate, repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "toml-parse-error")

    def test_rejects_unterminated_frontmatter(self) -> None:
        with self.assertRaises(ProductDocsError) as raised:
            parse_document("+++\nschema_version = 1\n", repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "unterminated-frontmatter")

    def test_rejects_unknown_frontmatter_field(self) -> None:
        contents = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        unknown = contents.replace('skill_version = "1.0.0"', 'skill_version = "1.0.0"\nunknown_field = "no"', 1)

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(unknown, repository_root=SKILL_ROOT.parents[2])

        self.assertEqual(raised.exception.diagnostics[0].code, "unknown-frontmatter-field")

    def test_rejects_absolute_and_traversal_binding_paths(self) -> None:
        template = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
        input_record = (
            "\n[[inputs]]\nkind = \"canon\"\nauthority_id = \"CANON-001\"\n"
            'path = "/outside.md"\ncommit = "0123456789abcdef0123456789abcdef01234567"\n'
        )
        with self.assertRaises(ProductDocsError) as absolute:
            parse_document(template.replace("+++\n\n## Agent", input_record + "+++\n\n## Agent", 1), repository_root=SKILL_ROOT.parents[2])
        self.assertEqual(absolute.exception.diagnostics[0].code, "absolute-path")

        traversal_record = input_record.replace('"/outside.md"', '"docs/../outside.md"')
        with self.assertRaises(ProductDocsError) as traversal:
            parse_document(template.replace("+++\n\n## Agent", traversal_record + "+++\n\n## Agent", 1), repository_root=SKILL_ROOT.parents[2])
        self.assertEqual(traversal.exception.diagnostics[0].code, "path-traversal")

    def test_atomic_write_preserves_target_when_candidate_is_invalid(self) -> None:
        with self.subTest("candidate validation"):
            from tempfile import TemporaryDirectory

            with TemporaryDirectory() as temporary_directory:
                root = Path(temporary_directory)
                target = root / "document.md"
                original = TEMPLATE_DIRECTORY.joinpath("research.md").read_text(encoding="utf-8")
                target.write_text(original, encoding="utf-8")
                invalid = original.replace('document_type = "research"', 'document_type = "unsupported"', 1)

                with self.assertRaises(ProductDocsError):
                    write_document_atomic(target, invalid, repository_root=root)

                self.assertEqual(target.read_text(encoding="utf-8"), original)

    def test_diagnostic_serialization_is_stable(self) -> None:
        from product_docs.errors import Diagnostic

        diagnostic = Diagnostic("invalid", "Bad input", path="docs/example.md", section="Findings")
        self.assertEqual(
            list(diagnostic.as_dict()),
            ["code", "message", "path", "section", "identifier", "remediation"],
        )


if __name__ == "__main__":
    unittest.main()
