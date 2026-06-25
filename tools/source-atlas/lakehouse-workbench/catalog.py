"""First-class Source Atlas Foundry candidate compiler."""

from __future__ import annotations

import json
import time
import zipfile
from pathlib import Path
from typing import Any

import duckdb

from foundry_bridge import compile_foundry_candidate_bundle


def zip_candidate_bundle(candidate_root: Path) -> Path:
    zip_path = candidate_root.parent / f"{candidate_root.name}.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for file_path in sorted(path for path in candidate_root.rglob("*") if path.is_file()):
            archive.write(file_path, file_path.relative_to(candidate_root))
    return zip_path


def compile_foundry_candidate_artifacts(run_dir: Path, domains_file: Path) -> dict[str, Any]:
    """Compile clean lakehouse records into a Foundry candidate bundle only."""

    start_time = time.time()
    result = compile_foundry_candidate_bundle(run_dir, domains_file, run_dir.name)
    candidate_root = Path(result["candidateRoot"])

    db_path = run_dir / "reports" / "qa_warehouse.db"
    parquet_out_dir = run_dir / "clean" / "parquet"
    parquet_out_dir.mkdir(parents=True, exist_ok=True)
    parquet_path = parquet_out_dir / "goal_intents.parquet"

    if db_path.exists() and not parquet_path.exists():
        conn = duckdb.connect(str(db_path))
        try:
            conn.execute(f"COPY goal_intents TO '{parquet_path}' (FORMAT PARQUET);")
        finally:
            conn.close()

    zip_path = zip_candidate_bundle(candidate_root)

    duration = time.time() - start_time
    file_count = sum(1 for path in candidate_root.rglob("*") if path.is_file())
    total_size = sum(path.stat().st_size for path in candidate_root.rglob("*") if path.is_file())

    perf_file = run_dir / "reports" / "performance_report.json"
    perf_file.parent.mkdir(parents=True, exist_ok=True)
    perf_data: dict[str, Any] = {}
    if perf_file.exists():
        try:
            perf_data = json.loads(perf_file.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            perf_data = {}

    perf_data["compile_duration_sec"] = duration
    perf_data["candidate_file_count"] = file_count
    perf_data["candidate_total_size_bytes"] = total_size
    perf_data["candidate_zip_path"] = str(zip_path)
    perf_file.write_text(json.dumps(perf_data, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    return {
        **result,
        "candidateZipPath": str(zip_path),
        "candidateFileCount": file_count,
        "candidateTotalSizeBytes": total_size,
    }
