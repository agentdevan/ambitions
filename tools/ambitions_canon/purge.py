"""Read-only purge eligibility and authority-sprawl verification."""

from __future__ import annotations

import base64
import hashlib
import json
import subprocess
import tomllib
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from functools import cache
from pathlib import Path, PurePosixPath

from tools.ambitions_canon.model import (
    AuthorityState,
    CanonManifest,
    CanonRegistry,
    Finding,
    GapSeverity,
)
from tools.ambitions_canon.authorization import (
    AuthorizationError,
    _json_mapping,
    approval_attestation_digest,
    canonical_json_bytes,
    validation_attestation_digest,
)


_SUBPROCESS_TIMEOUT_SECONDS = 60
_TASK29_OWNER_DIRECT_DECISION = "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z"

# These locations are retained historical evidence or canonical migration
# provenance.  They may quote a purged authority path without becoming an
# active authority consumer.  Everything else remains an inbound reference.
_HISTORICAL_PROVENANCE_REFERENCE_PREFIXES = (
    "docs/adr/",
    "docs/audits/",
    "docs/canon/migration/",
    "docs/linear/reconciliation/",
    "docs/quality/senior-review/",
    "docs/superpowers/",
    "docs/validation/",
    "fixtures/",
    "tests/",
)
_HISTORICAL_PROVENANCE_REFERENCE_PATHS = frozenset(
    {
        "docs/canon/references/task-authorization-policy.json",
        "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md",
    }
)


@dataclass(frozen=True, slots=True)
class PurgeReference:
    kind: str
    locator: str
    state: str
    replacement: str
    snapshot_path: str = ""
    snapshot_sha256: str = ""


@dataclass(frozen=True, slots=True)
class PurgeArtifact:
    artifact_id: str
    kind: str
    locator: str
    action: str
    claim_ids: tuple[str, ...]
    claim_dispositions: tuple[tuple[str, str], ...]
    replacement_ids: tuple[str, ...]
    claims_resolved: bool
    incoming_links_rewritten: bool
    external_references_reconciled: bool
    unique_content_extracted: bool
    owner_approved: bool
    independent_review: bool
    owner_approval_attestation_sha256: str
    independent_review_attestation_sha256: str
    rollback_ref: str
    references: tuple[PurgeReference, ...] = ()


@dataclass(frozen=True, slots=True)
class PurgePlan:
    schema_version: int
    rollback_ref: str
    source_catalog_sha256: str
    dispositions_sha256: str
    references_sha256: str
    artifacts: tuple[PurgeArtifact, ...]


def build_purge_plan(
    source_catalog: Sequence[Mapping[str, object]],
    dispositions: Mapping[str, Mapping[str, object]],
    references: Mapping[str, Sequence[Mapping[str, object]]],
    rollback_ref: str,
) -> PurgePlan:
    """Normalize explicit source/disposition/reference inputs without deleting."""

    source_catalog_sha256 = hashlib.sha256(
        canonical_json_bytes(list(source_catalog))
    ).hexdigest()
    dispositions_sha256 = hashlib.sha256(
        canonical_json_bytes(dict(dispositions))
    ).hexdigest()
    references_sha256 = hashlib.sha256(
        canonical_json_bytes(dict(references))
    ).hexdigest()

    artifacts: list[PurgeArtifact] = []
    seen: set[str] = set()
    for source in source_catalog:
        artifact_id = _string(source.get("artifact_id"))
        if artifact_id in seen:
            raise ValueError(f"duplicate purge artifact: {artifact_id}")
        seen.add(artifact_id)
        kind = _string(source.get("kind"))
        locator = _repo_or_external_locator(source.get("locator"))
        claim_ids = _strings(source.get("claim_ids"), allow_empty=True)
        disposition = dispositions.get(artifact_id, {})
        claim_map_value = disposition.get("claim_dispositions", {})
        if not isinstance(claim_map_value, Mapping):
            raise ValueError("claim_dispositions must be an object")
        claim_dispositions = tuple(
            sorted(
                (
                    _string(claim_id),
                    _string(replacement_id),
                )
                for claim_id, replacement_id in claim_map_value.items()
            )
        )
        normalized_references = tuple(
            sorted(
                (
                    PurgeReference(
                        kind=_string(item.get("kind")),
                        locator=_string(item.get("locator")),
                        state=_string(item.get("state")),
                        replacement=_string(item.get("replacement")),
                        snapshot_path=_optional_repo_path(
                            item.get("snapshot_path")
                        ),
                        snapshot_sha256=_optional_sha256(
                            item.get("snapshot_sha256")
                        ),
                    )
                    for item in references.get(locator, ())
                ),
                key=lambda item: (
                    item.kind,
                    item.locator,
                    item.state,
                    item.replacement,
                    item.snapshot_path,
                    item.snapshot_sha256,
                ),
            )
        )
        replacement_ids = _strings(
            disposition.get("replacement_ids", ()), allow_empty=True
        )
        resolved_claim_ids = {item[0] for item in claim_dispositions}
        artifacts.append(
            PurgeArtifact(
                artifact_id=artifact_id,
                kind=kind,
                locator=locator,
                action=_optional_string(disposition.get("action")),
                claim_ids=claim_ids,
                claim_dispositions=claim_dispositions,
                replacement_ids=replacement_ids,
                claims_resolved=set(claim_ids) <= resolved_claim_ids,
                incoming_links_rewritten=_true(
                    disposition.get("incoming_links_rewritten")
                ),
                external_references_reconciled=_true(
                    disposition.get("external_references_reconciled")
                ),
                unique_content_extracted=_true(
                    disposition.get("unique_content_extracted")
                ),
                owner_approved=_true(disposition.get("owner_approved")),
                independent_review=_true(disposition.get("independent_review")),
                owner_approval_attestation_sha256=_optional_sha256(
                    disposition.get("owner_approval_attestation_sha256")
                ),
                independent_review_attestation_sha256=_optional_sha256(
                    disposition.get("independent_review_attestation_sha256")
                ),
                rollback_ref=rollback_ref,
                references=normalized_references,
            )
        )
    return PurgePlan(
        schema_version=1,
        rollback_ref=rollback_ref,
        source_catalog_sha256=source_catalog_sha256,
        dispositions_sha256=dispositions_sha256,
        references_sha256=references_sha256,
        artifacts=tuple(sorted(artifacts, key=lambda item: item.artifact_id)),
    )


def purge_findings(
    plan: PurgePlan,
    repo_root: Path,
    registry: CanonRegistry | object,
) -> tuple[Finding, ...]:
    """Return every deterministic hard-red purge eligibility finding."""

    root = repo_root.resolve()
    requirement_ids = {
        str(item.requirement_id) for item in getattr(registry, "requirements", ())
    }
    findings: list[Finding] = []
    rollback_commit = _resolve_commit(root, plan.rollback_ref)
    if not plan.rollback_ref.strip():
        findings.append(_finding("PURGE_ROLLBACK_MISSING", "rollback ref is missing"))
    elif rollback_commit is None:
        findings.append(
            _finding(
                "PURGE_ROLLBACK_INVALID",
                f"rollback ref does not resolve to an immutable commit: {plan.rollback_ref}",
            )
        )
    for artifact in plan.artifacts:
        path = (
            Path(artifact.locator)
            if artifact.kind == "repo" and _is_repo_path(artifact.locator)
            else None
        )
        if artifact.action != "delete":
            findings.append(
                _finding(
                    "PURGE_ARCHIVE_FORBIDDEN",
                    f"artifact action must be delete: {artifact.artifact_id}",
                    path,
                )
            )
        disposition_map = dict(artifact.claim_dispositions)
        unresolved = sorted(set(artifact.claim_ids) - set(disposition_map))
        if not artifact.claim_ids or unresolved or not artifact.claims_resolved:
            unresolved_label = (
                unresolved[0]
                if unresolved
                else artifact.claim_ids[0]
                if artifact.claim_ids
                else artifact.artifact_id
            )
            findings.append(
                _finding(
                    "PURGE_CLAIM_UNRESOLVED",
                    f"claim has no disposition: {unresolved_label}",
                    path,
                )
            )
        replacements = set(artifact.replacement_ids) | set(disposition_map.values())
        for replacement in sorted(replacements - requirement_ids):
            findings.append(
                _finding(
                    "PURGE_REPLACEMENT_MISSING",
                    f"replacement requirement is not active: {replacement}",
                    path,
                )
            )
        for reference in artifact.references:
            if reference.state == "active":
                findings.append(
                    _finding(
                        "PURGE_REFERENCE_ACTIVE",
                        f"active inbound reference remains: {reference.locator}",
                        path,
                    )
                )
            elif reference.state != "rewritten":
                findings.append(
                    _finding(
                        "PURGE_REFERENCE_UNKNOWN",
                        f"inbound reference state is not proven: {reference.locator}",
                        path,
                    )
                )
        if not artifact.incoming_links_rewritten:
            findings.append(
                _finding(
                    "PURGE_REFERENCE_ACTIVE",
                    f"inbound links are not rewritten: {artifact.artifact_id}",
                    path,
                )
            )
        if not artifact.external_references_reconciled:
            findings.append(
                _finding(
                    "PURGE_REFERENCE_UNKNOWN",
                    f"external references are not reconciled: {artifact.artifact_id}",
                    path,
                )
            )
        if not artifact.unique_content_extracted:
            findings.append(
                _finding(
                    "PURGE_UNIQUE_CONTENT_UNPROVEN",
                    f"unique-content extraction is not proven: {artifact.artifact_id}",
                    path,
                )
            )
        if not artifact.owner_approved:
            findings.append(
                _finding(
                    "PURGE_OWNER_APPROVAL_MISSING",
                    f"owner approval is missing: {artifact.artifact_id}",
                    path,
                )
            )
        elif not artifact.owner_approval_attestation_sha256:
            findings.append(
                _finding(
                    "PURGE_OWNER_APPROVAL_UNVERIFIED",
                    f"owner approval has no authenticated attestation: {artifact.artifact_id}",
                    path,
                )
            )
        if not artifact.independent_review:
            findings.append(
                _finding(
                    "PURGE_REVIEW_MISSING",
                    f"independent review is missing: {artifact.artifact_id}",
                    path,
                )
            )
        elif not artifact.independent_review_attestation_sha256:
            findings.append(
                _finding(
                    "PURGE_REVIEW_UNVERIFIED",
                    f"independent review has no authenticated attestation: {artifact.artifact_id}",
                    path,
                )
            )
        if not artifact.rollback_ref.strip():
            findings.append(
                _finding(
                    "PURGE_ROLLBACK_MISSING",
                    f"artifact rollback ref is missing: {artifact.artifact_id}",
                    path,
                )
            )
        if (
            rollback_commit is not None
            and artifact.kind == "repo"
            and _is_repo_path(artifact.locator)
            and not _tree_has_path(root, rollback_commit, artifact.locator)
        ):
            findings.append(
                _finding(
                    "PURGE_ROLLBACK_CONTENT_MISSING",
                    f"rollback commit does not contain artifact: {artifact.artifact_id}",
                    path,
                )
            )
    return tuple(
        sorted(
            findings,
            key=lambda item: (
                item.code,
                item.path.as_posix() if item.path else "",
                item.message,
            ),
        )
    )


def verify_purge_dry_run(
    plan: PurgePlan,
    repo_root: Path,
    registry: CanonRegistry | object,
    *,
    pre_delete_revision: str | None = None,
    candidate_revision: str | None = None,
    owner_approval_attestations: Sequence[Mapping[str, object]] = (),
    independent_review_attestations: Sequence[Mapping[str, object]] = (),
    owner_direct_receipt: Mapping[str, object] | None = None,
) -> tuple[Finding, ...]:
    """Verify eligibility without mutating any repository or external artifact."""

    findings = list(purge_findings(plan, repo_root, registry))
    root = repo_root.resolve()
    if pre_delete_revision is None or candidate_revision is None:
        findings.append(
            _finding(
                "PURGE_TREE_BINDING_MISSING",
                "purge verification requires explicit pre-delete and candidate trees",
            )
        )
        return _sorted_findings(findings)
    pre_delete_tree = _resolve_tree(root, pre_delete_revision)
    candidate_tree = _resolve_tree(root, candidate_revision)
    pre_delete_commit = _resolve_commit(root, pre_delete_revision)
    candidate_commit = _resolve_commit(root, candidate_revision)
    if pre_delete_tree is None or candidate_tree is None:
        findings.append(
            _finding(
                "PURGE_TREE_BINDING_INVALID",
                "purge tree binding does not resolve to immutable Git trees",
            )
        )
        return _sorted_findings(findings)
    if pre_delete_commit is None or candidate_commit is None:
        findings.append(
            _finding(
                "PURGE_TREE_BINDING_INVALID",
                "purge attestations require immutable pre-delete and candidate commits",
            )
        )
    rollback_commit = _resolve_commit(root, plan.rollback_ref)
    if rollback_commit is None:
        return _sorted_findings(findings)
    plan_digest = purge_plan_digest(
        plan,
        pre_delete_tree_sha=pre_delete_tree,
        candidate_tree_sha=candidate_tree,
        rollback_commit_sha=rollback_commit,
    )
    direct_receipt_valid = _valid_task29_owner_direct_receipt(
        owner_direct_receipt,
        plan,
        plan_digest=plan_digest,
        pre_delete_commit=pre_delete_commit,
        pre_delete_tree=pre_delete_tree,
        candidate_commit=candidate_commit,
        candidate_tree=candidate_tree,
        rollback_commit=rollback_commit,
        rollback_tree=_resolve_tree(root, rollback_commit),
    )
    if owner_direct_receipt is not None and not direct_receipt_valid:
        findings.append(
            _finding(
                "PURGE_OWNER_DIRECT_RECEIPT_INVALID",
                "Task 29 owner-direct receipt is missing or scope-mismatched",
            )
        )
    if direct_receipt_valid:
        findings = [
            finding
            for finding in findings
            if finding.code
            not in {
                "PURGE_OWNER_APPROVAL_MISSING",
                "PURGE_OWNER_APPROVAL_UNVERIFIED",
                "PURGE_REVIEW_MISSING",
                "PURGE_REVIEW_UNVERIFIED",
            }
        ]
    evidence = _authenticated_purge_evidence(
        root,
        pre_delete_revision,
        owner_approval_attestations,
        independent_review_attestations,
    )
    for artifact in plan.artifacts:
        path = Path(artifact.locator) if _is_repo_path(artifact.locator) else None
        owner = evidence["owner"].get(artifact.owner_approval_attestation_sha256)
        expected_scope = sorted(
            [
                *(candidate.artifact_id for candidate in plan.artifacts),
                f"purge-plan-sha256:{plan_digest}",
            ]
        )
        owner_digest = artifact.owner_approval_attestation_sha256
        if not direct_receipt_valid and (
            owner is None
            or sorted(owner.get("approved_scope", [])) != expected_scope
            or owner.get("rollback_ref") != rollback_commit
            or owner.get("trusted_base_sha") != pre_delete_commit
            or owner.get("merge_base_sha") != pre_delete_commit
            or owner.get("trusted_head_sha") != candidate_commit
        ):
            findings.append(
                _finding(
                    "PURGE_OWNER_APPROVAL_UNVERIFIED",
                    f"owner approval attestation is missing or scope-mismatched: {artifact.artifact_id}",
                    path,
                )
            )
        review = evidence["review"].get(
            artifact.independent_review_attestation_sha256
        )
        if not direct_receipt_valid and (
            review is None
            or review.get("command_id") != "independent-review-evidence"
            or review.get("proof_obligation_ids") != ["independent-review"]
            or review.get("artifact_digest") != plan_digest
            or review.get("authorization_digest") != owner_digest
            or review.get("command_argv_digest")
            != hashlib.sha256(
                canonical_json_bytes(
                    ["purge", "verify", "--dry-run", plan_digest]
                )
            ).hexdigest()
            or owner is None
            or any(
                review.get(field) != owner.get(field)
                for field in (
                    "app_id",
                    "check_identity",
                    "command_manifest_digest",
                    "intake_digest",
                    "intake_id",
                    "integration_id",
                    "merge_base_sha",
                    "policy_revision",
                    "pull_request_number",
                    "repository_full_name",
                    "repository_id",
                    "task_id",
                    "trusted_base_sha",
                    "trusted_head_sha",
                    "workflow_digest",
                    "workflow_path",
                    "workflow_ref",
                )
            )
        ):
            findings.append(
                _finding(
                    "PURGE_REVIEW_UNVERIFIED",
                    f"independent review attestation is missing or invalid: {artifact.artifact_id}",
                    path,
                )
            )
        if artifact.kind == "repo" and _is_repo_path(artifact.locator):
            if not _tree_has_path(root, pre_delete_tree, artifact.locator):
                findings.append(
                    _finding(
                        "PURGE_PREDELETE_ARTIFACT_MISSING",
                        f"pre-delete tree does not contain artifact: {artifact.artifact_id}",
                        Path(artifact.locator),
                    )
                )
            try:
                inbound = _tracked_inbound_references(
                    repo_root,
                    artifact.locator,
                    candidate_tree,
                )
            except (OSError, subprocess.SubprocessError, ValueError):
                findings.append(
                    _finding(
                        "PURGE_REFERENCE_SCAN_FAILED",
                        f"tracked Git reference scan failed: {artifact.artifact_id}",
                        Path(artifact.locator),
                    )
                )
            else:
                for inbound_path in inbound:
                    findings.append(
                        _finding(
                            "PURGE_REFERENCE_ACTIVE",
                            f"tracked inbound reference remains: {inbound_path}",
                            Path(artifact.locator),
                        )
                    )
        for reference in artifact.references:
            if reference.kind in {"git", "repo"}:
                continue
            findings.extend(
                _external_reconciliation_findings(
                    repo_root, artifact, reference, candidate_tree
                )
            )
    return _sorted_findings(findings)


def _valid_task29_owner_direct_receipt(
    receipt: Mapping[str, object] | None,
    plan: PurgePlan,
    *,
    plan_digest: str,
    pre_delete_commit: str | None,
    pre_delete_tree: str | None,
    candidate_commit: str | None,
    candidate_tree: str | None,
    rollback_commit: str | None,
    rollback_tree: str | None,
) -> bool:
    """Validate the one-use owner-direct Task 29 exception without widening it."""

    if not isinstance(receipt, Mapping) or set(receipt) != {
        "schema_version",
        "receipt_type",
        "decision_id",
        "task_id",
        "pre_delete",
        "candidate",
        "rollback",
        "artifact_ids",
        "purge_operation_digest",
        "owner_approval",
        "exact_review",
    }:
        return False
    if (
        receipt.get("schema_version") != 1
        or receipt.get("receipt_type") != "owner-direct-task29-gate-c"
        or receipt.get("decision_id") != _TASK29_OWNER_DIRECT_DECISION
        or receipt.get("task_id") != "TASK-29"
        or receipt.get("purge_operation_digest") != plan_digest
    ):
        return False
    if any(
        value is None
        for value in (
            pre_delete_commit,
            pre_delete_tree,
            candidate_commit,
            candidate_tree,
            rollback_commit,
            rollback_tree,
        )
    ):
        return False
    expected_artifacts = sorted(item.artifact_id for item in plan.artifacts)
    artifact_ids = receipt.get("artifact_ids")
    if not isinstance(artifact_ids, list) or artifact_ids != expected_artifacts:
        return False
    if any(
        any(
            (
                not item.claims_resolved,
                not item.incoming_links_rewritten,
                not item.external_references_reconciled,
                not item.unique_content_extracted,
                item.owner_approved,
                item.independent_review,
                bool(item.owner_approval_attestation_sha256),
                bool(item.independent_review_attestation_sha256),
            )
        )
        for item in plan.artifacts
    ):
        return False
    expected_bindings = (
        ("pre_delete", pre_delete_commit, pre_delete_tree),
        ("candidate", candidate_commit, candidate_tree),
        ("rollback", rollback_commit, rollback_tree),
    )
    for key, commit_sha, tree_sha in expected_bindings:
        value = receipt.get(key)
        if not isinstance(value, Mapping) or set(value) != {"commit_sha", "tree_sha"}:
            return False
        if value.get("commit_sha") != commit_sha or value.get("tree_sha") != tree_sha:
            return False
    owner = receipt.get("owner_approval")
    if not isinstance(owner, Mapping) or set(owner) != {"text", "text_sha256"}:
        return False
    owner_text = owner.get("text")
    if (
        not isinstance(owner_text, str)
        or owner.get("text_sha256")
        != hashlib.sha256(owner_text.encode("utf-8")).hexdigest()
        or "approve" not in owner_text.lower()
        or candidate_commit not in owner_text
        or plan_digest not in owner_text
    ):
        return False
    review = receipt.get("exact_review")
    if not isinstance(review, Mapping) or set(review) != {
        "status",
        "critical_findings",
        "important_findings",
        "review_package_sha256",
        "reviewed_candidate_tree_sha",
        "reviewed_purge_operation_digest",
    }:
        return False
    return (
        review.get("status") == "complete_clean"
        and review.get("critical_findings") == 0
        and review.get("important_findings") == 0
        and not isinstance(review.get("critical_findings"), bool)
        and not isinstance(review.get("important_findings"), bool)
        and _is_sha256(review.get("review_package_sha256"))
        and review.get("reviewed_candidate_tree_sha") == candidate_tree
        and review.get("reviewed_purge_operation_digest") == plan_digest
    )


def purge_plan_digest(
    plan: PurgePlan,
    *,
    pre_delete_tree_sha: str,
    candidate_tree_sha: str,
    rollback_commit_sha: str,
) -> str:
    """Bind the exact purge operation without circular attestation pointers."""

    payload = {
        "schema_version": 1,
        "source_catalog_sha256": plan.source_catalog_sha256,
        "dispositions_sha256": plan.dispositions_sha256,
        "references_sha256": plan.references_sha256,
        "pre_delete_tree_sha": pre_delete_tree_sha,
        "candidate_tree_sha": candidate_tree_sha,
        "rollback_commit_sha": rollback_commit_sha,
        "artifacts": [
            {
                "artifact_id": artifact.artifact_id,
                "kind": artifact.kind,
                "locator": artifact.locator,
                "action": artifact.action,
                "claim_ids": list(artifact.claim_ids),
                "claim_dispositions": [
                    {"claim_id": claim, "replacement_id": replacement}
                    for claim, replacement in artifact.claim_dispositions
                ],
                "replacement_ids": list(artifact.replacement_ids),
                "claims_resolved": artifact.claims_resolved,
                "incoming_links_rewritten": artifact.incoming_links_rewritten,
                "external_references_reconciled": artifact.external_references_reconciled,
                "unique_content_extracted": artifact.unique_content_extracted,
                "owner_approved": artifact.owner_approved,
                "independent_review": artifact.independent_review,
                "references": [
                    {
                        "kind": reference.kind,
                        "locator": reference.locator,
                        "state": reference.state,
                        "replacement": reference.replacement,
                        "snapshot_path": reference.snapshot_path,
                        "snapshot_sha256": reference.snapshot_sha256,
                    }
                    for reference in artifact.references
                ],
            }
            for artifact in plan.artifacts
        ],
    }
    return hashlib.sha256(canonical_json_bytes(payload)).hexdigest()


def render_purge_plan(plan: PurgePlan) -> str:
    """Render deterministic TOML with a terminal newline."""

    lines = [
        f"schema_version = {plan.schema_version}",
        f"rollback_ref = {_toml_string(plan.rollback_ref)}",
        f"source_catalog_sha256 = {_toml_string(plan.source_catalog_sha256)}",
        f"dispositions_sha256 = {_toml_string(plan.dispositions_sha256)}",
        f"references_sha256 = {_toml_string(plan.references_sha256)}",
    ]
    for artifact in plan.artifacts:
        lines.extend(
            (
                "",
                "[[artifact]]",
                f"artifact_id = {_toml_string(artifact.artifact_id)}",
                f"kind = {_toml_string(artifact.kind)}",
                f"locator = {_toml_string(artifact.locator)}",
                f"action = {_toml_string(artifact.action)}",
                f"claim_ids = {_toml_array(artifact.claim_ids)}",
                f"replacement_ids = {_toml_array(artifact.replacement_ids)}",
                f"claims_resolved = {_toml_bool(artifact.claims_resolved)}",
                (
                    "incoming_links_rewritten = "
                    f"{_toml_bool(artifact.incoming_links_rewritten)}"
                ),
                (
                    "external_references_reconciled = "
                    f"{_toml_bool(artifact.external_references_reconciled)}"
                ),
                f"unique_content_extracted = {_toml_bool(artifact.unique_content_extracted)}",
                f"owner_approved = {_toml_bool(artifact.owner_approved)}",
                f"independent_review = {_toml_bool(artifact.independent_review)}",
                (
                    "owner_approval_attestation_sha256 = "
                    f"{_toml_string(artifact.owner_approval_attestation_sha256)}"
                ),
                (
                    "independent_review_attestation_sha256 = "
                    f"{_toml_string(artifact.independent_review_attestation_sha256)}"
                ),
                f"rollback_ref = {_toml_string(artifact.rollback_ref)}",
            )
        )
        for claim_id, replacement_id in artifact.claim_dispositions:
            lines.extend(
                (
                    "",
                    "[[artifact.claim_disposition]]",
                    f"claim_id = {_toml_string(claim_id)}",
                    f"replacement_id = {_toml_string(replacement_id)}",
                )
            )
        for reference in artifact.references:
            lines.extend(
                (
                    "",
                    "[[artifact.reference]]",
                    f"kind = {_toml_string(reference.kind)}",
                    f"locator = {_toml_string(reference.locator)}",
                    f"state = {_toml_string(reference.state)}",
                    f"replacement = {_toml_string(reference.replacement)}",
                )
            )
            if reference.snapshot_path:
                lines.append(
                    f"snapshot_path = {_toml_string(reference.snapshot_path)}"
                )
            if reference.snapshot_sha256:
                lines.append(
                    f"snapshot_sha256 = {_toml_string(reference.snapshot_sha256)}"
                )
    return "\n".join(lines) + "\n"


def parse_purge_plan(text: str) -> PurgePlan:
    """Parse the closed deterministic purge-plan subset."""

    data = tomllib.loads(text)
    required_fields = {
        "schema_version",
        "rollback_ref",
        "source_catalog_sha256",
        "dispositions_sha256",
        "references_sha256",
    }
    if set(data) not in (required_fields, required_fields | {"artifact"}):
        raise ValueError("purge plan fields do not match contract")
    if data["schema_version"] != 1 or isinstance(data["schema_version"], bool):
        raise ValueError("unsupported purge plan schema")
    raw_artifacts = data.get("artifact", [])
    if not isinstance(raw_artifacts, list):
        raise ValueError("artifact must be an array")
    artifacts: list[PurgeArtifact] = []
    for raw in raw_artifacts:
        if not isinstance(raw, Mapping):
            raise ValueError("artifact entry must be a table")
        claim_dispositions = tuple(
            sorted(
                (
                    _string(item.get("claim_id")),
                    _string(item.get("replacement_id")),
                )
                for item in raw.get("claim_disposition", ())
            )
        )
        references = tuple(
            sorted(
                (
                    PurgeReference(
                        kind=_string(item.get("kind")),
                        locator=_string(item.get("locator")),
                        state=_string(item.get("state")),
                        replacement=_string(item.get("replacement")),
                        snapshot_path=_optional_repo_path(
                            item.get("snapshot_path")
                        ),
                        snapshot_sha256=_optional_sha256(
                            item.get("snapshot_sha256")
                        ),
                    )
                    for item in raw.get("reference", ())
                ),
                key=lambda item: (
                    item.kind,
                    item.locator,
                    item.state,
                    item.replacement,
                    item.snapshot_path,
                    item.snapshot_sha256,
                ),
            )
        )
        artifacts.append(
            PurgeArtifact(
                artifact_id=_string(raw.get("artifact_id")),
                kind=_string(raw.get("kind")),
                locator=_repo_or_external_locator(raw.get("locator")),
                action=_string(raw.get("action")),
                claim_ids=_strings(raw.get("claim_ids"), allow_empty=True),
                claim_dispositions=claim_dispositions,
                replacement_ids=_strings(
                    raw.get("replacement_ids"), allow_empty=True
                ),
                claims_resolved=_bool(raw.get("claims_resolved")),
                incoming_links_rewritten=_bool(
                    raw.get("incoming_links_rewritten")
                ),
                external_references_reconciled=_bool(
                    raw.get("external_references_reconciled")
                ),
                unique_content_extracted=_bool(
                    raw.get("unique_content_extracted")
                ),
                owner_approved=_bool(raw.get("owner_approved")),
                independent_review=_bool(raw.get("independent_review")),
                owner_approval_attestation_sha256=_optional_sha256(
                    raw.get("owner_approval_attestation_sha256")
                ),
                independent_review_attestation_sha256=_optional_sha256(
                    raw.get("independent_review_attestation_sha256")
                ),
                rollback_ref=_string(raw.get("rollback_ref")),
                references=references,
            )
        )
    return PurgePlan(
        schema_version=1,
        rollback_ref=_string(data["rollback_ref"]),
        source_catalog_sha256=_required_sha256(data["source_catalog_sha256"]),
        dispositions_sha256=_required_sha256(data["dispositions_sha256"]),
        references_sha256=_required_sha256(data["references_sha256"]),
        artifacts=tuple(sorted(artifacts, key=lambda item: item.artifact_id)),
    )


def authority_sprawl_findings(
    repo_root: Path,
    manifest: CanonManifest,
    baseline: Sequence[str] | None = None,
    *,
    purge_dispositions: Sequence[str] = (),
    purge_plan: PurgePlan | None = None,
    registry: CanonRegistry | object | None = None,
    pre_delete_revision: str | None = None,
    candidate_revision: str | None = None,
    owner_approval_attestations: Sequence[Mapping[str, object]] = (),
    independent_review_attestations: Sequence[Mapping[str, object]] = (),
) -> tuple[Finding, ...]:
    """Detect filename-level normative authority outside the canonical atlas."""

    root = repo_root.resolve()
    allowed_canon = {
        (Path("docs/canon") / entry.path).as_posix()
        for entry in manifest.normative_files
    }
    baseline_set = set(baseline or ())
    if purge_dispositions:
        raise ValueError(
            "authority-sprawl allowances require a verified purge plan"
        )
    purge_set: set[str] = set()
    if purge_plan is not None:
        if registry is None or verify_purge_dry_run(
            purge_plan,
            root,
            registry,
            pre_delete_revision=pre_delete_revision,
            candidate_revision=candidate_revision,
            owner_approval_attestations=owner_approval_attestations,
            independent_review_attestations=independent_review_attestations,
        ):
            raise ValueError(
                "authority-sprawl allowances require a verified purge plan"
            )
        purge_set = {
            artifact.locator
            for artifact in purge_plan.artifacts
            if artifact.kind == "repo" and artifact.action == "delete"
        }
    findings: list[Finding] = []
    for path in sorted(root.rglob("*"), key=lambda item: item.as_posix()):
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        if any(
            part in {".git", ".worktrees", "__pycache__"}
            for part in PurePosixPath(relative).parts
        ):
            continue
        if relative.startswith("docs/canon/"):
            if relative in allowed_canon or not _authority_filename(path.name):
                continue
            findings.append(
                _finding(
                    "AUTHORITY_SPRAWL",
                    f"canon-like file is not declared by manifest: {relative}",
                    Path(relative),
                )
            )
            continue
        if not _authority_filename(path.name):
            continue
        if (
            manifest.authority_state is AuthorityState.SHADOW
            and relative in baseline_set
        ):
            continue
        if relative in purge_set:
            continue
        findings.append(
            _finding(
                "AUTHORITY_SPRAWL",
                f"authority-like file exists outside docs/canon: {relative}",
                Path(relative),
            )
        )
    return tuple(
        sorted(
            findings,
            key=lambda item: (
                item.code,
                item.path.as_posix() if item.path else "",
                item.message,
            ),
        )
    )


def _tracked_inbound_references(
    repo_root: Path, artifact_locator: str, candidate_revision: str
) -> tuple[str, ...]:
    root = repo_root.resolve()
    needle = artifact_locator.encode("utf-8")
    inbound: list[str] = []
    for raw_path, blob in _candidate_tree_blobs(str(root), candidate_revision):
        if raw_path == needle or _is_historical_provenance_reference(raw_path):
            continue
        if needle not in blob:
            continue
        try:
            display = raw_path.decode("utf-8")
        except UnicodeDecodeError:
            display = "raw-base64url:" + base64.urlsafe_b64encode(raw_path).rstrip(
                b"="
            ).decode("ascii")
        inbound.append(display)
    return tuple(sorted(inbound))


@cache
def _candidate_tree_blobs(
    root_path: str, candidate_revision: str
) -> tuple[tuple[bytes, bytes], ...]:
    """Load a candidate tree once for all per-artifact inbound checks."""

    root = Path(root_path)
    completed = subprocess.run(
        ["git", "ls-tree", "-r", "-z", "-l", candidate_revision],
        cwd=root,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=_SUBPROCESS_TIMEOUT_SECONDS,
    )
    blobs: list[tuple[bytes, bytes]] = []
    for record in completed.stdout.split(b"\0"):
        if not record:
            continue
        metadata, raw_path = record.split(b"\t", 1)
        _mode, object_type, object_id, _size = metadata.split(None, 3)
        if object_type != b"blob":
            continue
        blob = subprocess.run(
            ["git", "cat-file", "blob", object_id.decode("ascii")],
            cwd=root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        ).stdout
        blobs.append((raw_path, blob))
    return tuple(blobs)


def _is_historical_provenance_reference(raw_path: bytes) -> bool:
    """Classify exact historical evidence without suppressing live consumers."""

    try:
        path = raw_path.decode("utf-8")
    except UnicodeDecodeError:
        return False
    if path in _HISTORICAL_PROVENANCE_REFERENCE_PATHS:
        return True
    if path == "docs/qa/product-experience-scenario-gates.yaml":
        return False
    if path.startswith("docs/qa/"):
        return True
    return path.startswith(_HISTORICAL_PROVENANCE_REFERENCE_PREFIXES)


def _external_reconciliation_findings(
    repo_root: Path,
    artifact: PurgeArtifact,
    reference: PurgeReference,
    candidate_revision: str,
) -> tuple[Finding, ...]:
    path = Path(artifact.locator) if _is_repo_path(artifact.locator) else None
    if not reference.snapshot_path or not reference.snapshot_sha256:
        return (
            _finding(
                "PURGE_EXTERNAL_RECONCILIATION_MISSING",
                f"external reconciliation is not bound: {reference.locator}",
                path,
            ),
        )
    try:
        completed = subprocess.run(
            ["git", "show", f"{candidate_revision}:{reference.snapshot_path}"],
            cwd=repo_root.resolve(),
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError):
        return (
            _finding(
                "PURGE_EXTERNAL_RECONCILIATION_MISSING",
                f"tracked reconciliation snapshot is missing: {reference.snapshot_path}",
                path,
            ),
        )
    raw = completed.stdout
    if hashlib.sha256(raw).hexdigest() != reference.snapshot_sha256:
        return (
            _finding(
                "PURGE_EXTERNAL_RECONCILIATION_STALE",
                f"reconciliation snapshot digest is stale: {reference.snapshot_path}",
                path,
            ),
        )
    try:
        data = json.loads(raw.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError):
        data = None
    if not isinstance(data, Mapping) or set(data) != {
        "schema_version",
        "snapshot_revision",
        "references",
    }:
        return (
            _finding(
                "PURGE_EXTERNAL_RECONCILIATION_INVALID",
                f"reconciliation snapshot contract is invalid: {reference.snapshot_path}",
                path,
            ),
        )
    references = data["references"]
    expected = {
        "kind": reference.kind,
        "locator": reference.locator,
        "state": reference.state,
        "replacement": reference.replacement,
    }
    if not isinstance(references, list) or expected not in references:
        return (
            _finding(
                "PURGE_EXTERNAL_RECONCILIATION_MISMATCH",
                f"external reference is absent from snapshot: {reference.locator}",
                path,
            ),
        )
    return ()


def _authenticated_purge_evidence(
    repo_root: Path,
    trusted_revision: str,
    owner_attestations: Sequence[Mapping[str, object]],
    review_attestations: Sequence[Mapping[str, object]],
) -> dict[str, dict[str, Mapping[str, object]]]:
    anchors: Mapping[str, object] | None = None
    policy: Mapping[str, object] | None = None
    command_manifest: Mapping[str, object] | None = None
    command_manifest_digest = ""
    trusted_commit = _resolve_commit(repo_root, trusted_revision)
    try:
        raw = subprocess.run(
            [
                "git",
                "show",
                f"{trusted_revision}:docs/canon/references/task-authorization-policy.json",
            ],
            cwd=repo_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        ).stdout
        policy = _json_mapping(
            raw,
            "PURGE_TRUST_POLICY",
            "docs/canon/references/task-authorization-policy.json",
        )
        if isinstance(policy, Mapping) and isinstance(
            policy.get("trust_anchors"), Mapping
        ):
            anchors = policy["trust_anchors"]
        snapshots = policy.get("snapshot_paths")
        if not isinstance(snapshots, Mapping) or not isinstance(
            snapshots.get("command_manifest"), str
        ):
            raise ValueError
        command_raw = subprocess.run(
            [
                "git",
                "show",
                f"{trusted_revision}:{snapshots['command_manifest']}",
            ],
            cwd=repo_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        ).stdout
        command_manifest = _json_mapping(
            command_raw,
            "PURGE_TRUST_POLICY",
            str(snapshots["command_manifest"]),
        )
        command_manifest_digest = hashlib.sha256(command_raw).hexdigest()
    except (
        OSError,
        subprocess.SubprocessError,
        UnicodeError,
        json.JSONDecodeError,
        AuthorizationError,
        ValueError,
    ):
        anchors = None
    result: dict[str, dict[str, Mapping[str, object]]] = {
        "owner": {},
        "review": {},
    }
    if (
        anchors is None
        or policy is None
        or command_manifest is None
        or trusted_commit is None
    ):
        return result
    identity = anchors.get("repository_identity")
    if not isinstance(identity, Mapping):
        return result
    expected_identity = (
        identity.get("repository_id"),
        identity.get("repository_full_name"),
    )
    workflow = command_manifest.get("trusted_workflow")
    if not isinstance(workflow, Mapping):
        return result

    def matches_trusted_context(attestation: Mapping[str, object]) -> bool:
        return (
            attestation.get("trusted_base_sha") == trusted_commit
            and attestation.get("merge_base_sha") == trusted_commit
            and attestation.get("policy_revision") == policy.get("policy_revision")
            and attestation.get("command_manifest_digest")
            == command_manifest_digest
            and attestation.get("workflow_path") == workflow.get("path")
            and attestation.get("workflow_ref") == workflow.get("ref")
            and attestation.get("workflow_digest") == workflow.get("digest")
            and attestation.get("check_identity")
            == workflow.get("check_identity")
            and attestation.get("integration_id") == workflow.get("integration_id")
            and attestation.get("app_id") == workflow.get("app_id")
        )
    for attestation in owner_attestations:
        try:
            epoch = attestation.get("verification_epoch")
            if isinstance(epoch, bool) or not isinstance(epoch, int):
                continue
            digest = approval_attestation_digest(
                attestation,
                verification_epoch=epoch,
                trust_anchors=anchors,
            )
        except AuthorizationError:
            continue
        if (
            attestation.get("repository_id"),
            attestation.get("repository_full_name"),
        ) != expected_identity or not matches_trusted_context(attestation):
            continue
        result["owner"][digest] = attestation
    for attestation in review_attestations:
        try:
            digest = validation_attestation_digest(
                attestation, trust_anchors=anchors
            )
        except AuthorizationError:
            continue
        if (
            attestation.get("repository_id"),
            attestation.get("repository_full_name"),
        ) != expected_identity or not matches_trusted_context(attestation):
            continue
        result["review"][digest] = attestation
    return result


def _resolve_commit(repo_root: Path, revision: str) -> str | None:
    if not revision.strip():
        return None
    try:
        completed = subprocess.run(
            [
                "git",
                "rev-parse",
                "--verify",
                "--end-of-options",
                f"{revision}^{{commit}}",
            ],
            cwd=repo_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return completed.stdout.strip()


def _resolve_tree(repo_root: Path, revision: str) -> str | None:
    try:
        completed = subprocess.run(
            [
                "git",
                "rev-parse",
                "--verify",
                "--end-of-options",
                f"{revision}^{{tree}}",
            ],
            cwd=repo_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return completed.stdout.strip()


def _tree_has_path(repo_root: Path, revision: str, path: str) -> bool:
    try:
        subprocess.run(
            ["git", "cat-file", "-e", f"{revision}:{path}"],
            cwd=repo_root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=_SUBPROCESS_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    return True


def _sorted_findings(findings: Sequence[Finding]) -> tuple[Finding, ...]:
    return tuple(
        sorted(
            findings,
            key=lambda item: (
                item.code,
                item.path.as_posix() if item.path else "",
                item.message,
            ),
        )
    )


def _authority_filename(name: str) -> bool:
    upper = name.upper()
    return (
        upper in {"CANON.MD", "CONSTITUTION.MD", "PRODUCT_TRUTH.MD"}
        or upper.endswith("_TRUTH.MD")
        or upper.endswith("_CANON.MD")
        or upper.endswith("_CONSTITUTION.MD")
    )


def _finding(code: str, message: str, path: Path | None = None) -> Finding:
    return Finding(
        code=code,
        severity=GapSeverity.P0_BLOCKER,
        message=message,
        path=path,
    )


def _string(value: object) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError("expected non-empty string")
    return value


def _optional_string(value: object) -> str:
    return value if isinstance(value, str) else ""


def _optional_repo_path(value: object) -> str:
    if value is None:
        return ""
    if not isinstance(value, str):
        raise ValueError("snapshot path must be a string")
    if not value:
        return ""
    normalized = _repo_or_external_locator(value)
    if not _is_repo_path(normalized):
        raise ValueError("snapshot path must be repository-relative")
    return normalized


def _optional_sha256(value: object) -> str:
    if value is None or value == "":
        return ""
    if (
        not isinstance(value, str)
        or len(value) != 64
        or any(item not in "0123456789abcdef" for item in value)
    ):
        raise ValueError("snapshot digest must be lowercase SHA-256")
    return value


def _is_sha256(value: object) -> bool:
    return (
        isinstance(value, str)
        and len(value) == 64
        and all(item in "0123456789abcdef" for item in value)
    )


def _required_sha256(value: object) -> str:
    result = _optional_sha256(value)
    if not result:
        raise ValueError("required SHA-256 is missing")
    return result


def _strings(value: object, *, allow_empty: bool) -> tuple[str, ...]:
    if not isinstance(value, (list, tuple)) or (not allow_empty and not value):
        raise ValueError("expected string array")
    result = tuple(sorted(_string(item) for item in value))
    if len(result) != len(set(result)):
        raise ValueError("string array contains duplicates")
    return result


def _bool(value: object) -> bool:
    if not isinstance(value, bool):
        raise ValueError("expected boolean")
    return value


def _true(value: object) -> bool:
    return value is True


def _repo_or_external_locator(value: object) -> str:
    text = _string(value)
    if _is_repo_path(text):
        pure = PurePosixPath(text)
        if (
            pure.is_absolute()
            or any(part in {"", ".", ".."} for part in pure.parts)
            or "\\" in text
        ):
            raise ValueError("invalid repository locator")
    return text


def _is_repo_path(value: str) -> bool:
    return "://" not in value and not value.startswith(("linear:", "figma:"))


def _toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def _toml_array(values: Sequence[str]) -> str:
    return "[" + ", ".join(_toml_string(item) for item in values) + "]"


def _toml_bool(value: bool) -> str:
    return "true" if value else "false"
