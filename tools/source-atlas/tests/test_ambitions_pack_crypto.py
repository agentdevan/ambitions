import json
import subprocess
import tempfile
import sys
from pathlib import Path
import unittest

class TestPackCrypto(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-pack-crypto.py"
        
    def test_hash_and_sign(self):
        pack = {
            "id": "test-pack",
            "metadata": {
                "last_known_good_hash": "old-hash-123"
            },
            "claims": [
                {"id": "c1", "state": "official"}
            ]
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            pack_path = Path(tmpdir) / "pack.json"
            pack_path.write_text(json.dumps(pack))
            
            # test hash
            res_hash = subprocess.run([sys.executable, str(self.script), "hash", "--pack", str(pack_path)], capture_output=True, text=True, check=True)
            pack_hash = res_hash.stdout.strip()
            self.assertEqual(len(pack_hash), 64)
            
            # test sign
            res_sign = subprocess.run([sys.executable, str(self.script), "sign", "--pack", str(pack_path)], capture_output=True, text=True, check=True)
            sign_data = json.loads(res_sign.stdout)
            self.assertEqual(sign_data["sha256"], pack_hash)
            self.assertEqual(sign_data["rollback_pointer"], "old-hash-123")
            
    def test_validation_and_quarantine(self):
        pack = {"id": "p1", "claims": []}
        
        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            pack_path = base / "pack.json"
            quarantine_dir = base / "quarantine"
            
            # 1. Valid
            pack_path.write_text(json.dumps(pack))
            res = subprocess.run([sys.executable, str(self.script), "validate", "--pack", str(pack_path)], capture_output=True, text=True)
            self.assertEqual(res.returncode, 0)
            self.assertIn("VALID", res.stdout)
            
            # 2. Corrupt -> Quarantine
            pack_path.write_text("{ invalid json")
            res = subprocess.run([sys.executable, str(self.script), "validate", "--pack", str(pack_path), "--quarantine-dir", str(quarantine_dir)], capture_output=True, text=True)
            self.assertEqual(res.returncode, 1)
            self.assertFalse(pack_path.exists())
            self.assertTrue((quarantine_dir / "pack.json.corrupt").exists())
            
            # 3. Hash mismatch -> Quarantine
            pack_path.write_text(json.dumps(pack))
            res = subprocess.run([sys.executable, str(self.script), "validate", "--pack", str(pack_path), "--expected-hash", "wrong", "--quarantine-dir", str(quarantine_dir)], capture_output=True, text=True)
            self.assertEqual(res.returncode, 1)
            self.assertFalse(pack_path.exists())
            self.assertTrue((quarantine_dir / "pack.json.hash_mismatch").exists())
            
            # 4. Revoked -> Quarantine
            pack_path.write_text(json.dumps(pack))
            rev_path = base / "rev.json"
            rev_path.write_text(json.dumps({"revoked_pack_ids": ["p1"]}))
            res = subprocess.run([sys.executable, str(self.script), "validate", "--pack", str(pack_path), "--revocation-list", str(rev_path), "--quarantine-dir", str(quarantine_dir)], capture_output=True, text=True)
            self.assertEqual(res.returncode, 1)
            self.assertFalse(pack_path.exists())
            self.assertTrue((quarantine_dir / "pack.json.revoked").exists())

if __name__ == '__main__':
    unittest.main()
