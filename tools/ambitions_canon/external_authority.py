"""Stable, non-normative Linear, Figma, and proof reference handling."""

from __future__ import annotations

import hashlib
import json
import os
import stat
import tomllib
from collections import Counter
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.coverage import GapClass, GapDescriptor
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReference,
    AuthorityReferenceKind,
    CanonError,
    CanonRegistry,
    Finding,
    FigmaAuthorityRole,
    GapSeverity,
)


REFERENCE_FILES = (
    (Path("docs/canon/references/figma.toml"), AuthorityReferenceKind.FIGMA),
    (Path("docs/canon/references/linear.toml"), AuthorityReferenceKind.LINEAR),
    (Path("docs/canon/references/proof-sources.toml"), AuthorityReferenceKind.PROOF),
)
_TOP_LEVEL_FIELDS = frozenset({"schema_version", "kind", "references"})
_REFERENCE_REQUIRED = frozenset(
    {
        "reference_id",
        "source",
        "revision",
        "requirement_ids",
        "approval_state",
        "implementation_status",
    }
)
_REFERENCE_ALLOWED = _REFERENCE_REQUIRED | {"approved_by", "authority_role"}
_APPROVAL_STATES = frozenset({"unreviewed", "approved", "rejected", "stale"})
_ALLOWED_EXTERNAL_PROOF_PREFIXES = (
    "figma:",
    "linear:",
    "linear-comment:",
    "linear-ledger:",
    "https://",
)
_LINEAR_RECONCILIATION = Path("docs/canon/migration/linear-reconciliation.json")
_LINEAR_ROOT_FIELDS = frozenset(
    {
        "action_rules",
        "allowed_actions",
        "authority_state",
        "batches",
        "canon_revision",
        "content_checksum_contract",
        "disposition_state",
        "entities",
        "external_mutations_applied",
        "generated_from",
        "inventory_counts",
        "inventory_scope",
        "pilot_decision_required",
        "schema_version",
    }
)
_LINEAR_ENTITY_FIELDS = frozenset(
    {
        "action_status",
        "claimed_authority",
        "content_sha256",
        "current_execution_value",
        "entity_id",
        "entity_type",
        "live_metadata",
        "owner_approval_required",
        "parent_id",
        "recommended_action",
        "replacement_ids",
        "represented_requirement_ids",
        "title",
        "unique_accepted_content_summary",
    }
)
_LINEAR_ENTITY_TYPES = frozenset(
    {
        "comment",
        "document",
        "initiative",
        "issue",
        "milestone",
        "project",
        "status_update",
    }
)
_LINEAR_METADATA_FIELDS = frozenset({"created_at", "status", "updated_at"})
_LINEAR_BATCH_BASE_FIELDS = frozenset({"action", "batch_id", "status"})
_LINEAR_DESTRUCTIVE_FIELDS = frozenset(
    {"destructive_authorization", "gate", "manual_deletion_action"}
)
_LINEAR_DESTRUCTIVE_ACTIONS = frozenset(
    {"archive_after_extraction", "delete_after_extraction"}
)
_LINEAR_ACTIONS = frozenset(
    {
        "keep_execution_reference",
        "rewrite_to_requirement_references",
        "delete_after_extraction",
        "retain_provenance_only",
        "owner_review",
        "archive_after_extraction",
    }
)
_LINEAR_ACTION_ORDER = (
    "keep_execution_reference",
    "rewrite_to_requirement_references",
    "delete_after_extraction",
    "retain_provenance_only",
    "owner_review",
    "archive_after_extraction",
)
_LINEAR_CHECKSUM_CONTRACT = {
    "algorithm": "sha256",
    "encoding": "utf-8",
    "json_ensure_ascii": False,
    "json_key_order": ["title", "content", "summary"],
    "json_separators": [",", ":"],
    "null_or_absent_text": "",
    "terminal_newline": False,
    "extractors": {
        "comment": ["derived_parent_title", "body", ""],
        "document": ["title", "content", ""],
        "initiative": ["name", "description", "summary"],
        "issue": ["title", "description", ""],
        "milestone": ["name", "description", ""],
        "project": ["name", "description", "summary"],
        "status_update": ["derived_parent_title", "body", ""],
    },
    "offline_validation": "format_and_internal_bindings_only",
    "write_time_guard": "fresh_connector_read_and_exact_recomputation_required",
}


@dataclass(frozen=True, slots=True)
class ExternalReferenceSnapshot:
    references: tuple[AuthorityReference, ...]
    source_bytes: tuple[tuple[Path, bytes], ...]
    input_sha: str


@dataclass(frozen=True, slots=True)
class LinearReconciliationSnapshot:
    source_bytes: bytes
    input_sha: str
    entity_count: int
    inventory_counts: Mapping[str, int]
    action_counts: Mapping[str, int]
    status_counts: Mapping[str, int]
    disposition_state: str
    external_mutations_applied: bool
    owner_gate_required: bool

    def summary(self) -> Mapping[str, object]:
        return {
            "action_counts": dict(self.action_counts),
            "disposition_state": self.disposition_state,
            "entity_count": self.entity_count,
            "external_mutations_applied": self.external_mutations_applied,
            "input_sha": self.input_sha,
            "owner_gate_required": self.owner_gate_required,
            "status_counts": dict(self.status_counts),
        }


def load_external_references(repo_root: Path) -> tuple[AuthorityReference, ...]:
    """Load the fixed tracked reference files without granting them authority."""

    return load_external_reference_snapshot(repo_root).references


def load_external_reference_snapshot(repo_root: Path) -> ExternalReferenceSnapshot:
    """Read all fixed reference bytes without following any path component."""

    records: list[AuthorityReference] = []
    inputs: list[tuple[Path, bytes]] = []
    for relative_path, expected_kind in REFERENCE_FILES:
        try:
            source_bytes = _read_regular_nofollow(repo_root, relative_path)
        except FileNotFoundError as exc:
            raise CanonError(
                "CANON_EXTERNAL_REFERENCE_MISSING",
                "required external reference input is missing",
                repo_root / relative_path,
            ) from exc
        except OSError as exc:
            raise CanonError(
                "CANON_EXTERNAL_REFERENCE_READ",
                "unable to read external reference input without following links",
                repo_root / relative_path,
            ) from exc
        inputs.append((relative_path, source_bytes))
        records.extend(
            _load_reference_file_bytes(
                source_bytes,
                repo_root / relative_path,
                expected_kind,
            )
        )
    ordered = tuple(sorted(records, key=lambda item: item.reference_id))
    identifiers = tuple(item.reference_id for item in ordered)
    if len(identifiers) != len(set(identifiers)):
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_DUPLICATE",
            "external reference IDs must be unique across reference files",
        )
    source_bytes = tuple(sorted(inputs, key=lambda item: item[0].as_posix()))
    return ExternalReferenceSnapshot(
        references=ordered,
        source_bytes=source_bytes,
        input_sha=_input_sha(source_bytes),
    )


def validate_external_reference_snapshot(
    repo_root: Path,
    snapshot: ExternalReferenceSnapshot,
) -> None:
    """Reject reference changes after a caller pins an immutable snapshot."""

    current = load_external_reference_snapshot(repo_root)
    if current.input_sha != snapshot.input_sha or current.source_bytes != snapshot.source_bytes:
        raise CanonError(
            "CANON_TRACEABILITY_INPUT_CHANGED",
            "external reference inputs changed during traceability generation",
            repo_root / "docs/canon/references",
        )


def validate_linear_reconciliation(
    repo_root: Path,
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> LinearReconciliationSnapshot:
    """Validate the tracked Linear proposal without granting it authority."""

    path = repo_root / _LINEAR_RECONCILIATION
    try:
        source_bytes = _read_regular_nofollow(repo_root, _LINEAR_RECONCILIATION)
    except (OSError, ValueError) as exc:
        raise CanonError(
            "CANON_LINEAR_RECONCILIATION_READ",
            "unable to read tracked Linear reconciliation input",
            path,
        ) from exc
    try:
        data = json.loads(source_bytes.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "CANON_LINEAR_RECONCILIATION_PARSE",
            "unable to parse tracked Linear reconciliation JSON",
            path,
        ) from exc
    if not isinstance(data, dict):
        raise _linear_reconciliation_error(path, "root must be an object")
    disposition = data.get("disposition_state")
    bounded_pair_state = disposition == "pilot_applied_verified_broader_withheld"
    initiative_state = disposition == "initiative_applied_verified_broader_withheld"
    applied_state = bounded_pair_state or initiative_state
    expected_root_fields = set(_LINEAR_ROOT_FIELDS)
    if bounded_pair_state:
        expected_root_fields.add("pilot_execution")
    if initiative_state:
        expected_root_fields.add("initiative_execution")
    if set(data) != expected_root_fields:
        raise _linear_reconciliation_error(path, "top-level fields are closed")
    if data.get("schema_version") != 1:
        raise _linear_reconciliation_error(path, "schema_version must be 1")
    if data.get("canon_revision") != registry.manifest.canon_revision:
        raise _linear_reconciliation_error(path, "canon_revision is stale")
    if data.get("authority_state") != registry.manifest.authority_state.value:
        raise _linear_reconciliation_error(path, "authority_state is stale")
    if disposition not in {
        "pilot_applied_verified_broader_withheld",
        "initiative_applied_verified_broader_withheld",
        "proposed_not_applied_owner_gate",
    }:
        raise _linear_reconciliation_error(path, "disposition_state is invalid")
    if data.get("external_mutations_applied") is not applied_state:
        raise _linear_reconciliation_error(
            path, "external mutation flag conflicts with disposition state"
        )
    _validate_linear_generated_from(data.get("generated_from"), path)
    if data.get("content_checksum_contract") != _LINEAR_CHECKSUM_CONTRACT:
        raise _linear_reconciliation_error(
            path, "content_checksum_contract is closed or stale"
        )
    _validate_linear_inventory_scope(data.get("inventory_scope"), path)
    allowed_actions = data.get("allowed_actions")
    if allowed_actions != list(_LINEAR_ACTION_ORDER):
        raise _linear_reconciliation_error(path, "allowed_actions is closed or stale")
    _validate_linear_action_rules(data.get("action_rules"), path)
    pilot = _validate_linear_pilot_decision(
        data.get("pilot_decision_required"), path
    )
    applied_execution_ids: frozenset[str] = frozenset()
    initiative_execution: Mapping[str, object] | None = None
    if bounded_pair_state:
        applied_execution_ids = frozenset(pilot["recommended_entity_ids"])
        _validate_linear_pilot_execution(
            data.get("pilot_execution"), path, applied_execution_ids
        )
    elif initiative_state:
        raw_initiative_execution = data.get("initiative_execution")
        applied_execution_ids = _validate_linear_initiative_execution(
            raw_initiative_execution, path, pilot["option_entities"]
        )
        assert isinstance(raw_initiative_execution, dict)
        initiative_execution = raw_initiative_execution
    destructive_batches = _validate_linear_batches(
        data.get("batches"),
        path,
        applied_state=applied_state,
        applied_entity_ids=applied_execution_ids,
    )

    entities = data.get("entities")
    if not isinstance(entities, list) or not entities:
        raise _linear_reconciliation_error(path, "entities must be a non-empty array")
    active_ids = {item.requirement_id for item in registry.requirements}
    entities_by_id: dict[str, dict[str, object]] = {}
    counts: Counter[str] = Counter()
    actions: Counter[str] = Counter()
    statuses: Counter[str] = Counter()
    applied_entity_ids: set[str] = set()
    for entity in entities:
        if not isinstance(entity, dict) or set(entity) != _LINEAR_ENTITY_FIELDS:
            raise _linear_reconciliation_error(path, "entity fields are closed")
        entity_id = _linear_string(entity.get("entity_id"), path, "entity_id")
        if entity_id in entities_by_id:
            raise _linear_reconciliation_error(path, "entity IDs must be unique")
        entity_type = _linear_string(entity.get("entity_type"), path, "entity_type")
        if entity_type not in _LINEAR_ENTITY_TYPES:
            raise _linear_reconciliation_error(path, "entity_type is invalid")
        _linear_string(entity.get("title"), path, "title")
        parent_id = entity.get("parent_id")
        if parent_id is not None:
            _linear_string(parent_id, path, "parent_id")
        _linear_string(entity.get("claimed_authority"), path, "claimed_authority")
        _linear_string(
            entity.get("unique_accepted_content_summary"),
            path,
            "unique_accepted_content_summary",
        )
        _linear_string(
            entity.get("current_execution_value"), path, "current_execution_value"
        )
        requirement_ids = _linear_string_array(
            entity.get("represented_requirement_ids"),
            path,
            "represented_requirement_ids",
        )
        for requirement_id in requirement_ids:
            if requirement_id in registry.superseded_ids:
                raise CanonError(
                    "CANON_LINEAR_RECONCILIATION_REQUIREMENT_SUPERSEDED",
                    f"superseded requirement entity_id={entity_id}",
                    path,
                )
            if requirement_id not in active_ids:
                raise CanonError(
                    "CANON_LINEAR_RECONCILIATION_REQUIREMENT_UNKNOWN",
                    f"unknown requirement entity_id={entity_id}",
                    path,
                )
        action = _linear_string(
            entity.get("recommended_action"), path, "recommended_action"
        )
        if action not in _LINEAR_ACTIONS:
            raise _linear_reconciliation_error(path, "recommended_action is invalid")
        action_status = entity.get("action_status")
        if action_status not in {"applied_verified", "proposed_not_applied"}:
            raise _linear_reconciliation_error(path, "action_status is invalid")
        if not applied_state and action_status != "proposed_not_applied":
            raise _linear_reconciliation_error(
                path, "applied entity requires mixed disposition"
            )
        if action_status == "applied_verified":
            if action != "rewrite_to_requirement_references":
                raise _linear_reconciliation_error(
                    path, "applied pilot entities require rewrite action"
                )
            applied_entity_ids.add(entity_id)
        if entity.get("owner_approval_required") is not True:
            raise _linear_reconciliation_error(path, "owner approval must be required")
        replacement_ids = entity.get("replacement_ids")
        if not isinstance(replacement_ids, list):
            raise _linear_reconciliation_error(path, "replacement_ids is invalid")
        replacements = tuple(
            _linear_string(item, path, "replacement_ids") for item in replacement_ids
        )
        if replacements != tuple(sorted(set(replacements))):
            raise _linear_reconciliation_error(
                path, "replacement_ids must be sorted and unique"
            )
        metadata = entity.get("live_metadata")
        if not isinstance(metadata, dict) or set(metadata) != _LINEAR_METADATA_FIELDS:
            raise _linear_reconciliation_error(path, "live_metadata fields are closed")
        raw_created_at = metadata.get("created_at")
        if raw_created_at is None:
            if entity_type != "milestone":
                raise _linear_reconciliation_error(
                    path, "created_at may be absent only for milestones"
                )
        else:
            _linear_string(raw_created_at, path, "created_at")
        raw_status = metadata.get("status")
        if raw_status is None:
            if entity_type != "issue":
                raise _linear_reconciliation_error(
                    path, "status may be absent only for issues"
                )
        else:
            _linear_string(raw_status, path, "status")
        raw_updated_at = metadata.get("updated_at")
        if raw_updated_at is None:
            if entity_type != "milestone":
                raise _linear_reconciliation_error(
                    path, "updated_at may be absent only for milestones"
                )
            updated_at = None
        else:
            updated_at = _linear_string(raw_updated_at, path, "updated_at")
        content_sha = _linear_string(
            entity.get("content_sha256"), path, "content_sha256"
        )
        if len(content_sha) != 64 or any(
            character not in "0123456789abcdef" for character in content_sha
        ):
            raise _linear_reconciliation_error(path, "content_sha256 is invalid")
        entities_by_id[entity_id] = {
            "action_status": action_status,
            "content_sha256": content_sha,
            "entity_type": entity_type,
            "requirement_ids": requirement_ids,
            "updated_at": updated_at,
        }
        counts[entity_type] += 1
        actions[action] += 1
        statuses[action_status] += 1
        if action in _LINEAR_DESTRUCTIVE_ACTIONS:
            if not replacements:
                raise _linear_reconciliation_error(
                    path, "destructive actions require replacement_ids"
                )
            if entity_id not in destructive_batches.get(action, frozenset()):
                raise _linear_reconciliation_error(
                    path, "destructive action is not deferred through Gate C"
                )

    inventory_counts = data.get("inventory_counts")
    if (
        not isinstance(inventory_counts, dict)
        or set(inventory_counts) - _LINEAR_ENTITY_TYPES
        or any(type(value) is not int or value < 1 for value in inventory_counts.values())
        or inventory_counts != dict(sorted(counts.items()))
    ):
        raise _linear_reconciliation_error(path, "inventory_counts is stale")
    if not set(pilot["entity_ids"]) <= set(entities_by_id):
        raise _linear_reconciliation_error(path, "pilot references unknown entities")
    if applied_state:
        if applied_entity_ids != applied_execution_ids:
            raise _linear_reconciliation_error(
                path, "applied entities differ from the approved execution scope"
            )
        if statuses["proposed_not_applied"] != len(entities) - len(applied_execution_ids):
            raise _linear_reconciliation_error(
                path, "all non-executed entities must remain proposed"
            )
        if initiative_state:
            assert initiative_execution is not None
            executed_entity = entities_by_id[initiative_execution["entity_id"]]
            if executed_entity["entity_type"] != "initiative":
                raise _linear_reconciliation_error(
                    path, "initiative execution entity type is invalid"
                )
            if executed_entity["action_status"] != initiative_execution["status"]:
                raise _linear_reconciliation_error(
                    path, "initiative execution status differs from the entity"
                )
            if (
                executed_entity["content_sha256"]
                != initiative_execution["after_canonical_sha256"]
            ):
                raise _linear_reconciliation_error(
                    path, "initiative execution digest differs from the entity"
                )
            if (
                executed_entity["updated_at"]
                != initiative_execution["after_updated_at"]
            ):
                raise _linear_reconciliation_error(
                    path, "initiative execution revision differs from the entity"
                )
    elif applied_entity_ids:
        raise _linear_reconciliation_error(path, "proposed state cannot be applied")

    linear_references = tuple(
        item
        for item in references
        if item.reference_kind is AuthorityReferenceKind.LINEAR
    )
    if not linear_references:
        raise _linear_reconciliation_error(
            path, "at least one Linear reference is required"
        )
    for reference in linear_references:
        prefix = "linear:"
        if not reference.source.startswith(prefix):
            raise _linear_reconciliation_error(path, "Linear source locator is invalid")
        entity_id = reference.source[len(prefix) :]
        entity = entities_by_id.get(entity_id)
        if entity is None:
            raise CanonError(
                "CANON_LINEAR_RECONCILIATION_STALE",
                "referenced Linear entity is absent "
                f"reference_id={reference.reference_id}",
                path,
            )
        if entity["updated_at"] != reference.revision:
            raise CanonError(
                "CANON_LINEAR_RECONCILIATION_STALE",
                "reference revision differs from inventory "
                f"reference_id={reference.reference_id}",
                path,
            )
        represented = set(entity["requirement_ids"])
        if not set(reference.requirement_ids) <= represented:
            raise CanonError(
                "CANON_LINEAR_RECONCILIATION_STALE",
                "reference requirements differ from inventory "
                f"reference_id={reference.reference_id}",
                path,
            )
    return LinearReconciliationSnapshot(
        source_bytes=source_bytes,
        input_sha=hashlib.sha256(source_bytes).hexdigest(),
        entity_count=len(entities),
        inventory_counts=dict(sorted(counts.items())),
        action_counts=dict(sorted(actions.items())),
        status_counts=dict(sorted(statuses.items())),
        disposition_state=disposition,
        external_mutations_applied=applied_state,
        owner_gate_required=True,
    )


def load_linear_reconciliation_if_present(
    repo_root: Path,
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> LinearReconciliationSnapshot | None:
    """Load the tracked proposal when present; never treat a link as absence."""

    path = repo_root / _LINEAR_RECONCILIATION
    try:
        os.lstat(path)
    except FileNotFoundError:
        return None
    except OSError as exc:
        raise CanonError(
            "CANON_LINEAR_RECONCILIATION_READ",
            "unable to inspect tracked Linear reconciliation input",
            path,
        ) from exc
    return validate_linear_reconciliation(repo_root, registry, references)


def validate_linear_reconciliation_snapshot(
    repo_root: Path, snapshot: LinearReconciliationSnapshot
) -> None:
    """Reject reconciliation changes after a caller pins its input bytes."""

    path = repo_root / _LINEAR_RECONCILIATION
    try:
        current = _read_regular_nofollow(repo_root, _LINEAR_RECONCILIATION)
    except (OSError, ValueError) as exc:
        raise CanonError(
            "CANON_LINEAR_RECONCILIATION_READ",
            "unable to re-read tracked Linear reconciliation input",
            path,
        ) from exc
    if current != snapshot.source_bytes:
        raise CanonError(
            "CANON_LINEAR_RECONCILIATION_CHANGED",
            "Linear reconciliation changed during deterministic generation",
            path,
        )


def external_reference_findings(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
    repo_root: Path | None = None,
) -> tuple[Finding, ...]:
    """Validate external links while retaining their exact gap direction."""

    effective_root = repo_root or registry.manifest.repository_root
    active_ids = {item.requirement_id for item in registry.requirements}
    findings: list[Finding] = []
    approved_targets: dict[str, list[str]] = {}
    for reference in sorted(references, key=lambda item: item.reference_id):
        gap_class = _external_gap_class(reference.reference_kind)
        for requirement_id in sorted(reference.requirement_ids):
            if requirement_id in registry.superseded_ids:
                findings.append(
                    Finding(
                        code="CANON_EXTERNAL_REQUIREMENT_SUPERSEDED",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            f"{_descriptor(gap_class, requirement_id).serialize()} "
                            f"superseded requirement reference_id={reference.reference_id}"
                        ),
                    )
                )
            elif requirement_id not in active_ids:
                findings.append(
                    Finding(
                        code=_unknown_code(reference.reference_kind),
                        severity=(
                            _descriptor(gap_class, requirement_id).severity
                            if gap_class is not None
                            else GapSeverity.P1_REQUIRED
                        ),
                        message=(
                            f"{_descriptor(gap_class, requirement_id).serialize()} "
                            f"unknown requirement reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.FIGMA:
            if reference.authority_role is None:
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_AUTHORITY_ROLE_REQUIRED",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "visual authority requires a typed authority role "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )
            elif reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET:
                for requirement_id in reference.requirement_ids:
                    approved_targets.setdefault(requirement_id, []).append(
                        reference.reference_id
                    )
            if (
                reference.authority_role is not None
                and not _figma_role_state_valid(
                    reference.authority_role,
                    reference.approval_state,
                    reference.approved_by,
                )
            ):
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_AUTHORITY_STATE_INVALID",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "authority role, approval state, and approver do not form a "
                            f"legal combination reference_id={reference.reference_id}"
                        ),
                    )
                )
            if (
                reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
                and (
                    reference.approval_state != "approved"
                    or not reference.approved_by
                )
            ):
                affected = reference.requirement_ids or (reference.reference_id,)
                findings.append(
                    Finding(
                        code="CANON_FIGMA_OWNER_APPROVAL_REQUIRED",
                        severity=GapSeverity.P1_REQUIRED,
                        message=(
                            f"{GapDescriptor(GapClass.FIGMA_TO_CANON, affected).serialize()} "
                            "visual authority requires explicit owner approval "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.PROOF:
            if not _valid_proof_source(reference.source, effective_root):
                findings.append(
                    Finding(
                        code="CANON_PROOF_SOURCE_INVALID",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "proof source must be repository-confined or use an allowed "
                            f"stable external locator reference_id={reference.reference_id}"
                        ),
                    )
                )

    for requirement_id, reference_ids in sorted(approved_targets.items()):
        if len(reference_ids) > 1:
            descriptor = GapDescriptor(GapClass.FIGMA_TO_CANON, (requirement_id,))
            findings.append(
                Finding(
                    code="CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
                    severity=GapSeverity.P1_REQUIRED,
                    message=(
                        f"{descriptor.serialize()} multiple approved visual targets "
                        f"reference_ids={','.join(sorted(reference_ids))}"
                    ),
                )
            )

    return tuple(
        sorted(
            findings,
            key=lambda item: (item.code, item.message),
        )
    )


def render_visual_authority_manifest(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> dict[str, object]:
    """Project Figma approval posture without claiming implementation readiness."""

    authorities = []
    for reference in sorted(references, key=lambda item: item.reference_id):
        if reference.reference_kind is not AuthorityReferenceKind.FIGMA:
            continue
        approved = (
            reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
            and
            reference.approval_state == "approved"
            and bool(reference.approved_by)
        )
        authorities.append(
            {
                "approval_state": reference.approval_state,
                "approved_by": reference.approved_by,
                "authority_status": "approved" if approved else "non_authoritative",
                "authority_role": (
                    reference.authority_role.value
                    if reference.authority_role is not None
                    else None
                ),
                "implementation_status": reference.implementation_status,
                "reference_id": reference.reference_id,
                "requirement_ids": list(sorted(reference.requirement_ids)),
                "revision": reference.revision,
                "source": reference.source,
            }
        )
    approval_complete = bool(authorities) and all(
        item["authority_status"] == "approved" for item in authorities
    )
    return {
        "schema_version": 1,
        "authority_state": registry.manifest.authority_state.value,
        "canon_revision": registry.manifest.canon_revision,
        "authorities": authorities,
        "owner_approval_complete": approval_complete,
        "ui_readiness": False,
        "ui_readiness_reason": (
            "visual authority references do not prove implementation, accessibility, "
            "device, visual, or release readiness"
        ),
    }


def render_external_reference_impact(
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
    findings: Iterable[Finding],
    metadata: Mapping[str, object],
    *,
    linear_reconciliation: Mapping[str, object] | None = None,
) -> bytes:
    """Render a truthful shadow summary of the loaded external inputs."""

    ordered = tuple(sorted(references, key=lambda item: item.reference_id))
    invalid = tuple(sorted(findings, key=lambda item: (item.code, item.message)))
    counts = {
        kind: sum(item.reference_kind is kind for item in ordered)
        for kind in (
            AuthorityReferenceKind.LINEAR,
            AuthorityReferenceKind.FIGMA,
            AuthorityReferenceKind.PROOF,
        )
    }
    lines = [
        "# Ambitions External Reference Impact",
        "",
        f"- Canon revision: `{registry.manifest.canon_revision}`",
        f"- Authority state: `{registry.manifest.authority_state.value}`",
        f"- Traceability input SHA: `{metadata.get('traceability_input_sha', 'unknown')}`",
        "",
        "**Representation status:** Represented",
        "",
        f"- Stable references: `{len(ordered)}`",
        f"- Linear references: `{counts[AuthorityReferenceKind.LINEAR]}`",
        f"- Figma references: `{counts[AuthorityReferenceKind.FIGMA]}`",
        f"- Proof references: `{counts[AuthorityReferenceKind.PROOF]}`",
        f"- Invalid external findings: `{len(invalid)}`",
    ]
    if linear_reconciliation is None:
        lines.extend(
            (
                "- Linear reconciliation: `not_present`",
                "",
            )
        )
    else:
        lines.extend(
            (
                f"- Linear reconciliation SHA: `{linear_reconciliation['input_sha']}`",
                f"- Reconciliation entities: `{linear_reconciliation['entity_count']}`",
                "- Reconciliation disposition: "
                f"`{linear_reconciliation['disposition_state']}`",
                "- External mutations applied: "
                f"`{str(linear_reconciliation['external_mutations_applied']).lower()}`",
                "- Owner gate required: "
                f"`{str(linear_reconciliation['owner_gate_required']).lower()}`",
            )
        )
        for action, count in sorted(linear_reconciliation["action_counts"].items()):
            lines.append(f"- Reconciliation action `{action}`: `{count}`")
        for status, count in sorted(linear_reconciliation["status_counts"].items()):
            lines.append(f"- Reconciliation status `{status}`: `{count}`")
        lines.append("")
    lines.extend(
        (
            "This stable-link inventory does not prove implementation or readiness; "
            "the reconciliation record is also non-normative shadow input.",
            "",
            "| Reference | Kind | Role | Approval | Requirements |",
            "| --- | --- | --- | --- | --- |",
        )
    )
    for reference in ordered:
        role = reference.authority_role.value if reference.authority_role else "n/a"
        requirements = ", ".join(f"`{item}`" for item in reference.requirement_ids)
        lines.append(
            f"| `{_markdown_cell(reference.reference_id)}` | "
            f"{reference.reference_kind.value} | {role} | "
            f"{reference.approval_state} | {requirements} |"
        )
    if not ordered:
        lines.append("| none | none | none | none | none |")
    return ("\n".join(lines) + "\n").encode("utf-8")


def _load_reference_file_bytes(
    source_bytes: bytes,
    path: Path,
    expected_kind: AuthorityReferenceKind,
) -> tuple[AuthorityReference, ...]:
    try:
        data = tomllib.loads(source_bytes.decode("utf-8"))
    except (UnicodeError, tomllib.TOMLDecodeError) as exc:
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_PARSE",
            "unable to parse external reference TOML",
            path,
        ) from exc
    if not isinstance(data, dict) or set(data) != _TOP_LEVEL_FIELDS:
        raise _schema_error(path, "top-level fields are closed")
    if data.get("schema_version") != 1:
        raise _schema_error(path, "schema_version must be 1")
    if data.get("kind") != expected_kind.value:
        raise _schema_error(path, f"kind must be {expected_kind.value}")
    rows = data.get("references")
    if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
        raise _schema_error(path, "references must be an array of tables")
    authority_class = {
        AuthorityReferenceKind.FIGMA: AuthorityClass.FIGMA,
        AuthorityReferenceKind.LINEAR: AuthorityClass.LINEAR,
        AuthorityReferenceKind.PROOF: AuthorityClass.SOURCE_AND_TESTS,
    }[expected_kind]
    parsed: list[AuthorityReference] = []
    for row in rows:
        assert isinstance(row, dict)
        if not _REFERENCE_REQUIRED <= set(row) or not set(row) <= _REFERENCE_ALLOWED:
            raise _schema_error(path, "reference fields are closed")
        requirement_ids = _string_list(row["requirement_ids"], path, "requirement_ids")
        approval_state = _string(row["approval_state"], path, "approval_state")
        if approval_state not in _APPROVAL_STATES:
            raise _schema_error(path, "approval_state is invalid")
        approved_by = row.get("approved_by")
        if approved_by is not None:
            approved_by = _string(approved_by, path, "approved_by")
        authority_role = None
        if expected_kind is AuthorityReferenceKind.FIGMA:
            if "authority_role" not in row:
                raise _schema_error(path, "Figma reference requires authority_role")
            try:
                authority_role = FigmaAuthorityRole(
                    _string(row["authority_role"], path, "authority_role")
                )
            except ValueError as exc:
                raise _schema_error(path, "authority_role is invalid") from exc
            _validate_figma_role(
                authority_role,
                approval_state,
                approved_by,
                path,
            )
        elif "authority_role" in row:
            raise _schema_error(path, "authority_role is only valid for Figma")
        parsed.append(
            AuthorityReference(
                schema_version=1,
                reference_id=_string(row["reference_id"], path, "reference_id"),
                authority_class=authority_class,
                reference_kind=expected_kind,
                source=_string(row["source"], path, "source"),
                revision=_string(row["revision"], path, "revision"),
                requirement_ids=requirement_ids,
                approval_state=approval_state,
                approved_by=approved_by,
                implementation_status=_string(
                    row["implementation_status"], path, "implementation_status"
                ),
                authority_role=authority_role,
            )
        )
    ordered = tuple(sorted(parsed, key=lambda item: item.reference_id))
    if tuple(item.reference_id for item in ordered) != tuple(
        sorted(set(item.reference_id for item in ordered))
    ):
        raise CanonError(
            "CANON_EXTERNAL_REFERENCE_DUPLICATE",
            "reference IDs must be unique",
            path,
        )
    return ordered


def _valid_proof_source(source: str, repo_root: Path | None) -> bool:
    if source.startswith(_ALLOWED_EXTERNAL_PROOF_PREFIXES):
        return True
    if "://" in source:
        return False
    pure = PurePosixPath(source)
    if pure.is_absolute() or not pure.parts or ".." in pure.parts:
        return False
    if repo_root is None:
        return False
    try:
        _read_regular_nofollow(repo_root, Path(*pure.parts))
    except (OSError, ValueError):
        return False
    return True


def _validate_figma_role(
    role: FigmaAuthorityRole,
    approval_state: str,
    approved_by: str | None,
    path: Path,
) -> None:
    if not _figma_role_state_valid(role, approval_state, approved_by):
        raise _schema_error(
            path,
            "authority_role, approval_state, and approved_by combination is invalid",
        )


def _figma_role_state_valid(
    role: FigmaAuthorityRole,
    approval_state: str,
    approved_by: str | None,
) -> bool:
    return (
        role is FigmaAuthorityRole.APPROVED_TARGET
        and approval_state == "approved"
        and bool(approved_by)
    ) or (
        role is FigmaAuthorityRole.CANDIDATE
        and approval_state == "unreviewed"
        and approved_by is None
    ) or (
        role is FigmaAuthorityRole.SUPERSEDED
        and approval_state == "stale"
        and bool(approved_by)
    )


def _read_regular_nofollow(root: Path, relative_path: Path) -> bytes:
    if relative_path.is_absolute() or not relative_path.parts or ".." in relative_path.parts:
        raise ValueError("path must be repository-relative")
    directory_flags = (
        os.O_RDONLY
        | os.O_DIRECTORY
        | os.O_NOFOLLOW
        | getattr(os, "O_CLOEXEC", 0)
    )
    file_flags = os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
    descriptors: list[int] = []
    try:
        current = os.open(root, directory_flags)
        descriptors.append(current)
        for component in relative_path.parts[:-1]:
            current = os.open(component, directory_flags, dir_fd=current)
            descriptors.append(current)
        descriptor = os.open(relative_path.parts[-1], file_flags, dir_fd=current)
        descriptors.append(descriptor)
        if not stat.S_ISREG(os.fstat(descriptor).st_mode):
            raise OSError("reference input is not a regular file")
        chunks: list[bytes] = []
        while chunk := os.read(descriptor, 64 * 1024):
            chunks.append(chunk)
        return b"".join(chunks)
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def _input_sha(entries: tuple[tuple[Path, bytes], ...]) -> str:
    digest = hashlib.sha256()
    for path, content in entries:
        label = path.as_posix().encode("utf-8")
        digest.update(len(label).to_bytes(8, "big"))
        digest.update(label)
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)
    return digest.hexdigest()


def _external_gap_class(kind: AuthorityReferenceKind) -> GapClass | None:
    return {
        AuthorityReferenceKind.FIGMA: GapClass.FIGMA_TO_CANON,
        AuthorityReferenceKind.LINEAR: GapClass.LINEAR_TO_CANON,
    }.get(kind)


def _descriptor(gap_class: GapClass | None, identifier: str) -> GapDescriptor:
    return GapDescriptor(gap_class or GapClass.CANON_TO_CODE, (identifier,))


def _unknown_code(kind: AuthorityReferenceKind) -> str:
    return {
        AuthorityReferenceKind.FIGMA: "CANON_FIGMA_REQUIREMENT_UNKNOWN",
        AuthorityReferenceKind.LINEAR: "CANON_LINEAR_REQUIREMENT_UNKNOWN",
    }.get(kind, "CANON_EXTERNAL_REQUIREMENT_UNKNOWN")


def _string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _schema_error(path, f"{field} must be a non-empty trimmed string")
    return value


def _string_list(value: object, path: Path, field: str) -> tuple[str, ...]:
    if not isinstance(value, list) or not value:
        raise _schema_error(path, f"{field} must be a non-empty string array")
    values = tuple(_string(item, path, field) for item in value)
    if values != tuple(sorted(set(values))):
        raise _schema_error(path, f"{field} must be sorted and unique")
    return values


def _schema_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_EXTERNAL_REFERENCE_SCHEMA", message, path)


def _linear_reconciliation_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_LINEAR_RECONCILIATION_STATE", message, path)


def _validate_linear_generated_from(value: object, path: Path) -> None:
    if not isinstance(value, dict) or set(value) != {"inventory_date", "method"}:
        raise _linear_reconciliation_error(path, "generated_from fields are closed")
    if value.get("method") != "live_linear_oauth_reads":
        raise _linear_reconciliation_error(path, "generated_from method is invalid")
    _linear_string(value.get("inventory_date"), path, "inventory_date")


def _validate_linear_inventory_scope(value: object, path: Path) -> None:
    fields = {
        "active_related_initiatives",
        "issue_filter",
        "limitations",
        "linked_pilot_projects",
        "pilot_live_entity_type",
        "pilot_named_entity",
        "pilot_plan_label_type",
        "raw_exports_tracked",
    }
    if not isinstance(value, dict) or set(value) != fields:
        raise _linear_reconciliation_error(path, "inventory_scope fields are closed")
    for field in (
        "issue_filter",
        "pilot_live_entity_type",
        "pilot_named_entity",
        "pilot_plan_label_type",
    ):
        _linear_string(value.get(field), path, field)
    for field in (
        "active_related_initiatives",
        "limitations",
        "linked_pilot_projects",
    ):
        _linear_string_array(value.get(field), path, field, allow_empty=True)
    if value.get("raw_exports_tracked") is not False:
        raise _linear_reconciliation_error(path, "raw exports cannot be tracked")


def _validate_linear_action_rules(value: object, path: Path) -> None:
    fields = {
        "all_external_actions",
        "archive_after_extraction",
        "destructive_actions",
    }
    if not isinstance(value, dict) or set(value) != fields:
        raise _linear_reconciliation_error(path, "action_rules fields are closed")
    for field in sorted(fields):
        _linear_string(value.get(field), path, field)
    if value.get("destructive_actions") != (
        "deferred to Gate C and not authorized by this manifest"
    ):
        raise _linear_reconciliation_error(path, "destructive action rule is invalid")


def _validate_linear_pilot_decision(
    value: object, path: Path
) -> Mapping[str, object]:
    fields = {"mismatch", "options", "rationale", "recommended_option"}
    if not isinstance(value, dict) or set(value) != fields:
        raise _linear_reconciliation_error(
            path, "pilot_decision_required fields are closed"
        )
    for field in ("mismatch", "rationale", "recommended_option"):
        _linear_string(value.get(field), path, field)
    options = value.get("options")
    if not isinstance(options, list) or not options:
        raise _linear_reconciliation_error(path, "pilot options must be non-empty")
    option_ids: list[str] = []
    entity_ids: set[str] = set()
    option_entities: dict[str, tuple[str, ...]] = {}
    for option in options:
        if not isinstance(option, dict) or set(option) != {"entity_ids", "option_id"}:
            raise _linear_reconciliation_error(path, "pilot option fields are closed")
        option_id = _linear_string(option.get("option_id"), path, "option_id")
        selected_entities = _linear_string_array(
            option.get("entity_ids"), path, "entity_ids"
        )
        option_ids.append(option_id)
        option_entities[option_id] = selected_entities
        entity_ids.update(selected_entities)
    if len(option_ids) != len(set(option_ids)):
        raise _linear_reconciliation_error(path, "pilot option IDs must be unique")
    if value.get("recommended_option") not in option_ids:
        raise _linear_reconciliation_error(path, "recommended pilot option is unknown")
    recommended = value.get("recommended_option")
    return {
        "entity_ids": tuple(sorted(entity_ids)),
        "recommended_entity_ids": option_entities[recommended],
        "option_entities": option_entities,
    }


def _validate_linear_pilot_execution(
    value: object,
    path: Path,
    pilot_entity_ids: frozenset[str],
) -> None:
    fields = {
        "approval_scope",
        "approved_option",
        "broader_actions",
        "destructive_actions",
        "entity_ids",
        "status",
    }
    if not isinstance(value, dict) or set(value) != fields:
        raise _linear_reconciliation_error(path, "pilot_execution fields are closed")
    if value.get("approved_option") != "bounded-pair":
        raise _linear_reconciliation_error(path, "approved pilot option is invalid")
    if value.get("approval_scope") != "exact_reviewed_bytes_only":
        raise _linear_reconciliation_error(path, "pilot approval scope is invalid")
    if value.get("broader_actions") != "withheld_not_authorized":
        raise _linear_reconciliation_error(path, "broader actions must be withheld")
    if value.get("destructive_actions") != "withheld_gate_c":
        raise _linear_reconciliation_error(path, "destructive actions must be withheld")
    if value.get("status") != "applied_verified":
        raise _linear_reconciliation_error(path, "pilot execution status is invalid")
    entity_ids = frozenset(
        _linear_string_array(value.get("entity_ids"), path, "pilot entity_ids")
    )
    if entity_ids != pilot_entity_ids or len(entity_ids) != 2:
        raise _linear_reconciliation_error(path, "pilot execution IDs are invalid")


def _validate_linear_initiative_execution(
    value: object,
    path: Path,
    option_entities: Mapping[str, tuple[str, ...]],
) -> frozenset[str]:
    fields = {
        "after_bytes",
        "after_canonical_sha256",
        "after_raw_sha256",
        "after_terminal_lf",
        "after_updated_at",
        "approval_authority",
        "approval_review",
        "approved_option",
        "before_bytes",
        "before_canonical_sha256",
        "before_raw_sha256",
        "before_updated_at",
        "broader_actions",
        "destructive_actions",
        "entity_id",
        "status",
        "validation",
    }
    if not isinstance(value, dict) or set(value) != fields:
        raise _linear_reconciliation_error(
            path, "initiative_execution fields are closed"
        )
    if value.get("approved_option") != "initiative-only":
        raise _linear_reconciliation_error(
            path, "initiative execution approval option is invalid"
        )
    if value.get("approval_authority") != (
        "controller_on_owner_behalf_under_tasks_22_29_delegation"
    ):
        raise _linear_reconciliation_error(
            path, "initiative execution approval authority is invalid"
        )
    if value.get("approval_review") != "INITIATIVE_GATE_CLEAN":
        raise _linear_reconciliation_error(
            path, "initiative execution review receipt is invalid"
        )
    if value.get("broader_actions") != "withheld_not_authorized":
        raise _linear_reconciliation_error(path, "broader actions must be withheld")
    if value.get("destructive_actions") != "withheld_gate_c":
        raise _linear_reconciliation_error(path, "destructive actions must be withheld")
    if value.get("status") != "applied_verified":
        raise _linear_reconciliation_error(
            path, "initiative execution status is invalid"
        )
    if value.get("validation") != "dedicated_full_read_exact":
        raise _linear_reconciliation_error(
            path, "initiative execution validation is invalid"
        )
    if value.get("after_terminal_lf") is not False:
        raise _linear_reconciliation_error(
            path, "initiative target terminal LF is invalid"
        )
    if value.get("before_bytes") != 428 or value.get("after_bytes") != 2431:
        raise _linear_reconciliation_error(
            path, "initiative execution byte receipt is invalid"
        )
    for field in (
        "before_raw_sha256",
        "before_canonical_sha256",
        "after_raw_sha256",
        "after_canonical_sha256",
    ):
        digest = value.get(field)
        if not isinstance(digest, str) or len(digest) != 64 or any(
            character not in "0123456789abcdef" for character in digest
        ):
            raise _linear_reconciliation_error(
                path, "initiative execution digest is invalid"
            )
    for field in ("before_updated_at", "after_updated_at"):
        _linear_string(value.get(field), path, field)
    entity_id = _linear_string(value.get("entity_id"), path, "entity_id")
    selected = option_entities.get("initiative-only")
    if selected != (entity_id,):
        raise _linear_reconciliation_error(
            path, "initiative execution entity is outside the initiative-only option"
        )
    return frozenset({entity_id})


def _validate_linear_batches(
    value: object,
    path: Path,
    *,
    applied_state: bool,
    applied_entity_ids: frozenset[str],
) -> Mapping[str, frozenset[str]]:
    if not isinstance(value, list) or not value:
        raise _linear_reconciliation_error(path, "batches must be a non-empty array")
    batch_ids: set[str] = set()
    destructive: dict[str, set[str]] = {
        action: set() for action in _LINEAR_DESTRUCTIVE_ACTIONS
    }
    applied_pilot_batches = 0
    for batch in value:
        if not isinstance(batch, dict):
            raise _linear_reconciliation_error(path, "batch rows must be objects")
        action = _linear_string(batch.get("action"), path, "batch action")
        if action not in _LINEAR_ACTIONS:
            raise _linear_reconciliation_error(path, "batch action is invalid")
        selector_fields = {"entity_ids", "entity_types"} & set(batch)
        expected = set(_LINEAR_BATCH_BASE_FIELDS) | selector_fields
        if action in _LINEAR_DESTRUCTIVE_ACTIONS:
            expected.update(_LINEAR_DESTRUCTIVE_FIELDS)
        if len(selector_fields) != 1 or set(batch) != expected:
            raise _linear_reconciliation_error(path, "batch fields are closed")
        batch_id = _linear_string(batch.get("batch_id"), path, "batch_id")
        if batch_id in batch_ids:
            raise _linear_reconciliation_error(path, "batch IDs must be unique")
        batch_ids.add(batch_id)
        selector = next(iter(selector_fields))
        selected = _linear_string_array(batch.get(selector), path, selector)
        if selector == "entity_types" and not set(selected) <= _LINEAR_ENTITY_TYPES:
            raise _linear_reconciliation_error(path, "batch entity type is invalid")
        if action in _LINEAR_DESTRUCTIVE_ACTIONS:
            if selector != "entity_ids":
                raise _linear_reconciliation_error(
                    path, "destructive batches require explicit entity IDs"
                )
            if batch.get("gate") != "C":
                raise _linear_reconciliation_error(path, "destructive gate must be C")
            if batch.get("destructive_authorization") != "deferred_not_authorized":
                raise _linear_reconciliation_error(
                    path, "destructive authorization must remain deferred"
                )
            _linear_string(
                batch.get("manual_deletion_action"), path, "manual_deletion_action"
            )
            destructive[action].update(selected)
        status = batch.get("status")
        if applied_state:
            selected_ids = frozenset(selected) if selector == "entity_ids" else frozenset()
            if (
                action == "rewrite_to_requirement_references"
                and selected_ids == applied_entity_ids
            ):
                if status != "applied_verified":
                    raise _linear_reconciliation_error(
                        path, "pilot batch must be applied_verified"
                    )
                applied_pilot_batches += 1
            else:
                required_status = (
                    "withheld_gate_c"
                    if action in _LINEAR_DESTRUCTIVE_ACTIONS
                    else "withheld_not_authorized"
                )
                if status != required_status:
                    raise _linear_reconciliation_error(
                        path, "broader batch status is invalid"
                    )
        elif status != "not_applied":
            raise _linear_reconciliation_error(path, "batch status is invalid")
    if applied_state and applied_pilot_batches != 1:
        raise _linear_reconciliation_error(
            path, "mixed state requires one applied pilot batch"
        )
    return {action: frozenset(ids) for action, ids in destructive.items()}


def _linear_string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _linear_reconciliation_error(
            path, f"{field} must be a non-empty trimmed string"
        )
    return value


def _linear_string_array(
    value: object, path: Path, field: str, *, allow_empty: bool = False
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise _linear_reconciliation_error(path, f"{field} must be non-empty")
    values = tuple(_linear_string(item, path, field) for item in value)
    if values != tuple(sorted(set(values))):
        raise _linear_reconciliation_error(path, f"{field} must be sorted and unique")
    return values


def _markdown_cell(value: str) -> str:
    return value.replace("|", "&#124;").replace("`", "&#96;")
