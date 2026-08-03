from __future__ import annotations

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document
from product_docs.validation import validate_document, validate_initiative


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


def approved_template(document_type: str) -> str:
    template = (TEMPLATE_DIRECTORY / f"{document_type}.md").read_text(encoding="utf-8")
    return template.replace('initiative = ""', 'initiative = "example"').replace(
        'status = "draft"', 'status = "approved"'
    )


class ValidationTests(unittest.TestCase):
    def test_approved_document_rejects_placeholders(self) -> None:
        incomplete_approved_path = TEMPLATE_DIRECTORY / "research.md"
        contents = approved_template("research").replace(
            "Describe the idea, the user problem, and why it matters.",
            "<!-- PRODUCT-DOC-DRAFT: explain the problem -->",
        )

        result = validate_document(parse_document(contents))

        self.assertIn("approved-placeholder", {item.code for item in result.diagnostics})

    def test_requires_canonical_filename_and_headings(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            path = Path(temporary_directory) / "notes.md"
            path.write_text(approved_template("research").replace("## Evidence", "## Sources"), encoding="utf-8")

            result = validate_document(parse_document(path))

        self.assertEqual(
            {item.code for item in result.diagnostics},
            {"canonical-filename", "missing-required-heading"},
        )

    def test_validates_approval_order_and_upstream_paths(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            (initiative / "research.md").write_text(
                (TEMPLATE_DIRECTORY / "research.md").read_text(encoding="utf-8").replace(
                    'initiative = ""', 'initiative = "example"'
                ),
                encoding="utf-8",
            )
            (initiative / "scope.md").write_text(
                approved_template("scope").replace('upstream = "research.md"', 'upstream = "wrong.md"'),
                encoding="utf-8",
            )
            (initiative / "design.md").write_text(
                approved_template("design").replace('upstream = "scope.md"', 'upstream = "wrong.md"'),
                encoding="utf-8",
            )

            result = validate_initiative(initiative)

        self.assertEqual(
            {item.code for item in result.diagnostics},
            {"research-not-approved", "invalid-upstream"},
        )


if __name__ == "__main__":
    unittest.main()
