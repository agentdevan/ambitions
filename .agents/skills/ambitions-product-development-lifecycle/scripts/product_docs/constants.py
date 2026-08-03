"""Constants for the lightweight product-document lifecycle."""

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

ALLOWED_STATUSES = ("draft", "approved")

TEMPLATE_PROFILES = {
    "research": (
        "Idea and user problem",
        "Current truth",
        "Evidence",
        "Alternatives",
        "Unknowns and risks",
        "Recommended direction",
    ),
    "scope": (
        "Outcome",
        "In scope",
        "Out of scope",
        "Requirements",
        "Acceptance criteria",
        "Canon impact",
        "Risks and open decisions",
    ),
    "design": (
        "Design summary",
        "User flows",
        "States and recovery",
        "Architecture and data",
        "Privacy and accessibility",
        "Requirement traceability",
        "Verification design",
        "Open decisions",
    ),
}
