from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import ast
import json
import re
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/canon/frontend"
REPORT_DIR = ROOT / "build/reports"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def normalize_line(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip().lower())


def contains_any(text: str, needles: Iterable[str]) -> bool:
    lowered = text.lower()
    return any(needle.lower() in lowered for needle in needles)


def load_json_like(path: Path) -> Any:
    text = read_text(path)
    return json.loads(text)


def _parse_scalar(value: str) -> Any:
    value = value.strip()
    if not value:
        return ""
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        parts = [part.strip() for part in inner.split(",")]
        return [_parse_scalar(part) for part in parts]
    if (value.startswith("'") and value.endswith("'")) or (value.startswith('"') and value.endswith('"')):
        try:
            return ast.literal_eval(value)
        except Exception:
            return value[1:-1]
    if value in {"true", "false"}:
        return value == "true"
    if value == "null":
        return None
    return value


def load_priority_registry() -> dict[str, Any]:
    path = BASE / "trace/VISUAL_100_PRIORITY_RECIPE_REGISTRY.yaml"
    lines = read_text(path).splitlines()
    data: dict[str, Any] = {"generated_from_batch": "", "priority_recipes": []}
    idx = 0
    while idx < len(lines):
        line = lines[idx].rstrip()
        if not line.strip():
            idx += 1
            continue
        if line.startswith("generated_from_batch:"):
            data["generated_from_batch"] = line.split(":", 1)[1].strip()
            idx += 1
            continue
        if line.strip() == "priority_recipes:":
            idx += 1
            while idx < len(lines):
                raw = lines[idx].rstrip()
                if not raw.strip():
                    idx += 1
                    continue
                if not raw.startswith("  - "):
                    idx += 1
                    continue
                item: dict[str, Any] = {}
                first = raw.strip()[2:].strip()
                if first:
                    key, value = first.split(":", 1)
                    item[key.strip()] = _parse_scalar(value)
                idx += 1
                while idx < len(lines):
                    sub = lines[idx].rstrip()
                    if not sub.strip():
                        idx += 1
                        continue
                    if sub.startswith("  - "):
                        break
                    if not sub.startswith("    "):
                        break
                    key, value = sub.strip().split(":", 1)
                    item[key.strip()] = _parse_scalar(value)
                    idx += 1
                data["priority_recipes"].append(item)
                continue
        idx += 1
    return data


def p0_registry_entries() -> list[dict[str, Any]]:
    return [entry for entry in load_priority_registry().get("priority_recipes", []) if entry.get("tier") == "P0"]


def registry_entries_by_tier(tier: str | None = None) -> list[dict[str, Any]]:
    entries = load_priority_registry().get("priority_recipes", [])
    if tier is None:
        return entries
    return [entry for entry in entries if entry.get("tier") == tier]


def registry_recipe_paths(tier: str | None = None) -> list[Path]:
    return [ROOT / str(entry["recipe_path"]) for entry in registry_entries_by_tier(tier)]


def recipe_text_by_entry(entry: dict[str, Any]) -> str:
    return read_text(ROOT / str(entry["recipe_path"]))


def has_heading(text: str, heading: str) -> bool:
    target = normalize_line(heading)
    for line in text.splitlines():
        if normalize_line(line) == normalize_line(f"## {heading}"):
            return True
        if normalize_line(line) == target:
            return True
    return False


def text_contains_all(text: str, terms: Iterable[str]) -> bool:
    lowered = text.lower()
    return all(term.lower() in lowered for term in terms)


def text_contains_any(text: str, terms: Iterable[str]) -> bool:
    lowered = text.lower()
    return any(term.lower() in lowered for term in terms)


def count_file_hits(paths: Iterable[Path], predicate) -> int:
    count = 0
    for path in paths:
        if predicate(read_text(path)):
            count += 1
    return count


def load_flag_resolution_matrix() -> dict[str, Any]:
    path = BASE / "trace/VISUAL_100_FLAG_RESOLUTION_MATRIX.yaml"
    lines = read_text(path).splitlines()
    data: dict[str, Any] = {"generated_from_batch": "", "flags": []}
    idx = 0
    while idx < len(lines):
        line = lines[idx].rstrip()
        if not line.strip():
            idx += 1
            continue
        if line.startswith("generated_from_batch:"):
            data["generated_from_batch"] = line.split(":", 1)[1].strip()
            idx += 1
            continue
        if line.strip() == "flags:":
            idx += 1
            while idx < len(lines):
                raw = lines[idx].rstrip()
                if not raw.strip():
                    idx += 1
                    continue
                if not raw.startswith("  - "):
                    idx += 1
                    continue
                item: dict[str, Any] = {}
                first = raw.strip()[2:].strip()
                if first:
                    key, value = first.split(":", 1)
                    item[key.strip()] = _parse_scalar(value)
                idx += 1
                while idx < len(lines):
                    sub = lines[idx].rstrip()
                    if not sub.strip():
                        idx += 1
                        continue
                    if sub.startswith("  - "):
                        break
                    if not sub.startswith("    "):
                        break
                    key, value = sub.strip().split(":", 1)
                    item[key.strip()] = _parse_scalar(value)
                    idx += 1
                data["flags"].append(item)
                continue
        idx += 1
    return data


def load_gate_matrix() -> dict[str, Any]:
    path = BASE / "gates/NORTH_STAR_100_MEASURABLE_GATE_MATRIX.yaml"
    lines = read_text(path).splitlines()
    data: dict[str, Any] = {"gates": {}}
    idx = 0
    while idx < len(lines):
        line = lines[idx].rstrip()
        if not line.strip():
            idx += 1
            continue
        if line.strip() == "gates:":
            idx += 1
            while idx < len(lines):
                raw = lines[idx].rstrip()
                if not raw.strip():
                    idx += 1
                    continue
                if not raw.startswith("  "):
                    idx += 1
                    continue
                if raw.startswith("  ") and raw.endswith(":") and not raw.startswith("    "):
                    gate_name = raw.strip()[:-1]
                    gate_data: dict[str, Any] = {}
                    idx += 1
                    while idx < len(lines):
                        sub = lines[idx].rstrip()
                        if not sub.strip():
                            idx += 1
                            continue
                        if sub.startswith("  ") and not sub.startswith("    "):
                            break
                        if not sub.startswith("    "):
                            break
                        key, value = sub.strip().split(":", 1)
                        gate_data[key.strip()] = _parse_scalar(value)
                        idx += 1
                    data["gates"][gate_name] = gate_data
                    continue
                idx += 1
        else:
            idx += 1
    return data


def scan_frontend_text_files() -> list[Path]:
    paths = []
    for suffix in ("*.md", "*.yaml"):
        paths.extend(sorted(BASE.rglob(suffix)))
    return [path for path in paths if path.is_file()]


def append_block_if_missing(path: Path, marker: str, block: str) -> bool:
    text = read_text(path)
    if marker in text:
        return False
    if not text.endswith("\n"):
        text += "\n"
    text += "\n" + block.strip() + "\n"
    write_text(path, text)
    return True


def markdown_table(rows: list[list[str]]) -> str:
    if not rows:
        return ""
    widths = [max(len(row[i]) for row in rows) for i in range(len(rows[0]))]
    out = []
    out.append("| " + " | ".join(rows[0][i].ljust(widths[i]) for i in range(len(widths))) + " |")
    out.append("| " + " | ".join("---".ljust(widths[i]) for i in range(len(widths))) + " |")
    for row in rows[1:]:
        out.append("| " + " | ".join(row[i].ljust(widths[i]) for i in range(len(widths))) + " |")
    return "\n".join(out)
