#!/usr/bin/env bash
set -euo pipefail
rg -n "production ready|TestFlight ready|App Store ready|market proven|physical device passed|legal signoff|public accessibility proven" docs/canon docs/codex .codex scripts || true
