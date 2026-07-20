from __future__ import annotations

import base64
import hashlib
import importlib.util
import io
import json
import os
import stat
import subprocess
import sys
import tempfile
import unittest
from contextlib import nullcontext, redirect_stdout
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

from tools.ambitions_canon import authorization as authorization_module
from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon.authorization import (
    AuthorizationError,
    approval_attestation_digest,
    canonical_json_bytes,
    canonical_local_state,
    canonical_tree_delta,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
    task_start,
    validate_task_intake,
    validation_attestation_digest,
    validate_task_authorization,
    write_authorization_output,
    write_json_atomic,
)
from tools.ambitions_canon.independent_review import (
    CODEX_REVIEWER_ID,
    CODEX_REVIEWER_LOGIN,
    IndependentReviewError,
    fetch_independent_review_evidence,
    main as independent_review_main,
    validate_independent_review_payload,
)


ROOT = Path(__file__).resolve().parents[2]
SCHEMAS = ROOT / "docs/canon/schemas"
HEX_A = "a" * 40
HEX_B = "b" * 40
SHA_A = "a" * 64
SHA_B = "b" * 64
RSA_MODULUS = int(
    "a622e6242d99481cc62ee9dc9a63e57f0fbca78654f7e50b137bb37b16e5d04f"
    "1c3c6114eb09ca01da6063072e2df3cdbf818c481190bf37ee46a9b648562730"
    "baa62dbc bec7d6ae522c7f316039d0d9140697b33515a2305745d05bd4139f6a630c1e"
    "13b2e4647b5025cc1d7672f9b6b871d7d3c639eb70069fb415c5cd322d".replace(" ", ""),
    16,
)
RSA_PRIVATE_EXPONENT = int(
    "23144f5fe838eb5f1801a3e3aebdd521852322845cc0931e4998df06e888d1f9"
    "424f0578b34037e538450de3e03e57b263f368b976ec075439fdb5ac058e1b6b"
    "f95281d23116b338ab0e3361cec5baa5f20b9f07a00d99a96d64bfb9002d9092"
    "3949b08536342a0d780dd8e86b42bba3dd4430b32ab4914b63277457a5f99e49",
    16,
)
RSA_DIGEST_INFO = bytes.fromhex("3031300d060960864801650304020105000420")
TEST_ANCHOR_ID = "test-platform"


def write_json(root: Path, path: str, value: object) -> None:
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
        encoding="utf-8",
    )


def labeled_digest(entries: list[tuple[str, bytes]]) -> str:
    digest = hashlib.sha256()
    for label, content in sorted(entries):
        encoded = label.encode("utf-8")
        digest.update(len(encoded).to_bytes(8, "big"))
        digest.update(encoded)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def anchor() -> dict[str, object]:
    return {
        "anchor_id": TEST_ANCHOR_ID,
        "algorithm": "rsa-pkcs1v15-sha256",
        "purposes": ["approval", "event", "validation"],
        "modulus_hex": f"{RSA_MODULUS:x}",
        "public_exponent": 65537,
    }


def anchors() -> dict[str, object]:
    return {
        "schema_version": 1,
        "registry_revision": "test-anchors-v1",
        "repository_identity": {
            "repository_id": "12345",
            "repository_full_name": "agentdevan/ambitions",
        },
        "anchors": [anchor()],
    }


def sign(payload: dict[str, object]) -> dict[str, object]:
    candidate = dict(payload)
    candidate["trust_anchor_id"] = TEST_ANCHOR_ID
    candidate["trust_anchor_sha256"] = hashlib.sha256(
        canonical_json_bytes(anchor())
    ).hexdigest()
    candidate["signature_algorithm"] = "rsa-pkcs1v15-sha256"
    candidate["signature_base64url"] = ""
    signed = dict(candidate)
    signed.pop("signature_base64url")
    digest_info = RSA_DIGEST_INFO + hashlib.sha256(
        canonical_json_bytes(signed)
    ).digest()
    size = (RSA_MODULUS.bit_length() + 7) // 8
    encoded = b"\x00\x01" + b"\xff" * (size - len(digest_info) - 3) + b"\x00" + digest_info
    signature = pow(
        int.from_bytes(encoded, "big"), RSA_PRIVATE_EXPONENT, RSA_MODULUS
    ).to_bytes(size, "big")
    candidate["signature_base64url"] = base64.urlsafe_b64encode(signature).rstrip(
        b"="
    ).decode("ascii")
    return candidate


def resign(payload: dict[str, object]) -> dict[str, object]:
    unsigned = {
        key: value
        for key, value in payload.items()
        if key
        not in {
            "trust_anchor_id",
            "trust_anchor_sha256",
            "signature_algorithm",
            "signature_base64url",
        }
    }
    return sign(unsigned)


def write_trusted_state(
    root: Path,
    authorized_files: list[str],
    *,
    approval_required: bool = False,
    consumed_nonces: tuple[str, ...] = (),
    authorized_path_roots: tuple[str, ...] = (),
    protected_paths: tuple[str, ...] = (),
    maximum_changed_files: int = 128,
    maximum_changed_bytes: int = 16 * 1024 * 1024,
) -> None:
    (root / "docs/canon").mkdir(parents=True, exist_ok=True)
    (root / "docs/canon/MANIFEST.toml").write_text(
        'schema_version = 1\ncanon_revision = 11\nauthority_state = "shadow"\n'
        'compiler_version = "0.2.0"\nnormative_files = []\ngenerated_files = []\n',
        encoding="utf-8",
    )
    manifest_bytes = (root / "docs/canon/MANIFEST.toml").read_bytes()
    canon_sha = labeled_digest([("MANIFEST.toml", manifest_bytes)])
    projection_base = {
        "schema_version": 1,
        "canon_revision": 11,
        "canon_content_sha": canon_sha,
    }
    write_json(
        root,
        "docs/canon/generated/concept-ownership.json",
        {
            **projection_base,
            "concepts": [
                {"concept": "authorization", "spec_id": "TEST-AUTHORIZATION"},
                {
                    "concept": "engineering.release.rollout",
                    "spec_id": "TEST-RELEASE",
                },
            ],
        },
    )
    issue_state = {
        "schema_version": 1,
        "snapshot_revision": "issue-v1",
        "issues": [
            {
                "issue_reference": "CANON-TASK-24",
                "state": "in_progress",
                "task_ids": ["TASK-24"],
                "revision": "1",
                "prerequisite_task_ids": [],
            }
        ],
    }
    write_json(
        root,
        "docs/canon/generated/known-issues.json",
        {**projection_base, "issues": []},
    )
    write_json(
        root,
        "docs/canon/generated/proof-state.json",
        {**projection_base, "proof": []},
    )
    write_json(
        root,
        "docs/canon/generated/conflict-state.json",
        {**projection_base, "conflicts": []},
    )
    approval_nonce_state = {
        "schema_version": 1,
        "snapshot_revision": "nonce-consumption-v1",
        "consumption_generation": 1,
        "consumed_nonces": sorted(consumed_nonces),
    }
    requirement_index = {
        "requirements": [
            {"requirement_id": "AUTH-001", "concept": "authorization"},
            {
                "requirement_id": "RELEASE-003",
                "concept": "engineering.release.rollout",
            },
        ]
    }
    write_json(root, "docs/canon/generated/canon-index.json", requirement_index)
    constitution = root / "docs/canon/CONSTITUTION.md"
    constitution.write_text("# Test constitution\n", encoding="utf-8")
    skill = root / ".agents/skills/ambitions-source-truth-authority/SKILL.md"
    skill.parent.mkdir(parents=True, exist_ok=True)
    skill.write_text("# Test procedural adapter\n", encoding="utf-8")
    write_json(
        root,
        "docs/canon/references/skill-dependencies.json",
        {
            "schema_version": 1,
            "registry_revision": "test-skills-v1",
            "compiler_compatibility": ["0.2.0"],
            "requirement_index_path": "docs/canon/generated/canon-index.json",
            "requirement_index_sha256": hashlib.sha256(
                (root / "docs/canon/generated/canon-index.json").read_bytes()
            ).hexdigest(),
            "skills": [
                {
                    "skill_id": "ambitions-source-truth-authority",
                    "path": ".agents/skills/ambitions-source-truth-authority/SKILL.md",
                    "skill_sha256": hashlib.sha256(skill.read_bytes()).hexdigest(),
                    "allowed_adapter_purpose": "Route to test canon only.",
                    "may_authorize": False,
                    "requirement_ids": ["AUTH-001"],
                    "schema_compatibility": [1],
                    "compiler_compatibility": ["0.2.0"],
                    "depends_on_skills": [],
                    "dependencies": [
                        {
                            "path": "docs/canon/CONSTITUTION.md",
                            "sha256": hashlib.sha256(
                                constitution.read_bytes()
                            ).hexdigest(),
                            "authority_role": "canonical",
                        }
                    ],
                }
            ],
        },
    )
    workflow = root / ".github/workflows/canon-authorization.yml"
    workflow.parent.mkdir(parents=True, exist_ok=True)
    workflow.write_text("name: Canon authorization test\n", encoding="utf-8")
    workflow_digest = hashlib.sha256(workflow.read_bytes()).hexdigest()
    write_json(
        root,
        "docs/canon/references/validation-command-manifest.json",
        {
            "schema_version": 1,
            "manifest_revision": "commands-v1",
            "trusted_workflow": {
                "path": ".github/workflows/canon-authorization.yml",
                "ref": "refs/heads/main",
                "digest": workflow_digest,
                "check_identity": "ambitions-canon-authorization",
                "integration_id": "github-actions",
                "app_id": "15368",
            },
            "commands": [
                {
                    "command_id": "canon-unit",
                    "argv": ["python3", "-m", "unittest"],
                    "required_for_task_types": ["governance"],
                    "required_for_scenarios": [],
                    "proof_obligation_ids": [
                        "focused-tests",
                        "offline-determinism",
                    ],
                    "evidence_class": "automated-validation",
                },
                {
                    "command_id": "independent-review-evidence",
                    "argv": ["python3", "-m", "json.tool", "review.json"],
                    "required_for_task_types": ["governance"],
                    "required_for_scenarios": [],
                    "proof_obligation_ids": ["independent-review"],
                    "evidence_class": "independent-review",
                }
            ],
        },
    )
    schema_paths = [
        "docs/canon/schemas/task-intake.schema.json",
        "docs/canon/schemas/task-authorization.schema.json",
        "docs/canon/schemas/trusted-event.schema.json",
        "docs/canon/schemas/approval-attestation.schema.json",
        "docs/canon/schemas/validation-attestation.schema.json",
    ]
    for path in schema_paths:
        write_json(root, path, {"schema_version": 1})
    write_json(
        root,
        "docs/canon/references/task-authorization-policy.json",
        {
            "schema_version": 1,
            "policy_revision": "authorization-v1",
            "schema_revision": "authorization-schema-v1",
            "compiler_version": "0.2.0",
            "repository_identity": {
                "repository_id": "12345",
                "repository_full_name": "agentdevan/ambitions",
            },
            "approval_policies": [
                {
                    "policy_id": "owner-gate",
                    "policy_revision": "1",
                    "authenticated_principals": ["owner:devan"],
                    "break_glass_allowed": False,
                }
            ],
            "trust_anchors": anchors(),
            "approval_nonce_state": approval_nonce_state,
            "issue_state": issue_state,
            "snapshot_paths": {
                "canon_manifest": "docs/canon/MANIFEST.toml",
                "source_ownership": "docs/canon/generated/concept-ownership.json",
                "known_issues": "docs/canon/generated/known-issues.json",
                "proof_state": "docs/canon/generated/proof-state.json",
                "conflict_state": "docs/canon/generated/conflict-state.json",
                "skill_dependencies": "docs/canon/references/skill-dependencies.json",
                "command_manifest": "docs/canon/references/validation-command-manifest.json",
                "authorization_schemas": schema_paths,
            },
            "task_rules": [
                {
                    "task_id": "TASK-24",
                    "issue_reference": "CANON-TASK-24",
                    "task_types": ["governance"],
                    "scopes": ["authorization"],
                    "requirement_ids": ["AUTH-001"],
                    "source_owner": "canon-governance",
                    "authorized_files": sorted(authorized_files),
                    "required_checks": [
                        "canon-unit",
                        "independent-review-evidence",
                    ],
                    "proof_obligations": [
                        "focused-tests",
                        "independent-review",
                        "offline-determinism",
                    ],
                    "maximum_claim_ceiling": "Governance Green for exact scope",
                    "approval_required": approval_required,
                    "approval_policy_ids": ["owner-gate@1"],
                    **(
                        {
                            "authorization_modes": [
                                "exact-files",
                                "path-roots",
                            ],
                            "delegated_task_types": ["governance"],
                            "delegated_scope_mode": "base-canon-concepts",
                            "delegated_requirement_mode": "base-canon-requirements",
                            "authorized_path_roots": sorted(
                                authorized_path_roots
                            ),
                            "protected_paths": sorted(protected_paths),
                            "maximum_changed_files": maximum_changed_files,
                            "maximum_changed_bytes": maximum_changed_bytes,
                        }
                        if authorized_path_roots
                        else {}
                    ),
                }
            ],
            "approval_trust_anchor_id": TEST_ANCHOR_ID,
            "event_trust_anchor_id": TEST_ANCHOR_ID,
            "validation_trust_anchor_id": TEST_ANCHOR_ID,
        },
    )


def run(repo: Path, *args: str) -> str:
    completed = subprocess.run(
        ["git", *args],
        cwd=repo,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return completed.stdout.strip()


def init_repo(
    root: Path,
    *,
    approval_required: bool = False,
    consumed_nonces: tuple[str, ...] = (),
) -> tuple[str, str]:
    run(root, "init", "-q")
    run(root, "config", "user.name", "Canon Test")
    run(root, "config", "user.email", "canon@example.invalid")
    (root / "keep.txt").write_text("base\n", encoding="utf-8")
    (root / "delete.txt").write_text("delete\n", encoding="utf-8")
    (root / "mode.txt").write_text("mode\n", encoding="utf-8")
    raw_path = "raw-base64url:" + base64.urlsafe_b64encode(b"raw-\xff.txt").rstrip(
        b"="
    ).decode("ascii")
    write_trusted_state(
        root,
        [
            "binary.bin",
            "copy.txt",
            "delete.txt",
            "keep.txt",
            "link",
            "mode.txt",
            raw_path,
        ],
        approval_required=approval_required,
        consumed_nonces=consumed_nonces,
    )
    run(root, "add", "-A")
    run(root, "commit", "-qm", "base")
    base = run(root, "rev-parse", "HEAD")
    run(root, "branch", "main", base)

    (root / "delete.txt").unlink()
    (root / "keep.txt").write_text("changed\n", encoding="utf-8")
    (root / "copy.txt").write_text("base\n", encoding="utf-8")
    (root / "binary.bin").write_bytes(b"\x00\xff\x10")
    os.chmod(root / "mode.txt", stat.S_IMODE((root / "mode.txt").stat().st_mode) | 0o111)
    os.symlink("keep.txt", root / "link")
    run(root, "add", "-A")
    raw_blob = subprocess.run(
        ["git", "hash-object", "-w", "--stdin"],
        cwd=root,
        check=True,
        input=b"raw\n",
        stdout=subprocess.PIPE,
    ).stdout.strip()
    subprocess.run(
        ["git", "update-index", "-z", "--index-info"],
        cwd=root,
        check=True,
        input=b"100644 blob " + raw_blob + b"\traw-\xff.txt\0",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    run(root, "commit", "-qm", "head")
    return base, run(root, "rev-parse", "HEAD")


def intake(*files: str) -> dict[str, object]:
    return {
        "schema_version": 1,
        "intake_id": "INTAKE-24",
        "task_id": "TASK-24",
        "issue_reference": "CANON-TASK-24",
        "requested_task_type": "governance",
        "requested_scope": ["authorization"],
        "requested_requirement_ids": ["AUTH-001"],
        "requested_changed_files": list(files),
        "requested_validation": ["canon-unit"],
        "requested_proof": ["focused-tests"],
        "requested_rollback": ["git-revert"],
        "requested_claim_ceiling": "Governance Green for exact scope",
        "requested_skill_adapters": ["ambitions-source-truth-authority"],
    }


def root_intake(
    *roots: str,
    maximum_changed_files: int = 32,
    maximum_changed_bytes: int = 1024 * 1024,
) -> dict[str, object]:
    return {
        **intake(),
        "requested_changed_files": [],
        "requested_authorization_mode": "path-roots",
        "requested_path_roots": list(roots),
        "requested_max_changed_files": maximum_changed_files,
        "requested_max_changed_bytes": maximum_changed_bytes,
    }


def init_manifest_authorization_repo(
    root: Path,
    *,
    deterministic_candidate: bool = True,
    candidate_action: str = "delete",
) -> tuple[str, str, dict[str, object]]:
    victim = "docs/truth/OLD_CANON.md"
    plan_path = "docs/canon/migration/purge-plan.toml"
    run(root, "init", "-q", "-b", "main")
    run(root, "config", "user.name", "Canon Purge Authorization")
    run(root, "config", "user.email", "canon-purge@example.invalid")
    target = root / victim
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text("superseded\n", encoding="utf-8")
    write_trusted_state(root, [plan_path], approval_required=True)
    plan = root / plan_path
    plan.parent.mkdir(parents=True, exist_ok=True)
    plan.write_text(
        "\n".join(
            (
                "schema_version = 1",
                'rollback_ref = "refs/tags/canon-baseline"',
                f'source_catalog_sha256 = "{"a" * 64}"',
                f'dispositions_sha256 = "{"b" * 64}"',
                f'references_sha256 = "{"c" * 64}"',
                "",
                "[[artifact]]",
                'artifact_id = "REPO-OLD-CANON"',
                'kind = "repo"',
                f'locator = "{victim}"',
                'action = "delete"',
                'claim_ids = ["CLAIM-1"]',
                'replacement_ids = ["AUTH-001"]',
                'claims_resolved = true',
                'incoming_links_rewritten = true',
                'external_references_reconciled = true',
                f"unique_content_extracted = {str(deterministic_candidate).lower()}",
                'owner_approved = false',
                'independent_review = true',
                f'independent_review_attestation_sha256 = "{"e" * 64}"',
                'rollback_ref = "refs/tags/canon-baseline"',
                "",
                "[[artifact.claim_disposition]]",
                'claim_id = "CLAIM-1"',
                'replacement_id = "AUTH-001"',
                "",
            )
        ),
        encoding="utf-8",
    )
    policy_path = root / "docs/canon/references/task-authorization-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    rule = policy["task_rules"][0]
    rule["task_id"] = "TASK-27"
    rule["issue_reference"] = "CANON-TASK-27"
    rule["scopes"] = ["gate-c", "repo-purge"]
    rule["authorized_deletion_manifest"] = plan_path
    issue = policy["issue_state"]["issues"][0]
    issue["task_ids"] = ["TASK-27"]
    issue["issue_reference"] = "CANON-TASK-27"
    write_json(root, "docs/canon/references/task-authorization-policy.json", policy)
    run(root, "add", "-A")
    run(root, "commit", "-qm", "trusted purge manifest")
    base = run(root, "rev-parse", "HEAD")
    run(root, "tag", "canon-baseline", base)
    run(root, "checkout", "-qb", "topic")
    if candidate_action == "delete":
        target.unlink()
    elif candidate_action == "modify":
        target.write_text("candidate mutation\n", encoding="utf-8")
    else:
        raise AssertionError(candidate_action)
    run(root, "add", "-A")
    run(root, "commit", "-qm", f"candidate {candidate_action}")
    head = run(root, "rev-parse", "HEAD")
    request = intake(victim)
    request["task_id"] = "TASK-27"
    request["issue_reference"] = "CANON-TASK-27"
    request["requested_scope"] = ["gate-c", "repo-purge"]
    return base, head, request


def event(
    repo: Path,
    base: str,
    head: str,
    *,
    verification_epoch: int = 1_900_000_000,
    workflow_run_id: int = 24001,
    workflow_run_attempt: int = 1,
    consumption_generation: int = 1,
    completed_task_receipts: tuple[tuple[str, str], ...] = (),
) -> dict[str, object]:
    policy = load_base_policy(repo, base)
    payload: dict[str, object] = {
        "schema_version": 1,
        "event_provider": "github",
        "event_attestation_origin": "trusted-ci",
        "repository_id": "12345",
        "repository_full_name": "agentdevan/ambitions",
        "pull_request_number": 24,
        "base_ref": "refs/heads/main",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "merge_base_sha": run(repo, "merge-base", base, head),
        "verification_epoch": verification_epoch,
        "expires_at_epoch": verification_epoch + 3600,
        "workflow_run_id": workflow_run_id,
        "workflow_run_attempt": workflow_run_attempt,
        "consumption_generation": consumption_generation,
        "issue_state_transition": {
            "schema_version": 1,
            "snapshot_revision": "platform-issue-transition-v1",
            "base_issue_state_sha256": hashlib.sha256(
                canonical_json_bytes(policy["issue_state"])
            ).hexdigest(),
            "completed_task_receipts": [
                {
                    "task_id": task_id,
                    "finalization_receipt_sha256": receipt_sha256,
                }
                for task_id, receipt_sha256 in completed_task_receipts
            ],
        },
    }
    return refresh_event_digest(payload)


def refresh_event_digest(payload: dict[str, object]) -> dict[str, object]:
    result = {
        key: value
        for key, value in payload.items()
        if key
        not in {
            "event_projection_digest",
            "trust_anchor_id",
            "trust_anchor_sha256",
            "signature_algorithm",
            "signature_base64url",
        }
    }
    projection = dict(result)
    result["event_projection_digest"] = hashlib.sha256(
        canonical_json_bytes(projection)
    ).hexdigest()
    return sign(result)


def trusted_context(
    repo: Path, base: str, intake_data: dict[str, object]
) -> tuple[dict[str, object], dict[str, object]]:
    trusted_policy = load_base_policy(repo, base)
    trusted_bindings = load_trusted_bindings(
        repo, base, intake_data, trusted_policy
    )
    return trusted_bindings, trusted_policy


def approval(
    repo: Path,
    base: str,
    head: str,
    intake_digest: str,
    trusted_bindings: dict[str, object],
    event_data: dict[str, object] | None = None,
    *,
    task_id: str = "TASK-24",
    intake_id: str = "INTAKE-24",
    approved_scope: tuple[str, ...] = ("authorization",),
    one_time_use_nonce: str = "nonce-24",
) -> dict[str, object]:
    trusted_event = event_data or event(repo, base, head)
    return sign({
        "schema_version": 1,
        "attestation_id": "APPROVAL-24",
        "attestation_origin": "platform-authenticated",
        "repository_id": "12345",
        "repository_full_name": "agentdevan/ambitions",
        "pull_request_number": 24,
        "task_id": task_id,
        "intake_id": intake_id,
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "merge_base_sha": run(repo, "merge-base", base, head),
        "intake_digest": intake_digest,
        "policy_revision": trusted_bindings["policy_revision"],
        "command_manifest_digest": trusted_bindings["command_manifest_sha256"],
        "workflow_path": ".github/workflows/canon-authorization.yml",
        "workflow_ref": "refs/heads/main",
        "workflow_digest": trusted_bindings["validation_workflow_sha256"],
        "workflow_run_id": trusted_event["workflow_run_id"],
        "workflow_run_attempt": trusted_event["workflow_run_attempt"],
        "event_projection_digest": trusted_event["event_projection_digest"],
        "consumption_generation": trusted_event["consumption_generation"],
        "check_identity": "ambitions-canon-authorization",
        "integration_id": "github-actions",
        "app_id": "15368",
        "approval_policy_id": "owner-gate",
        "approval_policy_revision": "1",
        "authenticated_principal": "owner:devan",
        "approved_scope": list(approved_scope),
        "one_time_use_nonce": one_time_use_nonce,
        "verification_epoch": trusted_event["verification_epoch"],
        "consumed": False,
        "expires_at_epoch": trusted_event.get(
            "expires_at_epoch", trusted_event["verification_epoch"] + 3600
        ),
        "revoked": False,
        "break_glass": False,
        "incident_id": None,
        "rollback_ref": None,
        "post_action_review_required": False,
    })


def validation(
    authorization_digest: str,
    repo: Path,
    base: str,
    head: str,
    intake_digest: str,
    trusted_bindings: dict[str, object],
    command_argv_digest: str,
    *,
    command_id: str = "canon-unit",
    proof_obligation_ids: list[str] | None = None,
    artifact_digest: str = SHA_B,
) -> dict[str, object]:
    return sign({
        "schema_version": 1,
        "attestation_id": "VALIDATION-24",
        "attestation_origin": "trusted-ci",
        "pull_request_number": 24,
        "task_id": "TASK-24",
        "intake_id": "INTAKE-24",
        "intake_digest": intake_digest,
        "policy_revision": trusted_bindings["policy_revision"],
        "authorization_digest": authorization_digest,
        "command_manifest_digest": trusted_bindings["command_manifest_sha256"],
        "workflow_path": ".github/workflows/canon-authorization.yml",
        "workflow_ref": "refs/heads/main",
        "workflow_digest": trusted_bindings["validation_workflow_sha256"],
        "command_id": command_id,
        "command_argv_digest": command_argv_digest,
        "check_identity": "ambitions-canon-authorization",
        "repository_id": "12345",
        "repository_full_name": "agentdevan/ambitions",
        "trusted_base_sha": base,
        "trusted_head_sha": head,
        "merge_base_sha": run(repo, "merge-base", base, head),
        "integration_id": "github-actions",
        "app_id": "15368",
        "exit_status": 0,
        "artifact_digest": artifact_digest,
        "proof_obligation_ids": proof_obligation_ids
        if proof_obligation_ids is not None
        else ["focused-tests", "offline-determinism"],
        "skipped": False,
        "skipped_reason": None,
        "status": "green",
        "claim_ceiling": "Governance Green for exact scope",
        "ci_owned": True,
    })


class AuthorizationSchemaTests(unittest.TestCase):
    def test_schemas_are_closed_and_intake_is_request_only(self) -> None:
        optional_fields = {
            "task-intake.schema.json": {
                "requested_authorization_mode",
                "requested_path_roots",
                "requested_max_changed_files",
                "requested_max_changed_bytes",
            },
            "trusted-event.schema.json": {"expires_at_epoch"},
        }
        for name in (
            "task-intake.schema.json",
            "task-authorization.schema.json",
            "trusted-event.schema.json",
            "approval-attestation.schema.json",
            "validation-attestation.schema.json",
        ):
            payload = json.loads((SCHEMAS / name).read_text(encoding="utf-8"))
            self.assertFalse(payload["additionalProperties"], name)
            self.assertEqual(payload["type"], "object", name)
            self.assertEqual(
                set(payload["properties"]) - set(payload["required"]),
                optional_fields.get(name, set()),
                name,
            )

        intake_schema = json.loads(
            (SCHEMAS / "task-intake.schema.json").read_text(encoding="utf-8")
        )
        allowed = set(intake_schema["properties"])
        self.assertEqual(
            allowed - set(intake_schema["required"]),
            {
                "requested_authorization_mode",
                "requested_path_roots",
                "requested_max_changed_files",
                "requested_max_changed_bytes",
            },
        )
        self.assertTrue(all(name.startswith("requested_") for name in allowed - {"schema_version", "intake_id", "task_id", "issue_reference"}))
        exact_file_forbidden = {
            item["required"][0]
            for item in intake_schema["allOf"][0]["else"]["not"]["anyOf"]
        }
        self.assertEqual(
            exact_file_forbidden,
            {
                "requested_path_roots",
                "requested_max_changed_files",
                "requested_max_changed_bytes",
            },
        )
        for forbidden in (
            "owner_approved",
            "computed_authorized_files",
            "validation_results",
            "proof_results",
            "break_glass",
            "merge_permission",
        ):
            self.assertNotIn(forbidden, allowed)

    def test_authorization_schema_separates_requested_and_computed_values(self) -> None:
        payload = json.loads(
            (SCHEMAS / "task-authorization.schema.json").read_text(encoding="utf-8")
        )
        properties = payload["properties"]
        for field in (
            "intake",
            "computed_authorized_files",
            "computed_required_checks",
            "computed_proof_obligations",
            "computed_claim_ceiling",
            "trusted_event_provenance",
            "trusted_bindings",
            "approval_attestation_digests",
            "tree_delta",
        ):
            self.assertIn(field, properties)
        record = properties["tree_delta"]["properties"]["records"]["items"]
        self.assertFalse(record["additionalProperties"])
        self.assertEqual(set(record["required"]), set(record["properties"]))

    def test_finalization_receipt_schema_is_embedded_closed_and_exact(self) -> None:
        payload = json.loads(
            (SCHEMAS / "task-authorization.schema.json").read_text(encoding="utf-8")
        )
        receipt = payload["$defs"]["taskFinalizationReceipt"]
        self.assertFalse(receipt["additionalProperties"])
        self.assertEqual(set(receipt["required"]), set(receipt["properties"]))
        self.assertEqual(receipt["properties"]["receipt_type"]["const"], "task-finalization")
        self.assertTrue(receipt["properties"]["exact_diff_authorized"]["const"])
        self.assertEqual(
            {
                condition["if"]["properties"]["mode"]["const"]:
                condition["then"]["properties"]["merge_authorized"]["const"]
                for condition in receipt["allOf"]
            },
            {"local-advisory": False, "ci-pr-range": True},
        )

    def test_intake_rejects_authority_bearing_fields(self) -> None:
        for field in (
            "owner_approved",
            "computed_authorized_files",
            "validation_results",
            "proof_results",
            "break_glass",
            "merge_permission",
        ):
            candidate = intake("keep.txt")
            candidate[field] = True
            with self.assertRaisesRegex(AuthorizationError, "AUTH_INTAKE_FIELDS"):
                validate_task_intake(candidate)


class DeterminismAndTreeDeltaTests(unittest.TestCase):
    def test_canonical_json_is_sorted_utf8_and_newline_terminated(self) -> None:
        self.assertEqual(
            canonical_json_bytes({"z": "é", "a": 1}),
            b'{"a":1,"z":"\xc3\xa9"}\n',
        )

    def test_atomic_writer_replaces_complete_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "nested" / "value.json"
            write_json_atomic(path, {"z": 2, "a": 1})
            self.assertEqual(path.read_bytes(), b'{"a":1,"z":2}\n')
            self.assertEqual(list(path.parent.glob(f".{path.name}.*")), [])

    def test_authorization_outputs_are_ignored_confined_atomic_and_no_follow(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q")
            (repo / ".gitignore").write_text(".codex/\n", encoding="utf-8")
            output = repo / ".codex/task-authorization/TASK-24.json"
            write_authorization_output(
                repo, output, {"z": 2, "a": 1}, kind="authorization"
            )
            self.assertEqual(output.read_bytes(), b'{"a":1,"z":2}\n')

            outside = repo / "outside"
            outside.mkdir()
            finalization_root = repo / ".codex/task-finalization"
            finalization_root.symlink_to(outside, target_is_directory=True)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_OUTPUT_PATH"):
                write_authorization_output(
                    repo,
                    finalization_root / "TASK-24.json",
                    {"safe": True},
                    kind="finalization",
                )
            self.assertEqual(list(outside.iterdir()), [])

    def test_tree_delta_preserves_raw_paths_modes_objects_and_opaque_blobs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            delta = canonical_tree_delta(repo, base, head)
            records = delta["records"]
            self.assertEqual(
                [record["path_raw_base64url"] for record in records],
                sorted(
                    [record["path_raw_base64url"] for record in records],
                    key=lambda value: base64.urlsafe_b64decode(value + "=" * (-len(value) % 4)),
                ),
            )
            by_display = {record["path_display_utf8"]: record for record in records}
            self.assertEqual(by_display["delete.txt"]["status"], "deleted")
            self.assertEqual(by_display["copy.txt"]["status"], "added")
            self.assertEqual(by_display["binary.bin"]["new_object_type"], "blob")
            self.assertEqual(by_display["binary.bin"]["new_blob_size"], 3)
            self.assertEqual(by_display["link"]["new_mode"], "120000")
            self.assertEqual(by_display["mode.txt"]["status"], "modified")
            self.assertNotEqual(by_display["mode.txt"]["old_mode"], by_display["mode.txt"]["new_mode"])
            raw = next(record for record in records if record["path_display_utf8"] is None)
            self.assertEqual(
                base64.urlsafe_b64decode(raw["path_raw_base64url"] + "=="),
                b"raw-\xff.txt",
            )
            self.assertEqual(
                delta["digest"],
                hashlib.sha256(canonical_json_bytes(records)).hexdigest(),
            )

    def test_tree_delta_supports_merge_commits_and_submodule_gitlinks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Test")
            run(repo, "config", "user.email", "canon@example.invalid")
            (repo / "base.txt").write_text("base\n", encoding="utf-8")
            run(repo, "add", "base.txt")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            (repo / "topic.txt").write_text("topic\n", encoding="utf-8")
            run(repo, "add", "topic.txt")
            run(repo, "commit", "-qm", "topic")
            run(repo, "checkout", "-q", "main")
            (repo / "main.txt").write_text("main\n", encoding="utf-8")
            run(repo, "add", "main.txt")
            run(repo, "update-index", "--add", "--cacheinfo", f"160000,{base},vendor/submodule")
            run(repo, "commit", "-qm", "main")
            run(repo, "merge", "--no-ff", "-qm", "merge", "topic")
            head = run(repo, "rev-parse", "HEAD")
            self.assertEqual(len(run(repo, "rev-list", "--parents", "-n", "1", head).split()), 3)

            delta = canonical_tree_delta(repo, base, head)
            by_display = {
                record["path_display_utf8"]: record for record in delta["records"]
            }
            self.assertEqual(by_display["vendor/submodule"]["new_mode"], "160000")
            self.assertEqual(by_display["vendor/submodule"]["new_object_type"], "commit")
            self.assertIsNone(by_display["vendor/submodule"]["new_blob_size"])
            self.assertEqual(by_display["main.txt"]["status"], "added")
            self.assertEqual(by_display["topic.txt"]["status"], "added")


class StartFinalizeTests(unittest.TestCase):
    def _root_delegation_repo(
        self,
        directory: str,
        changed_path: str,
        *,
        content: str = "repair\n",
        approval_required: bool = False,
        maximum_changed_files: int = 32,
        maximum_changed_bytes: int = 1024 * 1024,
    ) -> tuple[Path, str, str]:
        repo = Path(directory)
        run(repo, "init", "-q", "-b", "main")
        run(repo, "config", "user.name", "Canon Test")
        run(repo, "config", "user.email", "canon@example.invalid")
        (repo / "README.md").write_text("base\n", encoding="utf-8")
        write_trusted_state(
            repo,
            ["README.md"],
            authorized_path_roots=(
                "Native",
                "docs",
                "project.yml",
                "scripts",
                "src",
                "tests",
            ),
            protected_paths=("src/protected",),
            maximum_changed_files=maximum_changed_files,
            maximum_changed_bytes=maximum_changed_bytes,
            approval_required=approval_required,
        )
        run(repo, "add", "-A")
        run(repo, "commit", "-qm", "base")
        base = run(repo, "rev-parse", "HEAD")
        run(repo, "checkout", "-qb", "topic")
        target = repo / changed_path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        run(repo, "add", changed_path)
        run(repo, "commit", "-qm", "repair")
        return repo, base, run(repo, "rev-parse", "HEAD")

    def test_signed_path_root_delegation_captures_new_file_exactly(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base, head = self._root_delegation_repo(
                directory, "src/new.py"
            )
            intake_data = root_intake("src")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            trusted_event = event(repo, base, head)
            signed_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=trusted_event,
            )
            result = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=trusted_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(signed_approval,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(result["computed_authorized_files"], ["src/new.py"])
            self.assertEqual(
                result["intake"]["requested_authorization_mode"], "path-roots"
            )

    def test_path_root_delegation_rejects_outside_protected_and_over_budget(self) -> None:
        cases = (
            (
                "outside/new.py",
                "src",
                "AUTH_FILE_POLICY",
                1024 * 1024,
                "too-large\n",
            ),
            (
                "src/protected/key.py",
                "src",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "too-large\n",
            ),
            (
                "src/secrets.yml",
                "src",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "value: ordinary\n",
            ),
            (
                "Native/Networking/Configuration.swift",
                "Native",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "let productionToken = \"value\"\n",
            ),
            (
                "scripts/ship.py",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "requests.post(production_url)\n",
            ),
            (
                "scripts/urllib_ship.py",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "urllib.request.urlopen(production_url, data=payload)\n",
            ),
            (
                "scripts/cleanup.py",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "shutil.rmtree(target)\n",
            ),
            (
                "Native/Resources/client.der",
                "Native",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "certificate bytes\n",
            ),
            (
                "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift",
                "Native",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "struct EventKitOutbox {}\n",
            ),
            (
                "scripts/ios_distribution.p12.enc",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "encrypted credential bytes\n",
            ),
            (
                "scripts/.env",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "PASSWORD=hunter2\n",
            ),
            (
                "scripts/id_rsa",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "private key bytes\n",
            ),
            (
                "scripts/canon-signer.py",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "def sign(payload): ...\n",
            ),
            (
                "scripts/trust-anchor-rotation.py",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "anchor = 'replacement'\n",
            ),
            (
                "scripts/authorization-policy.py",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "allow = True\n",
            ),
            (
                "scripts/trust.anchor.py",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "anchor = 'replacement'\n",
            ),
            (
                "scripts/external mutation.py",
                "scripts",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "mutate_external_system()\n",
            ),
            (
                "Native/Resources/auth.plist",
                "Native",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "<key>Password</key><string>value</string>\n",
            ),
            (
                "scripts/path_cleanup.py",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "Path(target).unlink()\n",
            ),
            (
                "scripts/cloud_copy.sh",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "aws s3 cp artifact s3://bucket/object\n",
            ),
            (
                "Native/Networking/Write.swift",
                "Native",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                'request.httpMethod = "POST"\nURLSession.shared.dataTask(with: request)\n',
            ),
            (
                "scripts/ship.js",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                'fetch(url, { method: "POST", body: payload })\n',
            ),
            (
                "scripts/quoted_cloud_copy.py",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                'subprocess.run(["aws", "s3", "cp", artifact, destination])\n',
            ),
            (
                "scripts/find_cleanup.sh",
                "scripts",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                'find build -type f -delete\n',
            ),
            (
                "project.yml",
                "project.yml",
                "AUTH_APPROVAL_MISSING",
                1024 * 1024,
                "CODE_SIGN_IDENTITY: iPhone Distribution\n",
            ),
            (
                "docs/foo/release/notes.md",
                "docs",
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                1024 * 1024,
                "ordinary-looking notes\n",
            ),
            (
                "src/large.py",
                "src",
                "AUTH_DELEGATION_BUDGET",
                4,
                "too-large\n",
            ),
        )
        for changed_path, root, code, byte_budget, content in cases:
            with self.subTest(changed_path=changed_path), tempfile.TemporaryDirectory() as directory:
                repo, base, head = self._root_delegation_repo(
                    directory,
                    changed_path,
                    content=content,
                    maximum_changed_bytes=byte_budget,
                )
                intake_data = root_intake(
                    root, maximum_changed_bytes=byte_budget
                )
                trusted_bindings, trusted_policy = trusted_context(
                    repo, base, intake_data
                )
                with self.assertRaisesRegex(AuthorizationError, code):
                    task_start(
                        repo_root=repo,
                        mode="ci-pr-range",
                        intake_data=intake_data,
                        trusted_event_data=event(repo, base, head),
                        trusted_bindings=trusted_bindings,
                        policy_data=trusted_policy,
                        approval_attestations=(),
                        verification_epoch=1_900_000_000,
                    )

    def test_path_root_delegation_rejects_noncanonical_utf8_tree_path(self) -> None:
        delta = {
            "records": [
                {
                    "path_display_utf8": "Native/..",
                    "path_raw_base64url": "TmF0aXZlLy4u",
                    "status": "added",
                    "old_mode": None,
                    "old_object_type": None,
                    "old_object_id": None,
                    "old_blob_size": None,
                    "new_mode": "160000",
                    "new_object_type": "commit",
                    "new_object_id": "a" * 40,
                    "new_blob_size": None,
                }
            ]
        }
        with tempfile.TemporaryDirectory() as directory, self.assertRaisesRegex(
            AuthorizationError, "AUTH_FILE_POLICY"
        ):
            authorization_module._validate_path_root_delta(
                Path(directory),
                delta,
                selected_roots=("Native",),
                protected_paths=(),
                maximum_changed_files=32,
                maximum_changed_bytes=1024 * 1024,
            )

        indirect_delta = {
            "records": [
                {
                    "path_display_utf8": "scripts/helper",
                    "path_raw_base64url": "c2NyaXB0cy9oZWxwZXI",
                    "status": "added",
                    "old_mode": None,
                    "old_object_type": None,
                    "old_object_id": None,
                    "old_blob_size": None,
                    "new_mode": "120000",
                    "new_object_type": "blob",
                    "new_object_id": "b" * 40,
                    "new_blob_size": 48,
                }
            ]
        }
        with tempfile.TemporaryDirectory() as directory, self.assertRaisesRegex(
            AuthorizationError, "AUTH_BOUNDARY_APPROVAL_REQUIRED"
        ):
            authorization_module._validate_path_root_delta(
                Path(directory),
                indirect_delta,
                selected_roots=("scripts",),
                protected_paths=(),
                maximum_changed_files=32,
                maximum_changed_bytes=1024 * 1024,
            )

    def test_path_root_delegation_rejects_protected_requested_root_before_delta(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base, head = self._root_delegation_repo(
                directory, "src/new.py"
            )
            intake_data = root_intake("src/protected")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            with self.assertRaisesRegex(
                AuthorizationError,
                "requested root crosses a renewed-approval boundary",
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_path_root_delegation_rejects_unsigned_event(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base, head = self._root_delegation_repo(
                directory, "src/new.py"
            )
            intake_data = root_intake("src")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            unsigned_event = event(repo, base, head)
            unsigned_event["event_attestation_origin"] = "local-advisory"
            unsigned_event["workflow_run_id"] = 0
            unsigned_event["workflow_run_attempt"] = 0
            for field in (
                "trust_anchor_id",
                "trust_anchor_sha256",
                "signature_algorithm",
                "signature_base64url",
            ):
                unsigned_event[field] = None
            unsigned_event["event_projection_digest"] = (
                authorization_module.trusted_event_projection_digest(unsigned_event)
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_SIGNATURE"):
                task_start(
                    repo_root=repo,
                    mode="local-advisory",
                    intake_data=intake_data,
                    trusted_event_data=unsigned_event,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_path_root_delegation_allows_contextual_design_token(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base, head = self._root_delegation_repo(
                directory,
                "Native/Design/Spacing.swift",
                content="let spacingToken = 8\n",
            )
            intake_data = root_intake("Native")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            trusted_event = event(repo, base, head)
            signed_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=trusted_event,
            )
            result = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=trusted_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(signed_approval,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(
                result["computed_authorized_files"],
                ["Native/Design/Spacing.swift"],
            )

    def test_path_root_delegation_rejects_replay_expiry_and_hard_boundaries(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base, head = self._root_delegation_repo(
                directory,
                "src/new.py",
                approval_required=True,
            )
            intake_data = root_intake("src")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            first_event = event(repo, base, head, workflow_run_id=24001)
            signed_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=first_event,
            )
            first = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=first_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(signed_approval,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(first["computed_authorized_files"], ["src/new.py"])
            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_MISMATCH"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(
                        repo, base, head, workflow_run_id=24002
                    ),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(signed_approval,),
                    verification_epoch=1_900_000_000,
                )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_EXPIRED"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                    evaluation_epoch=1_900_003_600,
                )
            with mock.patch.object(
                authorization_module.time,
                "time",
                return_value=1_900_003_600,
            ), self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_EXPIRED"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )
            release_intake = root_intake("src")
            release_intake["requested_scope"] = ["release"]
            release_bindings, release_policy = trusted_context(
                repo, base, release_intake
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_BOUNDARY_APPROVAL_REQUIRED"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=release_intake,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=release_bindings,
                    policy_data=release_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )
            for dotted_boundary in ("authority.amendment", "trust.anchor"):
                with self.subTest(dotted_boundary=dotted_boundary):
                    dotted_intake = root_intake("src")
                    dotted_intake["requested_scope"] = [dotted_boundary]
                    dotted_bindings, dotted_policy = trusted_context(
                        repo, base, dotted_intake
                    )
                    with self.assertRaisesRegex(
                        AuthorizationError, "AUTH_BOUNDARY_APPROVAL_REQUIRED"
                    ):
                        task_start(
                            repo_root=repo,
                            mode="ci-pr-range",
                            intake_data=dotted_intake,
                            trusted_event_data=event(repo, base, head),
                            trusted_bindings=dotted_bindings,
                            policy_data=dotted_policy,
                            approval_attestations=(),
                            verification_epoch=1_900_000_000,
                        )
            unknown_scope_intake = root_intake("src")
            unknown_scope_intake["requested_scope"] = ["privacy-critical"]
            unknown_bindings, unknown_policy = trusted_context(
                repo, base, unknown_scope_intake
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_SCOPE_POLICY"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=unknown_scope_intake,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=unknown_bindings,
                    policy_data=unknown_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )
            incoherent_intake = root_intake("src")
            incoherent_intake["requested_requirement_ids"] = ["RELEASE-003"]
            incoherent_bindings, incoherent_policy = trusted_context(
                repo, base, incoherent_intake
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_REQUIREMENT_POLICY"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=incoherent_intake,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=incoherent_bindings,
                    policy_data=incoherent_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Test")
            run(repo, "config", "user.email", "canon@example.invalid")
            for index in range(9):
                target = repo / "src" / f"item-{index}.txt"
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("base\n", encoding="utf-8")
            write_trusted_state(
                repo,
                ["README.md"],
                authorized_path_roots=("src",),
            )
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            for target in (repo / "src").iterdir():
                target.unlink()
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "mass delete")
            head = run(repo, "rev-parse", "HEAD")
            intake_data = root_intake("src")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_BOUNDARY_APPROVAL_REQUIRED"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_path_root_finalization_records_each_scope_expansion(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Test")
            run(repo, "config", "user.email", "canon@example.invalid")
            (repo / "README.md").write_text("base\n", encoding="utf-8")
            write_trusted_state(
                repo,
                ["README.md"],
                authorized_path_roots=("src", "tests"),
                approval_required=True,
            )
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            run(repo, "commit", "--allow-empty", "-qm", "delegation seed")
            delegation_head = run(repo, "rev-parse", "HEAD")
            intake_data = root_intake("src", "tests")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            delegation_event = event(
                repo,
                base,
                delegation_head,
                workflow_run_id=24001,
            )
            delegation_approval = approval(
                repo,
                base,
                delegation_head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=delegation_event,
                one_time_use_nonce="nonce-delegation-start",
            )
            delegation_start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=delegation_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(delegation_approval,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(delegation_start["computed_authorized_files"], [])
            for path in ("src/new.py", "tests/test_new.py"):
                target = repo / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text("repair\n", encoding="utf-8")
                run(repo, "add", path)
                run(repo, "commit", "-qm", f"add {path}")
            head = run(repo, "rev-parse", "HEAD")
            trusted_event = event(
                repo,
                base,
                head,
                verification_epoch=1_900_000_100,
                workflow_run_id=24002,
            )
            final_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=trusted_event,
                one_time_use_nonce="nonce-finalization",
            )
            start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=trusted_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(final_approval,),
                verification_epoch=1_900_000_100,
            )
            authorization_digest = hashlib.sha256(
                canonical_json_bytes(start)
            ).hexdigest()
            validations = (
                validation(
                    authorization_digest,
                    repo,
                    base,
                    head,
                    str(start["intake_digest"]),
                    trusted_bindings,
                    str(start["computed_command_digests"]["canon-unit"]),
                ),
                validation(
                    authorization_digest,
                    repo,
                    base,
                    head,
                    str(start["intake_digest"]),
                    trusted_bindings,
                    str(
                        start["computed_command_digests"][
                            "independent-review-evidence"
                        ]
                    ),
                    command_id="independent-review-evidence",
                    proof_obligation_ids=["independent-review"],
                    artifact_digest="c" * 64,
                ),
            )
            receipt = task_finalize(
                repo_root=repo,
                authorization=start,
                intake_data=intake_data,
                trusted_event_data=trusted_event,
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(final_approval,),
                validation_attestations=validations,
                verification_epoch=1_900_000_100,
                evaluation_epoch=1_900_000_100,
                delegation_start_authorization=delegation_start,
                delegation_start_event=delegation_event,
                delegation_start_approval=delegation_approval,
            )
            records = receipt["scope_expansion_records"]
            self.assertEqual(len(records), 3)
            self.assertEqual([record["sequence"] for record in records], [1, 2, 3])
            self.assertEqual(records[-1]["changed_files"], [
                "src/new.py",
                "tests/test_new.py",
            ])
            self.assertEqual(
                records[-1]["tree_delta_digest"],
                receipt["final_tree_delta"]["digest"],
            )
            self.assertEqual(
                receipt["delegation_start_authorization_digest"],
                hashlib.sha256(canonical_json_bytes(delegation_start)).hexdigest(),
            )
            tampered_receipt = dict(receipt)
            tampered_receipt["exact_changed_files"] = []
            with self.assertRaisesRegex(
                AuthorizationError, "exact changed files do not match"
            ):
                authorization_module.validate_task_finalization_receipt(
                    tampered_receipt
                )

            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_DELEGATION_START_MISSING"
            ):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=intake_data,
                    trusted_event_data=trusted_event,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(final_approval,),
                    validation_attestations=validations,
                    verification_epoch=1_900_000_100,
                    evaluation_epoch=1_900_000_100,
                )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_EXPIRED"):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=intake_data,
                    trusted_event_data=trusted_event,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(final_approval,),
                    validation_attestations=validations,
                    verification_epoch=1_900_000_100,
                    evaluation_epoch=1_900_003_600,
                    delegation_start_authorization=delegation_start,
                    delegation_start_event=delegation_event,
                    delegation_start_approval=delegation_approval,
                )
            with mock.patch.object(
                authorization_module.time,
                "time",
                return_value=1_900_003_600,
            ), self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_EXPIRED"):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=intake_data,
                    trusted_event_data=trusted_event,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(final_approval,),
                    validation_attestations=validations,
                    verification_epoch=1_900_000_100,
                    delegation_start_authorization=delegation_start,
                    delegation_start_event=delegation_event,
                    delegation_start_approval=delegation_approval,
                )

    def test_start_is_deterministic_and_computes_exact_policy_bounded_files(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = tuple(
                record["path_display_utf8"]
                for record in canonical_tree_delta(repo, base, head)["records"]
                if record["path_display_utf8"] is not None
            )
            raw_encoded = next(
                record["path_raw_base64url"]
                for record in canonical_tree_delta(repo, base, head)["records"]
                if record["path_display_utf8"] is None
            )
            requested = (*changed, f"raw-base64url:{raw_encoded}")
            intake_data = intake(*requested)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            arguments = dict(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            first = task_start(**arguments)
            second = task_start(**arguments)
            self.assertEqual(canonical_json_bytes(first), canonical_json_bytes(second))
            self.assertEqual(first["computed_authorized_files"], sorted(requested))
            self.assertFalse(first["merge_authorized"])
            self.assertNotIn("timestamp", canonical_json_bytes(first).decode())

    def test_start_fails_on_unrequested_or_policy_disallowed_tree_change(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            intake_data = intake("keep.txt")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_UNREQUESTED"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_policy_prefix_does_not_authorize_a_lexical_sibling(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Test")
            run(repo, "config", "user.email", "canon@example.invalid")
            (repo / "base.txt").write_text("base\n", encoding="utf-8")
            write_trusted_state(repo, ["docs/canon/allowed.txt"])
            run(repo, "add", "base.txt")
            run(repo, "add", "docs/canon")
            run(repo, "add", ".agents")
            run(repo, "add", ".github")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            (repo / "docs/canonical.txt").write_text("not canon\n", encoding="utf-8")
            run(repo, "add", "docs/canonical.txt")
            run(repo, "commit", "-qm", "sibling")
            head = run(repo, "rev-parse", "HEAD")
            intake_data = intake("docs/canonical.txt")
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_POLICY"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_start_rejects_repository_and_merge_base_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = [
                record["path_display_utf8"] or f'raw-base64url:{record["path_raw_base64url"]}'
                for record in canonical_tree_delta(repo, base, head)["records"]
            ]
            intake_data = intake(*changed)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            for field, value, code in (
                ("repository_full_name", "other/repo", "AUTH_REPOSITORY_MISMATCH"),
                ("merge_base_sha", head, "AUTH_MERGE_BASE_MISMATCH"),
                ("trusted_head_sha", "0" * 40, "AUTH_GIT_OBJECT_MISSING"),
                ("trusted_head_sha", "--help", "AUTH_EVENT_FIELDS"),
            ):
                bad_event = event(repo, base, head)
                bad_event[field] = value
                bad_event = refresh_event_digest(bad_event)
                with self.assertRaisesRegex(AuthorizationError, code):
                    task_start(
                        repo_root=repo,
                        mode="ci-pr-range",
                        intake_data=intake_data,
                        trusted_event_data=bad_event,
                        trusted_bindings=trusted_bindings,
                        policy_data=trusted_policy,
                        approval_attestations=(),
                        verification_epoch=1_900_000_000,
                    )

    def test_start_rejects_trusted_base_ref_movement(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = [
                record["path_display_utf8"] or f'raw-base64url:{record["path_raw_base64url"]}'
                for record in canonical_tree_delta(repo, base, head)["records"]
            ]
            intake_data = intake(*changed)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            run(repo, "branch", "-f", "main", head)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_BASE_MOVED"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_finalize_rejects_stale_bindings_and_exact_delta_drift(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = [
                record["path_display_utf8"] or f'raw-base64url:{record["path_raw_base64url"]}'
                for record in canonical_tree_delta(repo, base, head)["records"]
            ]
            intake_data = intake(*changed)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            stale = dict(trusted_bindings)
            stale["proof_state_sha256"] = SHA_B
            with self.assertRaisesRegex(AuthorizationError, "AUTH_BINDING_STALE"):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=stale,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    validation_attestations=(),
                    verification_epoch=1_900_000_000,
                )

            (repo / "late.txt").write_text("late\n", encoding="utf-8")
            run(repo, "add", "late.txt")
            run(repo, "commit", "-qm", "late")
            moved_event = event(repo, base, run(repo, "rev-parse", "HEAD"))
            with self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_STALE"):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=intake_data,
                    trusted_event_data=moved_event,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    validation_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_finalize_requires_matching_green_ci_owned_validation(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = [
                record["path_display_utf8"] or f'raw-base64url:{record["path_raw_base64url"]}'
                for record in canonical_tree_delta(repo, base, head)["records"]
            ]
            intake_data = intake(*changed)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            authorization_digest = hashlib.sha256(canonical_json_bytes(start)).hexdigest()
            good = validation(
                authorization_digest,
                repo,
                base,
                head,
                str(start["intake_digest"]),
                trusted_bindings,
                str(start["computed_command_digests"]["canon-unit"]),
            )
            independent = validation(
                authorization_digest,
                repo,
                base,
                head,
                str(start["intake_digest"]),
                trusted_bindings,
                str(
                    start["computed_command_digests"][
                        "independent-review-evidence"
                    ]
                ),
                command_id="independent-review-evidence",
                proof_obligation_ids=["independent-review"],
                artifact_digest="c" * 64,
            )
            result = task_finalize(
                repo_root=repo,
                authorization=start,
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                validation_attestations=(good, independent),
                verification_epoch=1_900_000_000,
            )
            self.assertTrue(result["exact_diff_authorized"])
            self.assertTrue(result["merge_authorized"])

            for field, value, code in (
                ("ci_owned", False, "AUTH_VALIDATION_UNTRUSTED"),
                ("status", "red", "AUTH_VALIDATION_NOT_GREEN"),
                ("skipped", True, "AUTH_VALIDATION_SKIPPED"),
                ("trusted_head_sha", base, "AUTH_VALIDATION_MISMATCH"),
                ("command_manifest_digest", SHA_B, "AUTH_VALIDATION_MISMATCH"),
            ):
                bad = dict(good)
                bad[field] = value
                if field == "skipped":
                    bad["skipped_reason"] = "not run"
                bad = resign(bad)
                with self.assertRaisesRegex(AuthorizationError, code):
                    task_finalize(
                        repo_root=repo,
                        authorization=start,
                        intake_data=intake_data,
                        trusted_event_data=event(repo, base, head),
                        trusted_bindings=trusted_bindings,
                        policy_data=trusted_policy,
                        approval_attestations=(),
                        validation_attestations=(bad, independent),
                        verification_epoch=1_900_000_000,
                    )

    def test_local_finalize_is_advisory_and_does_not_authorize_merge(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            changed = [
                record["path_display_utf8"] or f'raw-base64url:{record["path_raw_base64url"]}'
                for record in canonical_tree_delta(repo, base, head)["records"]
            ]
            intake_data = intake(*changed)
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            start = task_start(
                repo_root=repo,
                mode="local-advisory",
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            (repo / "keep.txt").write_text("local-final\n", encoding="utf-8")
            result = task_finalize(
                repo_root=repo,
                authorization=start,
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(),
                validation_attestations=(),
                verification_epoch=1_900_000_000,
            )
            self.assertTrue(result["exact_diff_authorized"])
            self.assertFalse(result["merge_authorized"])
            self.assertIn("keep.txt", result["exact_changed_files"])
            self.assertIn(
                "raw-base64url:cmF3Lf8udHh0", result["exact_changed_files"]
            )

    def test_attestation_validation_fails_closed_for_revocation_reuse_and_expiry(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            normalized_intake = validate_task_intake(intake("keep.txt"))
            intake_digest = hashlib.sha256(canonical_json_bytes(normalized_intake)).hexdigest()
            trusted_bindings, _trusted_policy = trusted_context(
                repo, base, normalized_intake
            )
            good = approval(repo, base, head, intake_digest, trusted_bindings)
            self.assertEqual(
                len(
                    approval_attestation_digest(
                        good,
                        verification_epoch=1_900_000_000,
                        trust_anchors=anchors(),
                    )
                ),
                64,
            )
            for field, value, code in (
                ("revoked", True, "AUTH_APPROVAL_REVOKED"),
                ("consumed", True, "AUTH_APPROVAL_REUSED"),
                ("expires_at_epoch", 1_800_000_000, "AUTH_APPROVAL_EXPIRED"),
            ):
                bad = dict(good)
                bad[field] = value
                with self.assertRaisesRegex(AuthorizationError, code):
                    approval_attestation_digest(
                        bad,
                        verification_epoch=1_900_000_000,
                        trust_anchors=anchors(),
                    )

            command_digest = hashlib.sha256(
                canonical_json_bytes(["python3", "-m", "unittest"])
            ).hexdigest()
            good_validation = validation(
                SHA_A,
                repo,
                base,
                head,
                intake_digest,
                trusted_bindings,
                command_digest,
            )
            self.assertEqual(
                len(
                    validation_attestation_digest(
                        good_validation, trust_anchors=anchors()
                    )
                ),
                64,
            )



def requested_delta(repo: Path, base: str, head: str) -> tuple[str, ...]:
    return tuple(
        record["path_display_utf8"]
        or f'raw-base64url:{record["path_raw_base64url"]}'
        for record in canonical_tree_delta(repo, base, head)["records"]
    )


def start_arguments(
    repo: Path,
    base: str,
    head: str,
    *,
    approvals: tuple[dict[str, object], ...] = (),
    verification_epoch: int = 1_900_000_000,
    mode: str = "ci-pr-range",
) -> tuple[dict[str, object], dict[str, object], dict[str, object]]:
    intake_data = intake(*requested_delta(repo, base, head))
    trusted_bindings, trusted_policy = trusted_context(repo, base, intake_data)
    result = task_start(
        repo_root=repo,
        mode=mode,
        intake_data=intake_data,
        trusted_event_data=event(
            repo, base, head, verification_epoch=verification_epoch
        ),
        trusted_bindings=trusted_bindings,
        policy_data=trusted_policy,
        approval_attestations=approvals,
        verification_epoch=verification_epoch,
    )
    return result, trusted_bindings, trusted_policy


class ApprovalFreshnessAndRepositoryTests(unittest.TestCase):
    def test_signed_approval_cannot_replay_across_run_attempt_or_generation(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo, approval_required=True)
            intake_data = intake(*requested_delta(repo, base, head))
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            first_event = event(
                repo,
                base,
                head,
                workflow_run_id=24001,
                workflow_run_attempt=1,
                consumption_generation=1,
            )
            signed_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
                event_data=first_event,
            )
            arguments = {
                "repo_root": repo,
                "mode": "ci-pr-range",
                "intake_data": intake_data,
                "trusted_bindings": trusted_bindings,
                "policy_data": trusted_policy,
                "approval_attestations": (signed_approval,),
                "verification_epoch": 1_900_000_000,
            }
            first = task_start(
                trusted_event_data=first_event,
                **arguments,
            )
            self.assertEqual(
                first,
                task_start(trusted_event_data=first_event, **arguments),
            )

            for replay_event in (
                event(
                    repo,
                    base,
                    head,
                    workflow_run_id=24002,
                    workflow_run_attempt=1,
                ),
                event(
                    repo,
                    base,
                    head,
                    workflow_run_id=24001,
                    workflow_run_attempt=2,
                ),
            ):
                with self.assertRaisesRegex(
                    AuthorizationError, "AUTH_APPROVAL_MISMATCH"
                ):
                    task_start(
                        trusted_event_data=replay_event,
                        **arguments,
                    )

            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_NONCE_GENERATION_STALE"
            ):
                task_start(
                    trusted_event_data=event(
                        repo,
                        base,
                        head,
                        workflow_run_id=24001,
                        workflow_run_attempt=1,
                        consumption_generation=2,
                    ),
                    **arguments,
                )
            tampered_event = dict(first_event)
            tampered_event["workflow_run_attempt"] = 2
            projection = {
                key: value
                for key, value in tampered_event.items()
                if key
                not in {
                    "event_projection_digest",
                    "trust_anchor_id",
                    "trust_anchor_sha256",
                    "signature_algorithm",
                    "signature_base64url",
                }
            }
            tampered_event["event_projection_digest"] = hashlib.sha256(
                canonical_json_bytes(projection)
            ).hexdigest()
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_EVENT_SIGNATURE"
            ):
                task_start(
                    trusted_event_data=tampered_event,
                    **arguments,
                )

    def test_zero_epoch_and_base_identity_mismatch_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            intake_data = intake(*requested_delta(repo, base, head))
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_VERIFICATION_EPOCH"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(
                        repo, base, head, verification_epoch=0
                    ),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=0,
                )

            wrong_repo = event(repo, base, head)
            wrong_repo["repository_id"] = "attacker-repository"
            wrong_repo = refresh_event_digest(wrong_repo)
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_REPOSITORY_MISMATCH"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=wrong_repo,
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_approval_policy_principal_break_glass_and_nonce_replay_are_bound(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo, approval_required=True)
            intake_data = intake(*requested_delta(repo, base, head))
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            intake_digest = hashlib.sha256(
                canonical_json_bytes(intake_data)
            ).hexdigest()
            good = approval(
                repo, base, head, intake_digest, trusted_bindings
            )
            start = task_start(
                repo_root=repo,
                mode="local-advisory",
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(good,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(
                [item["nonce"] for item in start["approval_nonce_consumptions"]],
                ["nonce-24"],
            )
            receipt = task_finalize(
                repo_root=repo,
                authorization=start,
                intake_data=intake_data,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=trusted_bindings,
                policy_data=trusted_policy,
                approval_attestations=(good,),
                validation_attestations=(),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(
                receipt["approval_nonce_consumptions"],
                start["approval_nonce_consumptions"],
            )

            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_REUSED"):
                task_start(
                    repo_root=repo,
                    mode="local-advisory",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(good, good),
                    verification_epoch=1_900_000_000,
                )

            for field, value, code in (
                ("authenticated_principal", "owner:attacker", "AUTH_APPROVAL_POLICY"),
                ("approval_policy_id", "caller-policy", "AUTH_APPROVAL_POLICY"),
            ):
                candidate = dict(good)
                candidate[field] = value
                with self.assertRaisesRegex(AuthorizationError, code):
                    task_start(
                        repo_root=repo,
                        mode="local-advisory",
                        intake_data=intake_data,
                        trusted_event_data=event(repo, base, head),
                        trusted_bindings=trusted_bindings,
                        policy_data=trusted_policy,
                        approval_attestations=(resign(candidate),),
                        verification_epoch=1_900_000_000,
                    )

            break_glass = dict(good)
            break_glass.update(
                {
                    "break_glass": True,
                    "incident_id": "INC-24",
                    "rollback_ref": "refs/tags/task24-rollback",
                    "post_action_review_required": True,
                }
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_BREAK_GLASS_FORBIDDEN"
            ):
                task_start(
                    repo_root=repo,
                    mode="local-advisory",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(resign(break_glass),),
                    verification_epoch=1_900_000_000,
                )

        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(
                repo,
                approval_required=True,
                consumed_nonces=("nonce-24",),
            )
            intake_data = intake(*requested_delta(repo, base, head))
            trusted_bindings, trusted_policy = trusted_context(
                repo, base, intake_data
            )
            consumed = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(intake_data)).hexdigest(),
                trusted_bindings,
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_REUSED"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(consumed,),
                    verification_epoch=1_900_000_000,
                )


class SkillAndProofBindingTests(unittest.TestCase):
    def test_invalid_base_skill_registry_and_unknown_adapter_fail_start(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, _head = init_repo(repo)
            run(repo, "checkout", "-q", "main")
            registry = repo / "docs/canon/references/skill-dependencies.json"
            registry.write_text(
                json.dumps({"skills": []}, sort_keys=True) + "\n",
                encoding="utf-8",
            )
            run(repo, "add", registry.relative_to(repo).as_posix())
            run(repo, "commit", "-qm", "invalid registry")
            invalid_base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "invalid-topic")
            (repo / "keep.txt").write_text("invalid-head\n", encoding="utf-8")
            run(repo, "add", "keep.txt")
            run(repo, "commit", "-qm", "invalid head")
            invalid_head = run(repo, "rev-parse", "HEAD")
            intake_data = intake("keep.txt")
            policy = load_base_policy(repo, invalid_base)
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_SKILL_CONFORMANCE"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(
                        repo, invalid_base, invalid_head
                    ),
                    trusted_bindings={},
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            _base, _head = init_repo(repo)
            run(repo, "checkout", "-q", "main")
            undeclared = repo / ".agents/skills/undeclared/SKILL.md"
            undeclared.parent.mkdir(parents=True)
            undeclared.write_text("# undeclared\n", encoding="utf-8")
            run(repo, "add", undeclared.relative_to(repo).as_posix())
            run(repo, "commit", "-qm", "undeclared skill")
            invalid_base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "undeclared-topic")
            (repo / "keep.txt").write_text("undeclared-head\n", encoding="utf-8")
            run(repo, "add", "keep.txt")
            run(repo, "commit", "-qm", "undeclared head")
            invalid_head = run(repo, "rev-parse", "HEAD")
            intake_data = intake("keep.txt")
            policy = load_base_policy(repo, invalid_base)
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_SKILL_CONFORMANCE"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=intake_data,
                    trusted_event_data=event(
                        repo, invalid_base, invalid_head
                    ),
                    trusted_bindings={},
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            intake_data = intake(*requested_delta(repo, base, head))
            intake_data["requested_skill_adapters"] = ["undeclared-adapter"]
            policy = load_base_policy(repo, base)
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_SKILL_ADAPTER_UNKNOWN"
            ):
                load_trusted_bindings(repo, base, intake_data, policy)

    def test_proof_obligations_require_complete_attested_artifact_coverage(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            start, trusted_bindings, trusted_policy = start_arguments(
                repo, base, head
            )
            auth_digest = hashlib.sha256(canonical_json_bytes(start)).hexdigest()
            evidence = validation(
                auth_digest,
                repo,
                base,
                head,
                str(start["intake_digest"]),
                trusted_bindings,
                str(start["computed_command_digests"]["canon-unit"]),
            )
            incomplete = dict(evidence)
            incomplete["proof_obligation_ids"] = ["focused-tests"]
            independent = validation(
                auth_digest,
                repo,
                base,
                head,
                str(start["intake_digest"]),
                trusted_bindings,
                str(
                    start["computed_command_digests"][
                        "independent-review-evidence"
                    ]
                ),
                command_id="independent-review-evidence",
                proof_obligation_ids=["independent-review"],
                artifact_digest="c" * 64,
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_PROOF_EVIDENCE_MISMATCH"
            ):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=start["intake"],
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    validation_attestations=(resign(incomplete), independent),
                    verification_epoch=1_900_000_000,
                )


class ClosedContractAndCliTests(unittest.TestCase):
    def test_unknown_envelope_local_state_and_receipt_fields_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            start, trusted_bindings, trusted_policy = start_arguments(
                repo, base, head, mode="local-advisory"
            )
            unknown_envelope = dict(start)
            unknown_envelope["caller_authority"] = True
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_ENVELOPE_FIELDS"
            ):
                task_finalize(
                    repo_root=repo,
                    authorization=unknown_envelope,
                    intake_data=start["intake"],
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    validation_attestations=(),
                    verification_epoch=1_900_000_000,
                )

            unknown_local = dict(start)
            local_state = dict(start["local_state"])
            local_state["caller_authority"] = True
            unknown_local["local_state"] = local_state
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_LOCAL_STATE_FIELDS"
            ):
                task_finalize(
                    repo_root=repo,
                    authorization=unknown_local,
                    intake_data=start["intake"],
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=trusted_bindings,
                    policy_data=trusted_policy,
                    approval_attestations=(),
                    validation_attestations=(),
                    verification_epoch=1_900_000_000,
                )

        validator = getattr(
            authorization_module, "validate_task_finalization_receipt", None
        )
        self.assertIsNotNone(validator)
        with self.assertRaisesRegex(AuthorizationError, "AUTH_RECEIPT_FIELDS"):
            validator({"schema_version": 1, "caller_authority": True})

    def test_finalize_cli_has_no_redundant_mode(self) -> None:
        completed = subprocess.run(
            [
                sys.executable,
                "scripts/ambitions-canon.py",
                "task",
                "finalize",
                "--help",
            ],
            cwd=ROOT,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout)
        self.assertNotIn("--mode", completed.stdout)



def changed_paths(repo: Path, base: str, head: str) -> tuple[str, ...]:
    return tuple(
        record["path_display_utf8"]
        or f'raw-base64url:{record["path_raw_base64url"]}'
        for record in canonical_tree_delta(repo, base, head)["records"]
    )


class LocalUntrackedStateTests(unittest.TestCase):
    def _repo(self, directory: str) -> tuple[Path, str]:
        repo = Path(directory)
        run(repo, "init", "-q", "-b", "main")
        run(repo, "config", "user.name", "Local State Test")
        run(repo, "config", "user.email", "local-state@example.invalid")
        (repo / "keep.txt").write_text("base\n", encoding="utf-8")
        write_trusted_state(repo, ["new.txt"])
        run(repo, "add", "-A")
        run(repo, "commit", "-qm", "trusted base")
        return repo, run(repo, "rev-parse", "HEAD")

    def _context(
        self, repo: Path, base: str
    ) -> tuple[dict[str, object], dict[str, object], dict[str, object]]:
        intake_data = intake("new.txt")
        bindings, policy = trusted_context(repo, base, intake_data)
        return intake_data, bindings, policy

    def test_requested_untracked_path_is_bound_at_start_and_finalize_without_index_mutation(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base = self._repo(directory)
            (repo / "new.txt").write_text("start\n", encoding="utf-8")
            intake_data, bindings, policy = self._context(repo, base)
            event_data = event(repo, base, base)
            index_before = run(repo, "write-tree")
            started = task_start(
                repo_root=repo,
                mode="local-advisory",
                intake_data=intake_data,
                trusted_event_data=event_data,
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(run(repo, "write-tree"), index_before)
            self.assertEqual(
                [
                    record["path_display_utf8"]
                    for record in started["tree_delta"]["records"]
                ],
                ["new.txt"],
            )
            (repo / "new.txt").write_text("final\n", encoding="utf-8")
            receipt = task_finalize(
                repo_root=repo,
                authorization=started,
                intake_data=intake_data,
                trusted_event_data=event_data,
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                validation_attestations=(),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(receipt["exact_changed_files"], ["new.txt"])
            self.assertEqual(run(repo, "write-tree"), index_before)

    def test_unrequested_untracked_path_fails_start_and_finalize(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo, base = self._repo(directory)
            (repo / "new.txt").write_text("requested\n", encoding="utf-8")
            intake_data, bindings, policy = self._context(repo, base)
            event_data = event(repo, base, base)
            (repo / "surprise.txt").write_text("unrequested\n", encoding="utf-8")
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_UNREQUESTED"):
                task_start(
                    repo_root=repo,
                    mode="local-advisory",
                    intake_data=intake_data,
                    trusted_event_data=event_data,
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )
            (repo / "surprise.txt").unlink()
            started = task_start(
                repo_root=repo,
                mode="local-advisory",
                intake_data=intake_data,
                trusted_event_data=event_data,
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            (repo / "surprise.txt").write_text("late\n", encoding="utf-8")
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_UNREQUESTED"):
                task_finalize(
                    repo_root=repo,
                    authorization=started,
                    intake_data=intake_data,
                    trusted_event_data=event_data,
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    validation_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_untracked_snapshot_rejects_count_size_and_symlink_boundaries(
        self,
    ) -> None:
        cases = (
            ("count", "_MAX_LOCAL_UNTRACKED_FILES"),
            ("per-file-size", "_MAX_LOCAL_UNTRACKED_FILE_BYTES"),
            ("aggregate-size", "_MAX_LOCAL_UNTRACKED_TOTAL_BYTES"),
            ("symlink", None),
        )
        for case, bound_name in cases:
            with self.subTest(case=case), tempfile.TemporaryDirectory() as directory:
                repo, _base = self._repo(directory)
                candidate = repo / "new.txt"
                if case == "symlink":
                    candidate.symlink_to("keep.txt")
                    expected_code = "AUTH_LOCAL_UNTRACKED_UNSAFE"
                    context = nullcontext()
                else:
                    candidate.write_text("bound\n", encoding="utf-8")
                    expected_code = "AUTH_LOCAL_UNTRACKED_BOUNDS"
                    context = mock.patch.object(
                        authorization_module,
                        str(bound_name),
                        0,
                    )
                index_before = run(repo, "write-tree")
                with context, self.assertRaisesRegex(
                    AuthorizationError, expected_code
                ):
                    canonical_local_state(repo, requested_paths=("new.txt",))
                self.assertEqual(run(repo, "write-tree"), index_before)


class FutureTaskAndSelfProtectionTests(unittest.TestCase):
    @staticmethod
    def _issue_transition(
        issue_state: dict[str, object],
        *completed_task_ids: str,
        base_digest: str | None = None,
    ) -> dict[str, object]:
        return {
            "schema_version": 1,
            "snapshot_revision": "platform-transition-test-v1",
            "base_issue_state_sha256": base_digest
            or hashlib.sha256(canonical_json_bytes(issue_state)).hexdigest(),
            "completed_task_receipts": [
                {
                    "task_id": task_id,
                    "finalization_receipt_sha256": hashlib.sha256(
                        f"finalization:{task_id}".encode()
                    ).hexdigest(),
                }
                for task_id in sorted(completed_task_ids)
            ],
        }

    def test_policy_preserves_train_routes_and_admits_autonomous_repair_delegation(self) -> None:
        policy = json.loads(
            (ROOT / "docs/canon/references/task-authorization-policy.json").read_text(
                encoding="utf-8"
            )
        )
        rules = {item["task_id"]: item for item in policy["task_rules"]}
        historical_tasks = {f"TASK-{number}" for number in range(24, 30)}
        self.assertEqual(
            set(rules),
            historical_tasks
            | {
                "CEBR-01-CANON-INTEGRATION",
                "CODEX-AUTONOMOUS-REPAIR-DELEGATION",
            },
        )
        for number in range(24, 30):
            rule = rules[f"TASK-{number}"]
            self.assertTrue(rule["approval_required"])
            self.assertTrue(rule["authorized_files"])
            self.assertTrue(rule["required_checks"])
            self.assertTrue(rule["proof_obligations"])

        delegation = rules["CODEX-AUTONOMOUS-REPAIR-DELEGATION"]
        self.assertTrue(delegation["approval_required"])
        self.assertEqual(delegation["approval_policy_ids"], ["owner-gate@1"])
        self.assertEqual(
            delegation["scopes"],
            ["AUTHORITY-AMENDMENT-001", "ordinary-repair"],
        )
        self.assertEqual(
            delegation["authorization_modes"], ["exact-files", "path-roots"]
        )
        self.assertEqual(
            delegation["delegated_task_types"],
            ["docs", "mechanical", "runtime", "swiftui"],
        )
        self.assertEqual(
            delegation["delegated_scope_mode"], "base-canon-concepts"
        )
        self.assertEqual(
            delegation["delegated_requirement_mode"],
            "base-canon-requirements",
        )
        self.assertGreater(delegation["maximum_changed_files"], 0)
        self.assertGreater(delegation["maximum_changed_bytes"], 0)
        self.assertIn(
            "docs/canon/references/task-authorization-policy.json",
            delegation["authorized_files"],
        )
        self.assertIn(
            ".github/workflows/ambitions-canon-authorization.yml",
            delegation["authorized_files"],
        )
        self.assertIn(
            "docs/canon/references/task-25-authorization-benchmark-policy.json",
            delegation["protected_paths"],
        )
        self.assertIn("docs/canon", delegation["protected_paths"])
        self.assertIn(
            "scripts/ambitions-canon.py",
            delegation["protected_paths"],
        )

        issue_snapshot = policy["issue_state"]
        issues = {
            task_id: item
            for item in issue_snapshot["issues"]
            for task_id in item["task_ids"]
        }
        self.assertEqual(set(issues), set(rules))
        self.assertEqual(issues["TASK-25"]["prerequisite_task_ids"], ["TASK-24"])
        self.assertEqual(issues["TASK-29"]["prerequisite_task_ids"], ["TASK-28"])

        self.assertEqual(
            rules["TASK-25"]["proof_obligations"],
            [
                "merged-task24-byte-gate-b-proof",
                "exact-base-verifier-binding",
                "independent-review",
                "offline-determinism",
            ],
        )
        self.assertIn(
            "no cutover, live CI enforcement, Governance Green",
            rules["TASK-25"]["maximum_claim_ceiling"],
        )
        retained_skills = {
            item
            for item in rules["TASK-26"]["authorized_files"]
            if item.startswith(".agents/skills/") and item.endswith("/SKILL.md")
        }
        self.assertEqual(
            retained_skills,
            {
                ".agents/skills/ambitions-architecture-tree-enforcement/SKILL.md",
                ".agents/skills/ambitions-ios-quality-gate/SKILL.md",
                ".agents/skills/ambitions-release-proof-honesty/SKILL.md",
                ".agents/skills/ambitions-runtime-contract-engineering/SKILL.md",
                ".agents/skills/ambitions-source-truth-authority/SKILL.md",
            },
        )
        self.assertEqual(
            rules["TASK-27"]["authorized_deletion_manifest"],
            "docs/canon/migration/purge-plan.toml",
        )
        self.assertNotIn("authorized_deletion_manifest", rules["TASK-28"])
        self.assertEqual(
            rules["TASK-29"]["authorized_deletion_manifest"],
            "docs/canon/migration/task-29-legacy-purge-plan.toml",
        )
        self.assertIn(
            "docs/canon/migration/task-29-legacy-purge-plan.toml",
            rules["TASK-29"]["authorized_files"],
        )
        self.assertFalse(
            any(
                path.startswith(("docs/truth/", "docs/constitution/"))
                for path in rules["TASK-29"]["authorized_files"]
            ),
            "Task 29 legacy deletions must be authorized only by its bound purge plan",
        )

    def test_task_26_and_29_forbid_protected_enforcement_scope_and_files(self) -> None:
        policy = json.loads(
            (ROOT / "docs/canon/references/task-authorization-policy.json").read_text(
                encoding="utf-8"
            )
        )
        rules = {item["task_id"]: item for item in policy["task_rules"]}
        forbidden = {
            "TASK-26": {
                "scopes": {"required-ci"},
                "files": {
                    ".github/workflows/ambitions-canon-audit.yml",
                    ".github/workflows/ambitions-canon-shadow-audit.yml",
                    ".github/workflows/ambitions-constitution-audit.yml",
                },
            },
            "TASK-29": {
                "scopes": {"ruleset-proof"},
                "files": {
                    ".github/workflows/ambitions-canon-audit.yml",
                    "docs/canon/generated/github-authorization-boundary.json",
                    "docs/canon/schemas/ruleset-evidence.schema.json",
                },
            },
        }
        for task_id, denied in forbidden.items():
            with self.subTest(task_id=task_id):
                rule = rules[task_id]
                self.assertTrue(denied["scopes"].isdisjoint(rule["scopes"]))
                self.assertTrue(denied["files"].isdisjoint(rule["authorized_files"]))
                workflows = {
                    path
                    for path in rule["authorized_files"]
                    if path.startswith(".github/workflows/")
                }
                self.assertEqual(
                    workflows,
                    {".github/workflows/ambitions-constitution-audit.yml"}
                    if task_id == "TASK-29"
                    else set(),
                )
                self.assertIn(
                    "protected enforcement is explicitly excluded",
                    rule["maximum_claim_ceiling"].lower(),
                )
                for requested_scope in denied["scopes"]:
                    with self.assertRaisesRegex(
                        AuthorizationError, "AUTH_SCOPE_POLICY"
                    ):
                        authorization_module._task_rule(
                            policy,
                            {
                                "task_id": task_id,
                                "issue_reference": rule["issue_reference"],
                                "requested_task_type": "release",
                                "requested_scope": [requested_scope],
                                "requested_requirement_ids": [],
                            },
                        )

    def test_platform_transition_receipts_advance_sequence_without_policy_edit(self) -> None:
        raw_policy = json.loads(
            (ROOT / "docs/canon/references/task-authorization-policy.json").read_text(
                encoding="utf-8"
            )
        )
        policy = authorization_module._validate_policy(raw_policy)
        issue_state = policy["issue_state"]
        self.assertEqual(
            next(
                item["state"]
                for item in issue_state["issues"]
                if item["issue_reference"] == "CANON-TASK-24"
            ),
            "in_progress",
        )
        task25 = {"task_id": "TASK-25", "issue_reference": "CANON-TASK-25"}
        authorization_module._require_current_issue(
            issue_state,
            task25,
            self._issue_transition(issue_state, "TASK-24"),
        )

        with self.assertRaisesRegex(AuthorizationError, "AUTH_ISSUE_BLOCKED"):
            authorization_module._require_current_issue(
                issue_state, task25, self._issue_transition(issue_state)
            )
        with self.assertRaisesRegex(
            AuthorizationError, "AUTH_ISSUE_TRANSITION_STALE"
        ):
            authorization_module._require_current_issue(
                issue_state,
                task25,
                self._issue_transition(issue_state, "TASK-24", base_digest="0" * 64),
            )
        with self.assertRaisesRegex(
            AuthorizationError, "AUTH_ISSUE_TRANSITION_FORGED"
        ):
            authorization_module._require_current_issue(
                issue_state,
                task25,
                self._issue_transition(issue_state, "TASK-UNKNOWN"),
            )
        task26 = {"task_id": "TASK-26", "issue_reference": "CANON-TASK-26"}
        with self.assertRaisesRegex(
            AuthorizationError, "AUTH_ISSUE_TRANSITION_SKIPPED"
        ):
            authorization_module._require_current_issue(
                issue_state,
                task26,
                self._issue_transition(issue_state, "TASK-25"),
            )

    def test_duplicate_policy_key_is_rejected_before_mapping_normalization(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            write_trusted_state(repo, ["keep.txt"])
            policy_path = repo / "docs/canon/references/task-authorization-policy.json"
            raw = policy_path.read_text(encoding="utf-8")
            raw = raw.replace(
                '"approval_required": false,',
                '"approval_required": false,\n          "approval_required": true,',
                1,
            )
            policy_path.write_text(raw, encoding="utf-8")
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "duplicate policy key")
            base = run(repo, "rev-parse", "HEAD")
            with self.assertRaisesRegex(AuthorizationError, "AUTH_POLICY_UNTRUSTED"):
                load_base_policy(repo, base)

    def test_trusted_approved_purge_manifest_authorizes_exact_deletion(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head, request = init_manifest_authorization_repo(repo)
            bindings, policy = trusted_context(repo, base, request)
            trusted_event = event(repo, base, head)
            current_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(request)).hexdigest(),
                bindings,
                trusted_event,
                task_id="TASK-27",
                approved_scope=("gate-c", "repo-purge"),
            )
            result = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=request,
                trusted_event_data=trusted_event,
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(current_approval,),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(
                result["computed_authorized_files"], ["docs/truth/OLD_CANON.md"]
            )
            self.assertEqual(result["tree_delta"]["records"][0]["status"], "deleted")

    def test_missing_current_gate_c_approval_blocks_manifest_candidate(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head, request = init_manifest_authorization_repo(repo)
            bindings, policy = trusted_context(repo, base, request)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_MISSING"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=request,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_nondeterministic_purge_manifest_entry_does_not_widen_policy(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head, request = init_manifest_authorization_repo(
                repo, deterministic_candidate=False
            )
            bindings, policy = trusted_context(repo, base, request)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_POLICY"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=request,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_purge_manifest_path_cannot_authorize_modification(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head, request = init_manifest_authorization_repo(
                repo, candidate_action="modify"
            )
            bindings, policy = trusted_context(repo, base, request)
            with self.assertRaisesRegex(
                AuthorizationError, "purge-manifest authorization permits deletion only"
            ):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=request,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_gate_c_approval_intake_digest_must_bind_exact_deletion_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head, request = init_manifest_authorization_repo(repo)
            bindings, policy = trusted_context(repo, base, request)
            trusted_event = event(repo, base, head)
            wrong_file_approval = approval(
                repo,
                base,
                head,
                hashlib.sha256(
                    canonical_json_bytes(
                        {**request, "requested_changed_files": ["docs/truth/OTHER.md"]}
                    )
                ).hexdigest(),
                bindings,
                trusted_event,
                task_id="TASK-27",
                approved_scope=("gate-c", "repo-purge"),
            )
            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_MISMATCH"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=request,
                    trusted_event_data=trusted_event,
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(wrong_file_approval,),
                    verification_epoch=1_900_000_000,
                )

    def test_sensitive_policy_change_requires_owner_approval_even_if_rule_claims_false(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            policy_path = "docs/canon/references/task-authorization-policy.json"
            write_trusted_state(repo, [policy_path], approval_required=False)
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            policy_file = repo / policy_path
            payload = json.loads(policy_file.read_text(encoding="utf-8"))
            payload["policy_revision"] = "attacker-weakened"
            write_json(repo, policy_path, payload)
            run(repo, "add", policy_path)
            run(repo, "commit", "-qm", "weaken policy")
            head = run(repo, "rev-parse", "HEAD")
            request = intake(policy_path)
            bindings, policy = trusted_context(repo, base, request)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_APPROVAL_MISSING"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=request,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )


class CanonAndValidationTrustTests(unittest.TestCase):
    def test_canon_binding_changes_when_a_manifest_declared_normative_blob_changes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            write_trusted_state(repo, ["keep.txt"])
            normative = repo / "docs/canon/specifications/test.md"
            normative.parent.mkdir(parents=True, exist_ok=True)
            normative.write_text("first law\n", encoding="utf-8")
            manifest = repo / "docs/canon/MANIFEST.toml"
            manifest.write_text(
                'schema_version = 1\ncanon_revision = 11\nauthority_state = "shadow"\n'
                'compiler_version = "0.2.0"\n'
                'normative_files = ["specifications/test.md"]\ngenerated_files = []\n',
                encoding="utf-8",
            )
            def bind_projections() -> None:
                canon_sha = labeled_digest(
                    [
                        ("MANIFEST.toml", manifest.read_bytes()),
                        ("specifications/test.md", normative.read_bytes()),
                    ]
                )
                for relative, payload_key in (
                    ("concept-ownership.json", "owners"),
                    ("known-issues.json", "issues"),
                    ("proof-state.json", "proof"),
                    ("conflict-state.json", "conflicts"),
                ):
                    write_json(
                        repo,
                        f"docs/canon/generated/{relative}",
                        {
                            "schema_version": 1,
                            "canon_revision": 11,
                            "canon_content_sha": canon_sha,
                            payload_key: [],
                        },
                    )

            bind_projections()
            (repo / "keep.txt").write_text("base\n", encoding="utf-8")
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "first base")
            first_base = run(repo, "rev-parse", "HEAD")
            first_request = intake("keep.txt")
            first = load_trusted_bindings(
                repo, first_base, first_request, load_base_policy(repo, first_base)
            )

            normative.write_text("second law\n", encoding="utf-8")
            bind_projections()
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "change normative law")
            second_base = run(repo, "rev-parse", "HEAD")
            second = load_trusted_bindings(
                repo, second_base, first_request, load_base_policy(repo, second_base)
            )
            self.assertNotEqual(
                first["canon_source_sha256"], second["canon_source_sha256"]
            )

    def test_stale_generated_projection_cannot_bind_to_current_canon(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            write_trusted_state(repo, ["keep.txt"])
            projection = repo / "docs/canon/generated/concept-ownership.json"
            write_json(
                repo,
                projection.relative_to(repo).as_posix(),
                {
                    "schema_version": 1,
                    "canon_revision": 11,
                    "canon_content_sha": "0" * 64,
                    "owners": [],
                },
            )
            (repo / "keep.txt").write_text("base\n", encoding="utf-8")
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "stale projection")
            base = run(repo, "rev-parse", "HEAD")
            with self.assertRaisesRegex(AuthorizationError, "AUTH_SNAPSHOT_STALE"):
                load_trusted_bindings(
                    repo, base, intake("keep.txt"), load_base_policy(repo, base)
                )

    def test_missing_base_owned_workflow_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            write_trusted_state(repo, ["keep.txt"])
            (repo / ".github/workflows/canon-authorization.yml").unlink()
            (repo / "keep.txt").write_text("base\n", encoding="utf-8")
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "missing workflow")
            base = run(repo, "rev-parse", "HEAD")
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_VALIDATION_WORKFLOW_MISSING"
            ):
                load_trusted_bindings(
                    repo, base, intake("keep.txt"), load_base_policy(repo, base)
                )

    def test_boolean_exit_status_is_not_integer_zero(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            request = intake(*changed_paths(repo, base, head))
            bindings, _policy = trusted_context(repo, base, request)
            candidate = validation(
                "a" * 64,
                repo,
                base,
                head,
                hashlib.sha256(canonical_json_bytes(request)).hexdigest(),
                bindings,
                hashlib.sha256(
                    canonical_json_bytes(["python3", "-m", "unittest"])
                ).hexdigest(),
            )
            candidate["exit_status"] = False
            with self.assertRaisesRegex(AuthorizationError, "AUTH_VALIDATION_FIELDS"):
                validation_attestation_digest(
                    resign(candidate), trust_anchors=anchors()
                )

    def test_validation_command_cannot_self_assign_independent_review_proof(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            request = intake(*changed_paths(repo, base, head))
            bindings, policy = trusted_context(repo, base, request)
            start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=request,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            forged = validation(
                hashlib.sha256(canonical_json_bytes(start)).hexdigest(),
                repo,
                base,
                head,
                str(start["intake_digest"]),
                bindings,
                str(start["computed_command_digests"]["canon-unit"]),
            )
            forged["proof_obligation_ids"] = [
                "focused-tests",
                "offline-determinism",
                "independent-review",
            ]
            independent = validation(
                hashlib.sha256(canonical_json_bytes(start)).hexdigest(),
                repo,
                base,
                head,
                str(start["intake_digest"]),
                bindings,
                str(
                    start["computed_command_digests"][
                        "independent-review-evidence"
                    ]
                ),
                command_id="independent-review-evidence",
                proof_obligation_ids=["independent-review"],
                artifact_digest="c" * 64,
            )
            with self.assertRaisesRegex(
                AuthorizationError, "AUTH_PROOF_EVIDENCE_MISMATCH"
            ):
                task_finalize(
                    repo_root=repo,
                    authorization=start,
                    intake_data=request,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    validation_attestations=(resign(forged), independent),
                    verification_epoch=1_900_000_000,
                )


class ExactScopeAndClosedContractTests(unittest.TestCase):
    def test_task_start_pack_failure_never_emits_authorization_envelope(self) -> None:
        arguments = SimpleNamespace(
            task_command="start",
            mode="local",
            intake_json=Path("intake.json"),
            trusted_event=None,
            approval_attestation=(),
            output=Path(".codex/canon-authorization/task-authorization.json"),
        )
        result = {
            "computed_authorized_files": [],
        }
        with (
            mock.patch.object(canon_cli, "_read_json_object", return_value={}),
            mock.patch.object(
                canon_cli,
                "_local_trusted_event",
                return_value={
                    "trusted_base_sha": "a" * 40,
                    "verification_epoch": 1,
                },
            ),
            mock.patch.object(canon_cli, "load_base_policy", return_value={}),
            mock.patch.object(canon_cli, "load_trusted_bindings", return_value={}),
            mock.patch.object(canon_cli, "task_start", return_value=result),
            mock.patch.object(canon_cli, "_pack", return_value=1),
            mock.patch.object(canon_cli, "write_authorization_output") as write,
            mock.patch("builtins.print"),
        ):
            self.assertEqual(canon_cli._task(Path("/repo"), arguments), 1)
        write.assert_not_called()

    def test_malformed_trusted_event_uses_stable_fail_closed_error(self) -> None:
        for malformed in (
            {},
            {"trusted_base_sha": "a" * 40, "verification_epoch": False},
            {"trusted_base_sha": "a" * 40, "verification_epoch": 0},
        ):
            with self.subTest(malformed=malformed):
                with self.assertRaisesRegex(AuthorizationError, "AUTH_EVENT_FIELDS"):
                    canon_cli._event_cli_bindings(malformed)

    def test_computed_files_are_the_exact_requested_policy_intersection(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            run(repo, "init", "-q", "-b", "main")
            run(repo, "config", "user.name", "Canon Review")
            run(repo, "config", "user.email", "canon-review@example.invalid")
            (repo / "one.txt").write_text("base\n", encoding="utf-8")
            (repo / "two.txt").write_text("base\n", encoding="utf-8")
            write_trusted_state(repo, ["one.txt", "two.txt"])
            run(repo, "add", "-A")
            run(repo, "commit", "-qm", "base")
            base = run(repo, "rev-parse", "HEAD")
            run(repo, "checkout", "-qb", "topic")
            (repo / "one.txt").write_text("head\n", encoding="utf-8")
            run(repo, "add", "one.txt")
            run(repo, "commit", "-qm", "head")
            head = run(repo, "rev-parse", "HEAD")
            request = intake("one.txt")
            bindings, policy = trusted_context(repo, base, request)
            result = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=request,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            self.assertEqual(result["computed_authorized_files"], ["one.txt"])

            overclaim = intake("one.txt", "forbidden.txt")
            overclaim_bindings = load_trusted_bindings(repo, base, overclaim, policy)
            with self.assertRaisesRegex(AuthorizationError, "AUTH_FILE_POLICY"):
                task_start(
                    repo_root=repo,
                    mode="ci-pr-range",
                    intake_data=overclaim,
                    trusted_event_data=event(repo, base, head),
                    trusted_bindings=overclaim_bindings,
                    policy_data=policy,
                    approval_attestations=(),
                    verification_epoch=1_900_000_000,
                )

    def test_tree_delta_validator_checks_values_order_and_digest(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            base, head = init_repo(repo)
            request = intake(*changed_paths(repo, base, head))
            bindings, policy = trusted_context(repo, base, request)
            start = task_start(
                repo_root=repo,
                mode="ci-pr-range",
                intake_data=request,
                trusted_event_data=event(repo, base, head),
                trusted_bindings=bindings,
                policy_data=policy,
                approval_attestations=(),
                verification_epoch=1_900_000_000,
            )
            tampered = json.loads(json.dumps(start))
            tampered["tree_delta"]["records"][0]["status"] = "renamed"
            with self.assertRaisesRegex(AuthorizationError, "AUTH_ENVELOPE_FIELDS"):
                validate_task_authorization(tampered)

            tampered = json.loads(json.dumps(start))
            tampered["tree_delta"]["digest"] = "0" * 64
            with self.assertRaisesRegex(AuthorizationError, "AUTH_ENVELOPE_FIELDS"):
                validate_task_authorization(tampered)


REVIEW_HEAD_SHA = "a" * 40
REVIEW_STALE_SHA = "b" * 40


def load_platform_runner():
    path = ROOT / "scripts/ambitions-canon-platform-run-command.py"
    spec = importlib.util.spec_from_file_location("platform_run_command", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def codex_review(
    *,
    commit_id: str = REVIEW_HEAD_SHA,
    reviewer_id: int = CODEX_REVIEWER_ID,
    reviewer_login: str = CODEX_REVIEWER_LOGIN,
    state: str = "COMMENTED",
) -> dict[str, object]:
    return {
        "id": 42,
        "commit_id": commit_id,
        "state": state,
        "body": f"### Codex Review\n\n**Reviewed commit:** `{commit_id[:10]}`",
        "user": {
            "id": reviewer_id,
            "login": reviewer_login,
            "type": "Bot",
        },
    }


def owner_review_request(
    *,
    head_sha: str = REVIEW_HEAD_SHA,
    created_at: str = "2026-07-19T20:00:00Z",
) -> dict[str, object]:
    return {
        "id": 84,
        "created_at": created_at,
        "body": (
            "CODEX-INDEPENDENT-REVIEW-REQUEST\n"
            f"head={head_sha}\n"
            "required=zero-critical-zero-important"
        ),
        "user": {"id": 529921, "login": "agentdevan", "type": "User"},
    }


def codex_clean_reaction(
    *, created_at: str = "2026-07-19T20:01:00Z"
) -> dict[str, object]:
    return {
        "id": 126,
        "created_at": created_at,
        "content": "+1",
        "user": {
            "id": CODEX_REVIEWER_ID,
            "login": CODEX_REVIEWER_LOGIN,
            "type": "User",
        },
    }


class IndependentReviewEvidenceTests(unittest.TestCase):
    def test_manifest_and_workflow_bind_real_independent_review_verifier(self) -> None:
        manifest = json.loads(
            (
                ROOT
                / "docs/canon/references/validation-command-manifest.json"
            ).read_text(encoding="utf-8")
        )
        command = next(
            item
            for item in manifest["commands"]
            if item["command_id"] == "independent-review-evidence"
        )
        self.assertEqual(
            command["argv"],
            [
                "python3",
                "scripts/ambitions-canon-independent-review-evidence.py",
            ],
        )
        self.assertEqual(command["proof_obligation_ids"], ["independent-review"])
        workflow = (
            ROOT / ".github/workflows/ambitions-canon-authorization.yml"
        ).read_text(encoding="utf-8")
        ordinary_step = workflow.split(
            "- name: Run candidate validation command", 1
        )[1].split("- name: Run trusted independent-review verifier", 1)[0]
        trusted_step = workflow.split(
            "- name: Run trusted independent-review verifier", 1
        )[1].split("\n  attest:", 1)[0]
        self.assertNotIn("GH_TOKEN:", ordinary_step)
        self.assertIn("GH_TOKEN: ${{ github.token }}", trusted_step)
        self.assertEqual(
            manifest["trusted_workflow"]["digest"],
            hashlib.sha256(workflow.encode("utf-8")).hexdigest(),
        )
        self.assertIn("operation:", workflow)
        self.assertIn("if: inputs.operation == 'finalize'", workflow)
        self.assertIn("delegation_start_run_id:", workflow)
        self.assertIn("--delegation-authorization", workflow)
        self.assertIn("--delegation-event", workflow)
        self.assertIn("--delegation-approval", workflow)
        self.assertIn(
            'canon-finalization/delegation-start', workflow
        )
        self.assertIn(
            "cp delegation-start/task-authorization.json", workflow
        )

    def test_platform_runner_uses_trusted_script_not_candidate_substitute(self) -> None:
        runner = load_platform_runner()
        trusted = Path("/trusted")
        candidate = Path("/candidate")
        argv, cwd = runner.resolve_validation_execution(
            command_id="independent-review-evidence",
            manifest_argv=[
                "python3",
                "scripts/ambitions-canon-independent-review-evidence.py",
            ],
            trusted_root=trusted,
            candidate_root=candidate,
        )
        self.assertEqual(
            argv,
            [
                sys.executable,
                str(
                    trusted
                    / "scripts/ambitions-canon-independent-review-evidence.py"
                ),
            ],
        )
        self.assertEqual(cwd, trusted)

        ordinary_argv, ordinary_cwd = runner.resolve_validation_execution(
            command_id="canon-audit",
            manifest_argv=["python3", "scripts/ambitions-canon.py", "audit"],
            trusted_root=trusted,
            candidate_root=candidate,
        )
        self.assertEqual(
            ordinary_argv, ["python3", "scripts/ambitions-canon.py", "audit"]
        )
        self.assertEqual(ordinary_cwd, candidate)

        source_environment = {"GH_TOKEN": "secret", "PATH": "/usr/bin"}
        self.assertEqual(
            runner.resolve_validation_environment(
                command_id="canon-audit",
                source_environment=source_environment,
            ),
            {"PATH": "/usr/bin"},
        )
        self.assertEqual(
            runner.resolve_validation_environment(
                command_id="independent-review-evidence",
                source_environment=source_environment,
            ),
            source_environment,
        )

    def test_comment_review_without_owner_request_and_reaction_fails(self) -> None:
        with self.assertRaisesRegex(
            IndependentReviewError, "REVIEW_EXACT_HEAD_MISSING"
        ):
            validate_independent_review_payload(
                [codex_review()],
                {42: []},
                expected_head_sha=REVIEW_HEAD_SHA,
                reviews_has_next_page=False,
                comments_with_next_page=frozenset(),
            )

    def test_live_clean_reaction_after_owner_exact_head_request_is_green(self) -> None:
        result = validate_independent_review_payload(
            [],
            {},
            expected_head_sha=REVIEW_HEAD_SHA,
            reviews_has_next_page=False,
            comments_with_next_page=frozenset(),
            review_requests=[owner_review_request()],
            clean_reactions=[codex_clean_reaction()],
        )
        self.assertEqual(result["review_id"], 126)
        self.assertEqual(result["review_request_id"], 84)
        self.assertEqual(
            result["evidence_kind"], "owner-request-clean-reaction"
        )

    def test_clean_reaction_wrong_order_stale_request_or_wrong_actor_fails(self) -> None:
        cases = (
            (
                [owner_review_request(created_at="2026-07-19T20:02:00Z")],
                [codex_clean_reaction()],
                "REVIEW_CLEAN_REACTION_MISSING",
            ),
            (
                [owner_review_request(head_sha=REVIEW_STALE_SHA)],
                [codex_clean_reaction()],
                "REVIEW_EXACT_HEAD_MISSING",
            ),
            (
                [owner_review_request()],
                [
                    {
                        **codex_clean_reaction(),
                        "user": {
                            "id": 1,
                            "login": "attacker",
                            "type": "User",
                        },
                    }
                ],
                "REVIEW_CLEAN_REACTION_MISSING",
            ),
        )
        for requests, reactions, code in cases:
            with self.subTest(code=code), self.assertRaisesRegex(
                IndependentReviewError, code
            ):
                validate_independent_review_payload(
                    [],
                    {},
                    expected_head_sha=REVIEW_HEAD_SHA,
                    reviews_has_next_page=False,
                    comments_with_next_page=frozenset(),
                    review_requests=requests,
                    clean_reactions=reactions,
                )

    def test_missing_wrong_reviewer_stale_head_and_wrong_state_fail_closed(self) -> None:
        cases = (
            ([], "REVIEW_EXACT_HEAD_MISSING"),
            ([codex_review(reviewer_id=1)], "REVIEW_EXACT_HEAD_MISSING"),
            (
                [codex_review(reviewer_login="agentdevan")],
                "REVIEW_EXACT_HEAD_MISSING",
            ),
            (
                [codex_review(commit_id=REVIEW_STALE_SHA)],
                "REVIEW_EXACT_HEAD_MISSING",
            ),
            ([codex_review(state="APPROVED")], "REVIEW_STATE_INVALID"),
        )
        for reviews, code in cases:
            with self.subTest(code=code), self.assertRaisesRegex(
                IndependentReviewError, code
            ):
                validate_independent_review_payload(
                    reviews,
                    {42: []},
                    expected_head_sha=REVIEW_HEAD_SHA,
                    reviews_has_next_page=False,
                    comments_with_next_page=frozenset(),
                )

    def test_inline_finding_and_pagination_ambiguity_fail_closed(self) -> None:
        with self.assertRaisesRegex(
            IndependentReviewError, "REVIEW_FINDINGS_PRESENT"
        ):
            validate_independent_review_payload(
                [codex_review()],
                {42: [{"id": 99, "body": "blocking finding"}]},
                expected_head_sha=REVIEW_HEAD_SHA,
                reviews_has_next_page=False,
                comments_with_next_page=frozenset(),
            )
        with self.assertRaisesRegex(
            IndependentReviewError, "REVIEW_PAGINATION_AMBIGUOUS"
        ):
            validate_independent_review_payload(
                [codex_review()],
                {42: []},
                expected_head_sha=REVIEW_HEAD_SHA,
                reviews_has_next_page=True,
                comments_with_next_page=frozenset(),
            )
        with self.assertRaisesRegex(
            IndependentReviewError, "REVIEW_PAGINATION_AMBIGUOUS"
        ):
            validate_independent_review_payload(
                [codex_review()],
                {42: []},
                expected_head_sha=REVIEW_HEAD_SHA,
                reviews_has_next_page=False,
                comments_with_next_page=frozenset({42}),
            )

    def test_github_fetch_uses_exact_repository_pr_and_token(self) -> None:
        responses = (
            subprocess.CompletedProcess(
                args=(),
                returncode=0,
                stdout=(f"[[{json.dumps(codex_review())}]]\n").encode(),
                stderr=b"",
            ),
            subprocess.CompletedProcess(
                args=(),
                returncode=0,
                stdout=b"[[]]\n",
                stderr=b"",
            ),
            subprocess.CompletedProcess(
                args=(),
                returncode=0,
                stdout=(
                    f"[[{json.dumps(owner_review_request())}]]\n"
                ).encode(),
                stderr=b"",
            ),
            subprocess.CompletedProcess(
                args=(),
                returncode=0,
                stdout=(
                    f"[[{json.dumps(codex_clean_reaction())}]]\n"
                ).encode(),
                stderr=b"",
            ),
        )
        with mock.patch(
            "tools.ambitions_canon.independent_review.subprocess.run",
            side_effect=responses,
        ) as run:
            result = fetch_independent_review_evidence(
                repository="agentdevan/ambitions",
                pull_request_number=38,
                expected_head_sha=REVIEW_HEAD_SHA,
                github_token="token",
            )
        self.assertEqual(result["review_id"], 126)
        self.assertEqual(run.call_count, 4)
        first = run.call_args_list[0]
        self.assertEqual(
            first.args[0],
            [
                "gh",
                "api",
                "--paginate",
                "--slurp",
                "repos/agentdevan/ambitions/pulls/38/reviews?per_page=100",
            ],
        )
        self.assertEqual(first.kwargs["env"]["GH_TOKEN"], "token")

    def test_github_fetch_rejects_malformed_or_multipage_payload(self) -> None:
        for stdout, code in (
            (b"not-json", "REVIEW_API_INVALID"),
            (b"[[],[]]", "REVIEW_PAGINATION_AMBIGUOUS"),
        ):
            with self.subTest(code=code), mock.patch(
                "tools.ambitions_canon.independent_review.subprocess.run",
                return_value=subprocess.CompletedProcess(
                    args=(), returncode=0, stdout=stdout, stderr=b""
                ),
            ), self.assertRaisesRegex(IndependentReviewError, code):
                fetch_independent_review_evidence(
                    repository="agentdevan/ambitions",
                    pull_request_number=38,
                    expected_head_sha=REVIEW_HEAD_SHA,
                    github_token="token",
                )

    def test_cli_environment_is_closed_and_reports_green_or_blocker(self) -> None:
        environment = {
            "AMBITIONS_CANON_REVIEW_REPOSITORY": "agentdevan/ambitions",
            "AMBITIONS_CANON_REVIEW_PULL_REQUEST": "38",
            "AMBITIONS_CANON_REVIEW_HEAD_SHA": REVIEW_HEAD_SHA,
            "GH_TOKEN": "token",
        }
        output = io.StringIO()
        with mock.patch.dict(os.environ, environment, clear=True), mock.patch(
            "tools.ambitions_canon.independent_review.fetch_independent_review_evidence",
            return_value={"review_id": 42},
        ), redirect_stdout(output):
            self.assertEqual(independent_review_main(), 0)
        self.assertEqual(
            output.getvalue().strip(),
            "GREEN independent review evidence "
            f"review_id=42 head={REVIEW_HEAD_SHA}",
        )

        output = io.StringIO()
        with mock.patch.dict(os.environ, {}, clear=True), redirect_stdout(output):
            self.assertEqual(independent_review_main(), 1)
        self.assertIn("P0_BLOCKER INDEPENDENT_REVIEW_FAILED", output.getvalue())


if __name__ == "__main__":
    unittest.main()
