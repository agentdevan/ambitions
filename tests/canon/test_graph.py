import unittest
from pathlib import Path

from tools.ambitions_canon.graph import (
    dependency_cycles,
    document_edges,
    requirement_edges,
)
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


def requirement(requirement_id: str, concept: str) -> Requirement:
    return Requirement(
        requirement_id=requirement_id,
        title=requirement_id,
        concept=concept,
        modality=Modality.MUST,
        scope="Test scope",
        status="normative",
        verification=(),
        supersedes=(),
        body="Test body.",
        source_path=Path(f"{requirement_id.lower()}.md"),
        line=20,
    )


def document(
    spec_id: str,
    *,
    requirement_id: str,
    concept: str,
    depends_on: tuple[str, ...] = (),
    inherits: tuple[str, ...] = (),
) -> CanonDocument:
    return CanonDocument(
        spec_id=spec_id,
        title=spec_id,
        kind=DocumentKind.SURFACE,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile=None,
        owns_concepts=(concept,),
        inherits=inherits,
        depends_on=depends_on,
        source_owners=(),
        sections=frozenset(),
        not_applicable=(),
        requirements=(requirement(requirement_id, concept),),
        source_path=Path(f"{spec_id.lower()}.md"),
    )


def registry(documents: tuple[CanonDocument, ...]):
    manifest = CanonManifest(
        schema_version=1,
        canon_revision=1,
        authority_state=AuthorityState.SHADOW,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
    )
    return build_registry(manifest, documents)


class GraphTests(unittest.TestCase):
    def test_acyclic_document_graph_has_sorted_edges_and_no_cycles(self):
        documents = (
            document(
                "SURFACE-TODAY",
                requirement_id="TODAY-001",
                concept="surface.today",
                depends_on=("OBJECT-STEP",),
            ),
            document(
                "OBJECT-STEP",
                requirement_id="STEP-001",
                concept="object.step",
            ),
        )

        edges = document_edges(registry(documents))

        self.assertEqual(edges, (("SURFACE-TODAY", "OBJECT-STEP"),))
        self.assertEqual(dependency_cycles(edges), ())

    def test_dependency_cycle_output_is_stable_and_closed(self):
        edges = (("B", "A"), ("A", "B"))

        self.assertEqual(dependency_cycles(edges), (("A", "B", "A"),))

    def test_unknown_dependency_is_rejected_before_graph_construction(self):
        documents = (
            document(
                "SURFACE-TODAY",
                requirement_id="TODAY-001",
                concept="surface.today",
                depends_on=("OBJECT-MISSING",),
            ),
        )

        with self.assertRaises(CanonError) as raised:
            registry(documents)

        self.assertEqual(raised.exception.code, "CANON_DEPENDENCY_UNKNOWN")

    def test_edges_are_sorted_independent_of_document_and_reference_order(self):
        documents = (
            document(
                "SURFACE-TODAY",
                requirement_id="TODAY-001",
                concept="surface.today",
                depends_on=("OBJECT-STEP", "GLOBAL-CAPTURE"),
                inherits=("STEP-001", "CAPTURE-001"),
            ),
            document(
                "OBJECT-STEP",
                requirement_id="STEP-001",
                concept="object.step",
            ),
            document(
                "GLOBAL-CAPTURE",
                requirement_id="CAPTURE-001",
                concept="global.capture",
            ),
        )

        first = registry(documents)
        second = registry(tuple(reversed(documents)))

        expected_documents = (
            ("SURFACE-TODAY", "GLOBAL-CAPTURE"),
            ("SURFACE-TODAY", "OBJECT-STEP"),
        )
        expected_requirements = (
            ("TODAY-001", "CAPTURE-001"),
            ("TODAY-001", "STEP-001"),
        )
        self.assertEqual(document_edges(first), expected_documents)
        self.assertEqual(document_edges(second), expected_documents)
        self.assertEqual(requirement_edges(first), expected_requirements)
        self.assertEqual(requirement_edges(second), expected_requirements)

    def test_cycle_output_is_deduplicated_and_sorted_for_arbitrary_edge_iterables(self):
        edges = iter(
            (
                ("D", "C"),
                ("B", "A"),
                ("C", "D"),
                ("A", "B"),
                ("A", "B"),
            )
        )

        self.assertEqual(
            dependency_cycles(edges),
            (("A", "B", "A"), ("C", "D", "C")),
        )


if __name__ == "__main__":
    unittest.main()
