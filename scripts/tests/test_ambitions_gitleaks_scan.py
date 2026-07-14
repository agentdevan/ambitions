import os
import re
import shutil
import subprocess
import tempfile
import tomllib
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "ci" / "ambitions-gitleaks-scan.sh"
REPO_ROOT = SCRIPT.parents[2]
CONFIG = REPO_ROOT / ".gitleaks.toml"


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


class GitleaksPublicIdentifierPolicyTests(unittest.TestCase):
    PUBLIC_FIGMA_DOCUMENT_KEY = "SWtHm9ouHTPbEFfNrrtZwv"
    ALLOWLIST_DESCRIPTION = "Exact reviewed public Figma document key"

    def test_allowlist_is_scoped_to_the_exact_public_identifier(self):
        config = tomllib.loads(CONFIG.read_text(encoding="utf-8"))
        matching_allowlists = [
            entry
            for entry in config.get("allowlists", [])
            if entry.get("description") == self.ALLOWLIST_DESCRIPTION
        ]

        self.assertEqual(len(matching_allowlists), 1)
        allowlist = matching_allowlists[0]
        self.assertEqual(allowlist.get("regexTarget"), "secret")
        self.assertEqual(
            allowlist.get("regexes"),
            [rf"^{re.escape(self.PUBLIC_FIGMA_DOCUMENT_KEY)}$"],
        )
        self.assertNotIn("paths", allowlist)
        self.assertNotIn("rules", allowlist)
        self.assertNotIn("commits", allowlist)

        pattern = re.compile(allowlist["regexes"][0])
        self.assertIsNotNone(pattern.fullmatch(self.PUBLIC_FIGMA_DOCUMENT_KEY))
        self.assertIsNone(pattern.fullmatch(self.PUBLIC_FIGMA_DOCUMENT_KEY + "X"))

    @unittest.skipUnless(shutil.which("gitleaks"), "gitleaks is not installed")
    def test_gitleaks_allows_the_exact_public_identifier(self):
        result = self.run_gitleaks(self.PUBLIC_FIGMA_DOCUMENT_KEY)

        self.assertEqual(result.returncode, 0, result.stderr)

    @unittest.skipUnless(shutil.which("gitleaks"), "gitleaks is not installed")
    def test_gitleaks_rejects_an_adjacent_credential_like_value(self):
        result = self.run_gitleaks(self.PUBLIC_FIGMA_DOCUMENT_KEY + "X")

        self.assertEqual(result.returncode, 1, result.stderr)

    def run_gitleaks(self, candidate):
        with tempfile.TemporaryDirectory() as temporary:
            fixture = Path(temporary) / "fixture.toml"
            fixture.write_text(f'file_key = "{candidate}"\n', encoding="utf-8")
            return subprocess.run(
                [
                    "gitleaks",
                    "dir",
                    temporary,
                    "--config",
                    str(CONFIG),
                    "--no-banner",
                    "--redact",
                    "--exit-code",
                    "1",
                ],
                cwd=REPO_ROOT,
                text=True,
                capture_output=True,
            )


if __name__ == "__main__":
    unittest.main()
