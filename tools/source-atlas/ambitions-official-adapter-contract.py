#!/usr/bin/env python3
"""Official Source Adapter Contract for Source Atlas Pack Factory."""

import abc
import json
from datetime import datetime
from typing import List, Dict, Any

class OfficialSourceAdapter(abc.ABC):
    """
    Base contract for all official source adapters (O*NET, BLS, Data.gov, etc.).
    These adapters run offline to generate Source Atlas Packs. They must never
    be included in the iOS app runtime.
    """
    
    @property
    @abc.abstractmethod
    def source_id(self) -> str:
        """The official SourceAtlasSourceRecord ID for this source."""
        pass

    @property
    @abc.abstractmethod
    def adapter_name(self) -> str:
        """Name of the adapter."""
        pass
        
    @abc.abstractmethod
    def fetch_raw_data(self) -> Any:
        """Fetch the raw data from the official source or a local cache."""
        pass
        
    @abc.abstractmethod
    def extract_claims(self, raw_data: Any) -> List[Dict[str, Any]]:
        """
        Extract claims from raw data.
        Must return explicit state='official', accurate freshness, and riskClass.
        Must not collapse into arbitrary confidence scores.
        """
        pass
        
    def generate_pack_claims(self) -> str:
        """Generate the claims section for a Source Atlas pack."""
        raw = self.fetch_raw_data()
        claims = self.extract_claims(raw)
        
        # Enforce contract rules
        for c in claims:
            if c.get("state") != "official":
                raise ValueError(f"Adapter {self.adapter_name} generated non-official claim.")
            if "id" not in c or "text" not in c:
                raise ValueError(f"Adapter {self.adapter_name} generated malformed claim.")
            if self.source_id not in c.get("sourceIDs", []):
                raise ValueError(f"Adapter {self.adapter_name} missing source_id in claim.")
                
        return json.dumps(claims, indent=2)

# Example Mock Adapter
class ONETMockAdapter(OfficialSourceAdapter):
    @property
    def source_id(self) -> str:
        return "src-onet-official"
        
    @property
    def adapter_name(self) -> str:
        return "ONET"
        
    def fetch_raw_data(self) -> Any:
        return [{"task": "Analyze data", "importance": 90}]
        
    def extract_claims(self, raw_data: Any) -> List[Dict[str, Any]]:
        claims = []
        for idx, item in enumerate(raw_data):
            claims.append({
                "id": f"onet-claim-{idx}",
                "text": f"Task: {item['task']} (Importance: {item['importance']})",
                "state": "official",
                "freshness": "current",
                "riskClass": "low",
                "sourceIDs": [self.source_id],
                "reviewRequired": False
            })
        return claims

if __name__ == "__main__":
    adapter = ONETMockAdapter()
    print(adapter.generate_pack_claims())
