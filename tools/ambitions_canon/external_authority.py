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
_FIGMA_GOVERNANCE_FIELDS = frozenset(
    {
        "accessibility_variants",
        "canon_revision",
        "frame_version",
        "swiftui_plausibility",
        "visual_authority_id",
    }
)
_REFERENCE_ALLOWED = _REFERENCE_REQUIRED | {"approved_by", "authority_role"} | _FIGMA_GOVERNANCE_FIELDS
_REFERENCE_ALLOWED = _REFERENCE_ALLOWED | {"reconciliation_status"}
_APPROVAL_STATES = frozenset({"unreviewed", "approved", "rejected", "stale"})
_ALLOWED_EXTERNAL_PROOF_PREFIXES = (
    "figma:",
    "linear:",
    "linear-comment:",
    "linear-ledger:",
    "https://",
)
_LINEAR_RECONCILIATION = Path("docs/canon/migration/linear-reconciliation.json")
_FIGMA_RECONCILIATION = Path("docs/canon/migration/figma-reconciliation.json")
_FIGMA_EXPECTED_LIVE_FILE_KEYS = (
    "9FhOWjt1KGmDg31rq2XP9e",
    "SWtHm9ouHTPbEFfNrrtZwv",
    "TgKZkoanB1hLaSYbthAIr3",
    "XSpaP7NkB2efoTgSy0KpFq",
    "hnVi8KV2SAuWP3V5hV160W",
    "lDslntJK8Xtmap7paJz7f5",
    "syAY6U5srUCifJgKq0wSSH",
    "tJzwkJCg7piFbb3LGy91vD",
)
_FIGMA_ACTION_ORDER = (
    "retain_authority",
    "merge_unique_visual_content",
    "downgrade_candidate",
    "delete_duplicate_node",
    "delete_duplicate_file",
    "retain_failure_evidence",
    "owner_review",
)
_FIGMA_ROOT_FIELDS = frozenset(
    {
        "allowed_actions",
        "authority_state",
        "canon_revision",
        "disposition_state",
        "external_mutations_applied",
        "expected_live_file_keys",
        "file_inventory",
        "generated_from",
        "inventory_counts",
        "manual_file_deletions",
        "nodes",
        "schema_version",
        "text_repairs",
    }
)
_FIGMA_FILE_FIELDS = frozenset(
    {
        "action_status",
        "authority_claims",
        "duplicate_or_competing_authority",
        "file_key",
        "governed_approved_requirement_ids",
        "inbound_links",
        "linear_issue_ids",
        "pages",
        "recommended_action",
        "unique_visual_content",
    }
)
_FIGMA_PAGE_FIELDS = frozenset(
    {
        "metadata_request_id",
        "original_height",
        "original_width",
        "page_id",
        "page_name",
        "repository_screenshots",
        "root_node_ids",
        "screenshot_request_id",
        "screenshot_sha256",
    }
)
_FIGMA_REPOSITORY_SCREENSHOT_FIELDS = frozenset({"node_id", "path", "sha256"})
_FIGMA_APPROVAL_EVIDENCE_FIELDS = frozenset({"path", "sha256"})
_FIGMA_TEXT_REPAIR_FIELDS = frozenset(
    {"action_status", "after", "before", "rollback", "root_node_id", "text_node_id"}
)
_FIGMA_EXECUTION_FIELDS = frozenset(
    {
        "approval_authority",
        "approval_review",
        "created_node_ids",
        "deleted_node_ids",
        "file_key",
        "metadata_writes",
        "page_id",
        "shared_plugin_namespace",
        "status",
        "text_writes",
    }
)
_FIGMA_METADATA_WRITE_FIELDS = frozenset(
    {
        "after",
        "after_screenshot",
        "before",
        "before_screenshot",
        "created_node_ids",
        "deleted_node_ids",
        "mutated_node_ids",
        "node_id",
        "readback_request_id",
    }
)
_FIGMA_TEXT_WRITE_FIELDS = frozenset(
    {
        "after",
        "after_screenshot",
        "before",
        "before_screenshot",
        "created_node_ids",
        "deleted_node_ids",
        "font_family",
        "font_style",
        "mutated_node_ids",
        "readback_request_id",
        "root_node_id",
        "text_node_id",
    }
)
_FIGMA_SCREENSHOT_RECEIPT_FIELDS = frozenset({"request_id", "sha256"})
_FIGMA_METADATA_KEYS = (
    "accessibility_variants",
    "approved_by",
    "authority_boundary",
    "canon_revision",
    "frame_version",
    "implementation_status",
    "owner_approval_state",
    "requirement_ids",
    "swiftui_plausibility",
    "visual_authority_id",
)
_FIGMA_EXECUTION_FILE_KEY = "SWtHm9ouHTPbEFfNrrtZwv"
_FIGMA_EXECUTION_PAGE_ID = "0:1"
_FIGMA_EXECUTION_APPROVAL_AUTHORITY = (
    "controller_on_owner_behalf_under_tasks_22_29_delegation"
)
_FIGMA_EXECUTION_APPROVAL_REVIEW = "OWNER_GATE_CLEAN"
_FIGMA_AUTHORITY_BOUNDARY = "visual_only_canon_and_source_own_product_law"
_FIGMA_NODE_FIELDS = frozenset(
    {
        "accessibility_variants",
        "action_status",
        "claim_ceiling",
        "duplicate_or_competing_authority",
        "evidence",
        "file_key",
        "frame_label",
        "frame_version",
        "node_id",
        "owner_approval",
        "page_id",
        "page_name",
        "recommended_action",
        "replacement_node_ids",
        "requirement_ids",
        "rollback",
        "swiftui_plausibility",
        "unique_visual_content",
        "visual_authority_id",
    }
)
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


@dataclass(frozen=True, slots=True)
class FigmaReconciliationSnapshot:
    source_bytes: bytes
    input_sha: str
    node_count: int
    action_counts: Mapping[str, int]
    status_counts: Mapping[str, int]
    disposition_state: str
    external_mutations_applied: bool
    owner_gate_required: bool
    actions_by_source: Mapping[str, str]
    expected_live_file_keys: tuple[str, ...]
    file_count: int
    text_repairs: tuple[Mapping[str, str], ...]
    execution_receipt: Mapping[str, object] | None = None

    def summary(self) -> Mapping[str, object]:
        return {
            "action_counts": dict(self.action_counts),
            "disposition_state": self.disposition_state,
            "external_mutations_applied": self.external_mutations_applied,
            "expected_live_file_keys": list(self.expected_live_file_keys),
            "file_count": self.file_count,
            "input_sha": self.input_sha,
            "node_count": self.node_count,
            "owner_gate_required": self.owner_gate_required,
            "status_counts": dict(self.status_counts),
            "text_repairs": [dict(item) for item in self.text_repairs],
            "execution_receipt": (
                dict(self.execution_receipt)
                if self.execution_receipt is not None
                else None
            ),
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


def validate_figma_reconciliation(
    repo_root: Path,
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> FigmaReconciliationSnapshot:
    """Validate the tracked Figma proposal without applying external writes."""

    path = repo_root / _FIGMA_RECONCILIATION
    try:
        source_bytes = _read_regular_nofollow(repo_root, _FIGMA_RECONCILIATION)
        data = json.loads(source_bytes.decode("utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as exc:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_READ",
            "unable to read tracked Figma reconciliation input",
            path,
        ) from exc
    if not isinstance(data, dict):
        raise _figma_reconciliation_error(path, "root must be an object")
    applied = data.get("disposition_state") == "authority_metadata_and_text_applied_verified"
    expected_root_fields = set(_FIGMA_ROOT_FIELDS)
    if applied:
        expected_root_fields.add("execution_receipt")
    if set(data) != expected_root_fields:
        raise _figma_reconciliation_error(path, "top-level fields are closed")
    if data.get("schema_version") != 1:
        raise _figma_reconciliation_error(path, "schema_version must be 1")
    if data.get("canon_revision") != registry.manifest.canon_revision:
        raise _figma_reconciliation_error(path, "canon_revision is stale")
    if data.get("authority_state") != registry.manifest.authority_state.value:
        raise _figma_reconciliation_error(path, "authority_state is stale")
    if data.get("disposition_state") not in {
        "proposed_not_applied_owner_gate",
        "authority_metadata_and_text_applied_verified",
    }:
        raise _figma_reconciliation_error(path, "disposition_state is invalid")
    if data.get("external_mutations_applied") is not applied:
        raise _figma_reconciliation_error(path, "external mutation state is inconsistent")
    if data.get("allowed_actions") != list(_FIGMA_ACTION_ORDER):
        raise _figma_reconciliation_error(path, "allowed_actions is closed or stale")
    expected_file_keys = _figma_string_array(
        data.get("expected_live_file_keys"), path, "expected_live_file_keys"
    )
    if expected_file_keys != _FIGMA_EXPECTED_LIVE_FILE_KEYS:
        raise _figma_reconciliation_error(
            path, "expected_live_file_keys differs from the live Linear VSP set"
        )

    generated = data.get("generated_from")
    if not isinstance(generated, dict) or set(generated) != {
        "figma_file_key",
        "inventory_date",
        "linear_issue_ids",
        "page_id",
        "repo_provenance",
    }:
        raise _figma_reconciliation_error(path, "generated_from fields are closed")
    for field in ("figma_file_key", "inventory_date", "page_id", "repo_provenance"):
        _figma_string(generated.get(field), path, field)
    _figma_string_array(generated.get("linear_issue_ids"), path, "linear_issue_ids")

    manual = data.get("manual_file_deletions")
    if manual != []:
        raise _figma_reconciliation_error(
            path, "whole-file deletion is not authorized in this train"
        )
    active_ids = {item.requirement_id for item in registry.requirements}
    file_inventory = data.get("file_inventory")
    if not isinstance(file_inventory, list) or not file_inventory:
        raise _figma_reconciliation_error(path, "file_inventory must be non-empty")
    file_keys: list[str] = []
    page_count = 0
    governed_by_file: dict[str, set[str]] = {}
    for file_record in file_inventory:
        if not isinstance(file_record, dict) or set(file_record) != _FIGMA_FILE_FIELDS:
            raise _figma_reconciliation_error(path, "file inventory fields are closed")
        file_key = _figma_string(file_record.get("file_key"), path, "file_key")
        file_keys.append(file_key)
        _figma_string_array(
            file_record.get("linear_issue_ids"), path, "linear_issue_ids"
        )
        _figma_string_array(
            file_record.get("authority_claims"), path, "authority_claims"
        )
        governed = _figma_string_array(
            file_record.get("governed_approved_requirement_ids"),
            path,
            "governed_approved_requirement_ids",
            allow_empty=True,
        )
        unknown_governed = set(governed) - active_ids
        if unknown_governed:
            raise CanonError(
                "CANON_FIGMA_RECONCILIATION_REQUIREMENT_UNKNOWN",
                f"unknown governed requirement file_key={file_key}",
                path,
            )
        governed_by_file[file_key] = set(governed)
        _figma_string(file_record.get("unique_visual_content"), path, "unique_visual_content")
        _figma_string(
            file_record.get("duplicate_or_competing_authority"),
            path,
            "duplicate_or_competing_authority",
        )
        _figma_string_array(
            file_record.get("inbound_links"), path, "inbound_links", allow_empty=True
        )
        file_action = _figma_string(
            file_record.get("recommended_action"), path, "recommended_action"
        )
        if file_action not in _FIGMA_ACTION_ORDER:
            raise _figma_reconciliation_error(path, "file action is invalid")
        expected_file_status = (
            "applied_verified"
            if applied and file_key == generated["figma_file_key"]
            else "proposed_not_applied"
        )
        if file_record.get("action_status") != expected_file_status:
            raise _figma_reconciliation_error(path, "file action_status is invalid")
        pages = file_record.get("pages")
        if not isinstance(pages, list) or not pages:
            raise _figma_reconciliation_error(path, "file pages must be non-empty")
        page_ids: list[str] = []
        for page in pages:
            if not isinstance(page, dict) or set(page) != _FIGMA_PAGE_FIELDS:
                raise _figma_reconciliation_error(path, "page fields are closed")
            page_id = _figma_string(page.get("page_id"), path, "page_id")
            page_ids.append(page_id)
            _figma_string(page.get("page_name"), path, "page_name")
            _figma_string_array(
                page.get("root_node_ids"), path, "root_node_ids", allow_empty=True
            )
            for field in (
                "metadata_request_id",
                "screenshot_request_id",
                "screenshot_sha256",
            ):
                _figma_string(page.get(field), path, field)
            _validate_sha256(page["screenshot_sha256"], path, "screenshot_sha256")
            for field in ("original_width", "original_height"):
                if type(page.get(field)) is not int or page[field] < 0:
                    raise _figma_reconciliation_error(path, f"{field} is invalid")
            repository_screenshots = page.get("repository_screenshots")
            if not isinstance(repository_screenshots, list):
                raise _figma_reconciliation_error(
                    path, "repository_screenshots must be an array"
                )
            for screenshot in repository_screenshots:
                if (
                    not isinstance(screenshot, dict)
                    or set(screenshot) != _FIGMA_REPOSITORY_SCREENSHOT_FIELDS
                ):
                    raise _figma_reconciliation_error(
                        path, "repository screenshot fields are closed"
                    )
                screenshot_path = _figma_string(
                    screenshot.get("path"), path, "repository screenshot path"
                )
                _figma_string(screenshot.get("node_id"), path, "repository node_id")
                expected_sha = _figma_string(
                    screenshot.get("sha256"), path, "repository screenshot sha256"
                )
                _validate_sha256(expected_sha, path, "repository screenshot sha256")
                actual_bytes = _read_repo_evidence(repo_root, screenshot_path, path)
                if hashlib.sha256(actual_bytes).hexdigest() != expected_sha:
                    raise _figma_reconciliation_error(
                        path, "repository screenshot digest is stale"
                    )
        if page_ids != sorted(set(page_ids)):
            raise _figma_reconciliation_error(path, "page IDs must be sorted and unique")
        page_count += len(pages)
    if tuple(file_keys) != expected_file_keys:
        raise _figma_reconciliation_error(
            path, "file inventory must exactly match expected live file keys in order"
        )
    nodes = data.get("nodes")
    if not isinstance(nodes, list) or not nodes:
        raise _figma_reconciliation_error(path, "nodes must be a non-empty array")
    figma_references = {
        item.source: item
        for item in references
        if item.reference_kind is AuthorityReferenceKind.FIGMA
    }
    approved_requirements_by_file: dict[str, set[str]] = {
        file_key: set() for file_key in expected_file_keys
    }
    for reference in figma_references.values():
        if reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET:
            parts = reference.source.split(":", 2)
            if len(parts) != 3 or parts[1] not in approved_requirements_by_file:
                raise CanonError(
                    "CANON_FIGMA_RECONCILIATION_STALE",
                    f"approved reference uses an uninventoried file reference_id={reference.reference_id}",
                    path,
                )
            approved_requirements_by_file[parts[1]].update(reference.requirement_ids)
    governed_owners: dict[str, list[str]] = {}
    for file_key, requirement_ids in governed_by_file.items():
        for requirement_id in requirement_ids:
            governed_owners.setdefault(requirement_id, []).append(file_key)
    duplicates = {
        requirement_id: owners
        for requirement_id, owners in governed_owners.items()
        if len(owners) > 1
    }
    if duplicates:
        raise CanonError(
            "CANON_FIGMA_MULTIPLE_APPROVED_TARGETS",
            "multiple governed approved files own one requirement",
            path,
        )
    if governed_by_file != approved_requirements_by_file:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_STALE",
            "governed approved ownership differs from tracked Figma references",
            path,
        )

    raw_text_repairs = data.get("text_repairs")
    if not isinstance(raw_text_repairs, list) or not raw_text_repairs:
        raise _figma_reconciliation_error(path, "text_repairs must be non-empty")
    text_repairs: list[Mapping[str, str]] = []
    text_ids: list[str] = []
    for repair in raw_text_repairs:
        if not isinstance(repair, dict) or set(repair) != _FIGMA_TEXT_REPAIR_FIELDS:
            raise _figma_reconciliation_error(path, "text repair fields are closed")
        values = {
            field: _figma_string(repair.get(field), path, field)
            for field in (
                "root_node_id",
                "text_node_id",
                "before",
                "after",
                "rollback",
                "action_status",
            )
        }
        if values["before"] == values["after"]:
            raise _figma_reconciliation_error(path, "text repair must change content")
        expected_text_status = "applied_verified" if applied else "proposed_not_applied"
        if values["action_status"] != expected_text_status:
            raise _figma_reconciliation_error(path, "text repair status is invalid")
        text_ids.append(values["text_node_id"])
        text_repairs.append(values)
    if text_ids != sorted(set(text_ids)):
        raise _figma_reconciliation_error(path, "text repair IDs must be sorted and unique")
    seen: set[str] = set()
    retained_sources: set[str] = set()
    actions: Counter[str] = Counter()
    statuses: Counter[str] = Counter()
    actions_by_source: dict[str, str] = {}
    for node in nodes:
        if not isinstance(node, dict) or set(node) != _FIGMA_NODE_FIELDS:
            raise _figma_reconciliation_error(path, "node fields are closed")
        file_key = _figma_string(node.get("file_key"), path, "file_key")
        node_id = _figma_string(node.get("node_id"), path, "node_id")
        source = f"figma:{file_key}:{node_id}"
        if source in seen:
            raise _figma_reconciliation_error(path, "node locators must be unique")
        seen.add(source)
        for field in (
            "visual_authority_id",
            "page_id",
            "page_name",
            "frame_label",
            "frame_version",
            "duplicate_or_competing_authority",
            "unique_visual_content",
            "swiftui_plausibility",
            "rollback",
            "claim_ceiling",
        ):
            _figma_string(node.get(field), path, field)
        requirement_ids = _figma_string_array(
            node.get("requirement_ids"), path, "requirement_ids", allow_empty=True
        )
        unknown = set(requirement_ids) - active_ids
        if unknown:
            raise CanonError(
                "CANON_FIGMA_RECONCILIATION_REQUIREMENT_UNKNOWN",
                f"unknown requirement node={node_id}",
                path,
            )
        accessibility = _figma_string_array(
            node.get("accessibility_variants"),
            path,
            "accessibility_variants",
            allow_empty=True,
        )
        replacements = _figma_string_array(
            node.get("replacement_node_ids"),
            path,
            "replacement_node_ids",
            allow_empty=True,
        )
        action = _figma_string(node.get("recommended_action"), path, "recommended_action")
        if action not in _FIGMA_ACTION_ORDER:
            raise _figma_reconciliation_error(path, "recommended_action is invalid")
        status = node.get("action_status")
        expected_node_status = (
            "applied_verified"
            if applied and action == "retain_authority"
            else "proposed_not_applied"
        )
        if status != expected_node_status:
            raise _figma_reconciliation_error(path, "action_status is invalid")
        owner = node.get("owner_approval")
        if not isinstance(owner, dict) or set(owner) != {"approved_by", "evidence", "state"}:
            raise _figma_reconciliation_error(path, "owner_approval fields are closed")
        state = _figma_string(owner.get("state"), path, "owner_approval.state")
        approved_by = owner.get("approved_by")
        if approved_by is not None:
            approved_by = _figma_string(approved_by, path, "owner_approval.approved_by")
        raw_owner_evidence = owner.get("evidence")
        if not isinstance(raw_owner_evidence, list):
            raise _figma_reconciliation_error(
                path, "owner_approval.evidence must be an array"
            )
        owner_evidence_paths: list[str] = []
        for binding in raw_owner_evidence:
            if (
                not isinstance(binding, dict)
                or set(binding) != _FIGMA_APPROVAL_EVIDENCE_FIELDS
            ):
                raise _figma_reconciliation_error(
                    path, "owner approval evidence fields are closed"
                )
            evidence_path = _figma_string(
                binding.get("path"), path, "owner_approval.evidence.path"
            )
            expected_digest = _figma_string(
                binding.get("sha256"), path, "owner_approval.evidence.sha256"
            )
            _validate_sha256(
                expected_digest, path, "owner_approval.evidence.sha256"
            )
            evidence_bytes = _read_repo_evidence(repo_root, evidence_path, path)
            if hashlib.sha256(evidence_bytes).hexdigest() != expected_digest:
                raise _figma_reconciliation_error(
                    path, "owner approval evidence digest is stale"
                )
            owner_evidence_paths.append(evidence_path)
        if owner_evidence_paths != sorted(set(owner_evidence_paths)):
            raise _figma_reconciliation_error(
                path, "owner approval evidence paths must be sorted and unique"
            )
        if state == "approved" and (not approved_by or not owner_evidence_paths):
            raise _figma_reconciliation_error(path, "approved node requires owner evidence")
        evidence = node.get("evidence")
        if not isinstance(evidence, dict) or set(evidence) != {
            "metadata_request_id",
            "original_height",
            "original_width",
            "repository_paths",
            "screenshot_request_id",
            "screenshot_sha256",
        }:
            raise _figma_reconciliation_error(path, "evidence fields are closed")
        for field in ("metadata_request_id", "screenshot_request_id", "screenshot_sha256"):
            _figma_string(evidence.get(field), path, field)
        digest = evidence["screenshot_sha256"]
        if len(digest) != 64 or any(ch not in "0123456789abcdef" for ch in digest):
            raise _figma_reconciliation_error(path, "screenshot_sha256 is invalid")
        for field in ("original_width", "original_height"):
            if type(evidence.get(field)) is not int or evidence[field] < 1:
                raise _figma_reconciliation_error(path, f"{field} is invalid")
        _figma_string_array(
            evidence.get("repository_paths"), path, "repository_paths", allow_empty=True
        )
        if action == "retain_authority":
            reference = figma_references.get(source)
            if reference is None or reference.authority_role is not FigmaAuthorityRole.APPROVED_TARGET:
                raise _figma_reconciliation_error(path, "retained authority lacks approved reference")
            if (
                reference.visual_authority_id != node["visual_authority_id"]
                or reference.frame_version != node["frame_version"]
                or reference.canon_revision != registry.manifest.canon_revision
                or set(reference.requirement_ids) != set(requirement_ids)
                or tuple(reference.accessibility_variants) != accessibility
                or reference.swiftui_plausibility != node["swiftui_plausibility"]
                or reference.approval_state != "approved"
                or state != reference.approval_state
                or reference.approved_by != approved_by
            ):
                raise CanonError(
                    "CANON_FIGMA_RECONCILIATION_STALE",
                    f"retained authority differs from reference node={node_id}",
                    path,
                )
            retained_sources.add(source)
        if action in {"delete_duplicate_node", "delete_duplicate_file"} and not replacements:
            raise _figma_reconciliation_error(path, "destructive action requires replacement")
        actions[action] += 1
        statuses[status] += 1
        actions_by_source[source] = action

    expected_retained = {
        source
        for source, reference in figma_references.items()
        if reference.authority_role is FigmaAuthorityRole.APPROVED_TARGET
    }
    if retained_sources != expected_retained:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_STALE",
            "retained authority set differs from approved references",
            path,
        )
    counts = data.get("inventory_counts")
    expected_counts = {
        "files": len(file_inventory),
        "nodes": len(nodes),
        "pages": page_count,
        "retained_authorities": len(retained_sources),
    }
    if counts != expected_counts:
        raise _figma_reconciliation_error(path, "inventory_counts is stale")
    execution_receipt = None
    if applied:
        execution_receipt = _validate_figma_execution_receipt(
            data.get("execution_receipt"),
            path,
            nodes,
            text_repairs,
            registry.manifest.canon_revision,
            figma_references,
        )
    return FigmaReconciliationSnapshot(
        source_bytes=source_bytes,
        input_sha=hashlib.sha256(source_bytes).hexdigest(),
        node_count=len(nodes),
        action_counts=dict(sorted(actions.items())),
        status_counts=dict(sorted(statuses.items())),
        disposition_state=data["disposition_state"],
        external_mutations_applied=applied,
        owner_gate_required=not applied,
        actions_by_source=dict(sorted(actions_by_source.items())),
        expected_live_file_keys=expected_file_keys,
        file_count=len(file_inventory),
        text_repairs=tuple(text_repairs),
        execution_receipt=execution_receipt,
    )


def _validate_figma_execution_receipt(
    raw: object,
    path: Path,
    nodes: list[object],
    text_repairs: list[Mapping[str, str]],
    canon_revision: int,
    figma_references: Mapping[str, AuthorityReference],
) -> Mapping[str, object]:
    if not isinstance(raw, dict) or set(raw) != _FIGMA_EXECUTION_FIELDS:
        raise _figma_reconciliation_error(path, "execution receipt fields are closed")
    for field in (
        "approval_authority",
        "approval_review",
        "file_key",
        "page_id",
        "shared_plugin_namespace",
        "status",
    ):
        _figma_string(raw.get(field), path, field)
    expected_envelope = {
        "approval_authority": _FIGMA_EXECUTION_APPROVAL_AUTHORITY,
        "approval_review": _FIGMA_EXECUTION_APPROVAL_REVIEW,
        "file_key": _FIGMA_EXECUTION_FILE_KEY,
        "page_id": _FIGMA_EXECUTION_PAGE_ID,
        "status": "applied_verified",
    }
    for field, expected in expected_envelope.items():
        if raw[field] != expected:
            raise _figma_reconciliation_error(
                path, f"execution receipt {field} is invalid"
            )
    if raw["shared_plugin_namespace"] != "ambitions.canon":
        raise _figma_reconciliation_error(path, "shared plugin namespace is invalid")
    if raw["deleted_node_ids"] != [] or raw["created_node_ids"] != []:
        raise _figma_reconciliation_error(path, "execution receipt must record no structural mutation")

    applied_node_ids = [
        node["node_id"]
        for node in nodes
        if isinstance(node, dict) and node.get("action_status") == "applied_verified"
    ]
    applied_nodes_by_id = {
        node["node_id"]: node
        for node in nodes
        if isinstance(node, dict) and node.get("action_status") == "applied_verified"
    }
    writes = raw.get("metadata_writes")
    if not isinstance(writes, list) or [item.get("node_id") for item in writes if isinstance(item, dict)] != applied_node_ids:
        raise _figma_reconciliation_error(path, "metadata receipts must match applied nodes")
    for item in writes:
        if not isinstance(item, dict) or set(item) != _FIGMA_METADATA_WRITE_FIELDS:
            raise _figma_reconciliation_error(path, "metadata receipt fields are closed")
        node_id = _figma_string(item.get("node_id"), path, "node_id")
        if item.get("mutated_node_ids") != [node_id]:
            raise _figma_reconciliation_error(path, "metadata mutated IDs are invalid")
        if item.get("deleted_node_ids") != [] or item.get("created_node_ids") != []:
            raise _figma_reconciliation_error(path, "metadata receipt records structural mutation")
        _figma_string(item.get("readback_request_id"), path, "readback_request_id")
        before = item.get("before")
        after = item.get("after")
        if (
            not isinstance(before, dict)
            or not isinstance(after, dict)
            or tuple(sorted(before)) != _FIGMA_METADATA_KEYS
            or tuple(sorted(after)) != _FIGMA_METADATA_KEYS
            or any(value != "" for value in before.values())
        ):
            raise _figma_reconciliation_error(path, "metadata before/after values are invalid")
        for value in after.values():
            _figma_string(value, path, "metadata after value")
        node = applied_nodes_by_id[node_id]
        if (
            node.get("file_key") != _FIGMA_EXECUTION_FILE_KEY
            or node.get("page_id") != _FIGMA_EXECUTION_PAGE_ID
        ):
            raise _figma_reconciliation_error(
                path, "applied metadata node is outside the execution target"
            )
        source = f"figma:{node['file_key']}:{node_id}"
        reference = figma_references.get(source)
        if reference is None:
            raise _figma_reconciliation_error(
                path, "applied metadata node lacks a canonical Figma reference"
            )
        if reference.reconciliation_status != "applied_verified":
            raise _figma_reconciliation_error(
                path, "applied metadata reference status is inconsistent"
            )
        expected_after = {
            "accessibility_variants": json.dumps(
                list(reference.accessibility_variants),
                ensure_ascii=False,
                separators=(",", ":"),
            ),
            "approved_by": node["owner_approval"]["approved_by"],
            "authority_boundary": _FIGMA_AUTHORITY_BOUNDARY,
            "canon_revision": str(canon_revision),
            "frame_version": reference.frame_version,
            "implementation_status": reference.implementation_status,
            "owner_approval_state": reference.approval_state,
            "requirement_ids": json.dumps(
                sorted(reference.requirement_ids),
                ensure_ascii=False,
                separators=(",", ":"),
            ),
            "swiftui_plausibility": reference.swiftui_plausibility,
            "visual_authority_id": reference.visual_authority_id,
        }
        if after != expected_after:
            raise _figma_reconciliation_error(
                path, f"metadata receipt differs from governed authority node={node_id}"
            )
        _validate_figma_screenshot_receipt(item.get("before_screenshot"), path)
        _validate_figma_screenshot_receipt(item.get("after_screenshot"), path)
        if item["before_screenshot"]["sha256"] != item["after_screenshot"]["sha256"]:
            raise _figma_reconciliation_error(path, "metadata-only screenshot changed")

    text_writes = raw.get("text_writes")
    if not isinstance(text_writes, list) or len(text_writes) != len(text_repairs):
        raise _figma_reconciliation_error(path, "text receipts must match text repairs")
    repair_by_id = {item["text_node_id"]: item for item in text_repairs}
    if [item.get("text_node_id") for item in text_writes if isinstance(item, dict)] != list(repair_by_id):
        raise _figma_reconciliation_error(path, "text receipt IDs are invalid")
    metadata_by_root = {item["node_id"]: item for item in writes}
    text_screenshots_by_root: dict[str, Mapping[str, str]] = {}
    for item in text_writes:
        if not isinstance(item, dict) or set(item) != _FIGMA_TEXT_WRITE_FIELDS:
            raise _figma_reconciliation_error(path, "text receipt fields are closed")
        text_node_id = _figma_string(item.get("text_node_id"), path, "text_node_id")
        repair = repair_by_id[text_node_id]
        if item.get("root_node_id") != repair["root_node_id"]:
            raise _figma_reconciliation_error(path, "text receipt root is stale")
        root_node_id = item["root_node_id"]
        metadata_receipt = metadata_by_root.get(root_node_id)
        if metadata_receipt is None:
            raise _figma_reconciliation_error(
                path, "text receipt root lacks applied metadata"
            )
        if item.get("before") != repair["before"] or item.get("after") != repair["after"]:
            raise _figma_reconciliation_error(path, "text receipt content is stale")
        if item.get("mutated_node_ids") != [text_node_id]:
            raise _figma_reconciliation_error(path, "text mutated IDs are invalid")
        if item.get("deleted_node_ids") != [] or item.get("created_node_ids") != []:
            raise _figma_reconciliation_error(path, "text receipt records structural mutation")
        for field in ("font_family", "font_style", "readback_request_id"):
            _figma_string(item.get(field), path, field)
        _validate_figma_screenshot_receipt(item.get("before_screenshot"), path)
        _validate_figma_screenshot_receipt(item.get("after_screenshot"), path)
        if item["before_screenshot"] != metadata_receipt["before_screenshot"]:
            raise _figma_reconciliation_error(
                path, "text receipt before screenshot is not bound to its root"
            )
        prior_after = text_screenshots_by_root.setdefault(
            root_node_id, item["after_screenshot"]
        )
        if item["after_screenshot"] != prior_after:
            raise _figma_reconciliation_error(
                path, "text receipt after screenshots disagree for one root"
            )
    return raw


def _validate_figma_screenshot_receipt(raw: object, path: Path) -> None:
    if not isinstance(raw, dict) or set(raw) != _FIGMA_SCREENSHOT_RECEIPT_FIELDS:
        raise _figma_reconciliation_error(path, "screenshot receipt fields are closed")
    _figma_string(raw.get("request_id"), path, "screenshot request_id")
    digest = _figma_string(raw.get("sha256"), path, "screenshot sha256")
    _validate_sha256(digest, path, "screenshot sha256")


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


def load_figma_reconciliation_if_present(
    repo_root: Path,
    registry: CanonRegistry,
    references: Iterable[AuthorityReference],
) -> FigmaReconciliationSnapshot | None:
    """Load the tracked Figma proposal when present without following links."""

    path = repo_root / _FIGMA_RECONCILIATION
    try:
        os.lstat(path)
    except FileNotFoundError:
        return None
    except OSError as exc:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_READ",
            "unable to inspect tracked Figma reconciliation input",
            path,
        ) from exc
    return validate_figma_reconciliation(repo_root, registry, references)


def validate_figma_reconciliation_snapshot(
    repo_root: Path, snapshot: FigmaReconciliationSnapshot
) -> None:
    """Reject Figma proposal changes after a caller pins its input bytes."""

    path = repo_root / _FIGMA_RECONCILIATION
    try:
        current = _read_regular_nofollow(repo_root, _FIGMA_RECONCILIATION)
    except (OSError, ValueError) as exc:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_READ",
            "unable to re-read tracked Figma reconciliation input",
            path,
        ) from exc
    if current != snapshot.source_bytes:
        raise CanonError(
            "CANON_FIGMA_RECONCILIATION_CHANGED",
            "Figma reconciliation changed during deterministic generation",
            path,
        )


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

        if reference.reference_kind in {
            AuthorityReferenceKind.TEST,
            AuthorityReferenceKind.PROOF,
        }:
            if reference.approval_state != "approved":
                findings.append(
                    Finding(
                        code="CANON_EVIDENCE_APPROVAL_REQUIRED",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "current test/proof evidence requires explicit approval "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )
            if (
                not isinstance(reference.approved_by, str)
                or not reference.approved_by.strip()
            ):
                findings.append(
                    Finding(
                        code="CANON_EVIDENCE_APPROVER_REQUIRED",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "current test/proof evidence requires a non-empty "
                            "attributable approver "
                            f"reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.TEST:
            content = _local_evidence_bytes(reference.source, effective_root)
            if content is None:
                findings.append(
                    Finding(
                        code="CANON_TEST_SOURCE_INVALID",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "test source must be a repository-confined real regular "
                            f"non-symlink file reference_id={reference.reference_id}"
                        ),
                    )
                )
            elif hashlib.sha256(content).hexdigest() != reference.revision:
                findings.append(
                    Finding(
                        code="CANON_EVIDENCE_REVISION_STALE",
                        severity=GapSeverity.P0_BLOCKER,
                        message=(
                            "local test/proof revision must equal the SHA-256 of current "
                            f"bytes reference_id={reference.reference_id}"
                        ),
                    )
                )

        if reference.reference_kind is AuthorityReferenceKind.PROOF:
            if reference.source.startswith(_ALLOWED_EXTERNAL_PROOF_PREFIXES):
                pass
            else:
                content = _local_evidence_bytes(reference.source, effective_root)
                if content is None:
                    findings.append(
                        Finding(
                            code="CANON_PROOF_SOURCE_INVALID",
                            severity=GapSeverity.P0_BLOCKER,
                            message=(
                                "proof source must be repository-confined or use an allowed "
                                "stable external locator "
                                f"reference_id={reference.reference_id}"
                            ),
                        )
                    )
                elif hashlib.sha256(content).hexdigest() != reference.revision:
                    findings.append(
                        Finding(
                            code="CANON_EVIDENCE_REVISION_STALE",
                            severity=GapSeverity.P0_BLOCKER,
                            message=(
                                "local test/proof revision must equal the SHA-256 of current "
                                f"bytes reference_id={reference.reference_id}"
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
    *,
    figma_reconciliation: FigmaReconciliationSnapshot | None = None,
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
                "reconciliation_action": (
                    figma_reconciliation.actions_by_source.get(reference.source)
                    if figma_reconciliation is not None
                    else None
                ),
                "reconciliation_status": reference.reconciliation_status,
                "implementation_status": reference.implementation_status,
                "accessibility_variants": list(reference.accessibility_variants),
                "canon_revision": reference.canon_revision,
                "frame_version": reference.frame_version,
                "reference_id": reference.reference_id,
                "requirement_ids": list(sorted(reference.requirement_ids)),
                "revision": reference.revision,
                "source": reference.source,
                "swiftui_plausibility": reference.swiftui_plausibility,
                "visual_authority_id": reference.visual_authority_id,
            }
        )
    approved_targets = tuple(
        item
        for item in authorities
        if item["authority_role"] == FigmaAuthorityRole.APPROVED_TARGET.value
    )
    approval_complete = bool(approved_targets) and all(
        item["authority_status"] == "approved" for item in approved_targets
    )
    rendered = {
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
    if figma_reconciliation is not None:
        rendered["reconciliation"] = dict(figma_reconciliation.summary())
    return rendered


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
        if expected_kind is AuthorityReferenceKind.FIGMA:
            present_governance_fields = set(row) & _FIGMA_GOVERNANCE_FIELDS
            if present_governance_fields and not _FIGMA_GOVERNANCE_FIELDS <= set(row):
                raise _schema_error(path, "Figma governance fields are all-or-none")
        elif set(row) & _FIGMA_GOVERNANCE_FIELDS:
            raise _schema_error(path, "Figma governance fields are only valid for Figma")
        requirement_ids = _string_list(row["requirement_ids"], path, "requirement_ids")
        approval_state = _string(row["approval_state"], path, "approval_state")
        if approval_state not in _APPROVAL_STATES:
            raise _schema_error(path, "approval_state is invalid")
        approved_by = row.get("approved_by")
        if approved_by is not None:
            approved_by = _string(approved_by, path, "approved_by")
        authority_role = None
        visual_authority_id = None
        canon_revision = None
        frame_version = None
        swiftui_plausibility = None
        accessibility_variants: tuple[str, ...] = ()
        reconciliation_status = None
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
            if _FIGMA_GOVERNANCE_FIELDS <= set(row):
                visual_authority_id = _string(
                    row["visual_authority_id"], path, "visual_authority_id"
                )
                if not visual_authority_id.startswith("VSP-"):
                    raise _schema_error(path, "visual_authority_id is invalid")
                raw_canon_revision = row["canon_revision"]
                if type(raw_canon_revision) is not int or raw_canon_revision < 1:
                    raise _schema_error(path, "canon_revision must be a positive integer")
                canon_revision = raw_canon_revision
                frame_version = _string(row["frame_version"], path, "frame_version")
                swiftui_plausibility = _string(
                    row["swiftui_plausibility"], path, "swiftui_plausibility"
                )
                if swiftui_plausibility not in {
                    "plausible_unverified",
                    "not_assessed",
                    "implausible",
                }:
                    raise _schema_error(path, "swiftui_plausibility is invalid")
                accessibility_variants = _string_list(
                    row["accessibility_variants"], path, "accessibility_variants"
                )
            if "reconciliation_status" in row:
                reconciliation_status = _string(
                    row["reconciliation_status"], path, "reconciliation_status"
                )
                if reconciliation_status not in {
                    "applied_verified",
                    "proposed_not_applied",
                }:
                    raise _schema_error(path, "reconciliation_status is invalid")
        elif "authority_role" in row:
            raise _schema_error(path, "authority_role is only valid for Figma")
        elif "reconciliation_status" in row:
            raise _schema_error(path, "reconciliation_status is only valid for Figma")
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
                visual_authority_id=visual_authority_id,
                canon_revision=canon_revision,
                frame_version=frame_version,
                swiftui_plausibility=swiftui_plausibility,
                accessibility_variants=accessibility_variants,
                reconciliation_status=reconciliation_status,
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


def _local_evidence_bytes(source: str, repo_root: Path | None) -> bytes | None:
    """Read one repository-confined evidence file without following links."""

    if "://" in source or repo_root is None:
        return None
    pure = PurePosixPath(source)
    if pure.is_absolute() or not pure.parts or ".." in pure.parts:
        return None
    try:
        return _read_regular_nofollow(repo_root, Path(*pure.parts))
    except (OSError, ValueError):
        return None


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


def _figma_reconciliation_error(path: Path, message: str) -> CanonError:
    return CanonError("CANON_FIGMA_RECONCILIATION_STATE", message, path)


def _figma_string(value: object, path: Path, field: str) -> str:
    if not isinstance(value, str) or not value or value != value.strip():
        raise _figma_reconciliation_error(
            path, f"{field} must be a non-empty trimmed string"
        )
    return value


def _figma_string_array(
    value: object, path: Path, field: str, *, allow_empty: bool = False
) -> tuple[str, ...]:
    if not isinstance(value, list) or (not value and not allow_empty):
        raise _figma_reconciliation_error(path, f"{field} must be non-empty")
    values = tuple(_figma_string(item, path, field) for item in value)
    if values != tuple(sorted(set(values))):
        raise _figma_reconciliation_error(path, f"{field} must be sorted and unique")
    return values


def _validate_sha256(value: object, path: Path, field: str) -> None:
    if (
        not isinstance(value, str)
        or len(value) != 64
        or any(character not in "0123456789abcdef" for character in value)
    ):
        raise _figma_reconciliation_error(path, f"{field} is invalid")


def _read_repo_evidence(repo_root: Path, value: str, path: Path) -> bytes:
    pure = PurePosixPath(value)
    if pure.is_absolute() or not pure.parts or ".." in pure.parts:
        raise _figma_reconciliation_error(path, "repository evidence path is invalid")
    try:
        return _read_regular_nofollow(repo_root, Path(*pure.parts))
    except (OSError, ValueError) as exc:
        raise _figma_reconciliation_error(
            path, f"repository evidence is missing or unsafe path={value}"
        ) from exc


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
