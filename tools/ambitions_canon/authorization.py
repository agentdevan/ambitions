"""Fail-closed, offline task authorization primitives.

The functions in this module operate only on explicit bytes, trusted Git objects,
and caller-supplied trusted projections.  They never perform network or model
calls and never treat contributor intake or local artifacts as authority.
"""

from __future__ import annotations

import base64
import binascii
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import tempfile
import time
import tomllib
from collections.abc import Mapping, Sequence
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.skill_conformance import (
    SkillConformanceError,
    check_skill_conformance,
)


_INTAKE_FIELDS = frozenset(
    {
        "schema_version",
        "intake_id",
        "task_id",
        "issue_reference",
        "requested_task_type",
        "requested_scope",
        "requested_requirement_ids",
        "requested_changed_files",
        "requested_validation",
        "requested_proof",
        "requested_rollback",
        "requested_claim_ceiling",
        "requested_skill_adapters",
    }
)
_INTAKE_DELEGATION_FIELDS = frozenset(
    {
        "requested_authorization_mode",
        "requested_path_roots",
        "requested_max_changed_files",
        "requested_max_changed_bytes",
    }
)
_EVENT_FIELDS = frozenset(
    {
        "schema_version",
        "event_provider",
        "event_attestation_origin",
        "repository_id",
        "repository_full_name",
        "pull_request_number",
        "base_ref",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "verification_epoch",
        "workflow_run_id",
        "workflow_run_attempt",
        "consumption_generation",
        "issue_state_transition",
        "event_projection_digest",
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    }
)
_EVENT_DELEGATION_FIELDS = frozenset({"expires_at_epoch"})
_BINDING_FIELDS = frozenset(
    {
        "canon_revision",
        "canon_source_sha256",
        "policy_sha256",
        "policy_revision",
        "schema_revision",
        "source_ownership_sha256",
        "issue_state_sha256",
        "known_issues_sha256",
        "proof_state_sha256",
        "conflict_state_sha256",
        "skill_dependencies_sha256",
        "skill_conformance_sha256",
        "approval_nonce_consumption_sha256",
        "command_manifest_sha256",
        "trust_anchors_sha256",
        "validation_workflow_sha256",
    }
)
_POLICY_REQUIRED_FIELDS = frozenset(
    {
        "schema_version",
        "policy_revision",
        "schema_revision",
        "compiler_version",
        "snapshot_paths",
        "task_rules",
        "repository_identity",
        "approval_policies",
        "approval_trust_anchor_id",
        "event_trust_anchor_id",
        "validation_trust_anchor_id",
        "trust_anchors",
        "approval_nonce_state",
        "issue_state",
    }
)
_SNAPSHOT_PATH_FIELDS = frozenset(
    {
        "canon_manifest",
        "source_ownership",
        "known_issues",
        "proof_state",
        "conflict_state",
        "skill_dependencies",
        "command_manifest",
        "authorization_schemas",
    }
)
_TASK_RULE_FIELDS = frozenset(
    {
        "task_id",
        "issue_reference",
        "task_types",
        "scopes",
        "requirement_ids",
        "source_owner",
        "authorized_files",
        "required_checks",
        "proof_obligations",
        "maximum_claim_ceiling",
        "approval_required",
        "approval_policy_ids",
    }
)
_TASK_RULE_OPTIONAL_FIELDS = frozenset(
    {
        "authorized_deletion_manifest",
        "authorization_modes",
        "delegated_task_types",
        "delegated_scope_mode",
        "delegated_requirement_mode",
        "authorized_path_roots",
        "protected_paths",
        "maximum_changed_files",
        "maximum_changed_bytes",
    }
)
_APPROVAL_FIELDS = frozenset(
    {
        "schema_version",
        "attestation_id",
        "attestation_origin",
        "repository_id",
        "repository_full_name",
        "pull_request_number",
        "task_id",
        "intake_id",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "intake_digest",
        "policy_revision",
        "command_manifest_digest",
        "workflow_path",
        "workflow_ref",
        "workflow_digest",
        "workflow_run_id",
        "workflow_run_attempt",
        "event_projection_digest",
        "consumption_generation",
        "check_identity",
        "integration_id",
        "app_id",
        "approval_policy_id",
        "approval_policy_revision",
        "authenticated_principal",
        "approved_scope",
        "one_time_use_nonce",
        "verification_epoch",
        "consumed",
        "expires_at_epoch",
        "revoked",
        "break_glass",
        "incident_id",
        "rollback_ref",
        "post_action_review_required",
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    }
)
_VALIDATION_FIELDS = frozenset(
    {
        "schema_version",
        "attestation_id",
        "attestation_origin",
        "pull_request_number",
        "task_id",
        "intake_id",
        "intake_digest",
        "policy_revision",
        "authorization_digest",
        "command_manifest_digest",
        "workflow_path",
        "workflow_ref",
        "workflow_digest",
        "command_id",
        "command_argv_digest",
        "check_identity",
        "repository_id",
        "repository_full_name",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "integration_id",
        "app_id",
        "exit_status",
        "artifact_digest",
        "proof_obligation_ids",
        "skipped",
        "skipped_reason",
        "status",
        "claim_ceiling",
        "ci_owned",
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    }
)
_HEX_SHA256_FIELDS = frozenset(
    {
        "canon_source_sha256",
        "policy_sha256",
        "source_ownership_sha256",
        "issue_state_sha256",
        "known_issues_sha256",
        "proof_state_sha256",
        "conflict_state_sha256",
        "skill_dependencies_sha256",
        "skill_conformance_sha256",
        "approval_nonce_consumption_sha256",
        "command_manifest_sha256",
        "trust_anchors_sha256",
        "validation_workflow_sha256",
    }
)

_POLICY_PATH = "docs/canon/references/task-authorization-policy.json"
_SUBPROCESS_TIMEOUT_SECONDS = 60
_SIGNATURE_ALGORITHM = "rsa-pkcs1v15-sha256"
_SHA256_DIGEST_INFO_PREFIX = bytes.fromhex("3031300d060960864801650304020105000420")
_MAX_LOCAL_UNTRACKED_FILES = 256
_MAX_LOCAL_UNTRACKED_FILE_BYTES = 8 * 1024 * 1024
_MAX_LOCAL_UNTRACKED_TOTAL_BYTES = 64 * 1024 * 1024
_MAX_DELEGATED_DELETIONS = 8
_MAX_DELEGATION_LIFETIME_SECONDS = 3600
_OUTPUT_ROOTS = {
    "authorization": PurePosixPath(".codex/task-authorization"),
    "finalization": PurePosixPath(".codex/task-finalization"),
}
_REPOSITORY_IDENTITY_FIELDS = frozenset(
    {"repository_id", "repository_full_name"}
)
_APPROVAL_POLICY_FIELDS = frozenset(
    {
        "policy_id",
        "policy_revision",
        "authenticated_principals",
        "break_glass_allowed",
    }
)
_AUTHORIZATION_FIELDS = frozenset(
    {
        "schema_version",
        "mode",
        "authority_class",
        "intake",
        "intake_digest",
        "trusted_event_provenance",
        "trusted_bindings",
        "tree_delta",
        "local_state",
        "computed_authorized_files",
        "computed_required_checks",
        "computed_command_digests",
        "computed_proof_command_bindings",
        "computed_proof_obligations",
        "computed_claim_ceiling",
        "resolved_skill_adapters",
        "skill_conformance_sha256",
        "approval_attestation_digests",
        "approval_nonce_consumptions",
        "exact_diff_authorized",
        "merge_authorized",
    }
)
_FINALIZATION_RECEIPT_FIELDS = frozenset(
    {
        "schema_version",
        "receipt_type",
        "mode",
        "authority_class",
        "authorization_digest",
        "intake_digest",
        "trusted_event_provenance",
        "trusted_bindings",
        "starting_tree_delta",
        "final_tree_delta",
        "computed_authorized_files",
        "exact_changed_files",
        "validation_attestation_digests",
        "approval_nonce_consumptions",
        "proof_obligation_evidence",
        "scope_expansion_records",
        "delegation_start_authorization_digest",
        "delegation_start_event_provenance",
        "exact_diff_authorized",
        "merge_authorized",
        "claim_ceiling",
    }
)
_LOCAL_STATE_FIELDS = frozenset(
    {
        "schema_version",
        "head_sha",
        "head_tree_sha",
        "index_tree_sha",
        "worktree_tree_sha",
        "head_to_index_delta",
        "head_to_worktree_delta",
    }
)
_TREE_DELTA_FIELDS = frozenset(
    {"schema_version", "old_tree_sha", "new_tree_sha", "records", "digest"}
)
_TREE_DELTA_RECORD_FIELDS = frozenset(
    {
        "path_raw_base64url",
        "path_display_utf8",
        "status",
        "old_mode",
        "new_mode",
        "old_object_type",
        "new_object_type",
        "old_object_id",
        "new_object_id",
        "old_blob_size",
        "new_blob_size",
    }
)
_NONCE_CONSUMPTION_FIELDS = frozenset(
    {
        "nonce",
        "attestation_id",
        "attestation_digest",
        "consumption_snapshot_sha256",
        "consumption_generation",
        "workflow_run_id",
        "workflow_run_attempt",
        "event_projection_digest",
    }
)
_EVENT_SIGNATURE_FIELDS = frozenset(
    {
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    }
)
_MANDATORY_PROOF_OBLIGATIONS = frozenset(
    {"independent-review", "offline-determinism"}
)

_SENSITIVE_AUTHORIZATION_PATHS = frozenset(
    {
        "docs/canon/references/skill-dependencies.json",
        "docs/canon/references/task-authorization-policy.json",
        "docs/canon/references/validation-command-manifest.json",
        "tools/ambitions_canon/authorization.py",
        "tools/ambitions_canon/cli.py",
    }
)


class AuthorizationError(ValueError):
    """Stable fail-closed authorization error."""

    def __init__(self, code: str, message: str) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


def canonical_json_bytes(value: object) -> bytes:
    """Serialize canonical UTF-8 JSON with sorted keys and one final newline."""

    return (
        json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("utf-8")


def trusted_event_projection_digest(data: Mapping[str, object]) -> str:
    """Digest the immutable event projection without its signature envelope."""

    projection = {
        key: value
        for key, value in data.items()
        if key not in _EVENT_SIGNATURE_FIELDS | {"event_projection_digest"}
    }
    return hashlib.sha256(canonical_json_bytes(projection)).hexdigest()


def write_json_atomic(path: Path, value: object) -> None:
    """Atomically replace *path* with canonical JSON bytes."""

    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent,
        prefix=f".{path.name}.",
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(canonical_json_bytes(value))
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary_path, path)
    finally:
        try:
            temporary_path.unlink()
        except FileNotFoundError:
            pass


def write_authorization_output(
    repo_root: Path,
    path: Path,
    value: object,
    *,
    kind: str,
) -> None:
    """Atomically write only below an ignored, no-follow authorization root."""

    if kind not in _OUTPUT_ROOTS:
        raise AuthorizationError("AUTH_OUTPUT_KIND", "unknown authorization output kind")
    lexical_root = Path(os.path.abspath(repo_root))
    root = lexical_root.resolve()
    absolute = path if path.is_absolute() else lexical_root / path
    absolute = Path(os.path.abspath(absolute))
    try:
        relative = absolute.relative_to(lexical_root)
    except ValueError as exc:
        raise AuthorizationError(
            "AUTH_OUTPUT_PATH", "authorization output escapes repository"
        ) from exc
    pure = PurePosixPath(relative.as_posix())
    allowed = _OUTPUT_ROOTS[kind]
    if pure == allowed or allowed not in pure.parents:
        raise AuthorizationError(
            "AUTH_OUTPUT_PATH",
            f"{kind} output must be below {allowed.as_posix()}",
        )
    if pure.suffix != ".json":
        raise AuthorizationError(
            "AUTH_OUTPUT_PATH", "authorization output must be JSON"
        )
    descriptors: list[int] = []
    temporary_name: str | None = None
    try:
        current = os.open(
            root,
            os.O_RDONLY
            | os.O_DIRECTORY
            | os.O_NOFOLLOW
            | getattr(os, "O_CLOEXEC", 0),
        )
        descriptors.append(current)
        for component in relative.parts[:-1]:
            try:
                next_descriptor = os.open(
                    component,
                    os.O_RDONLY
                    | os.O_DIRECTORY
                    | os.O_NOFOLLOW
                    | getattr(os, "O_CLOEXEC", 0),
                    dir_fd=current,
                )
            except FileNotFoundError:
                os.mkdir(component, mode=0o700, dir_fd=current)
                next_descriptor = os.open(
                    component,
                    os.O_RDONLY
                    | os.O_DIRECTORY
                    | os.O_NOFOLLOW
                    | getattr(os, "O_CLOEXEC", 0),
                    dir_fd=current,
                )
            except OSError as exc:
                raise AuthorizationError(
                    "AUTH_OUTPUT_PATH", "output parent is not a real directory"
                ) from exc
            descriptors.append(next_descriptor)
            current = next_descriptor
        try:
            subprocess.run(
                ["git", "check-ignore", "-q", "--", relative.as_posix()],
                cwd=root,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=_SUBPROCESS_TIMEOUT_SECONDS,
            )
        except (OSError, subprocess.SubprocessError) as exc:
            raise AuthorizationError(
                "AUTH_OUTPUT_NOT_IGNORED",
                "authorization output must be ignored by Git",
            ) from exc
        try:
            existing = os.stat(
                relative.name, dir_fd=current, follow_symlinks=False
            )
        except FileNotFoundError:
            existing = None
        if existing is not None and not _is_regular_mode(existing.st_mode):
            raise AuthorizationError(
                "AUTH_OUTPUT_PATH", "output target is not a regular file"
            )
        temporary_name = f".{relative.name}.{os.getpid()}.tmp"
        descriptor = os.open(
            temporary_name,
            os.O_WRONLY
            | os.O_CREAT
            | os.O_EXCL
            | os.O_NOFOLLOW
            | getattr(os, "O_CLOEXEC", 0),
            0o600,
            dir_fd=current,
        )
        descriptors.append(descriptor)
        content = canonical_json_bytes(value)
        written = 0
        while written < len(content):
            count = os.write(descriptor, content[written:])
            if count <= 0:
                raise AuthorizationError(
                    "AUTH_OUTPUT_WRITE", "short authorization output write"
                )
            written += count
        os.fsync(descriptor)
        os.close(descriptor)
        descriptors.pop()
        os.replace(
            temporary_name,
            relative.name,
            src_dir_fd=current,
            dst_dir_fd=current,
        )
        temporary_name = None
        os.fsync(current)
    except AuthorizationError:
        raise
    except OSError as exc:
        raise AuthorizationError(
            "AUTH_OUTPUT_WRITE", "unable to write authorization output"
        ) from exc
    finally:
        if temporary_name is not None and descriptors:
            try:
                os.unlink(temporary_name, dir_fd=descriptors[-1])
            except OSError:
                pass
        for descriptor in reversed(descriptors):
            try:
                os.close(descriptor)
            except OSError:
                pass


def _is_regular_mode(mode: int) -> bool:
    return (mode & 0o170000) == 0o100000


def validate_task_intake(data: Mapping[str, object]) -> dict[str, object]:
    """Validate and normalize the closed request-only intake contract."""

    fields = frozenset(data) if isinstance(data, Mapping) else frozenset()
    if fields not in {_INTAKE_FIELDS, _INTAKE_FIELDS | _INTAKE_DELEGATION_FIELDS}:
        raise AuthorizationError(
            "AUTH_INTAKE_FIELDS", "fields do not match closed contract"
        )
    _require_version(data)
    authorization_mode = str(data.get("requested_authorization_mode", "exact-files"))
    if authorization_mode not in {"exact-files", "path-roots"}:
        raise AuthorizationError(
            "AUTH_INTAKE_FIELDS", "requested authorization mode is invalid"
        )
    requested_files = _string_list(
        data,
        "requested_changed_files",
        allow_empty=authorization_mode == "path-roots",
    )
    normalized: dict[str, object] = {
        "schema_version": 1,
        "intake_id": _string(data, "intake_id"),
        "task_id": _string(data, "task_id"),
        "issue_reference": _string(data, "issue_reference"),
        "requested_task_type": _string(data, "requested_task_type"),
        "requested_scope": _string_list(data, "requested_scope", allow_empty=False),
        "requested_requirement_ids": _string_list(
            data, "requested_requirement_ids", allow_empty=False
        ),
        "requested_changed_files": requested_files,
        "requested_validation": _string_list(
            data, "requested_validation", allow_empty=False
        ),
        "requested_proof": _string_list(data, "requested_proof", allow_empty=False),
        "requested_rollback": _string_list(
            data, "requested_rollback", allow_empty=False
        ),
        "requested_claim_ceiling": _string(data, "requested_claim_ceiling"),
        "requested_skill_adapters": _string_list(
            data, "requested_skill_adapters", allow_empty=True
        ),
    }
    if fields == _INTAKE_FIELDS | _INTAKE_DELEGATION_FIELDS:
        roots = _string_list(data, "requested_path_roots", allow_empty=False)
        if authorization_mode != "path-roots" or requested_files:
            raise AuthorizationError(
                "AUTH_INTAKE_FIELDS",
                "path-root delegation requires roots and no exact file forecast",
            )
        maximum_files = _positive_integer(
            data.get("requested_max_changed_files"), "AUTH_INTAKE_FIELDS"
        )
        maximum_bytes = _positive_integer(
            data.get("requested_max_changed_bytes"), "AUTH_INTAKE_FIELDS"
        )
        normalized.update(
            {
                "requested_authorization_mode": authorization_mode,
                "requested_path_roots": [
                    _canonical_repo_path(root, "AUTH_INTAKE_FIELDS")
                    for root in roots
                ],
                "requested_max_changed_files": maximum_files,
                "requested_max_changed_bytes": maximum_bytes,
            }
        )
    return normalized


def validate_task_authorization(
    data: Mapping[str, object],
) -> dict[str, object]:
    """Reject open or malformed authorization envelopes before recomputation."""

    _require_closed_mapping(data, _AUTHORIZATION_FIELDS, "AUTH_ENVELOPE_FIELDS")
    _require_version(data)
    mode = data["mode"]
    if mode not in {"local-advisory", "ci-pr-range"}:
        raise AuthorizationError("AUTH_ENVELOPE_FIELDS", "invalid envelope mode")
    expected_authority = (
        "advisory-local" if mode == "local-advisory" else "ci-candidate"
    )
    if data["authority_class"] != expected_authority:
        raise AuthorizationError(
            "AUTH_ENVELOPE_FIELDS", "authority class does not match mode"
        )
    normalized_intake = validate_task_intake(
        _mapping(data["intake"], "AUTH_ENVELOPE_FIELDS")
    )
    _sha256(data["intake_digest"], "AUTH_ENVELOPE_FIELDS")
    _validate_trusted_bindings_contract(data["trusted_bindings"])
    _validate_tree_delta_contract(data["tree_delta"], "AUTH_ENVELOPE_FIELDS")
    local_state = data["local_state"]
    if mode == "local-advisory":
        _validate_local_state_contract(local_state)
    elif local_state is not None:
        raise AuthorizationError(
            "AUTH_LOCAL_STATE_FIELDS", "CI authorization cannot contain local state"
        )
    for field in (
        "computed_authorized_files",
        "computed_required_checks",
        "computed_proof_obligations",
        "resolved_skill_adapters",
        "approval_attestation_digests",
    ):
        _string_list(
            data,
            field,
            allow_empty=(
                field in {"resolved_skill_adapters", "approval_attestation_digests"}
                or (
                    field == "computed_authorized_files"
                    and normalized_intake.get("requested_authorization_mode")
                    == "path-roots"
                )
            ),
        )
    for digest in data["approval_attestation_digests"]:
        _sha256(digest, "AUTH_ENVELOPE_FIELDS")
    command_digests = _mapping(
        data["computed_command_digests"], "AUTH_ENVELOPE_FIELDS"
    )
    if set(command_digests) != set(data["computed_required_checks"]):
        raise AuthorizationError(
            "AUTH_ENVELOPE_FIELDS", "command digests do not match required checks"
        )
    for command_id, digest in command_digests.items():
        if not isinstance(command_id, str) or not command_id.strip():
            raise AuthorizationError("AUTH_ENVELOPE_FIELDS", "command id is invalid")
        _sha256(digest, "AUTH_ENVELOPE_FIELDS")
    proof_bindings = _mapping(
        data["computed_proof_command_bindings"], "AUTH_ENVELOPE_FIELDS"
    )
    if set(proof_bindings) != set(data["computed_required_checks"]):
        raise AuthorizationError(
            "AUTH_ENVELOPE_FIELDS", "proof bindings do not match required checks"
        )
    allowed_proof = set(data["computed_proof_obligations"])
    for command_id, obligations in proof_bindings.items():
        if not isinstance(obligations, list) or not obligations:
            raise AuthorizationError(
                "AUTH_ENVELOPE_FIELDS", "proof binding must be a non-empty array"
            )
        if obligations != sorted(set(obligations)) or not set(obligations) <= allowed_proof:
            raise AuthorizationError(
                "AUTH_ENVELOPE_FIELDS", "proof binding is invalid"
            )
    _string(data, "computed_claim_ceiling")
    _sha256(data["skill_conformance_sha256"], "AUTH_ENVELOPE_FIELDS")
    if data["exact_diff_authorized"] is not False or data["merge_authorized"] is not False:
        raise AuthorizationError(
            "AUTH_ENVELOPE_FIELDS", "task start cannot authorize final diff or merge"
        )
    _validate_nonce_consumptions(data["approval_nonce_consumptions"])
    return dict(data)


def _mapping(value: object, code: str) -> Mapping[str, object]:
    if not isinstance(value, Mapping):
        raise AuthorizationError(code, "expected object")
    return value


def _validate_trusted_bindings_contract(value: object) -> None:
    bindings = _mapping(value, "AUTH_ENVELOPE_FIELDS")
    _require_closed_mapping(bindings, _BINDING_FIELDS, "AUTH_ENVELOPE_FIELDS")
    revision = bindings["canon_revision"]
    if isinstance(revision, bool) or not isinstance(revision, int) or revision < 0:
        raise AuthorizationError("AUTH_ENVELOPE_FIELDS", "canon revision is invalid")
    _string(bindings, "policy_revision")
    _string(bindings, "schema_revision")
    for field in _HEX_SHA256_FIELDS:
        _sha256(bindings[field], "AUTH_ENVELOPE_FIELDS")


def validate_task_finalization_receipt(
    data: Mapping[str, object],
) -> dict[str, object]:
    """Validate the closed proof-only finalization receipt contract."""

    _require_closed_mapping(
        data, _FINALIZATION_RECEIPT_FIELDS, "AUTH_RECEIPT_FIELDS"
    )
    _require_version(data)
    if data["receipt_type"] != "task-finalization":
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "receipt type is not task-finalization"
        )
    if data["mode"] not in {"local-advisory", "ci-pr-range"}:
        raise AuthorizationError("AUTH_RECEIPT_FIELDS", "invalid receipt mode")
    expected_authority = (
        "advisory-local-finalization"
        if data["mode"] == "local-advisory"
        else "ci-pr-range-finalization"
    )
    if data["authority_class"] != expected_authority:
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "receipt authority class does not match mode"
        )
    for field in ("authorization_digest", "intake_digest"):
        _sha256(data[field], "AUTH_RECEIPT_FIELDS")
    _validate_trusted_bindings_contract(data["trusted_bindings"])
    _validate_tree_delta_contract(
        data["starting_tree_delta"], "AUTH_RECEIPT_FIELDS"
    )
    _validate_tree_delta_contract(data["final_tree_delta"], "AUTH_RECEIPT_FIELDS")
    for field in (
        "computed_authorized_files",
        "exact_changed_files",
        "validation_attestation_digests",
    ):
        _string_list(data, field, allow_empty=True)
    for digest in data["validation_attestation_digests"]:
        _sha256(digest, "AUTH_RECEIPT_FIELDS")
    final_records = data["final_tree_delta"]["records"]
    assert isinstance(final_records, list)
    expected_exact_changed_files = sorted(
        _record_path(record)
        for record in final_records
        if isinstance(record, Mapping)
    )
    if data["exact_changed_files"] != expected_exact_changed_files:
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS",
            "exact changed files do not match the final tree delta",
        )
    if not set(data["exact_changed_files"]) <= set(data["computed_authorized_files"]):
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "final changed files exceed computed authorization"
        )
    if data["exact_diff_authorized"] is not True:
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "final receipt must authorize the exact diff"
        )
    expected_merge = data["mode"] == "ci-pr-range"
    if data["merge_authorized"] is not expected_merge:
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "merge authorization does not match receipt mode"
        )
    _string(data, "claim_ceiling")
    _validate_nonce_consumptions(data["approval_nonce_consumptions"])
    _validate_scope_expansion_records(data["scope_expansion_records"])
    delegation_digest = data["delegation_start_authorization_digest"]
    delegation_event = data["delegation_start_event_provenance"]
    if delegation_digest is None or delegation_event is None:
        if delegation_digest is not None or delegation_event is not None:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS",
                "delegation start digest and event must appear together",
            )
        if data["scope_expansion_records"]:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS",
                "scope expansion records require a signed delegation start",
            )
    else:
        _sha256(delegation_digest, "AUTH_RECEIPT_FIELDS")
        if not isinstance(delegation_event, Mapping):
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "delegation start event must be an object"
            )
        event_fields = frozenset(delegation_event)
        if event_fields != _EVENT_FIELDS | _EVENT_DELEGATION_FIELDS:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "delegation start event fields are invalid"
            )
        if not data["scope_expansion_records"]:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS",
                "delegated finalization requires append-only scope records",
            )
    evidence = data["proof_obligation_evidence"]
    if not isinstance(evidence, Mapping):
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "proof obligation evidence must be an object"
        )
    for obligation, digests in evidence.items():
        if not isinstance(obligation, str) or not obligation.strip():
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "proof obligation key is invalid"
            )
        if not isinstance(digests, list):
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "proof evidence digests must be an array"
            )
        for digest in digests:
            _sha256(digest, "AUTH_RECEIPT_FIELDS")
    return dict(data)


def _validate_scope_expansion_records(value: object) -> None:
    if not isinstance(value, list):
        raise AuthorizationError(
            "AUTH_RECEIPT_FIELDS", "scope expansion records must be an array"
        )
    previous_digest: str | None = None
    for expected_sequence, record in enumerate(value, start=1):
        fields = {
            "sequence",
            "head_sha",
            "tree_delta_digest",
            "changed_files",
            "changed_file_count",
            "changed_bytes",
            "previous_record_sha256",
            "record_sha256",
        }
        if not isinstance(record, Mapping) or set(record) != fields:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion record fields are invalid"
            )
        if record["sequence"] != expected_sequence:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion sequence is not append-only"
            )
        _git_oid(record["head_sha"], "AUTH_RECEIPT_FIELDS")
        _sha256(record["tree_delta_digest"], "AUTH_RECEIPT_FIELDS")
        changed_files = _string_list(record, "changed_files", allow_empty=True)
        if changed_files != sorted(changed_files) or len(changed_files) != len(
            set(changed_files)
        ):
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion paths are not canonical"
            )
        if record["changed_file_count"] != len(changed_files):
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion path count is invalid"
            )
        _nonnegative_integer(record["changed_bytes"], "AUTH_RECEIPT_FIELDS")
        if record["previous_record_sha256"] != previous_digest:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion hash chain is invalid"
            )
        _sha256(record["record_sha256"], "AUTH_RECEIPT_FIELDS")
        unsigned = dict(record)
        unsigned.pop("record_sha256")
        expected_digest = hashlib.sha256(canonical_json_bytes(unsigned)).hexdigest()
        if record["record_sha256"] != expected_digest:
            raise AuthorizationError(
                "AUTH_RECEIPT_FIELDS", "scope expansion record digest is invalid"
            )
        previous_digest = str(record["record_sha256"])


def _validate_local_state_contract(value: object) -> None:
    if not isinstance(value, Mapping):
        raise AuthorizationError(
            "AUTH_LOCAL_STATE_FIELDS", "local state must be an object"
        )
    _require_closed_mapping(value, _LOCAL_STATE_FIELDS, "AUTH_LOCAL_STATE_FIELDS")
    _require_version(value)
    for field in ("head_sha", "head_tree_sha", "index_tree_sha", "worktree_tree_sha"):
        _git_oid(value[field], "AUTH_LOCAL_STATE_FIELDS")
    _validate_tree_delta_contract(
        value["head_to_index_delta"], "AUTH_LOCAL_STATE_FIELDS"
    )
    _validate_tree_delta_contract(
        value["head_to_worktree_delta"], "AUTH_LOCAL_STATE_FIELDS"
    )


def _validate_tree_delta_contract(value: object, code: str) -> None:
    if not isinstance(value, Mapping):
        raise AuthorizationError(code, "tree delta must be an object")
    _require_closed_mapping(value, _TREE_DELTA_FIELDS, code)
    _require_version(value)
    _git_oid(value["old_tree_sha"], code)
    _git_oid(value["new_tree_sha"], code)
    _sha256(value["digest"], code)
    records = value["records"]
    if not isinstance(records, list):
        raise AuthorizationError(code, "tree delta records must be an array")
    raw_paths: list[bytes] = []
    for record in records:
        if not isinstance(record, Mapping):
            raise AuthorizationError(code, "tree delta record must be an object")
        _require_closed_mapping(record, _TREE_DELTA_RECORD_FIELDS, code)
        encoded = record["path_raw_base64url"]
        if not isinstance(encoded, str) or not encoded:
            raise AuthorizationError(code, "tree delta raw path is invalid")
        try:
            raw_path = base64.urlsafe_b64decode(
                encoded + "=" * (-len(encoded) % 4)
            )
        except (ValueError, binascii.Error) as exc:
            raise AuthorizationError(code, "tree delta raw path is invalid") from exc
        if not raw_path or _base64url(raw_path) != encoded:
            raise AuthorizationError(code, "tree delta raw path is non-canonical")
        raw_paths.append(raw_path)
        try:
            expected_display: str | None = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            expected_display = None
        if record["path_display_utf8"] != expected_display:
            raise AuthorizationError(code, "tree delta display path mismatches raw bytes")

        status = record["status"]
        if status not in {"added", "deleted", "modified"}:
            raise AuthorizationError(code, "tree delta status is invalid")
        old_present = status in {"deleted", "modified"}
        new_present = status in {"added", "modified"}
        _validate_tree_side(record, "old", old_present, code)
        _validate_tree_side(record, "new", new_present, code)
    if raw_paths != sorted(raw_paths) or len(raw_paths) != len(set(raw_paths)):
        raise AuthorizationError(code, "tree delta records are not raw-byte sorted")
    if value["digest"] != hashlib.sha256(canonical_json_bytes(records)).hexdigest():
        raise AuthorizationError(code, "tree delta digest mismatch")


def _validate_tree_side(
    record: Mapping[str, object], side: str, present: bool, code: str
) -> None:
    mode = record[f"{side}_mode"]
    object_type = record[f"{side}_object_type"]
    object_id = record[f"{side}_object_id"]
    blob_size = record[f"{side}_blob_size"]
    if not present:
        if any(value is not None for value in (mode, object_type, object_id, blob_size)):
            raise AuthorizationError(code, f"absent {side} tree entry has metadata")
        return
    if (
        not isinstance(mode, str)
        or len(mode) != 6
        or any(character not in "01234567" for character in mode)
    ):
        raise AuthorizationError(code, f"{side} tree mode is invalid")
    if object_type not in {"blob", "commit"}:
        raise AuthorizationError(code, f"{side} tree object type is invalid")
    _git_oid(object_id, code)
    if (mode == "160000") != (object_type == "commit"):
        raise AuthorizationError(code, f"{side} tree mode and object type disagree")
    if object_type == "blob":
        if isinstance(blob_size, bool) or not isinstance(blob_size, int) or blob_size < 0:
            raise AuthorizationError(code, f"{side} blob size is invalid")
    elif blob_size is not None:
        raise AuthorizationError(code, f"{side} gitlink cannot have a blob size")


def _validate_nonce_consumptions(value: object) -> None:
    if not isinstance(value, list):
        raise AuthorizationError(
            "AUTH_ENVELOPE_FIELDS", "nonce consumptions must be an array"
        )
    seen: set[str] = set()
    for item in value:
        if not isinstance(item, Mapping):
            raise AuthorizationError(
                "AUTH_ENVELOPE_FIELDS", "nonce consumption must be an object"
            )
        _require_closed_mapping(
            item, _NONCE_CONSUMPTION_FIELDS, "AUTH_ENVELOPE_FIELDS"
        )
        nonce = _string(item, "nonce")
        _string(item, "attestation_id")
        _sha256(item["attestation_digest"], "AUTH_ENVELOPE_FIELDS")
        _sha256(item["consumption_snapshot_sha256"], "AUTH_ENVELOPE_FIELDS")
        _sha256(item["event_projection_digest"], "AUTH_ENVELOPE_FIELDS")
        for field in (
            "consumption_generation",
            "workflow_run_id",
            "workflow_run_attempt",
        ):
            value = item[field]
            if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
                raise AuthorizationError(
                    "AUTH_ENVELOPE_FIELDS", f"{field} must be a positive integer"
                )
        if nonce in seen:
            raise AuthorizationError(
                "AUTH_APPROVAL_REUSED", "duplicate persisted nonce consumption"
            )
        seen.add(nonce)


def canonical_tree_delta(repo_root: Path, old_sha: str, new_sha: str) -> dict[str, object]:
    """Return a rename-free canonical leaf-entry delta between two Git trees."""

    repository = repo_root.resolve()
    _git_oid(old_sha, "AUTH_GIT_OBJECT_ID")
    _git_oid(new_sha, "AUTH_GIT_OBJECT_ID")
    _require_git_object(repository, old_sha)
    _require_git_object(repository, new_sha)
    old_entries = _git_tree_entries(repository, old_sha)
    new_entries = _git_tree_entries(repository, new_sha)
    records: list[dict[str, object]] = []
    for raw_path in sorted(set(old_entries) | set(new_entries)):
        old = old_entries.get(raw_path)
        new = new_entries.get(raw_path)
        if old == new:
            continue
        if old is None:
            status = "added"
        elif new is None:
            status = "deleted"
        else:
            status = "modified"
        display: str | None
        try:
            display = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            display = None
        records.append(
            {
                "path_raw_base64url": _base64url(raw_path),
                "path_display_utf8": display,
                "status": status,
                "old_mode": old[0] if old else None,
                "new_mode": new[0] if new else None,
                "old_object_type": old[1] if old else None,
                "new_object_type": new[1] if new else None,
                "old_object_id": old[2] if old else None,
                "new_object_id": new[2] if new else None,
                "old_blob_size": old[3] if old and old[1] == "blob" else None,
                "new_blob_size": new[3] if new and new[1] == "blob" else None,
            }
        )
    return {
        "schema_version": 1,
        "old_tree_sha": _git(repository, "rev-parse", f"{old_sha}^{{tree}}").decode().strip(),
        "new_tree_sha": _git(repository, "rev-parse", f"{new_sha}^{{tree}}").decode().strip(),
        "records": records,
        "digest": hashlib.sha256(canonical_json_bytes(records)).hexdigest(),
    }


def approval_attestation_digest(
    data: Mapping[str, object],
    *,
    verification_epoch: int,
    trust_anchors: Mapping[str, object] | None = None,
) -> str:
    """Verify a one-use platform approval signature and return its digest."""

    if trust_anchors is None or set(data) != _APPROVAL_FIELDS:
        raise AuthorizationError(
            "AUTH_APPROVAL_SIGNATURE",
            "approval lacks a base-trusted cryptographic signature contract",
        )
    _require_closed_mapping(data, _APPROVAL_FIELDS, "AUTH_APPROVAL_FIELDS")
    _require_version(data)
    if (
        isinstance(verification_epoch, bool)
        or not isinstance(verification_epoch, int)
        or verification_epoch <= 0
    ):
        raise AuthorizationError(
            "AUTH_VERIFICATION_EPOCH",
            "approval verification epoch must be platform-trusted and positive",
        )
    if data["attestation_origin"] != "platform-authenticated":
        raise AuthorizationError("AUTH_APPROVAL_UNTRUSTED", "approval is not platform authenticated")
    if data["revoked"] is not False:
        raise AuthorizationError("AUTH_APPROVAL_REVOKED", "approval has been revoked")
    if data["consumed"] is not False:
        raise AuthorizationError("AUTH_APPROVAL_REUSED", "approval has already been consumed")
    expiry = data["expires_at_epoch"]
    if isinstance(expiry, bool) or not isinstance(expiry, int):
        raise AuthorizationError("AUTH_APPROVAL_FIELDS", "expiry must be an integer epoch")
    if expiry <= verification_epoch:
        raise AuthorizationError("AUTH_APPROVAL_EXPIRED", "approval has expired")
    attested_epoch = data["verification_epoch"]
    if (
        isinstance(attested_epoch, bool)
        or not isinstance(attested_epoch, int)
        or attested_epoch <= 0
        or attested_epoch != verification_epoch
    ):
        raise AuthorizationError(
            "AUTH_VERIFICATION_EPOCH",
            "approval verification epoch does not match trusted event time",
        )
    for field in (
        "attestation_id",
        "repository_id",
        "repository_full_name",
        "task_id",
        "intake_id",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "intake_digest",
        "policy_revision",
        "command_manifest_digest",
        "workflow_path",
        "workflow_ref",
        "workflow_digest",
        "check_identity",
        "integration_id",
        "app_id",
        "approval_policy_id",
        "approval_policy_revision",
        "authenticated_principal",
        "one_time_use_nonce",
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    ):
        _string(data, field)
    _string_list(data, "approved_scope", allow_empty=False)
    for field in ("break_glass", "post_action_review_required"):
        if not isinstance(data[field], bool):
            raise AuthorizationError(
                "AUTH_APPROVAL_FIELDS", f"{field} must be boolean"
            )
    for field in ("incident_id", "rollback_ref"):
        if data[field] is not None and (
            not isinstance(data[field], str) or not str(data[field]).strip()
        ):
            raise AuthorizationError(
                "AUTH_APPROVAL_FIELDS", f"{field} must be null or non-empty"
            )
    _sha256(data["intake_digest"], "AUTH_APPROVAL_FIELDS")
    _sha256(data["command_manifest_digest"], "AUTH_APPROVAL_FIELDS")
    _sha256(data["workflow_digest"], "AUTH_APPROVAL_FIELDS")
    _sha256(data["event_projection_digest"], "AUTH_APPROVAL_FIELDS")
    _sha256(data["trust_anchor_sha256"], "AUTH_APPROVAL_FIELDS")
    for field in (
        "workflow_run_id",
        "workflow_run_attempt",
        "consumption_generation",
    ):
        value = data[field]
        if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
            raise AuthorizationError(
                "AUTH_APPROVAL_FIELDS", f"{field} must be a positive integer"
            )
    _verify_signed_attestation(
        data,
        trust_anchors,
        purpose="approval",
        error_code="AUTH_APPROVAL_SIGNATURE",
    )
    return hashlib.sha256(canonical_json_bytes(dict(data))).hexdigest()


def validation_attestation_digest(
    data: Mapping[str, object],
    *,
    trust_anchors: Mapping[str, object] | None = None,
) -> str:
    """Verify structural and cryptographic CI attestation invariants."""

    if trust_anchors is None or set(data) != _VALIDATION_FIELDS:
        raise AuthorizationError(
            "AUTH_VALIDATION_SIGNATURE",
            "validation lacks a base-trusted cryptographic signature contract",
        )
    _require_closed_mapping(data, _VALIDATION_FIELDS, "AUTH_VALIDATION_FIELDS")
    _require_version(data)
    for field in (
        "attestation_id",
        "attestation_origin",
        "task_id",
        "intake_id",
        "intake_digest",
        "policy_revision",
        "authorization_digest",
        "command_manifest_digest",
        "workflow_path",
        "workflow_ref",
        "workflow_digest",
        "command_id",
        "command_argv_digest",
        "check_identity",
        "repository_id",
        "repository_full_name",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "integration_id",
        "app_id",
        "artifact_digest",
        "status",
        "claim_ceiling",
        "trust_anchor_id",
        "trust_anchor_sha256",
        "signature_algorithm",
        "signature_base64url",
    ):
        _string(data, field)
    for field in (
        "authorization_digest",
        "intake_digest",
        "command_manifest_digest",
        "workflow_digest",
        "command_argv_digest",
        "artifact_digest",
        "trust_anchor_sha256",
    ):
        _sha256(data[field], "AUTH_VALIDATION_FIELDS")
    _string_list(data, "proof_obligation_ids", allow_empty=False)
    if data["artifact_digest"] == "0" * 64:
        raise AuthorizationError(
            "AUTH_VALIDATION_ARTIFACT",
            "validation evidence artifact digest cannot be the null digest",
        )
    if isinstance(data["pull_request_number"], bool) or not isinstance(
        data["pull_request_number"], int
    ) or data["pull_request_number"] <= 0:
        raise AuthorizationError(
            "AUTH_VALIDATION_FIELDS", "pull request number must be positive"
        )
    for field in ("trusted_base_sha", "trusted_head_sha", "merge_base_sha"):
        _git_oid(data[field], "AUTH_VALIDATION_FIELDS")
    exit_status = data["exit_status"]
    if isinstance(exit_status, bool) or not isinstance(exit_status, int) or exit_status < 0:
        raise AuthorizationError(
            "AUTH_VALIDATION_FIELDS", "exit status must be a non-negative integer"
        )
    if not isinstance(data["ci_owned"], bool) or not isinstance(data["skipped"], bool):
        raise AuthorizationError(
            "AUTH_VALIDATION_FIELDS", "validation flags must be booleans"
        )
    skipped_reason = data["skipped_reason"]
    if skipped_reason is not None and (
        not isinstance(skipped_reason, str) or not skipped_reason.strip()
    ):
        raise AuthorizationError(
            "AUTH_VALIDATION_FIELDS", "skipped reason must be null or non-empty"
        )
    if data["skipped"] is False and skipped_reason is not None:
        raise AuthorizationError(
            "AUTH_VALIDATION_FIELDS", "non-skipped validation cannot name a reason"
        )
    if data["ci_owned"] is not True or data["attestation_origin"] != "trusted-ci":
        raise AuthorizationError("AUTH_VALIDATION_UNTRUSTED", "validation is not CI owned")
    if data["skipped"] is not False:
        raise AuthorizationError("AUTH_VALIDATION_SKIPPED", "required validation was skipped")
    if data["status"] != "green" or exit_status != 0:
        raise AuthorizationError("AUTH_VALIDATION_NOT_GREEN", "validation is not Green")
    _verify_signed_attestation(
        data,
        trust_anchors,
        purpose="validation",
        error_code="AUTH_VALIDATION_SIGNATURE",
    )
    return hashlib.sha256(canonical_json_bytes(dict(data))).hexdigest()


def task_start(
    *,
    repo_root: Path,
    mode: str,
    intake_data: Mapping[str, object],
    trusted_event_data: Mapping[str, object],
    trusted_bindings: Mapping[str, object],
    policy_data: Mapping[str, object],
    approval_attestations: Sequence[Mapping[str, object]],
    verification_epoch: int,
    evaluation_epoch: int | None = None,
) -> dict[str, object]:
    """Compute a deterministic advisory/local or CI-candidate authorization."""

    if mode not in {"local-advisory", "ci-pr-range"}:
        raise AuthorizationError("AUTH_MODE", "unsupported authorization mode")
    legacy_prefixes = policy_data.get("authorized_path_prefixes")
    if isinstance(legacy_prefixes, list) and any(
        not isinstance(item, str) or not item.strip() or item.strip("/") in {"", "."}
        for item in legacy_prefixes
    ):
        raise AuthorizationError(
            "AUTH_POLICY_PATH_ROOT", "blank or repository-root policy is forbidden"
        )
    normalized_intake = validate_task_intake(intake_data)
    normalized_event = _validate_trusted_event(
        repo_root,
        trusted_event_data,
    )
    (
        normalized_policy,
        recomputed_bindings,
        command_manifest,
        trust_anchors,
        nonce_snapshot,
        skill_context,
    ) = _load_base_trust_state(
        repo_root,
        str(normalized_event["trusted_base_sha"]),
        normalized_intake,
        policy_data,
    )
    if normalized_event["event_attestation_origin"] == "trusted-ci":
        if normalized_event["trust_anchor_id"] != normalized_policy[
            "event_trust_anchor_id"
        ]:
            raise AuthorizationError(
                "AUTH_EVENT_SIGNATURE", "event signing anchor is not policy-owned"
            )
        _verify_signed_attestation(
            normalized_event,
            trust_anchors,
            purpose="event",
            error_code="AUTH_EVENT_SIGNATURE",
        )
    elif mode != "local-advisory" or approval_attestations:
        raise AuthorizationError(
            "AUTH_EVENT_UNTRUSTED",
            "unsigned local events cannot authorize approvals or CI ranges",
        )
    if normalized_event["consumption_generation"] != nonce_snapshot[
        "consumption_generation"
    ]:
        raise AuthorizationError(
            "AUTH_NONCE_GENERATION_STALE",
            "trusted event does not name the authoritative nonce generation",
        )
    if (
        isinstance(verification_epoch, bool)
        or not isinstance(verification_epoch, int)
        or verification_epoch <= 0
        or verification_epoch != normalized_event["verification_epoch"]
    ):
        raise AuthorizationError(
            "AUTH_VERIFICATION_EPOCH",
            "verification epoch must match the positive platform event epoch",
        )
    if evaluation_epoch is None:
        evaluation_epoch = max(verification_epoch, int(time.time()))
    if (
        isinstance(evaluation_epoch, bool)
        or not isinstance(evaluation_epoch, int)
        or evaluation_epoch < verification_epoch
    ):
        raise AuthorizationError(
            "AUTH_VERIFICATION_EPOCH",
            "evaluation epoch must not precede the signed event epoch",
        )
    repository_identity = normalized_policy["repository_identity"]
    assert isinstance(repository_identity, Mapping)
    if (
        normalized_event["repository_id"],
        normalized_event["repository_full_name"],
    ) != (
        repository_identity["repository_id"],
        repository_identity["repository_full_name"],
    ):
        raise AuthorizationError(
            "AUTH_REPOSITORY_MISMATCH",
            "platform repository identity differs from base-owned policy",
        )
    normalized_bindings = _validate_bindings(trusted_bindings)
    if canonical_json_bytes(normalized_bindings) != canonical_json_bytes(
        recomputed_bindings
    ):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_STALE",
            "caller bindings do not match base-trusted snapshot bytes",
        )
    authorization_mode = str(
        normalized_intake.get("requested_authorization_mode", "exact-files")
    )
    task_rule = _task_rule(normalized_policy, normalized_intake)
    issue_state = normalized_policy["issue_state"]
    assert isinstance(issue_state, Mapping)
    _require_current_issue(
        issue_state,
        normalized_intake,
        _mapping(normalized_event["issue_state_transition"], "AUTH_ISSUE_TRANSITION"),
    )
    if (
        normalized_event["event_attestation_origin"] == "local-advisory"
        and task_rule["approval_required"]
    ):
        raise AuthorizationError(
            "AUTH_APPROVAL_MISSING",
            "approval-required tasks need a signed platform event",
        )
    resolved_skill_adapters = _resolve_skill_request(
        normalized_intake, skill_context
    )
    if authorization_mode not in task_rule["authorization_modes"]:
        raise AuthorizationError(
            "AUTH_MODE_POLICY", "requested authorization mode is outside trusted policy"
        )
    if authorization_mode == "path-roots":
        expiry = normalized_event.get("expires_at_epoch")
        if (
            isinstance(expiry, bool)
            or not isinstance(expiry, int)
            or expiry <= evaluation_epoch
            or expiry - verification_epoch > _MAX_DELEGATION_LIFETIME_SECONDS
        ):
            raise AuthorizationError(
                "AUTH_EVENT_EXPIRED",
                "path-root delegation is missing a current signed expiry",
            )
        _validate_delegated_canon_domains(
            repo_root,
            str(normalized_event["trusted_base_sha"]),
            normalized_policy,
            normalized_intake,
        )
    if (
        authorization_mode == "path-roots"
        and normalized_event["event_attestation_origin"] != "trusted-ci"
    ):
        raise AuthorizationError(
            "AUTH_EVENT_SIGNATURE", "path-root delegation requires a signed platform event"
        )
    static_policy_allowed_files = set(task_rule["authorized_files"])
    manifest_deletion_files = _approved_manifest_deletion_paths(
        repo_root,
        str(normalized_event["trusted_base_sha"]),
        task_rule["authorized_deletion_manifest"],
    )
    policy_allowed_files = static_policy_allowed_files | manifest_deletion_files
    requested_files = {
        _canonical_authorized_file(path)
        for path in normalized_intake["requested_changed_files"]
    }
    selected_roots: tuple[str, ...] = ()
    protected_paths = tuple(str(item) for item in task_rule["protected_paths"])
    if authorization_mode == "exact-files":
        outside_policy = sorted(requested_files - policy_allowed_files)
        if outside_policy:
            raise AuthorizationError(
                "AUTH_FILE_POLICY",
                f"requested file is outside trusted policy: {outside_policy[0]}",
            )
        computed_authorized_files = sorted(requested_files & policy_allowed_files)
    else:
        policy_roots = tuple(str(item) for item in task_rule["authorized_path_roots"])
        selected_roots = tuple(
            str(item) for item in normalized_intake["requested_path_roots"]
        )
        outside_roots = sorted(
            root
            for root in selected_roots
            if not any(_path_matches_delegated_root(root, allowed) for allowed in policy_roots)
        )
        if outside_roots:
            raise AuthorizationError(
                "AUTH_FILE_POLICY",
                f"requested root is outside trusted policy: {outside_roots[0]}",
            )
        protected_roots = sorted(
            root
            for root in selected_roots
            if _is_hard_delegation_boundary(root, protected_paths)
        )
        if protected_roots:
            raise AuthorizationError(
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                f"requested root crosses a renewed-approval boundary: {protected_roots[0]}",
            )
        if (
            int(normalized_intake["requested_max_changed_files"])
            > int(task_rule["maximum_changed_files"])
            or int(normalized_intake["requested_max_changed_bytes"])
            > int(task_rule["maximum_changed_bytes"])
        ):
            raise AuthorizationError(
                "AUTH_DELEGATION_BUDGET", "requested delegation budget exceeds policy"
            )
        computed_authorized_files = []
    if mode == "ci-pr-range":
        delta = canonical_tree_delta(
            repo_root,
            str(normalized_event["merge_base_sha"]),
            str(normalized_event["trusted_head_sha"]),
        )
        local_state = None
    else:
        local_requested_paths = computed_authorized_files
        if authorization_mode == "path-roots":
            local_requested_paths = _local_untracked_displays(repo_root)
        local_state = canonical_local_state(
            repo_root, requested_paths=local_requested_paths
        )
        if local_state["head_sha"] != normalized_event["trusted_head_sha"]:
            raise AuthorizationError(
                "AUTH_LOCAL_HEAD_STALE", "local HEAD changed from trusted task start"
            )
        delta = local_state["head_to_worktree_delta"]
    changed_files = sorted(_record_path(record) for record in delta["records"])
    requested = set(computed_authorized_files)
    for record in delta["records"]:
        path = _record_path(record)
        if authorization_mode != "path-roots":
            if path not in policy_allowed_files:
                raise AuthorizationError("AUTH_FILE_POLICY", f"tree change is outside trusted policy: {path}")
            if path not in requested:
                raise AuthorizationError("AUTH_FILE_UNREQUESTED", f"tree change was not requested: {path}")
        if (
            path in manifest_deletion_files
            and path not in static_policy_allowed_files
            and record["status"] != "deleted"
        ):
            raise AuthorizationError(
                "AUTH_FILE_POLICY",
                f"purge-manifest authorization permits deletion only: {path}",
            )
    if authorization_mode == "path-roots":
        computed_authorized_files = _validate_path_root_delta(
            repo_root,
            delta,
            selected_roots=selected_roots,
            protected_paths=protected_paths,
            maximum_changed_files=int(
                normalized_intake["requested_max_changed_files"]
            ),
            maximum_changed_bytes=int(
                normalized_intake["requested_max_changed_bytes"]
            ),
        )

    intake_digest = hashlib.sha256(canonical_json_bytes(normalized_intake)).hexdigest()
    required_checks, command_digests, proof_command_bindings = _required_validation_commands(
        command_manifest,
        str(normalized_intake["requested_task_type"]),
        tuple(str(item) for item in normalized_intake["requested_scope"]),
        tuple(str(item) for item in task_rule["required_checks"]),
        tuple(str(item) for item in task_rule["proof_obligations"]),
    )
    workflow = command_manifest["trusted_workflow"]
    approval_digests: list[str] = []
    approval_nonce_consumptions: list[dict[str, object]] = []
    seen_nonces: set[str] = set()
    consumed_nonces = set(nonce_snapshot["consumed_nonces"])
    for attestation in approval_attestations:
        digest = approval_attestation_digest(
            attestation,
            verification_epoch=verification_epoch,
            trust_anchors=trust_anchors,
        )
        _match_approval(
            attestation,
            normalized_event,
            normalized_intake,
            intake_digest,
            normalized_policy,
            recomputed_bindings,
            workflow,
            task_rule,
        )
        nonce = str(attestation["one_time_use_nonce"])
        if nonce in consumed_nonces or nonce in seen_nonces:
            raise AuthorizationError(
                "AUTH_APPROVAL_REUSED",
                "approval nonce is already consumed or duplicated",
            )
        seen_nonces.add(nonce)
        approval_digests.append(digest)
        approval_nonce_consumptions.append(
            {
                "nonce": nonce,
                "attestation_id": str(attestation["attestation_id"]),
                "attestation_digest": digest,
                "consumption_snapshot_sha256": str(
                    recomputed_bindings["approval_nonce_consumption_sha256"]
                ),
                "consumption_generation": normalized_event[
                    "consumption_generation"
                ],
                "workflow_run_id": normalized_event["workflow_run_id"],
                "workflow_run_attempt": normalized_event[
                    "workflow_run_attempt"
                ],
                "event_projection_digest": str(
                    normalized_event["event_projection_digest"]
                ),
            }
        )
    approval_required = (
        authorization_mode == "path-roots"
        or bool(task_rule["approval_required"])
        or any(
            _is_sensitive_authorization_path(path)
            for path in computed_authorized_files
        )
    )
    if approval_required and not approval_digests:
        raise AuthorizationError("AUTH_APPROVAL_MISSING", "trusted approval is required")

    result: dict[str, object] = {
        "schema_version": 1,
        "mode": mode,
        "authority_class": "advisory-local" if mode == "local-advisory" else "ci-candidate",
        "intake": normalized_intake,
        "intake_digest": intake_digest,
        "trusted_event_provenance": normalized_event,
        "trusted_bindings": normalized_bindings,
        "tree_delta": delta,
        "local_state": local_state,
        "computed_authorized_files": computed_authorized_files,
        "computed_required_checks": required_checks,
        "computed_command_digests": command_digests,
        "computed_proof_command_bindings": proof_command_bindings,
        "computed_proof_obligations": task_rule["proof_obligations"],
        "computed_claim_ceiling": task_rule["maximum_claim_ceiling"],
        "resolved_skill_adapters": resolved_skill_adapters,
        "skill_conformance_sha256": skill_context["conformance_sha256"],
        "approval_attestation_digests": sorted(approval_digests),
        "approval_nonce_consumptions": sorted(
            approval_nonce_consumptions, key=lambda item: item["nonce"]
        ),
        "exact_diff_authorized": False,
        "merge_authorized": False,
    }
    return validate_task_authorization(result)


def task_finalize(
    *,
    repo_root: Path,
    authorization: Mapping[str, object],
    intake_data: Mapping[str, object],
    trusted_event_data: Mapping[str, object],
    trusted_bindings: Mapping[str, object],
    policy_data: Mapping[str, object],
    approval_attestations: Sequence[Mapping[str, object]],
    validation_attestations: Sequence[Mapping[str, object]],
    verification_epoch: int,
    evaluation_epoch: int | None = None,
    delegation_start_authorization: Mapping[str, object] | None = None,
    delegation_start_event: Mapping[str, object] | None = None,
    delegation_start_approval: Mapping[str, object] | None = None,
) -> dict[str, object]:
    """Recompute every binding and authorize only the exact final tree delta."""

    validate_task_authorization(authorization)
    if dict(trusted_event_data) != authorization.get("trusted_event_provenance"):
        raise AuthorizationError("AUTH_EVENT_STALE", "trusted event changed after task start")
    if dict(trusted_bindings) != authorization.get("trusted_bindings"):
        raise AuthorizationError("AUTH_BINDING_STALE", "trusted state changed after task start")
    normalized_intake = validate_task_intake(intake_data)
    effective_evaluation_epoch = (
        max(verification_epoch, int(time.time()))
        if evaluation_epoch is None
        else evaluation_epoch
    )
    intake_digest = hashlib.sha256(canonical_json_bytes(normalized_intake)).hexdigest()
    if intake_digest != authorization.get("intake_digest"):
        raise AuthorizationError("AUTH_INTAKE_STALE", "request changed after task start")

    event_data = dict(trusted_event_data)
    recomputed = task_start(
        repo_root=repo_root,
        mode=str(authorization.get("mode")),
        intake_data=intake_data,
        trusted_event_data=trusted_event_data,
        trusted_bindings=trusted_bindings,
        policy_data=policy_data,
        approval_attestations=approval_attestations,
        verification_epoch=verification_epoch,
        evaluation_epoch=effective_evaluation_epoch,
    )
    immutable_keys = (
        "schema_version",
        "mode",
        "authority_class",
        "intake",
        "intake_digest",
        "trusted_event_provenance",
        "trusted_bindings",
        "computed_authorized_files",
        "computed_required_checks",
        "computed_command_digests",
        "computed_proof_command_bindings",
        "computed_proof_obligations",
        "computed_claim_ceiling",
        "resolved_skill_adapters",
        "skill_conformance_sha256",
        "approval_attestation_digests",
        "approval_nonce_consumptions",
        "exact_diff_authorized",
        "merge_authorized",
    )
    if recomputed["mode"] == "ci-pr-range":
        immutable_keys = (*immutable_keys, "tree_delta", "local_state")
    if any(
        canonical_json_bytes(recomputed.get(key))
        != canonical_json_bytes(authorization.get(key))
        for key in immutable_keys
    ):
        raise AuthorizationError(
            "AUTH_ENVELOPE_STALE", "authorization no longer regenerates exactly"
        )

    (
        delegation_start_authorization_digest,
        delegation_start_event_provenance,
    ) = _validate_delegation_start(
        repo_root=repo_root,
        current_authorization=recomputed,
        policy_data=policy_data,
        evaluation_epoch=effective_evaluation_epoch,
        delegation_start_authorization=delegation_start_authorization,
        delegation_start_event=delegation_start_event,
        delegation_start_approval=delegation_start_approval,
    )

    required_checks = set(recomputed["computed_required_checks"])
    by_command: dict[str, Mapping[str, object]] = {}
    authorization_digest = hashlib.sha256(
        canonical_json_bytes(dict(authorization))
    ).hexdigest()
    (
        _normalized_policy,
        _bindings,
        command_manifest,
        trust_anchors,
        _nonce_snapshot,
        _skill_context,
    ) = _load_base_trust_state(
        repo_root,
        str(event_data["trusted_base_sha"]),
        normalized_intake,
        policy_data,
    )
    workflow = command_manifest["trusted_workflow"]
    validation_digests: dict[str, str] = {}
    for attestation in validation_attestations:
        digest = validation_attestation_digest(
            attestation, trust_anchors=trust_anchors
        )
        command_id = str(attestation["command_id"])
        if command_id in by_command:
            raise AuthorizationError("AUTH_VALIDATION_DUPLICATE", "duplicate validation attestation")
        if command_id not in required_checks:
            raise AuthorizationError(
                "AUTH_VALIDATION_UNEXPECTED",
                f"validation is not required by trusted policy: {command_id}",
            )
        by_command[command_id] = attestation
        validation_digests[command_id] = digest
    missing = sorted(required_checks - set(by_command))
    if missing and recomputed["mode"] == "ci-pr-range":
        raise AuthorizationError("AUTH_VALIDATION_MISSING", f"missing validation: {missing[0]}")
    for command_id in sorted(required_checks):
        if command_id not in by_command:
            continue
        attestation = by_command[command_id]
        expected = {
            "pull_request_number": event_data["pull_request_number"],
            "task_id": normalized_intake["task_id"],
            "intake_id": normalized_intake["intake_id"],
            "intake_digest": intake_digest,
            "policy_revision": trusted_bindings["policy_revision"],
            "authorization_digest": authorization_digest,
            "command_manifest_digest": trusted_bindings["command_manifest_sha256"],
            "repository_id": event_data["repository_id"],
            "repository_full_name": event_data["repository_full_name"],
            "trusted_base_sha": event_data["trusted_base_sha"],
            "trusted_head_sha": event_data["trusted_head_sha"],
            "merge_base_sha": event_data["merge_base_sha"],
            "command_argv_digest": recomputed["computed_command_digests"][command_id],
            "workflow_path": workflow["path"],
            "workflow_ref": workflow["ref"],
            "workflow_digest": workflow["digest"],
            "check_identity": workflow["check_identity"],
            "integration_id": workflow["integration_id"],
            "app_id": workflow["app_id"],
            "claim_ceiling": recomputed["computed_claim_ceiling"],
        }
        if any(attestation.get(key) != value for key, value in expected.items()):
            raise AuthorizationError("AUTH_VALIDATION_MISMATCH", "validation binding mismatch")
        expected_proof = recomputed["computed_proof_command_bindings"][command_id]
        if sorted(attestation["proof_obligation_ids"]) != expected_proof:
            raise AuthorizationError(
                "AUTH_PROOF_EVIDENCE_MISMATCH",
                "validation proof claims differ from base-owned command policy",
            )
    independent_commands = {
        command_id
        for command_id, obligations in recomputed[
            "computed_proof_command_bindings"
        ].items()
        if obligations == ["independent-review"]
    }
    independent_artifacts = {
        str(by_command[command_id]["artifact_digest"])
        for command_id in independent_commands & set(by_command)
    }
    other_artifacts = {
        str(attestation["artifact_digest"])
        for command_id, attestation in by_command.items()
        if command_id not in independent_commands
    }
    if independent_artifacts & other_artifacts:
        raise AuthorizationError(
            "AUTH_PROOF_EVIDENCE_MISMATCH",
            "independent review must use a distinct evidence artifact",
        )
    proof_obligations = set(recomputed["computed_proof_obligations"])
    proof_evidence: dict[str, list[str]] = {
        obligation: [] for obligation in sorted(proof_obligations)
    }
    for command_id, attestation in sorted(by_command.items()):
        claimed = set(str(item) for item in attestation["proof_obligation_ids"])
        unexpected = sorted(claimed - proof_obligations)
        if unexpected:
            raise AuthorizationError(
                "AUTH_PROOF_EVIDENCE_UNKNOWN",
                f"validation claims unknown proof obligation: {unexpected[0]}",
            )
        for obligation in sorted(claimed):
            proof_evidence[obligation].append(validation_digests[command_id])
    missing_proof = sorted(
        obligation
        for obligation, evidence in proof_evidence.items()
        if not evidence
    )
    if missing_proof and recomputed["mode"] == "ci-pr-range":
        raise AuthorizationError(
            "AUTH_PROOF_EVIDENCE_MISSING",
            f"missing trusted proof evidence: {missing_proof[0]}",
        )
    receipt = {
        "schema_version": 1,
        "receipt_type": "task-finalization",
        "mode": recomputed["mode"],
        "authority_class": (
            "advisory-local-finalization"
            if recomputed["mode"] == "local-advisory"
            else "ci-pr-range-finalization"
        ),
        "authorization_digest": authorization_digest,
        "intake_digest": intake_digest,
        "trusted_event_provenance": recomputed["trusted_event_provenance"],
        "trusted_bindings": recomputed["trusted_bindings"],
        "starting_tree_delta": authorization["tree_delta"],
        "final_tree_delta": recomputed["tree_delta"],
        "computed_authorized_files": recomputed["computed_authorized_files"],
        "exact_changed_files": sorted(
            _record_path(record) for record in recomputed["tree_delta"]["records"]
        ),
        "validation_attestation_digests": sorted(
            validation_digests.values()
        ),
        "approval_nonce_consumptions": recomputed[
            "approval_nonce_consumptions"
        ],
        "proof_obligation_evidence": proof_evidence,
        "scope_expansion_records": _scope_expansion_records(
            repo_root,
            recomputed,
        ),
        "delegation_start_authorization_digest": (
            delegation_start_authorization_digest
        ),
        "delegation_start_event_provenance": (
            delegation_start_event_provenance
        ),
        "exact_diff_authorized": True,
        "merge_authorized": recomputed["mode"] == "ci-pr-range",
        "claim_ceiling": recomputed["computed_claim_ceiling"],
    }
    return validate_task_finalization_receipt(receipt)


def _validate_trusted_event(
    repo_root: Path,
    data: Mapping[str, object],
) -> dict[str, object]:
    fields = frozenset(data) if isinstance(data, Mapping) else frozenset()
    if fields not in {_EVENT_FIELDS, _EVENT_FIELDS | _EVENT_DELEGATION_FIELDS}:
        raise AuthorizationError(
            "AUTH_EVENT_FIELDS", "fields do not match closed contract"
        )
    _require_version(data)
    normalized = dict(data)
    for field in (
        "event_provider",
        "event_attestation_origin",
        "repository_id",
        "repository_full_name",
        "base_ref",
        "trusted_base_sha",
        "trusted_head_sha",
        "merge_base_sha",
        "event_projection_digest",
    ):
        _string(data, field)
    if isinstance(data["pull_request_number"], bool) or not isinstance(
        data["pull_request_number"], int
    ) or data["pull_request_number"] <= 0:
        raise AuthorizationError("AUTH_EVENT_FIELDS", "pull request number must be positive")
    if (
        isinstance(data["verification_epoch"], bool)
        or not isinstance(data["verification_epoch"], int)
        or data["verification_epoch"] <= 0
    ):
        raise AuthorizationError(
            "AUTH_VERIFICATION_EPOCH",
            "trusted event verification epoch must be positive",
        )
    if "expires_at_epoch" in data:
        expiry = data["expires_at_epoch"]
        if (
            isinstance(expiry, bool)
            or not isinstance(expiry, int)
            or expiry <= data["verification_epoch"]
        ):
            raise AuthorizationError(
                "AUTH_EVENT_FIELDS", "signed event expiry must follow its epoch"
            )
    for field in (
        "workflow_run_id",
        "workflow_run_attempt",
        "consumption_generation",
    ):
        value = data[field]
        if isinstance(value, bool) or not isinstance(value, int) or value < 0:
            raise AuthorizationError(
                "AUTH_EVENT_FIELDS", f"{field} must be a non-negative integer"
            )
    if data["consumption_generation"] <= 0:
        raise AuthorizationError(
            "AUTH_EVENT_FIELDS", "consumption generation must be positive"
        )
    origin = data["event_attestation_origin"]
    if origin == "trusted-ci":
        if data["workflow_run_id"] <= 0 or data["workflow_run_attempt"] <= 0:
            raise AuthorizationError(
                "AUTH_EVENT_FIELDS",
                "trusted CI event requires positive run ID and attempt",
            )
        for field in _EVENT_SIGNATURE_FIELDS:
            _string(data, field)
        _sha256(data["trust_anchor_sha256"], "AUTH_EVENT_FIELDS")
    elif origin == "local-advisory":
        if data["workflow_run_id"] != 0 or data["workflow_run_attempt"] != 0:
            raise AuthorizationError(
                "AUTH_EVENT_FIELDS", "local event cannot claim a workflow run"
            )
        if any(data[field] is not None for field in _EVENT_SIGNATURE_FIELDS):
            raise AuthorizationError(
                "AUTH_EVENT_FIELDS", "local event cannot claim a platform signature"
            )
    else:
        raise AuthorizationError(
            "AUTH_EVENT_FIELDS", "event attestation origin is unsupported"
        )
    _sha256(data["event_projection_digest"], "AUTH_EVENT_FIELDS")
    expected_projection_digest = trusted_event_projection_digest(data)
    if data["event_projection_digest"] != expected_projection_digest:
        raise AuthorizationError(
            "AUTH_EVENT_DIGEST", "trusted event projection digest mismatch"
        )
    if data["event_provider"] != "github":
        raise AuthorizationError(
            "AUTH_EVENT_FIELDS", "event provider must be github"
        )
    normalized["issue_state_transition"] = _validate_issue_state_transition(
        data["issue_state_transition"]
    )
    if (
        origin == "local-advisory"
        and normalized["issue_state_transition"]["completed_task_receipts"]
    ):
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION",
            "unsigned local events cannot assert predecessor completion",
        )
    for field in ("trusted_base_sha", "trusted_head_sha", "merge_base_sha"):
        _git_oid(data[field], "AUTH_EVENT_FIELDS")
    if not str(data["base_ref"]).startswith("refs/heads/"):
        raise AuthorizationError("AUTH_EVENT_FIELDS", "base_ref must be a full heads ref")
    repo = repo_root.resolve()
    _require_git_object(repo, str(data["trusted_base_sha"]))
    _require_git_object(repo, str(data["trusted_head_sha"]))
    try:
        observed_base = _git(repo, "rev-parse", "--verify", str(data["base_ref"])).decode().strip()
    except AuthorizationError as exc:
        raise AuthorizationError("AUTH_BASE_REF_MISSING", "trusted base ref is unavailable") from exc
    if observed_base != data["trusted_base_sha"]:
        raise AuthorizationError("AUTH_BASE_MOVED", "trusted base ref no longer names trusted base SHA")
    actual_merge_base = _git(
        repo,
        "merge-base",
        str(data["trusted_base_sha"]),
        str(data["trusted_head_sha"]),
    ).decode().strip()
    if actual_merge_base != data["merge_base_sha"]:
        raise AuthorizationError("AUTH_MERGE_BASE_MISMATCH", "trusted merge base is inconsistent")
    return normalized


def _validate_bindings(data: Mapping[str, object]) -> dict[str, object]:
    _require_closed_mapping(data, _BINDING_FIELDS, "AUTH_BINDING_FIELDS")
    revision = data["canon_revision"]
    if isinstance(revision, bool) or not isinstance(revision, int) or revision < 0:
        raise AuthorizationError("AUTH_BINDING_FIELDS", "canon revision must be non-negative")
    for field in _BINDING_FIELDS - {"canon_revision"}:
        _string(data, field)
    for field in _HEX_SHA256_FIELDS:
        _sha256(data[field], "AUTH_BINDING_FIELDS")
    return dict(data)


def _validate_policy(data: Mapping[str, object]) -> dict[str, object]:
    if not isinstance(data, Mapping) or set(data) != _POLICY_REQUIRED_FIELDS:
        raise AuthorizationError("AUTH_POLICY_FIELDS", "policy fields do not match contract")
    _require_version(data)
    normalized: dict[str, object] = {
        "schema_version": 1,
        "policy_revision": _string(data, "policy_revision"),
        "schema_revision": _string(data, "schema_revision"),
        "compiler_version": _string(data, "compiler_version"),
        "approval_trust_anchor_id": _string(data, "approval_trust_anchor_id"),
        "event_trust_anchor_id": _string(data, "event_trust_anchor_id"),
        "validation_trust_anchor_id": _string(data, "validation_trust_anchor_id"),
    }
    identity = data["repository_identity"]
    if not isinstance(identity, Mapping) or set(identity) != _REPOSITORY_IDENTITY_FIELDS:
        raise AuthorizationError(
            "AUTH_POLICY_FIELDS", "repository identity fields do not match contract"
        )
    normalized["repository_identity"] = {
        "repository_id": _string(identity, "repository_id"),
        "repository_full_name": _string(identity, "repository_full_name"),
    }
    trust_anchors = _validate_trust_anchors(data["trust_anchors"])
    if trust_anchors["repository_identity"] != normalized["repository_identity"]:
        raise AuthorizationError(
            "AUTH_REPOSITORY_MISMATCH",
            "embedded trust anchors and authorization policy identify different repositories",
        )
    normalized["trust_anchors"] = trust_anchors
    normalized["approval_nonce_state"] = _validate_nonce_consumption_snapshot(
        data["approval_nonce_state"]
    )
    normalized["issue_state"] = _validate_issue_snapshot(data["issue_state"])
    raw_approval_policies = data["approval_policies"]
    if not isinstance(raw_approval_policies, list) or not raw_approval_policies:
        raise AuthorizationError(
            "AUTH_POLICY_FIELDS", "approval policies must be non-empty"
        )
    approval_policies: list[dict[str, object]] = []
    approval_policy_refs: set[str] = set()
    for raw_approval_policy in raw_approval_policies:
        if (
            not isinstance(raw_approval_policy, Mapping)
            or set(raw_approval_policy) != _APPROVAL_POLICY_FIELDS
        ):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "approval policy fields do not match contract"
            )
        policy_id = _string(raw_approval_policy, "policy_id")
        policy_revision = _string(raw_approval_policy, "policy_revision")
        reference = f"{policy_id}@{policy_revision}"
        if reference in approval_policy_refs:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", f"duplicate approval policy: {reference}"
            )
        approval_policy_refs.add(reference)
        break_glass_allowed = raw_approval_policy["break_glass_allowed"]
        if not isinstance(break_glass_allowed, bool):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "break_glass_allowed must be boolean"
            )
        approval_policies.append(
            {
                "policy_id": policy_id,
                "policy_revision": policy_revision,
                "authenticated_principals": _string_list(
                    raw_approval_policy,
                    "authenticated_principals",
                    allow_empty=False,
                ),
                "break_glass_allowed": break_glass_allowed,
            }
        )
    normalized["approval_policies"] = sorted(
        approval_policies,
        key=lambda item: (str(item["policy_id"]), str(item["policy_revision"])),
    )
    snapshots = data["snapshot_paths"]
    if not isinstance(snapshots, Mapping) or set(snapshots) != _SNAPSHOT_PATH_FIELDS:
        raise AuthorizationError(
            "AUTH_POLICY_FIELDS", "snapshot paths do not match contract"
        )
    normalized_snapshots: dict[str, object] = {}
    for name in sorted(_SNAPSHOT_PATH_FIELDS - {"authorization_schemas"}):
        normalized_snapshots[name] = _canonical_repo_path(
            _string(snapshots, name), "AUTH_POLICY_PATH"
        )
    schema_paths = _string_list(
        snapshots, "authorization_schemas", allow_empty=False
    )
    normalized_snapshots["authorization_schemas"] = [
        _canonical_repo_path(item, "AUTH_POLICY_PATH") for item in schema_paths
    ]
    normalized["snapshot_paths"] = normalized_snapshots

    raw_rules = data["task_rules"]
    if not isinstance(raw_rules, list) or not raw_rules:
        raise AuthorizationError("AUTH_POLICY_FIELDS", "task_rules must be non-empty")
    normalized_rules: list[dict[str, object]] = []
    task_ids: set[str] = set()
    for raw in raw_rules:
        raw_fields = frozenset(raw) if isinstance(raw, Mapping) else frozenset()
        if (
            not isinstance(raw, Mapping)
            or not _TASK_RULE_FIELDS <= raw_fields
            or not raw_fields <= _TASK_RULE_FIELDS | _TASK_RULE_OPTIONAL_FIELDS
        ):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "task rule fields do not match contract"
            )
        task_id = _string(raw, "task_id")
        if task_id in task_ids:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", f"duplicate task rule: {task_id}"
            )
        task_ids.add(task_id)
        authorized_files = [
            _canonical_authorized_file(item)
            for item in _string_list(raw, "authorized_files", allow_empty=False)
        ]
        if any(item in {"", "."} for item in authorized_files):
            raise AuthorizationError(
                "AUTH_POLICY_PATH_ROOT", "repository-root authorization is forbidden"
            )
        authorization_modes = _string_list(
            raw,
            "authorization_modes",
            allow_empty=False,
        ) if "authorization_modes" in raw else ["exact-files"]
        if not set(authorization_modes) <= {"exact-files", "path-roots"}:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "task authorization mode is invalid"
            )
        delegated_task_types = (
            _string_list(
                raw,
                "delegated_task_types",
                allow_empty="path-roots" not in authorization_modes,
            )
            if "delegated_task_types" in raw
            else []
        )
        if not set(delegated_task_types) <= set(
            _string_list(raw, "task_types", allow_empty=False)
        ):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS",
                "delegated task types must be a subset of task rule types",
            )
        delegated_scope_mode = (
            _string(raw, "delegated_scope_mode")
            if "delegated_scope_mode" in raw
            else "exact-rule-subset"
        )
        delegated_requirement_mode = (
            _string(raw, "delegated_requirement_mode")
            if "delegated_requirement_mode" in raw
            else "exact-rule-subset"
        )
        if delegated_scope_mode not in {
            "exact-rule-subset",
            "base-canon-concepts",
        } or delegated_requirement_mode not in {
            "exact-rule-subset",
            "base-canon-requirements",
        }:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "delegated canon domain mode is invalid"
            )
        authorized_path_roots = [
            _canonical_repo_path(item, "AUTH_POLICY_PATH")
            for item in _string_list(
                raw,
                "authorized_path_roots",
                allow_empty="path-roots" not in authorization_modes,
            )
        ] if "authorized_path_roots" in raw else []
        protected_paths = [
            _canonical_repo_path(item, "AUTH_POLICY_PATH")
            for item in _string_list(
                raw, "protected_paths", allow_empty=True
            )
        ] if "protected_paths" in raw else []
        if "path-roots" in authorization_modes and not authorized_path_roots:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "path-root mode requires bounded roots"
            )
        if "path-roots" in authorization_modes and not delegated_task_types:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "path-root mode requires delegated task types"
            )
        if "path-roots" in authorization_modes and (
            delegated_scope_mode != "base-canon-concepts"
            or delegated_requirement_mode != "base-canon-requirements"
        ):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS",
                "path-root mode requires base-canon scope and requirement domains",
            )
        maximum_changed_files = (
            _nonnegative_integer(
                raw.get("maximum_changed_files"), "AUTH_POLICY_FIELDS"
            )
            if "maximum_changed_files" in raw
            else 0
        )
        maximum_changed_bytes = (
            _nonnegative_integer(
                raw.get("maximum_changed_bytes"), "AUTH_POLICY_FIELDS"
            )
            if "maximum_changed_bytes" in raw
            else 0
        )
        if "path-roots" in authorization_modes and (
            maximum_changed_files == 0 or maximum_changed_bytes == 0
        ):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "path-root mode requires change budgets"
            )
        approval_required = raw["approval_required"]
        if not isinstance(approval_required, bool):
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS", "approval_required must be boolean"
            )
        task_approval_policy_ids = _string_list(
            raw, "approval_policy_ids", allow_empty=False
        )
        unknown_approval_policies = sorted(
            set(task_approval_policy_ids) - approval_policy_refs
        )
        if unknown_approval_policies:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS",
                f"task names unknown approval policy: {unknown_approval_policies[0]}",
            )
        proof_obligations = _string_list(
            raw, "proof_obligations", allow_empty=False
        )
        missing_mandatory_proof = sorted(
            _MANDATORY_PROOF_OBLIGATIONS - set(proof_obligations)
        )
        if missing_mandatory_proof:
            raise AuthorizationError(
                "AUTH_POLICY_FIELDS",
                f"mandatory proof obligation is absent: {missing_mandatory_proof[0]}",
            )
        normalized_rules.append(
            {
                "task_id": task_id,
                "issue_reference": _string(raw, "issue_reference"),
                "task_types": _string_list(raw, "task_types", allow_empty=False),
                "scopes": _string_list(raw, "scopes", allow_empty=False),
                "requirement_ids": _string_list(
                    raw, "requirement_ids", allow_empty=False
                ),
                "source_owner": _string(raw, "source_owner"),
                "authorized_files": sorted(authorized_files),
                "required_checks": _string_list(
                    raw, "required_checks", allow_empty=False
                ),
                "proof_obligations": proof_obligations,
                "maximum_claim_ceiling": _string(raw, "maximum_claim_ceiling"),
                "approval_required": approval_required,
                "approval_policy_ids": task_approval_policy_ids,
                "authorization_modes": authorization_modes,
                "delegated_task_types": delegated_task_types,
                "delegated_scope_mode": delegated_scope_mode,
                "delegated_requirement_mode": delegated_requirement_mode,
                "authorized_path_roots": sorted(authorized_path_roots),
                "protected_paths": sorted(protected_paths),
                "maximum_changed_files": maximum_changed_files,
                "maximum_changed_bytes": maximum_changed_bytes,
                "authorized_deletion_manifest": (
                    _canonical_repo_path(
                        _string(raw, "authorized_deletion_manifest"),
                        "AUTH_POLICY_PATH",
                    )
                    if raw.get("authorized_deletion_manifest") is not None
                    else None
                ),
            }
        )
    normalized["task_rules"] = sorted(
        normalized_rules, key=lambda item: str(item["task_id"])
    )
    return normalized


def _match_approval(
    attestation: Mapping[str, object],
    event: Mapping[str, object],
    intake: Mapping[str, object],
    intake_digest: str,
    policy: Mapping[str, object],
    bindings: Mapping[str, object],
    workflow: Mapping[str, object],
    task_rule: Mapping[str, object],
) -> None:
    expected = {
        "repository_id": event["repository_id"],
        "repository_full_name": event["repository_full_name"],
        "pull_request_number": event["pull_request_number"],
        "trusted_base_sha": event["trusted_base_sha"],
        "trusted_head_sha": event["trusted_head_sha"],
        "merge_base_sha": event["merge_base_sha"],
        "task_id": intake["task_id"],
        "intake_id": intake["intake_id"],
        "intake_digest": intake_digest,
        "policy_revision": policy["policy_revision"],
        "command_manifest_digest": bindings["command_manifest_sha256"],
        "workflow_path": workflow["path"],
        "workflow_ref": workflow["ref"],
        "workflow_digest": workflow["digest"],
        "workflow_run_id": event["workflow_run_id"],
        "workflow_run_attempt": event["workflow_run_attempt"],
        "event_projection_digest": event["event_projection_digest"],
        "consumption_generation": event["consumption_generation"],
        "check_identity": workflow["check_identity"],
        "integration_id": workflow["integration_id"],
        "app_id": workflow["app_id"],
        "trust_anchor_id": policy["approval_trust_anchor_id"],
        "verification_epoch": event["verification_epoch"],
    }
    if any(attestation.get(key) != value for key, value in expected.items()):
        raise AuthorizationError("AUTH_APPROVAL_MISMATCH", "approval binding mismatch")
    if sorted(attestation["approved_scope"]) != sorted(intake["requested_scope"]):
        raise AuthorizationError("AUTH_APPROVAL_MISMATCH", "approval scope mismatch")
    approval_reference = (
        f"{attestation['approval_policy_id']}@"
        f"{attestation['approval_policy_revision']}"
    )
    if approval_reference not in task_rule["approval_policy_ids"]:
        raise AuthorizationError(
            "AUTH_APPROVAL_POLICY", "approval policy is not allowed for this task"
        )
    policies = policy["approval_policies"]
    assert isinstance(policies, list)
    matches = [
        item
        for item in policies
        if f"{item['policy_id']}@{item['policy_revision']}"
        == approval_reference
    ]
    if len(matches) != 1:
        raise AuthorizationError(
            "AUTH_APPROVAL_POLICY", "approval policy is not base allowlisted"
        )
    approval_policy = matches[0]
    if attestation["authenticated_principal"] not in approval_policy[
        "authenticated_principals"
    ]:
        raise AuthorizationError(
            "AUTH_APPROVAL_POLICY", "authenticated principal is not allowlisted"
        )
    if attestation["break_glass"] is True:
        if approval_policy["break_glass_allowed"] is not True:
            raise AuthorizationError(
                "AUTH_BREAK_GLASS_FORBIDDEN",
                "approval policy does not allow break-glass",
            )
        if (
            not isinstance(attestation["incident_id"], str)
            or not str(attestation["incident_id"]).strip()
            or not isinstance(attestation["rollback_ref"], str)
            or not str(attestation["rollback_ref"]).strip()
            or attestation["post_action_review_required"] is not True
        ):
            raise AuthorizationError(
                "AUTH_BREAK_GLASS_POSTURE",
                "break-glass requires incident, rollback, and post-action review",
            )
    elif (
        attestation["incident_id"] is not None
        or attestation["rollback_ref"] is not None
        or attestation["post_action_review_required"] is not False
    ):
        raise AuthorizationError(
            "AUTH_BREAK_GLASS_POSTURE",
            "routine approval cannot claim break-glass incident posture",
        )


def load_trusted_bindings(
    repo_root: Path,
    trusted_base_sha: str,
    intake_data: Mapping[str, object],
    policy_data: Mapping[str, object],
) -> dict[str, object]:
    """Recompute public bindings from exact bytes in the trusted base tree."""

    intake = validate_task_intake(intake_data)
    _policy, bindings, _commands, _anchors, _nonces, _skills = _load_base_trust_state(
        repo_root,
        trusted_base_sha,
        intake,
        policy_data,
    )
    return bindings


def load_base_policy(repo_root: Path, trusted_base_sha: str) -> dict[str, object]:
    """Load and normalize the fixed task policy path from a trusted Git tree."""

    raw = _git_blob_at_revision(repo_root.resolve(), trusted_base_sha, _POLICY_PATH)
    data = _json_mapping(raw, "AUTH_POLICY_UNTRUSTED", _POLICY_PATH)
    return _validate_policy(data)


def load_base_nonce_consumption_generation(
    repo_root: Path,
    trusted_base_sha: str,
) -> int:
    """Load the authoritative nonce generation from the exact trusted base tree."""

    policy = load_base_policy(repo_root, trusted_base_sha)
    snapshot = policy["approval_nonce_state"]
    assert isinstance(snapshot, Mapping)
    return int(snapshot["consumption_generation"])


def _load_base_trust_state(
    repo_root: Path,
    trusted_base_sha: str,
    intake: Mapping[str, object],
    caller_policy: Mapping[str, object],
) -> tuple[
    dict[str, object],
    dict[str, object],
    dict[str, object],
    dict[str, object],
    dict[str, object],
    dict[str, object],
]:
    repo = repo_root.resolve()
    try:
        policy_bytes = _git_blob_at_revision(repo, trusted_base_sha, _POLICY_PATH)
    except AuthorizationError as exc:
        raise AuthorizationError(
            "AUTH_POLICY_UNTRUSTED", "base-owned task policy is unavailable"
        ) from exc
    base_policy_data = _json_mapping(
        policy_bytes, "AUTH_POLICY_UNTRUSTED", _POLICY_PATH
    )
    normalized_policy = _validate_policy(base_policy_data)
    try:
        normalized_caller = _validate_policy(caller_policy)
    except AuthorizationError as exc:
        raise AuthorizationError(
            "AUTH_POLICY_UNTRUSTED", "caller policy is not the base-owned policy"
        ) from exc
    if canonical_json_bytes(normalized_caller) != canonical_json_bytes(
        normalized_policy
    ):
        raise AuthorizationError(
            "AUTH_POLICY_UNTRUSTED", "caller policy differs from trusted base bytes"
        )

    snapshots = normalized_policy["snapshot_paths"]
    assert isinstance(snapshots, Mapping)
    raw_snapshots: dict[str, bytes] = {}
    for name in sorted(_SNAPSHOT_PATH_FIELDS - {"authorization_schemas"}):
        raw_snapshots[name] = _git_blob_at_revision(
            repo, trusted_base_sha, str(snapshots[name])
        )
    schema_paths = snapshots["authorization_schemas"]
    assert isinstance(schema_paths, list)
    schema_blobs = [
        (
            path,
            _git_blob_at_revision(repo, trusted_base_sha, str(path)),
        )
        for path in schema_paths
    ]

    manifest = _toml_mapping(
        raw_snapshots["canon_manifest"],
        "AUTH_SNAPSHOT_INVALID",
        str(snapshots["canon_manifest"]),
    )
    canon_revision = manifest.get("canon_revision")
    if isinstance(canon_revision, bool) or not isinstance(canon_revision, int):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", "canon manifest has no integer revision"
        )
    if manifest.get("compiler_version") != normalized_policy["compiler_version"]:
        raise AuthorizationError(
            "AUTH_SNAPSHOT_STALE", "compiler version differs from trusted policy"
        )
    canon_source_sha256 = _canon_source_digest(
        repo,
        trusted_base_sha,
        manifest,
        raw_snapshots["canon_manifest"],
    )
    for snapshot_name in (
        "source_ownership",
        "known_issues",
        "proof_state",
        "conflict_state",
    ):
        _require_projection_canon_binding(
            raw_snapshots[snapshot_name],
            str(snapshots[snapshot_name]),
            canon_revision,
            canon_source_sha256,
        )

    issue_state = normalized_policy["issue_state"]
    assert isinstance(issue_state, Mapping)
    command_manifest = _validate_command_manifest(
        _json_mapping(
            raw_snapshots["command_manifest"],
            "AUTH_COMMAND_MANIFEST_INVALID",
            str(snapshots["command_manifest"]),
        )
    )
    trust_anchors = normalized_policy["trust_anchors"]
    assert isinstance(trust_anchors, Mapping)
    policy_identity = normalized_policy["repository_identity"]
    if trust_anchors["repository_identity"] != policy_identity:
        raise AuthorizationError(
            "AUTH_REPOSITORY_MISMATCH",
            "trust-anchor registry and authorization policy identify different repositories",
        )
    nonce_snapshot = normalized_policy["approval_nonce_state"]
    assert isinstance(nonce_snapshot, Mapping)
    skill_context = _base_skill_conformance(
        repo,
        trusted_base_sha,
        raw_snapshots["skill_dependencies"],
        str(normalized_policy["compiler_version"]),
        intake,
    )
    _require_anchor_purpose(
        trust_anchors,
        str(normalized_policy["approval_trust_anchor_id"]),
        "approval",
        "AUTH_APPROVAL_SIGNATURE",
    )
    _require_anchor_purpose(
        trust_anchors,
        str(normalized_policy["event_trust_anchor_id"]),
        "event",
        "AUTH_EVENT_SIGNATURE",
    )
    _require_anchor_purpose(
        trust_anchors,
        str(normalized_policy["validation_trust_anchor_id"]),
        "validation",
        "AUTH_VALIDATION_SIGNATURE",
    )

    schema_digest = _labeled_bytes_digest(schema_blobs)
    workflow = command_manifest["trusted_workflow"]
    assert isinstance(workflow, Mapping)
    workflow_path = str(workflow["path"])
    try:
        workflow_bytes = _git_blob_at_revision(
            repo, trusted_base_sha, workflow_path
        )
    except AuthorizationError as exc:
        raise AuthorizationError(
            "AUTH_VALIDATION_WORKFLOW_MISSING",
            "base-owned trusted validation workflow is unavailable",
        ) from exc
    workflow_digest = hashlib.sha256(workflow_bytes).hexdigest()
    if workflow_digest != workflow["digest"]:
        raise AuthorizationError(
            "AUTH_VALIDATION_WORKFLOW_STALE",
            "trusted validation workflow digest does not match base bytes",
        )
    bindings = {
        "canon_revision": canon_revision,
        "canon_source_sha256": canon_source_sha256,
        "policy_sha256": hashlib.sha256(policy_bytes).hexdigest(),
        "policy_revision": normalized_policy["policy_revision"],
        "schema_revision": (
            f"{normalized_policy['schema_revision']}:{schema_digest}"
        ),
        "source_ownership_sha256": hashlib.sha256(
            raw_snapshots["source_ownership"]
        ).hexdigest(),
        "issue_state_sha256": hashlib.sha256(
            canonical_json_bytes(issue_state)
        ).hexdigest(),
        "known_issues_sha256": hashlib.sha256(
            raw_snapshots["known_issues"]
        ).hexdigest(),
        "proof_state_sha256": hashlib.sha256(
            raw_snapshots["proof_state"]
        ).hexdigest(),
        "conflict_state_sha256": hashlib.sha256(
            raw_snapshots["conflict_state"]
        ).hexdigest(),
        "skill_dependencies_sha256": hashlib.sha256(
            raw_snapshots["skill_dependencies"]
        ).hexdigest(),
        "skill_conformance_sha256": skill_context["conformance_sha256"],
        "approval_nonce_consumption_sha256": hashlib.sha256(
            canonical_json_bytes(nonce_snapshot)
        ).hexdigest(),
        "command_manifest_sha256": hashlib.sha256(
            raw_snapshots["command_manifest"]
        ).hexdigest(),
        "trust_anchors_sha256": hashlib.sha256(
            canonical_json_bytes(trust_anchors)
        ).hexdigest(),
        "validation_workflow_sha256": workflow_digest,
    }
    return (
        normalized_policy,
        _validate_bindings(bindings),
        command_manifest,
        trust_anchors,
        nonce_snapshot,
        skill_context,
    )


def _canon_source_digest(
    repo: Path,
    trusted_base_sha: str,
    manifest: Mapping[str, object],
    manifest_bytes: bytes,
) -> str:
    raw_paths = manifest.get("normative_files")
    if not isinstance(raw_paths, list) or any(
        not isinstance(path, str) or not path.strip() for path in raw_paths
    ):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", "canon manifest normative files are invalid"
        )
    canonical_paths = [
        _canonical_repo_path(path, "AUTH_SNAPSHOT_PATH") for path in raw_paths
    ]
    if canonical_paths != sorted(set(canonical_paths)):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID",
            "canon manifest normative files must be sorted and unique",
        )
    entries: list[tuple[str, bytes]] = [("MANIFEST.toml", manifest_bytes)]
    for optional in (
        "decisions/SUPERSESSION_LEDGER.toml",
        "migration/impact-reference-index.json",
    ):
        content = _git_blob_optional(
            repo, trusted_base_sha, f"docs/canon/{optional}"
        )
        if content is not None:
            entries.append((optional, content))
    for relative in canonical_paths:
        entries.append(
            (
                relative,
                _git_blob_at_revision(
                    repo, trusted_base_sha, f"docs/canon/{relative}"
                ),
            )
        )
    conflict_projection_paths = (
        "migration/source-catalog.json",
        "migration/claim-dispositions.json",
        "migration/conflict-docket-baseline.json",
    )
    conflict_projection_bytes = [
        _git_blob_optional(repo, trusted_base_sha, f"docs/canon/{relative}")
        for relative in conflict_projection_paths
    ]
    if all(content is not None for content in conflict_projection_bytes):
        entries.extend(
            (relative, content)
            for relative, content in zip(
                conflict_projection_paths,
                conflict_projection_bytes,
                strict=True,
            )
            if content is not None
        )
    elif any(content is not None for content in conflict_projection_bytes):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_STALE",
            "conflict projection snapshot is incomplete at the trusted base",
        )
    return _labeled_bytes_digest(entries)


def _git_blob_optional(repo: Path, revision: str, path: str) -> bytes | None:
    canonical = _canonical_repo_path(path, "AUTH_SNAPSHOT_PATH")
    try:
        return _git(repo, "cat-file", "blob", f"{revision}:{canonical}")
    except AuthorizationError:
        return None


def _require_projection_canon_binding(
    raw: bytes,
    path: str,
    canon_revision: int,
    canon_source_sha256: str,
) -> None:
    if path.endswith(".json"):
        data = _json_mapping(raw, "AUTH_SNAPSHOT_INVALID", path)
        projection_revision = data.get("canon_revision")
        projection_sha = data.get("canon_content_sha")
    elif path.endswith(".md"):
        try:
            text = raw.decode("utf-8")
        except UnicodeError as exc:
            raise AuthorizationError(
                "AUTH_SNAPSHOT_INVALID", f"projection is not UTF-8: {path}"
            ) from exc
        revision_match = re.search(r"Canon revision:\s*`(\d+)`", text)
        sha_match = re.search(r"Canon content SHA:\s*`([0-9a-f]{64})`", text)
        projection_revision = (
            int(revision_match.group(1)) if revision_match is not None else None
        )
        projection_sha = sha_match.group(1) if sha_match is not None else None
    else:
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", f"unsupported projection format: {path}"
        )
    if projection_revision != canon_revision or projection_sha != canon_source_sha256:
        raise AuthorizationError(
            "AUTH_SNAPSHOT_STALE",
            f"projection is not bound to current canonical bytes: {path}",
        )


def _validate_nonce_consumption_snapshot(
    data: Mapping[str, object],
) -> dict[str, object]:
    fields = {
        "schema_version",
        "snapshot_revision",
        "consumption_generation",
        "consumed_nonces",
    }
    if set(data) != fields:
        raise AuthorizationError(
            "AUTH_NONCE_SNAPSHOT_INVALID",
            "nonce-consumption snapshot fields do not match contract",
        )
    _require_version(data)
    revision = _string(data, "snapshot_revision")
    generation = data["consumption_generation"]
    if (
        isinstance(generation, bool)
        or not isinstance(generation, int)
        or generation <= 0
    ):
        raise AuthorizationError(
            "AUTH_NONCE_SNAPSHOT_INVALID",
            "nonce-consumption generation must be positive",
        )
    consumed = _string_list(data, "consumed_nonces", allow_empty=True)
    return {
        "schema_version": 1,
        "snapshot_revision": revision,
        "consumption_generation": generation,
        "consumed_nonces": consumed,
    }


def _base_skill_conformance(
    repo: Path,
    trusted_base_sha: str,
    registry_bytes: bytes,
    compiler_version: str,
    intake: Mapping[str, object],
) -> dict[str, object]:
    registry = _json_mapping(
        registry_bytes,
        "AUTH_SKILL_CONFORMANCE",
        "base skill dependency registry",
    )
    paths: set[str] = set()
    requirement_path = registry.get("requirement_index_path")
    if isinstance(requirement_path, str):
        paths.add(_canonical_repo_path(requirement_path, "AUTH_SKILL_CONFORMANCE"))
    raw_skills = registry.get("skills")
    if isinstance(raw_skills, list):
        for raw_skill in raw_skills:
            if not isinstance(raw_skill, Mapping):
                continue
            skill_path = raw_skill.get("path")
            if isinstance(skill_path, str):
                paths.add(
                    _canonical_repo_path(skill_path, "AUTH_SKILL_CONFORMANCE")
                )
            dependencies = raw_skill.get("dependencies")
            if not isinstance(dependencies, list):
                continue
            for dependency in dependencies:
                if not isinstance(dependency, Mapping):
                    continue
                dependency_path = dependency.get("path")
                if isinstance(dependency_path, str):
                    paths.add(
                        _canonical_repo_path(
                            dependency_path, "AUTH_SKILL_CONFORMANCE"
                        )
                    )
    for raw_path, entry in _git_tree_entries(repo, trusted_base_sha).items():
        if entry[1] != "blob":
            continue
        try:
            path_text = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            continue
        parts = PurePosixPath(path_text).parts
        if (
            len(parts) == 4
            and parts[:2] == (".agents", "skills")
            and parts[-1] == "SKILL.md"
        ):
            paths.add(
                _canonical_repo_path(path_text, "AUTH_SKILL_CONFORMANCE")
            )
    try:
        with tempfile.TemporaryDirectory(
            prefix="ambitions-base-skill-conformance-"
        ) as directory:
            materialized = Path(directory)
            for path in sorted(paths):
                target = materialized / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(_git_blob_at_revision(repo, trusted_base_sha, path))
            result = check_skill_conformance(
                materialized,
                registry,
                compiler_version=compiler_version,
            )
            requirement_ids: set[str] = set()
            if isinstance(requirement_path, str):
                requirement_data = _json_mapping(
                    (materialized / requirement_path).read_bytes(),
                    "AUTH_SKILL_CONFORMANCE",
                    requirement_path,
                )
                raw_requirements = requirement_data.get("requirements")
                if isinstance(raw_requirements, list):
                    for item in raw_requirements:
                        if isinstance(item, Mapping) and isinstance(
                            item.get("requirement_id"), str
                        ):
                            requirement_ids.add(str(item["requirement_id"]))
    except (AuthorizationError, SkillConformanceError, OSError) as exc:
        raise AuthorizationError(
            "AUTH_SKILL_CONFORMANCE",
            "base-owned skill registry or dependency bytes are not conformant",
        ) from exc
    requested_requirements = set(intake["requested_requirement_ids"])
    missing_requirements = sorted(requested_requirements - requirement_ids)
    if missing_requirements:
        raise AuthorizationError(
            "AUTH_SKILL_REQUIREMENT_UNKNOWN",
            f"requested requirement is absent from the base index: {missing_requirements[0]}",
        )
    skill_ids = set(str(item) for item in result["skill_ids"])
    requested_adapters = set(intake["requested_skill_adapters"])
    missing_adapters = sorted(requested_adapters - skill_ids)
    if missing_adapters:
        raise AuthorizationError(
            "AUTH_SKILL_ADAPTER_UNKNOWN",
            f"requested adapter is absent from the conformant registry: {missing_adapters[0]}",
        )
    return {
        "conformance_sha256": hashlib.sha256(
            canonical_json_bytes(result)
        ).hexdigest(),
        "skill_ids": sorted(skill_ids),
        "requirement_ids": sorted(requirement_ids),
    }


def _resolve_skill_request(
    intake: Mapping[str, object], skill_context: Mapping[str, object]
) -> list[str]:
    requested = sorted(str(item) for item in intake["requested_skill_adapters"])
    available = set(str(item) for item in skill_context["skill_ids"])
    missing = sorted(set(requested) - available)
    if missing:
        raise AuthorizationError(
            "AUTH_SKILL_ADAPTER_UNKNOWN",
            f"requested adapter is absent from trusted conformance: {missing[0]}",
        )
    return requested


def _task_rule(
    policy: Mapping[str, object], intake: Mapping[str, object]
) -> dict[str, object]:
    rules = policy["task_rules"]
    assert isinstance(rules, list)
    matches = [item for item in rules if item["task_id"] == intake["task_id"]]
    if len(matches) != 1:
        raise AuthorizationError(
            "AUTH_TASK_POLICY_MISSING", "trusted policy has no exact task rule"
        )
    rule = matches[0]
    if rule["issue_reference"] != intake["issue_reference"]:
        raise AuthorizationError(
            "AUTH_ISSUE_MISMATCH", "task rule and intake issue differ"
        )
    authorization_mode = str(
        intake.get("requested_authorization_mode", "exact-files")
    )
    if intake["requested_task_type"] not in rule["task_types"]:
        raise AuthorizationError(
            "AUTH_TASK_TYPE_POLICY", "task type is outside trusted rule"
        )
    if (
        authorization_mode == "path-roots"
        and intake["requested_task_type"] not in rule["delegated_task_types"]
    ):
        raise AuthorizationError(
            "AUTH_BOUNDARY_APPROVAL_REQUIRED",
            "task type requires renewed exact-file owner approval",
        )
    if authorization_mode == "path-roots" and _requests_hard_boundary_scope(intake):
        raise AuthorizationError(
            "AUTH_BOUNDARY_APPROVAL_REQUIRED",
            "requested scope crosses a renewed-approval boundary",
        )
    if authorization_mode != "path-roots" and not set(
        intake["requested_scope"]
    ) <= set(rule["scopes"]):
        raise AuthorizationError(
            "AUTH_SCOPE_POLICY", "requested scope is outside trusted rule"
        )
    if authorization_mode != "path-roots" and not set(
        intake["requested_requirement_ids"]
    ) <= set(rule["requirement_ids"]):
        raise AuthorizationError(
            "AUTH_REQUIREMENT_POLICY",
            "requested requirement is outside trusted rule",
        )
    return rule


def _validate_delegated_canon_domains(
    repo_root: Path,
    trusted_base_sha: str,
    policy: Mapping[str, object],
    intake: Mapping[str, object],
) -> None:
    snapshot_paths = _mapping(policy["snapshot_paths"], "AUTH_SCOPE_POLICY")
    source_ownership_path = str(snapshot_paths["source_ownership"])
    source_ownership = _json_mapping(
        _git_blob_at_revision(repo_root, trusted_base_sha, source_ownership_path),
        "AUTH_SCOPE_POLICY",
        source_ownership_path,
    )
    raw_concepts = source_ownership.get("concepts")
    if not isinstance(raw_concepts, list):
        raise AuthorizationError(
            "AUTH_SCOPE_POLICY", "base source-ownership concepts are unavailable"
        )
    concept_spec_ids = {
        str(item["concept"]): str(item["spec_id"])
        for item in raw_concepts
        if isinstance(item, Mapping)
        and isinstance(item.get("concept"), str)
        and str(item["concept"]).strip()
        and isinstance(item.get("spec_id"), str)
        and str(item["spec_id"]).strip()
    }
    requested_scopes = set(str(item) for item in intake["requested_scope"])
    missing_scopes = sorted(requested_scopes - set(concept_spec_ids))
    if missing_scopes:
        raise AuthorizationError(
            "AUTH_SCOPE_POLICY",
            f"delegated scope is outside base canon: {missing_scopes[0]}",
        )
    skill_dependencies_path = str(snapshot_paths["skill_dependencies"])
    skill_dependencies = _json_mapping(
        _git_blob_at_revision(repo_root, trusted_base_sha, skill_dependencies_path),
        "AUTH_REQUIREMENT_POLICY",
        skill_dependencies_path,
    )
    requirement_index_path = skill_dependencies.get("requirement_index_path")
    if not isinstance(requirement_index_path, str):
        raise AuthorizationError(
            "AUTH_REQUIREMENT_POLICY",
            "base requirement index path is unavailable",
        )
    requirement_index_path = _canonical_repo_path(
        requirement_index_path, "AUTH_REQUIREMENT_POLICY"
    )
    requirement_index = _json_mapping(
        _git_blob_at_revision(repo_root, trusted_base_sha, requirement_index_path),
        "AUTH_REQUIREMENT_POLICY",
        requirement_index_path,
    )
    raw_requirements = requirement_index.get("requirements")
    if not isinstance(raw_requirements, list):
        raise AuthorizationError(
            "AUTH_REQUIREMENT_POLICY", "base requirements are unavailable"
        )
    requirement_concepts = {
        str(item["requirement_id"]): str(item["concept"])
        for item in raw_requirements
        if isinstance(item, Mapping)
        and isinstance(item.get("requirement_id"), str)
        and isinstance(item.get("concept"), str)
    }
    requested_requirements = set(
        str(item) for item in intake["requested_requirement_ids"]
    )
    unknown_requirements = sorted(requested_requirements - set(requirement_concepts))
    if unknown_requirements:
        raise AuthorizationError(
            "AUTH_REQUIREMENT_POLICY",
            f"delegated requirement is outside base canon: {unknown_requirements[0]}",
        )
    incoherent_requirements = sorted(
        requirement_id
        for requirement_id in requested_requirements
        if requirement_concepts[requirement_id] not in requested_scopes
    )
    if incoherent_requirements:
        raise AuthorizationError(
            "AUTH_REQUIREMENT_POLICY",
            "delegated requirement is outside the requested canon scope: "
            f"{incoherent_requirements[0]}",
        )


def _requests_hard_boundary_scope(intake: Mapping[str, object]) -> bool:
    values = [
        str(intake["requested_task_type"]),
        *(str(item) for item in intake["requested_scope"]),
    ]
    normalized = (
        " ".join(values)
        .casefold()
        .replace("_", "-")
        .replace(".", "-")
    )
    return any(
        marker in normalized
        for marker in (
            "authority-amendment",
            "authorization-policy",
            "trust-anchor",
            "ruleset",
            "credential",
            "secret",
            "signing-material",
            "destructive",
            "mass-deletion",
            "history-rewrite",
            "production-deploy",
            "external-mutation",
            "externalmutation",
            "external-write",
            "externalwrite",
            "external-writes",
            "externalwrites",
            "external-effect",
            "externaleffect",
            "release",
            "testflight",
            "app-store",
        )
    )


def _validate_issue_snapshot(
    snapshot: object,
) -> dict[str, object]:
    if not isinstance(snapshot, Mapping):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", "issue snapshot must be an object"
        )
    if set(snapshot) != {"schema_version", "snapshot_revision", "issues"}:
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", "issue snapshot fields do not match contract"
        )
    _require_version(snapshot)
    _string(snapshot, "snapshot_revision")
    issues = snapshot["issues"]
    if not isinstance(issues, list):
        raise AuthorizationError(
            "AUTH_SNAPSHOT_INVALID", "issue snapshot must contain issues"
        )
    normalized_issues: list[dict[str, object]] = []
    for item in issues:
        if not isinstance(item, Mapping) or set(item) != {
            "issue_reference",
            "state",
            "task_ids",
            "revision",
            "prerequisite_task_ids",
        }:
            raise AuthorizationError(
                "AUTH_SNAPSHOT_INVALID", "issue entry fields do not match contract"
            )
        _string(item, "issue_reference")
        _string(item, "revision")
        _string_list(item, "task_ids", allow_empty=False)
        _string_list(item, "prerequisite_task_ids", allow_empty=True)
        if item["state"] not in {
            "open",
            "approved",
            "in_progress",
            "complete",
            "blocked",
        }:
            raise AuthorizationError(
                "AUTH_SNAPSHOT_INVALID", "issue entry state is invalid"
            )
        normalized_issues.append(
            {
                "issue_reference": str(item["issue_reference"]),
                "state": str(item["state"]),
                "task_ids": sorted(str(value) for value in item["task_ids"]),
                "revision": str(item["revision"]),
                "prerequisite_task_ids": sorted(
                    str(value) for value in item["prerequisite_task_ids"]
                ),
            }
        )
    return {
        "schema_version": 1,
        "snapshot_revision": str(snapshot["snapshot_revision"]),
        "issues": sorted(
            normalized_issues,
            key=lambda item: (
                str(item["issue_reference"]),
                tuple(item["task_ids"]),
            ),
        ),
    }


def _validate_issue_state_transition(value: object) -> dict[str, object]:
    if not isinstance(value, Mapping) or set(value) != {
        "schema_version",
        "snapshot_revision",
        "base_issue_state_sha256",
        "completed_task_receipts",
    }:
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION", "issue transition fields do not match contract"
        )
    _require_version(value)
    revision = _string(value, "snapshot_revision")
    _sha256(value["base_issue_state_sha256"], "AUTH_ISSUE_TRANSITION")
    raw_receipts = value["completed_task_receipts"]
    if not isinstance(raw_receipts, list):
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION", "completed task receipts must be an array"
        )
    receipts: list[dict[str, str]] = []
    seen: set[str] = set()
    for raw in raw_receipts:
        if not isinstance(raw, Mapping) or set(raw) != {
            "task_id",
            "finalization_receipt_sha256",
        }:
            raise AuthorizationError(
                "AUTH_ISSUE_TRANSITION", "completion receipt fields do not match contract"
            )
        task_id = _string(raw, "task_id")
        if task_id in seen:
            raise AuthorizationError(
                "AUTH_ISSUE_TRANSITION", "completed task receipt is duplicated"
            )
        seen.add(task_id)
        receipt_digest = str(raw["finalization_receipt_sha256"])
        _sha256(receipt_digest, "AUTH_ISSUE_TRANSITION")
        receipts.append(
            {
                "task_id": task_id,
                "finalization_receipt_sha256": receipt_digest,
            }
        )
    if receipts != sorted(receipts, key=lambda item: item["task_id"]):
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION", "completed task receipts must be sorted"
        )
    return {
        "schema_version": 1,
        "snapshot_revision": revision,
        "base_issue_state_sha256": str(value["base_issue_state_sha256"]),
        "completed_task_receipts": receipts,
    }


def _require_current_issue(
    snapshot: Mapping[str, object],
    intake: Mapping[str, object],
    transition: Mapping[str, object],
) -> None:
    normalized = _validate_issue_snapshot(snapshot)
    normalized_transition = _validate_issue_state_transition(transition)
    expected_snapshot_digest = hashlib.sha256(
        canonical_json_bytes(normalized)
    ).hexdigest()
    if normalized_transition["base_issue_state_sha256"] != expected_snapshot_digest:
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION_STALE",
            "issue transition does not bind the base-owned issue graph",
        )
    normalized_issues = normalized["issues"]
    assert isinstance(normalized_issues, list)
    matches = [
        item
        for item in normalized_issues
        if item.get("issue_reference") == intake["issue_reference"]
        and intake["task_id"] in item.get("task_ids", [])
    ]
    if len(matches) != 1:
        raise AuthorizationError(
            "AUTH_ISSUE_STALE", "current issue is missing from trusted snapshot"
        )
    issue = matches[0]
    if issue["state"] not in {"open", "approved", "in_progress"}:
        raise AuthorizationError(
            "AUTH_ISSUE_STALE", "current issue state does not permit task start"
        )
    statically_completed = {
        task_id
        for item in normalized_issues
        if item["state"] == "complete"
        for task_id in item["task_ids"]
    }
    receipt_tasks = {
        str(item["task_id"])
        for item in normalized_transition["completed_task_receipts"]
    }
    known_tasks = {
        task_id for item in normalized_issues for task_id in item["task_ids"]
    }
    unknown_receipts = sorted(receipt_tasks - known_tasks)
    if unknown_receipts:
        raise AuthorizationError(
            "AUTH_ISSUE_TRANSITION_FORGED",
            f"completion receipt names unknown task: {unknown_receipts[0]}",
        )
    completed_tasks = statically_completed | receipt_tasks
    if intake["task_id"] in completed_tasks:
        raise AuthorizationError(
            "AUTH_ISSUE_STALE", "current task is already completed"
        )
    by_task = {
        task_id: item
        for item in normalized_issues
        for task_id in item["task_ids"]
    }
    for completed_task in sorted(receipt_tasks):
        skipped = sorted(
            set(by_task[completed_task]["prerequisite_task_ids"])
            - completed_tasks
        )
        if skipped:
            raise AuthorizationError(
                "AUTH_ISSUE_TRANSITION_SKIPPED",
                f"completed task skipped prerequisite: {skipped[0]}",
            )
    missing_prerequisites = sorted(
        set(issue["prerequisite_task_ids"]) - completed_tasks
    )
    if missing_prerequisites:
        raise AuthorizationError(
            "AUTH_ISSUE_BLOCKED",
            f"prerequisite task is not complete: {missing_prerequisites[0]}",
        )


def _validate_command_manifest(data: Mapping[str, object]) -> dict[str, object]:
    if set(data) != {
        "schema_version",
        "manifest_revision",
        "trusted_workflow",
        "commands",
    }:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID", "manifest fields do not match contract"
        )
    _require_version(data)
    revision = _string(data, "manifest_revision")
    workflow = data["trusted_workflow"]
    workflow_fields = {
        "path",
        "ref",
        "digest",
        "check_identity",
        "integration_id",
        "app_id",
    }
    if not isinstance(workflow, Mapping) or set(workflow) != workflow_fields:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID", "workflow fields do not match contract"
        )
    normalized_workflow = {
        field: _string(workflow, field) for field in sorted(workflow_fields)
    }
    _sha256(normalized_workflow["digest"], "AUTH_COMMAND_MANIFEST_INVALID")
    raw_commands = data["commands"]
    if not isinstance(raw_commands, list) or not raw_commands:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID", "commands must be non-empty"
        )
    commands: list[dict[str, object]] = []
    seen: set[str] = set()
    for raw in raw_commands:
        fields = {
            "command_id",
            "argv",
            "required_for_task_types",
            "required_for_scenarios",
            "proof_obligation_ids",
            "evidence_class",
        }
        if not isinstance(raw, Mapping) or set(raw) != fields:
            raise AuthorizationError(
                "AUTH_COMMAND_MANIFEST_INVALID",
                "command fields do not match contract",
            )
        command_id = _string(raw, "command_id")
        if command_id in seen:
            raise AuthorizationError(
                "AUTH_COMMAND_MANIFEST_INVALID", "duplicate command id"
            )
        seen.add(command_id)
        argv = _ordered_string_list(raw, "argv", allow_empty=False)
        proof_obligation_ids = _string_list(
            raw, "proof_obligation_ids", allow_empty=False
        )
        evidence_class = _string(raw, "evidence_class")
        if evidence_class not in {"automated-validation", "independent-review"}:
            raise AuthorizationError(
                "AUTH_COMMAND_MANIFEST_INVALID", "command evidence class is invalid"
            )
        if (evidence_class == "independent-review") != (
            proof_obligation_ids == ["independent-review"]
        ):
            raise AuthorizationError(
                "AUTH_COMMAND_MANIFEST_INVALID",
                "independent review must have a dedicated command and proof binding",
            )
        commands.append(
            {
                "command_id": command_id,
                "argv": argv,
                "required_for_task_types": _string_list(
                    raw, "required_for_task_types", allow_empty=True
                ),
                "required_for_scenarios": _string_list(
                    raw, "required_for_scenarios", allow_empty=True
                ),
                "proof_obligation_ids": proof_obligation_ids,
                "evidence_class": evidence_class,
            }
        )
    independent = [
        item for item in commands if item["evidence_class"] == "independent-review"
    ]
    if len(independent) != 1:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID",
            "exactly one independent-review evidence command is required",
        )
    return {
        "schema_version": 1,
        "manifest_revision": revision,
        "trusted_workflow": normalized_workflow,
        "commands": sorted(commands, key=lambda item: str(item["command_id"])),
    }


def _required_validation_commands(
    manifest: Mapping[str, object],
    task_type: str,
    scopes: tuple[str, ...],
    rule_required: tuple[str, ...],
    rule_proof_obligations: tuple[str, ...],
) -> tuple[list[str], dict[str, str], dict[str, list[str]]]:
    commands = manifest["commands"]
    assert isinstance(commands, list)
    selected: dict[str, dict[str, object]] = {}
    for command in commands:
        command_id = str(command["command_id"])
        if (
            task_type in command["required_for_task_types"]
            or set(scopes) & set(command["required_for_scenarios"])
            or command_id in rule_required
        ):
            selected[command_id] = dict(command)
    missing = sorted(set(rule_required) - set(selected))
    if missing:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID",
            f"required command is absent: {missing[0]}",
        )
    digests = {
        command_id: hashlib.sha256(
            canonical_json_bytes(command["argv"])
        ).hexdigest()
        for command_id, command in sorted(selected.items())
    }
    allowed_proof = set(rule_proof_obligations)
    proof_bindings = {
        command_id: sorted(
            set(command["proof_obligation_ids"]) & allowed_proof
        )
        for command_id, command in sorted(selected.items())
    }
    empty_bindings = sorted(
        command_id
        for command_id, obligations in proof_bindings.items()
        if not obligations
    )
    if empty_bindings:
        raise AuthorizationError(
            "AUTH_COMMAND_MANIFEST_INVALID",
            f"required command has no policy-approved proof binding: {empty_bindings[0]}",
        )
    return sorted(selected), digests, proof_bindings


def _validate_trust_anchors(data: Mapping[str, object]) -> dict[str, object]:
    if set(data) != {
        "schema_version",
        "registry_revision",
        "repository_identity",
        "anchors",
    }:
        raise AuthorizationError(
            "AUTH_TRUST_ANCHOR_INVALID", "anchor registry fields do not match"
        )
    _require_version(data)
    revision = _string(data, "registry_revision")
    identity = data["repository_identity"]
    if (
        not isinstance(identity, Mapping)
        or set(identity) != _REPOSITORY_IDENTITY_FIELDS
    ):
        raise AuthorizationError(
            "AUTH_TRUST_ANCHOR_INVALID",
            "trust-anchor repository identity fields do not match",
        )
    normalized_identity = {
        "repository_id": _string(identity, "repository_id"),
        "repository_full_name": _string(identity, "repository_full_name"),
    }
    raw_anchors = data["anchors"]
    if not isinstance(raw_anchors, list) or not raw_anchors:
        raise AuthorizationError(
            "AUTH_TRUST_ANCHOR_INVALID", "anchors must be non-empty"
        )
    anchors: list[dict[str, object]] = []
    seen: set[str] = set()
    for raw in raw_anchors:
        fields = {
            "anchor_id",
            "algorithm",
            "purposes",
            "modulus_hex",
            "public_exponent",
        }
        if not isinstance(raw, Mapping) or set(raw) != fields:
            raise AuthorizationError(
                "AUTH_TRUST_ANCHOR_INVALID", "anchor fields do not match"
            )
        anchor_id = _string(raw, "anchor_id")
        if anchor_id in seen:
            raise AuthorizationError(
                "AUTH_TRUST_ANCHOR_INVALID", "duplicate anchor id"
            )
        seen.add(anchor_id)
        if raw["algorithm"] != _SIGNATURE_ALGORITHM:
            raise AuthorizationError(
                "AUTH_TRUST_ANCHOR_INVALID", "unsupported signature algorithm"
            )
        modulus_hex = _string(raw, "modulus_hex")
        if len(modulus_hex) < 128 or len(modulus_hex) % 2 or any(
            item not in "0123456789abcdef" for item in modulus_hex
        ):
            raise AuthorizationError(
                "AUTH_TRUST_ANCHOR_INVALID", "invalid RSA modulus"
            )
        exponent = raw["public_exponent"]
        if isinstance(exponent, bool) or not isinstance(exponent, int) or exponent < 3:
            raise AuthorizationError(
                "AUTH_TRUST_ANCHOR_INVALID", "invalid public exponent"
            )
        anchors.append(
            {
                "anchor_id": anchor_id,
                "algorithm": _SIGNATURE_ALGORITHM,
                "purposes": _string_list(raw, "purposes", allow_empty=False),
                "modulus_hex": modulus_hex,
                "public_exponent": exponent,
            }
        )
    return {
        "schema_version": 1,
        "registry_revision": revision,
        "repository_identity": normalized_identity,
        "anchors": sorted(anchors, key=lambda item: str(item["anchor_id"])),
    }


def _require_anchor_purpose(
    registry: Mapping[str, object],
    anchor_id: str,
    purpose: str,
    code: str,
) -> Mapping[str, object]:
    anchors = registry["anchors"]
    assert isinstance(anchors, list)
    matches = [item for item in anchors if item["anchor_id"] == anchor_id]
    if len(matches) != 1 or purpose not in matches[0]["purposes"]:
        raise AuthorizationError(code, "trusted signing anchor is unavailable")
    return matches[0]


def _verify_signed_attestation(
    data: Mapping[str, object],
    trust_anchors: Mapping[str, object],
    *,
    purpose: str,
    error_code: str,
) -> None:
    if data.get("signature_algorithm") != _SIGNATURE_ALGORITHM:
        raise AuthorizationError(error_code, "signature algorithm is not trusted")
    anchor = _require_anchor_purpose(
        trust_anchors, str(data.get("trust_anchor_id")), purpose, error_code
    )
    anchor_digest = hashlib.sha256(canonical_json_bytes(dict(anchor))).hexdigest()
    if data.get("trust_anchor_sha256") != anchor_digest:
        raise AuthorizationError(error_code, "trust anchor digest mismatch")
    signature_text = data.get("signature_base64url")
    if not isinstance(signature_text, str) or not signature_text:
        raise AuthorizationError(error_code, "signature is missing")
    try:
        signature = base64.urlsafe_b64decode(
            signature_text + "=" * (-len(signature_text) % 4)
        )
    except (ValueError, binascii.Error) as exc:
        raise AuthorizationError(error_code, "signature encoding is invalid") from exc
    payload = dict(data)
    payload.pop("signature_base64url")
    digest = hashlib.sha256(canonical_json_bytes(payload)).digest()
    modulus = int(str(anchor["modulus_hex"]), 16)
    exponent = int(anchor["public_exponent"])
    size = (modulus.bit_length() + 7) // 8
    if len(signature) != size:
        raise AuthorizationError(error_code, "signature size mismatch")
    encoded = pow(int.from_bytes(signature, "big"), exponent, modulus).to_bytes(
        size, "big"
    )
    digest_info = _SHA256_DIGEST_INFO_PREFIX + digest
    padding_size = size - len(digest_info) - 3
    expected = b"\x00\x01" + b"\xff" * padding_size + b"\x00" + digest_info
    if padding_size < 8 or encoded != expected:
        raise AuthorizationError(error_code, "signature verification failed")


def canonical_local_state(
    repo_root: Path, *, requested_paths: Sequence[str] = ()
) -> dict[str, object]:
    """Bind HEAD, index, tracked bytes, and only explicitly requested untracked files."""

    repo = repo_root.resolve()
    head = _git(repo, "rev-parse", "HEAD").decode().strip()
    _git_oid(head, "AUTH_LOCAL_HEAD")
    head_tree = _git(repo, "rev-parse", f"{head}^{{tree}}").decode().strip()
    index_tree = _git(repo, "write-tree").decode().strip()
    requested = set(requested_paths)
    untracked_raw = tuple(
        path
        for path in _git(
            repo, "ls-files", "--others", "--exclude-standard", "-z", "--"
        ).split(b"\0")
        if path
    )
    untracked: list[tuple[bytes, str]] = []
    for raw_path in untracked_raw:
        try:
            display = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            display = f"raw-base64url:{_base64url(raw_path)}"
        if display not in requested:
            raise AuthorizationError(
                "AUTH_FILE_UNREQUESTED",
                f"untracked file was not requested: {display}",
            )
        untracked.append((raw_path, display))
    _validate_local_untracked_files(repo, untracked)
    git_index_text = _git(repo, "rev-parse", "--git-path", "index").decode().strip()
    git_index = Path(git_index_text)
    if not git_index.is_absolute():
        git_index = repo / git_index
    with tempfile.TemporaryDirectory(prefix="ambitions-auth-index-") as directory:
        temporary_index = Path(directory) / "index"
        try:
            shutil.copyfile(git_index, temporary_index)
        except OSError as exc:
            raise AuthorizationError(
                "AUTH_LOCAL_INDEX", "unable to snapshot Git index"
            ) from exc
        environment = dict(os.environ)
        environment["GIT_INDEX_FILE"] = str(temporary_index)
        _git_with_env(repo, environment, "add", "-u", "--", ".")
        if untracked:
            _git_with_env_input(
                repo,
                environment,
                b"\0".join(raw_path for raw_path, _display in untracked) + b"\0",
                "--literal-pathspecs",
                "add",
                "--pathspec-from-file=-",
                "--pathspec-file-nul",
            )
        worktree_tree = _git_with_env(repo, environment, "write-tree").decode().strip()
    return {
        "schema_version": 1,
        "head_sha": head,
        "head_tree_sha": head_tree,
        "index_tree_sha": index_tree,
        "worktree_tree_sha": worktree_tree,
        "head_to_index_delta": _canonical_tree_delta_from_treeish(
            repo, head_tree, index_tree
        ),
        "head_to_worktree_delta": _canonical_tree_delta_from_treeish(
            repo, head_tree, worktree_tree
        ),
    }


def _local_untracked_displays(repo_root: Path) -> list[str]:
    values: list[str] = []
    for raw_path in _git(
        repo_root.resolve(), "ls-files", "--others", "--exclude-standard", "-z", "--"
    ).split(b"\0"):
        if not raw_path:
            continue
        try:
            values.append(raw_path.decode("utf-8"))
        except UnicodeDecodeError:
            values.append(f"raw-base64url:{_base64url(raw_path)}")
    return sorted(values)


def _tree_delta_changed_bytes(delta: Mapping[str, object]) -> int:
    records = delta["records"]
    assert isinstance(records, list)
    return sum(
        max(int(record.get("old_blob_size") or 0), int(record.get("new_blob_size") or 0))
        for record in records
        if isinstance(record, Mapping)
    )


def _validate_path_root_delta(
    repo_root: Path,
    delta: Mapping[str, object],
    *,
    selected_roots: Sequence[str],
    protected_paths: Sequence[str],
    maximum_changed_files: int,
    maximum_changed_bytes: int,
) -> list[str]:
    records = delta["records"]
    assert isinstance(records, list)
    changed_files = sorted(_record_path(record) for record in records)
    for record in records:
        assert isinstance(record, Mapping)
        path = _record_path(record)
        if path.startswith("raw-base64url:"):
            raise AuthorizationError(
                "AUTH_FILE_POLICY", f"tree change is outside delegated roots: {path}"
            )
        path = _canonical_repo_path(path, "AUTH_FILE_POLICY")
        present_modes = tuple(
            str(record[field])
            for field in ("old_mode", "new_mode")
            if record.get(field) is not None
        )
        if any(mode not in {"100644", "100755"} for mode in present_modes):
            raise AuthorizationError(
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                f"delegated roots permit regular files only: {path}",
            )
        if not any(
            _path_matches_delegated_root(path, root) for root in selected_roots
        ):
            raise AuthorizationError(
                "AUTH_FILE_POLICY", f"tree change is outside delegated roots: {path}"
            )
        if _is_hard_delegation_boundary(path, protected_paths):
            raise AuthorizationError(
                "AUTH_BOUNDARY_APPROVAL_REQUIRED",
                f"tree change crosses a renewed-approval boundary: {path}",
            )
    deleted_count = sum(
        1
        for record in records
        if isinstance(record, Mapping) and record["status"] == "deleted"
    )
    if deleted_count > _MAX_DELEGATED_DELETIONS:
        raise AuthorizationError(
            "AUTH_BOUNDARY_APPROVAL_REQUIRED",
            "delegation exceeds the mass-deletion boundary",
        )
    if (
        len(changed_files) > maximum_changed_files
        or _tree_delta_changed_bytes(delta) > maximum_changed_bytes
    ):
        raise AuthorizationError(
            "AUTH_DELEGATION_BUDGET", "tree delta exceeds delegation budget"
        )
    return changed_files


def _scope_expansion_records(
    repo_root: Path,
    authorization: Mapping[str, object],
) -> list[dict[str, object]]:
    intake = _mapping(authorization["intake"], "AUTH_RECEIPT_FIELDS")
    if intake.get("requested_authorization_mode") != "path-roots":
        return []
    event = _mapping(
        authorization["trusted_event_provenance"], "AUTH_RECEIPT_FIELDS"
    )
    base_sha = str(event["trusted_base_sha"])
    head_sha = str(event["trusted_head_sha"])
    policy = load_base_policy(repo_root, base_sha)
    task_rule = _task_rule(policy, intake)
    protected_paths = tuple(str(item) for item in task_rule["protected_paths"])
    selected_roots = tuple(str(item) for item in intake["requested_path_roots"])
    revision_list = _git(
        repo_root.resolve(),
        "rev-list",
        "--reverse",
        "--topo-order",
        f"{base_sha}..{head_sha}",
    ).decode().splitlines()
    records: list[dict[str, object]] = []
    previous_digest: str | None = None
    for sequence, commit_sha in enumerate(revision_list, start=1):
        delta = canonical_tree_delta(repo_root, base_sha, commit_sha)
        changed_files = _validate_path_root_delta(
            repo_root,
            delta,
            selected_roots=selected_roots,
            protected_paths=protected_paths,
            maximum_changed_files=int(intake["requested_max_changed_files"]),
            maximum_changed_bytes=int(intake["requested_max_changed_bytes"]),
        )
        record: dict[str, object] = {
            "sequence": sequence,
            "head_sha": commit_sha,
            "tree_delta_digest": delta["digest"],
            "changed_files": changed_files,
            "changed_file_count": len(changed_files),
            "changed_bytes": _tree_delta_changed_bytes(delta),
            "previous_record_sha256": previous_digest,
        }
        record["record_sha256"] = hashlib.sha256(
            canonical_json_bytes(record)
        ).hexdigest()
        records.append(record)
        previous_digest = str(record["record_sha256"])
    return records


def _validate_delegation_start(
    *,
    repo_root: Path,
    current_authorization: Mapping[str, object],
    policy_data: Mapping[str, object],
    evaluation_epoch: int,
    delegation_start_authorization: Mapping[str, object] | None,
    delegation_start_event: Mapping[str, object] | None,
    delegation_start_approval: Mapping[str, object] | None,
) -> tuple[str | None, dict[str, object] | None]:
    current_intake = _mapping(
        current_authorization["intake"], "AUTH_DELEGATION_START"
    )
    is_delegated = current_intake.get("requested_authorization_mode") == "path-roots"
    supplied = (
        delegation_start_authorization,
        delegation_start_event,
        delegation_start_approval,
    )
    if not is_delegated:
        if any(item is not None for item in supplied):
            raise AuthorizationError(
                "AUTH_DELEGATION_START",
                "exact-file finalization cannot consume a root delegation",
            )
        return None, None
    if any(item is None for item in supplied):
        raise AuthorizationError(
            "AUTH_DELEGATION_START_MISSING",
            "path-root finalization requires its signed pre-edit delegation",
        )
    assert delegation_start_authorization is not None
    assert delegation_start_event is not None
    assert delegation_start_approval is not None
    prior = validate_task_authorization(delegation_start_authorization)
    prior_event = _validate_trusted_event(repo_root, delegation_start_event)
    if prior["trusted_event_provenance"] != prior_event:
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "delegation event differs from its authorization"
        )
    if prior["mode"] != "ci-pr-range" or prior["authority_class"] != "ci-candidate":
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "pre-edit delegation is not platform-owned"
        )
    if prior["intake"] != current_intake or prior["intake_digest"] != (
        current_authorization["intake_digest"]
    ):
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "delegation intake changed before finalization"
        )
    current_event = _mapping(
        current_authorization["trusted_event_provenance"],
        "AUTH_DELEGATION_START",
    )
    stable_event_fields = (
        "repository_id",
        "repository_full_name",
        "pull_request_number",
        "base_ref",
        "trusted_base_sha",
        "merge_base_sha",
        "consumption_generation",
        "issue_state_transition",
    )
    if any(prior_event[field] != current_event[field] for field in stable_event_fields):
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "delegation session identity changed"
        )
    if (
        prior_event["workflow_run_id"] == current_event["workflow_run_id"]
        and prior_event["workflow_run_attempt"]
        == current_event["workflow_run_attempt"]
    ):
        raise AuthorizationError(
            "AUTH_DELEGATION_REPLAY",
            "finalization cannot replay the pre-edit workflow run",
        )
    if prior_event["trusted_head_sha"] == current_event["trusted_head_sha"]:
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "delegated repair has no post-start commit"
        )
    try:
        _git(
            repo_root.resolve(),
            "merge-base",
            "--is-ancestor",
            str(prior_event["trusted_head_sha"]),
            str(current_event["trusted_head_sha"]),
        )
    except AuthorizationError as exc:
        raise AuthorizationError(
            "AUTH_DELEGATION_HISTORY",
            "final head does not append to the signed pre-edit head",
        ) from exc
    if prior["computed_authorized_files"] or prior["tree_delta"]["records"]:
        raise AuthorizationError(
            "AUTH_DELEGATION_START",
            "pre-edit delegation was issued after repair changes existed",
        )
    if prior["trusted_bindings"] != current_authorization["trusted_bindings"]:
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "base-owned delegation bindings changed"
        )
    prior_nonces = {
        str(item["nonce"])
        for item in prior["approval_nonce_consumptions"]
        if isinstance(item, Mapping)
    }
    current_nonces = {
        str(item["nonce"])
        for item in current_authorization["approval_nonce_consumptions"]
        if isinstance(item, Mapping)
    }
    if not prior_nonces or prior_nonces & current_nonces:
        raise AuthorizationError(
            "AUTH_DELEGATION_REPLAY",
            "pre-edit and final approval nonces must be distinct",
        )
    regenerated = task_start(
        repo_root=repo_root,
        mode="ci-pr-range",
        intake_data=current_intake,
        trusted_event_data=prior_event,
        trusted_bindings=_mapping(prior["trusted_bindings"], "AUTH_DELEGATION_START"),
        policy_data=policy_data,
        approval_attestations=(delegation_start_approval,),
        verification_epoch=int(prior_event["verification_epoch"]),
        evaluation_epoch=evaluation_epoch,
    )
    if canonical_json_bytes(regenerated) != canonical_json_bytes(prior):
        raise AuthorizationError(
            "AUTH_DELEGATION_START", "pre-edit delegation does not regenerate exactly"
        )
    return (
        hashlib.sha256(canonical_json_bytes(prior)).hexdigest(),
        dict(prior_event),
    )


def _is_hard_delegation_boundary(
    path: str, protected_paths: Sequence[str]
) -> bool:
    if _is_sensitive_authorization_path(path) or any(
        _path_matches_policy_prefix(path, protected) for protected in protected_paths
    ):
        return True
    raw_parts = PurePosixPath(path).parts
    camel_split_parts = tuple(
        re.sub(
            r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])",
            "-",
            part,
        )
        for part in raw_parts
    )
    parts = tuple(part.casefold() for part in camel_split_parts)
    flattened = re.sub(r"[^a-z0-9]+", "-", "-".join(parts)).strip("-")
    path_tokens = {
        token
        for part in camel_split_parts
        for token in re.split(
            r"[^a-z0-9]+",
            part.casefold(),
        )
        if token
    }
    if path_tokens & {"sign", "signer", "signing"}:
        return True
    if any(
        marker in flattened
        for marker in (
            "authority-amendment",
            "authorization-policy",
            "authorization-policies",
            "authorizationpolicy",
            "authorizationpolicies",
            "credential",
            "secret",
            "signing-key",
            "signing-material",
            "private-key",
            "trust-anchor",
            "trustanchor",
            "api-key",
            "apikey",
            "access-token",
            "ruleset",
            "destructive-migration",
            "production-deploy",
            "external-mutation",
            "externalmutation",
            "external-write",
            "externalwrite",
            "external-writes",
            "externalwrites",
            "external-effect",
            "externaleffect",
            "release",
            "testflight",
            "app-store",
        )
    ):
        return True
    if any(
        marker in PurePosixPath(path).name.casefold()
        for marker in ("deploy", "publish", "release", "testflight", "app-store")
    ):
        return True
    name = PurePosixPath(path).name.casefold()
    if name.startswith(".env"):
        return True
    if name in {"id_dsa", "id_ecdsa", "id_ed25519", "id_rsa"}:
        return True
    if name.startswith("ssh_host_") and name.endswith("_key"):
        return True
    sensitive_suffixes = {
        ".cer",
        ".crt",
        ".der",
        ".jks",
        ".key",
        ".keystore",
        ".pem",
        ".p7b",
        ".p8",
        ".p12",
        ".pfx",
        ".mobileprovision",
    }
    return any(
        suffix.casefold() in sensitive_suffixes
        for suffix in PurePosixPath(path).suffixes
    )


def _path_matches_delegated_root(path: str, root: str) -> bool:
    if root in {"Package.resolved", "Package.swift", "project.yml"}:
        return path == root
    return _path_matches_policy_prefix(path, root)


def _validate_local_untracked_files(
    repo: Path, untracked: Sequence[tuple[bytes, str]]
) -> None:
    if len(untracked) > _MAX_LOCAL_UNTRACKED_FILES:
        raise AuthorizationError(
            "AUTH_LOCAL_UNTRACKED_BOUNDS", "too many requested untracked files"
        )
    total = 0
    for raw_path, display in untracked:
        try:
            decoded = raw_path.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise AuthorizationError(
                "AUTH_LOCAL_UNTRACKED_UNSAFE",
                f"non-UTF-8 untracked path is unsupported: {display}",
            ) from exc
        canonical = _canonical_repo_path(decoded, "AUTH_LOCAL_UNTRACKED_UNSAFE")
        current = repo
        try:
            for component in PurePosixPath(canonical).parts:
                current = current / component
                metadata = current.lstat()
                if stat.S_ISLNK(metadata.st_mode):
                    raise AuthorizationError(
                        "AUTH_LOCAL_UNTRACKED_UNSAFE",
                        f"untracked path traverses a symlink: {display}",
                    )
            metadata = current.lstat()
        except OSError as exc:
            raise AuthorizationError(
                "AUTH_LOCAL_UNTRACKED_UNSAFE",
                f"unable to bind untracked file: {display}",
            ) from exc
        if not stat.S_ISREG(metadata.st_mode):
            raise AuthorizationError(
                "AUTH_LOCAL_UNTRACKED_UNSAFE",
                f"untracked path is not a regular file: {display}",
            )
        if metadata.st_size > _MAX_LOCAL_UNTRACKED_FILE_BYTES:
            raise AuthorizationError(
                "AUTH_LOCAL_UNTRACKED_BOUNDS",
                f"untracked file exceeds the per-file bound: {display}",
            )
        total += metadata.st_size
        if total > _MAX_LOCAL_UNTRACKED_TOTAL_BYTES:
            raise AuthorizationError(
                "AUTH_LOCAL_UNTRACKED_BOUNDS",
                "requested untracked files exceed the aggregate bound",
            )


def _canonical_tree_delta_from_treeish(
    repo: Path, old_treeish: str, new_treeish: str
) -> dict[str, object]:
    old_entries = _git_tree_entries(repo, old_treeish)
    new_entries = _git_tree_entries(repo, new_treeish)
    records: list[dict[str, object]] = []
    for raw_path in sorted(set(old_entries) | set(new_entries)):
        old = old_entries.get(raw_path)
        new = new_entries.get(raw_path)
        if old == new:
            continue
        status = "added" if old is None else "deleted" if new is None else "modified"
        try:
            display: str | None = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            display = None
        records.append(
            {
                "path_raw_base64url": _base64url(raw_path),
                "path_display_utf8": display,
                "status": status,
                "old_mode": old[0] if old else None,
                "new_mode": new[0] if new else None,
                "old_object_type": old[1] if old else None,
                "new_object_type": new[1] if new else None,
                "old_object_id": old[2] if old else None,
                "new_object_id": new[2] if new else None,
                "old_blob_size": old[3] if old and old[1] == "blob" else None,
                "new_blob_size": new[3] if new and new[1] == "blob" else None,
            }
        )
    return {
        "schema_version": 1,
        "old_tree_sha": _git(repo, "rev-parse", f"{old_treeish}^{{tree}}")
        .decode()
        .strip(),
        "new_tree_sha": _git(repo, "rev-parse", f"{new_treeish}^{{tree}}")
        .decode()
        .strip(),
        "records": records,
        "digest": hashlib.sha256(canonical_json_bytes(records)).hexdigest(),
    }


def _git_tree_entries(repo: Path, revision: str) -> dict[bytes, tuple[str, str, str, int | None]]:
    output = _git(repo, "ls-tree", "-r", "-z", "-l", revision)
    entries: dict[bytes, tuple[str, str, str, int | None]] = {}
    for record in output.split(b"\0"):
        if not record:
            continue
        try:
            metadata, raw_path = record.split(b"\t", 1)
            mode, object_type, object_id, size_text = metadata.split(None, 3)
        except ValueError as exc:
            raise AuthorizationError("AUTH_GIT_TREE", "unable to parse Git tree entry") from exc
        size = None if size_text == b"-" else int(size_text)
        entries[raw_path] = (
            mode.decode("ascii"),
            object_type.decode("ascii"),
            object_id.decode("ascii"),
            size,
        )
    return entries


def _require_git_object(repo: Path, revision: str) -> None:
    try:
        _git(repo, "cat-file", "-e", f"{revision}^{{commit}}")
    except AuthorizationError as exc:
        raise AuthorizationError("AUTH_GIT_OBJECT_MISSING", f"missing trusted Git object: {revision}") from exc


def _git(repo: Path, *arguments: str) -> bytes:
    try:
        completed = subprocess.run(
            ["git", "-c", "core.quotepath=false", *arguments],
            cwd=repo,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        raise AuthorizationError("AUTH_GIT", f"Git command failed: {' '.join(arguments)}") from exc
    return completed.stdout


def _git_with_env(
    repo: Path, environment: Mapping[str, str], *arguments: str
) -> bytes:
    try:
        completed = subprocess.run(
            ["git", "-c", "core.quotepath=false", *arguments],
            cwd=repo,
            env=dict(environment),
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        raise AuthorizationError(
            "AUTH_GIT", f"Git command failed: {' '.join(arguments)}"
        ) from exc
    return completed.stdout


def _git_with_env_input(
    repo: Path,
    environment: Mapping[str, str],
    input_bytes: bytes,
    *arguments: str,
) -> bytes:
    try:
        completed = subprocess.run(
            ["git", "-c", "core.quotepath=false", *arguments],
            cwd=repo,
            env=dict(environment),
            input=input_bytes,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        raise AuthorizationError(
            "AUTH_GIT", f"Git command failed: {' '.join(arguments)}"
        ) from exc
    return completed.stdout


def _git_blob_at_revision(repo: Path, revision: str, path: str) -> bytes:
    _git_oid(revision, "AUTH_GIT_OBJECT_ID")
    canonical = _canonical_repo_path(path, "AUTH_SNAPSHOT_PATH")
    try:
        return _git(repo, "cat-file", "blob", f"{revision}:{canonical}")
    except AuthorizationError as exc:
        raise AuthorizationError(
            "AUTH_SNAPSHOT_MISSING", f"trusted snapshot is missing: {canonical}"
        ) from exc


def _approved_manifest_deletion_paths(
    repo_root: Path,
    trusted_base_sha: str,
    manifest_path: object,
) -> set[str]:
    """Derive deletion-only paths from a closed, trusted-base purge plan."""

    if manifest_path is None:
        return set()
    if not isinstance(manifest_path, str) or not manifest_path.strip():
        raise AuthorizationError(
            "AUTH_POLICY_FIELDS", "authorized deletion manifest path is invalid"
        )
    canonical_manifest = _canonical_repo_path(
        manifest_path, "AUTH_POLICY_PATH"
    )
    raw = _git_blob_at_revision(repo_root.resolve(), trusted_base_sha, canonical_manifest)
    if len(raw) > 8 * 1024 * 1024:
        raise AuthorizationError(
            "AUTH_PURGE_MANIFEST_INVALID", "trusted purge manifest exceeds 8 MiB"
        )
    try:
        from tools.ambitions_canon.purge import parse_purge_plan

        plan = parse_purge_plan(raw.decode("utf-8"))
    except (UnicodeError, ValueError, tomllib.TOMLDecodeError) as exc:
        raise AuthorizationError(
            "AUTH_PURGE_MANIFEST_INVALID",
            f"trusted purge manifest is invalid: {canonical_manifest}",
        ) from exc
    if not plan.rollback_ref.strip():
        raise AuthorizationError(
            "AUTH_PURGE_MANIFEST_INVALID", "trusted purge manifest lacks rollback"
        )
    result: set[str] = set()
    artifact_ids: set[str] = set()
    for artifact in plan.artifacts:
        if artifact.artifact_id in artifact_ids:
            raise AuthorizationError(
                "AUTH_PURGE_MANIFEST_INVALID", "trusted purge manifest repeats an artifact"
            )
        artifact_ids.add(artifact.artifact_id)
        if artifact.kind != "repo" or artifact.action != "delete":
            continue
        disposition_map = dict(artifact.claim_dispositions)
        replacements = set(artifact.replacement_ids) | set(disposition_map.values())
        deterministic_candidate = all(
            (
                artifact.claims_resolved,
                bool(artifact.claim_ids),
                set(artifact.claim_ids) <= set(disposition_map),
                bool(replacements),
                artifact.incoming_links_rewritten,
                artifact.external_references_reconciled,
                artifact.unique_content_extracted,
                artifact.independent_review,
            )
        )
        if not deterministic_candidate:
            continue
        if (
            not artifact.independent_review_attestation_sha256
            or artifact.rollback_ref != plan.rollback_ref
        ):
            continue
        path = _canonical_authorized_file(artifact.locator)
        if path == canonical_manifest:
            raise AuthorizationError(
                "AUTH_PURGE_MANIFEST_INVALID",
                "purge manifest cannot authorize its own deletion",
            )
        result.add(path)
    return result


class _DuplicateJSONKey(ValueError):
    pass


def _closed_json_object(pairs: list[tuple[str, object]]) -> dict[str, object]:
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise _DuplicateJSONKey(key)
        result[key] = value
    return result


def _json_mapping(raw: bytes, code: str, path: str) -> dict[str, object]:
    try:
        value = json.loads(
            raw.decode("utf-8"), object_pairs_hook=_closed_json_object
        )
    except (UnicodeError, json.JSONDecodeError, _DuplicateJSONKey) as exc:
        raise AuthorizationError(code, f"invalid trusted JSON: {path}") from exc
    if not isinstance(value, dict):
        raise AuthorizationError(code, f"trusted JSON must be an object: {path}")
    return value


def _toml_mapping(raw: bytes, code: str, path: str) -> dict[str, object]:
    try:
        value = tomllib.loads(raw.decode("utf-8"))
    except (UnicodeError, tomllib.TOMLDecodeError) as exc:
        raise AuthorizationError(code, f"invalid trusted TOML: {path}") from exc
    if not isinstance(value, dict):
        raise AuthorizationError(code, f"trusted TOML must be a table: {path}")
    return value


def _labeled_bytes_digest(entries: Sequence[tuple[object, bytes]]) -> str:
    digest = hashlib.sha256()
    for label, content in sorted(
        ((str(label), bytes(content)) for label, content in entries),
        key=lambda item: item[0],
    ):
        label_bytes = label.encode("utf-8")
        digest.update(len(label_bytes).to_bytes(8, "big"))
        digest.update(label_bytes)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def _canonical_repo_path(value: str, code: str) -> str:
    pure = PurePosixPath(value)
    if (
        pure.is_absolute()
        or not pure.parts
        or any(part in {"", ".", ".."} for part in pure.parts)
        or "\x00" in value
        or "\\" in value
        or ":" in value
    ):
        raise AuthorizationError(code, f"invalid repository path: {value}")
    return pure.as_posix()


def _canonical_authorized_file(value: str) -> str:
    if value.startswith("raw-base64url:"):
        encoded = value.removeprefix("raw-base64url:")
        if not encoded or any(item not in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-" for item in encoded):
            raise AuthorizationError(
                "AUTH_POLICY_PATH", "invalid raw-path authorization"
            )
        try:
            raw = base64.urlsafe_b64decode(encoded + "=" * (-len(encoded) % 4))
        except (ValueError, binascii.Error) as exc:
            raise AuthorizationError(
                "AUTH_POLICY_PATH", "invalid raw-path authorization"
            ) from exc
        if not raw or _base64url(raw) != encoded:
            raise AuthorizationError(
                "AUTH_POLICY_PATH", "non-canonical raw-path authorization"
            )
        return value
    return _canonical_repo_path(value, "AUTH_POLICY_PATH")


def _is_sensitive_authorization_path(path: str) -> bool:
    return (
        path in _SENSITIVE_AUTHORIZATION_PATHS
        or path.startswith("docs/canon/schemas/")
        or path.startswith(".github/workflows/")
    )


def _record_path(record: Mapping[str, object]) -> str:
    display = record["path_display_utf8"]
    if display is not None:
        return str(display)
    return f"raw-base64url:{record['path_raw_base64url']}"


def _path_matches_policy_prefix(path: str, prefix: str) -> bool:
    if prefix == "":
        return True
    normalized = prefix.rstrip("/")
    return path == normalized or path.startswith(f"{normalized}/")


def _base64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _require_closed_mapping(
    data: Mapping[str, object], fields: frozenset[str], code: str
) -> None:
    if not isinstance(data, Mapping) or set(data) != fields:
        raise AuthorizationError(code, "fields do not match closed contract")


def _require_version(data: Mapping[str, object]) -> None:
    version = data.get("schema_version")
    if isinstance(version, bool) or version != 1:
        raise AuthorizationError("AUTH_SCHEMA_VERSION", "schema_version must be integer 1")


def _string(data: Mapping[str, object], field: str) -> str:
    value = data[field]
    if not isinstance(value, str) or not value.strip():
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must be a non-empty string")
    return value


def _positive_integer(value: object, code: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
        raise AuthorizationError(code, "expected positive integer")
    return value


def _nonnegative_integer(value: object, code: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise AuthorizationError(code, "expected nonnegative integer")
    return value


def _string_list(
    data: Mapping[str, object],
    field: str,
    *,
    allow_empty: bool,
    allow_blank: bool = False,
) -> list[str]:
    value = data[field]
    if not isinstance(value, list) or (not allow_empty and not value):
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must be an array")
    if any(not isinstance(item, str) or (not allow_blank and not item.strip()) for item in value):
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must contain strings")
    if len(value) != len(set(value)):
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must contain unique values")
    return sorted(value)


def _ordered_string_list(
    data: Mapping[str, object],
    field: str,
    *,
    allow_empty: bool,
) -> list[str]:
    value = data[field]
    if not isinstance(value, list) or (not allow_empty and not value):
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must be an array")
    if any(not isinstance(item, str) or not item.strip() for item in value):
        raise AuthorizationError("AUTH_FIELD_TYPE", f"{field} must contain strings")
    return list(value)


def _sha256(value: object, code: str) -> str:
    if not isinstance(value, str) or len(value) != 64 or any(
        character not in "0123456789abcdef" for character in value
    ):
        raise AuthorizationError(code, "expected lowercase SHA-256")
    return value


def _git_oid(value: object, code: str) -> str:
    if not isinstance(value, str) or len(value) not in {40, 64} or any(
        character not in "0123456789abcdef" for character in value
    ):
        raise AuthorizationError(code, "expected lowercase Git object ID")
    return value
