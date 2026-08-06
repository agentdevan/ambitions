from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from pathlib import Path
import re
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


def completed_template(document_type: str) -> str:
    contents = re.sub(
        r"<!-- PRODUCT-DOC-DRAFT:.*?-->",
        "Complete content.",
        approved_template(document_type),
    )
    if document_type == "scope":
        contents = contents.replace(
            "## Requirements\n\nComplete content.",
            "## Requirements\n\n- REQ-001: The user can complete the outcome.",
        )
    if document_type == "design":
        contents = contents.replace(
            "## Requirement traceability\n\nComplete content.",
            "## Requirement traceability\n\n- REQ-001: DESIGN-001 completes the outcome.",
        )
    if document_type == "research":
        contents = replace_section(
            contents,
            "Frontend impact investigation",
            "\n".join(
                (
                    "- Potential frontend impact: none",
                    "- Existing surfaces investigated: N/A — structural fixture.",
                    "- Evidence and unknowns: N/A — structural fixture.",
                )
            ),
        )
    if document_type == "scope":
        contents = replace_section(
            contents,
            "Frontend impact contract",
            "\n".join(
                (
                    "- Surface impact: none",
                    "- IA/navigation: none",
                    "- Assets/iconography: none",
                    "- Visual language: unchanged",
                    "- Motion: unchanged",
                    "- Copy/localization: N/A — structural fixture.",
                    "- Accessibility: N/A — structural fixture.",
                    "- Visual proof: N/A — structural fixture.",
                )
            ),
        )
    if document_type == "design":
        contents = replace_section(
            contents,
            "Frontend experience specification",
            "\n".join(
                (
                    "- Surface impact: none",
                    "- IA/navigation: none",
                    "- Assets/iconography: none",
                    "- Visual language: unchanged",
                    "- Motion: unchanged",
                    "- Copy/localization: N/A — structural fixture.",
                    "- Accessibility: N/A — structural fixture.",
                    "- Visual proof: N/A — structural fixture.",
                    "- Visual gate: not-required",
                )
            ),
        )
    return contents


def replace_section(contents: str, heading: str, body: str) -> str:
    return re.sub(
        rf"(## {re.escape(heading)}\n\n).*?(?=\n## |\Z)",
        rf"\1{body}\n",
        contents,
        flags=re.DOTALL,
    )


class ValidationTests(unittest.TestCase):
    def test_approved_documents_require_complete_frontend_contract_fields(self) -> None:
        contents = replace_section(
            completed_template("scope"),
            "Frontend impact contract",
            "- Surface impact: existing",
        )

        result = validate_document(parse_document(contents))

        codes = {item.code for item in result.diagnostics}
        self.assertIn("missing-frontend-field", codes)

    def test_frontend_scope_and_design_classifications_must_match(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory) / "example"
            initiative.mkdir()
            research = completed_template("research")
            scope = replace_section(
                completed_template("scope"),
                "Frontend impact contract",
                "\n".join(
                    (
                        "- Surface impact: existing",
                        "- IA/navigation: none",
                        "- Assets/iconography: system-only",
                        "- Visual language: unchanged",
                        "- Motion: unchanged",
                        "- Copy/localization: Existing localized copy patterns.",
                        "- Accessibility: Existing native semantics.",
                        "- Visual proof: Changed-state screenshots.",
                    )
                ),
            )
            design = replace_section(
                completed_template("design"),
                "Frontend experience specification",
                "\n".join(
                    (
                        "- Surface impact: new-child",
                        "- IA/navigation: none",
                        "- Assets/iconography: system-only",
                        "- Visual language: unchanged",
                        "- Motion: unchanged",
                        "- Copy/localization: Existing localized copy patterns.",
                        "- Accessibility: Existing native semantics.",
                        "- Visual proof: One native fixture and viewport.",
                        "- Visual gate: required",
                    )
                ),
            )
            (initiative / "research.md").write_text(research, encoding="utf-8")
            (initiative / "scope.md").write_text(scope, encoding="utf-8")
            (initiative / "design.md").write_text(design, encoding="utf-8")

            result = validate_initiative(initiative)

        self.assertIn(
            "frontend-contract-mismatch",
            {item.code for item in result.diagnostics},
        )

    def test_material_frontend_design_requires_visual_gate(self) -> None:
        contents = replace_section(
            completed_template("design"),
            "Frontend experience specification",
            "\n".join(
                (
                    "- Surface impact: new-child",
                    "- IA/navigation: none",
                    "- Assets/iconography: system-only",
                    "- Visual language: unchanged",
                    "- Motion: unchanged",
                    "- Copy/localization: Existing localized copy patterns.",
                    "- Accessibility: Existing native semantics.",
                    "- Visual proof: One native fixture and viewport.",
                    "- Visual gate: not-required",
                )
            ),
        )

        result = validate_document(parse_document(contents))

        self.assertIn(
            "frontend-visual-gate-required",
            {item.code for item in result.diagnostics},
        )
    def test_status_only_scope_promotion_remains_incomplete(self) -> None:
        result = validate_document(parse_document(approved_template("scope")))

        self.assertIn("approved-placeholder", {item.code for item in result.diagnostics})
        self.assertIn("missing-scope-requirement", {item.code for item in result.diagnostics})

    def test_approved_document_rejects_placeholders(self) -> None:
        contents = completed_template("research").replace(
            "Complete content.",
            "<!-- PRODUCT-DOC-DRAFT: explain the problem -->",
            1,
        )

        result = validate_document(parse_document(contents))

        self.assertIn("approved-placeholder", {item.code for item in result.diagnostics})

    def test_requires_canonical_filename_and_headings(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory) / "example"
            directory.mkdir()
            path = directory / "notes.md"
            path.write_text(completed_template("research").replace("## Evidence", "## Sources"), encoding="utf-8")

            result = validate_document(parse_document(path))

        self.assertEqual(
            {item.code for item in result.diagnostics},
            {"canonical-filename", "missing-required-heading"},
        )

    def test_validates_approval_order_and_upstream_paths(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory) / "example"
            initiative.mkdir()
            (initiative / "research.md").write_text(
                (TEMPLATE_DIRECTORY / "research.md").read_text(encoding="utf-8").replace(
                    'initiative = ""', 'initiative = "example"'
                ),
                encoding="utf-8",
            )
            (initiative / "scope.md").write_text(
                completed_template("scope").replace('upstream = "research.md"', 'upstream = "wrong.md"'),
                encoding="utf-8",
            )
            (initiative / "design.md").write_text(
                completed_template("design").replace('upstream = "scope.md"', 'upstream = "wrong.md"'),
                encoding="utf-8",
            )

            result = validate_initiative(initiative)

        self.assertEqual(
            {item.code for item in result.diagnostics},
            {"research-not-approved", "invalid-upstream"},
        )

    def test_approved_design_directly_reports_unapproved_scope(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory) / "example"
            initiative.mkdir()
            (initiative / "research.md").write_text(
                completed_template("research"), encoding="utf-8"
            )
            (initiative / "scope.md").write_text(
                (TEMPLATE_DIRECTORY / "scope.md")
                .read_text(encoding="utf-8")
                .replace('initiative = ""', 'initiative = "example"'),
                encoding="utf-8",
            )
            (initiative / "design.md").write_text(
                completed_template("design"), encoding="utf-8"
            )

            result = validate_initiative(initiative)

        self.assertIn("scope-not-approved", {item.code for item in result.diagnostics})

    def test_initiative_metadata_and_research_upstream_match_directory(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory) / "example"
            initiative.mkdir()
            (initiative / "research.md").write_text(
                completed_template("research")
                .replace('initiative = "example"', 'initiative = "other"')
                .replace('upstream = ""', 'upstream = "scope.md"'),
                encoding="utf-8",
            )
            (initiative / "scope.md").write_text(
                completed_template("scope"), encoding="utf-8"
            )
            (initiative / "design.md").write_text(
                completed_template("design").replace(
                    'initiative = "example"', 'initiative = "another"'
                ),
                encoding="utf-8",
            )

            result = validate_initiative(initiative)

        codes = {item.code for item in result.diagnostics}
        self.assertIn("initiative-mismatch", codes)
        self.assertIn("invalid-upstream", codes)


if __name__ == "__main__":
    unittest.main()
