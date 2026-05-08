#!/usr/bin/env python3
"""ACX Local: allowlisted local executor for Ambitions Codex OS."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
LOG_ROOT = ROOT / ".codex" / "logs"
OVERRIDES = ROOT / ".codex" / "local" / "acx-local-overrides.yml"
BUNDLES = ROOT / ".codex" / "manifests" / "acx-bundles.yml"
PROOF_CACHE = ROOT / ".codex" / "state" / "proof-cache.json"
DESTRUCTIVE_TERMS = [
    "rm",
    "mv",
    "cp -r",
    "git reset",
    "git clean",
    "git checkout",
    "git switch",
    "git push",
    "git commit",
    "sudo",
    "bash -c",
    "sh -c",
    "curl | sh",
]
KEY_PATTERNS = [
    "error:",
    "warning:",
    "BUILD FAILED",
    "TEST FAILED",
    "FAILED",
    "STOPPED ON RED",
    "Hard Red",
    "Red",
    "Yellow",
    "Green",
    "Traceback",
    "fatal:",
    ".swift:",
]


@dataclass(frozen=True)
class Profile:
    name: str
    description: str
    commands: tuple[tuple[str, ...], ...] = ()
    optional: bool = False
    kind: str = "run"


PROFILES: dict[str, Profile] = {
    "status": Profile("status", "git status --short --branch", (("git", "status", "--short", "--branch"),)),
    "changed-files": Profile("changed-files", "status plus Ambitions concern grouping", (("git", "status", "--short", "--branch"),)),
    "diff-stat": Profile("diff-stat", "git diff --stat", (("git", "diff", "--stat"),)),
    "diff-names": Profile("diff-names", "git diff --name-status", (("git", "diff", "--name-status"),)),
    "diff-compact": Profile("diff-compact", "git diff --unified=2 with compact key-line summary", (("git", "diff", "--unified=2"),)),
    "log": Profile("log", "git log --oneline -n 12", (("git", "log", "--oneline", "-n", "12"),)),
    "acx-help": Profile("acx-help", "python3 scripts/ai/acx.py --help", (("python3", "scripts/ai/acx.py", "--help"),)),
    "acx-gate-all": Profile("acx-gate-all", "python3 scripts/ai/acx.py gate all docs/codex .codex AGENTS.md", (("python3", "scripts/ai/acx.py", "gate", "all", "docs/codex", ".codex", "AGENTS.md"),)),
    "cqs-product-drift": Profile("cqs-product-drift", "CQS product drift scan", (("bash", "scripts/cqs-product-drift-scan.sh"),), optional=True),
    "cqs-release-claims": Profile("cqs-release-claims", "CQS privacy/security/release claim scan", (("bash", "scripts/cqs-privacy-security-claim-scan.sh"),), optional=True),
    "cqs-accessibility-motion": Profile("cqs-accessibility-motion", "CQS accessibility/motion scan", (("bash", "scripts/cqs-accessibility-motion-scan.sh"),), optional=True),
    "cqs-performance": Profile("cqs-performance", "CQS performance budget scan", (("bash", "scripts/cqs-performance-budget-scan.sh"),), optional=True),
    "xcodegen-generate": Profile("xcodegen-generate", "xcodegen generate when project.yml and xcodegen exist", (("xcodegen", "generate"),), optional=True),
    "build-help": Profile("build-help", "print discovered build command docs without running a build", kind="build-help"),
    "test-help": Profile("test-help", "print discovered test command docs without running tests", kind="test-help"),
}


def reject_destructive(argv: tuple[str, ...]) -> None:
    joined = " ".join(argv)
    for term in DESTRUCTIVE_TERMS:
        if term == "rm":
            if any(part == "rm" or part.endswith("/rm") for part in argv):
                raise ValueError(term)
            continue
        if term == "mv":
            if any(part == "mv" or part.endswith("/mv") for part in argv):
                raise ValueError(term)
            continue
        if term in joined:
            raise ValueError(term)


def load_override_profiles() -> dict[str, Profile]:
    if not OVERRIDES.exists():
        return {}
    profiles: dict[str, Profile] = {}
    current: str | None = None
    commands: list[tuple[str, ...]] = []
    for raw in OVERRIDES.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line == "profiles:":
            continue
        if line.endswith(":") and not line.startswith("-"):
            if current and commands:
                profiles[current] = Profile(current, "local override profile", tuple(commands), optional=True)
            current = line[:-1]
            commands = []
        elif line.startswith("- [") and current:
            body = line[3:].rstrip("]")
            argv = tuple(part.strip().strip('"').strip("'") for part in body.split(",") if part.strip())
            if argv:
                commands.append(argv)
    if current and commands:
        profiles[current] = Profile(current, "local override profile", tuple(commands), optional=True)
    return profiles


def all_profiles() -> dict[str, Profile]:
    merged = dict(PROFILES)
    merged.update(load_override_profiles())
    return merged


def load_bundles() -> dict[str, list[str]]:
    if not BUNDLES.exists():
        return {}
    bundles: dict[str, list[str]] = {}
    current: str | None = None
    in_profiles = False
    for raw in BUNDLES.read_text(encoding="utf-8").splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        leading = len(raw) - len(raw.lstrip(" "))
        if leading == 2 and stripped.endswith(":") and stripped[:-1] not in {"bundles", "safety"}:
            current = stripped[:-1]
            bundles.setdefault(current, [])
            in_profiles = False
            continue
        if current and stripped == "profiles:":
            in_profiles = True
            continue
        if current and in_profiles and stripped.startswith("-"):
            bundles[current].append(stripped[1:].strip().strip('"').strip("'"))
    return bundles


def concern_for(path: str) -> str:
    if path.startswith(".codex/"):
        return ".codex"
    if path.startswith("docs/canon/"):
        return "docs/canon"
    if path.startswith("docs/codex/"):
        return "docs/codex"
    if path.startswith("docs/"):
        return "docs"
    if path.startswith("scripts/"):
        return "scripts"
    if path.startswith(("Native/", "Sources/", "AppUI/Sources/")):
        return "source"
    if "Tests/" in path or path.endswith("Tests.swift"):
        return "tests"
    if path in {"AGENTS.md", "project.yml", ".gitignore"} or path.endswith((".yml", ".yaml", ".toml", ".json")):
        return "config"
    return "other"


def key_lines(text: str) -> list[str]:
    return [line for line in text.splitlines() if any(pattern in line for pattern in KEY_PATTERNS)]


def timestamp_dir() -> Path:
    stamp = dt.datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    path = LOG_ROOT / stamp
    path.mkdir(parents=True, exist_ok=True)
    return path


def optional_unavailable(profile: Profile) -> str | None:
    if profile.name == "xcodegen-generate":
        if not (ROOT / "project.yml").exists():
            return "project.yml is unavailable"
        if shutil.which("xcodegen") is None:
            return "xcodegen is not installed"
    for argv in profile.commands:
        if len(argv) >= 2 and argv[0] == "bash" and argv[1].startswith("scripts/") and not (ROOT / argv[1]).exists():
            return f"{argv[1]} is unavailable"
    return None


def discover_docs(kind: str) -> str:
    needles = ["xcodebuild", "build"] if kind == "build-help" else ["test", "xctest"]
    docs = [ROOT / "README.md", ROOT / "docs" / "README.md", ROOT / "docs" / "codex" / "CONTEXT_INDEX.md", ROOT / "docs" / "codex" / "MAC_CODEX_5_5_TOOLCHAIN_SETUP.md"]
    lines: list[str] = []
    for doc in docs:
        if not doc.exists():
            continue
        for idx, line in enumerate(doc.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            lowered = line.lower()
            if any(needle in lowered for needle in needles):
                lines.append(f"{doc.relative_to(ROOT)}:{idx}: {line}")
    if not lines:
        return "Yellow: no documented command lines discovered in the configured docs."
    return "\n".join(lines[:80])


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def write_logs(profile_name: str, raw: str, summary: str, code: int) -> Path:
    log_dir = timestamp_dir()
    raw_path = log_dir / f"{profile_name}.raw.log"
    summary_path = log_dir / f"{profile_name}.summary.md"
    raw_path.write_text(raw, encoding="utf-8")
    summary_path.write_text(summary + f"\n\nExit code: {code}\nRaw log: `{raw_path}`\nRaw log sha256: `{sha256_text(raw)}`\n", encoding="utf-8")
    update_proof_cache(profile_name, code, raw_path, sha256_text(raw))
    return raw_path


def current_commit() -> str:
    try:
        proc = subprocess.run(("git", "rev-parse", "HEAD"), cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
        return proc.stdout.strip() if proc.returncode == 0 else "unknown"
    except Exception:
        return "unknown"


def update_proof_cache(profile_name: str, code: int, raw_path: Path, digest: str) -> None:
    PROOF_CACHE.parent.mkdir(parents=True, exist_ok=True)
    try:
        data = json.loads(PROOF_CACHE.read_text(encoding="utf-8")) if PROOF_CACHE.exists() else {}
    except json.JSONDecodeError:
        data = {}
    entries = data.setdefault("entries", [])
    entries.append(
        {
            "timestamp": dt.datetime.now().isoformat(timespec="seconds"),
            "commit": current_commit(),
            "profile": profile_name,
            "exit": code,
            "raw_log": str(raw_path.relative_to(ROOT)) if raw_path.is_relative_to(ROOT) else str(raw_path),
            "raw_log_sha256": digest,
        }
    )
    data["entries"] = entries[-200:]
    PROOF_CACHE.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def run_profile(profile: Profile) -> int:
    unavailable = optional_unavailable(profile)
    if unavailable and profile.optional:
        raw = f"Yellow: optional profile unavailable: {unavailable}\n"
        summary = f"# ACX Local Summary: {profile.name}\n\nResult: Yellow\n- {unavailable}"
        raw_path = write_logs(profile.name, raw, summary, 0)
        print(summary)
        print(f"Raw log: {raw_path}")
        return 0
    if profile.kind in {"build-help", "test-help"}:
        raw = discover_docs(profile.kind)
        summary = f"# ACX Local Summary: {profile.name}\n\nResult: Yellow\nThis prints discovered docs only and does not prove build/test success.\n\n{raw}"
        raw_path = write_logs(profile.name, raw + "\n", summary, 0)
        print(summary)
        print(f"Raw log: {raw_path}")
        return 0

    combined = []
    exit_code = 0
    for argv in profile.commands:
        try:
            reject_destructive(argv)
        except ValueError as exc:
            raw = f"Rejected destructive command term before execution: {exc}\nCommand: {list(argv)}\n"
            summary = f"# ACX Local Summary: {profile.name}\n\nResult: Red\n- Rejected destructive term `{exc}` before execution."
            raw_path = write_logs(profile.name, raw, summary, 2)
            print(summary)
            print(f"Raw log: {raw_path}")
            return 2
        proc = subprocess.run(argv, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
        exit_code = proc.returncode if proc.returncode != 0 else exit_code
        combined.append(f"$ {' '.join(argv)}\n# exit {proc.returncode}\n\n[stdout]\n{proc.stdout}\n[stderr]\n{proc.stderr}\n")

    raw = "\n".join(combined)
    keys = key_lines(raw)
    summary_lines = [f"# ACX Local Summary: {profile.name}", "", f"Exit code: {exit_code}", ""]
    if profile.name == "changed-files":
        paths = []
        for line in raw.splitlines():
            if line.startswith("##") or len(line) < 4 or line.startswith("$ "):
                continue
            status_prefix = line[:2]
            known_status = status_prefix in {" M", "M ", "MM", "A ", " A", "D ", " D", "R ", " R", "C ", " C", "??"}
            if known_status:
                body = line[3:] if len(line) > 3 else line
                paths.append(body.split(" -> ")[-1].strip())
        grouped: dict[str, list[str]] = {}
        for path in paths:
            grouped.setdefault(concern_for(path), []).append(path)
        summary_lines.append("Changed files by Ambitions concern:")
        for concern, items in sorted(grouped.items()):
            summary_lines.append(f"- {concern}: {len(items)}")
            for item in items[:12]:
                summary_lines.append(f"  - {item}")
    elif profile.name == "diff-compact":
        summary_lines.append("Important diff/key lines:")
        for line in keys[:120]:
            summary_lines.append(f"- {line[:220]}")
        if not keys:
            summary_lines.append("- No configured key lines found; inspect raw log for full diff.")
    else:
        summary_lines.append("Key lines:")
        for line in keys[:80]:
            summary_lines.append(f"- {line[:220]}")
        if not keys:
            summary_lines.append("- No configured key lines found.")
    raw_path = write_logs(profile.name, raw, "\n".join(summary_lines), exit_code)
    print("\n".join(summary_lines))
    print(f"Raw log: {raw_path}")
    return exit_code


def run_bundle(name: str) -> int:
    bundles = load_bundles()
    profiles = all_profiles()
    selected = bundles.get(name)
    if not selected:
        raw = f"Unknown bundle rejected before execution: {name}\nNo profile executed.\n"
        summary = f"# ACX Local Bundle Summary: invalid-bundle\n\nResult: Red\n- Unknown bundle `{name}` rejected before execution."
        raw_path = write_logs("invalid-bundle", raw, summary, 2)
        print(f"ACX Local Red: unknown bundle `{name}`. No profile executed.", file=sys.stderr)
        print(f"Raw log: {raw_path}", file=sys.stderr)
        return 2
    print(f"# ACX Local Bundle: {name}")
    result = 0
    for profile_name in selected:
        profile = profiles.get(profile_name)
        if profile is None:
            print(f"- Missing profile `{profile_name}` in bundle `{name}`")
            result = 2
            continue
        code = run_profile(profile)
        if code != 0:
            result = code
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="ACX Local allowlisted executor.")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list", help="List allowlisted profiles")
    sub.add_parser("bundles", help="List configured bundles")
    run = sub.add_parser("run", help="Run one allowlisted profile")
    run.add_argument("profile")
    bundle = sub.add_parser("bundle", help="Run one allowlisted profile bundle")
    bundle.add_argument("name")
    args = parser.parse_args()

    profiles = all_profiles()
    if args.command == "list":
        for name in sorted(profiles):
            print(f"{name}: {profiles[name].description}")
        return 0
    if args.command == "bundles":
        for name, profile_names in sorted(load_bundles().items()):
            print(f"{name}: {', '.join(profile_names)}")
        return 0
    if args.command == "bundle":
        return run_bundle(args.name)
    profile = profiles.get(args.profile)
    if profile is None:
        raw = f"Unknown profile rejected before execution: {args.profile}\nNo command executed.\n"
        summary = f"# ACX Local Summary: invalid-profile\n\nResult: Red\n- Unknown profile `{args.profile}` rejected before execution."
        raw_path = write_logs("invalid-profile", raw, summary, 2)
        print(f"ACX Local Red: unknown profile `{args.profile}`. No command executed.", file=sys.stderr)
        print(f"Raw log: {raw_path}", file=sys.stderr)
        return 2
    return run_profile(profile)


if __name__ == "__main__":
    raise SystemExit(main())
