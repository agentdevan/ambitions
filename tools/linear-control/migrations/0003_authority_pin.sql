ALTER TABLE deliveries ADD COLUMN authority_pinned_at TEXT;

UPDATE deliveries
SET authority_pinned_at = received_at
WHERE authority_commit IS NOT NULL AND authority_pinned_at IS NULL;
