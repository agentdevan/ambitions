# AmbitionsOS Dream Handling Lanes And Ladder

<!-- markdownlint-disable MD013 -->

Status: Canonical future handling-lane source truth. This document does not claim runtime implementation.

## Handling Rule

Every capture/dream must land in exactly one primary lane and may have secondary lane flags. The lane is a handling outcome, not proof that a plan exists.

| Lane | Use | Boundary |
| --- | --- | --- |
| `parked_thought` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `clarification_needed` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `quick_step` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `project_plan` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `dream_scaffold` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `source_backed_plan` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `regulated_plan` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `professional_boundary_scaffold` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `north_star_extraction` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `unsafe_blocked` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `crisis_support` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `source_stale_review` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `source_conflict_review` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `impossible_timeline_review` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `conflict_review` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `privacy_sensitive_plan` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `sync_recovery` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `unsupported_domain_exploration` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `source_check_first` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `user_review_required` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |
| `local_only_private_plan` | Future LDI canonical lane; use only when source truth and active batch ownership are present. | Must not imply activation or guaranteed plan. |

## Dream Handling Ladder

1. Capture raw input
2. Classify input type
3. Detect seriousness
4. Screen for safety / legality / exploitation / crisis / harm
5. Detect regulated or professional-boundary domains
6. Detect fantasy, impossible, or symbolic intent
7. Check source-pack coverage
8. Check source freshness
9. Check starting-position needs
10. Generate appropriate handling lane
11. Ask for user review before activation
12. Store dream handling receipt
13. Activate only after approval when activation is allowed
14. Track source and user-life dependencies
15. Recompile when source, user, jurisdiction, capacity, or proof changes
16. Ask approval before changing commitments

## Outcome Rules

- Supported and source-backed dreams may become living plans after user review.
- Unsupported dreams become scaffolds or exploration paths.
- Impossible dreams become North Stars.
- Regulated dreams become professional-boundary scaffolds or plans with source and verification boundaries.
- Unsafe dreams are blocked and redirected.
- Crisis-coded inputs receive support and do not enter normal productivity routing.
- Ambiguous inputs receive one-question clarification.
- Commitments never move silently.

## Examples

- Become Batman -> North Star extraction: discipline, protection, justice, capability. Safe paths may include fitness, emergency response, law, cybersecurity, or community safety.
- Become immortal -> North Star extraction: longevity, legacy, impact. Safe paths may include health, family, creative work, estate planning, or research.
- Start a cult -> unsafe-literal redirection and North Star extraction: belonging, influence, community. Safe paths may include ethical community building, nonprofit, club, or brand.
- Time travel -> North Star extraction: curiosity, science, story. Safe paths may include physics, engineering, writing, or game design.
