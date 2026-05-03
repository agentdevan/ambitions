#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-no-generic-drift-scan"
rg -n "generic dashboard|SaaS|task board|OKR|KPI|chatbot|streak|productivity score|fake AI|visual identity split" docs/canon docs/codex docs/audits Native/Ambitions Sources .codex 2>/dev/null || true
echo "YELLOW advisory scan complete"
