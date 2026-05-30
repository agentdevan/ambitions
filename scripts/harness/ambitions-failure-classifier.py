#!/usr/bin/env python3
from __future__ import annotations
import argparse, json
from pathlib import Path
RULES = [
    ("build_tooling_failure", ["build exit", "xcodebuild", "exit 65"]),
    ("artifact_hygiene_failure", ["build/reports", "generated residue"]),
    ("claim_drift", ["release ready", "app store ready", "testflight ready"]),
    ("product_canon_drift", ["next best move", "top-level plan"]),
    ("app_driving_proof_failure", ["app-driving", "proof-mode"]),
]
def classify(text: str):
    lower = text.lower()
    for name, needles in RULES:
        if any(n in lower for n in needles):
            return name
    return "unclassified_yellow"
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()
    text = Path(args.path).read_text(encoding="utf-8", errors="ignore")
    cls = classify(text)
    payload = {"status": "Yellow", "failure_class": cls, "next_repair_action": f"Open a bounded repair issue for {cls}.", "claims_not_made": ["No release readiness claim"]}
    print(json.dumps(payload, indent=2) if args.json else payload)
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
