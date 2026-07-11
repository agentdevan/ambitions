import tempfile
import unittest
import json
from dataclasses import replace
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
from tools.ambitions_canon.build import _registry_content_sha
from tools.ambitions_canon.render import _supersession_manifest
from tools.ambitions_canon.supersession import load_supersession_ledger


def manifest(root: Path) -> CanonManifest:
    return CanonManifest(
        schema_version=1,
        canon_revision=1,
        authority_state=AuthorityState.SHADOW,
        compiler_version="0.1.0",
        normative_files=(),
        generated_files=(),
        source_path=Path("docs/canon/MANIFEST.toml"),
        repository_root=root,
    )


def active_document(identifier: str) -> CanonDocument:
    item = Requirement(
        requirement_id=identifier,
        title=identifier,
        concept="surface.today.identity",
        modality=Modality.MUST,
        scope="Today",
        status="normative",
        verification=(),
        supersedes=(),
        body="Today presents Start here.",
        source_path=Path("docs/canon/today.md"),
        line=20,
    )
    return CanonDocument(
        spec_id="SURFACE-TODAY",
        title="Today",
        kind=DocumentKind.SURFACE,
        status="normative",
        owner_domain="product",
        canon_revision=1,
        profile="surface-v1",
        owns_concepts=("surface.today.identity",),
        inherits=(),
        depends_on=(),
        source_owners=(),
        sections=frozenset(),
        not_applicable=(),
        requirements=(item,),
        source_path=Path("docs/canon/today.md"),
    )


def write_ledger(
    root: Path,
    text: str,
    *,
    indexed_requirement_ids: tuple[str, ...] = (),
) -> Path:
    path = root / "docs/canon/decisions/SUPERSESSION_LEDGER.toml"
    path.parent.mkdir(parents=True)
    path.write_text(text, encoding="utf-8")
    index_path = root / "docs/canon/migration/impact-reference-index.json"
    index_path.parent.mkdir(parents=True, exist_ok=True)
    index_path.write_text(
        json.dumps(
            {
                "schema_version": 1,
                "canon_revision": 1,
                "indexed_requirement_ids": list(indexed_requirement_ids),
                "authority_references": [],
                "task_packs": [],
                "specification_gaps": [],
            },
            sort_keys=True,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    return path


class SupersessionLedgerTests(unittest.TestCase):
    def test_repository_backed_registry_requires_fixed_ledger(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)

            with self.assertRaises(CanonError) as raised:
                build_registry(manifest(root), ())

            self.assertEqual(
                raised.exception.code,
                "CANON_SUPERSESSION_LEDGER_MISSING",
            )

    def test_initial_ledger_is_exact_closed_and_empty(self):
        path = Path("docs/canon/decisions/SUPERSESSION_LEDGER.toml")

        ledger = load_supersession_ledger(path)

        self.assertEqual(path.read_bytes(), b"schema_version = 1\nentries = []\n")
        self.assertEqual(ledger.schema_version, 1)
        self.assertEqual(ledger.entries, ())
        self.assertEqual(ledger.retired_ids, frozenset())

    def test_registry_loads_closed_durable_ledger_ids(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(
                root,
                """schema_version = 1

[[entries]]
conflict_id = "CONFLICT-TODAY-001"
old_ids = ["TODAY-001"]
resulting_id = "TODAY-002"
decision_date = "2026-07-11"
owner = "Devan Warner"
commit = "0123456789abcdef0123456789abcdef01234567"
superseded_artifacts = ["docs/truth/PRODUCT_DESIGN_TRUTH.md"]
""",
            )

            registry = build_registry(manifest(root), ())

            self.assertTrue(registry.supersession_ledger_complete)
            self.assertEqual(registry.superseded_ids, frozenset({"TODAY-001"}))
            self.assertEqual(len(registry.supersession_entries), 1)
            self.assertEqual(
                registry.supersession_entries[0].resulting_id,
                "TODAY-002",
            )
            self.assertEqual(
                registry.supersession_ledger_bytes,
                (
                    root / "docs/canon/decisions/SUPERSESSION_LEDGER.toml"
                ).read_bytes(),
            )

    def test_ledger_bytes_change_registry_sha_and_generated_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ledger_path = write_ledger(root, "schema_version = 1\nentries = []\n")
            first_manifest = manifest(root)
            first_manifest = replace(first_manifest, source_bytes=b"manifest\n")
            first = build_registry(first_manifest, ())
            first_sha = _registry_content_sha(first)

            ledger_path.write_text(
                """schema_version = 1
[[entries]]
conflict_id = "CONFLICT-001"
old_ids = ["OLD-001"]
decision_date = "2026-07-11"
owner = "Devan Warner"
commit = "0123456789abcdef0123456789abcdef01234567"
superseded_artifacts = ["docs/truth/PRODUCT_DESIGN_TRUTH.md"]
""",
                encoding="utf-8",
            )
            second = build_registry(first_manifest, ())
            second_sha = _registry_content_sha(second)
            payload = json.loads(
                _supersession_manifest(
                    {"schema_version": 1, "canon_content_sha": second_sha},
                    second,
                )
            )

            self.assertNotEqual(first_sha, second_sha)
            self.assertEqual(
                payload["supersessions"],
                [
                    {
                        "commit": "0123456789abcdef0123456789abcdef01234567",
                        "conflict_id": "CONFLICT-001",
                        "decision_date": "2026-07-11",
                        "old_ids": ["OLD-001"],
                        "owner": "Devan Warner",
                        "resulting_id": None,
                        "superseded_artifacts": [
                            "docs/truth/PRODUCT_DESIGN_TRUTH.md"
                        ],
                    }
                ],
            )

    def test_active_id_cannot_intersect_durable_ledger(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(
                root,
                """schema_version = 1

[[entries]]
conflict_id = "CONFLICT-TODAY-001"
old_ids = ["TODAY-001"]
decision_date = "2026-07-11"
owner = "Devan Warner"
commit = "0123456789abcdef0123456789abcdef01234567"
superseded_artifacts = []
""",
                indexed_requirement_ids=("TODAY-001",),
            )

            with self.assertRaises(CanonError) as raised:
                build_registry(manifest(root), (active_document("TODAY-001"),))

            self.assertEqual(raised.exception.code, "CANON_SUPERSEDED_REFERENCE")

    def test_ledger_contract_is_closed_sorted_and_rejects_reused_old_ids(self):
        invalid_ledgers = (
            "schema_version = 1\nentries = []\nunknown = true\n",
            """schema_version = 1
[[entries]]
conflict_id = "CONFLICT-1"
old_ids = ["OLD-1", "OLD-1"]
decision_date = "2026-07-11"
owner = "Owner"
commit = "0123456789abcdef0123456789abcdef01234567"
superseded_artifacts = []
""",
            """schema_version = 1
[[entries]]
conflict_id = "CONFLICT-2"
old_ids = ["OLD-2"]
decision_date = "not-a-date"
owner = "Owner"
commit = "not-a-commit"
superseded_artifacts = []
""",
        )
        for index, text in enumerate(invalid_ledgers):
            with self.subTest(index=index):
                with tempfile.TemporaryDirectory() as directory:
                    path = write_ledger(Path(directory), text)
                    with self.assertRaises(CanonError) as raised:
                        load_supersession_ledger(path)
                    self.assertEqual(
                        raised.exception.code,
                        "CANON_SUPERSESSION_LEDGER_SCHEMA",
                    )

    def test_ledger_read_rejects_symlinked_ancestor(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            external = root / "external"
            external.mkdir()
            (external / "SUPERSESSION_LEDGER.toml").write_text(
                "schema_version = 1\nentries = []\n",
                encoding="utf-8",
            )
            canon = root / "docs/canon"
            canon.mkdir(parents=True)
            (canon / "decisions").symlink_to(external, target_is_directory=True)

            with self.assertRaises(CanonError) as raised:
                load_supersession_ledger(
                    canon / "decisions/SUPERSESSION_LEDGER.toml"
                )

            self.assertEqual(
                raised.exception.code,
                "CANON_SUPERSESSION_LEDGER_READ",
            )


if __name__ == "__main__":
    unittest.main()
