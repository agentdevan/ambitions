#!/usr/bin/env python3
"""Fail-closed guard against parallel Ambitions implementations."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT_ROOT = ROOT / "build/reports/parallel-implementation-guard"
BOOTSTRAP_BATCHES = {
    # Initial install creates the owner maps, ledgers, and guard itself.
    "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01",
    # Addendum install creates champion merge queue and concept lock inputs.
    "AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02",
}
REQUIRED_INPUTS = [
    "docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md",
    "docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md",
    "docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md",
    "docs/codex/CHAMPION_SELECTION_GATE.md",
    "docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md",
    "docs/codex/canonical-owner-map.yml",
    "docs/codex/parallel-guard-concept-registry.yml",
    "docs/codex/existing-code-champion-coverage.yml",
]
CONCEPT_LOCK_REGISTRY = ROOT / "docs/codex/concept-lock-registry.yml"
OLD_TERMS = ["DayTimelineRail", "Hero Step Panel", "HeroStepPanel", "Plan tab", "Profile tab", "Captures tab", "dashboard", "AI recommends", "next best move", "best next move", "overdue", "failed", "streak", "score"]
RUNTIME_TERMS = ["recommendation", "compiler", "private runtime", "capture routing", "source ledger", "proof", "receipt", "replay", "closure", "recovery", "step candidate", "goal relevance", "time planning", "momentum reflow", "runtime learning", "start here", "personal runtime", "what ambitions knows"]
DECL_RE = re.compile(r"^\s*(?:public\s+|private\s+|fileprivate\s+|internal\s+)?(?:struct|class|actor|enum|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)


def run_git(args: list[str]) -> tuple[int, str, str]:
    result = subprocess.run(["git", *args], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    return result.returncode, result.stdout, result.stderr


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def changed_files(base: str | None) -> list[str]:
    if not base:
        raise RuntimeError("post guard requires --changed-from")
    code, out, err = run_git(["diff", "--name-status", base, "--", ".", ":(exclude).codex/runs/**"])
    if code != 0:
        raise RuntimeError(err.strip() or "git diff failed")
    other_code, other, _ = run_git(["ls-files", "--others", "--exclude-standard", "--", ".", ":(exclude).codex/runs/**"])
    rows = [line.strip() for line in out.splitlines() if line.strip()]
    if other_code == 0:
        rows.extend(f"A\t{line}" for line in other.splitlines() if line.strip())
    return sorted(set(rows))


def is_untracked(path: str) -> bool:
    code, _, _ = run_git(["ls-files", "--error-unmatch", path])
    return code != 0


def concept_hits(text: str) -> list[str]:
    concepts = ["Today", "Reality Meridian", "Start Here", "Recommended Step", "Step", "GoalThread", "Commitment", "Capture", "Atmosphere Composer", "Time", "LifeShape", "You", "User System Profile", "Personal Runtime", "SourceRecord", "Receipt", "Proof", "ReplayTrace", "Closure", "Recovery", "Momentum Reflow", "Recommendation", "RuntimeLearningSignal", "Parser", "Repository", "Service", "ViewModel", "SwiftUI View", "Design primitive"]
    return sorted({term for term in concepts if re.search(re.escape(term), text, re.IGNORECASE)})


def load_concept_locks() -> list[dict[str, object]]:
    if not CONCEPT_LOCK_REGISTRY.exists():
        return []
    locks: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    current_list_key: str | None = None
    for raw in read(CONCEPT_LOCK_REGISTRY).splitlines():
        line = raw.rstrip()
        if line.startswith("  - concept_id:"):
            if current:
                locks.append(current)
            current = {"concept_id": line.split(":", 1)[1].strip().strip('"')}
            current_list_key = None
        elif current and line.startswith("    ") and ":" in line:
            key, value = line.strip().split(":", 1)
            value = value.strip()
            if value == "":
                current[key] = []
                current_list_key = key
            elif value.startswith("[") and value.endswith("]"):
                current[key] = [item.strip().strip('"') for item in value.strip("[]").split(",") if item.strip()]
                current_list_key = None
            else:
                current[key] = value.strip('"')
                current_list_key = None
        elif current and current_list_key and line.strip().startswith("- "):
            current.setdefault(current_list_key, []).append(line.strip()[2:].strip('"'))
    if current:
        locks.append(current)
    return locks


def lock_terms(lock: dict[str, object]) -> list[str]:
    terms = [str(lock.get("concept_name", "")), str(lock.get("concept_id", "")).replace("_", " ")]
    for key in ("blocked_paths", "allowed_paths"):
        values = lock.get(key, [])
        if isinstance(values, str):
            values = [values]
        for value in values:
            terms.append(str(value))
    return [term for term in terms if term]


def batch_allowed_for_lock(batch: str, prompt_text: str, lock: dict[str, object]) -> bool:
    prefixes = lock.get("allowed_batch_prefixes", [])
    if isinstance(prefixes, str):
        prefixes = [prefixes]
    if any(batch.startswith(str(prefix)) for prefix in prefixes):
        return True
    concept = str(lock.get("concept_name", ""))
    return "Champion Merge" in prompt_text and concept and concept.lower() in prompt_text.lower()


def touched_locks(text: str, locks: list[dict[str, object]]) -> list[dict[str, object]]:
    lowered = text.lower()
    return [lock for lock in locks if any(term.lower() in lowered for term in lock_terms(lock))]


def batch_allows_bootstrap(batch: str, bootstrap: bool) -> bool:
    return bootstrap and batch in BOOTSTRAP_BATCHES


def required_inputs_missing(bootstrap_allowed: bool) -> list[str]:
    missing = [path for path in REQUIRED_INPUTS if not (ROOT / path).exists()]
    return [] if bootstrap_allowed else missing


def is_runtime_affecting(text: str) -> bool:
    lowered = text.lower()
    return any(term in lowered for term in RUNTIME_TERMS)


def owner_map_changed(rows: list[str]) -> bool:
    return any(row.split("\t")[-1] == "docs/codex/canonical-owner-map.yml" for row in rows)


def load_owner_paths() -> list[tuple[str, list[str]]]:
    owner_map = ROOT / "docs/codex/canonical-owner-map.yml"
    owners: list[tuple[str, list[str]]] = []
    current_owner: str | None = None
    for raw in read(owner_map).splitlines():
        line = raw.strip()
        if line.startswith("- owner_id:"):
            current_owner = line.split(":", 1)[1].strip().strip('"')
        elif current_owner and line.startswith("canonical_paths:"):
            paths = re.findall(r'"([^"]+)"', line)
            owners.append((current_owner, paths))
    return owners


def canonical_owner_for_path(path: str) -> str | None:
    for owner_id, canonical_paths in load_owner_paths():
        if any(path == owner_path or path.startswith(f"{owner_path}/") for owner_path in canonical_paths):
            return owner_id
    return None


def classify_new_type(path: str, batch: str) -> str:
    if path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/"):
        return "test-only"
    if "Preview" in path or "/Previews/" in path:
        return "preview-only"
    if path.startswith("build/") or path.endswith(".generated.swift"):
        return "generated/supporting"
    if batch.startswith("AMB-CHAMPION-MERGE-"):
        owner_id = canonical_owner_for_path(path)
        if owner_id:
            return f"canonical owner: {owner_id}"
    if path.startswith(("Native/Ambitions/", "Sources/", "AppUI/Sources/")):
        return "requires canonical owner"
    return "supporting"


def support_only_changed_paths(rows: list[str]) -> bool:
    paths = [row.split("\t", 1)[-1] for row in rows]
    return bool(paths) and all(is_support_path(path) for path in paths)


def is_support_path(path: str) -> bool:
    support_prefixes = (
        "docs/audits/",
        "docs/codex/",
        "docs/truth/",
        "build/reports/",
        "prompts/",
        "scripts/",
    )
    return path.startswith(support_prefixes) or path == "Makefile"


def is_active_source_path(path: str) -> bool:
    return path.startswith(("Native/Ambitions/", "Sources/", "AppUI/Sources/"))


def write_reports(batch: str, phase: str, status: str, payload: dict) -> tuple[Path, Path]:
    REPORT_ROOT.mkdir(parents=True, exist_ok=True)
    safe_batch = re.sub(r"[^A-Za-z0-9._-]+", "-", batch)
    json_path = REPORT_ROOT / f"{safe_batch}-{phase}.json"
    md_path = REPORT_ROOT / f"{safe_batch}-{phase}.md"
    payload["status"] = status
    payload["json_report"] = str(json_path.relative_to(ROOT))
    payload["markdown_report"] = str(md_path.relative_to(ROOT))
    json_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = [
        "# Parallel Implementation Guard",
        "",
        f"Status: {status}",
        f"Batch: {batch}",
        f"Phase: {phase}",
        "",
        f"Concepts detected: {', '.join(payload.get('concepts_detected', [])) or 'none'}",
        f"Canonical owners found: {payload.get('canonical_owners_found', 'unknown')}",
        f"New types detected: {', '.join(payload.get('new_types_detected', [])) or 'none'}",
        "",
        "## Duplicate Risks",
        *(f"- {item}" for item in payload.get("duplicate_risks", []) or ["none"]),
        "",
        "## Supersession Updates Required",
        *(f"- {item}" for item in payload.get("supersession_updates_required", []) or ["none"]),
        "",
        "## Runtime Wiring Gaps",
        *(f"- {item}" for item in payload.get("runtime_wiring_gaps", []) or ["none"]),
        "",
        "## Old-Term Violations",
        *(f"- {item}" for item in payload.get("old_term_violations", []) or ["none"]),
        "",
        "## Locked Concepts",
        *(f"- {item}" for item in payload.get("locked_concepts_touched", []) or ["none"]),
        "",
        "## Blocked Concept Violations",
        *(f"- {item}" for item in payload.get("blocked_concept_violations", []) or ["none"]),
        "",
        "## Concept Lock Updates Required",
        *(f"- {item}" for item in payload.get("concept_lock_updates_required", []) or ["none"]),
        "",
        f"Required next action: {payload.get('required_next_action', 'none')}",
        f"Report path: {md_path}",
    ]
    md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return json_path, md_path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", choices=["pre", "post"], required=True)
    parser.add_argument("--batch", required=True)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--changed-from")
    parser.add_argument("--bootstrap-install", action="store_true")
    parser.add_argument("--batch-type", choices=["source-changing", "docs-install", "guard-repair", "audit-only", "proof-only"], default="source-changing")
    parser.add_argument("--allow-yellow", action="store_true")
    args = parser.parse_args()
    bootstrap_allowed = batch_allows_bootstrap(args.batch, args.bootstrap_install)
    defects: list[str] = []
    warnings: list[str] = []
    payload: dict = {
        "batch": args.batch,
        "phase": args.phase,
        "batch_type": args.batch_type,
        "bootstrap_install": args.bootstrap_install,
        "diff_base": args.changed_from,
        "changed_files_inspected": [],
        "new_files": [],
        "deleted_files": [],
        "new_types_detected": [],
        "owner_classification": {},
        "concepts_detected": [],
        "duplicate_risks": [],
        "supersession_updates_required": [],
        "runtime_wiring_gaps": [],
        "old_term_violations": [],
        "locked_concepts_touched": [],
        "allowed_merge_batch": False,
        "blocked_concept_violations": [],
        "concept_lock_updates_required": [],
    }
    if args.bootstrap_install and not bootstrap_allowed:
        defects.append("--bootstrap-install is allowed only for the guard install batch")
    missing = required_inputs_missing(bootstrap_allowed)
    defects.extend(f"required guard input missing: {path}" for path in missing)
    prompt_path = Path(args.prompt)
    if not prompt_path.is_absolute():
        prompt_path = ROOT / args.prompt
    prompt_text = read(prompt_path)
    if not prompt_text:
        defects.append(f"prompt missing or empty: {args.prompt}")
    payload["concepts_detected"] = concept_hits(prompt_text)
    locks = load_concept_locks()
    prompt_locks = touched_locks(prompt_text, locks)
    payload["locked_concepts_touched"] = [str(lock.get("concept_id")) for lock in prompt_locks]
    for lock in prompt_locks:
        if batch_allowed_for_lock(args.batch, prompt_text, lock):
            payload["allowed_merge_batch"] = True
        elif args.batch_type == "source-changing":
            violation = f"{args.batch} touches locked concept {lock.get('concept_id')} without Champion Merge authorization"
            payload["blocked_concept_violations"].append(violation)
            defects.append(violation)
    payload["canonical_owners_found"] = "yes" if (ROOT / "docs/codex/canonical-owner-map.yml").exists() else "missing"
    old_terms = [term for term in OLD_TERMS if re.search(re.escape(term), prompt_text, re.IGNORECASE)]
    champion_merge_prompt = args.batch.startswith("AMB-CHAMPION-MERGE-") and (
        "retire old active terminology" in prompt_text.lower()
        or "supersession" in prompt_text.lower()
        or "parallel implementations" in prompt_text.lower()
    )
    if old_terms and args.batch_type == "source-changing" and not bootstrap_allowed and not champion_merge_prompt:
        payload["old_term_violations"].extend(f"old active terminology in prompt: {term}" for term in old_terms)
        defects.extend(f"old active terminology in prompt: {term}" for term in old_terms)
    elif old_terms and not champion_merge_prompt:
        warnings.extend(f"old terminology requires historical/supporting context only: {term}" for term in old_terms)
    runtime_prompt = is_runtime_affecting(prompt_text)
    if runtime_prompt and args.batch_type == "source-changing" and not bootstrap_allowed:
        for required in ["SourceRecord", "Receipt", "ReplayTrace"]:
            if required.lower() not in prompt_text.lower():
                defects.append(f"runtime-affecting prompt lacks required wiring term: {required}")
        if "what ambitions knows" not in prompt_text.lower() and "you inspection" not in prompt_text.lower():
            defects.append("runtime-affecting prompt lacks You / What Ambitions knows inspection requirement")
    if args.phase == "post":
        try:
            rows = changed_files(args.changed_from)
        except RuntimeError as exc:
            defects.append(f"post guard cannot determine changed files: {exc}")
            rows = []
        payload["changed_files_inspected"] = rows
        changed_path_text = "\n".join(row.split("\t", 1)[-1] for row in rows)
        changed_locks = touched_locks(changed_path_text, locks)
        for lock in changed_locks:
            concept_id = str(lock.get("concept_id"))
            if concept_id not in payload["locked_concepts_touched"]:
                payload["locked_concepts_touched"].append(concept_id)
            if not batch_allowed_for_lock(args.batch, prompt_text, lock) and args.batch_type == "source-changing":
                violation = f"changed files touch locked concept {concept_id} without allowed merge batch"
                payload["blocked_concept_violations"].append(violation)
                defects.append(violation)
        if changed_locks and not (ROOT / "docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md").exists():
            payload["concept_lock_updates_required"].append("CHAMPION_MERGE_QUEUE.md required when locked concepts are touched")
            defects.append("locked concept touched but CHAMPION_MERGE_QUEUE.md is missing")
        changed_text = ""
        introduced_source_text = ""
        for row in rows:
            status, path = row.split("\t", 1) if "\t" in row else ("M", row)
            if status.startswith("D"):
                payload["deleted_files"].append(path)
            if status.startswith("A"):
                payload["new_files"].append(path)
            file_text = read(ROOT / path)
            changed_text += "\n" + file_text
            if status.startswith("A") and is_untracked(path):
                introduced_path_text = file_text
            else:
                introduced_path_text = "\n".join(
                    line[1:]
                    for line in run_git(["diff", "--unified=0", args.changed_from or "", "--", path])[1].splitlines()
                    if line.startswith("+") and not line.startswith("+++")
                )
            if is_active_source_path(path):
                introduced_source_text += "\n" + introduced_path_text
            for name in DECL_RE.findall(introduced_path_text):
                payload["new_types_detected"].append(name)
                classification = classify_new_type(path, args.batch)
                payload["owner_classification"][name] = classification
                if classification == "requires canonical owner" and not bootstrap_allowed:
                    defects.append(f"new Swift type requires canonical owner classification: {name} in {path}")
        if payload["deleted_files"]:
            warnings.extend(f"deleted file inspected: {path}" for path in payload["deleted_files"])
        source_old_terms = [term for term in OLD_TERMS if re.search(re.escape(term), introduced_source_text, re.IGNORECASE)]
        for term in source_old_terms:
            if not support_only_changed_paths(rows):
                payload["old_term_violations"].append(f"old active terminology introduced in changed source: {term}")
                defects.append(f"old active terminology introduced in changed source: {term}")
            else:
                warnings.append(f"old terminology appears in support/audit context: {term}")
        if owner_map_changed(rows):
            owner_text = read(ROOT / "docs/codex/canonical-owner-map.yml")
            required_owner_change_terms = ["reason", "duplicate_search_result", "champion_score_entry", "affected_concept", "no_parallel_justification"]
            for term in required_owner_change_terms:
                if term not in owner_text:
                    defects.append(f"canonical-owner-map.yml changed without required field: {term}")
        if is_runtime_affecting(changed_text) and args.batch_type == "source-changing":
            for required in ["SourceRecord", "Receipt", "ReplayTrace"]:
                if required.lower() not in changed_text.lower():
                    payload["runtime_wiring_gaps"].append(f"changed runtime-affecting files lack {required}")
            if payload["runtime_wiring_gaps"]:
                defects.extend(payload["runtime_wiring_gaps"])
    status = "RED" if defects else ("YELLOW" if warnings else "GREEN")
    payload["defects"] = defects
    payload["warnings"] = warnings
    payload["required_next_action"] = "repair Red blockers" if defects else ("record accepted Yellow boundary" if warnings else "continue")
    _, md_path = write_reports(args.batch, args.phase, status, payload)
    print(f"Status: {status}")
    print(f"Batch: {args.batch}")
    print(f"Phase: {args.phase}")
    print(f"Concepts detected: {', '.join(payload['concepts_detected']) or 'none'}")
    print(f"Canonical owners found: {payload['canonical_owners_found']}")
    print(f"New types detected: {', '.join(payload['new_types_detected']) or 'none'}")
    print(f"Duplicate risks: {len(payload['duplicate_risks'])}")
    print(f"Supersession updates required: {len(payload['supersession_updates_required'])}")
    print(f"Runtime wiring gaps: {len(payload['runtime_wiring_gaps'])}")
    print(f"Old-term violations: {len(payload['old_term_violations'])}")
    print(f"Locked concepts touched: {', '.join(payload['locked_concepts_touched']) or 'none'}")
    print(f"Allowed merge batch: {payload['allowed_merge_batch']}")
    print(f"Blocked concept violations: {len(payload['blocked_concept_violations'])}")
    print(f"Concept lock updates required: {len(payload['concept_lock_updates_required'])}")
    print(f"Required next action: {payload['required_next_action']}")
    print(f"Report path: {md_path}")
    if status == "GREEN":
        return 0
    if status == "YELLOW":
        return 0 if args.allow_yellow else 2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
