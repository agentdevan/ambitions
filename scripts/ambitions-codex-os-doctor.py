#!/usr/bin/env python3
"""Status doctor for Ambitions Codex OS control-plane assets."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def exists(path: str) -> bool:
    return (ROOT / path).is_file() or (ROOT / path).is_dir()


def exists_dir(path: str) -> bool:
    return (ROOT / path).is_dir()


def line(label: str, cond: bool) -> str:
    status = "OK" if cond else "MISSING"
    return f"{status}: {label}"


def main() -> None:
    print("Ambitions Codex OS doctor")
    print()
    print("Core control-plane")
    print(" -", line("AGENTS.md", exists("AGENTS.md")))
    print(" -", line(".codex/config.toml", exists(".codex/config.toml")))
    print(" -", line(".codex/AGENTS.md", exists(".codex/AGENTS.md")))
    print(" -", line(".agents/AGENTS.md", exists(".agents/AGENTS.md")))
    print(" -", line("scripts/AGENTS.md", exists("scripts/AGENTS.md")))

    print("\nValidation assets")
    print(" -", line(".codex/hooks.json", exists(".codex/hooks.json")))
    print(" -", line(".codex/hooks", exists_dir(".codex/hooks")))
    print(" -", line(".codex/rules", exists_dir(".codex/rules")))
    print(" -", line(".codex/schemas", exists_dir(".codex/schemas")))
    print(" -", line("docs/codex/os", exists_dir("docs/codex/os")))
    print(" -", line("docs/codex/reports", exists_dir("docs/codex/reports")))
    print(" -", line("scripts/ambitions-codex-os-validate.py", exists("scripts/ambitions-codex-os-validate.py")))
    print(" -", line("scripts/ambitions-codex-os-doctor.py", exists("scripts/ambitions-codex-os-doctor.py")))
    print(" -", line(".codex/rules/ambitions-no-cost.rules", exists(".codex/rules/ambitions-no-cost.rules")))
    print(" -", line("docs/codex-os", exists_dir("docs/codex-os")))
    print(" -", line(".codex/skills/ambitions", exists_dir(".codex/skills/ambitions")))

    print("\nMake targets")
    makefile = ROOT / "Makefile"
    if makefile.exists():
        text = makefile.read_text(encoding="utf-8", errors="ignore")
        print(" -", line("ambitions-codex-os-validate", "ambitions-codex-os-validate:" in text))
        print(" -", line("ambitions-codex-os-doctor", "ambitions-codex-os-doctor:" in text))
    else:
        print(" - missing: Makefile")

    print("\nActivation")
    print(" - Enable hooks via [features].hooks = true in .codex/config.toml")
    print(" - Review/trust hook handlers from .codex/hooks.json when Codex prompts for hook trust")
    print(" - Runner path remains unchanged for safety; review docs/codex-os/RUNNER_UPGRADE_NOTES.md")

    print("\nNo-cost boundary")
    print(" - New dependencies: no")
    print(" - API keys: no")
    print(" - Network installers: no")
    print(" - CI additions: no")
    print(" - Paid services: no")


if __name__ == "__main__":
    main()
