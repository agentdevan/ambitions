#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "docs/ops/change-protocol/change-request-template.md"

REQUIRED_STRINGS = [
    "Decision summary",
    "Source-of-truth tag affected",
    "Owning canon file",
    "Required canon edit",
    "Affected surfaces",
    "Affected systems",
    "Affected active batches / prompts / trains",
    "Required implementation prompt or batch",
    "Required proof",
    "Linear project and issue links",
    "make batch-ledger-conflict-report",
    "make batch-ledger-conflict-action-workflow-validate",
    "conflict checks before implementation work begins",
    "Linear status is not repo truth.",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json",
    "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml",
    "docs/ops/batch-ledger/batch-ledger.json",
    "docs/ops/batch-ledger/conflict-report.json",
    "docs/ops/batch-ledger/conflict-action-workflow.md",
    "No-claim boundary",
    "AMB-34 Green criteria",
]

FORBIDDEN_STRINGS = [
    "Plan tab",
    "Profile tab",
    "Captures tab",
    "Habits tab",
    "Insights tab",
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
    forbidden = [item for item in FORBIDDEN_STRINGS if item in text]

    if missing or forbidden:
        print("AMB-34 template validation failed.")
        if missing:
            print("Missing:")
            for item in missing:
                print(f"- {item}")
        if forbidden:
            print("Forbidden:")
            for item in forbidden:
                print(f"- {item}")
        return 1

    print("AMB-34 change request template validation passed")
    print(f"template: {TEMPLATE.relative_to(ROOT)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
