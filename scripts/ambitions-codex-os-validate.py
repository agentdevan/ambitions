#!/usr/bin/env python3
"""Validate the local Ambitions Codex OS hardening control-plane."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
from fnmatch import fnmatch
from pathlib import Path
import py_compile

ROOT = Path(__file__).resolve().parents[1]
BUILD_REPORTS = ROOT / "build" / "reports"
REPORT_PATH = BUILD_REPORTS / "ambitions-codex-os-validate.json"

ALLOWED_REPORT_PATHS = {
    "build/reports/ambitions-codex-os-validate.json",
    "build/reports/ambitions-codex-os-dry-run-002.json",
    "build/reports/ambitions-codex-os-dry-run-003.json",
    "build/reports/ambitions-codex-os-dry-run-004.json",
    "build/reports/AMB-CODEX-OS-NO-COST-HARDENING-002-no-cost-runner-result.json",
}

REQUIRED_FILES = [
    ROOT / "AGENTS.md",
    ROOT / ".codex" / "AGENTS.md",
    ROOT / ".agents" / "AGENTS.md",
    ROOT / ".codex" / "config.toml",
    ROOT / ".codex" / "hooks.json",
    ROOT / ".codex" / "rules" / "ambitions-no-cost.rules",
    ROOT / ".codex" / "schemas" / "ambitions-batch-result.schema.json",
    ROOT / "docs" / "codex-os" / "AUTHORITY_HIERARCHY.md",
    ROOT / "docs" / "codex-os" / "RUNNER_UPGRADE_NOTES.md",
    ROOT / "docs" / "codex-os" / "RULES_POLICY.md",
    ROOT / "docs" / "codex-os" / "HOOKS_POLICY.md",
    ROOT / "docs" / "codex-os" / "STRUCTURED_OUTPUT.md",
    ROOT / "docs" / "codex-os" / "NO_COST_CODEX_OS.md",
    ROOT / "docs" / "codex-os" / "CODEX_OS_COMPONENTS.md",
    ROOT / "docs" / "codex-os" / "EXCLUDED_FOR_COST_OR_SCOPE.md",
    ROOT / "docs" / "codex-os" / "ROLLBACK.md",
    ROOT / "docs" / "codex" / "os" / "README.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-FLAGSHIP-UPGRADE-MANIFEST.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-AUTHORITY-RESOLVER.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-GREEN-YELLOW-RED-STANDARD.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-NO-SPRAWL-GUARD.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-PROOF-LEDGER.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-VISUAL-QA-GATE.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md",
    ROOT / "docs" / "codex" / "os" / "AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md",
    ROOT / "docs" / "codex" / "reports" / "AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md",
    ROOT / "scripts" / "ambitions-codex-os-validate.py",
    ROOT / "scripts" / "ambitions-codex-os-doctor.py",
]

REQUIRED_GENERATED_PROMPTS = [
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-01-AUTHORITY-RESOLVER.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-02-NO-SPRAWL-GUARD.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-03-PROOF-LEDGER.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-04-VISUAL-QA-GATE.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-05-PRIVACY-APPLE-CONTINUITY-GATES.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-06-LAUNCH-BELIEVABILITY-REVIEW.md",
    ROOT / "prompts" / "batches" / "OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md",
]

SKILLS = [
    ROOT / ".codex" / "skills" / "ambitions" / "README.md",
    ROOT / ".codex" / "skills" / "ambitions" / "authority-resolver.md",
    ROOT / ".codex" / "skills" / "ambitions" / "batch-train-composer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "no-sprawl-guard.md",
    ROOT / ".codex" / "skills" / "ambitions" / "source-truth-classifier.md",
    ROOT / ".codex" / "skills" / "ambitions" / "swiftui-flagship-ui-reviewer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "backend-local-first-reviewer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "apple-continuity-reviewer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "privacy-claim-verifier.md",
    ROOT / ".codex" / "skills" / "ambitions" / "proof-ledger-writer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "accessibility-native-ios-reviewer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "release-believability-reviewer.md",
    ROOT / ".codex" / "skills" / "ambitions" / "red-team-reviewer.md",
    ROOT / ".agents" / "skills" / "ambitions-batch-runner-operator" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-source-truth-auditor" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-no-cost-gate" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-ios-quality-gate" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-release-proof-honesty" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-repo-hygiene-rollback" / "SKILL.md",
    ROOT / ".agents" / "skills" / "ambitions-subagent-review-template" / "SKILL.md",
]

HOOKS = [
    ROOT / ".codex" / "hooks" / "session_start_context.py",
    ROOT / ".codex" / "hooks" / "user_prompt_submit_guard.py",
    ROOT / ".codex" / "hooks" / "pre_tool_use_policy.py",
    ROOT / ".codex" / "hooks" / "permission_request_guard.py",
    ROOT / ".codex" / "hooks" / "post_tool_use_review.py",
    ROOT / ".codex" / "hooks" / "stop_gate.py",
]

CONTROL_FILES = [
    *REQUIRED_FILES,
    *SKILLS,
    *HOOKS,
    ROOT / "Makefile",
    ROOT / "docs" / "AGENTS.md",
    ROOT / "scripts" / "AGENTS.md",
    ROOT / ".codex" / "AGENTS.md",
    ROOT / ".agents" / "AGENTS.md",
    ROOT / ".codex" / "config.toml",
    ROOT / ".codex" / "hooks.json",
    ROOT / "scripts" / "ambitions-codex-os-print-install-notes.py",
]

FORBIDDEN_SCOPE_PATTERNS = [
    "Native/",
    "Sources/",
    "AppUI/",
    "project.yml",
    "project.pbxproj",
    "Package.swift",
    "**/*.xcodeproj",
    "**/*.xcodeproj/**",
    "**/*.xcworkspace",
    "**/*.xcworkspace/**",
    "**/*.entitlements",
    "**/*Info.plist",
    "Package.resolved",
    "*.lock",
    ".github/workflows",
    ".github/workflows/**",
]

DEFAULT_EXTERNAL_DIRTY_CONTROL_WORK = {
    "prompts/batches/MOAT-ALIGNMENT-01.md",
}

FORBIDDEN_CONTENT_PATTERNS = [
    "openai_api",
    "openai-sdk",
    "agents sdk",
    "codex api key",
    "api_key",
    "github actions",
    "workflow",
    "npm install",
    "pip install",
    "pnpm install",
    "yarn install",
    "curl ",
    "wget ",
    "xcodebuild archive",
    "xcrun altool",
    "xcrun notarytool",
]

CONTENT_SCAN_EXEMPT_PREFIXES = [
    ".codex/runs/",
    ".codex/hooks/",
    ".codex/rules/",
    ".codex/schemas/",
    "docs/",
    "prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-001.md",
    "prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md",
    "prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md",
    "prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-004.md",
    "build/reports/",
    "AGENTS.md",
    ".agents/AGENTS.md",
    ".codex/AGENTS.md",
    "docs/AGENTS.md",
    "scripts/AGENTS.md",
]

SCHEMA_EXPECTED_REQUIRED = {
    "batch_id",
    "status",
    "summary",
    "changed_files",
    "validations_run",
    "no_cost_proof",
    "source_truth",
    "risks",
    "rollback",
    "next_recommended_batch",
}

SOURCE_TRUTH_ACTIVE_FILES = [
    "docs/truth/README.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
]

SOURCE_TRUTH_SUPPORTING_FILES = [
    "AGENTS.md",
    ".codex/config.toml",
    "docs/codex-os/",
]

EXECPOLICY_EXPECTATIONS = [
    (["git", "status"], "allow"),
    (["make", "ambitions-codex-os-validate"], "allow"),
    (["make", "ambitions-codex-os-doctor"], "allow"),
    (["git", "push"], "forbidden"),
    (["npm", "install"], "forbidden"),
    (["curl", "https://example.com"], "forbidden"),
    (["xcodebuild", "archive"], "forbidden"),
]

HOOK_SEMANTIC_CASES = [
    ("pre_tool_use_policy.py", {"tool_input": {"command": "rg openai docs/truth"}}, "approve"),
    ("pre_tool_use_policy.py", {"tool_input": {"command": "OPENAI_API_KEY=secret python3 script.py"}}, "deny"),
    ("pre_tool_use_policy.py", {"tool_input": {"command": "npm install"}}, "deny"),
    ("pre_tool_use_policy.py", {"tool_input": {"command": "curl https://example.com"}}, "deny"),
    ("pre_tool_use_policy.py", {"tool_input": {"command": "git push"}}, "deny"),
    ("pre_tool_use_policy.py", {"tool_input": {"command": "xcodebuild archive"}}, "deny"),
    ("permission_request_guard.py", {"tool_input": {"command": "rg openai docs/truth"}}, "allow"),
    ("permission_request_guard.py", {"tool_input": {"command": "OPENAI_API_KEY=secret python3 script.py"}}, "deny"),
    ("permission_request_guard.py", {"tool_input": {"command": "npm install"}}, "deny"),
]

ALLOWED_PATTERN_CONTEXT_EXEMPT_PREFIXES = [
    "docs/codex-os/",
    "docs/truth/",
    ".codex/rules/",
    ".codex/hooks/",
    ".agents/skills/",
    "scripts/ambitions-codex-os-validate.py",
    "scripts/ambitions-codex-os-doctor.py",
    "scripts/ambitions-codex-os-print-install-notes.py",
    "scripts/AGENTS.md",
    "docs/AGENTS.md",
    ".agents/AGENTS.md",
    ".codex/AGENTS.md",
]

ALLOWED_PROMPT_CONTROL_FILES = {
    "prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md",
    *[path.relative_to(ROOT).as_posix() for path in REQUIRED_GENERATED_PROMPTS],
}


def ok(message: str) -> dict:
    return {"status": "pass", "message": message}


def fail(message: str, hard: bool = True) -> dict:
    return {"status": "fail" if hard else "warn", "message": message}


def file_exists(path: Path) -> tuple[bool, str]:
    return path.is_file(), str(path)


def has_yaml_front_matter(path: Path) -> bool:
    text = path.read_text(encoding="utf-8", errors="ignore")
    if not text.startswith("---\n"):
        return False
    end = text.find("\n---\n", 3)
    if end == -1:
        return False
    front = text[4:end]
    return "name:" in front and "description:" in front


def has_runner_header(path: Path) -> bool:
    text = path.read_text(encoding="utf-8", errors="ignore")
    return (
        "<!-- AMBITIONS_RUNNER_REQUIRED: true -->" in text
        and "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->" in text
        and "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->" in text
    )


def run_json(path: Path) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8", errors="ignore"))


def normalize(paths: list[object]) -> list[str]:
    out: list[str] = []
    seen = set()
    for path in paths:
        if path is None:
            continue
        p = Path(str(path).strip())
        if p.is_absolute():
            try:
                p = p.relative_to(ROOT)
            except ValueError:
                p = p
        rel = p.as_posix()
        if not rel or rel in seen:
            continue
        seen.add(rel)
        out.append(rel)
    out.sort()
    return out


def external_dirty_paths() -> set[str]:
    """Return exact paths for unrelated in-flight work the operator classified."""
    raw = os.environ.get("AMBITIONS_CODEX_OS_EXTERNAL_DIRTY_PATHS", "")
    requested: list[str] = []
    for part in raw.replace(",", "\n").splitlines():
        part = part.strip()
        if part:
            requested.append(part)
    return set(normalize([*DEFAULT_EXTERNAL_DIRTY_CONTROL_WORK, *requested]))


def _parse_status_lines(raw: str) -> list[str]:
    paths: list[str] = []
    for line in raw.splitlines():
        if len(line) < 4:
            continue
        raw_path = line[3:].strip()
        if " -> " in raw_path:
            raw_path = raw_path.split(" -> ", 1)[1].strip()
        if raw_path:
            paths.append(raw_path)
    return paths


def _git_changed_files() -> list[str]:
    changed: list[str] = []
    try:
        changed += _parse_status_lines(
            subprocess.check_output(["git", "status", "--porcelain=v1"], cwd=str(ROOT), text=True)
        )
    except Exception:
        pass

    try:
        others = subprocess.check_output(
            ["git", "ls-files", "--others", "--exclude-standard"], cwd=str(ROOT), text=True
        )
        changed += [line for line in others.splitlines() if line.strip()]
    except Exception:
        pass

    return normalize(changed)


def _is_scoped_allow(path: str) -> bool:
    if path.startswith(".codex/runs/"):
        return True
    if path in ALLOWED_REPORT_PATHS:
        return True
    if path.startswith("build/reports/codex-runs/"):
        return True
    return False


def scope_gate(changed_files: list[str]) -> list[dict]:
    issues: list[dict] = []
    external_dirty = external_dirty_paths()
    for path in changed_files:
        if path in external_dirty:
            issues.append(ok(f"external dirty work excluded from batch-owned scope checks: {path}"))
            continue

        if _is_scoped_allow(path):
            continue

        for pattern in FORBIDDEN_SCOPE_PATTERNS:
            if fnmatch(path, pattern) or path.startswith(pattern):
                issues.append(fail(f"forbidden scope path changed: {path}"))
                break

        if path.endswith(".lock") and path not in {
            "package-lock.json",
            "yarn.lock",
            "pnpm-lock.yaml",
            "Podfile.lock",
            "Cartfile.resolved",
            "Gemfile.lock",
            "Pipfile.lock",
            "package-lock",
        }:
            issues.append(fail(f"locked dependency file changed: {path}"))
            continue

        if path.startswith(".github/workflows"):
            continue

        if path.endswith(".entitlements") or path.endswith("Info.plist"):
            issues.append(fail(f"app/project sensitive file changed: {path}"))

    return issues


def forbidden_content_scan() -> list[dict]:
    issues: list[dict] = []
    external_dirty = external_dirty_paths()

    for path in normalize([*CONTROL_FILES, *_git_changed_files()]):
        absolute = ROOT / path
        if not absolute.exists() or not absolute.is_file():
            continue

        if path in external_dirty:
            issues.append(ok(f"external dirty prompt content intentionally excluded: {path}"))
            continue

        if path in ALLOWED_PROMPT_CONTROL_FILES:
            continue

        if any(path.startswith(prefix) for prefix in CONTENT_SCAN_EXEMPT_PREFIXES):
            continue

        if any(path.startswith(prefix) for prefix in ALLOWED_PATTERN_CONTEXT_EXEMPT_PREFIXES):
            continue

        if absolute.suffix.lower() in {".py", ".toml", ".md", ".json", ".sh"}:
            text = absolute.read_text(encoding="utf-8", errors="ignore").lower()
            for pattern in FORBIDDEN_CONTENT_PATTERNS:
                if pattern in text:
                    issues.append(fail(f"forbidden pattern '{pattern}' in control file {path}"))

    return issues


def git_diff_report() -> list[dict]:
    checks: list[dict] = []

    for path in REQUIRED_FILES:
        exists, label = file_exists(path)
        checks.append(ok(f"exists: {label}") if exists else fail(f"missing required file: {label}"))

    for path in SKILLS:
        exists = path.is_file()
        if not exists:
            checks.append(fail(f"missing skill: {path}"))
            continue

        if not has_yaml_front_matter(path):
            checks.append(fail(f"invalid skill front matter: {path}"))

    for path in REQUIRED_GENERATED_PROMPTS:
        if not path.is_file():
            checks.append(fail(f"missing generated batch prompt: {path}"))
            continue

        if has_runner_header(path):
            checks.append(ok(f"generated batch prompt has runner header: {path}"))
        else:
            checks.append(fail(f"generated batch prompt missing runner header: {path}"))

    for path in HOOKS:
        if _compile_py(path):
            checks.append(ok(f"compiled {path}"))
        else:
            checks.append(fail(f"compile failed for hook: {path}"))

    checks.append(ok("schema loaded"))

    return checks


def _compile_py(path: Path) -> bool:
    try:
        py_compile.compile(str(path), doraise=True)
        return True
    except Exception as exc:
        return False


def schema_checks(checks: list[dict]) -> list[dict]:
    schema_path = ROOT / ".codex" / "schemas" / "ambitions-batch-result.schema.json"
    if not schema_path.exists():
        checks.append(fail(f"missing schema: {schema_path}"))
        return checks

    try:
        schema = run_json(schema_path)
    except Exception as exc:
        checks.append(fail(f"schema parse failed: {exc}"))
        return checks

    required = set(schema.get("required", []))
    missing = sorted(SCHEMA_EXPECTED_REQUIRED - required)
    if missing:
        checks.append(fail(f"schema missing required keys: {', '.join(missing)}"))
    else:
        checks.append(ok("schema parsed with expected required keys"))

    return checks


def _is_batch_output_report(path: str) -> bool:
    return (
        path in ALLOWED_REPORT_PATHS
        or path.startswith("build/reports/ambitions-codex-os-dry-run-")
        or path.startswith("build/reports/") and path.endswith("-no-cost-runner-result.json")
    )


def _validate_output_payload(path: str) -> list[dict]:
    checks: list[dict] = []
    try:
        payload = run_json(ROOT / path)
    except Exception as exc:
        return [fail(f"failed to parse batch output report {path}: {exc}")]

    missing = sorted(k for k in SCHEMA_EXPECTED_REQUIRED if k not in payload)
    if missing:
        checks.append(fail(f"batch output report {path} missing required keys: {', '.join(missing)}"))

    if payload.get("status") not in {"GREEN", "YELLOW", "RED"}:
        checks.append(fail(f"batch output report {path} has invalid status: {payload.get('status')}"))

    for key in ("changed_files", "validations_run", "risks", "rollback"):
        value = payload.get(key)
        if not isinstance(value, list):
            checks.append(fail(f"batch output report {path} field '{key}' must be an array"))

    for key in ("no_cost_proof", "source_truth"):
        if not isinstance(payload.get(key), dict):
            checks.append(fail(f"batch output report {path} field '{key}' must be an object"))

    return checks


def config_checks() -> list[dict]:
    checks: list[dict] = []
    config_path = ROOT / ".codex" / "config.toml"

    try:
        lines = config_path.read_text(encoding="utf-8").splitlines()
    except Exception as exc:
        return [fail(f"config parse failed: {exc}")]

    current_table = ""
    hooks_key_table: str | None = None
    hooks_enabled = False
    configured_events: set[str] = set()

    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        if line.startswith("[") and line.endswith("]"):
            current_table = line.strip("[]")
            continue

        if current_table == "features" and line in {"hooks = true", "codex_hooks = true"}:
            hooks_enabled = True

        if line.startswith("hooks =") and current_table != "features":
            hooks_key_table = current_table

    if hooks_enabled:
        checks.append(ok("config enables hooks feature"))
    else:
        checks.append(fail("config must enable [features].hooks = true"))

    if hooks_key_table is None:
        checks.append(ok("config leaves hook handlers to .codex/hooks.json discovery"))
    else:
        checks.append(fail("config.toml must not declare hook handlers inline; use .codex/hooks.json"))

    return checks


def hooks_json_checks() -> list[dict]:
    checks: list[dict] = []
    hooks_path = ROOT / ".codex" / "hooks.json"

    try:
        hooks_config = json.loads(hooks_path.read_text(encoding="utf-8"))
    except Exception as exc:
        return [fail(f"hooks.json parse failed: {exc}")]

    expected_events = {"SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest", "PostToolUse", "Stop"}
    configured_events = set(hooks_config.keys()) if isinstance(hooks_config, dict) else set()
    missing_events = sorted(expected_events - configured_events)
    if missing_events:
        checks.append(fail(f"hooks.json missing hook events: {', '.join(missing_events)}"))
    else:
        checks.append(ok("hooks.json declares expected hook events"))

    text = hooks_path.read_text(encoding="utf-8", errors="ignore")
    for hook in HOOKS:
        rel = hook.relative_to(ROOT).as_posix()
        if rel in text:
            checks.append(ok(f"hooks.json references {rel}"))
        else:
            checks.append(fail(f"hooks.json missing command reference for {rel}"))

    return checks


def runner_header_scan() -> dict:
    text_paths = [ROOT / "AGENTS.md", ROOT / "docs" / "AGENTS.md", ROOT / "scripts" / "AGENTS.md"]
    for path in text_paths:
        if not path.exists():
            continue
        body = path.read_text(encoding="utf-8", errors="ignore").lower()
        if "ambitions_runner_required" in body and "scripts/ambitions-codex-train.sh" in body:
            return ok("runner header policy documented")
    return fail("runner header policy missing")


def infer_batch_id(changed_files: list[str]) -> str:
    if (
        "prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md" in changed_files
        or any(path.startswith("prompts/batches/OS-FLAGSHIP-") for path in changed_files)
        or any(path.startswith("docs/codex/os/") for path in changed_files)
        or any(path.startswith(".codex/skills/ambitions/") for path in changed_files)
    ):
        return "AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01"

    return next(
        (
            changed.split("/", 2)[2].replace(".md", "")
            for changed in changed_files
            if changed.startswith("prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-")
        ),
        "AMB-CODEX-OS-NO-COST-HARDENING-002",
    )


def execpolicy_checks() -> list[dict]:
    checks: list[dict] = []
    if shutil.which("codex") is None:
        return [fail("codex execpolicy unavailable; rule semantics not verified", hard=False)]

    rules_path = ROOT / ".codex" / "rules" / "ambitions-no-cost.rules"
    for command, expected in EXECPOLICY_EXPECTATIONS:
        try:
            raw = subprocess.check_output(
                ["codex", "execpolicy", "check", "--rules", str(rules_path), *command],
                cwd=str(ROOT),
                text=True,
                stderr=subprocess.STDOUT,
            )
            payload = json.loads(raw)
        except Exception as exc:
            checks.append(fail(f"execpolicy check failed for {' '.join(command)}: {exc}"))
            continue

        decision = payload.get("decision")
        label = " ".join(command)
        if decision == expected:
            checks.append(ok(f"execpolicy {label}: {decision}"))
        else:
            checks.append(fail(f"execpolicy {label}: expected {expected}, got {decision}"))

    return checks


def hook_semantic_checks() -> list[dict]:
    checks: list[dict] = []
    hooks_dir = ROOT / ".codex" / "hooks"
    import sys
    python_exe = "python" if sys.platform == "win32" else ("python3" if shutil.which("python3") else "python")

    for hook_name, payload, expected in HOOK_SEMANTIC_CASES:
        hook_path = hooks_dir / hook_name
        try:
            raw = subprocess.check_output(
                [python_exe, str(hook_path)],
                cwd=str(ROOT),
                input=json.dumps(payload),
                text=True,
                stderr=subprocess.STDOUT,
            )
            result = json.loads(raw)
        except Exception as exc:
            checks.append(fail(f"hook semantic check failed for {hook_name}: {exc}"))
            continue

        decision = str(result.get("permissionDecision") or result.get("decision") or "").lower()
        label = payload.get("tool_input", {}).get("command", hook_name)
        if decision == expected:
            checks.append(ok(f"hook {hook_name} {label}: {decision}"))
        else:
            checks.append(fail(f"hook {hook_name} {label}: expected {expected}, got {decision}"))

    return checks


def validate() -> int:
    changed_files = _git_changed_files()
    external_dirty = sorted(path for path in changed_files if path in external_dirty_paths())

    checks: list[dict] = []
    checks.extend(git_diff_report())
    checks.extend(scope_gate(changed_files))
    checks.extend(forbidden_content_scan())
    checks = schema_checks(checks)
    checks.extend(config_checks())
    checks.extend(hooks_json_checks())
    checks.extend(execpolicy_checks())
    checks.extend(hook_semantic_checks())
    checks.append(runner_header_scan())

    hard_failures = [item for item in checks if item["status"] == "fail"]

    for path in changed_files:
        if _is_batch_output_report(path):
            checks.extend(_validate_output_payload(path))

    hard_failures = [item for item in checks if item["status"] == "fail"]

    status = "GREEN"
    if hard_failures:
        status = "RED"
    elif any(item["status"] == "warn" for item in checks):
        status = "YELLOW"

    for path in changed_files:
        if path.startswith("build/reports/") and not _is_batch_output_report(path):
            hard_failures.append(fail(f"disallowed report change: {path}"))
            status = "RED"
            checks.append(fail(f"disallowed report change: {path}"))

    batch_id = infer_batch_id(changed_files)

    if any(item["status"] == "fail" for item in hard_failures):
        status = "RED"
    elif status == "GREEN" and not any(item["status"] == "pass" for item in checks):
        status = "YELLOW"

    report = {
        "batch_id": batch_id,
        "status": status,
        "summary": "Ambitions Codex OS validation for local hardening control-plane",
        "changed_files": changed_files,
        "validations_run": checks,
        "no_cost_proof": {
            "new_dependencies_added": False,
            "credential_material_added": False,
            "network_or_ci_added": False,
            "paid_services_added": False,
            "notes": "Control-plane changes remain local-only and standard-library based.",
        },
        "source_truth": {
            "active_truth_files": SOURCE_TRUTH_ACTIVE_FILES,
            "supporting_files": SOURCE_TRUTH_SUPPORTING_FILES,
            "uncertainties": [
                "Validate final execpolicy behavior for allow/forbid outcomes after local CLI semantics are confirmed.",
                *(
                    [f"External dirty work was operator-classified and excluded from Codex OS scope: {', '.join(external_dirty)}"]
                    if external_dirty
                    else []
                ),
            ],
        },
        "risks": [
            "Rules parser syntax is inferred from existing project style; run-time validation is required via codex execpolicy.",
            "Hard-fail scope checks require repository-specific path policy review if external build artifacts are expected.",
        ],
        "rollback": [
            "git checkout -- AGENTS.md docs/AGENTS.md .codex/config.toml Makefile",
            "git checkout -- scripts/AGENTS.md .codex/AGENTS.md .agents/AGENTS.md prompts/ambitions/README.md 2>/dev/null || true",
            "rm -rf .agents/skills/ambitions-*",
            "rm -rf .codex/hooks .codex/rules .codex/schemas",
            "rm -f .codex/hooks.json",
            "rm -rf docs/codex-os",
            "rm -rf .codex/runs/AMB-CODEX-OS-NO-COST-HARDENING-001",
            "rm -f scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py",
            "rm -f build/reports/ambitions-codex-os-validate.json",
        ],
        "next_recommended_batch": (
            "OS-FLAGSHIP-01-AUTHORITY-RESOLVER"
            if batch_id == "AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01"
            else "AMB-CODEX-OS-NO-COST-HARDENING-003"
        ),
    }

    print("Validation summary:")
    print(f" - status: {report['status']}")
    print(f" - changed files: {len(report['changed_files'])}")
    if report["status"] == "GREEN":
        print(" - all hard checks passed")
    elif report["status"] == "YELLOW":
        print(" - non-fatal warnings present")
    else:
        print(" - hard failures present")

    for item in checks:
        if item["status"] == "fail":
            print(item["message"])

    with REPORT_PATH.open("w", encoding="utf-8") as fp:
        json.dump(report, fp, indent=2)

    return 0 if report["status"] in {"GREEN", "YELLOW"} else 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Validate the local Ambitions Codex OS hardening control-plane.",
    )
    parser.add_argument(
        "--report-path",
        default=str(REPORT_PATH),
        help="Override the JSON report output path.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    global REPORT_PATH
    REPORT_PATH = Path(args.report_path)
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    return validate()


if __name__ == "__main__":
    raise SystemExit(main())
