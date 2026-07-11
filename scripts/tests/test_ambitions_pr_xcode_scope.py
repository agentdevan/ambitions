import subprocess
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ambitions-pr-xcode-scope.sh"
REPO_ROOT = SCRIPT.parents[1]


class PullRequestXcodeScopeTests(unittest.TestCase):
    def applies(self, *paths):
        result = subprocess.run(
            ["bash", str(SCRIPT)],
            cwd=REPO_ROOT,
            input="\n".join(paths) + "\n",
            text=True,
            capture_output=True,
        )
        return result.returncode

    def test_package_manifest_only_applies(self):
        self.assertEqual(self.applies("Packages/AmbitionsDesignSystem/Package.swift"), 0)

    def test_package_source_only_applies(self):
        self.assertEqual(self.applies("Packages/AmbitionsDesignSystem/Sources/Tokens.swift"), 0)
        self.assertEqual(self.applies("Packages/AmbitionsDesignSystem/AppUI/Sources/Card.swift"), 0)

    def test_existing_native_project_workflow_and_script_inputs_apply(self):
        for path in (
            "Native/Ambitions/App/App.swift",
            "project.yml",
            ".github/workflows/ambitions-pr-review.yml",
            "scripts/ambitions-quality-gate.py",
            "docs/qa/evidence/2026-07-05-needs-repair-proof-trigger.md",
        ):
            with self.subTest(path=path):
                self.assertEqual(self.applies(path), 0)

    def test_unrelated_docs_only_does_not_apply(self):
        self.assertEqual(self.applies("docs/README.md", "docs/truth/README.md"), 1)


if __name__ == "__main__":
    unittest.main()
