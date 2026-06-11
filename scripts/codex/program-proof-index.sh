#!/usr/bin/env bash
set -u
root_dir() { git rev-parse --show-toplevel 2>/dev/null || pwd; }
normalize_program() { case "${1:-}" in uiql|UIQL) echo uiql;; plos|PLOS) echo plos;; source-atlas|source_atlas|saf|SAF) echo source-atlas;; qa|QA) echo qa;; privacy|PRIVACY) echo privacy;; repo-hygiene|repo_hygiene|REPO-HYGIENE) echo repo-hygiene;; release|RELEASE) echo release;; design|DESIGN) echo design;; codex-os-v2|codex-os|CODEX-OS) echo codex-os-v2;; *) echo "";; esac; }
artifact_dir_for() { case "$1" in uiql) echo artifacts/ui-quality-lockdown;; plos) echo artifacts/plos-runtime;; source-atlas) echo artifacts/source-atlas-factory;; codex-os-v2) echo artifacts/codex-os-v2;; qa) echo artifacts/qa;; privacy) echo artifacts/privacy;; repo-hygiene) echo artifacts/repo-hygiene;; release) echo artifacts/release;; design) echo artifacts/design;; *) echo "";; esac; }

program="$(normalize_program "${1:-codex-os-v2}")"; [ -n "$program" ] || { echo "usage: scripts/codex/program-proof-index.sh <program>" >&2; exit 2; }
root="$(root_dir)"; cd "$root" || exit 2
artifact="$(artifact_dir_for "$program")"; mkdir -p "$artifact/script-output" artifacts/proof-ledger; log="$artifact/script-output/program-proof-index-$(date +%Y%m%dT%H%M%S).log"; exec > >(tee "$log") 2>&1
python3 - "$program" <<'PYEOF'
import json, sys, subprocess
from pathlib import Path
program=sys.argv[1]; root=Path('.'); ledger=root/'artifacts/proof-ledger/PROOF_LEDGER.md'; entries=[]
if ledger.exists():
    cur=None
    for line in ledger.read_text(encoding='utf-8',errors='ignore').splitlines():
        if line.startswith('### '):
            if cur: entries.append(cur)
            cur={'id':line[4:].strip().lower().replace(' ','-'),'title':line[4:].strip(),'lines':[]}
        elif cur is not None: cur['lines'].append(line)
    if cur: entries.append(cur)
head=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
out=root/'artifacts/proof-ledger/proof-index.json'
out.write_text(json.dumps({'schema_version':1,'generated_by':'scripts/codex/program-proof-index.sh','program_filter':program,'head':head,'ledger':'artifacts/proof-ledger/PROOF_LEDGER.md','entries':entries,'non_claims':['release readiness','TestFlight readiness','App Store readiness','owner approval','accessibility certification','privacy/legal approval']},indent=2)+"\n",encoding='utf-8')
print(f'PASS wrote {out} with {len(entries)} entries')
PYEOF
echo "artifact=$log"
