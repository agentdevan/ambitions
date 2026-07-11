"""Deterministic amendment classification, impact, and scaffold support."""

from __future__ import annotations

import os
import re
import secrets
import unicodedata
from dataclasses import dataclass
from pathlib import Path

from tools.ambitions_canon.build import _open_parent_nofollow, _rename_noreplace
from tools.ambitions_canon.model import (
    AuthorityClass,
    AuthorityReferenceKind,
    CanonError,
    CanonRegistry,
    ImpactReferenceIndex,
    Requirement,
    SpecificationGapRecord,
)
from tools.ambitions_canon.registry import CONCEPT_KEY
from tools.ambitions_canon.reference_index import (
    validate_reference_index_provenance,
)


CHANGE_CLASSES = frozenset(
    {"clarification", "semantic_amendment", "structural_refactor", "removal"}
)

_SEMANTIC_FIELDS = (
    "concept",
    "modality",
    "scope",
    "status",
    "verification",
    "supersedes",
    "body",
)
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_APPROVAL_STATES = frozenset({"unreviewed", "approved", "rejected", "stale"})


@dataclass(frozen=True, slots=True)
class RequirementChange:
    before_id: str
    after_id: str | None
    classification: str


@dataclass(frozen=True, slots=True)
class ImpactReport:
    changes: tuple[RequirementChange, ...]
    affected_specifications: tuple[str, ...]
    dependent_requirements: tuple[str, ...]
    source_owners: tuple[str, ...]
    source_references: tuple[str, ...]
    scenarios: tuple[str, ...]
    tests: tuple[str, ...]
    proof_obligations: tuple[str, ...]
    figma_authority: tuple[str, ...]
    linear_work: tuple[str, ...]
    generated_task_packs: tuple[str, ...]
    unclassified_verification: tuple[str, ...]
    removed_ids: tuple[str, ...]
    retired_ids: tuple[str, ...]
    unresolved_p0_dependents: tuple[str, ...]
    new_specification_gaps: tuple[str, ...]


def classify_change(before: Requirement, after: Requirement) -> str:
    """Classify one requirement change using the closed amendment classes."""

    if not isinstance(before, Requirement) or not isinstance(after, Requirement):
        raise CanonError(
            "CANON_AMENDMENT_INPUT_INVALID",
            "change classification requires two Requirement values",
        )

    if before.requirement_id != after.requirement_id:
        return "semantic_amendment"

    semantic_differences = {
        field
        for field in _SEMANTIC_FIELDS
        if getattr(before, field) != getattr(after, field)
    }
    if semantic_differences:
        explicitly_declared_clarification = (
            semantic_differences <= {"status", "body"}
            and after.status == "clarification"
            and before.status in {"normative", "clarification"}
            and _semantic_body_tokens(before.body)
            == _semantic_body_tokens(after.body)
        )
        if explicitly_declared_clarification:
            return "clarification"
        return "semantic_amendment"

    if (
        before.source_path != after.source_path
        or before.line != after.line
    ):
        return "structural_refactor"

    return "clarification"


def _semantic_body_tokens(body: str) -> tuple[str, ...]:
    normalized = unicodedata.normalize("NFC", body).casefold()
    ignored_prose_punctuation = frozenset({".", ",", ";", ":"})
    tokens: list[str] = []
    word: list[str] = []

    def flush_word() -> None:
        if word:
            tokens.append("".join(word))
            word.clear()

    for character in normalized:
        if character.isalnum() or character == "_":
            word.append(character)
            continue
        flush_word()
        if character.isspace() or character in ignored_prose_punctuation:
            continue
        tokens.append(character)
    flush_word()
    return tuple(tokens)


def impact_report(before: CanonRegistry, after: CanonRegistry) -> ImpactReport:
    """Return a deterministic, fail-closed impact report for two snapshots."""

    _validate_registry_input(before, label="before")
    _validate_registry_input(after, label="after")
    before_index = _require_reference_index(before, label="before")
    after_index = _require_reference_index(after, label="after")
    before_by_id = {item.requirement_id: item for item in before.requirements}
    after_by_id = {item.requirement_id: item for item in after.requirements}

    active_after_ids = set(after_by_id) | {
        item.spec_id for item in after.documents
    }
    reactivated = sorted(before.superseded_ids & active_after_ids)
    if reactivated:
        identifier = reactivated[0]
        item = after_by_id.get(identifier)
        specification = next(
            (
                candidate
                for candidate in after.documents
                if candidate.spec_id == identifier
            ),
            None,
        )
        raise CanonError(
            "CANON_RETIRED_ID_REACTIVATED",
            f"retired canonical ID was reactivated: {identifier}",
            item.source_path if item is not None else specification.source_path,
            item.line if item is not None else None,
        )

    before_ledger_ids = _ledger_ids(before)
    after_ledger_ids = _ledger_ids(after)
    missing_durable_ids = before_ledger_ids - after_ledger_ids
    if missing_durable_ids:
        raise CanonError(
            "CANON_SUPERSESSION_LEDGER_REGRESSION",
            (
                "after snapshot dropped durable retired ID: "
                f"{sorted(missing_durable_ids)[0]}"
            ),
            after.manifest.source_path,
        )
    before_entries = {
        entry.conflict_id: entry for entry in before.supersession_entries
    }
    after_entries = {
        entry.conflict_id: entry for entry in after.supersession_entries
    }
    for conflict_id, entry in sorted(before_entries.items()):
        if after_entries.get(conflict_id) != entry:
            raise CanonError(
                "CANON_SUPERSESSION_LEDGER_REWRITE",
                f"existing ledger entry changed or disappeared: {conflict_id}",
                after.manifest.source_path,
            )

    changes: list[RequirementChange] = []
    changed_before_ids: set[str] = set()
    changed_after_ids: set[str] = set()
    for identifier in sorted(set(before_by_id) & set(after_by_id)):
        old = before_by_id[identifier]
        new = after_by_id[identifier]
        classification = classify_change(old, new)
        if classification == "semantic_amendment":
            raise CanonError(
                "CANON_AMENDMENT_ID_REUSE",
                (
                    "semantic amendment must create a new requirement ID: "
                    f"{identifier}"
                ),
                new.source_path,
                new.line,
            )
        if old != new:
            changes.append(
                RequirementChange(identifier, identifier, classification)
            )
            changed_before_ids.add(identifier)
            changed_after_ids.add(identifier)

    removed_ids = set(before_by_id) - set(after_by_id)
    added_ids = set(after_by_id) - set(before_by_id)
    if removed_ids and not after.supersession_ledger_complete:
        raise CanonError(
            "CANON_SUPERSESSION_LEDGER_REQUIRED",
            "removal requires a complete after-state supersession ledger",
            after.manifest.source_path,
        )
    unsynchronized = sorted(removed_ids - after_ledger_ids)
    if unsynchronized:
        raise CanonError(
            "CANON_SUPERSESSION_LEDGER_UNSYNCED",
            f"removed ID is absent from the durable ledger: {unsynchronized[0]}",
            after.manifest.source_path,
        )
    replacements: dict[str, list[Requirement]] = {
        identifier: [] for identifier in removed_ids
    }
    for identifier in sorted(added_ids):
        item = after_by_id[identifier]
        for retired_id in item.supersedes:
            if retired_id in replacements:
                replacements[retired_id].append(item)

    for retired_id in sorted(removed_ids):
        ledger_entry = _ledger_entry_for(after, retired_id)
        if ledger_entry.conflict_id in before_entries:
            raise CanonError(
                "CANON_SUPERSESSION_LEDGER_UNSYNCED",
                f"removal requires a new ledger entry: {retired_id}",
                after.manifest.source_path,
            )
        candidates = sorted(
            replacements[retired_id], key=lambda item: item.requirement_id
        )
        if len(candidates) > 1:
            raise CanonError(
                "CANON_AMENDMENT_SUPERSESSION_AMBIGUOUS",
                f"multiple requirements supersede removed ID: {retired_id}",
                candidates[1].source_path,
                candidates[1].line,
            )
        if candidates:
            replacement = candidates[0]
            if ledger_entry.resulting_id != replacement.requirement_id:
                raise CanonError(
                    "CANON_SUPERSESSION_LEDGER_RESULT",
                    (
                        "semantic replacement ledger result must equal new ID: "
                        f"{retired_id} -> {replacement.requirement_id}"
                    ),
                    after.manifest.source_path,
                )
            if classify_change(before_by_id[retired_id], replacement) != (
                "semantic_amendment"
            ):
                raise CanonError(
                    "CANON_AMENDMENT_CLASS_INVALID",
                    f"replacement did not classify as semantic: {retired_id}",
                    replacement.source_path,
                    replacement.line,
                )
            changes.append(
                RequirementChange(
                    retired_id,
                    replacement.requirement_id,
                    "semantic_amendment",
                )
            )
            changed_after_ids.add(replacement.requirement_id)
        else:
            if ledger_entry.resulting_id is not None:
                raise CanonError(
                    "CANON_SUPERSESSION_LEDGER_RESULT",
                    f"pure removal ledger result must be null: {retired_id}",
                    after.manifest.source_path,
                )
            same_concept_additions = sorted(
                item.requirement_id
                for item in after_by_id.values()
                if item.requirement_id in added_ids
                and item.concept == before_by_id[retired_id].concept
            )
            if same_concept_additions:
                replacement = after_by_id[same_concept_additions[0]]
                raise CanonError(
                    "CANON_AMENDMENT_SUPERSESSION_REQUIRED",
                    (
                        "semantic replacement must declare the removed ID in "
                        f"supersedes: {retired_id}"
                    ),
                    replacement.source_path,
                    replacement.line,
                )
            changes.append(RequirementChange(retired_id, None, "removal"))
        changed_before_ids.add(retired_id)

    changes.sort(
        key=lambda change: (
            change.before_id,
            change.after_id or "",
            change.classification,
        )
    )
    affected_specs = _affected_specifications(
        before,
        after,
        changed_before_ids,
        changed_after_ids,
    )
    dependent_requirements = _dependent_requirements(
        before,
        after,
        affected_specs,
        changed_before_ids,
        changed_after_ids,
    )
    affected_reference_ids = (
        changed_before_ids | changed_after_ids | dependent_requirements
    )
    references = _structured_references(
        before_index,
        after_index,
        affected_reference_ids,
    )
    source_owners = sorted(
        {
            owner
            for registry in (before, after)
            for specification in registry.documents
            if specification.spec_id in affected_specs
            for owner in specification.source_owners
        }
    )
    all_retired = before.superseded_ids | after.superseded_ids | removed_ids
    unresolved_retirements = removed_ids - after.superseded_ids
    unresolved_references = {
        retired_id
        for retired_id in all_retired
        for specification in after.documents
        if retired_id in specification.inherits
    }

    return ImpactReport(
        changes=tuple(changes),
        affected_specifications=tuple(sorted(affected_specs)),
        dependent_requirements=tuple(sorted(dependent_requirements)),
        source_owners=tuple(source_owners),
        source_references=references["source"],
        scenarios=references["scenario"],
        tests=references["test"],
        proof_obligations=references["proof"],
        figma_authority=references["figma"],
        linear_work=references["linear"],
        generated_task_packs=references["task_pack"],
        unclassified_verification=references["unclassified"],
        removed_ids=tuple(sorted(removed_ids)),
        retired_ids=tuple(sorted(all_retired)),
        unresolved_p0_dependents=tuple(
            sorted(unresolved_retirements | unresolved_references)
        ),
        new_specification_gaps=_new_specification_gaps(
            before_index,
            after_index,
        ),
    )


def render_amendment_scaffold(concept: str) -> bytes:
    """Render the fixed, complete temporary amendment docket."""

    if not isinstance(concept, str) or CONCEPT_KEY.fullmatch(concept) is None:
        raise CanonError(
            "CANON_AMENDMENT_CONCEPT_INVALID",
            f"invalid normalized concept key: {concept!r}",
        )
    headings = (
        "Problem",
        "Affected concept keys",
        "Current requirements",
        "Proposed requirements",
        "Rationale",
        "Alternatives",
        "Superseded requirements",
        "Specification impact",
        "Source and test impact",
        "Figma impact",
        "Linear impact",
        "Privacy, accessibility, and performance impact",
        "Migration",
        "Rollback",
        "Owner approval",
    )
    lines = [
        "+++",
        "schema_version = 1",
        'docket_type = "canon_amendment"',
        'status = "temporary_non_normative"',
        f'affected_concepts = ["{concept}"]',
        'owner_approval = "unresolved"',
        "+++",
        "",
        "# Temporary Canon Amendment",
        "",
        (
            "> This scaffold is non-normative until owner approval and "
            "integration into the canonical owner."
        ),
        "",
    ]
    for heading in headings:
        lines.extend(
            (
                f"## {heading}",
                "",
                _scaffold_prompt(heading, concept),
                "",
            )
        )
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def write_amendment_scaffold(root: Path, output: Path, concept: str) -> Path:
    """Atomically write one scaffold below the ignored migration root."""

    root = Path(os.path.abspath(root))
    migration_root = root / ".codex/canon-migration"
    _ensure_real_directory(root / ".codex")
    _ensure_real_directory(migration_root)
    absolute_output = Path(
        os.path.abspath(output if output.is_absolute() else root / output)
    )
    try:
        relative = absolute_output.relative_to(migration_root)
    except ValueError as exc:
        raise CanonError(
            "CANON_AMENDMENT_PATH",
            "amendment scaffold output must remain under .codex/canon-migration",
            absolute_output,
        ) from exc
    if not relative.parts or any(part in {"", ".", ".."} for part in relative.parts):
        raise CanonError(
            "CANON_AMENDMENT_PATH",
            "amendment scaffold output path is not canonical",
            absolute_output,
        )

    content = render_amendment_scaffold(concept)
    temporary_name: str | None = None
    try:
        with _open_parent_nofollow(absolute_output) as (
            parent_descriptor,
            output_name,
            pinned_output,
        ):
            try:
                for _ in range(128):
                    candidate = (
                        ".ambitions-canon-amendment-"
                        f"{secrets.token_hex(12)}"
                    )
                    try:
                        descriptor = os.open(
                            candidate,
                            os.O_WRONLY
                            | os.O_CREAT
                            | os.O_EXCL
                            | os.O_NOFOLLOW,
                            0o600,
                            dir_fd=parent_descriptor,
                        )
                        temporary_name = candidate
                        break
                    except FileExistsError:
                        continue
                else:
                    raise OSError("unable to allocate unique temporary output")
                try:
                    _write_all(descriptor, content)
                    os.fsync(descriptor)
                finally:
                    os.close(descriptor)
                try:
                    _rename_noreplace(
                    temporary_name,
                    output_name,
                        source_directory=parent_descriptor,
                        destination_directory=parent_descriptor,
                    )
                except FileExistsError as exc:
                    raise CanonError(
                        "CANON_AMENDMENT_EXISTS",
                        "amendment scaffold output already exists",
                        pinned_output,
                    ) from exc
                temporary_name = None
                os.fsync(parent_descriptor)
            except (OSError, CanonError) as exc:
                if temporary_name is not None:
                    try:
                        os.unlink(temporary_name, dir_fd=parent_descriptor)
                    except OSError:
                        pass
                if (
                    isinstance(exc, CanonError)
                    and exc.code == "CANON_AMENDMENT_EXISTS"
                ):
                    raise
                raise CanonError(
                    "CANON_AMENDMENT_WRITE",
                    "unable to atomically write amendment scaffold",
                    pinned_output,
                ) from exc
    except CanonError as exc:
        if exc.code.startswith("CANON_GENERATED_PATH"):
            raise CanonError(
                "CANON_AMENDMENT_PATH",
                "amendment scaffold output path contains an unsafe ancestor",
                absolute_output,
            ) from exc
        raise
    return absolute_output


def _validate_registry_input(registry: CanonRegistry, *, label: str) -> None:
    if not isinstance(registry, CanonRegistry):
        raise CanonError(
            "CANON_IMPACT_INPUT_INVALID",
            f"{label} impact input is not a CanonRegistry",
        )
    spec_ids = [item.spec_id for item in registry.documents]
    requirement_ids = [item.requirement_id for item in registry.requirements]
    active_ids = set(spec_ids) | set(requirement_ids)
    concept_owner_keys = [item[0] for item in registry.concept_owners]
    declared_concept_owners = sorted(
        (concept, specification.spec_id)
        for specification in registry.documents
        for concept in specification.owns_concepts
    )
    flattened = tuple(
        item for specification in registry.documents for item in specification.requirements
    )
    invalid = (
        len(spec_ids) != len(set(spec_ids))
        or len(requirement_ids) != len(set(requirement_ids))
        or bool(set(spec_ids) & set(requirement_ids))
        or sorted(flattened, key=_requirement_key)
        != sorted(registry.requirements, key=_requirement_key)
        or bool(active_ids & registry.superseded_ids)
        or len(concept_owner_keys) != len(set(concept_owner_keys))
        or sorted(registry.concept_owners) != declared_concept_owners
        or not _ledger_ids(registry) <= registry.superseded_ids
    )
    if invalid:
        raise CanonError(
            "CANON_IMPACT_INPUT_INVALID",
            f"{label} registry is not a closed identity snapshot",
            registry.manifest.source_path,
        )


def _ledger_ids(registry: CanonRegistry) -> set[str]:
    return {
        identifier
        for entry in registry.supersession_entries
        for identifier in entry.old_ids
    }


def _ledger_entry_for(
    registry: CanonRegistry,
    retired_id: str,
):
    matches = tuple(
        entry
        for entry in registry.supersession_entries
        if retired_id in entry.old_ids
    )
    if len(matches) != 1:
        raise CanonError(
            "CANON_SUPERSESSION_LEDGER_UNSYNCED",
            f"removed ID requires exactly one ledger entry: {retired_id}",
            registry.manifest.source_path,
        )
    return matches[0]


def _requirement_key(item: Requirement) -> tuple[object, ...]:
    return (
        item.requirement_id,
        item.title,
        item.concept,
        item.modality.value,
        item.scope,
        item.status,
        item.verification,
        item.supersedes,
        item.body,
        item.source_path.as_posix(),
        item.line,
    )


def _affected_specifications(
    before: CanonRegistry,
    after: CanonRegistry,
    before_ids: set[str],
    after_ids: set[str],
) -> set[str]:
    affected = {
        specification.spec_id
        for registry, identifiers in ((before, before_ids), (after, after_ids))
        for specification in registry.documents
        if any(
            item.requirement_id in identifiers
            for item in specification.requirements
        )
    }
    changed = True
    while changed:
        changed = False
        for registry, identifiers in ((before, before_ids), (after, after_ids)):
            for specification in registry.documents:
                if specification.spec_id in affected:
                    continue
                if (
                    set(specification.inherits) & identifiers
                    or set(specification.depends_on) & affected
                ):
                    affected.add(specification.spec_id)
                    changed = True
    return affected


def _dependent_requirements(
    before: CanonRegistry,
    after: CanonRegistry,
    affected_specs: set[str],
    changed_before_ids: set[str],
    changed_after_ids: set[str],
) -> set[str]:
    changed_ids = changed_before_ids | changed_after_ids
    return {
        item.requirement_id
        for registry in (before, after)
        for specification in registry.documents
        if specification.spec_id in affected_specs
        for item in specification.requirements
        if item.requirement_id not in changed_ids
    }


def _require_reference_index(
    registry: CanonRegistry,
    *,
    label: str,
) -> ImpactReferenceIndex:
    index = registry.reference_index
    if (
        index is None
        or index.schema_version != 1
    ):
        raise CanonError(
            "CANON_IMPACT_REFERENCE_INDEX_REQUIRED",
            f"{label} snapshot requires a complete reference index",
            registry.manifest.source_path,
        )
    validate_reference_index_provenance(
        index,
        canon_revision=registry.manifest.canon_revision,
        requirement_ids=tuple(
            sorted(item.requirement_id for item in registry.requirements)
        ),
        specification_ids=tuple(
            sorted(item.spec_id for item in registry.documents)
        ),
    )
    _validate_reference_index(index, registry, label=label)
    return index


def _validate_reference_index(
    index: ImpactReferenceIndex,
    registry: CanonRegistry,
    *,
    label: str,
) -> None:
    requirement_ids = {item.requirement_id for item in registry.requirements}
    active_ids = requirement_ids | {item.spec_id for item in registry.documents}
    reference_ids = [item.reference_id for item in index.authority_references]
    pack_ids = [item.pack_id for item in index.task_packs]
    gap_ids = [item.gap_id for item in index.specification_gaps]
    invalid = (
        len(reference_ids) != len(set(reference_ids))
        or len(pack_ids) != len(set(pack_ids))
        or len(gap_ids) != len(set(gap_ids))
        or any(
            item.schema_version != 1
            or not _canonical_text(item.reference_id)
            or not _canonical_text(item.source)
            or not _canonical_text(item.revision)
            or item.approval_state not in _APPROVAL_STATES
            or not _reference_class_matches_kind(item.authority_class, item.reference_kind)
            or item.requirement_ids
            != tuple(sorted(set(item.requirement_ids)))
            or not item.requirement_ids
            or not set(item.requirement_ids) <= requirement_ids
            for item in index.authority_references
        )
        or any(
            item.schema_version != 1
            or not _canonical_text(item.pack_id)
            or not _canonical_text(item.source)
            or isinstance(item.canon_revision, bool)
            or item.canon_revision != registry.manifest.canon_revision
            or _SHA256.fullmatch(item.canon_sha) is None
            or item.requirement_ids
            != tuple(sorted(set(item.requirement_ids)))
            or not item.requirement_ids
            or not set(item.requirement_ids) <= active_ids
            for item in index.task_packs
        )
        or any(
            not _canonical_text(item.gap_id)
            or not _canonical_text(item.message)
            or
            item.affected_ids != tuple(sorted(set(item.affected_ids)))
            or not item.affected_ids
            or not set(item.affected_ids) <= active_ids
            for item in index.specification_gaps
        )
    )
    if invalid:
        raise CanonError(
            "CANON_IMPACT_REFERENCE_INDEX_INVALID",
            f"{label} reference index is not closed and canonical",
            registry.manifest.source_path,
        )


def _canonical_text(value: object) -> bool:
    return isinstance(value, str) and bool(value) and value == value.strip()


def _reference_class_matches_kind(
    authority_class: AuthorityClass,
    reference_kind: AuthorityReferenceKind,
) -> bool:
    if reference_kind is AuthorityReferenceKind.FIGMA:
        return authority_class is AuthorityClass.FIGMA
    if reference_kind is AuthorityReferenceKind.LINEAR:
        return authority_class is AuthorityClass.LINEAR
    return authority_class is AuthorityClass.SOURCE_AND_TESTS


def _structured_references(
    before: ImpactReferenceIndex,
    after: ImpactReferenceIndex,
    requirement_ids: set[str],
) -> dict[str, tuple[str, ...]]:
    collected: dict[str, set[str]] = {
        kind.value: set() for kind in AuthorityReferenceKind
    }
    for index in (before, after):
        for reference in index.authority_references:
            if set(reference.requirement_ids) & requirement_ids:
                collected[reference.reference_kind.value].add(reference.source)
    task_packs = {
        pack.source
        for index in (before, after)
        for pack in index.task_packs
        if set(pack.requirement_ids) & requirement_ids
    }
    result = {key: tuple(sorted(values)) for key, values in collected.items()}
    result["task_pack"] = tuple(sorted(task_packs))
    result["unclassified"] = ()
    return result


def _new_specification_gaps(
    before: ImpactReferenceIndex,
    after: ImpactReferenceIndex,
) -> tuple[str, ...]:
    before_by_id = {gap.gap_id: gap for gap in before.specification_gaps}
    additions = sorted(
        (
            gap
            for gap in after.specification_gaps
            if before_by_id.get(gap.gap_id) != gap
        ),
        key=lambda gap: gap.gap_id,
    )
    return tuple(_serialize_gap(gap) for gap in additions)


def _serialize_gap(gap: SpecificationGapRecord) -> str:
    return (
        f"{gap.severity.value} {gap.gap_id} "
        f"affected_ids={','.join(gap.affected_ids)} {gap.message}"
    )


def _scaffold_prompt(heading: str, concept: str) -> str:
    if heading == "Affected concept keys":
        return f"- `{concept}`"
    if heading == "Owner approval":
        return "Unresolved. This docket has no normative authority."
    return (
        "Unresolved input required before owner review; this section has no "
        "normative effect."
    )


def _ensure_real_directory(path: Path) -> None:
    try:
        path.mkdir(mode=0o700, parents=True, exist_ok=True)
        if path.is_symlink() or not path.is_dir():
            raise OSError("path is not a real directory")
    except OSError as exc:
        raise CanonError(
            "CANON_AMENDMENT_PATH",
            "amendment migration root must be a real directory",
            path,
        ) from exc


def _write_all(descriptor: int, content: bytes) -> None:
    view = memoryview(content)
    while view:
        written = os.write(descriptor, view)
        if written <= 0:
            raise OSError("short amendment scaffold write")
        view = view[written:]
