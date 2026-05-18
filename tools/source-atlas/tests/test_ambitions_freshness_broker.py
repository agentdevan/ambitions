import json
import subprocess
import tempfile
from pathlib import Path
import unittest

class TestFreshnessBroker(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-freshness-broker.py"

    def run_broker(self, diff_output: dict, version_id: str = "v1.0.0") -> dict:
        with tempfile.TemporaryDirectory() as tmpdir:
            diff_path = Path(tmpdir) / "diff.json"
            diff_path.write_text(json.dumps(diff_output))

            out_path = Path(tmpdir) / "freshness.json"

            import sys
            subprocess.run([
                sys.executable,
                str(self.script),
                "--version-id",
                version_id,
                "--diff-files",
                str(diff_path),
                "--output",
                str(out_path),
            ], capture_output=True, text=True, check=True)

            return json.loads(out_path.read_text())

    def test_build_manifest_preserves_distinct_state_buckets(self):
        diff_output = {
            "packID": "pack-1",
            "currentSHA256": "abcdef",
            "currentSignature": "mock-sig",
            "rollbackPointers": {"old_hash": "abcdef"},
            "changedClaimIDs": ["c1", "c2"],
            "flags": {
                "unknown": ["c0"],
                "sourceNeeded": ["c1"],
                "stale": ["c2"],
                "contradicted": ["c3"],
                "revoked": ["c4"],
                "locallyProven": ["c5"],
            }
        }

        manifest = self.run_broker(diff_output)

        self.assertEqual(manifest["schemaVersion"], 1)
        self.assertEqual(manifest["versionID"], "v1.0.0")
        self.assertIn("publishedAt", manifest)
        self.assertEqual(len(manifest["packIndex"]), 1)
        self.assertEqual(manifest["packIndex"][0]["packID"], "pack-1")
        self.assertEqual(
            manifest["packIndex"][0]["claimStateBuckets"],
            [
                {"state": "unknown", "claimIDs": ["c0"]},
                {"state": "source_needed", "claimIDs": ["c1"]},
                {"state": "stale", "claimIDs": ["c2"]},
                {"state": "contradicted", "claimIDs": ["c3"]},
                {"state": "revoked", "claimIDs": ["c4"]},
                {"state": "locally_proven", "claimIDs": ["c5"]},
            ],
        )
        self.assertEqual(
            manifest["globalClaimStateBuckets"],
            [
                {"state": "unknown", "claimIDs": ["c0"]},
                {"state": "source_needed", "claimIDs": ["c1"]},
                {"state": "stale", "claimIDs": ["c2"]},
                {"state": "contradicted", "claimIDs": ["c3"]},
                {"state": "revoked", "claimIDs": ["c4"]},
                {"state": "locally_proven", "claimIDs": ["c5"]},
            ],
        )
        self.assertNotIn("globalRevocationList", manifest)
        self.assertNotIn("globalStaleClaims", manifest)
        self.assertNotIn("staleClaimIDs", manifest["packIndex"][0])
        self.assertNotIn("revokedClaimIDs", manifest["packIndex"][0])

    def test_build_manifest_accepts_legacy_snake_case_state_flags(self):
        diff_output = {
            "packID": "pack-legacy",
            "currentSHA256": "abcdef",
            "currentSignature": "sig",
            "flags": {
                "source_needed": ["c-source-needed"],
                "locally_proven": ["c-locally-proven"],
            },
        }

        manifest = self.run_broker(diff_output)

        self.assertEqual(
            manifest["packIndex"][0]["claimStateBuckets"],
            [
                {"state": "source_needed", "claimIDs": ["c-source-needed"]},
                {"state": "locally_proven", "claimIDs": ["c-locally-proven"]},
            ],
        )

    def test_build_manifest_keeps_global_state_buckets_in_contract_order(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            stale_path = Path(tmpdir) / "stale.json"
            stale_path.write_text(json.dumps({
                "packID": "stale-pack",
                "flags": {"stale": ["c-stale"]},
            }))

            unknown_path = Path(tmpdir) / "unknown.json"
            unknown_path.write_text(json.dumps({
                "packID": "unknown-pack",
                "flags": {"unknown": ["c-unknown"]},
            }))

            out_path = Path(tmpdir) / "freshness.json"

            import sys
            subprocess.run([
                sys.executable,
                str(self.script),
                "--version-id",
                "v1.0.0",
                "--diff-files",
                str(stale_path),
                str(unknown_path),
                "--output",
                str(out_path),
            ], capture_output=True, text=True, check=True)

            manifest = json.loads(out_path.read_text())

        self.assertEqual(
            manifest["globalClaimStateBuckets"],
            [
                {"state": "unknown", "claimIDs": ["c-unknown"]},
                {"state": "stale", "claimIDs": ["c-stale"]},
            ],
        )

    def test_build_manifest_ignores_confidence_or_official_current_claim_collapses(self):
        diff_output = {
            "packID": "pack-2",
            "currentSHA256": "123456",
            "currentSignature": "sig-2",
            "flags": {
                "official": ["c-official"],
                "current": ["c-current"],
                "confidence": ["c-confidence"],
                "unknown": ["c-unknown"],
            },
        }

        manifest = self.run_broker(diff_output, version_id="v2.0.0")

        self.assertEqual(
            manifest["packIndex"][0]["claimStateBuckets"],
            [{"state": "unknown", "claimIDs": ["c-unknown"]}],
        )
        self.assertEqual(
            manifest["globalClaimStateBuckets"],
            [{"state": "unknown", "claimIDs": ["c-unknown"]}],
        )
        self.assertNotIn("c-official", json.dumps(manifest))
        self.assertNotIn("c-current", json.dumps(manifest))
        self.assertNotIn("c-confidence", json.dumps(manifest))

if __name__ == '__main__':
    unittest.main()
