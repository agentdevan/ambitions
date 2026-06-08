import os
import subprocess
import hashlib
import tempfile
from pathlib import Path
from typing import Any, Dict, List
from dotenv import load_dotenv

def generate_wrangler_commands(run_dir: Path, bucket_name: str = "source-atlas-staged") -> List[Dict[str, str]]:
    """
    Generates a list of wrangler commands to run for staging files.
    """
    publish_dir = run_dir / "publish" / "factory" / "v1"
    run_id = run_dir.name
    
    files_to_upload = [
        ("goal-intent-index.jsonl", f"factory/v1/goal-intent-index.jsonl"),
        ("domain-index.json", f"factory/v1/domain-index.json"),
        ("alias-index.json", f"factory/v1/alias-index.json"),
        ("coverage-matrix.json", f"factory/v1/coverage-matrix.json"),
        ("staged-manifest.json", f"factory/v1/staged-manifest.json"),
        # Dev release pathing
        ("goal-intent-index.jsonl", f"factory/v1/releases/dev/{run_id}/goal-intent-index.jsonl"),
        ("staged-manifest.json", f"factory/v1/releases/dev/{run_id}/staged-manifest.json")
    ]
    
    commands = []
    for local_name, remote_key in files_to_upload:
        # Strict guardrail checks on keys and paths
        key_lower = remote_key.lower()
        if "current.json" in key_lower or "/packs/" in key_lower or "/seeds/" in key_lower:
            raise ValueError(f"Guardrail violation: Wrangler remote key '{remote_key}' is forbidden.")
            
        local_path = publish_dir / local_name
        if local_path.exists():
            cmd = f"wrangler r2 object put {bucket_name}/{remote_key} --file {local_path}"
            commands.append({
                "local_file": local_name,
                "remote_key": remote_key,
                "command": cmd
            })
            
    # Save a dry-run commands markdown report
    reports_dir = run_dir / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)
    report_file = reports_dir / "r2_dry_run_commands.md"
    
    report_lines = [
        "# R2 Wrangler Dry-Run Commands Preview",
        "",
        f"**Run ID**: `{run_id}`",
        f"**Target Bucket**: `{bucket_name}`",
        "",
        "## Generated Wrangler CLI Commands",
        ""
    ]
    for idx, c in enumerate(commands):
        report_lines.append(f"### [{idx+1}] Upload `{c['local_file']}`")
        report_lines.append(f"**Remote Key**: `{c['remote_key']}`")
        report_lines.append(f"```bash\n{c['command']}\n```")
        report_lines.append("")
        
    with report_file.open("w", encoding="utf-8") as f:
        f.write("\n".join(report_lines))
            
    return commands

def execute_r2_upload_mock(commands: List[Dict[str, str]]) -> Dict[str, Any]:
    """
    Simulates Wrangler R2 upload execution for Mock Mode.
    """
    uploaded_files = []
    for cmd in commands:
        uploaded_files.append({
            "local_file": cmd["local_file"],
            "remote_key": cmd["remote_key"],
            "status": "SUCCESS (MOCK)",
            "sha256": "verified_mock_sha"
        })
    return {
        "success": True,
        "details": uploaded_files
    }

def verify_integrity_mock(commands: List[Dict[str, str]], run_dir: Path) -> Dict[str, Any]:
    """
    Simulates verifying remote uploads by comparing hashes in mock mode.
    """
    publish_dir = run_dir / "publish" / "factory" / "v1"
    manifest_path = publish_dir / "staged-manifest.json"
    
    if not manifest_path.exists():
        return {"success": False, "error": "Manifest file not found."}
        
    with manifest_path.open("r", encoding="utf-8") as f:
        manifest = json.load(f)
        
    verification_results = []
    for local_name, hash_val in manifest.get("artifacts", {}).items():
        verification_results.append({
            "artifact": local_name,
            "expected_sha256": hash_val,
            "fetched_sha256": hash_val,
            "status": "PASS (MOCK)"
        })
        
    return {
        "success": True,
        "results": verification_results
    }

import json

def execute_wrangler_upload(commands: List[Dict[str, str]], bucket_name: str, mock: bool = True, user_confirmed: bool = False) -> Dict[str, Any]:
    """
    Executes actual wrangler commands if Wrangler is available on the path.
    Otherwise falls back to mock execution.
    """
    if not user_confirmed:
        return {
            "success": False,
            "error": "Real upload blocked: You must explicitly confirm that this dataset contains no personal user context."
        }
        
    if mock:
        return execute_r2_upload_mock(commands)
        
    load_dotenv()
    # Ensure wrangler is installed/available
    try:
        subprocess.run(["wrangler", "--version"], capture_output=True, check=True)
    except (subprocess.SubprocessError, FileNotFoundError):
        return {
            "success": False,
            "error": "Wrangler CLI not found on Path. Execute commands manually or verify wrangler setup."
        }
        
    details = []
    success = True
    
    for cmd in commands:
        try:
            # Execute command
            args = cmd["command"].split()
            # Replace backslashes in path for Windows-friendliness
            args = [a.replace("\\", "/") if "/" in a or "\\" in a else a for a in args]
            
            res = subprocess.run(args, capture_output=True, text=True, check=True)
            details.append({
                "local_file": cmd["local_file"],
                "remote_key": cmd["remote_key"],
                "status": "SUCCESS",
                "stdout": res.stdout
            })
        except subprocess.CalledProcessError as err:
            success = False
            details.append({
                "local_file": cmd["local_file"],
                "remote_key": cmd["remote_key"],
                "status": "FAILED",
                "error": err.stderr
            })
            
    return {
        "success": success,
        "details": details
    }

def verify_remote_integrity(commands: List[Dict[str, str]], run_dir: Path, bucket_name: str, mock: bool = True) -> Dict[str, Any]:
    """
    Verification downloads staged objects back from Cloudflare R2 using wrangler,
    calculates their SHA-256, and cross-references it with local staged manifest.
    """
    if mock:
        return verify_integrity_mock(commands, run_dir)
        
    publish_dir = run_dir / "publish" / "factory" / "v1"
    manifest_path = publish_dir / "staged-manifest.json"
    
    if not manifest_path.exists():
        return {"success": False, "error": "Local staged manifest not found."}
        
    with manifest_path.open("r", encoding="utf-8") as f:
        manifest = json.load(f)
        
    verification_results = []
    success = True
    
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        
        for local_name, expected_hash in manifest.get("artifacts", {}).items():
            # Find the remote key in command templates
            remote_key = None
            for cmd in commands:
                if cmd["local_file"] == local_name and "releases/dev" not in cmd["remote_key"]:
                    remote_key = cmd["remote_key"]
                    break
            
            if not remote_key:
                continue
                
            download_dest = tmp_path / local_name
            # Run: wrangler r2 object get bucket/key --file dest
            get_cmd = ["wrangler", "r2", "object", "get", f"{bucket_name}/{remote_key}", "--file", str(download_dest)]
            
            try:
                subprocess.run(get_cmd, capture_output=True, check=True)
                # Compute hash
                hasher = hashlib.sha256()
                with download_dest.open("rb") as f:
                    while chunk := f.read(8192):
                        hasher.update(chunk)
                fetched_hash = hasher.hexdigest()
                
                if fetched_hash == expected_hash:
                    status = "PASS"
                else:
                    status = "FAIL (HASH MISMATCH)"
                    success = False
                    
                verification_results.append({
                    "artifact": local_name,
                    "expected_sha256": expected_hash,
                    "fetched_sha256": fetched_hash,
                    "status": status
                })
            except Exception as e:
                success = False
                verification_results.append({
                    "artifact": local_name,
                    "expected_sha256": expected_hash,
                    "error": str(e),
                    "status": "FAIL (DOWNLOAD/API ERROR)"
                })
                
    return {
        "success": success,
        "results": verification_results
    }

