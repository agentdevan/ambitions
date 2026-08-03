from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
import json
from pathlib import Path
import sys


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.cli import EXIT_DOMAIN_FAILURE, EXIT_SUCCESS, EXIT_USAGE, main
from product_docs.documents import parse_document

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


SKILL_PATH = Path(".agents/skills/ambitions-product-development-lifecycle")
DOCUMENTS_PATH = Path("docs/product-development")


class CliTests(TemporaryRepositoryTestCase):
    def setUp(self) -> None:
        super().setUp()
        copy_skill_skeleton(self.root / SKILL_PATH)

    def invoke(self, *arguments: str) -> tuple[int, str, str]:
        stdout = StringIO()
        stderr = StringIO()
        with redirect_stdout(stdout), redirect_stderr(stderr):
            result = main(list(arguments), repository_root=self.root)
        return result, stdout.getvalue(), stderr.getvalue()

    def invoke_json(self, *arguments: str) -> tuple[int, dict[str, object]]:
        result, stdout, stderr = self.invoke(*arguments, "--json")
        self.assertEqual(stderr, "")
        return result, json.loads(stdout)

    def assert_command_succeeds(self, *arguments: str) -> None:
        result, _, _ = self.invoke(*arguments)
        self.assertNotEqual(result, EXIT_USAGE)

    def assert_command_usage_error(self, *arguments: str) -> None:
        result, _, _ = self.invoke(*arguments)
        self.assertEqual(result, EXIT_USAGE)

    def test_parser_exposes_only_new_and_check(self) -> None:
        self.assert_command_succeeds("new", "research", "--initiative", "example")
        self.assert_command_succeeds("check", "docs/product-development/example")
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
                self.assert_command_usage_error(removed)

    def test_new_creates_the_requested_template_with_its_relative_upstream(self) -> None:
        expected = {
            "research": "",
            "scope": "research.md",
            "design": "scope.md",
        }
        self.assertEqual(EXIT_SUCCESS, self.invoke("new", "research", "--initiative", "example")[0])

        for phase, upstream in tuple(expected.items())[1:]:
            with self.subTest(phase=phase):
                self.assertEqual(EXIT_SUCCESS, self.invoke("new", phase, "--initiative", "example")[0])
                document = parse_document(self.root / DOCUMENTS_PATH / "example" / f"{phase}.md")
                self.assertEqual(document.initiative, "example")
                self.assertEqual(document.document_type.value, phase)
                self.assertEqual(document.upstream, upstream)

    def test_new_rejects_existing_documents_and_invalid_slugs(self) -> None:
        self.assertEqual(EXIT_SUCCESS, self.invoke("new", "research", "--initiative", "example")[0])

        duplicate, payload = self.invoke_json("new", "research", "--initiative", "example")
        self.assertEqual(duplicate, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "document-exists")

        invalid, payload = self.invoke_json("new", "research", "--initiative", "Not A Slug")
        self.assertEqual(invalid, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "invalid-initiative")

    def test_new_requires_the_upstream_document(self) -> None:
        result, payload = self.invoke_json("new", "scope", "--initiative", "example")

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "upstream-unavailable")

    def test_check_emits_stable_json_for_a_document_and_initiative(self) -> None:
        self.assertEqual(EXIT_SUCCESS, self.invoke("new", "research", "--initiative", "example")[0])
        path = "docs/product-development/example/research.md"
        document_path = self.root / path
        document_path.write_text(
            document_path.read_text(encoding="utf-8").replace(
                'status = "draft"', 'status = "approved"'
            ),
            encoding="utf-8",
        )
        expected = {
            "command": "check",
            "status": "success",
            "documents": [{"path": path, "type": "research", "status": "approved"}],
            "diagnostics": [],
            "next_action": "create scope",
        }

        for target in (path, "docs/product-development/example"):
            with self.subTest(target=target):
                result, payload = self.invoke_json("check", target)
                self.assertEqual(result, EXIT_SUCCESS)
                self.assertEqual(payload, expected)

    def test_check_returns_validation_diagnostics(self) -> None:
        self.assertEqual(EXIT_SUCCESS, self.invoke("new", "research", "--initiative", "example")[0])
        path = self.root / DOCUMENTS_PATH / "example" / "research.md"
        path.write_text(path.read_text(encoding="utf-8").replace("## Evidence", "## Sources"), encoding="utf-8")

        result, payload = self.invoke_json("check", str(path.relative_to(self.root)))

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["status"], "failure")
        self.assertIn("missing-required-heading", {item["code"] for item in payload["diagnostics"]})

    def test_check_rejects_an_empty_initiative_directory(self) -> None:
        directory = self.root / DOCUMENTS_PATH / "example"
        directory.mkdir(parents=True)

        result, payload = self.invoke_json("check", str(directory.relative_to(self.root)))

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "no-documents")


if __name__ == "__main__":
    import unittest

    unittest.main()
