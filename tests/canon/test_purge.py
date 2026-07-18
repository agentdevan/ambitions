from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path
from types import SimpleNamespace

from tools.ambitions_canon.model import AuthorityState, CanonManifest, ManifestEntry
from tools.ambitions_canon.authorization import canonical_json_bytes
from tests.canon.test_authorization import anchors, resign, sign

try:
    from tools.ambitions_canon.purge import (
        authority_sprawl_findings,
        build_purge_plan,
        parse_purge_plan,
        purge_findings,
        purge_plan_digest,
        render_purge_plan,
        verify_purge_dry_run,
    )
except ModuleNotFoundError:
    authority_sprawl_findings = None
    build_purge_plan = None
    parse_purge_plan = None
    purge_findings = None
    purge_plan_digest = None
    render_purge_plan = None
    verify_purge_dry_run = None


def catalog() -> list[dict[str, object]]:
    return [
        {
            "artifact_id": "REPO-OLD-CANON",
            "kind": "repo",
            "locator": "docs/truth/OLD_CANON.md",
            "claim_ids": ["CLAIM-1"],
        }
    ]


def dispositions(**overrides: object) -> dict[str, dict[str, object]]:
    owner = owner_attestation()
    review = review_attestation()
    value: dict[str, object] = {
        "action": "delete",
        "claim_dispositions": {"CLAIM-1": "REQ-1"},
        "replacement_ids": ["REQ-1"],
        "incoming_links_rewritten": True,
        "external_references_reconciled": True,
        "unique_content_extracted": True,
        "owner_approved": True,
        "independent_review": True,
        "owner_approval_attestation_sha256": hashlib.sha256(
            canonical_json_bytes(owner)
        ).hexdigest(),
        "independent_review_attestation_sha256": hashlib.sha256(
            canonical_json_bytes(review)
        ).hexdigest(),
    }
    value.update(overrides)
    return {"REPO-OLD-CANON": value}


def references(
    *,
    state: str = "rewritten",
    snapshot_path: str | None = None,
    snapshot_sha256: str | None = None,
) -> dict[str, list[dict[str, str]]]:
    reference = {
        "kind": "git",
        "locator": "README.md",
        "state": state,
        "replacement": "REQ-1",
    }
    if snapshot_path is not None:
        reference["snapshot_path"] = snapshot_path
    if snapshot_sha256 is not None:
        reference["snapshot_sha256"] = snapshot_sha256
    return {
        "docs/truth/OLD_CANON.md": [reference]
    }


def git(root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", *arguments],
        cwd=root,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return completed.stdout.strip()


def commit_tree(root: Path) -> None:
    git(root, "init", "-q", "-b", "main")
    git(root, "config", "user.name", "Purge Test")
    git(root, "config", "user.email", "purge@example.invalid")
    policy = root / "docs/canon/references/task-authorization-policy.json"
    policy.parent.mkdir(parents=True, exist_ok=True)
    policy.write_text(
        json.dumps(
            {
                "policy_revision": "authorization-v1",
                "snapshot_paths": {
                    "command_manifest": "docs/canon/references/validation-command-manifest.json"
                },
                "trust_anchors": anchors(),
            },
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    manifest = root / "docs/canon/references/validation-command-manifest.json"
    manifest.write_bytes(
        canonical_json_bytes(
            {
                "trusted_workflow": {
                    "path": ".github/workflows/canon-authorization.yml",
                    "ref": "refs/heads/main",
                    "digest": "c" * 64,
                    "check_identity": "ambitions-canon-authorization",
                    "integration_id": "github-actions",
                    "app_id": "15368",
                }
            }
        )
    )
    git(root, "add", "-A")
    git(root, "commit", "-qm", "purge fixture")


def owner_attestation(
    *,
    base_sha: str = "a" * 40,
    head_sha: str = "b" * 40,
    plan_digest: str | None = None,
    rollback_commit: str | None = None,
    artifact_ids: tuple[str, ...] = ("REPO-OLD-CANON",),
    command_manifest_digest: str = "b" * 64,
    workflow_digest: str = "c" * 64,
) -> dict[str, object]:
    approved_scope = ["LEGACY-TRUTH", "REPO-OLD-CANON"]
    if plan_digest is not None:
        approved_scope = [
            *artifact_ids,
            f"purge-plan-sha256:{plan_digest}",
        ]
    return sign(
        {
            "schema_version": 1,
            "attestation_id": "PURGE-OWNER-APPROVAL",
            "attestation_origin": "platform-authenticated",
            "repository_id": "12345",
            "repository_full_name": "agentdevan/ambitions",
            "pull_request_number": 27,
            "task_id": "TASK-27",
            "intake_id": "PURGE-INTAKE",
            "trusted_base_sha": base_sha,
            "trusted_head_sha": head_sha,
            "merge_base_sha": base_sha,
            "intake_digest": "a" * 64,
            "policy_revision": "authorization-v1",
            "command_manifest_digest": command_manifest_digest,
            "workflow_path": ".github/workflows/canon-authorization.yml",
            "workflow_ref": "refs/heads/main",
            "workflow_digest": workflow_digest,
            "workflow_run_id": 27001,
            "workflow_run_attempt": 1,
            "event_projection_digest": "d" * 64,
            "consumption_generation": 1,
            "check_identity": "ambitions-canon-authorization",
            "integration_id": "github-actions",
            "app_id": "15368",
            "approval_policy_id": "owner-gate",
            "approval_policy_revision": "1",
            "authenticated_principal": "owner:devan",
            "approved_scope": approved_scope,
            "one_time_use_nonce": "purge-owner-nonce",
            "verification_epoch": 1_900_000_000,
            "consumed": False,
            "expires_at_epoch": 2_000_000_000,
            "revoked": False,
            "break_glass": False,
            "incident_id": None,
            "rollback_ref": rollback_commit,
            "post_action_review_required": False,
        }
    )


def review_attestation(
    *,
    base_sha: str = "a" * 40,
    head_sha: str = "b" * 40,
    plan_digest: str = "f" * 64,
    owner_digest: str = "b" * 64,
    command_manifest_digest: str = "b" * 64,
    workflow_digest: str = "c" * 64,
) -> dict[str, object]:
    return sign(
        {
            "schema_version": 1,
            "attestation_id": "PURGE-INDEPENDENT-REVIEW",
            "attestation_origin": "trusted-ci",
            "pull_request_number": 27,
            "task_id": "TASK-27",
            "intake_id": "PURGE-INTAKE",
            "intake_digest": "a" * 64,
            "policy_revision": "authorization-v1",
            "authorization_digest": owner_digest,
            "command_manifest_digest": command_manifest_digest,
            "workflow_path": ".github/workflows/canon-authorization.yml",
            "workflow_ref": "refs/heads/main",
            "workflow_digest": workflow_digest,
            "command_id": "independent-review-evidence",
            "command_argv_digest": hashlib.sha256(
                canonical_json_bytes(
                    ["purge", "verify", "--dry-run", plan_digest]
                )
            ).hexdigest(),
            "check_identity": "ambitions-canon-authorization",
            "repository_id": "12345",
            "repository_full_name": "agentdevan/ambitions",
            "trusted_base_sha": base_sha,
            "trusted_head_sha": head_sha,
            "merge_base_sha": base_sha,
            "integration_id": "github-actions",
            "app_id": "15368",
            "exit_status": 0,
            "artifact_digest": plan_digest,
            "proof_obligation_ids": ["independent-review"],
            "skipped": False,
            "skipped_reason": None,
            "status": "green",
            "claim_ceiling": "Purge reviewed for exact scope",
            "ci_owned": True,
        }
    )


def bound_purge_evidence(plan, root: Path):
    head = git(root, "rev-parse", "HEAD")
    tree = git(root, "rev-parse", "HEAD^{tree}")
    rollback = git(root, "rev-parse", f"{plan.rollback_ref}^{{commit}}")
    plan_sha256 = purge_plan_digest(
        plan,
        pre_delete_tree_sha=tree,
        candidate_tree_sha=tree,
        rollback_commit_sha=rollback,
    )
    command_manifest_digest = hashlib.sha256(
        (
            root / "docs/canon/references/validation-command-manifest.json"
        ).read_bytes()
    ).hexdigest()
    owner = owner_attestation(
        base_sha=head,
        head_sha=head,
        plan_digest=plan_sha256,
        rollback_commit=rollback,
        artifact_ids=tuple(artifact.artifact_id for artifact in plan.artifacts),
        command_manifest_digest=command_manifest_digest,
    )
    owner_digest = hashlib.sha256(canonical_json_bytes(owner)).hexdigest()
    review = review_attestation(
        base_sha=head,
        head_sha=head,
        plan_digest=plan_sha256,
        owner_digest=owner_digest,
        command_manifest_digest=command_manifest_digest,
    )
    review_digest = hashlib.sha256(canonical_json_bytes(review)).hexdigest()
    bound_plan = replace(
        plan,
        artifacts=tuple(
            replace(
                artifact,
                owner_approval_attestation_sha256=owner_digest,
                independent_review_attestation_sha256=review_digest,
            )
            for artifact in plan.artifacts
        ),
    )
    self_check = purge_plan_digest(
        bound_plan,
        pre_delete_tree_sha=tree,
        candidate_tree_sha=tree,
        rollback_commit_sha=rollback,
    )
    if self_check != plan_sha256:
        raise AssertionError("purge digest must exclude circular attestation pointers")
    return bound_plan, owner, review, head


def verified_purge(
    plan,
    root: Path,
    requirement_registry,
):
    bound_plan, owner, review, head = bound_purge_evidence(plan, root)
    return verify_purge_dry_run(
        bound_plan,
        root,
        requirement_registry,
        pre_delete_revision=head,
        candidate_revision=head,
        owner_approval_attestations=(owner,),
        independent_review_attestations=(review,),
    )


def registry(*requirement_ids: str) -> SimpleNamespace:
    return SimpleNamespace(
        requirements=tuple(
            SimpleNamespace(requirement_id=requirement_id)
            for requirement_id in requirement_ids
        )
    )


class PurgePlanTests(unittest.TestCase):
    def setUp(self) -> None:
        if build_purge_plan is None:
            self.fail("tools.ambitions_canon.purge is missing")

    def test_eligible_plan_is_deterministic_and_dry_run_never_mutates(self) -> None:
        plan = build_purge_plan(
            catalog(), dispositions(), references(), "refs/tags/canon-baseline"
        )
        rendered = render_purge_plan(plan)
        self.assertEqual(rendered, render_purge_plan(plan))
        self.assertTrue(rendered.endswith("\n"))
        self.assertEqual(parse_purge_plan(rendered), plan)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("old\n", encoding="utf-8")
            commit_tree(root)
            git(root, "tag", "canon-baseline")
            before = artifact.read_bytes()
            findings = verified_purge(plan, root, registry("REQ-1"))
            self.assertEqual(findings, ())
            self.assertEqual(artifact.read_bytes(), before)

    def test_unresolved_claim_and_missing_replacement_fail_closed(self) -> None:
        plan = build_purge_plan(
            catalog(),
            dispositions(claim_dispositions={}),
            references(),
            "refs/tags/canon-baseline",
        )
        codes = {item.code for item in purge_findings(plan, Path("."), registry())}
        self.assertIn("PURGE_CLAIM_UNRESOLVED", codes)

        plan = build_purge_plan(
            catalog(), dispositions(), references(), "refs/tags/canon-baseline"
        )
        codes = {item.code for item in purge_findings(plan, Path("."), registry())}
        self.assertIn("PURGE_REPLACEMENT_MISSING", codes)

    def test_active_or_unknown_inbound_reference_blocks(self) -> None:
        for state, code in (
            ("active", "PURGE_REFERENCE_ACTIVE"),
            ("unknown", "PURGE_REFERENCE_UNKNOWN"),
        ):
            plan = build_purge_plan(
                catalog(),
                dispositions(),
                references(state=state),
                "refs/tags/canon-baseline",
            )
            codes = {
                item.code for item in purge_findings(plan, Path("."), registry("REQ-1"))
            }
            self.assertIn(code, codes)

    def test_approval_review_rollback_and_delete_are_mandatory(self) -> None:
        cases = (
            ({"owner_approved": False}, "PURGE_OWNER_APPROVAL_MISSING"),
            ({"independent_review": False}, "PURGE_REVIEW_MISSING"),
            ({"action": "archive"}, "PURGE_ARCHIVE_FORBIDDEN"),
        )
        for overrides, code in cases:
            plan = build_purge_plan(
                catalog(),
                dispositions(**overrides),
                references(),
                "refs/tags/canon-baseline",
            )
            codes = {
                item.code for item in purge_findings(plan, Path("."), registry("REQ-1"))
            }
            self.assertIn(code, codes)

        plan = build_purge_plan(catalog(), dispositions(), references(), "")
        codes = {item.code for item in purge_findings(plan, Path("."), registry("REQ-1"))}
        self.assertIn("PURGE_ROLLBACK_MISSING", codes)

    def test_tracked_inbound_reference_overrides_plan_assertion(self) -> None:
        plan = build_purge_plan(
            catalog(), dispositions(), references(), "refs/tags/canon-baseline"
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("old\n", encoding="utf-8")
            (root / "README.md").write_text(
                "See docs/truth/OLD_CANON.md\n", encoding="utf-8"
            )
            commit_tree(root)
            git(root, "tag", "canon-baseline")
            codes = {
                item.code
                for item in verified_purge(plan, root, registry("REQ-1"))
            }
            self.assertIn("PURGE_REFERENCE_ACTIVE", codes)

    def test_historical_evidence_reference_does_not_block_a_purge(self) -> None:
        plan = build_purge_plan(
            catalog(), dispositions(), references(), "refs/tags/canon-baseline"
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifact = root / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("old\n", encoding="utf-8")
            evidence = root / "docs/audits/historical-proof.md"
            evidence.parent.mkdir(parents=True)
            evidence.write_text(
                "Historical evidence: docs/truth/OLD_CANON.md\n",
                encoding="utf-8",
            )
            commit_tree(root)
            git(root, "tag", "canon-baseline")
            codes = {
                item.code
                for item in verified_purge(plan, root, registry("REQ-1"))
            }
            self.assertNotIn("PURGE_REFERENCE_ACTIVE", codes)

    def test_external_reconciliation_snapshot_digest_is_verified(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            snapshot = root / "docs/canon/migration/external-reconciliation.json"
            snapshot.parent.mkdir(parents=True)
            snapshot.write_text(
                json.dumps(
                    {
                        "schema_version": 1,
                        "snapshot_revision": "external-v1",
                        "references": [
                            {
                                "kind": "figma",
                                "locator": "figma://file/node",
                                "state": "rewritten",
                                "replacement": "REQ-1",
                            }
                        ],
                    },
                    sort_keys=True,
                )
                + "\n",
                encoding="utf-8",
            )
            artifact = root / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("old\n", encoding="utf-8")
            commit_tree(root)
            git(root, "tag", "canon-baseline")
            external_references = {
                "docs/truth/OLD_CANON.md": [
                    {
                        "kind": "figma",
                        "locator": "figma://file/node",
                        "state": "rewritten",
                        "replacement": "REQ-1",
                        "snapshot_path": "docs/canon/migration/external-reconciliation.json",
                        "snapshot_sha256": "0" * 64,
                    }
                ]
            }
            plan = build_purge_plan(
                catalog(),
                dispositions(),
                external_references,
                "refs/tags/canon-baseline",
            )
            codes = {
                item.code
                for item in verified_purge(plan, root, registry("REQ-1"))
            }
            self.assertIn("PURGE_EXTERNAL_RECONCILIATION_STALE", codes)


class AuthoritySprawlTests(unittest.TestCase):
    def setUp(self) -> None:
        if authority_sprawl_findings is None:
            self.fail("tools.ambitions_canon.purge is missing")

    def _manifest(self, root: Path, state: AuthorityState) -> CanonManifest:
        return CanonManifest(
            schema_version=1,
            canon_revision=1,
            authority_state=state,
            compiler_version="0.2.0",
            normative_files=(ManifestEntry(Path("CONSTITUTION.md")),),
            generated_files=(),
            source_path=Path("docs/canon/MANIFEST.toml"),
            repository_root=root,
        )

    def test_manifest_canon_passes_and_filename_authority_outside_canon_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs/canon").mkdir(parents=True)
            (root / "docs/canon/CONSTITUTION.md").write_text("canon\n", encoding="utf-8")
            self.assertEqual(
                authority_sprawl_findings(
                    root, self._manifest(root, AuthorityState.ACTIVE), baseline=()
                ),
                (),
            )
            (root / "PRODUCT_TRUTH.md").write_text("duplicate\n", encoding="utf-8")
            findings = authority_sprawl_findings(
                root, self._manifest(root, AuthorityState.ACTIVE), baseline=()
            )
            self.assertEqual(findings[0].code, "AUTHORITY_SPRAWL")

    def test_shadow_legacy_is_allowed_but_active_requires_purge_disposition(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs/canon").mkdir(parents=True)
            (root / "docs/canon/CONSTITUTION.md").write_text("canon\n", encoding="utf-8")
            legacy = root / "docs/truth/PRODUCT_TRUTH.md"
            legacy.parent.mkdir(parents=True)
            legacy.write_text("legacy\n", encoding="utf-8")
            self.assertEqual(
                authority_sprawl_findings(
                    root,
                    self._manifest(root, AuthorityState.SHADOW),
                    baseline=("docs/truth/PRODUCT_TRUTH.md",),
                ),
                (),
            )
            self.assertTrue(
                authority_sprawl_findings(
                    root,
                    self._manifest(root, AuthorityState.ACTIVE),
                    baseline=("docs/truth/PRODUCT_TRUTH.md",),
                )
            )

    def test_source_comment_word_authority_does_not_trigger(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs/canon").mkdir(parents=True)
            (root / "docs/canon/CONSTITUTION.md").write_text("canon\n", encoding="utf-8")
            (root / "source.py").write_text("# authority is not inferred\n", encoding="utf-8")
            self.assertEqual(
                authority_sprawl_findings(
                    root, self._manifest(root, AuthorityState.ACTIVE), baseline=()
                ),
                (),
            )

    def test_sprawl_allowance_requires_a_verified_approved_purge_plan(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs/canon").mkdir(parents=True)
            (root / "docs/canon/CONSTITUTION.md").write_text(
                "canon\n", encoding="utf-8"
            )
            legacy = root / "docs/truth/PRODUCT_TRUTH.md"
            legacy.parent.mkdir(parents=True)
            legacy.write_text("legacy\n", encoding="utf-8")
            commit_tree(root)
            git(root, "tag", "canon-baseline")
            with self.assertRaisesRegex(ValueError, "verified purge plan"):
                authority_sprawl_findings(
                    root,
                    self._manifest(root, AuthorityState.ACTIVE),
                    baseline=(),
                    purge_dispositions=("docs/truth/PRODUCT_TRUTH.md",),
                )

            plan = build_purge_plan(
                [
                    {
                        "artifact_id": "LEGACY-TRUTH",
                        "kind": "repo",
                        "locator": "docs/truth/PRODUCT_TRUTH.md",
                        "claim_ids": ["CLAIM-1"],
                    }
                ],
                {
                    "LEGACY-TRUTH": {
                        **dispositions()["REPO-OLD-CANON"],
                    }
                },
                {"docs/truth/PRODUCT_TRUTH.md": []},
                "refs/tags/canon-baseline",
            )
            bound_plan, owner, review, head = bound_purge_evidence(plan, root)
            self.assertEqual(
                authority_sprawl_findings(
                    root,
                    self._manifest(root, AuthorityState.ACTIVE),
                    baseline=(),
                    purge_plan=bound_plan,
                    registry=registry("REQ-1"),
                    pre_delete_revision=head,
                    candidate_revision=head,
                    owner_approval_attestations=(owner,),
                    independent_review_attestations=(review,),
                ),
                (),
            )



def review_purge_inputs(*, claim_ids: tuple[str, ...] = ("CLAIM-1",)):
    catalog = [
        {
            "artifact_id": "LEGACY",
            "kind": "repo",
            "locator": "docs/truth/OLD_CANON.md",
            "claim_ids": list(claim_ids),
        }
    ]
    dispositions = {
        "LEGACY": {
            "action": "delete",
            "claim_dispositions": {
                claim_id: "REQ-1" for claim_id in claim_ids
            },
            "replacement_ids": ["REQ-1"],
            "incoming_links_rewritten": True,
            "external_references_reconciled": True,
            "owner_approved": True,
            "independent_review": True,
        }
    }
    return catalog, dispositions, {"docs/truth/OLD_CANON.md": []}


class PurgeTrustAndTreeTests(unittest.TestCase):
    def test_task29_owner_direct_receipt_binds_an_exact_gate_c_candidate(self) -> None:
        """The Train 5 exception is exact-candidate-only, never a generic bypass."""
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            artifact = repo / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("legacy\n", encoding="utf-8")
            commit_tree(repo)
            base = git(repo, "rev-parse", "HEAD")
            base_tree = git(repo, "rev-parse", "HEAD^{tree}")
            git(repo, "tag", "canon-baseline", base)
            plan = build_purge_plan(catalog(), dispositions(), references(), base)
            direct_plan = replace(
                plan,
                artifacts=tuple(
                    replace(
                        item,
                        owner_approved=False,
                        independent_review=False,
                        owner_approval_attestation_sha256="",
                        independent_review_attestation_sha256="",
                    )
                    for item in plan.artifacts
                ),
            )
            git(repo, "rm", "-q", "docs/truth/OLD_CANON.md")
            git(repo, "commit", "-qm", "gate c candidate")
            candidate = git(repo, "rev-parse", "HEAD")
            candidate_tree = git(repo, "rev-parse", "HEAD^{tree}")
            operation_digest = purge_plan_digest(
                direct_plan,
                pre_delete_tree_sha=base_tree,
                candidate_tree_sha=candidate_tree,
                rollback_commit_sha=base,
            )
            owner_text = (
                "I approve TASK-29 direct Gate C candidate "
                f"{candidate} for purge operation {operation_digest}."
            )
            receipt = {
                "schema_version": 1,
                "receipt_type": "owner-direct-task29-gate-c",
                "decision_id": "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z",
                "task_id": "TASK-29",
                "pre_delete": {"commit_sha": base, "tree_sha": base_tree},
                "candidate": {
                    "commit_sha": candidate,
                    "tree_sha": candidate_tree,
                },
                "rollback": {"commit_sha": base, "tree_sha": base_tree},
                "artifact_ids": ["REPO-OLD-CANON"],
                "purge_operation_digest": operation_digest,
                "owner_approval": {
                    "text": owner_text,
                    "text_sha256": hashlib.sha256(
                        owner_text.encode("utf-8")
                    ).hexdigest(),
                },
                "exact_review": {
                    "status": "complete_clean",
                    "critical_findings": 0,
                    "important_findings": 0,
                    "review_package_sha256": "d" * 64,
                    "reviewed_candidate_tree_sha": candidate_tree,
                    "reviewed_purge_operation_digest": operation_digest,
                },
            }
            findings = verify_purge_dry_run(
                direct_plan,
                repo,
                registry("REQ-1"),
                pre_delete_revision=base,
                candidate_revision=candidate,
                owner_direct_receipt=receipt,
            )
            self.assertEqual(findings, ())

    def test_plan_digest_and_attestations_bind_real_git_and_exact_context(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            artifact = repo / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("legacy\n", encoding="utf-8")
            commit_tree(repo)
            head = git(repo, "rev-parse", "HEAD")
            plan = build_purge_plan(
                catalog(), dispositions(), references(), head
            )
            bound_plan, owner, review, _head = bound_purge_evidence(plan, repo)
            findings = verify_purge_dry_run(
                bound_plan,
                repo,
                registry("REQ-1"),
                pre_delete_revision=head,
                candidate_revision=head,
                owner_approval_attestations=(owner,),
                independent_review_attestations=(review,),
            )
            codes = {finding.code for finding in findings}
            self.assertNotIn("PURGE_OWNER_APPROVAL_UNVERIFIED", codes)
            self.assertNotIn("PURGE_REVIEW_UNVERIFIED", codes)

            mismatched_review = resign({**review, "task_id": "TASK-OTHER"})
            mismatched_digest = hashlib.sha256(
                canonical_json_bytes(mismatched_review)
            ).hexdigest()
            mismatched_plan = replace(
                bound_plan,
                artifacts=tuple(
                    replace(
                        item,
                        independent_review_attestation_sha256=mismatched_digest,
                    )
                    for item in bound_plan.artifacts
                ),
            )
            mismatch_codes = {
                finding.code
                for finding in verify_purge_dry_run(
                    mismatched_plan,
                    repo,
                    registry("REQ-1"),
                    pre_delete_revision=head,
                    candidate_revision=head,
                    owner_approval_attestations=(owner,),
                    independent_review_attestations=(mismatched_review,),
                )
            }
            self.assertIn("PURGE_REVIEW_UNVERIFIED", mismatch_codes)

    def test_empty_claims_unverified_evidence_and_nonexistent_rollback_are_red(self) -> None:
        catalog, dispositions, references = review_purge_inputs(claim_ids=())
        plan = build_purge_plan(
            catalog, dispositions, references, "refs/tags/does-not-exist"
        )
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            git(repo, "init", "-q", "-b", "main")
            git(repo, "config", "user.name", "Canon Review")
            git(repo, "config", "user.email", "canon-review@example.invalid")
            artifact = repo / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("legacy\n", encoding="utf-8")
            git(repo, "add", "-A")
            git(repo, "commit", "-qm", "base")
            codes = {item.code for item in purge_findings(plan, repo, registry("REQ-1"))}
        self.assertIn("PURGE_CLAIM_UNRESOLVED", codes)
        self.assertIn("PURGE_ROLLBACK_INVALID", codes)
        self.assertIn("PURGE_OWNER_APPROVAL_UNVERIFIED", codes)
        self.assertIn("PURGE_REVIEW_UNVERIFIED", codes)
        self.assertIn("PURGE_UNIQUE_CONTENT_UNPROVEN", codes)
        rendered = render_purge_plan(plan)
        self.assertIn("source_catalog_sha256", rendered)
        self.assertIn("dispositions_sha256", rendered)
        self.assertIn("references_sha256", rendered)

    def test_candidate_tree_scan_sees_staged_inbound_reference_and_allows_expected_deletion(self) -> None:
        catalog, dispositions, references = review_purge_inputs()
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            git(repo, "init", "-q", "-b", "main")
            git(repo, "config", "user.name", "Canon Review")
            git(repo, "config", "user.email", "canon-review@example.invalid")
            artifact = repo / "docs/truth/OLD_CANON.md"
            artifact.parent.mkdir(parents=True)
            artifact.write_text("legacy\n", encoding="utf-8")
            git(repo, "add", "-A")
            git(repo, "commit", "-qm", "base")
            base = git(repo, "rev-parse", "HEAD")
            git(repo, "tag", "canon-baseline", base)
            plan = build_purge_plan(
                catalog, dispositions, references, "refs/tags/canon-baseline"
            )

            (repo / "README.md").write_text(
                "See docs/truth/OLD_CANON.md\n", encoding="utf-8"
            )
            git(repo, "add", "README.md")
            candidate = git(repo, "write-tree")
            codes = {
                item.code
                for item in verify_purge_dry_run(
                    plan,
                    repo,
                    registry("REQ-1"),
                    pre_delete_revision=base,
                    candidate_revision=candidate,
                )
            }
            self.assertIn("PURGE_REFERENCE_ACTIVE", codes)

            git(repo, "reset", "--hard", "-q", base)
            git(repo, "rm", "-q", "docs/truth/OLD_CANON.md")
            candidate = git(repo, "write-tree")
            codes = {
                item.code
                for item in verify_purge_dry_run(
                    plan,
                    repo,
                    registry("REQ-1"),
                    pre_delete_revision=base,
                    candidate_revision=candidate,
                )
            }
            self.assertNotIn("PURGE_REFERENCE_SCAN_FAILED", codes)


if __name__ == "__main__":
    unittest.main()
