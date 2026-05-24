#!/usr/bin/env python3
"""Local-only repo-intelligence preflight for advisory developer tooling."""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "build/reports/repo-intelligence/preflight.json"
POLICY_DOCS = [
    "docs/codex/LOCAL_REPO_INTELLIGENCE_POLICY.md",
    "docs/codex/REPO_INTELLIGENCE_" + "WORK" + "FLOW.md",
    "docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md",
]
SCHEMA = ".codex/schemas/repo-intelligence-evidence.schema.json"
IGNORES = [
    ".codegraph/",
    ".understand-anything/",
    ".codex/local-indexes/",
    ".codex/repo-intelligence/tools/",
    ".codex/repo-intelligence/generated/",
    ".codex/repo-intelligence/tmp/",
]
ARTIFACT_PREFIXES = tuple(IGNORES)


def run(cmd: list[str], timeout: int = 5) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            cmd,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        return 127, str(exc)
    return proc.returncode, (proc.stdout or "").strip()


def git_lines(args: list[str]) -> list[str]:
    code, output = run(["git", *args], timeout=10)
    if code != 0:
        return []
    return [line.strip() for line in output.splitlines() if line.strip()]


def command_version(name: str, args: list[str], help_args: list[str] | None = None) -> dict[str, Any]:
    local_candidates = [
        ROOT / ".codex/repo-intelligence/tools/bin" / name,
        ROOT / ".codex/repo-intelligence/tools/codegraph/node_modules/.bin" / name,
    ]
    path = shutil.which(name)
    if not path:
        for candidate in local_candidates:
            if candidate.exists() and candidate.is_file():
                path = str(candidate)
                break
    if not path:
        return {"available": False, "version": "", "path": "", "notes": [f"{name} not found in PATH"]}
    code, output = run([path, *args], timeout=15)
    notes = [] if code == 0 else [f"{name} version command exited {code}"]
    available = code == 0
    if not available and help_args is not None:
        help_code, help_output = run([path, *help_args], timeout=15)
        available = help_code == 0
        if available:
            notes.append(f"{name} has no usable version flag; help command succeeded")
            output = output or help_output.splitlines()[0] if help_output else ""
    return {"available": available, "version": output.splitlines()[0] if output else "", "path": path, "notes": notes}


def detect_understand_anything() -> dict[str, Any]:
    candidates = ["understand", "understand-dashboard"]
    found = [name for name in candidates if shutil.which(name)]
    local_dirs = [path for path in [ROOT / ".understand-anything"] if path.exists()]
    return {
        "available": bool(found or local_dirs),
        "used": False,
        "sandbox_only": True,
        "notes": [
            "coarse command/path detection only",
            *[f"command found: {name}" for name in found],
            *[f"local directory present: {path.relative_to(ROOT)}" for path in local_dirs],
        ],
    }


def artifact_violations() -> list[str]:
    tracked = git_lines(["ls-files", *IGNORES])
    staged = git_lines(["diff", "--cached", "--name-only"])
    unignored = git_lines(["ls-files", "--others", "--exclude-standard", *IGNORES])
    violations: list[str] = []
    for path in tracked:
        if path.startswith(ARTIFACT_PREFIXES):
            violations.append(f"tracked generated sidecar artifact: {path}")
    for path in staged:
        if path.startswith(ARTIFACT_PREFIXES):
            violations.append(f"staged generated sidecar artifact: {path}")
    for path in unignored:
        if path.startswith(ARTIFACT_PREFIXES):
            violations.append(f"unignored generated sidecar artifact: {path}")
    return violations


def check_gitignore() -> list[str]:
    gitignore = ROOT / ".gitignore"
    if not gitignore.exists():
        return ["missing .gitignore"]
    text = gitignore.read_text(encoding="utf-8")
    return [f".gitignore missing {entry}" for entry in IGNORES if entry not in text]


def build_payload() -> dict[str, Any]:
    codegraph = command_version("codegraph", ["--version"])
    codegraph["index_present"] = (ROOT / ".codegraph").exists()
    codegraph["status_command"] = "not run"
    if codegraph["index_present"] and codegraph["available"]:
        status_code, status_output = run([codegraph["path"], "status", "."], timeout=10)
        codegraph["status_command"] = f"{codegraph['path']} status . exit={status_code}"
        if status_output:
            codegraph.setdefault("notes", []).append(status_output[:500])

    semble = command_version("semble", ["--version"], ["--help"])
    legacy_semble_index = ROOT / ".codex/local-indexes/semble-ambitions"
    semble["index_present"] = legacy_semble_index.exists()
    semble["index_mode"] = "legacy_persistent" if semble["index_present"] else "query_time_in_memory"
    semble.setdefault("notes", []).append(
        "current Semble CLI exposes search/find-related and builds its index at query time"
    )
    semble.setdefault("notes", []).append(
        "legacy .codex/local-indexes/semble-ambitions path is optional and not created by current Semble"
    )
    if not semble["available"] and shutil.which("uvx"):
        semble.setdefault("notes", []).append("uvx is present but uvx --from was not invoked because it may install over network")

    missing = [path for path in [*POLICY_DOCS, SCHEMA] if not (ROOT / path).exists()]
    violations = [f"missing required policy/schema file: {path}" for path in missing]
    violations.extend(check_gitignore())
    violations.extend(artifact_violations())

    optional_missing = []
    if not codegraph["available"]:
        optional_missing.append("CodeGraph unavailable")
    if not semble["available"]:
        optional_missing.append("Semble unavailable")

    if violations:
        status = "RED"
        exit_code = 1
    elif optional_missing:
        status = "YELLOW"
        exit_code = 2
    else:
        status = "GREEN"
        exit_code = 0

    return {
        "timestamp_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "status": status,
        "exit_code": exit_code,
        "tools": {
            "codegraph": codegraph,
            "semble": semble,
            "understand_anything": detect_understand_anything(),
        },
        "local_indexes": {
            ".codegraph": (ROOT / ".codegraph").exists(),
            ".understand-anything": (ROOT / ".understand-anything").exists(),
            ".codex/local-indexes": (ROOT / ".codex/local-indexes").exists(),
        },
        "violations": violations,
        "yellow": optional_missing,
        "non_claims": [
            "advisory tooling status is not release proof",
            "optional tool availability is not Ambitions speed or cost proof",
            "generated summaries are not source truth",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help=f"write {REPORT.relative_to(ROOT)}")
    args = parser.parse_args()
    payload = build_payload()

    print(f"{payload['status']}: Ambitions repo-intelligence preflight")
    for name, tool in payload["tools"].items():
        print(f"{name}: available={tool.get('available')} index_present={tool.get('index_present', 'n/a')}")
    for item in payload["yellow"]:
        print(f"YELLOW: {item}; fallback to direct repo search/read")
    for item in payload["violations"]:
        print(f"RED: {item}")

    if args.json:
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"wrote {REPORT.relative_to(ROOT)}")
    return int(payload["exit_code"])


if __name__ == "__main__":
    raise SystemExit(main())
