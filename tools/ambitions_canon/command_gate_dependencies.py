"""Closed offline command-gate dependencies and independent approval receipts."""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.build import (
    _AuditedCanonSnapshot,
    _load_audited_canon_snapshot,
    _open_directory_absolute_nofollow,
    _read_file_at,
    _verify_audited_canon_snapshot,
)
from tools.ambitions_canon.model import (
    CanonError,
    StateCommand,
    StateCommandContract,
)


REGISTRY_PATH = Path("docs/canon/registries/command-gate-dependencies.json")
APPROVAL_RECEIPT_REGISTRY_PATH = Path(
    "docs/canon/registries/command-gate-approval-receipts.json"
)
OWNER_APPROVAL_REGISTRY_PATH = Path(
    "docs/canon/registries/command-gate-owner-approvals.json"
)
_COMMAND_GATE_INPUT_PATHS = (
    REGISTRY_PATH,
    APPROVAL_RECEIPT_REGISTRY_PATH,
    OWNER_APPROVAL_REGISTRY_PATH,
)
REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_id",
        "registry_revision",
        "canon_revision",
        "canon_content_sha256",
        "dependencies",
    }
)
APPROVAL_RECEIPT_REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_id",
        "registry_revision",
        "canon_revision",
        "canon_content_sha256",
        "approval_receipts",
    }
)
OWNER_APPROVAL_REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_id",
        "registry_revision",
        "owner_approvals",
    }
)


@dataclass(frozen=True, slots=True)
class _CommandGateCanonContext:
    """Module-owned live canon identity for one validation operation."""

    content_sha: str
DEPENDENCY_FIELDS = frozenset(
    {
        "dependency_id",
        "dependency_revision",
        "dependency_kind",
        "owner_concept",
        "requirement_id",
        "state_id",
        "command_id",
        "owner_approval_state",
        "approval_receipt_id",
        "mapping_record_id",
        "canon_content_sha256",
        "exact_product_mappings",
        "mapping_sha256",
        "freshness",
        "dependency_posture",
        "activation_authorization",
        "dependency_sha256",
    }
)
APPROVAL_SCOPE_FIELDS = frozenset(
    {"owner_concept", "requirement_id", "state_id", "command_id"}
)
APPROVAL_RECEIPT_FIELDS = frozenset(
    {
        "receipt_id",
        "receipt_revision",
        "dependency_id",
        "dependency_revision",
        "mapping_record_id",
        "exact_product_mappings",
        "mapping_sha256",
        "dependency_sha256",
        "canon_content_sha256",
        "approval_identity",
        "approval_attestation_sha256",
        "approval_state",
        "approved_scope",
        "approved_scope_sha256",
        "previous_receipt_sha256",
        "receipt_sha256",
    }
)
OWNER_APPROVAL_ATTESTATION_FIELDS = frozenset(
    {
        "approval_identity",
        "approval_revision",
        "approval_state",
        "dependency_id",
        "dependency_revision",
        "dependency_sha256",
        "mapping_record_id",
        "exact_product_mappings",
        "mapping_sha256",
        "canon_content_sha256",
        "approved_scope",
        "approved_scope_sha256",
        "trusted_dependency_registry_sha256",
        "trusted_receipt_registry_sha256",
        "trusted_prior_receipt_sha256",
        "attestation_sha256",
    }
)
DEPENDENCY_ID = re.compile(r"^GATE-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
COMMAND_ID = re.compile(r"^CMD-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
STATE_ID = re.compile(r"^UX-STATE-VARIANT-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CANON_ID = re.compile(r"^[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CONCEPT_ID = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
APPROVAL_IDENTITY = re.compile(r"^OWNER-APPROVAL-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
APPROVAL_RECEIPT_ID = re.compile(
    r"^APPROVAL-RECEIPT-GATE-[A-Z0-9]+(?:-[A-Z0-9]+)*-R[0-9]{4,}$"
)
MAPPING_RECORD_ID = re.compile(
    r"^MAPPING-GATE-[A-Z0-9]+(?:-[A-Z0-9]+)*-R[0-9]{4,}$"
)
GIT_SHA = re.compile(r"^[0-9a-f]{40}$")
PROTECTED_COMMAND_GATE_REF = "refs/remotes/origin/main"
PROTECTED_COMMAND_GATE_CI_PROVENANCE = (
    "github-protected-branch-required-check-v1"
)


@dataclass(frozen=True, slots=True)
class CommandGateApprovalScope:
    owner_concept: str
    requirement_id: str
    state_id: str
    command_id: str


@dataclass(frozen=True, slots=True)
class CommandGateOwnerApprovalAttestation:
    approval_identity: str
    approval_revision: int
    approval_state: str
    dependency_id: str
    dependency_revision: int
    dependency_sha256: str
    mapping_record_id: str
    exact_product_mappings: tuple[str, ...]
    mapping_sha256: str
    canon_content_sha256: str
    approved_scope: CommandGateApprovalScope
    approved_scope_sha256: str
    trusted_dependency_registry_sha256: str
    trusted_receipt_registry_sha256: str
    trusted_prior_receipt_sha256: str | None
    attestation_sha256: str

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "exact_product_mappings",
            tuple(self.exact_product_mappings),
        )


@dataclass(frozen=True, slots=True)
class CommandGateApprovalReceipt:
    receipt_id: str
    receipt_revision: int
    dependency_id: str
    dependency_revision: int
    mapping_record_id: str
    exact_product_mappings: tuple[str, ...]
    mapping_sha256: str
    dependency_sha256: str
    canon_content_sha256: str
    approval_identity: str
    approval_attestation_sha256: str
    approval_state: str
    approved_scope: CommandGateApprovalScope
    approved_scope_sha256: str
    previous_receipt_sha256: str | None
    receipt_sha256: str

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "exact_product_mappings",
            tuple(self.exact_product_mappings),
        )


@dataclass(frozen=True, slots=True)
class CommandGateDependency:
    dependency_id: str
    dependency_revision: int
    dependency_kind: str
    owner_concept: str
    requirement_id: str
    state_id: str
    command_id: str
    owner_approval_state: str
    approval_receipt_id: str | None
    mapping_record_id: str | None
    canon_content_sha256: str
    exact_product_mappings: tuple[str, ...]
    mapping_sha256: str | None
    freshness: str
    dependency_posture: str
    activation_authorization: bool
    dependency_sha256: str

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "exact_product_mappings",
            tuple(self.exact_product_mappings),
        )


@dataclass(frozen=True, slots=True)
class CommandGateDependencyRegistry:
    schema_version: int
    registry_id: str
    registry_revision: int
    canon_revision: int
    canon_content_sha256: str
    dependencies: tuple[CommandGateDependency, ...]
    approval_receipt_registry_id: str
    approval_receipt_registry_revision: int
    approval_receipts: tuple[CommandGateApprovalReceipt, ...]
    approval_receipt_source_sha256: str
    owner_approval_registry_id: str
    owner_approval_registry_revision: int
    owner_approvals: tuple[CommandGateOwnerApprovalAttestation, ...]
    owner_approval_source_sha256: str
    source_sha256: str
    source_path: Path
    repository_root: Path

    def __post_init__(self) -> None:
        object.__setattr__(self, "dependencies", tuple(self.dependencies))
        object.__setattr__(self, "approval_receipts", tuple(self.approval_receipts))
        object.__setattr__(self, "owner_approvals", tuple(self.owner_approvals))


@dataclass(frozen=True, slots=True)
class AuthenticatedCommandGateCIContext:
    protected_ref: str
    protected_sha: str
    candidate_head_sha: str
    provenance: str
    context_sha256: str


@dataclass(frozen=True, slots=True)
class TrustedCommandGateApprovalBase:
    authenticated_ci_context: AuthenticatedCommandGateCIContext | None
    repository_root: Path | None
    dependency_registry_bytes: bytes
    approval_receipt_registry_bytes: bytes
    owner_approval_registry_bytes: bytes
    dependency_registry_sha256: str
    approval_receipt_registry_sha256: str
    owner_approval_registry_sha256: str
    dependency_registry_revision: int
    approval_receipt_registry_revision: int
    owner_approval_registry_revision: int
    dependencies: tuple[CommandGateDependency, ...]
    approval_receipts: tuple[CommandGateApprovalReceipt, ...]
    owner_approvals: tuple[CommandGateOwnerApprovalAttestation, ...]

    def __post_init__(self) -> None:
        if self.repository_root is not None:
            object.__setattr__(
                self,
                "repository_root",
                self.repository_root.resolve(),
            )
        object.__setattr__(
            self,
            "dependency_registry_bytes",
            bytes(self.dependency_registry_bytes),
        )
        object.__setattr__(
            self,
            "approval_receipt_registry_bytes",
            bytes(self.approval_receipt_registry_bytes),
        )
        object.__setattr__(
            self,
            "owner_approval_registry_bytes",
            bytes(self.owner_approval_registry_bytes),
        )
        object.__setattr__(self, "dependencies", tuple(self.dependencies))
        object.__setattr__(self, "approval_receipts", tuple(self.approval_receipts))
        object.__setattr__(self, "owner_approvals", tuple(self.owner_approvals))


def _error(message: str, path: Path | None = None) -> CanonError:
    return CanonError("CANON_COMMAND_GATE_DEPENDENCY_INVALID", message, path)


def _stable_json(value: object) -> bytes:
    return (
        json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        + "\n"
    ).encode("utf-8")


def _pretty_json(value: object) -> bytes:
    return (
        json.dumps(
            value,
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
        )
        + "\n"
    ).encode("utf-8")


def command_gate_mapping_sha256(mappings: tuple[str, ...]) -> str:
    """Hash the exact sorted product mapping list."""

    return hashlib.sha256(_stable_json(list(mappings))).hexdigest()


def _ci_context_hash_payload(
    context: AuthenticatedCommandGateCIContext,
) -> dict[str, object]:
    return {
        "candidate_head_sha": context.candidate_head_sha,
        "protected_ref": context.protected_ref,
        "protected_sha": context.protected_sha,
        "provenance": context.provenance,
    }


def command_gate_ci_context_sha256(
    context: AuthenticatedCommandGateCIContext,
) -> str:
    """Hash the externally authenticated, fixed-ref CI authorization context."""

    return hashlib.sha256(_stable_json(_ci_context_hash_payload(context))).hexdigest()


def _scope_payload(scope: CommandGateApprovalScope) -> dict[str, object]:
    return {
        "command_id": scope.command_id,
        "owner_concept": scope.owner_concept,
        "requirement_id": scope.requirement_id,
        "state_id": scope.state_id,
    }


def command_gate_approval_scope_sha256(scope: CommandGateApprovalScope) -> str:
    """Hash the exact closed command-owner approval scope."""

    return hashlib.sha256(_stable_json(_scope_payload(scope))).hexdigest()


def _owner_approval_attestation_hash_payload(
    attestation: CommandGateOwnerApprovalAttestation,
) -> dict[str, object]:
    return {
        "approval_identity": attestation.approval_identity,
        "approval_revision": attestation.approval_revision,
        "approval_state": attestation.approval_state,
        "approved_scope": _scope_payload(attestation.approved_scope),
        "approved_scope_sha256": attestation.approved_scope_sha256,
        "canon_content_sha256": attestation.canon_content_sha256,
        "dependency_id": attestation.dependency_id,
        "dependency_revision": attestation.dependency_revision,
        "dependency_sha256": attestation.dependency_sha256,
        "exact_product_mappings": list(attestation.exact_product_mappings),
        "mapping_record_id": attestation.mapping_record_id,
        "mapping_sha256": attestation.mapping_sha256,
        "trusted_dependency_registry_sha256": (
            attestation.trusted_dependency_registry_sha256
        ),
        "trusted_prior_receipt_sha256": attestation.trusted_prior_receipt_sha256,
        "trusted_receipt_registry_sha256": (
            attestation.trusted_receipt_registry_sha256
        ),
    }


def command_gate_owner_approval_attestation_sha256(
    attestation: CommandGateOwnerApprovalAttestation,
) -> str:
    """Hash every owner-attested transition field except the self hash."""

    return hashlib.sha256(
        _stable_json(_owner_approval_attestation_hash_payload(attestation))
    ).hexdigest()


def _dependency_hash_payload(dependency: CommandGateDependency) -> dict[str, object]:
    return {
        "activation_authorization": dependency.activation_authorization,
        "approval_receipt_id": dependency.approval_receipt_id,
        "canon_content_sha256": dependency.canon_content_sha256,
        "command_id": dependency.command_id,
        "dependency_id": dependency.dependency_id,
        "dependency_kind": dependency.dependency_kind,
        "dependency_posture": dependency.dependency_posture,
        "dependency_revision": dependency.dependency_revision,
        "exact_product_mappings": list(dependency.exact_product_mappings),
        "freshness": dependency.freshness,
        "mapping_record_id": dependency.mapping_record_id,
        "mapping_sha256": dependency.mapping_sha256,
        "owner_approval_state": dependency.owner_approval_state,
        "owner_concept": dependency.owner_concept,
        "requirement_id": dependency.requirement_id,
        "state_id": dependency.state_id,
    }


def command_gate_dependency_sha256(dependency: CommandGateDependency) -> str:
    """Hash stable dependency fields while excluding the self hash."""

    return hashlib.sha256(_stable_json(_dependency_hash_payload(dependency))).hexdigest()


def _approval_receipt_hash_payload(
    receipt: CommandGateApprovalReceipt,
) -> dict[str, object]:
    return {
        "approval_identity": receipt.approval_identity,
        "approval_attestation_sha256": receipt.approval_attestation_sha256,
        "approval_state": receipt.approval_state,
        "approved_scope": _scope_payload(receipt.approved_scope),
        "approved_scope_sha256": receipt.approved_scope_sha256,
        "canon_content_sha256": receipt.canon_content_sha256,
        "dependency_id": receipt.dependency_id,
        "dependency_revision": receipt.dependency_revision,
        "dependency_sha256": receipt.dependency_sha256,
        "exact_product_mappings": list(receipt.exact_product_mappings),
        "mapping_record_id": receipt.mapping_record_id,
        "mapping_sha256": receipt.mapping_sha256,
        "previous_receipt_sha256": receipt.previous_receipt_sha256,
        "receipt_id": receipt.receipt_id,
        "receipt_revision": receipt.receipt_revision,
    }


def command_gate_approval_receipt_sha256(
    receipt: CommandGateApprovalReceipt,
) -> str:
    """Hash every approval binding while excluding the receipt self hash."""

    return hashlib.sha256(
        _stable_json(_approval_receipt_hash_payload(receipt))
    ).hexdigest()


def _required_string(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _error(f"{field} must be a trimmed nonempty string")
    return value


def _required_sha(value: object, field: str) -> str:
    result = _required_string(value, field)
    if SHA256.fullmatch(result) is None:
        raise _error(f"{field} must be SHA-256")
    return result


def _optional_sha(value: object, field: str) -> str | None:
    if value is None:
        return None
    return _required_sha(value, field)


def _optional_string(value: object, field: str) -> str | None:
    if value is None:
        return None
    return _required_string(value, field)


def _positive_integer(value: object, field: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 1:
        raise _error(f"{field} must be a positive integer")
    return value


def _sorted_mappings(value: object, field: str) -> tuple[str, ...]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item.strip() or item != item.strip()
        for item in value
    ):
        raise _error(f"{field} must be an array of trimmed strings")
    result = tuple(value)
    if result != tuple(sorted(set(result))):
        raise _error(f"{field} must be sorted and unique")
    return result


def _parse_dependency(value: object, path: Path) -> CommandGateDependency:
    if not isinstance(value, dict) or set(value) != DEPENDENCY_FIELDS:
        raise _error("dependency fields are closed", path)
    activation = value["activation_authorization"]
    if not isinstance(activation, bool):
        raise _error("activation_authorization must be boolean", path)
    dependency = CommandGateDependency(
        dependency_id=_required_string(value["dependency_id"], "dependency_id"),
        dependency_revision=_positive_integer(
            value["dependency_revision"], "dependency_revision"
        ),
        dependency_kind=_required_string(value["dependency_kind"], "dependency_kind"),
        owner_concept=_required_string(value["owner_concept"], "owner_concept"),
        requirement_id=_required_string(value["requirement_id"], "requirement_id"),
        state_id=_required_string(value["state_id"], "state_id"),
        command_id=_required_string(value["command_id"], "command_id"),
        owner_approval_state=_required_string(
            value["owner_approval_state"], "owner_approval_state"
        ),
        approval_receipt_id=_optional_string(
            value["approval_receipt_id"], "approval_receipt_id"
        ),
        mapping_record_id=_optional_string(
            value["mapping_record_id"], "mapping_record_id"
        ),
        canon_content_sha256=_required_sha(
            value["canon_content_sha256"], "canon_content_sha256"
        ),
        exact_product_mappings=_sorted_mappings(
            value["exact_product_mappings"], "exact_product_mappings"
        ),
        mapping_sha256=_optional_sha(value["mapping_sha256"], "mapping_sha256"),
        freshness=_required_string(value["freshness"], "freshness"),
        dependency_posture=_required_string(
            value["dependency_posture"], "dependency_posture"
        ),
        activation_authorization=activation,
        dependency_sha256=_required_sha(
            value["dependency_sha256"], "dependency_sha256"
        ),
    )
    _validate_dependency(dependency, path)
    return dependency


def _parse_approval_scope(value: object, path: Path) -> CommandGateApprovalScope:
    if not isinstance(value, dict) or set(value) != APPROVAL_SCOPE_FIELDS:
        raise _error("approval scope fields are closed", path)
    return CommandGateApprovalScope(
        owner_concept=_required_string(value["owner_concept"], "owner_concept"),
        requirement_id=_required_string(value["requirement_id"], "requirement_id"),
        state_id=_required_string(value["state_id"], "state_id"),
        command_id=_required_string(value["command_id"], "command_id"),
    )


def _parse_owner_approval_attestation(
    value: object,
    path: Path,
) -> CommandGateOwnerApprovalAttestation:
    if not isinstance(value, dict) or set(value) != OWNER_APPROVAL_ATTESTATION_FIELDS:
        raise _error("owner approval attestation fields are closed", path)
    attestation = CommandGateOwnerApprovalAttestation(
        approval_identity=_required_string(
            value["approval_identity"], "approval_identity"
        ),
        approval_revision=_positive_integer(
            value["approval_revision"], "approval_revision"
        ),
        approval_state=_required_string(value["approval_state"], "approval_state"),
        dependency_id=_required_string(value["dependency_id"], "dependency_id"),
        dependency_revision=_positive_integer(
            value["dependency_revision"], "dependency_revision"
        ),
        dependency_sha256=_required_sha(
            value["dependency_sha256"], "dependency_sha256"
        ),
        mapping_record_id=_required_string(
            value["mapping_record_id"], "mapping_record_id"
        ),
        exact_product_mappings=_sorted_mappings(
            value["exact_product_mappings"], "exact_product_mappings"
        ),
        mapping_sha256=_required_sha(value["mapping_sha256"], "mapping_sha256"),
        canon_content_sha256=_required_sha(
            value["canon_content_sha256"], "canon_content_sha256"
        ),
        approved_scope=_parse_approval_scope(value["approved_scope"], path),
        approved_scope_sha256=_required_sha(
            value["approved_scope_sha256"], "approved_scope_sha256"
        ),
        trusted_dependency_registry_sha256=_required_sha(
            value["trusted_dependency_registry_sha256"],
            "trusted_dependency_registry_sha256",
        ),
        trusted_receipt_registry_sha256=_required_sha(
            value["trusted_receipt_registry_sha256"],
            "trusted_receipt_registry_sha256",
        ),
        trusted_prior_receipt_sha256=_optional_sha(
            value["trusted_prior_receipt_sha256"],
            "trusted_prior_receipt_sha256",
        ),
        attestation_sha256=_required_sha(
            value["attestation_sha256"], "attestation_sha256"
        ),
    )
    _validate_owner_approval_attestation(attestation, path)
    return attestation


def _parse_approval_receipt(
    value: object,
    path: Path,
) -> CommandGateApprovalReceipt:
    if not isinstance(value, dict) or set(value) != APPROVAL_RECEIPT_FIELDS:
        raise _error("approval receipt fields are closed", path)
    receipt = CommandGateApprovalReceipt(
        receipt_id=_required_string(value["receipt_id"], "receipt_id"),
        receipt_revision=_positive_integer(
            value["receipt_revision"], "receipt_revision"
        ),
        dependency_id=_required_string(value["dependency_id"], "dependency_id"),
        dependency_revision=_positive_integer(
            value["dependency_revision"], "dependency_revision"
        ),
        mapping_record_id=_required_string(
            value["mapping_record_id"], "mapping_record_id"
        ),
        exact_product_mappings=_sorted_mappings(
            value["exact_product_mappings"], "exact_product_mappings"
        ),
        mapping_sha256=_required_sha(value["mapping_sha256"], "mapping_sha256"),
        dependency_sha256=_required_sha(
            value["dependency_sha256"], "dependency_sha256"
        ),
        canon_content_sha256=_required_sha(
            value["canon_content_sha256"], "canon_content_sha256"
        ),
        approval_identity=_required_string(
            value["approval_identity"], "approval_identity"
        ),
        approval_attestation_sha256=_required_sha(
            value["approval_attestation_sha256"],
            "approval_attestation_sha256",
        ),
        approval_state=_required_string(value["approval_state"], "approval_state"),
        approved_scope=_parse_approval_scope(value["approved_scope"], path),
        approved_scope_sha256=_required_sha(
            value["approved_scope_sha256"], "approved_scope_sha256"
        ),
        previous_receipt_sha256=_optional_sha(
            value["previous_receipt_sha256"], "previous_receipt_sha256"
        ),
        receipt_sha256=_required_sha(value["receipt_sha256"], "receipt_sha256"),
    )
    _validate_approval_receipt(receipt, path)
    return receipt


def _expected_receipt_id(dependency_id: str, revision: int) -> str:
    return f"APPROVAL-RECEIPT-{dependency_id}-R{revision:04d}"


def _expected_mapping_record_id(dependency_id: str, revision: int) -> str:
    return f"MAPPING-{dependency_id}-R{revision:04d}"


def _expected_approval_identity(dependency_id: str, revision: int) -> str:
    return f"OWNER-APPROVAL-{dependency_id}-R{revision:04d}"


def _validate_dependency(dependency: CommandGateDependency, path: Path | None) -> None:
    if DEPENDENCY_ID.fullmatch(dependency.dependency_id) is None:
        raise _error(f"invalid dependency ID: {dependency.dependency_id}", path)
    _positive_integer(dependency.dependency_revision, "dependency_revision")
    if dependency.dependency_kind != "storekit_product_registry":
        raise _error(f"unknown dependency kind: {dependency.dependency_kind}", path)
    if CONCEPT_ID.fullmatch(dependency.owner_concept) is None:
        raise _error("dependency owner concept is invalid", path)
    if CANON_ID.fullmatch(dependency.requirement_id) is None:
        raise _error("dependency requirement ID is invalid", path)
    if STATE_ID.fullmatch(dependency.state_id) is None:
        raise _error("dependency state ID is invalid", path)
    if COMMAND_ID.fullmatch(dependency.command_id) is None:
        raise _error("dependency command ID is invalid", path)
    if SHA256.fullmatch(dependency.canon_content_sha256) is None:
        raise _error("dependency canon content SHA is invalid", path)
    if dependency.owner_approval_state not in {"approved", "withheld"}:
        raise _error("owner_approval_state is not closed", path)
    if dependency.freshness not in {"absent", "current", "stale"}:
        raise _error("freshness is not closed", path)
    if dependency.dependency_posture not in {"blocked", "ready"}:
        raise _error("dependency_posture is not closed", path)
    expected_mapping_sha = (
        command_gate_mapping_sha256(dependency.exact_product_mappings)
        if dependency.exact_product_mappings
        else None
    )
    if dependency.mapping_sha256 != expected_mapping_sha:
        raise _error("exact product mapping hash is stale or contradictory", path)

    if dependency.owner_approval_state == "withheld":
        if (
            dependency.approval_receipt_id is not None
            or dependency.mapping_record_id is not None
            or dependency.exact_product_mappings
            or dependency.mapping_sha256 is not None
            or dependency.freshness != "absent"
            or dependency.dependency_posture != "blocked"
            or dependency.activation_authorization
        ):
            raise _error("withheld dependency must remain empty and blocked", path)
    else:
        if dependency.dependency_revision < 2:
            raise _error("approved mapping requires a new dependency revision", path)
        if dependency.approval_receipt_id != _expected_receipt_id(
            dependency.dependency_id,
            dependency.dependency_revision,
        ):
            raise _error("approved dependency lacks exact approval receipt identity", path)
        if dependency.mapping_record_id != _expected_mapping_record_id(
            dependency.dependency_id,
            dependency.dependency_revision,
        ):
            raise _error("approved dependency lacks exact mapping record identity", path)
        if not dependency.exact_product_mappings:
            raise _error("approved dependency lacks exact product mappings", path)

    expected_activation = bool(
        dependency.owner_approval_state == "approved"
        and dependency.approval_receipt_id
        and dependency.mapping_record_id
        and dependency.exact_product_mappings
        and dependency.freshness == "current"
        and dependency.dependency_posture == "ready"
    )
    if dependency.activation_authorization is not expected_activation:
        raise _error("activation authorization contradicts dependency posture", path)
    if dependency.dependency_sha256 != command_gate_dependency_sha256(dependency):
        raise _error("dependency hash is stale or invalid", path)


def _validate_approval_scope(
    scope: CommandGateApprovalScope,
    path: Path | None,
) -> None:
    if CONCEPT_ID.fullmatch(scope.owner_concept) is None:
        raise _error("approval scope owner concept is invalid", path)
    if CANON_ID.fullmatch(scope.requirement_id) is None:
        raise _error("approval scope requirement ID is invalid", path)
    if STATE_ID.fullmatch(scope.state_id) is None:
        raise _error("approval scope state ID is invalid", path)
    if COMMAND_ID.fullmatch(scope.command_id) is None:
        raise _error("approval scope command ID is invalid", path)


def _validate_owner_approval_attestation(
    attestation: CommandGateOwnerApprovalAttestation,
    path: Path | None,
) -> None:
    _validate_approval_scope(attestation.approved_scope, path)
    if APPROVAL_IDENTITY.fullmatch(attestation.approval_identity) is None:
        raise _error("owner approval attestation identity is invalid", path)
    if attestation.approval_state != "pending":
        raise _error("owner approval attestation state must be pending", path)
    if attestation.approval_revision != attestation.dependency_revision:
        raise _error("owner approval attestation revision is asymmetric", path)
    if DEPENDENCY_ID.fullmatch(attestation.dependency_id) is None:
        raise _error("owner approval attestation dependency ID is invalid", path)
    if attestation.dependency_revision < 2:
        raise _error("owner approval attestation requires revision 2 or later", path)
    if attestation.approval_identity != _expected_approval_identity(
        attestation.dependency_id,
        attestation.dependency_revision,
    ):
        raise _error("owner approval attestation identity is not revision bound", path)
    if (
        MAPPING_RECORD_ID.fullmatch(attestation.mapping_record_id) is None
        or attestation.mapping_record_id
        != _expected_mapping_record_id(
            attestation.dependency_id,
            attestation.dependency_revision,
        )
    ):
        raise _error("owner approval attestation mapping identity is invalid", path)
    if not attestation.exact_product_mappings:
        raise _error("owner approval attestation mappings are empty", path)
    if attestation.mapping_sha256 != command_gate_mapping_sha256(
        attestation.exact_product_mappings
    ):
        raise _error("owner approval attestation mapping hash is stale", path)
    if attestation.approved_scope_sha256 != command_gate_approval_scope_sha256(
        attestation.approved_scope
    ):
        raise _error("owner approval attestation scope hash is stale", path)
    if (
        attestation.attestation_sha256
        != command_gate_owner_approval_attestation_sha256(attestation)
    ):
        raise _error("owner approval attestation hash is stale", path)


def _validate_approval_receipt(
    receipt: CommandGateApprovalReceipt,
    path: Path | None,
) -> None:
    _validate_approval_scope(receipt.approved_scope, path)
    if APPROVAL_RECEIPT_ID.fullmatch(receipt.receipt_id) is None or (
        receipt.receipt_id
        != _expected_receipt_id(receipt.dependency_id, receipt.dependency_revision)
    ):
        raise _error("approval receipt identity is invalid", path)
    if receipt.receipt_revision != receipt.dependency_revision:
        raise _error("approval receipt revision does not bind dependency revision", path)
    if (
        receipt.dependency_revision == 2
        and receipt.previous_receipt_sha256 is not None
    ) or (
        receipt.dependency_revision > 2
        and receipt.previous_receipt_sha256 is None
    ):
        raise _error("approval receipt predecessor binding is invalid", path)
    if DEPENDENCY_ID.fullmatch(receipt.dependency_id) is None:
        raise _error("approval receipt dependency identity is invalid", path)
    if MAPPING_RECORD_ID.fullmatch(receipt.mapping_record_id) is None or (
        receipt.mapping_record_id
        != _expected_mapping_record_id(
            receipt.dependency_id,
            receipt.dependency_revision,
        )
    ):
        raise _error("approval receipt mapping record identity is invalid", path)
    if not receipt.exact_product_mappings:
        raise _error("approval receipt requires exact product mappings", path)
    if receipt.mapping_sha256 != command_gate_mapping_sha256(
        receipt.exact_product_mappings
    ):
        raise _error("approval receipt mapping hash is stale", path)
    if APPROVAL_IDENTITY.fullmatch(receipt.approval_identity) is None:
        raise _error("approval receipt identity is not an owner approval identity", path)
    if SHA256.fullmatch(receipt.approval_attestation_sha256) is None:
        raise _error("approval receipt attestation hash is invalid", path)
    if receipt.approval_state != "approved":
        raise _error("approval receipt state must be approved", path)
    if receipt.approved_scope_sha256 != command_gate_approval_scope_sha256(
        receipt.approved_scope
    ):
        raise _error("approval scope hash is stale", path)
    if receipt.receipt_sha256 != command_gate_approval_receipt_sha256(receipt):
        raise _error("approval receipt hash is stale or invalid", path)


def _dependency_payload(dependency: CommandGateDependency) -> dict[str, object]:
    return {
        **_dependency_hash_payload(dependency),
        "dependency_sha256": dependency.dependency_sha256,
    }


def _approval_receipt_payload(
    receipt: CommandGateApprovalReceipt,
) -> dict[str, object]:
    return {
        **_approval_receipt_hash_payload(receipt),
        "receipt_sha256": receipt.receipt_sha256,
    }


def _owner_approval_attestation_payload(
    attestation: CommandGateOwnerApprovalAttestation,
) -> dict[str, object]:
    return {
        **_owner_approval_attestation_hash_payload(attestation),
        "attestation_sha256": attestation.attestation_sha256,
    }


def render_command_gate_dependency_registry(
    registry: CommandGateDependencyRegistry,
) -> bytes:
    """Render the exact deterministic dependency-registry bytes."""

    return _pretty_json(
        {
            "canon_content_sha256": registry.canon_content_sha256,
            "canon_revision": registry.canon_revision,
            "dependencies": [
                _dependency_payload(item) for item in registry.dependencies
            ],
            "registry_id": registry.registry_id,
            "registry_revision": registry.registry_revision,
            "schema_version": registry.schema_version,
        }
    )


def render_command_gate_approval_receipt_registry(
    registry: CommandGateDependencyRegistry,
) -> bytes:
    """Render the exact deterministic append-only receipt-registry bytes."""

    return _pretty_json(
        {
            "approval_receipts": [
                _approval_receipt_payload(item)
                for item in registry.approval_receipts
            ],
            "canon_content_sha256": registry.canon_content_sha256,
            "canon_revision": registry.canon_revision,
            "registry_id": registry.approval_receipt_registry_id,
            "registry_revision": registry.approval_receipt_registry_revision,
            "schema_version": registry.schema_version,
        }
    )


def render_command_gate_owner_approval_registry(
    approvals: tuple[CommandGateOwnerApprovalAttestation, ...],
    *,
    registry_revision: int,
) -> bytes:
    """Render independent owner attestations; an empty list grants nothing."""

    return _pretty_json(
        {
            "owner_approvals": [
                _owner_approval_attestation_payload(item) for item in approvals
            ],
            "registry_id": "COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001",
            "registry_revision": registry_revision,
            "schema_version": 1,
        }
    )


def _current_canon_content_sha256(root: Path) -> str:
    return _load_audited_canon_snapshot(root).content_sha


def _load_approval_receipt_registry(
    root: Path,
    *,
    expected_canon_revision: int,
    expected_canon_content_sha256: str,
    source: bytes | None = None,
) -> tuple[str, int, tuple[CommandGateApprovalReceipt, ...], str]:
    path = root / APPROVAL_RECEIPT_REGISTRY_PATH
    try:
        if source is None:
            with _open_directory_absolute_nofollow(root) as descriptor:
                source = _read_file_at(
                    descriptor, APPROVAL_RECEIPT_REGISTRY_PATH
                )
        payload = json.loads(source)
    except (OSError, json.JSONDecodeError) as error:
        raise _error(f"cannot load approval receipt registry: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != APPROVAL_RECEIPT_REGISTRY_FIELDS:
        raise _error("approval receipt registry fields are closed", path)
    if isinstance(payload["schema_version"], bool) or payload["schema_version"] != 1:
        raise _error("approval receipt schema_version must be integer 1", path)
    registry_id = _required_string(payload["registry_id"], "registry_id")
    if registry_id != "COMMAND-GATE-APPROVAL-RECEIPT-REGISTRY-001":
        raise _error("approval receipt registry ID is invalid", path)
    revision = _positive_integer(payload["registry_revision"], "registry_revision")
    canon_revision = payload["canon_revision"]
    if (
        isinstance(canon_revision, bool)
        or not isinstance(canon_revision, int)
        or canon_revision != expected_canon_revision
    ):
        raise _error("approval receipt registry canon revision is stale", path)
    declared_canon_sha = _required_sha(
        payload["canon_content_sha256"], "canon_content_sha256"
    )
    if declared_canon_sha != expected_canon_content_sha256:
        raise _error("approval receipt registry canon content is stale", path)
    raw_receipts = payload["approval_receipts"]
    if not isinstance(raw_receipts, list):
        raise _error("approval_receipts must be an array", path)
    receipts = tuple(_parse_approval_receipt(item, path) for item in raw_receipts)
    receipt_ids = tuple(item.receipt_id for item in receipts)
    if receipt_ids != tuple(sorted(set(receipt_ids))):
        raise _error("approval receipts must be sorted with unique IDs", path)
    revision_keys = tuple(
        (item.dependency_id, item.dependency_revision) for item in receipts
    )
    if len(set(revision_keys)) != len(revision_keys):
        raise _error("dependency revision has multiple approval receipts", path)
    return registry_id, revision, receipts, hashlib.sha256(source).hexdigest()


def _load_owner_approval_registry(
    root: Path,
    *,
    source: bytes | None = None,
) -> tuple[
    str,
    int,
    tuple[CommandGateOwnerApprovalAttestation, ...],
    str,
]:
    path = root / OWNER_APPROVAL_REGISTRY_PATH
    try:
        if source is None:
            with _open_directory_absolute_nofollow(root) as descriptor:
                source = _read_file_at(descriptor, OWNER_APPROVAL_REGISTRY_PATH)
        payload = json.loads(source)
    except (OSError, json.JSONDecodeError) as error:
        raise _error(f"cannot load owner approval registry: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != OWNER_APPROVAL_REGISTRY_FIELDS:
        raise _error("owner approval registry fields are closed", path)
    if isinstance(payload["schema_version"], bool) or payload["schema_version"] != 1:
        raise _error("owner approval schema_version must be integer 1", path)
    registry_id = _required_string(payload["registry_id"], "registry_id")
    if registry_id != "COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001":
        raise _error("owner approval registry ID is invalid", path)
    revision = _positive_integer(payload["registry_revision"], "registry_revision")
    raw_approvals = payload["owner_approvals"]
    if not isinstance(raw_approvals, list):
        raise _error("owner_approvals must be an array", path)
    approvals = tuple(
        _parse_owner_approval_attestation(item, path) for item in raw_approvals
    )
    identities = tuple(item.approval_identity for item in approvals)
    if identities != tuple(sorted(set(identities))):
        raise _error("owner approvals must be sorted with unique identities", path)
    return registry_id, revision, approvals, hashlib.sha256(source).hexdigest()


def _parse_dependency_registry_snapshot(
    source: bytes,
    path: Path,
) -> tuple[int, int, str, tuple[CommandGateDependency, ...]]:
    try:
        payload = json.loads(source)
    except json.JSONDecodeError as error:
        raise _error(f"trusted dependency registry is invalid JSON: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != REGISTRY_FIELDS:
        raise _error("trusted dependency registry fields are closed", path)
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise _error("trusted dependency schema_version must be integer 1", path)
    if payload["registry_id"] != "COMMAND-GATE-DEPENDENCY-REGISTRY-001":
        raise _error("trusted dependency registry ID is invalid", path)
    registry_revision = _positive_integer(
        payload["registry_revision"], "registry_revision"
    )
    canon_revision = payload["canon_revision"]
    if isinstance(canon_revision, bool) or not isinstance(canon_revision, int):
        raise _error("trusted dependency canon revision is invalid", path)
    canon_sha = _required_sha(payload["canon_content_sha256"], "canon_content_sha256")
    raw = payload["dependencies"]
    if not isinstance(raw, list):
        raise _error("trusted dependencies must be an array", path)
    dependencies = tuple(_parse_dependency(item, path) for item in raw)
    identifiers = tuple(item.dependency_id for item in dependencies)
    if identifiers != tuple(sorted(set(identifiers))):
        raise _error("trusted dependencies must be sorted with unique IDs", path)
    return registry_revision, canon_revision, canon_sha, dependencies


def _parse_receipt_registry_snapshot(
    source: bytes,
    path: Path,
) -> tuple[int, int, str, tuple[CommandGateApprovalReceipt, ...]]:
    try:
        payload = json.loads(source)
    except json.JSONDecodeError as error:
        raise _error(f"trusted receipt registry is invalid JSON: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != APPROVAL_RECEIPT_REGISTRY_FIELDS:
        raise _error("trusted receipt registry fields are closed", path)
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise _error("trusted receipt schema_version must be integer 1", path)
    if payload["registry_id"] != "COMMAND-GATE-APPROVAL-RECEIPT-REGISTRY-001":
        raise _error("trusted receipt registry ID is invalid", path)
    registry_revision = _positive_integer(
        payload["registry_revision"], "registry_revision"
    )
    canon_revision = payload["canon_revision"]
    if isinstance(canon_revision, bool) or not isinstance(canon_revision, int):
        raise _error("trusted receipt canon revision is invalid", path)
    canon_sha = _required_sha(payload["canon_content_sha256"], "canon_content_sha256")
    raw = payload["approval_receipts"]
    if not isinstance(raw, list):
        raise _error("trusted approval_receipts must be an array", path)
    receipts = tuple(_parse_approval_receipt(item, path) for item in raw)
    identifiers = tuple(item.receipt_id for item in receipts)
    if identifiers != tuple(sorted(set(identifiers))):
        raise _error("trusted receipts must be sorted with unique IDs", path)
    return registry_revision, canon_revision, canon_sha, receipts


def _parse_owner_registry_snapshot(
    source: bytes,
    path: Path,
) -> tuple[int, tuple[CommandGateOwnerApprovalAttestation, ...]]:
    try:
        payload = json.loads(source)
    except json.JSONDecodeError as error:
        raise _error(f"trusted owner registry is invalid JSON: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != OWNER_APPROVAL_REGISTRY_FIELDS:
        raise _error("trusted owner approval registry fields are closed", path)
    if payload["schema_version"] != 1 or isinstance(payload["schema_version"], bool):
        raise _error("trusted owner schema_version must be integer 1", path)
    if payload["registry_id"] != "COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001":
        raise _error("trusted owner approval registry ID is invalid", path)
    revision = _positive_integer(payload["registry_revision"], "registry_revision")
    raw = payload["owner_approvals"]
    if not isinstance(raw, list):
        raise _error("trusted owner_approvals must be an array", path)
    approvals = tuple(_parse_owner_approval_attestation(item, path) for item in raw)
    identities = tuple(item.approval_identity for item in approvals)
    if identities != tuple(sorted(set(identities))):
        raise _error("trusted owner approvals must be sorted with unique IDs", path)
    return revision, approvals


def _parse_trusted_approval_base_from_bytes(
    dependency_registry_bytes: bytes,
    approval_receipt_registry_bytes: bytes,
    owner_approval_registry_bytes: bytes,
    *,
    authenticated_ci_context: AuthenticatedCommandGateCIContext | None,
    repository_root: Path | None,
) -> TrustedCommandGateApprovalBase:
    """Parse exact prior bytes after the caller has established provenance."""

    dependency_revision, dependency_canon_revision, dependency_canon_sha, dependencies = (
        _parse_dependency_registry_snapshot(
            dependency_registry_bytes,
            REGISTRY_PATH,
        )
    )
    receipt_revision, receipt_canon_revision, receipt_canon_sha, receipts = (
        _parse_receipt_registry_snapshot(
            approval_receipt_registry_bytes,
            APPROVAL_RECEIPT_REGISTRY_PATH,
        )
    )
    if (
        dependency_canon_revision != receipt_canon_revision
        or dependency_canon_sha != receipt_canon_sha
    ):
        raise _error("trusted registry canon identity is asymmetric")
    owner_revision, approvals = _parse_owner_registry_snapshot(
        owner_approval_registry_bytes,
        OWNER_APPROVAL_REGISTRY_PATH,
    )
    return TrustedCommandGateApprovalBase(
        authenticated_ci_context=authenticated_ci_context,
        repository_root=repository_root,
        dependency_registry_bytes=dependency_registry_bytes,
        approval_receipt_registry_bytes=approval_receipt_registry_bytes,
        owner_approval_registry_bytes=owner_approval_registry_bytes,
        dependency_registry_sha256=hashlib.sha256(
            dependency_registry_bytes
        ).hexdigest(),
        approval_receipt_registry_sha256=hashlib.sha256(
            approval_receipt_registry_bytes
        ).hexdigest(),
        owner_approval_registry_sha256=hashlib.sha256(
            owner_approval_registry_bytes
        ).hexdigest(),
        dependency_registry_revision=dependency_revision,
        approval_receipt_registry_revision=receipt_revision,
        owner_approval_registry_revision=owner_revision,
        dependencies=dependencies,
        approval_receipts=receipts,
        owner_approvals=approvals,
    )


def load_trusted_approval_base_from_bytes(
    dependency_registry_bytes: bytes,
    approval_receipt_registry_bytes: bytes,
    owner_approval_registry_bytes: bytes,
) -> TrustedCommandGateApprovalBase:
    """Parse a controller/test snapshot that cannot authorize a transition."""

    return _parse_trusted_approval_base_from_bytes(
        dependency_registry_bytes,
        approval_receipt_registry_bytes,
        owner_approval_registry_bytes,
        authenticated_ci_context=None,
        repository_root=None,
    )


def _git_bytes(root: Path, *arguments: str) -> bytes:
    try:
        return subprocess.run(
            ["git", *arguments],
            cwd=root,
            check=True,
            capture_output=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError) as error:
        raise _error(f"trusted Git approval base cannot be read: {error}", root) from error


def _validate_authenticated_ci_context(
    repository_root: Path,
    context: AuthenticatedCommandGateCIContext,
    path: Path | None = None,
) -> None:
    if context.protected_ref != PROTECTED_COMMAND_GATE_REF:
        raise _error("authenticated CI context must use the fixed protected ref", path)
    if context.provenance != PROTECTED_COMMAND_GATE_CI_PROVENANCE:
        raise _error("authenticated CI context provenance is invalid", path)
    if (
        GIT_SHA.fullmatch(context.protected_sha) is None
        or GIT_SHA.fullmatch(context.candidate_head_sha) is None
    ):
        raise _error("authenticated CI context requires full Git SHAs", path)
    if context.context_sha256 != command_gate_ci_context_sha256(context):
        raise _error("authenticated CI context digest is stale", path)

    actual_head = _git_bytes(
        repository_root,
        "rev-parse",
        "--verify",
        "HEAD^{commit}",
    ).decode("ascii").strip()
    if actual_head != context.candidate_head_sha:
        raise _error(
            "actual HEAD does not match authenticated candidate SHA",
            path,
        )
    protected_ref_sha = _git_bytes(
        repository_root,
        "rev-parse",
        "--verify",
        f"{PROTECTED_COMMAND_GATE_REF}^{{commit}}",
    ).decode("ascii").strip()
    if protected_ref_sha != context.protected_sha:
        raise _error(
            "fixed protected ref does not resolve exactly to authenticated protected SHA",
            path,
        )
    if context.protected_sha == context.candidate_head_sha:
        raise _error(
            "authenticated protected SHA must be a strict ancestor, never HEAD",
            path,
        )
    try:
        _git_bytes(
            repository_root,
            "merge-base",
            "--is-ancestor",
            context.protected_sha,
            context.candidate_head_sha,
        )
    except CanonError as error:
        raise _error(
            "authenticated protected SHA must be a strict ancestor of candidate HEAD",
            path,
        ) from error


def load_trusted_approval_base_from_git(
    root: Path,
    *,
    authenticated_ci_context: AuthenticatedCommandGateCIContext,
) -> TrustedCommandGateApprovalBase:
    """Load prior bytes from the externally authenticated protected CI base."""

    repository_root = root.resolve()
    _validate_authenticated_ci_context(
        repository_root,
        authenticated_ci_context,
        repository_root,
    )

    def show(path: Path) -> bytes:
        return _git_bytes(
            repository_root,
            "show",
            f"{authenticated_ci_context.protected_sha}:{path.as_posix()}",
        )

    return _parse_trusted_approval_base_from_bytes(
        show(REGISTRY_PATH),
        show(APPROVAL_RECEIPT_REGISTRY_PATH),
        show(OWNER_APPROVAL_REGISTRY_PATH),
        authenticated_ci_context=authenticated_ci_context,
        repository_root=repository_root,
    )


def _validate_trusted_git_approval_base(
    registry: CommandGateDependencyRegistry,
    trusted: TrustedCommandGateApprovalBase,
) -> TrustedCommandGateApprovalBase:
    """Re-prove Git provenance and exact object bytes at authorization time."""

    repository_root = registry.repository_root.resolve()
    if (
        trusted.repository_root is None
        or trusted.repository_root.resolve() != repository_root
        or trusted.authenticated_ci_context is None
    ):
        raise _error(
            "approved dependency requires an authenticated CI context",
            registry.source_path,
        )
    try:
        _validate_authenticated_ci_context(
            repository_root,
            trusted.authenticated_ci_context,
            registry.source_path,
        )

        def show(path: Path) -> bytes:
            return _git_bytes(
                repository_root,
                "show",
                f"{trusted.authenticated_ci_context.protected_sha}:"
                f"{path.as_posix()}",
            )

        live_bytes = (
            show(REGISTRY_PATH),
            show(APPROVAL_RECEIPT_REGISTRY_PATH),
            show(OWNER_APPROVAL_REGISTRY_PATH),
        )
    except CanonError as error:
        raise _error(
            "approved dependency requires a current authenticated CI context",
            registry.source_path,
        ) from error
    trusted_bytes = (
        trusted.dependency_registry_bytes,
        trusted.approval_receipt_registry_bytes,
        trusted.owner_approval_registry_bytes,
    )
    if live_bytes != trusted_bytes:
        raise _error(
            "authenticated protected-base approval bytes changed",
            registry.source_path,
        )
    return _parse_trusted_approval_base_from_bytes(
        *live_bytes,
        authenticated_ci_context=trusted.authenticated_ci_context,
        repository_root=repository_root,
    )


def load_command_gate_dependency_registry(
    root: Path,
    *,
    expected_canon_revision: int | None = None,
) -> CommandGateDependencyRegistry:
    """Load dependencies against a live audited canon identity."""

    with _open_directory_absolute_nofollow(root) as descriptor:
        captured = _capture_command_gate_input_bytes(descriptor)
        audited = _load_audited_canon_snapshot(root)
        registry = _load_command_gate_dependency_registry_for_audited_canon(
            root,
            audited,
            expected_canon_revision=expected_canon_revision,
            captured_inputs=captured,
        )
        if _capture_command_gate_input_bytes(descriptor) != captured:
            raise _error(
                "live command-gate bytes changed during registry load",
                root / REGISTRY_PATH,
            )
        _verify_audited_canon_snapshot(root, audited)
        return registry


def _capture_command_gate_input_bytes(
    root_descriptor: int,
) -> tuple[tuple[Path, bytes], ...]:
    return tuple(
        (path, _read_file_at(root_descriptor, path))
        for path in _COMMAND_GATE_INPUT_PATHS
    )


def _load_command_gate_dependency_registry_for_audited_canon(
    root: Path,
    audited: _AuditedCanonSnapshot,
    *,
    expected_canon_revision: int | None = None,
    captured_inputs: tuple[tuple[Path, bytes], ...] | None = None,
) -> CommandGateDependencyRegistry:
    """Module-private optimized load bound to a loader-owned audit context."""

    repository_root = Path(os.path.abspath(root))
    path = repository_root / REGISTRY_PATH
    captured = dict(captured_inputs or ())
    try:
        if REGISTRY_PATH in captured:
            source = captured[REGISTRY_PATH]
        else:
            with _open_directory_absolute_nofollow(repository_root) as descriptor:
                source = _read_file_at(descriptor, REGISTRY_PATH)
        payload = json.loads(source)
    except (OSError, json.JSONDecodeError) as error:
        raise _error(f"cannot load command-gate dependency registry: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != REGISTRY_FIELDS:
        raise _error("registry fields are closed", path)
    if isinstance(payload["schema_version"], bool) or payload["schema_version"] != 1:
        raise _error("schema_version must be integer 1", path)
    registry_id = _required_string(payload["registry_id"], "registry_id")
    if registry_id != "COMMAND-GATE-DEPENDENCY-REGISTRY-001":
        raise _error("registry ID is not the approved stable identity", path)
    registry_revision = _positive_integer(
        payload["registry_revision"], "registry_revision"
    )
    canon_revision = payload["canon_revision"]
    if (
        isinstance(canon_revision, bool)
        or not isinstance(canon_revision, int)
        or canon_revision < 0
    ):
        raise _error("canon_revision must be a nonnegative integer", path)
    if expected_canon_revision is not None and canon_revision != expected_canon_revision:
        raise _error("registry canon revision is stale", path)
    current_canon_sha = audited.content_sha
    if SHA256.fullmatch(current_canon_sha) is None:
        raise _error("expected canon content SHA is invalid", path)
    declared_canon_sha = _required_sha(
        payload["canon_content_sha256"], "canon_content_sha256"
    )
    if declared_canon_sha != current_canon_sha:
        raise _error("registry canon content is stale", path)
    raw_dependencies = payload["dependencies"]
    if not isinstance(raw_dependencies, list):
        raise _error("dependencies must be an array", path)
    dependencies = tuple(_parse_dependency(item, path) for item in raw_dependencies)
    identifiers = tuple(item.dependency_id for item in dependencies)
    if identifiers != tuple(sorted(set(identifiers))):
        raise _error("dependencies must be sorted with unique IDs", path)
    for dependency in dependencies:
        if dependency.canon_content_sha256 != current_canon_sha:
            raise _error("dependency canon content is stale", path)
    (
        approval_registry_id,
        approval_registry_revision,
        approval_receipts,
        approval_source_sha,
    ) = _load_approval_receipt_registry(
        repository_root,
        expected_canon_revision=canon_revision,
        expected_canon_content_sha256=current_canon_sha,
        source=captured.get(APPROVAL_RECEIPT_REGISTRY_PATH),
    )
    (
        owner_registry_id,
        owner_registry_revision,
        owner_approvals,
        owner_source_sha,
    ) = _load_owner_approval_registry(
        repository_root,
        source=captured.get(OWNER_APPROVAL_REGISTRY_PATH),
    )
    registry = CommandGateDependencyRegistry(
        schema_version=1,
        registry_id=registry_id,
        registry_revision=registry_revision,
        canon_revision=canon_revision,
        canon_content_sha256=current_canon_sha,
        dependencies=dependencies,
        approval_receipt_registry_id=approval_registry_id,
        approval_receipt_registry_revision=approval_registry_revision,
        approval_receipts=approval_receipts,
        approval_receipt_source_sha256=approval_source_sha,
        owner_approval_registry_id=owner_registry_id,
        owner_approval_registry_revision=owner_registry_revision,
        owner_approvals=owner_approvals,
        owner_approval_source_sha256=owner_source_sha,
        source_sha256=hashlib.sha256(source).hexdigest(),
        source_path=path,
        repository_root=repository_root,
    )
    _validate_registry_approval_bindings(registry)
    return registry


def _validate_registry_approval_bindings(
    registry: CommandGateDependencyRegistry,
) -> None:
    receipts = {item.receipt_id: item for item in registry.approval_receipts}
    if len(receipts) != len(registry.approval_receipts):
        raise _error("duplicate approval receipt identity", registry.source_path)
    for receipt in registry.approval_receipts:
        _validate_approval_receipt(receipt, registry.source_path)
    approvals = {item.approval_identity: item for item in registry.owner_approvals}
    if len(approvals) != len(registry.owner_approvals):
        raise _error("duplicate owner approval attestation", registry.source_path)
    for approval in registry.owner_approvals:
        _validate_owner_approval_attestation(approval, registry.source_path)
    for receipt in registry.approval_receipts:
        attestation = approvals.get(receipt.approval_identity)
        if (
            attestation is None
            or receipt.approval_attestation_sha256
            != attestation.attestation_sha256
            or receipt.approval_state != "approved"
            or attestation.approval_state != "pending"
            or receipt.dependency_id != attestation.dependency_id
            or receipt.dependency_revision != attestation.dependency_revision
            or receipt.dependency_sha256 != attestation.dependency_sha256
            or receipt.mapping_record_id != attestation.mapping_record_id
            or receipt.exact_product_mappings
            != attestation.exact_product_mappings
            or receipt.mapping_sha256 != attestation.mapping_sha256
            or receipt.canon_content_sha256
            != attestation.canon_content_sha256
            or receipt.approved_scope != attestation.approved_scope
            or receipt.approved_scope_sha256
            != attestation.approved_scope_sha256
        ):
            raise _error(
                "approval receipt and owner attestation binding is asymmetric",
                registry.source_path,
            )
    receipts_by_dependency: dict[str, list[CommandGateApprovalReceipt]] = {}
    for receipt in registry.approval_receipts:
        receipts_by_dependency.setdefault(receipt.dependency_id, []).append(receipt)
    for dependency_id, history in receipts_by_dependency.items():
        history.sort(key=lambda item: item.dependency_revision)
        revisions = tuple(item.dependency_revision for item in history)
        if revisions != tuple(range(2, revisions[-1] + 1)):
            raise _error(
                f"approval receipt history is not append-only: {dependency_id}",
                registry.source_path,
            )
        for previous, current in zip(history, history[1:], strict=False):
            if current.previous_receipt_sha256 != previous.receipt_sha256:
                raise _error(
                    f"approval receipt history chain is stale: {dependency_id}",
                    registry.source_path,
                )
    for dependency in registry.dependencies:
        _validate_dependency(dependency, registry.source_path)
        if dependency.canon_content_sha256 != registry.canon_content_sha256:
            raise _error("dependency canon content is stale", registry.source_path)
        if dependency.owner_approval_state == "withheld":
            continue
        receipt = receipts.get(dependency.approval_receipt_id or "")
        if receipt is None:
            raise _error(
                f"approved dependency has no resolvable approval receipt: "
                f"{dependency.dependency_id}",
                registry.source_path,
            )


def _record_bytes(value: object) -> bytes:
    return _stable_json(value)


def _approval_scope_for_dependency(
    dependency: CommandGateDependency,
) -> CommandGateApprovalScope:
    return CommandGateApprovalScope(
        owner_concept=dependency.owner_concept,
        requirement_id=dependency.requirement_id,
        state_id=dependency.state_id,
        command_id=dependency.command_id,
    )


def _validate_exact_receipt_dependency_binding(
    dependency: CommandGateDependency,
    receipt: CommandGateApprovalReceipt,
    attestation: CommandGateOwnerApprovalAttestation,
    path: Path,
) -> None:
    expected_scope = _approval_scope_for_dependency(dependency)
    if (
        receipt.dependency_id != dependency.dependency_id
        or receipt.dependency_revision != dependency.dependency_revision
        or receipt.receipt_revision != dependency.dependency_revision
        or receipt.mapping_record_id != dependency.mapping_record_id
        or receipt.exact_product_mappings != dependency.exact_product_mappings
        or receipt.mapping_sha256 != dependency.mapping_sha256
        or receipt.dependency_sha256 != dependency.dependency_sha256
        or receipt.canon_content_sha256 != dependency.canon_content_sha256
        or receipt.approval_identity != attestation.approval_identity
        or receipt.approval_attestation_sha256 != attestation.attestation_sha256
        or receipt.approved_scope != expected_scope
        or receipt.approval_state != "approved"
    ):
        raise _error(
            f"approval receipt does not bind exact dependency content: "
            f"{dependency.dependency_id}",
            path,
        )


def _validate_exact_attestation_dependency_binding(
    dependency: CommandGateDependency,
    attestation: CommandGateOwnerApprovalAttestation,
    path: Path,
) -> None:
    expected_scope = _approval_scope_for_dependency(dependency)
    if (
        attestation.dependency_id != dependency.dependency_id
        or attestation.dependency_revision != dependency.dependency_revision
        or attestation.dependency_sha256 != dependency.dependency_sha256
        or attestation.mapping_record_id != dependency.mapping_record_id
        or attestation.exact_product_mappings
        != dependency.exact_product_mappings
        or attestation.mapping_sha256 != dependency.mapping_sha256
        or attestation.canon_content_sha256 != dependency.canon_content_sha256
        or attestation.approved_scope != expected_scope
        or attestation.approved_scope_sha256
        != command_gate_approval_scope_sha256(expected_scope)
    ):
        raise _error("owner approval attestation binding is asymmetric", path)


def _validate_pending_attestation_staging_binding(
    prior: CommandGateDependency,
    attestation: CommandGateOwnerApprovalAttestation,
    trusted: TrustedCommandGateApprovalBase,
    path: Path,
) -> None:
    prior_history = tuple(
        item
        for item in trusted.approval_receipts
        if item.dependency_id == prior.dependency_id
    )
    prior_head = prior_history[-1].receipt_sha256 if prior_history else None
    if (
        attestation.approval_state != "pending"
        or attestation.dependency_id != prior.dependency_id
        or attestation.dependency_revision != prior.dependency_revision + 1
        or attestation.trusted_dependency_registry_sha256
        != trusted.dependency_registry_sha256
        or attestation.trusted_receipt_registry_sha256
        != trusted.approval_receipt_registry_sha256
        or attestation.trusted_prior_receipt_sha256 != prior_head
    ):
        raise _error(
            "pending owner attestation does not bind the protected registry heads",
            path,
        )
    future = CommandGateDependency(
        dependency_id=prior.dependency_id,
        dependency_revision=attestation.dependency_revision,
        dependency_kind=prior.dependency_kind,
        owner_concept=prior.owner_concept,
        requirement_id=prior.requirement_id,
        state_id=prior.state_id,
        command_id=prior.command_id,
        owner_approval_state="approved",
        approval_receipt_id=_expected_receipt_id(
            prior.dependency_id,
            attestation.dependency_revision,
        ),
        mapping_record_id=attestation.mapping_record_id,
        canon_content_sha256=attestation.canon_content_sha256,
        exact_product_mappings=attestation.exact_product_mappings,
        mapping_sha256=attestation.mapping_sha256,
        freshness="current",
        dependency_posture="ready",
        activation_authorization=True,
        dependency_sha256=attestation.dependency_sha256,
    )
    _validate_dependency(future, path)
    _validate_exact_attestation_dependency_binding(future, attestation, path)


def _validate_trusted_approval_transition(
    registry: CommandGateDependencyRegistry,
    trusted: TrustedCommandGateApprovalBase,
) -> None:
    trusted_owner_bytes = tuple(
        _record_bytes(_owner_approval_attestation_payload(item))
        for item in trusted.owner_approvals
    )
    candidate_owner_bytes = tuple(
        _record_bytes(_owner_approval_attestation_payload(item))
        for item in registry.owner_approvals
    )
    if (
        len(candidate_owner_bytes) < len(trusted_owner_bytes)
        or candidate_owner_bytes[: len(trusted_owner_bytes)]
        != trusted_owner_bytes
    ):
        raise _error(
            "immutable owner approval history was deleted or replaced",
            registry.source_path,
        )
    appended_attestations = registry.owner_approvals[len(trusted.owner_approvals) :]
    if appended_attestations:
        if (
            len(appended_attestations) != 1
            or registry.owner_approval_registry_revision
            != trusted.owner_approval_registry_revision + 1
        ):
            raise _error(
                "pending owner attestation staging must append exactly one revision",
                registry.source_path,
            )
    elif (
        registry.owner_approval_source_sha256
        != trusted.owner_approval_registry_sha256
        or registry.owner_approval_registry_revision
        != trusted.owner_approval_registry_revision
    ):
        raise _error(
            "owner approval registry mutated during pending consumption",
            registry.source_path,
        )

    trusted_receipt_bytes = tuple(
        _record_bytes(_approval_receipt_payload(item))
        for item in trusted.approval_receipts
    )
    candidate_receipt_bytes = tuple(
        _record_bytes(_approval_receipt_payload(item))
        for item in registry.approval_receipts
    )
    if (
        len(candidate_receipt_bytes) < len(trusted_receipt_bytes)
        or candidate_receipt_bytes[: len(trusted_receipt_bytes)]
        != trusted_receipt_bytes
    ):
        raise _error("immutable receipt history was deleted or replaced", registry.source_path)

    trusted_dependencies = {
        item.dependency_id: item for item in trusted.dependencies
    }
    candidate_dependencies = {item.dependency_id: item for item in registry.dependencies}
    if set(trusted_dependencies) != set(candidate_dependencies):
        raise _error("trusted dependency identity set changed", registry.source_path)

    appended_receipts = registry.approval_receipts[len(trusted.approval_receipts) :]
    changed_dependencies: list[CommandGateDependency] = []
    for dependency_id in sorted(candidate_dependencies):
        prior = trusted_dependencies[dependency_id]
        candidate = candidate_dependencies[dependency_id]
        prior_bytes = _record_bytes(_dependency_payload(prior))
        candidate_bytes = _record_bytes(_dependency_payload(candidate))
        if candidate.dependency_revision == prior.dependency_revision:
            if candidate_bytes != prior_bytes:
                raise _error(
                    f"dependency revision reuse changed content: {dependency_id}",
                    registry.source_path,
                )
            continue
        if candidate.dependency_revision != prior.dependency_revision + 1:
            raise _error(
                f"dependency revision must advance exactly once: {dependency_id}",
                registry.source_path,
            )
        changed_dependencies.append(candidate)

    if appended_attestations:
        if changed_dependencies or appended_receipts:
            raise _error(
                "pending attestation staging and consumption cannot be mixed",
                registry.source_path,
            )
        if (
            render_command_gate_dependency_registry(registry)
            != trusted.dependency_registry_bytes
            or render_command_gate_approval_receipt_registry(registry)
            != trusted.approval_receipt_registry_bytes
        ):
            raise _error(
                "pending attestation staging cannot change dependency or receipt state",
                registry.source_path,
            )
        pending = appended_attestations[0]
        prior = trusted_dependencies.get(pending.dependency_id)
        if prior is None:
            raise _error(
                "pending owner attestation dependency is not protected-base owned",
                registry.source_path,
            )
        _validate_pending_attestation_staging_binding(
            prior,
            pending,
            trusted,
            registry.source_path,
        )
    elif len(appended_receipts) != len(changed_dependencies):
        raise _error("approval receipt history append count is invalid", registry.source_path)

    appended_by_dependency = {item.dependency_id: item for item in appended_receipts}
    if len(appended_by_dependency) != len(appended_receipts):
        raise _error(
            "approval receipt history append identities are invalid",
            registry.source_path,
        )

    trusted_approvals = {
        item.approval_identity: item for item in trusted.owner_approvals
    }
    trusted_consumed_approval_ids = {
        item.approval_identity for item in trusted.approval_receipts
    }
    for dependency in changed_dependencies:
        receipt = appended_by_dependency.get(dependency.dependency_id)
        if receipt is None or receipt.dependency_revision != dependency.dependency_revision:
            raise _error(
                f"approval receipt history lacks the exact appended revision: "
                f"{dependency.dependency_id}",
                registry.source_path,
            )
        if dependency.owner_approval_state != "approved":
            raise _error(
                "approval history does not bind exact changed dependency: "
                f"{dependency.dependency_id}",
                registry.source_path,
            )
        prior_history = [
            item
            for item in trusted.approval_receipts
            if item.dependency_id == dependency.dependency_id
        ]
        prior_head = prior_history[-1].receipt_sha256 if prior_history else None
        if receipt.previous_receipt_sha256 != prior_head:
            raise _error(
                "approval receipt predecessor is not the trusted head",
                registry.source_path,
            )
        attestation = trusted_approvals.get(receipt.approval_identity)
        if (
            attestation is None
            or attestation.approval_state != "pending"
            or attestation.attestation_sha256
            != receipt.approval_attestation_sha256
            or receipt.approval_identity in trusted_consumed_approval_ids
        ):
            raise _error(
                "pending owner approval attestation is not consumable exactly once",
                registry.source_path,
            )
        if (
            attestation.trusted_dependency_registry_sha256
            != trusted.dependency_registry_sha256
            or attestation.trusted_receipt_registry_sha256
            != trusted.approval_receipt_registry_sha256
            or attestation.trusted_prior_receipt_sha256 != prior_head
        ):
            raise _error("owner approval attestation binding is asymmetric", registry.source_path)

    candidate_approvals = {
        item.approval_identity: item for item in registry.owner_approvals
    }
    for dependency in registry.dependencies:
        if dependency.owner_approval_state != "approved":
            continue
        receipt = next(
            (
                item
                for item in registry.approval_receipts
                if item.receipt_id == dependency.approval_receipt_id
            ),
            None,
        )
        attestation = (
            candidate_approvals.get(receipt.approval_identity)
            if receipt is not None
            else None
        )
        if (
            receipt is None
            or attestation is None
            or receipt.approval_attestation_sha256
            != attestation.attestation_sha256
        ):
            raise _error(
                "owner approval attestation is not resolvable",
                registry.source_path,
            )
        receipt_history = tuple(
            item
            for item in registry.approval_receipts
            if item.dependency_id == dependency.dependency_id
        )
        if not receipt_history or receipt is not receipt_history[-1]:
            raise _error(
                f"approval receipt does not bind exact dependency content: "
                f"{dependency.dependency_id}",
                registry.source_path,
            )
        _validate_exact_receipt_dependency_binding(
            dependency,
            receipt,
            attestation,
            registry.source_path,
        )
        _validate_exact_attestation_dependency_binding(
            dependency,
            attestation,
            registry.source_path,
        )


def validate_command_gate_dependency_bindings(
    registry: CommandGateDependencyRegistry,
    contracts: tuple[StateCommandContract, ...],
    *,
    canon_revision: int,
    trusted_approval_base: TrustedCommandGateApprovalBase | None = None,
) -> None:
    """Require symmetric binding against a live audited canon identity."""

    with _open_directory_absolute_nofollow(
        registry.repository_root
    ) as descriptor:
        initial_inputs = _capture_command_gate_input_bytes(descriptor)
        expected_inputs = (
            (REGISTRY_PATH, render_command_gate_dependency_registry(registry)),
            (
                APPROVAL_RECEIPT_REGISTRY_PATH,
                render_command_gate_approval_receipt_registry(registry),
            ),
            (
                OWNER_APPROVAL_REGISTRY_PATH,
                render_command_gate_owner_approval_registry(
                    registry.owner_approvals,
                    registry_revision=registry.owner_approval_registry_revision,
                ),
            ),
        )
        if initial_inputs != expected_inputs:
            raise _error(
                "caller registry does not match exact live command-gate bytes",
                registry.source_path,
            )
        initial_canon_sha = _current_canon_content_sha256(
            registry.repository_root
        )
        context = _CommandGateCanonContext(initial_canon_sha)
        _validate_command_gate_dependency_bindings_for_audited_canon(
            registry,
            contracts,
            context,
            canon_revision=canon_revision,
            trusted_approval_base=trusted_approval_base,
        )
        if _capture_command_gate_input_bytes(descriptor) != initial_inputs:
            raise _error(
                "live command-gate bytes changed during authorization validation",
                registry.source_path,
            )
        if (
            _current_canon_content_sha256(registry.repository_root)
            != initial_canon_sha
        ):
            raise _error(
                "canonical source changed during command-gate validation",
                registry.source_path,
            )


def _validate_command_gate_dependency_bindings_for_audited_canon(
    registry: CommandGateDependencyRegistry,
    contracts: tuple[StateCommandContract, ...],
    audited: _AuditedCanonSnapshot | _CommandGateCanonContext,
    *,
    canon_revision: int,
    trusted_approval_base: TrustedCommandGateApprovalBase | None = None,
) -> None:
    """Module-private optimized validation for one loader-owned audit context."""

    if (
        registry.schema_version != 1
        or registry.registry_id != "COMMAND-GATE-DEPENDENCY-REGISTRY-001"
        or isinstance(registry.registry_revision, bool)
        or not isinstance(registry.registry_revision, int)
        or registry.registry_revision < 1
        or registry.approval_receipt_registry_id
        != "COMMAND-GATE-APPROVAL-RECEIPT-REGISTRY-001"
        or isinstance(registry.approval_receipt_registry_revision, bool)
        or not isinstance(registry.approval_receipt_registry_revision, int)
        or registry.approval_receipt_registry_revision < 1
        or registry.owner_approval_registry_id
        != "COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001"
        or isinstance(registry.owner_approval_registry_revision, bool)
        or not isinstance(registry.owner_approval_registry_revision, int)
        or registry.owner_approval_registry_revision < 1
        or SHA256.fullmatch(registry.source_sha256) is None
        or SHA256.fullmatch(registry.approval_receipt_source_sha256) is None
        or SHA256.fullmatch(registry.owner_approval_source_sha256) is None
    ):
        raise _error("registry identity, revision, or source hash is invalid")
    if registry.canon_revision != canon_revision:
        raise _error("registry canon revision is stale", registry.source_path)
    current_canon_sha = audited.content_sha
    if SHA256.fullmatch(current_canon_sha) is None:
        raise _error("expected canon content SHA is invalid", registry.source_path)
    if registry.canon_content_sha256 != current_canon_sha:
        raise _error("registry canon content is stale", registry.source_path)
    requires_trusted_approval = bool(
        registry.approval_receipts
        or registry.owner_approvals
        or any(
            item.owner_approval_state == "approved"
            or item.activation_authorization
            for item in registry.dependencies
        )
    )
    if requires_trusted_approval:
        if trusted_approval_base is None:
            raise _error("approved dependency requires a trusted approval base")
        trusted_approval_base = _validate_trusted_git_approval_base(
            registry,
            trusted_approval_base,
        )
        _validate_trusted_approval_transition(registry, trusted_approval_base)
    _validate_registry_approval_bindings(registry)
    if registry.source_sha256 != hashlib.sha256(
        render_command_gate_dependency_registry(registry)
    ).hexdigest():
        raise _error("dependency registry source hash is stale", registry.source_path)
    if registry.approval_receipt_source_sha256 != hashlib.sha256(
        render_command_gate_approval_receipt_registry(registry)
    ).hexdigest():
        raise _error("approval receipt registry source hash is stale", registry.source_path)
    owner_bytes = render_command_gate_owner_approval_registry(
        registry.owner_approvals,
        registry_revision=registry.owner_approval_registry_revision,
    )
    if registry.owner_approval_source_sha256 != hashlib.sha256(owner_bytes).hexdigest():
        raise _error("owner approval registry source hash is stale", registry.source_path)

    dependencies = {item.dependency_id: item for item in registry.dependencies}
    if len(dependencies) != len(registry.dependencies):
        raise _error("duplicate dependency ID", registry.source_path)
    referenced: dict[str, tuple[StateCommandContract, StateCommand]] = {}
    for contract in contracts:
        for command in contract.commands:
            for dependency_id in command.gate_dependency_ids:
                if dependency_id in referenced:
                    raise _error(
                        f"dependency is bound to multiple commands: {dependency_id}",
                        registry.source_path,
                    )
                dependency = dependencies.get(dependency_id)
                if dependency is None:
                    raise _error(
                        f"command dependency is missing: {dependency_id}",
                        registry.source_path,
                    )
                if (
                    dependency.owner_concept != command.canonical_owner
                    or dependency.requirement_id != contract.requirement_id
                    or dependency.state_id != contract.state_id
                    or dependency.command_id != command.command_id
                ):
                    raise _error(
                        f"command dependency binding is asymmetric: {dependency_id}",
                        registry.source_path,
                    )
                referenced[dependency_id] = (contract, command)
    unbound = sorted(set(dependencies) - set(referenced))
    if unbound:
        raise _error(f"registry dependency has no symmetric command binding: {unbound[0]}")


def command_gate_approval_receipt_projection(
    receipt: CommandGateApprovalReceipt,
) -> dict[str, object]:
    """Project a fully resolvable, exact approval receipt into a task pack."""

    return {
        **_approval_receipt_hash_payload(receipt),
        "receipt_sha256": receipt.receipt_sha256,
    }


def command_gate_dependency_projection(
    registry: CommandGateDependencyRegistry,
    command: StateCommand,
) -> list[dict[str, object]]:
    """Project exact mappings and independently resolvable receipts into a pack."""

    dependencies = {item.dependency_id: item for item in registry.dependencies}
    receipts = {item.receipt_id: item for item in registry.approval_receipts}
    return [
        {
            "activation_authorization": dependency.activation_authorization,
            "approval_receipt": (
                command_gate_approval_receipt_projection(receipt)
                if receipt is not None
                else None
            ),
            "approval_receipt_id": dependency.approval_receipt_id,
            "approval_receipt_registry_id": registry.approval_receipt_registry_id,
            "approval_receipt_registry_revision": (
                registry.approval_receipt_registry_revision
            ),
            "approval_receipt_source_sha256": registry.approval_receipt_source_sha256,
            "canon_content_sha256": dependency.canon_content_sha256,
            "dependency_id": dependency.dependency_id,
            "dependency_kind": dependency.dependency_kind,
            "dependency_posture": dependency.dependency_posture,
            "dependency_revision": dependency.dependency_revision,
            "dependency_sha256": dependency.dependency_sha256,
            "exact_product_mappings": list(dependency.exact_product_mappings),
            "freshness": dependency.freshness,
            "mapping_record_id": dependency.mapping_record_id,
            "mapping_sha256": dependency.mapping_sha256,
            "owner_approval_state": dependency.owner_approval_state,
            "owner_approval_registry_id": registry.owner_approval_registry_id,
            "owner_approval_registry_revision": (
                registry.owner_approval_registry_revision
            ),
            "owner_approval_source_sha256": registry.owner_approval_source_sha256,
            "registry_id": registry.registry_id,
            "registry_revision": registry.registry_revision,
            "source_sha256": registry.source_sha256,
        }
        for dependency_id in command.gate_dependency_ids
        for dependency in (dependencies[dependency_id],)
        for receipt in (
            receipts.get(dependency.approval_receipt_id or ""),
        )
    ]
