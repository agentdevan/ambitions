"""Closed offline command-gate dependencies and independent approval receipts."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.build import _registry_content_sha
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import (
    CanonError,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
)
from tools.ambitions_canon.registry import build_registry


REGISTRY_PATH = Path("docs/canon/registries/command-gate-dependencies.json")
APPROVAL_RECEIPT_REGISTRY_PATH = Path(
    "docs/canon/registries/command-gate-approval-receipts.json"
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
        "approval_state",
        "approved_scope",
        "approved_scope_sha256",
        "previous_receipt_sha256",
        "receipt_sha256",
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


@dataclass(frozen=True, slots=True)
class CommandGateApprovalScope:
    owner_concept: str
    requirement_id: str
    state_id: str
    command_id: str


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
    source_sha256: str
    source_path: Path
    repository_root: Path

    def __post_init__(self) -> None:
        object.__setattr__(self, "dependencies", tuple(self.dependencies))
        object.__setattr__(self, "approval_receipts", tuple(self.approval_receipts))


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


def command_gate_mapping_sha256(mappings: tuple[str, ...]) -> str:
    """Hash the exact sorted product mapping list."""

    return hashlib.sha256(_stable_json(list(mappings))).hexdigest()


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
    if receipt.approval_state != "approved":
        raise _error("approval receipt state must be approved", path)
    if receipt.approved_scope_sha256 != command_gate_approval_scope_sha256(
        receipt.approved_scope
    ):
        raise _error("approval scope hash is stale", path)
    if receipt.receipt_sha256 != command_gate_approval_receipt_sha256(receipt):
        raise _error("approval receipt hash is stale or invalid", path)


def _current_canon_content_sha256(root: Path) -> str:
    manifest = load_manifest(root)
    registry = build_registry(manifest, load_documents(root, manifest))
    from tools.ambitions_canon.conflicts import (
        load_conflict_dockets,
        validate_conflict_repository,
    )

    dockets = load_conflict_dockets(root)
    conflict_snapshot = validate_conflict_repository(
        root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    return _registry_content_sha(registry, dockets, conflict_snapshot)


def _load_approval_receipt_registry(
    root: Path,
    *,
    expected_canon_revision: int,
    expected_canon_content_sha256: str,
) -> tuple[str, int, tuple[CommandGateApprovalReceipt, ...], str]:
    path = root / APPROVAL_RECEIPT_REGISTRY_PATH
    try:
        source = path.read_bytes()
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
    for receipt in receipts:
        if receipt.canon_content_sha256 != expected_canon_content_sha256:
            raise _error("approval receipt canon content is stale", path)
    return registry_id, revision, receipts, hashlib.sha256(source).hexdigest()


def load_command_gate_dependency_registry(
    root: Path,
    *,
    expected_canon_revision: int | None = None,
) -> CommandGateDependencyRegistry:
    """Load dependencies and independently tracked receipts without network access."""

    repository_root = root.resolve()
    path = repository_root / REGISTRY_PATH
    try:
        source = path.read_bytes()
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
    current_canon_sha = _current_canon_content_sha256(repository_root)
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
        if receipt.canon_content_sha256 != registry.canon_content_sha256:
            raise _error("approval receipt canon content is stale", registry.source_path)
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
        expected_scope = CommandGateApprovalScope(
            owner_concept=dependency.owner_concept,
            requirement_id=dependency.requirement_id,
            state_id=dependency.state_id,
            command_id=dependency.command_id,
        )
        if (
            receipt is not receipts_by_dependency[dependency.dependency_id][-1]
            or
            receipt.dependency_id != dependency.dependency_id
            or receipt.dependency_revision != dependency.dependency_revision
            or receipt.receipt_revision != dependency.dependency_revision
            or receipt.mapping_record_id != dependency.mapping_record_id
            or receipt.exact_product_mappings != dependency.exact_product_mappings
            or receipt.mapping_sha256 != dependency.mapping_sha256
            or receipt.dependency_sha256 != dependency.dependency_sha256
            or receipt.canon_content_sha256 != dependency.canon_content_sha256
            or receipt.approved_scope != expected_scope
            or receipt.approval_state != "approved"
        ):
            raise _error(
                f"approval receipt does not bind exact dependency content: "
                f"{dependency.dependency_id}",
                registry.source_path,
            )


def validate_command_gate_dependency_bindings(
    registry: CommandGateDependencyRegistry,
    contracts: tuple[StateCommandContract, ...],
    *,
    canon_revision: int,
) -> None:
    """Require symmetric command, current canon, and exact receipt binding."""

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
        or SHA256.fullmatch(registry.source_sha256) is None
        or SHA256.fullmatch(registry.approval_receipt_source_sha256) is None
    ):
        raise _error("registry identity, revision, or source hash is invalid")
    if registry.canon_revision != canon_revision:
        raise _error("registry canon revision is stale", registry.source_path)
    current_canon_sha = _current_canon_content_sha256(registry.repository_root)
    if registry.canon_content_sha256 != current_canon_sha:
        raise _error("registry canon content is stale", registry.source_path)
    _validate_registry_approval_bindings(registry)

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
                if (
                    command.activation_posture is StateCommandActivationPosture.ACTIVE
                    and not dependency.activation_authorization
                ):
                    raise _error(
                        f"active command dependency is not authorized: {dependency_id}",
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
