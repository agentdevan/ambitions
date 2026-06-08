import json
import uuid
from pathlib import Path

def generate_sample_data():
    output_dir = Path(__file__).parent
    output_file = output_dir / "sample_raw_run.jsonl"
    
    rows = []
    
    # 1. 70 Domain Intents
    domains = ["finance", "health", "career", "mindfulness"]
    verbs = ["Save", "Improve", "Learn", "Meditate", "Read", "Establish", "Reduce", "Exercise"]
    nouns = ["money", "cardio performance", "Python programming", "for 10 minutes", "industry books", "budgeting template", "credit card debt", "three times a week"]
    
    for i in range(70):
        domain = domains[i % len(domains)]
        verb = verbs[i % len(verbs)]
        noun = nouns[i % len(nouns)]
        
        intent_phrase = f"{verb} {noun} (Sample {i+1})"
        
        # Include some records that validate properly
        record_content = [
            {
                "id": f"intent_sample_{domain}_{i}",
                "domain": domain,
                "category": "general",
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
        
        # Introduce a few records with safety/validation errors to test the validator's rejection capabilities
        if i == 5:
            # Violation: runtime_eligible but wrong runtime_role
            record_content[0]["runtime_role"] = "step_generation"
            record_content[0]["runtime_eligible"] = True
        elif i == 15:
            # Violation: shaming language
            record_content[0]["intent_phrase"] = "shame myself because productivity dropped"
        elif i == 25:
            # Violation: private PII
            record_content[0]["intent_phrase"] = "Send email to john.doe@example.com about budget"
            record_content[0]["private_data_flag"] = False # will trigger validation error due to mismatch
        
        row = {
            "custom_id": f"req_domain_{domain}_{i}",
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
        rows.append(row)
        
    # 2. 10 Seed Archetypes
    for i in range(10):
        domain = domains[i % len(domains)]
        seed_content = [
            {
                "id": f"seed_sample_{domain}_{i}",
                "title": f"Seed Title {i+1}",
                "domain": domain,
                "category": "core",
                "intent_phrase": f"Establish {domain} seed guideline {i+1}",
                "evidence_quality": "seed_archetype",
                "source_freshness": "current",
                "risk_level": "ordinary"
            }
        ]
        row = {
            "custom_id": f"req_seeds_{domain}_{i}",
            "response": {
                "status": "COMPLETED",
                "candidates": [
                    {
                        "content": {
                            "parts": [
                                {
                                    "text": json.dumps(seed_content)
                                }
                            ]
                        }
                    }
                ]
            }
        }
        rows.append(row)
        
    # 3. 10 Grammar Banks
    for i in range(10):
        domain = domains[i % len(domains)]
        grammar_content = {
            "domain": domain,
            "category": "skills",
            "templates": [
                f"Practice [{domain}_skill_{i}] for [duration] every week"
            ],
            "vocab": {
                f"{domain}_skill_{i}": ["coding", "meditating", "running", "cooking"],
                "duration": ["1 hour", "2 hours"]
            }
        }
        row = {
            "custom_id": f"req_grammar_{domain}_{i}",
            "response": {
                "status": "COMPLETED",
                "candidates": [
                    {
                        "content": {
                            "parts": [
                                {
                                    "text": json.dumps(grammar_content)
                                }
                            ]
                        }
                    }
                ]
            }
        }
        rows.append(row)
        
    # 4. 10 Source Candidates
    for i in range(10):
        domain = domains[i % len(domains)]
        source_content = {
            "id": f"source_sample_{domain}_{i}",
            "url": f"https://example.com/sources/{domain}/{i}",
            "title": f"Source Guide Book {i+1}",
            "domain": domain,
            "category": "guides",
            "extracted_intents": [
                f"Read chapter {i+1} on {domain} planning"
            ]
        }
        row = {
            "custom_id": f"req_sources_{domain}_{i}",
            "response": {
                "status": "COMPLETED",
                "candidates": [
                    {
                        "content": {
                            "parts": [
                                {
                                    "text": json.dumps(source_content)
                                }
                            ]
                        }
                    }
                ]
            }
        }
        rows.append(row)
        
    with open(output_file, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r) + "\n")
            
if __name__ == "__main__":
    generate_sample_data()
