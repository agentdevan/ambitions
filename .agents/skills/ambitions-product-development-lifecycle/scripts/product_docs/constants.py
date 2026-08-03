"""Constants for the lightweight product-document lifecycle."""

from __future__ import annotations

SKILL_ROOT = ".agents/skills/ambitions-product-development-lifecycle"
DOCUMENTS_ROOT = "docs/product-development"

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
