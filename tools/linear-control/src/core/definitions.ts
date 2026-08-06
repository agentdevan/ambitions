export const OPERATIONAL_VIEWS = [
  { name: "Now", purpose: "Current-cycle executable and active work" },
  { name: "Parallel Wave", purpose: "The active dependency-safe Project pair" },
  {
    name: "Critical Path",
    purpose: "Open blockers on the longest dependency chain",
  },
  { name: "Next Up", purpose: "Next-cycle dependency-ready work" },
  {
    name: "Proof Queue",
    purpose: "Merged or reviewed work awaiting required proof",
  },
  {
    name: "External Gates",
    purpose: "Open gate:external or gate:owner-decision work",
  },
  { name: "Drift", purpose: "sync:stale and controller exceptions" },
  { name: "Portfolio Health", purpose: "At Risk and Off Track Projects" },
  { name: "Closeout", purpose: "Projects at M5/M6 requiring completion" },
] as const;

export const CONTROLLED_TEMPLATES = [
  "Lifecycle Project",
  "Plan Task",
  "Unplanned Intake",
  "Validation / Repair",
  "External Gate / Owner Decision",
  "Accepted Yellow Follow-up",
  "Closeout",
] as const;
