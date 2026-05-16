import json
import subprocess
import tempfile
from pathlib import Path
import unittest

class TestOfficialAdapterContract(unittest.TestCase):
    def setUp(self):
        self.script = Path(__file__).parent.parent / "ambitions-official-adapter-contract.py"
        
    def test_mock_adapter_output(self):
        import sys
        res = subprocess.run([sys.executable, str(self.script)], capture_output=True, text=True, check=True)
        claims = json.loads(res.stdout)
        
        self.assertEqual(len(claims), 1)
        self.assertEqual(claims[0]["id"], "onet-claim-0")
        self.assertEqual(claims[0]["state"], "official")
        self.assertIn("src-onet-official", claims[0]["sourceIDs"])
        self.assertEqual(claims[0]["freshness"], "current")

if __name__ == '__main__':
    unittest.main()
