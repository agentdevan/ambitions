#!/usr/bin/env bash
set -u
root_dir() { git rev-parse --show-toplevel 2>/dev/null || pwd; }
normalize_program() { case "${1:-}" in uiql|UIQL) echo uiql;; plos|PLOS) echo plos;; source-atlas|source_atlas|saf|SAF) echo source-atlas;; qa|QA) echo qa;; privacy|PRIVACY) echo privacy;; repo-hygiene|repo_hygiene|REPO-HYGIENE) echo repo-hygiene;; release|RELEASE) echo release;; design|DESIGN) echo design;; codex-os-v2|codex-os|CODEX-OS) echo codex-os-v2;; *) echo "";; esac; }
artifact_dir_for() { case "$1" in uiql) echo artifacts/ui-quality-lockdown;; plos) echo artifacts/plos-runtime;; source-atlas) echo artifacts/source-atlas-factory;; codex-os-v2) echo artifacts/codex-os-v2;; qa) echo artifacts/qa;; privacy) echo artifacts/privacy;; repo-hygiene) echo artifacts/repo-hygiene;; release) echo artifacts/release;; design) echo artifacts/design;; *) echo "";; esac; }

program="$(normalize_program "${1:-}")"
if [ -z "$program" ]; then echo "usage: scripts/codex/program-preflight.sh <program>" >&2; exit 2; fi
root="$(root_dir)"; cd "$root" || exit 2
artifact="$(artifact_dir_for "$program")"; mkdir -p "$artifact/script-output"
log="$artifact/script-output/program-preflight-$(date +%Y%m%dT%H%M%S).log"
exec > >(tee "$log") 2>&1
status=0
check_file(){ [ -e "$1" ] && echo "PASS file: $1" || { echo "FAIL missing: $1"; status=1; }; }
check_dir(){ [ -d "$1" ] && echo "PASS dir: $1" || { echo "FAIL missing dir: $1"; status=1; }; }
echo "program-preflight program=$program branch=$(git branch --show-current 2>/dev/null || true) head=$(git rev-parse --short HEAD 2>/dev/null || true)"
for f in docs/truth/README.md docs/truth/PRODUCT_DESIGN_TRUTH.md docs/truth/PRODUCT_MOAT_TRUTH.md docs/truth/IMPLEMENTATION_TRUTH.md docs/truth/RELEASE_TRUTH.md docs/truth/CODEX_PROCESS_TRUTH.md docs/truth/HISTORICAL_POLICY.md AGENTS.md docs/codex-os/PROGRAM_REGISTRY.md docs/codex-os/GOAL_MODE_EXECUTION_POLICY.md docs/codex-os/RUN_STATE_STANDARD.md docs/codex-os/PROOF_ARTIFACT_STANDARD.md docs/codex-os/SCRIPT_OUTPUT_STANDARD.md docs/codex-os/LINEAR_CLOSEOUT_STANDARD.md artifacts/proof-ledger/PROOF_LEDGER.md artifacts/proof-ledger/proof-index.json; do check_file "$f"; done
case "$program" in
 uiql) check_file artifacts/ui-quality-lockdown/UIQL_GOAL.md; check_file artifacts/ui-quality-lockdown/UIQL-run-state.md; check_file .agents/skills/uiql-quality-lockdown/SKILL.md;;
 plos) check_file artifacts/plos-runtime/PLOS_GOAL.md; check_file artifacts/plos-runtime/PLOS-run-state.md; check_file artifacts/plos-runtime/PLOS_PHASE_GATES.md; check_file artifacts/plos-runtime/PLOS_GOLDEN_SLICE_PROOF.md; check_file .agents/skills/plos-runtime-master-build/SKILL.md;;
 source-atlas) check_file artifacts/source-atlas-factory/SAF_GOAL.md; check_file artifacts/source-atlas-factory/SAF-run-state.md; check_file artifacts/source-atlas-factory/SAF_PACK_RELEASE_LEDGER.md; check_file .agents/skills/source-atlas-factory/SKILL.md; check_dir tools/source-atlas;;
 codex-os-v2) check_file artifacts/codex-os-v2/AMB-CODEX-OS-V2_GOAL.md; check_file artifacts/codex-os-v2/AMB-CODEX-OS-V2-run-state.md; check_file docs/codex-os/CODEX_OS_V2_INSTALL_REPORT.md; check_file docs/codex-os/CODEX_OS_V2_RED_TEAM_AUDIT.md; check_file .agents/skills/ambitions-reviewer-board/SKILL.md;;
 *) check_dir "$artifact";;
esac
if git status --porcelain=v1 | awk '{print substr($0,4)}' | grep -E '^(Native/|Sources/|AppUI/|project.yml|Package.swift|.*\.xcodeproj|.*\.entitlements|.*Info\.plist)' >/tmp/program-preflight-forbidden.$$ 2>/dev/null; then echo FAIL forbidden dirty paths; cat /tmp/program-preflight-forbidden.$$; rm -f /tmp/program-preflight-forbidden.$$; status=1; else rm -f /tmp/program-preflight-forbidden.$$; echo PASS no forbidden app/source/project dirty paths detected; fi
if rg -n --glob '!scripts/codex/program-preflight.sh' "TODO define later|TBD define later|placeholder only" docs/codex-os artifacts .agents/skills scripts/codex >/tmp/program-preflight-placeholders.$$ 2>/dev/null; then echo FAIL unresolved placeholder language; cat /tmp/program-preflight-placeholders.$$; rm -f /tmp/program-preflight-placeholders.$$; status=1; else rm -f /tmp/program-preflight-placeholders.$$; echo PASS no forbidden placeholder language detected; fi
echo "result=$([ "$status" -eq 0 ] && echo GREEN || echo RED)"
echo "artifact=$log"
exit "$status"
