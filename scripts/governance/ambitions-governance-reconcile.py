#!/usr/bin/env python3
"""
Ambitions governance reconciler.

Builds implementation-level governance metadata from actual local repo state:
- train -> prompt files
- train -> commit lineage
- train -> changed implementation files
- train -> audit/report/test/proof linkage
- registry status conflicts
- stale overlay detections
- generated registry projection

Run from repo root:
  python3 scripts/governance/ambitions-governance-reconcile.py --write

Strict validation:
  python3 scripts/governance/ambitions-governance-reconcile.py --write --strict
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

TRAIN_RE = re.compile(r"\b([A-Z]{2,8})(\d{1,3})([A-Z]?)\b")
TRAIN_RANGE_RE = re.compile(r"\b([A-Z]{2,8})(\d{1,3})\s*-\s*\1(\d{1,3})\b")
VALID_TEXT_SUFFIXES = {".md", ".txt", ".json", ".swift", ".py", ".yml", ".yaml", ".sh"}

PROMPT_DIRS = (
    "prompts",
    "docs/codex",
    "docs/canon",
    ".codex",
)
PROOF_DIR_PREFIXES = (
    "docs/audits/",
    "build/reports/",
    ".codex/runs/",
    "Tests/",
    "Native/Tests/",
    "Sources/Tests/",
    "test/",
    "tests/",
)
IMPLEMENTATION_PREFIXES = (
    "Native/",
    "Sources/",
    "App/",
    "Packages/",
    "scripts/",
    "project.yml",
    "Package.swift",
)
GOVERNANCE_PREFIXES = (
    "docs/governance/",
    "docs/codex/",
    "docs/canon/",
)

STALE_OVERLAY_PATTERNS = {
    "plan_top_level_language": re.compile(r"\bPlan\b(?!\s*(?:is no longer|remains valid|compatibility|historical|superseded|raw|route|contextual|Adjust plan))"),
    "hero_step_primary_language": re.compile(r"\bHero Step Panel\b(?!.*(?:alias|historical|superseded|implementation))"),
    "mission_control_primary_language": re.compile(r"\bMission Control\b(?!.*(?:detail|internal|historical|superseded|lane))"),
    "release_ready_claim": re.compile(r"\b(?:release[- ]ready|App Store ready|TestFlight ready|production ready)\b", re.I),
}

@dataclass
class CommitHit:
    sha: str
    date: str
    subject: str
    files: list[str]

@dataclass
class TrainRecord:
    train_id: str
    family: str
    prompt_files: set[str] = field(default_factory=set)
    registry_mentions: list[str] = field(default_factory=list)
    commits: list[CommitHit] = field(default_factory=list)
    implementation_files: set[str] = field(default_factory=set)
    proof_files: set[str] = field(default_factory=set)
    governance_files: set[str] = field(default_factory=set)
    audit_files: set[str] = field(default_factory=set)
    report_files: set[str] = field(default_factory=set)
    test_files: set[str] = field(default_factory=set)
    inferred_state: str = "NEEDS_RECONCILIATION"
    confidence: str = "LOW"
    warnings: list[str] = field(default_factory=list)

    def to_json(self) -> dict:
        return {
            "train_id": self.train_id,
            "family": self.family,
            "state": self.inferred_state,
            "confidence": self.confidence,
            "prompt_files": sorted(self.prompt_files),
            "registry_mentions": self.registry_mentions[:20],
            "commits": [c.__dict__ for c in self.commits[:50]],
            "implementation_files": sorted(self.implementation_files),
            "proof_files": sorted(self.proof_files),
            "audit_files": sorted(self.audit_files),
            "report_files": sorted(self.report_files),
            "test_files": sorted(self.test_files),
            "governance_files": sorted(self.governance_files),
            "warnings": self.warnings,
        }


def run_git(repo: Path, args: list[str], allow_fail: bool = False) -> str:
    proc = subprocess.run(["git", *args], cwd=repo, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if proc.returncode != 0 and not allow_fail:
        raise RuntimeError(f"git {' '.join(args)} failed:\n{proc.stderr}")
    return proc.stdout


def git_commit_iso(repo: Path) -> str:
    raw = run_git(repo, ["show", "-s", "--format=%cI", "HEAD"], allow_fail=True).strip()
    return raw or "unknown"


def rel(path: Path, repo: Path) -> str:
    return path.relative_to(repo).as_posix()


def is_text_file(path: Path) -> bool:
    return path.is_file() and path.suffix in VALID_TEXT_SUFFIXES


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


def extract_train_ids(text: str) -> set[str]:
    ids = {f"{m.group(1)}{int(m.group(2)):02d}{m.group(3)}" for m in TRAIN_RE.finditer(text)}
    for m in TRAIN_RANGE_RE.finditer(text):
        prefix = m.group(1)
        start = int(m.group(2))
        end = int(m.group(3))
        if 0 <= start <= end <= 200:
            ids.update(f"{prefix}{i:02d}" for i in range(start, end + 1))
    return ids


def family_of(train_id: str) -> str:
    return re.match(r"^[A-Z]+", train_id).group(0)  # type: ignore[union-attr]


def discover_files(repo: Path) -> list[Path]:
    ignored = {".git", ".build", "DerivedData", "node_modules"}
    out: list[Path] = []
    for root, dirs, files in os.walk(repo):
        dirs[:] = [d for d in dirs if d not in ignored]
        root_path = Path(root)
        for name in files:
            p = root_path / name
            if is_text_file(p):
                out.append(p)
    return out


def scan_prompt_and_registry_files(repo: Path, all_files: list[Path]) -> tuple[dict[str, TrainRecord], dict[str, list[str]], list[dict]]:
    records: dict[str, TrainRecord] = {}
    mentions: dict[str, list[str]] = defaultdict(list)
    stale_findings: list[dict] = []

    for path in all_files:
        r = rel(path, repo)
        text = read_text(path)
        train_ids = extract_train_ids(text + "\n" + Path(r).stem)
        for tid in train_ids:
            rec = records.setdefault(tid, TrainRecord(train_id=tid, family=family_of(tid)))
            mentions[tid].append(r)
            if r.startswith(PROMPT_DIRS) and ("prompt" in r.lower() or "/batches/" in r or "batch" in r.lower()):
                rec.prompt_files.add(r)
            if r == "docs/codex/BATCH_REGISTRY.md" or "registry" in r.lower():
                line_hits = []
                for i, line in enumerate(text.splitlines(), start=1):
                    if tid in line:
                        line_hits.append(f"{r}:{i}: {line.strip()[:220]}")
                        if len(line_hits) >= 10:
                            break
                rec.registry_mentions.extend(line_hits)
            if r.startswith(PROOF_DIR_PREFIXES):
                rec.proof_files.add(r)
                if r.startswith("docs/audits/"):
                    rec.audit_files.add(r)
                if r.startswith("build/reports/"):
                    rec.report_files.add(r)
                if "/test" in r.lower() or r.lower().startswith(("tests/", "test/")):
                    rec.test_files.add(r)
            if r.startswith(GOVERNANCE_PREFIXES):
                rec.governance_files.add(r)

        if r.startswith(("docs/", "prompts/")):
            for name, pattern in STALE_OVERLAY_PATTERNS.items():
                for i, line in enumerate(text.splitlines(), start=1):
                    if pattern.search(line):
                        stale_findings.append({"kind": name, "path": r, "line": i, "text": line.strip()[:260]})
                        break

    return records, mentions, stale_findings


def parse_git_log(repo: Path) -> list[CommitHit]:
    raw = run_git(repo, ["log", "--all", "--date=iso-strict", "--name-only", "--pretty=format:__COMMIT__%H%x09%ad%x09%s"], allow_fail=True)
    commits: list[CommitHit] = []
    current: CommitHit | None = None
    for line in raw.splitlines():
        if line.startswith("__COMMIT__"):
            if current:
                commits.append(current)
            parts = line.removeprefix("__COMMIT__").split("\t", 2)
            if len(parts) == 3:
                current = CommitHit(sha=parts[0], date=parts[1], subject=parts[2], files=[])
        elif current and line.strip():
            current.files.append(line.strip())
    if current:
        commits.append(current)
    return commits


def attach_commits(records: dict[str, TrainRecord], commits: list[CommitHit]) -> None:
    known_ids = set(records)
    for commit in commits:
        text = commit.subject + "\n" + "\n".join(commit.files)
        ids = extract_train_ids(text)
        for tid in sorted(ids & known_ids):
            rec = records[tid]
            rec.commits.append(commit)
            for f in commit.files:
                if f.startswith(IMPLEMENTATION_PREFIXES):
                    rec.implementation_files.add(f)
                if f.startswith(PROOF_DIR_PREFIXES):
                    rec.proof_files.add(f)
                    if f.startswith("docs/audits/"):
                        rec.audit_files.add(f)
                    if f.startswith("build/reports/"):
                        rec.report_files.add(f)
                    if "/test" in f.lower() or f.lower().startswith(("tests/", "test/")):
                        rec.test_files.add(f)
                if f.startswith(GOVERNANCE_PREFIXES):
                    rec.governance_files.add(f)


def infer_states(records: dict[str, TrainRecord]) -> None:
    for rec in records.values():
        has_prompt = bool(rec.prompt_files)
        has_commit = bool(rec.commits)
        has_impl = bool(rec.implementation_files)
        has_proof = bool(rec.proof_files or rec.audit_files or rec.report_files or rec.test_files)
        registry_text = "\n".join(rec.registry_mentions).lower()

        complete_mentions = any(x in registry_text for x in ["complete", "completed", "green", "accepted yellow"])
        queued_mentions = any(x in registry_text for x in ["queued", "next eligible", "pending", "blocked", "deferred"])

        if complete_mentions and queued_mentions:
            rec.inferred_state = "NEEDS_RECONCILIATION"
            rec.warnings.append("Registry contains both completion and queue/deferred language.")
        elif complete_mentions and has_impl and has_commit and has_proof:
            rec.inferred_state = "COMPLETE_PROOF_LINKED"
            rec.confidence = "HIGH"
        elif complete_mentions and has_commit and has_proof:
            rec.inferred_state = "COMPLETE_EVIDENCE_ONLY_OR_DOCS_ONLY"
            rec.confidence = "MEDIUM"
        elif complete_mentions:
            rec.inferred_state = "COMPLETION_CLAIM_UNPROVEN"
            rec.warnings.append("Completion language exists without enough local implementation/proof linkage.")
        elif queued_mentions:
            rec.inferred_state = "QUEUED_OR_BLOCKED"
            rec.confidence = "MEDIUM" if has_prompt else "LOW"
        elif has_prompt and not has_commit:
            rec.inferred_state = "PROMPT_WITHOUT_COMMIT_LINEAGE"
            rec.warnings.append("Prompt exists but no matching commit lineage was found by train ID.")
        elif has_commit:
            rec.inferred_state = "IMPLEMENTATION_OR_EVIDENCE_PRESENT"
            rec.confidence = "MEDIUM"
        else:
            rec.inferred_state = "NEEDS_RECONCILIATION"

        if has_prompt and not has_proof and rec.inferred_state.startswith("COMPLETE"):
            rec.warnings.append("Prompt/completion present but no proof artifact was linked.")


def generate_registry_projection(repo: Path, records: dict[str, TrainRecord]) -> str:
    families: dict[str, list[TrainRecord]] = defaultdict(list)
    for rec in records.values():
        families[rec.family].append(rec)

    lines = [
        "# Generated Ambitions Reconciled Registry Projection",
        "",
        f"Generated: {git_commit_iso(repo)}",
        "",
        "This file is generated from local repository data by `scripts/governance/ambitions-governance-reconcile.py`.",
        "Do not hand-edit generated output; update source files or governance rules and regenerate.",
        "",
    ]
    for family in sorted(families):
        lines += [f"## {family}", "", "| Train | State | Confidence | Prompts | Commits | Impl Files | Proof Files | Warnings |", "|---|---|---:|---:|---:|---:|---:|---|"]
        for rec in sorted(families[family], key=lambda r: r.train_id):
            warnings = "; ".join(rec.warnings) if rec.warnings else ""
            lines.append(
                f"| {rec.train_id} | {rec.inferred_state} | {rec.confidence} | {len(rec.prompt_files)} | {len(rec.commits)} | {len(rec.implementation_files)} | {len(rec.proof_files)} | {warnings} |"
            )
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def generate_orphan_prompt_report(repo: Path, records: dict[str, TrainRecord]) -> str:
    orphaned = [r for r in records.values() if r.prompt_files and not r.commits]
    lines = ["# Generated Orphan Prompt Audit", "", f"Generated: {git_commit_iso(repo)}", ""]
    lines += ["| Train | Prompt Files | State | Warning |", "|---|---:|---|---|"]
    for rec in sorted(orphaned, key=lambda r: r.train_id):
        lines.append(f"| {rec.train_id} | {len(rec.prompt_files)} | {rec.inferred_state} | {'; '.join(rec.warnings)} |")
    if not orphaned:
        lines.append("| None detected | 0 | - | - |")
    return "\n".join(lines) + "\n"


def generate_stale_overlay_report(repo: Path, stale_findings: list[dict]) -> str:
    lines = ["# Generated Stale Overlay Audit", "", f"Generated: {git_commit_iso(repo)}", ""]
    lines += ["| Kind | Path | Line | Text |", "|---|---|---:|---|"]
    for item in stale_findings[:500]:
        safe = item["text"].replace("|", "\\|")
        lines.append(f"| {item['kind']} | {item['path']} | {item['line']} | {safe} |")
    if not stale_findings:
        lines.append("| None detected | - | - | - |")
    return "\n".join(lines) + "\n"


def accepted_yellow_debt(
    repo: Path, records: dict[str, TrainRecord], stale_findings: list[dict]
) -> tuple[dict[str, object], str]:
    unresolved = [
        rec
        for rec in records.values()
        if rec.inferred_state in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"}
    ]
    orphaned = [rec for rec in records.values() if rec.prompt_files and not rec.commits]
    data = {
        "generated_at": git_commit_iso(repo),
        "status": "ACCEPTED_YELLOW",
        "owner": "Governance Reconciliation lane",
        "reason": "Historical registry normalization remains incomplete, but generated evidence is present and no product or release claim is made.",
        "no_claim_boundary": [
            "does not claim full registry normalization",
            "does not claim release readiness",
            "does not claim implementation proof for unresolved trains",
            "does not authorize product feature work",
        ],
        "required_green_proof": [
            "resolve every NEEDS_RECONCILIATION and COMPLETION_CLAIM_UNPROVEN train in registry_projection.md",
            "reduce stale_overlay_audit.md findings to zero or move them under explicit historical policy",
            "link orphan prompts to commits, proof artifacts, or explicit queued/deferred states",
        ],
        "evidence": {
            "registry_projection": "docs/governance/generated/registry_projection.md",
            "orphan_prompt_audit": "docs/governance/generated/orphan_prompt_audit.md",
            "stale_overlay_audit": "docs/governance/generated/stale_overlay_audit.md",
            "proof_linkage_graph": "docs/governance/generated/proof_linkage_graph.json",
            "train_to_implementation_map": "docs/governance/generated/train_to_implementation_map.json",
        },
        "counts": {
            "unresolved_reconciliation_count": len(unresolved),
            "stale_overlay_count": len(stale_findings),
            "orphan_prompt_count": len(orphaned),
            "train_count": len(records),
        },
        "sample_unresolved_trains": [
            {
                "train_id": rec.train_id,
                "state": rec.inferred_state,
                "warnings": rec.warnings,
            }
            for rec in sorted(unresolved, key=lambda r: r.train_id)[:25]
        ],
    }

    lines = [
        "# Generated Accepted-Yellow Governance Debt",
        "",
        f"Generated: {data['generated_at']}",
        "",
        "Status: ACCEPTED_YELLOW",
        "Owner: Governance Reconciliation lane",
        "",
        "## Why Yellow, Not Red",
        "",
        str(data["reason"]),
        "",
        "## Counts",
        "",
        f"- Unresolved reconciliation count: {len(unresolved)}",
        f"- Stale overlay count: {len(stale_findings)}",
        f"- Orphan prompt count: {len(orphaned)}",
        f"- Train count: {len(records)}",
        "",
        "## No-Claim Boundary",
        "",
    ]
    lines.extend(f"- {item}" for item in data["no_claim_boundary"])
    lines += [
        "",
        "## Required Green Proof",
        "",
    ]
    lines.extend(f"- {item}" for item in data["required_green_proof"])
    lines += [
        "",
        "## Evidence",
        "",
    ]
    for label, path in data["evidence"].items():
        lines.append(f"- {label}: `{path}`")
    return data, "\n".join(lines).rstrip() + "\n"


def write_outputs(repo: Path, out_dir: Path, records: dict[str, TrainRecord], stale_findings: list[dict], strict: bool) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    data = {
        "generated_at": git_commit_iso(repo),
        "train_count": len(records),
        "records": {tid: rec.to_json() for tid, rec in sorted(records.items())},
    }
    (out_dir / "train_lineage_graph.json").write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    (out_dir / "registry_projection.md").write_text(generate_registry_projection(repo, records))
    (out_dir / "orphan_prompt_audit.md").write_text(generate_orphan_prompt_report(repo, records))
    (out_dir / "stale_overlay_audit.md").write_text(generate_stale_overlay_report(repo, stale_findings))

    proof_linkage = {
        tid: {
            "audit_files": sorted(rec.audit_files),
            "report_files": sorted(rec.report_files),
            "test_files": sorted(rec.test_files),
            "proof_files": sorted(rec.proof_files),
        }
        for tid, rec in sorted(records.items())
    }
    (out_dir / "proof_linkage_graph.json").write_text(json.dumps(proof_linkage, indent=2, sort_keys=True) + "\n")

    implementation_map = {
        tid: {
            "implementation_files": sorted(rec.implementation_files),
            "governance_files": sorted(rec.governance_files),
            "commits": [c.sha for c in rec.commits],
        }
        for tid, rec in sorted(records.items())
    }
    (out_dir / "train_to_implementation_map.json").write_text(json.dumps(implementation_map, indent=2, sort_keys=True) + "\n")

    failures = [r for r in records.values() if r.inferred_state in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"}]
    accepted_yellow, accepted_yellow_md = accepted_yellow_debt(repo, records, stale_findings)
    (out_dir / "accepted_yellow_governance_debt.json").write_text(
        json.dumps(accepted_yellow, indent=2, sort_keys=True) + "\n"
    )
    (out_dir / "accepted_yellow_governance_debt.md").write_text(accepted_yellow_md)
    summary = {
        "generated_at": git_commit_iso(repo),
        "train_count": len(records),
        "needs_reconciliation_count": len(failures),
        "stale_overlay_count": len(stale_findings),
        "accepted_yellow": accepted_yellow,
        "accepted_yellow_count": len(failures) + len(stale_findings),
        "strict_passed": not strict or not failures,
    }
    (out_dir / "governance_reconciliation_summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    return 1 if strict and failures else 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".", help="Repository root")
    parser.add_argument("--out", default="docs/governance/generated", help="Output directory")
    parser.add_argument("--write", action="store_true", help="Write generated artifacts")
    parser.add_argument("--strict", action="store_true", help="Fail if unresolved reconciliation items remain")
    args = parser.parse_args(argv)

    repo = Path(args.repo_root).resolve()
    if not (repo / ".git").exists():
        print(f"ERROR: {repo} is not a git repository root", file=sys.stderr)
        return 2

    all_files = discover_files(repo)
    records, _mentions, stale_findings = scan_prompt_and_registry_files(repo, all_files)
    commits = parse_git_log(repo)
    attach_commits(records, commits)
    infer_states(records)

    unresolved = sum(1 for r in records.values() if r.inferred_state in {"NEEDS_RECONCILIATION", "COMPLETION_CLAIM_UNPROVEN"})
    print(f"Ambitions governance reconciliation scan")
    print(f"Repo: {repo}")
    print(f"Trains detected: {len(records)}")
    print(f"Commits scanned: {len(commits)}")
    print(f"Stale overlay findings: {len(stale_findings)}")
    print(f"Unresolved trains: {unresolved}")

    if args.write:
        code = write_outputs(repo, repo / args.out, records, stale_findings, args.strict)
        print(f"Generated: {repo / args.out}")
        return code

    return 1 if args.strict and unresolved else 0

if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
