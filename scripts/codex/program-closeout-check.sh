#!/usr/bin/env bash
set -u
root_dir() { git rev-parse --show-toplevel 2>/dev/null || pwd; }
normalize_program() { case "${1:-}" in uiql|UIQL) echo uiql;; plos|PLOS) echo plos;; amb-master|amb_master|AMB-MASTER|AMB_MASTER|master-build|MASTER-BUILD) echo amb-master;; source-atlas|source_atlas|saf|SAF) echo source-atlas;; qa|QA) echo qa;; privacy|PRIVACY) echo privacy;; repo-hygiene|repo_hygiene|REPO-HYGIENE) echo repo-hygiene;; release|RELEASE) echo release;; design|DESIGN) echo design;; codex-os-v2|codex-os|CODEX-OS) echo codex-os-v2;; *) echo "";; esac; }
artifact_dir_for() { case "$1" in uiql) echo artifacts/ui-quality-lockdown;; plos) echo artifacts/plos-runtime;; amb-master) echo artifacts/ambitions-master-build;; source-atlas) echo artifacts/source-atlas-factory;; codex-os-v2) echo artifacts/codex-os-v2;; qa) echo artifacts/qa;; privacy) echo artifacts/privacy;; repo-hygiene) echo artifacts/repo-hygiene;; release) echo artifacts/release;; design) echo artifacts/design;; *) echo "";; esac; }

program="$(normalize_program "${1:-}")"; issue="${2:-}"
if [ -z "$program" ] || [ -z "$issue" ]; then echo "usage: scripts/codex/program-closeout-check.sh <program> <issue>" >&2; exit 2; fi
root="$(root_dir)"; cd "$root" || exit 2
artifact="$(artifact_dir_for "$program")"; mkdir -p "$artifact/script-output"; log="$artifact/script-output/program-closeout-check-${issue}-$(date +%Y%m%dT%H%M%S).log"; exec > >(tee "$log") 2>&1
status=0; branch="$(git branch --show-current 2>/dev/null || true)"; echo "program-closeout-check program=$program issue=$issue branch=$branch head=$(git rev-parse --short HEAD 2>/dev/null || true)"
[ "$branch" = main ] && echo PASS branch main || { echo FAIL branch not main; status=1; }
git diff --check || status=1
if git status --porcelain=v1 | awk '{print substr($0,4)}' | grep -E '^(Native/|Sources/|AppUI/|project.yml|Package.swift|.*\.xcodeproj|.*\.entitlements|.*Info\.plist)' >/tmp/program-closeout-forbidden.$$ 2>/dev/null; then echo FAIL forbidden dirty paths; cat /tmp/program-closeout-forbidden.$$; rm -f /tmp/program-closeout-forbidden.$$; status=1; else rm -f /tmp/program-closeout-forbidden.$$; echo PASS no forbidden app/source/project dirty paths; fi
[ -f artifacts/proof-ledger/proof-index.json ] && echo PASS proof index exists || { echo FAIL proof index missing; status=1; }
echo "artifact=$log"; exit "$status"
