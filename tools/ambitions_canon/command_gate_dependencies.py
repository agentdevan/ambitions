"""Closed offline command-gate dependency registry and binding validation."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.model import (
    CanonError,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
)


REGISTRY_PATH = Path("docs/canon/registries/command-gate-dependencies.json")
REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_id",
        "registry_revision",
        "canon_revision",
        "dependencies",
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
        "owner_approval_evidence",
        "exact_product_mappings",
        "mapping_sha256",
        "freshness",
        "dependency_posture",
        "activation_authorization",
        "dependency_sha256",
    }
)
DEPENDENCY_ID = re.compile(r"^GATE-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
COMMAND_ID = re.compile(r"^CMD-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
STATE_ID = re.compile(r"^UX-STATE-VARIANT-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CANON_ID = re.compile(r"^[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CONCEPT_ID = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")


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
    owner_approval_evidence: str | None
    exact_product_mappings: tuple[str, ...]
    mapping_sha256: str | None
    freshness: str
    dependency_posture: str
    activation_authorization: bool
    dependency_sha256: str


@dataclass(frozen=True, slots=True)
class CommandGateDependencyRegistry:
    schema_version: int
    registry_id: str
    registry_revision: int
    canon_revision: int
    dependencies: tuple[CommandGateDependency, ...]
    source_sha256: str
    source_path: Path


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


def _dependency_hash_payload(dependency: CommandGateDependency) -> dict[str, object]:
    return {
        "activation_authorization": dependency.activation_authorization,
        "command_id": dependency.command_id,
        "dependency_id": dependency.dependency_id,
        "dependency_kind": dependency.dependency_kind,
        "dependency_posture": dependency.dependency_posture,
        "dependency_revision": dependency.dependency_revision,
        "exact_product_mappings": list(dependency.exact_product_mappings),
        "freshness": dependency.freshness,
        "mapping_sha256": dependency.mapping_sha256,
        "owner_approval_evidence": dependency.owner_approval_evidence,
        "owner_approval_state": dependency.owner_approval_state,
        "owner_concept": dependency.owner_concept,
        "requirement_id": dependency.requirement_id,
        "state_id": dependency.state_id,
    }


def command_gate_dependency_sha256(dependency: CommandGateDependency) -> str:
    """Hash stable dependency fields while excluding the self hash."""

    return hashlib.sha256(_stable_json(_dependency_hash_payload(dependency))).hexdigest()


def _required_string(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _error(f"{field} must be a trimmed nonempty string")
    return value


def _optional_sha(value: object, field: str) -> str | None:
    if value is None:
        return None
    result = _required_string(value, field)
    if SHA256.fullmatch(result) is None:
        raise _error(f"{field} must be SHA-256 or null")
    return result


def _parse_dependency(value: object, path: Path) -> CommandGateDependency:
    if not isinstance(value, dict) or set(value) != DEPENDENCY_FIELDS:
        raise _error("dependency fields are closed", path)
    mappings_raw = value["exact_product_mappings"]
    if not isinstance(mappings_raw, list) or any(
        not isinstance(item, str) or not item.strip() or item != item.strip()
        for item in mappings_raw
    ):
        raise _error("exact_product_mappings must be an array of trimmed strings", path)
    mappings = tuple(mappings_raw)
    if mappings != tuple(sorted(set(mappings))):
        raise _error("exact_product_mappings must be sorted and unique", path)
    revision = value["dependency_revision"]
    if isinstance(revision, bool) or not isinstance(revision, int) or revision < 1:
        raise _error("dependency_revision must be a positive integer", path)
    activation = value["activation_authorization"]
    if not isinstance(activation, bool):
        raise _error("activation_authorization must be boolean", path)
    evidence = value["owner_approval_evidence"]
    if evidence is not None:
        evidence = _required_string(evidence, "owner_approval_evidence")
    dependency = CommandGateDependency(
        dependency_id=_required_string(value["dependency_id"], "dependency_id"),
        dependency_revision=revision,
        dependency_kind=_required_string(value["dependency_kind"], "dependency_kind"),
        owner_concept=_required_string(value["owner_concept"], "owner_concept"),
        requirement_id=_required_string(value["requirement_id"], "requirement_id"),
        state_id=_required_string(value["state_id"], "state_id"),
        command_id=_required_string(value["command_id"], "command_id"),
        owner_approval_state=_required_string(
            value["owner_approval_state"], "owner_approval_state"
        ),
        owner_approval_evidence=evidence,
        exact_product_mappings=mappings,
        mapping_sha256=_optional_sha(value["mapping_sha256"], "mapping_sha256"),
        freshness=_required_string(value["freshness"], "freshness"),
        dependency_posture=_required_string(
            value["dependency_posture"], "dependency_posture"
        ),
        activation_authorization=activation,
        dependency_sha256=_required_string(
            value["dependency_sha256"], "dependency_sha256"
        ),
    )
    _validate_dependency(dependency, path)
    return dependency


def _validate_dependency(dependency: CommandGateDependency, path: Path | None) -> None:
    if DEPENDENCY_ID.fullmatch(dependency.dependency_id) is None:
        raise _error(f"invalid dependency ID: {dependency.dependency_id}", path)
    if (
        isinstance(dependency.dependency_revision, bool)
        or not isinstance(dependency.dependency_revision, int)
        or dependency.dependency_revision < 1
    ):
        raise _error("dependency revision must be a positive integer", path)
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
    if dependency.exact_product_mappings != tuple(
        sorted(set(dependency.exact_product_mappings))
    ):
        raise _error("exact product mappings must be sorted and unique", path)
    if dependency.owner_approval_state not in {"approved", "withheld"}:
        raise _error("owner_approval_state is not closed", path)
    if dependency.freshness not in {"absent", "current", "stale"}:
        raise _error("freshness is not closed", path)
    if dependency.dependency_posture not in {"blocked", "ready"}:
        raise _error("dependency_posture is not closed", path)
    if dependency.owner_approval_state == "approved":
        if dependency.owner_approval_evidence is None:
            raise _error("approved dependency lacks owner approval evidence", path)
    elif dependency.owner_approval_evidence is not None:
        raise _error("withheld dependency cannot name approval evidence", path)
    expected_mapping_sha = (
        command_gate_mapping_sha256(dependency.exact_product_mappings)
        if dependency.exact_product_mappings
        else None
    )
    if dependency.mapping_sha256 != expected_mapping_sha:
        raise _error("exact product mapping hash is stale or contradictory", path)
    expected_activation = bool(
        dependency.owner_approval_state == "approved"
        and dependency.owner_approval_evidence
        and dependency.exact_product_mappings
        and dependency.freshness == "current"
        and dependency.dependency_posture == "ready"
    )
    if dependency.activation_authorization is not expected_activation:
        raise _error("activation authorization contradicts dependency posture", path)
    expected_hash = command_gate_dependency_sha256(dependency)
    if dependency.dependency_sha256 != expected_hash:
        raise _error("dependency hash is stale or invalid", path)


def load_command_gate_dependency_registry(
    root: Path,
    *,
    expected_canon_revision: int | None = None,
) -> CommandGateDependencyRegistry:
    """Load the exact tracked machine-control registry without network access."""

    path = root / REGISTRY_PATH
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
    registry_revision = payload["registry_revision"]
    canon_revision = payload["canon_revision"]
    if (
        isinstance(registry_revision, bool)
        or not isinstance(registry_revision, int)
        or registry_revision < 1
    ):
        raise _error("registry_revision must be a positive integer", path)
    if (
        isinstance(canon_revision, bool)
        or not isinstance(canon_revision, int)
        or canon_revision < 0
    ):
        raise _error("canon_revision must be a nonnegative integer", path)
    if expected_canon_revision is not None and canon_revision != expected_canon_revision:
        raise _error("registry canon revision is stale", path)
    raw_dependencies = payload["dependencies"]
    if not isinstance(raw_dependencies, list):
        raise _error("dependencies must be an array", path)
    dependencies = tuple(_parse_dependency(item, path) for item in raw_dependencies)
    identifiers = tuple(item.dependency_id for item in dependencies)
    if identifiers != tuple(sorted(set(identifiers))):
        raise _error("dependencies must be sorted with unique IDs", path)
    return CommandGateDependencyRegistry(
        schema_version=1,
        registry_id=registry_id,
        registry_revision=registry_revision,
        canon_revision=canon_revision,
        dependencies=dependencies,
        source_sha256=hashlib.sha256(source).hexdigest(),
        source_path=path,
    )


def validate_command_gate_dependency_bindings(
    registry: CommandGateDependencyRegistry,
    contracts: tuple[StateCommandContract, ...],
    *,
    canon_revision: int,
) -> None:
    """Require symmetric command binding and current authorization for active commands."""

    if (
        registry.schema_version != 1
        or registry.registry_id != "COMMAND-GATE-DEPENDENCY-REGISTRY-001"
        or isinstance(registry.registry_revision, bool)
        or not isinstance(registry.registry_revision, int)
        or registry.registry_revision < 1
        or SHA256.fullmatch(registry.source_sha256) is None
    ):
        raise _error("registry identity, revision, or source hash is invalid")
    if registry.canon_revision != canon_revision:
        raise _error("registry canon revision is stale", registry.source_path)
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
                _validate_dependency(dependency, registry.source_path)
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


def command_gate_dependency_projection(
    registry: CommandGateDependencyRegistry,
    command: StateCommand,
) -> list[dict[str, object]]:
    """Project only authorization posture, hashes, and approval state into a pack."""

    dependencies = {item.dependency_id: item for item in registry.dependencies}
    return [
        {
            "activation_authorization": dependency.activation_authorization,
            "dependency_id": dependency.dependency_id,
            "dependency_kind": dependency.dependency_kind,
            "dependency_posture": dependency.dependency_posture,
            "dependency_revision": dependency.dependency_revision,
            "dependency_sha256": dependency.dependency_sha256,
            "exact_product_mapping_count": len(dependency.exact_product_mappings),
            "freshness": dependency.freshness,
            "mapping_sha256": dependency.mapping_sha256,
            "owner_approval_evidence": dependency.owner_approval_evidence,
            "owner_approval_state": dependency.owner_approval_state,
            "registry_id": registry.registry_id,
            "registry_revision": registry.registry_revision,
            "source_sha256": registry.source_sha256,
        }
        for dependency_id in command.gate_dependency_ids
        for dependency in (dependencies[dependency_id],)
    ]
