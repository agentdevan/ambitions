from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from dataclasses import replace
from itertools import product
from pathlib import Path
import sys
import unittest


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.hashing import compute_contract_hash
from product_docs.documents import parse_document
from product_docs.models import (
    AuthorityClass,
    DocumentMetadata,
    DocumentStatus,
    DocumentType,
    EvidenceFile,
    InputBinding,
    InputKind,
    LifecycleDocument,
    ReviewVerdict,
    Section,
)
from product_docs.validation import (
    derive_freshness_paths,
    validate_document,
    validate_sources,
    validate_structure,
    validate_traceability,
)

from support import TemporaryRepositoryTestCase


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_DIRECTORY = SKILL_ROOT / "assets" / "templates" / "v1"


def replace_section(
    document: LifecycleDocument, heading: str, body: str
) -> LifecycleDocument:
    return replace(
        document,
        sections=tuple(
            replace(section, body=body) if section.heading == heading else section
            for section in document.sections
        ),
    )


def complete_document(document_type: str) -> LifecycleDocument:
    document = parse_document(
        TEMPLATE_DIRECTORY / f"{document_type}.md",
        repository_root=SKILL_ROOT.parents[2],
    )
    sections = tuple(
        replace(
            section,
            body=(
                section.body.replace(
                    next(
                        (
                            line
                            for line in section.body.splitlines()
                            if "PRODUCT-DOC-DRAFT:" in line
                        ),
                        "",
                    ),
                    "Complete.",
                )
                if "PRODUCT-DOC-DRAFT:" in section.body
                else section.body
            ),
        )
        for section in document.sections
    )
    metadata = replace(
        document.metadata,
        template_hash="sha256:" + "1" * 64,
        skill_package_hash="sha256:" + "2" * 64,
        initiative_id="PD-2026-08-VALIDATION",
        document_id=f"PD-2026-08-VALIDATION-{document_type.upper()}",
        status=DocumentStatus.SEALED,
        repository_baseline_commit="a" * 40,
        external_research_as_of="2026-08-02",
    )
    document = replace(document, metadata=metadata, sections=sections)
    freshness = derive_freshness_paths(document.metadata)
    document = replace(
        document, metadata=replace(document.metadata, freshness_paths=freshness)
    )
    return replace(
        document,
        metadata=replace(
            document.metadata, contract_hash=compute_contract_hash(document)
        ),
    )


def diagnostic_codes(diagnostics: tuple[object, ...]) -> set[str]:
    return {diagnostic.code for diagnostic in diagnostics}


def hash_fixture() -> LifecycleDocument:
    metadata = DocumentMetadata(
        schema_version=1,
        template_version="research-v1",
        template_hash="sha256:" + "1" * 64,
        skill_version="1.0.0",
        skill_package_hash="sha256:" + "2" * 64,
        authoring_surface="chatgpt",
        initiative_id="PD-2026-08-HASH",
        document_id="PD-2026-08-HASH-RESEARCH",
        document_type=DocumentType.RESEARCH,
        authority_class=AuthorityClass.EVIDENCE,
        entry_point="research",
        status=DocumentStatus.PASSED,
        revision=7,
        created_at="2026-08-01",
        updated_at="2026-08-02",
        repository_baseline_commit="a" * 40,
        external_research_as_of="2026-08-02",
        contract_hash="sha256:" + "f" * 64,
        content_review_verdict=ReviewVerdict.PASS,
        content_review_revision=7,
        content_review_hash="sha256:" + "f" * 64,
        content_blocking_findings=0,
        consumer_review_verdict=ReviewVerdict.PASS,
        consumer_review_revision=7,
        consumer_review_hash="sha256:" + "f" * 64,
        consumer_blocking_findings=0,
        canon_targets=("docs/canon/z.md", "docs/canon/a.md", "docs/canon/a.md"),
        canon_delta_ids=("CANON-DELTA-002", "CANON-DELTA-001"),
        source_owner_paths=("Sources/Z.swift", "Sources/A.swift", "Sources/A.swift"),
        test_owner_paths=("Tests/ZTests.swift",),
        dependency_paths=("project.yml",),
        additional_freshness_paths=("docs/extra.md",),
        freshness_paths=("project.yml", "Sources/A.swift"),
        supersedes=("PD-OLD-002", "PD-OLD-001"),
        inputs=(
            InputBinding(
                InputKind.LIFECYCLE_DOCUMENT,
                "PD-UPSTREAM",
                "docs/product-development/upstream.md",
                revision=3,
                contract_hash="sha256:" + "3" * 64,
                commit="b" * 40,
            ),
            InputBinding(
                InputKind.CANON,
                "CANON-001",
                "docs/canon/a.md",
                commit="a" * 40,
            ),
        ),
        evidence_files=(
            EvidenceFile("docs/evidence/z.md", "4" * 64, "supports FIND-002"),
            EvidenceFile("docs/evidence/a.md", "5" * 64, "supports FIND-001"),
        ),
    )
    return LifecycleDocument(
        metadata=metadata,
        sections=(
            Section("Agent handoff summary", "Summary line.  \r\n", "\r\n"),
            Section("Findings", "FIND-001 supported.\r\n\r\n", "\r\n"),
            Section(
                "Review history", "REV-CONTENT-001 at a mutable timestamp.\r\n", "\r\n"
            ),
        ),
    )


class ContractHashTests(unittest.TestCase):
    def test_contract_hash_matches_literal_golden_projection(self) -> None:
        # Independently hand-checked canonical JSON + normalized authority body.
        self.assertEqual(
            compute_contract_hash(hash_fixture()),
            "sha256:fbe1224e804d52edb3443fe6207d95d5038fbbacdf8b101a6b3fae31b2942517",
        )

    def test_contract_hash_excludes_review_state_timestamps_and_history(self) -> None:
        document = hash_fixture()
        changed_metadata = replace(
            document.metadata,
            status=DocumentStatus.STALE,
            revision=99,
            created_at="2030-01-01",
            updated_at="2030-01-02",
            contract_hash="",
            content_review_verdict=ReviewVerdict.NEEDS_REVISION,
            content_review_revision=99,
            content_review_hash="sha256:" + "9" * 64,
            content_blocking_findings=9,
            consumer_review_verdict=ReviewVerdict.UNREVIEWED,
            consumer_review_revision=0,
            consumer_review_hash="",
            consumer_blocking_findings=8,
        )
        changed_sections = document.sections[:-1] + (
            replace(document.sections[-1], body="Entirely different review history.\n"),
        )

        self.assertEqual(
            compute_contract_hash(
                replace(document, metadata=changed_metadata, sections=changed_sections)
            ),
            compute_contract_hash(document),
        )

    def test_contract_hash_changes_for_each_authority_bearing_category(self) -> None:
        document = hash_fixture()
        baseline_hash = compute_contract_hash(document)
        mutations = {
            "body": replace(
                document,
                sections=(
                    replace(document.sections[0], body="Changed summary.\n"),
                    *document.sections[1:],
                ),
            ),
            "owner": replace(
                document,
                metadata=replace(
                    document.metadata, source_owner_paths=("Sources/Changed.swift",)
                ),
            ),
            "baseline": replace(
                document,
                metadata=replace(
                    document.metadata, repository_baseline_commit="c" * 40
                ),
            ),
            "input": replace(
                document,
                metadata=replace(
                    document.metadata,
                    inputs=(
                        replace(document.metadata.inputs[0], commit="c" * 40),
                        *document.metadata.inputs[1:],
                    ),
                ),
            ),
            "evidence": replace(
                document,
                metadata=replace(
                    document.metadata,
                    evidence_files=(
                        replace(
                            document.metadata.evidence_files[0],
                            role="supports FIND-003",
                        ),
                        *document.metadata.evidence_files[1:],
                    ),
                ),
            ),
            "package": replace(
                document,
                metadata=replace(
                    document.metadata, skill_package_hash="sha256:" + "6" * 64
                ),
            ),
            "template": replace(
                document,
                metadata=replace(document.metadata, template_hash="sha256:" + "7" * 64),
            ),
        }

        for category, candidate in mutations.items():
            with self.subTest(category=category):
                self.assertNotEqual(compute_contract_hash(candidate), baseline_hash)


class StructureAndFreshnessTests(unittest.TestCase):
    def test_rejects_wrong_heading_order(self) -> None:
        document = complete_document("research")
        candidate = replace(
            document,
            sections=(
                replace(document.sections[0], heading="Wrong summary"),
                *document.sections[1:],
            ),
        )

        self.assertIn(
            "section-order-mismatch", diagnostic_codes(validate_structure(candidate))
        )

    def test_rejects_duplicate_primary_ids(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|---|---|---|\n"
            "| FIND-001 | Fact | One | SRC-001 | One |\n"
            "| FIND-001 | Fact | Two | SRC-001 | Two |\n",
        )

        self.assertIn("duplicate-id", diagnostic_codes(validate_structure(document)))

    def test_rejects_remaining_draft_sentinel(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Idea and problem statement",
            "<!-- PRODUCT-DOC-DRAFT: STILL_DRAFT -->\n",
        )

        self.assertIn("draft-sentinel", diagnostic_codes(validate_structure(document)))

    def test_rejects_empty_authority_section(self) -> None:
        document = replace_section(
            complete_document("research"), "Research questions", " \n\t\n"
        )

        self.assertIn("empty-section", diagnostic_codes(validate_structure(document)))

    def test_rejects_table_header_without_authority_rows(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|---|---|---|\n",
        )

        self.assertIn("empty-section", diagnostic_codes(validate_structure(document)))

    def test_rejects_handoff_summary_over_1200_words(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Agent handoff summary",
            ("word " * 1201).strip() + "\n",
        )

        self.assertIn(
            "summary-too-long", diagnostic_codes(validate_structure(document))
        )

    def test_rejects_invalid_authority_mapping(self) -> None:
        document = complete_document("scope")
        candidate = replace(
            document,
            metadata=replace(
                document.metadata, authority_class=AuthorityClass.EVIDENCE
            ),
        )

        self.assertIn(
            "authority-class-mismatch", diagnostic_codes(validate_structure(candidate))
        )

    def test_rejects_invalid_state_review_combination(self) -> None:
        document = complete_document("research")
        candidate = replace(
            document,
            metadata=replace(
                document.metadata,
                content_review_verdict=ReviewVerdict.PASS,
                content_review_revision=document.metadata.revision,
                content_review_hash=document.metadata.contract_hash,
            ),
        )

        self.assertIn(
            "invalid-review-state", diagnostic_codes(validate_structure(candidate))
        )

    def test_state_review_matrix_accepts_only_reachable_lane_pairs(self) -> None:
        document = complete_document("research")
        contract_hash = document.metadata.contract_hash
        lane_values = {
            "clear": (ReviewVerdict.UNREVIEWED, 0, "", 0),
            "pass": (ReviewVerdict.PASS, 1, contract_hash, 0),
            "needs-revision": (
                ReviewVerdict.NEEDS_REVISION,
                1,
                contract_hash,
                1,
            ),
        }
        allowed = {
            DocumentStatus.DRAFT: {("clear", "clear")},
            DocumentStatus.SEALED: {("clear", "clear")},
            DocumentStatus.CONTENT_REVIEWED: {("pass", "clear")},
            DocumentStatus.NEEDS_REVISION: {
                ("needs-revision", "clear"),
                ("pass", "needs-revision"),
            },
            DocumentStatus.PASSED: {("pass", "pass")},
            DocumentStatus.STALE: {("pass", "pass")},
            DocumentStatus.SUPERSEDED: {
                ("clear", "clear"),
                ("pass", "clear"),
                ("needs-revision", "clear"),
                ("pass", "needs-revision"),
                ("pass", "pass"),
            },
        }

        for status, content_lane, consumer_lane in product(
            DocumentStatus, lane_values, lane_values
        ):
            with self.subTest(
                status=status.value,
                content=content_lane,
                consumer=consumer_lane,
            ):
                content = lane_values[content_lane]
                consumer = lane_values[consumer_lane]
                metadata = replace(
                    document.metadata,
                    status=status,
                    contract_hash=""
                    if status is DocumentStatus.DRAFT
                    else contract_hash,
                    freshness_paths=()
                    if status is DocumentStatus.DRAFT
                    else document.metadata.freshness_paths,
                    content_review_verdict=content[0],
                    content_review_revision=content[1],
                    content_review_hash=content[2],
                    content_blocking_findings=content[3],
                    consumer_review_verdict=consumer[0],
                    consumer_review_revision=consumer[1],
                    consumer_review_hash=consumer[2],
                    consumer_blocking_findings=consumer[3],
                )

                codes = diagnostic_codes(
                    validate_structure(replace(document, metadata=metadata))
                )

                self.assertEqual(
                    "invalid-review-state" not in codes,
                    (content_lane, consumer_lane) in allowed[status],
                )

    def test_rejects_malformed_contract_hash(self) -> None:
        document = complete_document("research")
        candidate = replace(
            document, metadata=replace(document.metadata, contract_hash="sha256:BAD")
        )

        self.assertIn("malformed-hash", diagnostic_codes(validate_structure(candidate)))

    def test_derives_exact_sorted_freshness_union_and_rejects_weakening(self) -> None:
        document = complete_document("scope")
        metadata = replace(
            document.metadata,
            canon_targets=("docs/canon/z.md",),
            source_owner_paths=("Sources/App.swift",),
            test_owner_paths=("Tests/AppTests.swift",),
            dependency_paths=("project.yml",),
            additional_freshness_paths=("docs/extra.md", "Sources/App.swift"),
            inputs=(
                InputBinding(
                    InputKind.CANON, "CANON-001", "docs/canon/input.md", commit="a" * 40
                ),
            ),
            evidence_files=(
                EvidenceFile("docs/evidence.md", "3" * 64, "supports FIND-001"),
            ),
        )
        expected = (
            ".agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md",
            ".agents/skills/ambitions-product-development-lifecycle/package-manifest.json",
            "Sources/App.swift",
            "Tests/AppTests.swift",
            "docs/canon/generated/CODEX_START_HERE.md",
            "docs/canon/generated/INDEX.md",
            "docs/canon/generated/canon-index.json",
            "docs/canon/generated/requirement-graph.json",
            "docs/canon/input.md",
            "docs/canon/z.md",
            "docs/evidence.md",
            "docs/extra.md",
            "project.yml",
        )

        self.assertEqual(derive_freshness_paths(metadata), expected)
        weakened = replace(
            document, metadata=replace(metadata, freshness_paths=expected[:-1])
        )
        self.assertIn(
            "freshness-mismatch", diagnostic_codes(validate_structure(weakened))
        )


class RepositoryValidationTests(TemporaryRepositoryTestCase):
    def _commit_required_freshness(self, document: LifecycleDocument) -> str:
        for path in derive_freshness_paths(document.metadata):
            target = self.root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(f"committed {path}\n", encoding="utf-8")
        return self.commit_all("baseline")

    def test_rejects_declared_path_missing_at_baseline(self) -> None:
        document = complete_document("research")
        metadata = replace(
            document.metadata, source_owner_paths=("Sources/Missing.swift",)
        )
        document = replace(document, metadata=metadata)
        baseline = self._commit_required_freshness(complete_document("research"))
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                repository_baseline_commit=baseline,
                freshness_paths=derive_freshness_paths(document.metadata),
            ),
        )
        document = replace(
            document,
            metadata=replace(
                document.metadata, contract_hash=compute_contract_hash(document)
            ),
        )

        report = validate_document(document, repository_root=self.root)

        self.assertIn("baseline-path-missing", diagnostic_codes(report.diagnostics))

    def test_rejects_uncommitted_evidence_path(self) -> None:
        document = complete_document("research")
        evidence = EvidenceFile(
            "docs/evidence/uncommitted.md", "3" * 64, "supports FIND-001"
        )
        document = replace(
            document, metadata=replace(document.metadata, evidence_files=(evidence,))
        )
        baseline = self._commit_required_freshness(complete_document("research"))
        evidence_path = self.root / evidence.path
        evidence_path.parent.mkdir(parents=True, exist_ok=True)
        evidence_path.write_text("not committed\n", encoding="utf-8")
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                repository_baseline_commit=baseline,
                freshness_paths=derive_freshness_paths(document.metadata),
            ),
        )
        document = replace(
            document,
            metadata=replace(
                document.metadata, contract_hash=compute_contract_hash(document)
            ),
        )

        report = validate_document(document, repository_root=self.root)

        self.assertIn("uncommitted-evidence", diagnostic_codes(report.diagnostics))

    def test_rejects_tracked_evidence_modified_after_baseline(self) -> None:
        document = complete_document("research")
        evidence_path = self.root / "docs/evidence/modified.md"
        evidence_path.parent.mkdir(parents=True, exist_ok=True)
        evidence_path.write_text("baseline evidence\n", encoding="utf-8")
        evidence = EvidenceFile(
            "docs/evidence/modified.md",
            "ed2871c37ea9cdc55171b44f78bf5f3df87e5b195311466691958ce446d8420a",
            "supports FIND-001",
        )
        document = replace(
            document, metadata=replace(document.metadata, evidence_files=(evidence,))
        )
        baseline = self._commit_required_freshness(document)
        evidence_path.write_text("modified but uncommitted\n", encoding="utf-8")
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                repository_baseline_commit=baseline,
                freshness_paths=derive_freshness_paths(document.metadata),
            ),
        )
        document = replace(
            document,
            metadata=replace(
                document.metadata, contract_hash=compute_contract_hash(document)
            ),
        )

        report = validate_document(document, repository_root=self.root)

        self.assertIn("uncommitted-evidence", diagnostic_codes(report.diagnostics))


class SourceAndTraceabilityTests(unittest.TestCase):
    def _research(self) -> LifecycleDocument:
        document = replace_section(
            complete_document("research"),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|---|---|---|\n"
            "| FIND-001 | Fact | Supported finding | SRC-001 | Bound the scope |\n",
        )
        return replace_section(
            document,
            "Source ledger",
            "| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |\n"
            "|---|---|---|---|---|---|---|---|---|\n"
            "| SRC-001 | Apple guide | Apple | https://example.invalid | 2026-08-02 | Low | Platform update | FIND-001 | Supports the finding |\n",
        )

    def test_research_findings_resolve_to_source_ledger(self) -> None:
        self.assertEqual(validate_sources(self._research()), ())

    def test_required_phase_tables_cannot_pass_without_primary_records(self) -> None:
        cases = (
            (complete_document("research"), validate_sources, {"missing-findings"}),
            (
                complete_document("scope"),
                validate_traceability,
                {"missing-requirements", "missing-acceptance-criteria"},
            ),
            (
                complete_document("design"),
                validate_traceability,
                {"missing-design-traceability", "missing-implementation-seams"},
            ),
        )

        for document, validator, expected_codes in cases:
            with self.subTest(document_type=document.metadata.document_type.value):
                self.assertTrue(
                    expected_codes.issubset(diagnostic_codes(validator(document)))
                )

    def test_malformed_required_table_surfaces_parser_diagnostic(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|\n"
            "| FIND-001 | Fact | Supported | SRC-001 | Bound |\n"
            "Complete.\n",
        )

        self.assertIn(
            "invalid-table-separator", diagnostic_codes(validate_structure(document))
        )

    def test_repository_evidence_reference_requires_exact_path_match(self) -> None:
        document = replace_section(
            complete_document("research"),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|---|---|---|\n"
            "| FIND-001 | Fact | Spoofed support | docs/evidence.md.bak | Bound the scope |\n",
        )
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                evidence_files=(
                    EvidenceFile("docs/evidence.md", "3" * 64, "supports FIND-001"),
                ),
            ),
        )

        self.assertIn("unresolved-source", diagnostic_codes(validate_sources(document)))

    def test_rejects_unresolved_research_source_and_zero_id(self) -> None:
        unresolved = replace_section(
            self._research(),
            "Findings",
            "| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
            "|---|---|---|---|---|\n"
            "| FIND-000 | Fact | Unsupported | SRC-999 | Bound the scope |\n",
        )

        codes = diagnostic_codes(
            (*validate_structure(unresolved), *validate_sources(unresolved))
        )

        self.assertIn("invalid-id", codes)
        self.assertIn("unresolved-source", codes)

    def _scope(self) -> LifecycleDocument:
        document = replace_section(
            complete_document("scope"),
            "Product requirements",
            "| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |\n"
            "|---|---|---|---|---|\n"
            "| REQ-001 | User sees result | App | FIND-001 | AC-001 |\n",
        )
        document = replace_section(
            document,
            "Acceptance criteria",
            "| Acceptance ID | Verifiable condition | Required evidence |\n"
            "|---|---|---|\n"
            "| AC-001 | Result is inspectable | Focused test |\n",
        )
        document = replace_section(
            document,
            "Canon impact and proposed canon deltas",
            "| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |\n"
            "|---|---|---|---|---|---|---|\n"
            "| CANON-DELTA-001 | docs/canon/current.md | Amend behavior | Align REQ-001 | REQ-001 | Compatible migration | Canon check and test |\n",
        )
        return replace(
            document,
            metadata=replace(document.metadata, canon_delta_ids=("CANON-DELTA-001",)),
        )

    def test_scope_requirements_map_to_authority_acceptance_and_detailed_canon_delta(
        self,
    ) -> None:
        self.assertEqual(validate_traceability(self._scope()), ())

    def test_rejects_scope_requirement_without_acceptance_and_canon_proof(self) -> None:
        document = replace_section(
            self._scope(), "Acceptance criteria", "No acceptance rows.\n"
        )
        document = replace_section(
            document,
            "Canon impact and proposed canon deltas",
            "| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |\n"
            "|---|---|---|---|---|---|---|\n"
            "| CANON-DELTA-001 | docs/canon/current.md | Amend behavior | Align REQ-001 | REQ-001 | Compatible migration |  |\n",
        )

        codes = diagnostic_codes(validate_traceability(document))

        self.assertIn("unresolved-acceptance", codes)
        self.assertIn("incomplete-canon-delta", codes)

    def test_rejects_scope_requirement_with_unresolved_authority(self) -> None:
        document = replace_section(
            self._scope(),
            "Product requirements",
            "| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |\n"
            "|---|---|---|---|---|\n"
            "| REQ-001 | User sees result | App | NOT-AUTHORITY | AC-001 |\n",
        )

        self.assertIn(
            "unresolved-requirement-authority",
            diagnostic_codes(validate_traceability(document)),
        )

    def _design(self) -> LifecycleDocument:
        document = replace_section(
            complete_document("design"),
            "Implementation seams and dependency order",
            "| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |\n"
            "|---|---|---|---|---|---|\n"
            "| SEAM-001 | Render result | REQ-001 | UI | None | VERIFY-001 |\n",
        )
        return replace_section(
            document,
            "Requirement-to-design traceability",
            "| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |\n"
            "|---|---|---|---|---|\n"
            "| FIND-001 | REQ-001 | AC-001 | DESIGN-001 | VERIFY-001 |\n",
        )

    def test_design_covers_requirements_acceptance_decisions_seams_and_verification(
        self,
    ) -> None:
        self.assertEqual(validate_traceability(self._design()), ())

    def test_rejects_design_decision_and_seam_without_verification(self) -> None:
        document = replace_section(
            self._design(),
            "Implementation seams and dependency order",
            "| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |\n"
            "|---|---|---|---|---|---|\n"
            "| SEAM-001 | Render result | REQ-001 | UI | None |  |\n",
        )
        document = replace_section(
            document,
            "Requirement-to-design traceability",
            "| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |\n"
            "|---|---|---|---|---|\n"
            "| FIND-001 | REQ-001 | AC-001 | DESIGN-001 |  |\n",
        )

        codes = diagnostic_codes(validate_traceability(document))

        self.assertIn("unverified-design", codes)
        self.assertIn("unverified-seam", codes)


if __name__ == "__main__":
    unittest.main()
