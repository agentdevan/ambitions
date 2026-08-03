from __future__ import annotations

# ruff: noqa: E402 -- the package-under-test path is intentionally injected below.

from contextlib import contextmanager
from dataclasses import replace
from datetime import date
import hashlib
import importlib
from pathlib import Path
import re
import sys
from types import SimpleNamespace


SCRIPTS_DIRECTORY = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from product_docs.package_identity import (
    build_manifest,
    canonical_manifest_bytes,
)

from support import TemporaryRepositoryTestCase, copy_skill_skeleton


SKILL_ROOT = Path(__file__).resolve().parents[1]
REPOSITORY_ROOT = SKILL_ROOT.parents[2]
INSTALLED_SKILL = Path(".agents/skills/ambitions-product-development-lifecycle")
EXPECTED_DESCRIPTION = (
    "Use when creating, reviewing, or consuming an Ambitions research, scope, or "
    "design document for a material product, UX, or architecture change; do not "
    "use for routine work whose behavior is already canonical."
)
EXPECTED_OPENAI_YAML = """interface:
  display_name: "Ambitions Product Development"
  short_description: "Create, review, and consume Ambitions lifecycle documents."
  default_prompt: "Use $ambitions-product-development-lifecycle to create, review, or consume the correct Research, Scope, or Design document for this material Ambitions initiative."
policy:
  allow_implicit_invocation: true
"""


@contextmanager
def isolated_installed_product_docs(skill_root: Path):
    """Load product_docs only from one copied package, restoring the test runner."""
    scripts = (skill_root / "scripts").resolve()
    saved_modules = {
        name: module
        for name, module in tuple(sys.modules.items())
        if name == "product_docs" or name.startswith("product_docs.")
    }
    for name in saved_modules:
        sys.modules.pop(name, None)
    sys.path.insert(0, str(scripts))
    importlib.invalidate_caches()
    try:
        documents = importlib.import_module("product_docs.documents")
        errors = importlib.import_module("product_docs.errors")
        models = importlib.import_module("product_docs.models")
        package_identity = importlib.import_module("product_docs.package_identity")
        transitions = importlib.import_module("product_docs.transitions")
        validation = importlib.import_module("product_docs.validation")
        loaded_modules = (
            documents,
            errors,
            models,
            package_identity,
            transitions,
            validation,
        )
        for module in loaded_modules:
            module_path = Path(module.__file__).resolve()
            if not module_path.is_relative_to(scripts):
                raise AssertionError(
                    f"{module.__name__} loaded outside installed package: {module_path}"
                )
        yield SimpleNamespace(
            parse_document=documents.parse_document,
            write_document_atomic=documents.write_document_atomic,
            ProductDocsError=errors.ProductDocsError,
            EvidenceFile=models.EvidenceFile,
            ReviewVerdict=models.ReviewVerdict,
            build_manifest=package_identity.build_manifest,
            canonical_manifest_bytes=package_identity.canonical_manifest_bytes,
            create_document=transitions.create_document,
            record_review=transitions.record_review,
            seal_document=transitions.seal_document,
            consume_document=validation.consume_document,
            module_paths=tuple(
                Path(module.__file__).resolve() for module in loaded_modules
            ),
        )
    finally:
        for name in tuple(sys.modules):
            if name == "product_docs" or name.startswith("product_docs."):
                sys.modules.pop(name, None)
        sys.modules.update(saved_modules)
        sys.path.remove(str(scripts))
        importlib.invalidate_caches()


class InstalledSkillSurfaceTests(TemporaryRepositoryTestCase):
    def test_skill_has_exact_identity_concise_body_and_live_links(self) -> None:
        contents = (SKILL_ROOT / "SKILL.md").read_text(encoding="utf-8")
        match = re.fullmatch(r"---\n(.*?)\n---\n(.*)", contents, re.DOTALL)
        self.assertIsNotNone(match)
        assert match is not None
        self.assertEqual(
            match.group(1),
            "name: ambitions-product-development-lifecycle\n"
            f"description: {EXPECTED_DESCRIPTION}",
        )
        body = match.group(2)
        self.assertLess(len(re.findall(r"\b[\w'-]+\b", body)), 500)
        self.assertEqual(
            re.findall(r"^## (.+)$", body, re.MULTILINE),
            [
                "Choose the role",
                "Producer",
                "Content review",
                "Consumer",
                "Lifecycle boundaries",
                "Commands",
            ],
        )

        links = re.findall(r"\[[^]]+\]\(([^)]+)\)", body)
        self.assertGreaterEqual(len(links), 10)
        for link in links:
            with self.subTest(link=link):
                self.assertTrue((SKILL_ROOT / link).is_file())

        for duplicated_rubric_detail in (
            "Blocking findings",
            "Non-blocking improvements",
            "Traceability gaps",
            "Stale or conflicting inputs",
            "Required revisions",
        ):
            self.assertNotIn(duplicated_rubric_detail, body)
        self.assertIn("Research and Scope cannot authorize implementation", body)
        self.assertIn("A document PASS cannot authorize merge", body)

    def test_openai_metadata_and_root_routing_are_exact(self) -> None:
        self.assertEqual(
            (SKILL_ROOT / "agents/openai.yaml").read_text(encoding="utf-8"),
            EXPECTED_OPENAI_YAML,
        )
        agents = (REPOSITORY_ROOT / "AGENTS.md").read_text(encoding="utf-8")
        self.assertIn(
            "For a material new product, UX, or architecture initiative whose behavior is not\n"
            "already resolved by current canon, use the repository skill\n"
            "`ambitions-product-development-lifecycle`. ChatGPT authors the canonical Research,\n"
            "Scope, and Design files; Codex performs consumer review before each downstream\n"
            "phase. This is a quality workflow, not edit or merge authorization.",
            agents,
        )
        self.assertIn("There are no process-only repository gates.", agents)
        self.assertNotIn(
            "finalization receipt",
            agents.lower().split("required engineering practice", 1)[-1],
        )

    def test_manifest_is_canonical_and_complete(self) -> None:
        manifest_path = SKILL_ROOT / "package-manifest.json"
        stored = manifest_path.read_bytes()
        expected = build_manifest(SKILL_ROOT)
        self.assertEqual(stored, canonical_manifest_bytes(expected))
        self.assertEqual(
            expected["supported_document_contracts"],
            [
                {
                    "schema_version": 1,
                    "template_versions": ["research-v1", "scope-v1", "design-v1"],
                }
            ],
        )
        paths = [record["path"] for record in expected["files"]]
        self.assertIn("SKILL.md", paths)
        self.assertIn("agents/openai.yaml", paths)
        self.assertNotIn("package-manifest.json", paths)
        self.assertFalse(any(path.startswith("tests/") for path in paths))


class LifecycleAcceptanceTests(TemporaryRepositoryTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.skill_root = self.root / INSTALLED_SKILL
        copy_skill_skeleton(self.skill_root)
        self._installed_context = isolated_installed_product_docs(self.skill_root)
        self.api = self._installed_context.__enter__()
        manifest = self.api.build_manifest(self.skill_root)
        (self.skill_root / "package-manifest.json").write_bytes(
            self.api.canonical_manifest_bytes(manifest)
        )
        self.package_commit = self.commit_all("install complete lifecycle package")

        self.owner = self.root / "Sources/Feature.swift"
        self.owner.parent.mkdir(parents=True)
        self.owner.write_text("struct Feature {}\n", encoding="utf-8")
        self.evidence = (
            self.root / "docs/product-development/lifecycle-fixture/evidence/source.md"
        )
        self.evidence.parent.mkdir(parents=True)
        self.evidence.write_text("# Evidence\n\nFixture evidence.\n", encoding="utf-8")
        self.evidence_commit = self.commit_all("add lifecycle evidence")

    def tearDown(self) -> None:
        self._installed_context.__exit__(None, None, None)
        super().tearDown()

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
        document = self.api.parse_document(path, repository_root=self.root)
        document = replace(
            document,
            metadata=replace(
                document.metadata,
                source_owner_paths=("Sources/Feature.swift",),
                evidence_files=(
                    self.api.EvidenceFile(
                        "docs/product-development/lifecycle-fixture/evidence/source.md",
                        hashlib.sha256(self.evidence.read_bytes()).hexdigest(),
                        "supports the fixture lifecycle",
                    ),
                ),
            ),
            sections=tuple(
                replace(
                    section,
                    body="".join(
                        "Complete.\n" if "PRODUCT-DOC-DRAFT:" in line else line
                        for line in section.body.splitlines(keepends=True)
                    ),
                )
                for section in document.sections
            ),
        )
        if document.metadata.document_type.value == "research":
            document = self._replace_section(
                document,
                "Findings",
                "\n| Finding ID | Classification | Finding | Source IDs | Scope implication |\n"
                "|---|---|---|---|---|\n"
                "| FIND-001 | Fact | The fixture is supported. | SRC-001 | Define REQ-001. |\n\n"
                "Complete.\n\n",
            )
            document = self._replace_section(
                document,
                "Source ledger",
                "\n| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |\n"
                "|---|---|---|---|---|---|---|---|---|\n"
                "| SRC-001 | Fixture evidence | Ambitions |  | 2026-08-03 | Low | Evidence changes | FIND-001 | Committed local evidence. |\n\n"
                "Complete.\n\n",
            )
        elif document.metadata.document_type.value == "scope":
            document = self._replace_section(
                document,
                "Product requirements",
                "\n| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |\n"
                "|---|---|---|---|---|\n"
                "| REQ-001 | Preserve the fixture behavior. | Product | FIND-001 | AC-001 |\n\n"
                "Complete.\n\n",
            )
            document = self._replace_section(
                document,
                "Acceptance criteria",
                "\n| Acceptance ID | Verifiable condition | Required evidence |\n"
                "|---|---|---|\n"
                "| AC-001 | The fixture completes the lifecycle. | Automated acceptance test. |\n\n"
                "Complete.\n\n",
            )
        else:
            document = self._replace_section(
                document,
                "Implementation seams and dependency order",
                "\n| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |\n"
                "|---|---|---|---|---|---|\n"
                "| SEAM-001 | Implement DESIGN-001. | REQ-001 | Behavior | None | VERIFY-001 |\n\n"
                "Complete.\n\n",
            )
            document = self._replace_section(
                document,
                "Requirement-to-design traceability",
                "\n| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |\n"
                "|---|---|---|---|---|\n"
                "| FIND-001 | REQ-001 | AC-001 | DESIGN-001 | VERIFY-001 |\n\n"
                "Complete.\n\n",
            )
        self.api.write_document_atomic(path, document, repository_root=self.root)

    @staticmethod
    def _review_payload(
        document,
        *,
        phase: str,
        lane: str,
        review_id: str,
        assessments: list[dict[str, str]] | None = None,
    ) -> dict[str, object]:
        next_phase = {
            "research": "scope",
            "scope": "design",
            "design": "canon-reconciliation",
        }[phase]
        return {
            "review_id": review_id,
            "lane": lane,
            "verdict": "pass",
            "reviewer_surface": "chatgpt" if lane == "content" else "codex",
            "reviewed_at": "2026-08-03T12:00:00Z",
            "reviewed_revision": document.metadata.revision,
            "reviewed_contract_hash": document.metadata.contract_hash,
            "blocking_findings": [],
            "non_blocking_improvements": [],
            "traceability_gaps": [],
            "stale_or_conflicting_inputs": [],
            "required_revisions": [],
            "next_permitted_lifecycle_phase": (
                "consumer-review" if lane == "content" else next_phase
            ),
            "drift_assessments": assessments or [],
        }

    def _create_complete_seal_and_content_review(self, phase: str) -> Path:
        path = self.api.create_document(
            self.root,
            initiative="Lifecycle Fixture",
            phase=phase,
            today=date(2026, 8, 3),
        )
        self._complete(path)
        self.commit_all(f"complete {phase}")
        sealed = self.api.seal_document(
            path,
            repository_root=self.root,
            sealed_at="2026-08-03T10:00:00Z",
        )
        self.commit_all(f"seal {phase}")
        self.api.record_review(
            path,
            self._review_payload(
                sealed,
                phase=phase,
                lane="content",
                review_id=f"REV-CONTENT-{phase.upper()}-001",
            ),
            repository_root=self.root,
        )
        self.commit_all(f"content review {phase}")
        return path

    def _consumer_review(
        self,
        path: Path,
        phase: str,
        *,
        assessments: list[dict[str, str]] | None = None,
    ) -> str:
        document = self.api.parse_document(path, repository_root=self.root)
        passed = self.api.record_review(
            path,
            self._review_payload(
                document,
                phase=phase,
                lane="consumer",
                review_id=f"REV-CONSUMER-{phase.upper()}-001",
                assessments=assessments,
            ),
            repository_root=self.root,
        )
        self.assertEqual(passed.metadata.status.value, "passed")
        return self.commit_all(f"consumer review {phase}")

    def test_installed_loader_rejects_corrupted_transition_module(self) -> None:
        transition_path = self.skill_root / "scripts/product_docs/transitions.py"
        original = transition_path.read_bytes()
        transition_path.write_text(
            'raise RuntimeError("installed transition corruption probe")\n',
            encoding="utf-8",
        )
        try:
            with self.assertRaisesRegex(
                RuntimeError, "installed transition corruption probe"
            ):
                with isolated_installed_product_docs(self.skill_root):
                    pass
        finally:
            transition_path.write_bytes(original)

        self.assertEqual(transition_path.read_bytes(), original)

    def test_complete_research_scope_design_chain_and_drift_contract(self) -> None:
        self.assertNotEqual(self.package_commit, self.evidence_commit)

        research = self._create_complete_seal_and_content_review("research")
        unrelated = self.root / "notes/unrelated.md"
        unrelated.parent.mkdir(parents=True)
        unrelated.write_text("unrelated repository drift\n", encoding="utf-8")
        self.commit_all("add unrelated drift")
        unrelated_report = self.api.consume_document(
            research, repository_root=self.root
        )
        self.assertEqual(unrelated_report.blockers, ())
        self.assertIn("notes/unrelated.md", unrelated_report.unrelated_paths)
        research_commit = self._consumer_review(research, "research")

        scope = self._create_complete_seal_and_content_review("scope")
        scope_document = self.api.parse_document(scope, repository_root=self.root)
        self.assertEqual(scope_document.metadata.inputs[0].commit, research_commit)
        scope_commit = self._consumer_review(scope, "scope")

        design = self._create_complete_seal_and_content_review("design")
        design_document = self.api.parse_document(design, repository_root=self.root)
        self.assertEqual(design_document.metadata.inputs[0].commit, scope_commit)

        self.owner.write_text(
            "struct Feature { let changed = true }\n", encoding="utf-8"
        )
        self.commit_all("add relevant owner drift")
        relevant_report = self.api.consume_document(design, repository_root=self.root)
        self.assertEqual(relevant_report.relevant_paths, ("Sources/Feature.swift",))
        self.assertIn("semantic-review-required", relevant_report.blockers)

        current = self.api.parse_document(design, repository_root=self.root)
        with self.assertRaises(self.api.ProductDocsError) as missing:
            self.api.record_review(
                design,
                self._review_payload(
                    current,
                    phase="design",
                    lane="consumer",
                    review_id="REV-CONSUMER-DESIGN-MISSING",
                ),
                repository_root=self.root,
            )
        self.assertEqual(
            missing.exception.diagnostics[0].code, "missing-drift-assessment"
        )

        design_commit = self._consumer_review(
            design,
            "design",
            assessments=[
                {
                    "path": "Sources/Feature.swift",
                    "impact": "none",
                    "rationale": "The fixture-only source change does not alter DESIGN-001.",
                }
            ],
        )
        final_document = self.api.parse_document(design, repository_root=self.root)
        self.assertEqual(final_document.metadata.status.value, "passed")
        self.assertEqual(
            final_document.metadata.consumer_review_verdict, self.api.ReviewVerdict.PASS
        )
        self.assertTrue(design_commit)


if __name__ == "__main__":
    import unittest

    unittest.main()
