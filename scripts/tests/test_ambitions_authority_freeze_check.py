import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ambitions-authority-freeze-check.py"
ROOT = SCRIPT.parents[1]


def load_module():
    spec = importlib.util.spec_from_file_location("authority_freeze", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class AuthorityFreezeTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()

    def test_detects_new_truth_file_outside_canon(self):
        paths = ["docs/truth/README.md", "docs/product/NEW_PRODUCT_TRUTH.md"]
        baseline = {"docs/truth/README.md"}
        self.assertEqual(
            self.module.new_authority_paths(paths, baseline),
            ("docs/product/NEW_PRODUCT_TRUTH.md",),
        )

    def test_allows_new_shadow_files_under_docs_canon(self):
        paths = ["docs/canon/MANIFEST.toml", "docs/canon/specifications/surfaces/today.md"]
        self.assertEqual(self.module.new_authority_paths(paths, set()), ())

    def test_allows_approved_train_one_compiler_test_and_ci_surfaces(self):
        paths = [
            "tools/ambitions_canon/compiler.py",
            "tests/canon/test_shadow_compiler.py",
            "scripts/ambitions-canon.py",
            ".github/workflows/ambitions-canon-shadow-audit.yml",
        ]
        self.assertEqual(self.module.authority_candidates(paths), ())

    def test_does_not_allow_train_one_lookalikes_or_unapproved_authority_paths(self):
        paths = [
            "tools/ambitions_canonical/compiler.py",
            "tests/canonical/test_shadow_compiler.py",
            "scripts/ambitions-canon.py.backup",
            ".github/workflows/ambitions-canon-shadow-audit.yml.backup",
            "docs/product/NEW_PRODUCT_AUTHORITY.md",
        ]
        self.assertEqual(
            self.module.authority_candidates(paths),
            (
                ".github/workflows/ambitions-canon-shadow-audit.yml.backup",
                "docs/product/NEW_PRODUCT_AUTHORITY.md",
                "scripts/ambitions-canon.py.backup",
                "tests/canonical/test_shadow_compiler.py",
                "tools/ambitions_canonical/compiler.py",
            ),
        )

    def test_ignores_superpowers_specs_and_plans(self):
        paths = [
            "docs/superpowers/specs/2026-07-11-design.md",
            "docs/superpowers/plans/2026-07-11-plan.md",
        ]
        self.assertEqual(self.module.new_authority_paths(paths, set()), ())

    def test_candidate_matching_is_case_insensitive_and_path_aware(self):
        paths = ["docs/Canon.md", "docs/design/AUTHORITY-notes.md", "Native/Foo.swift"]
        self.assertEqual(
            self.module.authority_candidates(paths),
            ("docs/Canon.md", "docs/design/AUTHORITY-notes.md"),
        )

    def test_rejects_traversal_before_applying_allowed_prefixes(self):
        with self.assertRaisesRegex(ValueError, "noncanonical-path"):
            self.module.authority_candidates(
                ["docs/canon/../product/NEW_PRODUCT_TRUTH.md"]
            )

    def test_baseline_covers_tracked_guard_candidates(self):
        candidates = self.module.authority_candidates(self.module.tracked_paths())
        guard_path = "scripts/ambitions-authority-freeze-check.py"
        test_path = "scripts/tests/test_ambitions_authority_freeze_check.py"
        self.assertIn(guard_path, candidates)
        self.assertIn(test_path, candidates)

        baseline = set(
            json.loads(self.module.BASELINE.read_text(encoding="utf-8"))["paths"]
        )
        self.assertEqual(self.module.new_authority_paths(candidates, baseline), ())

    def run_cli(self, baseline: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--baseline", str(baseline)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def write_payload(self, directory: Path, payload: object) -> Path:
        baseline = directory / "baseline.json"
        baseline.write_text(json.dumps(payload), encoding="utf-8")
        return baseline

    def assert_invalid_input(
        self, result: subprocess.CompletedProcess[str], reason: str, baseline: Path
    ) -> None:
        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, "")
        self.assertEqual(
            result.stderr,
            f"RED AUTHORITY_FREEZE_INVALID_INPUT reason={reason} baseline={baseline}\n",
        )
        self.assertNotIn("Traceback", result.stderr)

    def test_cli_returns_zero_for_current_baseline(self):
        result = self.run_cli(self.module.BASELINE)

        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stderr, "")
        self.assertEqual(result.stdout, "GREEN authority freeze baseline_paths=141\n")

    def test_cli_returns_one_for_new_authority_drift(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            payload = json.loads(self.module.BASELINE.read_text(encoding="utf-8"))
            payload["paths"].remove("scripts/ambitions-authority-freeze-check.py")
            baseline = self.write_payload(directory, payload)

            result = self.run_cli(baseline)

        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, "")
        self.assertEqual(
            result.stderr,
            "RED AUTHORITY_FREEZE_NEW_PATH "
            "scripts/ambitions-authority-freeze-check.py\n",
        )

    def test_cli_returns_two_for_missing_baseline(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            baseline = Path(temporary_directory) / "missing.json"

            result = self.run_cli(baseline)

        self.assert_invalid_input(result, "missing", baseline)

    def test_cli_returns_two_for_malformed_json(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            baseline = Path(temporary_directory) / "baseline.json"
            baseline.write_text("{not-json", encoding="utf-8")

            result = self.run_cli(baseline)

        self.assert_invalid_input(result, "malformed-json", baseline)

    def test_cli_returns_two_for_baseline_read_error(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            baseline = Path(temporary_directory)

            result = self.run_cli(baseline)

        self.assert_invalid_input(result, "read-error", baseline)

    def test_cli_returns_two_for_non_object_root(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            directory = Path(temporary_directory)
            baseline = self.write_payload(directory, [])

            result = self.run_cli(baseline)

        self.assert_invalid_input(result, "root-not-object", baseline)

    def test_cli_returns_two_for_missing_or_wrong_schema(self):
        cases = (
            ("schema-version", {"paths": []}),
            ("schema-version", {"schema_version": 2, "paths": []}),
            ("schema-version", {"schema_version": True, "paths": []}),
        )
        for reason, payload in cases:
            with self.subTest(payload=payload):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    directory = Path(temporary_directory)
                    baseline = self.write_payload(directory, payload)

                    result = self.run_cli(baseline)

                self.assert_invalid_input(result, reason, baseline)

    def test_cli_returns_two_for_invalid_paths_shape_or_members(self):
        cases = (
            ("paths-not-list", {"schema_version": 1}),
            ("paths-not-list", {"schema_version": 1, "paths": None}),
            ("paths-not-list", {"schema_version": 1, "paths": {}}),
            ("path-not-string", {"schema_version": 1, "paths": [1]}),
            (
                "path-not-string",
                {"schema_version": 1, "paths": ["docs/truth/README.md", 1]},
            ),
            ("path-empty", {"schema_version": 1, "paths": [""]}),
            ("path-absolute", {"schema_version": 1, "paths": ["/docs/truth.md"]}),
            (
                "noncanonical-path",
                {"schema_version": 1, "paths": ["docs/canon/../truth.md"]},
            ),
            (
                "noncanonical-path",
                {"schema_version": 1, "paths": ["./docs/truth.md"]},
            ),
            (
                "noncanonical-path",
                {"schema_version": 1, "paths": ["docs//truth.md"]},
            ),
            (
                "noncanonical-path",
                {"schema_version": 1, "paths": [r"docs\truth.md"]},
            ),
        )
        for reason, payload in cases:
            with self.subTest(payload=payload):
                with tempfile.TemporaryDirectory() as temporary_directory:
                    directory = Path(temporary_directory)
                    baseline = self.write_payload(directory, payload)

                    result = self.run_cli(baseline)

                self.assert_invalid_input(result, reason, baseline)


if __name__ == "__main__":
    unittest.main()
