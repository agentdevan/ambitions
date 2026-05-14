#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

from ambitions_visual_100_common import append_block_if_missing, load_priority_registry, write_json


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "build/reports/visual-100-p0-recipe-upgrade.json"


def build_appendix(entry: dict[str, object]) -> str:
    surface_name = str(entry.get("surface_name", "Surface"))
    destination = str(entry.get("destination", ""))
    primary_object = str(entry.get("primary_object", ""))
    source_status = str(entry.get("source_link_status", ""))
    recipe_path = str(entry.get("recipe_path", ""))
    return f"""
## P0 Proof Appendix

### Source Link Status

{source_status}

### Implementation Proof Boundary

This recipe is final-state design canon for {surface_name} in {destination}. It does not prove implementation or release readiness.

### Good / Bad Example

- Good: {surface_name} stays attached to {primary_object}, with trust, proof, receipt, and recovery visible.
- Bad: {surface_name} turns into a generic productivity pattern or hides its trust seam.

### Acceptance Checklist

- the surface stays anchored to {primary_object}
- the source or trust seam is explicit
- the proof or receipt path is explicit
- the correction or recovery path is explicit
- the surface does not read as a generic dashboard, task list, or calendar clone

### Notes

- recipe path: {recipe_path}
- source-link debt class: {source_status}
""".strip()


def build_canon_appendix(entry: dict[str, object]) -> str:
    surface_name = str(entry.get("surface_name", "Surface"))
    destination = str(entry.get("destination", ""))
    primary_object = str(entry.get("primary_object", ""))
    return f"""
## P0 Canon Appendix

### Source / Trust Behavior

{surface_name} keeps its trust seam attached to {primary_object} and {destination}.

### Proof / Receipt Behavior

The surface keeps proof and receipt visible at the object edge instead of hiding them in a generic toast or feed.

### Transaction Behavior

Meaningful changes must be previewed, committed, receipted, and recoverable.

### VoiceOver Order

Object, state, source, proof, action, recovery.

### Dynamic Type Behavior

The dominant object and primary action must survive large text.

### Reduce Motion Behavior

Static before / after summaries replace motion meaning.

### Reduce Transparency Behavior

Opaque graphite layers must preserve state when blur is reduced.

### Increase Contrast Behavior

State boundaries and recovery affordances strengthen.

### Differentiate Without Color Behavior

Shape, label, spacing, and structure carry meaning without color.

### ADHD Density Law

One dominant action at rest. One safe recovery path always visible.

### Native iPhone Believability Requirements

The surface stays thumb-reachable, restrained, and native rather than dashboard-like.

### Anti-Generic Red Flags

- generic dashboard
- task list clone
- calendar clone
- chatbot persona

### Forbidden Interpretations

- implementation proof
- release proof
- screenshot proof
- production readiness

### Acceptance Checklist

- the object is still recognizable without labels
- the source / proof seam is visible
- the recovery path is visible
- the surface still reads as the named object, not a generic productivity app
""".strip()


def build_local_runtime_appendix(entry: dict[str, object]) -> str:
    surface_name = str(entry.get("surface_name", "Surface"))
    destination = str(entry.get("destination", ""))
    return f"""
## P0 Local Runtime Appendix

### Local Runtime

{surface_name} exposes local runtime behavior as inspectable state, not hidden automation.

### User-Set / Learned / Suggested

The surface distinguishes user-set truth, learned guidance, and suggested defaults before any commitment.

### Reset / Forget

{surface_name} previews local reset or forget consequences before the user commits to them.

### Trust Boundary

{destination} remains local-first unless the active truth explicitly says otherwise.

### Acceptance Checklist

- local runtime is visible
- user-set, learned, and suggested states are distinguishable
- reset and forget are previewed
- automation remains inspectable
""".strip()


def main() -> int:
    registry = load_priority_registry()
    modified = []
    skipped = []
    for entry in registry.get("priority_recipes", []):
        if entry.get("tier") != "P0":
            continue
        recipe_path = ROOT / str(entry["recipe_path"])
        appendix = build_appendix(entry)
        changed = append_block_if_missing(recipe_path, "## P0 Proof Appendix", appendix)
        changed = append_block_if_missing(recipe_path, "## P0 Canon Appendix", build_canon_appendix(entry)) or changed
        changed = append_block_if_missing(recipe_path, "## P0 Local Runtime Appendix", build_local_runtime_appendix(entry)) or changed
        if changed:
            modified.append(str(recipe_path.relative_to(ROOT)))
        else:
            skipped.append(str(recipe_path.relative_to(ROOT)))

    payload = {
        "modified_count": len(modified),
        "skipped_count": len(skipped),
        "modified_files": modified,
        "skipped_files": skipped,
    }
    write_json(REPORT, payload)
    print(f"modified {len(modified)} P0 recipes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
