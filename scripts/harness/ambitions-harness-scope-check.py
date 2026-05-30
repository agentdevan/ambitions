#!/usr/bin/env python3
from __future__ import annotations
import argparse, subprocess, sys
FORBIDDEN_PREFIXES = ("Native/", "Sources/", "AppUI/", "Ambitions.xcodeproj/", "docs/truth/", "build/reports/")
FORBIDDEN_EXACT = {"Package.swift", "project.yml"}
def git(args):
    return subprocess.check_output(["git", *args], text=True).strip()
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--staged", action="store_true")
    parser.add_argument("--allow-source", action="store_true")
    args = parser.parse_args()
    cmd = ["diff", "--cached", "--name-only"] if args.staged else ["status", "--porcelain"]
    out = git(cmd)
    paths = []
    for line in out.splitlines():
        paths.append(line if args.staged else line[3:])
    bad = []
    for p in paths:
        if p in FORBIDDEN_EXACT or p.startswith("docs/truth/") or p.startswith("build/reports/"):
            bad.append(p)
        elif not args.allow_source and any(p.startswith(x) for x in FORBIDDEN_PREFIXES if x not in {"docs/truth/", "build/reports/"}):
            bad.append(p)
    if bad:
        print("Forbidden paths:")
        print("\n".join(bad))
        return 1
    print("Scope check passed")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
