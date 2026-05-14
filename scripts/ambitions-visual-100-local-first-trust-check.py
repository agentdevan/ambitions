#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import p0_registry_entries, recipe_text_by_entry, section_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-local-first-trust.json"


def main() -> int:
    missing = []
    for entry in p0_registry_entries():
        text = recipe_text_by_entry(entry).lower()
        surface_id = entry.get("surface_id")
        for marker in ["local runtime", "user-set", "learned", "suggested", "reset", "forget", "source truth", "trust boundary"]:
            if marker not in text:
                missing.append({"surface_id": surface_id, "marker": marker})
        local_runtime = section_text(recipe_text_by_entry(entry), "Source / Trust Behavior")
        if not local_runtime:
            local_runtime = section_text(recipe_text_by_entry(entry), "Local Runtime")
        if not local_runtime or "local" not in local_runtime.lower():
            missing.append({"surface_id": surface_id, "marker": "local runtime section"})
        if "user-set" not in text or "learned" not in text or "suggested" not in text:
            missing.append({"surface_id": surface_id, "marker": "user-set learned suggested"})
        if "reset" not in text or "forget" not in text:
            missing.append({"surface_id": surface_id, "marker": "reset forget"})
        if "llm" in text and "external" in text and "no external" not in text:
            missing.append({"surface_id": surface_id, "marker": "external llm dependency"})
    status = "green" if not missing else "red"
    write_json(REPORT, {"missing": missing, "status": status, "p0_count": len(p0_registry_entries())})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
