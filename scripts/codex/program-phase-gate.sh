#!/usr/bin/env bash
set -u
root_dir() { git rev-parse --show-toplevel 2>/dev/null || pwd; }
normalize_program() { case "${1:-}" in uiql|UIQL) echo uiql;; plos|PLOS) echo plos;; source-atlas|source_atlas|saf|SAF) echo source-atlas;; qa|QA) echo qa;; privacy|PRIVACY) echo privacy;; repo-hygiene|repo_hygiene|REPO-HYGIENE) echo repo-hygiene;; release|RELEASE) echo release;; design|DESIGN) echo design;; codex-os-v2|codex-os|CODEX-OS) echo codex-os-v2;; *) echo "";; esac; }
artifact_dir_for() { case "$1" in uiql) echo artifacts/ui-quality-lockdown;; plos) echo artifacts/plos-runtime;; source-atlas) echo artifacts/source-atlas-factory;; codex-os-v2) echo artifacts/codex-os-v2;; qa) echo artifacts/qa;; privacy) echo artifacts/privacy;; repo-hygiene) echo artifacts/repo-hygiene;; release) echo artifacts/release;; design) echo artifacts/design;; *) echo "";; esac; }

program="$(normalize_program "${1:-}")"; phase="${2:-}"
if [ -z "$program" ] || [ -z "$phase" ]; then echo "usage: scripts/codex/program-phase-gate.sh <program> <phase>" >&2; exit 2; fi
root="$(root_dir)"; cd "$root" || exit 2
artifact="$(artifact_dir_for "$program")"; mkdir -p "$artifact/script-output"; log="$artifact/script-output/program-phase-gate-${phase}-$(date +%Y%m%dT%H%M%S).log"; exec > >(tee "$log") 2>&1
status=0; echo "program-phase-gate program=$program phase=$phase"
case "$program" in
 plos) rg -n "^## ${phase}([[:space:]-]|$)" artifacts/plos-runtime/PLOS_PHASE_GATES.md >/dev/null || status=1; python3 scripts/codex/plos-readiness-validate.py --phase "$phase" || status=1;;
 uiql) rg -n "$phase" artifacts/ui-quality-lockdown/UIQL_GOAL.md artifacts/ui-quality-lockdown/UIQL-run-state.md >/dev/null || status=1;;
 source-atlas) rg -n "$phase|Pack|Seed|R2|Release" artifacts/source-atlas-factory/SAF_GOAL.md artifacts/source-atlas-factory/SAF_PACK_RELEASE_LEDGER.md artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md >/dev/null || status=1; python3 scripts/codex/source-atlas-readiness-validate.py || status=1;;
 codex-os-v2) rg -n "$phase|AMB-CODEX-OS-V2" artifacts/codex-os-v2 docs/codex-os >/dev/null || status=1;;
 *) status=0;;
esac
[ "$status" -eq 0 ] && echo PASS phase gate declared || echo FAIL phase gate not declared
echo "artifact=$log"; exit "$status"
