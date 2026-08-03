from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.errors import ProductDocsError
from product_docs.package_identity import (
    build_manifest,
    canonical_manifest_bytes,
    package_hash,
    verify_active_package,
    verify_historical_package,
)
from product_docs.repository import GitRepository
from support import TemporaryRepositoryTestCase


SKILL_PATH = Path(".agents/skills/ambitions-product-development-lifecycle")


class PackageIdentityTests(TemporaryRepositoryTestCase):
    def write_package(self, *, skill_contents: bytes = b"skill\n") -> Path:
        skill_root = self.root / SKILL_PATH
        files = {
            "SKILL.md": skill_contents,
            "agents/openai.yaml": b"name: lifecycle\n",
            "assets/templates/v1/research.md": b"research\r\n",
            "assets/templates/v1/scope.md": b"scope\n",
            "assets/templates/v1/design.md": b"design\n",
            "references/consumer-contract.md": b"consumer\n",
            "scripts/product_docs/entry.py": b"print('lifecycle')\n",
            "tests/test_ignored.py": b"raise AssertionError\n",
        }
        for relative_path, contents in files.items():
            target = skill_root / relative_path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(contents)
        self.write_manifest(skill_root)
        return skill_root

    def write_manifest(self, skill_root: Path) -> dict[str, object]:
        manifest = build_manifest(skill_root)
        (skill_root / "package-manifest.json").write_bytes(canonical_manifest_bytes(manifest))
        return manifest

    def test_build_manifest_discovers_sorted_operational_files_with_exact_byte_hashes(self) -> None:
        skill_root = self.write_package()

        manifest = build_manifest(skill_root)

        self.assertEqual(
            [record["path"] for record in manifest["files"]],
            [
                "SKILL.md",
                "agents/openai.yaml",
                "assets/templates/v1/design.md",
                "assets/templates/v1/research.md",
                "assets/templates/v1/scope.md",
                "references/consumer-contract.md",
                "scripts/product_docs/entry.py",
            ],
        )
        research = next(record for record in manifest["files"] if record["path"] == "assets/templates/v1/research.md")
        self.assertEqual(research["sha256"], hashlib.sha256(b"research\r\n").hexdigest())
        self.assertNotIn("tests/test_ignored.py", [record["path"] for record in manifest["files"]])
        self.assertNotIn("package-manifest.json", [record["path"] for record in manifest["files"]])
        self.assertEqual(
            manifest["supported_document_contracts"],
            [{"schema_version": 1, "template_versions": ["research-v1", "scope-v1", "design-v1"]}],
        )

    def test_manifest_bytes_are_canonical_and_package_hash_is_prefixed_sha256(self) -> None:
        skill_root = self.write_package()
        manifest = build_manifest(skill_root)

        contents = canonical_manifest_bytes(manifest)

        self.assertTrue(contents.endswith(b"\n"))
        self.assertFalse(contents.endswith(b"\n\n"))
        self.assertEqual(contents, json.dumps(manifest, sort_keys=True, separators=(",", ":")).encode("utf-8") + b"\n")
        self.assertEqual(package_hash(manifest), "sha256:" + hashlib.sha256(contents).hexdigest())

    def test_active_verification_rejects_extra_missing_and_changed_operational_files(self) -> None:
        skill_root = self.write_package()
        verify_active_package(skill_root)

        (skill_root / "scripts" / "extra.py").write_bytes(b"extra\n")
        with self.assertRaises(ProductDocsError) as extra:
            verify_active_package(skill_root)
        self.assertEqual(extra.exception.diagnostics[0].code, "package-manifest-mismatch")
        (skill_root / "scripts" / "extra.py").unlink()

        (skill_root / "references" / "consumer-contract.md").unlink()
        with self.assertRaises(ProductDocsError) as missing:
            verify_active_package(skill_root)
        self.assertEqual(missing.exception.diagnostics[0].code, "package-manifest-mismatch")
        (skill_root / "references" / "consumer-contract.md").write_bytes(b"changed\n")
        with self.assertRaises(ProductDocsError) as changed:
            verify_active_package(skill_root)
        self.assertEqual(changed.exception.diagnostics[0].code, "package-manifest-mismatch")

    def test_historical_verification_accepts_a_baseline_package_after_active_package_changes(self) -> None:
        skill_root = self.write_package(skill_contents=b"historical skill\n")
        historical_manifest = build_manifest(skill_root)
        self.write_manifest(skill_root)
        baseline = self.commit_all("historical package")
        historical_template_hash = "sha256:" + next(
            record["sha256"] for record in historical_manifest["files"] if record["path"] == "assets/templates/v1/research.md"
        )

        (skill_root / "SKILL.md").write_bytes(b"active skill\n")
        self.write_manifest(skill_root)
        self.commit_all("active package")

        verification = verify_historical_package(
            GitRepository(self.root),
            baseline_commit=baseline,
            schema_version=1,
            template_version="research-v1",
            expected_package_hash=package_hash(historical_manifest),
            expected_template_hash=historical_template_hash,
            active_skill_root=skill_root,
        )

        self.assertEqual(verification["package_hash"], package_hash(historical_manifest))
        self.assertEqual(verification["template_hash"], historical_template_hash)

    def test_historical_verification_rejects_an_unreachable_baseline(self) -> None:
        skill_root = self.write_package()
        manifest = build_manifest(skill_root)
        baseline = self.commit_all("active package")

        with self.assertRaises(ProductDocsError) as raised:
            verify_historical_package(
                GitRepository(self.root),
                baseline_commit="0" * 40,
                schema_version=1,
                template_version="research-v1",
                expected_package_hash=package_hash(manifest),
                expected_template_hash="sha256:" + next(
                    record["sha256"] for record in manifest["files"] if record["path"] == "assets/templates/v1/research.md"
                ),
                active_skill_root=skill_root,
            )

        self.assertNotEqual(baseline, "0" * 40)
        self.assertEqual(raised.exception.diagnostics[0].code, "unreachable-baseline")

    def test_git_repository_rejects_noncanonical_commits_and_paths(self) -> None:
        repository = GitRepository(self.root)
        for commit in ("ABCDEF" * 6 + "ABCD", "a" * 39, "a" * 41):
            with self.subTest(commit=commit):
                with self.assertRaises(ProductDocsError):
                    repository.is_commit_reachable(commit)
        for path in ("/absolute.md", "docs/../outside.md", "docs//double.md", "docs\\backslash.md", ""):
            with self.subTest(path=path):
                with self.assertRaises(ProductDocsError):
                    repository.is_tracked_at_head(path)


if __name__ == "__main__":
    unittest.main()
