"""Stable version-one contracts for lifecycle documents."""

from __future__ import annotations

SKILL_NAME = "ambitions-product-development-lifecycle"
SKILL_VERSION = "1.0.0"
PYTHON_MIN_VERSION = (3, 11)
PYTHON_MAX_VERSION = (3, 14)

SKILL_ROOT = ".agents/skills/ambitions-product-development-lifecycle"
TEMPLATES_ROOT = f"{SKILL_ROOT}/assets/templates/v1"
REFERENCES_ROOT = f"{SKILL_ROOT}/references"
DOCUMENTS_ROOT = "docs/product-development"

GENERATED_CANON_PATHS = (
    "docs/canon/generated/CODEX_START_HERE.md",
    "docs/canon/generated/INDEX.md",
    "docs/canon/generated/canon-index.json",
    "docs/canon/generated/requirement-graph.json",
)

ALLOWED_STATUSES = (
    "draft",
    "sealed",
    "content-reviewed",
    "needs-revision",
    "passed",
    "stale",
    "superseded",
)

AUTHORITY_CLASSES = {
    "research": "evidence",
    "scope": "product-commitment",
    "design": "implementation-design",
}

TEMPLATE_PROFILES = {
    "research": (
        "Agent handoff summary",
        "Idea and problem statement",
        "Research questions",
        "Current Ambitions baseline",
        "User and product evidence",
        "Apple platform and ecosystem evidence",
        "Technical feasibility",
        "Privacy and local-first implications",
        "Accessibility implications",
        "Alternatives and tradeoffs",
        "Findings",
        "Recommended direction",
        "Rejected directions",
        "Remaining unknowns",
        "Risk register",
        "Source ledger",
        "Handoff to Scope",
        "Review history",
    ),
    "scope": (
        "Agent handoff summary",
        "Research input and authority",
        "Problem and desired user outcome",
        "Target users and scenarios",
        "In scope",
        "Out of scope",
        "Product requirements",
        "Required states and behaviors",
        "Acceptance criteria",
        "Product invariants",
        "Native Apple constraints",
        "Privacy and data boundaries",
        "Accessibility requirements",
        "Offline, interruption, failure, and recovery expectations",
        "Performance expectations",
        "Dependencies and risks",
        "Measurement and success evidence",
        "Release boundary",
        "Canon impact and proposed canon deltas",
        "Design brief",
        "Open decisions",
        "Review history",
    ),
    "design": (
        "Agent handoff summary",
        "Scope input and authority",
        "Design principles and protected characteristics",
        "User journey and information architecture",
        "Canonical object ownership",
        "State model",
        "Command and consequence model",
        "Screen and presentation behavior",
        "Navigation, focus, dismissal, restoration, keyboard, and safe areas",
        "SwiftUI composition",
        "Domain and service boundaries",
        "Persistence, migration, concurrency, replay, and atomicity",
        "Offline behavior",
        "Privacy and security",
        "Accessibility",
        "Motion, Reduce Motion, Reduce Transparency, contrast, and legibility",
        "Error, interruption, recovery, rollback, and Undo",
        "Performance and diagnostics boundaries",
        "Testing strategy",
        "Visual and runtime proof plan",
        "File and module impact",
        "Current-source delta and legacy deletion",
        "Canon reconciliation plan",
        "Implementation seams and dependency order",
        "Requirement-to-design traceability",
        "Implementation grooming handoff",
        "Open questions",
        "Review history",
    ),
}
