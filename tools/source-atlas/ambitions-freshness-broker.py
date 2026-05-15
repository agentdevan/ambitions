#!/usr/bin/env python3
"""Build Freshness Broker Manifest from Source Atlas diff outputs."""

import argparse
import datetime
import json
import sys
from pathlib import Path

def build_manifest(version_id: str, diff_files: list[Path]) -> dict:
    pack_index = []
    global_revoked = set()
    global_stale = set()
    
    for df in diff_files:
        if not df.exists():
            continue
            
        data = json.loads(df.read_text())
        pack_id = data.get("packID", "unknown_pack")
        flags = data.get("flags", {})
        
        stale = flags.get("stale", [])
        revoked = flags.get("revoked", [])
        
        global_stale.update(stale)
        global_revoked.update(revoked)
        
        entry = {
            "packID": pack_id,
            "currentSHA256": data.get("currentSHA256", ""),
            "currentSignature": data.get("currentSignature", ""),
            "rollbackPointers": data.get("rollbackPointers", {}),
            "changedClaimIDs": data.get("changedClaimIDs", []),
            "staleClaimIDs": stale,
            "revokedClaimIDs": revoked
        }
        pack_index.append(entry)

    return {
        "schemaVersion": 1,
        "versionID": version_id,
        "publishedAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z"),
        "packIndex": pack_index,
        "globalRevocationList": sorted(list(global_revoked)),
        "globalStaleClaims": sorted(list(global_stale))
    }

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version-id", required=True, help="Version ID for the freshness manifest")
    parser.add_argument("--diff-files", nargs="+", type=Path, default=[], help="List of diff JSON files from SA28 tooling")
    parser.add_argument("--output", type=Path, help="Output manifest JSON path")
    
    args = parser.parse_args()
    
    manifest = build_manifest(args.version_id, args.diff_files)
    out_json = json.dumps(manifest, indent=2)
    
    if args.output:
        args.output.write_text(out_json)
        print(f"Wrote freshness manifest to {args.output}")
    else:
        print(out_json)
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
