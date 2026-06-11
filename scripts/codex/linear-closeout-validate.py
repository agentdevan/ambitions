#!/usr/bin/env python3
"""Validate Ambitions Goal Mode Linear closeout text locally without network or Linear writes."""
from __future__ import annotations
import argparse, sys
from pathlib import Path
REQUIRED=["Codex OS v2 Goal-Mode Install","Issues covered:","Pushed to main:","Push hash:","App source changed:","New parallel OS created:","Existing OS extended:","Runner removed as active default:","Goal Mode active as default:","Validation run:","Red blockers:","Yellow existing drift:","Owner approval claimed:","Release/TestFlight/App Store readiness claimed:","Next recommended action:"]
FORBID=["owner approval claimed: yes","release/testflight/app store readiness claimed: yes","app source changed: yes","new parallel os created: yes"]
ISSUES=[f"AMB-CODEX-OS-V2-{i:03d}" for i in range(1,14)]
def main():
    ap=argparse.ArgumentParser(description='Validate local Linear closeout text for Codex OS v2 Goal Mode installs.')
    ap.add_argument('path', nargs='?')
    ns=ap.parse_args(); text=Path(ns.path).read_text(encoding='utf-8',errors='ignore') if ns.path else sys.stdin.read(); low=text.lower(); failures=[]
    for p in REQUIRED:
        if p.lower() not in low: failures.append(f'missing required closeout field: {p}')
    for i in ISSUES:
        if i.lower() not in low: failures.append(f'missing issue id: {i}')
    for p in FORBID:
        if p in low: failures.append(f'forbidden unproven positive claim: {p}')
    for f in failures: print('FAIL '+f)
    if failures: return 1
    print('PASS linear closeout text has required fields and no forbidden positive claims'); return 0
if __name__=='__main__': raise SystemExit(main())
