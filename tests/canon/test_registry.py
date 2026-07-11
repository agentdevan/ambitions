import unittest
from pathlib import Path

from tools.ambitions_canon.model import (
    AuthorityState,
    CanonDocument,
    CanonError,
    CanonManifest,
    DocumentKind,
    Modality,
    Requirement,
)
from tools.ambitions_canon.registry import build_registry


def requirement(
    requirement_id: str,
    concept: str,
    *,
    supersedes: tuple[str, ...] = (),
    path: str = "document.md",
) -> Requirement:
    return Requirement(
        requirement_id=requirement_id,
        title=requirement_id,
        concept=concept,
        modality=Modality.MUST,
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


def manifest(state: AuthorityState = AuthorityState.SHADOW) -> CanonManifest:
    return CanonManifest(
        schema_version=1,
        canon_revision=1,
        authority_state=state,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
    )


class RegistryTests(unittest.TestCase):
    def assert_error_code(self, code: str, documents) -> CanonError:
        with self.assertRaises(CanonError) as raised:
            build_registry(manifest(), documents)
        self.assertEqual(raised.exception.code, code)
        return raised.exception

    def test_duplicate_spec_id_fails(self):
        documents = (
            document("SURFACE-TODAY", concepts=("surface.today.first",), path="a.md"),
            document("SURFACE-TODAY", concepts=("surface.today.second",), path="b.md"),
        )

        self.assert_error_code("CANON_ID_DUPLICATE", documents)

    def test_duplicate_requirement_id_across_files_fails(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today.identity",),
                requirements=(
                    requirement("TODAY-001", "surface.today.identity", path="a.md"),
                ),
                path="a.md",
            ),
            document(
                "SURFACE-TIME",
                concepts=("surface.time.identity",),
                requirements=(
                    requirement("TODAY-001", "surface.time.identity", path="b.md"),
                ),
                path="b.md",
            ),
        )

        self.assert_error_code("CANON_ID_DUPLICATE", documents)

    def test_spec_id_cannot_equal_active_requirement_id(self):
        documents = (
            document(
                "TODAY-001",
                concepts=("surface.today.identity",),
                requirements=(
                    requirement("TODAY-001", "surface.today.identity"),
                ),
            ),
        )

        self.assert_error_code("CANON_ID_DUPLICATE", documents)

    def test_duplicate_concept_owner_fails(self):
        documents = (
            document("SURFACE-TODAY", concepts=("surface.shared",), path="a.md"),
            document("SURFACE-TIME", concepts=("surface.shared",), path="b.md"),
        )

        self.assert_error_code("CANON_CONCEPT_DUPLICATE_OWNER", documents)

    def test_requirement_concept_must_be_owned_by_its_document(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today.identity",),
                requirements=(
                    requirement("TODAY-001", "surface.time.identity"),
                ),
            ),
        )

        self.assert_error_code("CANON_CONCEPT_UNOWNED", documents)

    def test_concept_owner_keys_must_be_normalized(self):
        invalid_concepts = (
            "",
            " ",
            "Surface.today",
            ".surface.today",
            "surface.today.",
            "surface..today",
            "surface--today",
            "surface_today",
            "surface/today",
            "surface.-today",
        )
        for concept in invalid_concepts:
            with self.subTest(concept=concept):
                documents = (
                    document("SURFACE-TODAY", concepts=(concept,)),
                )
                self.assert_error_code("CANON_CONCEPT_UNOWNED", documents)

    def test_unknown_inherits_requirement_fails(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today.identity",),
                inherits=("MISSION-999",),
            ),
        )

        self.assert_error_code("CANON_DEPENDENCY_UNKNOWN", documents)

    def test_unknown_depends_on_specification_fails(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today.identity",),
                depends_on=("OBJECT-STEP",),
            ),
        )

        self.assert_error_code("CANON_DEPENDENCY_UNKNOWN", documents)

    def test_superseded_id_cannot_be_reused_as_active(self):
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today.old", "surface.today.new"),
                requirements=(
                    requirement("TODAY-001", "surface.today.old"),
                    requirement(
                        "TODAY-002",
                        "surface.today.new",
                        supersedes=("TODAY-001",),
                    ),
                ),
            ),
        )

        self.assert_error_code("CANON_SUPERSEDED_REFERENCE", documents)

    def test_superseded_id_cannot_collide_with_active_spec_id(self):
        documents = (
            document(
                "RETIRED-001",
                concepts=("surface.today.identity",),
                requirements=(
                    requirement(
                        "TODAY-002",
                        "surface.today.identity",
                        supersedes=("RETIRED-001",),
                    ),
                ),
            ),
        )

        self.assert_error_code("CANON_SUPERSEDED_REFERENCE", documents)

    def test_registry_storage_is_sorted_independent_of_input_order(self):
        object_requirement = requirement("OBJECT-001", "object.step", path="z.md")
        surface_requirement = requirement("TODAY-001", "surface.today", path="a.md")
        documents = (
            document(
                "SURFACE-TODAY",
                concepts=("surface.today",),
                requirements=(surface_requirement,),
                inherits=("OBJECT-001",),
                depends_on=("OBJECT-STEP",),
                path="a.md",
            ),
            document(
                "OBJECT-STEP",
                concepts=("object.step",),
                requirements=(object_requirement,),
                kind=DocumentKind.OBJECT,
                path="z.md",
            ),
        )

        registry = build_registry(manifest(), reversed(documents))

        self.assertEqual(
            tuple(item.spec_id for item in registry.documents),
            ("OBJECT-STEP", "SURFACE-TODAY"),
        )
        self.assertEqual(
            tuple(item.requirement_id for item in registry.requirements),
            ("OBJECT-001", "TODAY-001"),
        )
        self.assertEqual(
            registry.concept_owners,
            (("object.step", "OBJECT-STEP"), ("surface.today", "SURFACE-TODAY")),
        )

    def test_active_registry_requires_exactly_one_constitution(self):
        with self.assertRaises(CanonError) as raised:
            build_registry(manifest(AuthorityState.ACTIVE), ())

        self.assertEqual(
            raised.exception.code,
            "CANON_MANIFEST_CONSTITUTION_REQUIRED",
        )


if __name__ == "__main__":
    unittest.main()
