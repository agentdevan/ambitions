#!/usr/bin/env python3
from __future__ import annotations
import argparse, subprocess
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("issue")
    ap.add_argument("status", choices=["Green", "Yellow", "Red"])
    args = ap.parse_args()
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
    files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1..HEAD"], text=True).splitlines()
    print(f"Verified {args.issue}\n\nCommit: `{sha}`\nStatus: {args.status}\n\nChanged files:\n" + "\n".join(f"- `{f}`" for f in files) + "\n\nClaims not made: no release/app/TestFlight/App Store/device/accessibility/privacy/legal readiness claim.")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
