#!/usr/bin/env python3
"""Build a compact advisory repo-intelligence context packet for one batch."""
from __future__ import annotations

import argparse
import hashlib
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
MAX_OWNER_CANDIDATES = 6
MAX_DIRECT_PATH_CANDIDATES = 16
MAX_PROOF_ROWS = 14
MAX_CODE_SNIPPETS = 4
MAX_OUTPUT_CHARS = 22000
DEFAULT_TIMEOUT = 45
OWNER_MAP = ROOT / "docs/codex/canonical-owner-map.yml"
COVERAGE = ROOT / "docs/codex/existing-code-champion-coverage.yml"
CONCEPT_LOCKS = ROOT / "docs/codex/concept-lock-registry.yml"
CONCEPT_REGISTRY = ROOT / "docs/codex/parallel-guard-concept-registry.yml"
RUNTIME_WIRES = [
    "source input",
    "output object",
    "SourceRecord",
    "Receipt",
    "ReplayTrace",
    "user control",
    "You / What Ambitions knows inspection path",
    "reset/delete path",
    "deterministic test",
    "proof artifact",
    "no cloud LLM",
    "no silent sensitive use",
    "no silent schedule mutation",
]
ACTIVE_SOURCE_PREFIXES = ("Native/Ambitions/", "Sources/", "AppUI/Sources/")


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


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def git_head() -> str:
    result = run(["git", "rev-parse", "HEAD"], timeout=10)
    return result["output"].splitlines()[0] if result["exit_code"] == 0 and result["output"] else "UNKNOWN"


def yaml_scalar(value: str) -> Any:
    value = value.strip()
    if value in {"true", "false"}:
        return value == "true"
    if value.startswith("[") and value.endswith("]"):
        return [item.strip().strip('"') for item in value.strip("[]").split(",") if item.strip()]
    return value.strip('"')


def parse_yaml_records(path: Path, record_marker: str) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    records: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    list_key: str | None = None
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if stripped.startswith(f"- {record_marker}:"):
            if current:
                records.append(current)
            current = {record_marker: yaml_scalar(stripped.split(":", 1)[1])}
            list_key = None
        elif current and line.startswith("    ") and ":" in stripped:
            key, value = stripped.split(":", 1)
            value = value.strip()
            if value:
                current[key] = yaml_scalar(value)
                list_key = None
            else:
                current[key] = []
                list_key = key
        elif current and list_key and stripped.startswith("- "):
            current.setdefault(list_key, []).append(yaml_scalar(stripped[2:]))
    if current:
        records.append(current)
    return records


def load_owner_map() -> list[dict[str, Any]]:
    return parse_yaml_records(OWNER_MAP, "owner_id")


def load_coverage() -> dict[str, dict[str, Any]]:
    return {str(entry.get("path", "")): entry for entry in parse_yaml_records(COVERAGE, "path")}


def load_concept_locks() -> list[dict[str, Any]]:
    return parse_yaml_records(CONCEPT_LOCKS, "concept_id")


def load_concept_registry() -> dict[str, list[str]]:
    if not CONCEPT_REGISTRY.exists():
        return {"aliases": [], "runtime_affecting_concepts": []}
    aliases: list[str] = []
    runtime_terms: list[str] = []
    section = ""
    pending_from = ""
    for raw in CONCEPT_REGISTRY.read_text(encoding="utf-8", errors="replace").splitlines():
        stripped = raw.strip()
        if stripped == "aliases:":
            section = "aliases"
        elif stripped == "runtime_affecting_concepts:":
            section = "runtime"
        elif section == "aliases" and stripped.startswith("- from:"):
            pending_from = yaml_scalar(stripped.split(":", 1)[1])
            aliases.append(str(pending_from))
        elif section == "aliases" and stripped.startswith("to:") and pending_from:
            aliases.append(str(yaml_scalar(stripped.split(":", 1)[1])))
        elif section == "runtime" and stripped.startswith("- "):
            runtime_terms.append(str(yaml_scalar(stripped[2:])))
    return {"aliases": sorted(set(aliases)), "runtime_affecting_concepts": sorted(set(runtime_terms))}


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


def extract_repo_paths(text: str, *, existing_only: bool = True) -> list[str]:
    matches = re.findall(
        r"(?:Native|Sources|AppUI|scripts|docs|prompts|tests|tools|build)/[A-Za-z0-9_./@+-]+",
        text,
    )
    seen: set[str] = set()
    paths: list[str] = []
    for match in matches:
        clean = match.rstrip("):,.;`")
        if clean not in seen and ((ROOT / clean).exists() or not existing_only):
            paths.append(clean)
            seen.add(clean)
        if len(paths) >= 20:
            break
    return paths


def path_kind(path: str) -> str:
    if path.endswith(".swift") and path.startswith(("Native/AmbitionsTests/", "Native/AmbitionsUITests/")):
        return "test"
    if path.endswith(".swift") and path.startswith(ACTIVE_SOURCE_PREFIXES):
        return "active_source"
    if path.startswith("build/reports/"):
        return "proof"
    if path.startswith("docs/"):
        return "docs"
    if path.startswith("scripts/"):
        return "script"
    return "supporting"


def owner_for_path(path: str, owners: list[dict[str, Any]]) -> str:
    for owner in owners:
        for prefix in owner.get("canonical_paths", []) or []:
            prefix_text = str(prefix)
            if path == prefix_text or path.startswith(f"{prefix_text}/"):
                return str(owner.get("owner_id", ""))
    return ""


def locks_for_path_or_text(path: str, text: str, locks: list[dict[str, Any]]) -> list[dict[str, Any]]:
    hay = f"{path}\n{text}".lower()
    hits: list[dict[str, Any]] = []
    for lock in locks:
        terms = [
            str(lock.get("concept_id", "")).replace("_", " "),
            str(lock.get("concept_name", "")),
            str(lock.get("canonical_owner_id", "")),
        ]
        for key in ("blocked_paths", "allowed_paths"):
            values = lock.get(key, []) or []
            if isinstance(values, str):
                values = [values]
            terms.extend(str(value) for value in values)
        if any(term and term.lower() in hay for term in terms):
            hits.append(lock)
    return hits


def likely_runtime_affecting(text: str, owners: list[dict[str, Any]], registry: dict[str, list[str]]) -> bool:
    lowered = text.lower()
    if any(term.lower() in lowered for term in registry.get("runtime_affecting_concepts", [])):
        return True
    for owner in owners:
        if owner.get("runtime_affecting") and str(owner.get("owner_id", "")).lower() in lowered:
            return True
    return False


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


def cache_key(batch_id: str, prompt_path: Path, preflight: dict[str, Any]) -> dict[str, Any]:
    codegraph = preflight.get("tools", {}).get("codegraph", {})
    return {
        "batch_id": batch_id,
        "prompt_sha256": sha256_file(prompt_path),
        "head": git_head(),
        "codegraph_status": {
            "available": bool(codegraph.get("available")),
            "index_present": bool(codegraph.get("index_present")),
            "path": codegraph.get("path", ""),
            "version": codegraph.get("version", ""),
        },
    }


def reusable_cached_packet(json_path: Path, md_path: Path, key: dict[str, Any]) -> bool:
    if not json_path.exists() or not md_path.exists():
        return False
    try:
        existing = json.loads(json_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return False
    return existing.get("cache_key") == key


def collect_candidate_paths(prompt_text: str, codegraph_output: str, codegraph_query: str, semble_output: str) -> list[str]:
    paths: list[str] = []
    for source in (prompt_text, codegraph_output, codegraph_query, semble_output):
        paths.extend(extract_repo_paths(source, existing_only=False))
    seen: set[str] = set()
    result: list[str] = []
    for path in paths:
        if path not in seen:
            result.append(path)
            seen.add(path)
        if len(result) >= MAX_DIRECT_PATH_CANDIDATES:
            break
    return result


def build_direct_path_candidates(paths: list[str], prompt_text: str, owners: list[dict[str, Any]], coverage: dict[str, dict[str, Any]], locks: list[dict[str, Any]]) -> list[dict[str, Any]]:
    candidates: list[dict[str, Any]] = []
    for path in paths:
        exists = (ROOT / path).exists()
        coverage_row = coverage.get(path)
        canonical_owner = str(coverage_row.get("canonical_owner_id", "")) if coverage_row else owner_for_path(path, owners)
        classification = str(coverage_row.get("classification", "")) if coverage_row else ""
        lock_hits = locks_for_path_or_text(path, "", locks)
        advisory_risks: list[str] = []
        if path_kind(path) == "active_source" and not coverage_row:
            advisory_risks.append("unclassified active source")
        if any(str(lock.get("blocked_status", "")) not in {"CLEARED", "CLOSED_GREEN"} for lock in lock_hits):
            advisory_risks.append("locked concept touched")
        candidates.append(
            {
                "path": path,
                "exists": exists,
                "kind": path_kind(path),
                "canonical_owner_id": canonical_owner or "unknown",
                "classification": classification or "UNCLASSIFIED",
                "classification_maturity": "mature"
                if coverage_row and classification != "UNKNOWN_REQUIRES_OWNER_REVIEW"
                else "owner_map_directory"
                if canonical_owner and (ROOT / path).is_dir()
                else "needs_owner_review",
                "target_membership": coverage_row.get("target_membership", "") if coverage_row else "",
                "lock_impact": [str(lock.get("concept_id", "")) for lock in lock_hits],
                "advisory_risks": advisory_risks,
                "requires_direct_verification": True,
            }
        )
    return candidates


def score_owner(owner: dict[str, Any], prompt_text: str, paths: list[str], terms: list[str]) -> tuple[int, list[str]]:
    score = 0
    reasons: list[str] = []
    owner_id = str(owner.get("owner_id", ""))
    hay = prompt_text.lower()
    if owner_id.lower() in hay:
        score += 5
        reasons.append("prompt names owner id")
    for field in ("area", "affected_concept", "reason"):
        value = str(owner.get(field, ""))
        if value and value.lower() in hay:
            score += 3
            reasons.append(f"prompt matches {field}")
            break
    for term in terms:
        if term.lower() in str(owner).lower():
            score += 1
    for path in paths:
        for prefix in owner.get("canonical_paths", []) or []:
            if path == prefix or path.startswith(f"{prefix}/"):
                score += 6
                reasons.append(f"path under {prefix}")
                break
        for prefix in owner.get("canonical_tests", []) or []:
            if path == prefix or path.startswith(f"{prefix}/"):
                score += 2
                reasons.append(f"test path under {prefix}")
                break
        for prefix in owner.get("canonical_proof", []) or []:
            if path == prefix or path.startswith(f"{prefix}/"):
                score += 2
                reasons.append(f"proof path under {prefix}")
                break
    return score, sorted(set(reasons))


def build_owner_candidates(owners: list[dict[str, Any]], prompt_text: str, paths: list[str], terms: list[str]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    scored: list[tuple[int, dict[str, Any], list[str]]] = []
    for owner in owners:
        score, reasons = score_owner(owner, prompt_text, paths, terms)
        scored.append((score, owner, reasons))
    scored.sort(key=lambda item: item[0], reverse=True)
    candidates: list[dict[str, Any]] = []
    rejected: list[dict[str, Any]] = []
    for score, owner, reasons in scored:
        compact = {
            "owner_id": owner.get("owner_id", ""),
            "area": owner.get("area", ""),
            "score": score,
            "confidence": "high" if score >= 8 else "medium" if score >= 3 else "low",
            "confidence_reasons": reasons or ["no direct path/concept match"],
            "canonical_paths": owner.get("canonical_paths", []),
            "canonical_tests": owner.get("canonical_tests", []),
            "canonical_proof": owner.get("canonical_proof", []),
            "runtime_affecting": bool(owner.get("runtime_affecting")),
            "required_wires": {
                "SourceRecord": bool(owner.get("requires_source_record")),
                "Receipt": bool(owner.get("requires_receipt")),
                "ReplayTrace": bool(owner.get("requires_replay_trace")),
                "You inspection": bool(owner.get("requires_you_inspection")),
                "reset/delete": bool(owner.get("reset_delete_required")),
            },
            "notes": owner.get("no_parallel_justification", ""),
        }
        if score > 0 and len(candidates) < MAX_OWNER_CANDIDATES:
            candidates.append(compact)
        elif len(rejected) < 6:
            compact["rejected_owner_note"] = "lower confidence than nearer mature owner candidates"
            rejected.append(compact)
    return candidates, rejected


def validation_commands_from_prompt(prompt_text: str) -> list[str]:
    block = extract_heading_block(prompt_text, "Validation commands", max_chars=1800)
    commands: list[str] = []
    for raw in block.splitlines():
        stripped = raw.strip(" -`")
        if stripped and stripped not in {"bash", "sh", "text"} and not stripped.startswith("#"):
            commands.append(stripped)
    return commands[:8]


def build_proof_matrix(owner_candidates: list[dict[str, Any]], validation_commands: list[str]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for owner in owner_candidates:
        proof_roots = owner.get("canonical_proof", []) or []
        tests = owner.get("canonical_tests", []) or []
        sources = owner.get("canonical_paths", []) or []
        for proof_root in proof_roots or [""]:
            discovered = proof_root if proof_root and (ROOT / proof_root).exists() else ""
            missing: list[str] = []
            if not discovered:
                missing.append("proof artifact not found")
            if not tests:
                missing.append("test path not declared")
            if not validation_commands:
                missing.append("validation command not found in prompt")
            rows.append(
                {
                    "owner": owner.get("owner_id", ""),
                    "concept": owner.get("area", ""),
                    "expected_proof": proof_root,
                    "discovered_proof_path": discovered,
                    "validation_command": validation_commands[0] if validation_commands else "",
                    "source_path": sources[0] if sources else "",
                    "test_path": tests[0] if tests else "",
                    "missing_evidence": missing,
                    "advisory_only": True,
                    "requires_direct_verification": True,
                }
            )
            if len(rows) >= MAX_PROOF_ROWS:
                return rows
    return rows


def build_wiring_checklist(prompt_text: str, owner_candidates: list[dict[str, Any]], proof_rows: list[dict[str, Any]], runtime_affecting: bool) -> list[dict[str, Any]]:
    if not runtime_affecting and not any(owner.get("runtime_affecting") for owner in owner_candidates):
        return []
    lowered = prompt_text.lower()
    source_hint = next((row.get("source_path", "") for row in proof_rows if row.get("source_path")), "")
    test_hint = next((row.get("test_path", "") for row in proof_rows if row.get("test_path")), "")
    proof_hint = next((row.get("expected_proof", "") for row in proof_rows if row.get("expected_proof")), "")
    rows: list[dict[str, Any]] = []
    for wire in RUNTIME_WIRES:
        token = wire.lower().split("/")[0].strip()
        present = token in lowered or wire.lower() in lowered
        rows.append(
            {
                "wire": wire,
                "status": "candidate_found" if present else "missing_hint",
                "likely_source_path": source_hint,
                "likely_test_path": test_hint if "test" in wire.lower() or not present else "",
                "likely_proof_path": proof_hint if "proof" in wire.lower() or not present else "",
                "phase_01_warning": not present,
                "advisory_only": True,
            }
        )
    return rows


def build_parallel_risks(prompt_text: str, codegraph_text: str, owner_candidates: list[dict[str, Any]], registry: dict[str, list[str]]) -> list[dict[str, Any]]:
    hay = f"{prompt_text}\n{codegraph_text}".lower()
    risks: list[dict[str, Any]] = []
    patterns = {
        "second engine/provider/repository": ["second ", "new engine", "new provider", "new repository", "parallel "],
        "detached DTO graph": ["dto", "snapshot model", "portable snapshot"],
        "parallel receipt/proof/replay path": ["second receipt", "second proof", "second replay", "parallel proof", "parallel replay"],
        "new runtime owner": ["new runtime", "runtime owner", "recommendation engine"],
    }
    for label, terms in patterns.items():
        if any(term in hay for term in terms):
            risks.append(
                {
                    "risk": label,
                    "severity": "advisory_red",
                    "suggested_existing_owner": owner_candidates[0].get("owner_id", "unknown") if owner_candidates else "unknown",
                    "reason": "prompt or graph output contains duplicate-like implementation language",
                    "advisory_only": True,
                }
            )
    for alias in registry.get("aliases", []):
        if alias and alias.lower() in hay:
            risks.append(
                {
                    "risk": f"legacy or duplicate-like term: {alias}",
                    "severity": "advisory_yellow",
                    "suggested_existing_owner": owner_candidates[0].get("owner_id", "unknown") if owner_candidates else "unknown",
                    "reason": "concept registry alias matched prompt/graph output",
                    "advisory_only": True,
                }
            )
    return risks[:10]


def advisory_red_risks(path_candidates: list[dict[str, Any]], lock_hits: list[dict[str, Any]]) -> list[dict[str, Any]]:
    risks: list[dict[str, Any]] = []
    for candidate in path_candidates:
        for risk in candidate.get("advisory_risks", []):
            risks.append(
                {
                    "risk": risk,
                    "path": candidate["path"],
                    "canonical_owner_id": candidate.get("canonical_owner_id", "unknown"),
                    "advisory_only": True,
                    "requires_direct_verification": True,
                }
            )
    for lock in lock_hits:
        if str(lock.get("blocked_status", "")) not in {"CLEARED", "CLOSED_GREEN"}:
            risks.append(
                {
                    "risk": "locked concept touched",
                    "concept_id": lock.get("concept_id", ""),
                    "canonical_owner_id": lock.get("canonical_owner_id", ""),
                    "blocked_status": lock.get("blocked_status", ""),
                    "no_claim_boundary": lock.get("no_claim_boundary", ""),
                    "advisory_only": True,
                    "requires_direct_verification": True,
                }
            )
    seen: set[str] = set()
    unique: list[dict[str, Any]] = []
    for risk in risks:
        key = json.dumps(risk, sort_keys=True)
        if key not in seen:
            unique.append(risk)
            seen.add(key)
    return unique


def build_packet(batch_id: str, prompt_path: Path, output_path: Path | None, *, use_cache: bool = True) -> tuple[dict[str, Any], str, Path]:
    prompt_text = prompt_path.read_text(encoding="utf-8")
    preflight = load_preflight().build_payload()
    safe_batch = sanitize_batch_id(batch_id)
    md_path = output_path or REPORT_DIR / f"{safe_batch}-repo-intelligence-context.md"
    json_path = md_path.with_suffix(".json")
    key = cache_key(batch_id, prompt_path, preflight)
    if use_cache and reusable_cached_packet(json_path, md_path, key):
        packet = json.loads(json_path.read_text(encoding="utf-8"))
        markdown = md_path.read_text(encoding="utf-8")
        return packet, markdown, md_path

    terms = extract_candidate_terms(batch_id, prompt_text)
    task_query = build_task_query(batch_id, prompt_text, terms)
    codegraph = preflight["tools"]["codegraph"]
    semble = preflight["tools"]["semble"]
    owners = load_owner_map()
    coverage = load_coverage()
    locks = load_concept_locks()
    registry = load_concept_registry()

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
    validation_commands = validation_commands_from_prompt(prompt_text)
    candidate_paths = collect_candidate_paths(prompt_text, codegraph_context["output"], codegraph_query["output"], semble_search["output"])
    direct_path_candidates = build_direct_path_candidates(candidate_paths, prompt_text, owners, coverage, locks)
    owner_candidates, rejected_owner_candidates = build_owner_candidates(owners, prompt_text, candidate_paths, terms)
    proof_lookup_matrix = build_proof_matrix(owner_candidates, validation_commands)
    runtime_affecting = likely_runtime_affecting(prompt_text, owners, registry) or any(owner.get("runtime_affecting") for owner in owner_candidates[:2])
    runtime_wiring_checklist = build_wiring_checklist(prompt_text, owner_candidates, proof_lookup_matrix, runtime_affecting)
    lock_hits: list[dict[str, Any]] = []
    for path in candidate_paths:
        lock_hits.extend(locks_for_path_or_text(path, "", locks))
    lock_hits.extend(locks_for_path_or_text("", prompt_text, locks))
    parallel_system_risks = build_parallel_risks(prompt_text, f"{codegraph_context['output']}\n{codegraph_query['output']}", owner_candidates, registry)
    red_risks = advisory_red_risks(direct_path_candidates, lock_hits)
    requires_direct_verification = [
        "Read each accepted candidate source/test/proof path directly before editing.",
        "Run guard scripts before treating any owner/classification finding as Green.",
        "Treat proof lookup rows as locators only until validation output or proof artifacts are inspected.",
        "Confirm runtime wiring rows against actual diff when source changes touch runtime-affecting owners.",
    ]

    packet = {
        "batch_id": batch_id,
        "timestamp_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "prompt": rel_path(prompt_path),
        "cache_key": key,
        "budgets": {
            "max_owner_candidates": MAX_OWNER_CANDIDATES,
            "max_direct_path_candidates": MAX_DIRECT_PATH_CANDIDATES,
            "max_proof_rows": MAX_PROOF_ROWS,
            "max_code_snippets": MAX_CODE_SNIPPETS,
            "max_output_chars": MAX_OUTPUT_CHARS,
        },
        "status": "GREEN" if preflight["status"] == "GREEN" else preflight["status"],
        "preflight_status": preflight["status"],
        "tools": preflight["tools"],
        "terms": terms,
        "task_query": task_query,
        "commands": commands,
        "output_markdown": rel_path(md_path),
        "tool_suggestions": [
            {
                "tool": "CodeGraph",
                "use_for": "symbol context, nearest owners, callers/callees, impact radius, affected-test hints",
                "status": "available" if codegraph.get("available") and codegraph.get("index_present") else "fallback_to_direct_search",
                "advisory_only": True,
            },
            {
                "tool": "Semble",
                "use_for": "scoped snippet retrieval for likely roots from prompt/CodeGraph",
                "status": "available" if semble.get("available") else "fallback_to_rg",
                "advisory_only": True,
            },
        ],
        "direct_path_candidates": direct_path_candidates,
        "owner_candidates": owner_candidates,
        "rejected_owner_candidates": rejected_owner_candidates,
        "proof_candidates": proof_lookup_matrix,
        "proof_lookup_matrix": proof_lookup_matrix,
        "runtime_wiring_checklist": runtime_wiring_checklist,
        "parallel_system_risks": parallel_system_risks,
        "advisory_red_risks": red_risks,
        "requires_direct_verification": requires_direct_verification,
        "accepted_findings_policy": {
            "phase_01": "Phase 01 must say which owner/proof/wiring findings were accepted only after direct verification.",
            "phase_02": "Phase 02 may use only the Phase 01 accepted bounded subset, not raw advisory packet findings.",
            "phase_03": "Phase 03 must verify accepted findings against the actual diff, guard reports, and proof output.",
            "final_gate": "No advisory-only finding may be cited as proof.",
        },
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
        "## Implementation Intelligence Summary",
        f"- Owner candidates: {len(owner_candidates)}",
        f"- Direct path candidates: {len(direct_path_candidates)}",
        f"- Proof lookup rows: {len(proof_lookup_matrix)}",
        f"- Runtime wiring rows: {len(runtime_wiring_checklist)}",
        f"- Advisory Red risks: {len(red_risks)}",
        "",
        "## Advisory Red Risks",
        "\n".join(f"- {risk.get('risk')}: {risk.get('path') or risk.get('concept_id')} -> {risk.get('canonical_owner_id', 'unknown')}" for risk in red_risks) or "- none",
        "",
        "## Owner Candidates",
        "\n".join(
            f"- {owner['owner_id']} ({owner['confidence']}, score {owner['score']}): {', '.join(owner['confidence_reasons'][:3])}"
            for owner in owner_candidates
        ) or "- none",
        "",
        "## Direct Path Candidates",
        "\n".join(
            f"- `{item['path']}` owner={item['canonical_owner_id']} classification={item['classification']} maturity={item['classification_maturity']} locks={','.join(item['lock_impact']) or '-'}"
            for item in direct_path_candidates
        ) or "- none",
        "",
        "## Proof Lookup Matrix",
        "\n".join(
            f"- owner={row['owner']} proof=`{row['expected_proof'] or '-'}` discovered=`{row['discovered_proof_path'] or '-'}` test=`{row['test_path'] or '-'}` command=`{row['validation_command'] or '-'}` advisory_only=true"
            for row in proof_lookup_matrix
        ) or "- none",
        "",
        "## Runtime Wiring Checklist",
        "\n".join(
            f"- {row['wire']}: {row['status']} source=`{row['likely_source_path'] or '-'}` test=`{row['likely_test_path'] or '-'}` proof=`{row['likely_proof_path'] or '-'}`"
            for row in runtime_wiring_checklist
        ) or "- not runtime-affecting by advisory scan",
        "",
        "## Parallel System Risks",
        "\n".join(
            f"- {risk['severity']}: {risk['risk']} -> extend `{risk['suggested_existing_owner']}`"
            for risk in parallel_system_risks
        ) or "- none",
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
        *[f"- {item}" for item in requires_direct_verification],
        "- Record CodeGraph/Semble usage and directly verified accepted findings in the final fields.",
        "",
        "## Non-Claims",
        *[f"- {item}" for item in packet["non_claims"]],
        "",
    ]

    md_path.parent.mkdir(parents=True, exist_ok=True)
    markdown = "\n".join(sections)
    if len(markdown) > MAX_OUTPUT_CHARS:
        markdown = markdown[:MAX_OUTPUT_CHARS].rstrip() + "\n\n...[packet markdown truncated to budget]\n"
    md_path.write_text(markdown, encoding="utf-8")
    json_path.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return packet, markdown, md_path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", required=True)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--out", help="optional markdown output path")
    parser.add_argument("--no-cache", action="store_true", help="regenerate even when prompt hash, HEAD, and CodeGraph status match")
    parser.add_argument("--print-path", action="store_true", help="print only the markdown path")
    args = parser.parse_args()

    prompt_path = (ROOT / args.prompt).resolve() if not Path(args.prompt).is_absolute() else Path(args.prompt)
    if not prompt_path.exists():
        raise SystemExit(f"RED: prompt missing: {args.prompt}")
    output_path = None
    if args.out:
        output_path = (ROOT / args.out).resolve() if not Path(args.out).is_absolute() else Path(args.out)

    packet, _markdown, md_path = build_packet(args.batch, prompt_path, output_path, use_cache=not args.no_cache)
    if args.print_path:
        print(rel_path(md_path))
    else:
        print(f"{packet['status']}: wrote {rel_path(md_path)}")
        print(f"{packet['status']}: wrote {rel_path(md_path.with_suffix('.json'))}")
    return 1 if packet["status"] == "RED" else 0


if __name__ == "__main__":
    raise SystemExit(main())
