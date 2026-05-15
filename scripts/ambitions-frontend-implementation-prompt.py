#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from ambitions_frontend_authority_common import (
    ROOT,
    REPORT_DIR,
    combined_surface_payload,
    prompt_paths,
    write_json,
    write_text,
)
from ambitions_signature_visual_instruments import enrich_packet_with_instrument


RUNNER_HEADER = """<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
"""


def _bullets(items: list[object]) -> list[str]:
    return [f"- `{item}`" for item in items] if items else ["- None"]


def render_prompt(packet: dict[str, object], batch_id: str) -> str:
    packet_path = REPORT_DIR / "frontend-authority-packets" / f"{packet['surface_id']}.md"
    preflight_path = REPORT_DIR / "frontend-authority-preflight" / f"{packet['surface_id']}.md"
    instrument = packet.get("signature_visual_instrument", {}) if isinstance(packet.get("signature_visual_instrument"), dict) else {}
    allowed_sources = _bullets(packet.get("source_candidates", []))
    token_lines = _bullets(packet.get("tokens", {}).get("design_tokens", [])) if isinstance(packet.get("tokens"), dict) else ["- None"]
    contract_lines = _bullets(packet.get("contracts", []))
    shared_primitives = _bullets(instrument.get("shared_instrument_primitives", []))
    future_files = _bullets(instrument.get("future_visual_object_source_files", []))
    techniques = _bullets(instrument.get("swiftui_technique_candidates", []))
    regressions = _bullets(instrument.get("forbidden_visual_regressions", []))
    lines = [
        RUNNER_HEADER.rstrip(),
        f"# Frontend Implementation Prompt: {batch_id}",
        "",
        f"Batch ID: `{batch_id}`",
        f"Surface ID: `{packet['surface_id']}`",
        f"Objective: Implement only within the declared source scope for {packet['surface_name']}.",
        f"Packet path: `{packet_path.relative_to(ROOT)}`",
        f"Preflight path: `{preflight_path.relative_to(ROOT)}`",
        "",
        "## Active Source Truth to Inspect",
        "- `docs/truth/README.md`",
        "- `docs/truth/PRODUCT_DESIGN_TRUTH.md`",
        "- `docs/truth/IMPLEMENTATION_TRUTH.md`",
        "- `docs/truth/RELEASE_TRUTH.md`",
        "- `docs/truth/CODEX_PROCESS_TRUTH.md`",
        "- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`",
        "- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`",
        "- `frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md`",
        "- `frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`",
        f"- `{packet['recipe_path']}`",
        f"- `{packet.get('surface_bible_path')}`" if packet.get("surface_bible_path") else "- `surface bible unavailable`",
        "",
        "## Signature Visual Instrument Requirements",
        f"- owning instrument id: `{instrument.get('signature_instrument_id') or 'shared_or_none'}`",
        f"- owning instrument name: `{instrument.get('signature_instrument_name') or 'Shared primitive / no owning instrument'}`",
        f"- instrument required: `{instrument.get('instrument_required')}`",
        f"- instrument implementation status before this batch: `{instrument.get('instrument_implementation_status')}`",
        f"- guidance: {instrument.get('dedicated_visual_object_guidance')}",
        "",
        "### Shared Instrument Primitives",
        *shared_primitives,
        "",
        "### Future Dedicated Visual Object Files",
        *future_files,
        "",
        "### Native SwiftUI Technique Candidates",
        *techniques,
        "",
        "### Visual Regression Guardrails",
        *regressions,
        "",
        "## Instrument Implementation Rules",
        "- Do not implement this surface as a generic card stack, static form, or list-only screen when it owns a signature instrument.",
        "- Prefer a dedicated SwiftUI visual-object component file for high-end instruments instead of burying the visual object inside the root screen.",
        "- Back the instrument with typed ViewState and preview fixtures.",
        "- Use AmbitionTheme and generated tokens; do not introduce hardcoded visual values when tokens exist.",
        "- Synthesize the instrument principles from the encyclopedia. Do not copy external app layouts, wording, brand marks, or mechanics.",
        "",
        "## Allowed Source Targets",
        *allowed_sources,
        "",
        "## Forbidden Scope",
        "- unrelated surfaces",
        "- top-level IA changes",
        "- Plan as an active destination",
        "- chatbot UI",
        "- generic dashboard/card/task-list fallback",
        "- persistence changes",
        "- routing changes",
        "- release or device proof claims",
        "",
        "## Source Binding Requirements",
        "- Use only the source files declared by the packet or explicitly extend scope with a reason in the receipt.",
        "- Do not treat packet generation as implementation proof.",
        "- Record instrument source binding status in the implementation receipt.",
        "",
        "## Token and Contract Requirements",
        *token_lines,
        *contract_lines,
        "",
        "## Scenario Proof Requirements",
        "- Preserve the required scenario coverage for the surface.",
        "- Do not claim proof without the matching receipt and preview/proof artifacts.",
        "",
        "## Interaction Grammar Requirements",
        "- Preserve the object-first interaction grammar.",
        "- Keep visible alternatives for source, proof, receipt, and recovery.",
        "",
        "## Accessibility Requirements",
        "- Dynamic Type proof required where the surface changes layout.",
        "- Reduce Motion proof required where motion exists.",
        "- VoiceOver proof required for the object/state/action order.",
        "- No color-only state meaning.",
        "",
        "## Visual Proof Requirements",
        "- Use previews or screenshots only when the surface implementation actually changes.",
        "- Do not claim implementation proof from generated docs alone.",
        "",
        "## Implementation Receipt Requirements",
        "- Emit a receipt only after the changed files, proof, and drift results are known.",
        "- Record known gaps explicitly.",
        "- Include signature_instrument_id, shared_instrument_primitives, visual_object_source_file, and instrument_implementation_status.",
        "",
        "## Drift Check Requirements",
        "- Run the frontend drift checker after the change set lands.",
        "- Keep the active IA labels exact.",
        "- Ensure the instrument-owned surface does not regress to generic cards/lists/forms.",
        "",
        "## Validation Commands",
        "- `git diff --check`",
        "- `python3 scripts/ambitions-frontend-authority-preflight.py --surface {surface}`".format(surface=packet["surface_id"]),
        "- `python3 scripts/ambitions-signature-visual-instruments-check.py`",
        "- `python3 scripts/ambitions-frontend-source-bindings.py`",
        "- `python3 scripts/ambitions-frontend-drift-check.py`",
        "- `python3 scripts/ambitions-frontend-implementation-dashboard.py`",
        "- `python3 scripts/ambitions-frontend-next-surface-queue.py`",
        "- `python3 scripts/ambitions-frontend-receipt-check.py`",
        "- `python3 scripts/ambitions-frontend-proof-contract-check.py`",
        "",
        "## Hard Red Conditions",
        "- Do not invent layout outside the packet.",
        "- Do not touch unrelated surfaces.",
        "- Do not add chatbot UI.",
        "- Do not reintroduce Plan as a top-level destination.",
        "- Do not claim implementation, accessibility, device, or release proof without evidence.",
        "- Do not ship a generic card/list-only surface when this packet declares an owning signature instrument.",
        "",
        "## Rollback Expectations",
        "- Restore only the files touched by the batch.",
        "- Remove any generated receipt or report that does not match the committed source.",
        "",
        "## Final Response Format",
        "- Report changed files, validation run, remaining gaps, and final status.",
        "- End with `STATUS: GREEN|YELLOW|RED`.",
    ]
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a frontend implementation prompt.")
    parser.add_argument("--surface", required=True)
    parser.add_argument("--batch", required=True)
    args = parser.parse_args()

    packet = enrich_packet_with_instrument(combined_surface_payload(args.surface))
    prompt_md, prompt_json = prompt_paths(args.batch)
    write_text(prompt_md, render_prompt(packet, args.batch))
    write_json(
        prompt_json,
        {
            "batch_id": args.batch,
            "surface_id": args.surface,
            "packet_path": str((REPORT_DIR / "frontend-authority-packets" / f"{args.surface}.md").relative_to(ROOT)),
            "signature_instrument_id": packet.get("signature_visual_instrument", {}).get("signature_instrument_id"),
            "shared_instrument_primitives": packet.get("signature_visual_instrument", {}).get("shared_instrument_primitives", []),
        },
    )
    print(prompt_md)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
