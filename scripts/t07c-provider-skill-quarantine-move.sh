#!/usr/bin/env bash
set -euo pipefail

# T07c — Provider Skill Quarantine Move
# Purpose: move external provider skills out of auto-loadable .agents/skills/ paths.
# Scope: repo-control-plane cleanup only. No app source changes.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OLD_SUPABASE=".agents/skills/supabase"
OLD_POSTGRES=".agents/skills/supabase-postgres-best-practices"
NEW_ROOT=".agents/quarantine/provider-skills"
NEW_SUPABASE="$NEW_ROOT/supabase"
NEW_POSTGRES="$NEW_ROOT/supabase-postgres-best-practices"

required_files=(
  "docs/truth/README.md"
  "docs/status/codex-agents-skill-inventory.md"
  "docs/status/cleanup-decision-register.md"
  "docs/status/quarantine-archive-folder-plan.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
done

if [[ ! -d "$OLD_SUPABASE" ]]; then
  echo "Missing source directory: $OLD_SUPABASE" >&2
  exit 1
fi

if [[ ! -d "$OLD_POSTGRES" ]]; then
  echo "Missing source directory: $OLD_POSTGRES" >&2
  exit 1
fi

mkdir -p "$NEW_ROOT"

if [[ -e "$NEW_SUPABASE" || -e "$NEW_POSTGRES" ]]; then
  echo "Destination already exists. Stop to avoid overwrite:" >&2
  [[ -e "$NEW_SUPABASE" ]] && echo "  $NEW_SUPABASE" >&2
  [[ -e "$NEW_POSTGRES" ]] && echo "  $NEW_POSTGRES" >&2
  exit 1
fi

mkdir -p ".agents/quarantine"
cat > ".agents/quarantine/README.md" <<'EOF'
# Agents Quarantine

External/provider-specific agent material lives here when it is retained for traceability but blocked from default Ambitions use.

Active Ambitions authority starts in `docs/truth/README.md`.

Quarantined provider skills must not be auto-loaded for Ambitions core work unless explicitly re-approved by `docs/truth/*` and a scoped owner decision.
EOF

mkdir -p "$NEW_ROOT"
cat > "$NEW_ROOT/README.md" <<'EOF'
# Provider Skills Quarantine

This folder contains external provider skills retained for traceability/candidate reference.

These packages are not active Ambitions product, implementation, backend, release, or Codex process authority.

Current authority starts in `docs/truth/README.md`.
EOF

mv "$OLD_SUPABASE" "$NEW_SUPABASE"
mv "$OLD_POSTGRES" "$NEW_POSTGRES"

python3 - <<'PY'
from pathlib import Path

replacements = {
    ".agents/skills/supabase/": ".agents/quarantine/provider-skills/supabase/",
    ".agents/skills/supabase-postgres-best-practices/": ".agents/quarantine/provider-skills/supabase-postgres-best-practices/",
    ".agents/skills/supabase*": ".agents/quarantine/provider-skills/supabase*",
}

paths = [
    Path("docs/status/codex-agents-skill-inventory.md"),
    Path("docs/status/cleanup-decision-register.md"),
    Path("docs/status/quarantine-archive-folder-plan.md"),
    Path("docs/status/reference-dependency-scan-cleanup-plan.md"),
    Path(".codex/manifests/skills-routing-map.yml"),
]

for path in paths:
    if not path.exists():
        continue
    body = path.read_text(encoding="utf-8")
    updated = body
    for old, new in replacements.items():
        updated = updated.replace(old, new)
    if updated != body:
        path.write_text(updated, encoding="utf-8")
        print(f"Updated references: {path}")

report = Path("docs/status/provider-skill-quarantine-move-audit.md")
report.write_text("""# Provider Skill Quarantine Move Audit

Status: Pending local validation after script execution  
Scope: T07c provider skill quarantine move

## Intended Moves

- `.agents/skills/supabase/` -> `.agents/quarantine/provider-skills/supabase/`
- `.agents/skills/supabase-postgres-best-practices/` -> `.agents/quarantine/provider-skills/supabase-postgres-best-practices/`

## Scope Boundaries

No Swift source changes, app implementation changes, release/readiness claims, hosted backend activation, or validation claims are authorized by this move.

## Required Validation

Run after script execution:

```bash
git status --short
git diff --stat
git diff -- .agents docs/status .codex/manifests/skills-routing-map.yml
```

Confirm only quarantine move paths and status/routing references changed.
""", encoding="utf-8")
print(f"Wrote audit: {report}")
PY

echo "T07c move prepared in working tree. Review with:"
echo "  git status --short"
echo "  git diff --stat"
echo "  git diff -- .agents docs/status .codex/manifests/skills-routing-map.yml"
