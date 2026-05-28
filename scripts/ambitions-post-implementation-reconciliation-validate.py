#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROTOCOL = ROOT / "docs/ops/change-protocol/post-implementation-proof-reconciliation.md"

REQUIRED_STRINGS = [
    "Post-Implementation Proof and Linear Reconciliation",
    "Implementation is not complete when code lands.",
    "Run the required validation/proof commands.",
    "Save exact proof artifacts.",
    "Green",
    "Accepted Yellow",
    "Red",
    "Partial",
    "Source-only implementation is never complete.",
    "Batch ledger update rules",
    "Source-of-truth tag update rules",
    "Linear reconciliation rules",
    "Follow-up issue policy for unresolved Red/Yellow items",
    "Required reconciliation artifact",
    "Rollback and failure behavior",
    "No-claim boundary",
    "docs/ops/change-protocol/reconciliation/<issue-or-batch-id>.md",
    "make batch-ledger-inventory",
    "make batch-ledger-detect-touchpoints",
    "make batch-ledger-classify-status",
    "make batch-ledger-conflict-report",
    "make post-implementation-reconciliation-validate",
    "Linear status is not repo truth.",
    "AMB-38 Green criteria",
]

FORBIDDEN_STRINGS = [
    "production-ready",
    "release-ready",
    "fully validated",
    "fully tested",
]

def main() -> int:
    if not PROTOCOL.exists():
        print(f"Missing protocol: {PROTOCOL.relative_to(ROOT)}")
        return 1

    text = PROTOCOL.read_text(encoding="utf-8")
    missing = [item for item in REQUIRED_STRINGS if item not in text]
    forbidden = [item for item in FORBIDDEN_STRINGS if item in text]

    if missing or forbidden:
        print("AMB-38 post-implementation reconciliation validation failed.")
        if missing:
            print("Missing:")
            for item in missing:
                print(f"- {item}")
        if forbidden:
            print("Forbidden:")
            for item in forbidden:
                print(f"- {item}")
        return 1

    print("AMB-38 post-implementation reconciliation validation passed")
    print(f"protocol: {PROTOCOL.relative_to(ROOT)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
