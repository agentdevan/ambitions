from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from dataclasses import replace
from datetime import date
import json
from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.documents import parse_document, write_document_atomic
from product_docs.errors import ProductDocsError
from product_docs.models import (
    DocumentStatus,
    EvidenceFile,
    ReviewVerdict,
)
from product_docs.package_identity import (
    build_manifest,
    canonical_manifest_bytes,
)
from product_docs.transitions import (
    create_document,
    is_committed_exact,
    mark_stale,
    record_review,
    reopen_document,
    seal_document,
    supersede_document,
)

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


SKILL_PATH = Path(".agents/skills/ambitions-product-development-lifecycle")
TODAY = date(2026, 8, 2)
WRONG_REVIEW_HASH = "sha256:" + "a" * 64


class TransitionTests(TemporaryRepositoryTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.skill_root = self.root / SKILL_PATH
        copy_skill_skeleton(self.skill_root)
        (self.skill_root / "SKILL.md").write_text(
            "# Lifecycle fixture\n", encoding="utf-8"
        )
        self.owner = self.root / "Sources" / "Owner.swift"
        self.owner.parent.mkdir(parents=True)
        self.owner.write_text("struct Owner {}\n", encoding="utf-8")
        self.canon = (
            self.root / "docs" / "canon" / "specifications" / "surfaces" / "today.md"
        )
        self.canon.parent.mkdir(parents=True)
        self.canon.write_text("# Today\n", encoding="utf-8")
        self._write_manifest()
        self.package_commit = self.commit_all("fixture package")

    def _write_manifest(self) -> None:
        manifest = build_manifest(self.skill_root)
        (self.skill_root / "package-manifest.json").write_bytes(
            canonical_manifest_bytes(manifest)
        )

    def _create_research(self, initiative: str = "Adaptive Start Here") -> Path:
        return create_document(
            self.root,
            initiative=initiative,
            phase="research",
            today=TODAY,
        )

    def _complete(self, path: Path) -> None:
        document = parse_document(path, repository_root=self.root)
        sections = []
        for section in document.sections:
            lines = [
                "Complete." if "PRODUCT-DOC-DRAFT:" in line else line
                for line in section.body.splitlines(keepends=True)
            ]
            sections.append(replace(section, body="".join(lines)))
        document = replace(document, sections=tuple(sections))
        if document.metadata.document_type.value == "research":
            document = self._replace_section(
                document,
                "Findings",
                "\n| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
                "|---|---|---|---|---|\n"
                "| FIND-001 | Fact | The fixture is complete. | SRC-001 | Continue. |\n\n"
                "Complete.\n\n",
            )
            document = self._replace_section(
                document,
                "Source ledger",
                "\n| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |\n"
                "|---|---|---|---|---|---|---|---|---|\n"
                "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-08-02 | Low | Contract changes | FIND-001 | Fixture support. |\n\n"
                "Complete.\n\n",
            )
        write_document_atomic(path, document, repository_root=self.root)

    @staticmethod
    def _replace_section(document, heading: str, body: str):
        return replace(
            document,
            sections=tuple(
                replace(section, body=body) if section.heading == heading else section
                for section in document.sections
            ),
        )

    def _tracked_complete_draft(self) -> Path:
        path = self._create_research()
        self.commit_all("track draft")
        self._complete(path)
        document = parse_document(path, repository_root=self.root)
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                source_owner_paths=("Sources/Owner.swift",),
            ),
        )
        write_document_atomic(path, document, repository_root=self.root)
        return path

    def _sealed_document(self) -> Path:
        path = self._tracked_complete_draft()
        seal_document(path, repository_root=self.root, sealed_at="2026-08-02T10:00:00Z")
        self.commit_all("seal document")
        return path

    @staticmethod
    def _review_payload(
        document,
        *,
        review_id: str,
        lane: str,
        verdict: str = "pass",
        blockers: list[str] | None = None,
    ) -> dict[str, object]:
        return {
            "review_id": review_id,
            "lane": lane,
            "verdict": verdict,
            "reviewer_surface": "codex" if lane == "consumer" else "chatgpt",
            "reviewed_at": "2026-08-02T12:00:00Z",
            "reviewed_revision": document.metadata.revision,
            "reviewed_contract_hash": document.metadata.contract_hash,
            "blocking_findings": blockers or [],
            "non_blocking_improvements": [],
            "traceability_gaps": [],
            "stale_or_conflicting_inputs": [],
            "required_revisions": [],
            "next_permitted_lifecycle_phase": "scope"
            if lane == "consumer"
            else "consumer-review",
            "drift_assessments": [],
        }

    def test_new_normalizes_ascii_slug_and_populates_stable_identity(self) -> None:
        path = self._create_research("  Café & Focus  ")

        self.assertEqual(
            path.resolve().relative_to(self.root.resolve()).as_posix(),
            "docs/product-development/cafe-focus/research.md",
        )
        document = parse_document(path, repository_root=self.root)
        self.assertEqual(document.metadata.initiative_id, "PD-2026-08-CAFE-FOCUS")
        self.assertEqual(
            document.metadata.document_id, "PD-2026-08-CAFE-FOCUS-RESEARCH"
        )
        self.assertEqual(
            document.metadata.repository_baseline_commit, self.package_commit
        )
        self.assertTrue(document.metadata.template_hash.startswith("sha256:"))
        self.assertTrue(document.metadata.skill_package_hash.startswith("sha256:"))
        self.assertEqual(document.metadata.status, DocumentStatus.DRAFT)

    def test_new_refuses_overwrite_and_invalid_or_mismatched_identity(self) -> None:
        self._create_research()
        with self.assertRaises(ProductDocsError) as overwrite:
            self._create_research()
        self.assertEqual(overwrite.exception.diagnostics[0].code, "document-exists")

        with self.assertRaises(ProductDocsError) as invalid:
            self._create_research("東京")
        self.assertEqual(
            invalid.exception.diagnostics[0].code, "invalid-initiative-slug"
        )

        with self.assertRaises(ProductDocsError) as mismatch:
            create_document(
                self.root,
                initiative="Adaptive Start Here",
                phase="research",
                initiative_id="PD-2026-08-WRONG",
                today=TODAY,
            )
        self.assertEqual(
            mismatch.exception.diagnostics[0].code, "initiative-id-mismatch"
        )

    def test_new_scope_and_design_require_committed_passed_upstream(self) -> None:
        for phase in ("scope", "design"):
            with self.subTest(phase=phase):
                with self.assertRaises(ProductDocsError) as raised:
                    create_document(
                        self.root,
                        initiative="Adaptive Start Here",
                        phase=phase,
                        today=TODAY,
                    )
                self.assertEqual(
                    raised.exception.diagnostics[0].code, "upstream-not-passed"
                )

    def test_reduced_entry_requires_and_validates_typed_authority_json(self) -> None:
        with self.assertRaises(ProductDocsError) as absent:
            create_document(
                self.root,
                initiative="Reduced Entry",
                phase="scope",
                input_path="",
                today=TODAY,
            )
        self.assertEqual(
            absent.exception.diagnostics[0].code, "reduced-entry-authority-required"
        )

        authority_file = self.root / "authority.json"
        authority_file.write_text(
            json.dumps(
                {
                    "inputs": [
                        {
                            "kind": "canon",
                            "authority_id": "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",
                            "path": "docs/canon/specifications/surfaces/today.md",
                            "commit": self.package_commit,
                        }
                    ],
                    "rationale": "Current canon resolves the skipped Research questions.",
                }
            ),
            encoding="utf-8",
        )

        path = create_document(
            self.root,
            initiative="Reduced Entry",
            phase="scope",
            input_path="",
            authority_file=authority_file,
            today=TODAY,
        )

        document = parse_document(path, repository_root=self.root)
        self.assertEqual(len(document.metadata.inputs), 1)
        self.assertEqual(
            document.metadata.inputs[0].authority_id,
            "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",
        )
        self.assertIn(
            "Current canon resolves",
            next(
                section.body
                for section in document.sections
                if section.heading == "Research input and authority"
            ),
        )

        malformed = self.root / "malformed-authority.json"
        malformed.write_text(
            '{"inputs": [{"kind": "canon"}], "rationale": "x"}', encoding="utf-8"
        )
        with self.assertRaises(ProductDocsError) as invalid:
            create_document(
                self.root,
                initiative="Invalid Reduced Entry",
                phase="scope",
                input_path="",
                authority_file=malformed,
                today=TODAY,
            )
        self.assertEqual(
            invalid.exception.diagnostics[0].code, "invalid-authority-file"
        )

    def test_seal_populates_contract_and_preserves_target_on_validation_failure(
        self,
    ) -> None:
        incomplete = self._create_research("Incomplete")
        self.commit_all("track incomplete draft")
        before = incomplete.read_bytes()
        with self.assertRaises(ProductDocsError):
            seal_document(incomplete, repository_root=self.root)
        self.assertEqual(incomplete.read_bytes(), before)

        path = self._tracked_complete_draft()
        sealed = seal_document(
            path, repository_root=self.root, sealed_at="2026-08-02T10:00:00Z"
        )

        self.assertEqual(sealed.metadata.status, DocumentStatus.SEALED)
        self.assertTrue(sealed.metadata.contract_hash.startswith("sha256:"))
        self.assertIn("Sources/Owner.swift", sealed.metadata.freshness_paths)
        self.assertEqual(
            sealed.metadata.content_review_verdict, ReviewVerdict.UNREVIEWED
        )
        self.assertEqual(
            sealed.metadata.consumer_review_verdict, ReviewVerdict.UNREVIEWED
        )
        self.assertIn("Seal event", path.read_text(encoding="utf-8"))
        self.assertFalse(is_committed_exact(path, repository_root=self.root))

    def test_seal_refuses_untracked_or_dirty_operational_and_owner_paths(self) -> None:
        untracked = self._create_research("Untracked")
        self._complete(untracked)
        with self.assertRaises(ProductDocsError) as missing:
            seal_document(untracked, repository_root=self.root)
        self.assertEqual(missing.exception.diagnostics[0].code, "document-untracked")

        dirty_package = self._tracked_complete_draft()
        before = dirty_package.read_bytes()
        (self.skill_root / "SKILL.md").write_text("changed\n", encoding="utf-8")
        with self.assertRaises(ProductDocsError) as package:
            seal_document(dirty_package, repository_root=self.root)
        self.assertIn(
            package.exception.diagnostics[0].code,
            {"package-manifest-mismatch", "uncommitted-dependency"},
        )
        self.assertEqual(dirty_package.read_bytes(), before)

    def test_seal_refuses_modified_evidence_or_owner_and_baseline_without_manifest(
        self,
    ) -> None:
        path = self._tracked_complete_draft()
        document = parse_document(path, repository_root=self.root)
        evidence = self.root / "docs" / "evidence.md"
        evidence.write_text("evidence\n", encoding="utf-8")
        evidence_commit = self.commit_all("add complete draft and evidence")
        document = parse_document(path, repository_root=self.root)
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                repository_baseline_commit=evidence_commit,
                evidence_files=(
                    EvidenceFile("docs/evidence.md", "0" * 64, "supports FIND-001"),
                ),
            ),
        )
        write_document_atomic(path, document, repository_root=self.root)
        evidence.write_text("modified\n", encoding="utf-8")
        before = path.read_bytes()
        with self.assertRaises(ProductDocsError) as dirty:
            seal_document(path, repository_root=self.root)
        self.assertIn(
            "uncommitted-evidence", {item.code for item in dirty.exception.diagnostics}
        )
        self.assertEqual(path.read_bytes(), before)

        evidence.write_text("evidence\n", encoding="utf-8")
        document = parse_document(path, repository_root=self.root)
        document = replace(
            document,
            metadata=replace(document.metadata, repository_baseline_commit="0" * 40),
        )
        write_document_atomic(path, document, repository_root=self.root)
        with self.assertRaises(ProductDocsError) as baseline:
            seal_document(path, repository_root=self.root)
        self.assertIn(
            baseline.exception.diagnostics[0].code,
            {"unreachable-baseline", "historical-path-missing"},
        )

    def test_review_lanes_advance_only_with_exact_committed_revision_and_hash(
        self,
    ) -> None:
        path = self._sealed_document()
        sealed = parse_document(path, repository_root=self.root)
        content_payload = self._review_payload(
            sealed, review_id="REV-CONTENT-001", lane="content"
        )
        content = record_review(path, content_payload, repository_root=self.root)
        self.assertEqual(content.metadata.status, DocumentStatus.CONTENT_REVIEWED)
        self.commit_all("content review")

        consumer_payload = self._review_payload(
            content, review_id="REV-CONSUMER-001", lane="consumer"
        )
        passed = record_review(path, consumer_payload, repository_root=self.root)
        self.assertEqual(passed.metadata.status, DocumentStatus.PASSED)
        self.assertEqual(
            passed.metadata.consumer_review_hash, passed.metadata.contract_hash
        )
        history = next(
            section.body
            for section in passed.sections
            if section.heading == "Review history"
        )
        self.assertLess(
            history.index("Review lane"), history.index("Blocking findings")
        )
        self.assertLess(
            history.index("Blocking findings"), history.index("Drift assessments")
        )

    def test_review_rejects_wrong_binding_duplicate_id_and_invalid_blockers(
        self,
    ) -> None:
        path = self._sealed_document()
        sealed = parse_document(path, repository_root=self.root)

        wrong = self._review_payload(
            sealed, review_id="REV-CONTENT-001", lane="content"
        )
        wrong["reviewed_contract_hash"] = WRONG_REVIEW_HASH
        with self.assertRaises(ProductDocsError) as binding:
            record_review(path, wrong, repository_root=self.root)
        self.assertEqual(
            binding.exception.diagnostics[0].code, "review-binding-mismatch"
        )

        missing = self._review_payload(
            sealed,
            review_id="REV-CONTENT-002",
            lane="content",
            verdict="needs-revision",
        )
        with self.assertRaises(ProductDocsError) as blockers:
            record_review(path, missing, repository_root=self.root)
        self.assertEqual(
            blockers.exception.diagnostics[0].code, "review-blockers-required"
        )

        present = self._review_payload(
            sealed,
            review_id="REV-CONTENT-003",
            lane="content",
            blockers=["Must not be present."],
        )
        with self.assertRaises(ProductDocsError) as passed_blockers:
            record_review(path, present, repository_root=self.root)
        self.assertEqual(
            passed_blockers.exception.diagnostics[0].code, "review-pass-has-blockers"
        )

        accepted = self._review_payload(
            sealed, review_id="REV-DUPLICATE-001", lane="content"
        )
        record_review(path, accepted, repository_root=self.root)
        self.commit_all("record first review")
        content = parse_document(path, repository_root=self.root)
        duplicate = self._review_payload(
            content, review_id="REV-DUPLICATE-001", lane="consumer"
        )
        with self.assertRaises(ProductDocsError) as duplicate_error:
            record_review(path, duplicate, repository_root=self.root)
        self.assertEqual(
            duplicate_error.exception.diagnostics[0].code, "duplicate-review-id"
        )

    def test_review_refuses_an_uncommitted_reviewed_document(self) -> None:
        path = self._sealed_document()
        path.write_text(path.read_text(encoding="utf-8") + "\n", encoding="utf-8")
        document = parse_document(path, repository_root=self.root)
        payload = self._review_payload(
            document, review_id="REV-CONTENT-001", lane="content"
        )

        with self.assertRaises(ProductDocsError) as raised:
            record_review(path, payload, repository_root=self.root)

        self.assertEqual(
            raised.exception.diagnostics[0].code, "document-not-committed-exact"
        )

    def test_needs_revision_reopens_once_and_preserves_history(self) -> None:
        path = self._sealed_document()
        sealed = parse_document(path, repository_root=self.root)
        failure = self._review_payload(
            sealed,
            review_id="REV-CONTENT-FAIL-001",
            lane="content",
            verdict="needs-revision",
            blockers=["Resolve FIND-001."],
        )
        failed = record_review(path, failure, repository_root=self.root)
        self.assertEqual(failed.metadata.status, DocumentStatus.NEEDS_REVISION)
        prior_history = next(
            section.body
            for section in failed.sections
            if section.heading == "Review history"
        )

        reopened = reopen_document(
            path, repository_root=self.root, reopened_at="2026-08-02T13:00:00Z"
        )

        self.assertEqual(reopened.metadata.status, DocumentStatus.DRAFT)
        self.assertEqual(reopened.metadata.revision, sealed.metadata.revision + 1)
        self.assertEqual(reopened.metadata.contract_hash, "")
        self.assertEqual(reopened.metadata.freshness_paths, ())
        self.assertEqual(
            reopened.metadata.content_review_verdict, ReviewVerdict.UNREVIEWED
        )
        history = next(
            section.body
            for section in reopened.sections
            if section.heading == "Review history"
        )
        self.assertTrue(history.startswith(prior_history))
        with self.assertRaises(ProductDocsError) as twice:
            reopen_document(path, repository_root=self.root)
        self.assertEqual(twice.exception.diagnostics[0].code, "invalid-transition")

    def test_mark_stale_and_supersede_change_only_state_and_history(self) -> None:
        path = self._sealed_document()
        sealed = parse_document(path, repository_root=self.root)
        content = record_review(
            path,
            self._review_payload(sealed, review_id="REV-CONTENT-001", lane="content"),
            repository_root=self.root,
        )
        self.commit_all("content review")
        passed = record_review(
            path,
            self._review_payload(
                content, review_id="REV-CONSUMER-001", lane="consumer"
            ),
            repository_root=self.root,
        )
        self.commit_all("consumer review")
        authority_before = tuple(
            section.body
            for section in passed.sections
            if section.heading != "Review history"
        )

        stale = mark_stale(
            path,
            reason="Owner path changed.",
            repository_root=self.root,
            marked_at="2026-08-02T14:00:00Z",
        )
        self.assertEqual(stale.metadata.status, DocumentStatus.STALE)
        superseded = supersede_document(
            path,
            replacement="docs/product-development/replacement/research.md",
            reason="A replacement owns the corrected authority.",
            repository_root=self.root,
            superseded_at="2026-08-02T15:00:00Z",
        )
        self.assertEqual(superseded.metadata.status, DocumentStatus.SUPERSEDED)
        authority_after = tuple(
            section.body
            for section in superseded.sections
            if section.heading != "Review history"
        )
        self.assertEqual(authority_after, authority_before)
        history = next(
            section.body
            for section in superseded.sections
            if section.heading == "Review history"
        )
        self.assertIn("docs/product-development/replacement/research.md", history)
        self.assertIn("A replacement owns the corrected authority.", history)


if __name__ == "__main__":
    unittest.main()
