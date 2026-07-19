import json
import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Generator, List, Tuple
from pydantic import ValidationError
from schema import GoalIntentRecord, GrammarBank, SeedArchetype, SourceCandidate

def stable_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()

def stable_id(prefix: str, payload_str: str) -> str:
    return f"{prefix}.{stable_hash(payload_str)[:16]}"

def parse_raw_gemini_jsonl(file_path: Path) -> List[Tuple[str, Any]]:
    """
    Parses a raw Gemini Batch output JSONL.
    Returns a list of tuples: (custom_id, parsed_inner_json)
    """
    parsed_items = []
    if not file_path.exists():
        return parsed_items
        
    with file_path.open("r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            record = json.loads(line.strip())
            custom_id = record.get("custom_id", "unknown")
            
            # Extract the actual text output from Gemini response structure
            try:
                candidates = record["response"]["candidates"]
                text_content = candidates[0]["content"]["parts"][0]["text"]
                # Sometimes LLMs wrap JSON inside markdown code blocks
                if "```json" in text_content:
                    text_content = text_content.split("```json")[1].split("```")[0].strip()
                elif "```" in text_content:
                    text_content = text_content.split("```")[1].split("```")[0].strip()
                
                parsed_json = json.loads(text_content.strip())
                parsed_items.append((custom_id, parsed_json))
            except Exception as e:
                parsed_items.append((custom_id, {"error": f"Failed to parse Gemini JSON: {str(e)}", "raw_text": line}))
                
    return parsed_items

def validate_domain_intents(raw_items: List[Tuple[str, Any]], run_dir: Path) -> Dict[str, int]:
    """
    Validates goal intents directly output by Gemini and splits them into clean/rejected files.
    """
    clean_path = run_dir / "clean" / "domain_intents.jsonl"
    rejected_path = run_dir / "rejected" / "domain_intents.jsonl"
    
    clean_count = 0
    rejected_count = 0
    
    clean_file = clean_path.open("w", encoding="utf-8")
    rejected_file = rejected_path.open("w", encoding="utf-8")
    
    try:
        for custom_id, payload in raw_items:
            # Payload can be a list of intent objects or a single dict
            items_to_validate = payload if isinstance(payload, list) else [payload]
            
            for item in items_to_validate:
                if "error" in item:
                    rejected_file.write(json.dumps({"custom_id": custom_id, **item}) + "\n")
                    rejected_count += 1
                    continue
                
                try:
                    # Provide missing fields if any
                    record_dict = {
                        "id": item.get("id") or stable_id("intent", f"{item.get('domain')}_{item.get('intent_phrase')}"),
                        "domain": item.get("domain", "unknown"),
                        "category": item.get("category", "general"),
                        "intent_phrase": item.get("intent_phrase", ""),
                        "runtime_eligible": item.get("runtime_eligible", False),
                        "runtime_role": item.get("runtime_role", "intent_matching_only"),
                        "blocked_for_step_generation": item.get("blocked_for_step_generation", True),
                        "evidence_quality": item.get("evidence_quality", "generated_only"),
                        "source_freshness": item.get("source_freshness", "current"),
                        "risk_level": item.get("risk_level", "ordinary"),
                        "private_data_flag": item.get("private_data_flag", False),
                        "created_at": item.get("created_at") or datetime.now(timezone.utc).isoformat()
                    }
                    
                    # Validate against Pydantic schema
                    validated_record = GoalIntentRecord(**record_dict)
                    clean_file.write(validated_record.model_dump_json() + "\n")
                    clean_count += 1
                except ValidationError as ve:
                    rejected_file.write(json.dumps({
                        "custom_id": custom_id,
                        "raw_item": item,
                        "validation_errors": json.loads(ve.json())
                    }) + "\n")
                    rejected_count += 1
                except Exception as ex:
                    rejected_file.write(json.dumps({
                        "custom_id": custom_id,
                        "raw_item": item,
                        "error": str(ex)
                    }) + "\n")
                    rejected_count += 1
    finally:
        clean_file.close()
        rejected_file.close()
        
    return {"clean": clean_count, "rejected": rejected_count}

def expand_grammar_bank(bank: GrammarBank) -> Generator[Dict[str, Any], None, None]:
    """
    Generates all combinations of templates and vocabulary list from a GrammarBank.
    """
    for template in bank.templates:
        # Find all placeholders inside brackets
        placeholders = re.findall(r"\[([a-zA-Z0-9_-]+)\]", template)
        if not placeholders:
            # No placeholders, just yield the template
            payload_str = f"{bank.domain}_{bank.category}_{template}"
            yield {
                "id": stable_id("intent_grammar", payload_str),
                "domain": bank.domain,
                "category": bank.category,
                "intent_phrase": template,
                "runtime_eligible": True,
                "runtime_role": "intent_matching_only",
                "blocked_for_step_generation": True,
                "evidence_quality": "generated_only",
                "source_freshness": "current",
                "risk_level": "ordinary",
                "private_data_flag": False
            }
            continue
            
        # Helper recursive function to expand placeholders
        def resolve_combinations(temp: str, phs: List[str]) -> Generator[str, None, None]:
            if not phs:
                yield temp
                return
            current_ph = phs[0]
            remaining_phs = phs[1:]
            for val in bank.vocab.get(current_ph, []):
                replaced = temp.replace(f"[{current_ph}]", val)
                yield from resolve_combinations(replaced, remaining_phs)
                
        for phrase in resolve_combinations(template, placeholders):
            payload_str = f"{bank.domain}_{bank.category}_{phrase}"
            yield {
                "id": stable_id("intent_grammar", payload_str),
                "domain": bank.domain,
                "category": bank.category,
                "intent_phrase": phrase,
                "runtime_eligible": True,
                "runtime_role": "intent_matching_only",
                "blocked_for_step_generation": True,
                "evidence_quality": "generated_only",
                "source_freshness": "current",
                "risk_level": "ordinary",
                "private_data_flag": False
            }

import re

def process_grammar_expansion(raw_grammar_banks: List[Tuple[str, Any]], run_dir: Path, target_limit: int = 1000000) -> Dict[str, int]:
    """
    Validates GrammarBank definitions, expands templates combinatorially, and writes clean intent records.
    """
    clean_path = run_dir / "clean" / "grammar_intents.jsonl"
    rejected_path = run_dir / "rejected" / "grammar_banks.jsonl"
    
    clean_count = 0
    rejected_count = 0
    
    clean_file = clean_path.open("w", encoding="utf-8")
    rejected_file = rejected_path.open("w", encoding="utf-8")
    
    try:
        for custom_id, payload in raw_grammar_banks:
            if "error" in payload:
                rejected_file.write(json.dumps({"custom_id": custom_id, **payload}) + "\n")
                rejected_count += 1
                continue
                
            try:
                # Validate the grammar bank definition itself
                bank = GrammarBank(**payload)
                
                # Expand combinations deterministically
                for item in expand_grammar_bank(bank):
                    if clean_count >= target_limit:
                        break
                    # Validate the generated goal intent record
                    validated_record = GoalIntentRecord(**item)
                    clean_file.write(validated_record.model_dump_json() + "\n")
                    clean_count += 1
                    
            except ValidationError as ve:
                rejected_file.write(json.dumps({
                    "custom_id": custom_id,
                    "raw_payload": payload,
                    "validation_errors": json.loads(ve.json())
                }) + "\n")
                rejected_count += 1
            except Exception as ex:
                rejected_file.write(json.dumps({
                    "custom_id": custom_id,
                    "raw_payload": payload,
                    "error": str(ex)
                }) + "\n")
                rejected_count += 1
    finally:
        clean_file.close()
        rejected_file.close()
        
    return {"clean_grammar_expanded": clean_count, "rejected_grammar_banks": rejected_count}

import time

def validate_all_shards(run_dir: Path) -> Dict[str, Any]:
    """
    Finds and parses all results_*.jsonl files under raw/,
    validates each intent record, writes them to clean/domain_intents.jsonl,
    and logs performance metrics.
    """
    start_time = time.time()
    raw_dir = run_dir / "raw"
    clean_dir = run_dir / "clean"
    rejected_dir = run_dir / "rejected"
    
    clean_count = 0
    rejected_count = 0
    
    clean_path = clean_dir / "domain_intents.jsonl"
    rejected_path = rejected_dir / "domain_intents.jsonl"
    
    clean_file = clean_path.open("w", encoding="utf-8")
    rejected_file = rejected_path.open("w", encoding="utf-8")
    
    try:
        # Find all raw result files
        raw_files = list(raw_dir.glob("results_*.jsonl"))
        
        for rf in raw_files:
            parsed = parse_raw_gemini_jsonl(rf)
            for custom_id, payload in parsed:
                items = payload if isinstance(payload, list) else [payload]
                for item in items:
                    if not item:
                        continue
                    if "error" in item:
                        rejected_file.write(json.dumps({"custom_id": custom_id, **item}) + "\n")
                        rejected_count += 1
                        continue
                    try:
                        record_dict = {
                            "id": item.get("id") or stable_id("intent", f"{item.get('domain')}_{item.get('intent_phrase')}"),
                            "domain": item.get("domain", "unknown"),
                            "category": item.get("category", "general"),
                            "intent_phrase": item.get("intent_phrase", ""),
                            "runtime_eligible": item.get("runtime_eligible", False),
                            "runtime_role": item.get("runtime_role", "intent_matching_only"),
                            "blocked_for_step_generation": item.get("blocked_for_step_generation", True),
                            "evidence_quality": item.get("evidence_quality", "generated_only"),
                            "source_freshness": item.get("source_freshness", "current"),
                            "risk_level": item.get("risk_level", "ordinary"),
                            "private_data_flag": item.get("private_data_flag", False),
                            "created_at": item.get("created_at") or datetime.now(timezone.utc).isoformat()
                        }
                        
                        # Validate against schema
                        validated = GoalIntentRecord(**record_dict)
                        clean_file.write(validated.model_dump_json() + "\n")
                        clean_count += 1
                    except ValidationError as ve:
                        rejected_file.write(json.dumps({
                            "custom_id": custom_id,
                            "raw_item": item,
                            "validation_errors": json.loads(ve.json())
                        }) + "\n")
                        rejected_count += 1
                    except Exception as ex:
                        rejected_file.write(json.dumps({
                            "custom_id": custom_id,
                            "raw_item": item,
                            "error": str(ex)
                        }) + "\n")
                        rejected_count += 1
    finally:
        clean_file.close()
        rejected_file.close()
        
    duration = time.time() - start_time
    
    # Save to performance report
    perf_file = run_dir / "reports" / "performance_report.json"
    perf_data = {}
    if perf_file.exists():
        try:
            with perf_file.open("r", encoding="utf-8") as pf:
                perf_data = json.load(pf)
        except Exception:
            pass
    perf_data["validation_duration_sec"] = duration
    with perf_file.open("w", encoding="utf-8") as pf:
        json.dump(perf_data, pf, indent=2)
        
    return {"clean": clean_count, "rejected": rejected_count, "validation_duration_sec": duration}

