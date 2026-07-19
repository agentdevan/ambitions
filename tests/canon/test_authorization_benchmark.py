from __future__ import annotations

import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ProcessPoolExecutor
from functools import partial
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

from tests.canon.test_authorization import resign, sign, write_json, write_trusted_state
from tools.ambitions_canon.authorization import (
    AuthorizationError,
    canonical_json_bytes,
    canonical_tree_delta,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
    task_start,
    trusted_event_projection_digest,
    validate_task_intake,
)
from tools.ambitions_canon.authorization_benchmark import (
    AUTHORIZATION_SCENARIO_IDS,
    BenchmarkError,
    canonical_benchmark_bytes,
    execute_base_owned_validations,
    detached_exact_source,
    handoff_to_task_intake,
    load_authorization_benchmark_scenarios,
    run_authorization_benchmark,
)
from tools.ambitions_canon import authorization_benchmark as benchmark_module
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.registry import build_registry
from tools.ambitions_canon.task_pack import TaskIntake, build_task_pack
ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "tests/canon/fixtures/authorization-benchmarks"
BENCHMARK_POLICY = (
    ROOT / "docs/canon/references/task-25-authorization-benchmark-policy.json"
)
VERIFICATION_EPOCH = 1_900_000_000
WORKFLOW_DIGEST = hashlib.sha256(
    b"name: Canon authorization test\n"
).hexdigest()
REPOSITORY_ID = "12345"
REPOSITORY_FULL_NAME = "agentdevan/ambitions"


def git(repo: Path, *arguments: str, input_bytes: bytes | None = None) -> str:
    environment = os.environ.copy()
    environment.update(
        {
            "GIT_AUTHOR_DATE": "2026-07-14T12:00:00+00:00",
            "GIT_COMMITTER_DATE": "2026-07-14T12:00:00+00:00",
        }
    )
    completed = subprocess.run(
        ["git", *arguments],
        cwd=repo,
        check=True,
        input=input_bytes,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=environment,
    )
    return completed.stdout.decode("ascii", errors="strict").strip()


def error_code(action) -> str:
    try:
        action()
    except AuthorizationError as exc:
        return exc.code
    raise AssertionError("negative authorization case unexpectedly authorized")


def intake_for(scenario) -> dict[str, object]:
    return {
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


def benchmark_policy_for(scenario) -> dict[str, object]:
    policy = json.loads(BENCHMARK_POLICY.read_text(encoding="utf-8"))
    matches = [
        item
        for item in policy["scenarios"]
        if item["scenario_id"] == scenario.scenario_id
    ]
    if len(matches) != 1:
        raise AssertionError(f"missing benchmark policy: {scenario.scenario_id}")
    profile = matches[0]
    expected = {
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
    if profile != expected:
        raise AssertionError(f"fixture drifted from benchmark policy: {scenario.scenario_id}")
    return profile


def task_pack_for(
    scenario,
    source_root: Path,
    *,
    repository_sha: str | None = None,
    source_is_exact: bool = False,
) -> dict[str, object]:
    if source_is_exact:
        return task_pack_from_source_checkout(
            scenario, source_root, repository_sha=repository_sha
        )
    with detached_exact_source(source_root) as exact_source:
        return task_pack_from_source_checkout(
            scenario, exact_source, repository_sha=repository_sha
        )


def task_pack_from_source_checkout(
    scenario, source_root: Path, *, repository_sha: str | None = None
) -> dict[str, object]:
    manifest = load_manifest(source_root)
    registry = build_registry(
        manifest, load_documents(source_root, manifest)
    )
    pack = build_task_pack(
        registry,
        TaskIntake.from_authorization_intake(intake_for(scenario)),
        repository_sha or git(source_root, "rev-parse", "HEAD"),
        [],
    )
    return pack.to_dict()


def rewrite_trusted_state(repo: Path, scenario) -> None:
    profile = benchmark_policy_for(scenario)
    intake = intake_for(scenario)
    issue_state = {
        "schema_version": 1,
        "snapshot_revision": "gate-b-issue-v1",
        "issues": [
            {
                "issue_reference": intake["issue_reference"],
                "state": "in_progress",
                "task_ids": [intake["task_id"]],
                "revision": "1",
                "prerequisite_task_ids": [],
            }
        ],
    }
    registry_path = repo / "docs/canon/references/skill-dependencies.json"
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    live_registry = json.loads(
        (ROOT / "docs/canon/references/skill-dependencies.json").read_text(
            encoding="utf-8"
        )
    )
    live_skills = {item["skill_id"]: item for item in live_registry["skills"]}
    skills: list[dict[str, object]] = []
    for skill_id in profile["skill_adapters"]:
        entry = json.loads(json.dumps(live_skills[skill_id]))
        for relative in [entry["path"], *(item["path"] for item in entry["dependencies"])]:
            target = repo / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((ROOT / relative).read_bytes())
        skills.append(entry)
    registry["skills"] = skills
    requirement_ids = sorted(
        {
            *scenario.requirement_ids,
            *(
                requirement_id
                for skill in skills
                for requirement_id in skill["requirement_ids"]
            ),
        }
    )
    requirement_index = {
        "requirements": [
            {"requirement_id": requirement_id}
            for requirement_id in requirement_ids
        ]
    }
    write_json(repo, "docs/canon/generated/canon-index.json", requirement_index)
    registry["requirement_index_sha256"] = hashlib.sha256(
        (repo / "docs/canon/generated/canon-index.json").read_bytes()
    ).hexdigest()
    write_json(repo, "docs/canon/references/skill-dependencies.json", registry)

    expected_subjects = []
    for operation in scenario.operations:
        if operation["kind"] == "write":
            path_bytes = operation["path"].encode("utf-8")
            content = operation["content"].encode("utf-8")
            display = operation["path"]
        else:
            path_bytes = base64.urlsafe_b64decode(
                operation["path_raw_base64url"]
                + "=" * (-len(operation["path_raw_base64url"]) % 4)
            )
            content = base64.urlsafe_b64decode(
                operation["content_base64url"]
                + "=" * (-len(operation["content_base64url"]) % 4)
            )
            display = "raw-base64url:" + operation["path_raw_base64url"]
        expected_subjects.append(
            (
                display,
                base64.urlsafe_b64encode(path_bytes).rstrip(b"=").decode("ascii"),
                hashlib.sha256(content).hexdigest(),
            )
        )
    expected_skills = [
        (skill["skill_id"], skill["path"], skill["skill_sha256"])
        for skill in skills
    ]

    command_manifest = {
        "schema_version": 1,
        "manifest_revision": "gate-b-commands-v1",
        "trusted_workflow": {
            "path": ".github/workflows/canon-authorization.yml",
            "ref": "refs/heads/main",
            "digest": WORKFLOW_DIGEST,
            "check_identity": "ambitions-canon-authorization",
            "integration_id": "github-actions",
            "app_id": "15368",
        },
        "commands": [
            {
                "command_id": profile["required_checks"][0],
                "argv": [
                    "python3",
                    "-c",
                    (
                        "import base64,hashlib,json,os,subprocess,sys;"
                        "sys.exit(97) if 'TASK25_SENTINEL_SECRET' in os.environ else None;"
                        f"subjects={expected_subjects!r};skills={expected_skills!r};"
                        "read=lambda p:subprocess.check_output([b'git',b'-c',b'core.hooksPath=/dev/null',b'show',b'HEAD:'+base64.urlsafe_b64decode(p+'='*(-len(p)%4))]);"
                        "subject_sha={d:hashlib.sha256(read(p)).hexdigest() for d,p,_ in subjects};"
                        "skill_sha={i:hashlib.sha256(open(p,'rb').read()).hexdigest() for i,p,_ in skills};"
                        "sys.exit(41) if subject_sha!={d:s for d,_p,s in subjects} else None;"
                        "sys.exit(42) if skill_sha!={i:s for i,_p,s in skills} else None;"
                        f"payload={{'schema_version':1,'scenario_id':'{scenario.scenario_id}',"
                        "'validator_kind':'exact-subject-and-retained-skill-contract',"
                        "'subject_path':[d for d,_p,_s in subjects],"
                        "'subject_sha256':subject_sha,'skill_contract_sha256':skill_sha,"
                        "'status':'green'};"
                        "print(json.dumps(payload,sort_keys=True,separators=(',',':')))"
                    ),
                ],
                "required_for_task_types": [scenario.task_type],
                "required_for_scenarios": list(scenario.scope),
                "proof_obligation_ids": [
                    proof_id
                    for proof_id in profile["proof_obligations"]
                    if proof_id != "independent-review"
                ],
                "evidence_class": "automated-validation",
            },
            {
                "command_id": "benchmark-independent-review",
                "argv": [
                    "python3",
                    "-c",
                    (
                        "import json;"
                        f"print(json.dumps({{'schema_version':1,'scenario_id':'{scenario.scenario_id}',"
                        "'review_kind':'independent-policy-review','status':'green'},"
                        "sort_keys=True,separators=(',',':')))"
                    ),
                ],
                "required_for_task_types": [scenario.task_type],
                "required_for_scenarios": [],
                "proof_obligation_ids": ["independent-review"],
                "evidence_class": "independent-review",
            },
        ],
    }
    write_json(
        repo,
        "docs/canon/references/validation-command-manifest.json",
        command_manifest,
    )

    policy_path = repo / "docs/canon/references/task-authorization-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["issue_state"] = issue_state
    policy["task_rules"] = [
        {
            "task_id": intake["task_id"],
            "issue_reference": intake["issue_reference"],
            "task_types": [profile["task_type"]],
            "scopes": list(profile["scope"]),
            "requirement_ids": list(profile["requirement_ids"]),
            "source_owner": "canon-gate-b-benchmark",
            "authorized_files": list(profile["authorized_files"]),
            "required_checks": list(profile["required_checks"]),
            "proof_obligations": list(profile["proof_obligations"]),
            "maximum_claim_ceiling": profile["maximum_claim_ceiling"],
            "approval_required": profile["approval_required"],
            "approval_policy_ids": ["owner-gate@1"],
        }
    ]
    write_json(repo, "docs/canon/references/task-authorization-policy.json", policy)


def apply_operations(repo: Path, scenario) -> None:
    raw_operations = []
    for operation in scenario.operations:
        if operation["kind"] == "write":
            target = repo / operation["path"]
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(operation["content"], encoding="utf-8")
        else:
            raw_operations.append(operation)
    git(repo, "add", "-A")
    for operation in raw_operations:
        raw_path = base64.urlsafe_b64decode(
            operation["path_raw_base64url"]
            + "=" * (-len(operation["path_raw_base64url"]) % 4)
        )
        content = base64.urlsafe_b64decode(
            operation["content_base64url"]
            + "=" * (-len(operation["content_base64url"]) % 4)
        )
        object_id = subprocess.run(
            ["git", "hash-object", "-w", "--stdin"],
            cwd=repo,
            check=True,
            input=content,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).stdout.strip()
        subprocess.run(
            ["git", "update-index", "-z", "--index-info"],
            cwd=repo,
            check=True,
            input=b"100644 blob " + object_id + b"\t" + raw_path + b"\0",
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )


def init_scenario_repo(repo: Path, scenario) -> tuple[str, str]:
    git(repo, "init", "-q")
    git(repo, "config", "user.name", "Gate B Benchmark")
    git(repo, "config", "user.email", "gate-b@example.invalid")
    (repo / "base-marker.txt").write_text("base\n", encoding="utf-8")
    write_trusted_state(
        repo,
        list(scenario.requested_changed_files),
        approval_required=scenario.approval_required,
    )
    rewrite_trusted_state(repo, scenario)
    git(repo, "add", "-A")
    git(repo, "commit", "-qm", "trusted base")
    base = git(repo, "rev-parse", "HEAD")
    git(repo, "branch", "main", base)
    apply_operations(repo, scenario)
    git(repo, "commit", "-qm", f"{scenario.scenario_id} head")
    return base, git(repo, "rev-parse", "HEAD")


def trusted_event(
    repo: Path,
    base: str,
    head: str,
    scenario,
    *,
    workflow_run_attempt: int = 1,
) -> dict[str, object]:
    policy = load_base_policy(repo, base)
    payload: dict[str, object] = {
        "schema_version": 1,
        "event_provider": "github",
        "event_attestation_origin": "trusted-ci",
        "repository_id": REPOSITORY_ID,
        "repository_full_name": REPOSITORY_FULL_NAME,
        "pull_request_number": 250,
        "base_ref": "refs/heads/main",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "merge_base_sha": git(repo, "merge-base", base, head),
        "verification_epoch": VERIFICATION_EPOCH,
        "workflow_run_id": 25001,
        "workflow_run_attempt": workflow_run_attempt,
        "consumption_generation": 1,
        "issue_state_transition": {
            "schema_version": 1,
            "snapshot_revision": "benchmark-issue-transition-v1",
            "base_issue_state_sha256": hashlib.sha256(
                canonical_json_bytes(policy["issue_state"])
            ).hexdigest(),
            "completed_task_receipts": [],
        },
    }
    payload["event_projection_digest"] = trusted_event_projection_digest(payload)
    return sign(payload)


def local_event(repo: Path, base: str, head: str) -> dict[str, object]:
    policy = load_base_policy(repo, base)
    payload: dict[str, object] = {
        "schema_version": 1,
        "event_provider": "github",
        "event_attestation_origin": "local-advisory",
        "repository_id": REPOSITORY_ID,
        "repository_full_name": REPOSITORY_FULL_NAME,
        "pull_request_number": 250,
        "base_ref": "refs/heads/main",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "merge_base_sha": git(repo, "merge-base", base, head),
        "verification_epoch": VERIFICATION_EPOCH,
        "workflow_run_id": 0,
        "workflow_run_attempt": 0,
        "consumption_generation": 1,
        "issue_state_transition": {
            "schema_version": 1,
            "snapshot_revision": "benchmark-local-empty-v1",
            "base_issue_state_sha256": hashlib.sha256(
                canonical_json_bytes(policy["issue_state"])
            ).hexdigest(),
            "completed_task_receipts": [],
        },
        "trust_anchor_id": None,
        "trust_anchor_sha256": None,
        "signature_algorithm": None,
        "signature_base64url": None,
    }
    payload["event_projection_digest"] = trusted_event_projection_digest(payload)
    return payload


def trusted_approval(
    scenario,
    event: dict[str, object],
    intake: dict[str, object],
    bindings: dict[str, object],
    *,
    suffix: str = "primary",
) -> dict[str, object]:
    return sign(
        {
            "schema_version": 1,
            "attestation_id": f"APPROVAL-{scenario.scenario_id}-{suffix}",
            "attestation_origin": "platform-authenticated",
            "repository_id": REPOSITORY_ID,
            "repository_full_name": REPOSITORY_FULL_NAME,
            "pull_request_number": event["pull_request_number"],
            "task_id": intake["task_id"],
            "intake_id": intake["intake_id"],
            "trusted_base_sha": event["trusted_base_sha"],
            "trusted_head_sha": event["trusted_head_sha"],
            "merge_base_sha": event["merge_base_sha"],
            "intake_digest": hashlib.sha256(
                canonical_json_bytes(validate_task_intake(intake))
            ).hexdigest(),
            "policy_revision": bindings["policy_revision"],
            "command_manifest_digest": bindings["command_manifest_sha256"],
            "workflow_path": ".github/workflows/canon-authorization.yml",
            "workflow_ref": "refs/heads/main",
            "workflow_digest": WORKFLOW_DIGEST,
            "workflow_run_id": event["workflow_run_id"],
            "workflow_run_attempt": event["workflow_run_attempt"],
            "event_projection_digest": event["event_projection_digest"],
            "consumption_generation": event["consumption_generation"],
            "check_identity": "ambitions-canon-authorization",
            "integration_id": "github-actions",
            "app_id": "15368",
            "approval_policy_id": "owner-gate",
            "approval_policy_revision": "1",
            "authenticated_principal": "owner:devan",
            "approved_scope": list(scenario.scope),
            "one_time_use_nonce": f"nonce-{scenario.scenario_id}-{suffix}",
            "verification_epoch": VERIFICATION_EPOCH,
            "consumed": False,
            "expires_at_epoch": 2_000_000_000,
            "revoked": False,
            "break_glass": False,
            "incident_id": None,
            "rollback_ref": None,
            "post_action_review_required": False,
        }
    )


def trusted_validation(
    scenario,
    event: dict[str, object],
    intake: dict[str, object],
    bindings: dict[str, object],
    authorization: dict[str, object],
    artifact_digest: str,
    *,
    command_id: str | None = None,
) -> dict[str, object]:
    command_id = command_id or scenario.required_checks[0]
    return sign(
        {
            "schema_version": 1,
            "attestation_id": f"VALIDATION-{scenario.scenario_id}-{command_id}",
            "attestation_origin": "trusted-ci",
            "pull_request_number": event["pull_request_number"],
            "task_id": intake["task_id"],
            "intake_id": intake["intake_id"],
            "intake_digest": authorization["intake_digest"],
            "policy_revision": bindings["policy_revision"],
            "authorization_digest": hashlib.sha256(
                canonical_json_bytes(authorization)
            ).hexdigest(),
            "command_manifest_digest": bindings["command_manifest_sha256"],
            "workflow_path": ".github/workflows/canon-authorization.yml",
            "workflow_ref": "refs/heads/main",
            "workflow_digest": WORKFLOW_DIGEST,
            "command_id": command_id,
            "command_argv_digest": authorization["computed_command_digests"][
                command_id
            ],
            "check_identity": "ambitions-canon-authorization",
            "repository_id": REPOSITORY_ID,
            "repository_full_name": REPOSITORY_FULL_NAME,
            "trusted_base_sha": event["trusted_base_sha"],
            "trusted_head_sha": event["trusted_head_sha"],
            "merge_base_sha": event["merge_base_sha"],
            "integration_id": "github-actions",
            "app_id": "15368",
            "exit_status": 0,
            "artifact_digest": artifact_digest,
            "proof_obligation_ids": authorization[
                "computed_proof_command_bindings"
            ][command_id],
            "skipped": False,
            "skipped_reason": None,
            "status": "green",
            "claim_ceiling": scenario.claim_ceiling,
            "ci_owned": True,
        }
    )


def write_validation_evidence(
    evidence_root: Path,
    scenario,
    event: dict[str, object],
    intake: dict[str, object],
    bindings: dict[str, object],
    authorization: dict[str, object],
    validation_results: dict[str, dict[str, object]],
) -> tuple[dict[str, object], ...]:
    attestations: list[dict[str, object]] = []
    for command_id, result in sorted(validation_results.items()):
        artifact_path = evidence_root / f"validation-artifacts/{command_id}.bin"
        artifact_path.parent.mkdir(parents=True, exist_ok=True)
        artifact_path.write_bytes(result["artifact_bytes"])
        attestations.append(
            trusted_validation(
                scenario,
                event,
                intake,
                bindings,
                authorization,
                str(result["artifact_digest"]),
                command_id=command_id,
            )
        )
    return tuple(attestations)


def write_artifact(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(canonical_json_bytes(value))


def handoff_for(scenario) -> dict[str, object]:
    return {
        "schema_version": 1,
        "handoff_id": f"25-{scenario.scenario_id}",
        "task_id": f"TASK-25-{scenario.scenario_id}",
        "issue_reference": f"CANON-GATE-B-{scenario.scenario_id}",
        "task_type": scenario.task_type,
        "scope": list(scenario.scope),
        "requirement_ids": list(scenario.requirement_ids),
        "changed_files": list(scenario.requested_changed_files),
        "validation_requests": list(scenario.required_checks),
        "proof_requests": list(scenario.proof_obligations),
        "rollback_requests": ["git-revert"],
        "claim_ceiling_request": scenario.claim_ceiling,
        "skill_adapter_requests": list(scenario.skill_adapters),
    }


def build_scenario_package(
    root: Path,
    scenario,
    *,
    source_root: Path = ROOT,
    source_is_exact: bool = False,
) -> None:
    package = root / scenario.scenario_id
    repo = package / "repo"
    repo.mkdir(parents=True)
    base, head = init_scenario_repo(repo, scenario)
    git(repo, "checkout", "--detach", "-q", head)

    handoff_path = package / "handoff.json"
    write_artifact(handoff_path, handoff_for(scenario))
    write_artifact(
        package / "task-pack.json",
        task_pack_for(
            scenario,
            source_root,
            repository_sha=head,
            source_is_exact=source_is_exact,
        ),
    )
    intake = handoff_to_task_intake(handoff_path, evidence_root=root)
    policy = load_base_policy(repo, base)
    bindings = load_trusted_bindings(repo, base, intake, policy)
    event = trusted_event(repo, base, head, scenario)
    approvals = (
        (trusted_approval(scenario, event, intake, bindings),)
        if scenario.approval_required
        else ()
    )
    start = task_start(
        repo_root=repo,
        mode="ci-pr-range",
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=approvals,
        verification_epoch=VERIFICATION_EPOCH,
    )
    validations = execute_base_owned_validations(repo, base, start)
    validation_attestations = write_validation_evidence(
        package,
        scenario,
        event,
        intake,
        bindings,
        start,
        validations,
    )
    receipt = task_finalize(
        repo_root=repo,
        authorization=start,
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=approvals,
        validation_attestations=validation_attestations,
        verification_epoch=VERIFICATION_EPOCH,
    )
    validation = next(
        item
        for item in validation_attestations
        if item["command_id"] == scenario.required_checks[0]
    )
    workflow_drift = resign({**validation, "workflow_digest": "a" * 64})
    manifest_drift = resign(
        {**validation, "command_manifest_digest": "a" * 64}
    )
    untrusted_green = resign({**validation, "ci_owned": False})
    attempt_event = trusted_event(
        repo, base, head, scenario, workflow_run_attempt=2
    )
    attempt_approvals = (
        (
            trusted_approval(
                scenario,
                attempt_event,
                intake,
                bindings,
                suffix="attempt-2",
            ),
        )
        if scenario.approval_required
        else ()
    )

    git(repo, "checkout", "-q", "--detach", head)
    first_path = scenario.requested_changed_files[0]
    if first_path.startswith("raw-base64url:"):
        replacement_path = repo / "base-marker.txt"
    else:
        replacement_path = repo / first_path
    replacement_path.parent.mkdir(parents=True, exist_ok=True)
    replacement_path.write_bytes(replacement_path.read_bytes() + b"replacement\n")
    git(repo, "add", "-A")
    git(repo, "commit", "-qm", "replacement head")
    replacement_head = git(repo, "rev-parse", "HEAD")
    replacement_event = trusted_event(repo, base, replacement_head, scenario)
    replacement_approvals = (
        (
            trusted_approval(
                scenario,
                replacement_event,
                intake,
                bindings,
                suffix="replacement",
            ),
        )
        if scenario.approval_required
        else ()
    )
    replacement_path.write_bytes(replacement_path.read_bytes() + b"final-diff\n")
    git(repo, "add", "-A")
    git(repo, "commit", "-qm", "final diff replacement")
    final_diff_head = git(repo, "rev-parse", "HEAD")
    final_diff_event = trusted_event(repo, base, final_diff_head, scenario)
    final_diff_approvals = (
        (
            trusted_approval(
                scenario,
                final_diff_event,
                intake,
                bindings,
                suffix="final-diff",
            ),
        )
        if scenario.approval_required
        else ()
    )
    git(repo, "checkout", "-q", "--detach", head)

    write_artifact(package / "trusted-event.json", event)
    write_artifact(package / "approval-attestations.json", list(approvals))
    write_artifact(package / "task-authorization.json", start)
    write_artifact(
        package / "validation-attestations.json", list(validation_attestations)
    )
    write_artifact(package / "task-finalization.json", receipt)
    write_artifact(
        package / "negative-validation-attestations.json",
        {
            "command_manifest_drift": manifest_drift,
            "re_attested_untrusted_green": untrusted_green,
            "workflow_drift": workflow_drift,
        },
    )
    write_artifact(package / "attempt-event.json", attempt_event)
    write_artifact(package / "attempt-approvals.json", list(attempt_approvals))
    write_artifact(package / "replacement-event.json", replacement_event)
    write_artifact(
        package / "replacement-approvals.json", list(replacement_approvals)
    )
    write_artifact(package / "final-diff-event.json", final_diff_event)
    write_artifact(
        package / "final-diff-approvals.json", list(final_diff_approvals)
    )
    build_regenerated_scenario_package(
        package,
        scenario,
        original_repo=repo,
        original_base=base,
        source_root=source_root,
        source_is_exact=source_is_exact,
    )


def build_regenerated_scenario_package(
    package: Path,
    scenario,
    *,
    original_repo: Path,
    original_base: str,
    source_root: Path,
    source_is_exact: bool = False,
) -> None:
    regeneration = package / "regeneration"
    repo = regeneration / "repo"
    regeneration.mkdir()
    subprocess.run(
        [
            "git",
            "clone",
            "-q",
            "--no-hardlinks",
            "--no-checkout",
            str(original_repo),
            str(repo),
        ],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    git(repo, "config", "user.name", "Gate B Regeneration")
    git(repo, "config", "user.email", "gate-b-regeneration@example.invalid")
    git(repo, "checkout", "-q", "-B", "main", original_base)
    marker = repo / "base-marker.txt"
    marker.write_bytes(marker.read_bytes() + b"trusted-base-advancement\n")
    git(repo, "add", "base-marker.txt")
    git(repo, "commit", "-qm", "trusted base advancement")
    base = git(repo, "rev-parse", "HEAD")
    git(repo, "checkout", "-q", "--detach", base)
    apply_operations(repo, scenario)
    git(repo, "commit", "-qm", f"{scenario.scenario_id} regenerated head")
    head = git(repo, "rev-parse", "HEAD")
    git(repo, "checkout", "-q", "--detach", head)

    intake = intake_for(scenario)
    policy = load_base_policy(repo, base)
    bindings = load_trusted_bindings(repo, base, intake, policy)
    event = trusted_event(repo, base, head, scenario, workflow_run_attempt=3)
    approvals = (
        (
            trusted_approval(
                scenario, event, intake, bindings, suffix="regenerated"
            ),
        )
        if scenario.approval_required
        else ()
    )
    authorization = task_start(
        repo_root=repo,
        mode="ci-pr-range",
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=approvals,
        verification_epoch=VERIFICATION_EPOCH,
    )
    validations = execute_base_owned_validations(repo, base, authorization)
    validation_attestations = write_validation_evidence(
        regeneration,
        scenario,
        event,
        intake,
        bindings,
        authorization,
        validations,
    )
    receipt = task_finalize(
        repo_root=repo,
        authorization=authorization,
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=approvals,
        validation_attestations=validation_attestations,
        verification_epoch=VERIFICATION_EPOCH,
    )
    write_artifact(
        regeneration / "task-pack.json",
        task_pack_for(
            scenario,
            source_root,
            repository_sha=head,
            source_is_exact=source_is_exact,
        ),
    )
    write_artifact(regeneration / "trusted-event.json", event)
    write_artifact(regeneration / "approval-attestations.json", list(approvals))
    write_artifact(regeneration / "task-authorization.json", authorization)
    write_artifact(
        regeneration / "validation-attestations.json",
        list(validation_attestations),
    )
    write_artifact(regeneration / "task-finalization.json", receipt)


def build_scenario_packages(
    root: Path, scenarios, *, source_root: Path = ROOT
) -> None:
    with detached_exact_source(source_root) as exact_source:
        build_package = partial(
            build_scenario_package,
            root,
            source_root=exact_source,
            source_is_exact=True,
        )
        with ProcessPoolExecutor(max_workers=min(4, len(scenarios))) as executor:
            list(
                executor.map(build_package, scenarios)
            )


class AuthorizationBenchmarkTests(unittest.TestCase):
    def test_task24_matrix_rejects_arbitrary_or_wrong_python_runtime(self) -> None:
        for executable in ("/usr/bin/true", "/usr/bin/python3"):
            with self.subTest(executable=executable), self.assertRaisesRegex(
                BenchmarkError,
                "BENCHMARK_PYTHON_RUNTIME",
            ):
                benchmark_module._run_task24_tree_matrix(
                    ROOT,
                    python_executable=executable,
                )
        with mock.patch.object(
            benchmark_module.sys,
            "implementation",
            SimpleNamespace(name="pypy"),
        ), self.assertRaisesRegex(BenchmarkError, "BENCHMARK_PYTHON_RUNTIME"):
            benchmark_module._run_task24_tree_matrix(
                ROOT,
                python_executable=sys.executable,
            )

    def test_task24_matrix_proves_trusted_python_version_and_exact_execution_count(self) -> None:
        matrix = benchmark_module._run_task24_tree_matrix(
            ROOT,
            python_executable=sys.executable,
        )
        self.assertEqual(matrix["python_version"], "3.12")
        self.assertEqual(matrix["python_implementation"], "cpython")
        self.assertEqual(matrix["executed_test_count"], 2)
        self.assertEqual(len(matrix["test_ids"]), matrix["executed_test_count"])

    def test_task24_matrix_never_imports_candidate_python(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            subprocess.run(
                ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            authorization_marker = root / "candidate-authorization-imported"
            test_marker = root / "candidate-authorization-test-imported"
            (source / "tools/ambitions_canon/authorization.py").write_text(
                "from pathlib import Path\n"
                f"Path({str(authorization_marker)!r}).write_text('imported')\n",
                encoding="utf-8",
            )
            (source / "tests/canon/test_authorization.py").write_text(
                "from pathlib import Path\nimport unittest\n"
                f"Path({str(test_marker)!r}).write_text('imported')\n"
                "import tools.ambitions_canon.authorization\n"
                "class DeterminismAndTreeDeltaTests(unittest.TestCase):\n"
                " def test_tree_delta_preserves_raw_paths_modes_objects_and_opaque_blobs(self): pass\n"
                " def test_tree_delta_supports_merge_commits_and_submodule_gitlinks(self): pass\n",
                encoding="utf-8",
            )
            git(
                source,
                "add",
                "tools/ambitions_canon/authorization.py",
                "tests/canon/test_authorization.py",
            )
            git(source, "commit", "-qm", "hostile matrix candidate")
            matrix = benchmark_module._run_task24_tree_matrix(
                source,
                python_executable=sys.executable,
            )
            self.assertFalse(authorization_marker.exists())
            self.assertFalse(test_marker.exists())
            self.assertEqual(
                matrix["verifier_file_sha256"],
                {
                    relative: hashlib.sha256((ROOT / relative).read_bytes()).hexdigest()
                    for relative in (
                        "tests/canon/test_authorization.py",
                        "tools/ambitions_canon/authorization.py",
                    )
                },
            )

    def test_benchmark_verifier_never_executes_validation_commands(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            packages = root / "packages"
            subprocess.run(
                ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            build_scenario_packages(packages, scenarios, source_root=source)
            with mock.patch.object(
                benchmark_module,
                "execute_base_owned_validations",
                side_effect=AssertionError("trusted verifier executed validation command"),
            ):
                report = run_authorization_benchmark(
                    scenarios,
                    packages,
                    source_root=source,
                )
            self.assertEqual(report["status"], "green")

    def test_eight_scenarios_project_from_independent_policy_and_real_task_packs(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        policy = json.loads(BENCHMARK_POLICY.read_text(encoding="utf-8"))
        self.assertEqual(policy["schema_version"], 1)
        self.assertEqual(
            [item["scenario_id"] for item in policy["scenarios"]],
            list(AUTHORIZATION_SCENARIO_IDS),
        )
        self.assertEqual(
            len({tuple(scenario.required_checks) for scenario in scenarios}), 8
        )
        self.assertGreater(
            len({tuple(scenario.skill_adapters) for scenario in scenarios}), 4
        )
        with detached_exact_source(ROOT) as exact_source:
            for scenario in scenarios:
                with self.subTest(scenario=scenario.scenario_id):
                    benchmark_policy_for(scenario)
                    pack = task_pack_for(
                        scenario, exact_source, source_is_exact=True
                    )
                    self.assertEqual(
                        pack["issue_id"], f"TASK-25-{scenario.scenario_id}"
                    )
                    self.assertEqual(pack["task_type"], scenario.task_type)
                    self.assertEqual(pack["scope"], list(scenario.scope))
                    self.assertEqual(
                        pack["changed_files"], list(scenario.requested_changed_files)
                    )

    def test_scenarios_use_exact_retained_skill_contract_bytes(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        live_registry = json.loads(
            (ROOT / "docs/canon/references/skill-dependencies.json").read_text(
                encoding="utf-8"
            )
        )
        by_id = {item["skill_id"]: item for item in live_registry["skills"]}
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, _head = init_scenario_repo(repo, scenario)
            for skill_id in scenario.skill_adapters:
                with self.subTest(skill_id=skill_id):
                    entry = by_id[skill_id]
                    expected = (ROOT / entry["path"]).read_bytes()
                    observed = subprocess.run(
                        ["git", "show", f"{base}:{entry['path']}"],
                        cwd=repo,
                        check=True,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                    ).stdout
                    self.assertGreater(len(observed), 200)
                    self.assertEqual(observed, expected)

    def test_scenario_validator_emits_substantive_bound_observations(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build_scenario_package(root, scenario)
            artifact = json.loads(
                (
                    root
                    / scenario.scenario_id
                    / "validation-artifacts"
                    / f"{scenario.required_checks[0]}.bin"
                ).read_text(encoding="utf-8")
            )
            stdout = base64.urlsafe_b64decode(
                artifact["stdout_base64url"]
                + "=" * (-len(artifact["stdout_base64url"]) % 4)
            )
            payload = json.loads(stdout.decode("utf-8"))
            self.assertEqual(
                set(payload),
                {
                    "schema_version",
                    "scenario_id",
                    "validator_kind",
                    "subject_path",
                    "subject_sha256",
                    "skill_contract_sha256",
                    "status",
                },
            )
            self.assertEqual(payload["scenario_id"], scenario.scenario_id)
            self.assertNotEqual(payload["validator_kind"], "green-label")
            self.assertEqual(payload["status"], "green")
            self.assertEqual(
                set(payload["skill_contract_sha256"]), set(scenario.skill_adapters)
            )

    def test_scenario_validator_rejects_changed_subject_bytes(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build_scenario_package(root, scenario)
            package = root / scenario.scenario_id
            repo = package / "repo"
            authorization = json.loads(
                (package / "task-authorization.json").read_text(encoding="utf-8")
            )
            target = repo / scenario.requested_changed_files[0]
            target.write_bytes(target.read_bytes() + b"forged-subject\n")
            git(repo, "add", "-A")
            git(repo, "commit", "-qm", "forged subject")
            with self.assertRaisesRegex(
                BenchmarkError, "BENCHMARK_SOURCE_STALE"
            ):
                execute_base_owned_validations(
                    repo, authorization["trusted_event_provenance"]["trusted_base_sha"], authorization
                )

    def test_approval_required_local_artifacts_remain_advisory_and_ci_rejects_substitution(self) -> None:
        scenario = next(
            item
            for item in load_authorization_benchmark_scenarios(FIXTURES)
            if item.scenario_id == "cloudkit-continuity"
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build_scenario_package(root, scenario)
            result = benchmark_module._verify_scenario(
                root.resolve(strict=True), scenario, ROOT
            )
        observation = result["negative_observations"][
            "local_substitution"
        ]
        self.assertEqual(observation["code"], "AUTH_LOCAL_NOT_MERGE_AUTHORITY")
        self.assertEqual(observation["observer"], "benchmark-evidence-verifier")

    def test_eight_scenarios_use_exact_leaf_operations(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        self.assertEqual(
            tuple(scenario.scenario_id for scenario in scenarios),
            AUTHORIZATION_SCENARIO_IDS,
        )
        for scenario in scenarios:
            self.assertTrue(scenario.requested_changed_files)
            for requested in scenario.requested_changed_files:
                self.assertFalse(requested.endswith("/"), requested)
                self.assertNotIn("/../", f"/{requested}/")
            operation_paths = []
            for operation in scenario.operations:
                if operation["kind"] == "write":
                    operation_paths.append(operation["path"])
                else:
                    operation_paths.append(
                        "raw-base64url:" + operation["path_raw_base64url"]
                    )
            self.assertEqual(sorted(operation_paths), list(scenario.requested_changed_files))

    def test_all_eight_scenarios_run_start_resume_finalize_and_negatives(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        with tempfile.TemporaryDirectory() as first_directory, tempfile.TemporaryDirectory() as second_directory:
            first_root = Path(first_directory)
            second_root = Path(second_directory)
            build_scenario_packages(first_root, scenarios)
            build_scenario_packages(second_root, scenarios)
            first = run_authorization_benchmark(
                scenarios, first_root, source_root=ROOT
            )
            second = run_authorization_benchmark(
                scenarios, second_root, source_root=ROOT
            )
            self.assertEqual(first["status"], "green")
            self.assertEqual(first["scenario_count"], 8)
            self.assertEqual(
                [item["scenario_id"] for item in first["scenarios"]],
                list(AUTHORIZATION_SCENARIO_IDS),
            )
            self.assertTrue(
                all(item["status"] == "green" for item in first["scenarios"])
            )
            self.assertEqual(
                canonical_benchmark_bytes(first), canonical_benchmark_bytes(second)
            )
            self.assertTrue(canonical_benchmark_bytes(first).endswith(b"\n"))
            self.assertNotIn(b"timestamp", canonical_benchmark_bytes(first))
            matrix = first["task24_tree_matrix"]
            self.assertEqual(matrix["status"], "green")
            self.assertEqual(
                matrix["covered_cases"],
                [
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
            )
            self.assertEqual(matrix["checkout_kind"], "detached-merge-commit")
            for scenario, result in zip(scenarios, first["scenarios"], strict=True):
                self.assertEqual(result["task_pack"]["status"], "green")
                self.assertEqual(result["regeneration"]["status"], "green")
                self.assertNotEqual(
                    result["regeneration"]["trusted_base_sha"],
                    result["trusted_base_sha"],
                )
                self.assertNotEqual(
                    result["regeneration"]["trusted_head_sha"],
                    result["trusted_head_sha"],
                )
                self.assertIn("negative_observations", result)
                observations = result["negative_observations"]
                self.assertEqual(
                    set(observations), set(scenario.expected_failure_codes)
                )
                for case, expected_code in scenario.expected_failure_codes.items():
                    with self.subTest(scenario=scenario.scenario_id, case=case):
                        self.assertEqual(observations[case]["code"], expected_code)
                        self.assertIn(
                            observations[case]["observer"],
                            {"benchmark-evidence-verifier", "task24-authorization"},
                        )
                self.assertEqual(
                    observations["local_substitution"]["observer"],
                    "benchmark-evidence-verifier",
                )
                self.assertEqual(
                    observations["absent_finalization"]["observer"],
                    "benchmark-evidence-verifier",
                )

    def test_missing_finalization_fails_without_partial_authorizing_report(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build_scenario_packages(root, scenarios)
            (root / scenarios[0].scenario_id / "task-finalization.json").unlink()
            with self.assertRaisesRegex(
                BenchmarkError, "BENCHMARK_FINALIZATION_MISSING"
            ) as context:
                run_authorization_benchmark(scenarios, root, source_root=ROOT)
            self.assertFalse(hasattr(context.exception, "partial_report"))

    def test_handoff_is_request_only_and_rejects_authority_fields(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        forbidden = (
            "approval",
            "authorized_files",
            "validation_results",
            "proof_claims",
            "break_glass",
            "merge_permission",
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            handoff = root / "handoff.json"
            write_artifact(handoff, handoff_for(scenario))
            self.assertEqual(
                handoff_to_task_intake(handoff, evidence_root=root),
                intake_for(scenario),
            )
            for field in forbidden:
                with self.subTest(field=field):
                    write_artifact(handoff, {**handoff_for(scenario), field: True})
                    with self.assertRaisesRegex(
                        BenchmarkError, "BENCHMARK_HANDOFF_AUTHORITY_FIELD"
                    ):
                        handoff_to_task_intake(handoff, evidence_root=root)

    def test_benchmark_recomputes_artifact_envelope_and_receipt_bytes(self) -> None:
        scenarios = load_authorization_benchmark_scenarios(FIXTURES)
        command_id = scenarios[0].required_checks[0]
        mutations = (
            (f"validation-artifacts/{command_id}.bin", b"substituted\n", "BENCHMARK_VALIDATION_ARTIFACT"),
            ("task-pack.json", b"{}\n", "BENCHMARK_TASK_PACK_MISMATCH"),
            ("task-authorization.json", b"{}\n", "BENCHMARK_AUTHORIZATION_MISMATCH"),
            ("task-finalization.json", b"{}\n", "BENCHMARK_FINALIZATION_MISMATCH"),
            (
                "absent-finalization.json",
                b"{}\n",
                "BENCHMARK_NEGATIVE_AUTHORIZED",
            ),
        )
        for relative, replacement, code in mutations:
            with self.subTest(relative=relative), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                build_scenario_packages(root, scenarios)
                (root / scenarios[0].scenario_id / relative).write_bytes(replacement)
                with self.assertRaisesRegex(BenchmarkError, code):
                    run_authorization_benchmark(scenarios, root, source_root=ROOT)

    def test_base_owned_validation_environment_drops_ambient_secret(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        with tempfile.TemporaryDirectory() as directory, mock.patch.dict(
            os.environ,
            {"TASK25_SENTINEL_SECRET": "must-not-reach-base-command"},
        ):
            package_root = Path(directory)
            build_scenario_package(package_root, scenario)
            artifact = (
                package_root
                / scenario.scenario_id
                / "validation-artifacts"
                / f"{scenario.required_checks[0]}.bin"
            )
            self.assertTrue(artifact.is_file())

    def test_benchmark_uses_clean_clone_and_never_executes_artifact_repo_hooks(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build_scenario_package(root, scenario)
            repo = root / scenario.scenario_id / "repo"
            sentinel = root / "artifact-hook-sentinel.txt"
            hooks = repo / "candidate-hooks"
            hooks.mkdir()
            hook = hooks / "reference-transaction"
            hook.write_text(
                "#!/bin/sh\n"
                "printf '%s' \"$TASK25_SENTINEL_SECRET\" > \"$TASK25_HOOK_SENTINEL\"\n",
                encoding="utf-8",
            )
            hook.chmod(0o755)
            git(repo, "config", "core.hooksPath", str(hooks))
            with mock.patch.dict(
                os.environ,
                {
                    "TASK25_HOOK_SENTINEL": str(sentinel),
                    "TASK25_SENTINEL_SECRET": "artifact-hook-observed-secret",
                },
            ):
                benchmark_module._verify_scenario(
                    root.resolve(strict=True), scenario, ROOT
                )
            self.assertFalse(sentinel.exists())

    def test_benchmark_rejects_path_escape_and_symlink_evidence(self) -> None:
        scenario = load_authorization_benchmark_scenarios(FIXTURES)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            outside = root.parent / f"{root.name}-outside.json"
            outside.write_text("{}\n", encoding="utf-8")
            link = root / "handoff.json"
            link.symlink_to(outside)
            try:
                with self.assertRaisesRegex(BenchmarkError, "BENCHMARK_HANDOFF_INVALID"):
                    handoff_to_task_intake(link, evidence_root=root)
            finally:
                outside.unlink(missing_ok=True)

    def test_task24_delta_supports_delete_add_move_in_detached_checkout(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            git(repo, "init", "-q")
            git(repo, "config", "user.name", "Gate B Matrix")
            git(repo, "config", "user.email", "matrix@example.invalid")
            (repo / "old.txt").write_text("same bytes\n", encoding="utf-8")
            git(repo, "add", "old.txt")
            git(repo, "commit", "-qm", "base")
            base = git(repo, "rev-parse", "HEAD")
            (repo / "old.txt").rename(repo / "new.txt")
            git(repo, "add", "-A")
            git(repo, "commit", "-qm", "delete add")
            head = git(repo, "rev-parse", "HEAD")
            git(repo, "checkout", "-q", "--detach", head)
            records = canonical_tree_delta(repo, base, head)["records"]
            self.assertEqual(
                [(record["path_display_utf8"], record["status"]) for record in records],
                [("new.txt", "added"), ("old.txt", "deleted")],
            )
if __name__ == "__main__":
    unittest.main()
