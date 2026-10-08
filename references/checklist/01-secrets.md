# 1. Hide API keys

## What to check
- Run `bash scripts/scan-secrets.sh .` and review hits (values are masked).
- Grep client code and build output for keys: `NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `EXPO_PUBLIC_` vars holding secrets.
- Check `.gitignore` covers `.env*`; check Dockerfiles, CI files, mobile configs, and `*.json` service-account files.

## How to fix
- Move secrets to server-side env vars or a secret manager. Reference them by name only.
- Add `.env*` to `.gitignore`, keep `.env.example` with empty values.
- If a client needs a third-party call, proxy it through a server route.
- Any key that was in the client bundle or repo is leaked: tell the user to rotate it.

## How to verify
- Re-run the scan: zero unmasked-secret findings in tracked files.
- Build the client and grep the output directory for the key prefixes found earlier.
- Confirm the app still starts with env vars supplied.
