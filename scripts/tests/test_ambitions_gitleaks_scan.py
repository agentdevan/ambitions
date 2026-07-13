import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ci" / "ambitions-gitleaks-scan.sh"
REPO_ROOT = SCRIPT.parents[2]


class GitleaksScanModeTests(unittest.TestCase):
    def run_scan(self, *arguments):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log = root / "gitleaks.log"
            executable = root / "gitleaks"
            executable.write_text(
                "#!/usr/bin/env bash\n"
                "printf '%s\\n' \"$*\" >> \"$GITLEAKS_TEST_LOG\"\n",
                encoding="utf-8",
            )
            executable.chmod(0o755)
            real_git = shutil.which("git")
            self.assertIsNotNone(real_git)
            git = root / "git"
            git.write_text(
                "#!/usr/bin/env bash\n"
                "if [[ \"${1:-}\" == \"ls-files\" ]]; then\n"
                "  printf 'README.md\\0'\n"
                "  exit 0\n"
                "fi\n"
                f"exec {real_git} \"$@\"\n",
                encoding="utf-8",
            )
            git.chmod(0o755)
            base = subprocess.run(
                ["git", "rev-parse", "HEAD^"],
                cwd=REPO_ROOT,
                check=True,
                text=True,
                capture_output=True,
            ).stdout.strip()
            environment = os.environ.copy()
            environment.update(
                {
                    "GITHUB_BASE_SHA": base,
                    "GITLEAKS_TEST_LOG": str(log),
                    "PATH": f"{root}:{environment['PATH']}",
                }
            )
            result = subprocess.run(
                ["bash", str(SCRIPT), *arguments],
                cwd=REPO_ROOT,
                env=environment,
                text=True,
                capture_output=True,
            )
            calls = log.read_text(encoding="utf-8").splitlines() if log.exists() else []
            return result, calls, base

    def test_default_mode_scans_current_material_and_introduced_range(self):
        result, calls, base = self.run_scan()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 2)
        self.assertTrue(calls[0].startswith("dir "), calls)
        self.assertIn("git ", calls[1])
        self.assertIn(f"--log-opts {base}..HEAD", calls[1])
        self.assertIn("mode=full", result.stdout)

    def test_range_only_mode_omits_current_material_but_scans_introduced_range(self):
        result, calls, base = self.run_scan("--range-only")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 1)
        self.assertTrue(calls[0].startswith("git "), calls)
        self.assertIn(f"--log-opts {base}..HEAD", calls[0])
        self.assertIn("mode=range-only", result.stdout)
        self.assertIn("current repo material skipped", result.stdout)

    def test_unknown_mode_fails_before_scanning(self):
        result, calls, _ = self.run_scan("--unknown")

        self.assertEqual(result.returncode, 2)
        self.assertEqual(calls, [])
        self.assertIn("usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()
