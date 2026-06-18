#!/usr/bin/env python3
"""Generate Design Truth Refraction Train 0/1 audit artifacts."""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
MAX_RAW_LOG_BYTES = 25 * 1024 * 1024

OUTPUTS = {
    "readback": ROOT / "docs/audits/design_truth_readback.md",
    "summary": ROOT / "docs/audits/design_truth_refraction_audit.md",
    "ledger": ROOT / "docs/audits/file_by_file_truth_ledger.md",
    "obsolete": ROOT / "docs/audits/obsolete_architecture_audit.md",
    "large": ROOT / "docs/audits/large_swift_file_discipline_audit.md",
    "stub": ROOT / "docs/audits/stub_adapter_retirement_audit.md",
    "language": ROOT / "docs/audits/forbidden_language_audit.md",
}

FORBIDDEN_LANGUAGE_PATTERNS = [
    "Source unavailable",
    "receipt before save",
    "route reveal",
    "runtime-backed",
    "fixture-only",
    "proof seam",
    "Close Today",
    "Motion Current",
    "Capture Anything",
    "blocked-pending-model",
    "local projection",
    "receipt path",
    "review before reflow",
    "No silent changes",
    "Open seam",
    "Re-enter thread",
    "best next move",
    "next best move",
    "Begin Focus",
    "productivity score",
    "life score",
    "habit score",
    "streak broken",
]

OBSOLETE_ARCHITECTURE_PATTERNS = [
    "RootTab",
    "MainTab",
    "TabRoot",
    "RootTabView",
    "MainTabView",
    "AmbitionsTabView",
    "TabShell",
    "RootShell",
    "Surfaces/Motion",
    "MotionSurface",
    "MotionView",
    "MotionTab",
    "MotionStageScene",
    "MotionLens",
    "MotionRoot",
    "Surfaces/Capture",
    "CaptureTab",
    "CaptureRoot",
    "CaptureDestination",
    "CaptureScreenShellMode",
    "topLevelCapture",
    "captureInbox",
    "openCapturesInbox",
]

STUB_PATTERNS = [
    "TODO",
    "FIXME",
    "stub",
    "placeholder",
    "mock",
    "fake",
    "sample",
    "demo",
    "noop",
    "no-op",
    "fatalError",
    "preconditionFailure",
    "return []",
    "return nil",
    "return .empty",
    "// temporary",
    "// for now",
    "preview only",
]

SOURCE_ROOTS = (
    "Native/",
    "Sources/",
    "AppUI/",
    "Packages/",
)


@dataclass
class FileAudit:
    path: str
    line_count: int
    current_role: str
    canonical_layer: str
    product_owner: str
    implementation_status: str
    design_violations: list[str] = field(default_factory=list)
    language_violations: list[str] = field(default_factory=list)
    runtime_mutation: str = "not applicable"
    accessibility: str = "not applicable"
    chrome_risk: str = "not applicable"
    split_recommendation: str = "not applicable"
    proof_required: list[str] = field(default_factory=list)
    status: str = "Yellow"

    @property
    def severity_score(self) -> int:
        base = {"Red": 400, "Yellow": 200, "Split": 180, "Delete": 350, "Replace": 260, "Green": 0, "Keep": 0, "Test-only": 0}.get(self.status, 100)
        return base + len(self.design_violations) * 20 + len(self.language_violations) * 10 + min(self.line_count, 2000)


def run(cmd: list[str], *, check: bool = True, cwd: Path = ROOT) -> str:
    result = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    if check and result.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)} failed with {result.returncode}\n{result.stderr}")
    return result.stdout


def git_lines(args: list[str]) -> list[str]:
    return [line for line in run(["git", *args]).splitlines() if line.strip()]


def current_branch() -> str:
    return run(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip()


def current_sha() -> str:
    return run(["git", "rev-parse", "HEAD"]).strip()


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def text_for(path: str) -> str:
    candidate = ROOT / path
    try:
        if candidate.stat().st_size > 2_000_000:
            return candidate.read_text(encoding="utf-8", errors="replace")[:2_000_000]
        return candidate.read_text(encoding="utf-8", errors="replace")
    except (OSError, UnicodeDecodeError):
        return ""


def line_counts(paths: list[str]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for index in range(0, len(paths), 200):
        batch = paths[index:index + 200]
        output = run(["wc", "-l", *batch])
        for raw_line in output.splitlines():
            line = raw_line.strip()
            if not line or line.endswith(" total"):
                continue
            parts = line.split(maxsplit=1)
            if len(parts) != 2:
                continue
            try:
                counts[parts[1]] = int(parts[0])
            except ValueError:
                continue
    return counts


def rg_summary(name: str, patterns: list[str], paths: list[str]) -> dict[str, object]:
    existing_roots = [path for path in paths if (ROOT / path).exists()]
    pattern = "|".join(re.escape(item) for item in patterns)
    output_globs: list[str] = []
    for output in OUTPUTS.values():
        output_globs.extend(["--glob", f"!{relative(output)}"])
    cmd = ["rg", "-n", "-i", *output_globs, pattern, *existing_roots]
    result = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    output = result.stdout
    raw_bytes = len(output.encode("utf-8", errors="replace"))
    lines = sorted(output.splitlines())
    by_file: dict[str, int] = {}
    for line in lines:
        path = line.split(":", 1)[0]
        by_file[path] = by_file.get(path, 0) + 1
    return {
        "name": name,
        "command": " ".join(cmd),
        "hit_count": len(lines),
        "file_count": len(by_file),
        "raw_bytes": raw_bytes,
        "raw_log_replaced": raw_bytes > MAX_RAW_LOG_BYTES,
        "samples": lines[:40],
        "top_files": sorted(by_file.items(), key=lambda item: (-item[1], item[0]))[:20],
    }


def contains_any(text: str, needles: Iterable[str]) -> list[str]:
    lower = text.lower()
    return [needle for needle in needles if needle.lower() in lower]


def canonical_layer(path: str) -> str:
    if path.startswith("Native/Ambitions/App/"):
        return "app"
    if path.startswith("Native/Ambitions/Stage/"):
        return "stage"
    if path.startswith("Native/Ambitions/Runtime/"):
        return "runtime"
    if path.startswith("Native/Ambitions/Persistence/"):
        return "persistence"
    if path.startswith("Native/Ambitions/Projection/"):
        return "projection"
    if path.startswith("Native/Ambitions/Domain/"):
        return "core domain"
    if path.startswith("Native/Ambitions/Services/") or path.startswith("Native/Ambitions/Integrations/"):
        return "runtime services"
    if path.startswith("Native/Ambitions/Features/Capture/"):
        return "composer"
    if path.startswith("Native/Ambitions/Features/"):
        return "surface"
    if path.startswith("Native/Ambitions/Diagnostics/"):
        return "diagnostics"
    if path.startswith("Native/Ambitions/PreviewSupport/") or path.startswith("Sources/Previews/"):
        return "preview support"
    if path.startswith("Native/AmbitionsWidgetExtension/"):
        return "widget"
    if path.startswith("Native/AmbitionsShareExtension/"):
        return "share extension"
    if path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/") or path.startswith("tools/tests/"):
        return "tests"
    if path.startswith("Sources/Components/") or path.startswith("Sources/Theme/") or path == "Sources/AmbitionsDesignSystem.swift":
        return "design system"
    if path.startswith("AppUI/"):
        return "external surface"
    if path.startswith("docs/truth/"):
        return "truth docs"
    if path.startswith("docs/audits/"):
        return "audit docs"
    if path.startswith("docs/validation/") or path.startswith("validation/"):
        return "validation docs"
    if path.startswith("docs/codex") or path.startswith("prompts/") or path.startswith("trains/") or path.startswith(".agents/"):
        return "codex governance"
    if path.startswith("scripts/") or path.startswith("tools/") or path == "Makefile":
        return "scripts"
    if path.endswith((".yml", ".yaml", ".json", ".plist", ".xcprivacy", ".entitlements")) or path in {"Package.swift", "project.yml"}:
        return "project config"
    if path.startswith("assets/") or "/Resources/" in path or path.endswith((".png", ".jpg", ".jpeg", ".pdf", ".xcassets")):
        return "resources"
    if path.endswith(".md") or path.endswith(".txt"):
        return "supporting docs"
    return "repo support"


def product_owner(path: str, text: str) -> str:
    lower_path = path.lower()
    lower_text = text[:20_000].lower()
    if "/today/" in lower_path or "today" in lower_path:
        return "Today"
    if "/goals/" in lower_path or "goal" in lower_path:
        return "Goals"
    if "/time/" in lower_path or "lifeshape" in lower_path:
        return "Time"
    if "/you/" in lower_path or "usersystem" in lower_path:
        return "You"
    if "capture" in lower_path:
        return "Capture"
    if "motion" in lower_path:
        return "Motion"
    if "sourceatlas" in lower_path or "r2" in lower_text:
        return "Source Atlas / R2"
    if "account" in lower_path or "entitlement" in lower_text:
        return "Account"
    if "accessibility" in lower_path:
        return "Accessibility"
    if "release" in lower_path or "proof" in lower_path or "receipt" in lower_path or "trust" in lower_path:
        return "Trust / release proof"
    if "widget" in lower_path:
        return "Widget"
    if "share" in lower_path:
        return "Share extension"
    if lower_path.startswith(("native/ambitions/app/", "native/ambitions/stage/")):
        return "Stage shell"
    if lower_path.startswith("sources/"):
        return "Design system"
    if lower_path.startswith(("docs/", "scripts/", "tools/", "prompts/", "trains/")):
        return "Codex governance"
    return "Broad repo"


def current_role(path: str, layer: str, owner: str) -> str:
    name = Path(path).name
    if path == "Native/Ambitions/App/AppTab.swift":
        return "Canonical four-surface registry with legacy route compatibility."
    if path == "Native/Ambitions/App/AmbitionsRootView.swift":
        return "Root SwiftUI shell, technical TabView host, overlays, dock, and stage motion routing."
    if path == "Native/Ambitions/Stage/StageOwner.swift":
        return "Stage motion routing coordinator for Motion Current actions."
    if "MotionCurrentScreen.swift" in path:
        return "Motion Current compatibility surface and behavior projection UI."
    if "CaptureScreen.swift" in path:
        return "Capture composer implementation plus compatibility screen modes."
    if layer == "tests":
        return f"Tests for {owner} / {name}."
    if layer == "truth docs":
        return "Active or supporting authority document."
    if layer == "audit docs":
        return "Audit/proof artifact."
    if layer == "scripts":
        return "Repo automation or validation script."
    if layer == "resources":
        return "Resource or asset."
    if layer == "preview support":
        return "Preview/scenario fixture support."
    return f"{layer.title()} file owned by {owner}."


def implementation_status(path: str, text: str, line_count: int) -> str:
    lower = path.lower()
    text_lower = text.lower()
    if path.startswith("Native/AmbitionsTests/") or path.startswith("Native/AmbitionsUITests/") or path.startswith("tools/tests/"):
        return "test-only"
    if path.startswith("Native/Ambitions/PreviewSupport/") or path.startswith("Sources/Previews/") or "#preview" in text_lower:
        return "preview-only"
    if "format-backup" in lower or "historical" in lower or path.startswith("history/"):
        return "obsolete canon"
    if "/features/motion/" in lower or "motionstagescene" in text_lower or "motionlens" in text_lower:
        return "obsolete architecture"
    if "stub" in lower or "stub" in text_lower:
        return "stub"
    if "previewfixtures" in lower or "fixture" in lower:
        return "fixture"
    if re.search(r"\b(fake|mock|noop|no-op)\b", text_lower):
        return "needs hardening"
    if line_count >= 651 and path.endswith(".swift") and ".generated." not in lower:
        return "oversized"
    if line_count >= 401 and path.endswith(".swift") and ".generated." not in lower:
        return "needs split"
    if "adapter" in lower or "integration" in lower or "repository" in lower or "permission" in lower:
        return "real boundary adapter"
    if "captureinbox" in text_lower or "toplevelcapture" in text_lower:
        return "needs hardening"
    if path.endswith(".md") and path.startswith("docs/truth/"):
        return "real implementation"
    return "real implementation"


def runtime_behavior(path: str, text: str, layer: str) -> str:
    lower = text.lower()
    if layer == "tests":
        return "test only"
    if layer.endswith("docs") or layer in {"truth docs", "audit docs", "supporting docs", "codex governance"}:
        return "documentation only"
    if layer in {"scripts", "diagnostics"}:
        return "diagnostic only"
    if any(token in lower for token in ["save", "create", "update", "delete", "performaction", "mutat", "repository"]):
        return "mutating runtime path"
    if any(token in lower for token in ["projection", "projector", "viewstate", "snapshot"]):
        return "projection only"
    if path.endswith(".swift"):
        return "display only"
    return "not applicable"


def accessibility_coverage(path: str, text: str, layer: str) -> str:
    lower = text.lower()
    if layer == "tests" and "accessibility" in lower:
        return "test coverage"
    if layer.endswith("docs") or layer in {"truth docs", "audit docs", "supporting docs"}:
        return "documentation only"
    if "semanticmodel" in lower or "semantic mirror" in lower:
        return "semantic mirror present"
    hits = sum(1 for token in ["accessibility", "voiceover", "dynamic type", "reducemotion", "reduce motion", "reduce transparency", "contrast"] if token in lower)
    if hits >= 2:
        return "explicit coverage"
    if hits == 1:
        return "partial coverage"
    if path.endswith(".swift") and path.startswith(SOURCE_ROOTS):
        return "not found"
    return "not applicable"


def chrome_risk(path: str, text: str) -> str:
    lower = text.lower()
    if "tabview" in lower or "toolbar(.hidden, for: .tabbar)" in lower:
        return "duplicate navigation risk"
    if "keyboard" in lower and ("capture" in lower or "composer" in lower):
        return "keyboard overlay risk"
    if "dock" in lower and "drilldown" in lower:
        return "drilldown dock risk"
    if "safearea" in lower or "ignoressafearea" in lower:
        return "root shell risk"
    if "dynamictype" in lower or "dynamic type" in lower:
        return "dynamic type risk"
    return "none" if path.endswith(".swift") else "not applicable"


def split_recommendation(status: str, path: str, line_count: int) -> str:
    if ".generated." in path:
        return "generated exception"
    if status == "obsolete architecture":
        return "replace"
    if status == "stub":
        return "replace"
    if status == "fixture" and path.startswith(SOURCE_ROOTS) and "Preview" not in path:
        return "move to previews"
    if line_count >= 401 and path.endswith(".swift"):
        return "split"
    if status == "needs hardening":
        return "harden"
    if status == "test-only":
        return "keep"
    if status == "obsolete canon":
        return "delete"
    return "keep"


def proof_required(path: str, status: str, layer: str, owner: str) -> list[str]:
    proof: list[str] = []
    if path.endswith(".swift") and path.startswith(SOURCE_ROOTS):
        proof.extend(["build", "focused tests"])
    if status in {"obsolete architecture", "needs hardening"} or "Stage shell" in owner:
        proof.append("architecture conformance scan")
    if status in {"stub", "fixture", "needs hardening"}:
        proof.append("stub/adapter audit")
    if status in {"oversized", "needs split"}:
        proof.append("large file audit")
    if layer in {"truth docs", "audit docs", "supporting docs"}:
        proof.append("authority readback")
    if path.endswith(".swift") or path.endswith(".md"):
        proof.append("forbidden language scan")
    if not proof:
        proof.append("not applicable")
    return sorted(set(proof))


def audit_status(audit: FileAudit) -> str:
    if audit.implementation_status == "obsolete canon":
        return "Delete"
    if audit.implementation_status == "obsolete architecture":
        return "Red"
    if audit.line_count >= 651 and audit.path.endswith(".swift") and ".generated." not in audit.path:
        return "Red"
    if audit.design_violations:
        return "Red"
    if audit.implementation_status in {"stub", "needs hardening"}:
        return "Yellow"
    if audit.line_count >= 401 and audit.path.endswith(".swift") and ".generated." not in audit.path:
        return "Split"
    if audit.language_violations and audit.path.startswith(("Native/Ambitions/", "Sources/", "AppUI/")):
        return "Yellow"
    if audit.implementation_status == "test-only":
        return "Test-only"
    return "Green"


def design_violations(path: str, text: str) -> list[str]:
    lower = text.lower()
    findings: list[str] = []
    if path == "Native/Ambitions/App/AmbitionsRootView.swift" and "tabview" in lower:
        findings.append("Root shell still uses technical TabView; native tab chrome is hidden but StageRoot guard is not yet formalized.")
    if path == "Native/Ambitions/App/AppNavigation.swift" and "captureinbox" in lower:
        findings.append("Capture inbox compatibility route remains and must be validated as overlay/global composer, not root destination.")
    if path == "Native/Ambitions/App/ShellCommandModels.swift" and "motionquickcapture" in lower:
        findings.append("Motion-named shell command source remains as compatibility vocabulary for audit review.")
    if path.startswith("Native/Ambitions/Features/Motion/"):
        findings.append("Motion feature file remains outside Stage/Motion behavior ownership.")
    if path == "Native/Ambitions/Features/Capture/CaptureScreen.swift" and "toplevelcapture" in lower:
        findings.append("CaptureScreen still exposes topLevelCapture shell mode for compatibility/previews.")
    if path == "docs/truth/HISTORICAL_POLICY.md" and "today / goals / time / motion / you" in lower:
        findings.append("Historical policy says active IA includes Motion; PRODUCT_DESIGN_TRUTH wins with Today / Goals / Time / You.")
    if path == "docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md":
        findings.append("Format backup is obsolete supporting canon and must not override active truth.")
    return findings


def language_violations(path: str, text: str) -> list[str]:
    hits = contains_any(text, FORBIDDEN_LANGUAGE_PATTERNS)
    if not hits:
        return []
    if path.startswith(("docs/truth/", "docs/audits/", "prompts/", "trains/")):
        return [f"restricted terms present in authority/audit context: {', '.join(hits[:5])}"]
    return hits[:8]


def build_audits(paths: list[str], counts: dict[str, int]) -> list[FileAudit]:
    audits: list[FileAudit] = []
    for path in paths:
        text = text_for(path)
        layer = canonical_layer(path)
        owner = product_owner(path, text)
        line_count = counts.get(path, 0)
        status = implementation_status(path, text, line_count)
        audit = FileAudit(
            path=path,
            line_count=line_count,
            current_role=current_role(path, layer, owner),
            canonical_layer=layer,
            product_owner=owner,
            implementation_status=status,
            design_violations=design_violations(path, text),
            language_violations=language_violations(path, text),
            runtime_mutation=runtime_behavior(path, text, layer),
            accessibility=accessibility_coverage(path, text, layer),
            chrome_risk=chrome_risk(path, text),
            split_recommendation=split_recommendation(status, path, line_count),
            proof_required=proof_required(path, status, layer, owner),
        )
        audit.status = audit_status(audit)
        audits.append(audit)
    return audits


def md_escape(value: object) -> str:
    text = str(value)
    text = text.replace("|", "\\|")
    text = text.replace("\n", "<br>")
    return text if text else "none"


def list_cell(items: list[str]) -> str:
    return "<br>".join(md_escape(item) for item in items) if items else "none"


def table(headers: list[str], rows: Iterable[list[object]]) -> str:
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    for row in rows:
        lines.append("| " + " | ".join(md_escape(item) for item in row) + " |")
    return "\n".join(lines)


def bullet_list(items: Iterable[str]) -> str:
    values = list(items)
    if not values:
        return "- none"
    return "\n".join(f"- {item}" for item in values)


def repo_counts(audits: list[FileAudit]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for audit in audits:
        counts[audit.status] = counts.get(audit.status, 0) + 1
    return counts


def top_red(audits: list[FileAudit], limit: int = 20) -> list[FileAudit]:
    return sorted([audit for audit in audits if audit.status == "Red"], key=lambda item: (-item.severity_score, item.path))[:limit]


def top_splits(audits: list[FileAudit], limit: int = 20) -> list[FileAudit]:
    return sorted(
        [audit for audit in audits if audit.path.endswith(".swift") and audit.line_count >= 251],
        key=lambda item: (-item.line_count, item.path),
    )[:limit]


def top_stubs(audits: list[FileAudit], limit: int = 20) -> list[FileAudit]:
    wanted = {"stub", "fixture", "needs hardening", "real boundary adapter"}
    return sorted(
        [audit for audit in audits if audit.implementation_status in wanted or "stub/adapter audit" in audit.proof_required],
        key=lambda item: (-item.severity_score, item.path),
    )[:limit]


def obsolete_findings(audits: list[FileAudit]) -> list[FileAudit]:
    return sorted(
        [audit for audit in audits if audit.design_violations or audit.implementation_status in {"obsolete architecture", "obsolete canon"}],
        key=lambda item: (-item.severity_score, item.path),
    )


def render_readback(audits: list[FileAudit]) -> str:
    contradiction = next((audit for audit in audits if audit.path == "docs/truth/HISTORICAL_POLICY.md"), None)
    conflicts = contradiction.design_violations if contradiction else []
    return f"""# Design Truth Readback

Status: Train 0 readback artifact  
Branch: `{current_branch()}`  
Commit: `{current_sha()}`  
Scope: Canon readback only; not implementation proof or release proof.

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Canon Readback

- Persistent stage surfaces are exactly `Today / Goals / Time / You`.
- `Capture` is the global composer/action layer, not a root surface, tab, inbox, chatbot, or default destination.
- `Motion` is a cross-surface behavior layer, not a root destination, feed, score, dashboard, or activity tab.
- `Proof / Source / Privacy / History / Receipts` are inspectable trust layers, not default root UI.
- The product root is one adaptive object stage, not commodity tab-app architecture.
- Every meaningful user action must produce runtime mutation, visible stage mutation, accessible state change, safe fallback, and proof artifact.
- Local-first/offline core value with no account is mandatory; R2/Source Atlas is public/reference/freshness infrastructure only.
- Hosted AI/cloud LLM behavior is excluded from core architecture.

## Language Rules

- Use `Start here`, `Recommended step`, `Start now`, `Open step`, and `Step`.
- Avoid `next best move`, `best next move`, `Begin Focus`, generic task language, top-level Plan language, AI-wrapper language, dashboard/admin/spec/debug language, and first-layer `Source / Proof / Receipt` labels.

## Accessibility And Proof Requirements

- VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, safe areas, dock legibility, keyboard behavior, and tap targets are product requirements.
- Screenshots, accessibility proof, mutation proof, build logs, and tests are not implied by source or docs.
- Train 0/1 does not claim screenshot, accessibility, device, mutation, privacy, release, or App Store proof.

## Conflicts Found

{bullet_list(conflicts)}

## Smallest Safe Next Action

Complete Train 1 classification artifacts without rebuilding product UI, deleting files, splitting large files, or repairing stale canon. Product Design Truth wins over stale compatibility material during classification.
"""


def render_ledger(audits: list[FileAudit]) -> str:
    rows = (
        [
            audit.path,
            audit.current_role,
            audit.canonical_layer,
            audit.product_owner,
            audit.implementation_status,
            list_cell(audit.design_violations),
            list_cell(audit.language_violations),
            audit.runtime_mutation,
            audit.accessibility,
            audit.chrome_risk,
            audit.split_recommendation,
            list_cell(audit.proof_required),
            audit.status,
        ]
        for audit in audits
    )
    return """# File-by-file Design Truth Ledger

Status: Train 1 generated audit artifact  
Generation: deterministic from `git ls-files`, `wc -l`, and targeted scans  
Scope: Classification only; this file does not prove implementation quality, build success, screenshots, accessibility, mutation, privacy, or release readiness.

""" + table(
        [
            "File",
            "Current role",
            "Canon layer",
            "Product object/system owned",
            "Real/stub/fixture/adapter/dead",
            "Design Truth violations",
            "User-facing language risk",
            "Runtime mutation behavior",
            "Accessibility coverage",
            "Safe-area/keyboard/chrome risk",
            "Split/refactor/delete recommendation",
            "Tests/proof needed",
            "Status",
        ],
        rows,
    ) + "\n"


def render_large(audits: list[FileAudit]) -> str:
    large = [audit for audit in audits if audit.path.endswith(".swift") and audit.line_count >= 251]
    rows = (
        [
            audit.path,
            audit.line_count,
            "Red" if audit.line_count >= 651 and ".generated." not in audit.path else "Inspect",
            audit.current_role,
            audit.implementation_status,
            audit.split_recommendation,
            list_cell(audit.proof_required),
            audit.status,
        ]
        for audit in sorted(large, key=lambda item: (-item.line_count, item.path))
    )
    return """# Large Swift File Discipline Audit

Status: Train 1 generated audit artifact  
Rules: 0-250 acceptable by default; 251-400 inspect; 401-650 justify or split; 651+ Red unless generated or explicitly excepted.

""" + table(
        ["File", "Lines", "Rule result", "Current responsibility", "Classification", "Split target recommendation", "Proof required", "Status"],
        rows,
    ) + "\n"


def render_obsolete(audits: list[FileAudit], rg_architecture: dict[str, object]) -> str:
    findings = obsolete_findings(audits)
    rows = (
        [
            audit.path,
            audit.implementation_status,
            list_cell(audit.design_violations),
            audit.split_recommendation,
            list_cell(audit.proof_required),
            audit.status,
        ]
        for audit in findings
    )
    return f"""# Obsolete Architecture Audit

Status: Train 1 generated audit artifact  
Scope: Findings are classification targets only; no files were deleted or migrated in Train 0/1.

## Search Summary

- Command used: `{rg_architecture["command"]}`
- Hit count: {rg_architecture["hit_count"]}
- File count: {rg_architecture["file_count"]}
- Raw output bytes: {rg_architecture["raw_bytes"]}
- Raw log replaced with summary: {rg_architecture["raw_log_replaced"]}

## Sample Findings

{bullet_list(str(sample) for sample in rg_architecture["samples"][:20])}

## Top Hit Files

{table(["File", "Hits"], rg_architecture["top_files"])}

## Classified Architecture Findings

{table(["File", "Classification", "Design Truth issue", "Recommendation", "Proof needed", "Status"], rows)}
"""


def render_stub(audits: list[FileAudit], rg_stub: dict[str, object]) -> str:
    rows = (
        [
            audit.path,
            audit.implementation_status,
            audit.current_role,
            audit.split_recommendation,
            list_cell(audit.proof_required),
            audit.status,
        ]
        for audit in top_stubs(audits, limit=200)
    )
    return f"""# Stub And Adapter Retirement Audit

Status: Train 1 generated audit artifact  
Rule: preserve real boundary adapters; classify fake/no-op/placeholder/pass-through/ad hoc adapters for later hardening, replacement, fixture movement, or deletion.

## Search Summary

- Command used: `{rg_stub["command"]}`
- Hit count: {rg_stub["hit_count"]}
- File count: {rg_stub["file_count"]}
- Raw output bytes: {rg_stub["raw_bytes"]}
- Raw log replaced with summary: {rg_stub["raw_log_replaced"]}

## Sample Findings

{bullet_list(str(sample) for sample in rg_stub["samples"][:20])}

## Top Hit Files

{table(["File", "Hits"], rg_stub["top_files"])}

## Classified Stub/Adapter Candidates

{table(["File", "Classification", "Current role", "Recommendation", "Proof needed", "Status"], rows)}
"""


def render_language(audits: list[FileAudit], rg_language: dict[str, object]) -> str:
    language_files = sorted([audit for audit in audits if audit.language_violations], key=lambda item: (-len(item.language_violations), item.path))
    rows = (
        [
            audit.path,
            list_cell(audit.language_violations),
            audit.canonical_layer,
            audit.product_owner,
            audit.status,
        ]
        for audit in language_files[:300]
    )
    return f"""# Forbidden Language Audit

Status: Train 1 generated audit artifact  
Scope: Classifies first-pass language risk. Terms in truth docs, audit docs, tests, prompts, and historical context are review triggers, not automatic product UI failures.

## Search Summary

- Command used: `{rg_language["command"]}`
- Hit count: {rg_language["hit_count"]}
- File count: {rg_language["file_count"]}
- Raw output bytes: {rg_language["raw_bytes"]}
- Raw log replaced with summary: {rg_language["raw_log_replaced"]}

## Sample Findings

{bullet_list(str(sample) for sample in rg_language["samples"][:20])}

## Top Hit Files

{table(["File", "Hits"], rg_language["top_files"])}

## Classified Language Risk

{table(["File", "Language risk", "Layer", "Owner", "Status"], rows)}
"""


def render_summary(audits: list[FileAudit], rg_architecture: dict[str, object], rg_stub: dict[str, object], rg_language: dict[str, object]) -> str:
    counts = repo_counts(audits)
    top_red_rows = ([audit.path, audit.line_count, audit.implementation_status, list_cell(audit.design_violations), audit.status] for audit in top_red(audits))
    top_split_rows = ([audit.path, audit.line_count, audit.current_role, audit.split_recommendation, audit.status] for audit in top_splits(audits))
    top_stub_rows = ([audit.path, audit.implementation_status, audit.split_recommendation, audit.status] for audit in top_stubs(audits))
    obsolete_rows = ([audit.path, audit.implementation_status, list_cell(audit.design_violations), audit.status] for audit in obsolete_findings(audits)[:40])

    p0_order = [
        "Train 2: Add enforcement gates for root architecture, shell chrome, forbidden language, copy policy, and scenario matrix baseline.",
        "Train 3: Harden root stage/shell routing, capture overlay policy, drilldown dock policy, and Motion/Capture non-root guards.",
        "Train 4: Establish semantic material/chrome policy before touching more product views.",
        "Train 5-10: Refactor Today, Closure, Capture, Goals, Time, and You only after guards exist.",
        "Train 11-13: Migrate Motion behavior, trust/inspection, large-file splits, and remaining stub/adapter hardening.",
    ]
    return f"""# Design Truth Refraction Audit

Status: Yellow  
Branch: `{current_branch()}`  
Commit: `{current_sha()}`  
Scope: Train 0/1 only: canon readback, file inventory, classification, and audit artifacts. No product UI rebuild, file deletion, aesthetic replacement, Train 2 guard implementation, screenshot proof, accessibility proof, mutation proof, privacy proof, or release proof is claimed.

## Inventory Summary

- Git-tracked files classified: {len(audits)}
- Swift files classified: {sum(1 for audit in audits if audit.path.endswith(".swift"))}
- Markdown files classified: {sum(1 for audit in audits if audit.path.endswith(".md"))}
- Status counts: {", ".join(f"{key}={counts[key]}" for key in sorted(counts))}
- Raw search logs over 25 MB are replaced with hit counts, samples, command lines, and top file summaries.

## Top 20 Red Files

{table(["File", "Lines", "Classification", "Primary issue", "Status"], top_red_rows)}

## Top 20 Files To Split

{table(["File", "Lines", "Current responsibility", "Recommendation", "Status"], top_split_rows)}

## Top 20 Stubs/Adapters To Retire Or Harden

{table(["File", "Classification", "Recommendation", "Status"], top_stub_rows)}

## Obsolete Motion/Capture/Root-Tab Architecture Found

{table(["File", "Classification", "Finding", "Status"], obsolete_rows)}

## Recommended P0 Implementation Train Order

{bullet_list(p0_order)}

## Validation Run By Generator

- `git ls-files` inventory for all tracked files.
- `wc -l` line counts for all tracked files.
- Targeted architecture scan: `{rg_architecture["name"]}` with {rg_architecture["hit_count"]} hits in {rg_architecture["file_count"]} files.
- Targeted stub/adapter scan: `{rg_stub["name"]}` with {rg_stub["hit_count"]} hits in {rg_stub["file_count"]} files.
- Targeted forbidden-language scan: `{rg_language["name"]}` with {rg_language["hit_count"]} hits in {rg_language["file_count"]} files.

## Validation Not Run / Not Claimed In This Artifact

- Xcode build/test success is not claimed by this generated artifact.
- Screenshot matrix was not run.
- VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and real-device accessibility proof were not run.
- Mutation proof was not run.
- Large-file splits were not performed.
- Stub retirement was not performed.
- Release, TestFlight, App Store, privacy/legal, account, R2, and device readiness are not claimed.
"""


def render_outputs(audits: list[FileAudit]) -> dict[Path, str]:
    scan_paths = ["Native", "Sources", "AppUI", "docs", "prompts", "scripts", "tools", "Package.swift", "project.yml", "AGENTS.md", "README.md"]
    rg_architecture = rg_summary("obsolete architecture", OBSOLETE_ARCHITECTURE_PATTERNS, scan_paths)
    rg_stub = rg_summary("stub and adapter", STUB_PATTERNS, scan_paths)
    rg_language = rg_summary("forbidden language", FORBIDDEN_LANGUAGE_PATTERNS, scan_paths)
    return {
        OUTPUTS["readback"]: render_readback(audits),
        OUTPUTS["summary"]: render_summary(audits, rg_architecture, rg_stub, rg_language),
        OUTPUTS["ledger"]: render_ledger(audits),
        OUTPUTS["obsolete"]: render_obsolete(audits, rg_architecture),
        OUTPUTS["large"]: render_large(audits),
        OUTPUTS["stub"]: render_stub(audits, rg_stub),
        OUTPUTS["language"]: render_language(audits, rg_language),
    }


def ensure_no_unknown(audits: list[FileAudit]) -> None:
    for audit in audits:
        serialized = " ".join(
            [
                audit.canonical_layer,
                audit.product_owner,
                audit.implementation_status,
                audit.runtime_mutation,
                audit.accessibility,
                audit.chrome_risk,
                audit.split_recommendation,
                audit.status,
            ]
        ).lower()
        if "unknown" in serialized:
            raise RuntimeError(f"unknown classification leaked into {audit.path}: {serialized}")


def write_outputs(outputs: dict[Path, str]) -> None:
    for path, content in outputs.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")


def check_outputs(outputs: dict[Path, str]) -> int:
    stale: list[str] = []
    for path, expected in outputs.items():
        if not path.exists():
            stale.append(f"missing: {relative(path)}")
            continue
        actual = path.read_text(encoding="utf-8")
        if actual != expected:
            actual_hash = hashlib.sha256(actual.encode("utf-8")).hexdigest()[:12]
            expected_hash = hashlib.sha256(expected.encode("utf-8")).hexdigest()[:12]
            stale.append(f"stale: {relative(path)} actual={actual_hash} expected={expected_hash}")
    if stale:
        print("RED: Design Truth Refraction audit artifacts are stale")
        for item in stale:
            print(f"- {item}")
        return 1
    print("GREEN: Design Truth Refraction audit artifacts are current")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true", help="write generated audit artifacts")
    group.add_argument("--check", action="store_true", help="verify generated audit artifacts are current")
    args = parser.parse_args()

    os.chdir(ROOT)
    paths = git_lines(["ls-files"])
    counts = line_counts(paths)
    audits = build_audits(paths, counts)
    ensure_no_unknown(audits)
    outputs = render_outputs(audits)

    if args.write:
        write_outputs(outputs)
        print(f"Wrote {len(outputs)} Design Truth Refraction audit artifacts")
        for path in outputs:
            print(f"- {relative(path)}")
        return 0
    return check_outputs(outputs)


if __name__ == "__main__":
    sys.exit(main())
