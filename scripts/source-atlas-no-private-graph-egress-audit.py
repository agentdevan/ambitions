#!/usr/bin/env python3
"""Audit Source Atlas egress surfaces for private-life-graph leakage."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SCAN_ROOTS = [
    ROOT / "tools" / "source-atlas",
]

TEXT_SUFFIXES = {".py", ".md", ".json", ".jsonl", ".yml", ".yaml", ".toml", ".txt"}

EGRESS_TERMS = re.compile(
    r"\b(r2|bucket|objectKey|object_key|cacheKey|cache_key|manifest|request|query|body|payload|upload|publish|staging|log|artifact|fixture|schema)\b",
    re.I,
)

PRIVATE_TERMS = re.compile(
    r"\b("
    r"userGoalId|user_goal_id|goalText|goal_text|stepText|step_text|captureText|capture_text|"
    r"voiceTranscript|voice_transcript|protectedTime|protected_time|scheduleAssumption|schedule_assumption|"
    r"timeAvailability|time_availability|capacityMetric|capacity_metric|cognitiveLoad|cognitive_load|"
    r"physicalEnergy|physical_energy|transitionFriction|transition_friction|recoveryState|recovery_state|"
    r"freeTimeQuality|free_time_quality|executionLane|execution_lane|goalLoad|goal_load|closureEvent|closure_event|"
    r"proofPayload|proof_payload|privateHistory|private_history|behaviorHistory|behavior_history|"
    r"lifeCapital|life_capital|inferredPriority|inferred_priority|personalization|recommendationScore|recommendation_score|"
    r"userCorrection|user_correction|privateLifeGraph|private_life_graph|accessToken|access_token|refreshToken|refresh_token"
    r")\b",
    re.I,
)

FORBIDDEN_KEY_SEGMENTS = {
    "users",
    "user",
    "private",
    "captures",
    "capture",
    "goals",
    "goal",
    "steps",
    "step",
    "life-graph",
    "life_graph",
    "receipts",
    "receipt",
    "personalization",
    "calendar",
    "schedule",
    "proof",
    "behavior",
}

BOUNDARY_MARKERS = [
    "must not upload",
    "mustNotUploadPrivateContext",
    "must never send",
    "no private",
    "not private",
    "public/reference",
    "never receive",
    "must never receive",
    "not compiled into",
    "happens locally",
]


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def is_boundary_line(line: str) -> bool:
    lowered = line.lower()
    return any(marker.lower() in lowered for marker in BOUNDARY_MARKERS)


def iter_files() -> list[Path]:
    files: list[Path] = []
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix.lower() in TEXT_SUFFIXES:
                files.append(path)
    return sorted(files)


def private_key_segments(value: str) -> list[str]:
    normalized = value.lower().replace("\\", "/")
    segments = [segment for segment in re.split(r"[/:\s]+", normalized) if segment]
    return [segment for segment in segments if segment in FORBIDDEN_KEY_SEGMENTS]


def scan_json(value: Any, label: str) -> list[str]:
    findings: list[str] = []

    def walk(item: Any, pointer: str) -> None:
        if isinstance(item, dict):
            for key, child in item.items():
                key_text = str(key)
                if EGRESS_TERMS.search(key_text) and PRIVATE_TERMS.search(json.dumps(child, ensure_ascii=False)):
                    findings.append(f"{label}{pointer}.{key}: egress field carries private runtime context")
                if re.search(r"(objectKey|object_key|cacheKey|cache_key|path|key)$", key_text, re.I) and isinstance(child, str):
                    for segment in private_key_segments(child):
                        findings.append(f"{label}{pointer}.{key}: object/cache key contains private segment '{segment}'")
                walk(child, f"{pointer}.{key}")
        elif isinstance(item, list):
            for index, child in enumerate(item):
                walk(child, f"{pointer}[{index}]")
        elif isinstance(item, str):
            if not is_boundary_line(item) and EGRESS_TERMS.search(pointer) and PRIVATE_TERMS.search(item):
                findings.append(f"{label}{pointer}: egress string carries private runtime context")

    walk(value, "")
    return findings


def scan_text(path: Path, text: str) -> list[str]:
    findings: list[str] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        if is_boundary_line(line):
            continue
        if EGRESS_TERMS.search(line) and PRIVATE_TERMS.search(line):
            findings.append(f"{rel(path)}:{line_number}: egress surface references private runtime context")
        key_match = re.search(r"(?:objectKey|object_key|cacheKey|cache_key|r2Key|r2_key)\s*[:=]\s*['\"]([^'\"]+)['\"]", line)
        if key_match:
            for segment in private_key_segments(key_match.group(1)):
                findings.append(f"{rel(path)}:{line_number}: object/cache key contains private segment '{segment}'")
    return findings


def main() -> int:
    findings: list[str] = []
    files = iter_files()
    for path in files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        if path.suffix.lower() == ".json":
            try:
                findings.extend(scan_json(json.loads(text), rel(path)))
                continue
            except json.JSONDecodeError:
                pass
        findings.extend(scan_text(path, text))

    print("# Source Atlas No Private Graph Egress Audit")
    print(f"scanned_files={len(files)}")
    if findings:
        for finding in findings:
            print(f"RED: {finding}", file=sys.stderr)
        return 1
    print("GREEN: no Source Atlas private-graph egress findings")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
