export const MANIFEST_SCHEMA_VERSION = 1 as const;

export type LifecyclePhase =
  | "Proposed"
  | "Researching"
  | "Scoping"
  | "Designing"
  | "Grooming"
  | "Building"
  | "Validating"
  | "Completed"
  | "Canceled";

export type IssueState =
  | "Backlog"
  | "Ready For Codex"
  | "Blocked"
  | "In Progress"
  | "In Review"
  | "Needs Repair"
  | "Done"
  | "Canceled"
  | "Duplicate"
  | "Won’t Do";

export interface DocumentContract {
  kind: "research" | "scope" | "design" | "plan" | "tasks" | "verification";
  path: string;
  revision: string;
  status: string;
  sha256: string;
  byteLength: number;
}

export interface ProofContract {
  required: readonly string[];
  validationCommands: readonly string[];
  rollback: string;
}

export interface TaskContract {
  id: string;
  canonicalKey: string;
  title: string;
  body: string;
  projectSlug: string;
  order: number;
  dependencies: readonly string[];
  sharedPaths: readonly string[];
  proof: ProofContract;
  frontendImpact: "none" | "affected" | "unclassified";
  visualGate: "not-required" | "required" | "approved" | "unclassified";
  globalRank?: number;
  parallelGroup?: string;
}

export interface ProjectContract {
  slug: string;
  canonicalKey: string;
  name: string;
  folder: string;
  primaryInitiative?: string;
  documents: readonly DocumentContract[];
  tasks: readonly TaskContract[];
  projectDependencies: readonly string[];
  sharedPaths: readonly string[];
  frontendAudit: {
    status: "passed" | "blocked";
    visualGate: "not-required" | "required" | "approved" | "unclassified";
    firstFrontendTaskKey?: string;
  };
  admission: "ready" | "pending";
  admissionBlockers: readonly string[];
}

export interface DesiredWorkspaceManifest {
  schemaVersion: typeof MANIFEST_SCHEMA_VERSION;
  authorityCommit: string;
  compileProvenanceCommit?: string;
  contractHash: string;
  projects: readonly ProjectContract[];
  schedule: readonly ScheduleGroup[];
}

export interface TaskProofEvidence {
  source?: "github" | "receipt";
  authorityCommit: string;
  mergedToMain: boolean;
  proofPassed: boolean;
  requiredProofFailed: boolean;
  issueIdentifier?: string;
  pullRequestUrl?: string;
  mergeCommitSha?: string;
}

export interface ScheduleGroup {
  id: string;
  projectSlugs: readonly string[];
  taskKeys: readonly string[];
}

export interface CurrentIssue {
  id: string;
  identifier: string;
  canonicalKey?: string;
  state: IssueState;
  projectSlug?: string;
  labels: readonly string[];
  blockedBy: readonly string[];
  branchName?: string;
  pullRequestUrl?: string;
  mergedToMain: boolean;
  proofPassed: boolean;
  requiredProofFailed: boolean;
  frontendAffected?: boolean;
  frontendContractPassed?: boolean;
  visualGateRequired?: boolean;
  visualGateApproved?: boolean;
}

export interface CurrentProject {
  id: string;
  slug: string;
  phase: LifecyclePhase;
  labels: readonly string[];
  issueIds: readonly string[];
}

export interface CurrentWorkspace {
  projects: readonly CurrentProject[];
  issues: readonly CurrentIssue[];
}

export type MutationKind =
  "create" | "update" | "delete" | "relation" | "document";

export interface Mutation {
  idempotencyKey: string;
  kind: MutationKind;
  objectType: string;
  canonicalKey: string;
  reason: string;
  desiredHash: string;
  payload: Readonly<Record<string, unknown>>;
  deletionEvidence?: DeletionEvidence;
}

export interface ReconciliationPlan {
  authorityCommit: string;
  desiredHash: string;
  mutations: readonly Mutation[];
  exceptions: readonly ControlException[];
}

export interface DeletionEvidence {
  disposition: "duplicate" | "superseded" | "invalid";
  replacementKey?: string;
  zeroUniqueValue: boolean;
  commentsInspected: boolean;
  attachmentsInspected: boolean;
  descendantsInspected: boolean;
  inboundRelationsInspected: boolean;
  referencesRepaired: boolean;
  activeWorkPreserved: boolean;
  canonicalTruthPreserved: boolean;
}

export interface ControlException {
  canonicalKey?: string;
  category: "drift" | "capability" | "authority" | "unsafe" | "delivery";
  severity: "warning" | "error";
  summary: string;
}

export interface EventEnvelope {
  schemaVersion: 1;
  deliveryId: string;
  source: "linear" | "github" | "scheduled" | "manual";
  authorityCommit?: string;
  authorityPinnedAt?: string;
  receivedAt: string;
  payload: unknown;
}
