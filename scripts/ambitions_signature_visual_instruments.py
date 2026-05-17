from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FRONTEND_ROOT = ROOT / "frontend" / "visual-encyclopedia"
DOCTRINE_PATH = FRONTEND_ROOT / "SIGNATURE_VISUAL_INSTRUMENTS.md"
MATRIX_PATH = FRONTEND_ROOT / "trace" / "SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml"

DESTINATION_INSTRUMENTS: dict[str, dict[str, Any]] = {
    "Today": {
        "signature_instrument_id": "reality_meridian_instrument",
        "signature_instrument_name": "Reality Meridian Instrument",
        "primary_object": "Reality Meridian",
        "shared_instrument_primitives": [
            "LivingBackground",
            "LiveTelemetryPanel",
            "ContextualDrilldownHeader",
            "MetricInstrumentChart",
        ],
        "likely_source_files": [
            "Native/Ambitions/Features/Today/TodayScreen.swift",
            "Native/Ambitions/Features/Today/TodayDayRailPanels.swift",
            "Native/Ambitions/Features/Today/TodayViewModel.swift",
            "Native/Ambitions/Features/Today/TodayExecutionViewState.swift",
        ],
        "future_visual_object_source_files": [
            "Native/Ambitions/Features/Today/RealityMeridianSurface.swift",
            "Native/Ambitions/Features/Today/RealityMeridianLiveStatePanel.swift",
            "Native/Ambitions/Features/Today/RealityMeridianContinuitySpine.swift",
        ],
        "swiftui_technique_candidates": ["Canvas", "Shape", "Path", "GeometryReader", "TimelineView", "matchedGeometryEffect"],
        "forbidden_visual_regressions": [
            "generic task list",
            "generic dashboard",
            "disconnected card stack",
            "shame language",
            "AI confidence language",
        ],
    },
    "Goals": {
        "signature_instrument_id": "constellation_atlas_instrument",
        "signature_instrument_name": "Constellation Atlas Instrument",
        "primary_object": "Constellation Atlas",
        "shared_instrument_primitives": [
            "CinematicObjectHero",
            "FloatingGlassNav",
            "MetricInstrumentChart",
            "ContextualDrilldownHeader",
        ],
        "likely_source_files": [
            "Native/Ambitions/Features/Goals/GoalsScreen.swift",
            "Native/Ambitions/Features/Goals/GoalsViewModel.swift",
            "Native/Ambitions/Features/Goals/GoalsFeatureService.swift",
        ],
        "future_visual_object_source_files": [
            "Native/Ambitions/Features/Goals/ConstellationAtlasView.swift",
            "Native/Ambitions/Features/Goals/GoalMissionHero.swift",
            "Native/Ambitions/Features/Goals/ProofOrbitView.swift",
            "Native/Ambitions/Features/Goals/GoalPathTrajectoryView.swift",
        ],
        "swiftui_technique_candidates": ["Canvas", "Shape", "Path", "GeometryReader", "matchedGeometryEffect"],
        "forbidden_visual_regressions": [
            "static goal list",
            "generic progress ring",
            "fake certainty",
            "motivational dashboard",
        ],
    },
    "Capture": {
        "signature_instrument_id": "atmosphere_composer_instrument",
        "signature_instrument_name": "Atmosphere Composer Instrument",
        "primary_object": "Atmosphere Composer",
        "shared_instrument_primitives": [
            "LivingBackground",
            "FloatingGlassNav",
            "CinematicObjectHero",
            "LiveTelemetryPanel",
        ],
        "likely_source_files": [
            "Native/Ambitions/Features/Captures/CapturesScreen.swift",
            "Native/Ambitions/Features/Captures/CaptureViewModel.swift",
            "Native/Ambitions/Features/Captures/CaptureFeatureService.swift",
        ],
        "future_visual_object_source_files": [
            "Native/Ambitions/Features/Captures/AtmosphereComposerView.swift",
            "Native/Ambitions/Features/Captures/CaptureRoutingField.swift",
            "Native/Ambitions/Features/Captures/CapturePlacementResolver.swift",
            "Native/Ambitions/Features/Captures/CaptureReceiptSurface.swift",
        ],
        "swiftui_technique_candidates": ["Canvas", "GeometryReader", "matchedGeometryEffect", "state-driven materials"],
        "forbidden_visual_regressions": [
            "chatbot thread",
            "inbox as top-level default",
            "generic notes app",
            "feed UI",
        ],
    },
    "Time": {
        "signature_instrument_id": "lifeshape_field_instrument",
        "signature_instrument_name": "LifeShape Field Instrument",
        "primary_object": "LifeShape Field",
        "shared_instrument_primitives": [
            "LivingBackground",
            "LiveTelemetryPanel",
            "MetricInstrumentChart",
            "ContextualDrilldownHeader",
            "FloatingGlassNav",
        ],
        "likely_source_files": [
            "Native/Ambitions/Features/Time/TimeScreen.swift",
            "Native/Ambitions/Features/Time/TimeViewModel.swift",
            "Native/Ambitions/Features/Time/TimeFeatureService.swift",
        ],
        "future_visual_object_source_files": [
            "Native/Ambitions/Features/Time/LifeShapeFieldView.swift",
            "Native/Ambitions/Features/Time/LifeShapePressureMap.swift",
            "Native/Ambitions/Features/Time/LifeShapeCapacityBars.swift",
            "Native/Ambitions/Features/Time/LifeShapeDrilldownHeader.swift",
        ],
        "swiftui_technique_candidates": ["Canvas", "Shape", "Path", "GeometryReader", "TimelineView"],
        "forbidden_visual_regressions": [
            "calendar clone",
            "market board copy",
            "fake precision",
            "silent reflow",
        ],
    },
    "You": {
        "signature_instrument_id": "user_system_profile_instrument",
        "signature_instrument_name": "User System Profile Instrument",
        "primary_object": "User System Profile",
        "shared_instrument_primitives": [
            "ContextualDrilldownHeader",
            "LiveTelemetryPanel",
            "FloatingGlassNav",
            "MetricInstrumentChart",
        ],
        "likely_source_files": [
            "Native/Ambitions/Features/You/YouScreen.swift",
            "Native/Ambitions/Features/You/YouViewModel.swift",
            "Native/Ambitions/Features/You/YouFeatureService.swift",
        ],
        "future_visual_object_source_files": [
            "Native/Ambitions/Features/You/UserSystemProfileSurface.swift",
            "Native/Ambitions/Features/You/TrustConsoleView.swift",
            "Native/Ambitions/Features/You/AutomationLadderView.swift",
            "Native/Ambitions/Features/You/LocalRuntimeTrustMap.swift",
        ],
        "swiftui_technique_candidates": ["GeometryReader", "state-driven materials", "contextual headers", "semantic metric panels"],
        "forbidden_visual_regressions": [
            "surveillance posture",
            "AI theater",
            "hidden learning claims",
            "generic settings dump",
        ],
    },
}

MAJOR_DRILLDOWN_PRIMITIVES: dict[str, list[str]] = {
    "detail": ["ContextualDrilldownHeader", "CinematicObjectHero"],
    "receipt": ["ContextualDrilldownHeader", "LiveTelemetryPanel"],
    "proof": ["ContextualDrilldownHeader", "CinematicObjectHero", "MetricInstrumentChart"],
    "session": ["ContextualDrilldownHeader", "LiveTelemetryPanel"],
    "month": ["CinematicObjectHero", "FloatingGlassNav", "MetricInstrumentChart"],
    "composer": ["LivingBackground", "FloatingGlassNav"],
}

ROOT_SURFACES = {
    "today_root_reality_meridian": "Today",
    "goals_root_constellation_atlas": "Goals",
    "capture_root_atmosphere_composer": "Capture",
    "time_root_lifeshape_field": "Time",
    "you_root_user_system_profile": "You",
}


def instrument_for(destination: str | None, surface_id: str | None = None, surface_name: str | None = None) -> dict[str, Any]:
    base = DESTINATION_INSTRUMENTS.get(str(destination or ""))
    if base:
        payload = dict(base)
        payload["instrument_required"] = True
        payload["doctrine_path"] = str(DOCTRINE_PATH.relative_to(ROOT))
        payload["matrix_path"] = str(MATRIX_PATH.relative_to(ROOT))
        payload["instrument_implementation_status"] = "intended_authority_pending_source_proof"
        payload["dedicated_visual_object_guidance"] = "Use or create a dedicated visual-object SwiftUI component rather than burying this instrument inside a root screen file."
        return payload

    text = f"{surface_id or ''} {surface_name or ''}".lower()
    primitives: list[str] = []
    for marker, values in MAJOR_DRILLDOWN_PRIMITIVES.items():
        if marker in text:
            primitives.extend(values)
    if primitives:
        return {
            "signature_instrument_id": None,
            "signature_instrument_name": None,
            "instrument_required": False,
            "shared_instrument_primitives": sorted(set(primitives)),
            "doctrine_path": str(DOCTRINE_PATH.relative_to(ROOT)),
            "matrix_path": str(MATRIX_PATH.relative_to(ROOT)),
            "instrument_implementation_status": "shared_primitive_required_pending_source_proof",
            "dedicated_visual_object_guidance": "Use the shared instrument primitive appropriate for this drill-down or state surface.",
            "future_visual_object_source_files": [],
            "swiftui_technique_candidates": ["GeometryReader", "state-driven materials", "contextual headers"],
            "forbidden_visual_regressions": ["generic card stack", "static list-only implementation"],
        }

    return {
        "signature_instrument_id": None,
        "signature_instrument_name": None,
        "instrument_required": False,
        "shared_instrument_primitives": [],
        "doctrine_path": str(DOCTRINE_PATH.relative_to(ROOT)),
        "matrix_path": str(MATRIX_PATH.relative_to(ROOT)),
        "instrument_implementation_status": "not_required_for_this_surface",
        "dedicated_visual_object_guidance": "No owning instrument required; preserve object-first visual canon and avoid generic fallback.",
        "future_visual_object_source_files": [],
        "swiftui_technique_candidates": [],
        "forbidden_visual_regressions": ["generic card stack", "static list-only implementation"],
    }


def enrich_packet_with_instrument(packet: dict[str, Any]) -> dict[str, Any]:
    enriched = dict(packet)
    destination = str(packet.get("destination") or "")
    surface_id = str(packet.get("surface_id") or "")
    surface_name = str(packet.get("surface_name") or "")
    instrument = instrument_for(destination, surface_id, surface_name)
    enriched["signature_visual_instrument"] = instrument
    existing_sources = list(enriched.get("source_candidates", []) or [])
    likely = list(instrument.get("likely_source_files", []) or [])
    enriched["source_candidates"] = _dedupe(existing_sources + likely)
    return enriched


def _dedupe(items: list[Any]) -> list[Any]:
    seen: set[str] = set()
    out: list[Any] = []
    for item in items:
        key = str(item)
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def instrument_counts(items: list[dict[str, Any]]) -> dict[str, int]:
    counts: Counter[str] = Counter()
    for item in items:
        instrument = item.get("signature_visual_instrument") or {}
        key = instrument.get("signature_instrument_id") or "shared_or_none"
        counts[str(key)] += 1
    return dict(sorted(counts.items()))


def missing_top_level_instruments(items: list[dict[str, Any]]) -> list[str]:
    missing: list[str] = []
    by_id = {str(item.get("surface_id")): item for item in items}
    for surface_id in ROOT_SURFACES:
        item = by_id.get(surface_id)
        instrument = item.get("signature_visual_instrument") if item else None
        if not item or not isinstance(instrument, dict) or not instrument.get("signature_instrument_id"):
            missing.append(surface_id)
    return sorted(missing)
