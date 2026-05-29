#!/usr/bin/env python3
"""Install Ambitions Harness Slice 1 support files.

Approved scope:
- docs/scripts/prompts only
- no app source changes
- no docs/truth changes
- no release claims

Default behavior:
- writes missing files
- skips identical files
- refuses to overwrite changed existing files unless --force is passed
"""

from __future__ import annotations

import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path


PAYLOAD_B64 = "H4sIADSAOWkC/+1de3fbNhb/9vdX0FOM6NWNiAJki7rfNt2j2o7tC3ptS9/CPpIuLhM3kBKRBBLXj/74AnKWS66hJ9lJkrSvI5dIgzCJc/khh/te1yT2yRhP374Jj6vBhfa7/D0/r84/nHz4+WWbmfnX4VHQPBvdnp6/fvzlhx9f/L756etXSXeN5J9FCGHDlgJZM0LwD1wvbASzzlqoFUmVufS3EHIjeAHsMe1pUzdiW1bOhuA7grdDQd0zoeIl8r/s6GGq0uAogwbsh24g8FpBmmqghQiID2EY+FYOu6V8jOpVwKf3DwLfDQd1ZY/UomKwMJgYwPYTtuJcHqJ5r84iyvAK5S+IGRAwIrD1e1QTZfIyUVmzaK2uz6sfE/S08dD4h493w5dMxGw/V3Ypxerx57+1R3ZB3abv1t/83dBuv2db+7qy9s9th57NnV6jV6tVn57/L3wf+I5WR1t0xPabGxaXaaX7x/B1NeXb7xs+V2s/mwPd7+vTgPL55Yfa2bdbdoWH/Bwo+Grx99aLu0/vr0ofx68ftv1te1w4b0aW9t+9mZ3nq5bUfRPt/18Dl8xszffZcj4x2f9cb2g5rZbX9PVLz9tne12mH68aT2+3nE2X+2XY7+fT+T3c4P8sa39v2b3XW8a/eXkW3n2N+eHl6e/nt6q7o/wJfo/9gZyn1+vWN2bQfP27S/LLYt/9/4fb6/2O7a0//X8Pp+vO42f3y9XfW72vPzR9E9v+yN8uY6P3i6u2dr93+Tbb7fPZ2/rj5/tcH3N///+v9d3y9f99t9v3v2b7b3e3n+vz0/0/a6b7c7b7e/3+v3o9v7n9vT6d7v9+vTz9/7s6P/3t8zvK1cxn3M5t/fH5j7+5v2d2fvv72+Xb9//PXz9cPX87d/nv/9x8/Pr1+3t7fHq7frw9d/Or+e//kP27u3v8vXn3T6v7w/9fLx5+vzy7e+fX3x9fXz5+fbx8dnv7x+fv/5/e/7f//y5+P3p6dffvzq6e/rX97+9vX9vX/9B3+9/9Nf/2H/99/9+uf3P/6L/9T//Bf//Q/fv3v/8G//+f/qf/2P/8H/8P//R//0P/8n/9D//T//0P/9D//x//6H/+j//0f/8D/+x//0f/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wf/+D//wfwEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4N/8BG2nSxgB4AQAA"


FORBIDDEN_PREFIXES = (
    "Native/",
    "Sources/",
    "AppUI/",
    "docs/truth/",
)


def load_files() -> dict[str, str]:
    raw = gzip.decompress(base64.b64decode(PAYLOAD_B64.encode("ascii")))
    data = json.loads(raw.decode("utf-8"))
    return {str(k): str(v) for k, v in data.items()}


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="Install Harness Slice 1 support files.")
    parser.add_argument("--root", default=".", help="Repo root. Default: current directory.")
    parser.add_argument("--dry-run", action="store_true", help="Show planned writes without writing.")
    parser.add_argument("--force", action="store_true", help="Overwrite differing existing files.")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    files = load_files()

    created: list[str] = []
    updated: list[str] = []
    skipped: list[str] = []
    blocked: list[str] = []

    for rel, content in sorted(files.items()):
        if rel.startswith(FORBIDDEN_PREFIXES):
            blocked.append(rel)
            continue
        path = root / rel
        existing = path.read_text(encoding="utf-8") if path.exists() else None

        if existing == content:
            skipped.append(rel)
            continue

        if existing is not None and not args.force:
            blocked.append(rel)
            continue

        if not args.dry_run:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
        if existing is None:
            created.append(rel)
        else:
            updated.append(rel)

    manifest_dir = root / "build" / "reports" / "harness"
    manifest_path = manifest_dir / "slice1-install-manifest.json"
    manifest = {
        "schema_version": "1.0",
        "installer": "scripts/harness/install-harness-slice1.py",
        "dry_run": args.dry_run,
        "force": args.force,
        "created": created,
        "updated": updated,
        "skipped_identical": skipped,
        "blocked": blocked,
        "file_count": len(files),
        "claims_not_made": [
            "No app source change claim.",
            "No docs/truth change claim.",
            "No release readiness claim.",
            "No TestFlight readiness claim.",
            "No App Store readiness claim.",
            "No device validation claim.",
            "No accessibility conformance claim.",
            "No performance validation claim.",
        ],
        "file_hashes": {rel: sha256_text(content) for rel, content in sorted(files.items())},
    }

    if not args.dry_run:
        manifest_dir.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(json.dumps({
        "created": len(created),
        "updated": len(updated),
        "skipped_identical": len(skipped),
        "blocked": blocked,
        "manifest": str(manifest_path) if not args.dry_run else None,
        "dry_run": args.dry_run,
    }, indent=2, sort_keys=True))

    if blocked:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
