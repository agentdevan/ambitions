from __future__ import annotations

from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"
REFERENCE_DIRECTORY = SKILL_ROOT / "references"

EXPECTED_HEADINGS = {
    "research": ("Idea and user problem", "Current truth", "Evidence", "Alternatives", "Unknowns and risks", "Recommended direction"),
    "scope": ("Outcome", "In scope", "Out of scope", "Requirements", "Acceptance criteria", "Canon impact", "Risks and open decisions"),
    "design": ("Design summary", "User flows", "States and recovery", "Architecture and data", "Privacy and accessibility", "Requirement traceability", "Verification design", "Open decisions"),
}


def template_path(phase: str) -> Path:
    return TEMPLATE_DIRECTORY / f"{phase}.md"


def extracted_headings(contents: str) -> list[str]:
    return [line.removeprefix("## ") for line in contents.splitlines() if line.startswith("## ")]


class TemplateProfileTests(unittest.TestCase):
    def test_templates_use_simple_metadata(self) -> None:
        for phase, headings in EXPECTED_HEADINGS.items():
            contents = template_path(phase).read_text(encoding="utf-8")
            self.assertIn('status = "draft"', contents)
            self.assertNotIn("contract_hash", contents)
            self.assertNotIn("freshness_paths", contents)
            self.assertEqual(extracted_headings(contents), list(headings))

    def test_templates_use_expected_upstream_defaults(self) -> None:
        self.assertIn('upstream = ""', template_path("research").read_text(encoding="utf-8"))
        self.assertIn('upstream = "research.md"', template_path("scope").read_text(encoding="utf-8"))
        self.assertIn('upstream = "scope.md"', template_path("design").read_text(encoding="utf-8"))

    def test_skill_and_rubrics_describe_conversational_lifecycle(self) -> None:
        skill = (SKILL_ROOT / "SKILL.md").read_text(encoding="utf-8")
        for mode in ("create", "review", "approve", "groom"):
            self.assertIn(mode, skill.lower())

        for phase in ("research", "scope", "design"):
            contents = (REFERENCE_DIRECTORY / f"{phase}-review-rubric.md").read_text(encoding="utf-8")
            self.assertIn("PASS", contents)
            self.assertIn("NEEDS REVISION", contents)
            self.assertIn("conversational", contents.lower())
