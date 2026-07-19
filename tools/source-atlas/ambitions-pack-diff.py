#!/usr/bin/env python3
"""Generate changed claim IDs, changelog, impacted requirements, and stale/revoked/disputed flags from two Source Atlas packs."""

import argparse
import json
import sys
from pathlib import Path

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("old_pack", type=Path, help="Old pack JSON file")
    parser.add_argument("new_pack", type=Path, help="New pack JSON file")
    args = parser.parse_args()

    for path in (args.old_pack, args.new_pack):
        if not path.exists():
            print(f"RED: missing pack file {path}", file=sys.stderr)
            return 1

    try:
        old_data = json.loads(args.old_pack.read_text())
        new_data = json.loads(args.new_pack.read_text())
    except json.JSONDecodeError as e:
        print(f"RED: invalid JSON {e}", file=sys.stderr)
        return 1

    old_claims = {c["id"]: c for c in old_data.get("claims", [])}
    new_claims = {c["id"]: c for c in new_data.get("claims", [])}

    old_requirements = {r["id"]: r for r in old_data.get("requirements", [])}
    new_requirements = {r["id"]: r for r in new_data.get("requirements", [])}

    changed_claim_ids = []
    changelog = []
    stale_flags = []
    revoked_flags = []
    disputed_flags = []
    unknown_flags = []
    source_needed_flags = []
    contradicted_flags = []
    locally_proven_flags = []
    
    for c_id, new_c in new_claims.items():
        old_c = old_claims.get(c_id)
        
        state = new_c.get("state", "unknown")
        freshness = new_c.get("freshness", "unknown")
        
        # Explicit states representation: unknown, source-needed, stale, contradicted, revoked, locally proven
        if state == "stale" or freshness in ("stale", "stale_critical"):
            stale_flags.append(c_id)
        if state == "revoked":
            revoked_flags.append(c_id)
        if state == "disputed":
            disputed_flags.append(c_id)
        if state == "unknown" or freshness == "unknown":
            unknown_flags.append(c_id)
        if state == "source_needed":
            source_needed_flags.append(c_id)
        if state == "contradicted":
            contradicted_flags.append(c_id)
        if state == "verified_by_local_proof":
            locally_proven_flags.append(c_id)
            
        if not old_c:
            changed_claim_ids.append(c_id)
            changelog.append({
                "claimID": c_id,
                "changeType": "added",
                "newState": state,
                "newFreshness": freshness
            })
        else:
            old_state = old_c.get("state", "unknown")
            old_freshness = old_c.get("freshness", "unknown")
            
            # Simple deep comparison on values
            state_changed = old_state != state or old_freshness != freshness
            data_changed = old_c.get("text") != new_c.get("text") or set(old_c.get("sourceIDs", [])) != set(new_c.get("sourceIDs", []))
            
            if state_changed or data_changed:
                changed_claim_ids.append(c_id)
                changelog.append({
                    "claimID": c_id,
                    "changeType": "modified",
                    "oldState": old_state,
                    "newState": state,
                    "oldFreshness": old_freshness,
                    "newFreshness": freshness
                })

    for c_id in old_claims:
        if c_id not in new_claims:
            changed_claim_ids.append(c_id)
            changelog.append({
                "claimID": c_id,
                "changeType": "removed"
            })

    changed_claim_set = set(changed_claim_ids)
    impacted_req_ids = []
    for r_id, new_r in new_requirements.items():
        if new_r.get("claimID") in changed_claim_set:
            impacted_req_ids.append(r_id)
            continue
        old_r = old_requirements.get(r_id)
        if not old_r:
            impacted_req_ids.append(r_id)
            continue
            
        # requirement-specific changes
        if old_r.get("sourceState") != new_r.get("sourceState") or old_r.get("freshnessState") != new_r.get("freshnessState") or old_r.get("reviewState") != new_r.get("reviewState"):
            impacted_req_ids.append(r_id)

    output = {
        "changedClaimIDs": sorted(changed_claim_ids),
        "impactedRequirementIDs": sorted(impacted_req_ids),
        "flags": {
            "stale": sorted(stale_flags),
            "revoked": sorted(revoked_flags),
            "disputed": sorted(disputed_flags),
            "unknown": sorted(unknown_flags),
            "sourceNeeded": sorted(source_needed_flags),
            "contradicted": sorted(contradicted_flags),
            "locallyProven": sorted(locally_proven_flags)
        },
        "changelog": changelog
    }

    print(json.dumps(output, indent=2))
    return 0

if __name__ == "__main__":
    sys.exit(main())
