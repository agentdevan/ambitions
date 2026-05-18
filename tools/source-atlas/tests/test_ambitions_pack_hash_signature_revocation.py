import json
import subprocess
import sys
import tempfile
from pathlib import Path
import unittest


class TestPackHashSignatureRevocation(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-pack-crypto.py"

    def _write_pack(self, base: Path, pack: dict) -> Path:
        pack_path = base / "pack.json"
        pack_path.write_text(json.dumps(pack))
        return pack_path

    def test_valid_hash_and_non_production_signature_status(self):
        pack = {
            "id": "hash-pack",
            "metadata": {
                "last_known_good_hash": "safe-hash",
                "last_known_good_pack": "pack-safe.json",
            },
            "claims": [{"id": "c1", "state": "official"}],
        }

        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            pack_path = self._write_pack(base, pack)

            hash_result = subprocess.run(
                [sys.executable, str(self.script), "hash", "--pack", str(pack_path)],
                capture_output=True,
                text=True,
                check=True,
            )
            pack_hash = hash_result.stdout.strip()

            sign_result = subprocess.run(
                [sys.executable, str(self.script), "sign", "--pack", str(pack_path)],
                capture_output=True,
                text=True,
                check=True,
            )
            sign_data = json.loads(sign_result.stdout)

            self.assertEqual(len(pack_hash), 64)
            self.assertEqual(sign_data["sha256"], pack_hash)
            self.assertEqual(sign_data["rollback_pointer"], "safe-hash")
            self.assertEqual(sign_data["last_known_good_pack"], "pack-safe.json")
            self.assertEqual(sign_data["signature_status"], "mock-non-production")
            self.assertIn("no production signing", sign_data["signature_claim"])

    def test_invalid_packs_are_quarantined_and_metadata_survives(self):
        pack = {
            "id": "q-pack",
            "metadata": {
                "last_known_good_hash": "keep-safe",
                "last_known_good_pack": "pack-safe.json",
            },
            "claims": [],
        }

        with tempfile.TemporaryDirectory() as tmpdir:
            base = Path(tmpdir)
            quarantine_dir = base / "quarantine"
            pack_path = self._write_pack(base, pack)

            valid_hash = subprocess.run(
                [sys.executable, str(self.script), "hash", "--pack", str(pack_path)],
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()

            # Hash mismatch quarantine.
            mismatch_result = subprocess.run(
                [
                    sys.executable,
                    str(self.script),
                    "validate",
                    "--pack",
                    str(pack_path),
                    "--expected-hash",
                    "wrong",
                    "--quarantine-dir",
                    str(quarantine_dir),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(mismatch_result.returncode, 1)
            self.assertFalse(pack_path.exists())
            mismatch_quarantine = quarantine_dir / "pack.json.hash_mismatch"
            self.assertTrue(mismatch_quarantine.exists())
            mismatch_data = json.loads(mismatch_quarantine.read_text())
            self.assertEqual(mismatch_data["metadata"]["last_known_good_hash"], "keep-safe")
            self.assertEqual(mismatch_data["metadata"]["last_known_good_pack"], "pack-safe.json")

            # Corrupt quarantine.
            pack_path.write_text("{ invalid json")
            corrupt_result = subprocess.run(
                [
                    sys.executable,
                    str(self.script),
                    "validate",
                    "--pack",
                    str(pack_path),
                    "--quarantine-dir",
                    str(quarantine_dir),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(corrupt_result.returncode, 1)
            self.assertFalse(pack_path.exists())
            self.assertTrue((quarantine_dir / "pack.json.corrupt").exists())

            # Revocation quarantine.
            pack_path.write_text(json.dumps(pack))
            revocation_path = base / "revocations.json"
            revocation_path.write_text(json.dumps({"revoked_pack_ids": ["q-pack"]}))
            revoked_result = subprocess.run(
                [
                    sys.executable,
                    str(self.script),
                    "validate",
                    "--pack",
                    str(pack_path),
                    "--expected-hash",
                    valid_hash,
                    "--revocation-list",
                    str(revocation_path),
                    "--quarantine-dir",
                    str(quarantine_dir),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(revoked_result.returncode, 1)
            self.assertFalse(pack_path.exists())
            self.assertTrue((quarantine_dir / "pack.json.revoked").exists())


if __name__ == "__main__":
    unittest.main()
