from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


class TemporaryRepositoryTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self._temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self._temporary_directory.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Ambitions Test"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "ambitions-test@example.invalid"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "gc.auto", "0"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "maintenance.auto", "false"], check=True)

    def tearDown(self) -> None:
        self._temporary_directory.cleanup()

    def commit_all(self, message: str) -> str:
        subprocess.run(["git", "-C", str(self.root), "add", "-A"], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-q", "-m", message], check=True)
        result = subprocess.run(
            ["git", "-C", str(self.root), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()


def copy_skill_skeleton(destination: Path) -> None:
    """Copy the operational fixture files, excluding the fixture test suite."""
    skill_root = Path(__file__).resolve().parents[1]
    destination.mkdir(parents=True, exist_ok=True)
    for source in skill_root.rglob("*"):
        if not source.is_file() or "tests" in source.relative_to(skill_root).parts:
            continue
        target = destination / source.relative_to(skill_root)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def complete_frontend_sections(contents: str, phase: str) -> str:
    sections = {
        "research": (
            "Frontend impact investigation",
            "- Potential frontend impact: none\n"
            "- Existing surfaces investigated: N/A — structural fixture.\n"
            "- Evidence and unknowns: N/A — structural fixture.",
        ),
        "scope": (
            "Frontend impact contract",
            "- Surface impact: none\n"
            "- IA/navigation: none\n"
            "- Assets/iconography: none\n"
            "- Visual language: unchanged\n"
            "- Motion: unchanged\n"
            "- Copy/localization: N/A — structural fixture.\n"
            "- Accessibility: N/A — structural fixture.\n"
            "- Visual proof: N/A — structural fixture.",
        ),
        "design": (
            "Frontend experience specification",
            "- Surface impact: none\n"
            "- IA/navigation: none\n"
            "- Assets/iconography: none\n"
            "- Visual language: unchanged\n"
            "- Motion: unchanged\n"
            "- Copy/localization: N/A — structural fixture.\n"
            "- Accessibility: N/A — structural fixture.\n"
            "- Visual proof: N/A — structural fixture.\n"
            "- Visual gate: not-required",
        ),
    }
    heading, body = sections[phase]
    return re.sub(
        rf"(## {re.escape(heading)}\n\n).*?(?=\n## |\Z)",
        rf"\1{body}\n",
        contents,
        flags=re.DOTALL,
    )
