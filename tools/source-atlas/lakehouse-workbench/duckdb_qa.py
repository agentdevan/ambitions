import json
import duckdb
from pathlib import Path
from typing import Any, Dict, List

import time

def run_qa_audits(run_dir: Path, domains_file: Path) -> Dict[str, Any]:
    """
    Loads clean records and domains into a local DuckDB file,
    runs quality audit queries, and returns audit reports.
    """
    start_time = time.time()
    db_path = run_dir / "reports" / "qa_warehouse.db"
    
    # Use a persistent db connection
    conn = duckdb.connect(str(db_path))
    
    # Create tables
    conn.execute("DROP TABLE IF EXISTS goal_intents;")
    conn.execute("DROP TABLE IF EXISTS domains;")
    
    conn.execute("""
        CREATE TABLE goal_intents (
            id VARCHAR,
            domain VARCHAR,
            category VARCHAR,
            intent_phrase VARCHAR,
            runtime_eligible BOOLEAN,
            runtime_role VARCHAR,
            blocked_for_step_generation BOOLEAN,
            evidence_quality VARCHAR,
            source_freshness VARCHAR,
            risk_level VARCHAR,
            private_data_flag BOOLEAN,
            created_at VARCHAR
        );
    """)
    
    conn.execute("""
        CREATE TABLE domains (
            code VARCHAR PRIMARY KEY,
            title VARCHAR,
            description VARCHAR
        );
    """)
    
    # Load domains
    if domains_file.exists():
        with domains_file.open("r", encoding="utf-8") as f:
            domains_data = json.load(f)
            # Ensure it is a list of domains
            if isinstance(domains_data, dict) and "domains" in domains_data:
                domains_list = domains_data["domains"]
            elif isinstance(domains_data, list):
                domains_list = domains_data
            else:
                domains_list = []
                
            for dom in domains_list:
                conn.execute(
                    "INSERT INTO domains VALUES (?, ?, ?);",
                    (dom.get("code"), dom.get("title"), dom.get("description"))
                )
                
    # Load clean records
    clean_domain_file = run_dir / "clean" / "domain_intents.jsonl"
    clean_grammar_file = run_dir / "clean" / "grammar_intents.jsonl"
    
    loaded_count = 0
    conn.execute("BEGIN TRANSACTION;")
    try:
        for file_path in [clean_domain_file, clean_grammar_file]:
            if file_path.exists():
                with file_path.open("r", encoding="utf-8") as f:
                    for line in f:
                        if not line.strip():
                            continue
                        item = json.loads(line.strip())
                        # Insert record
                        conn.execute("""
                            INSERT INTO goal_intents VALUES (
                                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                            );
                        """, (
                            item.get("id"),
                            item.get("domain"),
                            item.get("category"),
                            item.get("intent_phrase"),
                            item.get("runtime_eligible"),
                            item.get("runtime_role"),
                            item.get("blocked_for_step_generation"),
                            item.get("evidence_quality"),
                            item.get("source_freshness"),
                            item.get("risk_level"),
                            item.get("private_data_flag"),
                            item.get("created_at")
                        ))
                        loaded_count += 1
        conn.execute("COMMIT;")
    except Exception as e:
        conn.execute("ROLLBACK;")
        raise e
                    
    # Execute audits
    audit_reports = {
        "loaded_records_count": loaded_count,
        "duplicate_ids": [],
        "near_duplicate_intents": [],
        "missing_domains": [],
        "safety_violations": [],
        "generic_or_shaming_phrases": [],
        "private_data_leaks": [],
        "coverage_gaps": []
    }
    
    if loaded_count == 0:
        conn.close()
        return audit_reports

    # 1. Duplicate IDs
    dups_res = conn.execute("""
        SELECT id, COUNT(*) as count 
        FROM goal_intents 
        GROUP BY id 
        HAVING COUNT(*) > 1;
    """).fetchall()
    audit_reports["duplicate_ids"] = [{"id": r[0], "count": r[1]} for r in dups_res]

    # 2. Near-duplicate intent phrases (lower case, stripped punctuation, white spaces)
    near_dups_res = conn.execute("""
        SELECT 
            regexp_replace(lower(trim(intent_phrase)), '[^a-z0-9 ]', '', 'g') as norm_phrase, 
            COUNT(*) as count,
            list(id) as ids,
            list(intent_phrase) as original_phrases
        FROM goal_intents 
        GROUP BY norm_phrase 
        HAVING COUNT(*) > 1
        LIMIT 100;
    """).fetchall()
    audit_reports["near_duplicate_intents"] = [
        {"normalized_phrase": r[0], "count": r[1], "ids": r[2], "original_phrases": r[3]} for r in near_dups_res
    ]

    # 3. Missing domains
    missing_doms_res = conn.execute("""
        SELECT DISTINCT i.domain 
        FROM goal_intents i 
        LEFT JOIN domains d ON i.domain = d.code 
        WHERE d.code IS NULL;
    """).fetchall()
    audit_reports["missing_domains"] = [{"domain_code": r[0]} for r in missing_doms_res]

    # 4. Invalid risk, review, and source states (enforcing critical data safety invariants)
    # Goal intents may be runtime_eligible: true ONLY IF runtime_role = 'intent_matching_only' and blocked_for_step_generation = true
    # AND evidence_quality is NOT seed_archetype, peer_reviewed, professional_guidance_required
    safety_res = conn.execute("""
        SELECT id, intent_phrase, runtime_eligible, runtime_role, blocked_for_step_generation, evidence_quality
        FROM goal_intents
        WHERE runtime_eligible = true AND (
            runtime_role != 'intent_matching_only' 
            OR blocked_for_step_generation != true 
            OR evidence_quality IN ('seed_archetype', 'peer_reviewed', 'professional_guidance_required')
        );
    """).fetchall()
    audit_reports["safety_violations"] = [
        {
            "id": r[0], 
            "intent_phrase": r[1], 
            "runtime_eligible": r[2], 
            "runtime_role": r[3], 
            "blocked_for_step_generation": r[4], 
            "evidence_quality": r[5]
        } for r in safety_res
    ]

    # 5. Generic or forbidden/shaming phrases
    generic_res = conn.execute("""
        SELECT id, intent_phrase 
        FROM goal_intents
        WHERE lower(intent_phrase) LIKE '%do something%'
           OR lower(intent_phrase) LIKE '%plan my day%'
           OR lower(intent_phrase) LIKE '%streak broken%'
           OR lower(intent_phrase) LIKE '%productivity dropped%'
           OR lower(intent_phrase) LIKE '%shame%'
           OR lower(intent_phrase) LIKE '%guilty%';
    """).fetchall()
    audit_reports["generic_or_shaming_phrases"] = [{"id": r[0], "intent_phrase": r[1]} for r in generic_res]

    # 6. Private data leaks (checking regexes for email, phone numbers, or private flag is true)
    private_res = conn.execute("""
        SELECT id, intent_phrase, private_data_flag 
        FROM goal_intents
        WHERE private_data_flag = true
           OR regexp_matches(intent_phrase, '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}')
           OR regexp_matches(intent_phrase, '\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b');
    """).fetchall()
    audit_reports["private_data_leaks"] = [
        {"id": r[0], "intent_phrase": r[1], "private_data_flag": r[2]} for r in private_res
    ]

    # 7. Coverage Gaps (domains with less than 5 intents)
    coverage_res = conn.execute("""
        SELECT d.code, d.title, COUNT(i.id) as intent_count
        FROM domains d
        LEFT JOIN goal_intents i ON d.code = i.domain
        GROUP BY d.code, d.title
        HAVING COUNT(i.id) < 5;
    """).fetchall()
    audit_reports["coverage_gaps"] = [
        {"domain_code": r[0], "domain_title": r[1], "intent_count": r[2]} for r in coverage_res
    ]
    
    conn.close()
    
    # Save validation reports in run directory
    report_file = run_dir / "reports" / "qa_audit_report.json"
    with report_file.open("w", encoding="utf-8") as f:
        json.dump(audit_reports, f, indent=2)
        
    # Save performance metrics
    duration = time.time() - start_time
    perf_file = run_dir / "reports" / "performance_report.json"
    perf_data = {}
    if perf_file.exists():
        try:
            with perf_file.open("r", encoding="utf-8") as pf:
                perf_data = json.load(pf)
        except Exception:
            pass
    perf_data["dedupe_duration_sec"] = duration
    with perf_file.open("w", encoding="utf-8") as pf:
        json.dump(perf_data, pf, indent=2)
        
    return audit_reports
