import json
import subprocess
import tempfile
from pathlib import Path
import unittest

class TestPackDiff(unittest.TestCase):
    def test_diff(self):
        old_pack = {
            "claims": [
                {"id": "claim-1", "text": "Old text", "state": "official", "freshness": "current", "sourceIDs": ["source-1"]},
                {"id": "claim-2", "text": "Will be removed", "state": "official", "freshness": "current"}
            ],
            "requirements": [
                {"id": "req-1", "claimID": "claim-1", "sourceState": "official", "freshnessState": "current"},
                {"id": "req-2", "claimID": "claim-2"}
            ]
        }
        
        new_pack = {
            "claims": [
                {"id": "claim-1", "text": "New text", "state": "stale", "freshness": "stale_critical", "sourceIDs": ["source-1"]},
                {"id": "claim-3", "text": "Added claim", "state": "revoked", "freshness": "unknown"}
            ],
            "requirements": [
                {"id": "req-1", "claimID": "claim-1", "sourceState": "stale", "freshnessState": "stale"},
                {"id": "req-3", "claimID": "claim-3"}
            ]
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            old_path = Path(tmpdir) / "old.json"
            new_path = Path(tmpdir) / "new.json"
            
            old_path.write_text(json.dumps(old_pack))
            new_path.write_text(json.dumps(new_pack))
            
            script = Path(__file__).parent.parent / "ambitions-pack-diff.py"
            result = subprocess.run([str(script), str(old_path), str(new_path)], capture_output=True, text=True, check=True)
            
            output = json.loads(result.stdout)
            
            self.assertEqual(sorted(output["changedClaimIDs"]), ["claim-1", "claim-2", "claim-3"])
            self.assertIn("claim-1", output["flags"]["stale"])
            self.assertIn("claim-3", output["flags"]["revoked"])
            self.assertIn("claim-3", output["flags"]["unknown"])
            self.assertEqual(sorted(output["impactedRequirementIDs"]), ["req-1", "req-3"])

if __name__ == '__main__':
    unittest.main()
