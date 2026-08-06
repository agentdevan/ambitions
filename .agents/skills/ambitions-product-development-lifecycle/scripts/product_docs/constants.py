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
        "Frontend impact investigation",
        "Recommended direction",
    ),
    "scope": (
        "Outcome",
        "In scope",
        "Out of scope",
        "Requirements",
        "Acceptance criteria",
        "Frontend impact contract",
        "Canon impact",
        "Risks and open decisions",
    ),
    "design": (
        "Design summary",
        "User flows",
        "States and recovery",
        "Frontend experience specification",
        "Architecture and data",
        "Privacy and accessibility",
        "Requirement traceability",
        "Verification design",
        "Open decisions",
    ),
}
