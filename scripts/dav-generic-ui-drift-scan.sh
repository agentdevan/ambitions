#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-generic-ui-drift-scan"
rg -n "GenericCard|Dashboard|dashboard|CRM|admin panel|kanban|OKR|chatbot|AI glow|neon|card pile|card stack" Sources Native/Ambitions docs/codex docs/audits .codex 2>/dev/null || true
echo "YELLOW advisory scan complete"

