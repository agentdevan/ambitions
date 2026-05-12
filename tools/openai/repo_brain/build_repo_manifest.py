#!/usr/bin/env python3
"""Create a local JSON manifest for OBS repo tooling.

This module is intentionally local-only and can run in dry-run mode.
"""
from __future__ import annotations

import argparse
import json
import os
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[3]
DEFAULT_INDEX_DIRS = [
    Path("docs/truth"),
    Path("docs/codex"),
    Path("docs/audits"),
    Path("prompts/batches"),
    Path("scripts"),
]
EXCLUDE_DIRS = {
    ".codex/runs",
    "output",
    "build",
    "DerivedData",
    ".venv",
    "__pycache__",
}
EXCLUDE_FILENAMES = {
    ".env",
    ".env.local",
    ".DS_Store",
}
EXCLUDE_SUFFIXES = {
    ".log",
    ".xcresult",
}


@dataclass
class ManifestEntry:
    path: str
    size: int
    mtime: float
    extension: str


def iter_index_files(root: Path, rel_roots: Iterable[Path]) -> Iterable[Path]:
    allowed_roots = [root / rel_root for rel_root in rel_roots]
    for base in allowed_roots:
        if not base.exists():
            continue
        for child in base.rglob("*"):
            if child.is_dir():
                if any(seg in EXCLUDE_DIRS for seg in child.parts):
                    continue
                continue
            if child.name in EXCLUDE_FILENAMES:
                continue
            if any(part in EXCLUDE_DIRS for part in child.parts):
                continue
            if child.suffix in EXCLUDE_SUFFIXES:
                continue
            if child.name.startswith("."):
                continue
            yield child.relative_to(root)


def to_entries(root: Path, rel_roots: Iterable[Path], dry_run: bool) -> list[ManifestEntry]:
    entries: list[ManifestEntry] = []
    for rel_path in iter_index_files(root, rel_roots):
        if rel_path.suffix == ".swift" and "Native/Ambitions" in str(rel_path):
            continue
        if rel_path.name.startswith("."):
            continue
        abs_path = root / rel_path
        stat = abs_path.stat()
        entries.append(ManifestEntry(
            path=str(rel_path.as_posix()),
            size=stat.st_size,
            mtime=stat.st_mtime,
            extension=abs_path.suffix.lower(),
        ))
    return sorted(entries, key=lambda item: item.path)


def build_manifest(path: Path) -> dict:
    root = path
    entries = to_entries(root, DEFAULT_INDEX_DIRS, dry_run=False)
    return {
        "manifest_version": 1,
        "root": str(root),
        "count": len(entries),
        "files": [asdict(entry) for entry in entries],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build local OBS repo manifest")
    parser.add_argument("--root", default=str(ROOT), help="Repository root")
    parser.add_argument("--output", default=str(ROOT / "tools/openai/repo_brain/manifest.json"), help="Output manifest path")
    parser.add_argument("--dry-run", action="store_true", help="Print summary only")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    manifest = {
        "manifest_version": 1,
        "root": str(root),
        "index_dirs": [str((root / p).as_posix()) for p in DEFAULT_INDEX_DIRS],
        "count": 0,
        "files": [],
    }
    entries = to_entries(root, DEFAULT_INDEX_DIRS, args.dry_run)
    manifest["count"] = len(entries)
    manifest["files"] = [asdict(entry) for entry in entries]

    output_path = Path(args.output)
    if not args.dry_run:
        output_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        print(f"WROTE {output_path}")

    print(json.dumps(manifest, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
