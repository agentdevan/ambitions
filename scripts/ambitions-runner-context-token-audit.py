#!/usr/bin/env python3
"""Audit Ambitions runner/context prompt size and stale active-canon risk.

The audit is local-only and standard-library-only. It scans process, runner,
prompt, and Codex context files by default; production app source is excluded.
"""
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DEFAULT_PATHS = [
    "AGENTS.md",
    ".agents/AGENTS.md",
    "docs/AGENTS.md",
    "scripts/AGENTS.md",
    ".codex/os",
    ".codex/hooks",
    ".codex/reports/current-run-state.md",
    ".codex/reports/current-batch-train-state.md",
    "scripts/ambitions-codex-train.sh",
    "scripts/ambitions-runner-self-check.sh",
    "scripts/ambitions-advance-batch-state.py",
    "scripts/global-train-handoff-prompt.sh",
    "scripts/codex-os",
    "prompts/_BATCH_TEMPLATE.md",
    "prompts/_RUNNER_REQUIRED_HEADER.md",
    "docs/codex",
]

EXCLUDED_PARTS = {
    ".git",
    ".DS_Store",
    "Native",
    "Sources",
    "AppUI",
    "Packages",
    "Ambitions.xcodeproj",
    "DerivedData",
    "logs",
    "runs",
    "repo-intelligence",
    "xcode-logs",
    "xcode-results",
    "xcode-summaries",
}

TEXT_SUFFIXES = {
    ".md",
    ".py",
    ".sh",
    ".txt",
    ".yml",
    ".yaml",
    ".json",
    ".toml",
}

ACTIVE_CONTEXT_WORDS = re.compile(
    r"\b(active|canonical|required|must|expected|current|approved|preserve|truth|authority)\b",
    re.IGNORECASE,
)
HISTORICAL_CONTEXT_WORDS = re.compile(
    r"\b(stale|historical|superseded|prior|old|legacy|migration|not active|not current|source state|compatibility)\b",
    re.IGNORECASE,
)
NEGATED_CONTEXT_WORDS = re.compile(
    r"\b(do not|don't|must not|should not|cannot|no\s+\w+\s+tab|not a tab|never)\b",
    re.IGNORECASE,
)
FALLBACK_MODEL_WORDS = re.compile(
    r"\b(fallback|falling back|only when|unless|exhausted|never owns|does not decide)\b",
    re.IGNORECASE,
)

STALE_IA = "Today / Goals / Capture / Time / You"
ACTIVE_IA = "Today / Goals / Time / Motion / You"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit Ambitions runner/context token budget and stale canon risk.")
    parser.add_argument("paths", nargs="*", help="Optional files/directories to scan instead of the default runner/context set.")
    parser.add_argument("--top", type=int, default=12, help="Number of largest files and repeated blocks to print.")
    parser.add_argument("--max-file-bytes", type=int, default=500_000, help="Skip files larger than this byte count.")
    return parser.parse_args()


def is_excluded(path: Path) -> bool:
    rel_parts = path.relative_to(ROOT).parts if path.is_absolute() else path.parts
    return any(part in EXCLUDED_PARTS for part in rel_parts)


def iter_files(paths: list[str], max_file_bytes: int) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        path = (ROOT / raw).resolve() if not Path(raw).is_absolute() else Path(raw)
        if not path.exists():
            continue
        if path.is_file():
            candidates = [path]
        else:
            candidates = [candidate for candidate in path.rglob("*") if candidate.is_file()]
        for candidate in candidates:
            try:
                rel = candidate.relative_to(ROOT)
            except ValueError:
                continue
            if is_excluded(rel):
                continue
            if candidate.suffix not in TEXT_SUFFIXES:
                continue
            try:
                if candidate.stat().st_size > max_file_bytes:
                    continue
            except OSError:
                continue
            files.append(candidate)
    return sorted(set(files))


def approx_tokens(text: str) -> int:
    return max(1, (len(text) + 3) // 4)


def is_active_stale_ia(line: str) -> bool:
    if STALE_IA not in line:
        return False
    if HISTORICAL_CONTEXT_WORDS.search(line) or NEGATED_CONTEXT_WORDS.search(line):
        return False
    return bool(ACTIVE_CONTEXT_WORDS.search(line))


def is_pulse_active(line: str) -> bool:
    if "Pulse" not in line:
        return False
    if HISTORICAL_CONTEXT_WORDS.search(line) or NEGATED_CONTEXT_WORDS.search(line):
        return False
    return bool(re.search(r"Pulse.*(active|approved|current|canonical|fifth tab)", line, re.IGNORECASE))


def is_capture_tab_active(line: str) -> bool:
    if "Capture" not in line or "tab" not in line.lower():
        return False
    if HISTORICAL_CONTEXT_WORDS.search(line) or NEGATED_CONTEXT_WORDS.search(line):
        return False
    return bool(ACTIVE_CONTEXT_WORDS.search(line))


def paragraph_blocks(text: str) -> list[str]:
    blocks = []
    for block in re.split(r"\n\s*\n", text):
        compact = re.sub(r"\s+", " ", block).strip()
        if len(compact) >= 280:
            blocks.append(compact)
    return blocks


def main() -> int:
    args = parse_args()
    scan_roots = args.paths or DEFAULT_PATHS
    files = iter_files(scan_roots, args.max_file_bytes)

    file_rows = []
    repeated: dict[str, list[str]] = defaultdict(list)
    stale_findings: list[str] = []
    model_findings: list[str] = []
    proof_gate_candidates: list[str] = []

    for path in files:
        rel = str(path.relative_to(ROOT))
        text = path.read_text(encoding="utf-8", errors="replace")
        token_count = approx_tokens(text)
        file_rows.append((token_count, rel, len(text)))
        for lineno, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            if is_active_stale_ia(stripped):
                stale_findings.append(f"{rel}:{lineno}: active stale IA candidate: {stripped[:180]}")
            if is_pulse_active(stripped):
                stale_findings.append(f"{rel}:{lineno}: Pulse-as-active candidate: {stripped[:180]}")
            if is_capture_tab_active(stripped):
                stale_findings.append(f"{rel}:{lineno}: Capture-as-tab candidate: {stripped[:180]}")
            if ("GPT-5.4-mini" in stripped or "gpt-5.4-mini" in stripped) and not FALLBACK_MODEL_WORDS.search(stripped):
                model_findings.append(f"{rel}:{lineno}: 5.4-mini model-route candidate: {stripped[:180]}")
            if re.search(r"\b(proof|validation|release|accessibility|privacy|performance)\b", stripped, re.IGNORECASE):
                if len(stripped) > 160:
                    proof_gate_candidates.append(f"{rel}:{lineno}: {stripped[:180]}")
        for block in paragraph_blocks(text):
            repeated[block].append(rel)

    repeated_rows = [
        (len(paths), approx_tokens(block), block, sorted(set(paths)))
        for block, paths in repeated.items()
        if len(set(paths)) > 1
    ]
    repeated_rows.sort(key=lambda row: (row[0], row[1]), reverse=True)
    file_rows.sort(reverse=True)

    status = "GREEN"
    if stale_findings:
        status = "RED"
    elif model_findings:
        status = "YELLOW"

    print("# Ambitions Runner Context Token Audit")
    print()
    print(f"Status: {status}")
    print(f"Inspected files: {len(files)}")
    print(f"Approx total tokens: {sum(row[0] for row in file_rows)}")
    print("Heuristic: approximate tokens = ceil(character_count / 4)")
    print("Default scope excludes Native/, Sources/, AppUI/, Packages/, DerivedData, logs, run transcripts, and repo-intelligence caches.")
    print()
    print("## Largest Files")
    for tokens, rel, chars in file_rows[: args.top]:
        print(f"- {rel}: ~{tokens} tokens ({chars} chars)")
    print()
    print("## Repeated Large Block Candidates")
    if repeated_rows:
        for count, tokens, block, paths in repeated_rows[: args.top]:
            print(f"- ~{tokens} tokens repeated in {count} files: {', '.join(paths[:4])}")
            print(f"  {block[:220]}")
    else:
        print("- None")
    print()
    print("## Stale Language Findings")
    if stale_findings:
        for finding in stale_findings:
            print(f"- {finding}")
    else:
        print("- None")
    print()
    print("## Model Routing Findings")
    if model_findings:
        for finding in model_findings:
            print(f"- {finding}")
    else:
        print("- None")
    print()
    print("## Proof Gate Replay Candidates")
    if proof_gate_candidates:
        for finding in proof_gate_candidates[: args.top]:
            print(f"- {finding}")
    else:
        print("- None")
    print()
    print("## Suggested Compaction Targets")
    if repeated_rows:
        print("- Replace duplicated large prose blocks with pointers to docs/truth/*, AGENTS.md, and .codex/os/* where issue-specific prompts do not need full replay.")
    else:
        print("- No repeated large-block compaction target detected in the default runner/context scan.")
    if proof_gate_candidates:
        print("- Keep proof gates mandatory, but prefer authority-file references plus issue-specific validation commands over full prose replay.")
    if model_findings:
        print("- Review 5.4-mini references and keep them fallback/historical only where active process truth allows it.")
    return 1 if status == "RED" else 0


if __name__ == "__main__":
    raise SystemExit(main())
