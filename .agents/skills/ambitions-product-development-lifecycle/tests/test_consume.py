from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from dataclasses import replace
from datetime import date
import hashlib
from pathlib import Path
import sys


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.package_identity import build_manifest, canonical_manifest_bytes
from product_docs.documents import parse_document, write_document_atomic
from product_docs.errors import ProductDocsError
from product_docs.hashing import compute_contract_hash
from product_docs.models import EvidenceFile, InputBinding, InputKind, ReviewVerdict
from product_docs.repository import GitRepository
from product_docs.transitions import (
    create_document,
    record_review,
    seal_document,
)
from product_docs.validation import consume_document

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


SKILL_PATH = Path(".agents/skills/ambitions-product-development-lifecycle")
TODAY = date(2026, 8, 2)


class ConsumptionTests(TemporaryRepositoryTestCase):
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
        self.exact = self.root / "docs" / "exact.md"
        self.exact.parent.mkdir(parents=True)
        self.exact.write_text("baseline exact\n", encoding="utf-8")
        self.evidence = self.root / "docs" / "evidence" / "proof.md"
        self.evidence.parent.mkdir(parents=True)
        self.evidence.write_text("proof\n", encoding="utf-8")
        manifest = build_manifest(self.skill_root)
        (self.skill_root / "package-manifest.json").write_bytes(
            canonical_manifest_bytes(manifest)
        )
        self.package_commit = self.commit_all("fixture package")

    @staticmethod
    def _replace_section(document, heading: str, body: str):
        return replace(
            document,
            sections=tuple(
                replace(section, body=body) if section.heading == heading else section
                for section in document.sections
            ),
        )

    def _complete(self, path: Path) -> None:
        document = parse_document(path, repository_root=self.root)
        sections = tuple(
            replace(
                section,
                body="".join(
                    "Complete.\n" if "PRODUCT-DOC-DRAFT:" in line else line
                    for line in section.body.splitlines(keepends=True)
                ),
            )
            for section in document.sections
        )
        document = replace(document, sections=sections)
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
                "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-08-02 | Low | Owner changes | FIND-001 | Fixture support. |\n\n"
                "Complete.\n\n",
            )
        write_document_atomic(path, document, repository_root=self.root)

    @staticmethod
    def _review_payload(
        document,
        *,
        review_id: str,
        lane: str,
        assessments: list[dict[str, str]] | None = None,
    ) -> dict[str, object]:
        return {
            "review_id": review_id,
            "lane": lane,
            "verdict": "pass",
            "reviewer_surface": "codex" if lane == "consumer" else "chatgpt",
            "reviewed_at": "2026-08-02T12:00:00Z",
            "reviewed_revision": document.metadata.revision,
            "reviewed_contract_hash": document.metadata.contract_hash,
            "blocking_findings": [],
            "non_blocking_improvements": [],
            "traceability_gaps": [],
            "stale_or_conflicting_inputs": [],
            "required_revisions": [],
            "next_permitted_lifecycle_phase": "scope"
            if lane == "consumer"
            else "consumer-review",
            "drift_assessments": assessments or [],
        }

    def _content_reviewed_research(
        self,
        initiative: str = "Consumable",
        *,
        evidence: bool = False,
        input_binding: InputBinding | None = None,
        freshness_paths: tuple[str, ...] = ("Sources/Owner.swift",),
    ) -> Path:
        path = create_document(
            self.root, initiative=initiative, phase="research", today=TODAY
        )
        self.commit_all("track draft")
        self._complete(path)
        document = parse_document(path, repository_root=self.root)
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                source_owner_paths=freshness_paths,
                inputs=(input_binding,) if input_binding else (),
                evidence_files=(
                    EvidenceFile(
                        "docs/evidence/proof.md",
                        hashlib.sha256(b"proof\n").hexdigest(),
                        "supports FIND-001",
                    ),
                )
                if evidence
                else (),
            ),
        )
        write_document_atomic(path, document, repository_root=self.root)
        sealed = seal_document(
            path,
            repository_root=self.root,
            sealed_at="2026-08-02T10:00:00Z",
        )
        self.commit_all("seal research")
        record_review(
            path,
            self._review_payload(sealed, review_id="REV-CONTENT-001", lane="content"),
            repository_root=self.root,
        )
        self.commit_all("content review")
        return path

    def _passed_research(self, initiative: str = "Upstream") -> Path:
        path = self._content_reviewed_research(initiative, freshness_paths=())
        content = parse_document(path, repository_root=self.root)
        record_review(
            path,
            self._review_payload(
                content, review_id="REV-CONSUMER-001", lane="consumer"
            ),
            repository_root=self.root,
        )
        self.commit_all("consumer review")
        return path

    def _rewrite_sealed_identity(self, path: Path, **changes) -> None:
        document = parse_document(path, repository_root=self.root)
        metadata = replace(document.metadata, **changes, contract_hash="")
        document = replace(document, metadata=metadata)
        digest = compute_contract_hash(document)
        metadata = replace(
            metadata,
            contract_hash=digest,
            content_review_hash=digest,
            consumer_review_hash=(
                digest
                if metadata.consumer_review_verdict is ReviewVerdict.PASS
                else metadata.consumer_review_hash
            ),
        )
        write_document_atomic(
            path, replace(document, metadata=metadata), repository_root=self.root
        )

    def _rewrite_source_ledger(self, path: Path, source_row: str) -> None:
        document = parse_document(path, repository_root=self.root)
        document = self._replace_section(
            document,
            "Source ledger",
            "\n| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |\n"
            "|---|---|---|---|---|---|---|---|---|\n"
            f"{source_row}\n\nComplete.\n\n",
        )
        metadata = replace(document.metadata, contract_hash="")
        document = replace(document, metadata=metadata)
        digest = compute_contract_hash(document)
        metadata = replace(metadata, contract_hash=digest, content_review_hash=digest)
        write_document_atomic(
            path, replace(document, metadata=metadata), repository_root=self.root
        )

    def test_consume_rejects_untracked_target_before_document_state(self) -> None:
        path = create_document(
            self.root,
            initiative="Committed Target",
            phase="research",
            today=TODAY,
        )

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(report.blockers, ("document-not-committed-exact",))

    def test_consume_rejects_target_bytes_that_differ_from_head(self) -> None:
        path = self._content_reviewed_research()
        path.write_text(path.read_text(encoding="utf-8") + "\n", encoding="utf-8")

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(report.blockers, ("document-not-committed-exact",))

    def test_consume_checks_handoff_before_parsing_untracked_malformed_target(
        self,
    ) -> None:
        path = self.root / "docs" / "product-development" / "malformed" / "research.md"
        path.parent.mkdir(parents=True)
        path.write_text("not lifecycle TOML\n", encoding="utf-8")

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(report.blockers, ("document-not-committed-exact",))
        self.assertEqual(report.document_id, "")

    def test_consume_checks_noncanonical_path_before_parsing_committed_target(
        self,
    ) -> None:
        path = self.root / "docs" / "product-development" / "malformed.txt"
        path.parent.mkdir(parents=True)
        path.write_text("not lifecycle TOML\n", encoding="utf-8")
        self.commit_all("commit malformed noncanonical target")

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(report.blockers, ("noncanonical-document-path",))
        self.assertEqual(report.document_id, "")

    def test_consume_rejects_uncommitted_package_and_evidence(self) -> None:
        path = self._content_reviewed_research(evidence=True)
        (self.skill_root / "SKILL.md").write_text("# dirty package\n", encoding="utf-8")
        self.evidence.write_text("dirty proof\n", encoding="utf-8")

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(
            report.blockers,
            ("uncommitted-package", "uncommitted-evidence"),
        )

    def test_consume_rejects_committed_current_evidence_hash_mismatch(self) -> None:
        path = self._content_reviewed_research(evidence=True)
        self.evidence.write_text("new committed proof\n", encoding="utf-8")
        self.commit_all("change evidence")

        report = consume_document(path, repository_root=self.root)

        self.assertIn("evidence-hash-mismatch", report.blockers)

    def test_consume_rejects_unreachable_and_unsupported_historical_contract(
        self,
    ) -> None:
        unreachable = self._content_reviewed_research("Unreachable")
        self._rewrite_sealed_identity(unreachable, repository_baseline_commit="0" * 40)
        self.commit_all("write unreachable baseline")

        unsupported = self._content_reviewed_research("Unsupported")
        self._rewrite_sealed_identity(unsupported, schema_version=99)
        self.commit_all("write unsupported contract")

        self.assertEqual(
            consume_document(unreachable, repository_root=self.root).blockers,
            ("unreachable-baseline",),
        )
        self.assertIn(
            "unsupported-document-contract",
            consume_document(unsupported, repository_root=self.root).blockers,
        )

    def test_consume_rejects_upstream_bound_commit_and_current_identity_drift(
        self,
    ) -> None:
        upstream = self._passed_research()
        bound = parse_document(upstream, repository_root=self.root)
        binding = InputBinding(
            InputKind.LIFECYCLE_DOCUMENT,
            bound.metadata.document_id,
            upstream.resolve().relative_to(self.root.resolve()).as_posix(),
            revision=bound.metadata.revision,
            contract_hash=bound.metadata.contract_hash,
            commit=GitRepository(self.root).head(),
        )
        target = self._content_reviewed_research(
            "Downstream", input_binding=binding, freshness_paths=()
        )

        upstream_bytes = upstream.read_bytes()
        upstream.write_bytes(upstream_bytes + b"\n")
        self.assertIn(
            "uncommitted-upstream",
            consume_document(target, repository_root=self.root).blockers,
        )
        upstream.write_bytes(upstream_bytes)

        upstream_document = parse_document(upstream, repository_root=self.root)
        self._rewrite_sealed_identity(
            upstream, revision=upstream_document.metadata.revision + 1
        )
        self.commit_all("change current upstream identity")

        report = consume_document(target, repository_root=self.root)

        self.assertIn("current-upstream-binding-mismatch", report.blockers)

        bad_binding = replace(binding, commit=self.package_commit)
        self._rewrite_sealed_identity(target, inputs=(bad_binding,))
        self.commit_all("bind upstream before it passed")
        report = consume_document(target, repository_root=self.root)
        self.assertIn("upstream-not-passed-at-bound-commit", report.blockers)

    def test_consume_revalidates_committed_current_upstream_body(self) -> None:
        upstream = self._passed_research("Tampered Upstream")
        bound = parse_document(upstream, repository_root=self.root)
        binding = InputBinding(
            InputKind.LIFECYCLE_DOCUMENT,
            bound.metadata.document_id,
            upstream.resolve().relative_to(self.root.resolve()).as_posix(),
            revision=bound.metadata.revision,
            contract_hash=bound.metadata.contract_hash,
            commit=GitRepository(self.root).head(),
        )
        target = self._content_reviewed_research(
            "Tamper Consumer", input_binding=binding, freshness_paths=()
        )
        upstream.write_text(
            upstream.read_text(encoding="utf-8").replace(
                "The fixture is complete.", "The committed body was tampered."
            ),
            encoding="utf-8",
        )
        self.commit_all("commit upstream body tamper")

        report = consume_document(target, repository_root=self.root)

        self.assertIn("current-upstream-invalid", report.blockers)

    def test_consume_blocks_expired_and_triggered_external_sources(self) -> None:
        expired = self._content_reviewed_research("Expired Source")
        self._rewrite_source_ledger(
            expired,
            "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-07-01 | High | After 30 days | FIND-001 | Fixture support. |",
        )
        self.commit_all("write expired source")

        triggered = self._content_reviewed_research("Triggered Source")
        self._rewrite_source_ledger(
            triggered,
            "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-08-02 | High | On or after 2026-08-02 | FIND-001 | Fixture support. |",
        )
        self.commit_all("write triggered source")

        expired_report = consume_document(
            expired, repository_root=self.root, as_of="2026-08-02"
        )
        triggered_report = consume_document(
            triggered, repository_root=self.root, as_of="2026-08-02"
        )

        self.assertIn("external-source-expired", expired_report.blockers)
        self.assertIn("source-recheck-triggered", triggered_report.blockers)
        diagnostic = next(
            item
            for item in triggered_report.diagnostics
            if item.code == "source-recheck-triggered"
        )
        self.assertEqual(diagnostic.section, "Source ledger")
        self.assertEqual(diagnostic.identifier, "SRC-001")

    def test_consume_reports_invalid_explicit_recheck_date(self) -> None:
        path = self._content_reviewed_research("Invalid Trigger Date")
        self._rewrite_source_ledger(
            path,
            "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-08-02 | High | On or after 2026-99-99 | FIND-001 | Fixture support. |",
        )
        self.commit_all("write invalid source trigger")

        report = consume_document(path, repository_root=self.root, as_of="2026-08-02")

        self.assertIn("invalid-source-recheck-date", report.blockers)

    def test_consumer_pass_preserves_consumption_diagnostic_context(self) -> None:
        path = self._content_reviewed_research("Diagnostic Context")
        self._rewrite_source_ledger(
            path,
            "| SRC-001 | Fixture source | Ambitions | https://example.invalid | 2026-08-02 | High | On or after 2026-08-02 | FIND-001 | Fixture support. |",
        )
        self.commit_all("write triggered source")
        content = parse_document(path, repository_root=self.root)

        with self.assertRaises(ProductDocsError) as raised:
            record_review(
                path,
                self._review_payload(
                    content,
                    review_id="REV-CONSUMER-CONTEXT-001",
                    lane="consumer",
                ),
                repository_root=self.root,
            )

        diagnostic = raised.exception.diagnostics[0]
        self.assertEqual(diagnostic.code, "source-recheck-triggered")
        self.assertEqual(diagnostic.section, "Source ledger")
        self.assertEqual(diagnostic.identifier, "SRC-001")

    def test_consume_sorts_relevant_and_unrelated_drift_with_prefix_matching(
        self,
    ) -> None:
        path = self._content_reviewed_research(
            freshness_paths=("Sources", "docs/exact.md")
        )
        self.exact.write_text("changed exact\n", encoding="utf-8")
        descendant = self.root / "Sources" / "Nested.swift"
        descendant.write_text("nested\n", encoding="utf-8")
        unrelated = self.root / "README-drift.md"
        unrelated.write_text("unrelated\n", encoding="utf-8")
        self.commit_all("repository drift")

        report = consume_document(path, repository_root=self.root)

        self.assertEqual(
            report.relevant_paths, ("Sources/Nested.swift", "docs/exact.md")
        )
        self.assertEqual(
            report.unrelated_paths,
            (
                "README-drift.md",
                path.resolve().relative_to(self.root.resolve()).as_posix(),
            ),
        )
        self.assertEqual(report.blockers, ("semantic-review-required",))

    def test_consumer_pass_requires_exact_nonmaterial_drift_assessments(self) -> None:
        path = self._content_reviewed_research(freshness_paths=("Sources",))
        changed = self.root / "Sources" / "Nested.swift"
        changed.write_text("nested\n", encoding="utf-8")
        self.commit_all("relevant drift")
        content = parse_document(path, repository_root=self.root)

        cases = (
            ([], "missing-drift-assessment"),
            (
                [
                    {
                        "path": "Sources/Nested.swift",
                        "impact": "none",
                        "rationale": "No authority impact.",
                    },
                    {
                        "path": "README.md",
                        "impact": "none",
                        "rationale": "Extra.",
                    },
                ],
                "extra-drift-assessment",
            ),
            (
                [
                    {
                        "path": "Sources/Nested.swift",
                        "impact": "material",
                        "rationale": "The finding changed.",
                    }
                ],
                "material-drift",
            ),
        )
        for index, (assessments, code) in enumerate(cases, start=1):
            with self.subTest(code=code):
                payload = self._review_payload(
                    content,
                    review_id=f"REV-CONSUMER-{index:03d}",
                    lane="consumer",
                    assessments=assessments,
                )
                before = path.read_bytes()
                try:
                    with self.assertRaises(ProductDocsError) as raised:
                        record_review(path, payload, repository_root=self.root)
                    self.assertEqual(raised.exception.diagnostics[0].code, code)
                finally:
                    path.write_bytes(before)

        accepted = record_review(
            path,
            self._review_payload(
                content,
                review_id="REV-CONSUMER-010",
                lane="consumer",
                assessments=[
                    {
                        "path": "Sources/Nested.swift",
                        "impact": "none",
                        "rationale": "The new file is unrelated to FIND-001.",
                    }
                ],
            ),
            repository_root=self.root,
        )
        history = next(
            section.body
            for section in accepted.sections
            if section.heading == "Review history"
        )
        self.assertIn("The new file is unrelated to FIND-001.", history)
        self.assertFalse(
            consume_document(path, repository_root=self.root).verdict
            is ReviewVerdict.PASS
        )


if __name__ == "__main__":
    import unittest

    unittest.main()
