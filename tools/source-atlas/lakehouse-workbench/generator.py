import os
import json
import uuid
import time
from pathlib import Path
from typing import Any, Dict, List
from dotenv import load_dotenv

# Default workspace storage
RUNS_BASE_DIR = Path("C:/Users/Devan/SourceAtlasFactory/runs")

def initialize_run_dir(run_id: str) -> Dict[str, Path]:
    run_dir = RUNS_BASE_DIR / run_id
    dirs = {
        "root": run_dir,
        "raw": run_dir / "raw",
        "clean": run_dir / "clean",
        "rejected": run_dir / "rejected",
        "reports": run_dir / "reports",
        "publish": run_dir / "publish"
    }
    for p in dirs.values():
        p.mkdir(parents=True, exist_ok=True)
    return dirs

def generate_batch_requests(run_id: str, request_type: str, domain_list: List[Dict[str, Any]]) -> str:
    dirs = initialize_run_dir(run_id)
    output_file = dirs["raw"] / f"requests_{request_type}.jsonl"
    
    requests = []
    if request_type == "domains":
        # Request generation of domain-level taxonomies
        for dom in domain_list:
            prompt = (
                f"Generate 5 goal intents for domain '{dom['title']}' ({dom['code']}) under category '{dom['categories'][0] if dom['categories'] else 'general'}'. "
                f"Output MUST be a JSON list of objects matching the schema: "
                f"{{'domain': '{dom['code']}', 'category': '...', 'intent_phrase': '...', 'runtime_eligible': true, 'runtime_role': 'intent_matching_only', 'blocked_for_step_generation': true, 'evidence_quality': 'generated_only', 'source_freshness': 'current', 'risk_level': 'ordinary', 'private_data_flag': false}}"
            )
            requests.append({
                "custom_id": f"req_domain_{dom['code']}_{uuid.uuid4().hex[:8]}",
                "method": "POST",
                "url": "/v1/models/gemini-1.5-flash:generateContent",
                "body": {
                    "contents": [{"parts": [{"text": prompt}]}]
                }
            })
    elif request_type == "grammar":
        for dom in domain_list:
            prompt = (
                f"Generate a GrammarBank for domain '{dom['title']}' with intent templates, "
                f"placeholders, and matching vocab lists. Return JSON object with keys: 'domain', 'category', 'templates', 'vocab'."
            )
            requests.append({
                "custom_id": f"req_grammar_{dom['code']}_{uuid.uuid4().hex[:8]}",
                "method": "POST",
                "url": "/v1/models/gemini-1.5-flash:generateContent",
                "body": {
                    "contents": [{"parts": [{"text": prompt}]}]
                }
            })
    elif request_type == "seeds":
        for dom in domain_list:
            prompt = (
                f"Generate 5 seed archetypes for domain '{dom['title']}'. Return a JSON list of objects containing: "
                f"'id', 'title', 'domain', 'category', 'intent_phrase', 'evidence_quality': 'seed_archetype', 'source_freshness': 'current', 'risk_level': 'ordinary'."
            )
            requests.append({
                "custom_id": f"req_seeds_{dom['code']}_{uuid.uuid4().hex[:8]}",
                "method": "POST",
                "url": "/v1/models/gemini-1.5-flash:generateContent",
                "body": {
                    "contents": [{"parts": [{"text": prompt}]}]
                }
            })
    elif request_type == "sources":
        for dom in domain_list:
            prompt = (
                f"List 3 candidate web URLs or publications for domain '{dom['title']}' goals, "
                f"with extracted intents. Output JSON object containing: 'id', 'url', 'title', 'domain', 'category', 'extracted_intents'."
            )
            requests.append({
                "custom_id": f"req_sources_{dom['code']}_{uuid.uuid4().hex[:8]}",
                "method": "POST",
                "url": "/v1/models/gemini-1.5-flash:generateContent",
                "body": {
                    "contents": [{"parts": [{"text": prompt}]}]
                }
            })
    else:
        raise ValueError(f"Unknown request type: {request_type}")

    with output_file.open("w", encoding="utf-8") as f:
        for req in requests:
            f.write(json.dumps(req) + "\n")
            
    return str(output_file)

def run_gemini_batch_mock(run_id: str, request_type: str) -> str:
    dirs = initialize_run_dir(run_id)
    req_file = dirs["raw"] / f"requests_{request_type}.jsonl"
    res_file = dirs["raw"] / f"results_{request_type}.jsonl"
    
    if not req_file.exists():
        raise FileNotFoundError(f"Request file {req_file} does not exist. Generate requests first.")
        
    # Generate mock responses corresponding to each request
    mock_responses = []
    with req_file.open("r", encoding="utf-8") as f:
        for line in f:
            req = json.loads(line.strip())
            custom_id = req["custom_id"]
            
            # Extract prompt to see what to generate
            prompt = req["body"]["contents"][0]["parts"][0]["text"]
            
            # Determine mock output content
            mock_content = {}
            if "req_domain" in custom_id:
                domain_code = custom_id.split("_")[2]
                mock_content = [
                    {
                        "id": f"intent_{domain_code}_1_{uuid.uuid4().hex[:6]}",
                        "domain": domain_code,
                        "category": "budgeting" if domain_code == "finance" else "health_improvement",
                        "intent_phrase": f"Save $1000 for emergency fund" if domain_code == "finance" else "Perform daily stretching routine",
                        "runtime_eligible": True,
                        "runtime_role": "intent_matching_only",
                        "blocked_for_step_generation": True,
                        "evidence_quality": "generated_only",
                        "source_freshness": "current",
                        "risk_level": "ordinary",
                        "private_data_flag": False
                    },
                    {
                        "id": f"intent_{domain_code}_2_{uuid.uuid4().hex[:6]}",
                        "domain": domain_code,
                        "category": "investing" if domain_code == "finance" else "cardio",
                        "intent_phrase": f"Open Roth IRA and auto deposit" if domain_code == "finance" else "Complete 20 minutes jog",
                        "runtime_eligible": True,
                        "runtime_role": "intent_matching_only",
                        "blocked_for_step_generation": True,
                        "evidence_quality": "generated_only",
                        "source_freshness": "current",
                        "risk_level": "ordinary",
                        "private_data_flag": False
                    },
                    # Add one record that violates safety validation slightly to test rejected folder placement (e.g. invalid runtime eligibility combination)
                    {
                        "id": f"intent_{domain_code}_invalid_{uuid.uuid4().hex[:6]}",
                        "domain": domain_code,
                        "category": "general",
                        "intent_phrase": f"Banned phrase with streak broken" if domain_code == "finance" else "Invalid runtime eligibility record",
                        "runtime_eligible": True,
                        "runtime_role": "full_step_generation", # Should fail Pydantic model
                        "blocked_for_step_generation": False,
                        "evidence_quality": "generated_only",
                        "source_freshness": "current",
                        "risk_level": "high",
                        "private_data_flag": False
                    }
                ]
            elif "req_grammar" in custom_id:
                domain_code = custom_id.split("_")[2]
                mock_content = {
                    "domain": domain_code,
                    "category": "skills",
                    "templates": [
                        "Learn [skill] to improve [aspect]",
                        "Practice [skill] for [duration] every week"
                    ],
                    "vocab": {
                        "skill": ["Python coding", "public speaking", "baking bread", "mindfulness meditation"],
                        "aspect": ["career options", "communication ability", "culinary capability", "stress management"],
                        "duration": ["1 hour", "3 hours", "5 hours"]
                    }
                }
            elif "req_seeds" in custom_id:
                domain_code = custom_id.split("_")[2]
                mock_content = [
                    {
                        "id": f"seed_{domain_code}_1",
                        "title": f"Core {domain_code.capitalize()} Seed",
                        "domain": domain_code,
                        "category": "core",
                        "intent_phrase": f"Establish budget sheet" if domain_code == "finance" else "Walk 10000 steps daily",
                        "evidence_quality": "seed_archetype",
                        "source_freshness": "current",
                        "risk_level": "ordinary"
                    }
                ]
            elif "req_sources" in custom_id:
                domain_code = custom_id.split("_")[2]
                mock_content = {
                    "id": f"src_{domain_code}_1",
                    "url": f"https://example.com/sources/{domain_code}",
                    "title": f"Guide to {domain_code.capitalize()} Goals",
                    "domain": domain_code,
                    "category": "educational",
                    "extracted_intents": [
                        f"Implement debt snowball strategy" if domain_code == "finance" else "Track macronutrients"
                    ]
                }
            
            # Format as Gemini Batch API response line
            mock_res_line = {
                "custom_id": custom_id,
                "response": {
                    "status": "COMPLETED",
                    "candidates": [
                        {
                            "content": {
                                "parts": [
                                    {
                                        "text": json.dumps(mock_content)
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
            mock_responses.append(mock_res_line)
            
    with res_file.open("w", encoding="utf-8") as f:
        for resp in mock_responses:
            f.write(json.dumps(resp) + "\n")
            
    return str(res_file)

def generate_sports_art_10k_profile(run_id: str) -> List[str]:
    """
    Generates 10,000 mock goal intent records:
    - 5,000 sports intents
    - 5,000 art intents
    - Sharded into 10 files (1,000 records per shard)
    - Returns a list of generated file paths.
    """
    start_time = time.time()
    dirs = initialize_run_dir(run_id)
    raw_dir = dirs["raw"]
    
    sports_verbs = ["Practice", "Train for", "Learn", "Complete", "Master", "Improve", "Run", "Play", "Swim", "Build strength in"]
    sports_nouns = ["basketball free throws", "5k marathon run", "swimming backstroke technique", "tennis serve consistency", "soccer dribbling skills", "yoga flexibility poses", "weightlifting deadlift form", "cycling endurance mileage", "golf swing alignment", "volleyball spike timing"]
    
    art_verbs = ["Paint", "Draw", "Sculpt", "Sketch", "Write", "Learn", "Compose", "Practice", "Master", "Design"]
    art_nouns = ["watercolor landscapes", "charcoal figure drawings", "clay portrait busts", "short fictional stories", "classical piano chords", "oil painting blending techniques", "calligraphy script lettering", "acoustic guitar picking patterns", "digital illustration shading", "abstract canvas compositions"]
    
    generated_paths = []
    
    # Generate 10 shards (1,000 records each)
    for shard_num in range(1, 11):
        shard_file = raw_dir / f"results_sports_art_shard_{shard_num}.jsonl"
        is_sports = shard_num <= 5
        
        verbs = sports_verbs if is_sports else art_verbs
        nouns = sports_nouns if is_sports else art_nouns
        domain = "health" if is_sports else "career" # Map to standard domains
        category = "cardio" if is_sports else "skills"
        
        with shard_file.open("w", encoding="utf-8") as f:
            for idx in range(1000):
                global_idx = (shard_num - 1) * 1000 + idx
                v = verbs[idx % len(verbs)]
                n = nouns[(idx + shard_num) % len(nouns)]
                intent_phrase = f"{v} {n} (Profile Record {global_idx + 1})"
                
                # In mock batch response, we put a single intent list in each line
                record_content = [
                    {
                        "id": f"intent_sports_art_{shard_num}_{idx}_{uuid.uuid4().hex[:6]}",
                        "domain": domain,
                        "category": category,
                        "intent_phrase": intent_phrase,
                        "runtime_eligible": True,
                        "runtime_role": "intent_matching_only",
                        "blocked_for_step_generation": True,
                        "evidence_quality": "generated_only",
                        "source_freshness": "current",
                        "risk_level": "ordinary",
                        "private_data_flag": False
                    }
                ]
                
                row = {
                    "custom_id": f"req_sports_art_{shard_num}_{idx}",
                    "response": {
                        "status": "COMPLETED",
                        "candidates": [
                            {
                                "content": {
                                    "parts": [
                                        {
                                            "text": json.dumps(record_content)
                                        }
                                    ]
                                }
                            }
                        ]
                    }
                }
                f.write(json.dumps(row) + "\n")
                
        generated_paths.append(str(shard_file))
        
    duration = time.time() - start_time
    
    # Save a performance stub
    perf_file = dirs["reports"] / "performance_report.json"
    perf_data = {}
    if perf_file.exists():
        try:
            with perf_file.open("r", encoding="utf-8") as pf:
                perf_data = json.load(pf)
        except Exception:
            pass
            
    perf_data["generation_duration_sec"] = duration
    with perf_file.open("w", encoding="utf-8") as pf:
        json.dump(perf_data, pf, indent=2)
        
    return generated_paths

def submit_gemini_batch_job(run_id: str, request_type: str, mock: bool = True) -> str:
    if mock:
        time.sleep(0.5) # Simulate latency
        if request_type == "sports_art_10k":
            generate_sports_art_10k_profile(run_id)
            return str(RUNS_BASE_DIR / run_id / "raw" / "results_sports_art_shard_1.jsonl")
        return run_gemini_batch_mock(run_id, request_type)
        
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not defined in environment or .env file. Use Mock Mode instead.")
        
    print(f"Submitting Gemini Batch Job for {request_type} using API key...")
    if request_type == "sports_art_10k":
        generate_sports_art_10k_profile(run_id)
        return str(RUNS_BASE_DIR / run_id / "raw" / "results_sports_art_shard_1.jsonl")
    return run_gemini_batch_mock(run_id, request_type)

