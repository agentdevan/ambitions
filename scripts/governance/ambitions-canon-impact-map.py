#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path
from datetime import datetime, timezone

OUT_DIR = Path("docs/governance/generated")
OUT_JSON = OUT_DIR / "canon_impact_map.json"
OUT_MD = OUT_DIR / "canon_impact_plan.md"

CANON_ROOTS = [Path("docs/canon"), Path("docs/truth")]
SCAN_ROOTS = [Path("docs"), Path("prompts"), Path("Sources"), Path("Native"), Path("scripts"), Path("DesignTokens")]
KEY_TERMS = [
    "Today", "Goals", "Capture", "Time", "You", "Plan",
    "Reality Meridian", "Constellation Atlas", "Atmosphere Composer", "LifeShape Field",
    "User System Profile", "Start Here", "Hero Step Panel", "Mission Control",
    "local-first", "on-device", "Private Life Runtime", "AmbitionsOS", "AFI", "FCP"
]


def git(args: list[str]) -> str:
    return subprocess.run(["git", *args], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


def changed_canon_files() -> list[str]:
    raw = git(["diff", "--name-only", "HEAD"])
    files = [line.strip() for line in raw.splitlines() if line.strip()]
    return [f for f in files if f.startswith(("docs/canon/", "docs/truth/"))]


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    changed = changed_canon_files()

    corpus_hits: dict[str, list[str]] = {term: [] for term in KEY_TERMS}
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in {".md", ".swift", ".json", ".py", ".yml", ".yaml", ".sh"}:
                continue
            body = text(path)
            for term in KEY_TERMS:
                if term in body:
                    corpus_hits[term].append(path.as_posix())

    likely_affected = sorted({p for paths in corpus_hits.values() for p in paths})
    retired_signals = []
    for path in likely_affected:
        body = text(Path(path))[:12000]
        if re.search(r"\bPlan\b", body) and not re.search(r"Plan is no longer|superseded|compatibility|historical|Adjust plan", body):
            retired_signals.append({"path": path, "signal": "possible active Plan top-level residue"})
        if "Hero Step Panel" in body and "Start Here" not in body:
            retired_signals.append({"path": path, "signal": "possible Hero Step Panel without Start Here binding"})

    data = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "changed_canon_files": changed,
        "key_term_hits": {k: sorted(v) for k, v in corpus_hits.items() if v},
        "likely_affected_files": likely_affected,
        "retired_canon_signals": retired_signals,
    }
    OUT_JSON.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")

    lines = ["# Canon Impact Plan", "", f"Generated: {data['generated_at']}", ""]
    lines += ["## Changed Canon Files", ""]
    lines += [f"- {f}" for f in changed] or ["- None currently dirty"]
    lines += ["", "## Likely Affected Files", ""]
    lines += [f"- {f}" for f in likely_affected[:200]] or ["- None detected"]
    lines += ["", "## Retired Canon Signals", ""]
    lines += [f"- {i['path']}: {i['signal']}" for i in retired_signals[:200]] or ["- None detected"]
    lines += ["", "## Required Codex Behavior", "", "When canon changes, Codex must update affected specs, prompts, manifests, generated governance outputs, and archive retired canon before feature work continues."]
    OUT_MD.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT_JSON}")
    print(f"wrote {OUT_MD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
