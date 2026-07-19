#!/usr/bin/env python3
"""Import Source Atlas Research Seeds v1 from the Deep Research appendices ZIP.

This script is intentionally local-only and non-networked. It verifies the uploaded
ZIP hash, extracts appendices, renames misleading 10000 corpus files to honest
seed_5880 names, writes a manifest, and marks all artifacts as research_seed.

It does not approve sources, compile production packs, validate official claims,
or implement Source Atlas runtime behavior.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
import zipfile
from datetime import datetime, timezone
from pathlib import Path

EXPECTED_ZIP_SHA256 = "952617c70572fbcc8e42301c893412059c08556186e584366a88604e2cf51d81"
EXPECTED_FILE_COUNT = 24
EXPECTED_GOAL_CORPUS_ROWS = 5880

RENAMES = {
    "source_atlas_goal_corpus_10000.csv": "source_atlas_goal_corpus_seed_5880.csv",
    "source_atlas_goal_corpus_10000.jsonl": "source_atlas_goal_corpus_seed_5880.jsonl",
}

DEST_RELATIVE = Path("Resources/SourceAtlas/ResearchSeeds")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def count_json_items(path: Path):
    with path.open("r", encoding="utf-8") as f:
        value = json.load(f)
    if isinstance(value, list):
        return len(value)
    if isinstance(value, dict):
        result = {}
        for key, item in value.items():
            if isinstance(item, (list, dict)):
                result[key] = len(item)
            else:
                result[key] = type(item).__name__
        return result
    return type(value).__name__


def count_jsonl_rows(path: Path) -> int:
    with path.open("r", encoding="utf-8") as f:
        return sum(1 for line in f if line.strip())


def count_csv_rows(path: Path) -> int:
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        rows = sum(1 for _ in reader)
    return max(0, rows - 1)


def main() -> int:
    parser = argparse.ArgumentParser(description="Import Source Atlas Research Seeds v1")
    parser.add_argument("--zip", required=True, help="Path to ambitions_source_atlas_machine_readable_appendices.zip")
    parser.add_argument("--repo-root", default=".", help="Repository root")
    parser.add_argument("--force", action="store_true", help="Replace existing destination")
    args = parser.parse_args()

    zip_path = Path(args.zip).expanduser().resolve()
    repo_root = Path(args.repo_root).expanduser().resolve()
    dest = repo_root / DEST_RELATIVE

    if not zip_path.exists():
        raise SystemExit(f"ZIP not found: {zip_path}")

    actual_zip_sha = sha256_file(zip_path)
    if actual_zip_sha != EXPECTED_ZIP_SHA256:
        raise SystemExit(
            f"Unexpected ZIP SHA-256. Expected {EXPECTED_ZIP_SHA256}, got {actual_zip_sha}. "
            "Do not import until the source package is verified."
        )

    if dest.exists():
        if not args.force:
            raise SystemExit(f"Destination already exists: {dest}. Re-run with --force to replace.")
        shutil.rmtree(dest)
    dest.mkdir(parents=True, exist_ok=True)

    imported = []
    with zipfile.ZipFile(zip_path) as z:
        names = [n for n in z.namelist() if not n.endswith("/")]
        if len(names) != EXPECTED_FILE_COUNT:
            raise SystemExit(f"Expected {EXPECTED_FILE_COUNT} files, got {len(names)}. Refusing import.")

        for name in names:
            target_name = RENAMES.get(name, name)
            target_path = dest / target_name
            target_path.parent.mkdir(parents=True, exist_ok=True)
            with z.open(name) as src, target_path.open("wb") as out:
                shutil.copyfileobj(src, out)
            imported.append((name, target_name, target_path))

    manifest_files = []
    for original_name, target_name, path in sorted(imported, key=lambda item: item[1]):
        entry = {
            "original_name": original_name,
            "repo_name": target_name,
            "sha256": sha256_file(path),
            "size_bytes": path.stat().st_size,
            "classification": "research_seed",
            "production_use": False,
        }
        if target_name.endswith(".jsonl"):
            entry["row_count"] = count_jsonl_rows(path)
        elif target_name.endswith(".csv"):
            entry["row_count"] = count_csv_rows(path)
        elif target_name.endswith(".json"):
            entry["item_count"] = count_json_items(path)
        manifest_files.append(entry)

    corpus_jsonl = dest / "source_atlas_goal_corpus_seed_5880.jsonl"
    if corpus_jsonl.exists():
        rows = count_jsonl_rows(corpus_jsonl)
        if rows != EXPECTED_GOAL_CORPUS_ROWS:
            raise SystemExit(f"Expected {EXPECTED_GOAL_CORPUS_ROWS} JSONL goal rows, got {rows}.")

    manifest = {
        "manifest_id": "source_atlas_research_seeds_v1",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_zip": zip_path.name,
        "source_zip_sha256": actual_zip_sha,
        "source_zip_size_bytes": zip_path.stat().st_size,
        "destination": str(DEST_RELATIVE),
        "classification": "research_seed",
        "production_use": False,
        "verified_counts": {
            "zip_file_count": len(imported),
            "goal_corpus_rows": EXPECTED_GOAL_CORPUS_ROWS,
        },
        "renames": RENAMES,
        "limitations": [
            "Representative seed corpus, not statistically proven top-10000 global goals.",
            "Source registry entries are candidates, not approved authoritative sources.",
            "High-risk legal/civic/education/certification/medical/financial/professional claims remain review-bound.",
            "Research seeds must pass Source Atlas validators before becoming production packs.",
        ],
        "files": manifest_files,
    }

    manifest_path = dest / "source_atlas_research_seeds_v1_import_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    readme = dest / "README.md"
    readme.write_text(
        "# Source Atlas Research Seeds v1\n\n"
        "These files are research seed inputs for Source Atlas Pack Factory, Goal Projection, source registry candidates, and QA fixtures.\n\n"
        "They are not production source packs and must not be treated as official/current requirement truth.\n\n"
        "See `source_atlas_research_seeds_v1_import_manifest.json` for hashes, counts, and limitations.\n",
        encoding="utf-8",
    )

    print(f"Imported {len(imported)} files into {dest}")
    print(f"Wrote {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
