#!/usr/bin/env python3
"""Hash, Signature, and Revocation tooling for Source Atlas packs."""

import argparse
import hashlib
import json
import sys
from pathlib import Path

def hash_pack(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def extract_explicit_states(pack_data: dict) -> list[str]:
    """Extract explicit states to ensure they do not collapse into a single confidence claim."""
    states = set()
    for claim in pack_data.get("claims", []):
        states.add(claim.get("state", "unknown"))
    return sorted(list(states))

def sign_pack(path: Path) -> dict:
    pack_data = json.loads(path.read_text())
    h = hash_pack(path)
    
    explicit_states = extract_explicit_states(pack_data)
    
    return {
        "sha256": h,
        "signature": f"mock-ed25519-{h[:12]}",
        "explicit_states": explicit_states,
        "rollback_pointer": pack_data.get("metadata", {}).get("last_known_good_hash", "none")
    }

def check_revocation(pack_id: str, revocation_list: Path) -> bool:
    if not revocation_list.exists():
        return False
    data = json.loads(revocation_list.read_text())
    revoked_ids = data.get("revoked_pack_ids", [])
    return pack_id in revoked_ids

def quarantine(path: Path, quarantine_dir: Path, reason: str):
    quarantine_dir.mkdir(parents=True, exist_ok=True)
    target = quarantine_dir / f"{path.name}.{reason}"
    # Use copy + unlink for better cross-filesystem safety on Windows if needed, 
    # but rename is fine for local temp tests.
    target.write_bytes(path.read_bytes())
    path.unlink()
    return target

def validate_pack(pack_path: Path, expected_hash: str = None, revocation_list: Path = None, quarantine_dir: Path = None) -> bool:
    if not pack_path.exists():
        return False
    
    # 1. Corrupt check
    try:
        pack_data = json.loads(pack_path.read_text())
    except Exception:
        if quarantine_dir:
            quarantine(pack_path, quarantine_dir, "corrupt")
        return False
    
    # 2. Hash check
    if expected_hash:
        actual_hash = hash_pack(pack_path)
        if actual_hash != expected_hash:
            if quarantine_dir:
                quarantine(pack_path, quarantine_dir, "hash_mismatch")
            return False
            
    # 3. Revocation check
    pack_id = pack_data.get("id")
    if pack_id and revocation_list and check_revocation(pack_id, revocation_list):
        if quarantine_dir:
            quarantine(pack_path, quarantine_dir, "revoked")
        return False
        
    return True

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["hash", "sign", "check-revoked", "validate"])
    parser.add_argument("--pack", type=Path, help="Path to pack JSON")
    parser.add_argument("--pack-id", type=str, help="Pack ID for revocation check")
    parser.add_argument("--revocation-list", type=Path, help="Path to revocation JSON list")
    parser.add_argument("--expected-hash", type=str, help="Expected SHA-256 for validation")
    parser.add_argument("--quarantine-dir", type=Path, help="Directory to move failed packs")
    
    args = parser.parse_args()
    
    if args.action == "hash":
        if not args.pack or not args.pack.exists():
            print("RED: Missing --pack", file=sys.stderr)
            return 1
        print(hash_pack(args.pack))
        
    elif args.action == "sign":
        if not args.pack or not args.pack.exists():
            print("RED: Missing --pack", file=sys.stderr)
            return 1
        print(json.dumps(sign_pack(args.pack), indent=2))
        
    elif args.action == "check-revoked":
        if not args.pack_id or not args.revocation_list:
            print("RED: Missing --pack-id or --revocation-list", file=sys.stderr)
            return 1
        if check_revocation(args.pack_id, args.revocation_list):
            print("REVOKED")
            return 1
        print("OK")

    elif args.action == "validate":
        if not args.pack:
            print("RED: Missing --pack", file=sys.stderr)
            return 1
        if validate_pack(args.pack, args.expected_hash, args.revocation_list, args.quarantine_dir):
            print("VALID")
            return 0
        else:
            print("INVALID")
            return 1
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
