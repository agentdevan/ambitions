#!/usr/bin/env python3
"""Build a compact advisory repo-intelligence context packet for one batch."""
from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PREFLIGHT = ROOT / "scripts/ambitions-repo-intelligence-preflight.py"
REPORT_DIR = ROOT / "build/reports/repo-intelligence"
MAX_TEXT_CHARS = 7000
MAX_TOOL_CHARS = 5000
DEFAULT_TIMEOUT = 45


def load_preflight() -> Any:
    spec = importlib.util.spec_from_file_location("repo_intelligence_preflight", PREFLIGHT)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load preflight module")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(cmd: list[str], timeout: int = DEFAULT_TIMEOUT) -> dict[str, Any]:
    try:
        proc = subprocess.run(
            cmd,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
        )
    except FileNotFoundError as exc:
        return {"exit_code": 127, "output": str(exc)}
    except subprocess.TimeoutExpired as exc:
        output = exc.stdout or exc.stderr or ""
        return {"exit_code": 124, "output": f"timeout after {timeout}s\n{output}".strip()}
    return {"exit_code": proc.returncode, "output": (proc.stdout or "").strip()}


def rel_path(path: Path) -> str:
    return str(path.relative_to(ROOT))


def sanitize_batch_id(batch_id: str) -> str:
    safe = re.sub(r"[^A-Za-z0-9._-]+", "-", batch_id).strip("-")
    if not safe:
        raise SystemExit("RED: empty batch id after sanitization")
    return safe


def extract_heading_block(text: str, heading: str, max_chars: int = 1800) -> str:
    pattern = re.compile(rf"^##\s+{re.escape(heading)}\s*$", re.M)
    match = pattern.search(text)
    if not match:
        return ""
    start = match.end()
    next_heading = re.search(r"^##\s+", text[start:], re.M)
    end = start + next_heading.start() if next_heading else len(text)
    return text[start:end].strip()[:max_chars]


def extract_candidate_terms(batch_id: str, prompt_text: str) -> list[str]:
    terms: list[str] = []
    terms.extend(part for part in re.split(r"[-_]", batch_id) if len(part) >= 4 and not part.isdigit())
    for line in prompt_text.splitlines()[:80]:
        stripped = line.strip(" #`:-")
        if stripped.startswith("<!--") or stripped.endswith("-->"):
            continue
        if stripped in {"Batch ID", "Train ID and title", "Batch role in train", "Upstream dependencies"}:
            continue
        if 6 <= len(stripped) <= 100:
            terms.append(stripped)
    for match in re.finditer(r"`([^`]{4,90})`", prompt_text[:MAX_TEXT_CHARS]):
        terms.append(match.group(1))
    seen: set[str] = set()
    result: list[str] = []
    for term in terms:
        normalized = re.sub(r"\s+", " ", term).strip()
        if normalized and normalized.lower() not in seen:
            result.append(normalized)
            seen.add(normalized.lower())
        if len(result) >= 16:
            break
    return result


def extract_repo_paths(text: str) -> list[str]:
    matches = re.findall(
        r"(?:Native|Sources|AppUI|scripts|docs|prompts|tests|tools|build)/[A-Za-z0-9_./@+-]+",
        text,
    )
    seen: set[str] = set()
    paths: list[str] = []
    for match in matches:
        clean = match.rstrip("):,.;`")
        if clean not in seen and (ROOT / clean).exists():
            paths.append(clean)
            seen.add(clean)
        if len(paths) >= 20:
            break
    return paths


def semble_search_root(prompt_text: str, codegraph_output: str) -> str:
    paths = extract_repo_paths(prompt_text) + extract_repo_paths(codegraph_output)
    for path in paths:
        candidate = ROOT / path
        if candidate.is_dir():
            return path
        if candidate.is_file():
            parent = candidate.parent
            if parent != ROOT:
                return rel_path(parent)
    for fallback in ["Native/AmbitionsTests", "Native/Ambitions", "Sources", "docs/codex", "scripts"]:
        if (ROOT / fallback).exists():
            return fallback
    return "."


def build_task_query(batch_id: str, prompt_text: str, terms: list[str]) -> str:
    title = next((line.strip("# ").strip() for line in prompt_text.splitlines() if line.strip().startswith("#")), "")
    allowed = extract_heading_block(prompt_text, "Allowed files/directories", max_chars=900)
    validation = extract_heading_block(prompt_text, "Validation commands", max_chars=600)
    parts = [
        f"Batch {batch_id}",
        title,
        "Key terms: " + ", ".join(terms[:10]),
        "Allowed boundary: " + allowed,
        "Validation: " + validation,
    ]
    return "\n".join(part for part in parts if part.strip())[:2500]


def compact_output(output: str, max_chars: int = MAX_TOOL_CHARS) -> str:
    clean = output.strip()
    if len(clean) <= max_chars:
        return clean
    return clean[:max_chars].rstrip() + "\n...[truncated]"


def build_packet(batch_id: str, prompt_path: Path, output_path: Path | None) -> tuple[dict[str, Any], str, Path]:
    prompt_text = prompt_path.read_text(encoding="utf-8")
    preflight = load_preflight().build_payload()
    safe_batch = sanitize_batch_id(batch_id)
    md_path = output_path or REPORT_DIR / f"{safe_batch}-repo-intelligence-context.md"
    json_path = md_path.with_suffix(".json")

    terms = extract_candidate_terms(batch_id, prompt_text)
    task_query = build_task_query(batch_id, prompt_text, terms)
    codegraph = preflight["tools"]["codegraph"]
    semble = preflight["tools"]["semble"]

    commands: list[dict[str, Any]] = []
    codegraph_context = {"exit_code": 0, "output": "CodeGraph unavailable; fallback to direct repo search/read."}
    codegraph_query = {"exit_code": 0, "output": "CodeGraph unavailable; fallback to direct repo search/read."}
    semble_search = {"exit_code": 0, "output": "Semble unavailable; fallback to rg/find/direct reads."}

    if codegraph.get("available") and codegraph.get("index_present"):
        codegraph_path = codegraph["path"]
        codegraph_context_cmd = [
            codegraph_path,
            "context",
            task_query,
            "--path",
            ".",
            "--max-nodes",
            "45",
            "--max-code",
            "4",
            "--format",
            "markdown",
        ]
        codegraph_context = run(codegraph_context_cmd, timeout=DEFAULT_TIMEOUT)
        commands.append({"tool": "codegraph", "command": " ".join(codegraph_context_cmd), **codegraph_context})
        if terms:
            codegraph_query_cmd = [codegraph_path, "query", terms[0], "--path", ".", "--limit", "12"]
            codegraph_query = run(codegraph_query_cmd, timeout=20)
            commands.append({"tool": "codegraph", "command": " ".join(codegraph_query_cmd), **codegraph_query})

    if semble.get("available"):
        semble_path = semble["path"]
        search_root = semble_search_root(prompt_text, codegraph_context["output"])
        search_query = " ".join(terms[:6]) or task_query
        semble_cmd = [
            semble_path,
            "search",
            search_query[:700],
            search_root,
            "--include-text-files",
            "-k",
            "5",
            "-m",
            "bm25",
        ]
        semble_search = run(semble_cmd, timeout=30)
        commands.append({"tool": "semble", "command": " ".join(semble_cmd), **semble_search})

    allowed = extract_heading_block(prompt_text, "Allowed files/directories")
    forbidden = extract_heading_block(prompt_text, "Forbidden files/directories")
    validation = extract_heading_block(prompt_text, "Validation commands")

    packet = {
        "batch_id": batch_id,
        "timestamp_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "prompt": rel_path(prompt_path),
        "status": "GREEN" if preflight["status"] == "GREEN" else preflight["status"],
        "preflight_status": preflight["status"],
        "tools": preflight["tools"],
        "terms": terms,
        "task_query": task_query,
        "commands": commands,
        "output_markdown": rel_path(md_path),
        "non_claims": [
            "This is advisory retrieval context only.",
            "Tool output is not source truth, validation proof, release proof, accessibility proof, privacy proof, performance proof, or completion proof.",
            "Any accepted finding must be verified by direct file reads, validation output, tests, or existing Ambitions proof artifacts.",
        ],
    }

    sections = [
        f"# Repo Intelligence Context: {batch_id}",
        "",
        f"Status: {packet['status']}",
        f"Prompt: `{packet['prompt']}`",
        f"Timestamp UTC: {packet['timestamp_utc']}",
        "",
        "## Use Boundary",
        "This packet is advisory context for faster planning and narrower implementation. It must not override `docs/truth/*`, the frozen prompt boundary, direct file inspection, validation output, tests, or proof artifacts.",
        "",
        "## Prompt Boundary Extract",
        "### Allowed",
        allowed or "Not found in prompt.",
        "",
        "### Forbidden",
        forbidden or "Not found in prompt.",
        "",
        "### Validation",
        validation or "Not found in prompt.",
        "",
        "## Query Terms",
        "\n".join(f"- {term}" for term in terms) or "- none",
        "",
        "## CodeGraph Context",
        f"Exit code: {codegraph_context['exit_code']}",
        "",
        "```text",
        compact_output(codegraph_context["output"]),
        "```",
        "",
        "## CodeGraph Symbol Query",
        f"Exit code: {codegraph_query['exit_code']}",
        "",
        "```text",
        compact_output(codegraph_query["output"], max_chars=2500),
        "```",
        "",
        "## Semble Retrieval",
        f"Exit code: {semble_search['exit_code']}",
        "",
        "```text",
        compact_output(semble_search["output"]),
        "```",
        "",
        "## Required Verification",
        "- Resolve any useful finding to concrete repo paths.",
        "- Read the actual files before editing.",
        "- Use validation/test output for proof claims.",
        "- Record CodeGraph/Semble usage and directly verified findings in the final fields.",
        "",
        "## Non-Claims",
        *[f"- {item}" for item in packet["non_claims"]],
        "",
    ]

    md_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.write_text("\n".join(sections), encoding="utf-8")
    json_path.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return packet, "\n".join(sections), md_path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", required=True)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--out", help="optional markdown output path")
    parser.add_argument("--print-path", action="store_true", help="print only the markdown path")
    args = parser.parse_args()

    prompt_path = (ROOT / args.prompt).resolve() if not Path(args.prompt).is_absolute() else Path(args.prompt)
    if not prompt_path.exists():
        raise SystemExit(f"RED: prompt missing: {args.prompt}")
    output_path = None
    if args.out:
        output_path = (ROOT / args.out).resolve() if not Path(args.out).is_absolute() else Path(args.out)

    packet, _markdown, md_path = build_packet(args.batch, prompt_path, output_path)
    if args.print_path:
        print(rel_path(md_path))
    else:
        print(f"{packet['status']}: wrote {rel_path(md_path)}")
        print(f"{packet['status']}: wrote {rel_path(md_path.with_suffix('.json'))}")
    return 1 if packet["status"] == "RED" else 0


if __name__ == "__main__":
    raise SystemExit(main())
