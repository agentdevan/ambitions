import json
import subprocess
import tempfile
from pathlib import Path
import unittest

class TestFreshnessBroker(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-freshness-broker.py"
        
    def test_build_manifest(self):
        diff_output = {
            "packID": "pack-1",
            "currentSHA256": "abcdef",
            "currentSignature": "mock-sig",
            "rollbackPointers": {"old_hash": "abcdef"},
            "changedClaimIDs": ["c1", "c2"],
            "flags": {
                "stale": ["c2"],
                "revoked": ["c3"]
            }
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            diff_path = Path(tmpdir) / "diff.json"
            diff_path.write_text(json.dumps(diff_output))
            
            out_path = Path(tmpdir) / "freshness.json"
            
            import sys
            res = subprocess.run([
                sys.executable,
                str(self.script), 
                "--version-id", "v1.0.0", 
                "--diff-files", str(diff_path),
                "--output", str(out_path)
            ], capture_output=True, text=True, check=True)
            
            manifest = json.loads(out_path.read_text())
            self.assertEqual(manifest["schemaVersion"], 1)
            self.assertEqual(manifest["versionID"], "v1.0.0")
            self.assertIn("publishedAt", manifest)
            self.assertEqual(len(manifest["packIndex"]), 1)
            self.assertEqual(manifest["globalRevocationList"], ["c3"])
            self.assertEqual(manifest["globalStaleClaims"], ["c2"])
            self.assertEqual(manifest["packIndex"][0]["packID"], "pack-1")

if __name__ == '__main__':
    unittest.main()
