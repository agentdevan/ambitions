from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from contextlib import redirect_stderr, redirect_stdout
from dataclasses import replace
from datetime import date
import hashlib
from io import StringIO
import json
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import sys
from unittest import mock


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.cli import main
from product_docs.documents import parse_document, write_document_atomic
from product_docs.package_identity import build_manifest, canonical_manifest_bytes
from product_docs.transitions import create_document, record_review, seal_document

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


SKILL_PATH = Path(".agents/skills/ambitions-product-development-lifecycle")
JSON_KEYS = (
    "command",
    "status",
    "document",
    "changes",
    "diagnostics",
    "next_action",
)


class CliTests(TemporaryRepositoryTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.skill_root = self.root / SKILL_PATH
        copy_skill_skeleton(self.skill_root)
        (self.skill_root / "SKILL.md").write_text(
            "# Lifecycle fixture\n", encoding="utf-8"
        )
        self.write_manifest()
        self.commit_all("install lifecycle package")

    def write_manifest(self) -> None:
        manifest = build_manifest(self.skill_root)
        (self.skill_root / "package-manifest.json").write_bytes(
            canonical_manifest_bytes(manifest)
        )

    def invoke(self, *arguments: str) -> tuple[int, str, str]:
        stdout = StringIO()
        stderr = StringIO()
        with redirect_stdout(stdout), redirect_stderr(stderr):
            result = main(list(arguments), repository_root=self.root)
        return result, stdout.getvalue(), stderr.getvalue()

    def invoke_json(self, *arguments: str) -> tuple[int, dict[str, object]]:
        result, stdout, stderr = self.invoke(*arguments, "--json")
        self.assertEqual(stderr, "")
        payload = json.loads(stdout)
        self.assertEqual(tuple(payload), JSON_KEYS)
        return result, payload

    def repository_snapshot(self) -> tuple[dict[str, str], str]:
        hashes = {
            path.relative_to(self.root).as_posix(): hashlib.sha256(
                path.read_bytes()
            ).hexdigest()
            for path in sorted(self.root.rglob("*"))
            if path.is_file() and ".git" not in path.relative_to(self.root).parts
        }
        status = subprocess.run(
            ["git", "-C", str(self.root), "status", "--porcelain"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
        return hashes, status

    @staticmethod
    def complete_research(path: Path, root: Path) -> None:
        document = parse_document(path, repository_root=root)
        sections = tuple(
            replace(
                section,
                body="".join(
                    "Complete.\n" if "PRODUCT-DOC-DRAFT:" in line else line
                    for line in section.body.splitlines(keepends=True)
                ),
            )
            for section in document.sections
        )
        document = replace(document, sections=sections)
        document = replace(
            document,
            sections=tuple(
                replace(
                    section,
                    body=(
                        "\n| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
                        "|---|---|---|---|---|\n"
                        "| FIND-001 | Fact | The fixture is complete. | SRC-001 | Continue. |\n\n"
                        "Complete.\n\n"
                    ),
                )
                if section.heading == "Findings"
                else replace(
                    section,
                    body=(
                        "\n| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |\n"
                        "|---|---|---|---|---|---|---|---|---|\n"
                        "| SRC-001 | Fixture source | Ambitions |  | 2026-08-02 | Low | Owner changes | FIND-001 | Fixture support. |\n\n"
                        "Complete.\n\n"
                    ),
                )
                if section.heading == "Source ledger"
                else section
                for section in document.sections
            ),
        )
        write_document_atomic(path, document, repository_root=root)

    @staticmethod
    def review_payload(document, review_id: str, lane: str) -> dict[str, object]:
        return {
            "review_id": review_id,
            "lane": lane,
            "verdict": "pass",
            "reviewer_surface": "codex" if lane == "consumer" else "chatgpt",
            "reviewed_at": "2026-08-02T12:00:00Z",
            "reviewed_revision": document.metadata.revision,
            "reviewed_contract_hash": document.metadata.contract_hash,
            "blocking_findings": [],
            "non_blocking_improvements": [],
            "traceability_gaps": [],
            "stale_or_conflicting_inputs": [],
            "required_revisions": [],
            "next_permitted_lifecycle_phase": (
                "scope" if lane == "consumer" else "consumer-review"
            ),
            "drift_assessments": [],
        }

    def make_complete_draft(self, initiative: str = "CLI Fixture") -> Path:
        path = create_document(
            self.root, initiative=initiative, phase="research", today=date(2026, 8, 2)
        )
        self.commit_all("track draft")
        self.complete_research(path, self.root)
        return path

    def make_passed_document(self) -> Path:
        path = self.make_complete_draft("Consumable CLI")
        sealed = seal_document(
            path,
            repository_root=self.root,
            sealed_at="2026-08-02T10:00:00Z",
        )
        self.commit_all("seal document")
        content = record_review(
            path,
            self.review_payload(sealed, "REV-CONTENT-001", "content"),
            repository_root=self.root,
        )
        self.commit_all("content review")
        record_review(
            path,
            self.review_payload(content, "REV-CONSUMER-001", "consumer"),
            repository_root=self.root,
        )
        self.commit_all("consumer review")
        return path

    def test_parser_accepts_every_exact_command_shape(self) -> None:
        path = "docs/product-development/example/research.md"
        cases = (
            ("package", "--check"),
            ("package", "--write"),
            ("new", "--initiative", "Example", "--phase", "research"),
            ("check", path),
            ("check", "--initiative", "docs/product-development/example"),
            ("check", "--all"),
            ("hash", path),
            ("seal", path),
            ("review", path, "--review-file", "review.json"),
            ("reconcile", path, "--mark-stale", "--reason-file", "reason.txt"),
            ("reconcile", path, "--reopen"),
            ("consume", path, "--as-of", "2026-08-02"),
            (
                "supersede",
                path,
                "--replacement",
                "docs/product-development/replacement/research.md",
                "--reason-file",
                "reason.txt",
            ),
        )

        for arguments in cases:
            with self.subTest(arguments=arguments):
                result, _, _ = self.invoke(*arguments)
                self.assertNotEqual(result, 2)

    def test_usage_errors_return_two(self) -> None:
        cases = (
            (),
            ("package",),
            ("package", "--check", "--write"),
            ("new", "--initiative", "Example", "--phase", "invalid"),
            ("check",),
            ("check", "a.md", "--all"),
            ("review", "a.md"),
            ("reconcile", "a.md", "--reopen", "--mark-stale"),
            ("reconcile", "a.md", "--mark-stale"),
            ("reconcile", "a.md", "--reopen", "--reason-file", "reason.txt"),
            ("supersede", "a.md", "--replacement", "b.md"),
        )

        for arguments in cases:
            with self.subTest(arguments=arguments):
                result, _, _ = self.invoke(*arguments)
                self.assertEqual(result, 2)

    def test_reconcile_rejects_empty_supplied_options_from_the_other_mode(self) -> None:
        cases = (
            ("reconcile", "a.md", "--reopen", "--reason-file", ""),
            (
                "reconcile",
                "a.md",
                "--mark-stale",
                "--reason-file",
                "reason.txt",
                "--baseline",
                "",
            ),
            (
                "reconcile",
                "a.md",
                "--mark-stale",
                "--reason-file",
                "reason.txt",
                "--authority-file",
                "",
            ),
        )

        for arguments in cases:
            with self.subTest(arguments=arguments):
                result, _, _ = self.invoke(*arguments)
                self.assertEqual(result, 2)

    def test_json_contract_has_exact_keys_on_success_and_failure(self) -> None:
        success, payload = self.invoke_json("package", "--check")
        self.assertEqual(success, 0)
        self.assertEqual(payload["command"], "package")
        self.assertEqual(payload["status"], "success")
        self.assertEqual(payload["diagnostics"], [])

        failure, payload = self.invoke_json("check", "missing.md")
        self.assertEqual(failure, 1)
        self.assertEqual(payload["command"], "check")
        self.assertEqual(payload["status"], "failure")
        self.assertTrue(payload["diagnostics"])

    def test_new_and_hash_dispatch_to_the_domain_layer(self) -> None:
        result, created = self.invoke_json(
            "new", "--initiative", "Command Surface", "--phase", "research"
        )
        self.assertEqual(result, 0)
        self.assertEqual(
            created["document"]["path"],
            "docs/product-development/command-surface/research.md",
        )
        self.assertEqual(created["changes"][0]["field"], "document")

        result, hashed = self.invoke_json(
            "hash", "docs/product-development/command-surface/research.md"
        )
        self.assertEqual(result, 0)
        self.assertRegex(hashed["document"]["contract_hash"], r"^sha256:[0-9a-f]{64}$")

    def test_package_write_reports_the_manifest_change(self) -> None:
        (self.skill_root / "references" / "extra.md").write_text(
            "extra\n", encoding="utf-8"
        )

        result, payload = self.invoke_json("package", "--write")

        self.assertEqual(result, 0)
        self.assertEqual(payload["changes"][0]["field"], "package-manifest.json")
        self.assertEqual(
            (self.skill_root / "package-manifest.json").read_bytes(),
            canonical_manifest_bytes(build_manifest(self.skill_root)),
        )

    def test_check_supports_path_initiative_and_all_selection(self) -> None:
        path = self.make_complete_draft()
        relative = path.relative_to(self.root.resolve()).as_posix()

        for arguments in (
            ("check", relative),
            ("check", "--initiative", str(Path(relative).parent)),
            ("check", "--all"),
        ):
            with self.subTest(arguments=arguments):
                result, payload = self.invoke_json(*arguments)
                self.assertEqual(result, 0)
                self.assertEqual(payload["document"]["count"], 1)

    def test_read_only_commands_preserve_all_files_and_status_on_success_and_failure(
        self,
    ) -> None:
        draft = self.make_complete_draft("Read Only Draft")
        draft_relative = draft.relative_to(self.root.resolve()).as_posix()
        passed = self.make_passed_document()
        passed_relative = passed.relative_to(self.root.resolve()).as_posix()
        before = self.repository_snapshot()

        cases = (
            (0, ("package", "--check")),
            (1, ("package", "--check")),
            (0, ("check", draft_relative)),
            (1, ("check", "missing.md")),
            (0, ("hash", draft_relative)),
            (1, ("hash", "missing.md")),
            (0, ("consume", passed_relative, "--as-of", "2026-08-02")),
            (1, ("consume", "missing.md", "--as-of", "2026-08-02")),
        )
        for index, (expected, arguments) in enumerate(cases):
            with self.subTest(arguments=arguments):
                if index == 1:
                    manifest = self.skill_root / "package-manifest.json"
                    original = manifest.read_bytes()
                    manifest.write_bytes(
                        original.replace(
                            b'"skill_version":"1.0.0"', b'"skill_version":"9.9.9"'
                        )
                    )
                    failure_before = self.repository_snapshot()
                    result, _ = self.invoke_json(*arguments)
                    self.assertEqual(result, expected)
                    self.assertEqual(self.repository_snapshot(), failure_before)
                    manifest.write_bytes(original)
                    continue
                result, _ = self.invoke_json(*arguments)
                self.assertEqual(result, expected)
                self.assertEqual(self.repository_snapshot(), before)

    def test_inaccessible_repository_returns_three(self) -> None:
        missing = self.root / "missing-repository"
        output = StringIO()
        with redirect_stdout(output):
            result = main(["package", "--check", "--json"], repository_root=missing)
        payload = json.loads(output.getvalue())

        self.assertEqual(result, 3)
        self.assertEqual(payload["status"], "failure")
        self.assertEqual(payload["diagnostics"][0]["code"], "repository-unavailable")

    def test_unavailable_git_during_repository_discovery_returns_three(self) -> None:
        output = StringIO()
        unavailable = FileNotFoundError(2, "No such file or directory", "git")
        with mock.patch("product_docs.cli.subprocess.run", side_effect=unavailable):
            with redirect_stdout(output):
                result = main(
                    ["package", "--check", "--json"], repository_root=self.root
                )
        payload = json.loads(output.getvalue())

        self.assertEqual(result, 3)
        self.assertEqual(payload["status"], "failure")
        self.assertEqual(payload["diagnostics"][0]["code"], "repository-unavailable")

    def test_actual_entrypoint_returns_three_when_current_directory_was_deleted(
        self,
    ) -> None:
        entrypoint = self.skill_root / "scripts" / "ambitions_product_docs.py"
        program = """
import os
from pathlib import Path
import runpy
import sys
import tempfile

entrypoint = sys.argv[1]
parent = sys.argv[2]
deleted = tempfile.mkdtemp(dir=parent)
os.chdir(deleted)
Path(deleted).rmdir()
sys.argv = [entrypoint, "package", "--check", "--json"]
runpy.run_path(entrypoint, run_name="__main__")
"""

        result = subprocess.run(
            [sys.executable, "-c", program, str(entrypoint), str(self.root)],
            cwd=self.root,
            check=False,
            capture_output=True,
            text=True,
        )
        payload = json.loads(result.stdout)

        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertEqual(payload["status"], "failure")
        self.assertEqual(payload["diagnostics"][0]["code"], "repository-unavailable")

    def test_actual_entrypoint_never_writes_bytecode_on_success_or_failure(
        self,
    ) -> None:
        entrypoint = self.skill_root / "scripts" / "ambitions_product_docs.py"
        for cache in tuple(self.skill_root.rglob("__pycache__")):
            shutil.rmtree(cache)
        environment = os.environ.copy()
        environment.pop("PYTHONDONTWRITEBYTECODE", None)
        before = self.repository_snapshot()

        success = subprocess.run(
            [sys.executable, str(entrypoint), "package", "--check", "--json"],
            cwd=self.root,
            env=environment,
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(success.returncode, 0, success.stderr)
        self.assertEqual(json.loads(success.stdout)["status"], "success")
        self.assertEqual(self.repository_snapshot(), before)
        caches = tuple(self.skill_root.rglob("__pycache__"))
        self.assertFalse(caches, caches)

        failure = subprocess.run(
            [sys.executable, str(entrypoint), "check", "missing.md", "--json"],
            cwd=self.root,
            env=environment,
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(failure.returncode, 1, failure.stderr)
        self.assertEqual(json.loads(failure.stdout)["status"], "failure")
        self.assertEqual(self.repository_snapshot(), before)
        caches = tuple(self.skill_root.rglob("__pycache__"))
        self.assertFalse(caches, caches)

    def test_entrypoint_rejects_unsupported_python_with_exit_three(self) -> None:
        entrypoint = SCRIPTS_DIRECTORY / "ambitions_product_docs.py"
        stderr = StringIO()
        with (
            mock.patch.object(sys, "version_info", (3, 10, 0)),
            redirect_stderr(stderr),
        ):
            with self.assertRaises(SystemExit) as raised:
                runpy.run_path(str(entrypoint), run_name="__main__")

        self.assertEqual(raised.exception.code, 3)
        self.assertIn("requires Python 3.11-3.14", stderr.getvalue())


if __name__ == "__main__":
    import unittest

    unittest.main()
