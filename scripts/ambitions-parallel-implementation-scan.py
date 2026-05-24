#!/usr/bin/env python3
"""Conservative parallel implementation concept scan."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/reports/intelligence-consolidation"
SCAN_ROOTS = ["Native/Ambitions", "Native/AmbitionsTests", "Sources", "AppUI/Sources", "docs", "prompts"]
CONCEPTS = {
    "Reality Meridian": ["Reality Meridian", "RealityMeridian", "DayTimelineRail"],
    "Start Here": ["Start Here", "Start here", "HeroStepPanel", "Hero Step Panel", "Recommended step", "Recommended move", "next best move", "best next move"],
    "Capture routing": ["Capture", "Captures", "SmartAttachment", "PlacementPreview", "CaptureSemanticExtraction", "CaptureRuntimeFactoring"],
    "Time": ["Time", "Plan", "LifeShape", "Schedule", "Availability", "Protected time"],
    "You": ["You", "Profile", "User System Profile", "Personal Runtime", "What Ambitions knows"],
    "Runtime": ["Private Life Runtime", "Recommendation", "Goal compiler", "Step candidate", "RuntimeLearningSignal", "Source Atlas"],
    "Proof/Receipt/Replay": ["Proof", "Receipt", "ReplayTrace", "Replay", "Closure", "Recovery"],
    "Design System": ["Living Chrome", "Graphite", "Liquid Glass", "Celestial", "Material", "Motion", "Haptic", "Accessibility"],
}


def iter_files() -> list[Path]:
    files: list[Path] = []
    for root in SCAN_ROOTS:
        base = ROOT / root
        if base.exists():
            files.extend(p for p in base.rglob("*") if p.is_file() and p.suffix in {".swift", ".md", ".yml", ".yaml", ".json"})
    return sorted(files)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    clusters = []
    for concept, terms in CONCEPTS.items():
        hits = []
        for path in iter_files():
            rel = str(path.relative_to(ROOT))
            text = path.read_text(encoding="utf-8", errors="replace")
            matched = [term for term in terms if re.search(re.escape(term), text, re.IGNORECASE)]
            if matched:
                hits.append({"path": rel, "terms": sorted(set(matched))})
        status = "YELLOW" if len({h["path"] for h in hits if h["path"].endswith(".swift")}) > 1 else "GREEN"
        clusters.append({"concept": concept, "status": status, "hit_count": len(hits), "hits": hits[:200], "note": "Multiple hits are duplicate risk, not proof of duplicate behavior."})
    overall = "YELLOW" if any(c["status"] == "YELLOW" for c in clusters) else "GREEN"
    payload = {"status": overall, "clusters": clusters}
    (OUT / "parallel-implementation-scan.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = ["# Parallel Implementation Scan", "", f"Status: {overall}", "", "| Concept | Status | Hit count | Highest-signal hits |", "| --- | --- | --- | --- |"]
    for cluster in clusters:
        sample = "<br>".join(f"`{h['path']}` ({', '.join(h['terms'])})" for h in cluster["hits"][:12])
        lines.append(f"| {cluster['concept']} | {cluster['status']} | {cluster['hit_count']} | {sample or '-'} |")
    (OUT / "parallel-implementation-scan.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"STATUS: {overall}")
    print(f"Report: {OUT / 'parallel-implementation-scan.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
