# Active Code Map

Status: Bootstrap Yellow.

Generated machine reports:

- `build/reports/intelligence-consolidation/active-code-map.json`
- `build/reports/intelligence-consolidation/active-code-map.md`

This audit maps Swift files by broad target membership using `project.yml`, `Package.swift`, and configured source roots. It is conservative and does not claim definitive unused code from text search alone.

Required follow-up: owner review must resolve `UNKNOWN_REQUIRES_OWNER_REVIEW`, rescue candidates, and active-but-weaker candidates before implementation trains can claim Green champion coverage.
