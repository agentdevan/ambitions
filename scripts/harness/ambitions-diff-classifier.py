#!/usr/bin/env python3
from __future__ import annotations
import subprocess, json
def main():
    files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1..HEAD"], text=True).splitlines()
    classes = []
    for f in files:
        if f.startswith("Native/") or f.startswith("Sources/"):
            kind = "source"
        elif f.startswith("docs/"):
            kind = "docs"
        elif f.startswith("scripts/"):
            kind = "tooling"
        else:
            kind = "other"
        classes.append({"path": f, "class": kind})
    print(json.dumps({"files": classes, "claims_not_made": ["No release readiness claim"]}, indent=2))
if __name__ == "__main__":
    raise SystemExit(main())
