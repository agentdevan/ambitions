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
    "contains_runtime_write_credentials",
    "contains_realistic_private_goal_text",
    "public staging `r2.dev`",
    "Proof run: `amb-973-r2-green-repair-20260613T183742Z`",
    "SHA-256 body-hash",
    "HEAD",
    "GET body",
    "hash match",
    "rollback",
    "release receipt",
    "not acceptable Green evidence",
    "No production bucket write",
    "No app source changed",
]

REQUIRED_HASHES = [
    "e566417aea3de6acbe5fa3b19f8c32f67646db4f6dfab3c900b4dae7f0412ee3",
    "67e0b286b57c0738c54320d0515dfc290832064fa943c60f75da59bfd12811f4",
    "0445812decf276407d124714610c1b2ee9c1dbe519028af95981c841bd92b94c",
    "ac32bf7dd27913ac9d36346e1a738fa3766cf70f3b4dfcf7c21064d7ef3884a6",
    "6520b9716fe28a95a2ca5b15e3040cae45c1535debaaf9caacbe318683cd2ec0",
    "5ca3b2db43fb3435d946f02615cbf4a7a9e7df30067bc03d5accadb02243191c",
    "7ee30004aa64bb55ba7de485c88faf057ccaf9b894e6e4af443e5fe8c207c107",
    "bc452a01b7f8940d30c3e2bc8fd998de2dbe0c01aeb2ec68047dccb527a69347",
    "e789caec79dc4d547e3d0c17a460df53966a47735cb23e2b1e27454c45fd676b",
    "bf6dc4d48f28917838eefdb2b6de8b7b7b2a57fdbaade70421cde71ad721b7b2",
]

OLD_YELLOW_GREEN_FALSE_PASS = [
    re.compile(r"Status:\s*Yellow.*Cloudflare API error: 200", re.IGNORECASE | re.DOTALL),
    re.compile(r"Green/Yellow/Red status:\s*Yellow", re.IGNORECASE),
    re.compile(r"accepted-Yellow R2 staging activation", re.IGNORECASE),
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
    for digest in REQUIRED_HASHES:
        if digest not in text:
            failures.append(f"R2 staging artifacts missing refreshed canary SHA-256: {digest}")
    receipt = R2_DIR / "R2_CANARY_OBJECT_RECEIPT.md"
    receipt_text = receipt.read_text(encoding="utf-8", errors="ignore") if receipt.exists() else ""
    if receipt_text.count("| `staging/") != 10:
        failures.append("R2 canary receipt must list exactly 10 refreshed staging canary keys")
    for pattern in OLD_YELLOW_GREEN_FALSE_PASS:
        if pattern.search(text):
            failures.append("R2 staging artifacts still encode old accepted-Yellow connector limitation as the active status")
    for pattern in SECRET_PATTERNS:
        if pattern.search(text):
            failures.append(f"R2 staging artifacts contain secret-shaped value: {pattern.pattern}")
    for pattern in PRIVATE_CONTACT_PATTERNS:
        if pattern.search(text):
            failures.append(f"R2 staging artifacts contain private-contact-shaped value: {pattern.pattern}")
    return failures


def self_test() -> int:
    safe = "AMB-973 ambitions-source-atlas-staging contains_private_user_data contains_secret_material contains_runtime_write_credentials contains_realistic_private_goal_text public staging `r2.dev` Proof run: `amb-973-r2-green-repair-20260613T183742Z` SHA-256 body-hash HEAD GET body hash match rollback release receipt not acceptable Green evidence No production bucket write No app source changed"
    if any(pattern.search(safe) for pattern in SECRET_PATTERNS + PRIVATE_CONTACT_PATTERNS):
        print("FAIL self-test safe text tripped secret/private patterns")
        return 1
    unsafe = "CLOUDFLARE_API_TOKEN=abcdefghijklmnopqrstuvwxyz"
    if not any(pattern.search(unsafe) for pattern in SECRET_PATTERNS):
        print("FAIL self-test did not catch token-like assignment")
        return 1
    old_yellow = "Status: Yellow for AMB-973 because Cloudflare API error: 200"
    if not any(pattern.search(old_yellow) for pattern in OLD_YELLOW_GREEN_FALSE_PASS):
        print("FAIL self-test did not catch old accepted-Yellow connector limitation status")
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
    print("PASS Source Atlas R2 staging artifacts include current body-read/hash proof and no obvious secret/private-contact values were found")
    return 0


if __name__ == "__main__":
    sys.exit(main())
