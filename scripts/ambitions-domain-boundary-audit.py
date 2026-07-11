#!/usr/bin/env python3
"""Generate and validate the conservative Ambitions Domain boundary census."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from collections import Counter, defaultdict
from pathlib import Path


DOMAIN_ROOT = "Native/Ambitions/Core/Domain"
ALLOWED_IMPORTS = {"Foundation", "CryptoKit"}
PRODUCTION_TARGETS = {"Ambitions", "AmbitionsDomain"}
PUBLIC_STATUSES = {"candidate", "approved", "rejected"}
IMPORT_RE = re.compile(r"(?m)^\s*(?:@testable\s+)?import\s+([A-Za-z_]\w*)")
NOMINAL_RE = re.compile(r"\b(class|struct|enum|protocol|actor|typealias)[ \t]+([A-Za-z_]\w*)")
EXTENSION_RE = re.compile(r"\bextension[ \t]+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)")
IDENTIFIER_RE = re.compile(r"\b[A-Za-z_]\w*\b")
SIGNAL_PATTERNS = {
    "dynamic": re.compile(r"\b(?:NSClassFromString|StringFromClass|dlsym|performSelector)\b"),
    "persistence": re.compile(r"\b(?:Codable|Encodable|Decodable|SwiftData|ModelContext|UserDefaults|FileManager)\b"),
    "migration": re.compile(r"\b(?:Migration|SchemaMigrationPlan|VersionedSchema|migrate)\w*\b", re.I),
    "replay": re.compile(r"\b(?:Replay|rehydrat|event\s*log)\w*\b", re.I),
    "appIntents": re.compile(r"\b(?:AppIntent|AppEntity|AppShortcutsProvider|EntityQuery)\b|\bimport\s+AppIntents\b"),
    "widget": re.compile(r"\b(?:Widget|WidgetBundle|TimelineProvider)\b|\bimport\s+WidgetKit\b"),
    "share": re.compile(r"\b(?:ShareLink|UIActivityViewController|NSExtensionContext)\b|AmbitionsShareExtension"),
    "reflection": re.compile(r"\b(?:Mirror|reflecting|NSClassFromString|StringFromClass)\b"),
    "fixture": re.compile(r"\b(?:fixture|mock|stub|preview)\w*\b", re.I),
    "registry": re.compile(r"\b(?:Registry|register|registration|resolver|container)\b", re.I),
    "localRuntimeConstruction": re.compile(r"LocalRuntimeOS|LocalRuntime|AppContainerFactory|bootstrap", re.I),
}
REVIEW_CHECKS = (
    "dynamicPersistenceMigrationReplayChecked",
    "appIntentsWidgetsShareChecked",
    "reflectionFixturesRegistriesChecked",
    "localRuntimeConstructionChecked",
)


def _strip_comments_and_strings(text: str) -> str:
    result: list[str] = []
    index = 0
    state = "code"
    while index < len(text):
        pair = text[index:index + 2]
        char = text[index]
        if state == "code":
            if pair == "//":
                state = "line"
                result.extend("  ")
                index += 2
            elif pair == "/*":
                state = "block"
                result.extend("  ")
                index += 2
            elif char == '"':
                state = "string"
                result.append(" ")
                index += 1
            else:
                result.append(char)
                index += 1
        elif state == "line":
            result.append("\n" if char == "\n" else " ")
            if char == "\n":
                state = "code"
            index += 1
        elif state == "block":
            if pair == "*/":
                result.extend("  ")
                index += 2
                state = "code"
            else:
                result.append("\n" if char == "\n" else " ")
                index += 1
        else:
            if char == "\\" and index + 1 < len(text):
                result.extend("  ")
                index += 2
            elif char == '"':
                result.append(" ")
                index += 1
                state = "code"
            else:
                result.append("\n" if char == "\n" else " ")
                index += 1
    return "".join(result)


def _load_pbx_membership(project: Path) -> dict[str, list[str]]:
    pbxproj = project / "project.pbxproj" if project.is_dir() else project
    result = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(pbxproj)],
        check=True, capture_output=True, text=True,
    )
    data = json.loads(result.stdout)
    script = Path(__file__).with_name("ambitions-source-disposition-audit.py")
    spec = importlib.util.spec_from_file_location("ambitions_source_disposition_audit", script)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module.target_membership_from_pbx_json(data)


def _declarations(text: str) -> list[dict[str, str]]:
    clean = _strip_comments_and_strings(text)
    depth_at = []
    depth = 0
    for character in clean:
        depth_at.append(depth)
        if character == "{":
            depth += 1
        elif character == "}":
            depth = max(0, depth - 1)
    declarations = {
        (match.group(1), match.group(2))
        for match in NOMINAL_RE.finditer(clean)
        if not re.search(
            r"\b(?:private|fileprivate)[ \t]+$",
            clean[clean.rfind("\n", 0, match.start()) + 1:match.start()],
        )
    }
    declarations.update(
        ("extension", match.group(1))
        for match in EXTENSION_RE.finditer(clean)
        if not re.search(
            r"\b(?:private|fileprivate)[ \t]+$",
            clean[clean.rfind("\n", 0, match.start()) + 1:match.start()],
        )
    )
    return [{"kind": kind, "name": name} for kind, name in sorted(declarations)]


def _top_level_nominal_names(text: str) -> set[str]:
    clean = _strip_comments_and_strings(text)
    names = set()
    depth = 0
    position = 0
    matches = iter(NOMINAL_RE.finditer(clean))
    match = next(matches, None)
    for position, character in enumerate(clean):
        while match is not None and match.start() == position:
            prefix = clean[clean.rfind("\n", 0, match.start()) + 1:match.start()]
            if depth == 0 and not re.search(r"\b(?:private|fileprivate)[ \t]+$", prefix):
                names.add(match.group(2))
            match = next(matches, None)
        if character == "{":
            depth += 1
        elif character == "}":
            depth = max(0, depth - 1)
    return names


def _compiler_public_interface(path: Path | None) -> list[str]:
    if path is None:
        return []
    signatures: list[str] = []
    declaration = re.compile(
        r"^(?:@[A-Za-z_][^ ]*\s+)*(?:public|open)\s+(?:final\s+|static\s+|class\s+|mutating\s+|nonmutating\s+|convenience\s+|required\s+|override\s+|indirect\s+)*(?:class|struct|enum|protocol|actor|extension|typealias|init[!?]?|func|subscript|case|var|let)\b"
    )
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.strip()
        if declaration.match(line):
            signatures.append(re.sub(r"\s+\{.*$", "", line).rstrip())
    return sorted(set(signatures))


def _candidate_reasons(path: str, declarations: list[dict[str, str]], loc: int, duplicates: Counter[str]) -> list[str]:
    reasons = []
    name = Path(path).name
    if re.search(r"\+(?:0[2-9]|[1-9]\d*)\.swift$", name):
        reasons.append("numbered_suffix")
    if re.search(r"(?:compatibility|legacy|shim)", name, re.I):
        reasons.append("compatibility_or_legacy_name")
    if any(duplicates[row["name"]] > 1 for row in declarations if row["kind"] != "extension"):
        reasons.append("duplicate_nominal_declaration")
    if loc > 500:
        reasons.append("unusually_high_file_size")
    return reasons


def _nearby_signal_labels(text: str, names: set[str]) -> set[str]:
    lines = text.splitlines()
    name_lines = [
        index for index, line in enumerate(lines)
        if names & set(IDENTIFIER_RE.findall(_strip_comments_and_strings(line)))
    ]
    labels = set()
    for index in name_lines:
        context = "\n".join(lines[max(0, index - 2):index + 3])
        labels.update(label for label, pattern in SIGNAL_PATTERNS.items() if pattern.search(context))
    return labels


def collect_boundary(root: Path, project: Path, disposition: Path) -> dict[str, object]:
    """Return a sorted schema-version-1 census without authorizing public API or deletion."""
    root = root.resolve()
    membership = _load_pbx_membership(project)
    disposition_rows = {
        row["path"]: row for row in json.loads(disposition.read_text(encoding="utf-8")).get("files", [])
    }
    domain_paths = sorted((root / DOMAIN_ROOT).rglob("*.swift"))
    raw_rows = []
    duplicate_names: Counter[str] = Counter()
    symbols: set[str] = set()
    for path in domain_paths:
        relative = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8", errors="replace")
        declarations = _declarations(text)
        for declaration in declarations:
            if declaration["kind"] != "extension":
                symbols.add(declaration["name"])
        duplicate_names.update(_top_level_nominal_names(text))
        raw_rows.append((relative, text, declarations))
    files = []
    for relative, text, declarations in raw_rows:
        files.append({
            "path": relative,
            "imports": sorted(set(IMPORT_RE.findall(_strip_comments_and_strings(text)))),
            "declarations": declarations,
            "xcodeTargets": sorted(membership.get(relative, [])),
            "disposition": disposition_rows.get(relative, {}).get("disposition", "missing"),
            "loc": len(text.splitlines()),
            "contentSha256": hashlib.sha256(text.encode()).hexdigest(),
        })
    outside = []
    for relative, targets in sorted(membership.items()):
        if relative.startswith(DOMAIN_ROOT + "/") or not relative.endswith(".swift"):
            continue
        eligible = sorted(set(targets) & (PRODUCTION_TARGETS | {"AmbitionsTests", "AmbitionsUITests", "AmbitionsWidgetExtension", "AmbitionsShareExtension"}))
        path = root / relative
        if not eligible or not path.is_file():
            continue
        clean = _strip_comments_and_strings(path.read_text(encoding="utf-8", errors="replace"))
        tokens = set(IDENTIFIER_RE.findall(clean))
        candidates = sorted(symbols & tokens)
        if candidates:
            for target in eligible:
                outside.append({"path": relative, "target": target, "candidateSymbols": candidates})
    candidates = []
    searchable = []
    for relative in sorted(disposition_rows):
        source = root / relative
        if source.suffix != ".swift" or not source.is_file():
            continue
        text = source.read_text(encoding="utf-8", errors="replace")
        searchable.append((
            relative,
            text,
            set(IDENTIFIER_RE.findall(_strip_comments_and_strings(text))),
        ))
    for row in files:
        reasons = _candidate_reasons(row["path"], row["declarations"], row["loc"], duplicate_names)
        if not reasons:
            continue
        names = {item["name"] for item in row["declarations"]}
        candidate_evidence = {
            path: (
                _nearby_signal_labels(text, names)
                | {
                    label for label in ("appIntents", "widget", "share", "localRuntimeConstruction")
                    if SIGNAL_PATTERNS[label].search(text)
                }
            )
            for path, text, tokens in searchable
            if names & tokens
        }
        signals = {
            label: sorted(path for path, labels in candidate_evidence.items() if label in labels)
            for label in SIGNAL_PATTERNS
        }
        signal_summary = ", ".join(
            f"{label}={len(paths)}" for label, paths in signals.items() if paths
        ) or "no dynamic reference signals found"
        candidates.append({
            "path": row["path"],
            "reasons": reasons,
            "safetySignals": signals,
            "decision": "retain_unknown",
            "blockingEvidence": (
                f"{row['path']}: {', '.join(reasons)}; inspected signals: "
                f"{signal_summary}; no current Green destructive proof"
            ),
        })
    payload: dict[str, object] = {
        "schemaVersion": 1,
        "repositoryRoot": "." if root == Path.cwd().resolve() else str(root),
        "domainRoot": DOMAIN_ROOT,
        "files": files,
        "outsideConsumers": outside,
        "compilerDiagnostics": [],
        "compilerPublicInterface": [],
        "publicContracts": [],
        "consolidationCandidates": candidates,
        "deletionAuthorizations": [],
        "consolidationReview": {"status": "unreviewed", **{key: False for key in REVIEW_CHECKS}, "provenCandidatePaths": []},
        "review": {"status": "unreviewed", "reviewer": None, "reviewArtifact": None, "reviewedContentHash": None, "findings": []},
    }
    payload["generatedContentHash"] = reviewed_content_hash(root, payload)
    return payload


def reviewed_content_hash(root: Path, payload: dict[str, object]) -> str:
    """Hash normalized generated facts, diagnostics, interface, and declaration/consumer files."""
    normalized = {key: value for key, value in payload.items() if key not in {"review", "generatedContentHash"}}
    digest = hashlib.sha256(json.dumps(normalized, sort_keys=True, separators=(",", ":")).encode())
    paths = sorted({row["path"] for row in payload.get("files", [])} | {row["path"] for row in payload.get("outsideConsumers", [])})
    for relative in paths:
        digest.update(relative.encode())
        path = root / relative
        digest.update(path.read_bytes() if path.is_file() else b"<missing>")
    value = "sha256:" + digest.hexdigest()
    payload["generatedContentHash"] = value
    return value


def approve_review(root: Path, payload: dict[str, object], reviewer: str, review_artifact: Path) -> dict[str, object]:
    updated = json.loads(json.dumps(payload))
    findings = [line.strip() for line in review_artifact.read_text(encoding="utf-8").splitlines() if re.match(r"^(?:Critical|Important|Minor):", line.strip())]
    updated["review"] = {
        "status": "approved" if not any(item.startswith(("Critical:", "Important:")) for item in findings) else "needs_repair",
        "reviewer": reviewer,
        "reviewArtifact": review_artifact.as_posix(),
        "reviewedContentHash": None,
        "findings": findings,
    }
    updated["review"]["reviewedContentHash"] = reviewed_content_hash(root, updated)
    updated["generatedContentHash"] = updated["review"]["reviewedContentHash"]
    return updated


def validate_boundary(payload: dict[str, object], require_review: bool) -> list[str]:
    """Return stable ordered findings; an empty list is Green."""
    findings = []
    for row in payload.get("files", []):
        for imported in row.get("imports", []):
            if imported not in ALLOWED_IMPORTS:
                findings.append(f"forbidden Domain import: {imported} in {row['path']}")
        if len(set(row.get("xcodeTargets", [])) & PRODUCTION_TARGETS) > 1:
            findings.append(f"Domain source has multiple production targets: {row['path']}")
    if not require_review:
        return findings
    review = payload.get("review", {})
    if review.get("status") != "approved":
        findings.append("boundary review is not approved")
    contracts = payload.get("publicContracts", [])
    approved = set()
    for contract in contracts:
        symbol = contract.get("symbol", "<missing>")
        if contract.get("status") not in PUBLIC_STATUSES or contract.get("status") != "approved":
            findings.append(f"public contract lacks approved decision: {symbol}")
        else:
            approved.add(symbol)
            if any(not contract.get(field) for field in ("declarationPaths", "consumerPaths", "coverage", "decision")):
                findings.append(f"public contract has incomplete evidence: {symbol}")
    interface = set(payload.get("compilerPublicInterface", []))
    for signature in sorted(interface - approved):
        findings.append(f"unapproved compiler public declaration: {signature}")
    for signature in sorted(approved - interface):
        findings.append(f"approved public contract absent from compiler interface: {signature}")
    if any(item.startswith(("Critical:", "Important:")) for item in review.get("findings", [])):
        findings.append("boundary review retains Critical or Important findings")
    current_hash = reviewed_content_hash(Path(payload.get("repositoryRoot", ".")), payload)
    if review.get("reviewedContentHash") != current_hash:
        findings.append("reviewed content hash does not match current boundary content")
    consolidation = payload.get("consolidationReview", {})
    if consolidation.get("status") != "approved":
        findings.append("consolidation review is not approved")
    for check in REVIEW_CHECKS:
        if not consolidation.get(check):
            findings.append(f"consolidation review is incomplete: {check}")
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--disposition", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--swift-interface", type=Path)
    parser.add_argument("--validate-only", action="store_true")
    parser.add_argument("--require-review", action="store_true")
    parser.add_argument("--approve-review", action="store_true")
    parser.add_argument("--reviewer")
    parser.add_argument("--review-artifact", type=Path)
    args = parser.parse_args()
    root = Path.cwd()
    payload = collect_boundary(root, args.project, args.disposition)
    if args.output.exists():
        previous = json.loads(args.output.read_text(encoding="utf-8"))
        for key in ("publicContracts", "consolidationReview", "review"):
            if key in previous:
                payload[key] = previous[key]
    if args.swift_interface:
        payload["compilerPublicInterface"] = _compiler_public_interface(args.swift_interface)
        payload["compilerDiagnostics"] = []
    payload["generatedContentHash"] = reviewed_content_hash(root, payload)
    if args.approve_review:
        if not args.reviewer or not args.review_artifact:
            parser.error("--approve-review requires --reviewer and --review-artifact")
        payload = approve_review(root, payload, args.reviewer, args.review_artifact)
    findings = validate_boundary(payload, args.require_review)
    if not args.validate_only:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"domain-files={len(payload['files'])}")
    print(f"outside-consumers={len(payload['outsideConsumers'])}")
    print(f"consolidation-candidates={len(payload['consolidationCandidates'])}")
    for finding in findings:
        print(f"finding: {finding}")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
