from __future__ import annotations

from hashlib import sha256
from pathlib import Path
import json
import textwrap
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DESIGN_TOKENS_ROOT = ROOT / "DesignTokens"
DOCS_ROOT = ROOT / "docs"
FRONTEND_ROOT = ROOT / "frontend" / "visual-encyclopedia"
CONTRACTS_ROOT = FRONTEND_ROOT / "contracts"
TRACE_ROOT = FRONTEND_ROOT / "trace"
GATES_ROOT = FRONTEND_ROOT / "gates"
ARCH_ROOT = DOCS_ROOT / "architecture"
STATE_MACHINES_ROOT = ARCH_ROOT / "state-machines"
DECISIONS_ROOT = ARCH_ROOT / "decisions"
DEPS_ROOT = ARCH_ROOT / "dependencies"
FEATURE_SERVICES_ROOT = ARCH_ROOT / "feature-services"
PERF_ROOT = ARCH_ROOT / "performance"
REPORTS_ROOT = ROOT / "build/reports"
SWIFT_THEME_ROOT = ROOT / "Sources/Theme"


FOUNDATION_TOKENS = {
    "graphiteInk": {"hex": "#0F1114", "meaning": "quiet luxury base surface"},
    "graphiteRise": {"hex": "#171A1F", "meaning": "resting elevated surface"},
    "warmPaper": {"hex": "#E8E3DB", "meaning": "light canvas"},
    "warmMist": {"hex": "#F3EEE8", "meaning": "light elevated canvas"},
    "luminousTrace": {"hex": "#C8A96B", "meaning": "live trace and receipt highlight"},
    "celestialField": {"hex": "#141A24", "meaning": "deep field surface"},
    "quietGlass": {"hex": "#202838", "meaning": "overlay surface with restraint"},
    "recoveryMint": {"hex": "#8BC6A8", "meaning": "recovery and repaired state"},
}

SEMANTIC_TOKENS = {
    "todayFocus": {"hex": "#C8A96B", "meaning": "today attention surface"},
    "goalThread": {"hex": "#A9C0D6", "meaning": "goal-thread linkage"},
    "captureSignal": {"hex": "#D29D72", "meaning": "capture entry and route reveal"},
    "timeCapacity": {"hex": "#89A4C2", "meaning": "capacity and pressure"},
    "youTrust": {"hex": "#C6A3D4", "meaning": "trust seam and local runtime"},
    "sourceFreshness": {"hex": "#8AC6B8", "meaning": "freshness and staleness"},
    "proofReceipt": {"hex": "#D4BC7D", "meaning": "proof and receipt surface"},
    "protectedTime": {"hex": "#8DA3D9", "meaning": "protected time and conflict"},
}

COMPONENT_TOKENS = {
    "panelHero": {"radius": 30, "padding": 24, "meaning": "hero object panel"},
    "panelStandard": {"radius": 24, "padding": 20, "meaning": "standard rich panel"},
    "panelCompact": {"radius": 18, "padding": 16, "meaning": "dense secondary panel"},
    "ctaPrimary": {"radius": 999, "padding": 16, "meaning": "primary action"},
    "ctaSecondary": {"radius": 18, "padding": 14, "meaning": "secondary action"},
    "disclosureRow": {"radius": 16, "padding": 12, "meaning": "source / proof / receipt row"},
    "proofChip": {"radius": 16, "padding": 10, "meaning": "proof summary chip"},
    "sourceBadge": {"radius": 999, "padding": 10, "meaning": "source freshness badge"},
}

MOTION_TOKENS = {
    "micro": {"seconds": 0.12, "meaning": "micro feedback"},
    "regular": {"seconds": 0.22, "meaning": "standard object transition"},
    "emphasis": {"seconds": 0.30, "meaning": "important emphasis"},
    "route": {"seconds": 0.28, "meaning": "route change"},
    "settle": {"seconds": 0.18, "meaning": "settle animation"},
}

HAPTIC_TOKENS = {
    "selection": "selection",
    "completion": "completion",
    "correction": "correction",
    "reschedule": "reschedule",
    "routeChange": "route change",
    "warning": "warning",
}

ACCESSIBILITY_TOKENS = {
    "minimumTapTarget": {"value": 44, "meaning": "minimum tap target"},
    "textScaleFloor": {"value": "Large", "meaning": "supports dynamic type"},
    "reduceMotionFallback": {"value": "fade", "meaning": "motion fallback"},
    "contrastFallback": {"value": "elevated stroke", "meaning": "contrast fallback"},
    "differentiationFallback": {"value": "icon plus label", "meaning": "color-independent meaning"},
    "voiceOverOrder": {"value": "surface, source, proof, receipt, action", "meaning": "reading order"},
}

OBJECT_TOKENS = {
    "realityMeridian": {
        "surface": "Today",
        "primary_token": "todayFocus",
        "states": ["clear day", "recovery day", "high pressure", "stale source", "protected time", "no schedule data"],
        "proof": "source / proof / receipt clarity",
    },
    "constellationAtlas": {
        "surface": "Goals",
        "primary_token": "goalThread",
        "states": ["empty", "active threads", "proof gap", "blocker", "pivot", "recovery"],
        "proof": "goal-thread and proof-gap traceability",
    },
    "atmosphereComposer": {
        "surface": "Capture",
        "primary_token": "captureSignal",
        "states": ["idle", "active text", "route reveal", "held with dignity", "proof attached", "wrong-route recovery"],
        "proof": "capture routing and correction path",
    },
    "lifeshapeField": {
        "surface": "Time",
        "primary_token": "timeCapacity",
        "states": ["day capacity", "week pressure", "month life shape", "protected conflict", "reflow preview", "stale source", "away / vacation"],
        "proof": "capacity and protected-time semantics",
    },
    "userSystemProfile": {
        "surface": "You",
        "primary_token": "youTrust",
        "states": ["runtime trust", "automation ladder", "learned pattern", "privacy", "reset / forget preview"],
        "proof": "local learning and trust controls",
    },
}

STATE_TOKENS = {
    "sourceFreshness": {
        "live": "fresh and verified",
        "stale": "stale and needs refresh",
        "missing": "missing source",
    },
    "proof": {
        "strong": "proof attached",
        "partial": "proof gap",
        "none": "no proof yet",
    },
    "closure": {
        "closed": "closure recorded",
        "recovery": "recovery path open",
        "pivot": "pivot required",
    },
    "recovery": {
        "gentle": "gentle recovery",
        "active": "active recovery",
        "reset": "reset or forget preview",
    },
    "protectedTime": {
        "reserved": "protected time reserved",
        "conflict": "protected time conflict",
        "reschedule": "reschedule preview",
    },
}

TOKEN_SOURCE_FILENAMES = {
    "realityMeridian": "reality-meridian",
    "constellationAtlas": "constellation-atlas",
    "atmosphereComposer": "atmosphere-composer",
    "lifeshapeField": "lifeshape-field",
    "userSystemProfile": "user-system-profile",
    "sourceFreshness": "source-freshness",
    "protectedTime": "protected-time",
}


def token_source_filename(key: str) -> str:
    return TOKEN_SOURCE_FILENAMES.get(key, key)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n")


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")


def read_text(path: Path) -> str:
    return path.read_text()


def canonical_token_payload() -> dict[str, Any]:
    return {
        "foundation": FOUNDATION_TOKENS,
        "semantic": SEMANTIC_TOKENS,
        "component": COMPONENT_TOKENS,
        "motion": MOTION_TOKENS,
        "haptics": HAPTIC_TOKENS,
        "accessibility": ACCESSIBILITY_TOKENS,
        "objects": OBJECT_TOKENS,
        "states": STATE_TOKENS,
    }


def canonical_token_hash() -> str:
    payload = json.dumps(canonical_token_payload(), indent=2, sort_keys=True)
    return sha256(payload.encode("utf-8")).hexdigest()


def bullet_lines(items: list[str]) -> str:
    return "\n".join(f"- {item}" for item in items)


def render_doc(title: str, status: str, body: str) -> str:
    return textwrap.dedent(
        f"""\
        # {title}

        Status: {status}

        {body.strip()}
        """
    )


def render_contract_doc(title: str, subject: str, allowed: list[str], forbidden: list[str], required_tokens: list[str], accessibility: list[str], states: list[str], proof: str) -> str:
    return render_doc(
        title,
        "Active frontend contract scaffold",
        f"""
        ## Definition

        {subject}

        ## Allowed Use

        {bullet_lines(allowed)}

        ## Forbidden Use

        {bullet_lines(forbidden)}

        ## Required Tokens

        {bullet_lines(required_tokens)}

        ## Accessibility Requirements

        {bullet_lines(accessibility)}

        ## State Variants

        {bullet_lines(states)}

        ## Proof And Receipt

        {proof}
        """,
    )


def render_matrix_doc(title: str, intro: str, rows: list[list[str]], note: str) -> str:
    header = "| " + " | ".join(rows[0]) + " |"
    divider = "| " + " | ".join(["---"] * len(rows[0])) + " |"
    table_rows = "\n".join("| " + " | ".join(row) + " |" for row in rows[1:])
    return render_doc(
        title,
        "Active matrix scaffold",
        f"""
        {intro}

        {header}
        {divider}
        {table_rows}

        {note}
        """,
    )


def render_adr_doc(number: int, title: str, decision: str, consequences: list[str], status: str = "Accepted") -> str:
    body = f"""
        ## Context

        This ADR is dated 2026-05-14 and applies only to the control-plane install batch.

        ## Decision

        {decision}

        ## Consequences

        {bullet_lines(consequences)}

        ## Status

        {status}
        """
    return render_doc(f"ADR-{number:03d} {title}", "Active architecture decision record", body)


def render_ledger_doc(title: str, intro: str, rows: list[list[str]], footer: str) -> str:
    header = "| " + " | ".join(rows[0]) + " |"
    divider = "| " + " | ".join(["---"] * len(rows[0])) + " |"
    table_rows = "\n".join("| " + " | ".join(row) + " |" for row in rows[1:])
    return render_doc(
        title,
        "Active trace ledger",
        f"""
        {intro}

        {header}
        {divider}
        {table_rows}

        {footer}
        """,
    )


def render_yaml_matrix(title: str, sections: list[tuple[str, list[tuple[str, str]]]], footer: str) -> str:
    lines = [f"# {title}", "", "status: scaffold", "sections:"]
    for section_name, items in sections:
        lines.append(f"  - name: {section_name}")
        lines.append("    states:")
        for key, value in items:
            lines.append(f"      - key: {key}")
            lines.append(f"        value: {value}")
    lines.extend(["", footer])
    return "\n".join(lines)


def token_json_payload(category: str, data: dict[str, Any]) -> dict[str, Any]:
    return {
        "category": category,
        "source_manifest_hash": canonical_token_hash(),
        "items": data,
    }


def swift_header() -> str:
    return textwrap.dedent(
        f"""\
        // Generated by scripts/ambitions-token-generate.py
        // Source manifest hash: {canonical_token_hash()}
        // Do not edit by hand.
        """
    )


def swift_struct_name(name: str) -> str:
    parts = []
    current = ""
    for char in name:
        if char.isalnum():
            current += char
        elif current:
            parts.append(current)
            current = ""
    if current:
        parts.append(current)
    return "".join(part[:1].upper() + part[1:] for part in parts)


def render_swift_token_file() -> str:
    lines = [swift_header(), "", "import Foundation", "", "public struct AmbitionTokenColor: Codable, Sendable {", "    public let name: String", "    public let hex: String", "    public let meaning: String", "    public init(name: String, hex: String, meaning: String) {", "        self.name = name", "        self.hex = hex", "        self.meaning = meaning", "    }", "}", "", "public struct AmbitionTokenMeasure: Codable, Sendable {", "    public let name: String", "    public let value: Double", "    public let meaning: String", "    public init(name: String, value: Double, meaning: String) {", "        self.name = name", "        self.value = value", "        self.meaning = meaning", "    }", "}", "", "public struct AmbitionTokenLayout: Codable, Sendable {", "    public let name: String", "    public let radius: Double", "    public let padding: Double", "    public let meaning: String", "    public init(name: String, radius: Double, padding: Double, meaning: String) {", "        self.name = name", "        self.radius = radius", "        self.padding = padding", "        self.meaning = meaning", "    }", "}", "", "public struct AmbitionTokenText: Codable, Sendable {", "    public let name: String", "    public let value: String", "    public let meaning: String", "    public init(name: String, value: String, meaning: String) {", "        self.name = name", "        self.value = value", "        self.meaning = meaning", "    }", "}", "", "public enum AmbitionTokens {"]
    for section_name, data, token_kind in (
        ("Foundation", FOUNDATION_TOKENS, "color"),
        ("Semantic", SEMANTIC_TOKENS, "color"),
        ("Component", COMPONENT_TOKENS, "layout"),
        ("Motion", MOTION_TOKENS, "measure"),
        ("Accessibility", ACCESSIBILITY_TOKENS, "text"),
        ("Haptics", HAPTIC_TOKENS, "text"),
    ):
        lines.append(f"    public enum {section_name} {{")
        for token_name, payload in data.items():
            if token_kind == "color":
                lines.append(
                    f"        public static let {token_name}: AmbitionTokenColor = .init(name: \"{token_name}\", hex: \"{payload['hex']}\", meaning: \"{payload['meaning']}\")"
                )
            elif token_kind == "measure":
                value = payload.get("seconds", payload.get("value"))
                lines.append(
                    f"        public static let {token_name}: AmbitionTokenMeasure = .init(name: \"{token_name}\", value: {value}, meaning: \"{payload['meaning']}\")"
                )
            elif token_kind == "layout":
                lines.append(
                    f"        public static let {token_name}: AmbitionTokenLayout = .init(name: \"{token_name}\", radius: {payload['radius']}, padding: {payload['padding']}, meaning: \"{payload['meaning']}\")"
                )
            else:
                text_value = payload if isinstance(payload, str) else payload.get("value")
                meaning = payload["meaning"] if isinstance(payload, dict) else payload
                lines.append(
                    f"        public static let {token_name}: AmbitionTokenText = .init(name: \"{token_name}\", value: \"{text_value}\", meaning: \"{meaning}\")"
                )
        lines.append("    }")
        lines.append("")
    lines.append("}")
    return "\n".join(lines)


def render_object_swift_file() -> str:
    lines = [swift_header(), "", "import Foundation", "", "public struct AmbitionObjectToken: Codable, Sendable {", "    public let name: String", "    public let surface: String", "    public let primaryToken: String", "    public let states: [String]", "    public let proof: String", "    public init(name: String, surface: String, primaryToken: String, states: [String], proof: String) {", "        self.name = name", "        self.surface = surface", "        self.primaryToken = primaryToken", "        self.states = states", "        self.proof = proof", "    }", "}", "", "public enum AmbitionObjectTokens {"]
    for token_name, payload in OBJECT_TOKENS.items():
        struct_name = swift_struct_name(token_name)
        lines.append(
            f"    public static let {token_name}: AmbitionObjectToken = .init(name: \"{struct_name}\", surface: \"{payload['surface']}\", primaryToken: \"{payload['primary_token']}\", states: {json.dumps(payload['states'])}, proof: \"{payload['proof']}\")"
        )
    lines.append("}")
    return "\n".join(lines)


def render_state_swift_file() -> str:
    lines = [swift_header(), "", "import Foundation", "", "public struct AmbitionStateToken: Codable, Sendable {", "    public let name: String", "    public let states: [String: String]", "    public init(name: String, states: [String: String]) {", "        self.name = name", "        self.states = states", "    }", "}", "", "public enum AmbitionStateTokens {"]
    for token_name, payload in STATE_TOKENS.items():
        dict_literal = "[\n" + ", ".join(f'"{key}": "{value}"' for key, value in payload.items()) + "]"
        lines.append(
            f"    public static let {token_name}: AmbitionStateToken = .init(name: \"{token_name}\", states: {dict_literal})"
        )
    lines.append("}")
    return "\n".join(lines)


def generate_design_tokens() -> None:
    write_text(
        DESIGN_TOKENS_ROOT / "README.md",
        render_doc(
            "Design Tokens",
            "Active token source tree scaffold",
            """
            DesignTokens is the formal token source tree for the design-system install.

            ## Source Truth

            - `docs/truth/PRODUCT_DESIGN_TRUTH.md`
            - `Sources/Theme/AmbitionTheme.swift`
            - `frontend/visual-encyclopedia/primitives/*`

            ## Rule

            Tokens encode Ambitions product meaning. They are not a color dump.

            ## Current Architecture

            The token tree is intentionally bucketed rather than generic:

            - foundation: named surface/material colors such as graphite, quiet glass, and trace accents
            - semantic: product-specific meaning colors such as Today, Capture, proof, source freshness, and trust
            - component: spacing, radius, and panel geometry for reusable surface treatment
            - motion / haptics / accessibility: interaction and fallback contracts
            - objects / states: Reality Meridian, Start Here-adjacent surface behavior, closure, proof, recovery, and freshness semantics

            Quiet Glass and Graphite Recess remain named material/surface concepts. Reality Meridian remains the Today flagship object. Start Here remains a Today-facing command concept. The live theme is the implementation truth for typography, spacing, and material rendering; DesignTokens keeps those meanings inspectable without creating a second authority root.
            """,
        ),
    )
    write_json(DESIGN_TOKENS_ROOT / "foundations.tokens.json", token_json_payload("foundation", FOUNDATION_TOKENS))
    write_json(DESIGN_TOKENS_ROOT / "semantic.tokens.json", token_json_payload("semantic", SEMANTIC_TOKENS))
    write_json(DESIGN_TOKENS_ROOT / "component.tokens.json", token_json_payload("component", COMPONENT_TOKENS))
    write_json(DESIGN_TOKENS_ROOT / "motion.tokens.json", token_json_payload("motion", MOTION_TOKENS))
    write_json(DESIGN_TOKENS_ROOT / "haptics.tokens.json", token_json_payload("haptics", HAPTIC_TOKENS))
    write_json(DESIGN_TOKENS_ROOT / "accessibility.tokens.json", token_json_payload("accessibility", ACCESSIBILITY_TOKENS))
    for key, payload in OBJECT_TOKENS.items():
        write_json(DESIGN_TOKENS_ROOT / "objects" / f"{token_source_filename(key)}.tokens.json", token_json_payload("object", {key: payload}))
    for key, payload in STATE_TOKENS.items():
        write_json(DESIGN_TOKENS_ROOT / "states" / f"{token_source_filename(key)}.tokens.json", token_json_payload("state", {key: payload}))
    write_text(SWIFT_THEME_ROOT / "AmbitionTokens.generated.swift", render_swift_token_file())
    write_text(SWIFT_THEME_ROOT / "AmbitionObjectTokens.generated.swift", render_object_swift_file())
    write_text(SWIFT_THEME_ROOT / "AmbitionStateTokens.generated.swift", render_state_swift_file())
    write_text(
        FRONTEND_ROOT / "contracts/COMPONENT_CONTRACT_INDEX.md",
        render_ledger_doc(
            "Component Contract Index",
            "This index maps the new contract scaffold files. It is design control, not implementation proof.",
            [
                ["Contract", "File", "Focus"],
                ["Trust seam", "TRUST_SEAM_CONTRACT.md", "source / proof / receipt"],
                ["Proof chip", "PROOF_CHIP_CONTRACT.md", "proof summary and correction path"],
                ["Source freshness badge", "SOURCE_FRESHNESS_BADGE_CONTRACT.md", "freshness and staleness"],
                ["Receipt", "RECEIPT_CONTRACT.md", "closure and correction receipts"],
                ["Primary CTA", "PRIMARY_CTA_CONTRACT.md", "one primary action"],
                ["Disclosure row", "DISCLOSURE_ROW_CONTRACT.md", "detail, proof, and correction"],
            ],
            "Missing implementation remains missing until source proof exists.",
        ),
    )
    contract_specs = {
        "TRUST_SEAM_CONTRACT.md": dict(
            subject="The trust seam shows source, proof, receipt, and correction without pretending the app is smarter than the local data.",
            allowed=["Use in You, Today, Goals, Capture, and Time when a surface needs an explicit trust boundary.", "Use local-only trust language and inspectable controls."],
            forbidden=["Do not use for chatbot chrome, model confidence, or hidden automation.", "Do not imply cloud-backed trust or hosted memory."],
            required_tokens=["youTrust", "sourceFreshness", "proofReceipt"],
            accessibility=["VoiceOver order must read source before proof.", "Tap targets must remain explicit and visible."],
            states=["fresh", "stale", "missing", "repaired"],
            proof="Proof is required before any trust claim is upgraded beyond scaffold language.",
        ),
        "PROOF_CHIP_CONTRACT.md": dict(
            subject="The proof chip summarizes that something happened, what source produced it, and whether correction remains available.",
            allowed=["Use next to completion, receipt, or closure events.", "Use for proof summaries inside object surfaces."],
            forbidden=["Do not use as a vanity badge or scoreboard.", "Do not hide the correction path."],
            required_tokens=["proofReceipt", "luminousTrace"],
            accessibility=["The chip must be readable without color.", "The label must not rely on icon-only meaning."],
            states=["attached", "partial", "missing", "correction offered"],
            proof="A proof chip is a source-linked contract artifact, not proof by itself.",
        ),
        "SOURCE_FRESHNESS_BADGE_CONTRACT.md": dict(
            subject="The source freshness badge tells the user whether a recommendation, schedule, or summary is fresh, stale, or missing.",
            allowed=["Use in Today, Time, and You whenever freshness matters.", "Use with explicit refresh or correction actions."],
            forbidden=["Do not use as a silent health score.", "Do not imply real-time sync when none exists."],
            required_tokens=["sourceFreshness", "recoveryMint"],
            accessibility=["Badge text must say fresh or stale in words.", "Color must not be the only signal."],
            states=["fresh", "stale", "missing", "refreshing"],
            proof="This badge is a state label; it does not prove data provenance alone.",
        ),
        "RECEIPT_CONTRACT.md": dict(
            subject="The receipt contract captures what changed, what source it came from, and how the user can review or correct it later.",
            allowed=["Use for closures, pivots, and recoveries.", "Use in the trust seam and history surfaces."],
            forbidden=["Do not turn receipts into social feed items or metrics.", "Do not bury correction or delete actions."],
            required_tokens=["proofReceipt", "luminousTrace"],
            accessibility=["Receipts need a clear reading order and an accessible summary.", "Expandable details need visible affordances."],
            states=["created", "reviewed", "corrected", "forgotten"],
            proof="Receipts are local and inspectable; they do not imply release proof.",
        ),
        "PRIMARY_CTA_CONTRACT.md": dict(
            subject="The primary CTA is one clear action per surface and no more.",
            allowed=["Use for the dominant action on each object surface.", "Use when the user has one obvious next step."],
            forbidden=["Do not stack competing primary actions.", "Do not hide secondary actions as the primary action."],
            required_tokens=["ctaPrimary", "panelHero"],
            accessibility=["Label must make the action obvious.", "Disabled state must be explicit."],
            states=["enabled", "disabled", "loading", "correction"],
            proof="If the primary action is ambiguous, the surface is not yet contract-complete.",
        ),
        "DISCLOSURE_ROW_CONTRACT.md": dict(
            subject="The disclosure row reveals deeper source, proof, or correction detail without becoming a dashboard row.",
            allowed=["Use for source/proof drill-downs.", "Use for inspectable local controls."],
            forbidden=["Do not use as a generic list-row fallback.", "Do not use as a hidden menu substitute."],
            required_tokens=["disclosureRow", "sourceFreshness"],
            accessibility=["Rows must have a visible label and a meaningful accessory.", "VoiceOver must read the disclosure intent."],
            states=["collapsed", "expanded", "stale", "correctable"],
            proof="Disclosure rows are a control-plane primitive, not a generic app row.",
        ),
    }
    for filename, spec in contract_specs.items():
        write_text(
            CONTRACTS_ROOT / filename,
            render_contract_doc(
                filename.removesuffix(".md").replace("_", " ").title(),
                spec["subject"],
                spec["allowed"],
                spec["forbidden"],
                spec["required_tokens"],
                spec["accessibility"],
                spec["states"],
                spec["proof"],
            ),
        )

    write_text(
        FRONTEND_ROOT / "contracts/ACCESSIBILITY_CONTRACT_INDEX.md",
        render_ledger_doc(
            "Accessibility Contract Index",
            "This index tracks the accessibility contract scaffold. It sets requirements and proof gaps only.",
            [
                ["Contract", "File", "Focus"],
                ["Dynamic Type", "DYNAMIC_TYPE_CONTRACT.md", "scale and collapse"],
                ["VoiceOver Order", "VOICEOVER_ORDER_CONTRACT.md", "reading order and labels"],
                ["Reduce Motion", "REDUCE_MOTION_CONTRACT.md", "motion fallback"],
                ["Reduce Transparency", "REDUCE_TRANSPARENCY_CONTRACT.md", "contrast fallback"],
                ["Differentiate Without Color", "DIFFERENTIATE_WITHOUT_COLOR_CONTRACT.md", "non-color meaning"],
            ],
            "Accessibility claims remain unproven until current source or device evidence exists.",
        ),
    )
    accessibility_specs = {
        "DYNAMIC_TYPE_CONTRACT.md": dict(
            subject="Dynamic Type must be supported for all P0 object surfaces, including collapse behavior and readable labels.",
            allowed=["Use for any surface with text, CTA, or receipt content.", "Use to document collapse rules."],
            forbidden=["Do not claim fixed-size UI is sufficient.", "Do not hide critical content at larger sizes."],
            required_tokens=["textScaleFloor", "minimumTapTarget"],
            accessibility=["The contract requires readable content at larger sizes.", "The contract requires visible fallback paths."],
            states=["small", "large", "accessibility extra large"],
            proof="No accessibility conformance claim is made here; this file only states requirements.",
        ),
        "VOICEOVER_ORDER_CONTRACT.md": dict(
            subject="VoiceOver order must be logical, local, and source-first.",
            allowed=["Use for every object surface that includes control, source, or proof.", "Use to define reading order and labels."],
            forbidden=["Do not depend on visual ordering alone.", "Do not suppress correction paths from VoiceOver."],
            required_tokens=["voiceOverOrder", "sourceFreshness"],
            accessibility=["The order must lead with object, then state, then source, then proof, then action."],
            states=["surface first", "source first", "proof first", "correction first"],
            proof="This is a contract, not a verified VoiceOver audit.",
        ),
        "REDUCE_MOTION_CONTRACT.md": dict(
            subject="Reduce Motion must downgrade transitions to a lower-motion fallback.",
            allowed=["Use for route changes, emphasis, and settle states.", "Use with explicit non-animated fallbacks."],
            forbidden=["Do not require motion to understand state.", "Do not claim motion parity when reduced."],
            required_tokens=["reduceMotionFallback", "route"],
            accessibility=["Motion reductions must preserve meaning.", "Fallbacks must stay legible."],
            states=["full motion", "reduced motion", "no motion"],
            proof="No current device proof is claimed by this contract.",
        ),
        "REDUCE_TRANSPARENCY_CONTRACT.md": dict(
            subject="Reduce Transparency must preserve separation, depth, and contrast without depending on blur.",
            allowed=["Use for panels, overlays, and shell chrome.", "Use explicit contrast and outline fallback."],
            forbidden=["Do not rely on blur for meaning.", "Do not hide state behind glass alone."],
            required_tokens=["contrastFallback", "quietGlass"],
            accessibility=["The fallback must remain readable and distinct.", "Boundaries must remain visible."],
            states=["glass", "reduced transparency", "solid fallback"],
            proof="This is a requirement contract, not a live accessibility report.",
        ),
        "DIFFERENTIATE_WITHOUT_COLOR_CONTRACT.md": dict(
            subject="Meaning must survive when color is unavailable.",
            allowed=["Use icon + label + structure for state meaning.", "Use for state, source, and proof surfaces."],
            forbidden=["Do not use color alone to distinguish states.", "Do not assume users can infer meaning from hue."],
            required_tokens=["differentiationFallback", "sourceFreshness"],
            accessibility=["Each state must have a non-color cue.", "Meaningful labels must be present."],
            states=["same color different meaning", "icon plus label", "pattern plus label"],
            proof="Color-independent meaning remains a contract until observed in source or device evidence.",
        ),
    }
    for filename, spec in accessibility_specs.items():
        write_text(
            CONTRACTS_ROOT / filename,
            render_contract_doc(
                filename.removesuffix(".md").replace("_", " ").title(),
                spec["subject"],
                spec["allowed"],
                spec["forbidden"],
                spec["required_tokens"],
                spec["accessibility"],
                spec["states"],
                spec["proof"],
            ),
        )

    write_text(
        FRONTEND_ROOT / "trace/PREVIEW_MATRIX.md",
        render_ledger_doc(
            "Preview Matrix",
            "This matrix names required preview states and marks all missing previews as future implementation debt, not proof.",
            [
                ["Surface", "Required P0 states", "Status", "Notes"],
                ["Today", "clear day / recovery day / high pressure / stale source / protected time / no schedule data", "debt", "preview surfaces not yet verified"],
                ["Goals", "empty / active threads / proof gap / blocker / pivot / recovery", "debt", "preview surfaces not yet verified"],
                ["Capture", "idle / active text / route reveal / held with dignity / proof attached / wrong-route recovery", "debt", "preview surfaces not yet verified"],
                ["Time", "day capacity / week pressure / month life shape / protected conflict / reflow preview / stale source / away", "debt", "preview surfaces not yet verified"],
                ["You", "runtime trust / automation ladder / learned pattern / privacy / reset-forget preview", "debt", "preview surfaces not yet verified"],
            ],
            "Missing previews are explicitly tracked as debt and never upgraded to proof.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/PREVIEW_MATRIX.yaml",
        render_yaml_matrix(
            "Preview Matrix",
            [
                ("Today", [("clear_day", "debt"), ("recovery_day", "debt"), ("high_pressure", "debt"), ("stale_source", "debt"), ("protected_time", "debt"), ("no_schedule_data", "debt")]),
                ("Goals", [("empty", "debt"), ("active_threads", "debt"), ("proof_gap", "debt"), ("blocker", "debt"), ("pivot", "debt"), ("recovery", "debt")]),
                ("Capture", [("idle", "debt"), ("active_text", "debt"), ("route_reveal", "debt"), ("held_with_dignity", "debt"), ("proof_attached", "debt"), ("wrong_route_recovery", "debt")]),
                ("Time", [("day_capacity", "debt"), ("week_pressure", "debt"), ("month_life_shape", "debt"), ("protected_conflict", "debt"), ("reflow_preview", "debt"), ("stale_source", "debt"), ("away_vacation", "debt")]),
                ("You", [("runtime_trust", "debt"), ("automation_ladder", "debt"), ("learned_pattern", "debt"), ("privacy", "debt"), ("reset_forget_preview", "debt")]),
            ],
            "The YAML is a control-plane matrix and intentionally avoids claiming preview implementation.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/SNAPSHOT_TEST_TARGET_PLAN.md",
        render_doc(
            "Snapshot Test Target Plan",
            "Active target plan scaffold",
            """
            Planned future targets:

            - `AmbitionsVisualSnapshotTests`
            - `AmbitionsAccessibilitySnapshotTests`
            - `AmbitionsDynamicTypeSnapshotTests`
            - `AmbitionsReduceMotionSnapshotTests`

            These are future targets only. No snapshot implementation claim is made here.
            """,
        ),
    )

    write_text(
        GATES_ROOT / "VISUAL_REGRESSION_READINESS.md",
        render_contract_doc(
            "Visual Regression Readiness",
            "This gate defines readiness criteria for future visual regression tests. It is readiness scaffolding only.",
            ["Use to describe future snapshot coverage.", "Use to track debt by surface and state."],
            ["Do not claim snapshot implementation exists.", "Do not claim current screenshot proof."],
            ["AmbitionsVisualSnapshotTests", "AmbitionsAccessibilitySnapshotTests", "AmbitionsDynamicTypeSnapshotTests", "AmbitionsReduceMotionSnapshotTests"],
            ["The gate requires test-target names, state coverage, and an explicit debt note."],
            ["planned", "missing", "debt", "future proof"],
            "The gate remains a readiness contract until snapshot tests are actually implemented.",
        ),
    )

    write_text(
        DOCS_ROOT / "architecture/PRODUCT_OBJECT_STATE_MACHINES.md",
        render_ledger_doc(
            "Product Object State Machines",
            "This document names the object state machines as architecture contracts, not runtime implementation claims.",
            [
                ["Machine", "Scope", "Current status"],
                ["Closure flow", "completion, correction, recovery", "contract"],
                ["Capture route", "entry, reveal, place, recover", "contract"],
                ["Reflow", "pivot, conflict, protected time", "contract"],
                ["Source freshness", "fresh, stale, missing, refresh", "contract"],
                ["Proof transfer", "attach, inspect, correct, review", "contract"],
                ["Local learning", "learn, inspect, reset, forget", "contract"],
            ],
            "No runtime state machine changes are implied by this document.",
        ),
    )
    state_machine_specs = {
        "CLOSURE_FLOW_STATE_MACHINE.md": ("Closure Flow State Machine", "closure recording and correction", ["open", "closing", "closed", "reopening", "repaired"], "Do not claim a closure runtime implementation."),
        "CAPTURE_ROUTE_STATE_MACHINE.md": ("Capture Route State Machine", "capture entry and route reveal", ["idle", "typing", "route reveal", "held", "proof attached"], "Do not claim a route engine exists just because the contract exists."),
        "REFLOW_STATE_MACHINE.md": ("Reflow State Machine", "time pressure, pivot, and protected time", ["stable", "pressured", "protected", "reflowing", "settled"], "This is an architecture contract only."),
        "SOURCE_FRESHNESS_STATE_MACHINE.md": ("Source Freshness State Machine", "freshness and staleness transitions", ["fresh", "stale", "missing", "refreshing", "repaired"], "No live freshness service is claimed."),
        "PROOF_TRANSFER_STATE_MACHINE.md": ("Proof Transfer State Machine", "proof attachment and correction", ["unattached", "attached", "reviewed", "corrected", "archived"], "No proof storage claim is made."),
        "LOCAL_LEARNING_STATE_MACHINE.md": ("Local Learning State Machine", "inspectable local learning and reset", ["learning", "reviewing", "accepted", "resetting", "forgotten"], "No cloud learning runtime is introduced."),
    }
    for filename, (title, subject, states, note) in state_machine_specs.items():
        write_text(
            STATE_MACHINES_ROOT / filename,
            render_contract_doc(
                title,
                subject,
                ["Use as architecture guidance for the relevant object flow.", "Use to constrain future implementation reviews."],
                ["Do not treat as proof of runtime implementation.", "Do not widen the scope beyond the named flow."],
                ["sourceFreshness", "proofReceipt", "youTrust"],
                ["The machine must keep source, proof, and correction visible.", "Accessibility and recovery are explicit gates."],
                states,
                note,
            ),
        )

    write_text(
        DOCS_ROOT / "architecture/DEPENDENCY_CLIENTS.md",
        render_ledger_doc(
            "Dependency Clients",
            "This document defines Ambitions-native dependency boundaries and keeps them free of third-party architecture frameworks.",
            [
                ["Client", "Responsibility", "Forbidden"],
                ["Calendar", "schedule access and permission boundaries", "generic calendar clone behavior"],
                ["Notification", "local notification triggers", "hidden automation"],
                ["Persistence", "SwiftData/local persistence boundaries", "hosted data backend assumptions"],
                ["Local runtime", "inspectable local logic and learning", "cloud LLM core dependency"],
                ["Widget snapshot", "widget render and snapshot contract", "release proof claims"],
                ["Source freshness", "fresh/stale/missing checks", "silent stale data"],
            ],
            "These are architecture boundaries only; they do not change production source by themselves.",
        ),
    )
    dependency_specs = {
        "CALENDAR_CLIENT.md": ("Calendar Client", "calendar-aware reads and permission boundaries", ["read schedule", "derived capacity", "time-owned"], "The client must stay Time-owned and not become a calendar clone."),
        "NOTIFICATION_CLIENT.md": ("Notification Client", "local notification orchestration", ["schedule notification", "cancel notification", "refresh notification"], "No hidden automation or hosted trigger semantics are introduced."),
        "PERSISTENCE_CLIENT.md": ("Persistence Client", "local persistence boundary", ["read local model", "write local model", "receipt path"], "No hosted backend or synced account is assumed."),
        "LOCAL_RUNTIME_CLIENT.md": ("Local Runtime Client", "inspectable local behavior boundary", ["local learning", "manual review", "reset preview"], "No external/cloud LLM core dependency is introduced."),
        "WIDGET_SNAPSHOT_CLIENT.md": ("Widget Snapshot Client", "widget snapshot and render contract", ["render snapshot", "read fixture", "record debt"], "No snapshot implementation claim is made."),
        "SOURCE_FRESHNESS_CLIENT.md": ("Source Freshness Client", "freshness and staleness check boundary", ["fresh", "stale", "missing", "refresh"], "Source freshness remains inspectable and local."),
    }
    for filename, (title, subject, tokens, note) in dependency_specs.items():
        write_text(
            DEPS_ROOT / filename,
            render_contract_doc(
                title,
                subject,
                ["Use as an interface boundary in future implementation work.", "Use to constrain feature service calls."],
                ["Do not use these boundaries to justify hosted AI or generic frameworks.", "Do not treat the doc as implementation proof."],
                tokens,
                ["Each client must keep source and correction visible.", "No hidden state transitions."],
                ["contract", "scaffold", "future implementation"],
                note,
            ),
        )

    write_text(
        DOCS_ROOT / "architecture/FEATURE_SERVICE_BOUNDARIES.md",
        render_ledger_doc(
            "Feature Service Boundaries",
            "This document keeps SwiftUI views from becoming logic dumps.",
            [
                ["Service", "Responsibility", "Forbidden"],
                ["Today feature service", "today state and recovery", "screen-level business logic"],
                ["Goals feature service", "goal threads and pivots", "inline persistence mutation"],
                ["Capture feature service", "capture entry and route decision", "generic AI assistant behavior"],
                ["Time feature service", "capacity, pressure, and protected time", "calendar-clone logic"],
                ["You feature service", "trust, automation, and reset", "hosted profile backend"],
                ["Proof ledger service", "proof/receipt recording", "dashboard-only state"],
            ],
            "These boundaries are intended canon and do not by themselves prove runtime wiring.",
        ),
    )
    feature_service_specs = {
        "TODAY_FEATURE_SERVICE.md": ("Today Feature Service", "Reality Meridian state and recovery", ["surface state", "recovery", "freshness"], "Today must remain source-first and non-generic."),
        "GOALS_FEATURE_SERVICE.md": ("Goals Feature Service", "Constellation Atlas state and proof gaps", ["threads", "pivot", "proof gap"], "Goals must stay object-first."),
        "CAPTURE_FEATURE_SERVICE.md": ("Capture Feature Service", "Atmosphere Composer entry and route reveal", ["capture entry", "route reveal", "correction"], "Capture must preserve dignity and correction."),
        "TIME_FEATURE_SERVICE.md": ("Time Feature Service", "LifeShape Field capacity and protected time", ["capacity", "pressure", "protected time"], "Time is capacity, not a calendar clone."),
        "YOU_FEATURE_SERVICE.md": ("You Feature Service", "User System Profile trust and automation", ["trust", "automation ladder", "privacy"], "You remains the personal system center."),
        "PROOF_LEDGER_SERVICE.md": ("Proof Ledger Service", "proof and receipt recording", ["proof", "receipt", "correction"], "Proof ledger stays local and inspectable."),
        "SOURCE_AUTHORITY_SERVICE.md": ("Source Authority Service", "source freshness and precedence", ["fresh", "stale", "missing"], "Source authority is local and inspectable."),
        "REFLOW_ENGINE.md": ("Reflow Engine", "pivot and protected-time reflow", ["reflow", "pivot", "protected conflict"], "No runtime engine claim is made by this doc."),
        "CLOSURE_ENGINE.md": ("Closure Engine", "closure and recovery control", ["close", "recover", "reopen"], "This is an architecture contract only."),
        "LOCAL_RUNTIME_TRUST_SERVICE.md": ("Local Runtime Trust Service", "local-only trust ladder", ["inspectable", "reset", "forget preview"], "No external/cloud LLM core dependency is introduced."),
    }
    for filename, (title, subject, tokens, note) in feature_service_specs.items():
        write_text(
            FEATURE_SERVICES_ROOT / filename,
            render_contract_doc(
                title,
                subject,
                ["Use as a boundary between view code and logic-heavy code.", "Use for feature-level responsibility reviews."],
                ["Do not use as a justification for sprawling view logic.", "Do not use to claim runtime implementation."],
                tokens,
                ["Services must keep correction visible and accessible.", "Labels must be explicit and local."],
                ["scaffold", "contract", "future implementation"],
                note,
            ),
        )

    adr_specs = [
        (1, "Native SwiftUI First", "Ambitions is a native SwiftUI-first product system and should remain so for the foreground surface layer.", ["Preserves app quality and package compatibility.", "Keeps the control-plane install aligned with current source."]),
        (2, "Local First Runtime", "Core runtime behavior remains local-first and inspectable, with no external/cloud LLM core dependency.", ["Matches product truth.", "Prevents hosted dependency drift."]),
        (3, "Design Token Pipeline", "Design tokens are formalized as a source tree plus generated Swift contracts.", ["Creates deterministic token generation.", "Keeps generated code reproducible from token source."]),
        (4, "Product Object Architecture", "Ambitions organizes UI and logic around product objects rather than generic screens.", ["Reinforces Today / Goals / Capture / Time / You.", "Supports future object-first implementation work."]),
        (5, "No Core Cloud LLM", "The product core must not require a hosted/cloud LLM dependency.", ["Preserves privacy and local control.", "Avoids chatbot-driven architecture drift."]),
        (6, "State Machine Over Generic MVVM", "Critical flows are documented as object state machines rather than left as generic view-model assumptions.", ["Improves explicitness.", "Keeps recovery and correction visible."]),
        (7, "Source Proof Receipt Ledger", "Source, proof, and receipt are distinct contracts and must stay inspectable.", ["Keeps correction paths explicit.", "Prevents false release claims."]),
        (8, "Generated Token Contracts", "Generated Swift token contracts are source-derived and must stay reproducible.", ["Enables drift checking.", "Keeps source of truth in DesignTokens."]),
        (9, "Accessibility Contracts Before Claims", "Accessibility requires contract docs and proof gaps before any conformance claim.", ["Prevents false accessibility claims.", "Preserves honest validation posture."]),
    ]
    for number, title, decision, consequences in adr_specs:
        write_text(DECISIONS_ROOT / f"ADR-{number:03d}-{title.lower().replace(' ', '-')}.md", render_adr_doc(number, title, decision, consequences))

    write_text(
        FRONTEND_ROOT / "trace/DESIGN_SYSTEM_AUTHORITY_LEDGER.md",
        render_ledger_doc(
            "Design System Authority Ledger",
            "This ledger classifies the new design-system control-plane materials.",
            [
                ["Item", "Classification"],
                ["DesignTokens source tree", "active"],
                ["Generated Swift token files", "generated artifact"],
                ["Component contracts", "intended canon"],
                ["Accessibility contracts", "intended canon"],
                ["Preview matrix", "intended canon"],
                ["Validator reports", "report-only proof"],
                ["Release/device/accessibility claims", "unproven"],
            ],
            "The design-token tree stays bucketed by current source truth rather than a generic theme system. Surface, material, typography, spacing, geometry, motion, haptic, accessibility, proof, source freshness, closure, recovery, Start Here, Reality Meridian, Quiet Glass, and Graphite Recess are expressed across the existing token/source/theme seams, not through a second authority root.\n\nThis ledger is an authority map, not proof of runtime behavior.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/TOKEN_SOURCE_AUTHORITY_LEDGER.md",
        render_ledger_doc(
            "Token Source Authority Ledger",
            "This ledger clarifies token provenance and generated output boundaries.",
            [
                ["Item", "Classification"],
                ["DesignTokens/*.tokens.json", "token source truth"],
                ["Sources/Theme/AmbitionTokens.generated.swift", "generated artifact"],
                ["Sources/Theme/AmbitionObjectTokens.generated.swift", "generated artifact"],
                ["Sources/Theme/AmbitionStateTokens.generated.swift", "generated artifact"],
                ["AmbitionTheme.swift", "implementation truth"],
            ],
            "The generated files remain reproducible from DesignTokens source.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/COMPONENT_CONTRACT_AUTHORITY_LEDGER.md",
        render_ledger_doc(
            "Component Contract Authority Ledger",
            "This ledger classifies the component contract scaffold and its dependency-free validator.",
            [
                ["Item", "Classification"],
                ["frontend/visual-encyclopedia/contracts/*.md", "intended canon"],
                ["scripts/ambitions-component-contract-check.py", "report-only proof"],
                ["build/reports/component-contract-check.json", "report-only proof"],
            ],
            "The ledger keeps the contract layer separate from implementation evidence.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/PROMPT_SOURCE_CANON_AUTHORITY_LEDGER.md",
        render_ledger_doc(
            "Prompt Source Canon Authority Ledger",
            "This ledger records how the install batch prompt relates to source and canon.",
            [
                ["Item", "Classification"],
                ["Batch prompt", "supporting context"],
                ["Truth files", "active authority"],
                ["Generated docs", "intended canon"],
                ["Validator output", "report-only proof"],
            ],
            "Prompt text does not outrank active truth or current source.",
        ),
    )

    write_text(
        FRONTEND_ROOT / "trace/DESIGN_TO_SOURCE_TRACEABILITY.md",
        render_ledger_doc(
            "Design To Source Traceability",
            "This map is intentionally honest: intended-only entries are allowed and remain clearly marked.",
            [
                ["Object / primitive", "Canon doc", "Token deps", "Contract", "Source candidates", "Status", "Preview", "Validator", "Known drift"],
                ["Today / Reality Meridian", "frontend/visual-encyclopedia/surfaces/TODAY_REALITY_MERIDIAN_BIBLE.md", "todayFocus", "PRIMARY_CTA_CONTRACT.md", "Native/Ambitions/Features/Today/*", "source-present", "debt", "component-contract-check", "none"],
                ["Goals / Constellation Atlas", "frontend/visual-encyclopedia/surfaces/GOALS_CONSTELLATION_ATLAS_BIBLE.md", "goalThread", "DISCLOSURE_ROW_CONTRACT.md", "Native/Ambitions/Features/Goals/*", "source-present", "debt", "component-contract-check", "none"],
                ["Capture / Atmosphere Composer", "frontend/visual-encyclopedia/surfaces/CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md", "captureSignal", "PRIMARY_CTA_CONTRACT.md", "Native/Ambitions/Features/Captures/*", "source-present", "debt", "component-contract-check", "none"],
                ["Time / LifeShape Field", "frontend/visual-encyclopedia/surfaces/TIME_LIFESHAPE_FIELD_BIBLE.md", "timeCapacity", "SOURCE_FRESHNESS_BADGE_CONTRACT.md", "Native/Ambitions/Features/Plan/*", "source-present", "debt", "component-contract-check", "none"],
                ["You / User System Profile", "frontend/visual-encyclopedia/surfaces/YOU_USER_SYSTEM_PROFILE_BIBLE.md", "youTrust", "TRUST_SEAM_CONTRACT.md", "Native/Ambitions/Features/Profile/*", "source-present", "debt", "component-contract-check", "none"],
            ],
            "All preview and implementation status values remain honest about the current proof boundary.",
        ),
    )
    write_text(
        FRONTEND_ROOT / "trace/DESIGN_TO_SOURCE_TRACEABILITY.yaml",
        "\n".join(
            [
                "status: scaffold",
                "items:",
                "  - object: Today / Reality Meridian",
                "    canon_doc: frontend/visual-encyclopedia/surfaces/TODAY_REALITY_MERIDIAN_BIBLE.md",
                "    token_dependencies: [todayFocus]",
                "    contract: PRIMARY_CTA_CONTRACT.md",
                "    source_link_status: source-present",
                "    implementation_proof_status: unproven",
                "    preview_status: debt",
                "    validator_coverage: component-contract-check",
                "    known_drift: none",
                "  - object: Goals / Constellation Atlas",
                "    canon_doc: frontend/visual-encyclopedia/surfaces/GOALS_CONSTELLATION_ATLAS_BIBLE.md",
                "    token_dependencies: [goalThread]",
                "    contract: DISCLOSURE_ROW_CONTRACT.md",
                "    source_link_status: source-present",
                "    implementation_proof_status: unproven",
                "    preview_status: debt",
                "    validator_coverage: component-contract-check",
                "    known_drift: none",
                "  - object: Capture / Atmosphere Composer",
                "    canon_doc: frontend/visual-encyclopedia/surfaces/CAPTURE_ATMOSPHERE_COMPOSER_BIBLE.md",
                "    token_dependencies: [captureSignal]",
                "    contract: PRIMARY_CTA_CONTRACT.md",
                "    source_link_status: source-present",
                "    implementation_proof_status: unproven",
                "    preview_status: debt",
                "    validator_coverage: component-contract-check",
                "    known_drift: none",
                "  - object: Time / LifeShape Field",
                "    canon_doc: frontend/visual-encyclopedia/surfaces/TIME_LIFESHAPE_FIELD_BIBLE.md",
                "    token_dependencies: [timeCapacity]",
                "    contract: SOURCE_FRESHNESS_BADGE_CONTRACT.md",
                "    source_link_status: source-present",
                "    implementation_proof_status: unproven",
                "    preview_status: debt",
                "    validator_coverage: component-contract-check",
                "    known_drift: none",
                "  - object: You / User System Profile",
                "    canon_doc: frontend/visual-encyclopedia/surfaces/YOU_USER_SYSTEM_PROFILE_BIBLE.md",
                "    token_dependencies: [youTrust]",
                "    contract: TRUST_SEAM_CONTRACT.md",
                "    source_link_status: source-present",
                "    implementation_proof_status: unproven",
                "    preview_status: debt",
                "    validator_coverage: component-contract-check",
                "    known_drift: none",
            ]
        ),
    )

    write_text(
        GATES_ROOT / "SOURCE_PROOF_RECEIPT_COVERAGE_GATE.md",
        render_contract_doc(
            "Source Proof Receipt Coverage Gate",
            "This gate requires P0 surfaces to define source, proof, receipt, correction, stale/missing source, and local-only behavior.",
            ["Use for Today, Goals, Capture, Time, and You contracts.", "Use to confirm a complete control-plane definition."],
            ["Do not use to claim runtime implementation.", "Do not use to claim release proof."],
            ["sourceFreshness", "proofReceipt", "youTrust"],
            ["Every surface must expose a correction path and a visible stale/missing state.", "Local-only behavior must remain explicit."],
            ["source present", "proof attached", "receipt attached", "correction", "stale", "missing"],
            "The gate is a contract and does not by itself prove the runtime state.",
        ),
    )
    write_text(
        TRACE_ROOT / "SOURCE_PROOF_RECEIPT_COVERAGE_MATRIX.yaml",
        render_yaml_matrix(
            "Source Proof Receipt Coverage Matrix",
            [
                ("Today", [("source", "required"), ("proof", "required"), ("receipt", "required"), ("correction", "required"), ("stale", "required"), ("local_only", "required")]),
                ("Goals", [("source", "required"), ("proof", "required"), ("receipt", "required"), ("correction", "required"), ("stale", "required"), ("local_only", "required")]),
                ("Capture", [("source", "required"), ("proof", "required"), ("receipt", "required"), ("correction", "required"), ("stale", "required"), ("local_only", "required")]),
                ("Time", [("source", "required"), ("proof", "required"), ("receipt", "required"), ("correction", "required"), ("stale", "required"), ("local_only", "required")]),
                ("You", [("source", "required"), ("proof", "required"), ("receipt", "required"), ("correction", "required"), ("stale", "required"), ("local_only", "required")]),
            ],
            "Coverage is an explicit contract, not implementation proof.",
        ),
    )
    write_text(
        GATES_ROOT / "LOCAL_FIRST_RUNTIME_TRUST_GATE.md",
        render_contract_doc(
            "Local First Runtime Trust Gate",
            "This gate enforces local-first runtime trust: no external/cloud LLM core dependency, inspectable learning, reset/forget preview, source authority ladder, and no hidden automation.",
            ["Use to review local runtime behavior and user-set truth priorities.", "Use as a trust contract for You and the control-plane layers."],
            ["Do not use to justify hosted AI or hidden automation.", "Do not use to claim device validation."],
            ["youTrust", "sourceFreshness", "proofReceipt"],
            ["The gate requires inspectable learning and visible reset/forget preview.", "The gate requires user-set truth to outrank suggestion."],
            ["local-only", "inspectable", "reset preview", "forget preview", "no hidden automation"],
            "No external/cloud LLM core dependency is introduced by this batch.",
        ),
    )
    write_text(
        TRACE_ROOT / "LOCAL_FIRST_RUNTIME_TRUST_MATRIX.yaml",
        render_yaml_matrix(
            "Local First Runtime Trust Matrix",
            [
                ("Today", [("local_only", "required"), ("inspectable", "required"), ("source_authority", "required"), ("no_hidden_automation", "required")]),
                ("Goals", [("local_only", "required"), ("inspectable", "required"), ("source_authority", "required"), ("no_hidden_automation", "required")]),
                ("Capture", [("local_only", "required"), ("inspectable", "required"), ("source_authority", "required"), ("no_hidden_automation", "required")]),
                ("Time", [("local_only", "required"), ("inspectable", "required"), ("source_authority", "required"), ("no_hidden_automation", "required")]),
                ("You", [("local_only", "required"), ("inspectable", "required"), ("reset_forget_preview", "required"), ("source_authority", "required"), ("no_hidden_automation", "required")]),
            ],
            "The matrix is a control-plane contract only.",
        ),
    )

    write_text(
        PERF_ROOT / "TODAY_RENDER_BUDGET.md",
        render_contract_doc(
            "Today Render Budget",
            "This document sets a target budget for Today rendering only; no measured performance claim is made.",
            ["Use as a future budget target.", "Use to compare future render work against the control-plane contract."],
            ["Do not claim measured performance.", "Do not claim device profiling."],
            ["canvas", "surface", "proofReceipt"],
            ["Budget targets must preserve readability and Dynamic Type.", "Reduced motion should remain legible."],
            ["target", "debt", "unmeasured"],
            "The budget is target-only until current logs prove otherwise.",
        ),
    )
    perf_specs = {
        "CAPTURE_LATENCY_BUDGET.md": "Capture latency budget target and local responsiveness contract.",
        "TIME_LIFESHAPE_RENDER_BUDGET.md": "Time LifeShape render budget target and pressure handling contract.",
        "WIDGET_SNAPSHOT_BUDGET.md": "Widget snapshot budget target and render contract.",
        "LOCAL_RUNTIME_COMPUTE_BUDGET.md": "Local runtime compute budget target and inspectable behavior contract.",
    }
    for filename, subject in perf_specs.items():
        write_text(
            PERF_ROOT / filename,
            render_contract_doc(
                filename.removesuffix(".md").replace("_", " ").title(),
                subject,
                ["Use as a target budget.", "Use to keep local runtime work bounded."],
                ["Do not claim measured performance.", "Do not claim release readiness."],
                ["performance", "local", "target"],
                ["Budgets must preserve accessibility and non-shaming recovery language."],
                ["target", "unmeasured", "debt"],
                "The file defines a budget contract, not an observed benchmark.",
            ),
        )


def generate_all() -> None:
    generate_design_tokens()


def report_path(name: str) -> Path:
    return REPORTS_ROOT / name


def validate_token_generation() -> dict[str, Any]:
    generate_design_tokens()
    expected = [
        DESIGN_TOKENS_ROOT / "README.md",
        DESIGN_TOKENS_ROOT / "foundations.tokens.json",
        DESIGN_TOKENS_ROOT / "semantic.tokens.json",
        DESIGN_TOKENS_ROOT / "component.tokens.json",
        DESIGN_TOKENS_ROOT / "motion.tokens.json",
        DESIGN_TOKENS_ROOT / "haptics.tokens.json",
        DESIGN_TOKENS_ROOT / "accessibility.tokens.json",
        *[DESIGN_TOKENS_ROOT / "objects" / f"{token_source_filename(key)}.tokens.json" for key in OBJECT_TOKENS],
        *[DESIGN_TOKENS_ROOT / "states" / f"{token_source_filename(key)}.tokens.json" for key in STATE_TOKENS],
        SWIFT_THEME_ROOT / "AmbitionTokens.generated.swift",
        SWIFT_THEME_ROOT / "AmbitionObjectTokens.generated.swift",
        SWIFT_THEME_ROOT / "AmbitionStateTokens.generated.swift",
    ]
    missing = [str(path.relative_to(ROOT)) for path in expected if not path.exists()]
    report = {
        "status": "green" if not missing else "red",
        "expected_files": len(expected),
        "missing_files": missing,
        "source_manifest_hash": canonical_token_hash(),
    }
    write_json(report_path("design-token-generation.json"), report)
    return report


def validate_token_contracts() -> dict[str, Any]:
    report = {"status": "green", "issues": [], "checked_files": 0}
    for path in [
        DESIGN_TOKENS_ROOT / "foundations.tokens.json",
        DESIGN_TOKENS_ROOT / "semantic.tokens.json",
        DESIGN_TOKENS_ROOT / "component.tokens.json",
        DESIGN_TOKENS_ROOT / "motion.tokens.json",
        DESIGN_TOKENS_ROOT / "haptics.tokens.json",
        DESIGN_TOKENS_ROOT / "accessibility.tokens.json",
        *[DESIGN_TOKENS_ROOT / "objects" / f"{token_source_filename(key)}.tokens.json" for key in OBJECT_TOKENS],
        *[DESIGN_TOKENS_ROOT / "states" / f"{token_source_filename(key)}.tokens.json" for key in STATE_TOKENS],
    ]:
        payload = json.loads(path.read_text())
        report["checked_files"] += 1
        if payload.get("source_manifest_hash") != canonical_token_hash():
            report["issues"].append(f"hash mismatch: {path.name}")
        if "items" not in payload:
            report["issues"].append(f"missing items: {path.name}")
    if report["issues"]:
        report["status"] = "red"
    write_json(report_path("design-token-contract.json"), report)
    return report


def validate_token_drift() -> dict[str, Any]:
    expected_hash = canonical_token_hash()
    drift = []
    for path in [
        SWIFT_THEME_ROOT / "AmbitionTokens.generated.swift",
        SWIFT_THEME_ROOT / "AmbitionObjectTokens.generated.swift",
        SWIFT_THEME_ROOT / "AmbitionStateTokens.generated.swift",
    ]:
        text = path.read_text()
        if expected_hash not in text:
            drift.append(path.name)
    report = {"status": "green" if not drift else "red", "drift": drift, "source_manifest_hash": expected_hash}
    write_json(report_path("design-token-drift.json"), report)
    return report


def validate_component_contracts() -> dict[str, Any]:
    files = [
        "COMPONENT_CONTRACT_INDEX.md",
        "TRUST_SEAM_CONTRACT.md",
        "PROOF_CHIP_CONTRACT.md",
        "SOURCE_FRESHNESS_BADGE_CONTRACT.md",
        "RECEIPT_CONTRACT.md",
        "PRIMARY_CTA_CONTRACT.md",
        "DISCLOSURE_ROW_CONTRACT.md",
    ]
    issues = []
    for rel in files[1:]:
        path = CONTRACTS_ROOT / rel
        text = read_text(path)
        for marker in ["Allowed Use", "Forbidden Use", "Required Tokens", "Accessibility Requirements", "State Variants", "Proof And Receipt"]:
            if marker not in text:
                issues.append(f"{rel}: missing {marker}")
    index_text = read_text(CONTRACTS_ROOT / files[0])
    if "Component Contract Index" not in index_text or "Trust seam" not in index_text:
        issues.append("COMPONENT_CONTRACT_INDEX.md: missing index markers")
    report = {"status": "green" if not issues else "red", "files_checked": len(files), "issues": issues}
    write_json(report_path("component-contract-check.json"), report)
    return report


def validate_preview_matrix() -> dict[str, Any]:
    md = read_text(TRACE_ROOT / "PREVIEW_MATRIX.md")
    yaml = read_text(TRACE_ROOT / "PREVIEW_MATRIX.yaml")
    issues = []
    for marker in ["Today", "Goals", "Capture", "Time", "You", "debt"]:
        if marker not in md and marker not in yaml:
            issues.append(marker)
    report = {"status": "green" if not issues else "red", "issues": issues, "states": 5}
    write_json(report_path("preview-matrix.json"), report)
    return report


def validate_visual_regression_readiness() -> dict[str, Any]:
    text = read_text(GATES_ROOT / "VISUAL_REGRESSION_READINESS.md")
    required = ["AmbitionsVisualSnapshotTests", "AmbitionsAccessibilitySnapshotTests", "AmbitionsDynamicTypeSnapshotTests", "AmbitionsReduceMotionSnapshotTests"]
    issues = [marker for marker in required if marker not in text]
    report = {"status": "green" if not issues else "red", "issues": issues, "claim_boundary": "no screenshot test claim"}
    write_json(report_path("visual-regression-readiness.json"), report)
    return report


def validate_accessibility_contracts() -> dict[str, Any]:
    files = [
        "ACCESSIBILITY_CONTRACT_INDEX.md",
        "DYNAMIC_TYPE_CONTRACT.md",
        "VOICEOVER_ORDER_CONTRACT.md",
        "REDUCE_MOTION_CONTRACT.md",
        "REDUCE_TRANSPARENCY_CONTRACT.md",
        "DIFFERENTIATE_WITHOUT_COLOR_CONTRACT.md",
    ]
    issues = []
    for rel in files:
        text = read_text(CONTRACTS_ROOT / rel)
        if "Proof And Receipt" not in text and rel != "ACCESSIBILITY_CONTRACT_INDEX.md":
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("accessibility-contract.json"), report)
    return report


def validate_state_machines() -> dict[str, Any]:
    files = [
        "PRODUCT_OBJECT_STATE_MACHINES.md",
        "CLOSURE_FLOW_STATE_MACHINE.md",
        "CAPTURE_ROUTE_STATE_MACHINE.md",
        "REFLOW_STATE_MACHINE.md",
        "SOURCE_FRESHNESS_STATE_MACHINE.md",
        "PROOF_TRANSFER_STATE_MACHINE.md",
        "LOCAL_LEARNING_STATE_MACHINE.md",
    ]
    issues = []
    for rel in files:
        path = ARCH_ROOT / rel if rel == "PRODUCT_OBJECT_STATE_MACHINES.md" else STATE_MACHINES_ROOT / rel
        text = read_text(path)
        if "contract" not in text.lower():
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("state-machine-contract.json"), report)
    return report


def validate_dependency_boundaries() -> dict[str, Any]:
    files = [
        "DEPENDENCY_CLIENTS.md",
        "CALENDAR_CLIENT.md",
        "NOTIFICATION_CLIENT.md",
        "PERSISTENCE_CLIENT.md",
        "LOCAL_RUNTIME_CLIENT.md",
        "WIDGET_SNAPSHOT_CLIENT.md",
        "SOURCE_FRESHNESS_CLIENT.md",
    ]
    issues = []
    for rel in files:
        path = ARCH_ROOT / rel if rel == "DEPENDENCY_CLIENTS.md" else DEPS_ROOT / rel
        text = read_text(path)
        if "Forbidden" not in text and rel != "DEPENDENCY_CLIENTS.md":
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("dependency-boundary.json"), report)
    return report


def validate_feature_services() -> dict[str, Any]:
    files = [
        "FEATURE_SERVICE_BOUNDARIES.md",
        "TODAY_FEATURE_SERVICE.md",
        "GOALS_FEATURE_SERVICE.md",
        "CAPTURE_FEATURE_SERVICE.md",
        "TIME_FEATURE_SERVICE.md",
        "YOU_FEATURE_SERVICE.md",
        "PROOF_LEDGER_SERVICE.md",
        "SOURCE_AUTHORITY_SERVICE.md",
        "REFLOW_ENGINE.md",
        "CLOSURE_ENGINE.md",
        "LOCAL_RUNTIME_TRUST_SERVICE.md",
    ]
    issues = []
    for rel in files:
        path = ARCH_ROOT / rel if rel == "FEATURE_SERVICE_BOUNDARIES.md" else FEATURE_SERVICES_ROOT / rel
        text = read_text(path)
        if "Forbidden" not in text and rel != "FEATURE_SERVICE_BOUNDARIES.md":
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("feature-service-boundary.json"), report)
    return report


def validate_adrs() -> dict[str, Any]:
    files = list(DECISIONS_ROOT.glob("ADR-*.md"))
    issues = []
    for path in files:
        text = path.read_text()
        if "2026-05-14" not in text:
            issues.append(path.name)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("adr-check.json"), report)
    return report


def validate_source_proof_receipt() -> dict[str, Any]:
    gate = read_text(GATES_ROOT / "SOURCE_PROOF_RECEIPT_COVERAGE_GATE.md")
    matrix = read_text(TRACE_ROOT / "SOURCE_PROOF_RECEIPT_COVERAGE_MATRIX.yaml")
    issues = []
    for marker in ["source", "proof", "receipt", "correction", "stale", "missing", "local-only"]:
        if marker not in gate.lower() and marker not in matrix.lower():
            issues.append(marker)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": 2}
    write_json(report_path("source-proof-receipt-coverage.json"), report)
    return report


def validate_local_first_runtime_trust() -> dict[str, Any]:
    gate = read_text(GATES_ROOT / "LOCAL_FIRST_RUNTIME_TRUST_GATE.md")
    matrix = read_text(TRACE_ROOT / "LOCAL_FIRST_RUNTIME_TRUST_MATRIX.yaml")
    issues = []
    for marker in ["no external/cloud LLM", "inspectable", "reset preview", "forget preview", "no hidden automation", "source authority"]:
        if marker.lower() not in gate.lower() and marker.lower() not in matrix.lower():
            issues.append(marker)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": 2}
    write_json(report_path("local-first-runtime-trust.json"), report)
    return report


def validate_performance_budgets() -> dict[str, Any]:
    files = [
        "TODAY_RENDER_BUDGET.md",
        "CAPTURE_LATENCY_BUDGET.md",
        "TIME_LIFESHAPE_RENDER_BUDGET.md",
        "WIDGET_SNAPSHOT_BUDGET.md",
        "LOCAL_RUNTIME_COMPUTE_BUDGET.md",
    ]
    issues = []
    for rel in files:
        text = read_text(PERF_ROOT / rel)
        if "do not claim measured performance" not in text.lower():
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("performance-budget.json"), report)
    return report


def validate_authority_ledgers() -> dict[str, Any]:
    files = [
        "DESIGN_SYSTEM_AUTHORITY_LEDGER.md",
        "TOKEN_SOURCE_AUTHORITY_LEDGER.md",
        "COMPONENT_CONTRACT_AUTHORITY_LEDGER.md",
        "PROMPT_SOURCE_CANON_AUTHORITY_LEDGER.md",
    ]
    issues = []
    for rel in files:
        text = read_text(TRACE_ROOT / rel)
        if "Classification" not in text and "classifies" not in text.lower():
            issues.append(rel)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": len(files)}
    write_json(report_path("authority-ledger.json"), report)
    return report


def validate_design_to_source_trace() -> dict[str, Any]:
    md = read_text(TRACE_ROOT / "DESIGN_TO_SOURCE_TRACEABILITY.md")
    yaml = read_text(TRACE_ROOT / "DESIGN_TO_SOURCE_TRACEABILITY.yaml")
    issues = []
    for marker in ["source-present", "unproven", "debt", "validator_coverage", "known_drift"]:
        if marker not in md and marker not in yaml:
            issues.append(marker)
    report = {"status": "green" if not issues else "red", "issues": issues, "files_checked": 2}
    write_json(report_path("design-to-source-trace.json"), report)
    return report


def collect_status_map() -> dict[str, str]:
    result: dict[str, str] = {}
    for path in REPORTS_ROOT.glob("*.json"):
        try:
            payload = json.loads(path.read_text())
            result[path.stem] = payload.get("status", "missing")
        except json.JSONDecodeError:
            result[path.stem] = "missing"
    return result


def render_dashboard() -> tuple[dict[str, Any], str]:
    status_by_file = collect_status_map()
    remaining_red = [name for name, status in status_by_file.items() if status == "red"]
    overall = "green" if not remaining_red else "red"
    payload = {
        "status": overall,
        "token_pipeline_status": status_by_file.get("design-token-generation", "missing"),
        "generated_swift_token_status": status_by_file.get("design-token-drift", "missing"),
        "component_contract_status": status_by_file.get("component-contract-check", "missing"),
        "preview_matrix_status": status_by_file.get("preview-matrix", "missing"),
        "visual_regression_readiness_status": status_by_file.get("visual-regression-readiness", "missing"),
        "accessibility_contract_status": status_by_file.get("accessibility-contract", "missing"),
        "state_machine_contract_status": status_by_file.get("state-machine-contract", "missing"),
        "dependency_boundary_status": status_by_file.get("dependency-boundary", "missing"),
        "feature_service_boundary_status": status_by_file.get("feature-service-boundary", "missing"),
        "adr_status": status_by_file.get("adr-check", "missing"),
        "source_proof_receipt_status": status_by_file.get("source-proof-receipt-coverage", "missing"),
        "local_first_runtime_trust_status": status_by_file.get("local-first-runtime-trust", "missing"),
        "performance_budget_status": status_by_file.get("performance-budget", "missing"),
        "authority_ledger_status": status_by_file.get("authority-ledger", "missing"),
        "design_to_source_trace_status": status_by_file.get("design-to-source-trace", "missing"),
        "implementation_proof_boundary": "not claimed",
        "release_accessibility_device_proof": "not claimed",
        "remaining_red_flags": remaining_red,
    }
    lines = [
        "# Design System 15 Systems Dashboard",
        "",
        f"Status: {overall.upper()}",
        "",
        "## Summary",
        "",
    ]
    for key in [
        "token_pipeline_status",
        "generated_swift_token_status",
        "component_contract_status",
        "preview_matrix_status",
        "visual_regression_readiness_status",
        "accessibility_contract_status",
        "state_machine_contract_status",
        "dependency_boundary_status",
        "feature_service_boundary_status",
        "adr_status",
        "source_proof_receipt_status",
        "local_first_runtime_trust_status",
        "performance_budget_status",
        "authority_ledger_status",
        "design_to_source_trace_status",
        "implementation_proof_boundary",
        "release_accessibility_device_proof",
    ]:
        lines.append(f"- {key}: {payload[key]}")
    lines.append("")
    lines.append(f"- remaining_red_flags: {remaining_red}")
    return payload, "\n".join(lines)


def write_dashboard() -> dict[str, Any]:
    payload, markdown = render_dashboard()
    write_json(report_path("design-system-15-systems-dashboard.json"), payload)
    write_text(report_path("design-system-15-systems-dashboard.md"), markdown)
    return payload


def command_map() -> dict[str, Any]:
    return {
        "token_generate": validate_token_generation,
        "token_contract_check": validate_token_contracts,
        "token_drift_check": validate_token_drift,
        "component_contract_check": validate_component_contracts,
        "preview_matrix_check": validate_preview_matrix,
        "visual_regression_readiness_check": validate_visual_regression_readiness,
        "accessibility_contract_check": validate_accessibility_contracts,
        "state_machine_contract_check": validate_state_machines,
        "dependency_boundary_check": validate_dependency_boundaries,
        "feature_service_boundary_check": validate_feature_services,
        "adr_check": validate_adrs,
        "source_proof_receipt_check": validate_source_proof_receipt,
        "local_first_runtime_trust_check": validate_local_first_runtime_trust,
        "performance_budget_check": validate_performance_budgets,
        "authority_ledger_check": validate_authority_ledgers,
        "design_to_source_trace_check": validate_design_to_source_trace,
        "dashboard": write_dashboard,
        "generate_all": generate_all,
    }


def cli(command: str) -> int:
    result = command_map()[command]()
    if isinstance(result, dict):
        return 0 if result.get("status", "green") != "red" else 1
    return 0
