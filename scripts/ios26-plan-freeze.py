#!/usr/bin/env python3
"""Compile the IOS26 flagship manifest into frozen train orchestration files."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml"
RUNNER = ROOT / "scripts/ios26-flagship-run-sequential.sh"
RUNBOOK = ROOT / "docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md"
IOS26_DIR = ROOT / "docs/codex/ios26"
PLANNING_DIR = ROOT / "build/reports/ios26-planning"
PROMPT_DIR = ROOT / "prompts/batches"
HASH_FILE = IOS26_DIR / "IOS26_PROMPT_FREEZE_HASHES.json"
HEADER = [
    "<!-- AMBITIONS_RUNNER_REQUIRED: true -->",
    "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->",
    "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->",
]
BATCH_RE = re.compile(r"(IOS26-T\d{2}[A-Z]?-B\d{2})")
TRAIN_RE = re.compile(r"TRAIN_\d{2}[A-Z]?")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def parse_list(value: str) -> list[str]:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [item.strip() for item in inner.split(",") if item.strip()]
    return []


def parse_manifest() -> dict[str, object]:
    data: dict[str, object] = {
        "claim_boundaries": [],
        "stop_rules": [],
        "proof_artifact_roots": [],
        "dependencies": {},
        "trains": [],
    }
    section = ""
    current_train: dict[str, object] | None = None
    in_batches = False
    for raw in MANIFEST.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if not line.startswith(" ") and stripped.endswith(":"):
            section = stripped[:-1]
            current_train = None
            in_batches = False
            continue
        if not line.startswith(" ") and ":" in stripped:
            key, value = stripped.split(":", 1)
            data[key] = value.strip()
            continue
        if section in {"claim_boundaries", "stop_rules", "proof_artifact_roots", "installed_tooling"} and line.startswith("  - "):
            data.setdefault(section, []).append(stripped.removeprefix("- "))  # type: ignore[union-attr]
        elif section == "dependencies" and line.startswith("  TRAIN_"):
            key, value = stripped.split(":", 1)
            data["dependencies"][key] = parse_list(value)  # type: ignore[index]
        elif section == "trains":
            if line.startswith("  - id: "):
                current_train = {"id": stripped.removeprefix("- id: "), "title": "", "status": "", "batches": []}
                data["trains"].append(current_train)  # type: ignore[union-attr]
                in_batches = False
            elif current_train is not None and line.startswith("    title: "):
                current_train["title"] = stripped.removeprefix("title: ")
            elif current_train is not None and line.startswith("    status: "):
                current_train["status"] = stripped.removeprefix("status: ")
            elif current_train is not None and stripped == "batches:":
                in_batches = True
            elif current_train is not None and in_batches and line.startswith("      - "):
                current_train["batches"].append(stripped.removeprefix("- "))  # type: ignore[index]
    return data


def prompt_files_for(batch_id: str) -> list[Path]:
    return sorted(PROMPT_DIR.glob(f"{batch_id}-*.md"))


def selected_prompt(batch_id: str) -> Path | None:
    matches = prompt_files_for(batch_id)
    if not matches:
        return None
    return matches[0]


def manifest_matrix(manifest: dict[str, object]) -> list[dict[str, object]]:
    dependencies: dict[str, list[str]] = manifest["dependencies"]  # type: ignore[assignment]
    rows: list[dict[str, object]] = []
    previous_batch = ""
    trains: list[dict[str, object]] = manifest["trains"]  # type: ignore[assignment]
    for train in trains:
        train_id = str(train["id"])
        train_batches: list[str] = train["batches"]  # type: ignore[assignment]
        for index, batch_id in enumerate(train_batches, start=1):
            prompt = selected_prompt(batch_id)
            rows.append(
                {
                    "batch_id": batch_id,
                    "train_id": train_id,
                    "train_title": train["title"],
                    "train_status": train.get("status", ""),
                    "role": f"Batch {index} of {len(train_batches)} in {train_id}",
                    "upstream_dependencies": dependencies.get(train_id, []),
                    "previous_batch": previous_batch,
                    "downstream_dependencies": [],
                    "prompt_path": rel(prompt) if prompt else "",
                    "prompt_count": len(prompt_files_for(batch_id)),
                    "proof_roots": manifest["proof_artifact_roots"],
                    "stop_rules": manifest["stop_rules"],
                    "claim_boundaries": manifest["claim_boundaries"],
                    "skipped": bool(train.get("skipped", False)),
                    "skip_reason": str(train.get("skip_reason", "")),
                }
            )
            previous_batch = batch_id
    downstream: dict[str, list[str]] = {str(row["train_id"]): [] for row in rows}
    for train_id, deps in dependencies.items():
        for dep in deps:
            if dep in downstream and train_id not in downstream[dep]:
                downstream[dep].append(train_id)
    for row in rows:
        row["downstream_dependencies"] = downstream.get(str(row["train_id"]), [])
    return rows


def runner_batches() -> list[str]:
    if not RUNNER.exists():
        return []
    return [match.group(1) for match in re.finditer(r"run_batch\s+(IOS26-T\d{2}[A-Z]?-B\d{2})\s+", RUNNER.read_text(encoding="utf-8"))]


def drift_report(rows: list[dict[str, object]]) -> dict[str, object]:
    manifest_batches = [str(row["batch_id"]) for row in rows if not row.get("skipped")]
    runner = runner_batches()
    missing_prompts = [str(row["batch_id"]) for row in rows if not row["prompt_path"]]
    duplicate_prompts = {
        str(row["batch_id"]): int(row["prompt_count"])
        for row in rows
        if int(row["prompt_count"]) > 1
    }
    return {
        "manifest_batches": len(manifest_batches),
        "runner_batches": len(runner),
        "missing_prompts": missing_prompts,
        "duplicate_prompt_batches": duplicate_prompts,
        "runner_missing_batches": [batch for batch in manifest_batches if batch not in runner],
        "runner_extra_batches": [batch for batch in runner if batch not in manifest_batches],
        "runner_order_matches_manifest": runner == manifest_batches,
    }


def yaml_scalar(value: object) -> str:
    if isinstance(value, list):
        return "[" + ", ".join(str(item) for item in value) + "]"
    if value in (None, ""):
        return '""'
    return str(value).replace(":", " -")


def render_matrix_yml(rows: list[dict[str, object]]) -> str:
    out = ["# Generated by scripts/ios26-plan-freeze.py. Do not edit by hand.", "batches:"]
    for row in rows:
        out.append(f"  - batch_id: {row['batch_id']}")
        for key in [
            "train_id",
            "train_title",
            "role",
            "upstream_dependencies",
            "downstream_dependencies",
            "previous_batch",
            "prompt_path",
            "prompt_count",
            "skipped",
            "skip_reason",
        ]:
            out.append(f"    {key}: {yaml_scalar(row.get(key))}")
    return "\n".join(out) + "\n"


def render_dependency_graph(manifest: dict[str, object]) -> str:
    deps: dict[str, list[str]] = manifest["dependencies"]  # type: ignore[assignment]
    out = ["# Generated by scripts/ios26-plan-freeze.py. Do not edit by hand.", "dependencies:"]
    for train_id, values in deps.items():
        out.append(f"  {train_id}: [{', '.join(values)}]")
    return "\n".join(out) + "\n"


def render_order(rows: list[dict[str, object]]) -> str:
    lines = ["# IOS26 Implementation Order", "", "Generated from `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.", ""]
    for index, row in enumerate(rows, start=1):
        lines.append(f"{index}. `{row['batch_id']}` - {row['train_id']} / {row['train_title']} - `{row['prompt_path']}`")
    return "\n".join(lines) + "\n"


def render_freeze_doc(rows: list[dict[str, object]], drift: dict[str, object]) -> str:
    status = "GREEN"
    if drift["missing_prompts"] or drift["runner_missing_batches"] or drift["runner_extra_batches"] or not drift["runner_order_matches_manifest"]:
        status = "RED"
    lines = [
        "# IOS26 Plan Freeze",
        "",
        f"Generated: {utc_now()}",
        f"Status: {status}",
        "",
        "This file freezes the IOS26 flagship train into three passes: plan-freeze, frozen implementation, and review/proof sweep.",
        "It is orchestration proof only. It does not prove app implementation, accessibility, performance, privacy, release, TestFlight, or App Store readiness.",
        "",
        "## Counts",
        f"- Manifest batches: {drift['manifest_batches']}",
        f"- Prompt files selected: {sum(1 for row in rows if row['prompt_path'])}",
        f"- Runner batches before/at check: {drift['runner_batches']}",
        "",
        "## Drift",
        f"- Missing prompts: {', '.join(drift['missing_prompts']) or 'none'}",
        f"- Duplicate prompt batches: {json.dumps(drift['duplicate_prompt_batches'], sort_keys=True)}",
        f"- Runner missing batches: {', '.join(drift['runner_missing_batches']) or 'none'}",
        f"- Runner extra batches: {', '.join(drift['runner_extra_batches']) or 'none'}",
        f"- Runner order matches manifest: {drift['runner_order_matches_manifest']}",
        "",
        "## Frozen Implementation Rule",
        "For `IOS26-*` batches, the Ambitions runner uses Boundary Verification instead of strategic Phase 01 replanning when prompt hashes are frozen.",
        "Use `IOS26_REPLAN_ALLOWED=1` only for an explicit replan/freeze update.",
        "",
    ]
    return "\n".join(lines)


def extract_section(text: str, heading: str) -> str:
    pattern = re.compile(rf"^## {re.escape(heading)}\s*$", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return ""
    start = match.end()
    next_match = re.search(r"^## ", text[start:], re.MULTILINE)
    end = start + next_match.start() if next_match else len(text)
    return text[start:end].strip()


def infer_performance(batch_id: str, text: str) -> str:
    if "performance" in text.lower() or "-T14-" in batch_id:
        return "Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate."
    return "Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof."


OWNER_BOUNDARIES: dict[str, list[str]] = {
    "TRAIN_02": [
        "`design_system` owns design tokens/materials/primitives under `Sources`, `AppUI/Sources`, and `Native/Ambitions/UI`.",
        "Champion Merge Yellow: focused Xcode/preview/accessibility proof is not claimed until the skipped design-system lanes run.",
    ],
    "TRAIN_03": [
        "`private_life_runtime` owns runtime/recommendation/compiler work under `Native/Ambitions/Runtime`, `Native/Ambitions/Domain`, and `Native/Ambitions/Services`.",
        "`proof_receipt_replay` owns receipt, proof, and replay connections used by runtime traces.",
    ],
    "TRAIN_04": [
        "`private_life_runtime` owns compiler/recommendation work under `Native/Ambitions/Runtime`, `Native/Ambitions/Domain`, and `Native/Ambitions/Services`.",
        "`proof_receipt_replay` owns receipt/replay behavior added to compiler persistence.",
    ],
    "TRAIN_04A": [
        "`private_life_runtime` owns life-context runtime inputs that affect recommendations.",
        "`you_root` owns user inspection/reset/delete controls under `Native/Ambitions/Features/You`; focused XCTest proof remains Yellow until rerun after simulator repair.",
    ],
    "TRAIN_04B": [
        "`private_life_runtime` owns step candidate generation, rejection learning, and simulation loops.",
        "`today_root` may present optionality in Today only by extending `Native/Ambitions/Features/Today`, not by creating a detached Start Here/Today owner.",
    ],
    "TRAIN_04C": [
        "`private_life_runtime` owns runtime compiler integration.",
        "`proof_receipt_replay` owns receipt/replay traces for Source Atlas runtime bridges.",
        "`you_root` owns inspection surfaces for what Ambitions knows.",
    ],
    "TRAIN_04D": [
        "`capture_root` owns Capture parser/routing/SmartAttachment work under `Native/Ambitions/Features/Capture`, `Native/Ambitions/Services/CaptureService.swift`, and `Native/Ambitions/Services/SmartAttachmentService.swift`.",
        "Champion Merge Yellow: broad Capture runtime gauntlet remains unproven; do not claim full Capture runtime consolidation until that gate is Green or owner-accepted.",
    ],
    "TRAIN_04E": [
        "Contract harnesses must map replacement-app behavior onto the canonical owners in `docs/codex/canonical-owner-map.yml`; they must not create parallel runtime, capture, time, reminder, project, knowledge, proof, or persistence owners. Include SourceRecord and ReplayTrace wiring and explicitly verify What Ambitions Knows inspection where runtime-affecting behavior changes.",
    ],
    "TRAIN_04F": [
        "`time_root` owns Time/LifeShape and availability/calendar replacement work under `Native/Ambitions/Features/Time` and `Native/Ambitions/Integrations/CalendarReminders`.",
        "`Native/Ambitions/Features/Plan` is superseded compatibility only; do not revive Plan as top-level IA.",
        "Accepted Yellow: proof_receipt_replay remains in accepted Yellow status for adjacent Smart Attachment class-wide drift with sourcerecord + receipt + replaytrace links and What Ambitions Knows inspection. No-claim boundary: no parallel Proof/Receipt/ReplayTrace owner may be introduced. Follow-up gate: resolve the adjacent drift before broad proof consolidation. Affected canonical owner: proof_receipt_replay.",
    ],
    "TRAIN_04G": [
        "Reminder replacement must extend canonical runtime/proof/persistence owners and may not create a parallel reminder intelligence graph.",
        "`proof_receipt_replay` owns reminder closure/recovery receipts and replay traces.",
    ],
    "TRAIN_04H": [
        "`goals_root` and `private_life_runtime` own goal-thread/project-step hierarchy and recommendation behavior; do not create a generic task-app owner.",
        "`proof_receipt_replay` owns project-step closure/proof/replay behavior.",
    ],
    "TRAIN_04I": [
        "`private_life_runtime` owns knowledge-to-runtime source use.",
        "`proof_receipt_replay` owns source records/replay traces where knowledge changes behavior.",
        "`persistence` owns durable local storage/export/delete/reset boundaries.",
    ],
    "TRAIN_04J": [
        "Command/search/capture work must extend `capture_root`, `private_life_runtime`, `proof_receipt_replay`, and `you_root` as applicable; do not introduce chatbot, assistant, or parallel command intelligence owners.",
    ],
    "TRAIN_04K": [
        "`private_life_runtime` is the canonical Private Life Runtime owner.",
        "`proof_receipt_replay`, `capture_root`, `time_root`, `goals_root`, and `you_root` remain the only allowed owners for their respective integration seams.",
        "Do not claim final Private Life Runtime moat proof without replayable local proof artifacts.",
    ],
    "TRAIN_05": [
        "`today_root` owns Today / Reality Meridian / Start Here under `Native/Ambitions/Features/Today`.",
        "Do not revive `DayTimelineRail`, `HeroStepPanel`, `Hero Step Panel`, or `Today Hero` as active owner/source terms.",
    ],
    "TRAIN_06": [
        "`time_root` owns Time / LifeShape under `Native/Ambitions/Features/Time` and `Native/Ambitions/Integrations/CalendarReminders`.",
        "`Native/Ambitions/Features/Plan` is superseded compatibility only; preserve legacy route compatibility without active Plan UI ownership.",
    ],
    "TRAIN_07": [
        "`goals_root` owns Goals / GoalThread behavior under `Native/Ambitions/Features/Goals` and `Native/Ambitions/Domain`; do not create a goals status board or duplicate Mission Control owners.",
    ],
    "TRAIN_08": [
        "`capture_root` owns Capture / Atmosphere Composer and placement receipts.",
        "Champion Merge Yellow: broad Capture runtime gauntlet remains unproven; do not claim full Capture runtime consolidation until that gate is Green or owner-accepted.",
    ],
    "TRAIN_09": [
        "`you_root` owns You / User System Profile under `Native/Ambitions/Features/You`; do not introduce Profile-tab, social profile, or admin profile ownership.",
        "Champion Merge Yellow: focused You XCTest proof is not claimed until blocked lanes pass after simulator repair.",
    ],
    "TRAIN_10": [
        "`proof_receipt_replay` owns Proof / Receipt / ReplayTrace across `Native/Ambitions/Domain`, `Native/Ambitions/Services`, and `Native/Ambitions/Runtime`.",
        "Accepted Yellow: proof_receipt_replay remains in accepted Yellow status. No-claim boundary: no parallel Proof/Receipt/ReplayTrace owner may be introduced. Follow-up gate: resolve adjacent Smart Attachment drift before broad proof closure. Affected canonical owner: proof_receipt_replay.",
    ],
    "TRAIN_11": [
        "`persistence` owns SwiftData, portable snapshot, export/delete/reset, migration, and durable local storage boundaries under `Native/Ambitions/Persistence`.",
        "Champion Merge Yellow: focused persistence proof is not claimed until skipped Xcode lanes run.",
    ],
    "TRAIN_12": [
        "`external_surfaces` owns widgets, Live Activities, App Intents, share extension, and external snapshot adapters under `Native/Ambitions/ExternalSnapshots`, extension targets, and app route adapters.",
        "`persistence` owns portable snapshot/export/delete/reset data used by external surfaces.",
        "Champion Merge Yellow: focused external-surface proof is not claimed until skipped Xcode lanes run.",
    ],
    "TRAIN_13": [
        "`design_system` owns shared accessibility primitives, and each feature owner remains responsible for feature-local accessibility behavior.",
        "Champion Merge Yellow design proof remains unclaimed until focused Xcode/preview/accessibility lanes run.",
    ],
    "TRAIN_14": [
        "Performance work must improve measured behavior inside the relevant canonical owner; do not move logic into a parallel owner to meet a budget.",
    ],
    "TRAIN_15": [
        "Docs/naming sweeps must preserve `docs/codex/canonical-owner-map.yml` and `docs/codex/concept-lock-registry.yml` as source-boundary inputs and must not reopen resolved Champion Merge concepts.",
    ],
    "TRAIN_16": [
        "Release-candidate work may verify proof only; it must not change canonical owners, weaken concept locks, or claim release/TestFlight/App Store/accessibility/performance/privacy readiness without current evidence.",
    ],
}


def champion_merge_boundary(batch_id: str, train_id: str) -> str:
    lines = [
        "- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.",
        "- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.",
        "- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.",
        "- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.",
    ]
    lines.extend(f"- {item}" for item in OWNER_BOUNDARIES.get(str(train_id), []))
    if str(batch_id) == "IOS26-T00-B03":
        lines.append("- Naming/API drift inventory must report legacy terms without treating search patterns as active product language.")
    return "\n".join(lines)


def normalize_prompt(path: Path, row: dict[str, object] | None) -> str:
    original = path.read_text(encoding="utf-8")
    if "----- BEGIN ORIGINAL PROMPT -----" in original and "----- END ORIGINAL PROMPT -----" in original:
        body = original.split("----- BEGIN ORIGINAL PROMPT -----", 1)[1].split("----- END ORIGINAL PROMPT -----", 1)[0].strip()
    elif "## Original prompt intent retained" in original:
        result = subprocess.run(
            ["git", "show", f"HEAD:{rel(path)}"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            body = "\n".join(line for line in result.stdout.splitlines() if line.strip() not in HEADER)
        else:
            retained = original.split("## Original prompt intent retained", 1)[1]
            match = re.search(r"----- BEGIN ORIGINAL PROMPT -----\n(.*?)\n----- END ORIGINAL PROMPT -----", retained, re.DOTALL)
            body = match.group(1).strip() if match else original
    else:
        body = "\n".join(line for line in original.splitlines() if line.strip() not in HEADER)
    objective = extract_section(body, "Objective") or "Preserve the original objective below and implement only the sealed IOS26 work-order boundary."
    steps = extract_section(body, "Implementation steps") or extract_section(body, "Required implementation behavior") or "1. Re-read active truth files.\n2. Inspect only the allowed source and proof areas.\n3. Implement the smallest patch that satisfies this sealed work order.\n4. Write the required proof artifact.\n5. Run validation and report proof honestly."
    commands = extract_section(body, "Commands to run") or "```bash\nmake xcode-focused-test BATCH=<BATCH_ID> TEST=AmbitionsTests\n```"
    proof = extract_section(body, "Required proof artifacts") or "- `build/reports/ios26-flagship/<batch-id>.md`"
    allowed = extract_section(body, "Exact changes allowed") or extract_section(body, "Exact source areas to inspect") or "- Scope is limited to the original prompt intent and the active owner files identified after truth/source inspection."
    forbidden = extract_section(body, "Exact changes forbidden") or "- No cloud dependency.\n- No LLM dependency.\n- No analytics/tracking SDK.\n- No top-level IA changes.\n- No release/accessibility/performance/privacy claims without proof."
    accessibility = extract_section(body, "Accessibility requirements") or "Preserve VoiceOver semantics, Dynamic Type, Reduce Motion, Increase Contrast, and 44 pt minimum touch-target expectations where UI is touched. Do not claim accessibility verification without proof."
    privacy = extract_section(body, "Privacy/local-first requirements") or "Preserve local-first deterministic behavior. Do not introduce external personal-data, cloud LLM, analytics, tracking, backend SDK, or paid service dependencies."
    gates = extract_section(body, "Green / Yellow / Red closeout rules") or "Green: sealed objective, validation, and proof artifact pass. Yellow: bounded gap with owner, reason, no-claim boundary, and follow-up gate. Red: missing prompt, boundary violation, failed validation without accepted Yellow, or forbidden dependency/claim."
    rollback = extract_section(body, "Rollback strategy") or "Rollback only files touched by this batch and preserve unrelated dirty work."
    final_report = extract_section(body, "Final report format") or "Status:\nFiles changed:\nValidation run:\nValidation not run:\nProof artifacts:\nClaims allowed:\nClaims forbidden:\nYellow/Red items:\nRollback:"
    batch_id = row["batch_id"] if row else (BATCH_RE.search(path.name).group(1) if BATCH_RE.search(path.name) else path.stem)
    train_id = row["train_id"] if row else "NON_MANIFEST_IOS26_PROMPT"
    title = row["train_title"] if row else "Non-manifest IOS26 support prompt"
    role = row["role"] if row else "Supporting prompt outside manifest batch matrix"
    upstream = row["upstream_dependencies"] if row else []
    downstream = row["downstream_dependencies"] if row else []
    proof_roots = row["proof_roots"] if row else []
    rendered = [
        *HEADER,
        f"# {batch_id} - Sealed IOS26 Work Order",
        "",
        "## Batch ID",
        f"`{batch_id}`",
        "",
        "## Train ID and title",
        f"`{train_id}` - {title}",
        "",
        "## Batch role in train",
        str(role),
        "",
        "## Upstream dependencies",
        "\n".join(f"- `{dep}`" for dep in upstream) or "- none",
        "",
        "## Downstream dependencies",
        "\n".join(f"- `{dep}`" for dep in downstream) or "- none recorded",
        "",
        "## Objective",
        objective,
        "",
        "## Product/canon constraints",
        "- Active top-level IA remains `Today / Goals / Time / Motion / You`.",
        "- Capture remains the global Atmosphere Composer/action layer, not a tab.",
        "- Motion replaces Pulse; Pulse is prior working-name / historical context only.",
        "- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.",
        "- Do not reintroduce `Plan` as a user-facing top-level destination.",
        "- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.",
        "",
        "## Local-first/privacy constraints",
        privacy,
        "",
        "## Accessibility constraints",
        accessibility,
        "",
        "## Performance constraints when relevant",
        infer_performance(str(batch_id), body),
        "",
        "## Champion Merge source boundary",
        champion_merge_boundary(str(batch_id), str(train_id)),
        "",
        "## Allowed files/directories",
        allowed,
        "",
        "## Forbidden files/directories",
        forbidden,
        "",
        "## Exact implementation steps",
        steps,
        "",
        "## Validation commands",
        commands.replace("<BATCH_ID>", str(batch_id)),
        "",
        "## Proof artifacts to write",
        proof,
        "\n".join(f"- `{root}`" for root in proof_roots) if proof_roots else "",
        "",
        "## Green / Yellow / Red gates",
        gates,
        "",
        "## Rollback behavior",
        rollback,
        "",
        "## Claims allowed",
        "- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.",
        "- Docs-only or tooling-only changes must be described as docs-only or tooling-only.",
        "",
        "## Claims forbidden",
        "- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.",
        "",
        "## Final report required fields",
        final_report,
        "",
        "## STATUS placeholder",
        "STATUS: <GREEN|YELLOW|RED>",
        "",
        "## Original prompt intent retained",
        "The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.",
        "",
        "----- BEGIN ORIGINAL PROMPT -----",
        body.strip(),
        "----- END ORIGINAL PROMPT -----",
        "",
    ]
    return "\n".join(rendered)


def prompt_hash_entries(rows: list[dict[str, object]], generated_at: str) -> list[dict[str, str]]:
    row_by_prompt = {str(row["prompt_path"]): row for row in rows if row["prompt_path"]}
    entries: list[dict[str, str]] = []
    for path in sorted(PROMPT_DIR.glob("IOS26-*.md")):
        relative = rel(path)
        row = row_by_prompt.get(relative)
        batch_match = BATCH_RE.search(path.name)
        entries.append(
            {
                "batch_id": str(row["batch_id"] if row else (batch_match.group(1) if batch_match else path.stem)),
                "prompt_path": relative,
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "train_id": str(row["train_id"] if row else "NON_MANIFEST_IOS26_PROMPT"),
                "generated_at": generated_at,
            }
        )
    return entries


def write_files(rows: list[dict[str, object]], manifest: dict[str, object], drift: dict[str, object]) -> None:
    IOS26_DIR.mkdir(parents=True, exist_ok=True)
    PLANNING_DIR.mkdir(parents=True, exist_ok=True)
    row_by_path = {str(row["prompt_path"]): row for row in rows if row["prompt_path"]}
    for path in sorted(PROMPT_DIR.glob("IOS26-*.md")):
        path.write_text(normalize_prompt(path, row_by_path.get(rel(path))), encoding="utf-8")
    generated_at = utc_now()
    hashes = {
        "generated_at": generated_at,
        "hash_algorithm": "sha256",
        "replan_escape_hatch": "IOS26_REPLAN_ALLOWED=1",
        "entries": prompt_hash_entries(rows, generated_at),
    }
    (IOS26_DIR / "IOS26_PLAN_FREEZE.md").write_text(render_freeze_doc(rows, drift), encoding="utf-8")
    (IOS26_DIR / "IOS26_BATCH_MATRIX.yml").write_text(render_matrix_yml(rows), encoding="utf-8")
    (IOS26_DIR / "IOS26_DEPENDENCY_GRAPH.yml").write_text(render_dependency_graph(manifest), encoding="utf-8")
    (IOS26_DIR / "IOS26_IMPLEMENTATION_ORDER.md").write_text(render_order(rows), encoding="utf-8")
    (IOS26_DIR / "IOS26_REVIEW_SWEEP_PLAN.md").write_text(render_review_plan(rows), encoding="utf-8")
    HASH_FILE.write_text(json.dumps(hashes, indent=2) + "\n", encoding="utf-8")
    (PLANNING_DIR / "ios26-plan-freeze.md").write_text(render_freeze_doc(rows, drift), encoding="utf-8")
    (PLANNING_DIR / "ios26-plan-freeze.json").write_text(json.dumps({"generated_at": generated_at, "drift": drift, "batches": rows}, indent=2) + "\n", encoding="utf-8")
    (PLANNING_DIR / "manifest-runner-drift.md").write_text(render_drift_md(drift), encoding="utf-8")
    (PLANNING_DIR / "prompt-freeze-check.md").write_text(render_hash_md(hashes), encoding="utf-8")


def render_review_plan(rows: list[dict[str, object]]) -> str:
    return "\n".join(
        [
            "# IOS26 Review Sweep Plan",
            "",
            "Run after frozen implementation pass, before release-claim or final-candidate work.",
            "",
            "The sweep aggregates manifest coverage, prompt hash coverage, runner coverage, proof roots, validation reports, Green/Yellow/Red status, missing proof, stale claims, IA/naming drift, accessibility gaps, performance gaps, privacy/local-first gaps, and parallel owner warnings.",
            "",
            f"Total batches: {len(rows)}",
            "",
            "Output:",
            "- `build/reports/ios26-review-sweep/ios26-review-sweep.md`",
            "- `build/reports/ios26-review-sweep/ios26-review-sweep.json`",
            "- `docs/codex/ios26/IOS26_REPAIR_QUEUE.md`",
            "",
            "No new feature scope may be invented by the sweep.",
            "",
        ]
    )


def render_drift_md(drift: dict[str, object]) -> str:
    status = "GREEN" if not drift["runner_missing_batches"] and not drift["runner_extra_batches"] and drift["runner_order_matches_manifest"] else "RED"
    return "\n".join([f"# IOS26 Manifest/Runner Drift", "", f"Status: {status}", "", "```json", json.dumps(drift, indent=2), "```", ""])


def render_hash_md(hashes: dict[str, object]) -> str:
    entries: list[dict[str, str]] = hashes["entries"]  # type: ignore[assignment]
    return "\n".join(["# IOS26 Prompt Freeze Check", "", f"Generated: {hashes['generated_at']}", f"Entries: {len(entries)}", "", "Status: GREEN", ""])


def current_snapshot(rows: list[dict[str, object]], manifest: dict[str, object]) -> dict[str, str]:
    paths = [
        IOS26_DIR / "IOS26_PLAN_FREEZE.md",
        IOS26_DIR / "IOS26_BATCH_MATRIX.yml",
        IOS26_DIR / "IOS26_DEPENDENCY_GRAPH.yml",
        IOS26_DIR / "IOS26_IMPLEMENTATION_ORDER.md",
        IOS26_DIR / "IOS26_REVIEW_SWEEP_PLAN.md",
        HASH_FILE,
        PLANNING_DIR / "ios26-plan-freeze.md",
        PLANNING_DIR / "ios26-plan-freeze.json",
        PLANNING_DIR / "manifest-runner-drift.md",
        PLANNING_DIR / "prompt-freeze-check.md",
    ]
    return {rel(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths if path.exists()}


def check(rows: list[dict[str, object]], drift: dict[str, object]) -> int:
    issues: list[str] = []
    required = [
        IOS26_DIR / "IOS26_PLAN_FREEZE.md",
        IOS26_DIR / "IOS26_BATCH_MATRIX.yml",
        IOS26_DIR / "IOS26_DEPENDENCY_GRAPH.yml",
        IOS26_DIR / "IOS26_IMPLEMENTATION_ORDER.md",
        IOS26_DIR / "IOS26_REVIEW_SWEEP_PLAN.md",
        HASH_FILE,
        PLANNING_DIR / "ios26-plan-freeze.md",
        PLANNING_DIR / "ios26-plan-freeze.json",
        PLANNING_DIR / "manifest-runner-drift.md",
        PLANNING_DIR / "prompt-freeze-check.md",
    ]
    for path in required:
        if not path.exists():
            issues.append(f"missing generated file: {rel(path)}")
    if drift["missing_prompts"]:
        issues.append(f"missing prompts: {', '.join(drift['missing_prompts'])}")
    if drift["runner_missing_batches"] or drift["runner_extra_batches"] or not drift["runner_order_matches_manifest"]:
        issues.append("manifest/runner drift remains")
    for row in rows:
        if row["prompt_path"]:
            text = (ROOT / str(row["prompt_path"])).read_text(encoding="utf-8")
            for section in [
                "## Batch ID",
                "## Train ID and title",
                "## Allowed files/directories",
                "## Forbidden files/directories",
                "## Validation commands",
                "## STATUS placeholder",
            ]:
                if section not in text:
                    issues.append(f"{row['prompt_path']}: missing {section}")
    if issues:
        for issue in issues:
            print(f"RED: {issue}")
        return 1
    print(f"GREEN: IOS26 plan freeze check passed batches={len(rows)} prompts={sum(1 for row in rows if row['prompt_path'])}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify generated plan-freeze files and prompt normalization.")
    args = parser.parse_args()
    manifest = parse_manifest()
    rows = manifest_matrix(manifest)
    drift = drift_report(rows)
    if args.check:
        return check(rows, drift)
    write_files(rows, manifest, drift)
    print(f"GREEN: IOS26 plan freeze generated batches={len(rows)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
