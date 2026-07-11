import os
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path

from tools.ambitions_canon.cli import main
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.query import query_by_concept, query_by_id

from tests.canon.test_task_pack import sample_registry


class QueryTests(unittest.TestCase):
    def setUp(self):
        self.registry = sample_registry()

    def test_query_by_id_returns_specification_or_requirement(self):
        specification = query_by_id(self.registry, "SURFACE-TODAY")
        requirement = query_by_id(self.registry, "TODAY-001")

        self.assertEqual(specification.spec_id, "SURFACE-TODAY")
        self.assertEqual(requirement.requirement_id, "TODAY-001")

    def test_query_by_id_unknown_identifier_fails_stably(self):
        with self.assertRaises(CanonError) as raised:
            query_by_id(self.registry, "UNKNOWN-001")

        self.assertEqual(raised.exception.code, "CANON_QUERY_NOT_FOUND")
        self.assertEqual(raised.exception.path, Path("docs/canon/MANIFEST.toml"))

    def test_query_by_concept_is_sorted_and_exact(self):
        requirements = query_by_concept(
            self.registry,
            "surface.today.identity",
        )

        self.assertEqual(
            tuple(item.requirement_id for item in requirements),
            ("TODAY-001", "TODAY-002"),
        )
        self.assertEqual(query_by_concept(self.registry, "surface.time"), ())


class QueryCliTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_directory.cleanup)
        self.root = Path(self.temporary_directory.name)
        canon = self.root / "docs/canon"
        (canon / "specifications").mkdir(parents=True)
        (canon / "MANIFEST.toml").write_text(
            "schema_version = 1\n"
            "canon_revision = 1\n"
            'authority_state = "shadow"\n'
            'compiler_version = "0.1.0"\n'
            'normative_files = ["specifications/today.md"]\n'
            "generated_files = []\n",
            encoding="utf-8",
        )
        (canon / "specifications/today.md").write_text(
            "+++\n"
            'spec_id = "SURFACE-TODAY"\n'
            'title = "Today"\n'
            'kind = "surface"\n'
            'status = "normative"\n'
            'owner_domain = "product"\n'
            "canon_revision = 1\n"
            'profile = "surface-v1"\n'
            'owns_concepts = ["surface.today.identity"]\n'
            "inherits = []\n"
            "depends_on = []\n"
            'source_owners = ["Native/Ambitions/Surfaces/Today"]\n'
            "+++\n\n"
            "## TODAY-002 — Later law\n\n"
            "- **Concept:** `surface.today.identity`\n"
            "- **Modality:** `SHOULD`\n"
            "- **Scope:** Today\n"
            "- **Status:** `normative`\n"
            "- **Verification:** none\n"
            "- **Supersedes:** none\n\n"
            "Later law.\n\n"
            "## TODAY-001 — Primary law\n\n"
            "- **Concept:** `surface.today.identity`\n"
            "- **Modality:** `MUST`\n"
            "- **Scope:** Today\n"
            "- **Status:** `normative`\n"
            "- **Verification:** `SCENARIO-TODAY-001`\n"
            "- **Supersedes:** none\n\n"
            "Primary law.\n",
            encoding="utf-8",
        )

    def run_cli(self, arguments):
        output = StringIO()
        previous = Path.cwd()
        try:
            os.chdir(self.root)
            with redirect_stdout(output):
                result = main(arguments)
        finally:
            os.chdir(previous)
        return result, output.getvalue()

    def test_query_by_id_cli_renders_stable_json(self):
        first = self.run_cli(["query", "--id", "TODAY-001"])
        second = self.run_cli(["query", "--id", "TODAY-001"])

        self.assertEqual(first, second)
        self.assertEqual(first[0], 0)
        self.assertTrue(first[1].endswith("\n"))
        self.assertIn('"item_type": "requirement"', first[1])
        self.assertIn('"requirement_id": "TODAY-001"', first[1])
        self.assertNotIn("timestamp", first[1].casefold())

    def test_query_by_concept_cli_is_sorted(self):
        result, output = self.run_cli(
            ["query", "--concept", "surface.today.identity"]
        )

        self.assertEqual(result, 0)
        self.assertLess(output.index("TODAY-001"), output.index("TODAY-002"))
        self.assertIn('"concept": "surface.today.identity"', output)

    def test_query_not_found_returns_stable_nonzero_error(self):
        result, output = self.run_cli(["query", "--id", "UNKNOWN-001"])

        self.assertEqual(result, 1)
        self.assertEqual(
            output,
            "CANON_QUERY_NOT_FOUND docs/canon/MANIFEST.toml:0 "
            "canonical identifier was not found: UNKNOWN-001\n",
        )

    def test_query_concept_not_found_returns_stable_nonzero_error(self):
        result, output = self.run_cli(["query", "--concept", "surface.time"])

        self.assertEqual(result, 1)
        self.assertEqual(
            output,
            "CANON_QUERY_NOT_FOUND docs/canon/MANIFEST.toml:0 "
            "canonical concept was not found: surface.time\n",
        )

    def test_query_requires_exactly_one_selector(self):
        for arguments, message in (
            (["query"], "one of the arguments"),
            (
                [
                    "query",
                    "--id",
                    "TODAY-001",
                    "--concept",
                    "surface.today.identity",
                ],
                "not allowed with argument",
            ),
        ):
            with self.subTest(arguments=arguments):
                stderr = StringIO()
                with redirect_stderr(stderr), self.assertRaises(SystemExit) as raised:
                    main(arguments)
                self.assertEqual(raised.exception.code, 2)
                self.assertIn(message, stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
