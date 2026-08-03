from __future__ import annotations

from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document
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
            "\nState the intended user and product outcome from approved Research.\n\n",
        )

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


if __name__ == "__main__":
    unittest.main()
