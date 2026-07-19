#!/usr/bin/env python3
"""Validate Ambitions repo-local skill registry consistency."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / ".agents" / "skills" / "README.md"
SKILLS_ROOT = ROOT / ".agents" / "skills"
CODEX_START = "docs/truth/CODEX_START_HERE.md"


def section(text: str, heading: str) -> str:
    pattern = re.compile(
        rf"^## {re.escape(heading)}\n(?P<body>.*?)(?=^## |\Z)",
        flags=re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    return match.group("body") if match else ""


def registry_paths(text: str, headings: tuple[str, ...]) -> set[str]:
    paths: set[str] = set()
    for heading in headings:
        body = section(text, heading)
        paths.update(re.findall(r"\.agents/skills/[A-Za-z0-9_-]+/SKILL\.md", body))
    return paths


def frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---", 4)
    if end == -1:
        return {}
    values: dict[str, str] = {}
    for line in text[4:end].splitlines():
        key, separator, value = line.partition(":")
        if separator:
            values[key.strip()] = value.strip()
    return values


def main() -> int:
    errors: list[str] = []

    if not REGISTRY.exists():
        print("RED: missing .agents/skills/README.md", file=sys.stderr)
        return 1

    registry_text = REGISTRY.read_text(encoding="utf-8")
    retained = registry_paths(registry_text, ("Retained Skills",))
    allowed_non_retained = registry_paths(registry_text, ("Merge Candidates", "Delete Candidates", "Experimental Skills"))

    if not retained:
        errors.append("registry has no retained skills")

    present = {
        path.relative_to(ROOT).as_posix()
        for path in sorted(SKILLS_ROOT.glob("*/SKILL.md"))
    }

    names: dict[str, str] = {}
    for rel in sorted(present):
        path = ROOT / rel
        meta = frontmatter(path.read_text(encoding="utf-8"))
        name = meta.get("name", "")
        if not name:
            continue
        if name in names:
            errors.append(f"duplicate skill name {name!r}: {names[name]} and {rel}")
        names[name] = rel

    for rel in sorted(retained):
        path = ROOT / rel
        if not path.exists():
            errors.append(f"retained skill missing real SKILL.md: {rel}")
            continue

        text = path.read_text(encoding="utf-8")
        meta = frontmatter(text)
        name = meta.get("name", "")
        description = meta.get("description", "")
        if not name:
            errors.append(f"{rel}: missing frontmatter name:")
        if not description:
            errors.append(f"{rel}: missing frontmatter description:")
        if "## Skill digest" not in text:
            errors.append(f"{rel}: missing ## Skill digest")
        if CODEX_START not in text:
            errors.append(f"{rel}: missing {CODEX_START}")

    registered = retained | allowed_non_retained
    unregistered = sorted(present - registered)
    for rel in unregistered:
        errors.append(f"{rel}: present but absent from registry retained/merge/delete/experimental sections")

    print("# Ambitions Skill Registry Check")
    print(f"registry={REGISTRY.relative_to(ROOT)}")
    print(f"retained={len(retained)}")
    print(f"merge_delete_or_experimental={len(allowed_non_retained)}")
    print(f"present_skill_files={len(present)}")

    if errors:
        for error in errors:
            print(f"RED: {error}", file=sys.stderr)
        return 1

    print("GREEN: skill registry is consistent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
