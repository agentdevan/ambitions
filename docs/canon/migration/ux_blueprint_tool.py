"""Deterministic validation and projection for the visual-rebaseline UX blueprint.

The blueprint is a requirement-linked design input.  It is deliberately outside
the normative specification atlas and cannot activate canon or visual authority.
"""

from __future__ import annotations

import json
import hashlib
import os
import tempfile
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping


BLUEPRINT_PATH = Path("docs/canon/migration/ux-blueprint.json")
PROJECTION_PATH = Path("docs/canon/migration/UX_BLUEPRINT.md")
DISPOSITIONS_PATH = Path(
    "docs/canon/migration/ux-blueprint-requirement-dispositions.json"
)
REQUIREMENT_GRAPH_PATH = Path("docs/canon/generated/requirement-graph.json")
CANON_INDEX_PATH = Path("docs/canon/generated/canon-index.json")
APPROVED_SOURCE_SHA = "002fd07b795173c1c8590c0be986fc1e31569416"
PRIMARY_LINEAR_V3_ID = "96b93346-271d-46fc-beab-43ff7e286b5d"
PRIMARY_LINEAR_V3_TITLE = (
    "B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical"
)
CLAIM_CEILING = (
    "Visual design input only; no source, runtime, rendered-app, accessibility, "
    "device, privacy/legal, distribution, or release claim."
)
REQUIRED_SCOPES = frozenset(
    {
        "account",
        "app-shell",
        "capture",
        "goals",
        "offline-degraded",
        "permissions",
        "search",
        "setup",
        "time",
        "today",
        "trust",
        "you",
    }
)
REQUIRED_STATE_KINDS = frozenset(
    {
        "resting",
        "loading",
        "transitional",
        "empty",
        "degraded",
        "failure",
        "recovery",
        "rollback",
        "interruption",
    }
)
REQUIRED_ACCESSIBILITY_FACETS = frozenset(
    {
        "dynamic-type",
        "focus-keyboard",
        "localization-long-copy",
        "non-color-semantics",
        "reduce-motion",
        "reduce-transparency",
        "voiceover-reading-order",
    }
)
REQUIRED_OBJECT_IDS = frozenset(
    {
        "attachment",
        "closure",
        "event",
        "goal",
        "goal-path",
        "history-event",
        "import-diff-record",
        "life-area",
        "note",
        "notification-rule",
        "proof",
        "receipt",
        "recovery-segment",
        "reminder",
        "saved-for-later-draft",
        "schedule-placement",
        "source-reference",
        "step",
    }
)
LEGACY_FIGMA_ROLES = (
    "exploration",
    "failure_evidence",
    "implementation_history",
    "provenance",
    "unique_content_source",
)
PLACEHOLDER = re.compile(r"(?<!\w)(?:TBD|TODO|implement later)(?!\w)", re.IGNORECASE)

TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "blueprint_id",
        "title",
        "status",
        "authority_state",
        "canon_revision",
        "canon_content_sha",
        "source_sha",
        "source_documents",
        "primary_linear_v3",
        "requirement_disposition_policy",
        "legacy_figma_policy",
        "claim_ceiling",
        "screens",
        "state_models",
        "object_boundaries",
        "journeys",
        "cross_cutting",
    }
)
SCREEN_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "scope",
        "purpose",
        "entry",
        "exit",
        "presentation",
        "objects",
        "state_model_id",
        "requirement_ids",
        "accessibility",
        "swiftui_anatomy",
        "implementation_status",
        "proof_ceiling",
    }
)
STATE_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "applies_to",
        "state_kinds",
        "behavior",
        "recovery",
        "requirement_ids",
    }
)
OBJECT_FIELDS = frozenset(
    {
        "blueprint_id",
        "object_id",
        "title",
        "presentation_boundaries",
        "create",
        "detail",
        "edit",
        "delete_restore",
        "history_inspection",
        "requirement_ids",
    }
)
JOURNEY_FIELDS = frozenset(
    {
        "blueprint_id",
        "title",
        "trigger",
        "preconditions",
        "happy_path",
        "branches",
        "cancellation",
        "interruption_resume",
        "commit_boundary",
        "failure",
        "recovery",
        "rollback",
        "offline",
        "accessibility",
        "tests",
        "requirement_ids",
    }
)
CROSS_CUTTING_FIELDS = frozenset(
    {
        "blueprint_id",
        "facet",
        "title",
        "contract",
        "variants",
        "requirement_ids",
    }
)


class UXBlueprintError(ValueError):
    """A deterministic blueprint-contract failure."""


@dataclass(frozen=True, slots=True)
class UXBlueprintSummary:
    screen_count: int
    state_model_count: int
    object_boundary_count: int
    journey_count: int
    cross_cutting_count: int
    requirement_link_count: int
    scope_ids: tuple[str, ...]
    state_kinds: tuple[str, ...]
    accessibility_facets: tuple[str, ...]
    object_ids: tuple[str, ...]
    disposition_count: int
    visual_mapping_count: int
    nonvisual_count: int
    disposition_sha256: str


def load_ux_blueprint(root: Path) -> dict[str, object]:
    path = root / BLUEPRINT_PATH
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load UX blueprint: {error}") from error
    if not isinstance(payload, dict):
        raise UXBlueprintError("UX blueprint root must be an object")
    return payload


def _object(value: object, label: str) -> dict[str, object]:
    if not isinstance(value, dict):
        raise UXBlueprintError(f"{label} must be an object")
    return value


def _records(value: object, label: str) -> list[dict[str, object]]:
    if not isinstance(value, list) or not value:
        raise UXBlueprintError(f"{label} must be a non-empty array")
    result: list[dict[str, object]] = []
    for index, item in enumerate(value):
        result.append(_object(item, f"{label}[{index}]"))
    return result


def _string(value: object, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise UXBlueprintError(f"{label} must be a non-empty string")
    return value


def _strings(value: object, label: str, *, sorted_unique: bool = False) -> tuple[str, ...]:
    if not isinstance(value, list) or not value:
        raise UXBlueprintError(f"{label} must be a non-empty string array")
    items = tuple(_string(item, label) for item in value)
    if sorted_unique and items != tuple(sorted(set(items))):
        raise UXBlueprintError(f"{label} must be sorted and unique")
    return items


def _linked_ids(value: object, label: str) -> tuple[str, ...]:
    items = _strings(value, label)
    if len(items) != len(set(items)):
        raise UXBlueprintError(f"{label} must be unique")
    return items


def _closed(record: Mapping[str, object], expected: frozenset[str], label: str) -> None:
    fields = frozenset(record)
    if fields != expected:
        missing = sorted(expected - fields)
        extra = sorted(fields - expected)
        raise UXBlueprintError(
            f"{label} fields are closed; missing={missing} extra={extra}"
        )


def _sorted_unique_records(records: Iterable[Mapping[str, object]], label: str) -> tuple[str, ...]:
    identifiers = tuple(_string(item.get("blueprint_id"), f"{label}.blueprint_id") for item in records)
    if len(identifiers) != len(set(identifiers)):
        raise UXBlueprintError(f"duplicate blueprint ID in {label}")
    if identifiers != tuple(sorted(identifiers)):
        raise UXBlueprintError(f"{label} must be sorted by blueprint_id")
    return identifiers


def _walk_strings(value: object) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for child in value.values():
            yield from _walk_strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from _walk_strings(child)


def _requirement_ids(root: Path) -> tuple[frozenset[str], str, int, str]:
    graph_path = root / REQUIREMENT_GRAPH_PATH
    try:
        graph = json.loads(graph_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load requirement graph: {error}") from error
    graph = _object(graph, "requirement graph")
    ids = _strings(graph.get("requirement_ids"), "requirement graph IDs", sorted_unique=True)
    return (
        frozenset(ids),
        _string(graph.get("canon_content_sha"), "canon content SHA"),
        int(graph.get("canon_revision", 0)),
        _string(graph.get("authority_state"), "canon authority state"),
    )


def _requirement_records(root: Path) -> tuple[dict[str, object], ...]:
    path = root / CANON_INDEX_PATH
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise UXBlueprintError(f"cannot load canon index: {error}") from error
    payload = _object(payload, "canon index")
    records = _records(payload.get("requirements"), "canon index requirements")
    return tuple(records)


def build_requirement_dispositions(
    root: Path,
    blueprint: Mapping[str, object],
    known_blueprint_ids: frozenset[str],
) -> tuple[dict[str, object], ...]:
    """Classify every current requirement exactly once from a compact source policy."""

    policy = _object(
        blueprint.get("requirement_disposition_policy"),
        "requirement disposition policy",
    )
    if set(policy) != {"visual_source_routes", "nonvisual_sources"}:
        raise UXBlueprintError("requirement disposition policy fields are closed")
    routes = _records(policy.get("visual_source_routes"), "visual source routes")
    nonvisual = _records(policy.get("nonvisual_sources"), "nonvisual sources")

    route_prefixes: list[str] = []
    route_blueprints: dict[str, tuple[str, ...]] = {}
    for route in routes:
        if set(route) != {"source_prefix", "blueprint_ids"}:
            raise UXBlueprintError("visual source route fields are closed")
        prefix = _string(route.get("source_prefix"), "visual source prefix")
        ids = _strings(route.get("blueprint_ids"), "visual route blueprint IDs", sorted_unique=True)
        unknown_ids = sorted(set(ids) - known_blueprint_ids)
        if unknown_ids:
            raise UXBlueprintError(f"visual route references unknown blueprint IDs: {unknown_ids}")
        route_prefixes.append(prefix)
        route_blueprints[prefix] = ids
    if tuple(route_prefixes) != tuple(sorted(set(route_prefixes))):
        raise UXBlueprintError("visual source routes must be sorted and unique")

    nonvisual_paths: list[str] = []
    nonvisual_rationale: dict[str, str] = {}
    for item in nonvisual:
        if set(item) != {"source_path", "rationale"}:
            raise UXBlueprintError("nonvisual source fields are closed")
        source_path = _string(item.get("source_path"), "nonvisual source path")
        rationale = _string(item.get("rationale"), "nonvisual rationale")
        nonvisual_paths.append(source_path)
        nonvisual_rationale[source_path] = rationale
    if tuple(nonvisual_paths) != tuple(sorted(set(nonvisual_paths))):
        raise UXBlueprintError("nonvisual sources must be sorted and unique")

    requirements = _requirement_records(root)
    source_paths = {
        _string(item.get("source_path"), "requirement source path")
        for item in requirements
    }
    for prefix in route_prefixes:
        if not any(path.startswith(prefix) for path in source_paths):
            raise UXBlueprintError(f"unknown disposition source prefix: {prefix}")
    unknown_nonvisual = sorted(set(nonvisual_paths) - source_paths)
    if unknown_nonvisual:
        raise UXBlueprintError(f"unknown disposition source path: {unknown_nonvisual}")

    dispositions: list[dict[str, object]] = []
    seen: set[str] = set()
    for requirement in sorted(
        requirements,
        key=lambda item: _string(item.get("requirement_id"), "requirement_id"),
    ):
        requirement_id = _string(requirement.get("requirement_id"), "requirement_id")
        source_path = _string(requirement.get("source_path"), "requirement source path")
        matches = [prefix for prefix in route_prefixes if source_path.startswith(prefix)]
        if source_path in nonvisual_rationale:
            matches.append(source_path)
        if not matches:
            raise UXBlueprintError(
                f"missing requirement disposition: {requirement_id} from {source_path}"
            )
        if len(matches) != 1:
            raise UXBlueprintError(
                f"duplicate requirement disposition: {requirement_id} matches {matches}"
            )
        if requirement_id in seen:
            raise UXBlueprintError(f"duplicate requirement disposition ID: {requirement_id}")
        seen.add(requirement_id)
        if source_path in nonvisual_rationale:
            dispositions.append(
                {
                    "requirement_id": requirement_id,
                    "source_path": source_path,
                    "disposition": "nonvisual_with_rationale",
                    "rationale": nonvisual_rationale[source_path],
                }
            )
        else:
            prefix = matches[0]
            dispositions.append(
                {
                    "requirement_id": requirement_id,
                    "source_path": source_path,
                    "disposition": "visual_mapping_required",
                    "blueprint_ids": list(route_blueprints[prefix]),
                }
            )
    if len(dispositions) != len(requirements):
        raise UXBlueprintError("requirement disposition count is incomplete")
    return tuple(dispositions)


def _disposition_bytes(dispositions: tuple[dict[str, object], ...]) -> bytes:
    return (
        json.dumps(dispositions, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("utf-8")


def render_requirement_dispositions(
    root: Path, blueprint: Mapping[str, object]
) -> bytes:
    record_groups = (
        blueprint["screens"],
        blueprint["state_models"],
        blueprint["object_boundaries"],
        blueprint["journeys"],
        blueprint["cross_cutting"],
    )
    all_ids = frozenset(item["blueprint_id"] for group in record_groups for item in group)
    dispositions = build_requirement_dispositions(root, blueprint, all_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual_count = sum(
        item["disposition"] == "visual_mapping_required" for item in dispositions
    )
    payload = {
        "schema_version": 1,
        "blueprint_id": blueprint["blueprint_id"],
        "authority_state": blueprint["authority_state"],
        "canon_revision": blueprint["canon_revision"],
        "canon_content_sha": blueprint["canon_content_sha"],
        "source_sha": blueprint["source_sha"],
        "requirement_count": len(dispositions),
        "visual_mapping_count": visual_count,
        "nonvisual_count": len(dispositions) - visual_count,
        "disposition_sha256": hashlib.sha256(disposition_bytes).hexdigest(),
        "dispositions": list(dispositions),
        "claim_ceiling": blueprint["claim_ceiling"],
    }
    return (json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode(
        "utf-8"
    )


def validate_ux_blueprint(root: Path, blueprint: Mapping[str, object]) -> UXBlueprintSummary:
    _closed(blueprint, TOP_LEVEL_FIELDS, "top-level fields")
    if blueprint.get("schema_version") != 1:
        raise UXBlueprintError("schema_version must be 1")
    if blueprint.get("status") != "design_input_non_authoritative":
        raise UXBlueprintError("blueprint status must remain non-authoritative")
    if blueprint.get("authority_state") != "shadow":
        raise UXBlueprintError("blueprint and canon must remain shadow")
    if blueprint.get("source_sha") != APPROVED_SOURCE_SHA:
        raise UXBlueprintError("source SHA does not match the approved rebaseline input")
    if blueprint.get("claim_ceiling") != CLAIM_CEILING:
        raise UXBlueprintError("claim ceiling exceeds the approved design-input scope")

    source_documents = _strings(
        blueprint.get("source_documents"), "source documents", sorted_unique=True
    )
    for source_document in source_documents:
        source_path = Path(source_document)
        if source_path.is_absolute() or ".." in source_path.parts:
            raise UXBlueprintError(f"source document path is unsafe: {source_document}")
        if not (root / source_path).exists():
            raise UXBlueprintError(f"source document does not exist: {source_document}")

    known_requirements, canon_sha, canon_revision, authority_state = _requirement_ids(root)
    if blueprint.get("canon_content_sha") != canon_sha:
        raise UXBlueprintError("canon content SHA is stale")
    if blueprint.get("canon_revision") != canon_revision:
        raise UXBlueprintError("canon revision is stale")
    if authority_state != "shadow":
        raise UXBlueprintError("requirement graph authority must remain shadow")

    linear = _object(blueprint.get("primary_linear_v3"), "primary Linear V3")
    if set(linear) != {"document_id", "title", "disposition"}:
        raise UXBlueprintError("primary Linear V3 fields are closed")
    if (
        linear.get("document_id") != PRIMARY_LINEAR_V3_ID
        or linear.get("title") != PRIMARY_LINEAR_V3_TITLE
        or linear.get("disposition") != "migration_corpus_unchanged"
    ):
        raise UXBlueprintError("primary Linear V3 must remain unchanged migration corpus")

    legacy = _object(blueprint.get("legacy_figma_policy"), "legacy Figma policy")
    if set(legacy) != {"rejected_as_final_target", "allowed_roles", "destructive_actions"}:
        raise UXBlueprintError("legacy Figma policy fields are closed")
    roles = _strings(legacy.get("allowed_roles"), "legacy Figma roles", sorted_unique=True)
    if (
        legacy.get("rejected_as_final_target") is not True
        or roles != LEGACY_FIGMA_ROLES
        or legacy.get("destructive_actions") != "withheld_gate_c"
    ):
        raise UXBlueprintError("legacy Figma cannot be treated as final authority")

    for text in _walk_strings(blueprint):
        if PLACEHOLDER.search(text):
            raise UXBlueprintError(f"placeholder language is forbidden: {text!r}")

    screens = _records(blueprint.get("screens"), "screens")
    states = _records(blueprint.get("state_models"), "state models")
    objects = _records(blueprint.get("object_boundaries"), "object boundaries")
    journeys = _records(blueprint.get("journeys"), "journeys")
    cross = _records(blueprint.get("cross_cutting"), "cross-cutting records")
    screen_ids = _sorted_unique_records(screens, "screens")
    state_ids = _sorted_unique_records(states, "state models")
    _sorted_unique_records(objects, "object boundaries")
    _sorted_unique_records(journeys, "journeys")
    _sorted_unique_records(cross, "cross-cutting records")
    all_blueprint_ids = frozenset(
        item["blueprint_id"]
        for records in (screens, states, objects, journeys, cross)
        for item in records
    )

    linked_requirements: list[str] = []
    scopes: set[str] = set()
    referenced_state_models: set[str] = set()
    for screen in screens:
        _closed(screen, SCREEN_FIELDS, "screen fields")
        if screen.get("implementation_status") != "design_input_only":
            raise UXBlueprintError("screen implementation status must remain design input only")
        scopes.add(_string(screen.get("scope"), "screen scope"))
        state_id = _string(screen.get("state_model_id"), "screen state model")
        if state_id not in state_ids:
            raise UXBlueprintError(f"screen references unknown state model: {state_id}")
        referenced_state_models.add(state_id)
        screen_objects = _strings(screen.get("objects"), "screen objects")
        if len(screen_objects) != len(set(screen_objects)):
            raise UXBlueprintError("screen objects must be unique")
        screen_accessibility = _strings(screen.get("accessibility"), "screen accessibility")
        if len(screen_accessibility) != len(set(screen_accessibility)):
            raise UXBlueprintError("screen accessibility entries must be unique")
        linked_requirements.extend(
            _linked_ids(screen.get("requirement_ids"), "screen requirement IDs")
        )
    if scopes != REQUIRED_SCOPES:
        raise UXBlueprintError(f"screen scopes are incomplete or invented: {sorted(scopes)}")
    if referenced_state_models != set(state_ids):
        raise UXBlueprintError("every state model must be used by at least one screen")

    covered_screens: set[str] = set()
    state_kinds: set[str] = set()
    for state in states:
        _closed(state, STATE_FIELDS, "state model fields")
        applies_to = _strings(state.get("applies_to"), "state applies_to", sorted_unique=True)
        unknown_screens = set(applies_to) - set(screen_ids)
        if unknown_screens:
            raise UXBlueprintError(f"state model references unknown screens: {sorted(unknown_screens)}")
        covered_screens.update(applies_to)
        kinds = _strings(state.get("state_kinds"), "state kinds", sorted_unique=True)
        if set(kinds) != REQUIRED_STATE_KINDS:
            raise UXBlueprintError("each state model must cover the complete state taxonomy")
        state_kinds.update(kinds)
        linked_requirements.extend(
            _linked_ids(state.get("requirement_ids"), "state requirement IDs")
        )
    if covered_screens != set(screen_ids):
        raise UXBlueprintError("every screen must be covered by a complete state model")

    object_ids: set[str] = set()
    for item in objects:
        _closed(item, OBJECT_FIELDS, "object boundary fields")
        object_ids.add(_string(item.get("object_id"), "object_id"))
        linked_requirements.extend(
            _linked_ids(item.get("requirement_ids"), "object requirement IDs")
        )
    if object_ids != REQUIRED_OBJECT_IDS:
        raise UXBlueprintError("canonical object boundaries are incomplete or invented")

    for journey in journeys:
        _closed(journey, JOURNEY_FIELDS, "journey fields")
        _strings(journey.get("preconditions"), "journey preconditions")
        _strings(journey.get("happy_path"), "journey happy path")
        _strings(journey.get("branches"), "journey branches")
        _strings(journey.get("tests"), "journey tests")
        linked_requirements.extend(
            _linked_ids(journey.get("requirement_ids"), "journey requirement IDs")
        )

    facets: set[str] = set()
    for item in cross:
        _closed(item, CROSS_CUTTING_FIELDS, "cross-cutting fields")
        facets.add(_string(item.get("facet"), "cross-cutting facet"))
        _strings(item.get("variants"), "cross-cutting variants", sorted_unique=True)
        linked_requirements.extend(
            _linked_ids(item.get("requirement_ids"), "cross-cutting requirement IDs")
        )
    if not REQUIRED_ACCESSIBILITY_FACETS.issubset(facets):
        raise UXBlueprintError("required accessibility facets are incomplete")

    unknown_requirements = sorted(set(linked_requirements) - known_requirements)
    if unknown_requirements:
        raise UXBlueprintError(f"unknown requirement IDs: {unknown_requirements}")

    if len(screens) != 40 or len(states) != 16 or len(objects) != 18 or len(journeys) != 12 or len(cross) != 10:
        raise UXBlueprintError("blueprint inventory counts are stale")

    dispositions = build_requirement_dispositions(root, blueprint, all_blueprint_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual_mapping_count = sum(
        item["disposition"] == "visual_mapping_required" for item in dispositions
    )
    nonvisual_count = len(dispositions) - visual_mapping_count

    return UXBlueprintSummary(
        screen_count=len(screens),
        state_model_count=len(states),
        object_boundary_count=len(objects),
        journey_count=len(journeys),
        cross_cutting_count=len(cross),
        requirement_link_count=len(linked_requirements),
        scope_ids=tuple(sorted(scopes)),
        state_kinds=tuple(sorted(state_kinds)),
        accessibility_facets=tuple(sorted(REQUIRED_ACCESSIBILITY_FACETS)),
        object_ids=tuple(sorted(object_ids)),
        disposition_count=len(dispositions),
        visual_mapping_count=visual_mapping_count,
        nonvisual_count=nonvisual_count,
        disposition_sha256=hashlib.sha256(disposition_bytes).hexdigest(),
    )


def render_ux_blueprint_markdown(
    blueprint: Mapping[str, object], root: Path | None = None
) -> bytes:
    """Render the already-validated source in a stable human-reviewable form."""

    # Rendering is only called after validation in checked workflows; recalculate
    # the source-policy projection with the repository data recorded in the input.
    if root is None:
        root = Path(__file__).resolve().parents[3]
    record_groups = (
        blueprint["screens"],
        blueprint["state_models"],
        blueprint["object_boundaries"],
        blueprint["journeys"],
        blueprint["cross_cutting"],
    )
    all_ids = frozenset(item["blueprint_id"] for group in record_groups for item in group)
    dispositions = build_requirement_dispositions(root, blueprint, all_ids)
    disposition_bytes = _disposition_bytes(dispositions)
    visual = sum(item["disposition"] == "visual_mapping_required" for item in dispositions)
    disposition_line = (
        f"- Requirement dispositions: `{len(dispositions)}` total; `{visual}` visual; "
        f"`{len(dispositions) - visual}` nonvisual; SHA-256 "
        f"`{hashlib.sha256(disposition_bytes).hexdigest()}`"
    )
    lines = [
        "# Ambitions Canonical UX Blueprint",
        "",
        "> Shadow, non-authoritative visual-rebaseline design input.",
        "> It does not change product law, implementation state, or release proof.",
        "",
        f"- Blueprint ID: `{blueprint['blueprint_id']}`",
        f"- Canon revision: `{blueprint['canon_revision']}`",
        f"- Canon content SHA: `{blueprint['canon_content_sha']}`",
        f"- Source SHA: `{blueprint['source_sha']}`",
        f"- Authority state: `{blueprint['authority_state']}`",
        disposition_line,
        f"- Claim ceiling: {blueprint['claim_ceiling']}",
        "",
        "## Screens and presentations",
        "",
        "| Blueprint ID | Scope | Screen / state owner | Presentation | Requirements |",
        "| --- | --- | --- | --- | --- |",
    ]
    for screen in blueprint["screens"]:  # type: ignore[index]
        requirements = ", ".join(f"`{item}`" for item in screen["requirement_ids"])
        lines.append(
            f"| `{screen['blueprint_id']}` | `{screen['scope']}` | {screen['title']} | "
            f"{screen['presentation']} | {requirements} |"
        )
    lines.extend(
        [
            "",
            "## Complete state models",
            "",
            "Each model covers resting, loading, transitional, empty, degraded, "
            "failure, recovery, rollback, and interruption states.",
            "",
            "| Blueprint ID | Applies to | Recovery contract | Requirements |",
            "| --- | --- | --- | --- |",
        ]
    )
    for state in blueprint["state_models"]:  # type: ignore[index]
        screens = ", ".join(f"`{item}`" for item in state["applies_to"])
        requirements = ", ".join(f"`{item}`" for item in state["requirement_ids"])
        lines.append(
            f"| `{state['blueprint_id']}` | {screens} | {state['recovery']} | {requirements} |"
        )
    lines.extend(
        [
            "",
            "## Canonical object boundaries",
            "",
            "| Object | Presentation boundary | Delete / restore | Requirements |",
            "| --- | --- | --- | --- |",
        ]
    )
    for item in blueprint["object_boundaries"]:  # type: ignore[index]
        requirements = ", ".join(f"`{req}`" for req in item["requirement_ids"])
        lines.append(
            f"| `{item['object_id']}` | {item['presentation_boundaries']} | "
            f"{item['delete_restore']} | {requirements} |"
        )
    lines.extend(
        [
            "",
            "## Principal journeys",
            "",
            "| Blueprint ID | Journey | Commit boundary | Recovery / rollback | Requirements |",
            "| --- | --- | --- | --- | --- |",
        ]
    )
    for journey in blueprint["journeys"]:  # type: ignore[index]
        requirements = ", ".join(f"`{req}`" for req in journey["requirement_ids"])
        lines.append(
            f"| `{journey['blueprint_id']}` | {journey['title']} | "
            f"{journey['commit_boundary']} | {journey['recovery']} {journey['rollback']} | "
            f"{requirements} |"
        )
    lines.extend(
        [
            "",
            "## Cross-cutting design contracts",
            "",
            "| Facet | Contract | Variants | Requirements |",
            "| --- | --- | --- | --- |",
        ]
    )
    for item in blueprint["cross_cutting"]:  # type: ignore[index]
        variants = ", ".join(item["variants"])
        requirements = ", ".join(f"`{req}`" for req in item["requirement_ids"])
        lines.append(f"| `{item['facet']}` | {item['contract']} | {variants} | {requirements} |")
    lines.extend(
        [
            "",
            "## Authority and proof boundary",
            "",
            "The primary Linear V3 document remains unchanged migration corpus. Legacy Figma "
            "may be used only as provenance, exploration, failure evidence, implementation "
            "history, or a unique-content source pending extraction. It is rejected as the "
            "final visual target. Destructive actions remain withheld for Gate C.",
            "",
            "This projection does not assert source UI implementation, runtime behavior, "
            "rendered-app Visual Green, Accessibility Green, device readiness, privacy/legal "
            "approval, TestFlight readiness, App Store readiness, or Release Green.",
        ]
    )
    return ("\n".join(lines) + "\n").encode("utf-8")


def check_ux_blueprint(root: Path) -> int:
    try:
        blueprint = load_ux_blueprint(root)
        validate_ux_blueprint(root, blueprint)
        expected = render_ux_blueprint_markdown(blueprint, root)
        actual = (root / PROJECTION_PATH).read_bytes()
        expected_dispositions = render_requirement_dispositions(root, blueprint)
        actual_dispositions = (root / DISPOSITIONS_PATH).read_bytes()
    except (UXBlueprintError, OSError):
        return 1
    return (
        0
        if actual == expected and actual_dispositions == expected_dispositions
        else 1
    )


def write_ux_blueprint_projection(root: Path) -> UXBlueprintSummary:
    """Validate and atomically replace the deterministic human projection."""

    blueprint = load_ux_blueprint(root)
    summary = validate_ux_blueprint(root, blueprint)
    outputs = {
        root / PROJECTION_PATH: render_ux_blueprint_markdown(blueprint, root),
        root / DISPOSITIONS_PATH: render_requirement_dispositions(root, blueprint),
    }
    for target, rendered in outputs.items():
        target.parent.mkdir(parents=True, exist_ok=True)
        descriptor, temporary_name = tempfile.mkstemp(
            prefix=f".{target.name}.", suffix=".tmp", dir=target.parent
        )
        temporary = Path(temporary_name)
        try:
            with os.fdopen(descriptor, "wb") as stream:
                stream.write(rendered)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, target)
            directory = os.open(target.parent, os.O_RDONLY)
            try:
                os.fsync(directory)
            finally:
                os.close(directory)
        except BaseException:
            temporary.unlink(missing_ok=True)
            raise
    return summary
