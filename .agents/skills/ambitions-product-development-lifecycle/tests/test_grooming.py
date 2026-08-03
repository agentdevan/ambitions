from __future__ import annotations

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.validation import validate_initiative


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


def diagnostics(result) -> set[str]:
    return {item.code for item in result.diagnostics}


def completed_document(document_type: str, *, content: str) -> str:
    return (
        (TEMPLATE_DIRECTORY / f"{document_type}.md")
        .read_text(encoding="utf-8")
        .replace('initiative = ""', 'initiative = "example"')
        .replace('status = "draft"', 'status = "approved"')
        .replace(
            {
                "scope": "Define the product requirements without inventing implementation design.",
                "design": "Map each Scope requirement to the Design decisions that satisfy it.",
            }.get(document_type, ""),
            content,
        )
    )


def complete_initiative(directory: Path) -> None:
    (directory / "research.md").write_text(
        completed_document("research", content=""), encoding="utf-8"
    )
    (directory / "scope.md").write_text(
        completed_document("scope", content="- REQ-001: The user can complete the intended outcome."),
        encoding="utf-8",
    )
    (directory / "design.md").write_text(
        completed_document("design", content="- REQ-001: The primary flow completes the outcome."),
        encoding="utf-8",
    )


class GroomingValidationTests(unittest.TestCase):
    def test_design_must_trace_every_scope_requirement(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            complete_initiative(initiative)
            scope = initiative / "scope.md"
            scope.write_text(
                scope.read_text(encoding="utf-8").replace(
                    "- REQ-001: The user can complete the intended outcome.",
                    "- REQ-001: The user can complete the intended outcome.\n- REQ-002: The user can recover from a failure.",
                ),
                encoding="utf-8",
            )

            result = validate_initiative(initiative)

        self.assertIn("missing-design-traceability", diagnostics(result))

    def test_started_grooming_requires_all_three_files(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            complete_initiative(initiative)
            implementation = initiative / "implementation"
            implementation.mkdir()
            (implementation / "plan.md").write_text("# Plan\n\nImplementation order.\n", encoding="utf-8")

            result = validate_initiative(initiative)

        self.assertIn("missing-grooming-file", diagnostics(result))

    def test_started_grooming_requires_approved_design(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            complete_initiative(initiative)
            design = initiative / "design.md"
            design.write_text(
                design.read_text(encoding="utf-8").replace(
                    'status = "approved"', 'status = "draft"'
                ),
                encoding="utf-8",
            )
            implementation = initiative / "implementation"
            implementation.mkdir()
            for filename, heading, body in (
                ("plan.md", "Plan", "Implementation order."),
                ("tasks.md", "Tasks", "1. Implement the flow."),
                ("verification.md", "Verification", "Run the focused tests."),
            ):
                (implementation / filename).write_text(
                    f"# {heading}\n\n{body}\n", encoding="utf-8"
                )

            result = validate_initiative(initiative)

        self.assertIn("design-not-approved", diagnostics(result))

    def test_grooming_files_require_a_top_level_heading_and_body(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            complete_initiative(initiative)
            implementation = initiative / "implementation"
            implementation.mkdir()
            (implementation / "plan.md").write_text("# Plan\n\nImplementation order.\n", encoding="utf-8")
            (implementation / "tasks.md").write_text("Tasks without a heading.\n", encoding="utf-8")
            (implementation / "verification.md").write_text("# Verification\n", encoding="utf-8")

            result = validate_initiative(initiative)

        self.assertIn("invalid-grooming-file", diagnostics(result))

    def test_complete_idea_to_grooming_fixture_passes(self) -> None:
        with TemporaryDirectory() as temporary_directory:
            initiative = Path(temporary_directory)
            complete_initiative(initiative)
            implementation = initiative / "implementation"
            implementation.mkdir()
            for filename, heading, body in (
                ("plan.md", "Plan", "Implementation order."),
                ("tasks.md", "Tasks", "1. Implement the flow."),
                ("verification.md", "Verification", "Run the focused tests."),
            ):
                (implementation / filename).write_text(
                    f"# {heading}\n\n{body}\n", encoding="utf-8"
                )

            result = validate_initiative(initiative)

        self.assertTrue(result.valid)


if __name__ == "__main__":
    unittest.main()
