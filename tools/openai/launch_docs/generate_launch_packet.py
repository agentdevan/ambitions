#!/usr/bin/env python3
"""Generate a local launch packet from docs/audits evidence files."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

PROOF_INDICATORS = {
    "proof": re.compile(r"\bproof\b", re.I),
    "validated": re.compile(r"passed|evidence|log|validated", re.I),
}
RISKY_CLAIMS = {
    "release_ready": re.compile(r"release\s+ready|testflight|app\s*store|device\s*verified|accessibility\s+verified", re.I),
}


def scan_reports(root: Path) -> tuple[list[str], list[str]]:
    claims = []
    missing_proof = []

    audit_dir = root / "docs" / "audits"
    if not audit_dir.exists():
        return claims, ["docs/audits not present"]

    for path in sorted(audit_dir.glob("*.md")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        lines = text.splitlines()
        proof_lines = [line.strip() for line in lines if PROOF_INDICATORS["proof"].search(line)]
        if proof_lines:
            claims.append(f"{path.name}: {proof_lines[:2]}")

        for key, pattern in RISKY_CLAIMS.items():
            if pattern.search(text):
                missing_proof.append(f"{path.name}: risky claim '{key}' requires explicit proof packet")

    return claims, missing_proof


def build_packet(root: Path, include_drafts: bool) -> dict:
    claims, missing = scan_reports(root)
    packet = {
        "status": "green" if not missing else "yellow",
        "source_reports": len(list((root / "docs" / "audits").glob("*.md"))) if (root / "docs" / "audits").exists() else 0,
        "proof_claims": claims,
        "missing_proof": missing,
        "no_readiness_claims": True,
    }
    if include_drafts:
        packet["draft_text"] = (
            "Launch packet draft is evidence-first only. Readiness claims are deferred until explicit proof exists."
        )
    return packet


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate launch packet draft")
    parser.add_argument("--root", default=str(Path(__file__).resolve().parents[3]), help="Repo root")
    parser.add_argument("--dry-run", action="store_true", help="Dry run only")
    args = parser.parse_args()

    packet = build_packet(Path(args.root).resolve(), include_drafts=args.dry_run)
    print(json.dumps(packet, indent=2))
    if packet["missing_proof"]:
        print("YELLOW: missing proof for one or more claim classes")
        return 0
    print("GREEN: no missing proof blockers found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
