#!/usr/bin/env bash
set -Eeuo pipefail

cat <<'EOF'
Ambitions local repo-intelligence manual setup

These commands are optional and must be run manually by the operator. This
helper does not install tools, mutate global config, create indexes, read
secrets, or run remote installer scripts.

CodeGraph:
  npx @colbymchenry/codegraph
  codegraph install --print-config codex
  cd /Users/devan/Documents/GitHub/ambitions
  codegraph init -i
  codegraph status

Semble:
  uv tool install "semble[mcp]"
  cd /Users/devan/Documents/GitHub/ambitions
  semble search "Reality Meridian" . --include-text-files -k 5
  semble find-related Native/Ambitions/App/AmbitionsApp.swift 1 . --include-text-files -k 5

  Current Semble builds its working index at query time. The legacy
  .codex/local-indexes/semble-ambitions sidecar path stays ignored, but the
  current CLI does not create it.

Understand Anything:
  Optional sandbox-only human dashboard. Do not run it during normal iOS 26
  batch gates, and do not use it as source truth or proof.
  Follow upstream install docs manually if desired.
  /understand
  /understand-dashboard

Manual Codex MCP snippets are advisory only. Keep them local, avoid secrets,
and do not add write-capable or production-affecting tools without approval.
EOF
