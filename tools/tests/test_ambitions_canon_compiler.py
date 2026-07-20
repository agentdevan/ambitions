from __future__ import annotations

import unittest
from pathlib import Path

from tools.ambitions_canon.cli import SUPPORTED_COMMANDS
from tools.ambitions_canon.compiler import (
    Requirement,
    compile_repository,
    output_drift,
    query,
    render_outputs,
)


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]


class AmbitionsCanonCompilerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.compilation = compile_repository(REPOSITORY_ROOT)
        cls.outputs = render_outputs(cls.compilation)

    def test_repository_compiles_as_complete_product_canon(self) -> None:
        self.assertEqual(len(self.compilation.documents), 66)
        self.assertGreaterEqual(len(self.compilation.requirements), 450)
        self.assertGreaterEqual(self.compilation.ux_screen_count, 30)
        self.assertGreaterEqual(self.compilation.visual_contract_count, 25)

    def test_generated_outputs_are_current_and_deterministic(self) -> None:
        self.assertEqual(output_drift(self.compilation, self.outputs), ())
        self.assertEqual(render_outputs(self.compilation), self.outputs)

    def test_query_resolves_exact_requirement_and_multiword_text(self) -> None:
        exact = query(self.compilation, "LAW-LOCAL-AUTHORITY-001", mode="id")
        self.assertEqual(len(exact), 1)
        self.assertIsInstance(exact[0], Requirement)
        routed = query(
            self.compilation,
            "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",
            mode="id",
        )
        self.assertEqual(len(routed), 1)
        self.assertTrue(routed[0].source_owners)

        text_matches = query(self.compilation, "Today first viewport")
        requirement_ids = {
            item.requirement_id
            for item in text_matches
            if isinstance(item, Requirement)
        }
        self.assertIn("SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001", requirement_ids)

    def test_cli_exposes_only_product_compiler_commands(self) -> None:
        self.assertEqual(
            SUPPORTED_COMMANDS,
            {"version", "build", "check", "query"},
        )


if __name__ == "__main__":
    unittest.main()
