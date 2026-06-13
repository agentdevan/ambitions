#!/usr/bin/env python3
"""Validate AMB-973 Source Atlas R2 staging artifacts without network writes."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
R2_DIR = ROOT / "artifacts" / "source-atlas-factory" / "r2"

REQUIRED_FILES = [
    R2_DIR / "R2_STAGING_ACTIVATION_REPORT.md",
    R2_DIR / "R2_CANARY_OBJECT_RECEIPT.md",
    R2_DIR / "R2_NO_PRIVATE_DATA_AUDIT.md",
    R2_DIR / "R2_RELEASE_RECEIPT_TEMPLATE.md",
    R2_DIR / "R2_ROLLBACK_RECEIPT_TEMPLATE.md",
    R2_DIR / "R2_CONNECTOR_CAPABILITY_AUDIT.md",
]

REQUIRED_PHRASES = [
    "AMB-973",
    "ambitions-source-atlas-staging",
    "contains_private_user_data",
    "contains_secret_material",
    "runtime_eligible",
    "runtime_consumption_claimed",
    "production_readiness_claimed",
    "rollback",
    "release receipt",
    "Cloudflare API error: 200",
]

SECRET_PATTERNS = [
    re.compile(r"sk-[A-Za-z0-9_-]{12,}"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    re.compile(r"(?i)(?:api[_-]?key|secret|token|access[_-]?key)\s*[:=]\s*['\"]?[A-Za-z0-9_./+=-]{16,}"),
    re.compile(r"(?i)bearer\s+[A-Za-z0-9_./+=-]{16,}"),
]

PRIVATE_CONTACT_PATTERNS = [
    re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
    re.compile(r"\b\+?1?[-. (]*\d{3}[-. )]*\d{3}[-. ]*\d{4}\b"),
]


def read_all_text() -> str:
    parts: list[str] = []
    for path in REQUIRED_FILES:
        if path.exists():
            parts.append(path.read_text(encoding="utf-8", errors="ignore"))
    return "\n".join(parts)


def validate() -> list[str]:
    failures: list[str] = []
    for path in REQUIRED_FILES:
        if not path.exists():
            failures.append(f"missing required R2 staging artifact: {path.relative_to(ROOT)}")
    text = read_all_text()
    low = text.lower()
    for phrase in REQUIRED_PHRASES:
        if phrase.lower() not in low:
            failures.append(f"R2 staging artifacts missing required phrase: {phrase}")
    for pattern in SECRET_PATTERNS:
        if pattern.search(text):
            failures.append(f"R2 staging artifacts contain secret-shaped value: {pattern.pattern}")
    for pattern in PRIVATE_CONTACT_PATTERNS:
        if pattern.search(text):
            failures.append(f"R2 staging artifacts contain private-contact-shaped value: {pattern.pattern}")
    return failures


def self_test() -> int:
    safe = "AMB-973 ambitions-source-atlas-staging contains_private_user_data contains_secret_material runtime_eligible runtime_consumption_claimed production_readiness_claimed rollback release receipt Cloudflare API error: 200"
    if any(pattern.search(safe) for pattern in SECRET_PATTERNS + PRIVATE_CONTACT_PATTERNS):
        print("FAIL self-test safe text tripped secret/private patterns")
        return 1
    unsafe = "CLOUDFLARE_API_TOKEN=abcdefghijklmnopqrstuvwxyz"
    if not any(pattern.search(unsafe) for pattern in SECRET_PATTERNS):
        print("FAIL self-test did not catch token-like assignment")
        return 1
    print("PASS source atlas R2 staging validator self-test")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    failures = validate()
    for failure in failures:
        print("FAIL " + failure)
    if failures:
        return 1
    print("PASS Source Atlas R2 staging artifacts are present and no obvious secret/private-contact values were found")
    return 0


if __name__ == "__main__":
    sys.exit(main())
