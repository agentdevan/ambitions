import subprocess
import sys
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ci" / "ambitions-pr-scope.py"
REPO_ROOT = SCRIPT.parents[2]


class PullRequestScopeTests(unittest.TestCase):
    def classify(self, scope, *paths, output="summary"):
        return subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                scope,
                "--format",
                output,
            ],
            cwd=REPO_ROOT,
            input="\n".join(paths) + ("\n" if paths else ""),
            text=True,
            capture_output=True,
        )

    def test_active_law_scope_is_explicit_and_excludes_shadow_canon(self):
        for path in (
            "AGENTS.md",
            "docs/canon/CONSTITUTION.md",
            "docs/canon/migration/legacy-semantic-migration.json",
            "Native/Ambitions/App/AmbitionsApp.swift",
            "Packages/AmbitionsDesignSystem/Package.swift",
            "project.yml",
            "scripts/ambitions-green-standard-audit.py",
            "scripts/privacy-boundary-scan.sh",
            "scripts/release-claim-safety-scan.sh",
        ):
            with self.subTest(path=path):
                result = self.classify("active-law", path)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    result.stdout,
                    f"scope=active-law applicable=true matched={path}\n",
                )

        result = self.classify(
            "active-law",
            "docs/canon/CONSTITUTION.md",
            "tests/canon/test_build.py",
        )
        self.assertEqual(result.returncode, 1)
        self.assertEqual(
            result.stdout,
            "scope=active-law applicable=false reason=no-matching-changed-paths\n",
        )

    def test_source_atlas_scope_covers_implementation_tests_and_configs(self):
        for path in (
            "source-atlas/fixtures/runtime-001.json",
            "tools/source-atlas/foundry/compiler.py",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPack.swift",
            "Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackTests.swift",
            "scripts/source-atlas-boundary-audit.py",
            ".semgrep/ambitions-source-atlas.yml",
            "requirements-ci.txt",
        ):
            with self.subTest(path=path):
                self.assertEqual(self.classify("source-atlas", path).returncode, 0)

        self.assertEqual(
            self.classify("source-atlas", "docs/canon/specifications/systems/source-atlas.md").returncode,
            1,
        )

    def test_xcode_runtime_scope_is_explicit_and_does_not_match_generic_ci_changes(self):
        for path in (
            "Native/Ambitions/App/AmbitionsApp.swift",
            "Packages/AmbitionsDesignSystem/Package.swift",
            "Packages/AmbitionsDesignSystem/Sources/Tokens.swift",
            "project.yml",
            "Ambitions.xcodeproj/project.pbxproj",
            "Native/Ambitions.xcodeproj/project.pbxproj",
            "docs/qa/evidence/2026-07-05-needs-repair-proof-trigger.md",
            "scripts/ambitions-xcode-build-for-testing.sh",
            "scripts/ambitions-xcode-test-focused.sh",
            "scripts/ambitions-xcode-sim-health.sh",
            "scripts/ambitions-bounded-xcodebuild.sh",
            "scripts/ambitions-run-deterministic-screenshot-lane.sh",
            "scripts/ambitions-remediation-governance-check.py",
            "scripts/ambitions-quality-gate.py",
            "scripts/ambitions-quality-gate.sh",
            "scripts/ambitions-test-strength-audit.py",
            "scripts/ambitions-legacy-runtime-production-use-guard.py",
            "scripts/ambitions-run-ui-screenshot-matrix.sh",
            "scripts/lifeshape-linear-control-plane-check.py",
        ):
            with self.subTest(path=path):
                self.assertEqual(self.classify("xcode-runtime", path).returncode, 0)

        result = self.classify(
            "xcode-runtime",
            "docs/canon/CONSTITUTION.md",
            "scripts/ci/ambitions-pr-scope.py",
            "scripts/ci/ambitions-gitleaks-scan.sh",
            ".github/workflows/ambitions-pr-review.yml",
            "tests/canon/test_build.py",
            "scripts/ambitions-canon.py",
            "Packages/UnrelatedPackage/Package.swift",
        )
        self.assertEqual(result.returncode, 1)
        self.assertEqual(
            result.stdout,
            "scope=xcode-runtime applicable=false reason=no-matching-changed-paths\n",
        )

    def test_file_type_scopes_return_sorted_unique_matching_paths(self):
        cases = {
            "shell": (
                ("scripts/z-last.sh", "README.md", "scripts/a-first.sh", "scripts/z-last.sh"),
                "scripts/a-first.sh\nscripts/z-last.sh\n",
            ),
            "markdown": (
                ("docs/z.md", "project.yml", "README.md"),
                "README.md\ndocs/z.md\n",
            ),
            "yaml": (
                (
                    "project.yml",
                    ".github/workflows/ambitions-pr-review.yml",
                    ".semgrep/ambitions-source-atlas.yml",
                    ".markdownlint-cli2.yaml",
                ),
                ".github/workflows/ambitions-pr-review.yml\n"
                ".markdownlint-cli2.yaml\n"
                ".semgrep/ambitions-source-atlas.yml\n",
            ),
        }
        for scope, (paths, expected) in cases.items():
            with self.subTest(scope=scope):
                result = self.classify(scope, *paths, output="paths")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, expected)

    def test_no_match_and_unknown_scope_fail_transparently(self):
        result = self.classify("shell", "README.md")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(
            result.stdout,
            "scope=shell applicable=false reason=no-matching-changed-paths\n",
        )

        result = self.classify("unknown", "README.md")
        self.assertEqual(result.returncode, 2)
        self.assertIn("invalid choice", result.stderr)


if __name__ == "__main__":
    unittest.main()
