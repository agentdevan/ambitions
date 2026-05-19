#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys

SCRIPTS = [
    "python3 scripts/ambitions_validate_prompt_headers.py",
    "python3 scripts/ambitions_validate_batch_ids.py",
    "python3 scripts/ambitions_validate_authority_drift.py",
    "python3 scripts/ambitions_validate_claim_registry.py",
    "python3 scripts/ambitions_validate_projection_contracts.py",
    "python3 scripts/ambitions_validate_runtime_authority.py",
    "python3 scripts/ambitions_validate_proof_receipts.py",
    "python3 scripts/ambitions_validate_visual_proof.py",
    "python3 scripts/ambitions_validate_accessibility_gates.py",
    "python3 scripts/ambitions_validate_trust_privacy.py",
    "python3 scripts/ambitions_validate_continuity_claims.py",
]


def run(cmd: str) -> tuple[int, str, str]:
    proc = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def main() -> int:
    all_ok = True
    statuses = []
    for cmd in SCRIPTS:
        rc, out, err = run(cmd)
        statuses.append((cmd, rc, out, err))
        if rc != 0:
            all_ok = False

    for cmd, rc, out, err in statuses:
        print(f"{cmd} -> {'PASS' if rc == 0 else 'FAIL'}")
        if rc != 0:
            if out:
                print(out)
            if err:
                print(err)

    if all_ok:
        print("GREEN")
        return 0
    print("RED")
    return 1


if __name__ == "__main__":
    import sys
    sys.exit(main())
