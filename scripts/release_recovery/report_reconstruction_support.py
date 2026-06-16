#!/usr/bin/env python3
"""Shared helpers for Ambitions report reconstruction batches."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ARTIFACT_ROOT = ROOT / "artifacts" / "release-recovery"


def path(rel: str) -> Path:
    return ROOT / rel


def read(rel: str) -> str:
    return path(rel).read_text(encoding="utf-8")


def write(rel: str, text: str) -> None:
    target = path(rel)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")


def replace_required(text: str, old: str, new: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise RuntimeError(f"required anchor missing: {old[:120]}")
    return text.replace(old, new, 1)


def replace_all(text: str, replacements: dict[str, str]) -> str:
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def write_proof(name: str, body: str) -> None:
    ARTIFACT_ROOT.mkdir(parents=True, exist_ok=True)
    proof = ARTIFACT_ROOT / name
    proof.write_text(body.rstrip() + "\n", encoding="utf-8")


def require_markers(rel: str, markers: list[str]) -> None:
    text = read(rel)
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise RuntimeError(f"{rel} missing markers: {missing}")


def forbid_markers(rel: str, markers: list[str]) -> None:
    text = read(rel)
    found = [marker for marker in markers if marker in text]
    if found:
        raise RuntimeError(f"{rel} still contains forbidden markers: {found}")


def prepend_once(rel: str, marker: str, block: str) -> None:
    text = read(rel)
    if marker in text:
        return
    write(rel, block.rstrip() + "\n\n" + text)


def insert_before(rel: str, anchor: str, block: str, marker: str) -> None:
    text = read(rel)
    if marker in text:
        return
    if anchor not in text:
        raise RuntimeError(f"insert anchor missing in {rel}: {anchor[:120]}")
    write(rel, text.replace(anchor, block.rstrip() + "\n\n" + anchor, 1))


def append_once(rel: str, marker: str, block: str) -> None:
    text = read(rel)
    if marker in text:
        return
    write(rel, text.rstrip() + "\n\n" + block.rstrip() + "\n")
