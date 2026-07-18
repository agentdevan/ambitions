"""Deterministic renderers for tracked Ambitions canon projections."""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import tempfile
from collections.abc import Mapping
from pathlib import Path

from tools.ambitions_canon.graph import document_edges, requirement_edges
from tools.ambitions_canon.model import CanonError, CanonRegistry


def stable_json(value: object) -> bytes:
    """Serialize JSON with stable ordering and a terminal newline."""

    return (
        json.dumps(
            value,
            ensure_ascii=False,
            indent=2,
            sort_keys=True,
            separators=(",", ": "),
        )
        + "\n"
    ).encode("utf-8")


def _retained_task25_evidence(repository_root: Path) -> Mapping[Path, bytes]:
    """Preserve the exact, reviewed Task 25 cutover prerequisites fail-closed."""

    expected = {
        Path("cutover-readiness.md"): "874707c870ab42590ed74d65c4e849a952cc8fad9b14def0d4560c898887adc0",
        Path("task-25-owner-direct-finalization.json"): "e48e3e9b9049a2ea0863d6f98a918efd30e13a38911ff05de683e4460d09ed63",
    }
    retained: dict[Path, bytes] = {}
    for relative, expected_sha in expected.items():
        path = repository_root / "docs/canon/generated" / relative
        try:
            if path.is_symlink() or not path.is_file():
                raise OSError("retained evidence is not a regular file")
            content = path.read_bytes()
        except OSError as exc:
            raise CanonError(
                "CANON_TASK25_EVIDENCE_MISSING",
                "reviewed Task 25 generated evidence is missing or unsafe",
                Path("docs/canon/generated") / relative,
            ) from exc
        if hashlib.sha256(content).hexdigest() != expected_sha:
            raise CanonError(
                "CANON_TASK25_EVIDENCE_CHANGED",
                "reviewed Task 25 generated evidence changed",
                Path("docs/canon/generated") / relative,
            )
        retained[relative] = content
    return retained


def render_outputs(registry: CanonRegistry) -> Mapping[Path, bytes]:
    """Render projections from the exact immutable loaded-corpus snapshot."""

    from tools.ambitions_canon.build import _content_sha_entries

    if (
        registry.manifest.repository_root is None
        or registry.manifest.source_bytes is None
    ):
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded manifest provenance is required for rendering",
            registry.manifest.source_path,
        )
    entries: list[tuple[str, bytes]] = [
        ("MANIFEST.toml", registry.manifest.source_bytes)
    ]
    if registry.supersession_ledger_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded supersession ledger bytes are required for rendering",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "decisions/SUPERSESSION_LEDGER.toml",
            registry.supersession_ledger_bytes,
        )
    )
    if (
        registry.reference_index is None
        or registry.reference_index.source_bytes is None
    ):
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded impact reference index bytes are required for rendering",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "migration/impact-reference-index.json",
            registry.reference_index.source_bytes,
        )
    )
    canon_prefix = Path("docs/canon")
    for document in registry.documents:
        if document.source_bytes is None:
            raise CanonError(
                "CANON_PROVENANCE_MISSING",
                "loaded document provenance is required for rendering",
                document.source_path,
            )
        try:
            relative = document.source_path.relative_to(canon_prefix)
        except ValueError as exc:
            raise CanonError(
                "CANON_PROVENANCE_PATH",
                "document provenance is outside docs/canon",
                document.source_path,
            ) from exc
        entries.append((relative.as_posix(), document.source_bytes))
    from tools.ambitions_canon.conflicts import (
        docket_filename,
        load_conflict_dockets,
        render_conflict_docket,
        validate_conflict_repository,
    )

    dockets = load_conflict_dockets(registry.manifest.repository_root)
    conflict_snapshot = validate_conflict_repository(
        registry.manifest.repository_root,
        dockets,
        (item.requirement_id for item in registry.requirements),
        registry.supersession_entries,
    )
    entries.extend(
        (
            f"decisions/open/{docket_filename(docket).as_posix()}",
            render_conflict_docket(docket).encode("utf-8"),
        )
        for docket in dockets
    )
    if conflict_snapshot is not None:
        entries.extend(
            (
                (
                    "migration/source-catalog.json",
                    conflict_snapshot.source_catalog_bytes,
                ),
                (
                    "migration/claim-dispositions.json",
                    conflict_snapshot.claim_dispositions_bytes,
                ),
                (
                    "migration/conflict-docket-baseline.json",
                    conflict_snapshot.baseline_bytes,
                ),
            )
        )
    from tools.ambitions_canon.external_authority import (
        load_external_reference_snapshot,
    )
    from tools.ambitions_canon.traceability import (
        capture_traceability_input_snapshot,
    )

    reference_snapshot = load_external_reference_snapshot(
        registry.manifest.repository_root
    )
    traceability_snapshot = capture_traceability_input_snapshot(
        registry,
        registry.manifest.repository_root,
        reference_snapshot,
    )
    return _render_outputs(
        registry,
        _content_sha_entries(entries),
        dockets if conflict_snapshot is not None else None,
        traceability_snapshot,
    )


def _render_outputs(
    registry: CanonRegistry,
    content_sha: str,
    dockets: tuple[object, ...] | None = None,
    traceability_snapshot: object | None = None,
) -> Mapping[Path, bytes]:
    metadata = {
        "schema_version": 1,
        "canon_revision": registry.manifest.canon_revision,
        "authority_state": registry.manifest.authority_state.value,
        "compiler_version": registry.manifest.compiler_version,
        "canon_content_sha": content_sha,
    }
    documents = tuple(
        sorted(
            registry.documents,
            key=lambda item: (item.spec_id, item.source_path.as_posix()),
        )
    )
    requirements = tuple(
        sorted(
            registry.requirements,
            key=lambda item: (
                item.requirement_id,
                item.source_path.as_posix(),
                item.line,
            ),
        )
    )
    concept_owners = tuple(sorted(registry.concept_owners))

    from tools.ambitions_canon.external_authority import (
        external_reference_findings,
        load_external_reference_snapshot,
        load_figma_reconciliation_if_present,
        load_linear_reconciliation_if_present,
        render_external_reference_impact,
        render_visual_authority_manifest,
    )
    from tools.ambitions_canon.traceability import (
        build_traceability,
        capture_traceability_input_snapshot,
        render_traceability_maps,
    )

    repository_root = registry.manifest.repository_root
    if repository_root is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "repository root is required for traceability rendering",
            registry.manifest.source_path,
        )
    if traceability_snapshot is None:
        reference_snapshot = load_external_reference_snapshot(repository_root)
        traceability_snapshot = capture_traceability_input_snapshot(
            registry,
            repository_root,
            reference_snapshot,
        )
    references = traceability_snapshot.reference_snapshot.references
    metadata["traceability_input_sha"] = traceability_snapshot.input_sha
    invalid_references = external_reference_findings(
        registry,
        references,
        repository_root,
    )
    if invalid_references:
        first = invalid_references[0]
        raise CanonError(first.code, first.message, first.path, first.line)
    traceability = build_traceability(
        registry,
        repository_root,
        references,
        snapshot=traceability_snapshot,
    )
    traceability_outputs = render_traceability_maps(traceability, metadata)
    linear_reconciliation = load_linear_reconciliation_if_present(
        repository_root,
        registry,
        references,
    )
    figma_reconciliation = load_figma_reconciliation_if_present(
        repository_root,
        registry,
        references,
    )
    visual_manifest = {
        **metadata,
        **render_visual_authority_manifest(
            registry,
            references,
            figma_reconciliation=figma_reconciliation,
        ),
    }
    expected = tuple(
        sorted(
            (
                Path(*path.parts[1:])
                for path in registry.manifest.generated_files
            ),
            key=lambda path: path.as_posix(),
        )
    )
    retained_task25_paths = frozenset(
        {
            Path("cutover-readiness.md"),
            Path("task-25-owner-direct-finalization.json"),
        }
    )
    declared_retained_task25_paths = retained_task25_paths.intersection(expected)
    if declared_retained_task25_paths and declared_retained_task25_paths != retained_task25_paths:
        raise CanonError(
            "CANON_GENERATED_MANIFEST_MISMATCH",
            "Task 25 retained evidence declarations must be complete",
            registry.manifest.source_path,
        )
    retained_task25_evidence = (
        _retained_task25_evidence(repository_root)
        if declared_retained_task25_paths
        else {}
    )

    rendered: dict[Path, bytes] = {
        **retained_task25_evidence,
        Path("CODEX_START_HERE.md"): _codex_start_here(
            metadata, len(documents), len(requirements), len(concept_owners)
        ),
        Path("INDEX.md"): _index(metadata, documents, requirements),
        Path("canon-index.json"): stable_json(
            {
                **metadata,
                "documents": [
                    {
                        "spec_id": document.spec_id,
                        "title": document.title,
                        "kind": document.kind.value,
                        "status": document.status,
                        "owner_domain": document.owner_domain,
                        "profile": document.profile,
                        "source_path": document.source_path.as_posix(),
                    }
                    for document in documents
                ],
                "requirements": [
                    {
                        "requirement_id": requirement.requirement_id,
                        "title": requirement.title,
                        "concept": requirement.concept,
                        "modality": requirement.modality.value,
                        "status": requirement.status,
                        "source_path": requirement.source_path.as_posix(),
                        "line": requirement.line,
                    }
                    for requirement in requirements
                ],
            }
        ),
        Path("concept-ownership.json"): stable_json(
            {
                **metadata,
                "concepts": [
                    {"concept": concept, "spec_id": spec_id}
                    for concept, spec_id in concept_owners
                ],
            }
        ),
        Path("requirement-graph.json"): stable_json(
            {
                **metadata,
                "document_edges": [
                    {"from": source, "to": destination}
                    for source, destination in document_edges(registry)
                ],
                "requirement_edges": [
                    {"from": source, "to": destination}
                    for source, destination in requirement_edges(registry)
                ],
                "requirement_ids": [
                    requirement.requirement_id for requirement in requirements
                ],
            }
        ),
        Path("specification-coverage.md"): _coverage(metadata, documents),
        Path("unresolved-conflicts.md"): _unresolved_conflicts(
            metadata, documents, dockets
        ),
        Path("law-source-map.json"): traceability_outputs[Path("law-source-map.json")],
        Path("law-test-map.json"): traceability_outputs[Path("law-test-map.json")],
        Path("law-proof-map.json"): traceability_outputs[Path("law-proof-map.json")],
        Path("visual-authority-manifest.json"): stable_json(visual_manifest),
        Path("external-reference-impact.md"): render_external_reference_impact(
            registry,
            references,
            invalid_references,
            metadata,
            linear_reconciliation=(
                linear_reconciliation.summary()
                if linear_reconciliation is not None
                else None
            ),
        ),
        Path("supersession-manifest.json"): _supersession_manifest(
            metadata, registry
        ),
        Path("object-boundary-matrix.md"): _object_boundary_matrix(
            metadata, documents, requirements
        ),
    }

    if Path("CHATGPT_CODEX_HANDOFF.md") in expected:
        rendered[Path("CHATGPT_CODEX_HANDOFF.md")] = _chatgpt_codex_handoff(
            metadata,
            repository_root,
        )
    if Path("AUTHORIZATION_GATE_TRANSITION.md") in expected:
        rendered[Path("AUTHORIZATION_GATE_TRANSITION.md")] = (
            _authorization_gate_transition(metadata, repository_root)
        )
    unknown = tuple(path for path in expected if path not in rendered)
    undeclared = tuple(path for path in rendered if path not in expected)
    if unknown or undeclared:
        detail = unknown[0] if unknown else undeclared[0]
        raise CanonError(
            "CANON_GENERATED_MANIFEST_MISMATCH",
            f"generated projection contract mismatch: {detail.as_posix()}",
            registry.manifest.source_path,
        )
    return {
        path: rendered[path]
        for path in sorted(rendered, key=lambda item: item.as_posix())
    }


def _object_boundary_matrix(
    metadata: Mapping[str, object],
    documents: tuple[object, ...],
    requirements: tuple[object, ...],
) -> bytes:
    """Render the executable Step/Event/Reminder/Note distinction contract."""

    columns = (
        ("OBJECT-STEP", "Step"),
        ("OBJECT-EVENT", "Event"),
        ("OBJECT-REMINDER", "Reminder"),
        ("OBJECT-NOTE", "Note"),
    )
    capabilities = (
        ("executable_completable", "Executable / completable"),
        ("occupies_duration", "Occupies duration"),
        ("consumes_capacity", "Consumes capacity"),
        ("due_date", "Due date"),
        ("recurrence", "Recurrence"),
        ("substeps", "Substeps"),
        ("goal_path_node", "Goal Path node"),
        ("proof_requirement", "Proof requirement"),
        ("attendees_rsvp", "Attendees / RSVP"),
        ("alerts", "Alerts"),
        ("type_conversion", "Type conversion"),
    )
    law_references = (
        ("schedule_placement_nonduplication", "Schedule Placement nonduplication", "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001"),
        ("future_step_singularity", "Future Step singularity", "OBJECT-FUTURE-STEP-IDENTITY-001"),
        ("reminder_acknowledgement_noncompletion", "Reminder acknowledgement noncompletion", "OBJECT-REMINDER-COMPLETION-001"),
        ("proof_receipt_separation", "Proof / Receipt separation", "OBJECT-PROOF-REQUIREMENT-001"),
    )
    by_spec = {document.spec_id: document for document in documents}
    present = {spec_id for spec_id, _ in columns if spec_id in by_spec}
    lines = _markdown_header("Object Boundary Matrix", metadata)
    if not present:
        lines.extend(
            [
                "- Representation status: `unrepresented`",
                "- Reason: Step, Event, Reminder, and Note specifications are not all materialized.",
            ]
        )
        return ("\n".join(lines) + "\n").encode("utf-8")
    required_specs = {spec_id for spec_id, _ in columns}
    if present != required_specs:
        missing = sorted(required_specs - present)
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_MISSING",
            f"object boundary contract is missing specifications: {','.join(missing)}",
            by_spec[next(iter(present))].source_path,
        )
    boundary_documents = tuple(by_spec[spec_id] for spec_id, _ in columns)
    if any(document.object_boundary is None for document in boundary_documents):
        missing = next(
            document for document in boundary_documents if document.object_boundary is None
        )
        raise CanonError(
            "CANON_OBJECT_BOUNDARY_MISSING",
            f"object boundary data is missing: {missing.spec_id}",
            missing.source_path,
        )
    boundary_values = tuple(
        dict(document.object_boundary.capabilities) for document in boundary_documents
    )
    expected_laws = dict((key, requirement_id) for key, _, requirement_id in law_references)
    for document in boundary_documents:
        if dict(document.object_boundary.laws) != expected_laws:
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_LAW_INVALID",
                f"object boundary law references drifted: {document.spec_id}",
                document.source_path,
            )
    requirement_by_id = {
        requirement.requirement_id: requirement for requirement in requirements
    }
    resolved_laws = []
    for key, label, requirement_id in law_references:
        requirement = requirement_by_id.get(requirement_id)
        if requirement is None:
            raise CanonError(
                "CANON_OBJECT_BOUNDARY_LAW_INVALID",
                f"object boundary law does not resolve: {key}={requirement_id}",
            )
        first_paragraph = requirement.body.strip().split("\n\n", 1)[0]
        resolved_laws.append(
            (label, requirement_id, " ".join(first_paragraph.splitlines()))
        )
    rows = tuple(
        (label, *(values[key] for values in boundary_values))
        for key, label in capabilities
    )
    lines.extend(
        [
            "- Representation status: `materialized`",
            "- Scope: validated spec-owned semantic boundaries; not implementation proof",
            "",
            "| Capability | Step | Event | Reminder | Note |",
            "|---|---|---|---|---|",
            *("| " + " | ".join(row) + " |" for row in rows),
            "",
            "## Owning boundary laws",
            "",
            *(
                f"- **{label}** (`{requirement_id}`): {body}"
                for label, requirement_id, body in resolved_laws
            ),
        ]
    )
    return ("\n".join(lines) + "\n").encode("utf-8")


def _markdown_header(title: str, metadata: Mapping[str, object]) -> list[str]:
    posture = (
        "Generated, non-normative projection of the active canon."
        if metadata["authority_state"] == "active"
        else "Shadow, non-authoritative generated projection."
    )
    return [
        f"# {title}",
        "",
        f"> {posture}",
        "",
        f"- Schema version: `{metadata['schema_version']}`",
        f"- Canon revision: `{metadata['canon_revision']}`",
        f"- Authority state: `{metadata['authority_state']}`",
        f"- Compiler version: `{metadata['compiler_version']}`",
        f"- Canon content SHA: `{metadata['canon_content_sha']}`",
        "",
    ]


def _markdown(lines: list[str]) -> bytes:
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def _codex_start_here(
    metadata: Mapping[str, object],
    document_count: int,
    requirement_count: int,
    concept_count: int,
) -> bytes:
    lines = _markdown_header("Ambitions Canon — Codex Start Here", metadata)
    if metadata["authority_state"] == "active":
        lines.extend(
            [
                "`docs/canon/` is the sole normative repository authority.",
                "This file is a generated router, not a second authority root.",
                "",
                "## Required flow",
                "",
                "1. Run `python3 scripts/ambitions-canon.py audit`.",
                "2. Generate a bounded pack with `python3 scripts/ambitions-canon.py pack` for nontrivial work.",
                "3. Obtain current `task start` authorization before any tracked edit.",
                "4. Read only the Constitution, specifications, standards, requirements, and live evidence routed by the pack.",
                "5. Run exact-diff `task finalize` before commit or review.",
                "",
                "ChatGPT, Project Instructions, skills, intake, packs, envelopes, receipts, local approval claims, and local proof cannot authorize work or merge.",
                "",
                "The former `docs/truth/` and `docs/constitution/` trees are non-normative migration sources pending governed purge.",
                "",
                "## Registry summary",
                "",
                f"- Specifications: {document_count}",
                f"- Requirements: {requirement_count}",
                f"- Concept owners: {concept_count}",
            ]
        )
    else:
        lines.extend(
            [
                "This generated surface is shadow-only until authority cutover.",
                "",
                "## Registry summary",
                "",
                f"- Specifications: {document_count}",
                f"- Requirements: {requirement_count}",
                f"- Concept owners: {concept_count}",
                "",
                "Run `python3 scripts/ambitions-canon.py audit` before relying on this registry.",
            ]
        )
    return _markdown(lines)


def _chatgpt_codex_handoff(
    metadata: Mapping[str, object], repository_root: Path
) -> bytes:
    instructions_path = (
        repository_root
        / "docs/canon/references/chatgpt-project-instructions.md"
    )
    try:
        instructions = instructions_path.read_bytes()
    except OSError as exc:
        raise CanonError(
            "CANON_PROJECT_INSTRUCTIONS_MISSING",
            "governed ChatGPT Project Instructions are missing",
            Path("docs/canon/references/chatgpt-project-instructions.md"),
        ) from exc
    instructions_sha = hashlib.sha256(instructions).hexdigest()
    lines = _markdown_header("ChatGPT to Codex handoff", metadata)
    lines.extend(
        [
            "This handoff is request-only and cannot authorize tracked changes, approval, proof, merge, or canon.",
            "",
            "## Governed Project Instructions",
            "",
            "- Path: `docs/canon/references/chatgpt-project-instructions.md`",
            f"- Byte-for-byte SHA-256: `{instructions_sha}`",
            "- Authority: `none`",
            "",
            "## Flow",
            "",
            "```text",
            "user intent",
            "-> request-only task intake",
            "-> bounded canon pack",
            "-> current task start authorization",
            "-> tracked work and required validation",
            "-> exact-diff task finalize",
            "-> exact high-risk review when required",
            "```",
            "",
            "Intake may request scope, requirement IDs, files, validation, proof, rollback, and a claim ceiling. It cannot supply owner approval, computed authorization, validation results, proof claims, break-glass permission, or merge permission.",
        ]
    )
    return _markdown(lines)


_TASK26_RECORD_PATH = Path(
    "docs/canon/references/task-26-owner-direct-transition.json"
)
_TASK26_DECISION_ID = "OWNER-TRAIN5-TASK26-SCOPE-2026-07-17T234045Z"
_TASK26_OWNER_TEXT = (
    "I approve OWNER-TRAIN5-TASK26-SCOPE-2026-07-17T234045Z for the 42-path "
    "manifest digest "
    "ade805bb6d0059e66a0d54358c07da23daa1b70baaabe70d78a8896f6b2a636c."
)
_TASK26_SCOPE_SHA256 = (
    "ade805bb6d0059e66a0d54358c07da23daa1b70baaabe70d78a8896f6b2a636c"
)
_TASK26_BASE = {
    "commit_sha": "63d65170632f775ddbd8d440f143a7b7654acda9",
    "tree_sha": "4abd231742d68a4f143205efabf9eb6c0b6f44f0",
}
_TASK26_CANDIDATE_TREE_SHA = "63936de213bf9523d1bf2689ed92908352a790e6"
_TASK26_CANDIDATE_BUNDLE_SHA256 = (
    "3e77623ce06a71683c8c493103bc40a397cf08ebdaaa3f397019322c1c6c64aa"
)
_TASK26_TREE_DELTA_SHA256 = (
    "058696ef052e9d0f278e3363a86fca104cfdcc08e21ec4ffe573852b83e6be08"
)
_TASK26_REVIEW_ONLY = (
    "docs/canon/generated/AUTHORIZATION_GATE_TRANSITION.md",
    "docs/canon/references/task-26-owner-direct-transition.json",
)


def _task26_error(message: str) -> CanonError:
    return CanonError("CANON_TASK26_TRANSITION_INVALID", message, _TASK26_RECORD_PATH)


def _task26_git(root: Path, *arguments: str, input_bytes: bytes | None = None) -> bytes:
    try:
        return subprocess.run(
            ["git", "-c", "core.quotepath=false", *arguments],
            cwd=root,
            input=input_bytes,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError) as exc:
        raise _task26_error(f"Task 26 Git binding failed: {' '.join(arguments)}") from exc


def _task26_sha256_file(root: Path, path_text: str) -> str:
    path = root / path_text
    try:
        if path.is_symlink() or not path.is_file():
            raise OSError("not a regular file")
        content = path.read_bytes()
    except OSError as exc:
        raise _task26_error(f"Task 26 evidence is missing or unsafe: {path_text}") from exc
    return hashlib.sha256(content).hexdigest()


def _task26_sha256_git_file(root: Path, revision: str, path_text: str) -> str:
    """Return a historical evidence digest without consulting later worktrees."""

    try:
        content = _task26_git(root, "show", f"{revision}:{path_text}")
    except CanonError as exc:
        raise _task26_error(
            f"Task 26 historical evidence is unavailable: {path_text}"
        ) from exc
    return hashlib.sha256(content).hexdigest()


def _task26_status_paths(root: Path) -> list[str]:
    raw = _task26_git(
        root,
        "status",
        "--porcelain=v1",
        "-z",
        "--untracked-files=all",
    )
    paths: list[str] = []
    for entry in (item for item in raw.split(b"\0") if item):
        if len(entry) < 4 or entry[2:3] != b" " or entry[:1] in {b"R", b"C"}:
            raise _task26_error("Task 26 scope contains an unsupported Git status")
        try:
            paths.append(entry[3:].decode("utf-8"))
        except UnicodeDecodeError as exc:
            raise _task26_error("Task 26 scope contains a non-UTF-8 path") from exc
    if len(paths) != len(set(paths)):
        raise _task26_error("Task 26 scope paths are not unique")
    return sorted(paths)


def _task26_candidate_binding(
    root: Path,
    *,
    scope_paths: list[str],
    review_only_files: list[str],
) -> dict[str, object]:
    from tools.ambitions_canon.authorization import (
        canonical_json_bytes,
        canonical_tree_delta,
    )

    base = _task26_git(root, "rev-parse", "HEAD").decode().strip()
    base_tree = _task26_git(root, "rev-parse", f"{base}^{{tree}}").decode().strip()
    with tempfile.TemporaryDirectory(prefix="task26-binding-") as directory:
        environment = dict(os.environ)
        environment["GIT_INDEX_FILE"] = str(Path(directory) / "index")
        try:
            subprocess.run(
                ["git", "read-tree", "HEAD"],
                cwd=root,
                env=environment,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                ["git", "add", "-u", "--", "."],
                cwd=root,
                env=environment,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            included = sorted(set(scope_paths) - set(review_only_files))
            untracked = set(
                subprocess.check_output(
                    ["git", "ls-files", "--others", "--exclude-standard"],
                    cwd=root,
                    env=environment,
                    text=True,
                ).splitlines()
            )
            add_paths = sorted(untracked & set(included))
            if add_paths:
                subprocess.run(
                    ["git", "add", "--", *add_paths],
                    cwd=root,
                    env=environment,
                    check=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
            candidate_tree = subprocess.check_output(
                ["git", "write-tree"], cwd=root, env=environment, text=True
            ).strip()
        except (OSError, subprocess.CalledProcessError) as exc:
            raise _task26_error("Task 26 candidate index binding failed") from exc

    commit_environment = dict(os.environ)
    commit_environment.update(
        {
            "GIT_AUTHOR_NAME": "Task26 Binder",
            "GIT_AUTHOR_EMAIL": "task26@local.invalid",
            "GIT_AUTHOR_DATE": "2000-01-01T00:00:00Z",
            "GIT_COMMITTER_NAME": "Task26 Binder",
            "GIT_COMMITTER_EMAIL": "task26@local.invalid",
            "GIT_COMMITTER_DATE": "2000-01-01T00:00:00Z",
        }
    )
    try:
        candidate_commit = subprocess.check_output(
            ["git", "commit-tree", candidate_tree, "-p", base],
            cwd=root,
            env=commit_environment,
            input=b"Task 26 candidate binding\n",
        ).decode("utf-8").strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        raise _task26_error("Task 26 candidate commit binding failed") from exc
    delta = canonical_tree_delta(root, base, candidate_commit)
    tree_delta_sha256 = hashlib.sha256(canonical_json_bytes(delta)).hexdigest()
    files: list[dict[str, object]] = []
    for item in delta["records"]:
        path_text = item["path_display_utf8"]
        if (
            item["status"] == "deleted"
            or item["new_object_type"] != "blob"
            or path_text in review_only_files
        ):
            raise _task26_error("Task 26 candidate contains an invalid bound entry")
        content = (root / path_text).read_bytes()
        if len(content) != item["new_blob_size"]:
            raise _task26_error("Task 26 candidate file size changed during binding")
        files.append(
            {
                "byte_size": item["new_blob_size"],
                "git_blob_oid": item["new_object_id"],
                "mode": item["new_mode"],
                "path": path_text,
                "sha256": hashlib.sha256(content).hexdigest(),
            }
        )
    expected_bound_paths = sorted(set(scope_paths) - set(review_only_files))
    if [item["path"] for item in files] != expected_bound_paths:
        raise _task26_error("Task 26 candidate bound paths differ from approved scope")
    bundle_payload = {
        "schema_version": 1,
        "task_id": "TASK-26",
        "base_commit_sha": base,
        "base_tree_sha": base_tree,
        "candidate_tree_sha": candidate_tree,
        "tree_delta_sha256": tree_delta_sha256,
        "files": files,
    }
    return {
        "base_commit_sha": base,
        "base_tree_sha": base_tree,
        "bound_files": files,
        "candidate_bundle_sha256": hashlib.sha256(
            canonical_json_bytes(bundle_payload)
        ).hexdigest(),
        "candidate_tree_sha": candidate_tree,
        "review_only_files": review_only_files,
        "tree_delta_sha256": tree_delta_sha256,
    }


def _task26_historical_candidate_binding(
    root: Path,
    *,
    base: Mapping[str, str],
    candidate_tree_sha: str,
    scope_paths: list[str],
    review_only_files: list[str],
) -> dict[str, object]:
    """Recompute the completed Task 26 candidate from immutable Git objects.

    A completed transition must not become invalid merely because a later task
    has a dirty worktree.  Its evidence is the historical base/candidate tree,
    not the state of a subsequent task.
    """

    from tools.ambitions_canon.authorization import canonical_json_bytes

    base_commit = base["commit_sha"]
    if _task26_git(root, "rev-parse", f"{base_commit}^{{tree}}") != (
        base["tree_sha"].encode() + b"\n"
    ):
        raise _task26_error("Task 26 historical base tree is unavailable or stale")
    _task26_git(root, "cat-file", "-e", f"{candidate_tree_sha}^{{tree}}")

    try:
        changed_paths = sorted(
            line.decode("utf-8")
            for line in _task26_git(
                root,
                "diff",
                "--name-only",
                base_commit,
                candidate_tree_sha,
                "--",
            ).splitlines()
        )
    except UnicodeDecodeError as exc:
        raise _task26_error("Task 26 historical candidate has a non-UTF-8 path") from exc
    expected_bound_paths = sorted(set(scope_paths) - set(review_only_files))
    if changed_paths != expected_bound_paths:
        raise _task26_error("Task 26 historical candidate paths differ from approved scope")

    files: list[dict[str, object]] = []
    for path_text in expected_bound_paths:
        candidate_entry = _task26_git(
            root, "ls-tree", candidate_tree_sha, "--", path_text
        ).decode("utf-8").strip()
        if not candidate_entry or "\t" not in candidate_entry:
            raise _task26_error("Task 26 historical candidate file is missing")
        header, entry_path = candidate_entry.split("\t", 1)
        fields = header.split()
        if len(fields) != 3 or entry_path != path_text or fields[1] != "blob":
            raise _task26_error("Task 26 historical candidate contains an invalid entry")
        mode, _object_type, object_id = fields
        base_entry = _task26_git(root, "ls-tree", base_commit, "--", path_text)
        if base_entry and object_id.encode() in base_entry:
            raise _task26_error("Task 26 historical candidate omits an approved change")
        content = _task26_git(root, "cat-file", "blob", object_id)
        files.append(
            {
                "byte_size": len(content),
                "git_blob_oid": object_id,
                "mode": mode,
                "path": path_text,
                "sha256": hashlib.sha256(content).hexdigest(),
            }
        )
    bundle_payload = {
        "schema_version": 1,
        "task_id": "TASK-26",
        "base_commit_sha": base_commit,
        "base_tree_sha": base["tree_sha"],
        "candidate_tree_sha": candidate_tree_sha,
        "tree_delta_sha256": _TASK26_TREE_DELTA_SHA256,
        "files": files,
    }
    return {
        "base_commit_sha": base_commit,
        "base_tree_sha": base["tree_sha"],
        "bound_files": files,
        "candidate_bundle_sha256": hashlib.sha256(
            canonical_json_bytes(bundle_payload)
        ).hexdigest(),
        "candidate_tree_sha": candidate_tree_sha,
        "review_only_files": review_only_files,
        "tree_delta_sha256": _TASK26_TREE_DELTA_SHA256,
    }


def _validate_task26_transition_record(
    metadata: Mapping[str, object], repository_root: Path, record: object
) -> dict[str, object]:
    from tools.ambitions_canon.authorization import canonical_json_bytes

    required = {
        "schema_version",
        "task_id",
        "decision_id",
        "owner_text",
        "owner_text_sha256",
        "base",
        "scope",
        "verifier",
        "task25_evidence",
        "candidate",
        "task_start",
        "task_finalize",
        "exact_review",
        "rollback",
        "controls",
        "claim_ceiling",
    }
    if not isinstance(record, dict) or set(record) != required:
        raise _task26_error("Task 26 transition fields do not match the closed contract")
    if (
        record["schema_version"] != 1
        or record["task_id"] != "TASK-26"
        or record["decision_id"] != _TASK26_DECISION_ID
        or record["owner_text"] != _TASK26_OWNER_TEXT
        or hashlib.sha256(_TASK26_OWNER_TEXT.encode()).hexdigest()
        != record["owner_text_sha256"]
    ):
        raise _task26_error("Task 26 owner scope approval is stale")

    scope = record["scope"]
    if not isinstance(scope, dict) or set(scope) != {
        "algorithm",
        "manifest_sha256",
        "path_count",
        "paths",
    }:
        raise _task26_error("Task 26 scope manifest fields are closed")
    scope_paths = scope["paths"]
    if (
        scope["algorithm"]
        != "sha256 over sorted UTF-8 path lines, each terminated by LF"
        or scope["manifest_sha256"] != _TASK26_SCOPE_SHA256
        or scope["path_count"] != 42
        or not isinstance(scope_paths, list)
        or scope_paths != sorted(set(scope_paths))
        or hashlib.sha256(("\n".join(scope_paths) + "\n").encode()).hexdigest()
        != _TASK26_SCOPE_SHA256
    ):
        raise _task26_error("Task 26 worktree scope differs from owner approval")

    base = record["base"]
    if base != _TASK26_BASE:
        raise _task26_error("Task 26 historical base anchor is stale")

    verifier = record["verifier"]
    expected_verifier = {
        "canonicalizer": "tools.ambitions_canon.authorization.canonical_json_bytes",
        "command_manifest_path": "docs/canon/references/validation-command-manifest.json",
        "command_manifest_sha256": "d9bcb1d3d6141c81a5b040748494debd08f632f09bdfcc584d0beae89d54e54a",
        "contract_revision": "task24-authorization-v1",
        "implementation_path": "tools/ambitions_canon/authorization.py",
        "implementation_sha256": "661ac4f4b9c02549a39ca08c29002eeb6e4feb388f5edd5be9709ae7daf8bc06",
        "policy_path": "docs/canon/references/task-authorization-policy.json",
        "policy_sha256": "8f097622da7f6f520a700a3acc144c9fef052f4a9c112b4e8bb9b914c276a6be",
        "schema_path": "docs/canon/schemas/task-authorization.schema.json",
        "schema_sha256": "d852831fe74e3f5cf4a4ce87ee2aa88fea59bc4bcf818d65e9706d38882ec63d",
    }
    if verifier != expected_verifier:
        raise _task26_error("Task 24 verifier identity changed")
    for path_key, sha_key in (
        ("implementation_path", "implementation_sha256"),
        ("schema_path", "schema_sha256"),
        ("policy_path", "policy_sha256"),
        ("command_manifest_path", "command_manifest_sha256"),
    ):
        if (
            _task26_sha256_git_file(
                repository_root, _TASK26_BASE["commit_sha"], verifier[path_key]
            )
            != verifier[sha_key]
        ):
            raise _task26_error("Task 24 verifier evidence is stale")

    task25 = record["task25_evidence"]
    expected_task25 = {
        "finalization_path": "docs/canon/generated/task-25-owner-direct-finalization.json",
        "finalization_sha256": "e48e3e9b9049a2ea0863d6f98a918efd30e13a38911ff05de683e4460d09ed63",
        "readiness_path": "docs/canon/generated/cutover-readiness.md",
        "readiness_sha256": "874707c870ab42590ed74d65c4e849a952cc8fad9b14def0d4560c898887adc0",
        "report_path": "docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md",
        "report_sha256": "36a2b62ea4dd49a0156aed24063617b56c9b1614586cf94aae57a45ef8739c0e",
    }
    if task25 != expected_task25:
        raise _task26_error("Task 25 anchor fields changed")
    for path_key, sha_key in (
        ("finalization_path", "finalization_sha256"),
        ("readiness_path", "readiness_sha256"),
        ("report_path", "report_sha256"),
    ):
        if (
            _task26_sha256_git_file(
                repository_root, _TASK26_BASE["commit_sha"], task25[path_key]
            )
            != task25[sha_key]
        ):
            raise _task26_error("Task 25 anchor evidence is stale")

    rollback = record["rollback"]
    expected_rollback = {
        "peeled_commit_sha": "1759da08f48bef39d67762c6de9d9916a3ee5208",
        "peeled_tree_sha": "216056fe93601ec9ea0e23118188258807b796e2",
        "ref": "refs/tags/canon-train5-pre-cutover-2026-07-17",
        "tag_object_sha": "7333bb6cbb1bc990bb1d416f74125a343ec03818",
    }
    if rollback != expected_rollback:
        raise _task26_error("Task 26 rollback fields changed")
    if (
        _task26_git(repository_root, "rev-parse", rollback["ref"]).decode().strip()
        != rollback["tag_object_sha"]
        or _task26_git(repository_root, "rev-parse", f"{rollback['ref']}^{{commit}}")
        .decode()
        .strip()
        != rollback["peeled_commit_sha"]
        or _task26_git(repository_root, "rev-parse", f"{rollback['ref']}^{{tree}}")
        .decode()
        .strip()
        != rollback["peeled_tree_sha"]
    ):
        raise _task26_error("Task 26 rollback Git identity is stale")

    review_only = list(_TASK26_REVIEW_ONLY)
    candidate = _task26_historical_candidate_binding(
        repository_root,
        base=_TASK26_BASE,
        candidate_tree_sha=_TASK26_CANDIDATE_TREE_SHA,
        scope_paths=scope_paths,
        review_only_files=review_only,
    )
    if (
        record["candidate"] != candidate
        or candidate["candidate_bundle_sha256"] != _TASK26_CANDIDATE_BUNDLE_SHA256
        or candidate["tree_delta_sha256"] != _TASK26_TREE_DELTA_SHA256
    ):
        raise _task26_error("Task 26 candidate binding is stale or mutated")

    start_payload = {
        "task_id": "TASK-26",
        "decision_id": _TASK26_DECISION_ID,
        "owner_text_sha256": record["owner_text_sha256"],
        "base": base,
        "scope_manifest_sha256": _TASK26_SCOPE_SHA256,
        "task25_finalization_sha256": task25["finalization_sha256"],
        "verifier": verifier,
        "rollback": rollback,
        "reusable": False,
    }
    start_sha = hashlib.sha256(canonical_json_bytes(start_payload)).hexdigest()
    expected_start = {
        "payload_sha256": start_sha,
        "record_id": f"OWNER-DIRECT-TASK26-START-{start_sha}",
        "reusable": False,
        "status": "authorized_from_clean_base",
        "use_state": "reserved_pending_exact_review",
    }
    if record["task_start"] != expected_start:
        raise _task26_error("Task 26 start receipt is stale, reusable, or invalid")

    pending_review = {
        "critical_findings": "pending",
        "important_findings": "pending",
        "review_package_sha256": None,
        "review_receipt_sha256": None,
        "reviewed_candidate_bundle_sha256": None,
        "reviewed_candidate_tree_sha": None,
        "reviewed_scope_manifest_sha256": None,
        "status": "pending",
    }
    review = record["exact_review"]

    def nonplaceholder_sha256(value: object) -> bool:
        return (
            isinstance(value, str)
            and len(value) == 64
            and all(character in "0123456789abcdef" for character in value)
            and set(value) != {"0"}
        )

    clean_review = (
        isinstance(review, dict)
        and set(review) == set(pending_review)
        and review.get("status") == "complete_clean"
        and review.get("critical_findings") == 0
        and not isinstance(review.get("critical_findings"), bool)
        and review.get("important_findings") == 0
        and not isinstance(review.get("important_findings"), bool)
        and nonplaceholder_sha256(review.get("review_package_sha256"))
        and nonplaceholder_sha256(review.get("review_receipt_sha256"))
        and review.get("reviewed_candidate_bundle_sha256")
        == candidate["candidate_bundle_sha256"]
        and review.get("reviewed_candidate_tree_sha")
        == candidate["candidate_tree_sha"]
        and review.get("reviewed_scope_manifest_sha256")
        == _TASK26_SCOPE_SHA256
    )
    review_state = (
        "pending"
        if review == pending_review
        else "complete_clean"
        if clean_review
        else None
    )
    if review_state is None:
        raise _task26_error("Task 26 review closure is incomplete, dirty, or stale")
    controls = record["controls"]
    expected_controls = {
        "protected_ci_installed": False,
        "required_check_installed": False,
        "ruleset_inspected": False,
        "live_enforcement_proven": False,
        "post_merge_receipt_required": False,
        "standard_platform_signature_present": False,
        "gate_c": "red",
        "destructive_approval": False,
        "purge_approval": False,
    }
    if controls != expected_controls:
        raise _task26_error("Task 26 protected-enforcement ceiling drifted")

    finalization_payload = {
        "task_id": "TASK-26",
        "start_record_id": expected_start["record_id"],
        "scope_manifest_sha256": _TASK26_SCOPE_SHA256,
        "candidate": candidate,
        "exact_review": review,
        "controls": controls,
        "rollback": rollback,
        "reusable": False,
    }
    finalization_sha = hashlib.sha256(
        canonical_json_bytes(finalization_payload)
    ).hexdigest()
    finalization_closed = review_state == "complete_clean"
    expected_finalization = {
        "candidate_bundle_sha256": candidate["candidate_bundle_sha256"],
        "exact_review_status": review_state,
        "payload_sha256": finalization_sha,
        "record_id": (
            f"OWNER-DIRECT-TASK26-FINALIZE-CLEAN-{finalization_sha}"
            if finalization_closed
            else f"OWNER-DIRECT-TASK26-FINALIZE-{finalization_sha}"
        ),
        "reusable": False,
        "scope_manifest_sha256": _TASK26_SCOPE_SHA256,
        "start_record_id": expected_start["record_id"],
        "status": "complete_clean" if finalization_closed else "pending_exact_review",
        "use_state": (
            "consumed_complete_clean"
            if finalization_closed
            else "reserved_pending_exact_review"
        ),
    }
    if record["task_finalize"] != expected_finalization:
        raise _task26_error("Task 26 finalization receipt is stale, reusable, or invalid")
    if not isinstance(record["claim_ceiling"], str) or not record["claim_ceiling"]:
        raise _task26_error("Task 26 claim ceiling is missing")
    if metadata.get("authority_state") != "active":
        raise _task26_error("Task 26 transition may render only for active canon")
    return record


def _authorization_gate_transition(
    metadata: Mapping[str, object], repository_root: Path
) -> bytes:
    record_path = (
        repository_root
        / "docs/canon/references/task-26-owner-direct-transition.json"
    )
    try:
        raw = record_path.read_bytes()
        record = json.loads(raw)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise CanonError(
            "CANON_TASK26_TRANSITION_INVALID",
            "Task 26 owner-direct transition input is missing or invalid",
            Path("docs/canon/references/task-26-owner-direct-transition.json"),
        ) from exc
    record = _validate_task26_transition_record(metadata, repository_root, record)
    owner_text = record["owner_text"]
    candidate = record["candidate"]
    bound_files = candidate["bound_files"]
    review_only_files = candidate["review_only_files"]
    review = record["exact_review"]
    review_closed = review["status"] == "complete_clean"
    review_package_sha = review["review_package_sha256"] or "absent"
    review_receipt_sha = review["review_receipt_sha256"] or "absent"
    reviewed_tree_sha = review["reviewed_candidate_tree_sha"] or "absent"
    reviewed_bundle_sha = review["reviewed_candidate_bundle_sha256"] or "absent"
    reviewed_scope_sha = review["reviewed_scope_manifest_sha256"] or "absent"
    finalization_review_description = (
        "complete-clean review closure"
        if review_closed
        else "pending exact review"
    )
    review_posture = (
        "The exact review is complete and clean for the bound candidate. Direct "
        "integration remains outside this worktree; protected enforcement and Gate C "
        "remain unproven."
        if review_closed
        else "Authority activation and direct integration remain pending until this "
        "exact review result is complete and bound to the frozen candidate."
    )
    lines = _markdown_header("Authorization Gate Transition", metadata)
    lines.extend(
        [
            "This is deterministic Task 26 transition evidence, not protected-enforcement or merge authority.",
            "",
            f"owner_decision = `{record['decision_id']}`",
            f"owner_text_sha256 = `{record['owner_text_sha256']}`",
            f"scope_manifest_sha256 = `{record['scope']['manifest_sha256']}`",
            f"scope_path_count = `{record['scope']['path_count']}`",
            f"task_start_payload_sha256 = `{record['task_start']['payload_sha256']}`",
            f"task_finalize_payload_sha256 = `{record['task_finalize']['payload_sha256']}`",
            f"task_start_status = `{record['task_start']['status']}`",
            f"task_finalize_status = `{record['task_finalize']['status']}`",
            f"exact_review_status = `{record['exact_review']['status']}`",
            "protected_ci_installed = `false`",
            "required_check_installed = `false`",
            "ruleset_inspected = `false`",
            "live_enforcement_proven = `false`",
            "post_merge_receipt_required = `false`",
            "gate_c = `red`",
            "",
            "## Owner scope approval",
            "",
            f"> {owner_text}",
            "",
            "This approval is single-use for the exact 42-path Task 26 scope. It is not a reusable policy or code-path authorization and cannot waive review, rollback, Gate C, privacy/security, or proof honesty.",
            "",
            "## Base and predecessor evidence",
            "",
            f"- Base commit: `{record['base']['commit_sha']}`",
            f"- Base tree: `{record['base']['tree_sha']}`",
            f"- Task 25 finalization: `{record['task25_evidence']['finalization_path']}` (`{record['task25_evidence']['finalization_sha256']}`)",
            f"- Task 25 readiness: `{record['task25_evidence']['readiness_path']}` (`{record['task25_evidence']['readiness_sha256']}`)",
            f"- Task 25 report: `{record['task25_evidence']['report_path']}` (`{record['task25_evidence']['report_sha256']}`)",
            f"- Task 24 verifier: `{record['verifier']['implementation_path']}` (`{record['verifier']['implementation_sha256']}`)",
            f"- Task 24 authorization schema: `{record['verifier']['schema_path']}` (`{record['verifier']['schema_sha256']}`)",
            f"- Canonicalizer: `{record['verifier']['canonicalizer']}`",
            "",
            "## Exact candidate binding",
            "",
            f"- Candidate tree: `{candidate['candidate_tree_sha']}`",
            f"- Tree-delta SHA-256: `{candidate['tree_delta_sha256']}`",
            f"- Candidate bundle SHA-256: `{candidate['candidate_bundle_sha256']}`",
            "- Binding excludes only the transition input and this generated projection to avoid circular self-reference; both remain in the exact review range.",
            "",
            "| Path | Git blob | Mode | SHA-256 | Bytes |",
            "|---|---|---|---|---:|",
            *(
                f"| `{item['path']}` | `{item['git_blob_oid']}` | `{item['mode']}` | `{item['sha256']}` | {item['byte_size']} |"
                for item in bound_files
            ),
            "",
            "Review-only circular evidence files:",
            "",
            *(f"- `{path}`" for path in review_only_files),
            "",
            "## Authorization and finalization",
            "",
            f"- Start record: `{record['task_start']['record_id']}`; clean base/tree, owner decision, 42-path scope, Task 24 verifier, Task 25 anchor, and rollback bound; status `{record['task_start']['status']}`.",
            f"- Finalization record: `{record['task_finalize']['record_id']}`; start record, candidate bundle/tree delta, exact path/blob/mode/size/hash set, circular review-only list, controls, rollback, and {finalization_review_description} bound; status `{record['task_finalize']['status']}`.",
            "- The standard platform signature is unavailable and absent. These owner-direct local records are not a reusable bypass.",
            "",
            "## Exact high-risk review",
            "",
            f"- Status: `{review['status']}`",
            f"- Critical findings: `{review['critical_findings']}`",
            f"- Important findings: `{review['important_findings']}`",
            f"- Review package SHA-256: `{review_package_sha}`",
            f"- Review receipt SHA-256: `{review_receipt_sha}`",
            f"- Reviewed candidate tree: `{reviewed_tree_sha}`",
            f"- Reviewed candidate bundle SHA-256: `{reviewed_bundle_sha}`",
            f"- Reviewed scope manifest SHA-256: `{reviewed_scope_sha}`",
            "",
            review_posture,
            "",
            "## Rollback",
            "",
            f"- Ref: `{record['rollback']['ref']}`",
            f"- Tag object: `{record['rollback']['tag_object_sha']}`",
            f"- Peeled commit: `{record['rollback']['peeled_commit_sha']}`",
            f"- Peeled tree: `{record['rollback']['peeled_tree_sha']}`",
            "",
            "## Claim ceiling",
            "",
            record["claim_ceiling"],
        ]
    )
    return _markdown(lines)


def _index(metadata, documents, requirements) -> bytes:
    lines = _markdown_header("Ambitions Canon Index", metadata)
    lines.extend(["## Specifications", ""])
    if documents:
        lines.extend(
            [
                "| ID | Kind | Title | Source |",
                "| --- | --- | --- | --- |",
            ]
        )
        lines.extend(
            f"| `{_markdown_cell(item.spec_id)}` | {_markdown_cell(item.kind.value)} | "
            f"{_markdown_cell(item.title)} | `{_markdown_cell(item.source_path.as_posix())}` |"
            for item in documents
        )
    else:
        lines.append("No normative specifications are declared.")
    lines.extend(["", "## Requirements", ""])
    if requirements:
        lines.extend(
            [
                "| ID | Modality | Concept | Source |",
                "| --- | --- | --- | --- |",
            ]
        )
        lines.extend(
            f"| `{_markdown_cell(item.requirement_id)}` | "
            f"{_markdown_cell(item.modality.value)} | `{_markdown_cell(item.concept)}` | "
            f"`{_markdown_cell(item.source_path.as_posix())}:{item.line}` |"
            for item in requirements
        )
    else:
        lines.append("No normative requirements are declared.")
    return _markdown(lines)


def _coverage(metadata, documents) -> bytes:
    lines = _markdown_header("Ambitions Specification Coverage", metadata)
    lines.extend(["| Specification | Profile | Section markers |", "| --- | --- | ---: |"])
    if documents:
        lines.extend(
            f"| `{_markdown_cell(item.spec_id)}` | "
            f"{_markdown_cell(item.profile or 'none')} | {len(item.sections)} |"
            for item in documents
        )
    else:
        lines.append("| none | none | 0 |")
    return _markdown(lines)


def _unresolved_conflicts(metadata, documents, dockets=None) -> bytes:
    if dockets is not None:
        from tools.ambitions_canon.conflicts import render_unresolved_report

        return render_unresolved_report(
            dockets,
            canon_revision=int(metadata["canon_revision"]),
            canon_content_sha=str(metadata["canon_content_sha"]),
            compiler_version=str(metadata["compiler_version"]),
            authority_state=str(metadata["authority_state"]),
        )
    lines = _markdown_header("Ambitions Unresolved Conflicts", metadata)
    lines.extend(
        [
            "**Representation status:** Unrepresented",
            "",
            "Conflict-docket identity is not represented by the current model.",
        ]
    )
    return _markdown(lines)


def _markdown_cell(value: object) -> str:
    return (
        str(value)
        .replace("&", "&amp;")
        .replace("|", "&#124;")
        .replace("`", "&#96;")
        .replace("\r\n", "<br>")
        .replace("\r", "<br>")
        .replace("\n", "<br>")
    )


def _supersession_manifest(metadata, registry) -> bytes:
    rows = [
        {
            "conflict_id": entry.conflict_id,
            "old_ids": list(entry.old_ids),
            "resulting_id": entry.resulting_id,
            "decision_date": entry.decision_date,
            "owner": entry.owner,
            "decision_source": entry.decision_source,
            "resolution": entry.resolution,
            "decision_base_commit": entry.decision_base_commit,
            "integration_evidence_sha256": entry.integration_evidence_sha256,
            "superseded_artifacts": list(entry.superseded_artifacts),
        }
        for entry in registry.supersession_entries
    ]
    return stable_json({**metadata, "supersessions": rows})
