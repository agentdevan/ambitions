CREATE TABLE IF NOT EXISTS deliveries (
  id TEXT PRIMARY KEY,
  source TEXT NOT NULL,
  schema_version INTEGER NOT NULL,
  payload_hash TEXT NOT NULL,
  status TEXT NOT NULL,
  authority_commit TEXT,
  attempts INTEGER NOT NULL DEFAULT 0,
  received_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  last_error TEXT
);

CREATE TABLE IF NOT EXISTS runs (
  id TEXT PRIMARY KEY,
  delivery_id TEXT,
  mode TEXT NOT NULL,
  authority_commit TEXT NOT NULL,
  desired_hash TEXT NOT NULL,
  status TEXT NOT NULL,
  mutation_count INTEGER NOT NULL DEFAULT 0,
  started_at TEXT NOT NULL,
  completed_at TEXT,
  error TEXT,
  FOREIGN KEY (delivery_id) REFERENCES deliveries(id)
);

CREATE TABLE IF NOT EXISTS object_mappings (
  canonical_key TEXT PRIMARY KEY,
  linear_id TEXT NOT NULL UNIQUE,
  object_type TEXT NOT NULL,
  authority_commit TEXT NOT NULL,
  desired_hash TEXT NOT NULL,
  verified_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS mutation_receipts (
  id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL,
  canonical_key TEXT NOT NULL,
  operation TEXT NOT NULL,
  before_hash TEXT,
  desired_hash TEXT NOT NULL,
  result_hash TEXT,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL,
  verified_at TEXT,
  error TEXT,
  FOREIGN KEY (run_id) REFERENCES runs(id)
);

CREATE TABLE IF NOT EXISTS exceptions (
  id TEXT PRIMARY KEY,
  canonical_key TEXT,
  category TEXT NOT NULL,
  severity TEXT NOT NULL,
  summary TEXT NOT NULL,
  first_seen_at TEXT NOT NULL,
  last_seen_at TEXT NOT NULL,
  resolved_at TEXT
);

CREATE TABLE IF NOT EXISTS metric_snapshots (
  id TEXT PRIMARY KEY,
  captured_at TEXT NOT NULL,
  authority_commit TEXT NOT NULL,
  payload_json TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_deliveries_status ON deliveries(status, updated_at);
CREATE INDEX IF NOT EXISTS idx_receipts_run ON mutation_receipts(run_id, created_at);
CREATE INDEX IF NOT EXISTS idx_exceptions_open ON exceptions(resolved_at, severity);
