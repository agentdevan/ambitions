import unittest
from pathlib import Path


WORKFLOW = (
    Path(__file__).resolve().parents[2]
    / ".github"
    / "workflows"
    / "ambitions-pr-review.yml"
)


class PullRequestReviewWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WORKFLOW.read_text(encoding="utf-8")

    def test_scope_job_uses_base_diff_and_dispatch_runs_all_scopes(self):
        self.assertIn("pr_scope:", self.text)
        self.assertIn("fetch-depth: 0", self.text)
        self.assertIn('${GITHUB_EVENT_NAME}" == "workflow_dispatch', self.text)
        self.assertIn('git merge-base HEAD "origin/${base_ref}"', self.text)
        self.assertIn('python3 scripts/ci/ambitions-pr-scope.py "$scope"', self.text)
        for output in (
            "active_law",
            "source_atlas",
            "xcode_runtime",
            "shell",
            "markdown",
            "yaml",
        ):
            with self.subTest(output=output):
                self.assertIn(f"{output}:", self.text)
        self.assertIn("classify xcode-runtime xcode_runtime", self.text)

    def test_legacy_jobs_have_applicable_run_and_transparent_skip_steps(self):
        expected_skips = (
            "No active product/source/law paths changed; Ambitions law audits skipped.",
            "No Source Atlas implementation/config paths changed; Semgrep skipped.",
            "No Source Atlas implementation/config paths changed; Python tests skipped.",
            "No changed shell scripts; ShellCheck skipped.",
            "No changed Markdown files; markdownlint skipped.",
            "No changed relevant YAML files; yamllint skipped.",
        )
        for message in expected_skips:
            with self.subTest(message=message):
                self.assertIn(message, self.text)

        self.assertIn('shellcheck "${files[@]}"', self.text)
        self.assertIn('markdownlint-cli2 --no-globs "${files[@]}"', self.text)
        self.assertIn('yamllint "${files[@]}"', self.text)
        self.assertIn('while IFS= read -r file; do', self.text)
        self.assertNotIn('mapfile -t files', self.text)
        self.assertNotIn('find scripts -name "*.sh"', self.text)
        self.assertNotIn('markdownlint-cli2 "**/*.md"', self.text)
        self.assertNotIn("yamllint .github .semgrep", self.text)

    def test_pr_gitleaks_is_range_only_and_binds_the_introduced_base(self):
        self.assertIn("GITHUB_BASE_SHA:", self.text)
        self.assertIn(
            'if [[ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]]; then\n'
            "            bash scripts/ci/ambitions-gitleaks-scan.sh\n"
            "          else\n"
            "            bash scripts/ci/ambitions-gitleaks-scan.sh --range-only\n"
            "          fi",
            self.text,
        )

    def test_xcode_jobs_consume_explicit_scope_and_preserve_validation_bodies(self):
        self.assertNotIn("scripts/ambitions-pr-xcode-scope.sh", self.text)
        self.assertEqual(
            self.text.count("needs.pr_scope.outputs.xcode_runtime == 'true'"),
            6,
        )
        self.assertEqual(
            self.text.count("needs.pr_scope.outputs.xcode_runtime != 'true'"),
            2,
        )
        self.assertEqual(
            self.text.count(
                "No production/package/project/Xcode-tooling paths changed; "
            ),
            2,
        )
        for command in (
            "scripts/ambitions-xcode-build-for-testing.sh --batch green-standard",
            "scripts/ambitions-xcodegen-needed.sh",
            "python3 scripts/ambitions-remediation-governance-check.py",
            "scripts/ambitions-run-deterministic-screenshot-lane.sh",
        ):
            with self.subTest(command=command):
                self.assertIn(command, self.text)


if __name__ == "__main__":
    unittest.main()
