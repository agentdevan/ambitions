"""Parser for canonical Markdown specification contracts."""

from __future__ import annotations

import re
import tomllib
from pathlib import Path

from tools.ambitions_canon.identifiers import CANONICAL_ID_GRAMMAR
from tools.ambitions_canon.model import (
    CanonDocument,
    CanonError,
    DocumentKind,
    Modality,
    NotApplicable,
    ObjectBoundary,
    Requirement,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
    StateCommandRollbackPosture,
)


FRONT = "+++"
REQ_HEADING = re.compile(
    rf"^##\s+({CANONICAL_ID_GRAMMAR})\s+—\s+(.+?)\s*$"
)
REQ_HEADING_CANDIDATE = re.compile(r"^##\s+(\S+)\s+—\s+(.+?)\s*$")
SECTION = re.compile(r"^<!--\s*canon-section:\s*([a-z0-9-]+)\s*-->$")
LEVEL_TWO_HEADING = re.compile(r"^##\s+.+?\s*$")
FIELD = re.compile(
    r"^- \*\*(Concept|Modality|Scope|Status|Verification|Supersedes):\*\*"
    r"\s*(.*?)\s*$"
)
METADATA_SHAPED = re.compile(r"^- \*\*([^*\n]+):\*\*\s*.*$")
BACKTICK_VALUE = re.compile(r"^`([^`\n]+)`$")
BACKTICK_LIST = re.compile(r"^`[^`\n]+`(?:\s*,\s*`[^`\n]+`)*$")
BACKTICK_ITEM = re.compile(r"`([^`\n]+)`")
TOML_LINE_LOCATION = re.compile(
    r"^.+ \(at line ([1-9]\d*), column [1-9]\d*\)$"
)
TOML_END_LOCATION = re.compile(r"^.+ \(at end of document\)$")

REQUIRED_FRONT_MATTER = {
    "spec_id": str,
    "title": str,
    "kind": str,
    "status": str,
    "owner_domain": str,
    "canon_revision": int,
    "owns_concepts": list,
    "inherits": list,
    "depends_on": list,
    "source_owners": list,
}
OPTIONAL_FRONT_MATTER = frozenset(
    {"profile", "not_applicable", "object_boundary", "state_command_contracts"}
)
FRONT_MATTER_FIELDS = frozenset(REQUIRED_FRONT_MATTER) | OPTIONAL_FRONT_MATTER
STRING_FRONT_MATTER = (
    "spec_id",
    "title",
    "status",
    "owner_domain",
)
ARRAY_FRONT_MATTER = (
    "owns_concepts",
    "inherits",
    "depends_on",
    "source_owners",
)
CONCEPT_KEY = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
SECTION_KEY = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
REQUIRED_FIELDS = (
    "Concept",
    "Modality",
    "Scope",
    "Status",
    "Verification",
    "Supersedes",
)
OBJECT_BOUNDARY_CAPABILITIES = (
    "executable_completable",
    "occupies_duration",
    "consumes_capacity",
    "due_date",
    "recurrence",
    "substeps",
    "goal_path_node",
    "proof_requirement",
    "attendees_rsvp",
    "alerts",
    "type_conversion",
)
OBJECT_BOUNDARY_LAWS = (
    "schedule_placement_nonduplication",
    "future_step_singularity",
    "reminder_acknowledgement_noncompletion",
    "proof_receipt_separation",
)
STATE_COMMAND_CONTRACT_FIELDS = frozenset(
    {
        "state_id",
        "requirement_id",
        "activation_posture",
        "gate_requirement_ids",
        "transition_exit",
        "durable_effect",
        "recovery_rollback",
        "offline_behavior",
        "accessibility_focus",
        "commands",
    }
)
STATE_COMMAND_REQUIRED_FIELDS = frozenset(
    {
        "command_id",
        "label",
        "canonical_owner",
        "preconditions",
        "destination",
        "effect",
        "success_focus",
        "failure_focus",
        "commit_boundary",
        "rollback_undo",
        "privacy_egress",
        "verification_ids",
    }
)
STATE_COMMAND_FIELDS = STATE_COMMAND_REQUIRED_FIELDS | {
    "activation_posture",
    "gate_requirement_ids",
    "rollback_posture",
}
STATE_ID = re.compile(r"^UX-STATE-VARIANT-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
COMMAND_ID = re.compile(r"^CMD-[A-Z0-9]+(?:-[A-Z0-9]+)*$")
NO_DISCLOSURE_STATE_ID = "UX-STATE-VARIANT-TRUST-INLINE-NO-DISCLOSURE"
GENERIC_STATE_COMMAND_PHRASES = (
    "command review for ux-state-variant-",
    "truthful status for ux-state-variant-",
    "preserves current canonical state for ux-state-variant-",
)
UNRESOLVED_COMMAND_MARKER = re.compile(
    r"^\s*(?:tbd|todo|unknown|unspecified|unresolved|undecided)\s*$",
    re.IGNORECASE,
)
UNRESOLVED_COMMAND_TARGET_PREFIX = re.compile(
    r"^\s*(?:the\s+)?(?:"
    r"(?:pending|unknown|unspecified|unresolved|undecided|forthcoming)\s+"
    r"(?:destination|route|focus|target)\b"
    r"|(?:destination|route|focus|target)\b\s+(?:"
    r"(?:is|remains|will\s+be)\s+"
    r"(?:pending|unknown|unspecified|unresolved|undecided|forthcoming)\b"
    r"|(?:is|has|remains)?\s*not(?:\s+yet)?\s+(?:been\s+)?"
    r"(?:known|decided|defined|determined|specified|available)\b"
    r"|to\s+be\s+(?:decided|defined|determined|specified)\b"
    r"|forthcoming\b"
    r")"
    r")",
    re.IGNORECASE,
)
ROLLBACK_PLACEHOLDER = re.compile(
    r"^\s*(?:tbd|todo|unknown|unspecified|unresolved|undecided)\s*$",
    re.IGNORECASE,
)


def _is_unresolved_command_target(value: str) -> bool:
    """Reject placeholder routes/focuses without matching legitimate state titles."""

    normalized = " ".join(value.split())
    return bool(
        UNRESOLVED_COMMAND_MARKER.fullmatch(normalized)
        or UNRESOLVED_COMMAND_TARGET_PREFIX.match(normalized)
    )


def _rollback_term_is_negated(text: str, terms: tuple[str, ...]) -> bool:
    term_pattern = "(?:" + "|".join(re.escape(term) for term in terms) + ")"
    patterns = (
        rf"\b(?:no|without|missing|absent)\b(?:\W+\w+){{0,3}}\W+{term_pattern}\b",
        rf"\b{term_pattern}\b(?:\W+\w+){{0,6}}\W+"
        rf"(?:is|are|was|were|remains|has|have)?\s*"
        rf"(?:not\s+(?:available|defined|provided|specified|supported|safe)|"
        rf"unavailable|impossible|missing|absent|undefined|unspecified|unsupported|"
        rf"does\s+not\s+exist|has\s+not\s+been\s+(?:defined|provided|specified))\b",
    )
    return any(re.search(pattern, text, re.IGNORECASE | re.DOTALL) for pattern in patterns)


def _has_actionable_mutation_rollback(command: StateCommand) -> bool:
    """Require a positive posture-specific closure, not enum or keyword laundering."""

    posture = command.rollback_posture
    text = " ".join(command.rollback_undo.split()).casefold()
    if posture is None or ROLLBACK_PLACEHOLDER.fullmatch(text):
        return False

    if posture is StateCommandRollbackPosture.INVERSE_COMMAND:
        if _rollback_term_is_negated(
            text,
            (
                "rollback",
                "inverse",
                "undo",
                "reversing event",
                "restore",
                "re-enabling",
            ),
        ):
            return False
        return bool(
            "typed inverse command" in text
            or ("typed inverse" in text and any(token in text for token in ("restore", "revers")))
            or ("undo" in text and ("typed" in text or "revers" in text))
            or ("restore" in text and "typed command" in text)
            or ("inverse control" in text and "typed" in text)
            or ("re-enabl" in text and "typed command" in text)
        )

    if posture is StateCommandRollbackPosture.CHECKPOINT_RESTORE:
        if _rollback_term_is_negated(
            text,
            ("checkpoint", "restore", "rollback", "journal", "recovery point"),
        ):
            return False
        return bool(
            ("checkpoint" in text and any(token in text for token in ("restore", "reopen", "recover")))
            or ("journal" in text and any(token in text for token in ("rollback", "restore", "recover", "last honest store")))
        )

    if posture is StateCommandRollbackPosture.OWNER_RECOVERY_HANDOFF:
        if _rollback_term_is_negated(
            text,
            ("recovery", "handoff", "typed command", "recovery point"),
        ):
            return False
        return bool(
            ("recovery" in text and any(token in text for token in ("handoff", "route", "separately authorized typed command")))
            or ("separate typed command" in text)
            or ("recovery-point" in text and "quarantin" in text)
            or ("recovery" in text and "completed" in text and "failed" in text)
        )

    if posture is StateCommandRollbackPosture.CONFIRMED_IRREVERSIBLE:
        if _rollback_term_is_negated(text, ("confirmation", "confirmed")):
            return False
        return all(
            token in text
            for token in ("irreversible", "confirm", "receipt", "scope")
        )

    return False


def parse_front_matter(
    text: str,
    path: Path,
) -> tuple[dict[str, object], str, int]:
    """Parse the leading TOML block and retain body line correspondence."""

    lines = text.splitlines()
    if not lines or lines[0] != FRONT:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing opening delimiter",
            path,
            1,
        )
    try:
        closing = lines.index(FRONT, 1)
    except ValueError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing closing delimiter",
            path,
            len(lines),
        ) from exc

    try:
        metadata = tomllib.loads("\n".join(lines[1:closing]))
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "invalid TOML",
            path,
            _toml_source_line(exc, closing),
        ) from exc

    return metadata, "\n".join(lines[closing + 1 :]) + "\n", closing + 2


def _toml_source_line(exc: tomllib.TOMLDecodeError, closing: int) -> int:
    message = str(exc)
    if match := TOML_LINE_LOCATION.fullmatch(message):
        return int(match.group(1)) + 1
    if TOML_END_LOCATION.fullmatch(message):
        return max(1, closing)
    return 1


def parse_canon_document(path: Path, text: str) -> CanonDocument:
    """Parse one canonical Markdown document without global registry checks."""

    metadata, body, body_start_line = parse_front_matter(text, path)
    _validate_front_matter(metadata, path)

    body_lines = body.splitlines()
    sections = frozenset(
        match.group(1)
        for line in body_lines
        if (match := SECTION.fullmatch(line)) is not None
    )
    requirement_starts = _requirement_starts(body_lines, path, body_start_line)
    requirements = tuple(
        _parse_requirement(
            path,
            body_lines,
            start,
            _requirement_end(body_lines, start),
            heading,
            body_start_line,
        )
        for start, heading in requirement_starts
    )

    kind_value = metadata["kind"]
    assert isinstance(kind_value, str)
    try:
        kind = DocumentKind(kind_value)
    except ValueError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            f"invalid kind: {kind_value}",
            path,
            1,
        ) from exc

    profile = metadata.get("profile")
    assert profile is None or isinstance(profile, str)

    return CanonDocument(
        spec_id=_string(metadata, "spec_id"),
        title=_string(metadata, "title"),
        kind=kind,
        status=_string(metadata, "status"),
        owner_domain=_string(metadata, "owner_domain"),
        canon_revision=_integer(metadata, "canon_revision"),
        profile=profile,
        owns_concepts=_string_tuple(metadata, "owns_concepts"),
        inherits=_string_tuple(metadata, "inherits"),
        depends_on=_string_tuple(metadata, "depends_on"),
        source_owners=_string_tuple(metadata, "source_owners"),
        sections=sections,
        not_applicable=_not_applicable(metadata, path),
        requirements=requirements,
        source_path=path,
        object_boundary=_object_boundary(metadata, path),
        state_command_contracts=_state_command_contracts(
            metadata, path, requirements
        ),
    )


def _validate_front_matter(metadata: dict[str, object], path: Path) -> None:
    unknown = sorted(set(metadata) - FRONT_MATTER_FIELDS)
    if unknown:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            f"unknown field: {unknown[0]}",
            path,
            1,
        )
    for key, expected_type in REQUIRED_FRONT_MATTER.items():
        if key not in metadata:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"missing required field: {key}",
                path,
                1,
            )
        value = metadata[key]
        if expected_type is int:
            valid_type = isinstance(value, int) and not isinstance(value, bool)
        else:
            valid_type = isinstance(value, expected_type)
        if not valid_type:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"invalid field type: {key}",
                path,
                1,
            )

    for key in STRING_FRONT_MATTER:
        value = metadata[key]
        assert isinstance(value, str)
        if not value.strip():
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"field must be a non-empty string: {key}",
                path,
                1,
            )

    kind = metadata["kind"]
    assert isinstance(kind, str)
    if kind not in {item.value for item in DocumentKind}:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            f"invalid kind: {kind}",
            path,
            1,
        )

    revision = metadata["canon_revision"]
    assert isinstance(revision, int) and not isinstance(revision, bool)
    if revision < 0:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "canon_revision must be non-negative",
            path,
            1,
        )

    profile = metadata.get("profile")
    if profile is not None and (
        not isinstance(profile, str) or not profile.strip()
    ):
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "profile must be a non-empty string",
            path,
            1,
        )

    for key in ARRAY_FRONT_MATTER:
        value = metadata[key]
        assert isinstance(value, list)
        if not all(isinstance(item, str) and item.strip() for item in value):
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"field must contain only non-empty strings: {key}",
                path,
                1,
            )
        if len(value) != len(set(value)):
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"field must contain unique values: {key}",
                path,
                1,
            )

    concepts = metadata["owns_concepts"]
    assert isinstance(concepts, list)
    if any(CONCEPT_KEY.fullmatch(item) is None for item in concepts):
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "owns_concepts contains an invalid normalized concept",
            path,
            1,
        )

    _not_applicable(metadata, path)
    _object_boundary(metadata, path)
    _state_command_contracts(metadata, path)


def _state_command_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_STATE_COMMAND_INVALID", message, path, 1)


def _trimmed_state_text(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _state_command_error(
            path, f"state_command_contracts.{field} must be trimmed non-empty text"
        )
    return value


def _state_string_array(
    value: object,
    path: Path,
    field: str,
    *,
    allow_empty: bool = False,
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not allow_empty and not value):
        raise _state_command_error(
            path, f"state_command_contracts.{field} must be a string array"
        )
    items = tuple(_trimmed_state_text(item, path, field) for item in value)
    if items != tuple(sorted(set(items))):
        raise _state_command_error(
            path, f"state_command_contracts.{field} must be sorted and unique"
        )
    return items


def _state_command_contracts(
    metadata: dict[str, object],
    path: Path,
    requirements: tuple[Requirement, ...] | None = None,
) -> tuple[StateCommandContract, ...]:
    raw = metadata.get("state_command_contracts")
    if raw is None:
        return ()
    if not isinstance(raw, list) or not raw:
        raise _state_command_error(
            path, "state_command_contracts must be a non-empty array of tables"
        )
    contracts: list[StateCommandContract] = []
    command_ids: set[str] = set()
    for index, value in enumerate(raw):
        if not isinstance(value, dict) or set(value) != STATE_COMMAND_CONTRACT_FIELDS:
            raise _state_command_error(
                path,
                f"state_command_contracts[{index}] fields are closed",
            )
        state_id = _trimmed_state_text(value["state_id"], path, "state_id")
        if STATE_ID.fullmatch(state_id) is None:
            raise _state_command_error(path, f"invalid state ID: {state_id}")
        requirement_id = _trimmed_state_text(
            value["requirement_id"], path, "requirement_id"
        )
        if re.fullmatch(CANONICAL_ID_GRAMMAR, requirement_id) is None:
            raise _state_command_error(
                path, f"invalid owning requirement ID: {requirement_id}"
            )
        try:
            activation_posture = StateCommandActivationPosture(
                _trimmed_state_text(
                    value["activation_posture"], path, "activation_posture"
                )
            )
        except ValueError as exc:
            raise _state_command_error(
                path, f"invalid activation posture for {state_id}"
            ) from exc
        gate_requirement_ids = _state_string_array(
            value["gate_requirement_ids"],
            path,
            "gate_requirement_ids",
            allow_empty=True,
        )
        if any(
            re.fullmatch(CANONICAL_ID_GRAMMAR, identifier) is None
            for identifier in gate_requirement_ids
        ):
            raise _state_command_error(path, f"invalid gate requirement ID: {state_id}")
        if (
            activation_posture is StateCommandActivationPosture.ACTIVE
            and gate_requirement_ids
        ) or (
            activation_posture is StateCommandActivationPosture.FUTURE_GATED
            and not gate_requirement_ids
        ):
            raise _state_command_error(
                path, f"activation posture and gates contradict: {state_id}"
            )
        commands_raw = value["commands"]
        if not isinstance(commands_raw, list):
            raise _state_command_error(path, f"commands must be an array: {state_id}")
        if not commands_raw and state_id != NO_DISCLOSURE_STATE_ID:
            raise _state_command_error(
                path, f"state requires at least one command: {state_id}"
            )
        commands: list[StateCommand] = []
        for command_index, command_raw in enumerate(commands_raw):
            if (
                not isinstance(command_raw, dict)
                or not STATE_COMMAND_REQUIRED_FIELDS <= set(command_raw)
                or not set(command_raw) <= STATE_COMMAND_FIELDS
            ):
                raise _state_command_error(
                    path,
                    f"state command fields are closed: {state_id}[{command_index}]",
                )
            command_id = _trimmed_state_text(
                command_raw["command_id"], path, "commands.command_id"
            )
            if COMMAND_ID.fullmatch(command_id) is None:
                raise _state_command_error(path, f"invalid command ID: {command_id}")
            if command_id in command_ids:
                raise _state_command_error(path, f"duplicate command ID: {command_id}")
            command_ids.add(command_id)
            canonical_owner = _trimmed_state_text(
                command_raw["canonical_owner"], path, "commands.canonical_owner"
            )
            if CONCEPT_KEY.fullmatch(canonical_owner) is None:
                raise _state_command_error(
                    path, f"invalid canonical owner concept: {command_id}"
                )
            posture_is_explicit = "activation_posture" in command_raw
            gates_are_explicit = "gate_requirement_ids" in command_raw
            if posture_is_explicit != gates_are_explicit:
                raise _state_command_error(
                    path,
                    f"command activation posture and gates must be declared together: {command_id}",
                )
            if posture_is_explicit:
                try:
                    command_activation_posture = StateCommandActivationPosture(
                        _trimmed_state_text(
                            command_raw["activation_posture"],
                            path,
                            "commands.activation_posture",
                        )
                    )
                except ValueError as exc:
                    raise _state_command_error(
                        path, f"invalid command activation posture: {command_id}"
                    ) from exc
                command_gate_requirement_ids = _state_string_array(
                    command_raw["gate_requirement_ids"],
                    path,
                    "commands.gate_requirement_ids",
                    allow_empty=True,
                )
            else:
                command_activation_posture = activation_posture
                command_gate_requirement_ids = gate_requirement_ids
            if any(
                re.fullmatch(CANONICAL_ID_GRAMMAR, identifier) is None
                for identifier in command_gate_requirement_ids
            ):
                raise _state_command_error(
                    path, f"invalid command gate requirement ID: {command_id}"
                )
            if (
                command_activation_posture is StateCommandActivationPosture.ACTIVE
                and command_gate_requirement_ids
            ) or (
                command_activation_posture
                is StateCommandActivationPosture.FUTURE_GATED
                and not command_gate_requirement_ids
            ):
                raise _state_command_error(
                    path, f"command activation posture and gates contradict: {command_id}"
                )
            if (
                activation_posture is StateCommandActivationPosture.FUTURE_GATED
                and command_activation_posture is StateCommandActivationPosture.ACTIVE
            ):
                raise _state_command_error(
                    path, f"future-gated state cannot expose active command: {command_id}"
                )
            rollback_posture_raw = command_raw.get("rollback_posture")
            if rollback_posture_raw is None:
                rollback_posture = None
            else:
                try:
                    rollback_posture = StateCommandRollbackPosture(
                        _trimmed_state_text(
                            rollback_posture_raw,
                            path,
                            "commands.rollback_posture",
                        )
                    )
                except ValueError as exc:
                    raise _state_command_error(
                        path, f"invalid rollback posture: {command_id}"
                    ) from exc
            commands.append(
                StateCommand(
                    command_id=command_id,
                    label=_trimmed_state_text(
                        command_raw["label"], path, "commands.label"
                    ),
                    canonical_owner=canonical_owner,
                    preconditions=_state_string_array(
                        command_raw["preconditions"],
                        path,
                        "commands.preconditions",
                    ),
                    destination=_trimmed_state_text(
                        command_raw["destination"], path, "commands.destination"
                    ),
                    effect=_trimmed_state_text(
                        command_raw["effect"], path, "commands.effect"
                    ),
                    success_focus=_trimmed_state_text(
                        command_raw["success_focus"],
                        path,
                        "commands.success_focus",
                    ),
                    failure_focus=_trimmed_state_text(
                        command_raw["failure_focus"],
                        path,
                        "commands.failure_focus",
                    ),
                    commit_boundary=_trimmed_state_text(
                        command_raw["commit_boundary"],
                        path,
                        "commands.commit_boundary",
                    ),
                    rollback_undo=_trimmed_state_text(
                        command_raw["rollback_undo"],
                        path,
                        "commands.rollback_undo",
                    ),
                    privacy_egress=_trimmed_state_text(
                        command_raw["privacy_egress"],
                        path,
                        "commands.privacy_egress",
                    ),
                    verification_ids=_state_string_array(
                        command_raw["verification_ids"],
                        path,
                        "commands.verification_ids",
                    ),
                    activation_posture=command_activation_posture,
                    gate_requirement_ids=command_gate_requirement_ids,
                    rollback_posture=rollback_posture,
                )
            )
        if tuple(item.command_id for item in commands) != tuple(
            sorted(item.command_id for item in commands)
        ):
            raise _state_command_error(path, f"commands must be sorted: {state_id}")
        labels = tuple(item.label for item in commands)
        if len(labels) != len(set(labels)):
            raise _state_command_error(
                path, f"duplicate command label: {state_id}"
            )
        transition_exit = _trimmed_state_text(
            value["transition_exit"], path, "transition_exit"
        )
        expected_transition = (
            "\n".join(
                f"{item.label} => destination: {item.destination}; effect: "
                f"{item.effect}; focus: {item.success_focus}."
                for item in commands
            )
            if commands
            else "No command or transition is exposed."
        )
        durable_effect = _trimmed_state_text(
            value["durable_effect"], path, "durable_effect"
        )
        recovery_rollback = _trimmed_state_text(
            value["recovery_rollback"], path, "recovery_rollback"
        )
        offline_behavior = _trimmed_state_text(
            value["offline_behavior"], path, "offline_behavior"
        )
        accessibility_focus = _trimmed_state_text(
            value["accessibility_focus"], path, "accessibility_focus"
        )
        _validate_state_command_semantics(
            path,
            state_id,
            durable_effect,
            recovery_rollback,
            offline_behavior,
            accessibility_focus,
            commands,
        )
        if transition_exit != expected_transition:
            raise _state_command_error(
                path, f"state transition contradicts commands: {state_id}"
            )
        contracts.append(
            StateCommandContract(
                state_id=state_id,
                requirement_id=requirement_id,
                activation_posture=activation_posture,
                gate_requirement_ids=gate_requirement_ids,
                transition_exit=transition_exit,
                durable_effect=durable_effect,
                recovery_rollback=recovery_rollback,
                offline_behavior=offline_behavior,
                accessibility_focus=accessibility_focus,
                commands=tuple(commands),
            )
        )
    if tuple(item.state_id for item in contracts) != tuple(
        sorted({item.state_id for item in contracts})
    ):
        raise _state_command_error(
            path, "state_command_contracts must be sorted with unique state IDs"
        )
    if requirements is not None:
        by_id = {item.requirement_id: item for item in requirements}
        concept_counts: dict[str, int] = {}
        for item in requirements:
            concept_counts[item.concept] = concept_counts.get(item.concept, 0) + 1
        owned_concepts = set(metadata["owns_concepts"])
        for contract in contracts:
            requirement = by_id.get(contract.requirement_id)
            if requirement is None:
                raise _state_command_error(
                    path,
                    f"owning requirement is not in the same specification: {contract.state_id}",
                )
            if (
                requirement.modality is not Modality.MUST
                or requirement.concept not in owned_concepts
                or concept_counts.get(requirement.concept) != 1
            ):
                raise _state_command_error(
                    path,
                    f"owning requirement concept is not unique and local: {contract.state_id}",
                )
            for command in contract.commands:
                if command.canonical_owner != requirement.concept:
                    raise _state_command_error(
                        path, f"command owner concept mismatch: {command.command_id}"
                    )
                if re.search(
                    rf"(?<!\w){re.escape(command.label)}(?!\w)",
                    requirement.body,
                    re.IGNORECASE,
                ) is None:
                    raise _state_command_error(
                        path,
                        f"owning requirement does not name command label: {command.command_id}",
                    )
    return tuple(contracts)


def _validate_state_command_semantics(
    path: Path,
    state_id: str,
    durable_effect: str,
    recovery_rollback: str,
    offline_behavior: str,
    accessibility_focus: str,
    commands: list[StateCommand],
) -> None:
    """Reject self-referential templates and undeclared command consequences."""

    state_text = " ".join(
        (durable_effect, recovery_rollback, offline_behavior, accessibility_focus)
    ).casefold()
    if state_id.casefold() in state_text or any(
        phrase in state_text for phrase in GENERIC_STATE_COMMAND_PHRASES
    ):
        raise _state_command_error(
            path, f"generic or self-referential state semantics: {state_id}"
        )

    signatures: set[tuple[str, ...]] = set()
    for command in commands:
        semantic_fields = (
            command.destination,
            command.effect,
            command.success_focus,
            command.failure_focus,
            command.commit_boundary,
            command.rollback_undo,
            command.privacy_egress,
        )
        semantic_text = " ".join(semantic_fields).casefold()
        if any(
            _is_unresolved_command_target(value)
            for value in (
                command.destination,
                command.success_focus,
                command.failure_focus,
            )
        ):
            raise _state_command_error(
                path,
                f"unresolved command route or focus: {command.command_id}",
            )
        if state_id.casefold() in semantic_text or any(
            phrase in semantic_text for phrase in GENERIC_STATE_COMMAND_PHRASES
        ):
            raise _state_command_error(
                path,
                f"generic or self-referential command semantics: {command.command_id}",
            )
        if command.commit_boundary.startswith("Non-mutating:"):
            if (
                "no durable mutation" not in command.effect.casefold()
                or "no receipt" not in command.effect.casefold()
            ):
                raise _state_command_error(
                    path,
                    f"non-mutating command omits no-mutation/Receipt law: {command.command_id}",
                )
        elif command.commit_boundary.startswith("Mutation:"):
            required = ("typed", "event", "projection", "receipt", "history")
            if any(term not in command.effect.casefold() for term in required):
                raise _state_command_error(
                    path,
                    f"mutation command omits typed source/test/proof consequence: {command.command_id}",
                )
            if not _has_actionable_mutation_rollback(command):
                raise _state_command_error(
                    path,
                    f"mutation command omits actionable rollback: {command.command_id}",
                )
        elif command.commit_boundary.startswith("External-result:"):
            if "no local canonical mutation" not in command.effect.casefold():
                raise _state_command_error(
                    path,
                    f"external-result command can replay local mutation: {command.command_id}",
                )
        else:
            raise _state_command_error(
                path,
                f"command commit posture is undeclared: {command.command_id}",
            )
        signature = (
            command.destination,
            command.effect,
            command.success_focus,
            command.commit_boundary,
            command.rollback_undo,
        )
        if signature in signatures:
            raise _state_command_error(
                path,
                f"commands have indistinguishable semantics: {state_id}",
            )
        signatures.add(signature)


def validate_state_command_contract_semantics(
    path: Path,
    contract: StateCommandContract,
) -> None:
    """Revalidate a parsed or projected contract before downstream use."""

    _validate_state_command_semantics(
        path,
        contract.state_id,
        contract.durable_effect,
        contract.recovery_rollback,
        contract.offline_behavior,
        contract.accessibility_focus,
        list(contract.commands),
    )


def _object_boundary(
    metadata: dict[str, object], path: Path
) -> ObjectBoundary | None:
    raw = metadata.get("object_boundary")
    if raw is None:
        return None
    if metadata.get("kind") != DocumentKind.OBJECT.value or not isinstance(raw, dict):
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_INVALID",
            "object_boundary requires kind=object and a TOML table",
            path,
            1,
        )
    required = set(OBJECT_BOUNDARY_CAPABILITIES) | {"laws"}
    if set(raw) != required:
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_INVALID",
            "object_boundary must contain exactly 11 capabilities and laws",
            path,
            1,
        )
    capabilities: list[tuple[str, str]] = []
    for key in OBJECT_BOUNDARY_CAPABILITIES:
        value = raw[key]
        if not isinstance(value, str) or not value.strip() or value != value.strip():
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_INVALID",
                f"object_boundary.{key} must be a trimmed non-empty string",
                path,
                1,
            )
        capabilities.append((key, value))
    laws = raw["laws"]
    if not isinstance(laws, dict) or set(laws) != set(OBJECT_BOUNDARY_LAWS):
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_INVALID",
            "object_boundary.laws must contain exactly four stable law references",
            path,
            1,
        )
    law_items: list[tuple[str, str]] = []
    for key in OBJECT_BOUNDARY_LAWS:
        value = laws[key]
        if not isinstance(value, str) or not value.strip() or value != value.strip():
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_INVALID",
                f"object_boundary.laws.{key} must be a stable requirement ID",
                path,
                1,
            )
        law_items.append((key, value))
    return ObjectBoundary(tuple(capabilities), tuple(law_items))


def _not_applicable(
    metadata: dict[str, object],
    path: Path,
) -> tuple[NotApplicable, ...]:
    raw = metadata.get("not_applicable")
    if raw is None:
        return ()
    if not isinstance(raw, dict):
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "not_applicable must be a table",
            path,
            1,
        )
    entries: list[NotApplicable] = []
    for section in sorted(raw):
        if not isinstance(section, str) or SECTION_KEY.fullmatch(section) is None:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"invalid not_applicable section: {section}",
                path,
                1,
            )
        entry = raw[section]
        if not isinstance(entry, dict) or set(entry) != {"rationale", "owner"}:
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"not_applicable.{section} must contain exactly rationale and owner",
                path,
                1,
            )
        rationale = entry["rationale"]
        owner = entry["owner"]
        if not isinstance(rationale, str) or not rationale.strip():
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"not_applicable.{section}.rationale must be a non-empty string",
                path,
                1,
            )
        if not isinstance(owner, str) or not owner.strip():
            raise CanonError(
                "CANON_PARSE_FRONT_MATTER",
                f"not_applicable.{section}.owner must be a non-empty string",
                path,
                1,
            )
        entries.append(NotApplicable(section, rationale, owner))
    return tuple(entries)


def _requirement_starts(
    lines: list[str],
    path: Path,
    body_start_line: int,
) -> list[tuple[int, re.Match[str]]]:
    starts: list[tuple[int, re.Match[str]]] = []
    seen: set[str] = set()
    for index, line in enumerate(lines):
        match = REQ_HEADING.fullmatch(line)
        if match is None:
            if REQ_HEADING_CANDIDATE.fullmatch(line) is not None:
                raise CanonError(
                    "CANON_REQUIREMENT_FIELD",
                    "requirement heading uses an invalid canonical ID",
                    path,
                    body_start_line + index,
                )
            continue
        requirement_id = match.group(1)
        if requirement_id in seen:
            raise CanonError(
                "CANON_REQUIREMENT_DUPLICATE",
                f"duplicate requirement ID: {requirement_id}",
                path,
                body_start_line + index,
            )
        seen.add(requirement_id)
        starts.append((index, match))
    return starts


def _parse_requirement(
    path: Path,
    lines: list[str],
    start: int,
    end: int,
    heading: re.Match[str],
    body_start_line: int,
) -> Requirement:
    cursor = start + 1
    while cursor < end and lines[cursor] == "":
        cursor += 1

    fields: dict[str, tuple[str, int]] = {}
    while cursor < end:
        match = FIELD.fullmatch(lines[cursor])
        if match is None:
            break
        name, value = match.groups()
        source_line = body_start_line + cursor
        if name in fields:
            raise CanonError(
                "CANON_REQUIREMENT_FIELD",
                f"duplicate requirement field: {name}",
                path,
                source_line,
            )
        fields[name] = (value, source_line)
        cursor += 1

    for name in REQUIRED_FIELDS:
        if name not in fields:
            raise CanonError(
                "CANON_REQUIREMENT_FIELD",
                f"missing requirement field: {name}",
                path,
                body_start_line + start,
            )

    _reject_metadata_residue(path, lines, cursor, end, body_start_line)

    concept = _backtick_value(path, fields["Concept"], "Concept")
    if CONCEPT_KEY.fullmatch(concept) is None:
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"invalid normalized Concept: {concept}",
            path,
            fields["Concept"][1],
        )
    modality_text = _backtick_value(path, fields["Modality"], "Modality")
    try:
        modality = Modality(modality_text)
    except ValueError as exc:
        raise CanonError(
            "CANON_REQUIREMENT_MODALITY",
            f"invalid modality: {modality_text}",
            path,
            fields["Modality"][1],
        ) from exc
    scope = fields["Scope"][0]
    if not scope.strip():
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            "empty requirement field: Scope",
            path,
            fields["Scope"][1],
        )
    status = _backtick_value(path, fields["Status"], "Status")
    verification = _backtick_list(path, fields["Verification"], "Verification")
    supersedes = _backtick_list(path, fields["Supersedes"], "Supersedes")

    while cursor < end and lines[cursor] == "":
        cursor += 1
    body_end = end
    while body_end > cursor and lines[body_end - 1] == "":
        body_end -= 1

    return Requirement(
        requirement_id=heading.group(1),
        title=heading.group(2),
        concept=concept,
        modality=modality,
        scope=scope,
        status=status,
        verification=verification,
        supersedes=supersedes,
        body="\n".join(lines[cursor:body_end]),
        source_path=path,
        line=body_start_line + start,
    )


def _requirement_end(lines: list[str], start: int) -> int:
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if LEVEL_TWO_HEADING.fullmatch(line) or SECTION.fullmatch(line):
            return index
    return len(lines)


def _reject_metadata_residue(
    path: Path,
    lines: list[str],
    start: int,
    end: int,
    body_start_line: int,
) -> None:
    for index in range(start, end):
        match = METADATA_SHAPED.fullmatch(lines[index])
        if match is None:
            continue
        name = match.group(1)
        qualifier = "duplicate" if name in REQUIRED_FIELDS else "unknown"
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{qualifier} requirement field: {name}",
            path,
            body_start_line + index,
        )


def _backtick_value(
    path: Path,
    field: tuple[str, int],
    name: str,
) -> str:
    value, line = field
    match = BACKTICK_VALUE.fullmatch(value)
    if match is None or match.group(1) != match.group(1).strip():
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} must be one backtick value",
            path,
            line,
        )
    return match.group(1)


def _backtick_list(
    path: Path,
    field: tuple[str, int],
    name: str,
) -> tuple[str, ...]:
    value, line = field
    if value == "none":
        return ()
    if BACKTICK_LIST.fullmatch(value) is None:
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} must be a backtick list or literal none",
            path,
            line,
        )
    items = tuple(match.group(1) for match in BACKTICK_ITEM.finditer(value))
    if any(item != item.strip() for item in items):
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} contains an invalid backtick value",
            path,
            line,
        )
    if len(items) != len(set(items)):
        raise CanonError(
            "CANON_REQUIREMENT_FIELD",
            f"{name} contains a duplicate value",
            path,
            line,
        )
    return items


def _string(metadata: dict[str, object], key: str) -> str:
    value = metadata[key]
    assert isinstance(value, str)
    return value


def _integer(metadata: dict[str, object], key: str) -> int:
    value = metadata[key]
    assert isinstance(value, int) and not isinstance(value, bool)
    return value


def _string_tuple(metadata: dict[str, object], key: str) -> tuple[str, ...]:
    value = metadata[key]
    assert isinstance(value, list)
    return tuple(value)
