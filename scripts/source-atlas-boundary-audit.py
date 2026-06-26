#!/usr/bin/env python3
"""Audit Source Atlas files for private-life-runtime data classes."""

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

TEXT_SUFFIXES = {".py", ".md", ".json", ".jsonl", ".yml", ".yaml", ".toml", ".txt", ".csv"}
EXCLUDED_RELATIVE_FILES = {
    "tools/source-atlas/coverage.py",
}

BOUNDARY_MARKERS = [
    "no private",
    "not private",
    "must never receive",
    "must never send",
    "must not receive",
    "forbidden classes",
    "public/reference/freshness only",
    "not a user-data backend",
    "never receives",
    "local-only",
    "happens locally",
    "does not store",
    "not compiled into",
]

FORBIDDEN_PATTERNS: list[tuple[str, re.Pattern[str], str]] = [
    ("goal text", re.compile(r"\b(goalText|goal_text|goal-title|goal_title|goalBody|goal_body)\b", re.I), "Source Atlas must not carry private goal wording"),
    ("user goal IDs", re.compile(r"\b(userGoalId|userGoalID|user_goal_id|goalUserId|goal_user_id)\b", re.I), "Source Atlas must not carry user goal identifiers"),
    ("private step text", re.compile(r"\b(privateStepText|private_step_text|stepText|step_text)\b", re.I), "Source Atlas must not carry private Step wording"),
    ("capture text", re.compile(r"\b(captureText|capture_text|captureBody|capture_body)\b", re.I), "Source Atlas must not carry Capture wording"),
    ("attachment content", re.compile(r"\b(attachmentContent|attachment_content|attachmentBody|attachment_body)\b", re.I), "Source Atlas must not carry attachment contents"),
    ("voice transcripts", re.compile(r"\b(voiceTranscript|voice_transcript|transcriptText|transcript_text)\b", re.I), "Source Atlas must not carry voice transcripts"),
    ("private notes", re.compile(r"\b(privateNotes?|userNotes?|noteText|note_text)\b", re.I), "Source Atlas must not carry private notes"),
    ("calendar events", re.compile(r"\b(calendarEvent|calendar_event|eventTitle|event_title)\b", re.I), "Source Atlas must not carry calendar events"),
    ("protected time", re.compile(r"\b(protectedTime|protected_time|protectedWindow|protected_window)\b", re.I), "Source Atlas must not carry protected-time data"),
    ("schedule assumptions", re.compile(r"\b(scheduleAssumptions?|schedule_assumptions?)\b", re.I), "Source Atlas must not carry schedule assumptions"),
    ("time availability", re.compile(r"\b(timeAvailability|time_availability|availableTime|available_time)\b", re.I), "Source Atlas must not carry time availability"),
    ("capacity metrics", re.compile(r"\b(capacityMetrics?|capacity_metrics?)\b", re.I), "Source Atlas must not carry private capacity metrics"),
    ("cognitive load", re.compile(r"\b(cognitiveLoad|cognitive_load)\b", re.I), "Source Atlas must not carry cognitive-load data"),
    ("physical energy", re.compile(r"\b(physicalEnergy|physical_energy)\b", re.I), "Source Atlas must not carry physical-energy data"),
    ("transition friction", re.compile(r"\b(transitionFriction|transition_friction)\b", re.I), "Source Atlas must not carry transition-friction data"),
    ("recovery state", re.compile(r"\b(recoveryState|recovery_state)\b", re.I), "Source Atlas must not carry recovery state"),
    ("free-time quality", re.compile(r"\b(freeTimeQuality|free_time_quality)\b", re.I), "Source Atlas must not carry private free-time quality"),
    ("execution lanes", re.compile(r"\b(executionLanes?|execution_lanes?)\b", re.I), "Source Atlas must not carry execution lanes"),
    ("goal load", re.compile(r"\b(goalLoad|goal_load)\b", re.I), "Source Atlas must not carry goal load"),
    ("closure events", re.compile(r"\b(closureEvents?|closure_events?)\b", re.I), "Source Atlas must not carry closure events"),
    ("proof payloads", re.compile(r"\b(proofPayload|proof_payload)\b", re.I), "Source Atlas must not carry proof payloads"),
    ("private history", re.compile(r"\b(privateHistory|private_history)\b", re.I), "Source Atlas must not carry private history"),
    ("reflections", re.compile(r"\b(userReflections?|user_reflections?|reflectionText|reflection_text)\b", re.I), "Source Atlas must not carry user reflections"),
    ("adaptations", re.compile(r"\b(userAdaptations?|user_adaptations?|adaptationHistory|adaptation_history)\b", re.I), "Source Atlas must not carry adaptation history"),
    ("behavior history", re.compile(r"\b(behaviorHistory|behavior_history)\b", re.I), "Source Atlas must not carry behavior history"),
    ("Life Capital", re.compile(r"\b(lifeCapital|life_capital)\b"), "Source Atlas may provide public facts only; Life Capital matching stays local"),
    ("inferred priorities", re.compile(r"\b(inferredPriorit(?:y|ies)|inferred_priorit(?:y|ies))\b", re.I), "Source Atlas must not carry inferred priorities"),
    ("personalization settings", re.compile(r"\b(personalizationSettings?|personalization_settings?)\b", re.I), "Source Atlas must not carry personalization settings"),
    ("local recommendation scores", re.compile(r"\b(localRecommendationScores?|local_recommendation_scores?|recommendationScore|recommendation_score)\b", re.I), "Source Atlas must not carry local recommendation scores"),
    ("user corrections", re.compile(r"\b(userCorrections?|user_corrections?)\b", re.I), "Source Atlas must not carry user corrections"),
    ("precise location", re.compile(r"\b(homeLocation|workLocation|preciseLocation|home_location|work_location|precise_location)\b", re.I), "Source Atlas must not carry precise location/home/work"),
    ("contacts/messages/photos/files/health data", re.compile(r"\b(contactList|messageBody|photoLibrary|healthData|contacts|messages|photos|health_data)\b", re.I), "Source Atlas must not carry personal device data"),
    ("account secrets", re.compile(r"\b(accountSecret|account_secret|clientSecret|client_secret)\b", re.I), "Source Atlas must not carry account secrets"),
    ("access tokens", re.compile(r"\b(accessToken|access_token)\b", re.I), "Source Atlas must not carry access tokens"),
    ("refresh tokens", re.compile(r"\b(refreshToken|refresh_token)\b", re.I), "Source Atlas must not carry refresh tokens"),
    ("payment identity state", re.compile(r"\b(paymentState|payment_state|identityPayment|identity_payment)\b", re.I), "Source Atlas must not carry payment state tied to identity"),
    ("private life graph", re.compile(r"\b(privateLifeGraph|private_life_graph|private life graph node|private life graph edge)\b", re.I), "Source Atlas must not carry private life graph nodes or edges"),
]

ALLOWED_PRIVATE_REFERENCE_RE = re.compile(
    r"\b(private life graph|private user context|personalization|behavior history|Life Capital|receipts?)\b",
    re.I,
)


def is_boundary_line(line: str) -> bool:
    lowered = line.lower()
    return any(marker in lowered for marker in BOUNDARY_MARKERS)


def iter_scan_files() -> list[Path]:
    files: list[Path] = []
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            relative = rel(path) if path.exists() else ""
            if relative in EXCLUDED_RELATIVE_FILES:
                continue
            if any(part in path.parts for part in {".git", "__pycache__"}):
                continue
            if path.is_file() and path.suffix.lower() in TEXT_SUFFIXES:
                files.append(path)
    return sorted(files)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def json_scalar_findings(value: Any, label: str) -> list[str]:
    findings: list[str] = []

    def walk(item: Any, pointer: str) -> None:
        if isinstance(item, dict):
            for key, child in item.items():
                for name, pattern, reason in FORBIDDEN_PATTERNS:
                    if pattern.search(str(key)):
                        findings.append(f"{label}{pointer}.{key}: {name}: {reason}")
                walk(child, f"{pointer}.{key}")
        elif isinstance(item, list):
            for index, child in enumerate(item):
                walk(child, f"{pointer}[{index}]")
        elif isinstance(item, str):
            if is_boundary_line(item):
                return
            for name, pattern, reason in FORBIDDEN_PATTERNS:
                if pattern.search(item):
                    if name in {"private life graph", "Life Capital"} and ALLOWED_PRIVATE_REFERENCE_RE.search(item):
                        continue
                    findings.append(f"{label}{pointer}: {name}: {reason}")

    walk(value, "")
    return findings


def scan_text(path: Path, text: str) -> list[str]:
    findings: list[str] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        if is_boundary_line(line):
            continue
        if "PRIVATE_CONTENT_PATTERNS" in line or "PRIVACY_BOUNDARY" in line:
            continue
        if "re.compile" in line:
            continue
        for name, pattern, reason in FORBIDDEN_PATTERNS:
            if pattern.search(line):
                findings.append(f"{rel(path)}:{line_number}: {name}: {reason}")
    return findings


def main() -> int:
    findings: list[str] = []
    files = iter_scan_files()
    for path in files:
        text = path.read_text(encoding="utf-8", errors="ignore")
        if path.suffix.lower() == ".json":
            try:
                findings.extend(json_scalar_findings(json.loads(text), rel(path)))
                continue
            except json.JSONDecodeError:
                pass
        findings.extend(scan_text(path, text))

    print("# Source Atlas Boundary Audit")
    print(f"scanned_files={len(files)}")
    if findings:
        for finding in findings:
            print(f"RED: {finding}", file=sys.stderr)
        return 1
    print("GREEN: Source Atlas public/reference/freshness boundary passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
