#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from ambitions_visual_100_common import BASE, ROOT, read_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-prompt-authority.json"


def main() -> int:
    path = ROOT / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04.md"
    text = read_text(path)
    missing = []
    required = [
        "AMBITIONS_RUNNER_REQUIRED",
        "VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04",
        "VISUAL-ENCYCLOPEDIA-100-PERFECTION-INSTALL-01",
        "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03",
        "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03-MERGED",
        "GPT-5.4-mini",
        "scripts/ambitions-codex-train.sh",
    ]
    for marker in required:
        if marker not in text:
            missing.append(marker)

    ledger = read_text(ROOT / "docs/canon/frontend/trace/VISUAL_100_PROMPT_SUPERSESSION_LEDGER.md")
    if "VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04" not in ledger:
        missing.append("ledger-active-prompt")
    if "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-02" not in ledger or "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03" not in ledger:
        missing.append("ledger-superseded-prompts")

    forbidden_refs = []
    allowed_paths = {
        ROOT / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04.md",
        ROOT / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md",
        ROOT / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03-MERGED.md",
        ROOT / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-PERFECTION-INSTALL-01.md",
        ROOT / "docs/canon/frontend/trace/VISUAL_100_PROMPT_SUPERSESSION_LEDGER.md",
    }
    for root_dir in (ROOT / "docs", ROOT / "prompts", ROOT / ".codex"):
        if root_dir == ROOT / ".codex":
            # Ignore generated run transcripts; only live authority docs matter here.
            continue
        for candidate in root_dir.rglob("*.md"):
            if candidate in allowed_paths:
                continue
            text_candidate = read_text(candidate)
            if "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-02" in text_candidate or "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03-MERGED" in text_candidate:
                forbidden_refs.append(str(candidate.relative_to(ROOT)))
    if forbidden_refs:
        missing.append({"forbidden_refs": forbidden_refs})

    status = "red" if missing else "green"
    write_json(REPORT, {"missing": missing, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
