from __future__ import annotations

import ast
import base64
import hashlib
import inspect
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import tomllib
import unittest
import zlib
from contextlib import ExitStack
from pathlib import Path
from unittest import mock

from tests.canon.test_authorization import (
    approval as task_approval,
    event as task_event,
    intake as task_intake,
    resign,
    sign,
    trusted_context,
    write_trusted_state,
)
from tests.canon.test_authorization_benchmark import build_scenario_packages
from tools.ambitions_canon.authorization import (
    canonical_json_bytes,
    task_finalize,
    task_start,
)
from tools.ambitions_canon.authorization_benchmark import (
    AUTHORIZATION_SCENARIO_IDS,
    BenchmarkError,
    canonical_benchmark_bytes,
    execute_base_owned_validations,
    load_authorization_benchmark_scenarios,
    run_authorization_benchmark,
)
from tools.ambitions_canon import authorization_benchmark as benchmark_module
from tools.ambitions_canon import cutover_readiness as cutover_module
from tools.ambitions_canon.cutover_readiness import (
    BOOTSTRAP_CLAIM_CEILING,
    GATE_B_REQUIRED_EVIDENCE_IDS,
    GateBEvidenceError,
    evaluate_gate_b as _evaluate_gate_b,
    render_cutover_readiness,
    validate_gate_b_evidence_schema,
)


ROOT = Path(__file__).resolve().parents[2]
SCHEMA = ROOT / "docs/canon/schemas/gate-b-evidence.schema.json"
EVIDENCE_REGISTRY = (
    ROOT / "docs/canon/references/gate-b-evidence-registry.json"
)
SYNTHETIC_VISUAL_CONTRACT = (
    ROOT / "tests/canon/fixtures/task25-gate-b-visual-complete-contract.json"
)
SYNTHETIC_VISUAL_MANIFEST = (
    ROOT
    / "tests/canon/fixtures/task25-gate-b-visual-authority-manifest.json"
)


def evaluate_gate_b(
    evidence_path: Path,
    *,
    repo_root: Path,
    artifact_root: Path,
    expected_base_sha: str | None = None,
    authenticated_rollback: dict[str, object] | None = None,
    authenticated_current_event: dict[str, object] | None = None,
) -> dict[str, object]:
    evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
    if authenticated_current_event is None:
        requirement = evidence["requirements"][0]
        authorization = json.loads(
            (artifact_root / requirement["authorization_path"]).read_text(
                encoding="utf-8"
            )
        )
        authenticated_current_event = authorization["trusted_event_provenance"]
    return _evaluate_gate_b(
        evidence_path,
        repo_root=repo_root,
        artifact_root=artifact_root,
        expected_base_sha=expected_base_sha or evidence["expected_base_sha"],
        authenticated_rollback=authenticated_rollback or evidence["rollback"],
        authenticated_current_event=authenticated_current_event,
    )
FIXTURES = ROOT / "tests/canon/fixtures/authorization-benchmarks"
VERIFICATION_EPOCH = 1_900_000_000


def deterministic_png(width: int = 4, height: int = 3) -> bytes:
    def chunk(kind: bytes, data: bytes) -> bytes:
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    rows = b"".join(b"\x00" + b"\x20\x40\x60\xff" * width for _ in range(height))
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(rows, level=9))
        + chunk(b"IEND", b"")
    )


def git(repo: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", *arguments],
        cwd=repo,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return completed.stdout.strip()


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_artifact(root: Path, relative: str, value: object) -> tuple[str, str]:
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(value, bytes):
        target.write_bytes(value)
    else:
        target.write_bytes(canonical_json_bytes(value))
    return relative, digest(target)


def approval_attestation(
    *,
    source: Path,
    base: str,
    head: str,
    attestation_id: str,
    intake_id: str,
    intake_digest: str,
    approved_scope: list[str],
    authenticated_principal: str = "owner:devan",
    approval_policy_id: str = "owner-gate",
    task_id: str = "TASK-26-GATE-B",
    intake_id_override: str | None = None,
    current_event: dict[str, object],
) -> dict[str, object]:
    policy_path = "docs/canon/references/task-authorization-policy.json"
    policy_bytes = subprocess.run(
        ["git", "show", f"{base}:{policy_path}"],
        cwd=source,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout
    policy = json.loads(policy_bytes.decode("utf-8"))
    command_manifest_path = policy["snapshot_paths"]["command_manifest"]
    command_manifest_bytes = subprocess.run(
        ["git", "show", f"{base}:{command_manifest_path}"],
        cwd=source,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout
    command_manifest = json.loads(command_manifest_bytes.decode("utf-8"))
    workflow = command_manifest["trusted_workflow"]
    repository_identity = policy["repository_identity"]
    return sign(
        {
            "schema_version": 1,
            "attestation_id": attestation_id,
            "attestation_origin": "platform-authenticated",
            "repository_id": repository_identity["repository_id"],
            "repository_full_name": repository_identity["repository_full_name"],
            "pull_request_number": current_event["pull_request_number"],
            "task_id": task_id,
            "intake_id": intake_id_override or intake_id,
            "trusted_base_sha": base,
            "trusted_head_sha": head,
            "merge_base_sha": current_event["merge_base_sha"],
            "intake_digest": intake_digest,
            "policy_revision": policy["policy_revision"],
            "command_manifest_digest": hashlib.sha256(
                command_manifest_bytes
            ).hexdigest(),
            "workflow_path": workflow["path"],
            "workflow_ref": workflow["ref"],
            "workflow_digest": workflow["digest"],
            "workflow_run_id": current_event["workflow_run_id"],
            "workflow_run_attempt": current_event["workflow_run_attempt"],
            "event_projection_digest": current_event["event_projection_digest"],
            "consumption_generation": current_event["consumption_generation"],
            "check_identity": workflow["check_identity"],
            "integration_id": workflow["integration_id"],
            "app_id": workflow["app_id"],
            "approval_policy_id": approval_policy_id,
            "approval_policy_revision": "1",
            "authenticated_principal": authenticated_principal,
            "approved_scope": sorted(approved_scope),
            "one_time_use_nonce": f"nonce-{attestation_id}",
            "verification_epoch": current_event["verification_epoch"],
            "consumed": False,
            "expires_at_epoch": 2_000_000_000,
            "revoked": False,
            "break_glass": False,
            "incident_id": None,
            "rollback_ref": None,
            "post_action_review_required": False,
        }
    )


def independent_review_attestation(
    *,
    source: Path,
    base: str,
    head: str,
    review_id: str,
    review_digest: str,
    commit_range: str,
    dimensions: list[str],
    verdicts: dict[str, str],
    rollback_scope: list[str],
    current_event: dict[str, object],
) -> dict[str, object]:
    return approval_attestation(
        source=source,
        base=base,
        head=head,
        attestation_id=f"REVIEW-{review_id}",
        intake_id=f"REVIEW-{review_id}",
        intake_digest=review_digest,
        approved_scope=[
            f"review:{review_id}",
            f"review-artifact-sha256:{review_digest}",
            f"review-range:{commit_range}",
            f"source-sha:{head}",
            "critical-findings:0",
            "important-findings:0",
            *(f"review-dimension:{dimension}:green" for dimension in dimensions),
            *(f"review-verdict:{name}:{verdicts[name]}" for name in sorted(verdicts)),
            *rollback_scope,
        ],
        authenticated_principal="reviewer:independent",
        approval_policy_id="independent-review",
        task_id="TASK-25-GATE-B-REVIEW",
        current_event=current_event,
    )


def validation_attestation(
    *,
    source: Path,
    attestation_id: str,
    artifact_digest: str,
    authorization: dict[str, object],
    event_data: dict[str, object],
    command_id: str = "gate-b-evidence-suite",
) -> dict[str, object]:
    intake_data = authorization["intake"]
    bindings = authorization["trusted_bindings"]
    command_manifest = json.loads(
        (
            source / "docs/canon/references/validation-command-manifest.json"
        ).read_text(encoding="utf-8")
    )
    workflow = command_manifest["trusted_workflow"]
    return sign(
        {
            "schema_version": 1,
            "attestation_id": attestation_id,
            "attestation_origin": "trusted-ci",
            "pull_request_number": event_data["pull_request_number"],
            "task_id": intake_data["task_id"],
            "intake_id": intake_data["intake_id"],
            "intake_digest": authorization["intake_digest"],
            "policy_revision": bindings["policy_revision"],
            "authorization_digest": hashlib.sha256(
                canonical_json_bytes(authorization)
            ).hexdigest(),
            "command_manifest_digest": bindings["command_manifest_sha256"],
            "workflow_path": workflow["path"],
            "workflow_ref": workflow["ref"],
            "workflow_digest": workflow["digest"],
            "command_id": command_id,
            "command_argv_digest": authorization["computed_command_digests"][
                command_id
            ],
            "check_identity": workflow["check_identity"],
            "repository_id": event_data["repository_id"],
            "repository_full_name": event_data["repository_full_name"],
            "trusted_base_sha": event_data["trusted_base_sha"],
            "trusted_head_sha": event_data["trusted_head_sha"],
            "merge_base_sha": event_data["merge_base_sha"],
            "integration_id": workflow["integration_id"],
            "app_id": workflow["app_id"],
            "exit_status": 0,
            "artifact_digest": artifact_digest,
            "proof_obligation_ids": authorization[
                "computed_proof_command_bindings"
            ][command_id],
            "skipped": False,
            "skipped_reason": None,
            "status": "green",
            "claim_ceiling": authorization["computed_claim_ceiling"],
            "ci_owned": True,
        }
    )


def install_gate_b_evidence_suite_command(
    source: Path, *, no_op: bool = False
) -> None:
    registry = json.loads(
        (source / "docs/canon/references/gate-b-evidence-registry.json").read_text(
            encoding="utf-8"
        )
    )
    commands = []
    for entry in registry["requirements"]:
        evidence_id = entry["evidence_id"]
        if no_op:
            payload_expression = (
                "{'schema_version':1,'evidence_id':evidence_id,"
                "'check_identity':'gate-b:'+evidence_id,'semantic':'green-label',"
                "'source_sha':head,'source_tree_sha':tree,'input_paths':paths,"
                "'input_sha256':'0'*64,'observation':{'kind':'green-label',"
                "'subject_count':1,'subject_sha256':'0'*64},"
                "'validator_id':kind}"
            )
            script = (
                "import hashlib,json,subprocess;"
                "g=lambda *a:subprocess.check_output(['git','-c','core.hooksPath=/dev/null',*a]);"
                f"evidence_id={evidence_id!r};semantic={entry['semantic']!r};"
                f"kind={entry['observation_kind']!r};paths={entry['input_paths']!r};"
                "head=g('rev-parse','HEAD').decode().strip();"
                "tree=g('rev-parse','HEAD^{tree}').decode().strip();"
                "records=[{'path':p,'byte_size':len(raw),'sha256':hashlib.sha256(raw).hexdigest()} "
                "for p in paths for raw in [g('show',head+':'+p)]];"
                "record_bytes=(json.dumps(records,sort_keys=True,separators=(',',':'))+'\\n').encode();"
                f"payload={payload_expression};"
                "print(json.dumps(payload,sort_keys=True,separators=(',',':')))"
            )
            argv = ["python3", "-c", script]
        else:
            argv = [
                "python3",
                "-m",
                "tools.ambitions_canon.cutover_readiness",
                "validate-requirement",
                evidence_id,
            ]
        commands.append(
            {
                "command_id": f"gate-b-{evidence_id}",
                "argv": argv,
                "required_for_task_types": ["release"],
                "required_for_scenarios": ["authorization"],
                "proof_obligation_ids": (
                    ["independent-review"]
                    if evidence_id == "independent-ci-regeneration"
                    else ["focused-tests", "offline-determinism"]
                ),
                "evidence_class": (
                    "independent-review"
                    if evidence_id == "independent-ci-regeneration"
                    else "automated-validation"
                ),
            }
        )
    command_manifest_path = (
        source / "docs/canon/references/validation-command-manifest.json"
    )
    command_manifest = json.loads(command_manifest_path.read_text(encoding="utf-8"))
    command_manifest["manifest_revision"] = "gate-b-evidence-specific-v2"
    command_manifest["commands"] = commands
    command_manifest_path.write_bytes(canonical_json_bytes(command_manifest))
    policy_path = source / "docs/canon/references/task-authorization-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["task_rules"][0]["required_checks"] = [
        command["command_id"] for command in commands
    ]
    policy_path.write_bytes(canonical_json_bytes(policy))


def create_gate_b_bundle(
    root: Path, *, no_op_evidence_suite: bool = False
) -> tuple[Path, Path, Path]:
    source = root / "source"
    subprocess.run(
        ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    initial = git(source, "rev-parse", "HEAD")
    git(
        source,
        "-c",
        "user.name=Gate B Owner",
        "-c",
        "user.email=gate-b@example.invalid",
        "tag",
        "-a",
        "gate-b-rollback",
        "-m",
        "immutable Gate B rollback baseline",
        initial,
    )
    for relative in (
        "tools/ambitions_canon/audit.py",
        "tools/ambitions_canon/authorization.py",
        "tools/ambitions_canon/authorization_benchmark.py",
        "tools/ambitions_canon/cli.py",
        "tools/ambitions_canon/cutover_readiness.py",
        "tools/ambitions_canon/purge.py",
        "tools/ambitions_canon/skill_conformance.py",
        "tools/ambitions_canon/task_pack.py",
        "tests/canon/test_authorization.py",
        "tests/canon/test_authorization_benchmark.py",
        "tests/canon/test_cutover_readiness.py",
        "tests/canon/test_integration.py",
        "tests/canon/test_purge.py",
        "tests/canon/test_skill_conformance.py",
        "tests/canon/test_task_pack.py",
        "docs/canon/schemas/approval-attestation.schema.json",
        "docs/canon/schemas/gate-b-evidence.schema.json",
        "docs/canon/schemas/task-authorization.schema.json",
        "docs/canon/schemas/task-intake.schema.json",
        "docs/canon/schemas/task-pack.schema.json",
        "docs/canon/schemas/trusted-event.schema.json",
        "docs/canon/schemas/validation-attestation.schema.json",
        "docs/canon/references/gate-b-evidence-registry.json",
        "docs/canon/references/legacy-audit-invariant-parity.json",
        "docs/canon/references/skill-dependencies.json",
        "docs/canon/references/task-25-authorization-benchmark-policy.json",
        "docs/canon/references/task-authorization-policy.json",
        "docs/canon/references/validation-command-manifest.json",
        "docs/canon/migration/UX_BLUEPRINT.md",
        "docs/canon/migration/VISUAL_AUTHORITY_REBASELINE.md",
        "docs/canon/migration/ux-blueprint-requirement-dispositions.json",
        "docs/canon/migration/ux-blueprint.json",
        "docs/canon/migration/visual-authority-r1-node-snapshot.json",
        "docs/canon/migration/visual-authority-rebaseline.json",
        "docs/canon/registries/command-gate-approval-receipts.json",
        "docs/canon/registries/command-gate-dependencies.json",
        "docs/canon/specifications/global/search.md",
        "docs/canon/specifications/journeys/search-find-ask-act-inspect.md",
    ):
        (source / relative).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / relative, source / relative)
    source_benchmark_fixtures = (
        source / "tests/canon/fixtures/authorization-benchmarks"
    )
    source_benchmark_fixtures.mkdir(parents=True, exist_ok=True)
    for fixture in sorted(FIXTURES.glob("*.json")):
        shutil.copy2(fixture, source_benchmark_fixtures / fixture.name)
    shutil.rmtree(source / ".agents/skills")
    live_canon_manifest = (source / "docs/canon/MANIFEST.toml").read_bytes()
    manifest_data = tomllib.loads(live_canon_manifest.decode("utf-8"))
    canon_revision = manifest_data["canon_revision"]
    live_normative_files = {
        relative: (source / "docs/canon" / relative).read_bytes()
        for relative in manifest_data["normative_files"]
    }
    authorization_schema_paths = (
        "docs/canon/schemas/task-intake.schema.json",
        "docs/canon/schemas/task-authorization.schema.json",
        "docs/canon/schemas/trusted-event.schema.json",
        "docs/canon/schemas/approval-attestation.schema.json",
        "docs/canon/schemas/validation-attestation.schema.json",
    )
    live_authorization_schemas = {
        relative: (source / relative).read_bytes()
        for relative in authorization_schema_paths
    }
    subprocess.run(
        [
            sys.executable,
            "scripts/ambitions-canon.py",
            "build",
        ],
        cwd=source,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    live_generated_outputs = {
        relative: (source / "docs/canon" / relative).read_bytes()
        for relative in manifest_data["generated_files"]
    }
    write_trusted_state(source, ["gate-b-proof.txt"])
    (source / "docs/canon/MANIFEST.toml").write_bytes(live_canon_manifest)
    for relative, raw in live_normative_files.items():
        target = source / "docs/canon" / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for relative, raw in live_authorization_schemas.items():
        (source / relative).write_bytes(raw)
    for relative, raw in live_generated_outputs.items():
        target = source / "docs/canon" / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    synthetic_task25_report = (
        source / "docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md"
    )
    synthetic_task25_report.write_text(
        "# Synthetic Task 25 Gate B Report\n\n"
        "Gate B: Red\n\n"
        "This non-authoritative test fixture binds a detached rollback path. "
        "It is not live Task 25 approval, implementation, or cutover proof.\n",
        encoding="utf-8",
    )
    # This is a synthetic, non-live Gate B fixture. Its positive path must carry
    # a complete independent semantic-review projection; the live candidate
    # review remains unchanged and cannot authorize Task 25.
    from tools.ambitions_canon.build import _load_audited_registry
    from tools.ambitions_canon.migration import (
        render_compact_semantic_loss_review,
        semantic_review_content_sha256,
    )

    semantic_ledger_path = (
        source / "docs/canon/migration/semantic-equivalence-sets.json"
    )
    semantic_ledger = json.loads(
        semantic_ledger_path.read_text(encoding="utf-8")
    )
    semantic_ledger["review_status"] = "independently_reviewed"
    semantic_ledger["independent_review"] = {
        "schema_version": 1,
        "verdict": "clean",
        "reviewed_path_count": 5,
        "reviewed_candidate_diff_sha256": hashlib.sha256(
            b"synthetic Gate B candidate diff"
        ).hexdigest(),
        "reviewer_report_sha256": hashlib.sha256(
            b"synthetic Gate B reviewer report"
        ).hexdigest(),
        "reviewed_semantic_content_sha256": semantic_review_content_sha256(
            semantic_ledger
        ),
        "finding_counts": {"critical": 0, "important": 0, "minor": 0},
    }
    semantic_ledger_path.write_bytes(canonical_json_bytes(semantic_ledger))
    semantic_review_path = source / "docs/canon/migration/semantic-loss-review.json"
    semantic_review_path.write_bytes(
        render_compact_semantic_loss_review(
            source,
            _load_audited_registry(source),
        )
    )
    skill_registry_path = source / "docs/canon/references/skill-dependencies.json"
    skill_registry = json.loads(skill_registry_path.read_text(encoding="utf-8"))
    synthetic_requirement_id = "A11Y-002"
    skill_registry["requirement_index_sha256"] = digest(
        source / "docs/canon/generated/canon-index.json"
    )
    for skill in skill_registry["skills"]:
        skill["requirement_ids"] = [synthetic_requirement_id]
        for dependency in skill["dependencies"]:
            dependency_path = source / dependency["path"]
            dependency["sha256"] = hashlib.sha256(
                dependency_path.read_bytes()
            ).hexdigest()
    skill_registry_path.write_bytes(canonical_json_bytes(skill_registry))
    policy_path = source / "docs/canon/references/task-authorization-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    rule = policy["task_rules"][0]
    rule["task_id"] = "TASK-25"
    rule["issue_reference"] = "CANON-TASK-25"
    rule["task_types"] = ["release"]
    rule["requirement_ids"] = [synthetic_requirement_id]
    rule["approval_required"] = True
    issue = policy["issue_state"]["issues"][0]
    issue["task_ids"] = ["TASK-25"]
    issue["issue_reference"] = "CANON-TASK-25"
    policy["snapshot_paths"].update(
        {
            "known_issues": "docs/canon/generated/specification-coverage.md",
            "proof_state": "docs/canon/generated/law-proof-map.json",
            "conflict_state": "docs/canon/generated/unresolved-conflicts.md",
        }
    )
    policy_path.write_bytes(canonical_json_bytes(policy))
    install_gate_b_evidence_suite_command(
        source, no_op=no_op_evidence_suite
    )
    from tools.ambitions_canon.build import build_canon

    for _attempt in range(3):
        self_consistent_findings = build_canon(source)
        if self_consistent_findings:
            raise AssertionError(self_consistent_findings)
        expected_index_digest = digest(
            source / "docs/canon/generated/canon-index.json"
        )
        skill_registry = json.loads(
            skill_registry_path.read_text(encoding="utf-8")
        )
        if skill_registry["requirement_index_sha256"] == expected_index_digest:
            break
        skill_registry["requirement_index_sha256"] = expected_index_digest
        skill_registry_path.write_bytes(canonical_json_bytes(skill_registry))
    else:
        raise AssertionError("synthetic Gate B fixture did not reach a fixed point")
    git(source, "add", "-A")
    git(source, "commit", "-qm", "synthetic trusted Gate B base")
    for _attempt in range(3):
        post_commit_findings = build_canon(source)
        if post_commit_findings:
            raise AssertionError(post_commit_findings)
        skill_registry = json.loads(
            skill_registry_path.read_text(encoding="utf-8")
        )
        skill_registry["requirement_index_sha256"] = digest(
            source / "docs/canon/generated/canon-index.json"
        )
        skill_registry_path.write_bytes(canonical_json_bytes(skill_registry))
        git(source, "add", "-A")
        unchanged = subprocess.run(
            ["git", "diff", "--cached", "--quiet"], cwd=source, check=False
        ).returncode == 0
        if unchanged:
            break
        git(source, "commit", "--amend", "-qm", "synthetic trusted Gate B base")
    else:
        raise AssertionError("post-commit Gate B fixture did not stabilize")
    authorization_base = git(source, "rev-parse", "HEAD")
    git(source, "branch", "-f", "main", authorization_base)
    (source / "gate-b-proof.txt").write_text("gate-b proof\n", encoding="utf-8")
    git(source, "add", "gate-b-proof.txt")
    git(source, "commit", "-qm", "synthetic current Gate B source")
    head = git(source, "rev-parse", "HEAD")
    source_tree = git(source, "rev-parse", "HEAD^{tree}")
    intake_data = task_intake("gate-b-proof.txt")
    intake_data["task_id"] = "TASK-25"
    intake_data["issue_reference"] = "CANON-TASK-25"
    intake_data["requested_task_type"] = "release"
    intake_data["requested_requirement_ids"] = [synthetic_requirement_id]
    event_data = task_event(
        source,
        authorization_base,
        head,
        workflow_run_id=26001,
        workflow_run_attempt=1,
    )
    trusted_bindings, policy = trusted_context(
        source, authorization_base, intake_data
    )
    requirement_approval = task_approval(
        source,
        authorization_base,
        head,
        hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
        trusted_bindings,
        event_data=event_data,
        task_id="TASK-25",
        intake_id="INTAKE-24",
    )
    authorization = task_start(
        repo_root=source,
        mode="ci-pr-range",
        intake_data=intake_data,
        trusted_event_data=event_data,
        trusted_bindings=trusted_bindings,
        policy_data=policy,
        approval_attestations=(requirement_approval,),
        verification_epoch=VERIFICATION_EPOCH,
    )

    artifacts = root / "artifacts"
    authorization_path, authorization_digest = write_artifact(
        artifacts, "requirements/task-authorization.json", authorization
    )
    approval_path, approval_digest = write_artifact(
        artifacts, "requirements/task-approval.json", requirement_approval
    )
    scenarios = load_authorization_benchmark_scenarios(FIXTURES)
    packages = artifacts / "authorization-packages"
    packages.mkdir(parents=True)
    build_scenario_packages(packages, scenarios, source_root=source)
    report = run_authorization_benchmark(scenarios, packages, source_root=source)
    report_path, report_digest = write_artifact(
        artifacts, "authorization-report.json", canonical_benchmark_bytes(report)
    )

    evidence_registry = json.loads(
        (source / "docs/canon/references/gate-b-evidence-registry.json").read_text(
            encoding="utf-8"
        )
    )
    executions = execute_base_owned_validations(
        source, authorization_base, authorization
    )
    requirement_material: list[dict[str, object]] = []
    attestations: list[dict[str, object]] = []
    for requirement_id in GATE_B_REQUIRED_EVIDENCE_IDS:
        command_id = f"gate-b-{requirement_id}"
        execution = executions[command_id]
        artifact_path, artifact_digest = write_artifact(
            artifacts,
            f"requirements/{command_id}.bin",
            execution["artifact_bytes"],
        )
        attestation = validation_attestation(
            source=source,
            attestation_id=f"VALIDATION-{command_id.upper()}",
            artifact_digest=artifact_digest,
            authorization=authorization,
            event_data=event_data,
            command_id=command_id,
        )
        attestation_path, attestation_digest = write_artifact(
            artifacts,
            f"requirements/{command_id}.attestation.json",
            attestation,
        )
        attestations.append(attestation)
        requirement_material.append(
            {
                "requirement_id": requirement_id,
                "artifact_path": artifact_path,
                "artifact_sha256": artifact_digest,
                "validation_attestation_path": attestation_path,
                "validation_attestation_sha256": attestation_digest,
            }
        )
    suite_finalization = task_finalize(
        repo_root=source,
        authorization=authorization,
        intake_data=intake_data,
        trusted_event_data=event_data,
        trusted_bindings=trusted_bindings,
        policy_data=policy,
        approval_attestations=(requirement_approval,),
        validation_attestations=tuple(attestations),
        verification_epoch=VERIFICATION_EPOCH,
    )
    suite_finalization_path, suite_finalization_digest = write_artifact(
        artifacts,
        "requirements/gate-b-evidence-specific.finalization.json",
        suite_finalization,
    )
    requirements = []
    for material in requirement_material:
        requirements.append(
            {
                **material,
                "status": "green",
                "source_sha": head,
                "authorization_path": authorization_path,
                "authorization_sha256": authorization_digest,
                "approval_attestation_path": approval_path,
                "approval_attestation_sha256": approval_digest,
                "finalization_path": suite_finalization_path,
                "finalization_sha256": suite_finalization_digest,
                "checkout_tree_sha": source_tree,
            }
        )

    rollback_commit = git(source, "rev-parse", "refs/tags/gate-b-rollback^{commit}")
    rollback_tree = git(source, "rev-parse", f"{rollback_commit}^{{tree}}")
    rollback_receipt = cutover_module._rollback_restore_receipt(
        source,
        expected_base_sha=authorization_base,
        source_sha=head,
        rollback_commit_sha=rollback_commit,
        rollback_tree_sha=rollback_tree,
    )
    rollback_binding = {
        "ref": "refs/tags/gate-b-rollback",
        "tag_object_sha": git(source, "rev-parse", "refs/tags/gate-b-rollback"),
        "commit_sha": rollback_commit,
        "tree_sha": rollback_tree,
        "restore_receipt_sha256": hashlib.sha256(
            canonical_json_bytes(rollback_receipt)
        ).hexdigest(),
    }
    rollback_scope = cutover_module._rollback_scope(rollback_binding)

    review_dimensions = list(
        evidence_registry["independent_review"]["required_dimensions"]
    )
    review_verdicts = {
        verdict: "green"
        for verdict in evidence_registry["independent_review"][
            "required_verdicts"
        ]
    }
    review_data = {
        "review_id": "gate-b-independent-review",
        "reviewer_class": "independent",
        "verdict": "green",
        "verdicts": review_verdicts,
        "dimensions": [
            {"dimension_id": dimension, "verdict": "green"}
            for dimension in review_dimensions
        ],
        "base_sha": authorization_base,
        "head_sha": head,
        "commit_range": f"{authorization_base}..{head}",
        "critical_findings": 0,
        "important_findings": 0,
    }
    review_path, review_digest = write_artifact(
        artifacts, "reviews/gate-b.json", review_data
    )
    review_attestation = independent_review_attestation(
        source=source,
        base=authorization_base,
        head=head,
        review_id=review_data["review_id"],
        review_digest=review_digest,
        commit_range=review_data["commit_range"],
        dimensions=review_dimensions,
        verdicts=review_verdicts,
        rollback_scope=rollback_scope,
        current_event=event_data,
    )
    review_attestation_path, review_attestation_digest = write_artifact(
        artifacts, "reviews/gate-b.attestation.json", review_attestation
    )

    owner_request = {
        "decision_id": cutover_module.OWNER_DIRECT_INTEGRATION_DECISION_ID,
        "approval_date": cutover_module.OWNER_DIRECT_INTEGRATION_DECISION_DATE,
        "delegated": False,
        "requested_scope": [
            cutover_module.OWNER_DIRECT_INTEGRATION_SCOPE_LABEL,
            *rollback_scope,
        ],
        "source_sha": head,
        "review_bindings": [
            {
                "review_id": review_data["review_id"],
                "commit_range": review_data["commit_range"],
                "artifact_sha256": review_digest,
                "attestation_sha256": review_attestation_digest,
            }
        ],
        "rollback_binding": rollback_binding,
    }
    owner_request_path, owner_request_digest = write_artifact(
        artifacts, "owner/request.json", owner_request
    )
    owner_approval = approval_attestation(
        source=source,
        base=authorization_base,
        head=head,
        attestation_id="OWNER-GATE-B",
        intake_id="GATE-B-OWNER-REQUEST",
        intake_digest=owner_request_digest,
        approved_scope=[
            cutover_module.OWNER_DIRECT_INTEGRATION_SCOPE_LABEL,
            *rollback_scope,
        ],
        current_event=event_data,
    )
    owner_approval_path, owner_approval_digest = write_artifact(
        artifacts, "owner/approval.json", owner_approval
    )

    visual_completeness = cutover_module.derive_visual_completeness(
        source, authorization_base
    )
    frame_id = "FIGMA-ALL-VISUAL-COVERAGE"
    figma_artifact_bytes = canonical_json_bytes(
        {
            "evidence_kind": "figma-design-export",
            "figma_file_key": "Oik7612LSTUHWsNRFoTlTJ",
            "figma_node_id": "37:438",
            "frame_id": frame_id,
            "frame_version": "R1",
            "merged_visual_ledger_sha256": visual_completeness[
                "merged_visual_ledger_sha256"
            ],
        }
    )
    figma_artifact_path, figma_artifact_digest = write_artifact(
        artifacts, "visual/figma/complete-export.json", figma_artifact_bytes
    )
    figma_export = {
        "accessibility_variants": visual_completeness["accessibility_variants"],
        "artifact_path": figma_artifact_path,
        "artifact_sha256": figma_artifact_digest,
        "byte_size": len(figma_artifact_bytes),
        "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
        "evidence_kind": "figma-design-export",
        "figma_file_key": "Oik7612LSTUHWsNRFoTlTJ",
        "figma_node_id": "37:438",
        "frame_id": frame_id,
        "frame_version": "R1",
        "journey_ids": visual_completeness["journey_ids"],
        "media_type": "application/json",
        "merged_visual_ledger_sha256": visual_completeness[
            "merged_visual_ledger_sha256"
        ],
        "object_ids": visual_completeness["object_ids"],
        "screen_ids": visual_completeness["screen_ids"],
        "state_ids": visual_completeness["state_ids"],
        "visual_requirement_ids": visual_completeness["visual_requirement_ids"],
    }
    frame_ids = [frame_id]
    simulator_renders: list[dict[str, object]] = []
    visual_manifest_data = {
        "schema_version": 1,
        "canon_revision": canon_revision,
        "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
        "evidence_kind": "figma-design-export",
        "figma_exports": [figma_export],
        "final_frame_ids": frame_ids,
        "gap_blocked_state_ids": [],
        "merged_visual_ledger_sha256": visual_completeness[
            "merged_visual_ledger_sha256"
        ],
        "required_review_dimensions": visual_completeness[
            "required_review_dimensions"
        ],
        "simulator_renders": simulator_renders,
        "source_sha": head,
        "source_tree_sha": source_tree,
    }
    visual_manifest_path, visual_manifest_digest = write_artifact(
        artifacts, "visual/manifest.json", visual_manifest_data
    )
    visual_review_data = {
        "review_id": "gate-b-visual-independent-review",
        "reviewer_class": "independent",
        "verdict": "green",
        "dimensions": [
            {"dimension_id": dimension, "verdict": "green"}
            for dimension in visual_completeness["required_review_dimensions"]
        ],
        "base_sha": authorization_base,
        "head_sha": head,
        "commit_range": f"{authorization_base}..{head}",
        "critical_findings": 0,
        "important_findings": 0,
        "manifest_sha256": visual_manifest_digest,
        "merged_visual_ledger_sha256": visual_completeness[
            "merged_visual_ledger_sha256"
        ],
        "final_frame_ids": frame_ids,
        "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
    }
    visual_review_path, visual_review_digest = write_artifact(
        artifacts, "visual/review.json", visual_review_data
    )
    visual_review_scope = [
        "visual-independent-review",
        f"visual-ledger-sha256:{visual_completeness['merged_visual_ledger_sha256']}",
        f"visual-manifest-sha256:{visual_manifest_digest}",
        f"review-range:{authorization_base}..{head}",
        f"claim-ceiling:{cutover_module._VISUAL_CLAIM_CEILING}",
        *(
            f"review-dimension:{dimension}:green"
            for dimension in visual_completeness["required_review_dimensions"]
        ),
        *(f"frame:{current_frame_id}" for current_frame_id in frame_ids),
    ]
    visual_review_attestation = approval_attestation(
        source=source,
        base=authorization_base,
        head=head,
        attestation_id="VISUAL-INDEPENDENT-REVIEW",
        intake_id="VISUAL-INDEPENDENT-REVIEW",
        intake_digest=visual_review_digest,
        approved_scope=visual_review_scope,
        authenticated_principal="reviewer:independent",
        approval_policy_id="independent-review",
        task_id="TASK-25-GATE-B-VISUAL-REVIEW",
        current_event=event_data,
    )
    visual_review_attestation_path, visual_review_attestation_digest = write_artifact(
        artifacts, "visual/review.attestation.json", visual_review_attestation
    )
    visual_decision = {
        "decision_id": "visual-owner-final",
        "delegated": False,
        "canon_revision": canon_revision,
        "source_sha": head,
        "source_tree_sha": source_tree,
        "evidence_kind": "figma-design-export",
        "merged_visual_ledger_sha256": visual_completeness[
            "merged_visual_ledger_sha256"
        ],
        "manifest_sha256": visual_manifest_digest,
        "review_sha256": visual_review_digest,
        "review_attestation_sha256": visual_review_attestation_digest,
        "final_frame_ids": frame_ids,
        "gap_blocked_state_ids": [],
        "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
    }
    visual_decision_path, visual_decision_digest = write_artifact(
        artifacts, "visual/decision.json", visual_decision
    )
    visual_scope = [
        "visual-owner-final",
        f"canon-revision:{canon_revision}",
        f"source-sha:{head}",
        f"source-tree-sha:{source_tree}",
        "evidence-kind:figma-design-export",
        f"visual-ledger-sha256:{visual_completeness['merged_visual_ledger_sha256']}",
        f"visual-manifest-sha256:{visual_manifest_digest}",
        f"visual-review-sha256:{visual_review_digest}",
        f"visual-review-attestation-sha256:{visual_review_attestation_digest}",
        f"visual-review-range:{authorization_base}..{head}",
        f"claim-ceiling:{cutover_module._VISUAL_CLAIM_CEILING}",
        *(f"frame:{current_frame_id}" for current_frame_id in frame_ids),
        (
            "figma-export:"
            f"{frame_id}:{figma_export['figma_file_key']}:"
            f"{figma_export['figma_node_id']}:{figma_export['frame_version']}:"
            f"{figma_export['artifact_sha256']}:{figma_export['byte_size']}"
        ),
    ]
    visual_approval = approval_attestation(
        source=source,
        base=authorization_base,
        head=head,
        attestation_id="VISUAL-OWNER-FINAL",
        intake_id="VISUAL-OWNER-DECISION",
        intake_digest=visual_decision_digest,
        approved_scope=visual_scope,
        current_event=event_data,
    )
    visual_approval_path, visual_approval_digest = write_artifact(
        artifacts, "visual/approval.json", visual_approval
    )

    manifest = source / "docs/canon/MANIFEST.toml"
    verifier_path = "tools/ambitions_canon/cutover_readiness.py"
    verifier_bytes = subprocess.run(
        ["git", "show", f"{authorization_base}:{verifier_path}"],
        cwd=source,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout
    evidence = {
        "schema_version": 1,
        "evidence_revision": "gate-b-evidence-v2",
        "expected_base_sha": authorization_base,
        "canon_revision": canon_revision,
        "canon_manifest_path": "docs/canon/MANIFEST.toml",
        "canon_manifest_sha256": digest(manifest),
        "source_sha": head,
        "source_tree_sha": source_tree,
        "gate_b_requested_state": "green",
        "bootstrap_approval_ceiling": BOOTSTRAP_CLAIM_CEILING,
        "evidence_registry": {
            "path": "docs/canon/references/gate-b-evidence-registry.json",
            "sha256": digest(
                source / "docs/canon/references/gate-b-evidence-registry.json"
            ),
            "base_sha": authorization_base,
        },
        "verifier": {
            "path": verifier_path,
            "ref": "refs/heads/main",
            "base_sha": authorization_base,
            "base_tree_sha": git(source, "rev-parse", f"{authorization_base}^{{tree}}"),
            "blob_sha256": hashlib.sha256(verifier_bytes).hexdigest(),
            "check_identity": "gate-b-cutover-readiness",
            "integration_id": "isolated-base-checkout",
        },
        "requirements": requirements,
        "authorization_benchmark": {
            "report_path": report_path,
            "report_sha256": report_digest,
            "packages_root": "authorization-packages",
            "source_sha": head,
        },
        "reviews": [
            {
                **review_data,
                "artifact_path": review_path,
                "artifact_sha256": review_digest,
                "review_attestation_path": review_attestation_path,
                "review_attestation_sha256": review_attestation_digest,
            }
        ],
        "owner_decision": {
            "approved": True,
            "decision_id": cutover_module.OWNER_DIRECT_INTEGRATION_DECISION_ID,
            "approval_date": cutover_module.OWNER_DIRECT_INTEGRATION_DECISION_DATE,
            "approved_scope": [
                cutover_module.OWNER_DIRECT_INTEGRATION_SCOPE_LABEL,
                *rollback_scope,
            ],
            "delegated": False,
            "waived_checks": False,
            "request_path": owner_request_path,
            "request_sha256": owner_request_digest,
            "approval_attestation_path": owner_approval_path,
            "approval_attestation_sha256": owner_approval_digest,
        },
        "rollback": rollback_binding,
        "protected_boundary": {
            "authority_routing_cutover_only": True,
            "live_enforcement_proven": False,
            "post_merge_receipt_required": False,
        },
        "visual_owner_approval": {
            "delegated": False,
            "canon_revision": canon_revision,
            "source_sha": head,
            "evidence_kind": "figma-design-export",
            "merged_visual_ledger_sha256": visual_completeness[
                "merged_visual_ledger_sha256"
            ],
            "manifest_path": visual_manifest_path,
            "manifest_sha256": visual_manifest_digest,
            "review": {
                "artifact_path": visual_review_path,
                "artifact_sha256": visual_review_digest,
                "base_sha": authorization_base,
                "head_sha": head,
                "commit_range": f"{authorization_base}..{head}",
                "attestation_path": visual_review_attestation_path,
                "attestation_sha256": visual_review_attestation_digest,
            },
            "decision_receipt_path": visual_decision_path,
            "decision_receipt_sha256": visual_decision_digest,
            "approval_attestation_path": visual_approval_path,
            "approval_attestation_sha256": visual_approval_digest,
            "final_frame_ids": frame_ids,
            "figma_exports": [figma_export],
            "simulator_renders": simulator_renders,
            "gap_blocked_state_ids": [],
            "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
        },
    }
    evidence_path = artifacts / "gate-b-evidence.json"
    evidence_path.write_bytes(canonical_json_bytes(evidence))
    return source, artifacts, evidence_path


class OwnerDirectIntegrationPostureTests(unittest.TestCase):
    def test_gate_b_direct_integration_excludes_protected_enforcement(self) -> None:
        blockers: list[str] = []
        cutover_module._verify_protected(
            {
                "authority_routing_cutover_only": True,
                "live_enforcement_proven": False,
                "post_merge_receipt_required": False,
            },
            blockers,
        )
        self.assertEqual(blockers, [])

        red = cutover_module._red_assessment(["TEST_BLOCKER"])
        self.assertNotIn("task_26_installation_authorized", red)
        self.assertFalse(red["task_26_authority_routing_cutover_authorized"])
        self.assertFalse(red["live_enforcement_proven"])
        self.assertFalse(red["post_merge_receipt_required"])
        self.assertIn(
            "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z",
            BOOTSTRAP_CLAIM_CEILING,
        )
        self.assertIn(
            "protected CI installation and protected enforcement are explicitly excluded",
            BOOTSTRAP_CLAIM_CEILING,
        )

    def test_gate_b_owner_decision_is_exact_and_rejects_legacy_contract(self) -> None:
        rollback = {
            "ref": "refs/tags/owner-direct-rollback",
            "tag_object_sha": "1" * 40,
            "commit_sha": "2" * 40,
            "tree_sha": "3" * 40,
            "restore_receipt_sha256": "4" * 64,
        }
        rollback_scope = cutover_module._rollback_scope(rollback)
        owner_scope = [
            "Task 26 authority/routing cutover only",
            *rollback_scope,
        ]
        review = {
            "review_id": "task24-exact-high-risk-review",
            "commit_range": f"{'a' * 40}..{'b' * 40}",
            "artifact_sha256": "5" * 64,
            "review_attestation_sha256": "6" * 64,
        }
        review_binding = {
            "review_id": review["review_id"],
            "commit_range": review["commit_range"],
            "artifact_sha256": review["artifact_sha256"],
            "attestation_sha256": review["review_attestation_sha256"],
        }
        owner = {
            "approved": True,
            "decision_id": "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z",
            "approval_date": "2026-07-17",
            "approved_scope": owner_scope,
            "delegated": False,
            "waived_checks": False,
            "request_path": "owner/request.json",
            "request_sha256": "7" * 64,
            "approval_attestation_path": "owner/approval.json",
            "approval_attestation_sha256": "8" * 64,
        }
        request = {
            "decision_id": owner["decision_id"],
            "approval_date": owner["approval_date"],
            "delegated": owner["delegated"],
            "requested_scope": owner_scope,
            "source_sha": "b" * 40,
            "review_bindings": [review_binding],
            "rollback_binding": rollback,
        }
        with (
            mock.patch.object(
                cutover_module, "_artifact_json", side_effect=[request, {}]
            ),
            mock.patch.object(cutover_module, "_verify_approval") as verify,
        ):
            blockers: list[str] = []
            cutover_module._verify_owner(
                owner,
                [review],
                "b" * 40,
                ROOT,
                ROOT,
                {},
                rollback,
                "a" * 40,
                {},
                set(),
                blockers,
            )
        self.assertEqual(blockers, [])
        self.assertEqual(verify.call_args.kwargs["approved_scope"], owner_scope)

        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        properties = schema["$defs"]["ownerDecision"]["properties"]
        self.assertEqual(properties["approved"]["const"], True)
        self.assertEqual(
            properties["decision_id"]["const"], owner["decision_id"]
        )
        self.assertEqual(properties["approval_date"]["const"], "2026-07-17")
        self.assertEqual(properties["delegated"]["const"], False)
        self.assertEqual(
            properties["approved_scope"]["prefixItems"][0]["const"],
            "Task 26 authority/routing cutover only",
        )
        cutover_module._validate_json_schema(
            owner,
            schema["$defs"]["ownerDecision"],
            root_schema=schema,
            location="$.owner_decision",
        )

        cases = {
            "legacy-decision": {
                **owner,
                "decision_id": "owner-gate-b-bootstrap",
            },
            "legacy-scope": {
                **owner,
                "approved_scope": ["Task 26 installation only", *rollback_scope],
            },
            "delegated": {**owner, "delegated": True},
            "wrong-date": {**owner, "approval_date": "2026-07-14"},
        }
        for name, candidate in cases.items():
            with self.subTest(name=name):
                if name != "legacy-scope":
                    with self.assertRaises(ValueError):
                        cutover_module._validate_json_schema(
                            candidate,
                            schema["$defs"]["ownerDecision"],
                            root_schema=schema,
                            location="$.owner_decision",
                        )
                candidate_blockers: list[str] = []
                cutover_module._verify_owner(
                    candidate,
                    [review],
                    "b" * 40,
                    ROOT,
                    ROOT,
                    {},
                    rollback,
                    "a" * 40,
                    {},
                    set(),
                    candidate_blockers,
                )
                self.assertTrue(candidate_blockers)


class GateBDomainAdversarialTests(unittest.TestCase):
    def clone_root(self, directory: str) -> Path:
        source = Path(directory) / "source"
        subprocess.run(
            ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return source

    def entry(self, evidence_id: str) -> dict[str, object]:
        registry = json.loads(EVIDENCE_REGISTRY.read_text(encoding="utf-8"))
        return next(
            item
            for item in registry["requirements"]
            if item["evidence_id"] == evidence_id
        )

    def payload(self, source: Path, evidence_id: str) -> dict[str, object]:
        head = git(source, "rev-parse", "HEAD")
        return cutover_module._gate_b_substantive_payload(
            source,
            source_sha=head,
            source_tree=git(source, "rev-parse", "HEAD^{tree}"),
            entry=self.entry(evidence_id),
        )

    def _requirement_loop_fixture(self) -> dict[str, object]:
        evidence_ids = ("no-p0-gap", "rollback-proven")
        source_sha = "a" * 40
        source_tree = "b" * 40
        expected_base_sha = "c" * 40
        required_bindings = [
            "command_argv_sha256",
            "expected_base_sha",
            "input_sha256",
            "merge_base_sha",
            "source_sha",
            "source_tree_sha",
        ]
        entries = []
        requirements = []
        stored_artifacts: dict[str, object] = {}
        command_outputs: dict[str, bytes] = {}
        command_digests: dict[str, str] = {}
        for index, evidence_id in enumerate(evidence_ids):
            command_id = f"gate-b-{evidence_id}"
            argv = cutover_module._gate_b_command_argv(evidence_id)
            argv_digest = hashlib.sha256(canonical_json_bytes(argv)).hexdigest()
            command_digests[command_id] = argv_digest
            payload = {"evidence_id": evidence_id, "proof": "synthetic"}
            envelope = {
                "schema_version": 1,
                "command_id": command_id,
                "argv": argv,
                "exit_status": 0,
                "stdout_base64url": base64.urlsafe_b64encode(
                    canonical_json_bytes(payload)
                )
                .rstrip(b"=")
                .decode("ascii"),
                "stderr_base64url": "",
            }
            artifact_path = f"requirement-{index}.artifact.json"
            attestation_path = f"requirement-{index}.attestation.json"
            artifact_digest = hashlib.sha256(
                canonical_json_bytes(envelope)
            ).hexdigest()
            attestation = {
                "artifact_digest": artifact_digest,
                "command_id": command_id,
                "command_argv_digest": argv_digest,
            }
            attestation_digest = hashlib.sha256(
                canonical_json_bytes(attestation)
            ).hexdigest()
            stored_artifacts[artifact_path] = envelope
            stored_artifacts[attestation_path] = attestation
            command_outputs[evidence_id] = canonical_json_bytes(envelope)
            observation_kind = f"synthetic-{index}"
            semantic = f"synthetic canonical requirement {index}"
            entries.append(
                {
                    "evidence_id": evidence_id,
                    "command_id": command_id,
                    "output_schema": f"schema-{index}",
                    "required_bindings": required_bindings,
                    "result_parser": {
                        "kind": "gate-b-substantive-observation-v1",
                        "evidence_id": evidence_id,
                        "semantic": semantic,
                        "observation_kind": observation_kind,
                    },
                    "semantic": semantic,
                    "observation_kind": observation_kind,
                }
            )
            requirements.append(
                {
                    "requirement_id": evidence_id,
                    "status": "green",
                    "artifact_path": artifact_path,
                    "artifact_sha256": artifact_digest,
                    "authorization_path": "shared-authorization.json",
                    "authorization_sha256": "d" * 64,
                    "approval_attestation_path": "shared-approval.json",
                    "approval_attestation_sha256": "e" * 64,
                    "finalization_path": "shared-finalization.json",
                    "finalization_sha256": "f" * 64,
                    "checkout_tree_sha": source_tree,
                    "source_sha": source_sha,
                    "validation_attestation_path": attestation_path,
                    "validation_attestation_sha256": attestation_digest,
                }
            )
        event = {
            "trusted_head_sha": source_sha,
            "trusted_base_sha": expected_base_sha,
            "verification_epoch": 1_900_000_000,
        }
        authorization = {
            "trusted_event_provenance": event,
            "intake": {"task_id": "TASK-25"},
            "tree_delta": {"new_tree_sha": source_tree},
            "computed_command_digests": command_digests,
        }
        finalization = {"finalization": "synthetic"}
        stored_artifacts.update(
            {
                "shared-authorization.json": authorization,
                "shared-approval.json": {"approval": "synthetic"},
                "shared-finalization.json": finalization,
            }
        )
        return {
            "artifact_root": Path("/unused/artifacts"),
            "artifacts": stored_artifacts,
            "authorization": authorization,
            "command_outputs": command_outputs,
            "entries": entries,
            "event": event,
            "evidence_ids": evidence_ids,
            "expected_base_sha": expected_base_sha,
            "finalization": finalization,
            "registry": {
                "requirements": entries,
                "output_schemas": {
                    f"schema-{index}": {"type": "object"}
                    for index in range(len(entries))
                },
                "payload_schema": {"type": "object"},
            },
            "requirements": requirements,
            "source_sha": source_sha,
            "source_tree": source_tree,
        }

    def _run_requirement_loop_fixture(
        self, fixture: dict[str, object]
    ) -> tuple[object, list[str], list[str], list[str], int]:
        stored_artifacts = fixture["artifacts"]
        command_outputs = fixture["command_outputs"]
        executed: list[str] = []
        timeline: list[str] = []
        blockers: list[str] = []

        def artifact_json(
            _root: Path, relative: object, _digest: object, _code: str
        ) -> object:
            return stored_artifacts[str(relative)]

        def execute_command(
            _repo: Path, evidence_id: str, *, executable_repo: Path | None = None
        ) -> bytes:
            del executable_repo
            executed.append(evidence_id)
            timeline.append(f"command:{evidence_id}")
            return command_outputs[evidence_id]

        def substantive_payload(
            _repo: Path,
            *,
            source_sha: str,
            source_tree: str,
            entry: dict[str, object],
            executable_repo: Path | None = None,
        ) -> dict[str, object]:
            del source_sha, source_tree, executable_repo
            return {
                "evidence_id": entry["evidence_id"],
                "proof": "synthetic",
            }

        def finalize_task(**_kwargs: object) -> object:
            timeline.append("trust-preflight:finalize")
            error = fixture.get("finalization_error")
            if isinstance(error, Exception):
                raise error
            return fixture["finalization"]

        with (
            mock.patch.object(cutover_module, "_artifact_json", artifact_json),
            mock.patch.object(cutover_module, "_validate_json_schema"),
            mock.patch.object(
                cutover_module,
                "_execute_gate_b_command",
                side_effect=execute_command,
            ),
            mock.patch.object(
                cutover_module,
                "_gate_b_substantive_payload",
                substantive_payload,
            ),
            mock.patch.object(cutover_module, "load_base_policy", return_value={}),
            mock.patch.object(
                cutover_module, "load_trusted_bindings", return_value={}
            ),
            mock.patch.object(
                cutover_module,
                "task_start",
                return_value=fixture["authorization"],
            ),
            mock.patch.object(
                cutover_module,
                "task_finalize",
                side_effect=finalize_task,
            ) as finalize,
            mock.patch.object(
                cutover_module,
                "GATE_B_REQUIRED_EVIDENCE_IDS",
                fixture["evidence_ids"],
            ),
        ):
            observed_event = cutover_module._verify_requirements(
                fixture["requirements"],
                fixture["source_sha"],
                fixture["source_tree"],
                Path("/unused/repo"),
                Path("/unused/command"),
                Path("/unused/verifier"),
                fixture["artifact_root"],
                {"anchors": []},
                fixture["registry"],
                fixture["expected_base_sha"],
                blockers,
            )
        return observed_event, blockers, executed, timeline, finalize.call_count

    def test_requirement_failures_are_canonical_first_failure_and_fail_fast(
        self,
    ) -> None:
        cases = (
            ("invalid", "GATE_B_REQUIREMENT_INVALID", []),
            ("duplicate", "GATE_B_REQUIREMENT_DUPLICATE", []),
            ("missing", "GATE_B_REQUIREMENT_MISSING", []),
            ("unknown", "GATE_B_REQUIREMENT_UNKNOWN", []),
            ("not-green", "GATE_B_REQUIREMENT_NOT_GREEN", []),
            ("stale", "GATE_B_REQUIREMENT_NOT_GREEN", []),
            ("artifact-semantic", "GATE_B_REQUIREMENT_SEMANTICS", ["no-p0-gap"]),
            ("context-registry", "GATE_B_REQUIREMENT_REGISTRY", []),
            (
                "attestation",
                "GATE_B_REQUIREMENT_ATTESTATION_INVALID",
                [],
            ),
        )
        for name, expected_blocker, expected_executed in cases:
            with self.subTest(name=name):
                fixture = self._requirement_loop_fixture()
                requirements = fixture["requirements"]
                first = requirements[0]
                if name == "invalid":
                    del first["status"]
                elif name == "duplicate":
                    first["requirement_id"] = requirements[1]["requirement_id"]
                elif name == "missing":
                    requirements = requirements[1:]
                elif name == "unknown":
                    first["requirement_id"] = "caller-green-label"
                elif name == "not-green":
                    first["status"] = "red"
                elif name == "stale":
                    first["source_sha"] = "0" * 40
                elif name == "artifact-semantic":
                    fixture["command_outputs"]["no-p0-gap"] = b"forged semantics"
                elif name == "context-registry":
                    fixture["authorization"]["computed_command_digests"][
                        "gate-b-no-p0-gap"
                    ] = "0" * 64
                else:
                    fixture["finalization_error"] = (
                        cutover_module.AuthorizationError(
                            "AUTH_VALIDATION_SIGNATURE",
                            "forged canonical validation signature",
                        )
                    )
                fixture["requirements"] = list(reversed(requirements))

                _, blockers, executed, _, _ = (
                    self._run_requirement_loop_fixture(fixture)
                )

                self.assertEqual(blockers, [expected_blocker])
                self.assertEqual(executed, expected_executed)
                self.assertNotIn("rollback-proven", executed)

    def test_positive_requirements_process_in_canonical_registry_order(self) -> None:
        fixture = self._requirement_loop_fixture()
        fixture["requirements"] = list(reversed(fixture["requirements"]))

        observed_event, blockers, executed, timeline, finalize_count = (
            self._run_requirement_loop_fixture(fixture)
        )

        self.assertEqual(observed_event, fixture["event"])
        self.assertEqual(blockers, [])
        self.assertEqual(executed, list(fixture["evidence_ids"]))
        self.assertEqual(
            timeline,
            [
                "trust-preflight:finalize",
                "command:no-p0-gap",
                "command:rollback-proven",
            ],
        )
        self.assertEqual(finalize_count, 1)

    def test_invalid_shared_finalization_is_recomputed_once_and_keeps_specific_blocker(
        self,
    ) -> None:
        evidence_ids = ("no-p0-gap", "rollback-proven")
        source_sha = "a" * 40
        source_tree = "b" * 40
        expected_base_sha = "c" * 40
        required_bindings = [
            "command_argv_sha256",
            "expected_base_sha",
            "input_sha256",
            "merge_base_sha",
            "source_sha",
            "source_tree_sha",
        ]
        entries = []
        requirements = []
        stored_artifacts: dict[str, object] = {}
        command_outputs: dict[str, bytes] = {}
        command_digests: dict[str, str] = {}
        for index, evidence_id in enumerate(evidence_ids):
            command_id = f"gate-b-{evidence_id}"
            argv = cutover_module._gate_b_command_argv(evidence_id)
            argv_digest = hashlib.sha256(canonical_json_bytes(argv)).hexdigest()
            command_digests[command_id] = argv_digest
            payload = {"evidence_id": evidence_id, "proof": "synthetic"}
            encoded_payload = base64.urlsafe_b64encode(
                canonical_json_bytes(payload)
            ).rstrip(b"=").decode("ascii")
            envelope = {
                "command_id": command_id,
                "argv": argv,
                "exit_status": 0,
                "stdout_base64url": encoded_payload,
                "stderr_base64url": "",
            }
            artifact_path = f"requirement-{index}.artifact.json"
            attestation_path = f"requirement-{index}.attestation.json"
            artifact_digest = f"{index + 1}" * 64
            attestation_digest = f"{index + 3}" * 64
            stored_artifacts[artifact_path] = envelope
            stored_artifacts[attestation_path] = {
                "artifact_digest": artifact_digest,
                "command_id": command_id,
                "command_argv_digest": argv_digest,
            }
            command_outputs[evidence_id] = canonical_json_bytes(envelope)
            observation_kind = f"synthetic-{index}"
            semantic = f"synthetic shared finalization {index}"
            entries.append(
                {
                    "evidence_id": evidence_id,
                    "command_id": command_id,
                    "output_schema": f"schema-{index}",
                    "required_bindings": required_bindings,
                    "result_parser": {
                        "kind": "gate-b-substantive-observation-v1",
                        "evidence_id": evidence_id,
                        "semantic": semantic,
                        "observation_kind": observation_kind,
                    },
                    "semantic": semantic,
                    "observation_kind": observation_kind,
                }
            )
            requirements.append(
                {
                    "requirement_id": evidence_id,
                    "status": "green",
                    "artifact_path": artifact_path,
                    "artifact_sha256": artifact_digest,
                    "authorization_path": "shared-authorization.json",
                    "authorization_sha256": "d" * 64,
                    "approval_attestation_path": "shared-approval.json",
                    "approval_attestation_sha256": "e" * 64,
                    "finalization_path": "shared-finalization.json",
                    "finalization_sha256": "f" * 64,
                    "checkout_tree_sha": source_tree,
                    "source_sha": source_sha,
                    "validation_attestation_path": attestation_path,
                    "validation_attestation_sha256": attestation_digest,
                }
            )
        event = {
            "trusted_head_sha": source_sha,
            "trusted_base_sha": expected_base_sha,
            "verification_epoch": 1_900_000_000,
        }
        authorization = {
            "trusted_event_provenance": event,
            "intake": {"task_id": "TASK-25"},
            "tree_delta": {"new_tree_sha": source_tree},
            "computed_command_digests": command_digests,
        }
        stored_artifacts.update(
            {
                "shared-authorization.json": authorization,
                "shared-approval.json": {"approval": "synthetic"},
                "shared-finalization.json": {"finalization": "synthetic"},
            }
        )
        evidence_registry = {
            "requirements": entries,
            "output_schemas": {
                f"schema-{index}": {"type": "object"}
                for index in range(len(entries))
            },
            "payload_schema": {"type": "object"},
        }
        blockers: list[str] = []

        def artifact_json(
            _root: Path, relative: object, _digest: object, _code: str
        ) -> object:
            return stored_artifacts[str(relative)]

        def execute_command(
            _repo: Path, evidence_id: str, *, executable_repo: Path | None = None
        ) -> bytes:
            del executable_repo
            return command_outputs[evidence_id]

        def substantive_payload(
            _repo: Path,
            *,
            source_sha: str,
            source_tree: str,
            entry: dict[str, object],
            executable_repo: Path | None = None,
        ) -> dict[str, object]:
            del source_sha, source_tree, executable_repo
            return {
                "evidence_id": entry["evidence_id"],
                "proof": "synthetic",
            }

        with (
            mock.patch.object(cutover_module, "_artifact_json", artifact_json),
            mock.patch.object(cutover_module, "_validate_json_schema"),
            mock.patch.object(
                cutover_module,
                "_execute_gate_b_command",
                side_effect=execute_command,
            ) as execute,
            mock.patch.object(
                cutover_module,
                "_gate_b_substantive_payload",
                substantive_payload,
            ),
            mock.patch.object(cutover_module, "load_base_policy", return_value={}),
            mock.patch.object(
                cutover_module, "load_trusted_bindings", return_value={}
            ),
            mock.patch.object(
                cutover_module, "task_start", return_value=authorization
            ),
            mock.patch.object(
                cutover_module,
                "task_finalize",
                side_effect=cutover_module.AuthorizationError(
                    "AUTH_VALIDATION_SIGNATURE", "forged shared attestation"
                ),
            ) as finalize,
            mock.patch.object(
                cutover_module,
                "GATE_B_REQUIRED_EVIDENCE_IDS",
                evidence_ids,
            ),
        ):
            observed_event = cutover_module._verify_requirements(
                requirements,
                source_sha,
                source_tree,
                Path("/unused/repo"),
                Path("/unused/command"),
                Path("/unused/verifier"),
                Path("/unused/artifacts"),
                {"anchors": []},
                evidence_registry,
                expected_base_sha,
                blockers,
            )

        self.assertEqual(observed_event, event)
        self.assertEqual(finalize.call_count, 1)
        self.assertEqual(execute.call_count, 0)
        self.assertEqual(blockers, ["GATE_B_REQUIREMENT_ATTESTATION_INVALID"])

    def test_requirement_registry_mismatch_stops_before_later_commands(
        self,
    ) -> None:
        evidence_ids = ("no-p0-gap", "rollback-proven")
        source_sha = "a" * 40
        source_tree = "b" * 40
        expected_base_sha = "c" * 40
        entries = []
        requirements = []
        artifacts: dict[str, object] = {}
        for index, evidence_id in enumerate(evidence_ids):
            command_id = f"gate-b-{evidence_id}"
            artifact_path = f"requirement-{index}.json"
            artifact_command_id = (
                "caller-green-label" if index == 0 else command_id
            )
            artifacts[artifact_path] = {
                "command_id": artifact_command_id,
                "argv": cutover_module._gate_b_command_argv(evidence_id),
            }
            entries.append(
                {
                    "evidence_id": evidence_id,
                    "command_id": command_id,
                    "output_schema": f"schema-{index}",
                }
            )
            requirements.append(
                {
                    "requirement_id": evidence_id,
                    "status": "green",
                    "artifact_path": artifact_path,
                    "artifact_sha256": f"{index + 1}" * 64,
                    "authorization_path": "unused-authorization.json",
                    "authorization_sha256": "d" * 64,
                    "approval_attestation_path": "unused-approval.json",
                    "approval_attestation_sha256": "e" * 64,
                    "finalization_path": "unused-finalization.json",
                    "finalization_sha256": "f" * 64,
                    "checkout_tree_sha": source_tree,
                    "source_sha": source_sha,
                    "validation_attestation_path": "unused-attestation.json",
                    "validation_attestation_sha256": "9" * 64,
                }
            )
        evidence_registry = {
            "requirements": entries,
            "output_schemas": {
                f"schema-{index}": {"type": "object"}
                for index in range(len(entries))
            },
            "payload_schema": {"type": "object"},
        }
        blockers: list[str] = []

        def artifact_json(
            _root: Path, relative: object, _digest: object, _code: str
        ) -> object:
            return artifacts[str(relative)]

        with (
            mock.patch.object(cutover_module, "_artifact_json", artifact_json),
            mock.patch.object(cutover_module, "_validate_json_schema"),
            mock.patch.object(
                cutover_module,
                "_execute_gate_b_command",
                return_value=b"later command must remain unexecuted",
            ) as execute,
            mock.patch.object(
                cutover_module, "GATE_B_REQUIRED_EVIDENCE_IDS", evidence_ids
            ),
        ):
            observed_event = cutover_module._verify_requirements(
                requirements,
                source_sha,
                source_tree,
                Path("/unused/repo"),
                Path("/unused/command"),
                Path("/unused/verifier"),
                Path("/unused/artifacts"),
                {"anchors": []},
                evidence_registry,
                expected_base_sha,
                blockers,
            )

        self.assertIsNone(observed_event)
        self.assertEqual(blockers[0], "GATE_B_REQUIREMENT_REGISTRY")
        self.assertEqual(execute.call_count, 0)

    def _static_artifact_preflight_assessment(
        self, *, forged_artifact: str
    ) -> tuple[dict[str, object], mock.Mock]:
        source_sha = "a" * 40
        source_tree = "b" * 40
        expected_base_sha = "c" * 40
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            repo = root / "repo"
            artifacts = root / "artifacts"
            repo.mkdir()
            artifacts.mkdir()
            manifest_bytes = b"canon_revision = 1\n"
            (repo / "canon.toml").write_bytes(manifest_bytes)

            benchmark_report = {
                "status": "green",
                "scenario_ids": list(AUTHORIZATION_SCENARIO_IDS),
                "task24_tree_matrix": {
                    "source_sha": source_sha,
                    "python_implementation": "cpython",
                    "python_version": "3.12",
                    "executed_test_count": 2,
                    "test_ids": ["first", "second"],
                },
            }
            if forged_artifact == "benchmark":
                benchmark_report = {"schema_version": 1, "status": "green"}
            benchmark_bytes = canonical_json_bytes(benchmark_report)
            (artifacts / "benchmark.json").write_bytes(benchmark_bytes)

            owner_request_bytes = canonical_json_bytes({"request": "pinned"})
            owner_attestation_bytes = canonical_json_bytes(
                {"attestation": "pinned"}
            )
            (artifacts / "owner-request.json").write_bytes(owner_request_bytes)
            (artifacts / "owner-attestation.json").write_bytes(
                owner_attestation_bytes
            )
            owner_attestation_digest = hashlib.sha256(
                owner_attestation_bytes
            ).hexdigest()
            if forged_artifact == "owner":
                owner_attestation_digest = "0" * 64

            evidence = {field: None for field in cutover_module._TOP_LEVEL_FIELDS}
            evidence.update(
                {
                    "schema_version": 1,
                    "evidence_revision": "static-artifact-preflight-test",
                    "canon_manifest_path": "canon.toml",
                    "canon_manifest_sha256": hashlib.sha256(
                        manifest_bytes
                    ).hexdigest(),
                    "canon_revision": 1,
                    "source_sha": source_sha,
                    "source_tree_sha": source_tree,
                    "expected_base_sha": expected_base_sha,
                    "gate_b_requested_state": "green",
                    "bootstrap_approval_ceiling": BOOTSTRAP_CLAIM_CEILING,
                    "requirements": [],
                    "authorization_benchmark": {
                        "report_path": "benchmark.json",
                        "report_sha256": hashlib.sha256(
                            benchmark_bytes
                        ).hexdigest(),
                        "packages_root": "unused-packages",
                        "source_sha": source_sha,
                    },
                    "owner_decision": {
                        "request_path": "owner-request.json",
                        "request_sha256": hashlib.sha256(
                            owner_request_bytes
                        ).hexdigest(),
                        "approval_attestation_path": "owner-attestation.json",
                        "approval_attestation_sha256": owner_attestation_digest,
                    },
                }
            )

            def git_text(_repo: Path, *arguments: str) -> str:
                if arguments == ("rev-parse", "HEAD"):
                    return source_sha
                if arguments == ("rev-parse", "HEAD^{tree}"):
                    return source_tree
                if arguments == ("status", "--porcelain=v1"):
                    return ""
                raise AssertionError(arguments)

            def git_bytes(_repo: Path, *arguments: str) -> bytes:
                if arguments == ("show", f"{source_sha}:canon.toml"):
                    return manifest_bytes
                return b""

            with (
                mock.patch.object(
                    cutover_module, "_read_primary_evidence", return_value=evidence
                ),
                mock.patch.object(cutover_module, "_git_checkout", return_value=repo),
                mock.patch.object(cutover_module, "validate_gate_b_evidence_schema"),
                mock.patch.object(cutover_module, "_git_text", side_effect=git_text),
                mock.patch.object(cutover_module, "_git", side_effect=git_bytes),
                mock.patch.object(
                    cutover_module, "_preflight_requirement_ids", return_value=[]
                ),
                mock.patch.object(cutover_module, "_preflight_task25_candidate_paths"),
                mock.patch.object(
                    cutover_module, "_load_evidence_registry", return_value={}
                ),
                mock.patch.object(
                    cutover_module, "_load_trust_anchors", return_value={}
                ),
                mock.patch.object(
                    cutover_module, "_is_exact_clean_gate_b_source", return_value=True
                ),
                mock.patch.object(
                    cutover_module,
                    "_prepare_requirements",
                    return_value=(None, {"prepared": True}),
                ),
                mock.patch.object(
                    cutover_module, "_execute_requirement_semantics"
                ) as execute_requirements,
                mock.patch.object(cutover_module, "_verify_current_event", return_value=None),
                mock.patch.object(cutover_module, "_verify_reviews"),
                mock.patch.object(cutover_module, "_verify_owner"),
                mock.patch.object(cutover_module, "_verify_rollback"),
                mock.patch.object(cutover_module, "_verify_protected"),
                mock.patch.object(cutover_module, "_verify_visual_owner_v2"),
            ):
                assessment = cutover_module._evaluate_gate_b_core(
                    root / "unused-evidence.json",
                    repo_root=repo,
                    artifact_root=artifacts,
                    expected_base_sha=expected_base_sha,
                    authenticated_rollback={},
                    authenticated_current_event={},
                )
        return assessment, execute_requirements

    def test_forged_benchmark_shape_fails_before_requirement_commands(self) -> None:
        assessment, execute_requirements = self._static_artifact_preflight_assessment(
            forged_artifact="benchmark"
        )

        execute_requirements.assert_not_called()
        self.assertEqual(
            assessment["blocking_codes"], ["GATE_B_BENCHMARK_MISMATCH"]
        )

    def test_forged_owner_digest_fails_before_requirement_commands(self) -> None:
        assessment, execute_requirements = self._static_artifact_preflight_assessment(
            forged_artifact="owner"
        )

        execute_requirements.assert_not_called()
        self.assertEqual(
            assessment["blocking_codes"], ["GATE_B_OWNER_APPROVAL_INVALID"]
        )

    def _phase_boundary_assessment(
        self, *, failure_at: str | None
    ) -> tuple[dict[str, object], list[str]]:
        source_sha = "a" * 40
        source_tree = "b" * 40
        expected_base_sha = "c" * 40
        requirement_ids = tuple(
            f"prepared-requirement-{index:02d}" for index in range(18)
        )
        requirement_event = {
            "event_attestation_origin": "trusted-ci",
            "event_projection_digest": "synthetic-current-event",
        }
        timeline: list[str] = []
        blocker_codes = {
            "current-event": "GATE_B_CURRENT_EVENT_INVALID",
            "rollback": "GATE_B_ROLLBACK_UNVERIFIED",
            "protected": "GATE_B_PROTECTED_BOUNDARY_INVALID",
            "reviews": "GATE_B_REVIEW_INVALID",
            "owner": "GATE_B_OWNER_APPROVAL_INVALID",
            "visual": "GATE_B_VISUAL_OWNER_INVALID",
            "benchmark-static": "GATE_B_BENCHMARK_MISMATCH",
        }

        def record_preflight(
            name: str, blockers: list[str], result: object = None
        ) -> object:
            timeline.append(name)
            if failure_at == name:
                blockers.append(blocker_codes[name])
            return result

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            repo = root / "repo"
            artifacts = root / "artifacts"
            repo.mkdir()
            artifacts.mkdir()
            manifest_bytes = b"canon_revision = 1\n"
            (repo / "canon.toml").write_bytes(manifest_bytes)
            benchmark_bytes = canonical_json_bytes({"status": "green"})
            (artifacts / "benchmark.json").write_bytes(benchmark_bytes)
            owner_request = canonical_json_bytes({"request": "pinned"})
            owner_approval = canonical_json_bytes({"approval": "pinned"})
            (artifacts / "owner-request.json").write_bytes(owner_request)
            (artifacts / "owner-approval.json").write_bytes(owner_approval)

            evidence = {field: None for field in cutover_module._TOP_LEVEL_FIELDS}
            evidence.update(
                {
                    "schema_version": 1,
                    "evidence_revision": "two-phase-boundary-test",
                    "canon_manifest_path": "canon.toml",
                    "canon_manifest_sha256": hashlib.sha256(
                        manifest_bytes
                    ).hexdigest(),
                    "canon_revision": 1,
                    "source_sha": source_sha,
                    "source_tree_sha": source_tree,
                    "expected_base_sha": expected_base_sha,
                    "gate_b_requested_state": "green",
                    "bootstrap_approval_ceiling": BOOTSTRAP_CLAIM_CEILING,
                    "requirements": [],
                    "authorization_benchmark": {
                        "report_path": "benchmark.json",
                        "report_sha256": hashlib.sha256(
                            benchmark_bytes
                        ).hexdigest(),
                        "packages_root": "packages",
                        "source_sha": source_sha,
                    },
                    "owner_decision": {
                        "request_path": "owner-request.json",
                        "request_sha256": hashlib.sha256(owner_request).hexdigest(),
                        "approval_attestation_path": "owner-approval.json",
                        "approval_attestation_sha256": hashlib.sha256(
                            owner_approval
                        ).hexdigest(),
                    },
                }
            )

            def git_text(_repo: Path, *arguments: str) -> str:
                if arguments == ("rev-parse", "HEAD"):
                    return source_sha
                if arguments == ("rev-parse", "HEAD^{tree}"):
                    return source_tree
                if arguments == ("status", "--porcelain=v1"):
                    return ""
                raise AssertionError(arguments)

            def git_bytes(_repo: Path, *arguments: str) -> bytes:
                if arguments == ("show", f"{source_sha}:canon.toml"):
                    return manifest_bytes
                return b""

            def prepare_requirements(*arguments: object) -> object:
                blockers = arguments[-1]
                assert isinstance(blockers, list)
                record_preflight("requirements:prepare", blockers)
                return requirement_event, {"requirement_ids": requirement_ids}

            def legacy_requirements(*arguments: object) -> object:
                timeline.extend(
                    f"requirement:semantic:{requirement_id}"
                    for requirement_id in requirement_ids
                )
                return requirement_event

            def execute_requirements(*arguments: object) -> None:
                timeline.extend(
                    f"requirement:semantic:{requirement_id}"
                    for requirement_id in requirement_ids
                )

            def current_event(*arguments: object) -> object:
                blockers = arguments[-1]
                assert isinstance(blockers, list)
                return record_preflight("current-event", blockers, requirement_event)

            def verification(name: str):
                def verify(*arguments: object, **_keywords: object) -> None:
                    blockers = arguments[-1]
                    assert isinstance(blockers, list)
                    record_preflight(name, blockers)

                return verify

            def prepare_benchmark(*arguments: object) -> object:
                blockers = arguments[-1]
                assert isinstance(blockers, list)
                return record_preflight(
                    "benchmark-static", blockers, {"prepared": True}
                )

            def preflight_benchmark(*arguments: object) -> bytes | None:
                blockers = arguments[-1]
                assert isinstance(blockers, list)
                return record_preflight(
                    "benchmark-static", blockers, benchmark_bytes
                )

            def benchmark_semantics(*_arguments: object) -> None:
                timeline.append("benchmark:semantic")

            patches = (
                mock.patch.object(
                    cutover_module, "_read_primary_evidence", return_value=evidence
                ),
                mock.patch.object(cutover_module, "_git_checkout", return_value=repo),
                mock.patch.object(cutover_module, "validate_gate_b_evidence_schema"),
                mock.patch.object(cutover_module, "_git_text", side_effect=git_text),
                mock.patch.object(cutover_module, "_git", side_effect=git_bytes),
                mock.patch.object(
                    cutover_module, "_preflight_requirement_ids", return_value=[]
                ),
                mock.patch.object(cutover_module, "_preflight_task25_candidate_paths"),
                mock.patch.object(
                    cutover_module, "_load_evidence_registry", return_value={}
                ),
                mock.patch.object(
                    cutover_module, "_load_trust_anchors", return_value={}
                ),
                mock.patch.object(
                    cutover_module, "_is_exact_clean_gate_b_source", return_value=True
                ),
                mock.patch.object(cutover_module, "_preflight_owner_artifacts"),
                mock.patch.object(
                    cutover_module,
                    "_prepare_requirements",
                    side_effect=prepare_requirements,
                    create=True,
                ),
                mock.patch.object(
                    cutover_module,
                    "_execute_requirement_semantics",
                    side_effect=execute_requirements,
                    create=True,
                ),
                mock.patch.object(
                    cutover_module,
                    "_verify_requirements",
                    side_effect=legacy_requirements,
                ),
                mock.patch.object(
                    cutover_module, "_verify_current_event", side_effect=current_event
                ),
                mock.patch.object(
                    cutover_module, "_verify_rollback", side_effect=verification("rollback")
                ),
                mock.patch.object(
                    cutover_module,
                    "_verify_protected",
                    side_effect=verification("protected"),
                ),
                mock.patch.object(
                    cutover_module, "_verify_reviews", side_effect=verification("reviews")
                ),
                mock.patch.object(
                    cutover_module, "_verify_owner", side_effect=verification("owner")
                ),
                mock.patch.object(
                    cutover_module,
                    "_verify_visual_owner_v2",
                    side_effect=verification("visual"),
                ),
                mock.patch.object(
                    cutover_module,
                    "_prepare_benchmark",
                    side_effect=prepare_benchmark,
                    create=True,
                ),
                mock.patch.object(
                    cutover_module,
                    "_preflight_benchmark_report",
                    side_effect=preflight_benchmark,
                ),
                mock.patch.object(
                    cutover_module,
                    "_execute_benchmark",
                    side_effect=benchmark_semantics,
                    create=True,
                ),
                mock.patch.object(
                    cutover_module,
                    "_verify_benchmark",
                    side_effect=benchmark_semantics,
                ),
            )
            with ExitStack() as stack:
                for patcher in patches:
                    stack.enter_context(patcher)
                assessment = cutover_module._evaluate_gate_b_core(
                    root / "unused-evidence.json",
                    repo_root=repo,
                    artifact_root=artifacts,
                    expected_base_sha=expected_base_sha,
                    authenticated_rollback={},
                    authenticated_current_event=requirement_event,
                )
        return assessment, timeline

    def test_every_gate_b_preflight_blocker_stops_both_semantic_phases(self) -> None:
        for failure_at in (
            "current-event",
            "rollback",
            "protected",
            "reviews",
            "owner",
            "visual",
            "benchmark-static",
        ):
            with self.subTest(failure_at=failure_at):
                assessment, timeline = self._phase_boundary_assessment(
                    failure_at=failure_at
                )

                self.assertEqual(
                    assessment["blocking_codes"],
                    [
                        {
                            "current-event": "GATE_B_CURRENT_EVENT_INVALID",
                            "rollback": "GATE_B_ROLLBACK_UNVERIFIED",
                            "protected": "GATE_B_PROTECTED_BOUNDARY_INVALID",
                            "reviews": "GATE_B_REVIEW_INVALID",
                            "owner": "GATE_B_OWNER_APPROVAL_INVALID",
                            "visual": "GATE_B_VISUAL_OWNER_INVALID",
                            "benchmark-static": "GATE_B_BENCHMARK_MISMATCH",
                        }[failure_at]
                    ],
                )
                self.assertFalse(
                    any(item.startswith("requirement:semantic:") for item in timeline)
                )
                self.assertNotIn("benchmark:semantic", timeline)

    def test_gate_b_green_preflight_runs_all_requirements_then_benchmark(self) -> None:
        assessment, timeline = self._phase_boundary_assessment(failure_at=None)
        requirement_timeline = [
            f"requirement:semantic:prepared-requirement-{index:02d}"
            for index in range(18)
        ]

        self.assertEqual(assessment["gate_b"], "green")
        self.assertEqual(
            timeline,
            [
                "requirements:prepare",
                "current-event",
                "rollback",
                "protected",
                "reviews",
                "owner",
                "visual",
                "benchmark-static",
                *requirement_timeline,
                "benchmark:semantic",
            ],
        )

    def test_approval_trust_uses_embedded_exact_base_policy_authority(self) -> None:
        base = "c" * 40
        source_sha = "a" * 40
        policy = json.loads(
            (
                ROOT / "docs/canon/references/task-authorization-policy.json"
            ).read_text(encoding="utf-8")
        )
        command_manifest_path = policy["snapshot_paths"]["command_manifest"]
        manifest_bytes = (ROOT / command_manifest_path).read_bytes()
        workflow = json.loads(manifest_bytes.decode("utf-8"))["trusted_workflow"]
        repository_identity = policy["repository_identity"]
        self.assertNotIn("trust_anchors", policy["snapshot_paths"])
        self.assertNotIn("approval_nonce_consumption", policy["snapshot_paths"])
        self.assertIn("trust_anchors", policy)
        self.assertIn("approval_nonce_state", policy)
        current_event = {
            **repository_identity,
            "pull_request_number": 24,
            "trusted_base_sha": base,
            "trusted_head_sha": source_sha,
            "merge_base_sha": base,
            "workflow_run_id": 26001,
            "workflow_run_attempt": 1,
            "event_projection_digest": "e" * 64,
            "consumption_generation": 1,
            "verification_epoch": 1_900_000_000,
        }

        def attestation(
            *,
            intake_id: str,
            nonce: str,
            principal: str,
            policy_id: str,
            scope: list[str],
            task_id: str,
        ) -> dict[str, object]:
            return {
                **current_event,
                "intake_digest": "f" * 64,
                "approved_scope": sorted(scope),
                "authenticated_principal": principal,
                "approval_policy_id": policy_id,
                "approval_policy_revision": "1",
                "task_id": task_id,
                "intake_id": intake_id,
                "policy_revision": policy["policy_revision"],
                "break_glass": False,
                "command_manifest_digest": hashlib.sha256(
                    manifest_bytes
                ).hexdigest(),
                "workflow_path": workflow["path"],
                "workflow_ref": workflow["ref"],
                "workflow_digest": workflow["digest"],
                "check_identity": workflow["check_identity"],
                "integration_id": workflow["integration_id"],
                "app_id": workflow["app_id"],
                "one_time_use_nonce": nonce,
            }

        def git_bytes(_repo: Path, *arguments: str) -> bytes:
            self.assertEqual(
                arguments, ("show", f"{base}:{command_manifest_path}")
            )
            return manifest_bytes

        def git_text(_repo: Path, *arguments: str) -> str:
            if arguments == ("cat-file", "-t", base):
                return "commit"
            if arguments == ("merge-base", base, source_sha):
                return base
            raise AssertionError(arguments)

        cases = (
            {
                "name": "review",
                "intake_id": "REVIEW-gate-b-independent-review",
                "nonce": "nonce-review",
                "principal": "reviewer:independent",
                "policy_id": "independent-review",
                "scope": ["review:gate-b-independent-review"],
                "task_id": "TASK-25-GATE-B-REVIEW",
            },
            {
                "name": "owner",
                "intake_id": "GATE-B-OWNER-REQUEST",
                "nonce": "nonce-owner",
                "principal": "owner:devan",
                "policy_id": "owner-gate",
                "scope": [cutover_module.OWNER_DIRECT_INTEGRATION_SCOPE_LABEL],
                "task_id": "TASK-26-GATE-B",
            },
            {
                "name": "visual",
                "intake_id": "VISUAL-OWNER-DECISION",
                "nonce": "nonce-visual",
                "principal": "owner:devan",
                "policy_id": "owner-gate",
                "scope": ["visual-owner-final"],
                "task_id": "TASK-26-GATE-B",
            },
        )
        seen_nonces: set[str] = set()
        with (
            mock.patch.object(
                cutover_module, "load_base_policy", return_value=policy
            ),
            mock.patch.object(cutover_module, "_git", side_effect=git_bytes),
            mock.patch.object(cutover_module, "_git_text", side_effect=git_text),
            mock.patch.object(cutover_module, "approval_attestation_digest"),
        ):
            for case in cases:
                cutover_module._verify_approval(
                    attestation(
                        intake_id=str(case["intake_id"]),
                        nonce=str(case["nonce"]),
                        principal=str(case["principal"]),
                        policy_id=str(case["policy_id"]),
                        scope=list(case["scope"]),
                        task_id=str(case["task_id"]),
                    ),
                    policy["trust_anchors"],
                    source_sha=source_sha,
                    intake_digest="f" * 64,
                    approved_scope=list(case["scope"]),
                    repo=Path("/unused/repo"),
                    expected_principal=str(case["principal"]),
                    expected_policy_id=str(case["policy_id"]),
                    expected_task_id=str(case["task_id"]),
                    expected_intake_id=str(case["intake_id"]),
                    expected_base_sha=base,
                    current_event=current_event,
                    seen_nonces=seen_nonces,
                )

        self.assertEqual(
            seen_nonces, {"nonce-review", "nonce-owner", "nonce-visual"}
        )

        owner = cases[1]
        owner_attestation = attestation(
            intake_id=str(owner["intake_id"]),
            nonce="nonce-owner-negative",
            principal=str(owner["principal"]),
            policy_id=str(owner["policy_id"]),
            scope=list(owner["scope"]),
            task_id=str(owner["task_id"]),
        )
        malformed_policies = []
        for missing_key in ("trust_anchors", "approval_nonce_state"):
            malformed = dict(policy)
            del malformed[missing_key]
            malformed_policies.append((f"missing-{missing_key}", malformed))
        malformed_policies.extend(
            (
                (
                    "wrong-trust-anchors",
                    {**policy, "trust_anchors": {"repository_identity": {}}},
                ),
                (
                    "wrong-nonce-state",
                    {
                        **policy,
                        "approval_nonce_state": {
                            **policy["approval_nonce_state"],
                            "consumption_generation": 2,
                        },
                    },
                ),
            )
        )
        for name, malformed_policy in malformed_policies:
            with self.subTest(name=name), mock.patch.object(
                cutover_module, "load_base_policy", return_value=malformed_policy
            ), mock.patch.object(
                cutover_module, "_git", side_effect=git_bytes
            ), mock.patch.object(
                cutover_module, "_git_text", side_effect=git_text
            ), mock.patch.object(
                cutover_module, "approval_attestation_digest"
            ), self.assertRaisesRegex(
                cutover_module._EvidenceProblem, "GATE_B_APPROVAL_INVALID"
            ):
                cutover_module._verify_approval(
                    owner_attestation,
                    policy["trust_anchors"],
                    source_sha=source_sha,
                    intake_digest="f" * 64,
                    approved_scope=list(owner["scope"]),
                    repo=Path("/unused/repo"),
                    expected_intake_id=str(owner["intake_id"]),
                    expected_base_sha=base,
                    current_event=current_event,
                    seen_nonces=set(),
                )

    def test_approval_helper_binds_real_signature_to_exact_base_workflow(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            source.mkdir()
            git(source, "init", "-q")
            git(source, "config", "user.name", "Approval Helper")
            git(source, "config", "user.email", "approval@example.invalid")
            (source / "proof.txt").write_text("base\n", encoding="utf-8")
            write_trusted_state(source, ["proof.txt"])
            git(source, "add", "-A")
            git(source, "commit", "-qm", "trusted approval base")
            base = git(source, "rev-parse", "HEAD")
            git(source, "branch", "main", base)
            (source / "proof.txt").write_text("candidate\n", encoding="utf-8")
            git(source, "add", "proof.txt")
            git(source, "commit", "-qm", "approval candidate")
            head = git(source, "rev-parse", "HEAD")
            current_event = task_event(source, base, head)
            policy = cutover_module.load_base_policy(source, base)
            seen_nonces: set[str] = set()
            cases = (
                (
                    "REVIEW",
                    "REVIEW-gate-b-independent-review",
                    ["review:gate-b-independent-review"],
                    "reviewer:independent",
                    "independent-review",
                    "TASK-25-GATE-B-REVIEW",
                ),
                (
                    "OWNER",
                    "GATE-B-OWNER-REQUEST",
                    [cutover_module.OWNER_DIRECT_INTEGRATION_SCOPE_LABEL],
                    "owner:devan",
                    "owner-gate",
                    "TASK-26-GATE-B",
                ),
                (
                    "VISUAL",
                    "VISUAL-OWNER-DECISION",
                    ["visual-owner-final"],
                    "owner:devan",
                    "owner-gate",
                    "TASK-26-GATE-B",
                ),
            )
            for (
                identity,
                intake_id,
                scope,
                principal,
                policy_id,
                task_id,
            ) in cases:
                approval = approval_attestation(
                    source=source,
                    base=base,
                    head=head,
                    attestation_id=f"REAL-SIGNATURE-{identity}",
                    intake_id=intake_id,
                    intake_digest="f" * 64,
                    approved_scope=scope,
                    authenticated_principal=principal,
                    approval_policy_id=policy_id,
                    task_id=task_id,
                    current_event=current_event,
                )
                cutover_module._verify_approval(
                    approval,
                    policy["trust_anchors"],
                    source_sha=head,
                    intake_digest="f" * 64,
                    approved_scope=scope,
                    repo=source,
                    expected_principal=principal,
                    expected_policy_id=policy_id,
                    expected_task_id=task_id,
                    expected_intake_id=intake_id,
                    expected_base_sha=base,
                    current_event=current_event,
                    seen_nonces=seen_nonces,
                )

            self.assertEqual(
                seen_nonces,
                {
                    "nonce-REAL-SIGNATURE-REVIEW",
                    "nonce-REAL-SIGNATURE-OWNER",
                    "nonce-REAL-SIGNATURE-VISUAL",
                },
            )

    def test_task25_expected_base_path_preflight_keeps_candidate_executable_inert(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            source.mkdir()
            git(source, "init", "-q", "-b", "main")
            git(source, "config", "user.name", "Candidate Preflight")
            git(source, "config", "user.email", "preflight@example.invalid")
            (source / "allowed.json").write_text("{}\n", encoding="utf-8")
            write_trusted_state(source, ["allowed.json"])
            policy_path = source / "docs/canon/references/task-authorization-policy.json"
            policy = json.loads(policy_path.read_text(encoding="utf-8"))
            rule = policy["task_rules"][0]
            rule["task_id"] = "TASK-25"
            rule["issue_reference"] = "CANON-TASK-25"
            rule["task_types"] = ["release"]
            issue = policy["issue_state"]["issues"][0]
            issue["task_ids"] = ["TASK-25"]
            issue["issue_reference"] = "CANON-TASK-25"
            policy_path.write_bytes(canonical_json_bytes(policy))
            git(source, "add", "-A")
            git(source, "commit", "-qm", "trusted verifier base")
            base = git(source, "rev-parse", "HEAD")

            (source / "allowed.json").write_text('{"proof":true}\n', encoding="utf-8")
            git(source, "add", "allowed.json")
            git(source, "commit", "-qm", "exact Task 25 package")
            head = git(source, "rev-parse", "HEAD")
            receipt = cutover_module._preflight_task25_candidate_paths(
                source,
                expected_base_sha=base,
                source_sha=head,
                source_tree=git(source, "rev-parse", "HEAD^{tree}"),
            )
            self.assertEqual(receipt["changed_files"], ["allowed.json"])

            sentinel = root / "candidate-executed.txt"
            script = source / "scripts/ambitions-canon.py"
            script.parent.mkdir(parents=True, exist_ok=True)
            script.write_text(
                "from pathlib import Path\n"
                f"Path({str(sentinel)!r}).write_text('executed')\n",
                encoding="utf-8",
            )
            script.chmod(0o755)
            git(source, "add", "scripts/ambitions-canon.py")
            git(source, "commit", "-qm", "hostile candidate executable")
            hostile = git(source, "rev-parse", "HEAD")
            with self.assertRaises(ValueError):
                cutover_module._preflight_task25_candidate_paths(
                    source,
                    expected_base_sha=base,
                    source_sha=hostile,
                    source_tree=git(source, "rev-parse", "HEAD^{tree}"),
                )
            self.assertFalse(sentinel.exists())

    def test_detached_gate_b_source_rejects_symlink_after_clone(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            outside = Path(directory) / "outside-semantic-loss-review.json"
            outside.write_text('{"attacker":"external bytes"}\n', encoding="utf-8")
            relative = "docs/canon/migration/semantic-loss-review.json"
            tracked = source / relative
            tracked.unlink()
            tracked.symlink_to(outside)
            git(source, "add", relative)
            git(source, "commit", "-qm", "hostile symlink candidate")
            head = git(source, "rev-parse", "HEAD")

            with self.assertRaises(cutover_module._EvidenceProblem) as caught:
                with cutover_module._detached_gate_b_source(source, head):
                    self.fail("unsafe cloned symlink source was yielded")

            self.assertEqual(caught.exception.code, "GATE_B_REQUIREMENT_SEMANTICS")

    def test_detached_gate_b_source_rejects_gitlink_and_gitmodules_after_clone(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            linked_commit = git(source, "rev-parse", "HEAD")
            (source / ".gitmodules").write_text(
                '[submodule "hostile"]\n'
                "\tpath = third_party/hostile\n"
                "\turl = file:///tmp/attacker-controlled\n",
                encoding="utf-8",
            )
            git(source, "add", ".gitmodules")
            git(
                source,
                "update-index",
                "--add",
                "--cacheinfo",
                f"160000,{linked_commit},third_party/hostile",
            )
            git(source, "commit", "-qm", "hostile gitlink candidate")
            head = git(source, "rev-parse", "HEAD")

            with self.assertRaises(cutover_module._EvidenceProblem) as caught:
                with cutover_module._detached_gate_b_source(source, head):
                    self.fail("unsafe cloned gitlink source was yielded")

            self.assertEqual(caught.exception.code, "GATE_B_REQUIREMENT_SEMANTICS")

    def test_candidate_scripts_and_test_modules_are_never_executed_or_imported(self) -> None:
        hostile_sources = {
            "scripts/ambitions-canon.py": (
                "from pathlib import Path\n"
                "Path('candidate-script-executed').write_text('executed')\n"
            ),
            "tests/canon/test_authorization_benchmark.py": (
                "from pathlib import Path\nimport unittest\n"
                "Path('candidate-benchmark-test-imported').write_text('imported')\n"
                "# canonical_benchmark_bytes(first) canonical_benchmark_bytes(second)\n"
                "# test_all_eight_scenarios_run_start_resume_finalize_and_negatives\n"
                "class AuthorizationBenchmarkTests(unittest.TestCase):\n"
                " def test_eight_scenarios_project_from_independent_policy_and_real_task_packs(self): pass\n"
            ),
            "tests/canon/test_audit.py": (
                "from pathlib import Path\nimport unittest\n"
                "Path('candidate-audit-test-imported').write_text('imported')\n"
                "class AuditTests(unittest.TestCase):\n"
                " def test_live_shadow_cli_audit_is_green_and_deterministic(self): pass\n"
            ),
            "tests/canon/test_authorization.py": (
                "from pathlib import Path\nimport unittest\n"
                "Path('candidate-authorization-test-imported').write_text('imported')\n"
                "# AUTH_EVENT_STALE AUTH_INTAKE AUTH_APPROVAL_REUSED\n"
                "class AuthorizationSchemaTests(unittest.TestCase):\n"
                " def test_schemas_are_closed_and_intake_is_request_only(self): pass\n"
                "class StartFinalizeTests(unittest.TestCase):\n"
                " def test_finalize_rejects_stale_bindings_and_exact_delta_drift(self): pass\n"
                " def test_attestation_validation_fails_closed_for_revocation_reuse_and_expiry(self): pass\n"
            ),
            "tests/canon/test_task_pack.py": (
                "from pathlib import Path\nimport unittest\n"
                "Path('candidate-task-pack-test-imported').write_text('imported')\n"
                "# build_task_pack stale\n"
                "class TaskPackTests(unittest.TestCase):\n"
                " def test_pack_contains_every_approved_consumption_field(self): pass\n"
                " def test_stale_canon_repository_and_intake_sha_fail_independently(self): pass\n"
            ),
        }
        evidence_ids = (
            "external-references-resolve",
            "independent-ci-regeneration",
            "no-p0-conflict",
            "no-p0-gap",
            "old-audit-green",
            "request-only-handoff",
            "stale-input-negative-proof",
            "task-pack-representatives",
        )
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            for relative, content in hostile_sources.items():
                (source / relative).write_text(content, encoding="utf-8")
            git(source, "add", *sorted(hostile_sources))
            git(source, "commit", "-qm", "hostile candidate verifier code")
            for evidence_id in evidence_ids:
                with self.subTest(evidence_id=evidence_id):
                    try:
                        self.payload(source, evidence_id)
                    except cutover_module._EvidenceProblem as exc:
                        self.assertEqual(exc.code, "GATE_B_REQUIREMENT_SEMANTICS")
            sentinels = sorted(path.name for path in source.glob("candidate-*-executed"))
            sentinels.extend(
                sorted(path.name for path in source.glob("candidate-*-test-imported"))
            )
            self.assertEqual(sentinels, [])

    def test_trusted_rerun_never_imports_candidate_cutover_module(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            candidate_module = source / "tools/ambitions_canon/cutover_readiness.py"
            candidate_module.write_text(
                "from pathlib import Path\n"
                "Path('candidate-cutover-module-imported').write_text('imported')\n",
                encoding="utf-8",
            )
            shutil.copy2(
                EVIDENCE_REGISTRY,
                source / "docs/canon/references/gate-b-evidence-registry.json",
            )
            git(
                source,
                "add",
                "tools/ambitions_canon/cutover_readiness.py",
                "docs/canon/references/gate-b-evidence-registry.json",
            )
            git(source, "commit", "-qm", "hostile candidate cutover module")
            try:
                cutover_module._execute_gate_b_command(
                    source,
                    "active-authority-dispositions",
                )
            except cutover_module._EvidenceProblem as exc:
                # The live semantic review intentionally remains a candidate;
                # this adversarial test proves the trusted verifier stays inert,
                # not that live Gate B authority is already Green.
                self.assertEqual(exc.code, "GATE_B_REQUIREMENT_SEMANTICS")
            self.assertFalse((source / "candidate-cutover-module-imported").exists())

    def test_exact_corpus_proofs_reject_tiny_nonempty_subsets(self) -> None:
        cases: tuple[tuple[str, str, object], ...] = (
            (
                "active-authority-dispositions",
                "docs/canon/migration/claim-dispositions.json",
                {
                    "schema_version": 1,
                    "claims": [
                        {
                            "claim_id": "FAKE-CLAIM",
                            "concept": "fake.concept",
                            "disposition": "keep",
                            "target_id": "LAW-IA-ROOT-001",
                        }
                    ],
                    "uncovered": [],
                },
            ),
            (
                "single-concept-owner",
                "docs/canon/generated/concept-ownership.json",
                {
                    "schema_version": 1,
                    "concepts": [
                        {
                            "concept": "accessibility.dynamic-type",
                            "spec_id": "STANDARD-ACCESSIBILITY",
                        }
                    ],
                },
            ),
            (
                "unique-concepts-preserved",
                "docs/canon/generated/requirement-graph.json",
                {
                    "schema_version": 1,
                    "requirement_ids": ["A11Y-002"],
                    "requirement_edges": [],
                    "document_edges": [],
                },
            ),
        )
        for evidence_id, relative, replacement in cases:
            with self.subTest(evidence_id=evidence_id), tempfile.TemporaryDirectory() as directory:
                source = self.clone_root(directory)
                (source / relative).write_bytes(canonical_json_bytes(replacement))
                git(source, "add", relative)
                git(source, "commit", "-qm", f"tiny {evidence_id} corpus")
                with self.assertRaisesRegex(
                    cutover_module._EvidenceProblem,
                    "GATE_B_REQUIREMENT_SEMANTICS",
                ):
                    self.payload(source, evidence_id)

    def test_skill_freshness_runs_complete_canonical_conformance(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            relative = "docs/canon/references/skill-dependencies.json"
            registry = json.loads((source / relative).read_text(encoding="utf-8"))
            registry["skills"][0]["may_authorize"] = True
            (source / relative).write_bytes(canonical_json_bytes(registry))
            git(source, "add", relative)
            git(source, "commit", "-qm", "forge authority-bearing skill")
            with self.assertRaisesRegex(
                cutover_module._EvidenceProblem,
                "GATE_B_REQUIREMENT_SEMANTICS",
            ):
                self.payload(source, "skill-freshness")

    def test_generated_output_proof_covers_every_manifest_output_and_ignores_dirty_tree(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            forged = source / "docs/canon/generated/law-source-map.json"
            forged.write_bytes(canonical_json_bytes({"forged": "green"}))
            git(source, "add", "docs/canon/generated/law-source-map.json")
            git(source, "commit", "-qm", "forge non-index generated output")
            with self.assertRaisesRegex(
                cutover_module._EvidenceProblem,
                "GATE_B_REQUIREMENT_SEMANTICS",
            ):
                self.payload(source, "generated-output-reproducible")

        with tempfile.TemporaryDirectory() as directory:
            source = self.clone_root(directory)
            from tools.ambitions_canon.build import build_canon

            self.assertEqual(build_canon(source), ())
            git(source, "add", "docs/canon/generated")
            git(source, "commit", "-qm", "freeze build-consistent generated tree")
            with (source / "docs/canon/MANIFEST.toml").open("ab") as stream:
                stream.write(b"\n# dirty caller substitution\n")
            payload = self.payload(source, "generated-output-reproducible")
            self.assertEqual(payload["evidence_id"], "generated-output-reproducible")


class Task24SearchCoverageRepairTests(unittest.TestCase):
    def test_task24_repairs_exact_ten_search_p0_evidence_cells(self) -> None:
        from tools.ambitions_canon.build import _load_audited_registry
        from tools.ambitions_canon.coverage import (
            coverage_findings,
            load_profiles,
            profile_section_bodies,
        )
        from tools.ambitions_canon.model import GapSeverity

        repaired_cells = {
            "GLOBAL-SEARCH": {
                "durable-effects": "Durable effects are limited to canonical-owner commands, events, projections, Receipts, and replay after explicit confirmation.",
                "failure-rollback": "Failure preserves canonical state and query context; rollback delegates any committed inverse to the canonical owner.",
                "offline": "Offline Search preserves deterministic local Find, Act, Inspect, Receipt, replay, and index-rebuild behavior.",
                "proof": "Proof binds declared-corpus ranking, privacy filtering, local execution, grounded Ask fallback, owner Receipts, recovery, and accessibility evidence.",
                "resting-states": "Resting-state evidence covers the declared empty, result, answer, recovery, handoff, action, rebuild, restored, and privacy-suppressed presentations.",
                "source-ownership": "Source ownership remains exact across Stage, LocalRuntimeOS Search, Projections, Commands, Trust, and Quality.",
                "tests": "Executable tests bind ranking, privacy, object families, Ask grounding, action safety, recovery, offline use, replay, accessibility, and return focus.",
            },
            "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT": {
                "branches": "Branch evidence covers exact Find, bounded Ask, owner-routed action, Capture handoff, inspection, privacy filtering, and approved-reference outcomes.",
                "failure": "Failure evidence preserves deterministic results, query context, truthful canonical state, privacy boundaries, and exact recovery ownership.",
                "scenario-tests": "Scenario evidence binds retrieval, grounding, session boundaries, owner routing, mutation safety, offline fallback, recovery, focus, and non-color accessibility.",
            },
        }
        self.assertEqual(
            sum(len(sections) for sections in repaired_cells.values()),
            10,
        )
        registry = _load_audited_registry(ROOT)
        documents = {
            document.spec_id: document
            for document in registry.documents
            if document.spec_id in repaired_cells
        }
        self.assertEqual(set(documents), set(repaired_cells))
        for spec_id, expected_sections in repaired_cells.items():
            bodies = dict(profile_section_bodies(documents[spec_id]))
            for section, sentence in expected_sections.items():
                with self.subTest(spec_id=spec_id, section=section):
                    self.assertIn(sentence, bodies[section])

        profiles = load_profiles(
            ROOT / "docs/canon/schemas/completeness-profiles.toml"
        )
        p0_findings = tuple(
            finding
            for finding in coverage_findings(registry, profiles)
            if finding.severity is GapSeverity.P0_BLOCKER
        )
        self.assertEqual(p0_findings, ())


class CutoverReadinessTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temporary = tempfile.TemporaryDirectory()
        cls.source, cls.artifacts, cls.evidence_path = create_gate_b_bundle(
            Path(cls.temporary.name)
        )
        cls.evidence = json.loads(cls.evidence_path.read_text(encoding="utf-8"))

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temporary.cleanup()

    def write_evidence(self, value: dict[str, object], name: str) -> Path:
        path = self.artifacts / name
        path.write_bytes(canonical_json_bytes(value))
        return path

    def authenticated_current_event(self) -> dict[str, object]:
        requirement = self.evidence["requirements"][0]
        authorization = json.loads(
            (
                self.artifacts / requirement["authorization_path"]
            ).read_text(encoding="utf-8")
        )
        current_event = authorization["trusted_event_provenance"]
        self.assertEqual(
            current_event["event_projection_digest"],
            cutover_module.trusted_event_projection_digest(current_event),
        )
        return current_event

    def test_substantive_gate_b_command_rejects_invalid_domain_evidence(self) -> None:
        registry = json.loads(EVIDENCE_REGISTRY.read_text(encoding="utf-8"))
        entry = next(
            item
            for item in registry["requirements"]
            if item["evidence_id"] == "active-authority-dispositions"
        )
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            subprocess.run(
                ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            disposition = source / entry["input_paths"][0]
            disposition.write_bytes(
                canonical_json_bytes(
                    {
                        "schema_version": 1,
                        "claims": [],
                        "uncovered": [],
                    }
                )
            )
            git(source, "add", entry["input_paths"][0])
            git(source, "commit", "-qm", "invalid disposition corpus")
            head = git(source, "rev-parse", "HEAD")
            tree = git(source, "rev-parse", "HEAD^{tree}")
            with self.assertRaisesRegex(
                cutover_module._EvidenceProblem,
                "GATE_B_REQUIREMENT_SEMANTICS",
            ):
                cutover_module._gate_b_substantive_payload(
                    source,
                    source_sha=head,
                    source_tree=tree,
                    entry=entry,
                )

    def test_benchmark_source_contract_requires_clean_detached_exact_sha(self) -> None:
        factory = getattr(benchmark_module, "detached_exact_source", None)
        self.assertIsNotNone(
            factory,
            "benchmark/task-pack inputs need one detached exact-source boundary",
        )
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            subprocess.run(
                ["git", "clone", "-q", "--no-hardlinks", str(ROOT), str(source)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            (source / "dirty-substitution.txt").write_text(
                "mutable caller bytes\n", encoding="utf-8"
            )
            with self.assertRaisesRegex(
                BenchmarkError, "BENCHMARK_SOURCE_DIRTY"
            ):
                with factory(source):
                    self.fail("dirty source must not produce an exact checkout")

    def test_gate_b_approval_uses_current_event_and_one_time_nonce_projection(self) -> None:
        parameters = inspect.signature(_evaluate_gate_b).parameters
        self.assertIn("authenticated_current_event", parameters)
        requirement = self.evidence["requirements"][0]
        authorization = json.loads(
            (
                self.artifacts / requirement["authorization_path"]
            ).read_text(encoding="utf-8")
        )
        current_event = authorization["trusted_event_provenance"]

        wrong_event = dict(current_event)
        wrong_event["pull_request_number"] = int(
            wrong_event["pull_request_number"]
        ) + 1
        wrong_event["event_projection_digest"] = (
            cutover_module.trusted_event_projection_digest(wrong_event)
        )
        wrong_event = resign(wrong_event)
        assessment = _evaluate_gate_b(
            self.evidence_path,
            repo_root=self.source,
            artifact_root=self.artifacts,
            expected_base_sha=self.evidence["expected_base_sha"],
            authenticated_rollback=self.evidence["rollback"],
            authenticated_current_event=wrong_event,
        )
        self.assertIn(
            "GATE_B_CURRENT_EVENT_INVALID", assessment["blocking_codes"]
        )

        cases: list[tuple[str, dict[str, object], str]] = []
        for name, field, value in (
            ("wrong-pr", "pull_request_number", 251),
            ("wrong-run", "workflow_run_id", 26002),
            ("wrong-attempt", "workflow_run_attempt", 2),
            ("expired", "expires_at_epoch", VERIFICATION_EPOCH),
        ):
            evidence = json.loads(json.dumps(self.evidence))
            approval_path = evidence["owner_decision"][
                "approval_attestation_path"
            ]
            approval = json.loads(
                (self.artifacts / approval_path).read_text(encoding="utf-8")
            )
            approval[field] = value
            approval = resign(approval)
            path, sha = write_artifact(
                self.artifacts, f"owner/{name}-approval.json", approval
            )
            evidence["owner_decision"]["approval_attestation_path"] = path
            evidence["owner_decision"]["approval_attestation_sha256"] = sha
            cases.append((name, evidence, "GATE_B_OWNER_APPROVAL_INVALID"))

        replay = json.loads(json.dumps(self.evidence))
        owner_approval = json.loads(
            (
                self.artifacts
                / replay["owner_decision"]["approval_attestation_path"]
            ).read_text(encoding="utf-8")
        )
        visual_approval = json.loads(
            (
                self.artifacts
                / replay["visual_owner_approval"]["approval_attestation_path"]
            ).read_text(encoding="utf-8")
        )
        visual_approval["one_time_use_nonce"] = owner_approval[
            "one_time_use_nonce"
        ]
        visual_approval = resign(visual_approval)
        path, sha = write_artifact(
            self.artifacts, "visual/replayed-approval.json", visual_approval
        )
        replay["visual_owner_approval"]["approval_attestation_path"] = path
        replay["visual_owner_approval"]["approval_attestation_sha256"] = sha
        cases.append(("replayed", replay, "GATE_B_VISUAL_BINDING"))

        for name, evidence, blocker in cases:
            with self.subTest(name=name):
                assessment = _evaluate_gate_b(
                    self.write_evidence(evidence, f"{name}-approval-evidence.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                    expected_base_sha=self.evidence["expected_base_sha"],
                    authenticated_rollback=self.evidence["rollback"],
                    authenticated_current_event=current_event,
                )
                self.assertIn(blocker, assessment["blocking_codes"])

    def test_every_requirement_binds_the_exact_task25_approval_context(self) -> None:
        contexts = {
            (
                requirement["authorization_path"],
                requirement["authorization_sha256"],
                requirement["approval_attestation_path"],
                requirement["approval_attestation_sha256"],
                requirement["finalization_path"],
                requirement["finalization_sha256"],
            )
            for requirement in self.evidence["requirements"]
        }
        self.assertEqual(len(contexts), 1)
        requirement = self.evidence["requirements"][0]
        authorization = json.loads(
            (
                self.artifacts / requirement["authorization_path"]
            ).read_text(encoding="utf-8")
        )
        approval = json.loads(
            (
                self.artifacts / requirement["approval_attestation_path"]
            ).read_text(encoding="utf-8")
        )
        self.assertEqual(authorization["intake"]["task_id"], "TASK-25")
        self.assertEqual(
            authorization["approval_attestation_digests"],
            [hashlib.sha256(canonical_json_bytes(approval)).hexdigest()],
        )

        mismatched = resign({**approval, "workflow_run_attempt": 2})
        path, sha = write_artifact(
            self.artifacts,
            "requirements/mismatched-task25-approval.json",
            mismatched,
        )
        evidence = json.loads(json.dumps(self.evidence))
        for item in evidence["requirements"]:
            item["approval_attestation_path"] = path
            item["approval_attestation_sha256"] = sha
        assessment = cutover_module._evaluate_gate_b_core(
            self.write_evidence(evidence, "requirement-approval-mismatch.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
            expected_base_sha=self.evidence["expected_base_sha"],
            authenticated_rollback=self.evidence["rollback"],
            authenticated_current_event=self.authenticated_current_event(),
        )
        self.assertIn(
            "GATE_B_REQUIREMENT_CONTEXT_INVALID", assessment["blocking_codes"]
        )

    def test_rollback_ref_must_exist_and_resolve_to_declared_tag_object(self) -> None:
        rollback = self.evidence["rollback"]
        git(self.source, "tag", "-d", "gate-b-rollback")
        try:
            blockers: list[str] = []
            cutover_module._verify_rollback(
                rollback,
                self.source,
                blockers,
                expected_base_sha=self.evidence["expected_base_sha"],
                authenticated_rollback=rollback,
                source_sha=self.evidence["source_sha"],
            )
            self.assertIn("GATE_B_ROLLBACK_UNVERIFIED", blockers)
        finally:
            git(
                self.source,
                "update-ref",
                rollback["ref"],
                rollback["tag_object_sha"],
            )

    def test_gate_b_schema_is_closed_recursively(self) -> None:
        schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
        self.assertFalse(schema["additionalProperties"])
        for definition in schema["$defs"].values():
            if definition.get("type") == "object":
                self.assertFalse(definition["additionalProperties"])
        self.assertTrue(
            {
                "review_attestation_path",
                "review_attestation_sha256",
            }
            <= set(schema["$defs"]["reviewEvidence"]["required"])
        )
        self.assertTrue(
            {
                "authorization_path",
                "authorization_sha256",
                "finalization_path",
                "finalization_sha256",
                "checkout_tree_sha",
            }
            <= set(schema["$defs"]["requirementEvidence"]["required"])
        )
        self.assertEqual(
            set(schema["required"]),
            set(schema["properties"]),
        )
        self.assertIn("evidence_registry", schema["properties"])
        self.assertIn("verifier", schema["properties"])

    def test_every_requirement_is_bound_to_base_owned_registry_command_schema_and_parser(self) -> None:
        registry = json.loads(EVIDENCE_REGISTRY.read_text(encoding="utf-8"))
        entries = registry["requirements"]
        self.assertEqual(
            [entry["evidence_id"] for entry in entries],
            list(GATE_B_REQUIRED_EVIDENCE_IDS),
        )
        payload_schema = registry["payload_schema"]
        self.assertFalse(payload_schema["additionalProperties"])
        self.assertEqual(
            set(payload_schema["required"]), set(payload_schema["properties"])
        )
        self.assertIn("observation", payload_schema["properties"])
        self.assertIn("input_sha256", payload_schema["properties"])
        self.assertEqual(
            len({entry["command_id"] for entry in entries}),
            len(GATE_B_REQUIRED_EVIDENCE_IDS),
        )
        self.assertEqual(
            len({entry["output_schema"] for entry in entries}),
            len(GATE_B_REQUIRED_EVIDENCE_IDS),
        )
        for entry in entries:
            with self.subTest(evidence_id=entry["evidence_id"]):
                self.assertEqual(
                    entry["command_id"], f"gate-b-{entry['evidence_id']}"
                )
                self.assertTrue(entry["check_identity"].startswith("gate-b:"))
                output_schema = registry["output_schemas"][entry["output_schema"]]
                self.assertFalse(output_schema["additionalProperties"])
                self.assertEqual(
                    set(output_schema["required"]),
                    set(output_schema["properties"]),
                )
                self.assertEqual(
                    entry["result_parser"],
                    {
                        "kind": "gate-b-substantive-observation-v1",
                        "evidence_id": entry["evidence_id"],
                        "semantic": entry["semantic"],
                        "observation_kind": entry["observation_kind"],
                    },
                )
                self.assertEqual(
                    entry["required_bindings"],
                    [
                        "command_argv_sha256",
                        "expected_base_sha",
                        "input_sha256",
                        "merge_base_sha",
                        "source_sha",
                        "source_tree_sha",
                    ],
                )
        signed_label = json.loads(json.dumps(self.evidence))
        requirement = signed_label["requirements"][0]
        artifact = json.loads(
            (self.artifacts / requirement["artifact_path"]).read_text(
                encoding="utf-8"
            )
        )
        artifact["command_id"] = "caller-green-label"
        path, sha = write_artifact(
            self.artifacts, "requirements/signed-label-substitution.json", artifact
        )
        requirement["artifact_path"] = path
        requirement["artifact_sha256"] = sha
        assessment = evaluate_gate_b(
            self.write_evidence(signed_label, "signed-label-substitution-evidence.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_REQUIREMENT_REGISTRY", assessment["blocking_codes"])

    def test_authenticated_expected_base_rejects_candidate_repointed_main(self) -> None:
        parameters = inspect.signature(evaluate_gate_b).parameters
        self.assertIn("expected_base_sha", parameters)
        self.assertIn("authenticated_rollback", parameters)
        expected_base = self.evidence["verifier"]["base_sha"]
        candidate = self.evidence["source_sha"]
        forged = json.loads(json.dumps(self.evidence))
        verifier_path = forged["verifier"]["path"]
        forged["verifier"]["base_sha"] = candidate
        forged["verifier"]["base_tree_sha"] = git(
            self.source, "rev-parse", f"{candidate}^{{tree}}"
        )
        forged["verifier"]["blob_sha256"] = hashlib.sha256(
            subprocess.run(
                ["git", "show", f"{candidate}:{verifier_path}"],
                cwd=self.source,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            ).stdout
        ).hexdigest()
        forged["evidence_registry"]["base_sha"] = candidate
        forged_path = self.write_evidence(
            forged, "candidate-repointed-main-evidence.json"
        )
        git(self.source, "branch", "-f", "main", candidate)
        try:
            assessment = evaluate_gate_b(
                forged_path,
                repo_root=self.source,
                artifact_root=self.artifacts,
                expected_base_sha=expected_base,
                authenticated_rollback=self.evidence["rollback"],
            )
        finally:
            git(self.source, "branch", "-f", "main", expected_base)
        self.assertEqual(assessment["gate_b"], "red")
        self.assertIn("GATE_B_VERIFIER_INVALID", assessment["blocking_codes"])

    def test_correctly_signed_base_owned_green_label_noop_cannot_authorize(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source, artifacts, evidence_path = create_gate_b_bundle(
                Path(directory), no_op_evidence_suite=True
            )
            assessment = evaluate_gate_b(
                evidence_path,
                repo_root=source,
                artifact_root=artifacts,
            )
        self.assertEqual(assessment["gate_b"], "red")
        self.assertIn(
            "GATE_B_REQUIREMENT_REGISTRY", assessment["blocking_codes"]
        )

    def test_shared_finalization_cache_does_not_authorize_a_different_envelope_digest(self) -> None:
        substituted = json.loads(json.dumps(self.evidence))
        requirement = substituted["requirements"][1]
        envelope = json.loads(
            (self.artifacts / requirement["artifact_path"]).read_text(
                encoding="utf-8"
            )
        )
        envelope["stderr_base64url"] = "dW5zaWduZWQ"
        path, sha = write_artifact(
            self.artifacts,
            "requirements/unsigned-alternate-envelope.json",
            envelope,
        )
        requirement["artifact_path"] = path
        requirement["artifact_sha256"] = sha
        assessment = evaluate_gate_b(
            self.write_evidence(
                substituted, "unsigned-alternate-envelope-evidence.json"
            ),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn(
            "GATE_B_REQUIREMENT_SEMANTICS",
            assessment["blocking_codes"],
        )

    def test_independent_review_requires_exact_dimensions_and_both_verdicts(self) -> None:
        registry = json.loads(EVIDENCE_REGISTRY.read_text(encoding="utf-8"))
        required_dimensions = registry["independent_review"]["required_dimensions"]
        required_verdicts = registry["independent_review"]["required_verdicts"]
        review = self.evidence["reviews"][0]
        self.assertEqual(
            [item["dimension_id"] for item in review["dimensions"]],
            required_dimensions,
        )
        self.assertEqual(set(review["verdicts"]), set(required_verdicts))
        cases = []
        missing_dimension = json.loads(json.dumps(self.evidence))
        missing_dimension["reviews"][0]["dimensions"] = missing_dimension[
            "reviews"
        ][0]["dimensions"][:-1]
        cases.append(missing_dimension)
        failed_verdict = json.loads(json.dumps(self.evidence))
        failed_verdict["reviews"][0]["verdicts"][required_verdicts[0]] = "red"
        cases.append(failed_verdict)
        unknown_dimension = json.loads(json.dumps(self.evidence))
        unknown_dimension["reviews"][0]["dimensions"].append(
            {"dimension_id": "caller-invented", "verdict": "green"}
        )
        cases.append(unknown_dimension)
        for index, candidate in enumerate(cases):
            with self.subTest(index=index):
                assessment = evaluate_gate_b(
                    self.write_evidence(candidate, f"review-matrix-negative-{index}.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                )
                self.assertIn("GATE_B_REVIEW_NOT_GREEN", assessment["blocking_codes"])

    def test_runtime_schema_validation_rejects_bool_int_and_nested_type_substitution(self) -> None:
        cases = []
        schema_bool = json.loads(json.dumps(self.evidence))
        schema_bool["schema_version"] = True
        cases.append(schema_bool)
        revision_float = json.loads(json.dumps(self.evidence))
        revision_float["canon_revision"] = 11.0
        cases.append(revision_float)
        protected_int = json.loads(json.dumps(self.evidence))
        protected_int["protected_boundary"]["authority_routing_cutover_only"] = 1
        cases.append(protected_int)
        findings_bool = json.loads(json.dumps(self.evidence))
        findings_bool["reviews"][0]["critical_findings"] = False
        cases.append(findings_bool)
        export_bool = json.loads(json.dumps(self.evidence))
        export_bool["visual_owner_approval"]["figma_exports"][0][
            "byte_size"
        ] = True
        cases.append(export_bool)
        nested_unknown = json.loads(json.dumps(self.evidence))
        nested_unknown["visual_owner_approval"]["figma_exports"][0][
            "caller_green"
        ] = True
        cases.append(nested_unknown)
        for index, candidate in enumerate(cases):
            with self.subTest(index=index), self.assertRaisesRegex(
                GateBEvidenceError, "GATE_B_SCHEMA"
            ):
                validate_gate_b_evidence_schema(
                    candidate,
                    repo_root=self.source,
                    expected_base_sha=self.evidence["expected_base_sha"],
                )

    def test_gate_b_is_green_only_after_recomputing_local_git_and_artifacts(self) -> None:
        assessment = evaluate_gate_b(
            self.evidence_path, repo_root=self.source, artifact_root=self.artifacts
        )
        self.assertEqual(assessment["gate_b"], "green", assessment)
        self.assertTrue(assessment["task_26_authority_routing_cutover_authorized"])
        self.assertFalse(assessment["live_enforcement_proven"])
        self.assertFalse(assessment["post_merge_receipt_required"])
        self.assertEqual(assessment["claim_ceiling"], BOOTSTRAP_CLAIM_CEILING)
        first = render_cutover_readiness(
            self.evidence_path,
            repo_root=self.source,
            artifact_root=self.artifacts,
            expected_base_sha=self.evidence["expected_base_sha"],
            authenticated_rollback=self.evidence["rollback"],
            authenticated_current_event=json.loads(
                (
                    self.artifacts
                    / self.evidence["requirements"][0]["authorization_path"]
                ).read_text(encoding="utf-8")
            )["trusted_event_provenance"],
        )
        self.assertTrue(first.endswith("\n"))
        self.assertNotIn("generated_at", first)

    def test_gate_b_rejects_substitution_stale_git_and_unresolved_rollback(self) -> None:
        cases = []
        missing = json.loads(json.dumps(self.evidence))
        missing["requirements"] = missing["requirements"][:-1]
        cases.append((missing, "GATE_B_REQUIREMENT_MISSING"))
        stale_source = json.loads(json.dumps(self.evidence))
        stale_source["source_sha"] = "a" * 40
        cases.append((stale_source, "GATE_B_SOURCE_STALE"))
        rollback = json.loads(json.dumps(self.evidence))
        rollback["rollback"]["ref"] = "refs/tags/missing"
        cases.append((rollback, "GATE_B_ROLLBACK_AUTHENTICATION"))
        review = json.loads(json.dumps(self.evidence))
        review["reviews"][0]["critical_findings"] = 1
        cases.append((review, "GATE_B_REVIEW_NOT_GREEN"))
        requirement = json.loads(json.dumps(self.evidence))
        requirement["requirements"][0]["artifact_sha256"] = "0" * 64
        cases.append((requirement, "GATE_B_ARTIFACT_DIGEST"))
        for index, (value, code) in enumerate(cases):
            with self.subTest(code=code):
                assessment = evaluate_gate_b(
                    self.write_evidence(value, f"negative-{index}.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                    authenticated_rollback=self.evidence["rollback"],
                )
                self.assertEqual(assessment["gate_b"], "red")
                self.assertIn(code, assessment["blocking_codes"])

    def test_visual_owner_is_non_delegable_and_binds_figma_exports_and_review(self) -> None:
        cases = []
        missing = json.loads(json.dumps(self.evidence))
        del missing["visual_owner_approval"]
        cases.append((missing, "GATE_B_VISUAL_OWNER_MISSING"))
        delegated = json.loads(json.dumps(self.evidence))
        delegated["visual_owner_approval"]["delegated"] = True
        cases.append((delegated, "GATE_B_VISUAL_OWNER_DELEGATED"))
        frame = json.loads(json.dumps(self.evidence))
        frame["visual_owner_approval"]["final_frame_ids"] = ["VA-FORGED"]
        cases.append((frame, "GATE_B_VISUAL_BINDING"))
        export = json.loads(json.dumps(self.evidence))
        export["visual_owner_approval"]["figma_exports"][0][
            "artifact_sha256"
        ] = "0" * 64
        cases.append((export, "GATE_B_FIGMA_DESIGN_EXPORT_DIGEST"))
        for index, (value, code) in enumerate(cases):
            with self.subTest(code=code):
                assessment = evaluate_gate_b(
                    self.write_evidence(value, f"visual-negative-{index}.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                )
                self.assertEqual(assessment["gate_b"], "red")
                self.assertIn(code, assessment["blocking_codes"])

    def test_visual_manifest_binds_derived_ledgers_and_design_only_ceiling(self) -> None:
        visual = self.evidence["visual_owner_approval"]
        completeness = cutover_module.derive_visual_completeness(
            self.source, self.evidence["expected_base_sha"]
        )
        manifest = json.loads(
            (self.artifacts / visual["manifest_path"]).read_text(encoding="utf-8")
        )
        self.assertEqual(manifest["evidence_kind"], "figma-design-export")
        self.assertEqual(
            manifest["merged_visual_ledger_sha256"],
            completeness["merged_visual_ledger_sha256"],
        )
        self.assertEqual(manifest["gap_blocked_state_ids"], [])
        self.assertEqual(manifest["simulator_renders"], [])
        self.assertEqual(
            manifest["claim_ceiling"], cutover_module._VISUAL_CLAIM_CEILING
        )
        export = manifest["figma_exports"][0]
        self.assertEqual(export["screen_ids"], completeness["screen_ids"])
        self.assertEqual(export["state_ids"], completeness["state_ids"])
        self.assertEqual(export["journey_ids"], completeness["journey_ids"])
        self.assertEqual(export["object_ids"], completeness["object_ids"])
        self.assertEqual(
            export["visual_requirement_ids"],
            completeness["visual_requirement_ids"],
        )

    def test_visual_fixtures_are_negative_only_and_never_completeness_authority(self) -> None:
        contract = json.loads(SYNTHETIC_VISUAL_CONTRACT.read_text(encoding="utf-8"))
        manifest = json.loads(SYNTHETIC_VISUAL_MANIFEST.read_text(encoding="utf-8"))
        self.assertEqual(contract["completion_state"], "synthetic-complete")
        registry = json.loads(EVIDENCE_REGISTRY.read_text(encoding="utf-8"))
        visual_entry = next(
            item
            for item in registry["requirements"]
            if item["evidence_id"] == "visual-reconciliation-green"
        )
        self.assertNotIn(SYNTHETIC_VISUAL_CONTRACT.name, visual_entry["input_paths"])
        self.assertNotIn(SYNTHETIC_VISUAL_MANIFEST.name, visual_entry["input_paths"])
        with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_BINDING"):
            cutover_module._derive_visual_completeness_from_bytes(
                {
                    SYNTHETIC_VISUAL_CONTRACT.name: canonical_json_bytes(contract),
                    SYNTHETIC_VISUAL_MANIFEST.name: canonical_json_bytes(manifest),
                }
            )

    def test_png_without_idat_or_decoded_pixels_is_rejected(self) -> None:
        def chunk(kind: bytes, data: bytes) -> bytes:
            body = kind + data
            return (
                struct.pack(">I", len(data))
                + body
                + struct.pack(">I", zlib.crc32(body))
            )

        minimal = (
            b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", 1179, 2556, 8, 6, 0, 0, 0))
            + chunk(b"IEND", b"")
        )
        with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_SCREENSHOT_INVALID"):
            cutover_module._png_dimensions(minimal)

    def test_visual_independent_review_is_cryptographic_and_owner_binds_exact_set(self) -> None:
        unsigned = json.loads(json.dumps(self.evidence))
        visual = unsigned["visual_owner_approval"]
        visual["review"]["attestation_sha256"] = "0" * 64
        assessment = evaluate_gate_b(
            self.write_evidence(unsigned, "visual-unsigned-review.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_VISUAL_REVIEW_ATTESTATION", assessment["blocking_codes"])

        subset = json.loads(json.dumps(self.evidence))
        subset["visual_owner_approval"]["figma_exports"][0]["state_ids"] = subset[
            "visual_owner_approval"
        ]["figma_exports"][0]["state_ids"][1:]
        assessment = evaluate_gate_b(
            self.write_evidence(subset, "visual-owner-subset.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_VISUAL_COMPLETENESS", assessment["blocking_codes"])

    def test_rollback_accepts_only_immutable_annotated_tag_and_peeled_tree(self) -> None:
        valid = self.evidence["rollback"]
        self.assertEqual(
            git(self.source, "cat-file", "-t", valid["tag_object_sha"]), "tag"
        )
        self.assertEqual(
            git(self.source, "rev-parse", f"{valid['ref']}^{{commit}}"),
            valid["commit_sha"],
        )
        cases = []
        branch = json.loads(json.dumps(self.evidence))
        branch["rollback"]["ref"] = "refs/heads/main"
        branch["rollback"]["tag_object_sha"] = git(
            self.source, "rev-parse", "refs/heads/main"
        )
        branch["rollback"]["commit_sha"] = branch["rollback"]["tag_object_sha"]
        cases.append(branch)
        wrong_tag = json.loads(json.dumps(self.evidence))
        wrong_tag["rollback"]["tag_object_sha"] = "0" * 40
        cases.append(wrong_tag)
        wrong_commit = json.loads(json.dumps(self.evidence))
        wrong_commit["rollback"]["commit_sha"] = "0" * 40
        cases.append(wrong_commit)
        for index, candidate in enumerate(cases):
            with self.subTest(index=index):
                assessment = evaluate_gate_b(
                    self.write_evidence(candidate, f"rollback-negative-{index}.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                    authenticated_rollback=self.evidence["rollback"],
                )
                self.assertIn(
                    "GATE_B_ROLLBACK_AUTHENTICATION",
                    assessment["blocking_codes"],
                )

    def test_rollback_requires_external_authentication_non_noop_ancestry_and_restore(self) -> None:
        parameters = inspect.signature(cutover_module._verify_rollback).parameters
        self.assertIn("expected_base_sha", parameters)
        self.assertIn("authenticated_rollback", parameters)
        self.assertIn("source_sha", parameters)
        candidate = self.evidence["source_sha"]
        git(
            self.source,
            "-c",
            "user.name=Gate B Owner",
            "-c",
            "user.email=gate-b@example.invalid",
            "tag",
            "-a",
            "gate-b-noop-rollback",
            "-m",
            "candidate no-op rollback",
            candidate,
        )
        no_op = {
            "ref": "refs/tags/gate-b-noop-rollback",
            "tag_object_sha": git(
                self.source, "rev-parse", "refs/tags/gate-b-noop-rollback"
            ),
            "commit_sha": candidate,
            "tree_sha": git(self.source, "rev-parse", f"{candidate}^{{tree}}"),
        }
        blockers: list[str] = []
        cutover_module._verify_rollback(
            no_op,
            self.source,
            blockers,
            expected_base_sha=self.evidence["verifier"]["base_sha"],
            authenticated_rollback=self.evidence["rollback"],
            source_sha=candidate,
        )
        self.assertIn("GATE_B_ROLLBACK_AUTHENTICATION", blockers)

    def test_verifier_is_sha_bound_and_executes_from_isolated_base_checkout(self) -> None:
        live_module = self.source / "tools/ambitions_canon/cutover_readiness.py"
        original = live_module.read_bytes()
        live_module.write_text("raise RuntimeError('working-tree verifier used')\n")
        try:
            assessment = evaluate_gate_b(
                self.evidence_path,
                repo_root=self.source,
                artifact_root=self.artifacts,
            )
            self.assertEqual(assessment["gate_b"], "green", assessment)
            self.assertEqual(assessment["blocking_codes"], [])
            self.assertEqual(
                assessment["verifier_receipt"]["base_sha"],
                self.evidence["verifier"]["base_sha"],
            )
            self.assertEqual(
                assessment["verifier_receipt"]["blob_sha256"],
                self.evidence["verifier"]["blob_sha256"],
            )
        finally:
            live_module.write_bytes(original)

        forged = json.loads(json.dumps(self.evidence))
        forged["verifier"]["blob_sha256"] = "0" * 64
        assessment = evaluate_gate_b(
            self.write_evidence(forged, "forged-verifier.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_VERIFIER_INVALID", assessment["blocking_codes"])

    def test_benchmark_and_owner_approval_are_reverified_not_trusted_by_digest(self) -> None:
        requirement = json.loads(json.dumps(self.evidence))
        first_requirement = requirement["requirements"][0]
        original_attestation = json.loads(
            (self.artifacts / first_requirement["validation_attestation_path"]).read_text(
                encoding="utf-8"
            )
        )
        signature = original_attestation["signature_base64url"]
        original_attestation["signature_base64url"] = (
            ("B" if signature.startswith("A") else "A") + signature[1:]
        )
        forged_attestation_path, forged_attestation_digest = write_artifact(
            self.artifacts,
            "forged-requirement-attestation.json",
            original_attestation,
        )
        first_requirement["validation_attestation_path"] = forged_attestation_path
        first_requirement["validation_attestation_sha256"] = forged_attestation_digest
        assessment = evaluate_gate_b(
            self.write_evidence(requirement, "forged-requirement-evidence.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn(
            "GATE_B_REQUIREMENT_ATTESTATION_INVALID",
            assessment["blocking_codes"],
        )

        forged_report_path, forged_report_digest = write_artifact(
            self.artifacts,
            "forged-report.json",
            {"schema_version": 1, "status": "green"},
        )
        report = json.loads(json.dumps(self.evidence))
        report["authorization_benchmark"]["report_path"] = forged_report_path
        report["authorization_benchmark"]["report_sha256"] = forged_report_digest
        assessment = evaluate_gate_b(
            self.write_evidence(report, "forged-report-evidence.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_BENCHMARK_MISMATCH", assessment["blocking_codes"])

        owner = json.loads(json.dumps(self.evidence))
        owner["owner_decision"]["approval_attestation_sha256"] = "0" * 64
        assessment = evaluate_gate_b(
            self.write_evidence(owner, "forged-owner-evidence.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_OWNER_APPROVAL_INVALID", assessment["blocking_codes"])

    def test_owner_request_cryptographically_binds_approval_date_and_delegation(self) -> None:
        owner = self.evidence["owner_decision"]
        request = json.loads(
            (self.artifacts / owner["request_path"]).read_text(encoding="utf-8")
        )
        self.assertEqual(request["approval_date"], owner["approval_date"])
        self.assertIs(request["delegated"], owner["delegated"])
        for field, replacement in (
            ("approval_date", "2026-07-15"),
            ("delegated", not owner["delegated"]),
        ):
            with self.subTest(field=field):
                candidate = json.loads(json.dumps(self.evidence))
                candidate["owner_decision"][field] = replacement
                assessment = evaluate_gate_b(
                    self.write_evidence(candidate, f"owner-{field}-unbound.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                )
                self.assertIn(
                    "GATE_B_OWNER_DECISION_INVALID",
                    assessment["blocking_codes"],
                )

    def test_independent_review_is_trust_root_verified_and_owner_bound(self) -> None:
        original = self.evidence["reviews"][0]
        manufactured_review = {
            "review_id": "caller-manufactured-green",
            "reviewer_class": "independent",
            "verdict": "green",
            "verdicts": original["verdicts"],
            "dimensions": original["dimensions"],
            "base_sha": original["base_sha"],
            "head_sha": original["head_sha"],
            "commit_range": original["commit_range"],
            "critical_findings": 0,
            "important_findings": 0,
        }
        review_path, review_digest = write_artifact(
            self.artifacts, "reviews/caller-manufactured-green.json", manufactured_review
        )
        caller = json.loads(json.dumps(self.evidence))
        caller["reviews"] = [
            {
                **manufactured_review,
                "artifact_path": review_path,
                "artifact_sha256": review_digest,
                "review_attestation_path": original.get(
                    "review_attestation_path",
                    self.evidence["owner_decision"]["approval_attestation_path"],
                ),
                "review_attestation_sha256": original.get(
                    "review_attestation_sha256",
                    self.evidence["owner_decision"]["approval_attestation_sha256"],
                ),
            }
        ]
        assessment = evaluate_gate_b(
            self.write_evidence(caller, "caller-manufactured-review-evidence.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn(
            "GATE_B_REVIEW_ATTESTATION_INVALID", assessment["blocking_codes"]
        )

        trusted_review_attestation = independent_review_attestation(
            source=self.source,
            base=original["base_sha"],
            head=original["head_sha"],
            review_id=manufactured_review["review_id"],
            review_digest=review_digest,
            commit_range=manufactured_review["commit_range"],
            dimensions=[
                item["dimension_id"] for item in manufactured_review["dimensions"]
            ],
            verdicts=manufactured_review["verdicts"],
            rollback_scope=cutover_module._rollback_scope(self.evidence["rollback"]),
            current_event=json.loads(
                (
                    self.artifacts
                    / self.evidence["requirements"][0]["authorization_path"]
                ).read_text(encoding="utf-8")
            )["trusted_event_provenance"],
        )
        attestation_path, attestation_digest = write_artifact(
            self.artifacts,
            "reviews/caller-manufactured-green.attestation.json",
            trusted_review_attestation,
        )
        trusted_but_not_owner_approved = json.loads(json.dumps(caller))
        trusted_but_not_owner_approved["reviews"][0].update(
            {
                "review_attestation_path": attestation_path,
                "review_attestation_sha256": attestation_digest,
            }
        )
        assessment = evaluate_gate_b(
            self.write_evidence(
                trusted_but_not_owner_approved,
                "trusted-review-stale-owner-evidence.json",
            ),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_OWNER_APPROVAL_INVALID", assessment["blocking_codes"])

    def test_requirement_ci_attestation_binds_exact_task_and_checkout_context(self) -> None:
        requirement = self.evidence["requirements"][0]
        required_context = {
            "authorization_path",
            "authorization_sha256",
            "finalization_path",
            "finalization_sha256",
            "checkout_tree_sha",
        }
        self.assertTrue(required_context <= set(requirement))
        attestation_path = self.artifacts / requirement["validation_attestation_path"]
        original = json.loads(attestation_path.read_text(encoding="utf-8"))
        mismatches = {
            "repository_id": "caller-repository",
            "repository_full_name": "caller/fork",
            "pull_request_number": 999,
            "task_id": "CALLER-TASK",
            "intake_id": "CALLER-INTAKE",
            "intake_digest": "0" * 64,
            "policy_revision": "caller-policy",
            "authorization_digest": "0" * 64,
        }
        for index, (field, replacement) in enumerate(mismatches.items()):
            with self.subTest(field=field):
                forged = resign({**original, field: replacement})
                forged_path, forged_digest = write_artifact(
                    self.artifacts,
                    f"requirements/forged-context-{index}.json",
                    forged,
                )
                evidence = json.loads(json.dumps(self.evidence))
                evidence["requirements"][0][
                    "validation_attestation_path"
                ] = forged_path
                evidence["requirements"][0][
                    "validation_attestation_sha256"
                ] = forged_digest
                evidence["visual_owner_approval"]["delegated"] = True
                assessment = evaluate_gate_b(
                    self.write_evidence(evidence, f"context-negative-{index}.json"),
                    repo_root=self.source,
                    artifact_root=self.artifacts,
                )
                self.assertIn(
                    "GATE_B_REQUIREMENT_ATTESTATION_INVALID",
                    assessment["blocking_codes"],
                )

        authorization = json.loads(
            (self.artifacts / requirement["authorization_path"]).read_text(
                encoding="utf-8"
            )
        )
        authorization["tree_delta"]["new_tree_sha"] = "0" * 40
        authorization_path, authorization_digest = write_artifact(
            self.artifacts,
            "requirements/forged-checkout-authorization.json",
            authorization,
        )
        evidence = json.loads(json.dumps(self.evidence))
        evidence["requirements"][0]["authorization_path"] = authorization_path
        evidence["requirements"][0]["authorization_sha256"] = authorization_digest
        evidence["visual_owner_approval"]["delegated"] = True
        assessment = evaluate_gate_b(
            self.write_evidence(evidence, "checkout-tree-negative.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn(
            "GATE_B_REQUIREMENT_CONTEXT_INVALID", assessment["blocking_codes"]
        )

    def test_requirement_set_is_preflighted_and_identical_auth_context_is_cached(self) -> None:
        unknown = json.loads(json.dumps(self.evidence))
        unknown_requirement = json.loads(json.dumps(unknown["requirements"][0]))
        unknown_requirement["requirement_id"] = "caller-green-label"
        unknown["requirements"].append(unknown_requirement)
        unknown_path = self.write_evidence(unknown, "unknown-requirement-fast.json")
        with mock.patch.object(
            cutover_module, "_load_trust_anchors", wraps=cutover_module._load_trust_anchors
        ) as anchors, mock.patch.object(
            cutover_module, "task_start", wraps=cutover_module.task_start
        ) as start:
            assessment = cutover_module._evaluate_gate_b_core(
                unknown_path,
                repo_root=self.source,
                artifact_root=self.artifacts,
                expected_base_sha=self.evidence["expected_base_sha"],
                authenticated_rollback=self.evidence["rollback"],
                authenticated_current_event=self.authenticated_current_event(),
            )
        self.assertIn("GATE_B_REQUIREMENT_UNKNOWN", assessment["blocking_codes"])
        anchors.assert_not_called()
        start.assert_not_called()

        with mock.patch.object(
            cutover_module, "task_start", wraps=cutover_module.task_start
        ) as start, mock.patch.object(
            cutover_module, "_execute_benchmark", return_value=None
        ):
            assessment = cutover_module._evaluate_gate_b_core(
                self.evidence_path,
                repo_root=self.source,
                artifact_root=self.artifacts,
                expected_base_sha=self.evidence["expected_base_sha"],
                authenticated_rollback=self.evidence["rollback"],
                authenticated_current_event=self.authenticated_current_event(),
            )
        self.assertEqual(assessment["gate_b"], "green", assessment)
        self.assertEqual(start.call_count, 1)

    def test_unknown_fields_and_path_escape_fail_closed(self) -> None:
        unknown = json.loads(json.dumps(self.evidence))
        unknown["merge_authorized"] = True
        with self.assertRaisesRegex(GateBEvidenceError, "GATE_B_FIELDS"):
            evaluate_gate_b(
                self.write_evidence(unknown, "unknown.json"),
                repo_root=self.source,
                artifact_root=self.artifacts,
            )
        escaped = json.loads(json.dumps(self.evidence))
        escaped["requirements"][0]["artifact_path"] = "../outside"
        assessment = evaluate_gate_b(
            self.write_evidence(escaped, "escaped.json"),
            repo_root=self.source,
            artifact_root=self.artifacts,
        )
        self.assertIn("GATE_B_ARTIFACT_PATH", assessment["blocking_codes"])

    def test_every_git_subprocess_ignores_hooks_global_config_and_ambient_secret(self) -> None:
        for module in (benchmark_module, cutover_module):
            with self.subTest(module=module.__name__), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                repo = root / "repo"
                repo.mkdir()
                git(repo, "init", "-q")
                git(repo, "config", "user.name", "Hook Probe")
                git(repo, "config", "user.email", "hook@example.invalid")
                (repo / "probe.txt").write_text("probe\n", encoding="utf-8")
                git(repo, "add", "probe.txt")
                git(repo, "commit", "-qm", "probe")
                hook_directory = root / "global-hooks"
                hook_directory.mkdir()
                sentinel = root / "hook-sentinel.txt"
                hook = hook_directory / "reference-transaction"
                hook.write_text(
                    "#!/bin/sh\n"
                    "printf '%s' \"$TASK25_SENTINEL_SECRET\" > \"$TASK25_HOOK_SENTINEL\"\n",
                    encoding="utf-8",
                )
                hook.chmod(0o755)
                home = root / "ambient-home"
                home.mkdir()
                (home / ".gitconfig").write_text(
                    f"[core]\n\thooksPath = {hook_directory}\n",
                    encoding="utf-8",
                )
                with mock.patch.dict(
                    os.environ,
                    {
                        "HOME": str(home),
                        "TASK25_HOOK_SENTINEL": str(sentinel),
                        "TASK25_SENTINEL_SECRET": "ambient-secret-reached-hook",
                    },
                ):
                    module._git(repo, "branch", "-f", "probe-branch", "HEAD")
                self.assertFalse(sentinel.exists())

    def test_primary_evidence_surrogate_size_and_nesting_fail_with_stable_bounds_code(self) -> None:
        nested: object = 0
        for _ in range(80):
            nested = [nested]
        cases = {
            "surrogate": b'{"value":"\\ud800"}\n',
            "oversize": canonical_json_bytes({"value": "x" * (4 * 1024 * 1024)}),
            "nested": canonical_json_bytes({"value": nested}),
        }
        for name, raw in cases.items():
            with self.subTest(name=name):
                path = self.artifacts / f"primary-{name}.json"
                path.write_bytes(raw)
                try:
                    cutover_module._read_primary_evidence(path, self.artifacts)
                except GateBEvidenceError as exc:
                    self.assertEqual(exc.code, "GATE_B_EVIDENCE_BOUNDS")
                except UnicodeEncodeError:
                    self.fail("raw UnicodeEncodeError escaped the fail-closed parser")
                else:
                    self.fail("unbounded primary evidence was accepted")


class LegacyAuditParityTests(unittest.TestCase):
    @staticmethod
    def _inputs() -> dict[str, bytes]:
        paths = (
            "docs/canon/references/legacy-audit-invariant-parity.json",
            "scripts/ambitions-constitution-audit.py",
        )
        return {path: (ROOT / path).read_bytes() for path in paths}

    def test_every_legacy_invariant_has_one_equivalent_or_stronger_mapping(self) -> None:
        count, commands = cutover_module._validate_legacy_audit_parity(
            self._inputs()
        )
        self.assertEqual(count, 37)
        self.assertEqual(
            commands,
            [
                "audit",
                "authority-sprawl",
                "build-check",
                "p0-coverage",
                "traceability",
            ],
        )

    def test_missing_duplicate_unknown_and_weaker_parity_mappings_fail(self) -> None:
        for mutation in ("missing", "duplicate", "unknown", "weaker"):
            with self.subTest(mutation=mutation):
                inputs = self._inputs()
                path = "docs/canon/references/legacy-audit-invariant-parity.json"
                registry = json.loads(inputs[path].decode("utf-8"))
                if mutation == "missing":
                    registry["invariants"] = registry["invariants"][:-1]
                elif mutation == "duplicate":
                    registry["invariants"][-1] = registry["invariants"][0]
                elif mutation == "unknown":
                    registry["invariants"][0]["legacy_invariant_id"] = "UNKNOWN"
                else:
                    registry["invariants"][0]["coverage_strength"] = "weaker"
                inputs[path] = canonical_json_bytes(registry)
                with self.assertRaisesRegex(
                    Exception, "GATE_B_LEGACY_AUDIT_PARITY"
                ):
                    cutover_module._validate_legacy_audit_parity(inputs)

    def test_each_replacement_command_requires_a_parsed_green_result(self) -> None:
        command_ids = sorted(cutover_module._LEGACY_REPLACEMENT_COMMANDS)

        def green_run(argv, **_kwargs):
            command_id = next(
                identifier
                for identifier, (suffix, _prefix, _invariant_prefix) in cutover_module._LEGACY_REPLACEMENT_COMMANDS.items()
                if argv[-len(suffix) :] == suffix
            )
            prefix = cutover_module._LEGACY_REPLACEMENT_COMMANDS[command_id][1]
            return subprocess.CompletedProcess(argv, 0, (prefix + "ok\n").encode(), b"")

        with mock.patch.object(subprocess, "run", side_effect=green_run):
            self.assertEqual(
                cutover_module._run_legacy_replacement_commands(ROOT, command_ids),
                {command_id: "green" for command_id in command_ids},
            )

        failed = subprocess.CompletedProcess(["python"], 1, b"RED\n", b"")
        with mock.patch.object(subprocess, "run", return_value=failed):
            with self.assertRaisesRegex(Exception, "GATE_B_LEGACY_COMMAND_RESULT"):
                cutover_module._run_legacy_replacement_commands(ROOT, command_ids)

    def test_replacement_ids_are_machine_resolved_and_old_audit_is_executed(self) -> None:
        inputs = self._inputs()
        path = "docs/canon/references/legacy-audit-invariant-parity.json"
        registry = json.loads(inputs[path].decode("utf-8"))
        registry["invariants"][0]["replacement_invariant_id"] = "DECLARED-BUT-UNKNOWN"
        inputs[path] = canonical_json_bytes(registry)
        with self.assertRaisesRegex(Exception, "GATE_B_LEGACY_AUDIT_PARITY"):
            cutover_module._validate_legacy_audit_parity(inputs)

        completed = subprocess.CompletedProcess(
            [sys.executable, "scripts/ambitions-constitution-audit.py"],
            0,
            b"GREEN ambitions constitutional registry audit\nopportunities=1\n",
            b"",
        )
        with mock.patch.object(subprocess, "run", return_value=completed) as invoked:
            self.assertEqual(
                cutover_module._run_base_owned_legacy_audit(ROOT), "green"
            )
        self.assertEqual(
            invoked.call_args.args[0],
            [sys.executable, "scripts/ambitions-constitution-audit.py"],
        )


class VisualLedgerDerivationTests(unittest.TestCase):
    @staticmethod
    def _inputs() -> dict[str, bytes]:
        paths = (
            *cutover_module._VISUAL_LEDGER_PATHS,
            cutover_module._VISUAL_POLICY_PATH,
        )
        return {path: (ROOT / path).read_bytes() for path in paths}

    def test_visual_completeness_is_derived_from_exact_merged_ledgers(self) -> None:
        completeness = cutover_module._derive_visual_completeness_from_bytes(
            self._inputs()
        )
        self.assertEqual(len(completeness["screen_ids"]), 47)
        self.assertEqual(len(completeness["state_ids"]), 441)
        self.assertEqual(len(completeness["journey_ids"]), 12)
        self.assertEqual(len(completeness["object_ids"]), 18)
        self.assertEqual(len(completeness["visual_requirement_ids"]), 346)
        self.assertEqual(
            completeness["required_review_dimensions"],
            [
                "accessibility-coverage",
                "frame-completeness",
                "journey-coverage",
                "object-coverage",
                "requirement-coverage",
                "screenshot-authenticity",
                "state-coverage",
            ],
        )

    def test_visual_requirement_omission_cannot_hide_behind_a_reduced_count(self) -> None:
        inputs = self._inputs()
        path = "docs/canon/migration/ux-blueprint.json"
        blueprint = json.loads(inputs[path].decode("utf-8"))
        removed = next(
            item
            for item in blueprint["requirement_dispositions"]
            if item["disposition"] == "visual_mapping_required"
        )
        blueprint["requirement_dispositions"].remove(removed)
        inputs[path] = canonical_json_bytes(blueprint)
        with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_BINDING"):
            cutover_module._derive_visual_completeness_from_bytes(inputs)

    def test_figma_export_omission_and_claim_upgrade_fail_closed(self) -> None:
        completeness = cutover_module._derive_visual_completeness_from_bytes(
            self._inputs()
        )
        with tempfile.TemporaryDirectory() as directory:
            artifacts = Path(directory)
            raw = b"bounded-figma-design-export"
            (artifacts / "frame.fig").write_bytes(raw)
            export = {
                "accessibility_variants": completeness["accessibility_variants"],
                "artifact_path": "frame.fig",
                "artifact_sha256": hashlib.sha256(raw).hexdigest(),
                "byte_size": len(raw),
                "claim_ceiling": cutover_module._VISUAL_CLAIM_CEILING,
                "evidence_kind": "figma-design-export",
                "figma_file_key": "Oik7612LSTUHWsNRFoTlTJ",
                "figma_node_id": "37:438",
                "frame_id": "FRAME-COMPLETE",
                "frame_version": "R1",
                "journey_ids": completeness["journey_ids"],
                "media_type": "application/x-figma-design-export",
                "merged_visual_ledger_sha256": completeness[
                    "merged_visual_ledger_sha256"
                ],
                "object_ids": completeness["object_ids"],
                "screen_ids": completeness["screen_ids"],
                "state_ids": completeness["state_ids"],
                "visual_requirement_ids": completeness[
                    "visual_requirement_ids"
                ],
            }
            accepted = cutover_module._verify_figma_design_exports(
                [export], completeness, artifacts
            )
            self.assertEqual(accepted[0]["frame_id"], "FRAME-COMPLETE")

            omitted = json.loads(json.dumps(export))
            omitted["state_ids"] = omitted["state_ids"][1:]
            with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_COMPLETENESS"):
                cutover_module._verify_figma_design_exports(
                    [omitted], completeness, artifacts
                )

            overclaim = dict(export)
            overclaim["claim_ceiling"] = "Runtime and Accessibility Green"
            with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_BINDING"):
                cutover_module._verify_figma_design_exports(
                    [overclaim], completeness, artifacts
                )

            simulator = dict(export)
            simulator["evidence_kind"] = "simulator-render"
            with self.assertRaisesRegex(Exception, "GATE_B_VISUAL_BINDING"):
                cutover_module._verify_figma_design_exports(
                    [simulator], completeness, artifacts
                )


class VerifierResourceBoundTests(unittest.TestCase):
    def test_every_verifier_controlled_subprocess_has_explicit_timeout(self) -> None:
        paths = (
            "tools/ambitions_canon/authorization.py",
            "tools/ambitions_canon/authorization_benchmark.py",
            "tools/ambitions_canon/cli.py",
            "tools/ambitions_canon/cutover_readiness.py",
            "tools/ambitions_canon/purge.py",
        )
        missing: list[str] = []
        for relative in paths:
            tree = ast.parse((ROOT / relative).read_text(encoding="utf-8"))
            for node in ast.walk(tree):
                if (
                    isinstance(node, ast.Call)
                    and isinstance(node.func, ast.Attribute)
                    and isinstance(node.func.value, ast.Name)
                    and node.func.value.id == "subprocess"
                    and node.func.attr == "run"
                    and not any(keyword.arg == "timeout" for keyword in node.keywords)
                ):
                    missing.append(f"{relative}:{node.lineno}")
        self.assertEqual(missing, [])

    def test_primary_and_artifact_reads_reject_preflight_size_limit(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            primary = root / "primary.json"
            with primary.open("wb") as handle:
                handle.truncate(cutover_module._MAX_PRIMARY_EVIDENCE_BYTES)
            with self.assertRaisesRegex(GateBEvidenceError, "GATE_B_EVIDENCE_BOUNDS"):
                cutover_module._read_primary_evidence(primary, root)

            artifact = root / "artifact.bin"
            with artifact.open("wb") as handle:
                handle.truncate(cutover_module._MAX_ARTIFACT_BYTES)
            with self.assertRaisesRegex(Exception, "GATE_B_TEST_PATH"):
                cutover_module._artifact_bytes(
                    root, "artifact.bin", "0" * 64, "GATE_B_TEST"
                )

    def test_rollback_receipt_executes_real_detached_clean_restore(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory) / "repo"
            repo.mkdir()
            git(repo, "init", "-q", "-b", "main")
            git(repo, "config", "user.name", "Rollback Proof")
            git(repo, "config", "user.email", "rollback@example.invalid")
            (repo / "state.txt").write_text("rollback\n", encoding="utf-8")
            git(repo, "add", "state.txt")
            git(repo, "commit", "-qm", "rollback state")
            rollback_commit = git(repo, "rev-parse", "HEAD")
            rollback_tree = git(repo, "rev-parse", "HEAD^{tree}")
            (repo / "state.txt").write_text("source\n", encoding="utf-8")
            git(repo, "commit", "-qam", "source state")
            source_sha = git(repo, "rev-parse", "HEAD")
            receipt = cutover_module._rollback_restore_receipt(
                repo,
                expected_base_sha=source_sha,
                source_sha=source_sha,
                rollback_commit_sha=rollback_commit,
                rollback_tree_sha=rollback_tree,
            )
            self.assertEqual(receipt["restored_head_sha"], rollback_commit)
            self.assertEqual(receipt["restored_tree_sha"], rollback_tree)
            self.assertEqual(receipt["worktree_status"], "clean")


if __name__ == "__main__":
    unittest.main()
