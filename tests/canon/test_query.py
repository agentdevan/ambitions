import unittest
from pathlib import Path

from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.query import query_by_concept, query_by_id

from tests.canon.test_task_pack import sample_registry


class QueryTests(unittest.TestCase):
    def setUp(self):
        self.registry = sample_registry()

    def test_query_by_id_returns_specification_or_requirement(self):
        specification = query_by_id(self.registry, "SURFACE-TODAY")
        requirement = query_by_id(self.registry, "TODAY-001")

        self.assertEqual(specification.spec_id, "SURFACE-TODAY")
        self.assertEqual(requirement.requirement_id, "TODAY-001")

    def test_query_by_id_unknown_identifier_fails_stably(self):
        with self.assertRaises(CanonError) as raised:
            query_by_id(self.registry, "UNKNOWN-001")

        self.assertEqual(raised.exception.code, "CANON_QUERY_NOT_FOUND")
        self.assertEqual(raised.exception.path, Path("docs/canon/MANIFEST.toml"))

    def test_query_by_concept_is_sorted_and_exact(self):
        requirements = query_by_concept(
            self.registry,
            "surface.today.identity",
        )

        self.assertEqual(
            tuple(item.requirement_id for item in requirements),
            ("TODAY-001", "TODAY-002"),
        )
        self.assertEqual(query_by_concept(self.registry, "surface.time"), ())


if __name__ == "__main__":
    unittest.main()
