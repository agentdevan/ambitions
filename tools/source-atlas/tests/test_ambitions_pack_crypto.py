import json
import subprocess
import tempfile
from pathlib import Path
import unittest

class TestPackCrypto(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-pack-crypto.py"
        
    def test_hash_and_sign(self):
        pack = {
            "claims": [
                {"id": "c1", "state": "official"},
                {"id": "c2", "state": "stale"},
                {"id": "c3", "state": "revoked"}
            ]
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            pack_path = Path(tmpdir) / "pack.json"
            pack_path.write_text(json.dumps(pack))
            
            # test hash
            res_hash = subprocess.run([str(self.script), "hash", "--pack", str(pack_path)], capture_output=True, text=True, check=True)
            pack_hash = res_hash.stdout.strip()
            self.assertEqual(len(pack_hash), 64)
            
            # test sign
            res_sign = subprocess.run([str(self.script), "sign", "--pack", str(pack_path)], capture_output=True, text=True, check=True)
            sign_data = json.loads(res_sign.stdout)
            self.assertEqual(sign_data["sha256"], pack_hash)
            self.assertTrue(sign_data["signature"].startswith("mock-ed25519-"))
            self.assertEqual(sorted(sign_data["explicit_states"]), ["official", "revoked", "stale"])
            
    def test_revocation(self):
        rev_list = {
            "revoked_pack_ids": ["pack-1", "pack-3"]
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            rev_path = Path(tmpdir) / "rev.json"
            rev_path.write_text(json.dumps(rev_list))
            
            # check revoked
            res1 = subprocess.run([str(self.script), "check-revoked", "--pack-id", "pack-1", "--revocation-list", str(rev_path)], capture_output=True, text=True)
            self.assertEqual(res1.returncode, 1)
            self.assertEqual(res1.stdout.strip(), "REVOKED")
            
            # check not revoked
            res2 = subprocess.run([str(self.script), "check-revoked", "--pack-id", "pack-2", "--revocation-list", str(rev_path)], capture_output=True, text=True)
            self.assertEqual(res2.returncode, 0)
            self.assertEqual(res2.stdout.strip(), "OK")

if __name__ == '__main__':
    unittest.main()
