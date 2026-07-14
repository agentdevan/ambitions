import importlib.util
import json
import subprocess
import unittest
from copy import deepcopy
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock

from tools.ambitions_canon import benchmark
from tools.ambitions_canon import cli as canon_cli
from tools.ambitions_canon.build import build_canon
from tools.ambitions_canon.manifest import load_documents, load_manifest
from tools.ambitions_canon.model import CanonError


ROOT = Path(__file__).resolve().parents[2]
RECEIPT = (
    ROOT
    / "docs/qa/evidence/2026-07-13-train-4-semantic-comparison/receipt.json"
)
EVALUATED_COMMIT = "1e81d170e997e6895b92cdc080563b28b60ac636"


class SemanticReceiptTest(unittest.TestCase):
    def receipt_module(self):
        return benchmark

    def payload(self):
        return json.loads(RECEIPT.read_text(encoding="utf-8"))

    def assert_error(self, payload, code):
        with self.assertRaises(CanonError) as raised:
            self.receipt_module().validate_semantic_receipt(ROOT, payload)
        self.assertEqual(raised.exception.code, code)

    def test_tracked_receipt_is_closed_canonical_and_current(self):
        module = self.receipt_module()

        receipt = module.load_and_validate_semantic_receipt(ROOT)

        self.assertEqual(receipt["schema_version"], 1)
        self.assertEqual(receipt["evaluated_task_pack_commit"], EVALUATED_COMMIT)
        self.assertEqual(receipt["compiler_version"], "0.2.0")
        self.assertEqual(receipt["authority_state"], "shadow")
        self.assertEqual(receipt["lane"], "explicit_non_ci_semantic_review")
        self.assertEqual(len(receipt["pack_hashes"]), 8)
        self.assertEqual(
            sum(2 for _ in receipt["pack_hashes"]),
            16,
        )
        comparison = receipt["comparison"]
        self.assertEqual(comparison["overall_verdict"], "new_better")
        self.assertEqual(comparison["old_total_score"], 26)
        self.assertEqual(comparison["new_total_score"], 28)
        self.assertEqual(len(comparison["dimensions"]), 7)
        self.assertEqual(
            tuple(
                (
                    row["dimension"],
                    row["verdict"],
                    row["old_score"],
                    row["new_score"],
                )
                for row in comparison["dimensions"]
            ),
            (
                ("semantic_equivalence", "equivalent", 4, 4),
                ("relevant_law_recall", "new_better", 3, 4),
                ("contradiction_control", "equivalent", 4, 4),
                ("unauthorized_assumptions", "equivalent", 4, 4),
                ("source_ownership", "new_better", 3, 4),
                ("validation_completeness", "equivalent", 4, 4),
                ("proof_discipline", "equivalent", 4, 4),
            ),
        )
        self.assertNotIn(
            "old_better", {row["verdict"] for row in comparison["dimensions"]}
        )
        raw = RECEIPT.read_bytes()
        self.assertNotIn(b'"response"', raw)
        self.assertNotIn(b'"rationale"', raw)
        self.assertLess(len(raw), 10_000)
        self.assertTrue(raw.endswith(b"\n"))
        self.assertEqual(
            raw,
            (json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode(),
        )

    def test_current_checkout_regenerates_exact_prompt_and_pack_hashes(self):
        module = self.receipt_module()
        receipt = self.payload()

        regenerated = module.regenerate_semantic_receipt_bindings(ROOT)

        for field in (
            "compiler_version",
            "canon_sha256",
            "old_prompt_sha256",
            "new_prompt_sha256",
            "pack_hashes",
        ):
            with self.subTest(field=field):
                self.assertEqual(receipt[field], regenerated[field])

    def test_receipt_is_outside_canon_inputs_and_build_outputs_stay_current(self):
        manifest = load_manifest(ROOT)
        documents = load_documents(ROOT, manifest)
        canon_inputs = {
            manifest.source_path.resolve(),
            *(document.source_path.resolve() for document in documents),
            (ROOT / "docs/canon/decisions/SUPERSESSION_LEDGER.toml").resolve(),
            (ROOT / "docs/canon/migration/impact-reference-index.json").resolve(),
        }

        self.assertFalse(RECEIPT.is_relative_to(ROOT / "docs/canon"))
        self.assertNotIn(RECEIPT.resolve(), canon_inputs)
        self.assertEqual(build_canon(ROOT, check=True), ())

    def test_receipt_path_is_not_an_authority_freeze_candidate(self):
        relative = RECEIPT.relative_to(ROOT).as_posix()
        spec = importlib.util.spec_from_file_location(
            "authority_freeze_for_receipt_test",
            ROOT / "scripts/ambitions-authority-freeze-check.py",
        )
        self.assertIsNotNone(spec)
        self.assertIsNotNone(spec.loader)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        self.assertEqual(benchmark.SEMANTIC_RECEIPT_PATH.as_posix(), relative)
        self.assertEqual(module.authority_candidates([relative]), ())

    def test_stale_task_compiler_canon_prompt_and_every_pack_hash_fail(self):
        base = self.payload()
        cases = []
        for field in (
            "evaluated_task_pack_commit",
            "canon_sha256",
            "old_prompt_sha256",
            "new_prompt_sha256",
        ):
            changed = deepcopy(base)
            changed[field] = "0" * (40 if field == "evaluated_task_pack_commit" else 64)
            cases.append((field, changed))
        changed = deepcopy(base)
        changed["compiler_version"] = "0.1.0"
        cases.append(("compiler_version", changed))
        for index, row in enumerate(base["pack_hashes"]):
            for field in ("markdown_sha256", "json_sha256"):
                changed = deepcopy(base)
                changed["pack_hashes"][index][field] = "0" * 64
                cases.append((f"{row['scenario_id']}:{field}", changed))

        for label, payload in cases:
            with self.subTest(label=label):
                self.assert_error(payload, "SEMANTIC_RECEIPT_STALE")

    def test_evaluated_ancestor_accepts_only_closed_proof_only_changes(self):
        module = self.receipt_module()
        receipt = self.payload()
        regenerated = {
            field: receipt[field]
            for field in (
                "compiler_version",
                "canon_sha256",
                "old_prompt_sha256",
                "new_prompt_sha256",
                "pack_hashes",
            )
        }
        changed = "\n".join(
            (
                ".superpowers/sdd/visual-command-contract-amendment-report.md",
                "docs/qa/evidence/2026-07-13-train-4-semantic-comparison/receipt.json",
                "tests/canon/test_semantic_receipt.py",
            )
        ) + "\n"

        with (
            mock.patch.object(module, "_semantic_receipt_require_ancestor"),
            mock.patch.object(module, "_semantic_receipt_require_evaluated_pack_bytes"),
            mock.patch.object(
                module, "regenerate_semantic_receipt_bindings", return_value=regenerated
            ),
            mock.patch.object(
                module,
                "_semantic_receipt_git",
                return_value=subprocess.CompletedProcess((), 0, stdout=changed),
            ) as git,
        ):
            module.validate_semantic_receipt(ROOT, receipt)

        git.assert_called_once_with(
            ROOT,
            "diff",
            "--name-only",
            "--diff-filter=ACMRTUXB",
            f"{receipt['evaluated_task_pack_commit']}..HEAD",
            "--",
        )

    def test_evaluated_ancestor_rejects_any_non_proof_change(self):
        module = self.receipt_module()
        receipt = self.payload()
        for relative in (
            "docs/canon/specifications/surfaces/today.md",
            "tools/ambitions_canon/task_pack.py",
        ):
            with self.subTest(path=relative):
                with (
                    mock.patch.object(module, "_semantic_receipt_require_ancestor"),
                    mock.patch.object(
                        module,
                        "_semantic_receipt_git",
                        return_value=subprocess.CompletedProcess(
                            (), 0, stdout=f"{relative}\n"
                        ),
                    ),
                ):
                    self.assert_error(receipt, "SEMANTIC_RECEIPT_STALE")

    def test_non_ancestor_and_evaluated_pack_byte_mutation_remain_stale(self):
        module = self.receipt_module()
        receipt_path = ROOT / module.SEMANTIC_RECEIPT_PATH
        with mock.patch.object(
            module.subprocess,
            "run",
            return_value=subprocess.CompletedProcess((), 1, stdout="", stderr=""),
        ):
            with self.assertRaises(CanonError) as raised:
                module._semantic_receipt_require_ancestor(
                    ROOT, "0" * 40, receipt_path
                )
        self.assertEqual(raised.exception.code, "SEMANTIC_RECEIPT_STALE")

        with mock.patch.object(
            module.subprocess,
            "run",
            return_value=subprocess.CompletedProcess((), 0, stdout=b"changed"),
        ):
            with self.assertRaises(CanonError) as raised:
                module._semantic_receipt_require_evaluated_pack_bytes(
                    ROOT, receipt_path.name * 2, receipt_path
                )
        self.assertEqual(raised.exception.code, "SEMANTIC_RECEIPT_STALE")

    def test_closed_schema_attribution_scores_verdicts_and_policy_fail_closed(self):
        base = self.payload()
        malformed = []
        changed = deepcopy(base)
        changed["unexpected"] = True
        malformed.append(("open root", changed, "SEMANTIC_RECEIPT_INVALID"))
        for record_name in ("old_response", "new_response", "comparison"):
            for field in ("reviewer", "model"):
                changed = deepcopy(base)
                changed[record_name][field] = "\u200b"
                malformed.append(
                    (f"{record_name}:{field}", changed, "SEMANTIC_RECEIPT_INVALID")
                )
        changed = deepcopy(base)
        changed["comparison"]["dimensions"][0]["old_score"] = True
        malformed.append(("boolean score", changed, "SEMANTIC_RECEIPT_INVALID"))
        changed = deepcopy(base)
        changed["comparison"]["dimensions"][0]["verdict"] = "better"
        malformed.append(("unknown verdict", changed, "SEMANTIC_RECEIPT_INVALID"))
        changed = deepcopy(base)
        changed["comparison"]["dimensions"][0].update(
            {"old_score": 4, "new_score": 3, "verdict": "old_better"}
        )
        changed["comparison"]["old_total_score"] = 26
        changed["comparison"]["new_total_score"] = 27
        changed["comparison"]["overall_verdict"] = "new_better"
        malformed.append(("old better policy", changed, "SEMANTIC_RECEIPT_POLICY"))
        changed = deepcopy(base)
        changed["comparison"]["new_total_score"] = 26
        malformed.append(("new total below old", changed, "SEMANTIC_RECEIPT_INVALID"))

        for label, payload, code in malformed:
            with self.subTest(label=label):
                self.assert_error(payload, code)

    def test_evaluated_pack_defining_bytes_remain_at_task_commit(self):
        module = self.receipt_module()
        for relative in module.EVALUATED_TASK_PACK_PATHS:
            with self.subTest(path=relative):
                committed = subprocess.run(
                    ("git", "show", f"{EVALUATED_COMMIT}:{relative}"),
                    cwd=ROOT,
                    check=True,
                    stdout=subprocess.PIPE,
                ).stdout
                self.assertEqual((ROOT / relative).read_bytes(), committed)

    def test_cli_and_ci_expose_offline_receipt_check(self):
        self.receipt_module()
        with mock.patch.object(
            canon_cli, "_semantic_review_receipt_check", return_value=0
        ) as check:
            self.assertEqual(
                canon_cli.main(["semantic-review", "--check-receipt"]), 0
            )
        check.assert_called_once_with(ROOT)

        workflow = (
            ROOT / ".github/workflows/ambitions-canon-shadow-audit.yml"
        ).read_text(encoding="utf-8")
        self.assertIn(
            "python3 scripts/ambitions-canon.py semantic-review --check-receipt",
            workflow,
        )

        output = StringIO()
        with redirect_stdout(output), self.assertRaises(SystemExit) as raised:
            canon_cli.main(["semantic-review", "--help"])
        self.assertEqual(raised.exception.code, 0)
        self.assertIn("--check-receipt", output.getvalue())


if __name__ == "__main__":
    unittest.main()
