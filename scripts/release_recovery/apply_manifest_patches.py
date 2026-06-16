#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: apply_manifest_patches.py <manifest>", file=sys.stderr)
        return 2
    manifest = ROOT / argv[1]
    data = json.loads(manifest.read_text(encoding="utf-8"))
    changed: list[str] = []
    for patch in data.get("patches", []):
        path = ROOT / patch["path"]
        text = path.read_text(encoding="utf-8")
        old = patch["old"]
        new = patch["new"]
        if new not in text:
            if old not in text:
                raise RuntimeError(f"patch anchor missing: {patch['path']}")
            text = text.replace(old, new, 1)
            path.write_text(text, encoding="utf-8")
            changed.append(patch["path"])
    for check in data.get("checks", []):
        path = ROOT / check["path"]
        text = path.read_text(encoding="utf-8")
        missing = [needle for needle in check.get("contains", []) if needle not in text]
        if missing:
            raise RuntimeError(f"{check['path']} missing: {', '.join(missing)}")
    print(f"applied manifest {argv[1]}")
    for item in changed:
        print(f"- {item}")
    if not changed:
        print("- no source changes required")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
