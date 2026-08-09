ALTER TABLE mutation_receipts ADD COLUMN evidence_json TEXT;
ALTER TABLE mutation_receipts ADD COLUMN reconciliation_key TEXT;

CREATE INDEX IF NOT EXISTS idx_receipts_reconciliation
  ON mutation_receipts(reconciliation_key, status, created_at);
