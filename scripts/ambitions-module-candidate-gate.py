#!/usr/bin/env python3
"""Fail-closed authorization gate for prospective Ambitions build modules."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import plistlib
import re
import shutil
import statistics
import subprocess
from collections import Counter
from pathlib import Path, PurePosixPath
from typing import Any, NamedTuple


ALLOWED_STATUSES = {"observed", "rejected", "authorized"}
CANONICAL_OWNERS = {
    "App", "Stage", "Core", "Projection", "Language", "Trust", "Interaction",
    "Rendering", "DesignSystem", "Surfaces", "Composer", "Scenarios", "Diagnostics", "Quality",
}
THRESHOLD_KEYS = {
    "historyMaximumFirstParentCommits", "historyMinimumFirstParentCommits",
    "productionHighChurnPercentile", "benchmarkSamplesPerCohort",
    "moduleTestMedianMaximumSeconds", "leafProofMedianMaximumSeconds",
    "leafProofMinimumHostedImprovementFraction", "candidateWorstMaximumHostedRatio",
    "appNoChangeMaximumRegressionFraction",
}
BENCHMARK_COHORTS = (
    "moduleTest", "leafProofCandidate", "leafProofHostedBaseline",
    "appNoChangeCandidate", "appNoChangeBaseline",
)
TEST_BENCHMARK_COHORTS = {"moduleTest", "leafProofCandidate", "leafProofHostedBaseline"}
AUTHORITY_PATHS = ("project.yml", "scripts/ambitions-changed-file-test-routes.json")
TARGET_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
DISQUALIFIER_FINDINGS = {
    "folder_derived": "source set is folder-derived rather than explicit",
    "compiler_closure_failed": "compiler closure did not pass",
    "low_churn": "candidate median file touches are below the production high-churn cohort",
}


class EvidenceFormatError(ValueError):
    pass


class CandidateResult(NamedTuple):
    candidate_id: str
    declared_status: str
    status: str
    findings: tuple[str, ...]
    proposed_target: str | None


class PolicyResult(NamedTuple):
    ok: bool
    candidates: tuple[CandidateResult, ...]
    authorized_targets: tuple[str, ...]
    findings: tuple[str, ...]


class GitContext(NamedTuple):
    head: str
    commits: tuple[str, ...]
    touches: dict[str, int]
    authority_hashes: dict[str, str]


def _mapping(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise EvidenceFormatError(f"{label} must be an object")
    return value


def _list(value: Any, label: str) -> list[Any]:
    if not isinstance(value, list):
        raise EvidenceFormatError(f"{label} must be an array")
    return value


def _strings(value: Any, label: str, *, nonempty: bool = False) -> list[str]:
    rows = _list(value, label)
    if (nonempty and not rows) or any(not isinstance(row, str) or not row for row in rows):
        raise EvidenceFormatError(f"{label} must be a{' nonempty' if nonempty else ''} string array")
    return rows


def _number(value: Any, label: str, *, integer: bool = False) -> float | int:
    valid = type(value) is int if integer else type(value) in {int, float}
    if not valid or value < 0 or (not integer and not math.isfinite(float(value))):
        raise EvidenceFormatError(f"{label} must be a nonnegative {'integer' if integer else 'number'}")
    return value


def _sha(value: Any) -> bool:
    return (
        isinstance(value, str) and len(value) == 71 and value.startswith("sha256:")
        and all(character in "0123456789abcdef" for character in value[7:])
    )


def _commit(value: Any) -> bool:
    return isinstance(value, str) and len(value) == 40 and all(character in "0123456789abcdef" for character in value)


def _append(destination: list[str], finding: str) -> None:
    if finding not in destination:
        destination.append(finding)


def _digest_bytes(value: bytes) -> str:
    return "sha256:" + hashlib.sha256(value).hexdigest()


def _repository_file(root: Path, relative: str) -> Path | None:
    path = Path(relative)
    if path.is_absolute() or ".." in path.parts:
        return None
    candidate = root / path
    try:
        resolved = candidate.resolve(strict=True)
        resolved.relative_to(root.resolve())
    except (OSError, ValueError):
        return None
    current = candidate
    while current != root:
        if current.is_symlink():
            return None
        current = current.parent
    return candidate if candidate.is_file() else None


def _json_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise EvidenceFormatError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def _json_loads(value: str | bytes) -> Any:
    def invalid_constant(constant: str):
        raise EvidenceFormatError(f"nonfinite JSON number: {constant}")

    return json.loads(value, object_pairs_hook=_json_object, parse_constant=invalid_constant)


def source_set_hash(root: Path, paths: list[str]) -> str:
    digest = hashlib.sha256()
    for relative in sorted(paths):
        source = _repository_file(root, relative)
        if source is None:
            raise EvidenceFormatError(f"source path is a symlink or resolves outside repository: {relative}")
        digest.update(relative.encode())
        digest.update(b"\0")
        digest.update(source.read_bytes())
        digest.update(b"\0")
    return "sha256:" + digest.hexdigest()


def candidate_identity(
    candidate_id: str,
    target: str,
    files: list[str],
    source_hash: str,
    head: str,
    authority_hashes: dict[str, str],
) -> str:
    payload = {
        "authorityHashes": authority_hashes,
        "candidateID": candidate_id,
        "proposedTarget": target,
        "repositoryHead": head,
        "sourceContentHash": source_hash,
        "sourceFiles": sorted(files),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return _digest_bytes(encoded)


def _canonical_source_path(relative: str) -> bool:
    path = PurePosixPath(relative)
    return (
        not path.is_absolute() and ".." not in path.parts and len(path.parts) >= 4
        and path.parts[:2] == ("Native", "Ambitions") and path.parts[2] in CANONICAL_OWNERS
        and path.suffix == ".swift"
    )


def _git(root: Path, *arguments: str) -> str | None:
    try:
        result = subprocess.run(
            ["git", *arguments], cwd=root, check=False, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
    except OSError:
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def _authority_hashes(root: Path) -> dict[str, str] | None:
    authority_files = {relative: _repository_file(root, relative) for relative in AUTHORITY_PATHS}
    if any(path is None for path in authority_files.values()):
        return None
    return {relative: _digest_bytes(path.read_bytes()) for relative, path in authority_files.items() if path is not None}


def _git_context(root: Path, maximum: int) -> GitContext | None:
    top = _git(root, "rev-parse", "--show-toplevel")
    if top is None or Path(top).resolve() != root.resolve():
        return None
    tracked_status = _git(root, "status", "--porcelain", "--untracked-files=no")
    if tracked_status is None or tracked_status:
        return None
    head = _git(root, "rev-parse", "HEAD")
    commit_text = _git(root, "rev-list", "--first-parent", f"--max-count={maximum}", "HEAD")
    tracked_text = _git(root, "ls-files", "--", "Native/Ambitions")
    authority = _authority_hashes(root)
    authorities_tracked = all(
        _git(root, "ls-files", "--error-unmatch", "--", relative) is not None
        for relative in AUTHORITY_PATHS
    )
    if not _commit(head) or commit_text is None or tracked_text is None or authority is None or not authorities_tracked:
        return None
    commits = tuple(commit_text.splitlines())
    if any(not _commit(commit) for commit in commits):
        return None
    tracked = sorted(path for path in tracked_text.splitlines() if _canonical_source_path(path))
    touches = {path: 0 for path in tracked}
    log = _git(
        root, "log", "--first-parent", f"--max-count={maximum}", "--format=@@@%H",
        "--name-only", "--no-renames", "HEAD", "--", "Native/Ambitions",
    )
    if log is None:
        return None
    seen: set[str] = set()
    for line in log.splitlines():
        if line.startswith("@@@"):
            seen = set()
        elif line in touches and line not in seen:
            touches[line] += 1
            seen.add(line)
    return GitContext(head, commits, touches, authority)


def _reference_bytes(
    root: Path,
    label: str,
    raw: Any,
    observed: list[str],
    rejected: list[str],
    *,
    missing_is_observed: bool = True,
) -> bytes | None:
    if raw is None:
        _append(observed if missing_is_observed else rejected, f"{label} artifact reference is missing")
        return None
    if not isinstance(raw, dict) or set(raw) != {"path", "sha256"}:
        _append(rejected, f"{label} artifact reference is invalid")
        return None
    relative, digest = raw.get("path"), raw.get("sha256")
    if not isinstance(relative, str) or not relative or not _sha(digest):
        _append(rejected, f"{label} artifact reference is invalid")
        return None
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        _append(rejected, f"{label} artifact is outside the repository root")
        return None
    path = _repository_file(root, relative)
    if path is None and (root / relative).exists():
        _append(rejected, f"{label} artifact is outside the repository root")
        return None
    if path is None and (root / relative).is_symlink():
        _append(rejected, f"{label} artifact is outside the repository root")
        return None
    if path is None:
        _append(observed if missing_is_observed else rejected, f"{label} artifact is missing")
        return None
    contents = path.read_bytes()
    if _digest_bytes(contents) != digest:
        _append(rejected, f"{label} artifact digest does not match file")
        return None
    return contents


def _load_artifact(
    root: Path,
    label: str,
    raw_ref: Any,
    artifact_type: str,
    expected_identity: str,
    candidate_id: str,
    target: str,
    files: list[str],
    source_hash: str,
    context: GitContext,
    observed: list[str],
    rejected: list[str],
) -> dict[str, Any] | None:
    contents = _reference_bytes(root, label, raw_ref, observed, rejected)
    if contents is None:
        return None
    try:
        payload = _mapping(_json_loads(contents), f"{label} artifact")
        if type(payload.get("schemaVersion")) is not int or payload["schemaVersion"] != 1:
            raise EvidenceFormatError("schemaVersion must be integer 1")
        if payload.get("artifactType") != artifact_type:
            raise EvidenceFormatError(f"artifactType must be {artifact_type}")
        artifact_files = _strings(payload.get("sourceFiles"), "sourceFiles")
        authority = _mapping(payload.get("authorityHashes"), "authorityHashes")
    except (json.JSONDecodeError, UnicodeDecodeError, EvidenceFormatError) as error:
        _append(rejected, f"{label} artifact schema is invalid: {error}")
        return None
    if payload.get("candidateIdentity") != expected_identity:
        _append(rejected, f"{label} artifact candidate identity does not match candidate")
        return None
    if (
        payload.get("candidateID") != candidate_id or payload.get("proposedTarget") != target
        or artifact_files != sorted(files) or payload.get("sourceContentHash") != source_hash
    ):
        _append(rejected, f"{label} artifact candidate binding does not match candidate")
        return None
    if payload.get("repositoryHead") != context.head:
        _append(
            rejected,
            "history artifact head does not match live Git"
            if label == "history"
            else f"{label} artifact repository HEAD does not match live Git",
        )
        return None
    if authority != context.authority_hashes:
        _append(rejected, f"{label} artifact authority hashes do not match live files")
        return None
    return payload


def _schema(rejected: list[str], label: str, operation):
    try:
        return operation()
    except EvidenceFormatError as error:
        _append(rejected, f"{label} artifact schema is invalid: {error}")
        _append(rejected, str(error))
        return None


def _top_cohort_median(values: list[float], percentile: float) -> float:
    count = max(1, math.ceil(len(values) * (1.0 - percentile)))
    return float(statistics.median(sorted(values, reverse=True)[:count]))


def _evaluate_history(
    payload: dict[str, Any] | None,
    context: GitContext,
    thresholds: dict[str, Any],
    files: list[str],
    rejected: list[str],
) -> None:
    if payload is None:
        return

    def parse():
        commits = _strings(payload.get("firstParentCommits"), "history firstParentCommits", nonempty=True)
        if any(not _commit(commit) for commit in commits):
            raise EvidenceFormatError("history firstParentCommits must contain full lowercase commit SHAs")
        candidate = _mapping(payload.get("candidateFileTouches"), "history candidateFileTouches")
        production = _mapping(payload.get("productionFileTouches"), "history productionFileTouches")
        for path, value in candidate.items():
            _number(value, f"candidate touch count for {path}", integer=True)
        for path, value in production.items():
            _number(value, f"production touch count for {path}", integer=True)
        return commits, candidate, production

    parsed = _schema(rejected, "history", parse)
    if parsed is None:
        return
    commits, candidate, production = parsed
    if payload.get("repositoryHead") != context.head:
        _append(rejected, "history artifact head does not match live Git")
    if commits != list(context.commits):
        _append(rejected, "history artifact first-parent window does not match live Git")
    if len(context.commits) < thresholds["historyMinimumFirstParentCommits"]:
        _append(rejected, "first-parent history has fewer commits than policy minimum")
    if any(path not in context.touches for path in files):
        _append(rejected, "source set is not fully tracked at live Git HEAD")
        return
    expected_candidate = {path: context.touches.get(path, 0) for path in files}
    if candidate != expected_candidate or production != context.touches:
        _append(rejected, "history artifact touch maps do not match live Git")
        return
    if not candidate or not production:
        _append(rejected, "history artifact touch maps are empty")
        return
    candidate_median = statistics.median(candidate.values())
    cohort = _top_cohort_median([float(value) for value in production.values()], thresholds["productionHighChurnPercentile"])
    if candidate_median < cohort:
        _append(rejected, "candidate median file touches are below the production high-churn cohort")


def _parse_graph(payload: dict[str, Any], target: str, files: list[str], rejected: list[str]) -> dict[str, Any] | None:
    def parse():
        nodes = [_mapping(row, "graph node") for row in _list(payload.get("nodes"), "graph nodes")]
        node_pairs = [(row.get("name"), row.get("kind")) for row in nodes]
        if any(not isinstance(name, str) or not name or not isinstance(kind, str) or not kind for name, kind in node_pairs):
            raise EvidenceFormatError("graph nodes require nonempty name and kind")
        if len({name for name, _ in node_pairs}) != len(node_pairs):
            raise EvidenceFormatError("graph node names must be unique")
        kinds = dict(node_pairs)
        edges_raw = [_mapping(row, "graph edge") for row in _list(payload.get("edges"), "graph edges")]
        edges = [(row.get("from"), row.get("to")) for row in edges_raw]
        if any(not isinstance(source, str) or not source or not isinstance(destination, str) or not destination for source, destination in edges):
            raise EvidenceFormatError("graph edges require nonempty string endpoints")
        if any(source not in kinds or destination not in kinds for source, destination in edges):
            raise EvidenceFormatError("graph edges must reference declared nodes")
        if len(set(edges)) != len(edges):
            raise EvidenceFormatError("graph edges must be unique")
        memberships = _mapping(payload.get("sourceMemberships"), "graph sourceMemberships")
        for path, targets in memberships.items():
            _strings(targets, f"memberships for {path}", nonempty=True)
        module_test = payload.get("moduleTestTarget")
        integration_test = payload.get("integrationTestTarget")
        if not isinstance(module_test, str) or not module_test or not isinstance(integration_test, str) or not integration_test:
            raise EvidenceFormatError("graph target names must be nonempty strings")
        applications = _strings(payload.get("applicationTargets"), "graph applicationTargets", nonempty=True)
        extensions = _strings(payload.get("extensionTargets"), "graph extensionTargets")
        if kinds.get(target) != "production" or kinds.get(module_test) != "module-test" or kinds.get(integration_test) != "integration-test":
            raise EvidenceFormatError("graph target and test target kinds are invalid")
        if any(kinds.get(name) != "application" for name in applications) or any(kinds.get(name) != "extension" for name in extensions):
            raise EvidenceFormatError("graph host target kinds are invalid")
        return kinds, edges, memberships, module_test, integration_test, applications, extensions

    parsed = _schema(rejected, "graph", parse)
    if parsed is None:
        return None
    kinds, edges, memberships, module_test, integration_test, applications, extensions = parsed
    adjacency = {node: set() for node in kinds}
    for source, destination in edges:
        adjacency[source].add(destination)

    visiting: set[str] = set()
    visited: set[str] = set()

    def has_cycle(node: str) -> bool:
        if node in visiting:
            return True
        if node in visited:
            return False
        visiting.add(node)
        cyclic = any(has_cycle(child) for child in adjacency[node])
        visiting.remove(node)
        visited.add(node)
        return cyclic

    if any(has_cycle(node) for node in kinds):
        _append(rejected, "candidate target graph contains a cycle")
    if set(memberships) != set(files) or any(memberships[path] != [target] for path in files if path in memberships):
        _append(rejected, "candidate source lacks exactly one production membership")
    reachable: set[str] = set()
    pending = list(adjacency[module_test])
    while pending:
        node = pending.pop()
        if node not in reachable:
            reachable.add(node)
            pending.extend(adjacency[node])
    if target not in reachable:
        _append(rejected, "module tests do not reach the candidate target")
    if reachable.intersection(set(applications + extensions)):
        _append(rejected, "module tests can reach an application or extension target")
    return {
        "nodes": set(kinds), "dependencies": sorted(adjacency[target]),
        "moduleTestTarget": module_test, "integrationTestTarget": integration_test,
    }


def _remember_reference(raw: Any, fingerprints: dict[str, str]) -> None:
    if isinstance(raw, dict) and isinstance(raw.get("path"), str) and _sha(raw.get("sha256")):
        fingerprints[raw["path"]] = raw["sha256"]


def _evaluate_compiler(
    root: Path,
    payload: dict[str, Any] | None,
    target: str,
    files: list[str],
    graph: dict[str, Any] | None,
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> None:
    if payload is None:
        return

    result_ref = payload.get("compilerResult")
    _remember_reference(result_ref, fingerprints)
    contents = _reference_bytes(root, "compiler raw result", result_ref, observed, rejected)
    if contents is None:
        return

    def parse():
        raw = _mapping(_json_loads(contents), "compiler raw result")
        invocation = _strings(raw.get("argv"), "compiler invocation", nonempty=True)
        exit_code = _number(raw.get("exit_code"), "compiler exit_code", integer=True)
        stdout, stderr = raw.get("stdout"), raw.get("stderr")
        if not isinstance(stdout, str) or not isinstance(stderr, str):
            raise EvidenceFormatError("compiler stdout and stderr must be strings")
        diagnostics = _list(raw.get("diagnostics"), "compiler diagnostics")
        for diagnostic in diagnostics:
            row = _mapping(diagnostic, "compiler diagnostic")
            severity = row.get("severity")
            if (
                not isinstance(severity, str)
                or severity not in {"warning", "note", "remark", "error"}
                or not isinstance(row.get("message"), str)
            ):
                raise EvidenceFormatError("compiler diagnostics require typed severity and message")
        dependencies = _strings(payload.get("declaredDependencies"), "compiler declaredDependencies")
        if len(set(dependencies)) != len(dependencies):
            raise EvidenceFormatError("compiler dependencies must be unique")
        return invocation, exit_code, stdout, stderr, diagnostics, dependencies

    parsed = _schema(rejected, "compiler", parse)
    if parsed is None:
        return
    invocation, exit_code, stdout, stderr, diagnostics, dependencies = parsed
    def trusted_tool(token: str, name: str) -> bool:
        if token == name:
            return True
        discovered = shutil.which(name)
        return bool(discovered and Path(token).is_absolute() and Path(token).resolve() == Path(discovered).resolve())

    uses_swiftc = trusted_tool(invocation[0], "swiftc") or (
        trusted_tool(invocation[0], "xcrun") and len(invocation) > 1 and invocation[1] == "swiftc"
    )
    if not uses_swiftc:
        _append(rejected, "compiler invocation does not use Swift compiler")
    if exit_code != 0:
        _append(rejected, "compiler invocation did not exit successfully")
    if any("error:" in line.lower() for line in (stdout + "\n" + stderr).splitlines()) or any(
        row["severity"] == "error" for row in diagnostics
    ):
        _append(rejected, "compiler artifact reports error diagnostics")
    positions = [index for index, value in enumerate(invocation) if value == "-module-name"]
    if len(positions) != 1 or positions[0] + 1 >= len(invocation) or invocation[positions[0] + 1] != target:
        _append(rejected, "compiler invocation module name does not match proposed target")
    invocation_sources = [value for value in invocation if value.endswith(".swift")]
    if sorted(invocation_sources) != sorted(files) or len(invocation_sources) != len(files):
        _append(rejected, "compiler invocation source paths do not match exact source set")
    if graph is not None and sorted(dependencies) != graph["dependencies"]:
        _append(rejected, "compiler dependencies do not match graph target edges")


def _evaluate_public_api(
    payload: dict[str, Any] | None,
    root: Path,
    target: str,
    graph: dict[str, Any] | None,
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> None:
    if payload is None:
        return

    symbol_ref = payload.get("symbolGraph")
    _remember_reference(symbol_ref, fingerprints)
    contents = _reference_bytes(root, "public API symbol graph", symbol_ref, observed, rejected)
    if contents is None:
        return

    def parse():
        symbol_graph = _mapping(_json_loads(contents), "symbol graph")
        module = _mapping(symbol_graph.get("module"), "symbol graph module")
        if module.get("name") != target:
            raise EvidenceFormatError("symbol graph module does not match proposed target")
        symbols = [_mapping(row, "symbol graph symbol") for row in _list(symbol_graph.get("symbols"), "symbol graph symbols")]
        if not symbols:
            raise EvidenceFormatError("symbol graph contains no compiler-public declarations")
        contracts = [_mapping(row, "approved contract") for row in _list(payload.get("approvedContracts"), "approvedContracts")]
        declaration_keys = []
        for row in symbols:
            identifier = _mapping(row.get("identifier"), "symbol identifier")
            fragments = [_mapping(fragment, "declaration fragment") for fragment in _list(row.get("declarationFragments"), "declarationFragments")]
            usr = identifier.get("precise")
            if row.get("accessLevel") != "public" or not isinstance(usr, str) or not usr or not fragments:
                raise EvidenceFormatError("symbol graph public declarations require USR and declaration fragments")
            signature = _digest_bytes(json.dumps(fragments, sort_keys=True, separators=(",", ":")).encode())
            declaration_keys.append((usr, signature))
        if len(set(declaration_keys)) != len(declaration_keys):
            raise EvidenceFormatError("compiler public declarations must be unique")
        contract_keys = []
        for row in contracts:
            usr, signature, consumer = row.get("usr"), row.get("signatureHash"), row.get("consumerTarget")
            consumers = _strings(row.get("consumerFiles"), "contract consumerFiles", nonempty=True)
            if not isinstance(usr, str) or not usr or not _sha(signature) or not isinstance(consumer, str) or not consumer:
                raise EvidenceFormatError("approved contracts require USR, signature hash, and consumer target")
            if any(
                not _canonical_source_path(path)
                or _repository_file(root, path) is None
                or _git(root, "ls-files", "--error-unmatch", "--", path) is None
                for path in consumers
            ):
                raise EvidenceFormatError("approved contract consumer file is not repository-contained")
            contract_keys.append((usr, signature, consumer))
        return declaration_keys, contract_keys

    parsed = _schema(rejected, "public API", parse)
    if parsed is None:
        return
    declarations, contracts = parsed
    counts = Counter((usr, signature) for usr, signature, _ in contracts)
    if set(counts) != set(declarations) or any(counts[key] != 1 for key in declarations):
        _append(rejected, "compiler-public declarations lack exactly one approved consumer contract")
    if graph is not None and any(consumer not in graph["nodes"] for _, _, consumer in contracts):
        _append(rejected, "public API contract names an unknown consumer target")


def _evaluate_routes(
    payload: dict[str, Any] | None,
    files: list[str],
    module_executed: set[str],
    integration_executed: set[str],
    rejected: list[str],
) -> None:
    if payload is None:
        return

    def parse():
        rows = [_mapping(row, "changed-file route") for row in _list(payload.get("routes"), "routes")]
        parsed = []
        for row in rows:
            source = row.get("sourceFile")
            if not isinstance(source, str) or not source:
                raise EvidenceFormatError("route sourceFile must be nonempty")
            module = _strings(row.get("moduleTests"), "route moduleTests")
            hosted = _strings(row.get("hostedIntegrationTests"), "route hostedIntegrationTests")
            parsed.append((source, module, hosted))
        return parsed

    rows = _schema(rejected, "routes", parse)
    if rows is None:
        return
    sources = [source for source, _, _ in rows]
    if sorted(sources) != sorted(files) or len(sources) != len(set(sources)):
        _append(rejected, "changed-file routes do not cover the exact source set")
    if any(not module for _, module, _ in rows):
        _append(rejected, "changed-file route lacks module test proof")
    if any(not hosted for _, _, hosted in rows):
        _append(rejected, "changed-file route lacks hosted integration proof")
    if any(identifier not in module_executed for _, module, _ in rows for identifier in module):
        _append(rejected, "changed-file route names a module test that did not execute")
    if any(identifier not in integration_executed for _, _, hosted in rows for identifier in hosted):
        _append(rejected, "changed-file route names a hosted integration test that did not execute")


def _parse_test(
    root: Path,
    payload: dict[str, Any] | None,
    label: str,
    lane: str,
    target: str | None,
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> tuple[str, set[str]] | None:
    if payload is None:
        return None

    def parse():
        result_id = payload.get("resultID")
        if not isinstance(result_id, str) or not result_id:
            raise EvidenceFormatError(f"{label} resultID must be nonempty")
        bundle = payload.get("resultBundlePath")
        if not isinstance(bundle, str) or not bundle:
            raise EvidenceFormatError(f"{label} resultBundlePath must be nonempty")
        identifiers = _strings(payload.get("executedTestIdentifiers"), f"{label} executedTestIdentifiers", nonempty=True)
        if len(set(identifiers)) != len(identifiers):
            raise EvidenceFormatError(f"{label} executedTestIdentifiers must be unique")
        return (
            payload.get("lane"), payload.get("testTarget"),
            _number(payload.get("exitCode"), f"{label} exitCode", integer=True),
            _number(payload.get("executedTests"), f"{label} executedTests", integer=True),
            result_id, identifiers, bundle, payload.get("resultInfoPlist"), payload.get("rawLog"),
        )

    parsed = _schema(rejected, f"{label} test", parse)
    if parsed is None:
        return None
    observed_lane, observed_target, exit_code, executed, result_id, identifiers, bundle, info_ref, log_ref = parsed
    if observed_lane != lane:
        _append(rejected, f"{label} test artifact lane is invalid")
    if observed_target != target:
        _append(rejected, f"{label} test target does not match graph")
    if exit_code != 0:
        _append(rejected, f"{label} test proof did not pass")
    if executed == 0:
        _append(rejected, f"{label} test proof executed zero tests")
    bundle_path = root / bundle
    try:
        bundle_path.resolve().relative_to(root.resolve())
    except ValueError:
        _append(rejected, f"{label} test result bundle is outside the repository root")
        return result_id, set(identifiers)
    if not bundle_path.is_dir():
        _append(observed, f"{label} test result bundle is missing")
    for reference in (info_ref, log_ref):
        if isinstance(reference, dict) and isinstance(reference.get("path"), str) and _sha(reference.get("sha256")):
            fingerprints[reference["path"]] = reference["sha256"]
    expected_info = str(PurePosixPath(bundle) / "Info.plist")
    if not isinstance(info_ref, dict) or info_ref.get("path") != expected_info:
        _append(rejected, f"{label} test result Info.plist reference is invalid")
        info = None
    else:
        info = _reference_bytes(root, f"{label} test result Info.plist", info_ref, observed, rejected)
    log = _reference_bytes(root, f"{label} test raw log", log_ref, observed, rejected)
    if info is not None:
        try:
            info_payload = plistlib.loads(info)
        except (plistlib.InvalidFileException, ValueError) as error:
            _append(rejected, f"{label} test result Info.plist is invalid: {error}")
        else:
            root_id = info_payload.get("rootId") if isinstance(info_payload, dict) else None
            if not isinstance(root_id, dict) or root_id.get("hash") != result_id:
                _append(rejected, f"{label} test result identity does not match Info.plist")
    if log is not None:
        try:
            transcript = log.decode("utf-8")
        except UnicodeDecodeError:
            _append(rejected, f"{label} test raw log is not UTF-8")
        else:
            matches = re.findall(r"Executed (\d+) tests?, with (\d+) failures?", transcript)
            logged_identifiers = re.findall(r"Test Case '([^']+)' passed", transcript)
            if len(matches) != 1:
                _append(rejected, f"{label} test raw log lacks one execution summary")
            else:
                logged_count, failures = map(int, matches[0])
                if logged_count != executed:
                    _append(rejected, f"{label} test executed count does not match raw log")
                if failures != 0:
                    _append(rejected, f"{label} test raw log reports failures")
            if logged_identifiers != identifiers:
                _append(rejected, f"{label} test identifiers do not match raw log")
            if len(identifiers) != executed:
                _append(rejected, f"{label} test identifier count does not match executed count")
    return result_id, set(identifiers)


def _reference_map(artifacts: dict[str, Any]) -> dict[str, str]:
    references: list[Any] = [artifacts.get(key) for key in (
        "history", "compiler", "graph", "publicAPI", "routes", "moduleTests", "integrationTests",
    )]
    benchmarks = artifacts.get("benchmarks")
    if isinstance(benchmarks, dict):
        for cohort in BENCHMARK_COHORTS:
            rows = benchmarks.get(cohort)
            if isinstance(rows, list):
                references.extend(rows)
    result = {}
    for reference in references:
        if isinstance(reference, dict) and isinstance(reference.get("path"), str) and _sha(reference.get("sha256")):
            result[reference["path"]] = reference["sha256"]
    return result


def _evaluate_review(
    payload: dict[str, Any] | None,
    fingerprints_expected: dict[str, str],
    allow_extra_fingerprints: bool,
    rejected: list[str],
) -> None:
    if payload is None:
        return

    def parse():
        author, reviewer, status = payload.get("author"), payload.get("reviewer"), payload.get("status")
        if any(not isinstance(value, str) or not value for value in (author, reviewer, status)):
            raise EvidenceFormatError("review author, reviewer, and status must be nonempty")
        critical = _strings(payload.get("criticalFindings"), "review criticalFindings")
        important = _strings(payload.get("importantFindings"), "review importantFindings")
        fingerprints = _mapping(payload.get("reviewedArtifacts"), "review reviewedArtifacts")
        if any(not isinstance(path, str) or not path or not _sha(digest) for path, digest in fingerprints.items()):
            raise EvidenceFormatError("reviewedArtifacts must map paths to SHA-256 digests")
        return author, reviewer, status, critical, important, fingerprints

    parsed = _schema(rejected, "independent review", parse)
    if parsed is None:
        return
    author, reviewer, status, critical, important, fingerprints = parsed
    if author == reviewer:
        _append(rejected, "independent review author and reviewer must differ")
    if status != "approved":
        _append(rejected, "independent review is not approved")
    if critical or important:
        _append(rejected, "independent review retains blocking findings")
    fingerprints_match = (
        all(fingerprints.get(path) == digest for path, digest in fingerprints_expected.items())
        if allow_extra_fingerprints
        else fingerprints == fingerprints_expected
    )
    if not fingerprints_match:
        _append(rejected, "independent review artifact fingerprints do not match candidate evidence")


def _linked_json(
    root: Path,
    label: str,
    reference: Any,
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> dict[str, Any] | None:
    _remember_reference(reference, fingerprints)
    contents = _reference_bytes(root, label, reference, observed, rejected)
    if contents is None:
        return None
    try:
        return _mapping(_json_loads(contents), label)
    except (json.JSONDecodeError, UnicodeDecodeError, EvidenceFormatError) as error:
        _append(rejected, f"{label} artifact schema is invalid: {error}")
        return None


def _benchmark_test_result(
    root: Path,
    result: dict[str, Any],
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> tuple[str, str] | None:
    try:
        if result.get("result_kind") != "focused-test":
            raise EvidenceFormatError("benchmark test result kind is invalid")
        exit_code = _number(result.get("exit_code"), "benchmark test exit_code", integer=True)
        executed = _number(result.get("executed_tests"), "benchmark test executed_tests", integer=True)
        identifiers = _strings(result.get("executed_test_identifiers"), "benchmark executed test identifiers", nonempty=True)
        result_id, simulator, bundle = result.get("result_id"), result.get("simulator_udid"), result.get("result_bundle_path")
        if any(not isinstance(value, str) or not value for value in (result_id, simulator, bundle)):
            raise EvidenceFormatError("benchmark test result identities must be nonempty")
    except EvidenceFormatError as error:
        _append(rejected, f"benchmark test result artifact schema is invalid: {error}")
        return None
    if exit_code != 0:
        _append(rejected, "benchmark test result did not pass")
    if executed == 0:
        _append(rejected, "benchmark test result executed zero tests")
    if len(identifiers) != executed or len(set(identifiers)) != len(identifiers):
        _append(rejected, "benchmark test identifiers do not match executed count")
    bundle_path = root / bundle
    try:
        bundle_path.resolve().relative_to(root.resolve())
    except ValueError:
        _append(rejected, "benchmark test result bundle is outside repository")
    if not bundle_path.is_dir():
        _append(observed, "benchmark test result bundle is missing")
    info_ref, log_ref = result.get("result_info_plist"), result.get("raw_log")
    _remember_reference(info_ref, fingerprints)
    _remember_reference(log_ref, fingerprints)
    if not isinstance(info_ref, dict) or info_ref.get("path") != str(PurePosixPath(bundle) / "Info.plist"):
        _append(rejected, "benchmark test result Info.plist reference is invalid")
        info = None
    else:
        info = _reference_bytes(root, "benchmark test result Info.plist", info_ref, observed, rejected)
    log = _reference_bytes(root, "benchmark test raw log", log_ref, observed, rejected)
    if info is not None:
        try:
            root_id = _mapping(plistlib.loads(info).get("rootId"), "benchmark result rootId")
        except (plistlib.InvalidFileException, ValueError, AttributeError, EvidenceFormatError) as error:
            _append(rejected, f"benchmark test result Info.plist is invalid: {error}")
        else:
            if root_id.get("hash") != result_id:
                _append(rejected, "benchmark test result identity does not match Info.plist")
    if log is not None:
        try:
            transcript = log.decode("utf-8")
        except UnicodeDecodeError:
            _append(rejected, "benchmark test raw log is not UTF-8")
        else:
            summary = re.findall(r"Executed (\d+) tests?, with (\d+) failures?", transcript)
            logged = re.findall(r"Test Case '([^']+)' passed", transcript)
            if summary != [(str(executed), "0")] or logged != identifiers:
                _append(rejected, "benchmark test result does not match raw log")
    return result_id, simulator


def _benchmark_build_result(
    root: Path,
    result: dict[str, Any],
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> bool:
    try:
        exit_code = _number(result.get("exit_code"), "benchmark build exit_code", integer=True)
    except EvidenceFormatError as error:
        _append(rejected, f"benchmark build result artifact schema is invalid: {error}")
        return False
    if result.get("result_kind") != "build-for-testing" or exit_code != 0 or result.get("build_succeeded") is not True:
        _append(rejected, "benchmark build result did not succeed")
    log_ref = result.get("raw_log")
    _remember_reference(log_ref, fingerprints)
    log = _reference_bytes(root, "benchmark build raw log", log_ref, observed, rejected)
    if log is not None and b"** BUILD SUCCEEDED **" not in log:
        _append(rejected, "benchmark build raw log lacks success marker")
    return True


def _evaluate_benchmarks(
    root: Path,
    raw: Any,
    thresholds: dict[str, Any],
    loader,
    context: GitContext,
    fingerprints: dict[str, str],
    observed: list[str],
    rejected: list[str],
) -> None:
    if raw is None:
        _append(observed, "benchmark evidence is missing")
        return
    try:
        cohorts_raw = _mapping(raw, "benchmark artifacts")
    except EvidenceFormatError as error:
        _append(rejected, f"benchmark artifact schema is invalid: {error}")
        return
    parsed: dict[str, list[dict[str, Any]]] = {}
    valid = True
    identities: list[str] = []
    result_ids: list[str] = []
    comparable, simulators, baseline_commits = set(), set(), set()
    for cohort in BENCHMARK_COHORTS:
        refs = cohorts_raw.get(cohort)
        if not isinstance(refs, list):
            _append(rejected, f"benchmark cohort {cohort} references must be an array")
            valid = False
            continue
        if len(refs) != thresholds["benchmarkSamplesPerCohort"]:
            _append(observed, f"benchmark cohort {cohort} does not have the policy sample count")
            valid = False
        samples, stable = [], set()
        for ref in refs:
            wrapper = loader("benchmark sample", ref, "benchmark-sample")
            if wrapper is None:
                valid = False
                continue
            if wrapper.get("cohort") != cohort:
                _append(rejected, f"benchmark sample cohort does not match {cohort}")
                valid = False
            summary = _linked_json(root, "benchmark raw summary", wrapper.get("benchmarkSummary"), fingerprints, observed, rejected)
            result = _linked_json(root, "benchmark result summary", wrapper.get("resultSummary"), fingerprints, observed, rejected)
            result_proof = None
            if summary is not None and result is not None and (
                result.get("benchmark_execution_id") != summary.get("timestamp_utc")
                or result.get("benchmark_commit") != summary.get("commit")
                or result.get("cohort") != cohort
            ):
                _append(rejected, "benchmark result summary does not bind its raw execution")
                valid = False
            if result is not None and cohort in TEST_BENCHMARK_COHORTS:
                result_proof = _benchmark_test_result(root, result, fingerprints, observed, rejected)
                if result_proof is None:
                    valid = False
                else:
                    result_ids.append(result_proof[0])
                    simulators.add(result_proof[1])
            elif result is not None and not _benchmark_build_result(root, result, fingerprints, observed, rejected):
                valid = False
            if summary is None or result is None:
                valid = False
                continue
            try:
                execution = summary.get("timestamp_utc")
                package, xcode = summary.get("package_identity"), summary.get("xcode_version")
                macos, cpu = summary.get("macos_version"), summary.get("cpu")
                lane, scenario, command = summary.get("lane"), summary.get("scenario"), summary.get("command")
                if any(not isinstance(value, str) or not value for value in (execution, package, xcode, macos, cpu, lane, scenario, command)):
                    raise EvidenceFormatError("benchmark identity fields must be nonempty strings")
                exit_code = _number(summary.get("exit_code"), "benchmark exit_code", integer=True)
                duration = float(_number(summary.get("duration_seconds"), "benchmark duration_seconds"))
            except EvidenceFormatError as error:
                _append(rejected, f"benchmark raw summary artifact schema is invalid: {error}")
                valid = False
                continue
            identities.append(execution)
            comparable.add((package, xcode, macos, cpu))
            stable.add((lane, scenario, command))
            commit = summary.get("commit")
            if not _commit(commit):
                _append(rejected, "benchmark commit must be a full live Git SHA")
                valid = False
            elif cohort.endswith("Baseline"):
                if _git(root, "merge-base", "--is-ancestor", commit, context.head) is None:
                    _append(rejected, "benchmark baseline commit is not a live Git ancestor")
                    valid = False
                baseline_commits.add(commit)
            elif commit != context.head:
                _append(rejected, "benchmark commit does not match live Git HEAD")
                valid = False
            if summary.get("warm_cold") != "warm":
                _append(rejected, "benchmark sample is not warm-cache evidence")
                valid = False
            derived_raw = summary.get("derived_data")
            if not isinstance(derived_raw, str) or not derived_raw:
                canonical_derived = False
            else:
                derived_path = Path(derived_raw)
                resolved_derived = (derived_path if derived_path.is_absolute() else root / derived_path).resolve()
                canonical_derived = resolved_derived == (root / ".codex/DerivedData/Ambitions").resolve()
            if not canonical_derived:
                _append(rejected, "benchmark sample uses noncanonical DerivedData")
                valid = False
            if exit_code != 0:
                _append(rejected, "benchmark sample is not a successful run")
                valid = False
            if duration <= 0:
                _append(rejected, "benchmark duration must be positive")
                valid = False
            summary["_duration"] = duration
            samples.append(summary)
        if len(stable) > 1:
            _append(rejected, f"benchmark cohort {cohort} mixes command, lane, or scenario")
            valid = False
        parsed[cohort] = samples
    if len(set(identities)) != len(identities):
        _append(rejected, "benchmark samples contain replayed execution identifiers")
        valid = False
    if len(set(result_ids)) != len(result_ids):
        _append(rejected, "benchmark test samples contain replayed result identifiers")
        valid = False
    if len(comparable) != 1:
        _append(rejected, "benchmark samples do not share one comparable environment identity")
        valid = False
    if len(simulators) != 1:
        _append(rejected, "benchmark test samples do not share one simulator identity")
        valid = False
    if len(baseline_commits) != 1:
        _append(rejected, "benchmark baseline cohorts do not share one commit identity")
        valid = False
    if not valid or any(len(parsed.get(cohort, [])) != thresholds["benchmarkSamplesPerCohort"] for cohort in BENCHMARK_COHORTS):
        return
    durations = {cohort: [sample["_duration"] for sample in parsed[cohort]] for cohort in BENCHMARK_COHORTS}
    module = statistics.median(durations["moduleTest"])
    candidate = statistics.median(durations["leafProofCandidate"])
    baseline = statistics.median(durations["leafProofHostedBaseline"])
    if module > thresholds["moduleTestMedianMaximumSeconds"]:
        _append(rejected, "module test median exceeds policy maximum")
    if candidate > thresholds["leafProofMedianMaximumSeconds"]:
        _append(rejected, "leaf proof median exceeds policy maximum")
    if candidate > baseline * (1.0 - thresholds["leafProofMinimumHostedImprovementFraction"]):
        _append(rejected, "leaf proof median lacks the required hosted improvement")
    if max(durations["leafProofCandidate"]) > max(durations["leafProofHostedBaseline"]) * thresholds["candidateWorstMaximumHostedRatio"]:
        _append(rejected, "candidate leaf proof worst sample is worse than hosted baseline")
    ratio = 1.0 + thresholds["appNoChangeMaximumRegressionFraction"]
    app_candidate, app_baseline = durations["appNoChangeCandidate"], durations["appNoChangeBaseline"]
    if statistics.median(app_candidate) > statistics.median(app_baseline) * ratio:
        _append(rejected, "app no-change median regression exceeds policy maximum")
    if max(app_candidate) > max(app_baseline) * ratio:
        _append(rejected, "app no-change worst regression exceeds policy maximum")


def _validate_supporting(root: Path, raw: Any, observed: list[str], rejected: list[str]) -> None:
    if raw is None:
        return
    for reference in _list(raw, "supportingEvidence"):
        _reference_bytes(root, "supporting evidence", reference, observed, rejected, missing_is_observed=False)


def evaluate_candidate(root: Path, thresholds: dict[str, Any], candidate: dict[str, Any]) -> CandidateResult:
    candidate = _mapping(candidate, "candidate")
    candidate_id, declared, target = candidate.get("id"), candidate.get("status"), candidate.get("proposedTarget")
    if not isinstance(candidate_id, str) or not candidate_id:
        raise EvidenceFormatError("candidate id must be nonempty")
    if not isinstance(declared, str) or declared not in ALLOWED_STATUSES:
        raise EvidenceFormatError(f"candidate {candidate_id} has invalid status")
    if target is not None and (not isinstance(target, str) or TARGET_PATTERN.fullmatch(target) is None):
        raise EvidenceFormatError(f"candidate {candidate_id} proposedTarget must be a valid Swift target identifier")
    prospective = candidate.get("prospectiveGateEvidence")
    if type(prospective) is not bool:
        raise EvidenceFormatError(f"candidate {candidate_id} prospectiveGateEvidence must be a boolean")
    observed: list[str] = []
    rejected: list[str] = []
    source_raw = candidate.get("sourceSet")
    if source_raw is None:
        return CandidateResult(candidate_id, declared, "rejected", ("explicit source set is missing",), target)
    source = _mapping(source_raw, "sourceSet")
    files = _strings(source.get("files"), "sourceSet files")
    if not files:
        return CandidateResult(candidate_id, declared, "rejected", ("source set is empty",), target)
    if source.get("selection") != "explicit_files":
        _append(rejected, "source set is folder-derived rather than explicit")
    if len(set(files)) != len(files):
        _append(rejected, "source set contains duplicate paths")
    readable = True
    for relative in files:
        if not _canonical_source_path(relative):
            readable = False
            _append(rejected, f"noncanonical source path: {relative}")
        elif _repository_file(root, relative) is None:
            readable = False
            if (root / relative).is_symlink() or (root / relative).exists():
                _append(rejected, "source path is a symlink or resolves outside repository")
            else:
                _append(rejected, f"source file is missing: {relative}")
    source_hash = source.get("contentHash")
    current_source = readable and _sha(source_hash) and source_set_hash(root, files) == source_hash
    if not _sha(source_hash):
        _append(observed, "source content hash is missing")
    elif readable and not current_source:
        _append(observed, "source content hash is stale")
    if not prospective:
        _append(observed, "candidate predates or lacks prospective gate evidence")
    disqualifiers = candidate.get("affirmativeDisqualifiers", [])
    if (
        not isinstance(disqualifiers, list)
        or any(not isinstance(item, str) for item in disqualifiers)
        or any(item not in DISQUALIFIER_FINDINGS for item in disqualifiers)
    ):
        raise EvidenceFormatError(f"candidate {candidate_id} has invalid affirmativeDisqualifiers")
    for item in disqualifiers:
        _append(rejected, DISQUALIFIER_FINDINGS[item])
    _validate_supporting(root, candidate.get("supportingEvidence"), observed, rejected)
    if prospective and target is None:
        _append(observed, "prospective candidate has no proposed target")
    if prospective and target is not None and current_source and len(set(files)) == len(files):
        tracked_status = _git(root, "status", "--porcelain", "--untracked-files=no")
        context = None if tracked_status else _git_context(root, thresholds["historyMaximumFirstParentCommits"])
        if tracked_status:
            _append(rejected, "authorization requires a clean tracked worktree")
        elif context is None:
            _append(rejected, "authorization requires the supplied root to be a Git repository root")
        else:
            artifacts_raw = candidate.get("artifacts")
            if artifacts_raw is None:
                _append(observed, "authorization artifact references are missing")
            else:
                artifacts = _mapping(artifacts_raw, "artifacts")
                identity = candidate_identity(candidate_id, target, files, source_hash, context.head, context.authority_hashes)

                def load(label: str, reference: Any, kind: str):
                    return _load_artifact(
                        root, label, reference, kind, identity, candidate_id, target, files,
                        source_hash, context, observed, rejected,
                    )

                history = load("history", artifacts.get("history"), "history")
                compiler = load("compiler", artifacts.get("compiler"), "compiler")
                graph_payload = load("graph", artifacts.get("graph"), "graph")
                api = load("public API", artifacts.get("publicAPI"), "public-api")
                routes = load("routes", artifacts.get("routes"), "routes")
                module_tests = load("module test", artifacts.get("moduleTests"), "test-result")
                integration_tests = load("integration test", artifacts.get("integrationTests"), "test-result")
                fingerprints = _reference_map(artifacts)
                _evaluate_history(history, context, thresholds, files, rejected)
                graph = _parse_graph(graph_payload, target, files, rejected) if graph_payload else None
                _evaluate_compiler(root, compiler, target, files, graph, fingerprints, observed, rejected)
                _evaluate_public_api(api, root, target, graph, fingerprints, observed, rejected)
                module_proof = _parse_test(
                    root, module_tests, "module", "module",
                    graph["moduleTestTarget"] if graph else None,
                    fingerprints, observed, rejected,
                )
                integration_proof = _parse_test(
                    root, integration_tests, "integration", "hosted-integration",
                    graph["integrationTestTarget"] if graph else None,
                    fingerprints, observed, rejected,
                )
                module_ids = module_proof[1] if module_proof else set()
                integration_ids = integration_proof[1] if integration_proof else set()
                _evaluate_routes(routes, files, module_ids, integration_ids, rejected)
                if module_proof is not None and integration_proof is not None and module_proof[0] == integration_proof[0]:
                    _append(rejected, "test result identities are replayed")
                _evaluate_benchmarks(
                    root, artifacts.get("benchmarks"), thresholds, load, context,
                    fingerprints, observed, rejected,
                )
                review = load("independent review", artifacts.get("review"), "review")
                _evaluate_review(review, fingerprints, bool(observed), rejected)
    status = "rejected" if rejected else "observed" if observed else "authorized"
    return CandidateResult(candidate_id, declared, status, tuple(rejected + observed), target)


def _validate_thresholds(raw: Any) -> dict[str, Any]:
    thresholds = _mapping(raw, "thresholds")
    if set(thresholds) != THRESHOLD_KEYS:
        raise EvidenceFormatError(
            f"threshold keys differ; missing={sorted(THRESHOLD_KEYS - set(thresholds))} "
            f"extra={sorted(set(thresholds) - THRESHOLD_KEYS)}"
        )
    for key in THRESHOLD_KEYS:
        integer = key in {"historyMaximumFirstParentCommits", "historyMinimumFirstParentCommits", "benchmarkSamplesPerCohort"}
        _number(thresholds[key], f"threshold {key}", integer=integer)
    percentile = thresholds["productionHighChurnPercentile"]
    fractions = (thresholds["leafProofMinimumHostedImprovementFraction"], thresholds["appNoChangeMaximumRegressionFraction"])
    if not 0 < percentile < 1 or any(not 0 <= value < 1 for value in fractions):
        raise EvidenceFormatError("policy percentile and fraction thresholds are out of range")
    if thresholds["historyMinimumFirstParentCommits"] > thresholds["historyMaximumFirstParentCommits"]:
        raise EvidenceFormatError("history minimum exceeds history maximum")
    if thresholds["benchmarkSamplesPerCohort"] <= 0 or thresholds["candidateWorstMaximumHostedRatio"] <= 0:
        raise EvidenceFormatError("sample count and worst-sample ratio must be positive")
    return thresholds


def evaluate_policy(root: Path, policy: dict[str, Any]) -> PolicyResult:
    policy = _mapping(policy, "policy")
    if type(policy.get("schemaVersion")) is not int or policy["schemaVersion"] != 1:
        raise EvidenceFormatError("unsupported policy schemaVersion")
    thresholds = _validate_thresholds(policy.get("thresholds"))
    candidates_raw = _list(policy.get("candidates"), "candidates")
    declared_targets = _strings(policy.get("authorizedFutureTargets"), "authorizedFutureTargets")
    if len(set(declared_targets)) != len(declared_targets):
        raise EvidenceFormatError("authorizedFutureTargets contains duplicates")
    if any(TARGET_PATTERN.fullmatch(target) is None for target in declared_targets):
        raise EvidenceFormatError("authorizedFutureTargets contains an invalid target identifier")
    proposed = [candidate.get("proposedTarget") for candidate in candidates_raw if isinstance(candidate, dict) and candidate.get("proposedTarget") is not None]
    if any(not isinstance(target, str) or TARGET_PATTERN.fullmatch(target) is None for target in proposed):
        raise EvidenceFormatError("candidate proposedTarget must be a valid Swift target identifier")
    if len(set(proposed)) != len(proposed):
        raise EvidenceFormatError("candidate proposedTarget values must be unique")
    results = tuple(evaluate_candidate(root, thresholds, candidate) for candidate in candidates_raw)
    ids = [result.candidate_id for result in results]
    if len(set(ids)) != len(ids):
        raise EvidenceFormatError("candidate ids must be unique")
    findings: list[str] = []
    authorized = []
    for result in results:
        if result.declared_status != result.status:
            findings.append(f"candidate {result.candidate_id} declares {result.declared_status} but evaluates {result.status}")
        if any(finding.startswith("supporting evidence artifact") for finding in result.findings):
            findings.append(f"candidate {result.candidate_id} has invalid supporting evidence")
        if result.status == "authorized" and result.proposed_target:
            authorized.append(result.proposed_target)
        elif result.status == "authorized":
            findings.append(f"authorized candidate {result.candidate_id} lacks a proposedTarget")
        elif result.proposed_target:
            findings.append(f"non-authorized candidate {result.candidate_id} claims proposed target {result.proposed_target}")
    authorized_tuple = tuple(sorted(authorized))
    if tuple(sorted(declared_targets)) != authorized_tuple:
        findings.append("authorizedFutureTargets does not equal the evaluated authorized target set")
    return PolicyResult(not findings, results, authorized_tuple, tuple(findings))


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--policy", required=True, type=Path)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--json", action="store_true", dest="as_json")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        payload = _json_loads(args.policy.read_text(encoding="utf-8"))
        result = evaluate_policy(args.root.resolve(), payload)
    except (OSError, json.JSONDecodeError, EvidenceFormatError) as error:
        response = {"status": "malformed", "error": str(error)}
        print(json.dumps(response, indent=2, sort_keys=True) if args.as_json else f"MALFORMED {error}")
        return 2
    response = {
        "status": "pass" if result.ok else "fail",
        "authorizedFutureTargets": list(result.authorized_targets),
        "candidates": [
            {
                "id": row.candidate_id, "declaredStatus": row.declared_status,
                "evaluatedStatus": row.status, "findings": list(row.findings),
            }
            for row in result.candidates
        ],
        "findings": list(result.findings),
    }
    if args.as_json:
        print(json.dumps(response, indent=2, sort_keys=True))
    else:
        print(f"MODULE_CANDIDATE_POLICY={'PASS' if result.ok else 'FAIL'}")
        for row in result.candidates:
            print(f"{row.candidate_id}: {row.status}")
            for finding in row.findings:
                print(f"  {finding}")
        for finding in result.findings:
            print(f"finding: {finding}")
    return 0 if result.ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
