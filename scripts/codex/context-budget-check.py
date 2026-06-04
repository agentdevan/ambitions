import os
import sys

def parse_simple_yaml(filepath):
    # Extremely simple line-based parser for our manifest format
    result = {}
    current_key = None
    if not os.path.exists(filepath):
        return result
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if line.endswith(':'):
                current_key = line[:-1]
                result[current_key] = []
            elif line.startswith('-') and current_key:
                val = line[1:].strip().strip('"').strip("'")
                result[current_key].append(val)
    return result

def get_file_size(filepath):
    if os.path.exists(filepath):
        return os.path.getsize(filepath)
    return 0

def check_boilerplate_in_skills():
    skills_dir = ".agents/skills"
    if not os.path.exists(skills_dir):
        return []
        
    boilerplate_warnings = []
    
    # A simple check for overly long skills or repeated phrases could go here.
    # For now, we'll flag any skill over 5KB as a potential boilerplate candidate.
    for root, dirs, files in os.walk(skills_dir):
        for file in files:
            if file.endswith(".md"):
                path = os.path.join(root, file)
                size = get_file_size(path)
                if size > 5120:  # 5 KB
                    boilerplate_warnings.append(f"{path} is {size} bytes, check for duplicated boilerplate.")
                    
    return boilerplate_warnings

def main():
    manifest_path = "docs/codex/context-manifest.yml"
    manifest = parse_simple_yaml(manifest_path)
    
    status = "Green"
    messages = []
    
    # Check champion coverage classification
    cold_files = manifest.get("cold_generated_query_only", [])
    if "docs/codex/existing-code-champion-coverage.yml" not in cold_files:
        status = "Red"
        messages.append("[RED] docs/codex/existing-code-champion-coverage.yml is not classified as cold_generated_query_only!")
        
    # Check hot context
    hot_files = manifest.get("hot_always_safe", [])
    for hf in hot_files:
        if "archive" in hf:
            status = "Red"
            messages.append(f"[RED] Archive path {hf} classified as hot_always_safe!")
        
        size = get_file_size(hf)
        if size > 65536: # 64 KB
            status = "Red"
            messages.append(f"[RED] Hot file {hf} exceeds 64 KB limit ({size} bytes).")
        elif size > 32768: # 32 KB
            if status == "Green": status = "Yellow"
            messages.append(f"[YELLOW] Hot file {hf} exceeds 32 KB warning threshold ({size} bytes).")
            
    # Check warm context
    warm_files = manifest.get("warm_on_demand", [])
    for wf in warm_files:
        size = get_file_size(wf)
        if size > 98304: # 96 KB
            if status == "Green": status = "Yellow"
            messages.append(f"[YELLOW] Warm file {wf} exceeds 96 KB warning threshold ({size} bytes).")
            
    # Check train ledger
    ledger_path = ".codex/state/global-train-attempt-ledger.md"
    ledger_size = get_file_size(ledger_path)
    if ledger_size > 65536: # 64 KB
        status = "Red"
        messages.append(f"[RED] Train ledger {ledger_path} exceeds 64 KB limit ({ledger_size} bytes). Rotate immediately.")
    elif ledger_size > 32768: # 32 KB
        if status == "Green": status = "Yellow"
        messages.append(f"[YELLOW] Train ledger {ledger_path} exceeds 32 KB warning threshold ({ledger_size} bytes).")
        
    # Check boilerplate
    bp_warnings = check_boilerplate_in_skills()
    if bp_warnings:
        if status == "Green": status = "Yellow"
        for bpw in bp_warnings:
            messages.append(f"[YELLOW] Boilerplate check: {bpw}")
            
    # Report
    print(f"Status: {status}")
    for msg in messages:
        print(msg)
        
    if status == "Red":
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__":
    main()
