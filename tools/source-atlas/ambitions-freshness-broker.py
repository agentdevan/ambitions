#!/usr/bin/env python3
"""Build Freshness Broker Manifest from Source Atlas diff outputs."""

import argparse
import datetime
import json
import sys
from pathlib import Path

STATE_BUCKET_ORDER = (
    "unknown",
    "source_needed",
    "stale",
    "contradicted",
    "revoked",
    "locally_proven",
)

STATE_FLAG_ALIASES = {
    "source_needed": ("source_needed", "sourceNeeded"),
    "locally_proven": ("locally_proven", "locallyProven"),
}


def _unique_claim_ids(values: object) -> list[str]:
    if not isinstance(values, list):
        return []

    unique_values: list[str] = []
    for value in values:
        if isinstance(value, str) and value not in unique_values:
            unique_values.append(value)
    return unique_values


def _build_state_buckets(flags: dict) -> list[dict]:
    buckets = []
    for state in STATE_BUCKET_ORDER:
        claim_ids = []
        for flag_name in STATE_FLAG_ALIASES.get(state, (state,)):
            for claim_id in _unique_claim_ids(flags.get(flag_name, [])):
                if claim_id not in claim_ids:
                    claim_ids.append(claim_id)
        if claim_ids:
            buckets.append({
                "state": state,
                "claimIDs": claim_ids,
            })
    return buckets


def build_manifest(version_id: str, diff_files: list[Path]) -> dict:
    pack_index = []
    global_state_buckets: dict[str, list[str]] = {}
    
    for df in diff_files:
        if not df.exists():
            continue
            
        data = json.loads(df.read_text())
        pack_id = data.get("packID", "unknown_pack")
        flags = data.get("flags", {})
        if not isinstance(flags, dict):
            flags = {}
        claim_state_buckets = _build_state_buckets(flags)

        for bucket in claim_state_buckets:
            state = bucket["state"]
            claim_ids = global_state_buckets.setdefault(state, [])
            for claim_id in bucket["claimIDs"]:
                if claim_id not in claim_ids:
                    claim_ids.append(claim_id)
        
        entry = {
            "packID": pack_id,
            "currentSHA256": data.get("currentSHA256", ""),
            "currentSignature": data.get("currentSignature", ""),
            "rollbackPointers": data.get("rollbackPointers", {}),
            "changedClaimIDs": data.get("changedClaimIDs", []),
            "claimStateBuckets": claim_state_buckets,
        }
        pack_index.append(entry)

    global_claim_state_buckets = [
        {
            "state": state,
            "claimIDs": global_state_buckets[state],
        }
        for state in STATE_BUCKET_ORDER
        if state in global_state_buckets
    ]

    return {
        "schemaVersion": 1,
        "versionID": version_id,
        "publishedAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z"),
        "packIndex": pack_index,
        "globalClaimStateBuckets": global_claim_state_buckets,
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
