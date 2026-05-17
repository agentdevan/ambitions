#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path
from datetime import datetime, timezone

ROOTS = [Path("Sources"), Path("Native"), Path("App"), Path("Packages"), Path("scripts")]
OUT = Path("docs/governance/generated/semantic_code_graph.json")
TYPE_RE = re.compile(r"^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?(?:struct|class|enum|protocol|actor)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
FUNC_RE = re.compile(r"^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
IMPORT_RE = re.compile(r"^\s*import\s+([A-Za-z0-9_]+)", re.M)
CALL_RE = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def owner(path: str) -> str:
    rules = [
        ("Today", ["Today", "Reality", "Rail", "StartHere", "Closure"]),
        ("Goals", ["Goal", "Constellation", "Mission", "LifePath"]),
        ("Capture", ["Capture", "Draft", "Composer", "Atmosphere"]),
        ("Time", ["Time", "Plan", "LifeShape", "Schedule", "Availability"]),
        ("You", ["Profile", "You", "Memory", "Trust", "Receipt"]),
        ("PlatformKernel", ["Persistence", "Repository", "Ledger", "UnitOfWork", "Command"]),
        ("Governance", ["governance", "ambitions-"])
    ]
    hay = path.lower()
    for name, keys in rules:
        if any(k.lower() in hay for k in keys):
            return name
    return "Unknown"


def main() -> int:
    nodes = []
    edges = []
    for root in ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix not in {".swift", ".py", ".sh"}:
                continue
            body = read(path)
            rel = path.as_posix()
            file_id = f"file:{rel}"
            nodes.append({"id": file_id, "kind": "file", "path": rel, "owner": owner(rel)})
            for imp in IMPORT_RE.findall(body):
                edges.append({"from": file_id, "to": f"module:{imp}", "kind": "imports"})
            for sym in TYPE_RE.findall(body):
                sid = f"symbol:{sym}"
                nodes.append({"id": sid, "kind": "type", "name": sym, "path": rel, "owner": owner(rel)})
                edges.append({"from": file_id, "to": sid, "kind": "declares"})
            for fn in FUNC_RE.findall(body):
                sid = f"function:{fn}"
                nodes.append({"id": sid, "kind": "function", "name": fn, "path": rel, "owner": owner(rel)})
                edges.append({"from": file_id, "to": sid, "kind": "declares"})
            for call in set(CALL_RE.findall(body)):
                if call not in {"if", "for", "while", "switch", "return"}:
                    edges.append({"from": file_id, "to": f"call:{call}", "kind": "references_call"})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"generated_at": datetime.now(timezone.utc).isoformat(), "nodes": nodes, "edges": edges}, indent=2, sort_keys=True) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
