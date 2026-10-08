# 2. Purge Git secrets

## What to check
- `bash scripts/scan-secrets.sh .` scans current files and the full Git history (`git log -p --all`).
- Check for committed `.env`, `*.pem`, `id_rsa`, `credentials.json`, service-account JSON.

## How to fix
- Rotate every secret found in history FIRST. Removal does not un-leak it.
- Ask the user before rewriting history. If approved, use `git filter-repo` (or BFG) on a fresh clone, then force-push. Ask again before the force-push, and warn collaborators must re-clone.
- Add a pre-commit secret scan (gitleaks or the bundled script).

## How to verify
- Re-run the history scan on the rewritten repo: no findings.
- Record in the report that rotation is required, listing secrets by file and commit, never by value.
