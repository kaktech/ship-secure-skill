# 5. Encrypt sensitive data

## What to check
- In transit: all traffic TLS (see item 19), including DB and internal service connections.
- At rest: DB/disk encryption enabled; sensitive fields (tokens, national IDs, health or financial data) encrypted at the application level.
- Passwords are hashed, not encrypted (item 10).
- Logs, analytics, error trackers, and URLs contain no sensitive data.

## How to fix
- Use AES-256-GCM or the platform's KMS/field-encryption feature; keys come from a secret manager, never the repo.
- Enable DB-managed encryption and encrypted backups.
- Redact sensitive fields in logs and error reports.

## How to verify
- Inspect the stored value of one sensitive field in the DB: ciphertext, not plaintext.
- Grep logs from a test run for the test PII value: not present.
- Check DB connection string requires SSL.
