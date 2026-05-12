#!/usr/bin/env python3
"""Local, non-network repo-brain query utility.

This module supports local text search for upcoming OpenAI File Search/vector workflows.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

DEFAULT_MANIFEST = Path(__file__).resolve().parents[1] / "manifest.json"
ROOT = Path(__file__).resolve().parents[2]


def load_manifest(manifest_path: Path) -> dict[str, Any]:
    return json.loads(manifest_path.read_text(encoding="utf-8"))


def search_entries(manifest: dict[str, Any], query: str) -> list[dict[str, Any]]:
    query_l = query.lower()
    matches = []
    for item in manifest.get("files", []):
        path = Path(item["path"])
        full_path = ROOT / path
        try:
            text = full_path.read_text(encoding="utf-8", errors="ignore").lower()
        except OSError:
            continue
        if query_l in text:
            count = text.count(query_l)
            matches.append({"path": item["path"], "matches": count})
    matches.sort(key=lambda entry: (-entry["matches"], entry["path"]))
    return matches[:20]


def main() -> int:
    parser = argparse.ArgumentParser(description="Query local repo-brain manifest")
    parser.add_argument("query", help="Search string")
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST), help="Manifest path")
    parser.add_argument("--limit", type=int, default=20, help="Max match count")
    parser.add_argument("--dry-run", action="store_true", help="Explain integration path only")
    parser.add_argument("--explain", action="store_true", help="Print future File Search plan")
    args = parser.parse_args()

    if args.dry_run:
        print("DRY RUN: local-only query path")
        print("- Build manifest with build_repo_manifest.py")
        print("- Run this query over local manifest entries")
        print("- Upload normalized embeddings in a future batch where runner policy allows")
        print("- Keep all results local-first unless explicitly user-approved")

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        if args.dry_run:
            print(f"MANIFEST_MISSING_DRY_RUN_OK: {manifest_path}")
            print("DRY RUN: no manifest is required for this validation path")
            return 0
        print(f"MANIFEST_MISSING: {manifest_path}")
        return 1

    manifest = load_manifest(manifest_path)
    matches = search_entries(manifest, args.query)
    result = {
        "query": args.query,
        "results": matches[:args.limit],
        "total": len(matches),
        "manifest_path": str(manifest_path),
    }
    print(json.dumps(result, indent=2))

    if args.explain:
        print("FILE_SEARCH_EXPLAIN: future upload would occur in non-runtime tooling lane only")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
