"""Parse, validate, compile, and query Ambitions product canon.

The compiler intentionally has no authorization, signing, approval, task,
pack, attestation, receipt-ledger, or status-policing behavior. Its only job is
to make product direction deterministic and easy to inspect.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import unquote, urlparse


CANON_ROOT_PATH = Path("docs/canon")
MANIFEST_PATH = CANON_ROOT_PATH / "MANIFEST.toml"
GENERATED_PATHS = (
    "generated/CODEX_START_HERE.md",
    "generated/INDEX.md",
    "generated/canon-index.json",
    "generated/object-boundary-matrix.md",
    "generated/requirement-graph.json",
)

REQUIRED_FRONTMATTER = {
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
REQUIREMENT_FIELDS = (
    "Concept",
    "Modality",
    "Scope",
    "Status",
    "Verification",
    "Supersedes",
)
MODALITIES = {"MUST", "MUST NOT", "MAY", "SHOULD"}
SPEC_ID_RE = re.compile(r"^[A-Z][A-Z0-9-]+$")
REQUIREMENT_ID_PATTERN = r"[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)*-[0-9]{3}"
REQUIREMENT_HEADING_RE = re.compile(
    rf"^##\s+({REQUIREMENT_ID_PATTERN})\s+—\s+(.+?)\s*$", re.MULTILINE
)
HEADING_WITH_SEPARATOR_RE = re.compile(r"^##\s+(\S+)\s+—\s+(.+?)\s*$", re.MULTILINE)
LEVEL_TWO_HEADING_RE = re.compile(r"^##\s+.+$", re.MULTILINE)
FIELD_RE = re.compile(
    r"^- \*\*(Concept|Modality|Scope|Status|Verification|Supersedes):\*\*"
    r"\s*(.*?)\s*$",
    re.MULTILINE,
)
CONCEPT_RE = re.compile(r"^[a-z0-9]+(?:[.-][a-z0-9]+)*$")
MARKDOWN_LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")

REQUIRED_CONSTITUTION_IDS = {
    "MISSION-CATEGORY-001",
    "MISSION-FUNCTION-001",
    "MISSION-INTEGRATION-001",
    "MISSION-HARD-RED-001",
    "MISSION-ORIGIN-PROBLEM-001",
    "MISSION-USER-001",
    "MISSION-MOAT-001",
    "MISSION-ORCHESTRATION-LOOP-001",
    "CONST-IA-ROOT-001",
    "LAW-IA-ROOT-001",
    "LAW-IA-NONROOT-001",
    "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
    "LAW-IA-PLAIN-LANGUAGE-001",
    "LAW-SHELL-STAGE-001",
    "CONTROL-FORCE-NOTHING-001",
    "CONTROL-MATERIAL-CONFIRMATION-001",
    "CONTROL-UNDO-RECOVERY-001",
    "OBJECT-CANONICAL-GRAPH-001",
    "CONST-RUNTIME-MUTATION-001",
    "RUNTIME-MUTATION-SEQUENCE-001",
    "LAW-LOCAL-AUTHORITY-001",
    "LAW-OFFLINE-NO-ACCOUNT-001",
    "LAW-R2-PUBLIC-ONLY-001",
    "PLATFORM-NATIVE-IPHONE-001",
    "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
    "LAW-DATA-LOSS-STOP-SHIP-001",
}

OBJECT_CAPABILITIES = (
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
OBJECT_ORDER = ("Step", "Event", "Reminder", "Note")


class CanonError(Exception):
    """A concrete source or generated-canon defect."""


@dataclass(frozen=True, slots=True)
class Requirement:
    requirement_id: str
    title: str
    concept: str
    modality: str
    scope: str
    status: str
    verification: tuple[str, ...]
    supersedes: tuple[str, ...]
    body: str
    source_path: str
    line: int
    owner_spec_id: str
    source_owners: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class Document:
    spec_id: str
    title: str
    kind: str
    status: str
    owner_domain: str
    canon_revision: int
    owns_concepts: tuple[str, ...]
    inherits: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_owners: tuple[str, ...]
    object_boundary: dict[str, Any] | None
    source_path: str
    source_bytes: bytes
    requirements: tuple[Requirement, ...]


@dataclass(frozen=True, slots=True)
class Manifest:
    schema_version: int
    canon_revision: int
    normative_files: tuple[str, ...]
    generated_files: tuple[str, ...]
    reference_files: tuple[str, ...]
    source_bytes: bytes


@dataclass(frozen=True, slots=True)
class Compilation:
    root: Path
    manifest: Manifest
    documents: tuple[Document, ...]
    canon_digest: str
    local_link_count: int
    json_count: int
    ux_screen_count: int
    visual_contract_count: int

    @property
    def requirements(self) -> tuple[Requirement, ...]:
        return tuple(
            requirement
            for document in self.documents
            for requirement in document.requirements
        )


def _strip_code(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value.startswith("`") and value.endswith("`"):
        return value[1:-1]
    return value


def _list_value(value: str) -> tuple[str, ...]:
    if value.strip().casefold() == "none":
        return ()
    backticks = tuple(re.findall(r"`([^`]+)`", value))
    if backticks:
        return backticks
    return (value.strip(),)


def _confined_path(root: Path, relative_path: Path, *, base: Path | None = None) -> Path:
    repository_root = root.resolve(strict=True)
    candidate = ((base or repository_root) / relative_path).resolve()
    try:
        candidate.relative_to(repository_root)
    except ValueError as exc:
        raise CanonError(f"path escapes repository: {relative_path.as_posix()}") from exc
    return candidate


def load_manifest(root: Path) -> Manifest:
    path = _confined_path(root, MANIFEST_PATH)
    try:
        source = path.read_bytes()
        data = tomllib.loads(source.decode("utf-8"))
    except (OSError, UnicodeDecodeError, tomllib.TOMLDecodeError) as exc:
        raise CanonError(f"unable to parse {MANIFEST_PATH}: {exc}") from exc

    allowed = {
        "schema_version",
        "canon_revision",
        "normative_files",
        "generated_files",
        "reference_files",
    }
    unknown = sorted(set(data) - allowed)
    if unknown:
        raise CanonError(f"MANIFEST.toml has unknown field: {unknown[0]}")
    missing = sorted(allowed - set(data))
    if missing:
        raise CanonError(f"MANIFEST.toml is missing field: {missing[0]}")
    if data["schema_version"] != 2:
        raise CanonError("MANIFEST.toml schema_version must be 2")
    if not isinstance(data["canon_revision"], int) or data["canon_revision"] < 1:
        raise CanonError("MANIFEST.toml canon_revision must be a positive integer")

    lists: dict[str, tuple[str, ...]] = {}
    for key in ("normative_files", "generated_files", "reference_files"):
        values = data[key]
        if not isinstance(values, list) or not values or not all(
            isinstance(value, str) and value for value in values
        ):
            raise CanonError(f"MANIFEST.toml {key} must be a non-empty string list")
        if len(values) != len(set(values)):
            raise CanonError(f"MANIFEST.toml {key} contains duplicate paths")
        lists[key] = tuple(values)

    if lists["generated_files"] != GENERATED_PATHS:
        expected = ", ".join(GENERATED_PATHS)
        raise CanonError(f"MANIFEST.toml generated_files must be exactly: {expected}")

    canon_root = _confined_path(root, CANON_ROOT_PATH)
    for key in ("normative_files", "reference_files"):
        for value in lists[key]:
            path = _confined_path(root, Path(value), base=canon_root)
            if not path.is_file():
                raise CanonError(f"manifest path is missing: {value}")

    discovered = {"CONSTITUTION.md"}
    discovered.update(
        path.relative_to(canon_root).as_posix()
        for path in (canon_root / "specifications").rglob("*.md")
    )
    discovered.update(
        path.relative_to(canon_root).as_posix()
        for path in (canon_root / "standards").glob("*.md")
    )
    declared = set(lists["normative_files"])
    if discovered != declared:
        missing_paths = sorted(discovered - declared)
        stale_paths = sorted(declared - discovered)
        details = [*(f"unlisted normative file: {p}" for p in missing_paths)]
        details.extend(f"stale normative manifest path: {p}" for p in stale_paths)
        raise CanonError("; ".join(details))

    return Manifest(
        schema_version=data["schema_version"],
        canon_revision=data["canon_revision"],
        normative_files=lists["normative_files"],
        generated_files=lists["generated_files"],
        reference_files=lists["reference_files"],
        source_bytes=source,
    )


def _frontmatter(path: Path, text: str) -> tuple[dict[str, Any], int]:
    if not text.startswith("+++\n"):
        raise CanonError(f"{path}: missing opening TOML frontmatter delimiter")
    end = text.find("\n+++\n", 4)
    if end == -1:
        raise CanonError(f"{path}: missing closing TOML frontmatter delimiter")
    try:
        data = tomllib.loads(text[4:end])
    except tomllib.TOMLDecodeError as exc:
        raise CanonError(f"{path}: invalid TOML frontmatter: {exc}") from exc
    for key, expected_type in REQUIRED_FRONTMATTER.items():
        value = data.get(key)
        if not isinstance(value, expected_type) or (
            expected_type is list and not all(isinstance(item, str) for item in value)
        ):
            raise CanonError(f"{path}: invalid or missing frontmatter field: {key}")
    return data, end + len("\n+++\n")


def parse_document(root: Path, relative_path: str, manifest_revision: int) -> Document:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    path = _confined_path(root, Path(relative_path), base=canon_root)
    source = path.read_bytes()
    try:
        text = source.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise CanonError(f"{relative_path}: source is not UTF-8") from exc
    metadata, body_start = _frontmatter(Path(relative_path), text)

    if metadata["status"] != "normative":
        raise CanonError(f"{relative_path}: document status must be normative")
    if not SPEC_ID_RE.fullmatch(metadata["spec_id"]):
        raise CanonError(f"{relative_path}: invalid spec_id: {metadata['spec_id']}")
    if not 1 <= metadata["canon_revision"] <= manifest_revision:
        raise CanonError(f"{relative_path}: canon_revision exceeds manifest revision")
    for key in ("owns_concepts", "inherits", "depends_on", "source_owners"):
        if len(metadata[key]) != len(set(metadata[key])):
            raise CanonError(f"{relative_path}: duplicate {key} value")
    for concept in metadata["owns_concepts"]:
        if not CONCEPT_RE.fullmatch(concept):
            raise CanonError(f"{relative_path}: invalid concept: {concept}")

    body = text[body_start:]
    matches = list(REQUIREMENT_HEADING_RE.finditer(body))
    candidate_ids = {match.group(1) for match in HEADING_WITH_SEPARATOR_RE.finditer(body)}
    valid_ids = {match.group(1) for match in matches}
    invalid_ids = sorted(candidate_ids - valid_ids)
    if invalid_ids:
        raise CanonError(f"{relative_path}: invalid requirement ID: {invalid_ids[0]}")
    if not matches:
        raise CanonError(f"{relative_path}: no canonical requirements")

    requirements: list[Requirement] = []
    for index, match in enumerate(matches):
        next_heading = LEVEL_TWO_HEADING_RE.search(body, match.end())
        block_end = next_heading.start() if next_heading else len(body)
        block = body[match.end() : block_end]
        field_matches = list(FIELD_RE.finditer(block))
        fields: dict[str, str] = {}
        for field_match in field_matches:
            key = field_match.group(1)
            if key in fields:
                raise CanonError(
                    f"{relative_path}:{text[: body_start + match.start()].count(chr(10)) + 1}: "
                    f"duplicate requirement field: {key}"
                )
            fields[key] = field_match.group(2)
        missing = [key for key in REQUIREMENT_FIELDS if key not in fields]
        line = text[: body_start + match.start()].count("\n") + 1
        if missing:
            raise CanonError(
                f"{relative_path}:{line}: {match.group(1)} missing field: {missing[0]}"
            )
        concept = _strip_code(fields["Concept"])
        modality = _strip_code(fields["Modality"])
        status = _strip_code(fields["Status"])
        if not CONCEPT_RE.fullmatch(concept):
            raise CanonError(f"{relative_path}:{line}: invalid concept: {concept}")
        if modality not in MODALITIES:
            raise CanonError(f"{relative_path}:{line}: invalid modality: {modality}")
        if status != "normative":
            raise CanonError(f"{relative_path}:{line}: requirement status must be normative")
        last_field_end = field_matches[-1].end() if field_matches else 0
        requirement_body = block[last_field_end:].strip()
        if not requirement_body:
            raise CanonError(f"{relative_path}:{line}: requirement body is empty")
        requirements.append(
            Requirement(
                requirement_id=match.group(1),
                title=match.group(2).strip(),
                concept=concept,
                modality=modality,
                scope=_strip_code(fields["Scope"]),
                status=status,
                verification=_list_value(fields["Verification"]),
                supersedes=_list_value(fields["Supersedes"]),
                body=requirement_body,
                source_path=relative_path,
                line=line,
                owner_spec_id=metadata["spec_id"],
                source_owners=tuple(metadata["source_owners"]),
            )
        )

    owned = set(metadata["owns_concepts"])
    actual = {requirement.concept for requirement in requirements}
    if owned != actual:
        missing = sorted(owned - actual)
        unowned = sorted(actual - owned)
        details = [*(f"owned concept has no requirement: {v}" for v in missing)]
        details.extend(f"requirement concept is not owned: {v}" for v in unowned)
        raise CanonError(f"{relative_path}: " + "; ".join(details))
    if len(actual) != len(requirements):
        raise CanonError(f"{relative_path}: duplicate requirement concept")

    object_boundary = metadata.get("object_boundary")
    if object_boundary is not None and not isinstance(object_boundary, dict):
        raise CanonError(f"{relative_path}: object_boundary must be a table")

    return Document(
        spec_id=metadata["spec_id"],
        title=metadata["title"],
        kind=metadata["kind"],
        status=metadata["status"],
        owner_domain=metadata["owner_domain"],
        canon_revision=metadata["canon_revision"],
        owns_concepts=tuple(metadata["owns_concepts"]),
        inherits=tuple(metadata["inherits"]),
        depends_on=tuple(metadata["depends_on"]),
        source_owners=tuple(metadata["source_owners"]),
        object_boundary=object_boundary,
        source_path=relative_path,
        source_bytes=source,
        requirements=tuple(requirements),
    )


def _find_cycle(graph: dict[str, tuple[str, ...]]) -> tuple[str, ...] | None:
    visited: set[str] = set()
    active: list[str] = []

    def visit(node: str) -> tuple[str, ...] | None:
        if node in active:
            start = active.index(node)
            return tuple(active[start:] + [node])
        if node in visited:
            return None
        active.append(node)
        for dependency in graph.get(node, ()):
            cycle = visit(dependency)
            if cycle:
                return cycle
        active.pop()
        visited.add(node)
        return None

    for node in sorted(graph):
        cycle = visit(node)
        if cycle:
            return cycle
    return None


def validate_documents(documents: tuple[Document, ...]) -> None:
    errors: list[str] = []
    spec_by_id: dict[str, Document] = {}
    requirement_by_id: dict[str, Requirement] = {}
    concept_owner: dict[str, Requirement] = {}
    for document in documents:
        if document.spec_id in spec_by_id:
            errors.append(f"duplicate spec_id: {document.spec_id}")
        spec_by_id[document.spec_id] = document
        for requirement in document.requirements:
            previous = requirement_by_id.get(requirement.requirement_id)
            if previous:
                errors.append(
                    f"duplicate requirement ID {requirement.requirement_id}: "
                    f"{previous.source_path} and {requirement.source_path}"
                )
            requirement_by_id[requirement.requirement_id] = requirement
            previous_concept = concept_owner.get(requirement.concept)
            if previous_concept:
                errors.append(
                    f"duplicate concept owner {requirement.concept}: "
                    f"{previous_concept.owner_spec_id} and {requirement.owner_spec_id}"
                )
            concept_owner[requirement.concept] = requirement

    for document in documents:
        for dependency in document.depends_on:
            if dependency not in spec_by_id:
                errors.append(f"{document.spec_id}: unknown dependency: {dependency}")
        for inherited in document.inherits:
            if inherited not in requirement_by_id:
                errors.append(f"{document.spec_id}: unknown inherited requirement: {inherited}")

    cycle = _find_cycle(
        {document.spec_id: document.depends_on for document in documents}
    )
    if cycle:
        errors.append("document dependency cycle: " + " -> ".join(cycle))

    constitution = spec_by_id.get("CONSTITUTION")
    if constitution is None:
        errors.append("CONSTITUTION is missing")
    else:
        constitution_ids = {req.requirement_id for req in constitution.requirements}
        for requirement_id in sorted(REQUIRED_CONSTITUTION_IDS - constitution_ids):
            errors.append(f"Constitution is missing product law: {requirement_id}")
        constitution_text = constitution.source_bytes.decode("utf-8")
        for article in range(1, 10):
            if f"# Article {article} " not in constitution_text:
                errors.append(f"Constitution is missing Article {article}")

    if errors:
        raise CanonError("\n".join(errors))


def _manifest_markdown_paths(root: Path, manifest: Manifest) -> Iterable[Path]:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    for value in (*manifest.normative_files, *manifest.reference_files):
        path = _confined_path(root, Path(value), base=canon_root)
        if path.suffix.casefold() == ".md":
            yield path


def validate_local_links(root: Path, manifest: Manifest) -> int:
    repository_root = root.resolve(strict=True)
    count = 0
    errors: list[str] = []
    for path in _manifest_markdown_paths(root, manifest):
        text = path.read_text(encoding="utf-8")
        for match in MARKDOWN_LINK_RE.finditer(text):
            target = match.group(1).strip()
            if target.startswith("<") and ">" in target:
                target = target[1 : target.index(">")]
            else:
                target = target.split(maxsplit=1)[0]
            parsed = urlparse(target)
            if not target or parsed.scheme or target.startswith("#"):
                continue
            local_target = unquote(target.split("#", 1)[0])
            if not local_target:
                continue
            count += 1
            resolved = (path.parent / local_target).resolve()
            try:
                resolved.relative_to(repository_root)
            except ValueError:
                errors.append(
                    f"{path.relative_to(repository_root)}: link escapes repository: {target}"
                )
                continue
            if not resolved.exists():
                errors.append(
                    f"{path.relative_to(repository_root)}: broken local link: {target}"
                )
    if errors:
        raise CanonError("\n".join(errors))
    return count


def validate_structured_references(root: Path) -> int:
    repository_root = root.resolve(strict=True)
    roots = (
        repository_root / "docs/canon/migration",
        repository_root / "docs/canon/schemas",
        repository_root / "docs/design/provenance",
        repository_root / "docs/qa/evidence",
    )
    paths = sorted(path for scan_root in roots for path in scan_root.rglob("*.json"))
    errors: list[str] = []
    for path in paths:
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
            errors.append(f"invalid JSON {path.relative_to(repository_root)}: {exc}")
    if errors:
        raise CanonError("\n".join(errors))
    return len(paths)


def validate_design_direction(root: Path) -> tuple[int, int]:
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    blueprint = (canon_root / "migration/UX_BLUEPRINT.md").read_text(encoding="utf-8")
    visual_system = (canon_root / "design/VISUAL_SYSTEM_R1.md").read_text(
        encoding="utf-8"
    )
    provenance = (root / "docs/design/provenance/README.md").read_text(
        encoding="utf-8"
    )
    screens = set(re.findall(r"\bUX-SCREEN-[A-Z0-9-]+", blueprint))
    contracts = set(re.findall(r"\bVAD-R1-[A-Z0-9-]+", visual_system))
    if len(screens) < 30:
        raise CanonError(f"UX Blueprint has only {len(screens)} screen IDs")
    if len(contracts) < 25:
        raise CanonError(f"Visual System R1 has only {len(contracts)} contracts")
    for number in range(1, 11):
        vsp = f"VSP-{number:02d}"
        if vsp not in provenance:
            raise CanonError(f"visual provenance index is missing {vsp}")
    return len(screens), len(contracts)


def _canon_digest(root: Path, manifest: Manifest, documents: tuple[Document, ...]) -> str:
    digest = hashlib.sha256()
    digest.update(b"ambitions-product-canon-v1\0")
    digest.update(manifest.source_bytes)
    digest.update(b"\0")
    for document in sorted(documents, key=lambda item: item.source_path):
        digest.update(document.source_path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(document.source_bytes)
        digest.update(b"\0")
    canon_root = _confined_path(root, CANON_ROOT_PATH)
    for relative_path in sorted(manifest.reference_files):
        path = _confined_path(root, Path(relative_path), base=canon_root)
        digest.update(relative_path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def compile_repository(root: Path) -> Compilation:
    root = root.resolve(strict=True)
    manifest = load_manifest(root)
    documents = tuple(
        sorted(
            (
                parse_document(root, path, manifest.canon_revision)
                for path in manifest.normative_files
            ),
            key=lambda document: (document.kind, document.spec_id),
        )
    )
    validate_documents(documents)
    local_links = validate_local_links(root, manifest)
    json_count = validate_structured_references(root)
    screen_count, visual_contract_count = validate_design_direction(root)
    return Compilation(
        root=root,
        manifest=manifest,
        documents=documents,
        canon_digest=_canon_digest(root, manifest, documents),
        local_link_count=local_links,
        json_count=json_count,
        ux_screen_count=screen_count,
        visual_contract_count=visual_contract_count,
    )


def _requirement_record(requirement: Requirement) -> dict[str, Any]:
    return {
        "concept": requirement.concept,
        "id": requirement.requirement_id,
        "line": requirement.line,
        "modality": requirement.modality,
        "scope": requirement.scope,
        "source_path": requirement.source_path,
        "source_owners": list(requirement.source_owners),
        "supersedes": list(requirement.supersedes),
        "title": requirement.title,
        "verification": list(requirement.verification),
    }


def render_index_json(compilation: Compilation) -> bytes:
    payload = {
        "canon_digest": compilation.canon_digest,
        "canon_revision": compilation.manifest.canon_revision,
        "documents": [
            {
                "depends_on": list(document.depends_on),
                "inherits": list(document.inherits),
                "kind": document.kind,
                "owner_domain": document.owner_domain,
                "owns_concepts": list(document.owns_concepts),
                "path": document.source_path,
                "requirements": [
                    _requirement_record(requirement)
                    for requirement in document.requirements
                ],
                "source_owners": list(document.source_owners),
                "spec_id": document.spec_id,
                "title": document.title,
            }
            for document in sorted(compilation.documents, key=lambda item: item.spec_id)
        ],
        "schema_version": 1,
    }
    return (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode(
        "utf-8"
    )


def render_graph_json(compilation: Compilation) -> bytes:
    dependents: dict[str, list[str]] = {
        document.spec_id: [] for document in compilation.documents
    }
    inherited_by: dict[str, list[str]] = {
        requirement.requirement_id: [] for requirement in compilation.requirements
    }
    for document in compilation.documents:
        for dependency in document.depends_on:
            dependents[dependency].append(document.spec_id)
        for requirement_id in document.inherits:
            inherited_by[requirement_id].append(document.spec_id)
    payload = {
        "canon_digest": compilation.canon_digest,
        "concepts": {
            requirement.concept: {
                "owner_spec_id": requirement.owner_spec_id,
                "requirement_id": requirement.requirement_id,
            }
            for requirement in sorted(
                compilation.requirements, key=lambda item: item.concept
            )
        },
        "requirements": {
            requirement.requirement_id: {
                "inherited_by": sorted(inherited_by[requirement.requirement_id]),
                "owner_spec_id": requirement.owner_spec_id,
                "source_path": requirement.source_path,
            }
            for requirement in sorted(
                compilation.requirements, key=lambda item: item.requirement_id
            )
        },
        "schema_version": 1,
        "specifications": {
            document.spec_id: {
                "dependencies": list(document.depends_on),
                "dependents": sorted(dependents[document.spec_id]),
                "inherits": list(document.inherits),
                "source_path": document.source_path,
            }
            for document in sorted(compilation.documents, key=lambda item: item.spec_id)
        },
    }
    return (json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode(
        "utf-8"
    )


def render_index_markdown(compilation: Compilation) -> bytes:
    lines = [
        "# Ambitions Canon Index",
        "",
        "> Generated from normative product canon. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Canon digest: `{compilation.canon_digest}`",
        f"- Documents: `{len(compilation.documents)}`",
        f"- Requirements: `{len(compilation.requirements)}`",
        "",
    ]
    kind_order = (
        "constitution",
        "app",
        "surface",
        "global",
        "object",
        "system",
        "journey",
        "standard",
    )
    by_kind: dict[str, list[Document]] = {}
    for document in compilation.documents:
        by_kind.setdefault(document.kind, []).append(document)
    for kind in (*kind_order, *sorted(set(by_kind) - set(kind_order))):
        documents = by_kind.get(kind)
        if not documents:
            continue
        lines.extend(
            [
                f"## {kind.replace('-', ' ').title()}",
                "",
                "| Specification | Title | Requirements | Concepts | Source |",
                "| --- | --- | ---: | ---: | --- |",
            ]
        )
        for document in sorted(documents, key=lambda item: item.spec_id):
            lines.append(
                f"| `{document.spec_id}` | {document.title} | "
                f"{len(document.requirements)} | {len(document.owns_concepts)} | "
                f"[{document.source_path}](../{document.source_path}) |"
            )
        lines.append("")
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def render_codex_start(compilation: Compilation) -> bytes:
    lines = [
        "# Codex Start Here",
        "",
        "> Generated navigation for Ambitions product canon. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Documents: `{len(compilation.documents)}`",
        f"- Requirements: `{len(compilation.requirements)}`",
        "",
        "Canon defines product and engineering direction. It does not authorize",
        "repository work and creates no task, pack, signature, approval, attestation,",
        "or merge ceremony.",
        "",
        "## Fast route",
        "",
        "1. Read [the Constitution](../CONSTITUTION.md) for product mission, IA,",
        "   object/runtime invariants, privacy, accessibility, and native-platform law.",
        "2. Use the compiler query command to locate the exact owning specification,",
        "   requirement, concept, dependencies, and source-owner hints.",
        "3. Read that owning specification plus current source and tests; canon does not",
        "   establish current implementation state.",
        "4. Implement the smallest coherent change and run changed-scope engineering",
        "   validation.",
        "",
        "```sh",
        "python3 scripts/ambitions-canon.py query --id LAW-LOCAL-AUTHORITY-001",
        "python3 scripts/ambitions-canon.py query --concept surface.today.first-viewport",
        "python3 scripts/ambitions-canon.py query --spec SURFACE-TODAY",
        "python3 scripts/ambitions-canon.py query \"migration replay integrity\"",
        "```",
        "",
        "## Product and design entry points",
        "",
        "- [Full canon index](INDEX.md)",
        "- [Canon README and reading order](../README.md)",
        "- [Visual System R1](../design/VISUAL_SYSTEM_R1.md)",
        "- [Canonical UX Blueprint](../migration/UX_BLUEPRINT.md)",
        "- [Object Boundary Matrix](object-boundary-matrix.md)",
        "- [Requirement graph](requirement-graph.json)",
        "- [Machine index](canon-index.json)",
        "",
        "## Compiler maintenance",
        "",
        "```sh",
        "python3 scripts/ambitions-canon.py build",
        "python3 scripts/ambitions-canon.py check",
        "```",
        "",
        "`build` writes deterministic navigation outputs. `check` detects concrete",
        "parse, identity, dependency, concept, link, structured-data, and generated",
        "drift defects. Neither command performs authorization or process enforcement.",
    ]
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def _first_paragraph(body: str) -> str:
    visible = body.split("<!--", 1)[0].strip()
    paragraph = visible.split("\n\n", 1)[0]
    return " ".join(paragraph.split())


def render_object_boundary(compilation: Compilation) -> bytes:
    boundary_documents = {
        document.title: document
        for document in compilation.documents
        if document.object_boundary is not None
    }
    missing = [title for title in OBJECT_ORDER if title not in boundary_documents]
    if missing:
        raise CanonError("object boundary projection is missing: " + ", ".join(missing))
    requirement_by_id = {
        requirement.requirement_id: requirement for requirement in compilation.requirements
    }
    lines = [
        "# Object Boundary Matrix",
        "",
        "> Generated from normative object specifications. Do not edit by hand.",
        "",
        f"- Canon revision: `{compilation.manifest.canon_revision}`",
        f"- Canon digest: `{compilation.canon_digest}`",
        "",
        "| Capability | " + " | ".join(OBJECT_ORDER) + " |",
        "| --- | " + " | ".join("---" for _ in OBJECT_ORDER) + " |",
    ]
    for key, label in OBJECT_CAPABILITIES:
        values: list[str] = []
        for title in OBJECT_ORDER:
            boundary = boundary_documents[title].object_boundary or {}
            value = boundary.get(key)
            if not isinstance(value, str):
                raise CanonError(f"{title} object_boundary is missing {key}")
            values.append(value.replace("|", "\\|"))
        lines.append(f"| {label} | " + " | ".join(values) + " |")

    first_boundary = boundary_documents[OBJECT_ORDER[0]].object_boundary or {}
    laws = first_boundary.get("laws")
    if not isinstance(laws, dict):
        raise CanonError("object_boundary laws table is missing")
    lines.extend(["", "## Owning boundary laws", ""])
    for _, requirement_id in sorted(laws.items()):
        requirement = requirement_by_id.get(requirement_id)
        if requirement is None:
            raise CanonError(f"object boundary references unknown law: {requirement_id}")
        lines.append(
            f"- **{requirement.title}** (`{requirement.requirement_id}`): "
            f"{_first_paragraph(requirement.body)}"
        )
    return ("\n".join(lines).rstrip() + "\n").encode("utf-8")


def render_outputs(compilation: Compilation) -> dict[str, bytes]:
    return {
        "generated/CODEX_START_HERE.md": render_codex_start(compilation),
        "generated/INDEX.md": render_index_markdown(compilation),
        "generated/canon-index.json": render_index_json(compilation),
        "generated/object-boundary-matrix.md": render_object_boundary(compilation),
        "generated/requirement-graph.json": render_graph_json(compilation),
    }


def write_outputs(compilation: Compilation, outputs: dict[str, bytes]) -> None:
    canon_root = _confined_path(compilation.root, CANON_ROOT_PATH)
    for relative_path in GENERATED_PATHS:
        destination = _confined_path(
            compilation.root, Path(relative_path), base=canon_root
        )
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(
            dir=destination.parent, prefix=f".{destination.name}.", delete=False
        ) as handle:
            handle.write(outputs[relative_path])
            temporary = Path(handle.name)
        os.replace(temporary, destination)


def output_drift(compilation: Compilation, outputs: dict[str, bytes]) -> tuple[str, ...]:
    canon_root = _confined_path(compilation.root, CANON_ROOT_PATH)
    drift: list[str] = []
    for relative_path in GENERATED_PATHS:
        destination = _confined_path(
            compilation.root, Path(relative_path), base=canon_root
        )
        try:
            current = destination.read_bytes()
        except OSError:
            drift.append(relative_path)
            continue
        if current != outputs[relative_path]:
            drift.append(relative_path)
    return tuple(drift)


def query(
    compilation: Compilation,
    term: str,
    *,
    mode: str = "any",
) -> tuple[Document | Requirement, ...]:
    normalized = term.casefold()
    if mode == "spec":
        return tuple(
            document
            for document in compilation.documents
            if document.spec_id.casefold() == normalized
        )
    if mode == "id":
        return tuple(
            requirement
            for requirement in compilation.requirements
            if requirement.requirement_id.casefold() == normalized
        )
    if mode == "concept":
        return tuple(
            requirement
            for requirement in compilation.requirements
            if requirement.concept.casefold() == normalized
        )

    exact: list[Document | Requirement] = []
    for document in compilation.documents:
        if document.spec_id.casefold() == normalized:
            exact.append(document)
    for requirement in compilation.requirements:
        if normalized in {
            requirement.requirement_id.casefold(),
            requirement.concept.casefold(),
        }:
            exact.append(requirement)
    if exact:
        return tuple(exact)

    tokens = tuple(token for token in re.split(r"\s+", normalized) if token)
    results: list[Document | Requirement] = []
    for requirement in compilation.requirements:
        haystack = " ".join(
            (
                requirement.requirement_id,
                requirement.title,
                requirement.concept,
                requirement.scope,
                requirement.body,
            )
        ).casefold()
        if all(token in haystack for token in tokens):
            results.append(requirement)
    for document in compilation.documents:
        haystack = " ".join(
            (document.spec_id, document.title, document.kind, *document.owns_concepts)
        ).casefold()
        if all(token in haystack for token in tokens):
            results.append(document)
    return tuple(results)


def query_record(item: Document | Requirement) -> dict[str, Any]:
    if isinstance(item, Document):
        return {
            "depends_on": list(item.depends_on),
            "inherits": list(item.inherits),
            "kind": "document",
            "owns_concepts": list(item.owns_concepts),
            "path": item.source_path,
            "requirements": [req.requirement_id for req in item.requirements],
            "source_owners": list(item.source_owners),
            "spec_id": item.spec_id,
            "title": item.title,
        }
    return {
        "body": item.body,
        "concept": item.concept,
        "id": item.requirement_id,
        "kind": "requirement",
        "line": item.line,
        "modality": item.modality,
        "owner_spec_id": item.owner_spec_id,
        "path": item.source_path,
        "scope": item.scope,
        "source_owners": list(item.source_owners),
        "supersedes": list(item.supersedes),
        "title": item.title,
        "verification": list(item.verification),
    }
