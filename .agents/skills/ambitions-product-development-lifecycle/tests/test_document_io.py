from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document, render_document
from product_docs.errors import ProductDocsError
from product_docs.models import DocumentStatus, DocumentType


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


class DocumentIOTests(unittest.TestCase):
    def test_parse_simple_document(self) -> None:
        research_path = TEMPLATE_DIRECTORY / "research.md"

        document = parse_document(research_path)

        self.assertEqual(document.document_type, DocumentType.RESEARCH)
        self.assertEqual(document.status, DocumentStatus.DRAFT)
        self.assertEqual(document.upstream, "")

    def test_preserves_section_text(self) -> None:
        document = parse_document(TEMPLATE_DIRECTORY / "scope.md")

        self.assertEqual(
            document.sections[0].body,
            "\n<!-- PRODUCT-DOC-DRAFT: State the intended user and product outcome from approved Research. -->\n\n",
        )

    def test_preserves_reviewed_preamble_before_level_two_sections(self) -> None:
        contents = (TEMPLATE_DIRECTORY / "research.md").read_text(encoding="utf-8")
        contents = contents.replace(
            "\n## Idea and user problem",
            "\n# Reviewed research title\n\n**Evidence snapshot:** 2026-08-13\n\n## Idea and user problem",
            1,
        )

        document = parse_document(contents)

        self.assertEqual(
            document.preamble,
            "\n# Reviewed research title\n\n**Evidence snapshot:** 2026-08-13\n\n",
        )
        rendered = render_document(document)
        self.assertEqual(parse_document(rendered).preamble, document.preamble)
        self.assertIn("# Reviewed research title", rendered)

    def test_rejects_extra_frontmatter_fields(self) -> None:
        contents = (TEMPLATE_DIRECTORY / "research.md").read_text(encoding="utf-8")

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(contents.replace('status = "draft"', 'status = "draft"\nextra = "no"'))

        self.assertEqual(raised.exception.diagnostics[0].code, "invalid-frontmatter")

    def test_rejects_malformed_toml_as_invalid_frontmatter(self) -> None:
        with self.assertRaises(ProductDocsError) as raised:
            parse_document("+++\ninitiative = [\n+++\n\n## Idea and user problem\n")

        self.assertEqual(raised.exception.diagnostics[0].code, "invalid-frontmatter")

    def test_rejects_duplicate_headings(self) -> None:
        contents = (TEMPLATE_DIRECTORY / "research.md").read_text(encoding="utf-8")
        duplicate = contents + "\n## Evidence\n\nRepeated.\n"

        with self.assertRaises(ProductDocsError) as raised:
            parse_document(duplicate)

        self.assertEqual(raised.exception.diagnostics[0].code, "duplicate-section-heading")

    def test_path_parse_diagnostic_names_the_source_file(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            path = Path(temporary_directory) / "research.md"
            path.write_text("not TOML frontmatter\n", encoding="utf-8")

            with self.assertRaises(ProductDocsError) as raised:
                parse_document(path)

        self.assertEqual(raised.exception.diagnostics[0].code, "missing-frontmatter")
        self.assertEqual(raised.exception.diagnostics[0].path, str(path))

    def test_invalid_utf8_is_a_stable_path_diagnostic(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            path = Path(temporary_directory) / "research.md"
            path.write_bytes(b"\xff")

            with self.assertRaises(ProductDocsError) as raised:
                parse_document(path)

        self.assertEqual(raised.exception.diagnostics[0].code, "document-decode-error")
        self.assertEqual(raised.exception.diagnostics[0].path, str(path))


if __name__ == "__main__":
    unittest.main()
