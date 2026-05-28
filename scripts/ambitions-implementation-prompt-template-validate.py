#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "docs/ops/change-protocol/implementation-prompt-template.md"

REQUIRED_STRINGS = [
    "Source-of-truth tags",
    "Canon files to read first",
    "Scope",
    "Affected ledger items",
    "Conflicts to retire, update, merge, rewrite, expedite, or finish first",
    "Required source changes",
    "Required proof artifacts",
    "Linear project/issue links",
    "Rollback and failure behavior",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/ops/change-protocol/change-request-template.md",
    "docs/ops/change-protocol/change-impact-check.md",
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/conflict-action-workflow.md",
    "make change-impact-check",
    "Linear status is not repo truth.",
    "No-claim boundary",
    "AMB-36 Green criteria",
]

FORBIDDEN_STRINGS = [
    "read repo lore",
    "broad repo lore as canon",
    "old chat history as authority",
    "production-ready",
    "release-ready",
    "fully validated",
    "fully tested",
]

def main() -> int:
    if not TEMPLATE.exists():
        print(f"Missing template: {TEMPLATE.relative_to(ROOT)}")
        return 1

    text = TEMPLATE.read_text(encoding="utf-8")
    missing = [item for item in REQUIRED_STRINGS if item not in text]
    forbidden = []

    for item in FORBIDDEN_STRINGS:
        if item in text and item not in {
            "broad repo lore as canon",
            "read repo lore",
        }:
            forbidden.append(item)

    # The template must explicitly reject broad repo lore, so check for the rejection phrase.
    if "Do not use broad repo lore as canon." not in text:
        missing.append("Do not use broad repo lore as canon.")

    if missing or forbidden:
        print("AMB-36 implementation prompt template validation failed.")
        if missing:
            print("Missing:")
            for item in missing:
                print(f"- {item}")
        if forbidden:
            print("Forbidden:")
            for item in forbidden:
                print(f"- {item}")
        return 1

    print("AMB-36 implementation prompt template validation passed")
    print(f"template: {TEMPLATE.relative_to(ROOT)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
