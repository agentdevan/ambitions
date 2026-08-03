from __future__ import annotations

from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.constants import TEMPLATE_PROFILES


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"
REFERENCE_DIRECTORY = SKILL_ROOT / "references"

REQUIRED_TABLES = {
    "research.md": (
        "| Finding ID | Classification | Finding | Source IDs | Scope implication |",
        "| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |",
    ),
    "scope.md": (
        "| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |",
        "| Acceptance ID | Verifiable condition | Required evidence |",
        "| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |",
    ),
    "design.md": (
        "| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |",
        "| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |",
    ),
}


class TemplateProfileTests(unittest.TestCase):
    def test_profiles_have_the_approved_heading_shapes(self) -> None:
        expected_counts = {
            "research": 18,
            "scope": 22,
            "design": 28,
        }

        self.assertEqual(set(TEMPLATE_PROFILES), set(expected_counts))
        for document_type, expected_count in expected_counts.items():
            profile = TEMPLATE_PROFILES[document_type]
            self.assertEqual(len(profile), expected_count)
            self.assertEqual(profile[0], "Agent handoff summary")
            self.assertEqual(profile[-1], "Review history")

        self.assertEqual(TEMPLATE_PROFILES["design"][22], "Canon reconciliation plan")

    def test_templates_match_profiles_and_are_deterministic_drafts(self) -> None:
        for document_type, headings in TEMPLATE_PROFILES.items():
            template_path = TEMPLATE_DIRECTORY / f"{document_type}.md"
            contents = template_path.read_text(encoding="utf-8")
            actual_headings = [
                line.removeprefix("## ")
                for line in contents.splitlines()
                if line.startswith("## ")
            ]

            self.assertEqual(actual_headings, list(headings))
            self.assertEqual(len(actual_headings), len(set(actual_headings)))
            self.assertIn('status = "draft"', contents)
            self.assertIn("revision = 1", contents)
            self.assertIn('contract_hash = ""', contents)
            self.assertIn("freshness_paths = []", contents)
            self.assertIn('content_review_hash = ""', contents)
            self.assertIn('consumer_review_hash = ""', contents)
            for heading in headings:
                sentinel = heading.upper().replace(" ", "_").replace(",", "").replace("-", "_")
                self.assertIn("<!-- PRODUCT-DOC-DRAFT:", contents, heading)
            for table in REQUIRED_TABLES[template_path.name]:
                self.assertIn(table, contents)

    def test_references_are_complete_and_not_draft_instructions(self) -> None:
        forbidden_markers = ("PRODUCT-DOC-DRAFT", "TODO", "FIXME", "implement later", "fill in details")
        for reference_path in sorted(REFERENCE_DIRECTORY.glob("*.md")):
            contents = reference_path.read_text(encoding="utf-8")
            self.assertLess(len(contents.split()), 500, reference_path.name)
            for marker in forbidden_markers:
                self.assertNotIn(marker, contents, reference_path.name)

        for phase in ("research", "scope", "design"):
            contents = (REFERENCE_DIRECTORY / f"{phase}-review-rubric.md").read_text(encoding="utf-8")
            self.assertIn("## Content review", contents)
            self.assertIn("## Codex consumption review", contents)
            self.assertIn("Verdict: PASS | NEEDS REVISION", contents)
