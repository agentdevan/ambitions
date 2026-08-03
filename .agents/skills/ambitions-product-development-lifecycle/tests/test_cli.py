from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
import json
from pathlib import Path
import re
import shutil
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

    def approve(self, phase: str) -> None:
        path = self.root / DOCUMENTS_PATH / "example" / f"{phase}.md"
        contents = path.read_text(encoding="utf-8").replace(
            'status = "draft"', 'status = "approved"'
        )
        contents = re.sub(
            r"<!-- PRODUCT-DOC-DRAFT:.*?-->", "Complete content.", contents
        )
        if phase == "scope":
            contents = contents.replace(
                "## Requirements\n\nComplete content.",
                "## Requirements\n\n- REQ-001: The user can complete the outcome.",
            )
        elif phase == "design":
            contents = contents.replace(
                "## Requirement traceability\n\nComplete content.",
                "## Requirement traceability\n\n- REQ-001: DESIGN-001 completes the outcome.",
            )
        path.write_text(contents, encoding="utf-8")

    def write_phase(self, phase: str, *, status: str) -> Path:
        template = self.root / SKILL_PATH / "assets/templates/v1" / f"{phase}.md"
        target = self.root / DOCUMENTS_PATH / "example" / f"{phase}.md"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(
            template.read_text(encoding="utf-8")
            .replace('initiative = ""', 'initiative = "example"')
            .replace('status = "draft"', f'status = "{status}"'),
            encoding="utf-8",
        )
        return target

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
        self.assertEqual(
            EXIT_SUCCESS,
            self.invoke("new", "research", "--initiative", "example")[0],
        )
        self.approve("research")
        self.assertEqual(
            EXIT_SUCCESS, self.invoke("new", "scope", "--initiative", "example")[0]
        )
        self.approve("scope")
        self.assertEqual(
            EXIT_SUCCESS, self.invoke("new", "design", "--initiative", "example")[0]
        )

        for phase, upstream in expected.items():
            with self.subTest(phase=phase):
                document = parse_document(
                    self.root / DOCUMENTS_PATH / "example" / f"{phase}.md"
                )
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

    def test_new_invalid_utf8_template_emits_stable_json_and_domain_exit(self) -> None:
        template = self.root / SKILL_PATH / "assets/templates/v1/research.md"
        template.write_bytes(b"\xff")

        result, payload = self.invoke_json(
            "new", "research", "--initiative", "example"
        )

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["status"], "failure")
        self.assertEqual(payload["diagnostics"][0]["code"], "document-decode-error")
        self.assertEqual(
            payload["diagnostics"][0]["path"],
            ".agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md",
        )

    def test_new_requires_the_upstream_document(self) -> None:
        result, payload = self.invoke_json("new", "scope", "--initiative", "example")

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "upstream-unavailable")

    def test_new_requires_an_approved_immediate_upstream(self) -> None:
        self.assertEqual(
            EXIT_SUCCESS,
            self.invoke("new", "research", "--initiative", "example")[0],
        )

        result, payload = self.invoke_json("new", "scope", "--initiative", "example")
        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "upstream-not-approved")

        self.approve("research")
        self.assertEqual(
            EXIT_SUCCESS, self.invoke("new", "scope", "--initiative", "example")[0]
        )
        result, payload = self.invoke_json("new", "design", "--initiative", "example")
        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "upstream-not-approved")

        self.approve("scope")
        self.assertEqual(
            EXIT_SUCCESS, self.invoke("new", "design", "--initiative", "example")[0]
        )

    def test_new_rejects_an_invalid_existing_approval_chain(self) -> None:
        self.write_phase("scope", status="approved")

        result, payload = self.invoke_json("new", "design", "--initiative", "example")

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertIn(
            "research-not-approved", {item["code"] for item in payload["diagnostics"]}
        )
        self.assertFalse(
            (self.root / DOCUMENTS_PATH / "example" / "design.md").exists()
        )

    def test_new_rejects_a_structurally_invalid_approved_upstream(self) -> None:
        self.assertEqual(
            EXIT_SUCCESS,
            self.invoke("new", "research", "--initiative", "example")[0],
        )
        self.approve("research")
        research = self.root / DOCUMENTS_PATH / "example" / "research.md"
        research.write_text(
            research.read_text(encoding="utf-8").replace("## Evidence", "## Sources"),
            encoding="utf-8",
        )

        result, payload = self.invoke_json("new", "scope", "--initiative", "example")

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertIn(
            "missing-required-heading",
            {item["code"] for item in payload["diagnostics"]},
        )
        self.assertFalse((research.parent / "scope.md").exists())

    def test_check_emits_stable_json_for_a_document_and_initiative(self) -> None:
        self.assertEqual(EXIT_SUCCESS, self.invoke("new", "research", "--initiative", "example")[0])
        path = "docs/product-development/example/research.md"
        self.approve("research")
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

    def test_check_rejects_mismatched_identity_at_a_canonical_path(self) -> None:
        self.assertEqual(
            EXIT_SUCCESS,
            self.invoke("new", "research", "--initiative", "example")[0],
        )
        path = self.root / DOCUMENTS_PATH / "example" / "research.md"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                'initiative = "example"', 'initiative = "other"'
            ),
            encoding="utf-8",
        )

        result, payload = self.invoke_json(
            "check", "docs/product-development/example/research.md"
        )

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertIn(
            "initiative-mismatch", {item["code"] for item in payload["diagnostics"]}
        )

    def test_check_file_emits_one_parse_diagnostic_for_a_malformed_document(self) -> None:
        path = self.root / DOCUMENTS_PATH / "example" / "research.md"
        path.parent.mkdir(parents=True)
        path.write_text("not TOML frontmatter\n", encoding="utf-8")

        result, payload = self.invoke_json(
            "check", "docs/product-development/example/research.md"
        )

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(
            payload["diagnostics"],
            [
                {
                    "code": "missing-frontmatter",
                    "message": "Document must begin with TOML frontmatter",
                    "path": "docs/product-development/example/research.md",
                    "section": None,
                    "identifier": None,
                    "remediation": None,
                }
            ],
        )

    def test_check_invalid_utf8_emits_stable_json_and_domain_exit(self) -> None:
        path = self.root / DOCUMENTS_PATH / "example" / "research.md"
        path.parent.mkdir(parents=True)
        path.write_bytes(b"\xff")

        result, payload = self.invoke_json(
            "check", "docs/product-development/example/research.md"
        )

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["status"], "failure")
        self.assertEqual(payload["diagnostics"][0]["code"], "document-decode-error")
        self.assertEqual(
            payload["diagnostics"][0]["path"],
            "docs/product-development/example/research.md",
        )

    def test_check_grooming_decode_failure_emits_stable_json_and_domain_exit(self) -> None:
        for phase in ("research", "scope", "design"):
            self.assertEqual(
                EXIT_SUCCESS,
                self.invoke("new", phase, "--initiative", "example")[0],
            )
            self.approve(phase)
        implementation = self.root / DOCUMENTS_PATH / "example" / "implementation"
        implementation.mkdir()
        (implementation / "plan.md").write_bytes(b"\xff")
        for filename in ("tasks.md", "verification.md"):
            (implementation / filename).write_text(
                "# Complete\n\nComplete grooming content.\n", encoding="utf-8"
            )

        result, payload = self.invoke_json(
            "check", "docs/product-development/example"
        )

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        decode = [
            item
            for item in payload["diagnostics"]
            if item["code"] == "document-decode-error"
        ]
        self.assertEqual(len(decode), 1)
        self.assertEqual(
            decode[0]["path"],
            "docs/product-development/example/implementation/plan.md",
        )

    def test_check_file_reports_only_requested_design_but_uses_full_state_for_action(self) -> None:
        for phase in ("research", "scope", "design"):
            self.assertEqual(
                EXIT_SUCCESS,
                self.invoke("new", phase, "--initiative", "example")[0],
            )
            self.approve(phase)
        implementation = self.root / DOCUMENTS_PATH / "example" / "implementation"
        implementation.mkdir()
        for filename in ("plan.md", "tasks.md", "verification.md"):
            (implementation / filename).write_text(
                "# Complete\n\nComplete grooming content.\n", encoding="utf-8"
            )

        result, payload = self.invoke_json(
            "check", "docs/product-development/example/design.md"
        )

        self.assertEqual(result, EXIT_SUCCESS)
        self.assertEqual(
            payload["documents"],
            [
                {
                    "path": "docs/product-development/example/design.md",
                    "type": "design",
                    "status": "approved",
                }
            ],
        )
        self.assertEqual(payload["next_action"], "implementation grooming complete")

        directory_result, directory_payload = self.invoke_json(
            "check", "docs/product-development/example"
        )
        self.assertEqual(directory_result, EXIT_SUCCESS)
        self.assertEqual(
            directory_payload["next_action"], "implementation grooming complete"
        )

    def test_help_honors_success_and_json_remains_machine_parseable(self) -> None:
        result, stdout, stderr = self.invoke("--help")

        self.assertEqual(result, EXIT_SUCCESS)
        self.assertIn("usage: ambitions_product_docs.py", stdout)
        self.assertNotIn("failure", stdout)
        self.assertEqual(stderr, "")

        json_result, json_stdout, json_stderr = self.invoke("new", "--help", "--json")
        payload = json.loads(json_stdout)
        self.assertEqual(json_result, EXIT_SUCCESS)
        self.assertEqual(json_stderr, "")
        self.assertEqual(payload["status"], "success")
        self.assertIn("usage: ambitions_product_docs.py new", payload["help"])

    def test_check_file_validates_approval_order_for_approved_downstream_documents(
        self,
    ) -> None:
        cases = (
            ("scope", None, "research-not-approved"),
            ("scope", ("research", "draft"), "research-not-approved"),
            ("design", None, "scope-not-approved"),
            ("design", ("scope", "draft"), "scope-not-approved"),
        )
        for phase, upstream, expected_code in cases:
            with self.subTest(phase=phase, upstream=upstream):
                self.write_phase(phase, status="approved")
                if upstream is not None:
                    self.write_phase(upstream[0], status=upstream[1])

                result, payload = self.invoke_json(
                    "check", f"docs/product-development/example/{phase}.md"
                )

                self.assertEqual(result, EXIT_DOMAIN_FAILURE)
                self.assertIn(
                    expected_code, {item["code"] for item in payload["diagnostics"]}
                )
                shutil.rmtree(self.root / DOCUMENTS_PATH / "example")

    def test_check_rejects_an_empty_initiative_directory(self) -> None:
        directory = self.root / DOCUMENTS_PATH / "example"
        directory.mkdir(parents=True)

        result, payload = self.invoke_json("check", str(directory.relative_to(self.root)))

        self.assertEqual(result, EXIT_DOMAIN_FAILURE)
        self.assertEqual(payload["diagnostics"][0]["code"], "no-documents")


if __name__ == "__main__":
    import unittest

    unittest.main()
