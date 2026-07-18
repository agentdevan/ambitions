"""Deterministic, evidence-verifying Gate B authorization benchmark."""

from __future__ import annotations

import base64
import contextlib
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from collections.abc import Mapping, Sequence
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.authorization import (
    AuthorizationError,
    canonical_json_bytes,
    canonical_tree_delta,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
    task_start,
    trusted_event_projection_digest,
    validate_task_finalization_receipt,
)
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.task_pack import TaskIntake, build_task_pack


AUTHORIZATION_SCENARIO_IDS = (
    "today-swiftui",
    "time-recurrence",
    "capture-proposal",
    "local-runtime-mutation",
    "cloudkit-continuity",
    "source-atlas-boundary",
    "accessibility-repair",
    "release-proof-claim",
)
_MAX_EVIDENCE_BYTES = 64 * 1024 * 1024
_MAX_TRUSTED_INPUT_BYTES = 8 * 1024 * 1024
_SUBPROCESS_TIMEOUT_SECONDS = 60

_SCENARIO_FIELDS = frozenset(
    {
        "schema_version",
        "scenario_id",
        "title",
        "task_type",
        "scope",
        "requirement_ids",
        "requested_changed_files",
        "operations",
        "required_checks",
        "proof_obligations",
        "skill_adapters",
        "claim_ceiling",
        "approval_required",
        "expected_failure_codes",
    }
)
_WRITE_FIELDS = frozenset({"kind", "path", "content"})
_WRITE_RAW_FIELDS = frozenset(
    {"kind", "path_raw_base64url", "content_base64url"}
)
_FAILURE_CASES = frozenset(
    {
        "missing_intake",
        "stale_intake",
        "stale_envelope",
        "base_movement",
        "head_replacement",
        "stale_skill",
        "workflow_drift",
        "command_manifest_drift",
        "re_attested_untrusted_green",
        "local_substitution",
        "final_diff_drift",
        "absent_finalization",
    }
)
_HANDOFF_FIELDS = frozenset(
    {
        "schema_version",
        "handoff_id",
        "task_id",
        "issue_reference",
        "task_type",
        "scope",
        "requirement_ids",
        "changed_files",
        "validation_requests",
        "proof_requests",
        "rollback_requests",
        "claim_ceiling_request",
        "skill_adapter_requests",
    }
)
_HANDOFF_AUTHORITY_FIELDS = frozenset(
    {
        "approval",
        "authorized_files",
        "validation_results",
        "proof_claims",
        "break_glass",
        "merge_permission",
    }
)
_EXECUTION_ENVIRONMENT_ALLOWLIST = (
    "PATH",
    "SYSTEMROOT",
    "TMPDIR",
    "WINDIR",
)
_TRUSTED_PYTHON_VERSION = (3, 12)


class BenchmarkError(ValueError):
    """Stable fail-closed benchmark error without a partial report."""

    def __init__(self, code: str, message: str) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


@dataclass(frozen=True)
class ScenarioDefinition:
    schema_version: int
    scenario_id: str
    title: str
    task_type: str
    scope: tuple[str, ...]
    requirement_ids: tuple[str, ...]
    requested_changed_files: tuple[str, ...]
    operations: tuple[dict[str, str], ...]
    required_checks: tuple[str, ...]
    proof_obligations: tuple[str, ...]
    skill_adapters: tuple[str, ...]
    claim_ceiling: str
    approval_required: bool
    expected_failure_codes: dict[str, str]


def canonical_benchmark_bytes(value: object) -> bytes:
    """Return the shared canonical JSON representation."""

    return canonical_json_bytes(value)


def load_authorization_benchmark_scenarios(
    fixture_directory: Path,
) -> tuple[ScenarioDefinition, ...]:
    """Load the closed eight-scenario fixture corpus in canonical order."""

    if not fixture_directory.is_dir():
        raise BenchmarkError(
            "BENCHMARK_FIXTURE_DIRECTORY", "fixture directory is unavailable"
        )
    scenarios: list[ScenarioDefinition] = []
    for path in sorted(fixture_directory.glob("*.json"), key=lambda item: item.name):
        try:
            data = json.loads(
                _bounded_file_bytes(
                    path, "BENCHMARK_FIXTURE_INVALID", _MAX_TRUSTED_INPUT_BYTES
                ).decode("utf-8")
            )
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            raise BenchmarkError(
                "BENCHMARK_FIXTURE_INVALID", f"cannot read {path.name}"
            ) from exc
        scenarios.append(_validate_scenario(data, path.name))
    observed = tuple(item.scenario_id for item in scenarios)
    if observed != AUTHORIZATION_SCENARIO_IDS:
        raise BenchmarkError(
            "BENCHMARK_SCENARIO_SET",
            "fixture corpus must contain the exact eight representative scenarios",
        )
    return tuple(scenarios)


def run_authorization_benchmark(
    scenarios: Sequence[ScenarioDefinition],
    evidence_root: Path,
    *,
    source_root: Path,
    python_executable: str | None = None,
) -> dict[str, object]:
    """Recompute every scenario from confined local evidence and real Git bytes."""

    ordered = tuple(scenarios)
    if tuple(item.scenario_id for item in ordered) != AUTHORIZATION_SCENARIO_IDS:
        raise BenchmarkError(
            "BENCHMARK_SCENARIO_SET",
            "authorization benchmark requires all eight scenarios in order",
        )
    root = _safe_directory(evidence_root, evidence_root, "BENCHMARK_EVIDENCE_PATH")
    with detached_exact_source(source_root) as source:
        exact_scenarios = load_authorization_benchmark_scenarios(
            source / "tests/canon/fixtures/authorization-benchmarks"
        )
        if exact_scenarios != ordered:
            raise BenchmarkError(
                "BENCHMARK_FIXTURE_SUBSTITUTION",
                "caller scenarios differ from the detached source SHA corpus",
            )
        policy_digest = _verify_benchmark_policy(source, exact_scenarios)
        try:
            with ThreadPoolExecutor(max_workers=min(4, len(ordered))) as executor:
                validated = list(
                    executor.map(
                        lambda scenario: _verify_scenario(
                            root,
                            scenario,
                            source,
                            _source_is_exact=True,
                        ),
                        exact_scenarios,
                    )
                )
        except BenchmarkError:
            raise
        except Exception as exc:
            raise BenchmarkError(
                "BENCHMARK_EXECUTION_FAILED",
                "scenario execution failed before complete evidence",
            ) from exc
        matrix = _run_task24_tree_matrix(
            source, python_executable=python_executable or sys.executable
        )
        source_sha = _git_text(source, "rev-parse", "HEAD")
        source_tree = _git_text(source, "rev-parse", "HEAD^{tree}")
    report = {
        "schema_version": 1,
        "benchmark_id": "gate-b-chatgpt-codex-authorization-v1",
        "status": "green",
        "scenario_count": len(validated),
        "scenario_ids": list(AUTHORIZATION_SCENARIO_IDS),
        "benchmark_policy_sha256": policy_digest,
        "source_sha": source_sha,
        "source_tree_sha": source_tree,
        "scenarios": validated,
        "task24_tree_matrix": matrix,
        "authority_class": "proof-only-non-authoritative",
        "claim_ceiling": (
            "Gate B authorization benchmark Green for exact synthetic scope only; "
            "no live protected-branch, product, runtime, visual, accessibility, "
            "privacy/legal, device, TestFlight, App Store, or Release Green."
        ),
    }
    return report


@contextlib.contextmanager
def detached_exact_source(
    source_root: Path, *, expected_source_sha: str | None = None
):
    """Yield one clean detached checkout of the caller's exact committed HEAD."""

    source = _safe_git_checkout(source_root)
    source_status = _git(
        source,
        "status",
        "--porcelain=v1",
        "-z",
        "--untracked-files=all",
    )
    if source_status and not _only_unmaterialized_raw_paths(source_status):
        raise BenchmarkError(
            "BENCHMARK_SOURCE_DIRTY",
            "mutable source bytes cannot generate or verify benchmark evidence",
        )
    source_sha = _git_text(source, "rev-parse", "HEAD")
    if expected_source_sha is not None and source_sha != expected_source_sha:
        raise BenchmarkError(
            "BENCHMARK_SOURCE_STALE", "source HEAD differs from the declared SHA"
        )
    source_tree = _git_text(source, "rev-parse", "HEAD^{tree}")
    with tempfile.TemporaryDirectory(prefix="ambitions-exact-source-") as directory:
        checkout = Path(directory) / "checkout"
        _git(
            source,
            "clone",
            "-q",
            "--no-hardlinks",
            "--no-checkout",
            str(source),
            str(checkout),
        )
        _git(checkout, "checkout", "-q", "--detach", source_sha)
        _mark_unmaterialized_raw_paths(checkout)
        if (
            _git_text(checkout, "rev-parse", "HEAD") != source_sha
            or _git_text(checkout, "rev-parse", "HEAD^{tree}") != source_tree
            or _git_text(
                checkout,
                "status",
                "--porcelain=v1",
                "--untracked-files=all",
            )
        ):
            raise BenchmarkError(
                "BENCHMARK_SOURCE_STALE",
                "detached source checkout does not match the declared SHA tree",
            )
        yield checkout


def _only_unmaterialized_raw_paths(status: bytes) -> bool:
    records = [item for item in status.split(b"\0") if item]
    if not records:
        return True
    for record in records:
        if not record.startswith(b" D "):
            return False
        try:
            record[3:].decode("utf-8")
        except UnicodeDecodeError:
            continue
        return False
    return True


def _mark_unmaterialized_raw_paths(repo: Path) -> None:
    for raw_path in _git(repo, "ls-files", "-z").split(b"\0"):
        if not raw_path:
            continue
        try:
            raw_path.decode("utf-8")
        except UnicodeDecodeError:
            _git(
                repo,
                b"update-index",
                b"--skip-worktree",
                b"--",
                raw_path,
            )


def _verify_benchmark_policy(
    source_root: Path, scenarios: Sequence[ScenarioDefinition]
) -> str:
    path = _safe_file(
        source_root
        / "docs/canon/references/task-25-authorization-benchmark-policy.json",
        source_root,
        "BENCHMARK_POLICY",
    )
    raw = _bounded_file_bytes(path, "BENCHMARK_POLICY", _MAX_TRUSTED_INPUT_BYTES)
    try:
        policy = json.loads(raw.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError("BENCHMARK_POLICY", "benchmark policy is invalid") from exc
    if (
        not isinstance(policy, Mapping)
        or set(policy)
        != {
            "schema_version",
            "registry_revision",
            "scenarios",
            "visual_review_policy",
        }
        or policy.get("schema_version") != 1
        or not isinstance(policy.get("registry_revision"), str)
        or not isinstance(policy.get("scenarios"), list)
    ):
        raise BenchmarkError("BENCHMARK_POLICY", "benchmark policy is malformed")
    expected_visual_review_policy = {
        "accessibility_variants_source": (
            "docs/canon/migration/visual-authority-rebaseline.json"
        ),
        "claim_ceiling": (
            "Figma design authority only; no simulator, runtime, device, "
            "accessibility, privacy, or release proof."
        ),
        "figma_evidence_kind": "figma-design-export",
        "merged_visual_ledger_paths": [
            "docs/canon/generated/canon-index.json",
            "docs/canon/generated/visual-authority-manifest.json",
            "docs/canon/migration/ux-blueprint.json",
            "docs/canon/migration/visual-authority-rebaseline.json",
        ],
        "required_review_dimensions": [
            "accessibility-coverage",
            "frame-completeness",
            "journey-coverage",
            "object-coverage",
            "requirement-coverage",
            "screenshot-authenticity",
            "state-coverage",
        ],
    }
    if policy["visual_review_policy"] != expected_visual_review_policy:
        raise BenchmarkError(
            "BENCHMARK_POLICY", "visual review policy differs from closed contract"
        )
    expected = []
    for scenario in scenarios:
        expected.append(
            {
                "scenario_id": scenario.scenario_id,
                "task_type": scenario.task_type,
                "scope": list(scenario.scope),
                "requirement_ids": list(scenario.requirement_ids),
                "authorized_files": list(scenario.requested_changed_files),
                "required_checks": list(scenario.required_checks),
                "proof_obligations": list(scenario.proof_obligations),
                "skill_adapters": list(scenario.skill_adapters),
                "approval_required": scenario.approval_required,
                "maximum_claim_ceiling": scenario.claim_ceiling,
            }
        )
    if policy["scenarios"] != expected:
        raise BenchmarkError(
            "BENCHMARK_POLICY", "scenario fixtures differ from independent policy"
        )
    return hashlib.sha256(raw).hexdigest()


def handoff_to_task_intake(
    handoff_path: Path, *, evidence_root: Path
) -> dict[str, object]:
    """Translate a closed request-only ChatGPT handoff into Task 24 intake."""

    data, _raw = _read_json_file(
        handoff_path, evidence_root, "BENCHMARK_HANDOFF_INVALID"
    )
    if not isinstance(data, Mapping):
        raise BenchmarkError(
            "BENCHMARK_HANDOFF_INVALID", "handoff must be an object"
        )
    authority = sorted(set(data) & _HANDOFF_AUTHORITY_FIELDS)
    if authority:
        raise BenchmarkError(
            "BENCHMARK_HANDOFF_AUTHORITY_FIELD",
            f"handoff cannot grant authority: {authority[0]}",
        )
    if set(data) != _HANDOFF_FIELDS or data.get("schema_version") != 1:
        raise BenchmarkError(
            "BENCHMARK_HANDOFF_INVALID", "handoff fields do not match contract"
        )
    handoff_id = _text(data["handoff_id"], "handoff_id")
    intake = {
        "schema_version": 1,
        "intake_id": f"INTAKE-{handoff_id}",
        "task_id": _text(data["task_id"], "task_id"),
        "issue_reference": _text(data["issue_reference"], "issue_reference"),
        "requested_task_type": _text(data["task_type"], "task_type"),
        "requested_scope": list(_strings(data["scope"], "scope")),
        "requested_requirement_ids": list(
            _strings(data["requirement_ids"], "requirement_ids")
        ),
        "requested_changed_files": list(
            _strings(data["changed_files"], "changed_files")
        ),
        "requested_validation": list(
            _strings(data["validation_requests"], "validation_requests")
        ),
        "requested_proof": list(
            _strings(data["proof_requests"], "proof_requests")
        ),
        "requested_rollback": list(
            _strings(data["rollback_requests"], "rollback_requests")
        ),
        "requested_claim_ceiling": _text(
            data["claim_ceiling_request"], "claim_ceiling_request"
        ),
        "requested_skill_adapters": list(
            _strings(
                data["skill_adapter_requests"],
                "skill_adapter_requests",
                allow_empty=True,
            )
        ),
    }
    from tools.ambitions_canon.authorization import validate_task_intake

    return validate_task_intake(intake)


def execute_base_owned_validations(
    repo_root: Path,
    trusted_base_sha: str,
    authorization: Mapping[str, object],
) -> dict[str, dict[str, object]]:
    """Produce Task 24 CI evidence from authorized argv with a hard time bound.

    Gate B verification never calls this producer; it independently reconstructs
    the expected benchmark artifact from inert Git bytes.
    """

    repo = _safe_git_checkout(repo_root)
    event = authorization.get("trusted_event_provenance")
    if not isinstance(event, Mapping) or not isinstance(
        event.get("trusted_head_sha"), str
    ):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_BINDING",
            "authorization has no trusted source SHA",
        )
    with detached_exact_source(
        repo, expected_source_sha=str(event["trusted_head_sha"])
    ) as checkout:
        return _execute_base_owned_validations(
            checkout, trusted_base_sha, authorization
        )


def _execute_base_owned_validations(
    repo: Path,
    trusted_base_sha: str,
    authorization: Mapping[str, object],
) -> dict[str, dict[str, object]]:
    manifest_bytes = _git(repo, "show", f"{trusted_base_sha}:docs/canon/references/validation-command-manifest.json")
    try:
        manifest = json.loads(manifest_bytes.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_MANIFEST", "base command manifest is invalid"
        ) from exc
    commands = manifest.get("commands") if isinstance(manifest, Mapping) else None
    if not isinstance(commands, list):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_MANIFEST", "base command list is invalid"
        )
    by_id = {
        item.get("command_id"): item
        for item in commands
        if isinstance(item, Mapping) and isinstance(item.get("command_id"), str)
    }
    required = authorization.get("computed_required_checks")
    digests = authorization.get("computed_command_digests")
    if not isinstance(required, list) or not isinstance(digests, Mapping):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_MANIFEST", "authorization has no command bindings"
        )
    results: dict[str, dict[str, object]] = {}
    environment = _trusted_execution_environment()
    for command_id in required:
        command = by_id.get(command_id)
        if not isinstance(command, Mapping) or not isinstance(command.get("argv"), list):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_MANIFEST", f"missing command: {command_id}"
            )
        argv = command["argv"]
        if not argv or any(not isinstance(item, str) or not item for item in argv):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_MANIFEST", f"invalid argv: {command_id}"
            )
        argv_digest = hashlib.sha256(canonical_json_bytes(argv)).hexdigest()
        if digests.get(command_id) != argv_digest:
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_BINDING", f"argv digest changed: {command_id}"
            )
        try:
            execution_argv = _trusted_execution_argv(argv)
            completed = subprocess.run(
                execution_argv,
                cwd=repo,
                env=environment,
                check=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=300,
            )
        except (OSError, subprocess.TimeoutExpired) as exc:
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_EXECUTION", f"cannot execute: {command_id}"
            ) from exc
        artifact = canonical_json_bytes(
            {
                "schema_version": 1,
                "command_id": command_id,
                "argv": argv,
                "exit_status": completed.returncode,
                "stdout_base64url": _base64url_encode(completed.stdout),
                "stderr_base64url": _base64url_encode(completed.stderr),
            }
        )
        if completed.returncode != 0:
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_NOT_GREEN", f"command failed: {command_id}"
            )
        results[str(command_id)] = {
            "artifact_bytes": artifact,
            "artifact_digest": hashlib.sha256(artifact).hexdigest(),
            "exit_status": completed.returncode,
        }
    return dict(sorted(results.items()))


def _trusted_execution_argv(argv: list[str]) -> list[str]:
    """Bind the portable python3 manifest token to this trusted 3.12 process."""

    if argv[0] != "python3":
        return argv
    if sys.version_info[:2] != _TRUSTED_PYTHON_VERSION:
        raise BenchmarkError(
            "BENCHMARK_PYTHON_RUNTIME",
            "base-owned Python commands require the trusted Python 3.12 runtime",
        )
    return [sys.executable, *argv[1:]]


def _trusted_execution_environment() -> dict[str, str]:
    """Return the closed, deterministic environment allowed for trusted commands."""

    environment = {
        key: os.environ[key]
        for key in _EXECUTION_ENVIRONMENT_ALLOWLIST
        if key in os.environ
    }
    environment.update(
        {
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_TERMINAL_PROMPT": "0",
            "HOME": "/var/empty",
            "LANG": "C",
            "LC_ALL": "C",
            "PYTHONDONTWRITEBYTECODE": "1",
            "PYTHONHASHSEED": "0",
            "TZ": "UTC",
        }
    )
    return environment


def _verify_scenario(
    evidence_root: Path,
    scenario: ScenarioDefinition,
    source_root: Path,
    *,
    _clean_repo: Path | None = None,
    _source_is_exact: bool = False,
) -> dict[str, object]:
    package = _safe_directory(
        evidence_root / scenario.scenario_id,
        evidence_root,
        "BENCHMARK_EVIDENCE_PATH",
    )
    artifact_repo = _safe_directory(
        package / "repo", evidence_root, "BENCHMARK_EVIDENCE_PATH"
    )
    if _clean_repo is None:
        artifact_head = _git_text(artifact_repo, "rev-parse", "HEAD")
        artifact_base = _git_text(artifact_repo, "rev-parse", "refs/heads/main")
        with tempfile.TemporaryDirectory(
            prefix=f"ambitions-benchmark-{scenario.scenario_id}-"
        ) as directory:
            clean_repo = Path(directory) / "repo"
            _git(
                artifact_repo,
                "clone",
                "-q",
                "--no-hardlinks",
                "--no-checkout",
                str(artifact_repo),
                str(clean_repo),
            )
            _prepare_clean_scenario_checkout(
                clean_repo,
                head=artifact_head,
                base=artifact_base,
                scenario=scenario,
            )
            return _verify_scenario(
                evidence_root,
                scenario,
                source_root,
                _clean_repo=clean_repo,
                _source_is_exact=_source_is_exact,
            )
    repo = _clean_repo
    handoff_path = package / "handoff.json"
    intake = handoff_to_task_intake(handoff_path, evidence_root=evidence_root)
    stored_task_pack, task_pack_raw = _read_json_file(
        package / "task-pack.json",
        evidence_root,
        "BENCHMARK_TASK_PACK_MISMATCH",
    )
    expected_intake = {
        "schema_version": 1,
        "intake_id": f"INTAKE-25-{scenario.scenario_id}",
        "task_id": f"TASK-25-{scenario.scenario_id}",
        "issue_reference": f"CANON-GATE-B-{scenario.scenario_id}",
        "requested_task_type": scenario.task_type,
        "requested_scope": list(scenario.scope),
        "requested_requirement_ids": list(scenario.requirement_ids),
        "requested_changed_files": list(scenario.requested_changed_files),
        "requested_validation": list(scenario.required_checks),
        "requested_proof": list(scenario.proof_obligations),
        "requested_rollback": ["git-revert"],
        "requested_claim_ceiling": scenario.claim_ceiling,
        "requested_skill_adapters": list(scenario.skill_adapters),
    }
    if canonical_json_bytes(intake) != canonical_json_bytes(expected_intake):
        raise BenchmarkError(
            "BENCHMARK_HANDOFF_BINDING", "handoff differs from scenario request"
        )
    event, event_raw = _read_json_file(
        package / "trusted-event.json", evidence_root, "BENCHMARK_EVENT_INVALID"
    )
    approvals, approvals_raw = _read_json_file(
        package / "approval-attestations.json",
        evidence_root,
        "BENCHMARK_APPROVAL_INVALID",
    )
    stored_start, start_raw = _read_json_file(
        package / "task-authorization.json",
        evidence_root,
        "BENCHMARK_AUTHORIZATION_MISMATCH",
    )
    validations, validations_raw = _read_json_file(
        package / "validation-attestations.json",
        evidence_root,
        "BENCHMARK_VALIDATION_INVALID",
    )
    stored_receipt, receipt_raw = _read_json_file(
        package / "task-finalization.json",
        evidence_root,
        "BENCHMARK_FINALIZATION_MISSING",
    )
    negatives, negatives_raw = _read_json_file(
        package / "negative-validation-attestations.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    attempt_event, attempt_event_raw = _read_json_file(
        package / "attempt-event.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    attempt_approvals, attempt_approvals_raw = _read_json_file(
        package / "attempt-approvals.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    replacement_event, replacement_event_raw = _read_json_file(
        package / "replacement-event.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    replacement_approvals, replacement_approvals_raw = _read_json_file(
        package / "replacement-approvals.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    final_diff_event, final_diff_event_raw = _read_json_file(
        package / "final-diff-event.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    final_diff_approvals, final_diff_approvals_raw = _read_json_file(
        package / "final-diff-approvals.json",
        evidence_root,
        "BENCHMARK_NEGATIVE_INVALID",
    )
    if not isinstance(event, Mapping) or not isinstance(approvals, list):
        raise BenchmarkError(
            "BENCHMARK_EVENT_INVALID", "event or approval evidence is malformed"
        )
    try:
        recomputed_task_pack = _build_task_pack_from_exact_source(
            source_root,
            intake=intake,
            repository_sha=str(event["trusted_head_sha"]),
            source_is_exact=_source_is_exact,
        )
    except Exception as exc:
        raise BenchmarkError(
            "BENCHMARK_TASK_PACK_MISMATCH",
            "TaskPack could not be independently projected from source canon",
        ) from exc
    if (
        not isinstance(stored_task_pack, Mapping)
        or canonical_json_bytes(recomputed_task_pack) != task_pack_raw
    ):
        raise BenchmarkError(
            "BENCHMARK_TASK_PACK_MISMATCH",
            "stored TaskPack differs from independent source projection",
        )
    if not isinstance(validations, list) or not validations:
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_INVALID", "exact validation evidence is required"
        )
    _verify_event_git(repo, event)
    base = str(event["trusted_base_sha"])
    head = str(event["trusted_head_sha"])
    if _git_text(repo, "rev-parse", "HEAD") != head:
        raise BenchmarkError(
            "BENCHMARK_SYNTHETIC_CHECKOUT", "package checkout is not exact trusted head"
        )
    policy = load_base_policy(repo, base)
    bindings = load_trusted_bindings(repo, base, intake, policy)
    start_arguments = {
        "repo_root": repo,
        "mode": "ci-pr-range",
        "intake_data": intake,
        "trusted_event_data": event,
        "trusted_bindings": bindings,
        "policy_data": policy,
        "approval_attestations": approvals,
        "verification_epoch": int(event["verification_epoch"]),
    }
    try:
        start = task_start(**start_arguments)
        resumed = task_start(**start_arguments)
    except AuthorizationError as exc:
        raise BenchmarkError(
            "BENCHMARK_AUTHORIZATION_REJECTED", "trusted task start failed"
        ) from exc
    if canonical_json_bytes(start) != start_raw:
        raise BenchmarkError(
            "BENCHMARK_AUTHORIZATION_MISMATCH",
            "stored authorization does not equal independent recomputation",
        )
    if canonical_json_bytes(start) != canonical_json_bytes(resumed):
        raise BenchmarkError(
            "BENCHMARK_RESUME_MISMATCH", "resumed authorization is not byte-identical"
        )

    validation_results = _recompute_benchmark_validation(
        repo,
        base,
        start,
        scenario,
    )
    validation_artifacts = _verify_validation_artifacts(
        package,
        evidence_root=evidence_root,
        scenario=scenario,
        repo=repo,
        trusted_base_sha=base,
        validations=validations,
        validation_results=validation_results,
        error_code="BENCHMARK_VALIDATION_ARTIFACT",
    )
    artifact_bytes = validation_artifacts[scenario.required_checks[0]]
    try:
        receipt = task_finalize(
            repo_root=repo,
            authorization=start,
            intake_data=intake,
            trusted_event_data=event,
            trusted_bindings=bindings,
            policy_data=policy,
            approval_attestations=approvals,
            validation_attestations=validations,
            verification_epoch=int(event["verification_epoch"]),
        )
        validate_task_finalization_receipt(receipt)
    except AuthorizationError as exc:
        raise BenchmarkError(
            "BENCHMARK_FINALIZATION_REJECTED", "trusted task finalization failed"
        ) from exc
    if canonical_json_bytes(receipt) != receipt_raw:
        raise BenchmarkError(
            "BENCHMARK_FINALIZATION_MISMATCH",
            "stored receipt does not equal independent recomputation",
        )
    if not isinstance(stored_start, Mapping) or not isinstance(stored_receipt, Mapping):
        raise BenchmarkError(
            "BENCHMARK_EVIDENCE_TYPE", "authorization evidence must be objects"
        )

    finalize_arguments = {
        "repo_root": repo,
        "authorization": start,
        "intake_data": intake,
        "trusted_event_data": event,
        "trusted_bindings": bindings,
        "policy_data": policy,
        "approval_attestations": approvals,
        "validation_attestations": validations,
        "verification_epoch": int(event["verification_epoch"]),
    }
    negative_observations: dict[str, dict[str, str]] = {}
    negative_observations["missing_intake"] = _observe_authorization_failure(
        lambda: task_start(**{**start_arguments, "intake_data": {}})
    )
    stale_intake = dict(intake)
    stale_intake["requested_claim_ceiling"] = "forged broader claim"
    negative_observations["stale_intake"] = _observe_authorization_failure(
        lambda: task_finalize(**{**finalize_arguments, "intake_data": stale_intake})
    )
    stale_envelope = dict(start)
    stale_envelope["computed_claim_ceiling"] = "forged broader claim"
    negative_observations["stale_envelope"] = _observe_authorization_failure(
        lambda: task_finalize(
            **{**finalize_arguments, "authorization": stale_envelope}
        )
    )
    stale_skill = dict(bindings)
    stale_skill["skill_dependencies_sha256"] = "0" * 64
    negative_observations["stale_skill"] = _observe_authorization_failure(
        lambda: task_start(
            **{**start_arguments, "trusted_bindings": stale_skill}
        )
    )
    if not isinstance(negatives, Mapping):
        raise BenchmarkError(
            "BENCHMARK_NEGATIVE_INVALID", "negative validation set is malformed"
        )
    for case in (
        "workflow_drift",
        "command_manifest_drift",
        "re_attested_untrusted_green",
    ):
        negative = negatives.get(case)
        if not isinstance(negative, Mapping):
            raise BenchmarkError(
                "BENCHMARK_NEGATIVE_INVALID", f"missing signed negative: {case}"
            )
        target_command = negative.get("command_id")
        negative_set = [
            negative
            if isinstance(item, Mapping)
            and item.get("command_id") == target_command
            else item
            for item in validations
        ]
        if sum(
            isinstance(item, Mapping)
            and item.get("command_id") == target_command
            for item in validations
        ) != 1:
            raise BenchmarkError(
                "BENCHMARK_NEGATIVE_INVALID",
                f"signed negative has no exact validation target: {case}",
            )
        negative_observations[case] = _observe_authorization_failure(
            lambda negative_set=negative_set: task_finalize(
                **{
                    **finalize_arguments,
                    "validation_attestations": negative_set,
                }
            )
        )

    local_originals = _apply_local_advisory_probe(repo, scenario)
    try:
        local_arguments = {
            "repo_root": repo,
            "mode": "local-advisory",
            "intake_data": intake,
            "trusted_event_data": event,
            "trusted_bindings": bindings,
            "policy_data": policy,
            "approval_attestations": approvals,
            "verification_epoch": int(event["verification_epoch"]),
        }
        negative_observations["local_substitution"] = _observe_benchmark_failure(
            lambda: _verify_local_substitution_rejected(
                local_arguments=local_arguments,
                finalize_arguments=finalize_arguments,
                trusted_ci_event=event,
            )
        )
    finally:
        _restore_local_advisory_probe(repo, local_originals)

    _git(repo, "branch", "-f", "main", head)
    try:
        negative_observations["base_movement"] = _observe_authorization_failure(
            lambda: task_start(**start_arguments)
        )
    finally:
        _git(repo, "branch", "-f", "main", base)

    if not isinstance(attempt_event, Mapping) or not isinstance(attempt_approvals, list):
        raise BenchmarkError(
            "BENCHMARK_NEGATIVE_INVALID", "workflow-attempt evidence is malformed"
        )
    attempt_observation = _observe_authorization_failure(
        lambda: task_finalize(
            **{
                **finalize_arguments,
                "trusted_event_data": attempt_event,
                "approval_attestations": attempt_approvals,
            }
        )
    )
    attempt_code = attempt_observation["code"]
    if attempt_code != "AUTH_EVENT_STALE":
        raise BenchmarkError(
            "BENCHMARK_WORKFLOW_ATTEMPT_REPLACEMENT",
            "signed workflow-run attempt replacement did not fail closed",
        )
    if not isinstance(replacement_event, Mapping) or not isinstance(
        replacement_approvals, list
    ):
        raise BenchmarkError(
            "BENCHMARK_NEGATIVE_INVALID", "head replacement evidence is malformed"
        )
    negative_observations["head_replacement"] = _observe_authorization_failure(
        lambda: task_finalize(
            **{
                **finalize_arguments,
                "trusted_event_data": replacement_event,
                "approval_attestations": replacement_approvals,
            }
        )
    )
    if not isinstance(final_diff_event, Mapping) or not isinstance(
        final_diff_approvals, list
    ):
        raise BenchmarkError(
            "BENCHMARK_NEGATIVE_INVALID", "final-diff evidence is malformed"
        )
    negative_observations["final_diff_drift"] = _observe_authorization_failure(
        lambda: task_finalize(
            **{
                **finalize_arguments,
                "trusted_event_data": final_diff_event,
                "approval_attestations": final_diff_approvals,
            }
        )
    )
    negative_observations["absent_finalization"] = _observe_benchmark_failure(
        lambda: _verify_absent_finalization(package, evidence_root)
    )
    failures = {
        case: observation["code"]
        for case, observation in negative_observations.items()
    }
    if failures != scenario.expected_failure_codes:
        raise BenchmarkError(
            "BENCHMARK_FAILURE_CODE",
            (
                f"negative case code mismatch for {scenario.scenario_id}: "
                f"observed={failures!r} expected={scenario.expected_failure_codes!r}"
            ),
        )
    dependency_codes = {}
    for label, field in (
        ("stale_source", "source_ownership_sha256"),
        ("stale_proof", "proof_state_sha256"),
        ("stale_skill", "skill_dependencies_sha256"),
    ):
        stale = dict(bindings)
        stale[field] = "0" * 64
        dependency_codes[label] = _observe_authorization_failure(
            lambda stale=stale: task_start(
                **{**start_arguments, "trusted_bindings": stale}
            )
        )["code"]
    if set(dependency_codes.values()) != {"AUTH_SNAPSHOT_STALE"}:
        raise BenchmarkError(
            "BENCHMARK_DEPENDENCY_FRESHNESS",
            "source, proof, or skill staleness did not fail closed",
        )
    regeneration = _verify_regenerated_scenario(
        package,
        evidence_root=evidence_root,
        source_root=source_root,
        scenario=scenario,
        intake=intake,
        original_base=base,
        original_head=head,
        _source_is_exact=_source_is_exact,
    )
    records = start["tree_delta"]["records"]
    evidence_bytes = {
        "handoff": _bounded_file_bytes(
            _safe_file(handoff_path, evidence_root, "BENCHMARK_EVIDENCE_PATH"),
            "BENCHMARK_EVIDENCE_PATH",
            _MAX_EVIDENCE_BYTES,
        ),
        "event": event_raw,
        "approvals": approvals_raw,
        "authorization": start_raw,
        "validations": validations_raw,
        "validation_artifact": artifact_bytes,
        "finalization": receipt_raw,
        "negative_validations": negatives_raw,
        "attempt_event": attempt_event_raw,
        "attempt_approvals": attempt_approvals_raw,
        "replacement_event": replacement_event_raw,
        "replacement_approvals": replacement_approvals_raw,
        "final_diff_event": final_diff_event_raw,
        "final_diff_approvals": final_diff_approvals_raw,
        "task_pack": task_pack_raw,
    }
    evidence_bytes.update(
        {
            f"validation_artifact:{command_id}": raw
            for command_id, raw in sorted(validation_artifacts.items())
        }
    )
    return {
        "schema_version": 1,
        "scenario_id": scenario.scenario_id,
        "status": "green",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "source_checkout": "detached-synthetic",
        "task_pack": {
            "status": "green",
            "sha256": hashlib.sha256(task_pack_raw).hexdigest(),
            "canon_sha": recomputed_task_pack["canon_sha"],
            "intake_sha": recomputed_task_pack["intake_sha"],
        },
        "regeneration": regeneration,
        "authorization_sha256": hashlib.sha256(start_raw).hexdigest(),
        "finalization_sha256": hashlib.sha256(receipt_raw).hexdigest(),
        "validation_artifact_sha256": hashlib.sha256(artifact_bytes).hexdigest(),
        "validation_artifact_sha256_by_command": {
            command_id: hashlib.sha256(raw).hexdigest()
            for command_id, raw in sorted(validation_artifacts.items())
        },
        "evidence_sha256": {
            key: hashlib.sha256(value).hexdigest()
            for key, value in sorted(evidence_bytes.items())
        },
        "computed_authorized_files": start["computed_authorized_files"],
        "exact_changed_files": receipt["exact_changed_files"],
        "tree_delta_digest": start["tree_delta"]["digest"],
        "tree_record_count": len(records),
        "raw_path_record_count": sum(
            record["path_display_utf8"] is None for record in records
        ),
        "approval_attestation_count": len(approvals),
        "validation_attestation_count": len(validations),
        "required_checks": start["computed_required_checks"],
        "claim_ceiling": receipt["claim_ceiling"],
        "failure_codes": failures,
        "negative_observations": negative_observations,
        "dependency_failure_codes": dependency_codes,
        "workflow_attempt_replacement_code": attempt_code,
    }


def _verify_regenerated_scenario(
    package: Path,
    *,
    evidence_root: Path,
    source_root: Path,
    scenario: ScenarioDefinition,
    intake: Mapping[str, object],
    original_base: str,
    original_head: str,
    _clean_repo: Path | None = None,
    _source_is_exact: bool = False,
) -> dict[str, object]:
    regeneration = _safe_directory(
        package / "regeneration", evidence_root, "BENCHMARK_REGENERATION"
    )
    artifact_repo = _safe_directory(
        regeneration / "repo", evidence_root, "BENCHMARK_REGENERATION"
    )
    if _clean_repo is None:
        artifact_head = _git_text(artifact_repo, "rev-parse", "HEAD")
        artifact_base = _git_text(artifact_repo, "rev-parse", "refs/heads/main")
        with tempfile.TemporaryDirectory(
            prefix=f"ambitions-benchmark-regenerated-{scenario.scenario_id}-"
        ) as directory:
            clean_repo = Path(directory) / "repo"
            _git(
                artifact_repo,
                "clone",
                "-q",
                "--no-hardlinks",
                "--no-checkout",
                str(artifact_repo),
                str(clean_repo),
            )
            _prepare_clean_scenario_checkout(
                clean_repo,
                head=artifact_head,
                base=artifact_base,
                scenario=scenario,
            )
            return _verify_regenerated_scenario(
                package,
                evidence_root=evidence_root,
                source_root=source_root,
                scenario=scenario,
                intake=intake,
                original_base=original_base,
                original_head=original_head,
                _clean_repo=clean_repo,
                _source_is_exact=_source_is_exact,
            )
    repo = _clean_repo
    event, _event_raw = _read_json_file(
        regeneration / "trusted-event.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    approvals, _approvals_raw = _read_json_file(
        regeneration / "approval-attestations.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    stored_pack, pack_raw = _read_json_file(
        regeneration / "task-pack.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    stored_authorization, authorization_raw = _read_json_file(
        regeneration / "task-authorization.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    validations, _validations_raw = _read_json_file(
        regeneration / "validation-attestations.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    stored_finalization, finalization_raw = _read_json_file(
        regeneration / "task-finalization.json",
        evidence_root,
        "BENCHMARK_REGENERATION",
    )
    if (
        not isinstance(event, Mapping)
        or not isinstance(approvals, list)
        or not isinstance(validations, list)
        or not validations
    ):
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated evidence is malformed"
        )
    _verify_event_git(repo, event)
    base = str(event["trusted_base_sha"])
    head = str(event["trusted_head_sha"])
    if (
        base == original_base
        or head == original_head
        or _git_text(repo, "rev-parse", "HEAD") != head
        or _git_text(repo, "rev-parse", "refs/heads/main") != base
    ):
        raise BenchmarkError(
            "BENCHMARK_REGENERATION",
            "base and head replacements were not independently regenerated",
        )
    try:
        recomputed_pack = _build_task_pack_from_exact_source(
            source_root,
            intake=intake,
            repository_sha=head,
            source_is_exact=_source_is_exact,
        )
    except Exception as exc:
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated TaskPack projection failed"
        ) from exc
    if (
        not isinstance(stored_pack, Mapping)
        or canonical_json_bytes(recomputed_pack) != pack_raw
    ):
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated TaskPack is stale"
        )
    policy = load_base_policy(repo, base)
    bindings = load_trusted_bindings(repo, base, intake, policy)
    try:
        authorization = task_start(
            repo_root=repo,
            mode="ci-pr-range",
            intake_data=intake,
            trusted_event_data=event,
            trusted_bindings=bindings,
            policy_data=policy,
            approval_attestations=approvals,
            verification_epoch=int(event["verification_epoch"]),
        )
    except AuthorizationError as exc:
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated task start failed"
        ) from exc
    if (
        not isinstance(stored_authorization, Mapping)
        or canonical_json_bytes(authorization) != authorization_raw
    ):
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated authorization is stale"
        )
    validation_results = _recompute_benchmark_validation(
        repo,
        base,
        authorization,
        scenario,
    )
    _verify_validation_artifacts(
        regeneration,
        evidence_root=evidence_root,
        scenario=scenario,
        repo=repo,
        trusted_base_sha=base,
        validations=validations,
        validation_results=validation_results,
        error_code="BENCHMARK_REGENERATION",
    )
    try:
        finalization = task_finalize(
            repo_root=repo,
            authorization=authorization,
            intake_data=intake,
            trusted_event_data=event,
            trusted_bindings=bindings,
            policy_data=policy,
            approval_attestations=approvals,
            validation_attestations=validations,
            verification_epoch=int(event["verification_epoch"]),
        )
    except AuthorizationError as exc:
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated finalization failed"
        ) from exc
    if (
        not isinstance(stored_finalization, Mapping)
        or canonical_json_bytes(finalization) != finalization_raw
    ):
        raise BenchmarkError(
            "BENCHMARK_REGENERATION", "regenerated finalization is stale"
        )
    return {
        "status": "green",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "task_pack_sha256": hashlib.sha256(pack_raw).hexdigest(),
        "authorization_sha256": hashlib.sha256(authorization_raw).hexdigest(),
        "finalization_sha256": hashlib.sha256(finalization_raw).hexdigest(),
    }


def _build_task_pack_from_exact_source(
    source_root: Path,
    *,
    intake: Mapping[str, object],
    repository_sha: str,
    source_is_exact: bool = False,
) -> dict[str, object]:
    if source_is_exact:
        return _build_task_pack_from_source_checkout(
            source_root,
            intake=intake,
            repository_sha=repository_sha,
        )
    with detached_exact_source(source_root) as exact_source:
        return _build_task_pack_from_source_checkout(
            exact_source,
            intake=intake,
            repository_sha=repository_sha,
        )


def _build_task_pack_from_source_checkout(
    source_root: Path,
    *,
    intake: Mapping[str, object],
    repository_sha: str,
) -> dict[str, object]:
    manifest = load_manifest(source_root)
    registry = build_registry(
        manifest, load_documents(source_root, manifest)
    )
    return build_task_pack(
        registry,
        TaskIntake.from_authorization_intake(intake),
        repository_sha,
        [],
    ).to_dict()


def _run_task24_tree_matrix(
    source_root: Path, *, python_executable: str
) -> dict[str, object]:
    trusted_python = _trusted_matrix_python(python_executable)
    source_sha = _git_text(source_root, "rev-parse", "HEAD")
    source_tree = _git_text(source_root, "rev-parse", "HEAD^{tree}")
    verifier_root = Path(__file__).resolve().parents[2]
    verifier_paths = (
        "tests/canon/test_authorization.py",
        "tools/ambitions_canon/authorization.py",
    )
    verifier_digests = {
        relative: hashlib.sha256(
            _bounded_file_bytes(
                verifier_root / relative,
                "BENCHMARK_TASK24_MATRIX",
                _MAX_TRUSTED_INPUT_BYTES,
            )
        ).hexdigest()
        for relative in verifier_paths
    }
    test_names = (
        "tests.canon.test_authorization.DeterminismAndTreeDeltaTests.test_tree_delta_preserves_raw_paths_modes_objects_and_opaque_blobs",
        "tests.canon.test_authorization.DeterminismAndTreeDeltaTests.test_tree_delta_supports_merge_commits_and_submodule_gitlinks",
    )
    runner = (
        "import io,json,sys,unittest;"
        "root=sys.argv[1];names=json.loads(sys.argv[2]);sys.path.insert(0,root);"
        "suite=unittest.defaultTestLoader.loadTestsFromNames(names);"
        "result=unittest.TextTestRunner(stream=io.StringIO(),verbosity=0).run(suite);"
        "payload={'executed_test_count':result.testsRun,'python_version':"
        "f'{sys.version_info.major}.{sys.version_info.minor}','python_implementation':"
        "sys.implementation.name,'status':"
        "'green' if result.wasSuccessful() else 'red','test_ids':names};"
        "print(json.dumps(payload,sort_keys=True,separators=(',',':')));"
        "sys.exit(0 if result.wasSuccessful() and result.testsRun==len(names) else 1)"
    )
    try:
        completed = subprocess.run(
            [
                trusted_python,
                "-I",
                "-c",
                runner,
                str(verifier_root),
                json.dumps(list(test_names), separators=(",", ":")),
            ],
            cwd=verifier_root,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=_trusted_execution_environment(),
            timeout=300,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise BenchmarkError(
            "BENCHMARK_TASK24_MATRIX", "verifier-owned Task 24 matrix failed"
        ) from exc
    if completed.returncode != 0:
        raise BenchmarkError(
            "BENCHMARK_TASK24_MATRIX", "SHA-bound Task 24 matrix failed"
        )
    try:
        execution_proof = json.loads(completed.stdout.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(
            "BENCHMARK_TASK24_MATRIX", "Task 24 execution proof is invalid"
        ) from exc
    expected_execution_proof = {
        "executed_test_count": len(test_names),
        "python_implementation": "cpython",
        "python_version": "3.12",
        "status": "green",
        "test_ids": list(test_names),
    }
    if execution_proof != expected_execution_proof:
        raise BenchmarkError(
            "BENCHMARK_TASK24_MATRIX", "Task 24 execution proof is incomplete"
        )
    synthetic_merge = _prove_detached_merge_checkout()
    return {
        "schema_version": 1,
        "status": "green",
        "source_sha": source_sha,
        "source_tree_sha": source_tree,
        "verifier_file_sha256": dict(sorted(verifier_digests.items())),
        "test_ids": list(test_names),
        "python_implementation": execution_proof["python_implementation"],
        "python_version": execution_proof["python_version"],
        "executed_test_count": execution_proof["executed_test_count"],
        "covered_cases": [
            "copy-as-add",
            "delete-add-move",
            "deletions",
            "gitlinks",
            "merge-commits",
            "mode-only",
            "opaque-blobs",
            "symlinks",
            "synthetic-merge-checkout",
        ],
        "checkout_kind": "detached-merge-commit",
        "synthetic_merge": synthetic_merge,
    }


def _trusted_matrix_python(python_executable: str) -> str:
    """Accept only this verifier's exact trusted CPython 3.12 executable."""

    if (
        sys.implementation.name != "cpython"
        or sys.version_info[:2] != _TRUSTED_PYTHON_VERSION
    ):
        raise BenchmarkError(
            "BENCHMARK_PYTHON_RUNTIME",
            "Task 24 matrix requires trusted CPython 3.12",
        )
    try:
        candidate = Path(python_executable).resolve(strict=True)
        trusted = Path(sys.executable).resolve(strict=True)
    except OSError as exc:
        raise BenchmarkError(
            "BENCHMARK_PYTHON_RUNTIME",
            "Task 24 matrix Python executable is unavailable",
        ) from exc
    if candidate != trusted or not os.access(candidate, os.X_OK):
        raise BenchmarkError(
            "BENCHMARK_PYTHON_RUNTIME",
            "Task 24 matrix rejects an untrusted Python executable",
        )
    return str(trusted)


def _prove_detached_merge_checkout() -> dict[str, str]:
    with tempfile.TemporaryDirectory(prefix="ambitions-tree-matrix-") as directory:
        repo = Path(directory)
        _git(repo, "init", "-q")
        _git(repo, "config", "user.name", "Gate B Matrix")
        _git(repo, "config", "user.email", "matrix@example.invalid")
        (repo / "old.txt").write_bytes(b"same bytes\n")
        _git(repo, "add", "old.txt")
        _git(repo, "commit", "-qm", "base")
        base = _git_text(repo, "rev-parse", "HEAD")
        primary_branch = _git_text(repo, "symbolic-ref", "--short", "HEAD")
        _git(repo, "checkout", "-q", "-b", "feature")
        (repo / "old.txt").rename(repo / "new.txt")
        _git(repo, "add", "-A")
        _git(repo, "commit", "-qm", "feature delete add")
        _git(repo, "checkout", "-q", primary_branch)
        (repo / "main.txt").write_bytes(b"main side\n")
        _git(repo, "add", "main.txt")
        _git(repo, "commit", "-qm", "main side")
        _git(repo, "merge", "-q", "--no-ff", "feature", "-m", "synthetic merge")
        merge = _git_text(repo, "rev-parse", "HEAD")
        parents = _git_text(repo, "rev-list", "--parents", "-n", "1", merge).split()
        if len(parents) != 3:
            raise BenchmarkError(
                "BENCHMARK_TASK24_MATRIX", "synthetic merge has no two parents"
            )
        checkout = Path(directory) / "detached-checkout"
        _git(repo, "clone", "-q", "--no-hardlinks", str(repo), str(checkout))
        _git(checkout, "checkout", "-q", "--detach", merge)
        delta = canonical_tree_delta(checkout, base, merge)
        observed = [
            (record["path_display_utf8"], record["status"])
            for record in delta["records"]
        ]
        if ("new.txt", "added") not in observed or ("old.txt", "deleted") not in observed:
            raise BenchmarkError(
                "BENCHMARK_TASK24_MATRIX", "delete/add move proof failed"
            )
        return {
            "parent_count": "2",
            "merge_tree_sha": _git_text(checkout, "rev-parse", "HEAD^{tree}"),
        }


def _local_event(repo: Path, event: Mapping[str, object]) -> dict[str, object]:
    local = dict(event)
    local.update(
        {
            "event_attestation_origin": "local-advisory",
            "workflow_run_id": 0,
            "workflow_run_attempt": 0,
            "trust_anchor_id": None,
            "trust_anchor_sha256": None,
            "signature_algorithm": None,
            "signature_base64url": None,
            "trusted_head_sha": _git_text(repo, "rev-parse", "HEAD"),
        }
    )
    local["event_projection_digest"] = trusted_event_projection_digest(local)
    return local


def _verify_event_git(repo: Path, event: Mapping[str, object]) -> None:
    required = (
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "base_ref",
    )
    if any(not isinstance(event.get(field), str) for field in required):
        raise BenchmarkError("BENCHMARK_EVENT_INVALID", "event Git fields are invalid")
    base = str(event["trusted_base_sha"])
    head = str(event["trusted_head_sha"])
    merge = str(event["merge_base_sha"])
    for revision in (base, head, merge):
        if _git_text(repo, "cat-file", "-t", revision) != "commit":
            raise BenchmarkError(
                "BENCHMARK_GIT_OBJECT", "event revision is not a commit"
            )
        _git_text(repo, "rev-parse", f"{revision}^{{tree}}")
    if _git_text(repo, "merge-base", base, head) != merge:
        raise BenchmarkError(
            "BENCHMARK_GIT_MERGE_BASE", "event merge base is not recomputable"
        )
    if _git_text(repo, "rev-parse", str(event["base_ref"])) != base:
        raise BenchmarkError(
            "BENCHMARK_GIT_BASE_REF", "event base ref does not resolve to base"
        )


def _observe_authorization_failure(action) -> dict[str, str]:
    try:
        action()
    except AuthorizationError as exc:
        return {"code": exc.code, "observer": "task24-authorization"}
    raise BenchmarkError(
        "BENCHMARK_NEGATIVE_AUTHORIZED", "negative authorization case succeeded"
    )


def _observe_benchmark_failure(action) -> dict[str, str]:
    try:
        action()
    except BenchmarkError as exc:
        return {"code": exc.code, "observer": "benchmark-evidence-verifier"}
    raise BenchmarkError(
        "BENCHMARK_NEGATIVE_AUTHORIZED", "negative benchmark case succeeded"
    )


def _verify_local_substitution_rejected(
    *,
    local_arguments: Mapping[str, object],
    finalize_arguments: Mapping[str, object],
    trusted_ci_event: Mapping[str, object],
) -> None:
    local_start = task_start(**local_arguments)
    if (
        local_start.get("authority_class") != "advisory-local"
        or local_start.get("merge_authorized") is not False
    ):
        raise BenchmarkError(
            "BENCHMARK_LOCAL_SUBSTITUTION",
            "local authorization did not remain advisory-only",
        )
    local_finalization = task_finalize(
        **{
            **{
                key: value
                for key, value in local_arguments.items()
                if key != "mode"
            },
            "authorization": local_start,
            "validation_attestations": (),
        }
    )
    if (
        local_finalization.get("authority_class")
        != "advisory-local-finalization"
        or local_finalization.get("merge_authorized") is not False
        or local_finalization.get("exact_diff_authorized") is not True
    ):
        raise BenchmarkError(
            "BENCHMARK_LOCAL_SUBSTITUTION",
            "local finalization did not remain advisory-only",
        )
    observed = _observe_authorization_failure(
        lambda: task_finalize(
            **{
                **finalize_arguments,
                "authorization": local_start,
                "trusted_event_data": trusted_ci_event,
            }
        )
    )
    if not observed["code"].startswith("AUTH_"):
        raise BenchmarkError(
            "BENCHMARK_LOCAL_SUBSTITUTION", "CI did not reject local artifacts"
        )
    raise BenchmarkError(
        "AUTH_LOCAL_NOT_MERGE_AUTHORITY",
        "verified local authorization is advisory and rejected by CI finalization",
    )


def _apply_local_advisory_probe(
    repo: Path, scenario: ScenarioDefinition
) -> list[tuple[bytes, bytes | None]]:
    originals: list[tuple[bytes, bytes | None]] = []
    root = os.fsencode(repo)
    operation_content: dict[str, bytes] = {}
    for operation in scenario.operations:
        if operation["kind"] == "write":
            operation_content[str(operation["path"])] = str(
                operation["content"]
            ).encode("utf-8")
        else:
            display = "raw-base64url:" + str(operation["path_raw_base64url"])
            operation_content[display] = _base64url(
                str(operation["content_base64url"]), "operation content"
            )
    for requested in scenario.requested_changed_files:
        if requested.startswith("raw-base64url:"):
            relative = _base64url(requested.removeprefix("raw-base64url:"), "path")
            content = operation_content[requested] + b"local-advisory-probe\n"
            object_id = _git(
                repo, "hash-object", "-w", "--stdin", input_bytes=content
            ).strip()
            _git(
                repo,
                "update-index",
                "-z",
                "--index-info",
                input_bytes=b"100644 blob " + object_id + b"\t" + relative + b"\0",
            )
            _git(repo, b"update-index", b"--skip-worktree", b"--", relative)
            originals.append((relative, None))
            continue
        else:
            relative = requested.encode("utf-8")
        absolute = root + b"/" + relative
        try:
            with open(absolute, "rb") as handle:
                raw = handle.read()
            with open(absolute, "wb") as handle:
                handle.write(raw + b"local-advisory-probe\n")
        except OSError as exc:
            raise BenchmarkError(
                "BENCHMARK_LOCAL_SUBSTITUTION", "cannot prepare advisory local diff"
            ) from exc
        originals.append((absolute, raw))
    return originals


def _restore_local_advisory_probe(
    repo: Path, originals: list[tuple[bytes, bytes | None]]
) -> None:
    for absolute, raw in originals:
        if raw is not None:
            with open(absolute, "wb") as handle:
                handle.write(raw)
    _git(repo, "read-tree", "HEAD")
    for relative, raw in originals:
        if raw is None:
            _git(repo, b"update-index", b"--skip-worktree", b"--", relative)
    if _git_text(repo, "status", "--porcelain=v1"):
        raise BenchmarkError(
            "BENCHMARK_LOCAL_SUBSTITUTION", "advisory local probe did not restore"
        )


def _verify_absent_finalization(package: Path, evidence_root: Path) -> None:
    _read_json_file(
        package / "absent-finalization.json",
        evidence_root,
        "BENCHMARK_FINALIZATION_MISSING",
    )


def _read_json_file(
    path: Path, evidence_root: Path, error_code: str
) -> tuple[object, bytes]:
    try:
        safe = _safe_file(path, evidence_root, error_code)
        raw = _bounded_file_bytes(safe, error_code, _MAX_EVIDENCE_BYTES)
        data = json.loads(raw.decode("utf-8"))
    except BenchmarkError:
        raise
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(error_code, f"cannot read {path.name}") from exc
    if raw != canonical_json_bytes(data):
        raise BenchmarkError(error_code, f"non-canonical evidence: {path.name}")
    return data, raw


def _bounded_file_bytes(path: Path, error_code: str, limit: int) -> bytes:
    try:
        if path.stat().st_size >= limit:
            raise BenchmarkError(error_code, f"bounded input is too large: {path.name}")
        with path.open("rb") as handle:
            raw = handle.read(limit)
    except BenchmarkError:
        raise
    except OSError as exc:
        raise BenchmarkError(error_code, f"cannot read {path.name}") from exc
    if len(raw) >= limit:
        raise BenchmarkError(error_code, f"bounded input is too large: {path.name}")
    return raw


def _safe_git_checkout(path: Path) -> Path:
    repo = path.resolve(strict=True)
    try:
        if _git_text(repo, "rev-parse", "--is-inside-work-tree") != "true":
            raise BenchmarkError("BENCHMARK_GIT_REPOSITORY", "not a Git checkout")
    except (OSError, subprocess.CalledProcessError) as exc:
        raise BenchmarkError(
            "BENCHMARK_GIT_REPOSITORY", "Git checkout is unavailable"
        ) from exc
    return repo


def _safe_directory(path: Path, root: Path, error_code: str) -> Path:
    candidate = _confined_path(path, root, error_code)
    if not candidate.is_dir():
        raise BenchmarkError(error_code, "evidence directory is unavailable")
    return candidate


def _safe_file(path: Path, root: Path, error_code: str) -> Path:
    candidate = _confined_path(path, root, error_code)
    if not candidate.is_file():
        raise BenchmarkError(error_code, "evidence file is unavailable")
    return candidate


def _confined_path(path: Path, root: Path, error_code: str) -> Path:
    try:
        root_path = root.absolute()
        if root_path.is_symlink():
            raise BenchmarkError(error_code, "evidence root cannot be a symlink")
        candidate = path if path.is_absolute() else root_path / path
        candidate = candidate.absolute()
        relative = candidate.relative_to(root_path)
        current = root_path
        for part in relative.parts:
            current = current / part
            if current.is_symlink():
                raise BenchmarkError(error_code, "symlink evidence is forbidden")
        root_resolved = root_path.resolve(strict=True)
        resolved = candidate.resolve(strict=True)
        resolved.relative_to(root_resolved)
        return resolved
    except BenchmarkError:
        raise
    except (OSError, ValueError) as exc:
        raise BenchmarkError(error_code, "evidence path escapes its root") from exc


def _prepare_clean_scenario_checkout(
    repo: Path,
    *,
    head: str,
    base: str,
    scenario: ScenarioDefinition,
) -> None:
    _git(repo, "update-ref", "--no-deref", "HEAD", head)
    _git(repo, "read-tree", head)
    for requested in scenario.requested_changed_files:
        if requested.startswith("raw-base64url:"):
            raw = _base64url(requested.removeprefix("raw-base64url:"), "path")
            _git(repo, b"update-index", b"--skip-worktree", b"--", raw)
    _git(repo, "checkout-index", "-a")
    _git(repo, "branch", "-f", "main", base)
    if _git_text(repo, "status", "--porcelain=v1"):
        raise BenchmarkError(
            "BENCHMARK_SYNTHETIC_CHECKOUT", "clean verifier checkout is not clean"
        )


def _git(
    repo: Path,
    *arguments: str | bytes,
    input_bytes: bytes | None = None,
) -> bytes:
    try:
        with tempfile.TemporaryDirectory(prefix="ambitions-benchmark-git-home-") as home:
            return subprocess.run(
                [
                    "git",
                    "-c",
                    "core.hooksPath=/dev/null",
                    "-c",
                    "core.fsmonitor=false",
                    "-c",
                    "core.pager=cat",
                    *arguments,
                ],
                cwd=repo,
                env=_trusted_git_environment(Path(home)),
                input=input_bytes,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=_SUBPROCESS_TIMEOUT_SECONDS,
            ).stdout
    except (OSError, subprocess.SubprocessError) as exc:
        display = " ".join(os.fsdecode(argument) for argument in arguments)
        raise BenchmarkError(
            "BENCHMARK_GIT", f"Git command failed: {display}"
        ) from exc


def _trusted_git_environment(home: Path) -> dict[str, str]:
    environment = {
        key: os.environ[key]
        for key in ("PATH", "SYSTEMROOT", "TMPDIR", "WINDIR")
        if key in os.environ
    }
    environment.update(
        {
            "GIT_AUTHOR_DATE": "2026-07-14T12:00:00+00:00",
            "GIT_COMMITTER_DATE": "2026-07-14T12:00:00+00:00",
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_TERMINAL_PROMPT": "0",
            "HOME": str(home),
            "LANG": "C",
            "LC_ALL": "C",
            "PYTHONHASHSEED": "0",
            "TZ": "UTC",
        }
    )
    return environment


def _git_text(repo: Path, *arguments: str) -> str:
    try:
        return _git(repo, *arguments).decode("ascii", errors="strict").strip()
    except UnicodeError as exc:
        raise BenchmarkError("BENCHMARK_GIT", "Git output is not ASCII") from exc


def _base64url_encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _recompute_benchmark_validation(
    repo: Path,
    trusted_base_sha: str,
    authorization: Mapping[str, object],
    scenario: ScenarioDefinition,
) -> dict[str, dict[str, object]]:
    """Rebuild benchmark validation bytes without executing subject code."""

    try:
        manifest = json.loads(
            _git(
                repo,
                "show",
                f"{trusted_base_sha}:docs/canon/references/validation-command-manifest.json",
            ).decode("utf-8")
        )
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_MANIFEST", "base command manifest is invalid"
        ) from exc
    commands = manifest.get("commands") if isinstance(manifest, Mapping) else None
    if not isinstance(commands, list):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_MANIFEST", "base command list is invalid"
        )
    required = authorization.get("computed_required_checks")
    digests = authorization.get("computed_command_digests")
    proof_bindings = authorization.get("computed_proof_command_bindings")
    primary_command = scenario.required_checks[0]
    independent_command = "benchmark-independent-review"
    expected_commands = {primary_command, independent_command}
    if (
        not isinstance(required, list)
        or set(required) != expected_commands
        or len(scenario.required_checks) != 1
        or not isinstance(digests, Mapping)
        or not isinstance(proof_bindings, Mapping)
        or proof_bindings.get(primary_command)
        != sorted(
            proof_id
            for proof_id in scenario.proof_obligations
            if proof_id != "independent-review"
        )
        or proof_bindings.get(independent_command) != ["independent-review"]
    ):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_BINDING", "benchmark validation set is not exact"
        )
    by_id = {
        item.get("command_id"): item
        for item in commands
        if isinstance(item, Mapping) and isinstance(item.get("command_id"), str)
    }
    results: dict[str, dict[str, object]] = {}
    for command_id in sorted(expected_commands):
        command = by_id.get(command_id)
        if not isinstance(command, Mapping):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_MANIFEST", f"missing command: {command_id}"
            )
        argv = command.get("argv")
        if not isinstance(argv, list) or not argv or any(
            not isinstance(item, str) or not item for item in argv
        ):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_MANIFEST", f"invalid argv: {command_id}"
            )
        argv_digest = hashlib.sha256(canonical_json_bytes(argv)).hexdigest()
        if digests.get(command_id) != argv_digest:
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_BINDING", f"argv digest changed: {command_id}"
            )
        if command_id == primary_command:
            payload = _expected_substantive_validation_payload(
                scenario=scenario,
                repo=repo,
                trusted_base_sha=trusted_base_sha,
            )
        else:
            payload = {
                "schema_version": 1,
                "scenario_id": scenario.scenario_id,
                "review_kind": "independent-policy-review",
                "status": "green",
            }
        artifact = canonical_json_bytes(
            {
                "schema_version": 1,
                "command_id": command_id,
                "argv": argv,
                "exit_status": 0,
                "stdout_base64url": _base64url_encode(canonical_json_bytes(payload)),
                "stderr_base64url": "",
            }
        )
        results[command_id] = {
            "artifact_bytes": artifact,
            "artifact_digest": hashlib.sha256(artifact).hexdigest(),
            "exit_status": 0,
        }
    return results


def _expected_substantive_validation_payload(
    *,
    scenario: ScenarioDefinition,
    repo: Path,
    trusted_base_sha: str,
) -> dict[str, object]:
    expected_subjects: dict[str, str] = {}
    expected_paths: list[str] = []
    for operation in scenario.operations:
        if operation["kind"] == "write":
            display = str(operation["path"])
            content = str(operation["content"]).encode("utf-8")
        else:
            display = "raw-base64url:" + str(operation["path_raw_base64url"])
            content = _base64url(
                str(operation["content_base64url"]), "operation content"
            )
        expected_paths.append(display)
        expected_subjects[display] = hashlib.sha256(content).hexdigest()
    try:
        registry = json.loads(
            _git(
                repo,
                "show",
                f"{trusted_base_sha}:docs/canon/references/skill-dependencies.json",
            ).decode("utf-8")
        )
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_SEMANTICS", "base skill registry is malformed"
        ) from exc
    if not isinstance(registry, Mapping) or not isinstance(registry.get("skills"), list):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_SEMANTICS", "base skill registry is malformed"
        )
    skills = {
        item.get("skill_id"): item
        for item in registry["skills"]
        if isinstance(item, Mapping)
    }
    expected_skill_digests: dict[str, str] = {}
    for skill_id in scenario.skill_adapters:
        entry = skills.get(skill_id)
        if not isinstance(entry, Mapping) or not isinstance(entry.get("path"), str):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_SEMANTICS", "required skill contract is absent"
            )
        raw = _git(repo, "show", f"{trusted_base_sha}:{entry['path']}")
        digest = hashlib.sha256(raw).hexdigest()
        if digest != entry.get("skill_sha256"):
            raise BenchmarkError(
                "BENCHMARK_VALIDATION_SEMANTICS", "required skill contract is stale"
            )
        expected_skill_digests[skill_id] = digest
    return {
        "schema_version": 1,
        "scenario_id": scenario.scenario_id,
        "validator_kind": "exact-subject-and-retained-skill-contract",
        "subject_path": expected_paths,
        "subject_sha256": expected_subjects,
        "skill_contract_sha256": expected_skill_digests,
        "status": "green",
    }


def _verify_substantive_validation_payload(
    artifact_bytes: bytes,
    *,
    scenario: ScenarioDefinition,
    repo: Path,
    trusted_base_sha: str,
) -> None:
    try:
        envelope = json.loads(artifact_bytes.decode("utf-8"))
        encoded = envelope["stdout_base64url"]
        if not isinstance(encoded, str):
            raise ValueError
        stdout = base64.b64decode(
            encoded + "=" * (-len(encoded) % 4), altchars=b"-_", validate=True
        )
        payload = json.loads(stdout.decode("utf-8"))
        if stdout != canonical_json_bytes(payload):
            raise ValueError
    except (KeyError, TypeError, ValueError, UnicodeError, json.JSONDecodeError) as exc:
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_SEMANTICS",
            "validation output is not a canonical substantive observation",
        ) from exc
    expected = _expected_substantive_validation_payload(
        scenario=scenario,
        repo=repo,
        trusted_base_sha=trusted_base_sha,
    )
    expected_keys = {
        "schema_version",
        "scenario_id",
        "validator_kind",
        "subject_path",
        "subject_sha256",
        "skill_contract_sha256",
        "status",
    }
    if (
        not isinstance(payload, Mapping)
        or set(payload) != expected_keys
        or payload != expected
    ):
        raise BenchmarkError(
            "BENCHMARK_VALIDATION_SEMANTICS",
            "validation output is not bound to exact subject and skill bytes",
        )


def _verify_validation_artifacts(
    artifact_root: Path,
    *,
    evidence_root: Path,
    scenario: ScenarioDefinition,
    repo: Path,
    trusted_base_sha: str,
    validations: Sequence[object],
    validation_results: Mapping[str, Mapping[str, object]],
    error_code: str,
) -> dict[str, bytes]:
    by_command: dict[str, Mapping[str, object]] = {}
    for validation in validations:
        if not isinstance(validation, Mapping):
            raise BenchmarkError(error_code, "validation attestation is malformed")
        command_id = validation.get("command_id")
        if not isinstance(command_id, str) or not command_id:
            raise BenchmarkError(error_code, "validation command id is malformed")
        if command_id in by_command:
            raise BenchmarkError(error_code, "validation command is duplicated")
        by_command[command_id] = validation
    if set(by_command) != set(validation_results):
        raise BenchmarkError(
            error_code, "validation evidence differs from the base-owned command set"
        )

    artifacts: dict[str, bytes] = {}
    for command_id, result in sorted(validation_results.items()):
        validation = by_command[command_id]
        artifact = _bounded_file_bytes(
            _safe_file(
                artifact_root / f"validation-artifacts/{command_id}.bin",
                evidence_root,
                error_code,
            ),
            error_code,
            _MAX_EVIDENCE_BYTES,
        )
        if (
            artifact != result["artifact_bytes"]
            or hashlib.sha256(artifact).hexdigest()
            != validation.get("artifact_digest")
        ):
            raise BenchmarkError(
                error_code,
                "validation output bytes do not match execution and attestation",
            )
        artifacts[command_id] = artifact

    primary_command = scenario.required_checks[0]
    primary_artifact = artifacts.get(primary_command)
    if primary_artifact is None:
        raise BenchmarkError(error_code, "primary validation evidence is absent")
    _verify_substantive_validation_payload(
        primary_artifact,
        scenario=scenario,
        repo=repo,
        trusted_base_sha=trusted_base_sha,
    )
    if (
        len({hashlib.sha256(raw).digest() for raw in artifacts.values()})
        != len(artifacts)
    ):
        raise BenchmarkError(
            error_code, "independent review must use a distinct evidence artifact"
        )
    return artifacts


def _validate_scenario(data: object, source: str) -> ScenarioDefinition:
    if not isinstance(data, Mapping) or set(data) != _SCENARIO_FIELDS:
        raise BenchmarkError(
            "BENCHMARK_FIXTURE_FIELDS", f"closed fields mismatch in {source}"
        )
    if data["schema_version"] != 1:
        raise BenchmarkError(
            "BENCHMARK_FIXTURE_VERSION", f"unsupported fixture version in {source}"
        )
    scenario_id = _text(data["scenario_id"], "scenario_id")
    title = _text(data["title"], "title")
    task_type = _text(data["task_type"], "task_type")
    scope = _strings(data["scope"], "scope")
    requirement_ids = _strings(data["requirement_ids"], "requirement_ids")
    requested_files = _strings(
        data["requested_changed_files"], "requested_changed_files"
    )
    required_checks = _strings(data["required_checks"], "required_checks")
    proof_obligations = _strings(
        data["proof_obligations"], "proof_obligations"
    )
    skill_adapters = _strings(
        data["skill_adapters"], "skill_adapters", allow_empty=True
    )
    claim_ceiling = _text(data["claim_ceiling"], "claim_ceiling")
    if isinstance(data["approval_required"], bool):
        approval_required = data["approval_required"]
    else:
        raise BenchmarkError(
            "BENCHMARK_FIXTURE_TYPE", "approval_required must be boolean"
        )
    operations_value = data["operations"]
    if not isinstance(operations_value, list) or not operations_value:
        raise BenchmarkError(
            "BENCHMARK_OPERATION", "operations must be a non-empty array"
        )
    operations: list[dict[str, str]] = []
    operation_paths: list[str] = []
    for operation in operations_value:
        if not isinstance(operation, Mapping):
            raise BenchmarkError(
                "BENCHMARK_OPERATION", "operation must be an object"
            )
        kind = operation.get("kind")
        if kind == "write" and set(operation) == _WRITE_FIELDS:
            path = _leaf_path(_text(operation["path"], "operation.path"))
            content = operation["content"]
            if not isinstance(content, str):
                raise BenchmarkError(
                    "BENCHMARK_OPERATION", "write content must be UTF-8 text"
                )
            operations.append({"kind": "write", "path": path, "content": content})
            operation_paths.append(path)
        elif kind == "write_raw" and set(operation) == _WRITE_RAW_FIELDS:
            raw_path_text = _text(
                operation["path_raw_base64url"], "operation.path_raw_base64url"
            )
            raw_path = _base64url(raw_path_text, "raw path")
            _raw_leaf_path(raw_path)
            content_text = _text(
                operation["content_base64url"], "operation.content_base64url"
            )
            _base64url(content_text, "raw content")
            operations.append(
                {
                    "kind": "write_raw",
                    "path_raw_base64url": raw_path_text,
                    "content_base64url": content_text,
                }
            )
            operation_paths.append(f"raw-base64url:{raw_path_text}")
        else:
            raise BenchmarkError(
                "BENCHMARK_OPERATION", "operation fields or kind are unsupported"
            )
    for requested in requested_files:
        if requested.startswith("raw-base64url:"):
            raw = _base64url(requested.removeprefix("raw-base64url:"), "requested raw path")
            _raw_leaf_path(raw)
        else:
            _leaf_path(requested)
    if tuple(sorted(operation_paths)) != requested_files:
        raise BenchmarkError(
            "BENCHMARK_OPERATION_SCOPE",
            "requested changed files must equal exact operation leaf paths",
        )
    failures = data["expected_failure_codes"]
    if not isinstance(failures, Mapping) or set(failures) != _FAILURE_CASES:
        raise BenchmarkError(
            "BENCHMARK_FAILURE_SET", "negative case set is incomplete"
        )
    normalized_failures = {
        key: _text(failures[key], f"expected_failure_codes.{key}")
        for key in sorted(failures)
    }
    return ScenarioDefinition(
        schema_version=1,
        scenario_id=scenario_id,
        title=title,
        task_type=task_type,
        scope=scope,
        requirement_ids=requirement_ids,
        requested_changed_files=requested_files,
        operations=tuple(operations),
        required_checks=required_checks,
        proof_obligations=proof_obligations,
        skill_adapters=skill_adapters,
        claim_ceiling=claim_ceiling,
        approval_required=approval_required,
        expected_failure_codes=normalized_failures,
    )


def _leaf_path(value: str) -> str:
    if value.endswith("/"):
        raise BenchmarkError(
            "BENCHMARK_DIRECTORY_AUTHORIZATION", "directory authorization is forbidden"
        )
    path = PurePosixPath(value)
    if path.is_absolute() or not path.parts or any(part in {"", ".", ".."} for part in path.parts):
        raise BenchmarkError("BENCHMARK_PATH", "operation path is not canonical")
    return path.as_posix()


def _raw_leaf_path(value: bytes) -> None:
    if not value or value.startswith(b"/") or value.endswith(b"/") or b"\x00" in value:
        raise BenchmarkError("BENCHMARK_PATH", "raw operation path is not a leaf")
    if any(part in {b"", b".", b".."} for part in value.split(b"/")):
        raise BenchmarkError("BENCHMARK_PATH", "raw operation path is not canonical")


def _base64url(value: str, label: str) -> bytes:
    if not value or any(character not in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_" for character in value):
        raise BenchmarkError("BENCHMARK_BASE64URL", f"{label} is not base64url")
    try:
        decoded = base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
    except (ValueError, TypeError) as exc:
        raise BenchmarkError("BENCHMARK_BASE64URL", f"{label} is invalid") from exc
    if base64.urlsafe_b64encode(decoded).rstrip(b"=").decode("ascii") != value:
        raise BenchmarkError("BENCHMARK_BASE64URL", f"{label} is non-canonical")
    return decoded


def _text(value: object, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise BenchmarkError("BENCHMARK_VALUE", f"{label} must be non-empty text")
    return value


def _strings(value: object, label: str, *, allow_empty: bool = False) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise BenchmarkError("BENCHMARK_VALUE", f"{label} must be an array")
    normalized = tuple(_text(item, label) for item in value)
    if normalized != tuple(sorted(set(normalized))):
        raise BenchmarkError("BENCHMARK_ORDER", f"{label} must be sorted and unique")
    return normalized
