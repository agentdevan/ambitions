from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from contextlib import contextmanager, redirect_stderr, redirect_stdout
import importlib
from io import StringIO
import json
from pathlib import Path
import sys


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


INSTALLED_SKILL = Path(".agents/skills/ambitions-product-development-lifecycle")


@contextmanager
def installed_cli(skill_root: Path):
    """Load the CLI from a copied installed skill, not the source checkout."""
    scripts = (skill_root / "scripts").resolve()
    saved_modules = {
        name: module
        for name, module in tuple(sys.modules.items())
        if name == "product_docs" or name.startswith("product_docs.")
    }
    for name in saved_modules:
        sys.modules.pop(name, None)
    sys.path.insert(0, str(scripts))
    importlib.invalidate_caches()
    try:
        cli = importlib.import_module("product_docs.cli")
        documents = importlib.import_module("product_docs.documents")
        for module in (cli, documents):
            if not Path(module.__file__).resolve().is_relative_to(scripts):
                raise AssertionError(
                    f"{module.__name__} loaded outside installed package"
                )
        yield cli, documents
    finally:
        for name in tuple(sys.modules):
            if name == "product_docs" or name.startswith("product_docs."):
                sys.modules.pop(name, None)
        sys.modules.update(saved_modules)
        sys.path.remove(str(scripts))
        importlib.invalidate_caches()


class InstalledSkillSurfaceTests(TemporaryRepositoryTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.skill_root = self.root / INSTALLED_SKILL
        copy_skill_skeleton(self.skill_root)

    def invoke(self, cli, *arguments: str) -> tuple[int, str, str]:
        stdout = StringIO()
        stderr = StringIO()
        with redirect_stdout(stdout), redirect_stderr(stderr):
            result = cli.main(list(arguments), repository_root=self.root)
        return result, stdout.getvalue(), stderr.getvalue()

    def test_installed_skill_describes_the_conversational_lightweight_workflow(self) -> None:
        contents = (self.skill_root / "SKILL.md").read_text(encoding="utf-8")

        self.assertIn("Research, Scope, Design, and implementation grooming", contents)
        self.assertIn("Do not\ncreate separate review artifacts", contents)
        self.assertIn("do not review content, change approval state", contents)
        self.assertNotIn("package-manifest.json", contents)

    def test_installed_cli_exposes_only_new_and_check(self) -> None:
        with installed_cli(self.skill_root) as (cli, _):
            result, _, _ = self.invoke(cli, "new", "research", "--initiative", "example")
            self.assertEqual(result, cli.EXIT_SUCCESS)

            result, _, _ = self.invoke(cli, "check", "docs/product-development/example")
            self.assertEqual(result, cli.EXIT_SUCCESS)

            for removed in (
                "package",
                "hash",
                "seal",
                "review",
                "reconcile",
                "consume",
                "supersede",
            ):
                with self.subTest(command=removed):
                    result, _, _ = self.invoke(cli, removed)
                    self.assertEqual(result, cli.EXIT_USAGE)

    def test_installed_cli_creates_and_checks_a_research_document(self) -> None:
        with installed_cli(self.skill_root) as (cli, documents):
            result, _, _ = self.invoke(cli, "new", "research", "--initiative", "example")
            self.assertEqual(result, cli.EXIT_SUCCESS)
            path = self.root / "docs/product-development/example/research.md"
            document = documents.parse_document(path)
            self.assertEqual(document.initiative, "example")
            self.assertEqual(document.upstream, "")

            path.write_text(
                path.read_text(encoding="utf-8").replace(
                    'status = "draft"', 'status = "approved"'
                ),
                encoding="utf-8",
            )
            result, stdout, stderr = self.invoke(
                cli,
                "check",
                "docs/product-development/example/research.md",
                "--json",
            )

        self.assertEqual(result, 0)
        self.assertEqual(stderr, "")
        self.assertEqual(
            json.loads(stdout),
            {
                "command": "check",
                "status": "success",
                "documents": [
                    {
                        "path": "docs/product-development/example/research.md",
                        "type": "research",
                        "status": "approved",
                    }
                ],
                "diagnostics": [],
                "next_action": "create scope",
            },
        )

    def test_installed_cli_accepts_complete_grooming_documents(self) -> None:
        with installed_cli(self.skill_root) as (cli, _):
            for phase in ("research", "scope", "design"):
                result, _, _ = self.invoke(cli, "new", phase, "--initiative", "example")
                self.assertEqual(result, cli.EXIT_SUCCESS)
                path = self.root / "docs/product-development/example" / f"{phase}.md"
                path.write_text(
                    path.read_text(encoding="utf-8").replace(
                        'status = "draft"', 'status = "approved"'
                    ),
                    encoding="utf-8",
                )

            implementation = self.root / "docs/product-development/example/implementation"
            implementation.mkdir()
            for filename, heading, body in (
                ("plan.md", "Plan", "Implementation order."),
                ("tasks.md", "Tasks", "1. Implement the flow."),
                ("verification.md", "Verification", "Run the focused tests."),
            ):
                (implementation / filename).write_text(
                    f"# {heading}\n\n{body}\n", encoding="utf-8"
                )

            result, _, _ = self.invoke(cli, "check", "docs/product-development/example")

        self.assertEqual(result, cli.EXIT_SUCCESS)


if __name__ == "__main__":
    import unittest

    unittest.main()
