#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path
from datetime import datetime, timezone

OUT_DIR = Path("docs/governance/generated")
OUT = OUT_DIR / "symbol_ownership_map.json"
SWIFT_ROOTS = [Path("Sources"), Path("Native"), Path("App"), Path("Packages")]
SYMBOL_RE = re.compile(r"^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?(?:struct|class|enum|protocol|actor|extension)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
FUNC_RE = re.compile(r"^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)

OWNERS = [
    ("Today", re.compile(r"Today|Reality|StartHere|Rail|Closure", re.I)),
    ("Goals", re.compile(r"Goal|Constellation|MissionControl|LifePath", re.I)),
    ("Capture", re.compile(r"Capture|Atmosphere|Composer|Draft|Inbox", re.I)),
    ("Time", re.compile(r"Time|Plan|LifeShape|Schedule|Availability", re.I)),
    ("You", re.compile(r"Profile|You|UserSystem|Trust|Memory|Receipt", re.I)),
    ("PlatformKernel", re.compile(r"UnitOfWork|Ledger|Repository|Persistence|SwiftData|Command|Diagnostic|Privacy", re.I)),
    ("DesignSystem", re.compile(r"Token|Primitive|Panel|Chrome|Material|Motion|Haptic|Accessibility", re.I)),
]


def owner_for(path: str, symbol: str) -> str:
    text = f"{path} {symbol}"
    for owner, rx in OWNERS:
        if rx.search(text):
            return owner
    return "Unknown"


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    symbols = []
    for root in SWIFT_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*.swift"):
            body = path.read_text(encoding="utf-8", errors="replace")
            for m in SYMBOL_RE.finditer(body):
                name = m.group(1)
                symbols.append({"symbol": name, "kind": "type", "path": path.as_posix(), "owner": owner_for(path.as_posix(), name)})
            for m in FUNC_RE.finditer(body):
                name = m.group(1)
                symbols.append({"symbol": name, "kind": "function", "path": path.as_posix(), "owner": owner_for(path.as_posix(), name)})

    data = {"generated_at": datetime.now(timezone.utc).isoformat(), "symbol_count": len(symbols), "symbols": symbols}
    OUT.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
