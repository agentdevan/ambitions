#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "$#" -gt 0 ]]; then
  paths=("$@")
else
  paths=(
    "README.md"
    "AGENTS.md"
    "docs"
    ".codex"
    "scripts"
    "tools"
  )
fi

python3 - "${paths[@]}" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

root = Path.cwd()
raw_paths = [Path(p) for p in sys.argv[1:]]

skip_parts = {
    ".git",
    "node_modules",
    "Ambitions.xcodeproj",
    "output",
}
skip_suffixes = {
    ".png", ".jpg", ".jpeg", ".gif", ".pdf", ".xcresult", ".zip",
    ".gz", ".DS_Store",
}
scanner_path = Path("scripts/codex-forbidden-claim-scan.sh")

patterns = {
    "false_release_claim": re.compile(
        r"\b(production[- ]ready|release[- ]ready|App Store[- ]ready|"
        r"TestFlight[- ]ready|signed release[- ]ready|device[- ]verified|"
        r"physical[- ]device validated|CI[- ]proven|fully tested|"
        r"fully accessible|VoiceOver verified|Dynamic Type verified|"
        r"Reduce Motion verified|performance validated|memory safe|"
        r"launch[- ]time safe|scroll[- ]performance safe|privacy approved|"
        r"legally approved|App Review ready|store metadata ready|"
        r"screenshots ready|support URL verified|privacy URL verified|"
        r"human release[- ]approved)\b",
        re.IGNORECASE,
    ),
    "provider_backend_drift": re.compile(
        r"\b(Supabase|Postgres|hosted backend|custom hosted account|"
        r"server-side user profiling|analytics|telemetry|external LLM|"
        r"OpenAI/API|cloud model calls|auth provider|sync server)\b",
        re.IGNORECASE,
    ),
    "obsolete_hierarchy": re.compile(
        r"\b(Plan tab|Profile tab|Captures tab|Insights tab|Habits tab|"
        r"top-level Plan|top-level Profile|top-level Captures|"
        r"top-level Insights|top-level Habits|Ambitions 3\.0 is the active "
        r"source of truth|PXOS active|ACUI active)\b",
        re.IGNORECASE,
    ),
    "product_drift": re.compile(
        r"\b(AI confidence|AI recommends|chatbot|assistant tab|"
        r"productivity score|life score|streak broken|overdue queue|"
        r"best next move|next best move)\b",
        re.IGNORECASE,
    ),
}

allowed_context = re.compile(
    r"(\bno\b|forbidden|must not|do not|does not|not prove|not claim|"
    r"without current|unless current|blocked|ban |avoid |no[- ]claim|"
    r"non[- ]claim|terms to avoid|hard claims not made|"
    r"release evidence firewall|current release posture|not yet proven|"
    r"deleted provider|provider exclusion|historical|supporting only)",
    re.IGNORECASE,
)


def iter_files(path: Path):
    if not path.exists():
      return
    if path.is_file():
      yield path
      return
    for child in path.rglob("*"):
      if child.is_file():
        yield child


blocking = []
context = []
missing = []

for raw in raw_paths:
    path = raw if raw.is_absolute() else root / raw
    if not path.exists():
        missing.append(str(raw))
        continue
    for file_path in iter_files(path):
        rel = file_path.relative_to(root)
        if rel == scanner_path:
            continue
        if any(part in skip_parts for part in rel.parts):
            continue
        if file_path.suffix in skip_suffixes:
            continue
        try:
            text = file_path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for line_no, line in enumerate(text.splitlines(), 1):
            for category, pattern in patterns.items():
                if not pattern.search(line):
                    continue
                item = (str(rel), line_no, category, line.strip())
                if allowed_context.search(line):
                    context.append(item)
                else:
                    blocking.append(item)

if missing:
    print("Missing paths:")
    for path in missing:
        print(f"  {path}")

if context:
    print("Context-only hits:")
    for path, line_no, category, text in context[:200]:
        print(f"{path}:{line_no}: {category}: {text}")
    if len(context) > 200:
        print(f"... {len(context) - 200} additional context-only hits omitted")

if blocking:
    print("Blocking hits:")
    for path, line_no, category, text in blocking:
        print(f"{path}:{line_no}: {category}: {text}")
    sys.exit(1)

print("codex-forbidden-claim-scan: no blocking hits")
PY
