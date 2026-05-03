#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "pxeq-generic-card-stack-scan: advisory"
rg -n -i "generic card|card stack|stacked cards|dashboard grid|dashboard sprawl|settings dump|CRM|admin" docs/codex docs/audits .codex Native Sources AppUI 2>/dev/null || true
echo "YELLOW advisory scan complete"

