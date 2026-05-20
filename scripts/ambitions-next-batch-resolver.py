#!/usr/bin/env python3
"""Authoritative next-batch resolver for Ambitions runner trains.

The resolver selects only runnable prompts with the Ambitions runner metadata
header. It never executes Codex directly; execution stays with
scripts/ambitions-codex-train.sh and the supervisor/Makefile wrappers.
"""
from __future__ import annotations

import argparse
import json
import re
import tempfile
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PROMPTS_ROOT = ROOT / "prompts/batches"
RUNNER = "scripts/ambitions-codex-train.sh"
REQUIRED_HEADER = (
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
)
RUNNABLE_CLASSIFICATIONS = {"executable_now", "active", "queued", "active_partial"}
NON_RUNNABLE_CLASSIFICATIONS = {
    "historical_complete_do_not_run",
    "absorbed_as_overlay",
    "conditional_trigger_only",
    "deleted_obsolete",
    "evidence_preserved_minimal",
    "unknown_requires_repair",
}
QUEUE_CLASSIFICATION_SOURCES = [
    ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json",
    ROOT / "docs/codex/AMB_REMAINING_BATCH_REFERENCE.json",
]
STATUS_SOURCES = [
    ROOT / "docs/codex/BATCH_REGISTRY.md",
    ROOT / ".codex/reports/current-run-state.md",
    ROOT / ".codex/reports/current-batch-train-state.md",
    ROOT / "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md",
    ROOT / "docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md",
]


@dataclass(frozen=True)
class PromptInfo:
    batch_id: str
    prompt_path: Path
    runnable: bool
    missing_metadata: tuple[str, ...]


@dataclass(frozen=True)
class Candidate:
    batch_id: str
    prompt_path: Path
    source: str
    reason: str
    priority: int


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def load_json(path: Path) -> Any:
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def iter_json_dicts(value: Any) -> list[dict[str, Any]]:
    found: list[dict[str, Any]] = []
    if isinstance(value, dict):
        found.append(value)
        for child in value.values():
            found.extend(iter_json_dicts(child))
    elif isinstance(value, list):
        for child in value:
            found.extend(iter_json_dicts(child))
    return found


@lru_cache(maxsize=1)
def queue_classifications() -> dict[str, str]:
    classifications: dict[str, str] = {}
    for source in QUEUE_CLASSIFICATION_SOURCES:
        data = load_json(source)
        if data is None:
            continue
        for item in iter_json_dicts(data):
            batch_id = str(item.get("id") or item.get("batch_id") or "").strip()
            classification = str(item.get("classification") or "").strip()
            if batch_id and classification and batch_id not in classifications:
                classifications[batch_id] = classification
    return classifications


def queue_classification(batch_id: str) -> str | None:
    return queue_classifications().get(batch_id)


def classification_is_runnable(batch_id: str) -> bool:
    classification = queue_classification(batch_id)
    if not classification:
        return True
    if classification in NON_RUNNABLE_CLASSIFICATIONS:
        return False
    return classification in RUNNABLE_CLASSIFICATIONS


def prompt_metadata(path: Path) -> tuple[bool, tuple[str, ...]]:
    head = "\n".join(read_text(path).splitlines()[:12])
    missing = tuple(line for line in REQUIRED_HEADER if line not in head)
    return not missing, missing


def prompt_index(root: Path = ROOT) -> dict[str, PromptInfo]:
    prompts_root = root / "prompts/batches"
    found: dict[str, PromptInfo] = {}
    if not prompts_root.exists():
        return found
    for path in sorted(prompts_root.glob("**/*.md")):
        if not path.is_file():
            continue
        runnable, missing = prompt_metadata(path)
        batch_id = path.stem
        # Prefer the shallower prompt if duplicate ids exist, then stable path order.
        current = found.get(batch_id)
        info = PromptInfo(batch_id=batch_id, prompt_path=path, runnable=runnable, missing_metadata=missing)
        if current is None or (len(path.parts), rel(path)) < (len(current.prompt_path.parts), rel(current.prompt_path)):
            found[batch_id] = info
    return found


def valid_prompt(batch_id: str, prompts: dict[str, PromptInfo]) -> PromptInfo | None:
    info = prompts.get(batch_id)
    if info and info.runnable:
        return info
    return None


def strip_title(batch: str) -> str:
    text = batch.strip().strip("`")
    if not text:
        return ""
    return text.split()[0].strip("`")


def parse_active_batch_yml(path: Path) -> list[str]:
    text = read_text(path)
    ids: list[str] = []
    for key in ("next_eligible_batch", "batch", "previous_batch"):
        match = re.search(rf"^\s*{re.escape(key)}:\s*[\"']?([^\"'\n]+)", text, re.MULTILINE)
        if match:
            ids.append(strip_title(match.group(1)))
    return ids


def parse_next_eligible(path: Path) -> list[str]:
    text = read_text(path)
    ids: list[str] = []
    for match in re.finditer(r"^Next eligible batch:\s*(.+)$", text, re.MULTILINE):
        ids.append(strip_title(match.group(1)))
    return ids


def completion_report_paths(batch_id: str, root: Path = ROOT) -> list[Path]:
    batch_slug = batch_id.lower()
    paths = [
        root / f".codex/reports/{batch_id}.md",
        root / f"docs/codex/reports/{batch_id}.md",
        root / f"docs/audits/{batch_slug}-batch-closeout-report.md",
        root / f"docs/audits/{batch_id}-batch-closeout-report.md",
        root / f"docs/audits/{batch_slug}-report.md",
        root / f"docs/audits/{batch_id}-report.md",
    ]
    return [path for path in paths if path.exists()]


def report_is_closed(path: Path) -> bool:
    text = read_text(path)
    head = "\n".join(text.splitlines()[:40])
    tail = "\n".join(text.splitlines()[-20:])
    scoped = f"{head}\n{tail}"
    if re.search(r"(?im)^\s*status:\s*green\b", scoped):
        return True
    if re.search(r"(?im)^\s*status:\s*(complete\s*/\s*)?accepted yellow\b", scoped):
        return True
    if re.search(r"(?im)^\s*status:\s*complete\s*/\s*green\b", scoped):
        return True
    if re.search(r"(?ims)^##\s+Status\s*\n\s*GREEN\b", scoped):
        return True
    if re.search(r"(?ims)^##\s+Status\s*\n\s*ACCEPTED YELLOW\b", scoped):
        return True
    if re.search(r"(?ims)^##\s+Status\s*\n\s*YELLOW\b", scoped):
        return False
    if re.search(r"(?ims)^##\s+Status\s*\n\s*RED\b", scoped):
        return False
    if re.search(r"(?im)^\s*status:\s*yellow\b", scoped):
        return False
    if re.search(r"(?im)^\s*status:\s*red\b", scoped):
        return False
    if re.search(r"(?im)^STATUS:\s*GREEN\b", scoped):
        return True
    if re.search(r"(?im)^STATUS:\s*ACCEPTED YELLOW\b", scoped):
        return True
    if re.search(r"(?im)^STATUS:\s*YELLOW\b", scoped):
        return False
    return False


def runner_status_closed(batch_id: str, root: Path = ROOT) -> bool:
    run_root = root / ".codex/runs" / batch_id
    if not run_root.exists():
        return False
    status_files = sorted(run_root.glob("*/runner-status.env"), reverse=True)
    for path in status_files:
        text = read_text(path)
        if re.search(r"(?m)^FINAL_STATUS=GREEN\s*$", text):
            return True
        if re.search(r"(?m)^FINAL_STATUS=ACCEPTED YELLOW\s*$", text):
            return True
        if re.search(r"(?m)^FINAL_STATUS=(YELLOW|RED|UNKNOWN)\s*$", text):
            return False
    return False


def batch_completed(batch_id: str, root: Path = ROOT) -> bool:
    for path in completion_report_paths(batch_id, root=root):
        if report_is_closed(path):
            return True
    if runner_status_closed(batch_id, root=root):
        return True

    escaped = re.escape(batch_id)
    complete_patterns = [
        rf"\b{escaped}\b[^\n]{{0,180}}\bComplete\s*/\s*Green\b",
        rf"\b{escaped}\b[^\n]{{0,180}}\bComplete\s*/\s*Accepted Yellow\b",
        rf"\b{escaped}\b[^\n]{{0,180}}\bcomplete(?:d)?\s*/\s*Green\b",
        rf"\b{escaped}\b[^\n]{{0,180}}\bclosed\s+Green\b",
        rf"\b{escaped}\b[^\n]{{0,180}}\bclosed\s+Accepted Yellow\b",
        rf"\b{escaped}\b[^\n]{{0,180}}\bhistorical complete\b",
    ]
    yellow_open = re.compile(rf"\b{escaped}\b[^\n]{{0,180}}\bStatus:\s*Yellow\b", re.IGNORECASE)
    status_sources = STATUS_SOURCES if root == ROOT else [
        root / "docs/codex/BATCH_REGISTRY.md",
        root / ".codex/reports/current-run-state.md",
        root / ".codex/reports/current-batch-train-state.md",
        root / "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md",
        root / "docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md",
    ]
    for source in status_sources:
        text = read_text(source)
        if yellow_open.search(text):
            return False
        if any(re.search(pattern, text, re.IGNORECASE) for pattern in complete_patterns):
            return True
    return False


def add_candidate(
    candidates: list[Candidate],
    batch_id: str,
    source: str,
    reason: str,
    priority: int,
    prompts: dict[str, PromptInfo],
) -> None:
    info = valid_prompt(batch_id, prompts)
    if info is None:
        return
    if not classification_is_runnable(batch_id):
        return
    if batch_completed(batch_id):
        return
    candidates.append(Candidate(batch_id=batch_id, prompt_path=info.prompt_path, source=source, reason=reason, priority=priority))


def codex_os_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    for path in (ROOT / "build/codex-os/batch-selection.json", ROOT / "build/codex-os/next-action.json"):
        data = load_json(path)
        if not isinstance(data, dict):
            continue
        classification = str(data.get("classification") or data.get("decision") or "")
        if classification and classification not in RUNNABLE_CLASSIFICATIONS:
            continue
        batch_id = data.get("selected_batch") or data.get("batch_id") or data.get("next_batch_id")
        prompt_file = data.get("prompt_file") or data.get("prompt") or data.get("prompt_path")
        if isinstance(batch_id, str) and batch_id.strip():
            add_candidate(candidates, strip_title(batch_id), rel(path), "active Codex OS selection", 10, prompts)
        elif isinstance(prompt_file, str) and prompt_file.strip():
            prompt = ROOT / prompt_file
            if prompt.exists():
                add_candidate(candidates, prompt.stem, rel(path), "active Codex OS prompt selection", 10, prompts)
    return candidates


def active_state_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    for batch_id in parse_active_batch_yml(ROOT / ".codex/state/active-batch.yml"):
        add_candidate(candidates, batch_id, ".codex/state/active-batch.yml", "active batch mirror", 20, prompts)
    return candidates


def active_train_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    for path in (ROOT / ".codex/reports/current-run-state.md", ROOT / ".codex/reports/current-batch-train-state.md"):
        for batch_id in parse_next_eligible(path):
            add_candidate(candidates, batch_id, rel(path), "current active train state", 30, prompts)
    ledger = ROOT / ".codex/state/global-train-attempt-ledger.md"
    text = read_text(ledger)
    match = re.search(r"selected child batch:\s*([A-Z0-9][A-Z0-9._-]+)", text)
    if match and "status: finalization-required" in text[: match.start() + 2000]:
        add_candidate(candidates, f"{match.group(1)}-FINALIZE-01", rel(ledger), "finalization-required ledger entry", 31, prompts)
    return candidates


def ids_from_order_file(path: Path) -> list[str]:
    text = read_text(path)
    ids: list[str] = []
    for match in re.finditer(r"`([A-Z0-9][A-Z0-9._-]+)`", text):
        ids.append(match.group(1))
    for match in re.finditer(r"^\s*\d+\.\s+([A-Z0-9][A-Z0-9._-]+)\b", text, re.MULTILINE):
        ids.append(match.group(1))
    for match in re.finditer(r"\|\s*`?([A-Z0-9][A-Z0-9._-]+)`?\s*\|", text):
        ids.append(match.group(1))
    ordered = []
    seen = set()
    for batch_id in ids:
        if batch_id not in seen:
            ordered.append(batch_id)
            seen.add(batch_id)
    return ordered


def train_order_files(train_dir: Path) -> list[Path]:
    priority_names = (
        "EXECUTION-ORDER",
        "EXECUTION_ORDER",
        "MANIFEST",
        "README",
        "STATUS",
    )
    files = [path for path in sorted(train_dir.glob("*.md")) if path.is_file()]
    return sorted(files, key=lambda path: (next((i for i, name in enumerate(priority_names) if name in path.name), 99), path.name))


def train_priority(train_dir: Path) -> int:
    # Post-23 is a live repair/audit bridge and must be discovered before broad
    # fallback implementation trains when its Yellow evidence is still open.
    name = train_dir.as_posix()
    if "post-23-truth-audit" in name:
        return 0
    if "amb-fe-be" in name:
        return 1
    if "post99-ui-suite" in name:
        return 2
    return 10


def train_manifest_candidates(prompts: dict[str, PromptInfo], train_filter: str | None = None) -> list[Candidate]:
    candidates: list[Candidate] = []
    root = ROOT / "docs/codex/batch-trains"
    if not root.exists():
        return candidates
    train_dirs = sorted({path.parent for path in root.glob("**/*.md") if path.parent != root}, key=lambda p: (train_priority(p), rel(p)))
    train_dirs.extend(path for path in sorted(root.iterdir()) if path.is_file() and path.suffix == ".md")
    for train in train_dirs:
        if train_filter and train_filter not in rel(train):
            continue
        ordered_ids: list[str] = []
        if train.is_file():
            ordered_ids = ids_from_order_file(train)
            source = rel(train)
        else:
            for order_file in train_order_files(train):
                ordered_ids.extend(ids_from_order_file(order_file))
            source = rel(train)
        if not ordered_ids and train.is_dir():
            prompt_dir = PROMPTS_ROOT / train.name
            if prompt_dir.exists():
                ordered_ids = [path.stem for path in sorted(prompt_dir.glob("*.md"))]
        seen = set()
        for batch_id in ordered_ids:
            if batch_id in seen:
                continue
            seen.add(batch_id)
            before = len(candidates)
            add_candidate(candidates, batch_id, source, "train manifest/order", 40 + train_priority(train), prompts)
            if len(candidates) > before:
                break
    return candidates


def nested_prompt_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    for info in sorted(prompts.values(), key=lambda p: (len(p.prompt_path.parts), rel(p.prompt_path))):
        if not info.runnable:
            continue
        if batch_completed(info.batch_id):
            continue
        if info.prompt_path.parent == PROMPTS_ROOT:
            continue
        candidates.append(Candidate(info.batch_id, info.prompt_path, "prompts/batches/**/*.md", "nested runnable prompt scan", 50))
        break
    return candidates


def legacy_queue_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    path = ROOT / "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
    data = load_json(path)
    if not isinstance(data, dict):
        return candidates
    for item in data.get("batches", []):
        if not isinstance(item, dict):
            continue
        classification = str(item.get("classification", ""))
        if classification in NON_RUNNABLE_CLASSIFICATIONS:
            continue
        if classification not in RUNNABLE_CLASSIFICATIONS:
            continue
        batch_id = str(item.get("id", "")).strip()
        before = len(candidates)
        add_candidate(candidates, batch_id, rel(path), f"legacy flat queue classification: {classification}", 60, prompts)
        if len(candidates) > before:
            break
    return candidates


def flat_prompt_candidates(prompts: dict[str, PromptInfo]) -> list[Candidate]:
    candidates: list[Candidate] = []
    for info in sorted(prompts.values(), key=lambda p: rel(p.prompt_path)):
        if not info.runnable:
            continue
        if info.prompt_path.parent != PROMPTS_ROOT:
            continue
        if batch_completed(info.batch_id):
            continue
        candidates.append(Candidate(info.batch_id, info.prompt_path, "prompts/batches/*.md", "legacy flat runnable prompt fallback", 70))
        break
    return candidates


def resolve(*, ignore_live_state: bool = False, train_filter: str | None = None, legacy_only: bool = False) -> dict[str, Any]:
    prompts = prompt_index()
    if legacy_only:
        stages = [legacy_queue_candidates, flat_prompt_candidates]
    elif train_filter:
        stages = [lambda p: train_manifest_candidates(p, train_filter=train_filter)]
    elif ignore_live_state:
        stages = [
            train_manifest_candidates,
            nested_prompt_candidates,
            legacy_queue_candidates,
            flat_prompt_candidates,
        ]
    else:
        stages = [
            codex_os_candidates,
            active_state_candidates,
            active_train_candidates,
            train_manifest_candidates,
            nested_prompt_candidates,
            legacy_queue_candidates,
            flat_prompt_candidates,
        ]
    candidates: list[Candidate] = []
    for stage in stages:
        candidates.extend(stage(prompts))
        if candidates:
            break
    if not candidates:
        return {
            "batch_id": None,
            "next_batch_id": None,
            "prompt_path": None,
            "prompt": None,
            "runner_command": None,
            "selection_source": None,
            "reason": "no executable next batch found",
            "metadata_required": list(REQUIRED_HEADER),
            "direct_codex_execution": "not introduced",
            "hard_red_reasons": ["unable_to_resolve_next_batch"],
        }
    selected = sorted(candidates, key=lambda c: (c.priority, rel(c.prompt_path)))[0]
    prompt_rel = rel(selected.prompt_path)
    return {
        "batch_id": selected.batch_id,
        "next_batch_id": selected.batch_id,
        "prompt_path": prompt_rel,
        "prompt": prompt_rel,
        "runner_command": f"{RUNNER} {selected.batch_id} {prompt_rel}",
        "make_command": f"make batch BATCH={selected.batch_id} PROMPT={prompt_rel}",
        "selection_source": selected.source,
        "reason": selected.reason,
        "metadata_required": list(REQUIRED_HEADER),
        "direct_codex_execution": "not introduced",
        "hard_red_reasons": [],
    }


def print_human(route: dict[str, Any]) -> None:
    if route.get("batch_id"):
        print(f"Next batch: {route['batch_id']}")
        print(f"Prompt: {route['prompt_path']}")
        print(f"Runner: {route['runner_command']}")
        print(f"Source: {route['selection_source']}")
        print(f"Reason: {route['reason']}")
    else:
        print("Next batch: none")
        print("Prompt: none")
        print(f"Reason: {route['reason']}")


def self_test() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "prompts/batches/post-23-truth-audit").mkdir(parents=True)
        (root / "prompts/batches/legacy").mkdir(parents=True)
        good = "\n".join(REQUIRED_HEADER) + "\n\n# Batch\n"
        bad = "<!-- AMBITIONS_RUNNER_REQUIRED: true -->\n# Missing metadata\n"
        nested = root / "prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md"
        legacy = root / "prompts/batches/LEGACY-FLAT-01.md"
        invalid = root / "prompts/batches/post-23-truth-audit/AMB-POST23-02-BAD.md"
        report = root / "docs/audits/amb-fe-be-integrated-proof-99-report.md"
        codex_report = root / ".codex/reports/AMB-FE-BE-PREFLIGHT-00.md"
        runner_status = root / ".codex/runs/AMB-FE-BE-CONTRACT-FREEZE-01/20260520T000000Z/runner-status.env"
        nested.write_text(good, encoding="utf-8")
        legacy.write_text(good, encoding="utf-8")
        invalid.write_text(bad, encoding="utf-8")
        report.parent.mkdir(parents=True)
        report.write_text("# Report\n\nStatus: Green\n\nBatch: AMB-FE-BE-INTEGRATED-PROOF-99\n", encoding="utf-8")
        codex_report.parent.mkdir(parents=True)
        codex_report.write_text("# Report\n\n## Status\n\nGREEN\n", encoding="utf-8")
        runner_status.parent.mkdir(parents=True)
        runner_status.write_text("BATCH_ID=AMB-FE-BE-CONTRACT-FREEZE-01\nFINAL_STATUS=GREEN\n", encoding="utf-8")
        idx = prompt_index(root)
        assert idx["AMB-POST23-01-TRUTH-AUDIT"].runnable
        assert idx["LEGACY-FLAT-01"].runnable
        assert not idx["AMB-POST23-02-BAD"].runnable
        assert batch_completed("AMB-FE-BE-INTEGRATED-PROOF-99", root=root)
        assert batch_completed("AMB-FE-BE-PREFLIGHT-00", root=root)
        assert batch_completed("AMB-FE-BE-CONTRACT-FREEZE-01", root=root)
    print("self-test: nested runnable prompt discovered")
    print("self-test: legacy flat prompt discovered")
    print("self-test: missing runner metadata rejected")
    print("self-test: audit report closeout path discovered")
    print("self-test: codex report closeout path discovered")
    print("self-test: runner status closeout discovered")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Resolve the next Ambitions runner batch.")
    parser.add_argument("--json", action="store_true", help="Print the selected route as JSON.")
    parser.add_argument("--dry-run", action="store_true", help="Alias for default non-executing output.")
    parser.add_argument("--field", choices=["batch_id", "prompt_path", "runner_command", "reason"], help="Print one selected field.")
    parser.add_argument("--self-test", action="store_true", help="Run resolver fixture checks.")
    parser.add_argument("--prefer-hbi", action="store_true", help="Compatibility flag; resolver priority remains source-order driven.")
    parser.add_argument("--ignore-live-state", action="store_true", help="Dry-run fallback sources without Codex OS, active-batch, or run-state mirrors.")
    parser.add_argument("--train", help="Dry-run a specific train manifest path fragment, for example post-23-truth-audit.")
    parser.add_argument("--legacy-only", action="store_true", help="Dry-run only the legacy flat queue fallback.")
    args = parser.parse_args()

    if args.self_test:
        return self_test()
    route = resolve(ignore_live_state=args.ignore_live_state, train_filter=args.train, legacy_only=args.legacy_only)
    if args.field:
        print(route.get(args.field) or "")
    elif args.json:
        print(json.dumps(route, indent=2, sort_keys=True))
    else:
        print_human(route)
    return 1 if route.get("hard_red_reasons") else 0


if __name__ == "__main__":
    raise SystemExit(main())
