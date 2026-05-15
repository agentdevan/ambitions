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
        "explicit_states": explicit_states
    }

def check_revocation(pack_id: str, revocation_list: Path) -> bool:
    if not revocation_list.exists():
        return False
    data = json.loads(revocation_list.read_text())
    revoked_ids = data.get("revoked_pack_ids", [])
    return pack_id in revoked_ids

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["hash", "sign", "check-revoked"])
    parser.add_argument("--pack", type=Path, help="Path to pack JSON")
    parser.add_argument("--pack-id", type=str, help="Pack ID for revocation check")
    parser.add_argument("--revocation-list", type=Path, help="Path to revocation JSON list")
    
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
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
