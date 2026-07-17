"""Independent closed resolution records for state-command machine identities."""

from __future__ import annotations

import copy
import hashlib
import json
import os
import re
from dataclasses import dataclass, field, replace
from pathlib import Path
from types import MappingProxyType
from typing import Mapping

from tools.ambitions_canon.model import (
    CanonError,
    CanonRegistry,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
    StateCommandResolutionPosture,
    StateCommandRollbackPosture,
)


REGISTRY_PATH = Path("docs/canon/registries/command-resolution-registry.json")
REGISTRY_FIELDS = frozenset(
    {
        "schema_version",
        "registry_id",
        "registry_revision",
        "canon_revision",
        "records",
        "state_command_records",
    }
)
RECORD_FIELDS = frozenset(
    {
        "resolution_id",
        "resolution_kind",
        "mechanism_kind",
        "posture",
        "owner_concept",
        "requirement_id",
        "state_id",
        "command_id",
        "behavior_binding",
        "record_sha256",
        "state_command_record_sha256",
    }
)
STATE_COMMAND_RECORD_FIELDS = frozenset(
    {
        "source_path",
        "requirement_id",
        "state_id",
        "trigger_command_id",
        "mechanism_kind",
        "redo_command_id",
        "redo_preconditions",
        "command_id",
        "command_sha256",
        "record_sha256",
    }
)
BEHAVIOR_BINDING_FIELDS = frozenset(
    {
        "source_path",
        "source_field",
        "source_text_sha256",
        "behavior_sha256",
    }
)
RESOLUTION_KINDS = frozenset(
    {
        "destination",
        "success_focus",
        "failure_focus",
        "recovery",
        "recovery_command",
        "checkpoint",
        "confirmation",
        "receipt",
    }
)
MECHANISM_KINDS = frozenset(
    {
        "inverse_command",
        "checkpoint_restore",
        "recovery_handoff_command",
        "irreversible_confirmation",
        "irreversible_receipt",
    }
)
SOURCE_FIELDS = frozenset(
    {"destination", "success_focus", "failure_focus", "rollback_undo"}
)
RESOLUTION_ID = re.compile(
    r"^(?:DEST|FOCUS|RECOVERY|CMD|CHECKPOINT|CONFIRMATION|RECEIPT)-"
    r"[A-Z0-9]+(?:-[A-Z0-9]+)*$"
)
COMMAND_ID = re.compile(r"^CMD-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
STATE_ID = re.compile(r"^UX-STATE-VARIANT-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CANON_ID = re.compile(r"^[A-Z0-9]+(?:-[A-Z0-9]+)*$")
CONCEPT_ID = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
RESOLUTION_POSTURES = frozenset(
    item.value for item in StateCommandResolutionPosture
)


@dataclass(frozen=True, slots=True)
class CommandResolutionBehaviorBinding:
    source_path: str
    source_field: str
    source_text_sha256: str
    behavior_sha256: str


@dataclass(frozen=True, slots=True)
class CommandResolutionRecord:
    resolution_id: str
    resolution_kind: str
    mechanism_kind: str | None
    posture: str
    owner_concept: str
    requirement_id: str
    state_id: str
    command_id: str
    behavior_binding: CommandResolutionBehaviorBinding
    state_command_record_sha256: str | None
    record_sha256: str


@dataclass(frozen=True, slots=True)
class StateCommandResolutionRecord:
    source_path: str
    requirement_id: str
    state_id: str
    trigger_command_id: str
    mechanism_kind: str
    command: StateCommand
    command_sha256: str
    record_sha256: str
    redo_command_id: str | None = None
    redo_preconditions: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "redo_preconditions",
            tuple(self.redo_preconditions),
        )


@dataclass(frozen=True, slots=True)
class CommandResolutionRegistry:
    schema_version: int
    registry_id: str
    registry_revision: int
    canon_revision: int
    records: tuple[CommandResolutionRecord, ...]
    state_command_records: tuple[StateCommandResolutionRecord, ...]
    source_sha256: str
    source_path: Path
    repository_root: Path
    records_by_id: Mapping[str, CommandResolutionRecord] = field(
        init=False,
        repr=False,
        compare=False,
    )
    state_command_records_by_id: Mapping[str, StateCommand] = field(
        init=False,
        repr=False,
        compare=False,
    )
    validated_contract_sets: set[
        tuple[tuple[Path, StateCommandContract], ...]
    ] = field(default_factory=set, init=False, repr=False, compare=False)
    resolution_cache: dict[
        tuple[Path, StateCommandContract, StateCommand],
        dict[str, object],
    ] = field(default_factory=dict, init=False, repr=False, compare=False)

    def __post_init__(self) -> None:
        object.__setattr__(self, "records", tuple(self.records))
        object.__setattr__(
            self,
            "state_command_records",
            tuple(self.state_command_records),
        )
        object.__setattr__(
            self,
            "records_by_id",
            MappingProxyType(
                {item.resolution_id: item for item in self.records}
            ),
        )
        object.__setattr__(
            self,
            "state_command_records_by_id",
            MappingProxyType(
                {
                    item.command.command_id: item.command
                    for item in self.state_command_records
                }
            ),
        )


_LOADED_REGISTRY_CACHE: dict[
    tuple[Path, str], CommandResolutionRegistry
] = {}


def _error(message: str, path: Path | None = None) -> CanonError:
    return CanonError("CANON_COMMAND_RESOLUTION_INVALID", message, path)


def _stable_json(value: object, *, pretty: bool = False) -> bytes:
    if pretty:
        rendered = json.dumps(
            value,
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
        )
    else:
        rendered = json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
    return (rendered + "\n").encode("utf-8")


def _required_string(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _error(f"{field} must be a trimmed nonempty string")
    return value


def _required_sha(value: object, field: str) -> str:
    result = _required_string(value, field)
    if SHA256.fullmatch(result) is None:
        raise _error(f"{field} must be SHA-256")
    return result


def _positive_integer(value: object, field: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 1:
        raise _error(f"{field} must be a positive integer")
    return value


def _source_text_sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _state_command_payload(command: StateCommand) -> dict[str, object]:
    return {
        "activation_posture": command.activation_posture.value,
        "canonical_owner": command.canonical_owner,
        "checkpoint_id": command.checkpoint_id,
        "command_id": command.command_id,
        "commit_boundary": command.commit_boundary,
        "destination": command.destination,
        "destination_id": command.destination_id,
        "destination_posture": command.destination_posture.value,
        "effect": command.effect,
        "failure_focus": command.failure_focus,
        "failure_focus_id": command.failure_focus_id,
        "failure_focus_posture": command.failure_focus_posture.value,
        "gate_dependency_ids": list(command.gate_dependency_ids),
        "gate_requirement_ids": list(command.gate_requirement_ids),
        "inverse_command_id": command.inverse_command_id,
        "irreversible_confirmation_id": command.irreversible_confirmation_id,
        "irreversible_receipt_id": command.irreversible_receipt_id,
        "label": command.label,
        "preconditions": list(command.preconditions),
        "privacy_egress": command.privacy_egress,
        "recovery_handoff_command_id": command.recovery_handoff_command_id,
        "recovery_id": command.recovery_id,
        "recovery_owner": command.recovery_owner,
        "recovery_posture": command.recovery_posture.value,
        "rollback_posture": (
            command.rollback_posture.value
            if command.rollback_posture is not None
            else None
        ),
        "rollback_undo": command.rollback_undo,
        "success_focus": command.success_focus,
        "success_focus_id": command.success_focus_id,
        "success_focus_posture": command.success_focus_posture.value,
        "verification_ids": list(command.verification_ids),
    }


def state_command_behavior_sha256(command: StateCommand) -> str:
    """Hash every behavior-bearing field on an actual state-command record."""

    return hashlib.sha256(_stable_json(_state_command_payload(command))).hexdigest()


def _state_command_record_hash_payload(
    record: StateCommandResolutionRecord,
) -> dict[str, object]:
    return {
        "command": _state_command_payload(record.command),
        "command_id": record.command.command_id,
        "command_sha256": record.command_sha256,
        "mechanism_kind": record.mechanism_kind,
        "record_sha256": None,
        "redo_command_id": record.redo_command_id,
        "redo_preconditions": list(record.redo_preconditions),
        "requirement_id": record.requirement_id,
        "source_path": record.source_path,
        "state_id": record.state_id,
        "trigger_command_id": record.trigger_command_id,
    }


def state_command_resolution_record_sha256(
    record: StateCommandResolutionRecord,
) -> str:
    """Hash the complete actual recovery command while excluding its self hash."""

    payload = _state_command_record_hash_payload(record)
    payload.pop("record_sha256")
    return hashlib.sha256(_stable_json(payload)).hexdigest()


def _state_command_record_payload(
    record: StateCommandResolutionRecord,
) -> dict[str, object]:
    """Render the independent binding; command bytes remain normative in source."""

    return {
        "command_id": record.command.command_id,
        "command_sha256": record.command_sha256,
        "mechanism_kind": record.mechanism_kind,
        "record_sha256": record.record_sha256,
        "redo_command_id": record.redo_command_id,
        "redo_preconditions": list(record.redo_preconditions),
        "requirement_id": record.requirement_id,
        "source_path": record.source_path,
        "state_id": record.state_id,
        "trigger_command_id": record.trigger_command_id,
    }


def _behavior_hash_payload(
    source_path: Path,
    contract: StateCommandContract,
    command: StateCommand,
) -> dict[str, object]:
    """Return the complete structured behavior, excluding allocated resolution IDs."""

    return {
        "accessibility_focus": contract.accessibility_focus,
        "activation_posture": command.activation_posture.value,
        "canonical_owner": command.canonical_owner,
        "command_id": command.command_id,
        "commit_boundary": command.commit_boundary,
        "contract_activation_posture": contract.activation_posture.value,
        "contract_gate_requirement_ids": list(contract.gate_requirement_ids),
        "destination": command.destination,
        "destination_posture": command.destination_posture.value,
        "durable_effect": contract.durable_effect,
        "effect": command.effect,
        "failure_focus": command.failure_focus,
        "failure_focus_posture": command.failure_focus_posture.value,
        "gate_dependency_ids": list(command.gate_dependency_ids),
        "gate_requirement_ids": list(command.gate_requirement_ids),
        "label": command.label,
        "mechanism_declarations": {
            "checkpoint_id": command.checkpoint_id,
            "inverse_command_id": command.inverse_command_id,
            "irreversible_confirmation_id": command.irreversible_confirmation_id,
            "irreversible_receipt_id": command.irreversible_receipt_id,
            "recovery_handoff_command_id": command.recovery_handoff_command_id,
            "rollback_posture": (
                command.rollback_posture.value
                if command.rollback_posture is not None
                else None
            ),
        },
        "offline_behavior": contract.offline_behavior,
        "preconditions": list(command.preconditions),
        "privacy_egress": command.privacy_egress,
        "recovery_owner": command.recovery_owner,
        "recovery_posture": command.recovery_posture.value,
        "recovery_rollback": contract.recovery_rollback,
        "requirement_id": contract.requirement_id,
        "rollback_undo": command.rollback_undo,
        "source_path": source_path.as_posix(),
        "state_id": contract.state_id,
        "success_focus": command.success_focus,
        "success_focus_posture": command.success_focus_posture.value,
        "transition_exit": contract.transition_exit,
        "verification_ids": list(command.verification_ids),
    }


def command_resolution_behavior_sha256(
    source_path: Path,
    contract: StateCommandContract,
    command: StateCommand,
) -> str:
    """Hash the exact structured behavior and source binding."""

    return hashlib.sha256(
        _stable_json(_behavior_hash_payload(source_path, contract, command))
    ).hexdigest()


def _record_hash_payload(record: CommandResolutionRecord) -> dict[str, object]:
    return {
        "behavior_binding": {
            "behavior_sha256": record.behavior_binding.behavior_sha256,
            "source_field": record.behavior_binding.source_field,
            "source_path": record.behavior_binding.source_path,
            "source_text_sha256": record.behavior_binding.source_text_sha256,
        },
        "command_id": record.command_id,
        "mechanism_kind": record.mechanism_kind,
        "owner_concept": record.owner_concept,
        "posture": record.posture,
        "record_sha256": None,
        "requirement_id": record.requirement_id,
        "resolution_id": record.resolution_id,
        "resolution_kind": record.resolution_kind,
        "state_command_record_sha256": record.state_command_record_sha256,
        "state_id": record.state_id,
    }


def command_resolution_record_sha256(record: CommandResolutionRecord) -> str:
    """Hash a resolution record while excluding its self hash value."""

    payload = _record_hash_payload(record)
    payload.pop("record_sha256")
    return hashlib.sha256(_stable_json(payload)).hexdigest()


def _record_payload(record: CommandResolutionRecord) -> dict[str, object]:
    payload = _record_hash_payload(record)
    payload["record_sha256"] = record.record_sha256
    return payload


def command_resolution_record_projection(
    record: CommandResolutionRecord,
) -> dict[str, object]:
    """Project the complete independently resolvable record."""

    return _record_payload(record)


def compact_resolved_machine_contract(
    machine: Mapping[str, object],
) -> dict[str, object]:
    """Project bounded references plus complete applicable recovery behavior."""

    def reference(value: object) -> dict[str, object]:
        if not isinstance(value, Mapping):
            raise _error("resolved command record projection is invalid")
        result = {
            "record_sha256": value["record_sha256"],
            "resolution_id": value["resolution_id"],
        }
        state_command_record_sha256 = value.get(
            "state_command_record_sha256"
        )
        if state_command_record_sha256 is not None:
            result["state_command_record_sha256"] = (
                state_command_record_sha256
            )
        return result

    result = dict(machine)
    for field_name in ("destination", "success_focus", "failure_focus"):
        target_value = result[field_name]
        if not isinstance(target_value, Mapping):
            raise _error("resolved command target projection is invalid")
        target = dict(target_value)
        target["resolution_record"] = reference(target["resolution_record"])
        result[field_name] = target
    recovery_value = result["recovery"]
    if not isinstance(recovery_value, Mapping):
        raise _error("resolved command recovery projection is invalid")
    recovery = dict(recovery_value)
    recovery["resolution_record"] = reference(recovery["resolution_record"])
    mechanism_values = recovery["mechanism_records"]
    if not isinstance(mechanism_values, list):
        raise _error("resolved recovery mechanism projection is invalid")
    recovery["mechanism_records"] = [
        reference(item) for item in mechanism_values
    ]
    result["recovery"] = recovery
    return result


def _recovery_command_behavior_projection(
    record: StateCommandResolutionRecord,
) -> dict[str, object]:
    """Expose the complete behavior needed to execute or reject recovery."""

    command = record.command
    redo = (
        {
            "authorization_posture": "fresh_task_authorization_required",
            "command_id": record.redo_command_id,
            "receipt_posture": "current_inverse_receipt_required",
            "revision_posture": "current_revision_required",
        }
        if record.redo_command_id is not None
        else None
    )
    return {
        "behavior": {
            "activation_posture": command.activation_posture.value,
            "canonical_owner": command.canonical_owner,
            "command_id": command.command_id,
            "commit_boundary": command.commit_boundary,
            "effect": command.effect,
            "failure_focus": command.failure_focus,
            "gate_dependency_ids": list(command.gate_dependency_ids),
            "gate_requirement_ids": list(command.gate_requirement_ids),
            "label": command.label,
            "preconditions": list(command.preconditions),
            "presentation": {
                "destination": command.destination,
                "destination_id": command.destination_id,
                "destination_posture": command.destination_posture.value,
                "failure_focus_id": command.failure_focus_id,
                "failure_focus_posture": command.failure_focus_posture.value,
                "success_focus": command.success_focus,
                "success_focus_id": command.success_focus_id,
                "success_focus_posture": command.success_focus_posture.value,
            },
            "privacy_egress": command.privacy_egress,
            "recovery_id": command.recovery_id,
            "recovery_owner": command.recovery_owner,
            "recovery_posture": command.recovery_posture.value,
            "rollback_undo": command.rollback_undo,
            "verification_ids": list(command.verification_ids),
        },
        "mechanism_kind": record.mechanism_kind,
        "redo": redo,
        "state_command_record_sha256": record.record_sha256,
        "trigger_command_id": record.trigger_command_id,
    }


def _expected_record(
    *,
    resolution_id: str,
    resolution_kind: str,
    mechanism_kind: str | None,
    posture: str,
    owner_concept: str,
    requirement_id: str,
    state_id: str,
    command_id: str,
    state_command_record_sha256: str | None,
    source_path: Path,
    source_field: str,
    source_text: str,
    behavior_sha256: str,
) -> CommandResolutionRecord:
    binding = CommandResolutionBehaviorBinding(
        source_path=source_path.as_posix(),
        source_field=source_field,
        source_text_sha256=_source_text_sha256(source_text),
        behavior_sha256=behavior_sha256,
    )
    record = CommandResolutionRecord(
        resolution_id=resolution_id,
        resolution_kind=resolution_kind,
        mechanism_kind=mechanism_kind,
        posture=posture,
        owner_concept=owner_concept,
        requirement_id=requirement_id,
        state_id=state_id,
        command_id=command_id,
        behavior_binding=binding,
        state_command_record_sha256=state_command_record_sha256,
        record_sha256="",
    )
    return CommandResolutionRecord(
        resolution_id=record.resolution_id,
        resolution_kind=record.resolution_kind,
        mechanism_kind=record.mechanism_kind,
        posture=record.posture,
        owner_concept=record.owner_concept,
        requirement_id=record.requirement_id,
        state_id=record.state_id,
        command_id=record.command_id,
        behavior_binding=record.behavior_binding,
        state_command_record_sha256=record.state_command_record_sha256,
        record_sha256=command_resolution_record_sha256(record),
    )


def _command_record_specs(
    source_path: Path,
    contract: StateCommandContract,
    command: StateCommand,
    *,
    state_command_record_sha256: str | None = None,
    recovery_command_record_hashes: Mapping[str, str] | None = None,
) -> tuple[CommandResolutionRecord, ...]:
    behavior_sha256 = command_resolution_behavior_sha256(
        source_path,
        contract,
        command,
    )
    common = {
        "owner_concept": command.canonical_owner,
        "requirement_id": contract.requirement_id,
        "state_id": contract.state_id,
        "command_id": command.command_id,
        "source_path": source_path,
        "behavior_sha256": behavior_sha256,
        "state_command_record_sha256": state_command_record_sha256,
    }
    specs = [
        _expected_record(
            resolution_id=command.destination_id,
            resolution_kind="destination",
            mechanism_kind=None,
            posture=command.destination_posture.value,
            source_field="destination",
            source_text=command.destination,
            **common,
        ),
        _expected_record(
            resolution_id=command.success_focus_id,
            resolution_kind="success_focus",
            mechanism_kind=None,
            posture=command.success_focus_posture.value,
            source_field="success_focus",
            source_text=command.success_focus,
            **common,
        ),
        _expected_record(
            resolution_id=command.failure_focus_id,
            resolution_kind="failure_focus",
            mechanism_kind=None,
            posture=command.failure_focus_posture.value,
            source_field="failure_focus",
            source_text=command.failure_focus,
            **common,
        ),
        _expected_record(
            resolution_id=command.recovery_id,
            resolution_kind="recovery",
            mechanism_kind=None,
            posture=command.recovery_posture.value,
            source_field="rollback_undo",
            source_text=command.rollback_undo,
            **common,
        ),
    ]
    mechanisms = (
        (
            command.inverse_command_id,
            "recovery_command",
            "inverse_command",
        ),
        (command.checkpoint_id, "checkpoint", "checkpoint_restore"),
        (
            command.recovery_handoff_command_id,
            "recovery_command",
            "recovery_handoff_command",
        ),
        (
            command.irreversible_confirmation_id,
            "confirmation",
            "irreversible_confirmation",
        ),
        (
            command.irreversible_receipt_id,
            "receipt",
            "irreversible_receipt",
        ),
    )
    specs.extend(
        _expected_record(
            resolution_id=identifier,
            resolution_kind=kind,
            mechanism_kind=mechanism,
            posture=command.recovery_posture.value,
            source_field="rollback_undo",
            source_text=command.rollback_undo,
            **{
                **common,
                "state_command_record_sha256": (
                    recovery_command_record_hashes.get(identifier)
                    if recovery_command_record_hashes is not None
                    and kind == "recovery_command"
                    else state_command_record_sha256
                ),
            },
        )
        for identifier, kind, mechanism in mechanisms
        if identifier is not None
    )
    return tuple(specs)


def _expected_state_command_record(
    source_path: Path,
    contract: StateCommandContract,
    trigger_command_id: str,
    mechanism_kind: str,
    command: StateCommand,
    redo_command_id: str | None,
    redo_preconditions: tuple[str, ...],
) -> StateCommandResolutionRecord:
    command_sha256 = state_command_behavior_sha256(command)
    record = StateCommandResolutionRecord(
        source_path=source_path.as_posix(),
        requirement_id=contract.requirement_id,
        state_id=contract.state_id,
        trigger_command_id=trigger_command_id,
        mechanism_kind=mechanism_kind,
        command=command,
        command_sha256=command_sha256,
        record_sha256="",
        redo_command_id=redo_command_id,
        redo_preconditions=redo_preconditions,
    )
    return replace(
        record,
        record_sha256=state_command_resolution_record_sha256(record),
    )


def expected_state_command_resolution_records(
    canon: CanonRegistry,
) -> tuple[StateCommandResolutionRecord, ...]:
    """Build the closed actual-command bindings for inverse and handoff IDs."""

    records = tuple(
        _expected_state_command_record(
            document.source_path,
            contract,
            recovery.trigger_command_id,
            recovery.mechanism_kind,
            recovery.command,
            recovery.redo_command_id,
            recovery.redo_preconditions,
        )
        for document in canon.documents
        for contract in document.state_command_contracts
        for recovery in contract.recovery_commands
    )
    return tuple(sorted(records, key=lambda item: item.command.command_id))


def expected_command_resolution_records(
    canon: CanonRegistry,
) -> tuple[CommandResolutionRecord, ...]:
    """Build exact bindings for references already declared by normative canon."""

    state_records = expected_state_command_resolution_records(canon)
    state_hashes = {
        item.command.command_id: item.record_sha256 for item in state_records
    }
    primary_records = tuple(
        record
        for document in canon.documents
        for contract in document.state_command_contracts
        for command in contract.commands
        for record in _command_record_specs(
            document.source_path,
            contract,
            command,
            recovery_command_record_hashes=state_hashes,
        )
    )
    recovery_records = tuple(
        record
        for document in canon.documents
        for contract in document.state_command_contracts
        for recovery in contract.recovery_commands
        for record in _command_record_specs(
            document.source_path,
            contract,
            recovery.command,
            state_command_record_sha256=state_hashes[
                recovery.command.command_id
            ],
        )
    )
    records = (*primary_records, *recovery_records)
    return tuple(sorted(records, key=lambda item: item.resolution_id))


def render_command_resolution_registry(
    canon: CanonRegistry,
    *,
    registry_revision: int = 2,
) -> bytes:
    """Render an explicit bootstrap/update candidate for human-governed review."""

    payload = {
        "canon_revision": canon.manifest.canon_revision,
        "records": [
            _record_payload(record)
            for record in expected_command_resolution_records(canon)
        ],
        "state_command_records": [
            _state_command_record_payload(record)
            for record in expected_state_command_resolution_records(canon)
        ],
        "registry_id": "COMMAND-RESOLUTION-REGISTRY-001",
        "registry_revision": registry_revision,
        "schema_version": 2,
    }
    return _stable_json(payload, pretty=True)


def _parse_binding(value: object, path: Path) -> CommandResolutionBehaviorBinding:
    if not isinstance(value, dict) or set(value) != BEHAVIOR_BINDING_FIELDS:
        raise _error("behavior binding fields are closed", path)
    binding = CommandResolutionBehaviorBinding(
        source_path=_required_string(value["source_path"], "source_path"),
        source_field=_required_string(value["source_field"], "source_field"),
        source_text_sha256=_required_sha(
            value["source_text_sha256"], "source_text_sha256"
        ),
        behavior_sha256=_required_sha(
            value["behavior_sha256"], "behavior_sha256"
        ),
    )
    if binding.source_field not in SOURCE_FIELDS:
        raise _error("behavior source field is not closed", path)
    if not binding.source_path.startswith("docs/canon/specifications/"):
        raise _error("behavior source path is outside specifications", path)
    return binding


def _parse_record(value: object, path: Path) -> CommandResolutionRecord:
    if not isinstance(value, dict) or set(value) != RECORD_FIELDS:
        raise _error("resolution record fields are closed", path)
    mechanism = value["mechanism_kind"]
    if mechanism is not None:
        mechanism = _required_string(mechanism, "mechanism_kind")
    state_command_record_sha256 = value["state_command_record_sha256"]
    if state_command_record_sha256 is not None:
        state_command_record_sha256 = _required_sha(
            state_command_record_sha256,
            "state_command_record_sha256",
        )
    record = CommandResolutionRecord(
        resolution_id=_required_string(value["resolution_id"], "resolution_id"),
        resolution_kind=_required_string(
            value["resolution_kind"], "resolution_kind"
        ),
        mechanism_kind=mechanism,
        posture=_required_string(value["posture"], "posture"),
        owner_concept=_required_string(value["owner_concept"], "owner_concept"),
        requirement_id=_required_string(value["requirement_id"], "requirement_id"),
        state_id=_required_string(value["state_id"], "state_id"),
        command_id=_required_string(value["command_id"], "command_id"),
        behavior_binding=_parse_binding(value["behavior_binding"], path),
        state_command_record_sha256=state_command_record_sha256,
        record_sha256=_required_sha(value["record_sha256"], "record_sha256"),
    )
    _validate_record(record, path)
    return record


def _validate_record(record: CommandResolutionRecord, path: Path | None) -> None:
    if RESOLUTION_ID.fullmatch(record.resolution_id) is None:
        raise _error("resolution ID is invalid", path)
    if record.resolution_kind not in RESOLUTION_KINDS:
        raise _error("resolution kind is not closed", path)
    if (
        record.mechanism_kind is not None
        and record.mechanism_kind not in MECHANISM_KINDS
    ):
        raise _error("mechanism kind is not closed", path)
    if record.posture not in RESOLUTION_POSTURES:
        raise _error("resolution posture is not closed", path)
    if CONCEPT_ID.fullmatch(record.owner_concept) is None:
        raise _error("resolution owner concept is invalid", path)
    if CANON_ID.fullmatch(record.requirement_id) is None:
        raise _error("resolution requirement identity is invalid", path)
    if STATE_ID.fullmatch(record.state_id) is None:
        raise _error("resolution state identity is invalid", path)
    if COMMAND_ID.fullmatch(record.command_id) is None:
        raise _error("resolution command owner is invalid", path)
    if record.record_sha256 != command_resolution_record_sha256(record):
        raise _error("resolution record hash is stale", path)


def _validate_state_command_record(
    record: StateCommandResolutionRecord,
    path: Path | None,
) -> None:
    if not record.source_path.startswith("docs/canon/specifications/"):
        raise _error("state command source path is outside specifications", path)
    if CANON_ID.fullmatch(record.requirement_id) is None:
        raise _error("state command requirement identity is invalid", path)
    if STATE_ID.fullmatch(record.state_id) is None:
        raise _error("state command state identity is invalid", path)
    if COMMAND_ID.fullmatch(record.trigger_command_id) is None:
        raise _error("state command trigger identity is invalid", path)
    if record.mechanism_kind not in {
        "inverse_command",
        "recovery_handoff_command",
    }:
        raise _error("state command mechanism kind is not closed", path)
    if record.command.command_id == record.trigger_command_id:
        raise _error("state command collides with its trigger", path)
    if record.mechanism_kind == "inverse_command":
        if record.redo_command_id != record.trigger_command_id:
            raise _error("redo command must bind original trigger", path)
        if record.redo_preconditions != (
            "current inverse Receipt",
            "current revision",
            "fresh task authorization",
        ):
            raise _error("redo preconditions are not machine closed", path)
    elif record.redo_command_id is not None or record.redo_preconditions:
        raise _error("non-inverse state command cannot declare redo", path)
    actual_command_sha256 = state_command_behavior_sha256(record.command)
    if record.command_sha256 != actual_command_sha256:
        raise _error("state command behavior binding is stale", path)
    if record.record_sha256 != state_command_resolution_record_sha256(record):
        raise _error("state command record hash is stale", path)


def _parse_state_command_record(
    value: object,
    path: Path,
    repository_root: Path,
    captured_sources: Mapping[Path, bytes] | None = None,
) -> StateCommandResolutionRecord:
    if not isinstance(value, dict) or set(value) != STATE_COMMAND_RECORD_FIELDS:
        raise _error("state command record fields are closed", path)
    source_path = _required_string(value["source_path"], "source_path")
    source_relative = Path(source_path)
    if (
        source_relative.is_absolute()
        or not source_path.startswith("docs/canon/specifications/")
        or ".." in source_relative.parts
    ):
        raise _error("state command source path is outside specifications", path)
    try:
        if captured_sources is not None and source_relative in captured_sources:
            source_bytes = captured_sources[source_relative]
        else:
            from tools.ambitions_canon.build import _read_confined_bytes

            source_bytes = _read_confined_bytes(repository_root, source_relative)
        source = source_bytes.decode("utf-8")
    except (OSError, UnicodeError, CanonError) as error:
        raise _error(f"cannot load state command source: {error}", path) from error
    from tools.ambitions_canon.parser import parse_canon_document

    document = parse_canon_document(source_relative, source)
    requirement_id = _required_string(
        value["requirement_id"],
        "requirement_id",
    )
    state_id = _required_string(value["state_id"], "state_id")
    trigger_command_id = _required_string(
        value["trigger_command_id"],
        "trigger_command_id",
    )
    mechanism_kind = _required_string(
        value["mechanism_kind"],
        "mechanism_kind",
    )
    raw_redo_command_id = value["redo_command_id"]
    redo_command_id = (
        None
        if raw_redo_command_id is None
        else _required_string(raw_redo_command_id, "redo_command_id")
    )
    raw_redo_preconditions = value["redo_preconditions"]
    if not isinstance(raw_redo_preconditions, list) or any(
        not isinstance(item, str) or not item.strip() or item != item.strip()
        for item in raw_redo_preconditions
    ):
        raise _error("redo_preconditions must be an array of trimmed strings", path)
    redo_preconditions = tuple(raw_redo_preconditions)
    if redo_preconditions != tuple(sorted(set(redo_preconditions))):
        raise _error("redo_preconditions must be sorted and unique", path)
    command_id = _required_string(value["command_id"], "command_id")
    matches = [
        recovery
        for contract in document.state_command_contracts
        if contract.state_id == state_id
        and contract.requirement_id == requirement_id
        for recovery in contract.recovery_commands
        if recovery.trigger_command_id == trigger_command_id
        and recovery.mechanism_kind == mechanism_kind
        and recovery.command.command_id == command_id
    ]
    if len(matches) != 1:
        raise _error(
            f"state command source binding is unresolved: {command_id}",
            path,
        )
    source_recovery = matches[0]
    if (
        redo_command_id != source_recovery.redo_command_id
        or redo_preconditions != source_recovery.redo_preconditions
    ):
        raise _error(
            f"state command redo source binding is unresolved: {command_id}",
            path,
        )
    record = StateCommandResolutionRecord(
        source_path=source_path,
        requirement_id=requirement_id,
        state_id=state_id,
        trigger_command_id=trigger_command_id,
        mechanism_kind=mechanism_kind,
        command=source_recovery.command,
        command_sha256=_required_sha(
            value["command_sha256"],
            "command_sha256",
        ),
        record_sha256=_required_sha(
            value["record_sha256"],
            "record_sha256",
        ),
        redo_command_id=redo_command_id,
        redo_preconditions=redo_preconditions,
    )
    _validate_state_command_record(record, path)
    return record


def load_command_resolution_registry(root: Path) -> CommandResolutionRegistry:
    """Load the separately authored resolution record registry."""

    from tools.ambitions_canon.build import _read_confined_bytes

    try:
        source = _read_confined_bytes(root, REGISTRY_PATH)
    except (OSError, CanonError) as error:
        raise _error(
            f"cannot load command-resolution registry: {error}",
            root / REGISTRY_PATH,
        ) from error
    return _load_command_resolution_registry_bytes(root, source)


def _load_command_resolution_registry_bytes(
    root: Path,
    source: bytes,
    *,
    captured_sources: Mapping[Path, bytes] | None = None,
) -> CommandResolutionRegistry:
    """Parse one descriptor-captured immutable registry byte snapshot."""

    repository_root = Path(os.path.abspath(root))
    path = repository_root / REGISTRY_PATH
    source_sha256 = hashlib.sha256(source).hexdigest()
    cached = _LOADED_REGISTRY_CACHE.get((repository_root, source_sha256))
    if cached is not None:
        return cached
    try:
        payload = json.loads(source)
    except json.JSONDecodeError as error:
        raise _error(f"cannot load command-resolution registry: {error}", path) from error
    if not isinstance(payload, dict) or set(payload) != REGISTRY_FIELDS:
        raise _error("command-resolution registry fields are closed", path)
    if payload["schema_version"] != 2 or isinstance(payload["schema_version"], bool):
        raise _error("command-resolution schema version must be integer 2", path)
    registry_id = _required_string(payload["registry_id"], "registry_id")
    if registry_id != "COMMAND-RESOLUTION-REGISTRY-001":
        raise _error("command-resolution registry identity is invalid", path)
    revision = _positive_integer(payload["registry_revision"], "registry_revision")
    canon_revision = payload["canon_revision"]
    if (
        isinstance(canon_revision, bool)
        or not isinstance(canon_revision, int)
        or canon_revision < 0
    ):
        raise _error("command-resolution canon revision is invalid", path)
    raw_records = payload["records"]
    if not isinstance(raw_records, list):
        raise _error("command-resolution records must be an array", path)
    records = tuple(_parse_record(item, path) for item in raw_records)
    identifiers = tuple(item.resolution_id for item in records)
    if identifiers != tuple(sorted(set(identifiers))):
        raise _error("resolution records must be sorted with unique global IDs", path)
    raw_state_command_records = payload["state_command_records"]
    if not isinstance(raw_state_command_records, list):
        raise _error("state command records must be an array", path)
    state_command_records = tuple(
        _parse_state_command_record(
            item, path, repository_root, captured_sources
        )
        for item in raw_state_command_records
    )
    state_command_ids = tuple(
        item.command.command_id for item in state_command_records
    )
    if state_command_ids != tuple(sorted(set(state_command_ids))):
        raise _error(
            "state command records must be sorted with unique command IDs",
            path,
        )
    registry = CommandResolutionRegistry(
        schema_version=2,
        registry_id=registry_id,
        registry_revision=revision,
        canon_revision=canon_revision,
        records=records,
        state_command_records=state_command_records,
        source_sha256=source_sha256,
        source_path=path,
        repository_root=repository_root,
    )
    if len(_LOADED_REGISTRY_CACHE) >= 8:
        _LOADED_REGISTRY_CACHE.pop(next(iter(_LOADED_REGISTRY_CACHE)))
    _LOADED_REGISTRY_CACHE[(repository_root, source_sha256)] = registry
    return registry


def _binding_mismatch(
    actual: CommandResolutionRecord,
    expected: CommandResolutionRecord,
    path: Path | None,
) -> None:
    if actual.owner_concept != expected.owner_concept:
        raise _error("resolution owner binding is wrong", path)
    if (
        actual.requirement_id != expected.requirement_id
        or actual.state_id != expected.state_id
        or actual.command_id != expected.command_id
    ):
        raise _error("resolution requirement/state/command binding is wrong", path)
    if (
        actual.resolution_kind != expected.resolution_kind
        or actual.mechanism_kind != expected.mechanism_kind
        or actual.posture != expected.posture
    ):
        raise _error("resolution kind or posture binding is wrong", path)
    if actual.behavior_binding != expected.behavior_binding:
        raise _error("resolution behavior/source binding is stale", path)
    if (
        actual.state_command_record_sha256
        != expected.state_command_record_sha256
    ):
        raise _error("resolution state command binding is stale", path)
    if actual.record_sha256 != expected.record_sha256:
        raise _error("resolution record hash is stale", path)


def _state_command_binding_mismatch(
    actual: StateCommandResolutionRecord,
    expected: StateCommandResolutionRecord,
    path: Path | None,
) -> None:
    if actual.record_sha256 != state_command_resolution_record_sha256(actual):
        raise _error("state command record hash is stale", path)
    if (
        actual.command.canonical_owner != expected.command.canonical_owner
        or actual.command.recovery_owner != expected.command.recovery_owner
    ):
        raise _error("state command owner binding is wrong", path)
    if (
        actual.source_path != expected.source_path
        or actual.requirement_id != expected.requirement_id
        or actual.state_id != expected.state_id
        or actual.trigger_command_id != expected.trigger_command_id
        or actual.mechanism_kind != expected.mechanism_kind
        or actual.command.command_id != expected.command.command_id
    ):
        raise _error("state command source binding is wrong", path)
    if (
        actual.command != expected.command
        or actual.command_sha256 != state_command_behavior_sha256(actual.command)
        or actual.command_sha256 != expected.command_sha256
    ):
        raise _error("state command behavior binding is stale", path)
    if actual.record_sha256 != expected.record_sha256:
        raise _error("state command record binding is stale", path)


def validate_command_resolution_bindings(
    registry: CommandResolutionRegistry,
    canon: CanonRegistry,
) -> None:
    """Require exact independent resolution for every canonical machine reference."""

    if registry.canon_revision != canon.manifest.canon_revision:
        raise _error("command-resolution canon revision is stale", registry.source_path)
    contract_set = tuple(
        (document.source_path, contract)
        for document in canon.documents
        for contract in document.state_command_contracts
    )
    if contract_set in registry.validated_contract_sets:
        return
    actual_state_records = {
        item.command.command_id: item for item in registry.state_command_records
    }
    if len(actual_state_records) != len(registry.state_command_records):
        raise _error("duplicate state command record", registry.source_path)
    expected_state_records_tuple = expected_state_command_resolution_records(canon)
    expected_state_records = {
        item.command.command_id: item for item in expected_state_records_tuple
    }
    missing_state_records = sorted(
        set(expected_state_records) - set(actual_state_records)
    )
    if missing_state_records:
        raise _error(
            f"state command record is missing: {missing_state_records[0]}",
            registry.source_path,
        )
    unbound_state_records = sorted(
        set(actual_state_records) - set(expected_state_records)
    )
    if unbound_state_records:
        raise _error(
            f"state command record is not referenced: {unbound_state_records[0]}",
            registry.source_path,
        )
    for identifier in sorted(expected_state_records):
        _state_command_binding_mismatch(
            actual_state_records[identifier],
            expected_state_records[identifier],
            registry.source_path,
        )
    actual = {item.resolution_id: item for item in registry.records}
    if len(actual) != len(registry.records):
        raise _error("duplicate command-resolution identity", registry.source_path)
    expected_records = expected_command_resolution_records(canon)
    expected = {item.resolution_id: item for item in expected_records}
    if len(expected) != len(expected_records):
        raise _error("canonical machine identities are not globally unique")
    missing = sorted(set(expected) - set(actual))
    if missing:
        raise _error(
            f"resolution record is missing: {missing[0]}",
            registry.source_path,
        )
    unbound = sorted(set(actual) - set(expected))
    if unbound:
        raise _error(
            f"resolution record is not referenced: {unbound[0]}",
            registry.source_path,
        )
    primary_commands = {
        command.command_id
        for document in canon.documents
        for contract in document.state_command_contracts
        for command in contract.commands
    }
    for identifier in sorted(expected):
        _binding_mismatch(actual[identifier], expected[identifier], registry.source_path)
        _validate_record(actual[identifier], registry.source_path)
        if (
            actual[identifier].resolution_kind == "recovery_command"
            and identifier in primary_commands
        ):
            raise _error(
                f"recovery command collides with primary command: {identifier}",
                registry.source_path,
            )
    registry.validated_contract_sets.add(contract_set)


def validate_repository_command_resolutions(
    root: Path,
    canon: CanonRegistry,
) -> CommandResolutionRegistry | None:
    """Close live audit/build only when a command-bearing corpus fully resolves."""

    if not any(
        document.state_command_contracts for document in canon.documents
    ):
        return None
    registry = load_command_resolution_registry(root)
    validate_command_resolution_bindings(registry, canon)
    return registry


def _resolved_record(
    records: Mapping[str, CommandResolutionRecord],
    expected: CommandResolutionRecord,
    path: Path,
) -> CommandResolutionRecord:
    actual = records.get(expected.resolution_id)
    if actual is None:
        raise _error(
            f"resolution record is missing: {expected.resolution_id}",
            path,
        )
    _binding_mismatch(actual, expected, path)
    return actual


def resolve_state_command_machine_contract(
    registry: CommandResolutionRegistry,
    source_path: Path,
    contract: StateCommandContract,
    command: StateCommand,
) -> dict[str, object]:
    """Resolve a command projection only through exact independent records."""

    cache_key = (source_path, contract, command)
    cached = registry.resolution_cache.get(cache_key)
    if cached is not None:
        return copy.deepcopy(cached)
    recovery_command_record_hashes = {
        item.command.command_id: item.record_sha256
        for item in registry.state_command_records
    }
    expected = _command_record_specs(
        source_path,
        contract,
        command,
        recovery_command_record_hashes=recovery_command_record_hashes,
    )
    resolved = {
        item.resolution_id: _resolved_record(
            registry.records_by_id,
            item,
            registry.source_path,
        )
        for item in expected
    }
    mechanism_ids = tuple(
        identifier
        for identifier in (
            command.inverse_command_id,
            command.checkpoint_id,
            command.recovery_handoff_command_id,
            command.irreversible_confirmation_id,
            command.irreversible_receipt_id,
        )
        if identifier is not None
    )
    mechanism_commands = []
    for identifier in mechanism_ids:
        state_record = next(
            (
                item
                for item in registry.state_command_records
                if item.command.command_id == identifier
            ),
            None,
        )
        if state_record is None:
            continue
        if state_record.trigger_command_id != command.command_id:
            raise _error(
                f"recovery command trigger binding is wrong: {identifier}",
                registry.source_path,
            )
        mechanism_commands.append(
            _recovery_command_behavior_projection(state_record)
        )
    projection = {
        "activation_posture": command.activation_posture.value,
        "command_id": command.command_id,
        "destination": {
            "detail": command.destination,
            "id": command.destination_id,
            "posture": command.destination_posture.value,
            "resolution_record": command_resolution_record_projection(
                resolved[command.destination_id]
            ),
        },
        "failure_focus": {
            "detail": command.failure_focus,
            "id": command.failure_focus_id,
            "posture": command.failure_focus_posture.value,
            "resolution_record": command_resolution_record_projection(
                resolved[command.failure_focus_id]
            ),
        },
        "label": command.label,
        "recovery": {
            "checkpoint_id": command.checkpoint_id,
            "detail": command.rollback_undo,
            "id": command.recovery_id,
            "inverse_command_id": command.inverse_command_id,
            "irreversible_confirmation_id": command.irreversible_confirmation_id,
            "irreversible_receipt_id": command.irreversible_receipt_id,
            "mechanism_records": [
                command_resolution_record_projection(resolved[identifier])
                for identifier in mechanism_ids
            ],
            "mechanism_commands": mechanism_commands,
            "owner": command.recovery_owner,
            "posture": command.recovery_posture.value,
            "recovery_handoff_command_id": command.recovery_handoff_command_id,
            "resolution_record": command_resolution_record_projection(
                resolved[command.recovery_id]
            ),
            "rollback_posture": (
                command.rollback_posture.value
                if command.rollback_posture is not None
                else None
            ),
        },
        "resolution_registry": {
            "registry_id": registry.registry_id,
            "registry_revision": registry.registry_revision,
            "source_sha256": registry.source_sha256,
        },
        "success_focus": {
            "detail": command.success_focus,
            "id": command.success_focus_id,
            "posture": command.success_focus_posture.value,
            "resolution_record": command_resolution_record_projection(
                resolved[command.success_focus_id]
            ),
        },
    }
    registry.resolution_cache[cache_key] = projection
    return copy.deepcopy(projection)
