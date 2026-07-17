"""Deterministic validation and task selection for visual-authority rebaseline."""

from __future__ import annotations

import hashlib
import json
import os
import stat
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping, Sequence

from tools.ambitions_canon.model import CanonError, StateCommandActivationPosture
from tools.ambitions_canon.build import (
    _AuditedCanonSnapshot,
    _read_confined_bytes,
)
from tools.ambitions_canon.ux_blueprint import (
    _ACTIVE_OPERATION,
    _captured_input_bytes,
    UXBlueprintError,
    _freeze_mapping,
    _load_state_command_contracts,
    _ux_operation,
    _validate_ux_blueprint,
    _read_projection_output_locked,
    load_state_command_contracts,
    load_state_inventory,
    load_ux_blueprint,
    validate_ux_blueprint,
)


MANIFEST_PATH = Path("docs/canon/migration/visual-authority-rebaseline.json")
SCHEMA_PATH = Path("docs/canon/schemas/visual-authority-rebaseline.schema.json")
R1_NODE_SNAPSHOT_PATH = Path(
    "docs/canon/migration/visual-authority-r1-node-snapshot.json"
)
REQUIREMENT_DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
SEARCH_GAP_BLOCKED_STATE_IDS = frozenset(
    {
        "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED",
        "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED",
        "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED",
        "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED",
        "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK",
        "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF",
        "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER",
        "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS",
    }
)
SEARCH_ASK_COMMAND_REQUIREMENT_ID = (
    "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
)
SEARCH_ASK_ACTIVATION_GATE_REQUIREMENT_ID = (
    "SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"
)
_SHA256 = frozenset("0123456789abcdef")
_TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "authority_state",
        "phase",
        "status",
        "canon",
        "repository",
        "presentation_matrix",
        "figma",
        "coverage",
        "state_posture",
        "gate_b",
        "legacy",
        "screenshots",
        "legacy_before_screenshots",
        "rollback",
        "claim_ceiling",
        "candidate_proofs",
    }
)
_CANON_FIELDS = frozenset({"revision", "source_sha", "content_sha"})
_FIGMA_FIELDS = frozenset(
    {
        "file_key",
        "additive_page_ids",
        "phase3_root_node_ids",
        "reconciliation_root_node_id",
        "authority_nodes",
    }
)
_COVERAGE_FIELDS = frozenset(
    {
        "visual_requirement_count",
        "visual_requirement_ids",
        "additional_mapped_requirement_ids",
        "screen_count",
        "object_count",
        "journey_count",
        "cross_cutting_count",
        "sensitive_exposure_channel_count",
        "state_count",
    }
)
_STATE_FIELDS = frozenset(
    {"eligible_state_ids", "future_state_ids", "gap_blocked_state_ids"}
)
_GATE_FIELDS = frozenset(
    {
        "state",
        "task_pack_selection",
        "blocked_state_handling",
        "independent_semantic_review",
        "independent_visual_review",
        "rollback_proven",
    }
)
_LEGACY_FIELDS = frozenset(
    {
        "file_key",
        "prior_reconciliation_path",
        "prior_reconciliation_sha256",
        "nodes",
        "destructive_actions",
        "legacy_visual_bytes_changed",
        "proposed_future_destruction_targets",
    }
)
_AUTHORITY_NODE_FIELDS = frozenset(
    {
        "accessibility_variants",
        "blueprint_id",
        "canon_content_sha",
        "canon_revision",
        "canon_source_sha",
        "frame_version",
        "implementation_status",
        "kind",
        "metadata_provenance",
        "name",
        "node_id",
        "owner_approval_state",
        "page_id",
        "page_name",
        "proof_ceiling",
        "requirement_ids",
        "swiftui_plausibility",
        "task_pack_eligible",
        "visual_authority_id",
    }
)
_SCREEN_NODE_FIELDS = _AUTHORITY_NODE_FIELDS | frozenset(
    {
        "state_variant_ids",
        "authority_eligible_state_count",
        "future_gated_state_count",
        "gap_blocked_state_count",
    }
)
_CANDIDATE_MASTER_FIELDS = _AUTHORITY_NODE_FIELDS | frozenset(
    {
        "anatomy_node_id",
        "presentation_class",
        "presentation_variants",
        "screen_mappings",
    }
)
_SCREEN_MAPPING_FIELDS = frozenset(
    {
        "authority_eligible_state_count",
        "blueprint_id",
        "future_gated_state_count",
        "gap_blocked_state_count",
        "state_variant_ids",
    }
)
_PRESENTATION_MATRIX_FIELDS = frozenset(
    {
        "contextual_trust_presentation",
        "no_root_chrome_surfaces",
        "required_accessibility_variants",
        "root_chrome_rule",
        "root_navigation_surfaces",
    }
)
_CANDIDATE_PROOF_FIELDS = frozenset(
    {
        "artifacts",
        "canonical_artifact_role",
        "canonical_node_id",
        "direct_visual_review_note",
        "visual_authority_id",
    }
)
_PROOF_ARTIFACT_FIELDS = frozenset(
    {"asset_id", "node_id", "path", "proof_posture", "sha256"}
)
_REQUIRED_ACCESSIBILITY_VARIANTS = (
    "Accessibility Size",
    "Increase Contrast",
    "Large Text",
    "Reduce Motion",
    "Reduce Transparency",
    "Standard",
    "VoiceOver Order",
)
_ROOT_NAVIGATION_SURFACES = ("Goals", "Time", "Today", "You")
_NO_ROOT_CHROME_SURFACES = ("Capture", "Search", "Trust/Proof inspection")


@dataclass(frozen=True, slots=True)
class VisualAuthorityBinding:
    visual_authority_id: str
    node_id: str
    blueprint_id: str | None
    frame_version: str
    requirement_ids: tuple[str, ...]
    state_variant_ids: tuple[str, ...]
    authority_eligible_state_count: int
    future_gated_state_count: int
    gap_blocked_state_count: int


@dataclass(frozen=True, slots=True)
class VisualAuthoritySnapshot:
    source_bytes: bytes
    source_sha256: str
    canon_revision: int
    canon_source_sha: str
    canon_content_sha: str
    figma_file_key: str
    gate_b_state: str
    authority_node_count: int
    screen_count: int
    visual_requirement_ids: tuple[str, ...]
    eligible_state_ids: tuple[str, ...]
    future_state_ids: tuple[str, ...]
    gap_blocked_state_ids: tuple[str, ...]
    legacy_node_count: int
    destructive_actions: tuple[str, ...]
    bindings: tuple[VisualAuthorityBinding, ...]


def load_visual_authority_rebaseline(repo_root: Path) -> VisualAuthoritySnapshot:
    """Load and fully validate the tracked Phase 3/4 visual-authority contract."""

    try:
        with _ux_operation(
            repo_root, include_visual_evidence=True
        ) as context:
            return _load_visual_authority_rebaseline_from_context(
                repo_root, context
            )
    except UXBlueprintError as exc:
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            f"visual-authority input changed during operation: {exc}",
        ) from exc


def _load_visual_authority_rebaseline_from_context(
    repo_root: Path,
    context,
) -> VisualAuthoritySnapshot:
    """Parse only the immutable manifest bytes captured by the UX operation."""

    source_bytes = _captured_input_bytes(context, MANIFEST_PATH)
    try:
        payload = json.loads(source_bytes)
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID",
            "manifest is not valid JSON",
        ) from exc
    frozen = _freeze_mapping(payload, "visual-authority manifest")
    snapshot = _validate_visual_authority_payload(
        repo_root,
        frozen,
        source_bytes,
        context.canon,
    )
    _validate_r1_node_snapshot(
        repo_root, _object(frozen, "manifest")
    )
    return snapshot


def load_visual_authority_rebaseline_if_present(
    repo_root: Path | None,
) -> VisualAuthoritySnapshot | None:
    """Load the contract when installed; preserve isolated unit-registry behavior."""

    if repo_root is None:
        return None
    try:
        with _ux_operation(
            repo_root, include_visual_evidence=True
        ) as context:
            captured = tuple(
                item for item in context.inputs if item.path == MANIFEST_PATH
            )
            if not captured:
                return None
            if len(captured) != 1:
                raise UXBlueprintError(
                    "visual-authority manifest capture is ambiguous"
                )
            return _load_visual_authority_rebaseline_from_context(
                repo_root, context
            )
    except UXBlueprintError as exc:
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            f"visual-authority input changed during operation: {exc}",
        ) from exc


def validate_visual_authority_payload(
    repo_root: Path,
    payload: object,
    source_bytes: bytes,
) -> VisualAuthoritySnapshot:
    """Validate exact coverage, provenance, state posture, and retained evidence."""

    with _ux_operation(
        repo_root, include_visual_evidence=True
    ) as context:
        frozen = _freeze_mapping(
            _object(payload, "visual-authority manifest"),
            "visual-authority manifest",
        )
        return _validate_visual_authority_payload(
            repo_root,
            frozen,
            bytes(source_bytes),
            context.canon,
        )


def _validate_visual_authority_payload(
    repo_root: Path,
    payload: object,
    source_bytes: bytes,
    canon_snapshot: _AuditedCanonSnapshot,
) -> VisualAuthoritySnapshot:
    data = _object(payload, "visual-authority manifest")
    _exact_fields(data, _TOP_LEVEL_FIELDS, "manifest")
    if data.get("schema_version") != 1:
        raise _error("VISUAL_AUTHORITY_SCHEMA_INVALID", "schema_version must be 1")
    if data.get("authority_state") != "shadow" or data.get("phase") != "phase3_4":
        raise _error(
            "VISUAL_AUTHORITY_AUTHORITY_STATE_INVALID",
            "rebaseline must remain phase3_4 shadow authority before cutover",
        )

    canon = _object(data["canon"], "canon")
    _exact_fields(canon, _CANON_FIELDS, "canon")
    canon_revision = _integer(canon["revision"], "canon revision")
    canon_source_sha = _sha(canon["source_sha"], 40, "canon source SHA")
    canon_content_sha = _sha(canon["content_sha"], 64, "canon content SHA")
    try:
        blueprint = load_ux_blueprint(repo_root)
        _validate_ux_blueprint(repo_root, blueprint, canon_snapshot)
    except UXBlueprintError as exc:
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            f"current UX blueprint/canon validation failed: {exc}",
        ) from exc
    if (
        blueprint.get("canon_revision") != canon_revision
        or blueprint.get("source_sha") != canon_source_sha
        or blueprint.get("canon_content_sha") != canon_content_sha
    ):
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            "visual authority does not match the current validated UX blueprint",
        )

    dispositions = _load_json_object(repo_root, REQUIREMENT_DISPOSITIONS_PATH)
    visual_requirement_ids = tuple(
        sorted(
            _string(item.get("requirement_id"), "requirement ID")
            for item in _list(dispositions.get("dispositions"), "dispositions")
            if _object(item, "disposition").get("disposition")
            == "visual_mapping_required"
        )
    )

    state_posture = _object(data["state_posture"], "state_posture")
    _exact_fields(state_posture, _STATE_FIELDS, "state_posture")
    eligible_state_ids = _sorted_unique_strings(
        state_posture["eligible_state_ids"], "eligible state IDs"
    )
    future_state_ids = _sorted_unique_strings(
        state_posture["future_state_ids"], "future state IDs"
    )
    gap_state_ids = _sorted_unique_strings(
        state_posture["gap_blocked_state_ids"], "gap-blocked state IDs"
    )
    if set(gap_state_ids) != SEARCH_GAP_BLOCKED_STATE_IDS:
        raise _error(
            "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
            "gap-blocked states must equal the exact canonical Search gap set",
        )
    try:
        state_contracts = {
            contract.state_id: contract
            for contract in _load_state_command_contracts(
                repo_root, canon_snapshot
            )
        }
    except UXBlueprintError as exc:
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            f"canonical state-command validation failed: {exc}",
        ) from exc
    exact_gate = (SEARCH_ASK_ACTIVATION_GATE_REQUIREMENT_ID,)
    if any(
        (contract := state_contracts.get(state_id)) is None
        or contract.requirement_id != SEARCH_ASK_COMMAND_REQUIREMENT_ID
        or contract.activation_posture
        is not StateCommandActivationPosture.FUTURE_GATED
        or contract.gate_requirement_ids != exact_gate
        for state_id in SEARCH_GAP_BLOCKED_STATE_IDS
    ):
        raise _error(
            "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
            "gap-blocked Search states must remain exact future-gated contracts",
        )
    state_sets = tuple(map(set, (eligible_state_ids, future_state_ids, gap_state_ids)))
    if any(state_sets[index] & state_sets[other] for index in range(3) for other in range(index + 1, 3)):
        raise _error(
            "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
            "eligible, future, and gap-blocked state sets must be disjoint",
        )
    inventory = load_state_inventory(repo_root)
    inventory_ids = {
        _string(item.get("blueprint_id"), "state blueprint ID")
        for item in _list(inventory.get("state_variants"), "state inventory")
    }
    if set().union(*state_sets) != inventory_ids:
        raise _error(
            "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
            "state posture must classify every current UX state exactly once",
        )
    gap_blocked_requirement_ids = {
        _string(item.get("requirement_id"), "requirement ID")
        for item in _list(dispositions.get("dispositions"), "dispositions")
        if _object(item, "disposition").get("disposition")
        == "visual_mapping_required"
        and (
            state_ids := set(
                _list(item.get("state_blueprint_ids"), "state blueprint IDs")
            )
        )
        and state_ids <= SEARCH_GAP_BLOCKED_STATE_IDS
    }

    presentation = _object(data["presentation_matrix"], "presentation_matrix")
    _exact_fields(
        presentation,
        _PRESENTATION_MATRIX_FIELDS,
        "presentation_matrix",
    )
    try:
        root_surfaces = _sorted_unique_strings(
            presentation["root_navigation_surfaces"],
            "root navigation surfaces",
        )
        no_root_surfaces = _sorted_unique_strings(
            presentation["no_root_chrome_surfaces"],
            "no-root-chrome surfaces",
        )
    except CanonError as exc:
        raise _error(
            "VISUAL_AUTHORITY_PRESENTATION_MATRIX_INVALID",
            "root navigation and contextual presentation matrix is malformed",
        ) from exc
    if (
        root_surfaces != _ROOT_NAVIGATION_SURFACES
        or no_root_surfaces != _NO_ROOT_CHROME_SURFACES
        or presentation.get("contextual_trust_presentation") != "inspection_only"
        or presentation.get("root_chrome_rule")
        != "root_navigation_visible_only_on_today_goals_time_you"
    ):
        raise _error(
            "VISUAL_AUTHORITY_PRESENTATION_MATRIX_INVALID",
            "root navigation and contextual presentation matrix is not exact",
        )
    try:
        required_variants = _sorted_unique_strings(
            presentation["required_accessibility_variants"],
            "required accessibility variants",
        )
    except CanonError as exc:
        raise _error(
            "VISUAL_AUTHORITY_ACCESSIBILITY_MATRIX_INVALID",
            "accessibility presentation variants are malformed",
        ) from exc
    if required_variants != _REQUIRED_ACCESSIBILITY_VARIANTS:
        raise _error(
            "VISUAL_AUTHORITY_ACCESSIBILITY_MATRIX_INVALID",
            "accessibility presentation variants are incomplete or changed",
        )

    figma = _object(data["figma"], "figma")
    _exact_fields(figma, _FIGMA_FIELDS, "figma")
    file_key = _string(figma["file_key"], "Figma file key")
    pages = set(_sorted_unique_strings(figma["additive_page_ids"], "additive page IDs"))
    if pages != {f"17:{index}" for index in range(2, 12)} | {"215:2"}:
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "additive Phase 3/4 pages do not match the retained and R1 page family",
        )
    if (
        figma.get("reconciliation_root_node_id") != "307:57"
        or "215:2"
        not in _sorted_unique_strings(
            figma.get("phase3_root_node_ids"), "Phase 3 root node IDs"
        )
    ):
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "R1 live index and reconciliation roots are not exact",
        )
    records = tuple(_object(item, "authority node") for item in _list(figma["authority_nodes"], "authority nodes"))
    if len(records) != 147:
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "authority registry must contain exactly 147 nodes",
        )
    node_ids = tuple(_string(item.get("node_id"), "node ID") for item in records)
    authority_ids = tuple(
        _string(item.get("visual_authority_id"), "visual authority ID")
        for item in records
    )
    if len(set(node_ids)) != len(node_ids) or len(set(authority_ids)) != len(authority_ids):
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "authority node IDs and visual authority IDs must be globally unique",
        )
    if any(_string(item.get("page_id"), "page ID") not in pages for item in records):
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "authority node resolves outside the additive page family",
        )

    bindings: list[VisualAuthorityBinding] = []
    mapped_requirement_ids: set[str] = set()
    mapped_state_ids: set[str] = set()
    support_overlay_state_ids: set[str] = set()
    screen_count = 0
    candidate_records: dict[str, Mapping[str, object]] = {}
    anatomy_node_ids: set[str] = set()
    for item in records:
        kind = _string(item.get("kind"), "authority node kind")
        expected_fields = (
            _SCREEN_NODE_FIELDS
            if kind == "screen"
            else _CANDIDATE_MASTER_FIELDS
            if kind == "candidate_master"
            else _AUTHORITY_NODE_FIELDS
        )
        _exact_fields(
            item,
            expected_fields,
            "authority node",
        )
        authority_id = _string(
            item.get("visual_authority_id"), "visual authority ID"
        )
        support_overlay = authority_id in {
            "VA-P4-A11Y-CLASS-003",
            "VA-P4-A11Y-CLASS-005",
        }
        if (
            item.get("canon_revision") != canon_revision
            or item.get("canon_source_sha") != canon_source_sha
            or item.get("canon_content_sha") != canon_content_sha
        ):
            raise _error(
                "VISUAL_AUTHORITY_CANON_STALE",
                f"authority node canon metadata is stale: {authority_id}",
            )
        name = _string(item.get("name"), "authority node name")
        labels = tuple(
            label
            for label in ("CANDIDATE", "ARCHIVE", "FAILURE_EVIDENCE")
            if name.startswith(f"{label} — ")
        )
        task_pack_eligible = item.get("task_pack_eligible")
        if len(labels) != 1 or not isinstance(task_pack_eligible, bool):
            raise _error(
                "VISUAL_AUTHORITY_LABEL_INVALID",
                f"authority node lacks one binary posture label: {authority_id}",
            )
        label = labels[0]
        if (
            (kind == "screen" and (label != "FAILURE_EVIDENCE" or task_pack_eligible))
            or (kind == "candidate_master" and (label != "CANDIDATE" or not task_pack_eligible))
            or (kind != "candidate_master" and task_pack_eligible)
            or (label in {"ARCHIVE", "FAILURE_EVIDENCE"} and task_pack_eligible)
        ):
            raise _error(
                "VISUAL_AUTHORITY_LABEL_INVALID",
                f"binary authority label and task-pack eligibility conflict: {authority_id}",
            )
        accessibility_variants = _unique_strings_preserve_order(
            item.get("accessibility_variants"), "accessibility variants"
        )
        plausibility = _string(
            item.get("swiftui_plausibility"), "SwiftUI plausibility"
        )
        if (
            not accessibility_variants
            or item.get("metadata_provenance") != "direct_figma_shared_plugin_data"
            or item.get("implementation_status")
            != "design_authority_candidate_not_source_implementation"
            or item.get("proof_ceiling") != "visual_design_authority_candidate_only"
            or item.get("owner_approval_state")
            not in {
                "candidate_pending_independent_review",
                "candidate_with_future_gated_states",
                "mapped_non_authoritative_blocked",
            }
            or (
                "reconciliation_only" in plausibility
                and authority_id != "VA-P4-RECONCILIATION-001"
            )
            or (
                authority_id == "VA-P4-RECONCILIATION-001"
                and "reconciliation_only" not in plausibility
            )
        ):
            raise _error(
                "VISUAL_AUTHORITY_NODE_METADATA_INVALID",
                f"authority node metadata is incomplete or overclaims: {authority_id}",
            )
        _string(item.get("page_name"), "authority page name")
        _string(item.get("frame_version"), "frame version")
        requirement_ids = _sorted_unique_strings(
            item.get("requirement_ids"), "node requirement IDs"
        )
        if task_pack_eligible:
            mapped_requirement_ids.update(requirement_ids)
        blueprint_id = item.get("blueprint_id")
        if blueprint_id is not None:
            blueprint_id = _string(blueprint_id, "blueprint ID")
        if kind == "screen":
            if not blueprint_id or not blueprint_id.startswith("UX-SCREEN-"):
                raise _error(
                    "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
                    "failure-evidence screen must retain its UX screen provenance",
                )
            state_ids = _sorted_unique_strings(
                item.get("state_variant_ids"), "screen state IDs"
            )
            eligible_count = _integer(
                item.get("authority_eligible_state_count"), "eligible state count"
            )
            future_count = _integer(
                item.get("future_gated_state_count"), "future state count"
            )
            gap_count = _integer(
                item.get("gap_blocked_state_count"), "gap state count"
            )
            if (
                eligible_count != len(set(state_ids) & state_sets[0])
                or future_count != len(set(state_ids) & state_sets[1])
                or gap_count != len(set(state_ids) & state_sets[2])
            ):
                raise _error(
                    "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
                    f"failure-evidence state provenance does not resolve for {blueprint_id}",
                )
            continue
        if kind != "candidate_master":
            continue

        if blueprint_id is not None:
            raise _error(
                "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
                "candidate master uses screen_mappings instead of a monolithic blueprint_id",
            )
        anatomy_node_id = _string(item.get("anatomy_node_id"), "anatomy node ID")
        if anatomy_node_id == item.get("node_id") or anatomy_node_id in anatomy_node_ids:
            raise _error(
                "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
                "candidate anatomy nodes must be distinct from canonical task-pack nodes",
            )
        anatomy_node_ids.add(anatomy_node_id)
        presentation_variants = _sorted_unique_strings(
            item.get("presentation_variants"), "presentation variants"
        )
        if presentation_variants != required_variants:
            raise _error(
                "VISUAL_AUTHORITY_ACCESSIBILITY_MATRIX_INVALID",
                f"candidate master accessibility variants differ: {authority_id}",
            )
        if _string(item.get("presentation_class"), "presentation class") not in {
            "Root surface",
            "Global overlay",
            "Contextual detail",
            "System state",
            "Object lifecycle",
            "Journey flow",
        }:
            raise _error(
                "VISUAL_AUTHORITY_PRESENTATION_MATRIX_INVALID",
                f"candidate presentation class is invalid: {authority_id}",
            )
        candidate_records[authority_id] = item
        screen_mappings = tuple(
            _object(mapping, "candidate screen mapping")
            for mapping in _list(item.get("screen_mappings"), "screen mappings")
        )
        mapping_blueprints: list[str] = []
        for mapping in screen_mappings:
            _exact_fields(mapping, _SCREEN_MAPPING_FIELDS, "candidate screen mapping")
            mapped_blueprint = _string(mapping.get("blueprint_id"), "screen blueprint ID")
            mapping_blueprints.append(mapped_blueprint)
            if not mapped_blueprint.startswith("UX-SCREEN-"):
                raise _error(
                    "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
                    "candidate screen mapping must resolve one UX screen blueprint",
                )
            state_ids = _sorted_unique_strings(
                mapping.get("state_variant_ids"), "candidate screen state IDs"
            )
            if not support_overlay and mapped_state_ids.intersection(state_ids):
                raise _error(
                    "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
                    "one UX state is mapped by more than one candidate master",
                )
            if not support_overlay:
                mapped_state_ids.update(state_ids)
            else:
                support_overlay_state_ids.update(state_ids)
            eligible_count = _integer(
                mapping.get("authority_eligible_state_count"), "eligible state count"
            )
            future_count = _integer(
                mapping.get("future_gated_state_count"), "future state count"
            )
            gap_count = _integer(
                mapping.get("gap_blocked_state_count"), "gap state count"
            )
            if (
                eligible_count != len(set(state_ids) & state_sets[0])
                or future_count != len(set(state_ids) & state_sets[1])
                or gap_count != len(set(state_ids) & state_sets[2])
            ):
                raise _error(
                    "VISUAL_AUTHORITY_STATE_POSTURE_INVALID",
                    f"candidate screen state counts do not resolve for {mapped_blueprint}",
                )
            if not support_overlay:
                screen_count += 1
            bindings.append(
                VisualAuthorityBinding(
                    visual_authority_id=authority_id,
                    node_id=_string(item.get("node_id"), "node ID"),
                    blueprint_id=mapped_blueprint,
                    frame_version=_string(item.get("frame_version"), "frame version"),
                    requirement_ids=requirement_ids,
                    state_variant_ids=state_ids,
                    authority_eligible_state_count=eligible_count,
                    future_gated_state_count=future_count,
                    gap_blocked_state_count=gap_count,
                )
            )
        if mapping_blueprints != sorted(mapping_blueprints) or len(set(mapping_blueprints)) != len(mapping_blueprints):
            raise _error(
                "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
                "candidate screen mappings must be sorted and unique",
            )
        if not screen_mappings:
            bindings.append(
                VisualAuthorityBinding(
                    visual_authority_id=authority_id,
                    node_id=_string(item.get("node_id"), "node ID"),
                    blueprint_id=None,
                    frame_version=_string(item.get("frame_version"), "frame version"),
                    requirement_ids=requirement_ids,
                    state_variant_ids=(),
                    authority_eligible_state_count=0,
                    future_gated_state_count=0,
                    gap_blocked_state_count=0,
                )
            )
    if (
        len(candidate_records) != 18
        or screen_count != 47
        or mapped_state_ids != inventory_ids - SEARCH_GAP_BLOCKED_STATE_IDS
        or not support_overlay_state_ids.issubset(mapped_state_ids)
    ):
        raise _error(
            "VISUAL_AUTHORITY_FIGMA_MAPPING_INVALID",
            "18 candidate masters must map all 47 UX screens and every "
            "non-gap-blocked state exactly once",
        )

    coverage = _object(data["coverage"], "coverage")
    _exact_fields(coverage, _COVERAGE_FIELDS, "coverage")
    declared_visual = _sorted_unique_strings(
        coverage["visual_requirement_ids"], "visual requirement IDs"
    )
    additional = _sorted_unique_strings(
        coverage["additional_mapped_requirement_ids"],
        "additional mapped requirement IDs",
    )
    if declared_visual != visual_requirement_ids:
        raise _error(
            "VISUAL_AUTHORITY_REQUIREMENT_COVERAGE_INVALID",
            "declared visual requirements differ from current UX dispositions",
        )
    if mapped_requirement_ids != (
        set(visual_requirement_ids) - gap_blocked_requirement_ids
    ) | set(additional):
        raise _error(
            "VISUAL_AUTHORITY_REQUIREMENT_COVERAGE_INVALID",
            "Figma authority mappings must cover current non-gap-blocked visual "
            "requirements exactly",
        )
    expected_counts = {
        "visual_requirement_count": len(visual_requirement_ids),
        "screen_count": 47,
        "object_count": 18,
        "journey_count": 12,
        "cross_cutting_count": 11,
        "sensitive_exposure_channel_count": 9,
        "state_count": len(inventory_ids),
    }
    if any(coverage.get(key) != value for key, value in expected_counts.items()):
        raise _error(
            "VISUAL_AUTHORITY_REQUIREMENT_COVERAGE_INVALID",
            "coverage summary differs from exact validated mappings",
        )

    legacy = _object(data["legacy"], "legacy")
    _exact_fields(legacy, _LEGACY_FIELDS, "legacy")
    prior_reconciliation_path = Path(
        _string(legacy["prior_reconciliation_path"], "prior reconciliation path")
    )
    prior_reconciliation_sha = _sha(
        legacy["prior_reconciliation_sha256"],
        64,
        "prior reconciliation SHA",
    )
    if hashlib.sha256(
        _read_regular_nofollow(repo_root, prior_reconciliation_path)
    ).hexdigest() != prior_reconciliation_sha:
        raise _error(
            "VISUAL_AUTHORITY_LEGACY_PROVENANCE_STALE",
            "prior Figma reconciliation receipt is missing or changed",
        )
    legacy_nodes = tuple(_object(item, "legacy node") for item in _list(legacy["nodes"], "legacy nodes"))
    if len(legacy_nodes) != 15 or len(
        {_string(item.get("node_id"), "legacy node ID") for item in legacy_nodes}
    ) != 15:
        raise _error(
            "VISUAL_AUTHORITY_LEGACY_RECONCILIATION_INVALID",
            "legacy reconciliation must disposition exactly 15 unique nodes",
        )
    for item in legacy_nodes:
        replacements = _sorted_unique_strings(
            item.get("replacement_visual_authority_ids"), "replacement authority IDs"
        )
        candidate_replacement_ids = {
            _string(record.get("visual_authority_id"), "visual authority ID")
            for record in records
            if _string(record.get("name"), "authority node name").startswith(
                "CANDIDATE — "
            )
        }
        if not replacements or not set(replacements).issubset(candidate_replacement_ids):
            raise _error(
                "VISUAL_AUTHORITY_LEGACY_RECONCILIATION_INVALID",
                "every legacy node must resolve to retained candidate replacement authority",
            )
    destructive_actions = _sorted_unique_strings(
        legacy["destructive_actions"], "destructive actions"
    )
    if destructive_actions or legacy.get("legacy_visual_bytes_changed") is not False:
        raise _error(
            "VISUAL_AUTHORITY_DESTRUCTIVE_ACTION_FORBIDDEN",
            "Gate C is withheld; legacy visual bytes and nodes must remain unchanged",
        )

    _validate_screenshot_records(
        repo_root,
        data["screenshots"],
        expected_count=10,
        valid_node_ids=set(node_ids),
        legacy=False,
    )
    _validate_screenshot_records(
        repo_root,
        data["legacy_before_screenshots"],
        expected_count=9,
        valid_node_ids={_string(item.get("node_id"), "legacy node ID") for item in legacy_nodes},
        legacy=True,
    )
    _validate_candidate_proofs(
        repo_root,
        data["candidate_proofs"],
        candidate_records,
    )

    gate = _object(data["gate_b"], "gate_b")
    _exact_fields(gate, _GATE_FIELDS, "gate_b")
    gate_state = _string(gate["state"], "Gate B state")
    if gate_state not in {"pending_independent_review", "green"}:
        raise _error("VISUAL_AUTHORITY_GATE_B_INVALID", "Gate B state is invalid")
    if gate.get("blocked_state_handling") != "fail_closed_zero_source_authorization":
        raise _error(
            "VISUAL_AUTHORITY_GATE_B_INVALID",
            "blocked visual states must fail closed with zero source authorization",
        )
    if gate_state == "green":
        if (
            data.get("status") != "gate_b_green"
            or gate.get("task_pack_selection") != "new_authority_only"
            or gate.get("independent_semantic_review") != "green"
            or gate.get("independent_visual_review") != "green"
            or gate.get("rollback_proven") is not True
        ):
            raise _error(
                "VISUAL_AUTHORITY_GATE_B_INVALID",
                "Green Gate B requires both reviews, rollback proof, and new-only selection",
            )
    elif gate.get("task_pack_selection") != "blocked_until_gate_b_green":
        raise _error(
            "VISUAL_AUTHORITY_GATE_B_INVALID",
            "pending Gate B must block task-pack visual selection",
        )

    result = VisualAuthoritySnapshot(
        source_bytes=source_bytes,
        source_sha256=hashlib.sha256(source_bytes).hexdigest(),
        canon_revision=canon_revision,
        canon_source_sha=canon_source_sha,
        canon_content_sha=canon_content_sha,
        figma_file_key=file_key,
        gate_b_state=gate_state,
        authority_node_count=len(records),
        screen_count=screen_count,
        visual_requirement_ids=visual_requirement_ids,
        eligible_state_ids=eligible_state_ids,
        future_state_ids=future_state_ids,
        gap_blocked_state_ids=gap_state_ids,
        legacy_node_count=len(legacy_nodes),
        destructive_actions=destructive_actions,
        bindings=tuple(sorted(bindings, key=lambda item: item.visual_authority_id)),
    )
    return result


def select_visual_authority(
    snapshot: VisualAuthoritySnapshot,
    *,
    scope_ids: Iterable[str],
    requirement_ids: Iterable[str],
    canon_revision: int | None = None,
    canon_content_sha: str | None = None,
) -> tuple[str, ...]:
    """Select exact new authority or fail closed for stale, future, or gap scope."""

    revision = snapshot.canon_revision if canon_revision is None else canon_revision
    content_sha = (
        snapshot.canon_content_sha
        if canon_content_sha is None
        else canon_content_sha
    )
    if revision != snapshot.canon_revision or content_sha != snapshot.canon_content_sha:
        raise _error(
            "VISUAL_AUTHORITY_CANON_STALE",
            "task scope does not match the visual authority canon revision",
        )
    if snapshot.gate_b_state != "green":
        raise _error(
            "VISUAL_AUTHORITY_GATE_B_NOT_GREEN",
            "candidate visual authority cannot authorize task-pack selection",
        )
    scopes = frozenset(_nonempty_strings(scope_ids, "scope IDs"))
    requirements = frozenset(_nonempty_strings(requirement_ids, "requirement IDs"))
    future = scopes & set(snapshot.future_state_ids)
    if future:
        raise _error(
            "VISUAL_AUTHORITY_FUTURE_GATED",
            f"future-gated visual state cannot authorize source work: {min(future)}",
        )
    gaps = scopes & set(snapshot.gap_blocked_state_ids)
    if gaps:
        raise _error(
            "VISUAL_AUTHORITY_GAP_BLOCKED",
            f"gap-blocked visual state cannot authorize source work: {min(gaps)}",
        )

    state_scopes = scopes & (
        set(snapshot.eligible_state_ids)
        | set(snapshot.future_state_ids)
        | set(snapshot.gap_blocked_state_ids)
    )
    screen_scopes = {scope for scope in scopes if scope.startswith("UX-SCREEN-")}
    selected: list[VisualAuthorityBinding] = []
    incomplete_broad_bindings: list[str] = []
    for binding in snapshot.bindings:
        if state_scopes:
            matches = bool(state_scopes & set(binding.state_variant_ids))
        elif screen_scopes:
            matches = binding.blueprint_id in screen_scopes
        else:
            matches = bool(requirements & set(binding.requirement_ids)) or (
                binding.blueprint_id in scopes
                or binding.visual_authority_id in scopes
            )
        if not matches:
            continue
        if not state_scopes and (
            binding.future_gated_state_count > 0
            or binding.gap_blocked_state_count > 0
        ):
            incomplete_broad_bindings.append(binding.visual_authority_id)
            continue
        if (
            binding.state_variant_ids
            and binding.authority_eligible_state_count == 0
        ):
            continue
        selected.append(binding)
    if incomplete_broad_bindings:
        raise _error(
            "VISUAL_AUTHORITY_SCOPE_TOO_BROAD",
            "screen or requirement scope includes future-gated or gap-blocked "
            f"visual states: {min(incomplete_broad_bindings)}",
        )
    if not selected:
        raise _error(
            "VISUAL_AUTHORITY_MAPPING_MISSING",
            "no Gate-B-Green visual authority resolves the declared task scope",
        )
    selected_by_id = {item.visual_authority_id: item for item in selected}
    return tuple(
        f"{item.visual_authority_id} | "
        f"figma:{snapshot.figma_file_key}:{item.node_id} | "
        f"frame {item.frame_version} | Gate B Green visual design authority only; "
        "source implementation and rendered-app proof remain unverified"
        for item in sorted(
            selected_by_id.values(),
            key=lambda value: value.visual_authority_id,
        )
    )


def visual_authority_lines_for_task_pack(
    snapshot: VisualAuthoritySnapshot,
    *,
    scope_ids: Iterable[str],
    requirement_ids: Iterable[str],
) -> tuple[str, ...]:
    """Return nothing while Gate B is pending; otherwise enforce exact selection."""

    if snapshot.gate_b_state != "green":
        return ()
    return select_visual_authority(
        snapshot,
        scope_ids=scope_ids,
        requirement_ids=requirement_ids,
    )


def _validate_candidate_proofs(
    root: Path,
    value: object,
    candidate_records: Mapping[str, Mapping[str, object]],
) -> None:
    records = tuple(
        _object(item, "candidate proof")
        for item in _list(value, "candidate proofs")
    )
    proof_ids = tuple(
        _string(item.get("visual_authority_id"), "proof visual authority ID")
        for item in records
    )
    if (
        len(records) != 18
        or len(set(proof_ids)) != len(proof_ids)
        or set(proof_ids) != set(candidate_records)
    ):
        raise _error(
            "VISUAL_AUTHORITY_PROOF_INVALID",
            "every candidate master requires exactly one proof bundle",
        )
    paths: set[str] = set()
    for proof in records:
        _exact_fields(proof, _CANDIDATE_PROOF_FIELDS, "candidate proof")
        authority_id = _string(
            proof.get("visual_authority_id"), "proof visual authority ID"
        )
        candidate = candidate_records[authority_id]
        canonical_node_id = _string(
            proof.get("canonical_node_id"), "canonical proof node ID"
        )
        if canonical_node_id != candidate.get("node_id"):
            raise _error(
                "VISUAL_AUTHORITY_PROOF_INVALID",
                f"proof does not resolve the canonical candidate node: {authority_id}",
            )
        _string(proof.get("direct_visual_review_note"), "direct visual review note")
        artifacts = _object(proof.get("artifacts"), "candidate proof artifacts")
        if set(artifacts) != {"hero", "presentation", "viewport"}:
            raise _error(
                "VISUAL_AUTHORITY_PROOF_INVALID",
                f"proof roles are incomplete: {authority_id}",
            )
        canonical_role = _string(
            proof.get("canonical_artifact_role"), "canonical artifact role"
        )
        if canonical_role not in artifacts:
            raise _error(
                "VISUAL_AUTHORITY_PROOF_INVALID",
                f"canonical proof role is invalid: {authority_id}",
            )
        artifact_node_ids: set[str] = set()
        for role in ("hero", "presentation", "viewport"):
            artifact = _object(artifacts[role], f"{role} proof artifact")
            _exact_fields(artifact, _PROOF_ARTIFACT_FIELDS, "proof artifact")
            node_id = _string(artifact.get("node_id"), "proof artifact node ID")
            artifact_node_ids.add(node_id)
            if artifact.get("proof_posture") != "product_only":
                raise _error(
                    "VISUAL_AUTHORITY_PROOF_INVALID",
                    f"anatomy/spec boards cannot serve as product proof: {authority_id}",
                )
            relative = _string(artifact.get("path"), "proof artifact path")
            expected_path = (
                "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
                f"repair/screens/task-pack/{authority_id.lower()}-viewport.png"
                if role == "viewport"
                else "docs/qa/evidence/2026-07-14-canon-visual-authority-"
                "rebaseline/screens/phase3-4/candidate-masters/"
                f"{authority_id.lower()}-{role}.png"
            )
            if relative != expected_path or relative in paths:
                raise _error(
                    "VISUAL_AUTHORITY_PROOF_INVALID",
                    f"proof artifact path is not exact or unique: {authority_id}",
                )
            paths.add(relative)
            _string(artifact.get("asset_id"), "proof artifact asset ID")
            content = _read_regular_nofollow(root, Path(relative))
            if hashlib.sha256(content).hexdigest() != _sha(
                artifact.get("sha256"), 64, "proof artifact SHA"
            ):
                raise _error(
                    "VISUAL_AUTHORITY_PROOF_INVALID",
                    f"proof artifact digest is stale: {relative}",
                )
        if (
            len(artifact_node_ids) != 3
            or candidate.get("anatomy_node_id") in artifact_node_ids
            or _object(artifacts[canonical_role], "canonical artifact").get("node_id")
            != canonical_node_id
        ):
            raise _error(
                "VISUAL_AUTHORITY_PROOF_INVALID",
                f"proof nodes are not product-only and canonical: {authority_id}",
            )


def _validate_r1_node_snapshot(
    root: Path,
    manifest: Mapping[str, object],
) -> None:
    """Fail closed when the frozen live-node and render bindings drift."""

    snapshot = _load_json_object(root, R1_NODE_SNAPSHOT_PATH)
    validate_r1_node_snapshot_payload(root, manifest, snapshot)


def validate_r1_node_snapshot_payload(
    root: Path,
    manifest: Mapping[str, object],
    snapshot: Mapping[str, object],
) -> None:
    """Validate one caller-supplied R1 snapshot with closed nested records."""

    expected_fields = frozenset(
        {
            "authority_metadata",
            "authority_node_bindings",
            "authority_state",
            "canon",
            "command_registry",
            "command_registry_bindings",
            "deleted_node_ids",
            "destructive_actions",
            "drilldown_shell_frames",
            "figma_write_receipt",
            "file_key",
            "page_id",
            "page_name",
            "pixel_equivalent_replacements",
            "presentation_repairs",
            "repository_base_sha",
            "root_shell_frames",
            "schema_version",
            "support_overlay_bindings",
            "task_pack_targets",
        }
    )
    _r1_exact_fields(snapshot, expected_fields, "R1 node snapshot")
    figma = _object(manifest.get("figma"), "figma")
    canon = _object(manifest.get("canon"), "canon")
    _r1_exact_fields(canon, _CANON_FIELDS, "R1 canon")
    if (
        snapshot.get("schema_version") != 1
        or snapshot.get("authority_state") != "candidate_shadow"
        or snapshot.get("file_key") != figma.get("file_key")
        or snapshot.get("page_id") != "215:2"
        or snapshot.get("page_name") != "CANDIDATE — AV1 · Revision 1"
        or snapshot.get("canon") != canon
        or snapshot.get("deleted_node_ids") != []
        or snapshot.get("destructive_actions") != []
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 snapshot identity, canon, or non-destructive posture is stale",
        )

    receipt = _object(snapshot.get("figma_write_receipt"), "Figma write receipt")
    _r1_exact_fields(
        receipt,
        frozenset(
            {
                "created_node_count",
                "deleted_node_ids",
                "destructive_actions",
                "mutated_node_count",
                "review_repair",
            }
        ),
        "R1 Figma write receipt",
    )
    repair_receipt = _object(receipt.get("review_repair"), "review repair receipt")
    _r1_exact_fields(
        repair_receipt,
        frozenset(
            {
                "atomic_write_count",
                "created_node_ids",
                "failed_atomic_attempt_count",
                "failed_atomic_debug_uuid",
                "hidden_retained_node_ids",
                "mutated_node_ids",
            }
        ),
        "R1 review repair receipt",
    )
    if (
        receipt.get("created_node_count") != 79
        or receipt.get("mutated_node_count") != 105
        or receipt.get("deleted_node_ids") != []
        or receipt.get("destructive_actions") != []
        or repair_receipt.get("atomic_write_count") != 2
        or repair_receipt.get("failed_atomic_attempt_count") != 1
        or repair_receipt.get("created_node_ids") != ["367:2746", "368:2746"]
        or repair_receipt.get("hidden_retained_node_ids")
        != ["354:2562", "354:2733"]
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 Figma write receipt is incomplete or destructive",
        )

    authority_nodes = {
        _string(item.get("visual_authority_id"), "visual authority ID"): item
        for item in (
            _object(value, "authority node")
            for value in _list(figma.get("authority_nodes"), "authority nodes")
        )
    }
    bindings = tuple(
        _object(value, "R1 authority binding")
        for value in _list(
            snapshot.get("authority_node_bindings"), "R1 authority bindings"
        )
    )
    for item in bindings:
        _r1_exact_fields(
            item,
            frozenset({"node_id", "visual_authority_id"}),
            "R1 authority binding",
        )
    binding_pairs = tuple(
        (
            _string(item.get("visual_authority_id"), "visual authority ID"),
            _string(item.get("node_id"), "node ID"),
        )
        for item in bindings
    )
    expected_bindings = tuple(
        sorted(
            (
                authority_id,
                _string(item.get("node_id"), "node ID"),
            )
            for authority_id, item in authority_nodes.items()
            if item.get("page_id") == "215:2"
        )
    )
    if (
        len(binding_pairs) != 49
        or binding_pairs != expected_bindings
        or any(
            authority_nodes[authority_id].get("page_name")
            != "CANDIDATE — AV1 · Revision 1"
            or authority_nodes[authority_id].get("frame_version") != "R1"
            for authority_id, _ in binding_pairs
        )
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 authority-node bindings do not match the live candidate page",
        )

    candidate_proofs = {
        _string(item.get("visual_authority_id"), "proof visual authority ID"): item
        for item in (
            _object(value, "candidate proof")
            for value in _list(manifest.get("candidate_proofs"), "candidate proofs")
        )
    }
    targets = tuple(
        _object(value, "R1 task-pack target")
        for value in _list(snapshot.get("task_pack_targets"), "R1 task-pack targets")
    )
    for item in targets:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "direct_link",
                    "frame_version",
                    "node_id",
                    "screenshot_path",
                    "screenshot_sha256",
                    "visual_authority_id",
                }
            ),
            "R1 task-pack target",
        )
    target_ids = tuple(
        _string(item.get("visual_authority_id"), "visual authority ID")
        for item in targets
    )
    if target_ids != tuple(sorted(candidate_proofs)) or len(target_ids) != 18:
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 task-pack targets are incomplete or unsorted",
        )
    for item in targets:
        authority_id = _string(
            item.get("visual_authority_id"), "visual authority ID"
        )
        node_id = _string(item.get("node_id"), "node ID")
        path = _string(item.get("screenshot_path"), "screenshot path")
        sha = _sha(item.get("screenshot_sha256"), 64, "screenshot SHA")
        expected_link = (
            "https://www.figma.com/design/Oik7612LSTUHWsNRFoTlTJ"
            f"?node-id={node_id.replace(':', '-')}"
        )
        viewport = _object(
            _object(
                candidate_proofs[authority_id].get("artifacts"), "proof artifacts"
            ).get("viewport"),
            "viewport proof",
        )
        if (
            item.get("frame_version") != "R1"
            or item.get("direct_link") != expected_link
            or authority_nodes[authority_id].get("node_id") != node_id
            or candidate_proofs[authority_id].get("canonical_node_id") != node_id
            or viewport.get("node_id") != node_id
            or viewport.get("path") != path
            or viewport.get("sha256") != sha
            or hashlib.sha256(_read_regular_nofollow(root, Path(path))).hexdigest()
            != sha
        ):
            raise _error(
                "VISUAL_AUTHORITY_R1_PROOF_INVALID",
                f"R1 task-pack target or render proof is stale: {authority_id}",
            )

    metadata = tuple(
        _object(value, "R1 authority metadata")
        for value in _list(snapshot.get("authority_metadata"), "R1 authority metadata")
    )
    for item in metadata:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "implementation_status",
                    "node_id",
                    "owner_approval_state",
                    "proof_ceiling",
                    "task_pack_eligibility",
                    "visual_authority_id",
                }
            ),
            "R1 authority metadata",
        )
    metadata_ids = tuple(
        _string(item.get("visual_authority_id"), "visual authority ID")
        for item in metadata
    )
    if metadata_ids != target_ids or any(
        item.get("node_id") != authority_nodes[authority_id].get("node_id")
        or item.get("owner_approval_state")
        != authority_nodes[authority_id].get("owner_approval_state")
        or item.get("implementation_status")
        != authority_nodes[authority_id].get("implementation_status")
        or item.get("proof_ceiling")
        != authority_nodes[authority_id].get("proof_ceiling")
        or item.get("task_pack_eligibility") != "blocked_until_gate_b_green"
        for authority_id, item in zip(metadata_ids, metadata, strict=True)
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 candidate metadata is stale or authorizes source work",
        )

    support_overlays = tuple(
        _object(value, "R1 support overlay")
        for value in _list(
            snapshot.get("support_overlay_bindings"),
            "R1 support overlay bindings",
        )
    )
    support_ids = tuple(
        _string(item.get("visual_authority_id"), "support authority ID")
        for item in support_overlays
    )
    if support_ids != ("VA-P4-A11Y-CLASS-003", "VA-P4-A11Y-CLASS-005"):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 accessibility support overlays are incomplete or unsorted",
        )
    for item in support_overlays:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "mapping_role",
                    "requirement_ids",
                    "screen_mappings",
                    "visual_authority_id",
                }
            ),
            "R1 support overlay",
        )
        authority_id = _string(
            item.get("visual_authority_id"), "support authority ID"
        )
        mappings = tuple(
            _object(value, "support screen mapping")
            for value in _list(item.get("screen_mappings"), "support screen mappings")
        )
        for mapping in mappings:
            _r1_exact_fields(
                mapping,
                _SCREEN_MAPPING_FIELDS,
                "R1 support screen mapping",
            )
        if (
            item.get("mapping_role") != "accessibility_support_overlay"
            or not _list(item.get("requirement_ids"), "support requirements")
            or item.get("requirement_ids")
            != authority_nodes[authority_id].get("requirement_ids")
            or item.get("screen_mappings")
            != authority_nodes[authority_id].get("screen_mappings")
        ):
            raise _error(
                "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
                f"R1 support-overlay mapping is stale: {authority_id}",
            )

    registry_binding = _object(
        snapshot.get("command_registry"), "R1 command registry"
    )
    _r1_exact_fields(
        registry_binding,
        frozenset({"path", "registry_id", "registry_revision", "sha256"}),
        "R1 command registry",
    )
    registry_path = Path(
        _string(registry_binding.get("path"), "command registry path")
    )
    registry_bytes = _read_regular_nofollow(root, registry_path)
    registry = _object(json.loads(registry_bytes), "command registry")
    if (
        hashlib.sha256(registry_bytes).hexdigest()
        != _sha(registry_binding.get("sha256"), 64, "command registry SHA")
        or registry_binding.get("registry_id") != registry.get("registry_id")
        or registry_binding.get("registry_revision") != registry.get("registry_revision")
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 command-registry provenance is stale",
        )
    command_bindings = tuple(
        _object(value, "R1 command registry binding")
        for value in _list(
            snapshot.get("command_registry_bindings"),
            "R1 command registry bindings",
        )
    )
    expected_command_states = {
        "UX-STATE-VARIANT-TIME-DETAIL-VIEWING": (
            "329:1695",
            "SPEC-SURFACE-TIME-DETAIL-COMMAND-CONTRACT-001",
        ),
        "UX-STATE-VARIANT-TIME-IMPORT-REVIEWING-DIFF": (
            "329:1698",
            "JOURNEY-CALENDAR-IMPORT-COMMAND-CONTRACT-001",
        ),
    }
    if tuple(item.get("state_id") for item in command_bindings) != tuple(
        sorted(expected_command_states)
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 command-registry bindings are incomplete or unsorted",
        )
    registry_records = tuple(
        _object(value, "command registry record")
        for value in _list(registry.get("records"), "command registry records")
    )
    for item in command_bindings:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "command_ids",
                    "figma_text_node_id",
                    "requirement_id",
                    "state_id",
                }
            ),
            "R1 command registry binding",
        )
        state_id = _string(item.get("state_id"), "command state ID")
        expected_node, expected_requirement = expected_command_states[state_id]
        expected_commands = sorted(
            {
                _string(record.get("command_id"), "command ID")
                for record in registry_records
                if record.get("state_id") == state_id
                and record.get("posture") == "current"
                and not _string(record.get("command_id"), "command ID").endswith(
                    ("-INVERSE", "-RECOVERY-HANDOFF")
                )
            }
        )
        if (
            item.get("figma_text_node_id") != expected_node
            or item.get("requirement_id") != expected_requirement
            or item.get("command_ids") != expected_commands
        ):
            raise _error(
                "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
                f"R1 command-registry binding is stale: {state_id}",
            )
    serialized_snapshot = json.dumps(snapshot, sort_keys=True)
    if (
        "GAP-UX-COMMAND-CONTRACT-TIME-DETAIL-001" in serialized_snapshot
        or "GAP-UX-COMMAND-CONTRACT-TIME-IMPORT-001" in serialized_snapshot
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 snapshot retains obsolete Time command-gap copy",
        )

    roots = tuple(
        _object(value, "root shell frame")
        for value in _list(snapshot.get("root_shell_frames"), "root shell frames")
    )
    for item in roots:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "bottom_clearance",
                    "capture_count",
                    "capture_node_id",
                    "dock_height",
                    "dock_node_id",
                    "fade_node_id",
                    "frame_id",
                    "root_dock_count",
                    "search_count",
                    "search_node_id",
                }
            ),
            "R1 root shell frame",
        )
    if (
        len(roots) != 14
        or len({_string(item.get("frame_id"), "frame ID") for item in roots}) != 14
        or any(
            item.get("root_dock_count") != 1
            or item.get("search_count") != 1
            or item.get("capture_count") != 1
            or item.get("bottom_clearance") != item.get("dock_height")
            or item.get("dock_height") not in {84, 96}
            for item in roots
        )
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SHELL_INVALID",
            "root shell frames do not preserve unique dock and global actions",
        )
    drilldowns = tuple(
        _object(value, "drilldown shell frame")
        for value in _list(
            snapshot.get("drilldown_shell_frames"), "drilldown shell frames"
        )
    )
    for item in drilldowns:
        _r1_exact_fields(
            item,
            frozenset(
                {
                    "back_count",
                    "back_hit_node_id",
                    "back_node_id",
                    "capture_count",
                    "frame_id",
                    "root_dock_count",
                    "search_count",
                }
            ),
            "R1 drilldown shell frame",
        )
    if (
        len(drilldowns) != 7
        or len({_string(item.get("frame_id"), "frame ID") for item in drilldowns})
        != 7
        or any(
            item.get("root_dock_count") != 0
            or item.get("search_count") != 0
            or item.get("capture_count") != 0
            or item.get("back_count") != 1
            for item in drilldowns
        )
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_SHELL_INVALID",
            "drilldown frames do not preserve one back affordance and no root chrome",
        )

    presentation_repairs = tuple(
        _object(value, "R1 presentation repair")
        for value in _list(
            snapshot.get("presentation_repairs"), "R1 presentation repairs"
        )
    )
    expected_presentation_repairs: dict[str, Mapping[str, object]] = {
        "VA-P4-A11Y-CLASS-006": {
            "clips_consequence_copy": False,
            "frame_height": 124,
            "frame_id": "327:1648",
            "repair_kind": "unclip_and_resize",
            "screenshot_height": 124,
            "screenshot_path": (
                "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
                "repair/screens/task-pack/va-p4-a11y-class-006-viewport.png"
            ),
            "screenshot_sha256": (
                "2b37bf9db0d74e53f574b69f3bf54486904a77967f743f93364da1c5183e3e71"
            ),
            "screenshot_width": 916,
            "visible_consequence_text": "You can continue offline",
            "visual_authority_id": "VA-P4-A11Y-CLASS-006",
        },
        "VA-P4-CANDIDATE-001": {
            "content_bottom_clearance": 84,
            "dock_height": 84,
            "fade_height": 84,
            "fade_node_id": "354:2300",
            "fade_y": 768,
            "frame_id": "266:1424",
            "preserved_composition": "rolling_vertical_time_rail",
            "repair_kind": "trim_fade_to_dock",
            "screenshot_height": 852,
            "screenshot_path": (
                "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
                "repair/screens/task-pack/va-p4-candidate-001-viewport.png"
            ),
            "screenshot_sha256": (
                "af6bf216b3809b832780089eb14e5ecdef6a57d58b4514275ca8c52cdfe2532b"
            ),
            "screenshot_width": 393,
            "visual_authority_id": "VA-P4-CANDIDATE-001",
        },
        "VA-P4-CANDIDATE-003": {
            "content_bottom_clearance": 84,
            "dock_height": 84,
            "fade_height": 84,
            "fade_node_id": "354:2552",
            "fade_y": 768,
            "frame_id": "272:1424",
            "old_hidden_dock_node_id": "354:2562",
            "repair_kind": "trim_fade_and_replace_dock",
            "replacement_dock_node_id": "368:2746",
            "screenshot_height": 852,
            "screenshot_path": (
                "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
                "repair/screens/task-pack/va-p4-candidate-003-viewport.png"
            ),
            "screenshot_sha256": (
                "a19e378f86dcf4d9a0cde336ef35b8c77d99a8da6a543ef2f4dd1449bb406090"
            ),
            "screenshot_width": 393,
            "visible_root_dock_glyphs": ["Goals", "Time", "Today", "You"],
            "visual_authority_id": "VA-P4-CANDIDATE-003",
        },
        "VA-P4-CANDIDATE-005": {
            "frame_id": "278:1449",
            "old_hidden_dock_node_id": "354:2733",
            "pixel_equivalent_render": True,
            "repair_kind": "replace_dock",
            "replacement_dock_node_id": "367:2746",
            "screenshot_height": 852,
            "screenshot_path": (
                "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
                "repair/screens/task-pack/va-p4-candidate-005-viewport.png"
            ),
            "screenshot_sha256": (
                "a792881c96c7f3e12b7cdd5ece054fb9bde25b6bb80fcfe9e2919ed53c8d20a3"
            ),
            "screenshot_width": 393,
            "visible_root_dock_glyphs": ["Goals", "Time", "Today", "You"],
            "visual_authority_id": "VA-P4-CANDIDATE-005",
        },
    }
    repair_ids = tuple(item.get("visual_authority_id") for item in presentation_repairs)
    if repair_ids != tuple(sorted(expected_presentation_repairs)):
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            "R1 presentation repairs are incomplete or unsorted",
        )
    for item in presentation_repairs:
        authority_id = _string(
            item.get("visual_authority_id"), "presentation repair authority ID"
        )
        expected = expected_presentation_repairs[authority_id]
        _r1_exact_fields(
            item,
            frozenset(expected),
            "R1 presentation repair",
        )
        screenshot_path = Path(
            _string(item.get("screenshot_path"), "presentation screenshot path")
        )
        screenshot = _read_regular_nofollow(root, screenshot_path)
        if (
            item != expected
            or hashlib.sha256(screenshot).hexdigest()
            != item.get("screenshot_sha256")
            or _png_dimensions(screenshot)
            != (item.get("screenshot_width"), item.get("screenshot_height"))
        ):
            raise _error(
                "VISUAL_AUTHORITY_R1_PROOF_INVALID",
                f"R1 presentation repair proof is stale: {authority_id}",
            )
    representative_pairs = (
        (
            "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
            "repair/screens/266-1424-today-populated-light.png",
            expected_presentation_repairs["VA-P4-CANDIDATE-001"]["screenshot_path"],
        ),
        (
            "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
            "repair/screens/272-1424-goals-root-light.png",
            expected_presentation_repairs["VA-P4-CANDIDATE-003"]["screenshot_path"],
        ),
        (
            "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
            "repair/screens/275-1424-time-day-light.png",
            "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
            "repair/screens/task-pack/va-p4-candidate-004-viewport.png",
        ),
        (
            "docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-"
            "repair/screens/278-1449-you-root-light.png",
            expected_presentation_repairs["VA-P4-CANDIDATE-005"]["screenshot_path"],
        ),
    )
    if any(
        _read_regular_nofollow(root, Path(representative))
        != _read_regular_nofollow(root, Path(task_pack))
        for representative, task_pack in representative_pairs
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_PROOF_INVALID",
            "R1 representative and task-pack screenshots are not byte-identical",
        )

    replacements = tuple(
        _object(value, "pixel-equivalent replacement")
        for value in _list(
            snapshot.get("pixel_equivalent_replacements"),
            "pixel-equivalent replacements",
        )
    )
    if len(replacements) != 1:
        raise _error(
            "VISUAL_AUTHORITY_R1_PROOF_INVALID",
            "R1 replacement proof is missing or ambiguous",
        )
    replacement = replacements[0]
    _r1_exact_fields(
        replacement,
        frozenset(
            {
                "after_render",
                "audit_conclusion",
                "before_render",
                "frame_id",
                "non_destructive",
                "normalized_old_nodes",
                "normalized_properties_sha256",
                "normalized_replacement_nodes",
                "old_hidden_node_ids",
                "pixel_equivalent",
                "raw_node_pairs",
                "replacement_node_ids",
                "visible_capture_node_ids",
                "visible_search_node_ids",
            }
        ),
        "R1 pixel-equivalent replacement",
    )
    before_render = _object(replacement.get("before_render"), "before render")
    after_render = _object(replacement.get("after_render"), "after render")
    for render in (before_render, after_render):
        _r1_exact_fields(
            render,
            frozenset({"path", "sha256"}),
            "R1 replacement render",
        )
    raw_pairs = tuple(
        _object(value, "R1 replacement node pair")
        for value in _list(replacement.get("raw_node_pairs"), "replacement node pairs")
    )
    for pair in raw_pairs:
        _r1_exact_fields(
            pair,
            frozenset(
                {
                    "old_node_id",
                    "old_node_type",
                    "old_visible",
                    "replacement_node_id",
                    "replacement_node_type",
                    "replacement_visible",
                    "role",
                }
            ),
            "R1 replacement node pair",
        )
    normalized_old = tuple(
        _object(value, "R1 normalized old node")
        for value in _list(
            replacement.get("normalized_old_nodes"), "normalized old nodes"
        )
    )
    normalized_new = tuple(
        _object(value, "R1 normalized replacement node")
        for value in _list(
            replacement.get("normalized_replacement_nodes"),
            "normalized replacement nodes",
        )
    )
    normalized_node_fields = frozenset(
        {
            "component_id",
            "fill_paints",
            "geometry",
            "opacity",
            "role",
            "shape_kind",
            "stroke_paints",
            "stroke_weight",
            "vectors",
        }
    )
    paint_fields = frozenset({"color", "opacity", "type"})
    vector_fields = frozenset(
        {"geometry", "paths", "stroke_paints", "stroke_weight"}
    )
    for node in (*normalized_old, *normalized_new):
        _r1_exact_fields(node, normalized_node_fields, "R1 normalized node")
        for paint_value in (
            *_list(node.get("fill_paints"), "normalized fill paints"),
            *_list(node.get("stroke_paints"), "normalized stroke paints"),
        ):
            _r1_exact_fields(
                _object(paint_value, "normalized paint"),
                paint_fields,
                "R1 normalized paint",
            )
        for vector_value in _list(node.get("vectors"), "normalized vectors"):
            vector = _object(vector_value, "normalized vector")
            _r1_exact_fields(vector, vector_fields, "R1 normalized vector")
            for paint_value in _list(
                vector.get("stroke_paints"), "normalized vector stroke paints"
            ):
                _r1_exact_fields(
                    _object(paint_value, "normalized vector paint"),
                    paint_fields,
                    "R1 normalized vector paint",
                )
    normalized_digest = hashlib.sha256(
        json.dumps(
            list(normalized_old),
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        ).encode("utf-8")
    ).hexdigest()
    before_path = Path(_string(before_render.get("path"), "before render path"))
    after_path = Path(_string(after_render.get("path"), "after render path"))
    before_sha = _sha(before_render.get("sha256"), 64, "before render SHA")
    after_sha = _sha(after_render.get("sha256"), 64, "after render SHA")
    if (
        replacement.get("frame_id") != "270:1430"
        or replacement.get("visible_search_node_ids") != ["359:243"]
        or replacement.get("visible_capture_node_ids") != ["359:248"]
        or replacement.get("old_hidden_node_ids")
        != ["354:2517", "354:2518", "354:2522", "354:2523"]
        or replacement.get("replacement_node_ids")
        != ["359:242", "359:243", "359:247", "359:248"]
        or replacement.get("pixel_equivalent") is not True
        or replacement.get("non_destructive") is not True
        or tuple(item.get("old_visible") for item in raw_pairs)
        != (False, False, False, False)
        or tuple(item.get("replacement_visible") for item in raw_pairs)
        != (True, True, True, True)
        or normalized_old != normalized_new
        or replacement.get("normalized_properties_sha256") != normalized_digest
        or before_path == after_path
        or before_sha != after_sha
        or hashlib.sha256(_read_regular_nofollow(root, before_path)).hexdigest()
        != before_sha
        or hashlib.sha256(_read_regular_nofollow(root, after_path)).hexdigest()
        != after_sha
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_PROOF_INVALID",
            "R1 visible-node uniqueness or pixel-equivalent render proof is stale",
        )


def _validate_screenshot_records(
    root: Path,
    value: object,
    *,
    expected_count: int,
    valid_node_ids: set[str],
    legacy: bool,
) -> None:
    records = tuple(_object(item, "screenshot") for item in _list(value, "screenshots"))
    if len(records) != expected_count:
        raise _error(
            "VISUAL_AUTHORITY_SCREENSHOT_INVALID",
            f"expected {expected_count} durable screenshot bindings",
        )
    paths: set[str] = set()
    for record in records:
        node_id = _string(record.get("node_id"), "screenshot node ID")
        if node_id not in valid_node_ids:
            raise _error(
                "VISUAL_AUTHORITY_SCREENSHOT_INVALID",
                f"screenshot node does not resolve: {node_id}",
            )
        relative = _string(record.get("path"), "screenshot path")
        if relative in paths:
            raise _error(
                "VISUAL_AUTHORITY_SCREENSHOT_INVALID",
                "screenshot paths must be unique",
            )
        paths.add(relative)
        content = _read_regular_nofollow(root, Path(relative))
        if hashlib.sha256(content).hexdigest() != _sha(
            record.get("sha256"), 64, "screenshot SHA"
        ):
            raise _error(
                "VISUAL_AUTHORITY_SCREENSHOT_INVALID",
                f"screenshot digest is stale: {relative}",
            )
        if legacy and record.get("proof_posture") != "before_only_not_applied_mutation_proof":
            raise _error(
                "VISUAL_AUTHORITY_SCREENSHOT_INVALID",
                "legacy screenshots may prove before-state only",
            )


def _read_regular_nofollow(root: Path, relative_path: Path) -> bytes:
    if relative_path.is_absolute() or not relative_path.parts or ".." in relative_path.parts:
        raise _error("VISUAL_AUTHORITY_PATH_INVALID", "path must stay inside repository")
    context = _ACTIVE_OPERATION.get()
    if context is not None:
        return _captured_input_bytes(context, relative_path)
    if relative_path == REQUIREMENT_DISPOSITIONS_PATH:
        return _read_projection_output_locked(root, relative_path)
    path = root / relative_path
    try:
        info = path.lstat()
    except OSError as exc:
        raise CanonError(
            "VISUAL_AUTHORITY_READ_FAILED",
            f"unable to read required visual-authority artifact: {relative_path}",
            path,
        ) from exc
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
        raise CanonError(
            "VISUAL_AUTHORITY_PATH_INVALID",
            "visual-authority artifacts must be regular non-symlink files",
            path,
        )
    try:
        return _read_confined_bytes(root, relative_path)
    except (OSError, CanonError) as exc:
        raise CanonError(
            "VISUAL_AUTHORITY_READ_FAILED",
            f"unable to read visual-authority artifact: {relative_path}",
            path,
        ) from exc


def _load_json_object(root: Path, relative_path: Path) -> Mapping[str, object]:
    content = _read_regular_nofollow(root, relative_path)
    try:
        return _object(json.loads(content), relative_path.as_posix())
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise _error(
            "VISUAL_AUTHORITY_READ_FAILED",
            f"invalid JSON input: {relative_path}",
        ) from exc


def _exact_fields(value: Mapping[str, object], expected: frozenset[str], name: str) -> None:
    if set(value) != expected:
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID",
            f"{name} fields do not match schema version 1",
        )


def _r1_exact_fields(
    value: Mapping[str, object], expected: frozenset[str], name: str
) -> None:
    if set(value) != expected:
        raise _error(
            "VISUAL_AUTHORITY_R1_SNAPSHOT_INVALID",
            f"{name} fields do not match the closed R1 snapshot contract",
        )


def _png_dimensions(content: bytes) -> tuple[int, int]:
    if (
        len(content) < 24
        or content[:8] != b"\x89PNG\r\n\x1a\n"
        or content[12:16] != b"IHDR"
    ):
        raise _error(
            "VISUAL_AUTHORITY_R1_PROOF_INVALID",
            "R1 screenshot proof is not a valid PNG",
        )
    return (
        int.from_bytes(content[16:20], "big"),
        int.from_bytes(content[20:24], "big"),
    )


def _object(value: object, name: str) -> Mapping[str, object]:
    if not isinstance(value, Mapping):
        raise _error("VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be an object")
    return value


def _list(value: object, name: str) -> Sequence[object]:
    if not isinstance(value, list):
        raise _error("VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be an array")
    return value


def _string(value: object, name: str) -> str:
    if not isinstance(value, str) or not value.strip() or value != value.strip():
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be a normalized string"
        )
    return value


def _integer(value: object, name: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be a nonnegative integer"
        )
    return value


def _sha(value: object, length: int, name: str) -> str:
    sha = _string(value, name)
    if len(sha) != length or not set(sha).issubset(_SHA256):
        raise _error("VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} is invalid")
    return sha


def _sorted_unique_strings(value: object, name: str) -> tuple[str, ...]:
    strings = tuple(_string(item, name) for item in _list(value, name))
    if strings != tuple(sorted(strings)) or len(set(strings)) != len(strings):
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be sorted and unique"
        )
    return strings


def _unique_strings_preserve_order(value: object, name: str) -> tuple[str, ...]:
    strings = tuple(_string(item, name) for item in _list(value, name))
    if len(set(strings)) != len(strings):
        raise _error(
            "VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} must be unique"
        )
    return strings


def _nonempty_strings(value: Iterable[str], name: str) -> tuple[str, ...]:
    strings = tuple(value)
    if any(not isinstance(item, str) or not item.strip() for item in strings):
        raise _error("VISUAL_AUTHORITY_SCHEMA_INVALID", f"{name} are invalid")
    return strings


def _error(code: str, message: str) -> CanonError:
    return CanonError(code, message, MANIFEST_PATH)
