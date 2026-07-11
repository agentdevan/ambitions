#!/usr/bin/env python3
"""Fail-closed authorization gate for prospective Ambitions build modules."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import statistics
import sys
from pathlib import Path, PurePosixPath
from typing import Any, NamedTuple


ALLOWED_STATUSES = {"observed", "rejected", "authorized"}
CANONICAL_OWNERS = {
    "App", "Stage", "Core", "Projection", "Language", "Trust",
    "Interaction", "Rendering", "DesignSystem", "Surfaces", "Composer",
    "Scenarios", "Diagnostics", "Quality",
}
THRESHOLD_KEYS = {
    "historyMaximumFirstParentCommits",
    "historyMinimumFirstParentCommits",
    "productionHighChurnPercentile",
    "benchmarkSamplesPerCohort",
    "moduleTestMedianMaximumSeconds",
    "leafProofMedianMaximumSeconds",
    "leafProofMinimumHostedImprovementFraction",
    "candidateWorstMaximumHostedRatio",
    "appNoChangeMaximumRegressionFraction",
}
BENCHMARK_COHORTS = (
    "moduleTest",
    "leafProofCandidate",
    "leafProofHostedBaseline",
    "appNoChangeCandidate",
    "appNoChangeBaseline",
)
IDENTITY_FIELDS = (
    "commit", "sourceContentHash", "packageIdentity", "derivedDataPath", "cacheState",
)
SAMPLE_STABILITY_FIELDS = ("lane", "scenario", "command")
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


def _mapping(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise EvidenceFormatError(f"{label} must be an object")
    return value


def _list(value: Any, label: str) -> list[Any]:
    if not isinstance(value, list):
        raise EvidenceFormatError(f"{label} must be an array")
    return value


def _number(value: Any, label: str, *, integer: bool = False) -> float | int:
    valid = isinstance(value, int) and not isinstance(value, bool) if integer else isinstance(value, (int, float)) and not isinstance(value, bool)
    if not valid or value < 0 or (not integer and not math.isfinite(float(value))):
        raise EvidenceFormatError(f"{label} must be a nonnegative {'integer' if integer else 'number'}")
    return value


def _sha(value: Any) -> bool:
    return isinstance(value, str) and len(value) == 71 and value.startswith("sha256:") and all(character in "0123456789abcdef" for character in value[7:])


def _commit(value: Any) -> bool:
    return isinstance(value, str) and len(value) == 40 and all(character in "0123456789abcdef" for character in value)


def evidence_digest(payload: dict[str, Any]) -> str:
    normalized = {key: value for key, value in payload.items() if key != "evidenceDigest"}
    encoded = json.dumps(normalized, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()
    return "sha256:" + hashlib.sha256(encoded).hexdigest()


def source_set_hash(root: Path, paths: list[str]) -> str:
    digest = hashlib.sha256()
    for relative in sorted(paths):
        path = root / relative
        digest.update(relative.encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return "sha256:" + digest.hexdigest()


def _canonical_source_path(relative: str) -> bool:
    path = PurePosixPath(relative)
    return (
        not path.is_absolute()
        and ".." not in path.parts
        and len(path.parts) >= 4
        and path.parts[:2] == ("Native", "Ambitions")
        and path.parts[2] in CANONICAL_OWNERS
        and path.suffix == ".swift"
    )


def _append_unique(destination: list[str], finding: str) -> None:
    if finding not in destination:
        destination.append(finding)


def _bound_evidence(
    root: Path,
    label: str,
    payload: dict[str, Any] | None,
    source_hash: str,
    observed: list[str],
    rejected: list[str],
    *,
    require_artifact: bool = True,
) -> bool:
    if payload is None:
        _append_unique(observed, f"{label} evidence is missing")
        return False
    digest = payload.get("evidenceDigest")
    if not _sha(digest):
        _append_unique(observed, f"{label} evidence digest is missing")
        return False
    if digest != evidence_digest(payload):
        _append_unique(rejected, f"{label} evidence digest is invalid")
        return False
    if payload.get("sourceContentHash") != source_hash:
        _append_unique(observed, f"{label} evidence is stale for the source set")
        return False
    if require_artifact:
        artifact = payload.get("artifact")
        artifact_digest = payload.get("artifactDigest")
        if not isinstance(artifact, str) or not artifact or not _sha(artifact_digest):
            _append_unique(observed, f"{label} artifact identity is incomplete")
            return False
        artifact_path = root / artifact
        try:
            artifact_path.resolve().relative_to(root.resolve())
        except ValueError:
            _append_unique(rejected, f"{label} artifact is outside the repository root")
            return False
        if not artifact_path.is_file():
            _append_unique(rejected, f"{label} artifact is missing")
            return False
        actual_digest = "sha256:" + hashlib.sha256(artifact_path.read_bytes()).hexdigest()
        if actual_digest != artifact_digest:
            _append_unique(rejected, f"{label} artifact digest does not match file")
            return False
    return True


def _top_cohort_median(values: list[float], percentile: float) -> float:
    count = max(1, math.ceil(len(values) * (1.0 - percentile)))
    return float(statistics.median(sorted(values, reverse=True)[:count]))


def _evaluate_history(
    root: Path,
    candidate: dict[str, Any],
    thresholds: dict[str, Any],
    source_files: list[str],
    source_hash: str,
    observed: list[str],
    rejected: list[str],
) -> None:
    raw = candidate.get("history")
    if raw is None:
        _append_unique(observed, "pre-extraction history evidence is missing")
        return
    history = _mapping(raw, "candidate history")
    if not _bound_evidence(root, "history", history, source_hash, observed, rejected):
        return
    commits = _list(history.get("firstParentCommits"), "history firstParentCommits")
    if any(not _commit(commit) for commit in commits):
        raise EvidenceFormatError("history firstParentCommits must contain full lowercase commit SHAs")
    available = int(_number(history.get("availableFirstParentCommits"), "history availableFirstParentCommits", integer=True))
    window_count = int(_number(history.get("windowCommitCount"), "history windowCommitCount", integer=True))
    minimum = thresholds["historyMinimumFirstParentCommits"]
    maximum = thresholds["historyMaximumFirstParentCommits"]
    if available < minimum or len(commits) < minimum:
        _append_unique(rejected, "first-parent history has fewer commits than policy minimum")
    if len(commits) > maximum:
        _append_unique(rejected, "first-parent history exceeds policy maximum")
    expected = min(available, maximum)
    if len(commits) != expected or window_count != len(commits):
        _append_unique(observed, "first-parent history window is incomplete")
    if len(set(commits)) != len(commits):
        _append_unique(rejected, "first-parent history window contains duplicate commits")
    if commits and history.get("preExtractionHead") != commits[0]:
        _append_unique(rejected, "pre-extraction head does not anchor the first-parent history window")
    extraction = history.get("extractionCommit")
    if extraction is not None and not _commit(extraction):
        raise EvidenceFormatError("history extractionCommit must be a full lowercase commit SHA")
    if extraction in commits:
        _append_unique(rejected, "extraction commit is included in the pre-extraction history window")

    touches = _mapping(history.get("candidateFileTouches"), "history candidateFileTouches")
    if set(touches) != set(source_files):
        _append_unique(observed, "candidate touch evidence does not cover the exact source set")
        return
    candidate_values = [float(_number(touches[path], f"touch count for {path}", integer=True)) for path in source_files]
    production_raw = _list(history.get("productionFileTouches"), "history productionFileTouches")
    if not production_raw:
        _append_unique(observed, "production churn cohort is missing")
        return
    production = [float(_number(value, "production file touch count", integer=True)) for value in production_raw]
    candidate_median = float(statistics.median(candidate_values))
    cohort_median = _top_cohort_median(production, thresholds["productionHighChurnPercentile"])
    if candidate_median < cohort_median:
        _append_unique(rejected, "candidate median file touches are below the production high-churn cohort")


def _evaluate_proof_surfaces(
    root: Path,
    candidate: dict[str, Any],
    source_files: list[str],
    source_hash: str,
    observed: list[str],
    rejected: list[str],
) -> None:
    compiler_raw = candidate.get("compilerClosure")
    compiler = _mapping(compiler_raw, "compilerClosure") if compiler_raw is not None else None
    compiler_bound = _bound_evidence(root, "compiler closure", compiler, source_hash, observed, rejected)
    if compiler_bound:
        if compiler.get("kind") != "compiler_build":
            _append_unique(rejected, "compiler closure uses non-compiler evidence")
        if compiler.get("status") != "passed":
            _append_unique(rejected, "compiler closure did not pass")

    graph_raw = candidate.get("graph")
    graph = _mapping(graph_raw, "graph") if graph_raw is not None else None
    graph_bound = _bound_evidence(root, "graph", graph, source_hash, observed, rejected)
    if graph_bound:
        checks = (
            (not graph.get("acyclic"), "candidate target graph contains a cycle"),
            (not graph.get("singleProductionMembership"), "candidate source lacks single production membership"),
            (not graph.get("hostlessModuleTests"), "module tests are not hostless"),
            (bool(graph.get("appReachableFromModuleTests")), "module tests can reach the app target"),
        )
        for failed, finding in checks:
            if failed:
                _append_unique(rejected, finding)

    api_raw = candidate.get("publicAPI")
    api = _mapping(api_raw, "publicAPI") if api_raw is not None else None
    api_bound = _bound_evidence(root, "public API", api, source_hash, observed, rejected)
    if api_bound:
        approved = int(_number(api.get("approvedContractCount"), "approvedContractCount", integer=True))
        compiler_count = int(_number(api.get("compilerPublicDeclarationCount"), "compilerPublicDeclarationCount", integer=True))
        unapproved = int(_number(api.get("unapprovedContractCount"), "unapprovedContractCount", integer=True))
        if api.get("status") != "approved" or unapproved != 0 or approved != compiler_count:
            _append_unique(rejected, "compiler-public API is not exactly covered by approved contracts")

    routes_raw = candidate.get("changedFileRoutes")
    routes = _mapping(routes_raw, "changedFileRoutes") if routes_raw is not None else None
    routes_bound = _bound_evidence(root, "changed-file routes", routes, source_hash, observed, rejected)
    if routes_bound:
        covered = _list(routes.get("coveredSourceFiles"), "changed-file route coveredSourceFiles")
        unrouted = int(_number(routes.get("unroutedFileCount"), "unroutedFileCount", integer=True))
        if routes.get("status") != "complete" or unrouted != 0 or covered != source_files:
            _append_unique(rejected, "changed-file routes do not cover the complete source set")

    tests_raw = candidate.get("tests")
    if tests_raw is None:
        _append_unique(observed, "test evidence is missing")
    else:
        tests = _mapping(tests_raw, "tests")
        for lane in ("module", "integration"):
            lane_raw = tests.get(lane)
            lane_evidence = _mapping(lane_raw, f"tests {lane}") if lane_raw is not None else None
            if _bound_evidence(root, f"{lane} test proof", lane_evidence, source_hash, observed, rejected):
                executed = int(_number(lane_evidence.get("executed"), f"{lane} executed tests", integer=True))
                if lane_evidence.get("status") != "passed":
                    _append_unique(rejected, f"{lane} test proof did not pass")
                if executed == 0:
                    _append_unique(rejected, f"{lane} test proof executed zero tests")

    review_raw = candidate.get("review")
    review = _mapping(review_raw, "review") if review_raw is not None else None
    if _bound_evidence(root, "independent review", review, source_hash, observed, rejected):
        critical = int(_number(review.get("criticalFindings"), "criticalFindings", integer=True))
        important = int(_number(review.get("importantFindings"), "importantFindings", integer=True))
        if review.get("status") != "approved" or critical or important:
            _append_unique(rejected, "independent review retains blocking findings")


def _evaluate_benchmarks(
    root: Path,
    candidate: dict[str, Any],
    thresholds: dict[str, Any],
    source_hash: str,
    observed: list[str],
    rejected: list[str],
) -> None:
    raw = candidate.get("benchmarks")
    if raw is None:
        _append_unique(observed, "benchmark evidence is missing")
        return
    benchmarks = _mapping(raw, "benchmarks")
    count = thresholds["benchmarkSamplesPerCohort"]
    cohorts: dict[str, list[dict[str, Any]]] = {}
    complete = True
    for name in BENCHMARK_COHORTS:
        samples = _list(benchmarks.get(name), f"benchmark cohort {name}")
        if len(samples) != count:
            _append_unique(observed, f"benchmark cohort {name} does not have the policy sample count")
            complete = False
        cohorts[name] = [_mapping(sample, f"benchmark sample {name}") for sample in samples]
    if not complete:
        return

    identities = set()
    run_ids: list[str] = []
    for name, samples in cohorts.items():
        stable_fields = set()
        for sample in samples:
            _bound_evidence(root, "benchmark sample", sample, source_hash, observed, rejected)
            duration = _number(sample.get("durationSeconds"), "benchmark duration")
            exit_code = _number(sample.get("exitCode"), "benchmark exitCode", integer=True)
            executed = _number(sample.get("executedTests"), "benchmark executedTests", integer=True)
            run_id = sample.get("runID")
            if not isinstance(run_id, str) or not run_id:
                raise EvidenceFormatError("benchmark runID must be nonempty")
            run_ids.append(run_id)
            if exit_code != 0 or executed == 0:
                _append_unique(rejected, "benchmark sample is not a successful executing run")
            if sample.get("sourceContentHash") != source_hash:
                _append_unique(observed, "benchmark sample is stale for the source set")
            identity = tuple(sample.get(field) for field in IDENTITY_FIELDS)
            if any(not isinstance(value, str) or not value for value in identity):
                raise EvidenceFormatError("benchmark identity fields must be nonempty strings")
            identities.add(identity)
            stable_fields.add(tuple(sample.get(field) for field in SAMPLE_STABILITY_FIELDS))
            if any(not isinstance(sample.get(field), str) or not sample.get(field) for field in SAMPLE_STABILITY_FIELDS):
                raise EvidenceFormatError("benchmark lane, command, and scenario must be nonempty")
            _ = duration
        if len(stable_fields) != 1:
            _append_unique(rejected, f"benchmark cohort {name} mixes lane, command, or scenario")
    if len(set(run_ids)) != len(run_ids):
        _append_unique(rejected, "benchmark samples contain replayed run identifiers")
    if len(identities) != 1:
        _append_unique(rejected, "benchmark samples do not share one stable identity")
    if rejected or any("benchmark" in finding and "stale" in finding for finding in observed):
        return

    durations = {
        name: [float(sample["durationSeconds"]) for sample in samples]
        for name, samples in cohorts.items()
    }
    module_median = float(statistics.median(durations["moduleTest"]))
    candidate_median = float(statistics.median(durations["leafProofCandidate"]))
    baseline_median = float(statistics.median(durations["leafProofHostedBaseline"]))
    if module_median > thresholds["moduleTestMedianMaximumSeconds"]:
        _append_unique(rejected, "module test median exceeds policy maximum")
    if candidate_median > thresholds["leafProofMedianMaximumSeconds"]:
        _append_unique(rejected, "leaf proof median exceeds policy maximum")
    required_ratio = 1.0 - thresholds["leafProofMinimumHostedImprovementFraction"]
    if candidate_median > baseline_median * required_ratio:
        _append_unique(rejected, "leaf proof median lacks the required hosted improvement")
    if max(durations["leafProofCandidate"]) > max(durations["leafProofHostedBaseline"]) * thresholds["candidateWorstMaximumHostedRatio"]:
        _append_unique(rejected, "candidate leaf proof worst sample is worse than hosted baseline")
    regression_ratio = 1.0 + thresholds["appNoChangeMaximumRegressionFraction"]
    app_candidate = durations["appNoChangeCandidate"]
    app_baseline = durations["appNoChangeBaseline"]
    if statistics.median(app_candidate) > statistics.median(app_baseline) * regression_ratio:
        _append_unique(rejected, "app no-change median regression exceeds policy maximum")
    if max(app_candidate) > max(app_baseline) * regression_ratio:
        _append_unique(rejected, "app no-change worst regression exceeds policy maximum")


def evaluate_candidate(root: Path, thresholds: dict[str, Any], candidate: dict[str, Any]) -> CandidateResult:
    candidate = _mapping(candidate, "candidate")
    candidate_id = candidate.get("id")
    declared = candidate.get("status")
    if not isinstance(candidate_id, str) or not candidate_id:
        raise EvidenceFormatError("candidate id must be nonempty")
    if declared not in ALLOWED_STATUSES:
        raise EvidenceFormatError(f"candidate {candidate_id} has invalid status")
    proposed = candidate.get("proposedTarget")
    if proposed is not None and (not isinstance(proposed, str) or not proposed):
        raise EvidenceFormatError(f"candidate {candidate_id} proposedTarget must be nonempty")

    observed: list[str] = []
    rejected: list[str] = []
    source_raw = candidate.get("sourceSet")
    if source_raw is None:
        _append_unique(rejected, "explicit source set is missing")
        return CandidateResult(candidate_id, declared, "rejected", tuple(rejected), proposed)
    source = _mapping(source_raw, "sourceSet")
    files = _list(source.get("files"), "sourceSet files")
    if any(not isinstance(path, str) or not path for path in files):
        raise EvidenceFormatError("sourceSet files must contain nonempty strings")
    source_readable = bool(files) and len(set(files)) == len(files)
    if not files:
        _append_unique(rejected, "source set is empty")
    if source.get("selection") != "explicit_files":
        _append_unique(rejected, "source set is folder-derived rather than explicit")
    if len(set(files)) != len(files):
        _append_unique(rejected, "source set contains duplicate paths")
    for relative in files:
        if not _canonical_source_path(relative):
            source_readable = False
            _append_unique(rejected, f"noncanonical source path: {relative}")
        elif not (root / relative).is_file():
            source_readable = False
            _append_unique(rejected, f"source file is missing: {relative}")
    expected_hash = source.get("contentHash")
    if not _sha(expected_hash):
        _append_unique(observed, "source content hash is missing")
        expected_hash = ""
    elif source_readable:
        actual_hash = source_set_hash(root, files)
        if actual_hash != expected_hash:
            _append_unique(observed, "source content hash is stale")

    if candidate.get("prospectiveGateEvidence") is not True:
        _append_unique(observed, "candidate predates or lacks prospective gate evidence")
    disqualifiers = candidate.get("affirmativeDisqualifiers", [])
    if not isinstance(disqualifiers, list) or any(item not in DISQUALIFIER_FINDINGS for item in disqualifiers):
        raise EvidenceFormatError(f"candidate {candidate_id} has invalid affirmativeDisqualifiers")
    for item in disqualifiers:
        _append_unique(rejected, DISQUALIFIER_FINDINGS[item])

    _evaluate_history(root, candidate, thresholds, files, expected_hash, observed, rejected)
    _evaluate_proof_surfaces(root, candidate, files, expected_hash, observed, rejected)
    _evaluate_benchmarks(root, candidate, thresholds, expected_hash, observed, rejected)

    status = "rejected" if rejected else "observed" if observed else "authorized"
    return CandidateResult(candidate_id, declared, status, tuple(rejected + observed), proposed)


def _validate_thresholds(raw: Any) -> dict[str, Any]:
    thresholds = _mapping(raw, "thresholds")
    if set(thresholds) != THRESHOLD_KEYS:
        missing = sorted(THRESHOLD_KEYS - set(thresholds))
        extra = sorted(set(thresholds) - THRESHOLD_KEYS)
        raise EvidenceFormatError(f"threshold keys differ; missing={missing} extra={extra}")
    for key in THRESHOLD_KEYS:
        integer = key in {"historyMaximumFirstParentCommits", "historyMinimumFirstParentCommits", "benchmarkSamplesPerCohort"}
        _number(thresholds[key], f"threshold {key}", integer=integer)
    percentile = thresholds["productionHighChurnPercentile"]
    fractions = (
        thresholds["leafProofMinimumHostedImprovementFraction"],
        thresholds["appNoChangeMaximumRegressionFraction"],
    )
    if not 0 < percentile < 1 or any(not 0 <= value < 1 for value in fractions):
        raise EvidenceFormatError("policy percentile and fraction thresholds are out of range")
    if thresholds["historyMinimumFirstParentCommits"] > thresholds["historyMaximumFirstParentCommits"]:
        raise EvidenceFormatError("history minimum exceeds history maximum")
    if thresholds["benchmarkSamplesPerCohort"] <= 0 or thresholds["candidateWorstMaximumHostedRatio"] <= 0:
        raise EvidenceFormatError("sample count and worst-sample ratio must be positive")
    return thresholds


def evaluate_policy(root: Path, policy: dict[str, Any]) -> PolicyResult:
    policy = _mapping(policy, "policy")
    if policy.get("schemaVersion") != 1:
        raise EvidenceFormatError("unsupported policy schemaVersion")
    thresholds = _validate_thresholds(policy.get("thresholds"))
    candidates_raw = _list(policy.get("candidates"), "candidates")
    declared_targets = _list(policy.get("authorizedFutureTargets"), "authorizedFutureTargets")
    if any(not isinstance(target, str) or not target for target in declared_targets):
        raise EvidenceFormatError("authorizedFutureTargets must contain nonempty strings")
    if len(set(declared_targets)) != len(declared_targets):
        raise EvidenceFormatError("authorizedFutureTargets contains duplicates")

    results = tuple(evaluate_candidate(root, thresholds, candidate) for candidate in candidates_raw)
    ids = [result.candidate_id for result in results]
    if len(set(ids)) != len(ids):
        raise EvidenceFormatError("candidate ids must be unique")
    findings: list[str] = []
    authorized: list[str] = []
    for result in results:
        if result.declared_status != result.status:
            findings.append(
                f"candidate {result.candidate_id} declares {result.declared_status} but evaluates {result.status}"
            )
        if result.status == "authorized":
            if not result.proposed_target:
                findings.append(f"authorized candidate {result.candidate_id} lacks a proposedTarget")
            else:
                authorized.append(result.proposed_target)
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
        payload = json.loads(args.policy.read_text(encoding="utf-8"))
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
                "id": row.candidate_id,
                "declaredStatus": row.declared_status,
                "evaluatedStatus": row.status,
                "findings": list(row.findings),
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
