import tempfile
import unittest
import json
import hashlib
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
from tools.ambitions_canon.supersession import (
    integration_evidence_digest,
    load_supersession_ledger,
)


def ledger_text(
    *,
    conflict_id: str,
    old_ids: tuple[str, ...],
    resulting_id: str | None,
    decision_date: str,
    owner: str,
    decision_source: str,
    superseded_artifacts: tuple[str, ...],
    resolution: str = "compose",
    decision_base_commit: str = "0123456789abcdef0123456789abcdef01234567",
) -> str:
    digest = integration_evidence_digest(
        conflict_id=conflict_id,
        old_ids=old_ids,
        resulting_id=resulting_id,
        decision_date=decision_date,
        owner=owner,
        decision_source=decision_source,
        resolution=resolution,
        decision_base_commit=decision_base_commit,
        superseded_artifacts=superseded_artifacts,
    )
    resulting_line = (
        f'resulting_id = "{resulting_id}"\n' if resulting_id is not None else ""
    )
    old_ids_text = ", ".join(f'"{item}"' for item in old_ids)
    artifacts_text = ", ".join(f'"{item}"' for item in superseded_artifacts)
    return f'''schema_version = 1

[[entries]]
conflict_id = "{conflict_id}"
old_ids = [{old_ids_text}]
{resulting_line}decision_date = "{decision_date}"
owner = "{owner}"
decision_source = "{decision_source}"
resolution = "{resolution}"
decision_base_commit = "{decision_base_commit}"
integration_evidence_sha256 = "{digest}"
superseded_artifacts = [{artifacts_text}]
'''


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

    def test_repository_ledger_is_closed_and_owner_decision_bound(self):
        path = Path("docs/canon/decisions/SUPERSESSION_LEDGER.toml")

        ledger = load_supersession_ledger(path)

        self.assertEqual(ledger.schema_version, 1)
        self.assertEqual(len(ledger.entries), 21)
        self.assertEqual(
            tuple(item.conflict_id for item in ledger.entries),
            tuple(sorted(item.conflict_id for item in ledger.entries)),
        )
        original = tuple(
            item
            for item in ledger.entries
            if item.conflict_id != "CONFLICT-SEARCH-FIND-ASK-ACT-INSPECT"
        )
        self.assertEqual(len(original), 20)
        self.assertTrue(
            all(
                item.decision_source
                == "Owner approval on 2026-07-12: “Approve all 20 recommended resolutions and proposed canonical laws.”"
                for item in original
            )
        )
        search = next(
            item
            for item in ledger.entries
            if item.conflict_id == "CONFLICT-SEARCH-FIND-ASK-ACT-INSPECT"
        )
        self.assertIn("stronger third law", search.decision_source)
        self.assertTrue(ledger.retired_ids)

    def test_registry_loads_closed_durable_ledger_ids(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(
                root,
                ledger_text(
                    conflict_id="CONFLICT-TODAY-001",
                    old_ids=("TODAY-001",),
                    resulting_id="TODAY-002",
                    decision_date="2026-07-11",
                    owner="Devan Warner",
                    decision_source="Owner approval recorded in the Task 13 instruction.",
                    superseded_artifacts=("docs/truth/PRODUCT_DESIGN_TRUTH.md",),
                ),
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

    def test_ledger_preserves_owner_decision_source_in_generated_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_ledger(
                root,
                ledger_text(
                    conflict_id="CONFLICT-TODAY-001",
                    old_ids=("TODAY-001",),
                    resulting_id="TODAY-002",
                    decision_date="2026-07-12",
                    owner="Devan Warner",
                    decision_source="Owner approval: Approve the recommended resolution and proposed canonical law.",
                    superseded_artifacts=("docs/truth/PRODUCT_DESIGN_TRUTH.md",),
                ),
            )

            registry = build_registry(manifest(root), ())
            entry = registry.supersession_entries[0]
            payload = json.loads(
                _supersession_manifest(
                    {"schema_version": 1, "canon_content_sha": "abc"},
                    registry,
                )
            )

            self.assertEqual(
                entry.decision_source,
                "Owner approval: Approve the recommended resolution and proposed canonical law.",
            )
            self.assertEqual(
                payload["supersessions"][0]["decision_source"],
                entry.decision_source,
            )

    def test_ledger_uses_decision_base_and_content_evidence_not_false_commit(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            evidence_fields = {
                "conflict_id": "CONFLICT-TODAY-001",
                "decision_base_commit": "0123456789abcdef0123456789abcdef01234567",
                "decision_date": "2026-07-12",
                "decision_source": "Owner approval",
                "old_ids": ["TODAY-001"],
                "owner": "Devan Warner",
                "resolution": "compose",
                "resulting_id": "TODAY-002",
                "superseded_artifacts": ["docs/truth/PRODUCT_DESIGN_TRUTH.md"],
            }
            digest = hashlib.sha256(
                json.dumps(
                    evidence_fields,
                    ensure_ascii=False,
                    separators=(",", ":"),
                    sort_keys=True,
                ).encode("utf-8")
            ).hexdigest()
            write_ledger(
                root,
                f'''schema_version = 1

[[entries]]
conflict_id = "CONFLICT-TODAY-001"
old_ids = ["TODAY-001"]
resulting_id = "TODAY-002"
decision_date = "2026-07-12"
owner = "Devan Warner"
decision_source = "Owner approval"
resolution = "compose"
decision_base_commit = "0123456789abcdef0123456789abcdef01234567"
integration_evidence_sha256 = "{digest}"
superseded_artifacts = ["docs/truth/PRODUCT_DESIGN_TRUTH.md"]
''',
            )

            registry = build_registry(manifest(root), ())
            entry = registry.supersession_entries[0]
            payload = json.loads(
                _supersession_manifest(
                    {"schema_version": 1, "canon_content_sha": "abc"},
                    registry,
                )
            )

            self.assertEqual(entry.resolution, "compose")
            self.assertEqual(
                entry.decision_base_commit,
                "0123456789abcdef0123456789abcdef01234567",
            )
            self.assertEqual(entry.integration_evidence_sha256, digest)
            self.assertNotIn("commit", payload["supersessions"][0])

    def test_ledger_bytes_change_registry_sha_and_generated_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ledger_path = write_ledger(root, "schema_version = 1\nentries = []\n")
            first_manifest = manifest(root)
            first_manifest = replace(first_manifest, source_bytes=b"manifest\n")
            first = build_registry(first_manifest, ())
            first_sha = _registry_content_sha(first)

            ledger_path.write_text(
                ledger_text(
                    conflict_id="CONFLICT-001",
                    old_ids=("OLD-001",),
                    resulting_id=None,
                    decision_date="2026-07-11",
                    owner="Devan Warner",
                    decision_source="Owner approval recorded in the Task 13 instruction.",
                    superseded_artifacts=("docs/truth/PRODUCT_DESIGN_TRUTH.md",),
                ),
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
            entry = second.supersession_entries[0]
            self.assertEqual(
                payload["supersessions"],
                [
                    {
                        "conflict_id": "CONFLICT-001",
                        "decision_base_commit": entry.decision_base_commit,
                        "decision_date": "2026-07-11",
                        "decision_source": "Owner approval recorded in the Task 13 instruction.",
                        "integration_evidence_sha256": entry.integration_evidence_sha256,
                        "old_ids": ["OLD-001"],
                        "owner": "Devan Warner",
                        "resolution": "compose",
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
                ledger_text(
                    conflict_id="CONFLICT-TODAY-001",
                    old_ids=("TODAY-001",),
                    resulting_id=None,
                    decision_date="2026-07-11",
                    owner="Devan Warner",
                    decision_source="Owner approval recorded in the Task 13 instruction.",
                    superseded_artifacts=(),
                ),
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
decision_source = "Owner decision source"
commit = "0123456789abcdef0123456789abcdef01234567"
superseded_artifacts = []
""",
            """schema_version = 1
[[entries]]
conflict_id = "CONFLICT-2"
old_ids = ["OLD-2"]
decision_date = "not-a-date"
owner = "Owner"
decision_source = "Owner decision source"
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
