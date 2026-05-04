#!/usr/bin/env bash
set -u
echo "ldi-handling-lane-scan: canonical handling lane coverage"
status=0
lanes=(parked_thought clarification_needed quick_step project_plan dream_scaffold source_backed_plan regulated_plan professional_boundary_scaffold north_star_extraction unsafe_blocked crisis_support source_stale_review source_conflict_review impossible_timeline_review conflict_review privacy_sensitive_plan sync_recovery unsupported_domain_exploration source_check_first user_review_required local_only_private_plan)
for lane in "${lanes[@]}"; do
  if ! rg -q "\b$lane\b" docs/canon/AmbitionsOS_Dream_Handling_Lanes_And_Ladder.md docs/canon/AmbitionsOS_Living_Dream_Architecture_Index.md; then
    echo "RED: canonical lane missing from LDI canon: $lane"
    status=1
  fi
done
if [[ "$status" -eq 0 ]]; then
  echo "PASS: all canonical LDI handling lanes are present in source truth."
fi
exit "$status"
