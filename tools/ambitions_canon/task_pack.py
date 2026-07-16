"""Bounded, deterministic Codex task packs compiled from canonical scope."""

from __future__ import annotations

import hashlib
import json
import os
import re
import stat
from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass, replace
from pathlib import Path

from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon.coverage import profile_section_bodies
from tools.ambitions_canon.command_gate_dependencies import (
    CommandGateDependencyRegistry,
    TrustedCommandGateApprovalBase,
    command_gate_dependency_projection,
    load_command_gate_dependency_registry,
    validate_command_gate_dependency_bindings,
)
from tools.ambitions_canon.command_resolution_registry import (
    CommandResolutionRegistry,
    compact_resolved_machine_contract,
    load_command_resolution_registry,
    resolve_state_command_machine_contract,
    validate_command_resolution_bindings,
)
from tools.ambitions_canon.build import (
    _content_sha_entries,
    _assert_parent_path_identity,
    _descriptor_identity,
    _entry_identity,
    _entry_kind_and_identity,
    _open_directory_at,
    _open_directory_absolute_nofollow,
    _read_file_at,
    _tree_files_descriptor,
    write_outputs_atomic,
)
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonRegistry,
    DocumentKind,
    Requirement,
    StateCommand,
    StateCommandActivationPosture,
    StateCommandContract,
)
from tools.ambitions_canon.render import stable_json
from tools.ambitions_canon.traceability import TraceabilityReport
from tools.ambitions_canon.visual_authority import (
    load_visual_authority_rebaseline_if_present,
    visual_authority_lines_for_task_pack,
)


PACK_SECTION_ORDER = (
    "Identity",
    "Constitutional laws",
    "Owning specifications",
    "Object lifecycles",
    "Journeys",
    "Cross-cutting standards",
    "Source ownership",
    "Implementation posture",
    "Command authorization",
    "Known risks",
    "Visual authority",
    "Required tests",
    "Validation",
    "Proof",
    "Forbidden changes",
    "Open conflicts",
    "Claim ceiling",
    "Rollback",
)

PACK_BUDGETS = {
    "mechanical": 8_000,
    "normal": 16_000,
    "complex": 30_000,
    "constitutional-audit": None,
}

TASK_TYPE_BUDGET_CLASS = {
    "mechanical": "mechanical",
    "docs": "normal",
    "release": "complex",
    "swiftui": "complex",
    "runtime": "complex",
    "privacy": "complex",
    "constitutional-audit": "constitutional-audit",
}

_INTAKE_FIELDS = frozenset(
    {
        "schema_version",
        "issue_id",
        "task_type",
        "scope",
        "changed_files",
        "claim_type",
        "known_issue_ids",
    }
)
_ISSUE_FIELDS = frozenset(
    {
        "schema_version",
        "issue_id",
        "severity",
        "status",
        "kind",
        "scope",
        "summary",
    }
)
_ISSUE_SEVERITIES = frozenset(
    {"P0_BLOCKER", "P1_REQUIRED", "P2_IMPROVEMENT", "INFORMATIONAL"}
)
_ISSUE_STATUSES = frozenset({"open", "unresolved", "resolved", "closed"})
_ISSUE_KINDS = frozenset({"conflict", "risk"})
_SLUG_COMPONENT = re.compile(r"[^a-z0-9]+")
_SHA256 = re.compile(r"^[0-9a-f]{64}$")
@dataclass(frozen=True, slots=True)
class TaskIntake:
    schema_version: int
    issue_id: str
    task_type: str
    scope: tuple[str, ...]
    changed_files: tuple[str, ...]
    claim_type: str
    known_issue_ids: tuple[str, ...]
    sha: str
    source_path: str | None = None

    @classmethod
    def from_json(cls, data: Mapping[str, object]) -> "TaskIntake":
        """Parse the closed issue-intake contract and hash normalized content."""

        if not isinstance(data, Mapping) or set(data) != _INTAKE_FIELDS:
            raise _intake_error("issue intake fields do not match schema version 1")
        schema_version = data["schema_version"]
        if isinstance(schema_version, bool) or schema_version != 1:
            raise _intake_error("schema_version must be integer 1")

        issue_id = _required_string(data["issue_id"], "issue_id")
        task_type = _required_string(data["task_type"], "task_type")
        claim_type = _required_string(data["claim_type"], "claim_type")
        scope = _string_tuple(data["scope"], "scope", allow_empty=False)
        changed_files = _string_tuple(
            data["changed_files"],
            "changed_files",
            allow_empty=False,
        )
        known_issue_ids = _string_tuple(
            data["known_issue_ids"],
            "known_issue_ids",
            allow_empty=True,
        )
        normalized = {
            "schema_version": 1,
            "issue_id": issue_id,
            "task_type": task_type,
            "scope": list(scope),
            "changed_files": list(changed_files),
            "claim_type": claim_type,
            "known_issue_ids": list(known_issue_ids),
        }
        encoded = json.dumps(
            normalized,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        ).encode("utf-8")
        return cls(
            schema_version=1,
            issue_id=issue_id,
            task_type=task_type,
            scope=scope,
            changed_files=changed_files,
            claim_type=claim_type,
            known_issue_ids=known_issue_ids,
            sha=hashlib.sha256(encoded).hexdigest(),
        )

    def with_source_path(self, path: str) -> "TaskIntake":
        return replace(self, source_path=_required_string(path, "source_path"))


@dataclass(frozen=True, slots=True)
class TaskPack:
    schema_version: int
    canon_revision: int
    canon_sha: str
    repository_sha: str
    intake_sha: str
    compiler_version: str
    authority_state: str
    issue_id: str
    task_type: str
    budget_class: str
    token_budget: int | None
    estimated_tokens: int
    scope: tuple[str, ...]
    changed_files: tuple[str, ...]
    claim_type: str
    known_issue_ids: tuple[str, ...]
    intake_path: str
    constitutional_laws: tuple[str, ...]
    applicable_requirement_ids: tuple[str, ...]
    specifications: tuple[str, ...]
    object_lifecycles: tuple[str, ...]
    journeys: tuple[str, ...]
    standards: tuple[str, ...]
    source_owners: tuple[str, ...]
    implementation_posture: str
    known_risks: tuple[str, ...]
    visual_authority: tuple[str, ...]
    required_tests: tuple[str, ...]
    required_validation: tuple[str, ...]
    required_proof: tuple[str, ...]
    forbidden_changes: tuple[str, ...]
    open_conflicts: tuple[str, ...]
    claim_ceiling: str
    rollback_requirements: tuple[str, ...]
    _section_content: tuple[tuple[str, tuple[str, ...]], ...]
    command_authorizations: tuple[dict[str, object], ...] = ()

    def to_dict(self) -> dict[str, object]:
        """Return the stable public machine contract without render internals."""

        return {
            "schema_version": self.schema_version,
            "canon_revision": self.canon_revision,
            "canon_sha": self.canon_sha,
            "repository_sha": self.repository_sha,
            "intake_sha": self.intake_sha,
            "compiler_version": self.compiler_version,
            "authority_state": self.authority_state,
            "issue_id": self.issue_id,
            "task_type": self.task_type,
            "budget_class": self.budget_class,
            "token_budget": self.token_budget,
            "estimated_tokens": self.estimated_tokens,
            "scope": list(self.scope),
            "changed_files": list(self.changed_files),
            "claim_type": self.claim_type,
            "known_issue_ids": list(self.known_issue_ids),
            "intake_path": self.intake_path,
            "constitutional_laws": list(self.constitutional_laws),
            "applicable_requirement_ids": list(self.applicable_requirement_ids),
            "specifications": list(self.specifications),
            "object_lifecycles": list(self.object_lifecycles),
            "journeys": list(self.journeys),
            "standards": list(self.standards),
            "source_owners": list(self.source_owners),
            "implementation_posture": self.implementation_posture,
            "command_authorizations": [
                dict(item) for item in self.command_authorizations
            ],
            "known_risks": list(self.known_risks),
            "visual_authority": list(self.visual_authority),
            "required_tests": list(self.required_tests),
            "required_validation": list(self.required_validation),
            "required_proof": list(self.required_proof),
            "forbidden_changes": list(self.forbidden_changes),
            "open_conflicts": list(self.open_conflicts),
            "claim_ceiling": self.claim_ceiling,
            "rollback_requirements": list(self.rollback_requirements),
        }

    def to_json_bytes(self) -> bytes:
        return stable_json(self.to_dict())

    def to_markdown(self) -> str:
        """Render the fixed, complete section sequence with a final newline."""

        content = dict(self._section_content)
        lines = ["# Ambitions Canon Task Pack", ""]
        for heading in PACK_SECTION_ORDER:
            lines.extend((f"## {heading}", ""))
            section_lines = content[heading]
            lines.extend(section_lines if section_lines else ("- None represented.",))
            lines.append("")
        return "\n".join(lines).rstrip() + "\n"


@dataclass(frozen=True, slots=True)
class _PackDirectorySnapshot:
    identity: tuple[int, int] | None
    entries: tuple[tuple[Path, bytes], ...]


def estimate_tokens(text: str) -> int:
    """Apply the approved deterministic four-characters-per-token estimate."""

    return (len(text) + 3) // 4


def build_task_pack(
    registry: CanonRegistry,
    intake: TaskIntake,
    repository_sha: str,
    known_issues: Sequence[Mapping[str, object]],
    *,
    traceability: TraceabilityReport | None = None,
    trusted_command_gate_approval_base: TrustedCommandGateApprovalBase | None = None,
) -> TaskPack:
    """Compile the dependency-closed, scope-bounded task pack or fail closed."""

    findings = audit_registry(registry)
    if findings:
        finding = findings[0]
        raise CanonError(
            "PACK_CANON_AUDIT_FAILED",
            f"{finding.code}: {finding.message}",
            finding.path,
            finding.line,
        )

    budget_class = TASK_TYPE_BUDGET_CLASS.get(intake.task_type)
    if budget_class is None:
        raise CanonError(
            "PACK_TASK_TYPE_UNKNOWN",
            f"unknown task type: {intake.task_type}",
        )
    repository_sha = _required_string(repository_sha, "repository_sha")
    canon_sha = _registry_canon_sha(registry)
    roots = _scope_documents(registry, intake.scope)
    if not roots and registry.manifest.authority_state is AuthorityState.ACTIVE:
        raise CanonError(
            "PACK_SCOPE_UNOWNED",
            "active canon has no owning specification for the declared scope",
            registry.manifest.source_path,
        )
    closure = _dependency_closure(registry, roots)
    relevant_issues = _relevant_issues(known_issues, intake)
    supplied_issue_ids = {str(issue["issue_id"]) for issue in relevant_issues}
    missing_issue_ids = tuple(sorted(set(intake.known_issue_ids) - supplied_issue_ids))
    if missing_issue_ids:
        raise CanonError(
            "PACK_KNOWN_ISSUE_MISSING",
            f"declared known issue was not supplied: {missing_issue_ids[0]}",
        )
    blocking = tuple(
        issue
        for issue in relevant_issues
        if issue["severity"] == "P0_BLOCKER"
        and issue["status"] in {"open", "unresolved"}
    )
    if blocking:
        raise CanonError(
            "PACK_P0_CONFLICT",
            f"unresolved P0 conflict blocks task pack: {blocking[0]['issue_id']}",
        )

    requirement_graph = _requirement_inclusion_graph(
        roots,
        closure,
        intake.scope,
        include_visual_authority=intake.task_type == "swiftui",
    )
    semantic_documents = tuple(
        document for document in closure if document.spec_id in requirement_graph
    )
    selected_requirement_ids = {
        requirement_id
        for requirement_ids in requirement_graph.values()
        for requirement_id in requirement_ids
    }
    while True:
        selected_command_records = tuple(
            sorted(
                (
                    (contract.requirement_id, contract.state_id, command)
                    for document in semantic_documents
                    for contract in document.state_command_contracts
                    if contract.requirement_id in selected_requirement_ids
                    for command in contract.commands
                ),
                key=lambda item: (item[0], item[1], item[2].command_id),
            )
        )
        gate_requirement_ids = {
            identifier
            for _, _, command in selected_command_records
            for identifier in command.gate_requirement_ids
        }
        missing_gate_ids = gate_requirement_ids - selected_requirement_ids
        if not missing_gate_ids:
            break
        selected_requirement_ids.update(missing_gate_ids)
        gate_documents = {
            document.spec_id: document
            for document in registry.documents
            if any(
                requirement.requirement_id in missing_gate_ids
                for requirement in document.requirements
            )
        }
        if {
            identifier
            for identifier in missing_gate_ids
            if identifier not in {
                requirement.requirement_id
                for document in gate_documents.values()
                for requirement in document.requirements
            }
        }:
            raise CanonError(
                "PACK_COMMAND_GATE_REQUIREMENT_UNKNOWN",
                f"command gate requirement is not in canon: {sorted(missing_gate_ids)[0]}",
            )
        semantic_documents = tuple(
            sorted(
                {
                    document.spec_id: document
                    for document in (*semantic_documents, *gate_documents.values())
                }.values(),
                key=lambda item: item.spec_id,
            )
        )
    requirements_by_id = {
        requirement.requirement_id: requirement for requirement in registry.requirements
    }
    inherited_ids = {
        requirement_id
        for document in semantic_documents
        for requirement_id in document.inherits
    }
    directly_scoped_law_ids = {
        requirement.requirement_id
        for document in roots
        if document.kind is DocumentKind.CONSTITUTION
        for requirement in document.requirements
    }
    applicable_law_ids = tuple(sorted(inherited_ids | directly_scoped_law_ids))
    constitution_ids = {
        requirement.requirement_id
        for document in registry.documents
        if document.kind is DocumentKind.CONSTITUTION
        for requirement in document.requirements
    }
    laws = tuple(
        requirements_by_id[identifier]
        for identifier in applicable_law_ids
        if identifier in requirements_by_id and identifier in constitution_ids
    )
    specifications = tuple(
        sorted(
            (
                document
                for document in semantic_documents
                if document.kind
                not in {
                    DocumentKind.CONSTITUTION,
                    DocumentKind.OBJECT,
                    DocumentKind.JOURNEY,
                    DocumentKind.STANDARD,
                }
            ),
            key=lambda item: item.spec_id,
        )
    )
    objects = _documents_of_kind(semantic_documents, DocumentKind.OBJECT)
    journeys = _documents_of_kind(semantic_documents, DocumentKind.JOURNEY)
    standards = _documents_of_kind(semantic_documents, DocumentKind.STANDARD)
    source_owners = tuple(
        sorted({owner for document in semantic_documents for owner in document.source_owners})
    )
    selected_requirements = tuple(
        sorted(
            {
                requirement.requirement_id: requirement
                for document in (
                    *specifications,
                    *objects,
                    *journeys,
                    *standards,
                )
                for requirement in document.requirements
                if requirement.requirement_id in selected_requirement_ids
            }.values(),
            key=lambda item: item.requirement_id,
        )
    )
    future_gated_commands = tuple(
        (requirement_id, command)
        for requirement_id, _, command in selected_command_records
        if command.activation_posture is StateCommandActivationPosture.FUTURE_GATED
    )
    dependency_registry: CommandGateDependencyRegistry | None = None
    if any(
        command.gate_dependency_ids
        for _, _, command in selected_command_records
    ):
        repository_root = registry.manifest.repository_root
        if repository_root is None:
            raise CanonError(
                "PACK_COMMAND_GATE_DEPENDENCY_ROOT_MISSING",
                "command dependency validation requires the manifest repository root",
            )
        dependency_registry = load_command_gate_dependency_registry(
            repository_root,
            expected_canon_revision=registry.manifest.canon_revision,
        )
        validate_command_gate_dependency_bindings(
            dependency_registry,
            tuple(
                contract
                for document in registry.documents
                for contract in document.state_command_contracts
            ),
            canon_revision=registry.manifest.canon_revision,
            trusted_approval_base=trusted_command_gate_approval_base,
        )
    resolution_registry: CommandResolutionRegistry | None = None
    command_sources: dict[str, tuple[Path, StateCommandContract]] = {}
    if selected_command_records:
        repository_root = registry.manifest.repository_root
        if repository_root is None:
            raise CanonError(
                "PACK_COMMAND_RESOLUTION_ROOT_MISSING",
                "command resolution requires the manifest repository root",
            )
        resolution_registry = load_command_resolution_registry(repository_root)
        validate_command_resolution_bindings(resolution_registry, registry)
        command_sources = {
            command.command_id: (document.source_path, contract)
            for document in registry.documents
            for contract in document.state_command_contracts
            for command in contract.commands
        }
    command_authorizations = tuple(
        _command_authorization_record(
            requirement_id,
            state_id,
            command,
            dependency_registry,
            resolution_registry,
            command_sources[command.command_id][0],
            command_sources[command.command_id][1],
            authority_active=(
                registry.manifest.authority_state is AuthorityState.ACTIVE
            ),
        )
        for requirement_id, state_id, command in selected_command_records
    )
    required_tests = tuple(
        sorted(
            {
                verification
                for requirement in (*laws, *selected_requirements)
                for verification in requirement.verification
            }
        )
    )

    evidence_requirement_ids = frozenset(
        selected_requirement_ids | {law.requirement_id for law in laws}
    )
    evidence_records = tuple(
        record
        for record in (traceability.records if traceability is not None else ())
        if record.requirement_id in evidence_requirement_ids
    )
    shadow = registry.manifest.authority_state is AuthorityState.SHADOW
    no_owner = not roots
    authority_posture = (
        "Shadow canon is non-authoritative; implementation posture must be "
        "verified directly from current source, tests, and proof."
        if shadow
        else "Implementation posture must be verified from current source, tests, and proof."
    )
    implementation_posture = _combine_implementation_posture(
        authority_posture,
        _traceability_posture(
            evidence_records,
            evidence_requirement_ids,
            supplied=traceability is not None,
        ),
    )
    known_risk_values = (
        sorted(
            {str(issue["summary"]) for issue in relevant_issues}
            | {
                _future_gated_command_risk(requirement_id, command)
                for requirement_id, command in future_gated_commands
            }
            | (
                {"Declared scope has no owning specification in the current canon."}
                if no_owner
                else set()
            )
        )
    )
    legacy_visual_references = tuple(
        sorted(
            {
                reference.reference_id: reference
                for record in evidence_records
                for reference in record.figma_references
                if reference.authority_role is not None
                and reference.authority_role.value == "approved_target"
                and reference.approval_state == "approved"
            }.values(),
            key=lambda item: item.reference_id,
        )
    )
    visual_contract = load_visual_authority_rebaseline_if_present(
        registry.manifest.repository_root
    )
    visual_contract_lines = (
        visual_authority_lines_for_task_pack(
            visual_contract,
            scope_ids=intake.scope,
            requirement_ids=evidence_requirement_ids,
        )
        if visual_contract is not None
        else ()
    )
    visual_references = (
        () if visual_contract is not None else legacy_visual_references
    )
    visual_required = intake.task_type == "swiftui" or any(
        "VISUAL-AUTHORITY" in identifier for identifier in evidence_requirement_ids
    )
    visual_gap = visual_required and not (
        visual_contract_lines or visual_references
    )
    known_risks = tuple(
        sorted(
            set(known_risk_values)
            | (
                {
                    "Required visual authority is missing; UI readiness remains stopped."
                }
                if visual_gap
                else set()
            )
        )
    )
    open_conflicts = tuple(
        sorted(
            str(issue["issue_id"])
            for issue in relevant_issues
            if issue["kind"] == "conflict" and issue["status"] in {"open", "unresolved"}
        )
    )
    visual_authority = (
        visual_contract_lines
        if visual_contract_lines
        else
        tuple(_visual_authority_line(item) for item in visual_references)
        if visual_references
        else (
            "UI-readiness stop: required visual authority is not mapped for this scope.",
        )
        if visual_gap
        else ("No applicable governed visual authority is mapped for this scope.",)
    )
    verification_contract = (
        "Execute selected verification contracts: "
        + ", ".join(required_tests)
        + "."
    )
    required_validation = (
        verification_contract,
        "python3 scripts/ambitions-canon.py audit",
        "python3 scripts/ambitions-canon.py build --check",
        "git diff --check",
    )
    proof_references = tuple(
        sorted(
            {
                reference.reference_id: reference
                for record in evidence_records
                for reference in record.proof_references
            }.values(),
            key=lambda item: item.reference_id,
        )
    )
    required_proof = (
        "Current source, focused tests, regression tests, and claim-specific proof.",
        "Claim-specific proof for "
        f"claim_type={intake.claim_type} must cover changed-file boundary "
        f"{', '.join(intake.changed_files)} and applicable requirements "
        f"{', '.join(sorted(selected_requirement_ids | {document.spec_id for document in semantic_documents}))}.",
        *tuple(
            "Current proof reference "
            f"reference_id={item.reference_id}; source={item.source}; "
            f"revision={item.revision}; approval={item.approval_state}; "
            f"approved_by={item.approved_by}; posture="
            f"{item.implementation_status or 'evidence only; claim status unverified'}."
            for item in proof_references
        ),
        _proof_gap_line(evidence_records, evidence_requirement_ids),
    )
    forbidden_changes = (
        "Changes outside the declared task scope and changed-file boundary.",
        "Product, runtime, visual, accessibility, privacy, device, TestFlight, App Store, or release Green claims without separate current evidence.",
    )
    if future_gated_commands:
        forbidden_changes += (
            "Future-gated command metadata must not authorize implementation, source edits, UI exposure, active-state tests, or authority claims.",
        )
    forbidden_changes += (("Implementation authorized by this shadow pack.",) if shadow else ())
    claim_ceiling = (
        "Shadow pack only; it cannot authorize implementation or any product, runtime, visual, accessibility, privacy, device, TestFlight, App Store, or release claim."
        if shadow
        else "Source/governance claim only within the declared scope and current linked evidence."
    )
    if visual_gap:
        claim_ceiling += " UI work is blocked by the visual-authority gap."
    rollback_requirements = (
        "Record the pre-change Git SHA and provide a scoped revert path.",
    )
    intake_path = intake.source_path or f".codex/intake/{_slug(intake.issue_id)}.json"

    pack = TaskPack(
        schema_version=1,
        canon_revision=registry.manifest.canon_revision,
        canon_sha=canon_sha,
        repository_sha=repository_sha,
        intake_sha=intake.sha,
        compiler_version=registry.manifest.compiler_version,
        authority_state=registry.manifest.authority_state.value,
        issue_id=intake.issue_id,
        task_type=intake.task_type,
        budget_class=budget_class,
        token_budget=PACK_BUDGETS[budget_class],
        estimated_tokens=0,
        scope=intake.scope,
        changed_files=intake.changed_files,
        claim_type=intake.claim_type,
        known_issue_ids=intake.known_issue_ids,
        intake_path=intake_path,
        constitutional_laws=tuple(law.requirement_id for law in laws),
        applicable_requirement_ids=tuple(
            sorted(
                selected_requirement_ids
                | {document.spec_id for document in semantic_documents}
            )
        ),
        specifications=tuple(document.spec_id for document in specifications),
        object_lifecycles=tuple(document.spec_id for document in objects),
        journeys=tuple(document.spec_id for document in journeys),
        standards=tuple(document.spec_id for document in standards),
        source_owners=source_owners,
        implementation_posture=implementation_posture,
        known_risks=known_risks,
        visual_authority=visual_authority,
        required_tests=required_tests,
        required_validation=required_validation,
        required_proof=required_proof,
        forbidden_changes=forbidden_changes,
        open_conflicts=open_conflicts,
        claim_ceiling=claim_ceiling,
        rollback_requirements=rollback_requirements,
        _section_content=(),
        command_authorizations=command_authorizations,
    )
    for _ in range(8):
        section_content = _render_sections(
            pack,
            laws=laws,
            specifications=specifications,
            objects=objects,
            journeys=journeys,
            standards=standards,
            selected_requirement_ids=frozenset(selected_requirement_ids),
        )
        candidate = replace(pack, _section_content=section_content)
        estimate = estimate_tokens(candidate.to_markdown())
        if estimate == candidate.estimated_tokens:
            pack = candidate
            break
        pack = replace(candidate, estimated_tokens=estimate)
    else:
        raise CanonError(
            "PACK_ESTIMATE_UNSTABLE", "task-pack token estimate did not converge"
        )

    token_budget = pack.token_budget
    if token_budget is not None and pack.estimated_tokens > token_budget:
        raise CanonError(
            "PACK_BUDGET_EXCEEDED",
            (
                f"task pack requires {pack.estimated_tokens} estimated tokens; "
                f"budget is {token_budget}; no required content was truncated"
            ),
        )
    return pack


def load_task_pack_traceability(root: Path, registry: CanonRegistry) -> TraceabilityReport:
    """Load the same tracked, offline evidence used by Train 4 projections."""

    from tools.ambitions_canon.external_authority import (
        load_external_reference_snapshot,
        validate_external_reference_snapshot,
    )
    from tools.ambitions_canon.traceability import build_traceability

    snapshot = load_external_reference_snapshot(root)
    validate_external_reference_snapshot(root, snapshot)
    report = build_traceability(registry, root, snapshot.references)
    validate_external_reference_snapshot(root, snapshot)
    return report


def _traceability_posture(
    records: Sequence[object],
    required_ids: frozenset[str],
    *,
    supplied: bool,
) -> str:
    if not supplied:
        return json.dumps(
            {
                "applicable_requirement_count": len(required_ids),
                "covered_requirement_count": 0,
                "current_proof_references": [],
                "current_test_references": [],
                "missing_requirement_ids": sorted(required_ids),
                "source_gap_records": [],
                "source_gap_requirement_count": len(required_ids),
                "source_status_counts": {"unknown": len(required_ids)},
                "summary": "Current traceability evidence was not supplied; mappings remain unknown.",
            },
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
    by_status: dict[str, int] = {}
    source_gap_records: list[object] = []
    for record in records:
        has_source = any(item.has_implementation for item in record.source_mappings)
        has_gap = not record.source_mappings or any(
            not item.has_implementation for item in record.source_mappings
        )
        status = (
            "partial_source_mapping_gap"
            if has_source and has_gap
            else "source_files_present"
            if has_source
            else "source_mapping_gap"
        )
        by_status[status] = by_status.get(status, 0) + 1
        if has_gap:
            source_gap_records.append(record)
    represented = {record.requirement_id for record in records}
    missing = sorted(required_ids - represented)
    test_references = tuple(
        sorted(
            {
                reference.reference_id: reference
                for record in records
                for reference in record.test_references
            }.values(),
            key=lambda item: item.reference_id,
        )
    )
    proof_references = tuple(
        sorted(
            {
                reference.reference_id: reference
                for record in records
                for reference in record.proof_references
            }.values(),
            key=lambda item: item.reference_id,
        )
    )
    summary = (
        f"Current traceability covers {len(represented)}/{len(required_ids)} requirements; "
        f"{len(source_gap_records)}/{len(required_ids)} have at least one source gap."
    )
    return json.dumps(
        {
            "applicable_requirement_count": len(required_ids),
            "covered_requirement_count": len(represented),
            "current_proof_references": [
                _evidence_reference_dict(reference) for reference in proof_references
            ],
            "current_test_references": [
                _evidence_reference_dict(reference) for reference in test_references
            ],
            "missing_requirement_ids": missing,
            "source_gap_records": [
                {
                    "gaps": [finding.message for finding in record.findings],
                    "mappings": [
                        {
                            "exists": mapping.exists,
                            "implementation_files": list(mapping.implementation_files),
                            "owner_path": mapping.owner_path,
                            "status": mapping.status,
                        }
                        for mapping in record.source_mappings
                    ],
                    "requirement_id": record.requirement_id,
                    "source_owners": list(record.source_owners),
                }
                for record in source_gap_records
            ],
            "source_gap_requirement_count": len(source_gap_records),
            "source_status_counts": {
                status: by_status[status] for status in sorted(by_status)
            },
            "summary": summary,
        },
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def _evidence_reference_dict(reference: object) -> dict[str, object]:
    return {
        "approval_state": reference.approval_state,
        "approved_by": reference.approved_by,
        "implementation_status": reference.implementation_status,
        "reference_id": reference.reference_id,
        "revision": reference.revision,
        "source": reference.source,
    }


def _combine_implementation_posture(authority_posture: str, traceability: str) -> str:
    try:
        payload = json.loads(traceability)
    except json.JSONDecodeError:
        return f"{authority_posture} {traceability}"
    if not isinstance(payload, dict):
        return f"{authority_posture} {traceability}"
    payload["authority_posture"] = authority_posture
    payload["summary"] = f"{authority_posture} {payload.get('summary', '')}".strip()
    return json.dumps(
        payload,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def _implementation_posture_markdown(value: str) -> str:
    try:
        posture = json.loads(value)
    except json.JSONDecodeError:
        return value
    if not isinstance(posture, dict):
        return value
    summary = str(posture.get("summary", value))
    gap_records = posture.get("source_gap_records", [])
    if isinstance(gap_records, list) and gap_records:
        identifiers = ",".join(
            str(item.get("requirement_id"))
            for item in gap_records
            if isinstance(item, dict)
        )
        summary += f" Source gap requirement IDs: [{identifiers}]."
    for kind in ("test", "proof"):
        references = posture.get(f"current_{kind}_references", [])
        if not isinstance(references, list):
            continue
        for reference in references:
            if not isinstance(reference, dict):
                continue
            summary += (
                f" Current {kind} evidence reference_id={reference.get('reference_id')}; "
                f"source={reference.get('source')}; revision={reference.get('revision')}; "
                f"approval={reference.get('approval_state')}; "
                f"approved_by={reference.get('approved_by')}; posture="
                f"{reference.get('implementation_status')}."
            )
    return summary


def _visual_authority_line(reference: object) -> str:
    variants = ", ".join(reference.accessibility_variants) or "none recorded"
    return (
        f"{reference.visual_authority_id or 'visual-authority'} | "
        f"{reference.reference_id} | frame {reference.frame_version or reference.revision} | "
        f"owner {reference.approved_by or 'unrecorded'} | "
        f"SwiftUI {reference.swiftui_plausibility or 'unrecorded'} | "
        f"accessibility variants: {variants} | posture: "
        f"{reference.implementation_status or 'visual evidence only; implementation unverified'}"
    )


def _proof_gap_line(records: Sequence[object], required_ids: frozenset[str]) -> str:
    mapped = {
        record.requirement_id for record in records if record.proof_references
    }
    gap_count = len(required_ids - mapped)
    return (
        f"Current proof mapping gaps: {gap_count} applicable requirements lack current proof references."
        if gap_count
        else "Current proof mappings exist for every applicable requirement; execution still requires validation."
    )


def validate_task_pack(
    data: Mapping[str, object],
    *,
    canon_sha: str,
    repository_sha: str,
    intake_sha: str,
) -> None:
    """Reject a generated pack whose authority, repository, or intake moved."""

    checks = (
        ("canon_sha", canon_sha, "PACK_CANON_STALE"),
        ("repository_sha", repository_sha, "PACK_REPOSITORY_STALE"),
        ("intake_sha", intake_sha, "PACK_INTAKE_STALE"),
    )
    for field, current, code in checks:
        if data.get(field) != current:
            raise CanonError(code, f"task pack {field} does not match current state")


def require_pack_authorization_current(
    stored: Mapping[str, object],
    current: Mapping[str, object],
) -> None:
    """Fail closed when any source-edit authorization input has changed."""

    checks = (
        (("canon_revision", "canon_sha", "compiler_version"), "PACK_CANON_STALE"),
        (("repository_sha",), "PACK_REPOSITORY_STALE"),
        (("intake_sha", "intake_path"), "PACK_INTAKE_STALE"),
        (
            ("issue_id", "task_type", "scope", "changed_files", "claim_type"),
            "PACK_ISSUE_STALE",
        ),
        (("source_owners",), "PACK_SOURCE_STALE"),
        (("open_conflicts",), "PACK_CONFLICT_STALE"),
        (("known_issue_ids", "known_risks"), "PACK_KNOWN_ISSUES_STALE"),
        (
            (
                "authority_state",
                "required_tests",
                "required_validation",
                "required_proof",
                "visual_authority",
                "claim_ceiling",
            ),
            "PACK_PROOF_POSTURE_STALE",
        ),
    )
    for fields, code in checks:
        for field in fields:
            if stored.get(field) != current.get(field):
                raise CanonError(
                    code,
                    f"task pack {field} no longer matches source-edit authority",
                )
    if dict(stored) != dict(current):
        raise CanonError(
            "PACK_CONTENT_STALE",
            "stored task-pack content differs from deterministic current output",
        )


def task_pack_paths(root: Path, pack: TaskPack) -> tuple[Path, Path]:
    """Derive the ignored, shell-safe Markdown and JSON output paths."""

    if _SHA256.fullmatch(pack.canon_sha) is None:
        raise CanonError("PACK_PATH_INVALID", "canon SHA is not a lowercase SHA-256")
    name = f"{_slug(pack.issue_id)}-{_slug(pack.task_type)}"
    parent = root / ".codex" / "canon-packs" / pack.canon_sha
    return parent / f"{name}.md", parent / f"{name}.json"


def read_task_pack_pair(
    root: Path,
    pack: TaskPack,
) -> tuple[Path, Path, bytes, bytes]:
    """Read one stored pair through pinned, no-follow directory descriptors."""

    current_markdown, current_json = task_pack_paths(root, pack)
    pack_root = root / ".codex" / "canon-packs"
    try:
        pack_root_info = pack_root.lstat()
    except FileNotFoundError as exc:
        raise CanonError(
            "PACK_NOT_FOUND",
            "no stored task-pack root exists",
            pack_root,
        ) from exc
    except OSError as exc:
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "unable to inspect task-pack root",
            pack_root,
        ) from exc
    if stat.S_ISLNK(pack_root_info.st_mode) or not stat.S_ISDIR(pack_root_info.st_mode):
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "task-pack root must be a real directory",
            pack_root,
        )
    candidates: list[tuple[Path, Path, bytes, bytes]] = []
    try:
        with _open_directory_absolute_nofollow(pack_root) as root_descriptor:
            root_identity = _descriptor_identity(root_descriptor)
            for sha_name in sorted(os.listdir(root_descriptor)):
                kind, sha_identity = _entry_kind_and_identity(
                    root_descriptor,
                    sha_name,
                )
                if kind == "symlink":
                    raise CanonError(
                        "PACK_PATH_ESCAPE",
                        "task-pack SHA directory must not be a symlink",
                        pack_root / sha_name,
                    )
                if kind != "directory":
                    continue
                if _SHA256.fullmatch(sha_name) is None:
                    raise CanonError(
                        "PACK_PATH_ESCAPE",
                        "task-pack directory name is not a canonical SHA-256",
                        pack_root / sha_name,
                    )
                assert sha_identity is not None
                sha_descriptor = _open_directory_at(root_descriptor, sha_name)
                try:
                    if _descriptor_identity(sha_descriptor) != sha_identity:
                        raise CanonError(
                            "PACK_PATH_ESCAPE",
                            "task-pack SHA directory identity changed during open",
                            pack_root / sha_name,
                        )
                    names = (current_markdown.name, current_json.name)
                    entries = tuple(
                        _entry_kind_and_identity(sha_descriptor, name) for name in names
                    )
                    if all(kind is None for kind, _ in entries):
                        continue
                    if any(kind != "file" for kind, _ in entries):
                        raise CanonError(
                            "PACK_PATH_ESCAPE",
                            "task-pack members must be a complete pair of regular files",
                            pack_root / sha_name,
                        )
                    markdown_identity = entries[0][1]
                    json_identity = entries[1][1]
                    markdown_bytes = _read_file_at(
                        sha_descriptor,
                        Path(current_markdown.name),
                    )
                    json_bytes = _read_file_at(
                        sha_descriptor,
                        Path(current_json.name),
                    )
                    if (
                        _entry_identity(sha_descriptor, current_markdown.name)
                        != markdown_identity
                        or _entry_identity(sha_descriptor, current_json.name)
                        != json_identity
                        or _entry_identity(root_descriptor, sha_name) != sha_identity
                    ):
                        raise CanonError(
                            "PACK_PATH_ESCAPE",
                            "task-pack member identity changed during read",
                            pack_root / sha_name,
                        )
                    candidates.append(
                        (
                            pack_root / sha_name / current_markdown.name,
                            pack_root / sha_name / current_json.name,
                            markdown_bytes,
                            json_bytes,
                        )
                    )
                finally:
                    os.close(sha_descriptor)
            if _descriptor_identity(root_descriptor) != root_identity:
                raise CanonError(
                    "PACK_PATH_ESCAPE",
                    "task-pack root descriptor identity changed",
                    pack_root,
                )
            _assert_parent_path_identity(pack_root, root_descriptor)
    except CanonError as exc:
        if exc.code.startswith("PACK_"):
            raise
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "task-pack path is not confined to real directories and files",
            pack_root,
        ) from exc
    except OSError as exc:
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "task-pack path changed or is unreadable",
            pack_root,
        ) from exc

    current = tuple(
        candidate
        for candidate in candidates
        if candidate[1].parent.name == pack.canon_sha
    )
    if current:
        return current[0]
    if not candidates:
        raise CanonError(
            "PACK_NOT_FOUND",
            "no stored task pack exists for the issue and task type",
            current_json,
        )
    if len(candidates) != 1:
        raise CanonError(
            "PACK_CHECK_AMBIGUOUS",
            "multiple stored task packs require explicit cleanup or regeneration",
            pack_root,
        )
    return candidates[0]


def write_task_pack(
    root: Path,
    pack: TaskPack,
    *,
    source_precondition: Callable[[], None] | None = None,
) -> tuple[Path, Path]:
    """Atomically install both representations as one recoverable tree."""

    markdown_path, json_path = task_pack_paths(root, pack)
    parent = markdown_path.parent
    _ensure_real_directory(root, parent.parent)
    markdown = pack.to_markdown().encode("utf-8")
    json_bytes = pack.to_json_bytes()
    if not markdown.endswith(b"\n") or not json_bytes.endswith(b"\n"):
        raise CanonError("PACK_WRITE_FAILED", "task-pack outputs must end in newline")
    prior_snapshot = _capture_pack_snapshot(parent)
    outputs = dict(prior_snapshot.entries)
    outputs[Path(markdown_path.name)] = markdown
    outputs[Path(json_path.name)] = json_bytes
    expected_pair = {
        Path(markdown_path.name): markdown,
        Path(json_path.name): json_bytes,
    }

    def require_unchanged_inputs() -> None:
        _require_pack_snapshot(parent, prior_snapshot)
        if source_precondition is not None:
            source_precondition()

    def verify_installed_outputs_and_inputs() -> None:
        _verify_installed_pair(parent, expected_pair)
        if source_precondition is not None:
            source_precondition()

    write_outputs_atomic(
        parent,
        outputs,
        precondition=require_unchanged_inputs,
        postcondition=verify_installed_outputs_and_inputs,
    )
    return markdown_path, json_path


def _snapshot_pack_directory(root: Path) -> dict[Path, bytes]:
    return dict(_capture_pack_snapshot(root).entries)


def _capture_pack_snapshot(root: Path) -> _PackDirectorySnapshot:
    try:
        info = root.lstat()
    except FileNotFoundError:
        return _PackDirectorySnapshot(None, ())
    except OSError as exc:
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "unable to inspect task-pack directory without following links",
            root,
        ) from exc
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISDIR(info.st_mode):
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "task-pack directory must be a real directory",
            root,
        )
    expected_identity = (info.st_dev, info.st_ino)
    try:
        with _open_directory_absolute_nofollow(root) as descriptor:
            root_identity = _descriptor_identity(descriptor)
            if root_identity != expected_identity:
                raise CanonError(
                    "PACK_PATH_ESCAPE",
                    "task-pack directory identity changed during open",
                    root,
                )
            paths = _tree_files_descriptor(descriptor)
            outputs = {path: _read_file_at(descriptor, path) for path in paths}
            if _descriptor_identity(descriptor) != root_identity:
                raise CanonError(
                    "PACK_PATH_ESCAPE",
                    "task-pack directory descriptor identity changed",
                    root,
                )
            _assert_parent_path_identity(root, descriptor)
            return _PackDirectorySnapshot(
                root_identity,
                tuple(sorted(outputs.items(), key=lambda item: item[0].as_posix())),
            )
    except CanonError as exc:
        raise CanonError(
            "PACK_PATH_ESCAPE",
            "task-pack tree is not confined to real directories and files",
            root,
        ) from exc


def _require_pack_snapshot(
    root: Path,
    expected: _PackDirectorySnapshot,
) -> None:
    current = _capture_pack_snapshot(root)
    if current != expected:
        raise CanonError(
            "PACK_CONCURRENT_MODIFICATION",
            "task-pack directory changed after generation began",
            root,
        )


def _verify_installed_pair(
    root: Path,
    expected: Mapping[Path, bytes],
) -> None:
    installed = _snapshot_pack_directory(root)
    for path, content in expected.items():
        if installed.get(path) != content:
            raise CanonError(
                "PACK_INSTALL_VERIFY_FAILED",
                f"installed task-pack member differs: {path.as_posix()}",
                root / path,
            )


def _registry_canon_sha(registry: CanonRegistry) -> str:
    manifest_bytes = registry.manifest.source_bytes
    if manifest_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded manifest provenance is required for task packs",
            registry.manifest.source_path,
        )
    entries: list[tuple[str, bytes]] = [("MANIFEST.toml", manifest_bytes)]
    if registry.supersession_ledger_bytes is None:
        raise CanonError(
            "CANON_PROVENANCE_MISSING",
            "loaded supersession ledger provenance is required for task packs",
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
            "loaded impact reference index provenance is required for task packs",
            registry.manifest.source_path,
        )
    entries.append(
        (
            "migration/impact-reference-index.json",
            registry.reference_index.source_bytes,
        )
    )
    prefix = Path("docs/canon")
    for document in registry.documents:
        if document.source_bytes is None:
            raise CanonError(
                "CANON_PROVENANCE_MISSING",
                "loaded document provenance is required for task packs",
                document.source_path,
            )
        try:
            relative = document.source_path.relative_to(prefix)
        except ValueError as exc:
            raise CanonError(
                "CANON_PROVENANCE_PATH",
                "document provenance is outside docs/canon",
                document.source_path,
            ) from exc
        entries.append((relative.as_posix(), document.source_bytes))
    return _content_sha_entries(entries)


def _scope_documents(
    registry: CanonRegistry,
    scopes: tuple[str, ...],
) -> tuple[CanonDocument, ...]:
    matches = {
        document.spec_id: document
        for document in registry.documents
        if any(_document_matches_scope(document, scope) for scope in scopes)
    }
    return tuple(matches[key] for key in sorted(matches))


def _document_matches_scope(document: CanonDocument, scope: str) -> bool:
    if document.spec_id == scope:
        return True
    if any(
        requirement.requirement_id == scope for requirement in document.requirements
    ):
        return True
    return any(_scope_overlap(concept, scope) for concept in document.owns_concepts)


def _scope_overlap(left: str, right: str) -> bool:
    return left == right or left.startswith(f"{right}.") or right.startswith(f"{left}.")


def _requirement_matches_scope(
    document: CanonDocument,
    requirement: Requirement,
    scopes: tuple[str, ...],
) -> bool:
    return any(
        scope in {document.spec_id, requirement.requirement_id}
        or _scope_overlap(requirement.concept, scope)
        for scope in scopes
    )


def _requirement_inclusion_graph(
    roots: tuple[CanonDocument, ...],
    closure: tuple[CanonDocument, ...],
    scopes: tuple[str, ...],
    *,
    include_visual_authority: bool = False,
) -> dict[str, tuple[str, ...]]:
    """Select exact roots plus direct, profile-rich semantic dependencies."""

    documents = {document.spec_id: document for document in closure}
    graph: dict[str, tuple[str, ...]] = {}
    root_spec_ids = {root.spec_id for root in roots}
    for root in roots:
        scoped_requirement_ids = tuple(
            requirement.requirement_id
            for requirement in root.requirements
            if _requirement_matches_scope(root, requirement, scopes)
            or (
                include_visual_authority
                and "VISUAL-AUTHORITY" in requirement.requirement_id
            )
        )
        if not scoped_requirement_ids:
            raise CanonError(
                "PACK_REQUIREMENT_GRAPH_EMPTY",
                f"owning document has no requirement semantics for scope: {root.spec_id}",
                root.source_path,
            )
        graph[root.spec_id] = scoped_requirement_ids
    for parent in roots:
        for dependency_id in sorted(parent.depends_on):
            if dependency_id in root_spec_ids:
                continue
            dependency = documents.get(dependency_id)
            if dependency is None:
                raise CanonError(
                    "PACK_DEPENDENCY_OWNER_MISSING",
                    f"required direct semantic owner is absent: {dependency_id}",
                    parent.source_path,
                )
            if dependency.kind is DocumentKind.CONSTITUTION:
                continue
            dependency_ids = tuple(
                requirement.requirement_id
                for requirement in dependency.requirements
                if _requirement_matches_scope(dependency, requirement, scopes)
            )
            if not dependency_ids:
                continue
            graph[dependency_id] = dependency_ids
    return {identifier: graph[identifier] for identifier in sorted(graph)}


def _dependency_closure(
    registry: CanonRegistry,
    roots: tuple[CanonDocument, ...],
) -> tuple[CanonDocument, ...]:
    documents = {document.spec_id: document for document in registry.documents}
    selected: dict[str, CanonDocument] = {}
    pending = [document.spec_id for document in reversed(roots)]
    while pending:
        identifier = pending.pop()
        if identifier in selected:
            continue
        document = documents[identifier]
        selected[identifier] = document
        pending.extend(
            spec_id
            for spec_id in sorted(document.depends_on, reverse=True)
            if spec_id not in selected
        )
    return tuple(selected[key] for key in sorted(selected))


def _documents_of_kind(
    documents: tuple[CanonDocument, ...],
    kind: DocumentKind,
) -> tuple[CanonDocument, ...]:
    return tuple(document for document in documents if document.kind is kind)


def _relevant_issues(
    known_issues: Sequence[Mapping[str, object]],
    intake: TaskIntake,
) -> tuple[dict[str, object], ...]:
    records = tuple(known_issues)
    seen_ids: set[str] = set()
    for issue in records:
        if not isinstance(issue, Mapping):
            raise CanonError("PACK_ISSUE_INVALID", "known issue must be an object")
        try:
            issue_id = _required_string(issue.get("issue_id"), "issue_id")
        except CanonError as exc:
            raise CanonError(
                "PACK_ISSUE_INVALID",
                f"malformed known issue: {exc.message}",
            ) from exc
        if issue_id in seen_ids:
            raise CanonError(
                "PACK_ISSUE_DUPLICATE",
                f"duplicate known issue ID: {issue_id}",
            )
        seen_ids.add(issue_id)

    normalized: list[dict[str, object]] = []
    for issue in records:
        assert isinstance(issue, Mapping)
        try:
            if set(issue) != _ISSUE_FIELDS:
                raise CanonError(
                    "PACK_ISSUE_INVALID",
                    "known issue fields do not match schema version 1",
                )
            schema_version = issue["schema_version"]
            if isinstance(schema_version, bool) or schema_version != 1:
                raise CanonError(
                    "PACK_ISSUE_INVALID",
                    "known issue schema_version must be integer 1",
                )
            issue_id = _required_string(issue.get("issue_id"), "issue_id")
            severity = _required_string(issue["severity"], "severity")
            if severity not in _ISSUE_SEVERITIES:
                raise CanonError(
                    "PACK_ISSUE_INVALID",
                    f"unknown known-issue severity: {severity}",
                )
            status_value = _required_string(issue["status"], "status")
            if status_value not in _ISSUE_STATUSES:
                raise CanonError(
                    "PACK_ISSUE_INVALID",
                    f"unknown known-issue status: {status_value}",
                )
            issue_kind = _required_string(issue["kind"], "kind")
            if issue_kind not in _ISSUE_KINDS:
                raise CanonError(
                    "PACK_ISSUE_INVALID",
                    f"unknown known-issue kind: {issue_kind}",
                )
            summary = _required_string(issue["summary"], "summary")
            raw_scope = issue["scope"]
            issue_scope = _string_tuple(raw_scope, "scope", allow_empty=True)
        except CanonError as exc:
            if exc.code == "PACK_ISSUE_INVALID":
                raise
            raise CanonError(
                "PACK_ISSUE_INVALID",
                f"malformed known issue: {exc.message}",
            ) from exc
        relevant = (
            issue_id in intake.known_issue_ids
            or not issue_scope
            or any(
                _scope_overlap(left, right)
                for left in issue_scope
                for right in intake.scope
            )
        )
        if relevant:
            normalized.append(
                {
                    "issue_id": issue_id,
                    "severity": severity,
                    "status": status_value,
                    "summary": f"{issue_id}: {summary}",
                    "kind": issue_kind,
                }
            )
    return tuple(sorted(normalized, key=lambda item: str(item["issue_id"])))


def _render_sections(
    pack: TaskPack,
    *,
    laws: tuple[Requirement, ...],
    specifications: tuple[CanonDocument, ...],
    objects: tuple[CanonDocument, ...],
    journeys: tuple[CanonDocument, ...],
    standards: tuple[CanonDocument, ...],
    selected_requirement_ids: frozenset[str],
) -> tuple[tuple[str, tuple[str, ...]], ...]:
    identity = (
        f"- Canon revision: `{pack.canon_revision}`",
        f"- Canon SHA: `{pack.canon_sha}`",
        f"- Repository SHA: `{pack.repository_sha}`",
        f"- Intake SHA: `{pack.intake_sha}`",
        f"- Compiler version: `{pack.compiler_version}`",
        f"- Authority state: `{pack.authority_state}`",
        f"- Issue: `{pack.issue_id}`",
        f"- Task type: `{pack.task_type}`",
        f"- Budget class: `{pack.budget_class}`",
        f"- Token budget: `{pack.token_budget}`",
        f"- Estimated tokens: `{pack.estimated_tokens}`",
        f"- Scope: `{', '.join(pack.scope)}`",
        f"- Changed files: `{', '.join(pack.changed_files)}`",
        f"- Claim type: `{pack.claim_type}`",
        f"- Intake: `{pack.intake_path}`",
    )
    values = {
        "Identity": identity,
        "Constitutional laws": _render_laws(laws),
        "Owning specifications": tuple(
            _render_document(item, selected_requirement_ids) for item in specifications
        ),
        "Object lifecycles": tuple(
            _render_document(item, selected_requirement_ids) for item in objects
        ),
        "Journeys": tuple(
            _render_document(item, selected_requirement_ids) for item in journeys
        ),
        "Cross-cutting standards": tuple(
            _render_document(item, selected_requirement_ids) for item in standards
        ),
        "Source ownership": (
            "- **Declared changed-file boundary:**",
            *(f"  - `{path}`" for path in pack.changed_files),
            "- **Coupled canonical owners:**",
            *(f"  - `{path}`" for path in pack.source_owners),
        ),
        "Implementation posture": (
            _implementation_posture_markdown(pack.implementation_posture),
        ),
        "Command authorization": _render_command_authorizations(
            pack.command_authorizations
        ),
        "Known risks": _bullet_values(pack.known_risks),
        "Visual authority": _bullet_values(pack.visual_authority),
        "Required tests": _bullet_values(pack.required_tests),
        "Validation": _bullet_values(pack.required_validation),
        "Proof": _bullet_values(pack.required_proof),
        "Forbidden changes": _bullet_values(pack.forbidden_changes),
        "Open conflicts": _bullet_values(pack.open_conflicts),
        "Claim ceiling": (pack.claim_ceiling,),
        "Rollback": _bullet_values(pack.rollback_requirements),
    }
    return tuple((heading, values[heading]) for heading in PACK_SECTION_ORDER)


def _command_authorization_record(
    requirement_id: str,
    state_id: str,
    command: StateCommand,
    dependency_registry: CommandGateDependencyRegistry | None,
    resolution_registry: CommandResolutionRegistry | None,
    source_path: Path,
    contract: StateCommandContract,
    *,
    authority_active: bool,
) -> dict[str, object]:
    if resolution_registry is None:
        raise CanonError(
            "PACK_COMMAND_RESOLUTION_MISSING",
            f"command resolution is missing: {command.command_id}",
        )
    dependencies = (
        command_gate_dependency_projection(dependency_registry, command)
        if dependency_registry is not None and command.gate_dependency_ids
        else []
    )
    activation_authorized = bool(
        authority_active
        and command.activation_posture is StateCommandActivationPosture.ACTIVE
        and all(item["activation_authorization"] is True for item in dependencies)
    )
    resolved_machine = resolve_state_command_machine_contract(
        resolution_registry,
        source_path,
        contract,
        command,
    )
    compact_machine = compact_resolved_machine_contract(resolved_machine)
    return {
        "activation_authorized": activation_authorized,
        "activation_posture": command.activation_posture.value,
        "command_id": command.command_id,
        "gate_dependencies": dependencies,
        "gate_requirement_ids": list(command.gate_requirement_ids),
        "label": command.label,
        "machine_contract": compact_machine,
        "requirement_id": requirement_id,
        "state_id": state_id,
    }


def _render_command_authorizations(
    records: tuple[dict[str, object], ...],
) -> tuple[str, ...]:
    rendered = []
    for record in records:
        posture = str(record["activation_posture"])
        prefix = (
            "FUTURE-GATED / NON-AUTHORIZING"
            if posture == "future_gated"
            else "ACTIVE / AUTHORIZING"
            if record["activation_authorized"] is True
            else "ACTIVE COMMAND / NON-AUTHORIZING PACK"
        )
        rendered.append(
            f"- **{prefix}:** requirement_id=`{record['requirement_id']}`; "
            f"state_id=`{record['state_id']}`; command_id=`{record['command_id']}`; "
            f"label=`{record['label']}`; activation_posture=`{posture}`; "
            "activation_authorized="
            f"`{str(record['activation_authorized']).casefold()}`; "
            "gate_requirement_ids="
            f"`{', '.join(record['gate_requirement_ids'])}`; machine_contract=`"
            + json.dumps(
                record["machine_contract"],
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            )
            + "`; gate_dependencies=`"
            + json.dumps(
                record["gate_dependencies"],
                ensure_ascii=False,
                sort_keys=True,
                separators=(",", ":"),
            )
            + "`."
        )
    return tuple(rendered)


def _future_gated_command_risk(
    requirement_id: str,
    command: StateCommand,
) -> str:
    gates = ", ".join(command.gate_requirement_ids)
    preconditions = " | ".join(command.preconditions)
    return (
        "Future-gated command metadata is non-authorizing: "
        f"owning_requirement_id={requirement_id}; command_id={command.command_id}; "
        f"label={command.label}; activation_posture=future_gated; "
        f"gate_requirement_ids={gates}; unmet_gate_reason=authorization remains invalid "
        f"until every named gate and precondition is current: {preconditions}."
    )


def _render_requirement(requirement: Requirement) -> str:
    body = requirement.body.strip()
    quoted_body = "\n".join(f"  > {line}" for line in body.splitlines())
    return (
        f"- **{requirement.requirement_id}** (`{requirement.modality.value}`):\n{quoted_body}"
    )


def _render_laws(
    laws: tuple[Requirement, ...],
) -> tuple[str, ...]:
    """Embed every applicable constitutional body in the self-contained pack."""

    return tuple(_render_requirement(law) for law in laws)


def _render_document(
    document: CanonDocument,
    selected_requirement_ids: frozenset[str],
) -> str:
    requirements = "\n".join(
        f"  {_render_requirement(requirement)}"
        for requirement in sorted(
            document.requirements,
            key=lambda item: item.requirement_id,
        )
        if requirement.requirement_id in selected_requirement_ids
    )
    heading = (
        f"- **{document.spec_id} — {_inline(document.title)}** "
        f"(`{document.kind.value}`)"
    )
    profiles = "\n".join(
        "  - **Profile section "
        f"`{section}`:**\n"
        + "\n".join(f"    > {line}" for line in body.splitlines())
        for section, body in profile_section_bodies(document)
    )
    content = "\n".join(value for value in (requirements, profiles) if value)
    return f"{heading}\n{content}" if content else heading


def _bullet_values(values: tuple[str, ...]) -> tuple[str, ...]:
    return tuple(f"- {value}" for value in values)


def _required_string(value: object, field: str) -> str:
    if (
        not isinstance(value, str)
        or not value.strip()
        or any(ord(character) < 32 or ord(character) == 127 for character in value)
    ):
        raise _intake_error(f"{field} must be a nonempty string")
    return value.strip()


def _inline(value: str) -> str:
    return " ".join(value.splitlines())


def _string_tuple(value: object, field: str, *, allow_empty: bool) -> tuple[str, ...]:
    if not isinstance(value, list):
        raise _intake_error(f"{field} must be an array of strings")
    items = tuple(_required_string(item, field) for item in value)
    if not allow_empty and not items:
        raise _intake_error(f"{field} must not be empty")
    if len(items) != len(set(items)):
        raise _intake_error(f"{field} must not contain duplicates")
    return tuple(sorted(items))


def _intake_error(message: str) -> CanonError:
    return CanonError("PACK_INTAKE_INVALID", message)


def _slug(value: str) -> str:
    slug = _SLUG_COMPONENT.sub("-", value.lower()).strip("-")
    if not slug:
        raise CanonError("PACK_PATH_INVALID", "task-pack name is not shell-safe")
    return slug


def _ensure_real_directory(root: Path, target: Path) -> None:
    try:
        root.mkdir(parents=True, exist_ok=True)
        root_stat = root.lstat()
    except OSError as exc:
        raise CanonError(
            "PACK_WRITE_FAILED", "task-pack root is unavailable", root
        ) from exc
    if stat.S_ISLNK(root_stat.st_mode) or not stat.S_ISDIR(root_stat.st_mode):
        raise CanonError(
            "PACK_WRITE_FAILED", "task-pack root must be a real directory", root
        )
    current = root
    for component in target.relative_to(root).parts:
        current = current / component
        try:
            current.mkdir()
        except FileExistsError:
            pass
        except OSError as exc:
            raise CanonError(
                "PACK_WRITE_FAILED", "unable to create task-pack directory", current
            ) from exc
        try:
            current_stat = current.lstat()
        except OSError as exc:
            raise CanonError(
                "PACK_WRITE_FAILED", "task-pack directory is unavailable", current
            ) from exc
        if stat.S_ISLNK(current_stat.st_mode) or not stat.S_ISDIR(current_stat.st_mode):
            raise CanonError(
                "PACK_WRITE_FAILED", "task-pack path must not contain symlinks", current
            )
