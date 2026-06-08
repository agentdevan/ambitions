import json
import hashlib
import os
import zipfile
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List
import duckdb

def calculate_sha256(file_path: Path) -> str:
    hasher = hashlib.sha256()
    with file_path.open("rb") as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def zip_publish_folder(run_dir: Path) -> Path:
    publish_root = run_dir / "publish"
    zip_path = run_dir / "publish_bundle.zip"
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(publish_root):
            for file in files:
                file_path = Path(root) / file
                archive_name = file_path.relative_to(publish_root)
                zipf.write(file_path, archive_name)
    return zip_path

def compile_staged_artifacts(run_dir: Path, domains_file: Path) -> Dict[str, Any]:
    """
    Compiles all clean records and domains into final staged JSON/JSONL index artifacts
    and saves them in the run's `publish/factory/v1/` folder.
    """
    start_time = time.time()
    publish_dir = run_dir / "publish" / "factory" / "v1"
    publish_dir.mkdir(parents=True, exist_ok=True)
    
    clean_domain_file = run_dir / "clean" / "domain_intents.jsonl"
    clean_grammar_file = run_dir / "clean" / "grammar_intents.jsonl"
    
    # 1. Compile goal-intent-index.jsonl
    intent_index_path = publish_dir / "goal-intent-index.jsonl"
    all_intents = []
    
    with intent_index_path.open("w", encoding="utf-8") as out:
        for file_path in [clean_domain_file, clean_grammar_file]:
            if file_path.exists():
                with file_path.open("r", encoding="utf-8") as f:
                    for line in f:
                        if not line.strip():
                            continue
                        item = json.loads(line.strip())
                        # Format strictly as matching-index entries
                        index_entry = {
                            "id": item["id"],
                            "domain": item["domain"],
                            "category": item["category"],
                            "intent_phrase": item["intent_phrase"],
                            "runtime_eligible": item["runtime_eligible"],
                            "runtime_role": item["runtime_role"],
                            "blocked_for_step_generation": item["blocked_for_step_generation"],
                            "evidence_quality": item["evidence_quality"]
                        }
                        out.write(json.dumps(index_entry) + "\n")
                        all_intents.append(index_entry)
                        
    # 2. Compile domain-index.json
    domain_index_path = publish_dir / "domain-index.json"
    domains_data = []
    if domains_file.exists():
        with domains_file.open("r", encoding="utf-8") as f:
            domains_raw = json.load(f)
            if isinstance(domains_raw, dict) and "domains" in domains_raw:
                domains_data = domains_raw["domains"]
            elif isinstance(domains_raw, list):
                domains_data = domains_raw
                
    domain_index = {}
    for dom in domains_data:
        domain_index[dom["code"]] = {
            "title": dom["title"],
            "description": dom["description"],
            "categories": dom.get("categories", ["general"])
        }
    with domain_index_path.open("w", encoding="utf-8") as f:
        json.dump(domain_index, f, indent=2)
        
    # 3. Compile alias-index.json
    alias_index_path = publish_dir / "alias-index.json"
    aliases = {}
    for dom in domains_data:
        code = dom["code"]
        title_lower = dom["title"].lower()
        aliases[title_lower] = code
        aliases[f"get better in {title_lower}"] = code
        aliases[f"improve {title_lower}"] = code
        for cat in dom.get("categories", []):
            aliases[cat.replace("_", " ")] = f"{code}/{cat}"
            
    with alias_index_path.open("w", encoding="utf-8") as f:
        json.dump(aliases, f, indent=2)
        
    # 4. Compile coverage-matrix.json
    coverage_matrix_path = publish_dir / "coverage-matrix.json"
    domain_counts = {}
    for dom in domains_data:
        domain_counts[dom["code"]] = 0
    for it in all_intents:
        dom = it["domain"]
        if dom in domain_counts:
            domain_counts[dom] += 1
            
    coverage_matrix = {
        "metadata": {
            "total_intents": len(all_intents),
            "generated_at": datetime.now(timezone.utc).isoformat()
        },
        "domain_coverage": domain_counts
    }
    with coverage_matrix_path.open("w", encoding="utf-8") as f:
        json.dump(coverage_matrix, f, indent=2)
        
    # 5. Compile staged-manifest.json
    manifest_path = publish_dir / "staged-manifest.json"
    
    staged_files = {
        "goal-intent-index.jsonl": calculate_sha256(intent_index_path),
        "domain-index.json": calculate_sha256(domain_index_path),
        "alias-index.json": calculate_sha256(alias_index_path),
        "coverage-matrix.json": calculate_sha256(coverage_matrix_path)
    }
    
    staged_manifest = {
        "manifest_version": "staged.v1",
        "run_id": run_dir.name,
        "built_at": datetime.now(timezone.utc).isoformat(),
        "stats": {
            "intent_count": len(all_intents),
            "domain_count": len(domain_counts)
        },
        "artifacts": staged_files
    }
    
    with manifest_path.open("w", encoding="utf-8") as f:
        json.dump(staged_manifest, f, indent=2)
        
    # --- Guardrail check ---
    for path_item in [intent_index_path, domain_index_path, alias_index_path, coverage_matrix_path, manifest_path]:
        path_str = str(path_item).replace("\\", "/").lower()
        if "current.json" in path_str or "/packs/" in path_str or "/seeds/" in path_str:
            raise ValueError(f"Path violation detected: '{path_str}' violates guardrails (no current.json, no /packs/, no /seeds/).")
            
    # Warehouse Local Parquet Storage
    db_path = run_dir / "reports" / "qa_warehouse.db"
    parquet_out_dir = run_dir / "clean" / "parquet"
    parquet_out_dir.mkdir(parents=True, exist_ok=True)
    
    if db_path.exists() and len(all_intents) > 0:
        conn = duckdb.connect(str(db_path))
        try:
            conn.execute(f"COPY goal_intents TO '{parquet_out_dir / 'goal_intents.parquet'}' (FORMAT PARQUET);")
        finally:
            conn.close()
            
    # ZIP export creation
    zip_publish_folder(run_dir)
    
    # Trace performance duration
    duration = time.time() - start_time
    file_count = 0
    total_size = 0
    
    publish_root = run_dir / "publish"
    for root, dirs, files in os.walk(publish_root):
        for file in files:
            file_count += 1
            total_size += (Path(root) / file).stat().st_size
            
    perf_file = run_dir / "reports" / "performance_report.json"
    perf_data = {}
    if perf_file.exists():
        try:
            with perf_file.open("r", encoding="utf-8") as pf:
                perf_data = json.load(pf)
        except Exception:
            pass
            
    perf_data["compile_duration_sec"] = duration
    perf_data["staged_file_count"] = file_count
    perf_data["staged_total_size_bytes"] = total_size
    with perf_file.open("w", encoding="utf-8") as pf:
        json.dump(perf_data, pf, indent=2)
        
    return staged_manifest

