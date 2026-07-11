import contextlib
import importlib.util
import io
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "ambitions-truth-path-vocabulary-audit.py"


def load_audit():
    spec = importlib.util.spec_from_file_location("truth_path_vocabulary_audit", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class TruthPathVocabularyAuditTests(unittest.TestCase):
    def setUp(self):
        self.audit = load_audit()
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.truth_dir = root / "docs" / "truth"
        self.truth_dir.mkdir(parents=True)
        self.audit.ROOT = root
        self.audit.TRUTH_DIR = self.truth_dir
        self.audit.TRUTH_BASENAMES = set()

    def run_audit(self, text):
        (self.truth_dir / "TEST_TRUTH.md").write_text(text, encoding="utf-8")
        stdout = io.StringIO()
        stderr = io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exit_code = self.audit.main()
        return exit_code, stdout.getvalue(), stderr.getvalue()

    def test_recommended_next_move_is_rejected(self):
        exit_code, _, stderr = self.run_audit("Use Recommended next move here.\n")

        self.assertEqual(exit_code, 1)
        self.assertIn("active stale term `Recommended next move`", stderr)

    def test_recommended_next_movement_is_allowed(self):
        exit_code, stdout, stderr = self.run_audit("Describe the recommended next movement.\n")

        self.assertEqual(exit_code, 0)
        self.assertIn("GREEN:", stdout)
        self.assertEqual(stderr, "")

    def test_stale_term_detection_is_case_insensitive(self):
        exit_code, _, stderr = self.run_audit("Use RECOMMENDED NEXT MOVE here.\n")

        self.assertEqual(exit_code, 1)
        self.assertIn("active stale term `Recommended next move`", stderr)

    def test_unrelated_stale_term_remains_rejected(self):
        exit_code, _, stderr = self.run_audit("Show the Reality Meridian.\n")

        self.assertEqual(exit_code, 1)
        self.assertIn("active stale term `Reality Meridian`", stderr)


if __name__ == "__main__":
    unittest.main()
