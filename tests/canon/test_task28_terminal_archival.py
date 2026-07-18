from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

from tools.ambitions_canon.external_authority import (
    load_external_references,
    validate_linear_reconciliation,
)
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError
from tools.ambitions_canon.registry import build_registry


ROOT = Path(__file__).resolve().parents[2]
LINEAR_PATH = Path("docs/canon/migration/linear-reconciliation.json")


class Task28TerminalArchivalTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        manifest = load_manifest(ROOT)
        cls.registry = build_registry(manifest, load_documents(ROOT, manifest))
        cls.references = load_external_references(ROOT)
        cls.record = json.loads((ROOT / LINEAR_PATH).read_text(encoding="utf-8"))

    def _validate(self, record: dict[str, object]) -> None:
        with tempfile.TemporaryDirectory(prefix="task28-linear-") as directory:
            root = Path(directory)
            target = root / LINEAR_PATH
            target.parent.mkdir(parents=True)
            target.write_text(json.dumps(record), encoding="utf-8")
            validate_linear_reconciliation(root, self.registry, self.references)

    def test_terminal_archival_requires_the_exact_archival_rule(self) -> None:
        record = copy.deepcopy(self.record)
        record["action_rules"]["archive_after_extraction"] = "contradictory"
        with self.assertRaisesRegex(CanonError, "archival rule"):
            self._validate(record)

    def test_terminal_archival_rejects_a_replacement_change(self) -> None:
        record = copy.deepcopy(self.record)
        for entity in record["entities"]:
            if entity["entity_id"] == "AMB-1756":
                entity["replacement_ids"] = ["AMB-OTHER"]
                break
        with self.assertRaisesRegex(CanonError, "replacement differs"):
            self._validate(record)

    def test_terminal_archival_rejects_a_preserved_preimage_change(self) -> None:
        record = copy.deepcopy(self.record)
        for entity in record["entities"]:
            if entity["entity_id"] == "AMB-1756":
                entity["content_sha256"] = "0" * 64
                break
        with self.assertRaisesRegex(CanonError, "terminal archival entity"):
            self._validate(record)

    def test_terminal_archival_requires_the_exact_batch_id(self) -> None:
        record = copy.deepcopy(self.record)
        for batch in record["batches"]:
            if batch["batch_id"] == "superseded-design-artifacts":
                batch["batch_id"] = "renamed-terminal-archive"
                break
        with self.assertRaisesRegex(CanonError, "batch ID differs"):
            self._validate(record)


if __name__ == "__main__":
    unittest.main()
