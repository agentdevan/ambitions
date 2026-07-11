import os
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path

from tools.ambitions_canon.audit import audit_registry
from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon.cli import main
from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonManifest,
    CanonRegistry,
    DocumentKind,
    GapSeverity,
    Modality,
    Requirement,
)


def requirement(
    requirement_id: str,
    concept: str,
    *,
    modality=Modality.MUST,
    supersedes: tuple[str, ...] = (),
    path: str = "document.md",
) -> Requirement:
    return Requirement(
        requirement_id=requirement_id,
        title=requirement_id,
        concept=concept,
        modality=modality,
        scope="Test scope",
        status="normative",
        verification=(),
        supersedes=supersedes,
        body="Test body.",
        source_path=Path(path),
        line=20,
    )


def document(
    spec_id: str,
    *,
    concepts: tuple[str, ...],
    requirements: tuple[Requirement, ...] = (),
    inherits: tuple[str, ...] = (),
    depends_on: tuple[str, ...] = (),
    kind: DocumentKind = DocumentKind.SURFACE,
    path: str | None = None,
) -> CanonDocument:
    return CanonDocument(
        spec_id=spec_id,
        title=spec_id,
        kind=kind,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile=None,
        owns_concepts=concepts,
        inherits=inherits,
        depends_on=depends_on,
        source_owners=(),
        sections=frozenset(),
        not_applicable=(),
        requirements=requirements,
        source_path=Path(path or f"{spec_id.lower()}.md"),
    )


def registry(
    documents: tuple[CanonDocument, ...],
    *,
    state: AuthorityState = AuthorityState.SHADOW,
    concept_owners: tuple[tuple[str, str], ...] = (),
    superseded_ids: frozenset[str] = frozenset(),
) -> CanonRegistry:
    requirements = tuple(
        requirement
        for item in documents
        for requirement in item.requirements
    )
    return CanonRegistry(
        manifest=CanonManifest(
            schema_version=1,
            canon_revision=1,
            authority_state=state,
            compiler_version="0.1.0",
            normative_files=(),
            generated_files=(),
            source_path=Path("docs/canon/MANIFEST.toml"),
        ),
        documents=documents,
        requirements=requirements,
        concept_owners=concept_owners,
        superseded_ids=superseded_ids,
    )


def markdown_document(
    spec_id: str,
    concept: str,
    *,
    inherits: tuple[str, ...] = (),
    depends_on: tuple[str, ...] = (),
    requirement_blocks: tuple[str, ...] = (),
) -> str:
    inherited = ", ".join(f'"{item}"' for item in inherits)
    dependencies = ", ".join(f'"{item}"' for item in depends_on)
    return (
        "+++\n"
        f'spec_id = "{spec_id}"\n'
        f'title = "{spec_id}"\n'
        'kind = "surface"\n'
        'status = "normative"\n'
        'owner_domain = "product"\n'
        "canon_revision = 1\n"
        f'owns_concepts = ["{concept}"]\n'
        f"inherits = [{inherited}]\n"
        f"depends_on = [{dependencies}]\n"
        "source_owners = []\n"
        "+++\n\n"
        + "\n\n".join(requirement_blocks)
        + ("\n" if requirement_blocks else "")
    )


def requirement_block(
    requirement_id: str,
    concept: str,
    *,
    modality: str = "MUST",
    supersedes: str = "none",
) -> str:
    return (
        f"## {requirement_id} — Test law\n\n"
        f"- **Concept:** `{concept}`\n"
        f"- **Modality:** `{modality}`\n"
        "- **Scope:** Test scope\n"
        "- **Status:** `normative`\n"
        "- **Verification:** none\n"
        f"- **Supersedes:** {supersedes}\n\n"
        "Test body."
    )


def run_filesystem_audit(documents: dict[str, str]) -> tuple[int, str]:
    output = StringIO()
    with tempfile.TemporaryDirectory() as temporary_directory:
        root = Path(temporary_directory)
        canon_root = root / "docs" / "canon"
        canon_root.mkdir(parents=True)
        normative_files = ", ".join(
            f'"{path}"' for path in sorted(documents)
        )
        (canon_root / "MANIFEST.toml").write_text(
            "schema_version = 1\n"
            "canon_revision = 1\n"
            'authority_state = "shadow"\n'
            'compiler_version = "0.1.0"\n'
            f"normative_files = [{normative_files}]\n"
            "generated_files = []\n",
            encoding="utf-8",
        )
        for relative_path, text in documents.items():
            destination = canon_root / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(text, encoding="utf-8")
        previous = Path.cwd()
        try:
            os.chdir(root)
            with redirect_stdout(output):
                result = main(["audit"])
        finally:
            os.chdir(previous)
    return result, output.getvalue()


class AuditTests(unittest.TestCase):
    def assert_codes(self, expected: tuple[str, ...], value: CanonRegistry):
        findings = audit_registry(value)
        self.assertEqual(tuple(item.code for item in findings), expected)
        self.assertTrue(
            all(item.severity is GapSeverity.P0_BLOCKER for item in findings)
        )
        return findings

    def test_duplicate_global_id_is_reported(self):
        documents = (
            document("SURFACE-TODAY", concepts=("surface.today",), path="a.md"),
            document("SURFACE-TODAY", concepts=("surface.time",), path="b.md"),
        )

        self.assert_codes(("CANON_ID_DUPLICATE",), registry(documents))

    def test_duplicate_concept_owner_is_reported(self):
        documents = (
            document("SURFACE-TODAY", concepts=("surface.shared",), path="a.md"),
            document("SURFACE-TIME", concepts=("surface.shared",), path="b.md"),
        )

        self.assert_codes(
            ("CANON_CONCEPT_DUPLICATE_OWNER",),
            registry(documents),
        )

    def test_unowned_requirement_concept_is_reported(self):
        today = requirement("TODAY-001", "surface.missing", path="today.md")
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today",),
                requirements=(today,),
                path="today.md",
            ),
        )

        findings = self.assert_codes(
            ("CANON_CONCEPT_UNOWNED",),
            registry(documents),
        )
        self.assertEqual(findings[0].path, Path("today.md"))
        self.assertEqual(findings[0].line, 20)

    def test_unknown_document_and_requirement_dependencies_are_reported(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today",),
                inherits=("MISSION-999",),
                depends_on=("OBJECT-MISSING",),
            ),
        )

        self.assert_codes(
            ("CANON_DEPENDENCY_UNKNOWN", "CANON_DEPENDENCY_UNKNOWN"),
            registry(documents),
        )

    def test_document_and_requirement_dependency_cycles_are_reported(self):
        a = requirement("A-001", "object.a", path="a.md")
        b = requirement("B-001", "object.b", path="b.md")
        documents = (
            document(
                "SPEC-A",
                concepts=("object.a",),
                requirements=(a,),
                inherits=("B-001",),
                depends_on=("SPEC-B",),
                path="a.md",
            ),
            document(
                "SPEC-B",
                concepts=("object.b",),
                requirements=(b,),
                inherits=("A-001",),
                depends_on=("SPEC-A",),
                path="b.md",
            ),
        )

        self.assert_codes(
            ("CANON_DEPENDENCY_CYCLE", "CANON_DEPENDENCY_CYCLE"),
            registry(documents),
        )

    def test_invalid_modality_is_reported_even_for_manually_built_registry(self):
        invalid = requirement(
            "TODAY-001",
            "surface.today",
            modality="REQUIRED",
            path="today.md",
        )
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today",),
                requirements=(invalid,),
                path="today.md",
            ),
        )

        self.assert_codes(("CANON_MODALITY_INVALID",), registry(documents))

    def test_superseded_id_reuse_and_inheritance_are_reported(self):
        active = requirement("OLD-001", "object.old", path="old.md")
        current = requirement(
            "NEW-001",
            "object.new",
            supersedes=("OLD-001",),
            path="new.md",
        )
        documents = (
            document(
                "SPEC-OLD",
                concepts=("object.old",),
                requirements=(active,),
                path="old.md",
            ),
            document(
                "SPEC-NEW",
                concepts=("object.new",),
                requirements=(current,),
                inherits=("OLD-001",),
                depends_on=("SPEC-RETIRED",),
                path="new.md",
            ),
        )

        self.assert_codes(
            (
                "CANON_SUPERSEDED_REFERENCE",
                "CANON_SUPERSEDED_REFERENCE",
                "CANON_SUPERSEDED_REFERENCE",
            ),
            registry(
                documents,
                superseded_ids=frozenset({"OLD-001", "SPEC-RETIRED"}),
            ),
        )

    def test_active_authority_requires_exactly_one_constitution(self):
        value = registry((), state=AuthorityState.ACTIVE)

        findings = self.assert_codes(
            ("CANON_ACTIVE_CONSTITUTION_COUNT",),
            value,
        )
        self.assertEqual(findings[0].path, Path("docs/canon/MANIFEST.toml"))

    def test_findings_sort_by_severity_code_path_line_and_message(self):
        requirements = (
            requirement("Z-001", "missing.z", path="z.md"),
            requirement("A-001", "missing.a", path="a.md"),
        )
        documents = (
            document(
                "SPEC-Z",
                concepts=(),
                requirements=requirements,
                path="z.md",
            ),
        )

        findings = audit_registry(registry(documents))

        self.assertEqual(
            tuple((item.code, item.path, item.line) for item in findings),
            (
                ("CANON_CONCEPT_UNOWNED", Path("a.md"), 20),
                ("CANON_CONCEPT_UNOWNED", Path("z.md"), 20),
            ),
        )

    def test_live_shadow_cli_audit_is_green_and_deterministic(self):
        output = StringIO()

        with redirect_stdout(output):
            result = main(["audit"])

        self.assertEqual(result, 0)
        self.assertEqual(
            output.getvalue(),
            "GREEN ambitions canon audit documents=0 requirements=0 "
            "concepts=0 authority_state=shadow\n",
        )

    def test_cli_audit_renders_red_finding_and_exits_one(self):
        output = StringIO()
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            canon_root = root / "docs" / "canon"
            canon_root.mkdir(parents=True)
            (canon_root / "MANIFEST.toml").write_text(
                "schema_version = 1\n"
                "canon_revision = 1\n"
                'authority_state = "active"\n'
                'compiler_version = "0.1.0"\n'
                "normative_files = []\n"
                "generated_files = []\n",
                encoding="utf-8",
            )
            previous = Path.cwd()
            try:
                os.chdir(root)
                with redirect_stdout(output):
                    result = main(["audit"])
            finally:
                os.chdir(previous)

        self.assertEqual(result, 1)
        self.assertEqual(
            output.getvalue(),
            "P0_BLOCKER CANON_ACTIVE_CONSTITUTION_COUNT "
            "docs/canon/MANIFEST.toml:0 active authority requires exactly one "
            "Constitution; found 0\n",
        )

    def test_cli_normalizes_invalid_modality_from_parser(self):
        documents = {
            "specifications/today.md": markdown_document(
                "SURFACE-TODAY",
                "surface.today",
                requirement_blocks=(
                    requirement_block(
                        "TODAY-001",
                        "surface.today",
                        modality="REQUIRED",
                    ),
                ),
            ),
        }

        result, output = run_filesystem_audit(documents)

        self.assertEqual(result, 1)
        self.assertTrue(
            output.startswith(
                "P0_BLOCKER CANON_MODALITY_INVALID "
                "docs/canon/specifications/today.md:"
            ),
            output,
        )

    def test_cli_normalizes_duplicate_requirement_from_parser(self):
        duplicate = requirement_block("TODAY-001", "surface.today")
        documents = {
            "specifications/today.md": markdown_document(
                "SURFACE-TODAY",
                "surface.today",
                requirement_blocks=(duplicate, duplicate),
            ),
        }

        result, output = run_filesystem_audit(documents)

        self.assertEqual(result, 1)
        self.assertTrue(
            output.startswith(
                "P0_BLOCKER CANON_ID_DUPLICATE "
                "docs/canon/specifications/today.md:"
            ),
            output,
        )

    def test_cli_classifies_known_retired_inheritance_as_superseded(self):
        documents = {
            "specifications/current.md": markdown_document(
                "SPEC-CURRENT",
                "object.current",
                requirement_blocks=(
                    requirement_block(
                        "CURRENT-001",
                        "object.current",
                        supersedes="`RETIRED-001`",
                    ),
                ),
            ),
            "specifications/consumer.md": markdown_document(
                "SPEC-CONSUMER",
                "object.consumer",
                inherits=("RETIRED-001",),
            ),
        }

        result, output = run_filesystem_audit(documents)

        self.assertEqual(result, 1)
        self.assertTrue(
            output.startswith(
                "P0_BLOCKER CANON_SUPERSEDED_REFERENCE "
                "docs/canon/specifications/consumer.md:"
            ),
            output,
        )

    def test_cli_classifies_known_retired_spec_dependency_as_superseded(self):
        documents = {
            "specifications/current.md": markdown_document(
                "SPEC-CURRENT",
                "object.current",
                requirement_blocks=(
                    requirement_block(
                        "CURRENT-001",
                        "object.current",
                        supersedes="`SPEC-RETIRED`",
                    ),
                ),
            ),
            "specifications/consumer.md": markdown_document(
                "SPEC-CONSUMER",
                "object.consumer",
                depends_on=("SPEC-RETIRED",),
            ),
        }

        result, output = run_filesystem_audit(documents)

        self.assertEqual(result, 1)
        self.assertTrue(
            output.startswith(
                "P0_BLOCKER CANON_SUPERSEDED_REFERENCE "
                "docs/canon/specifications/consumer.md:"
            ),
            output,
        )

    def test_discovery_code_normalization_table_is_exhaustive(self):
        public_codes = {
            "CANON_ID_DUPLICATE",
            "CANON_CONCEPT_DUPLICATE_OWNER",
            "CANON_CONCEPT_UNOWNED",
            "CANON_DEPENDENCY_UNKNOWN",
            "CANON_DEPENDENCY_CYCLE",
            "CANON_MODALITY_INVALID",
            "CANON_SUPERSEDED_REFERENCE",
            "CANON_ACTIVE_CONSTITUTION_COUNT",
        }
        expected_discovery_codes = public_codes | {
            "CANON_REQUIREMENT_DUPLICATE",
            "CANON_REQUIREMENT_MODALITY",
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
        }

        self.assertEqual(canon_cli.PUBLIC_AUDIT_CODES, frozenset(public_codes))
        self.assertEqual(
            frozenset(canon_cli.AUDIT_CODE_BY_DISCOVERY_CODE),
            frozenset(expected_discovery_codes),
        )
        self.assertTrue(
            all(
                canon_cli.normalize_audit_error_code(discovery_code)
                in public_codes
                for discovery_code in expected_discovery_codes
            )
        )

    def test_invalid_cli_invocation_exits_two(self):
        output = StringIO()
        errors = StringIO()

        with redirect_stdout(output), redirect_stderr(errors):
            with self.assertRaises(SystemExit) as raised:
                main(["audit", "--unknown"])

        self.assertEqual(raised.exception.code, 2)
        self.assertEqual(output.getvalue(), "")


if __name__ == "__main__":
    unittest.main()
