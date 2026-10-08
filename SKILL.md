---
name: ship-secure
description: Applies secure-by-default rules while building web and app features (auth, APIs, database access, forms, file uploads, payments, sessions, deployment config) and runs a full 20-point pre-launch security audit on request. Use when the user asks for a "security audit", "pre-launch check", "is this safe to launch", "review security", "harden my app", or "ship secure", or when writing security-sensitive code. Skip trivial UI work. Does not replace a professional penetration test.
---

# Ship Secure

Two modes. Pick one, load only the files it needs.

## Safety rules (always)
- Never print secret values. Report file and line, mask the value (`sk_l****`).
- Test only against local or staging. Never run exploit tests or load tests against production.
- Ask before force-pushing, rewriting Git history, or rotating credentials.
- If a secret was ever committed, it is compromised. Tell the user to rotate it. Deleting it from current files is not enough.
- State plainly in every audit report: Ship Secure does not replace a professional penetration test.
- Preserve the existing architecture and style. Do not rewrite what works.

## Mode 1: Build (automatic)
Trigger: the task creates or changes auth, APIs, database access, forms, uploads, payments, sessions, or deploy config.

1. Read `references/build-rules.md`.
2. Detect the stack (see Stack files). Read the matching stack file only if the task touches its areas.
3. Write the code with the rules applied.
4. End with a short "Security controls applied" note: 1 line per control, no lecture.

Skip this mode for styling, copy, layout, and other UI-only work. Add no friction there.

## Mode 2: Audit (on request)
Trigger phrases: security audit, pre-launch check, is this safe to launch, review security, harden my app, ship secure.

Copy this checklist and track it:
```
- [ ] 1 Detect stack, read matching stack file
- [ ] 2 Inspect: structure, backend, frontend, DB config, auth, routes, middleware, env vars, uploads, deps, deploy config
- [ ] 3 Run scripts (below) against the repo and a local/staging URL
- [ ] 4 For each of the 20 items: read its checklist file, check, fix what is missing, test the fix
- [ ] 5 Read references/beyond-the-list.md and check those risks
- [ ] 6 Write the report using references/report-template.md
```

Spec: `references/audit-prompt.md` is the authoritative requirement text. If it conflicts with a checklist file, the audit prompt wins.

Status per item: PASS / PARTIAL / FAIL (or NOT APPLICABLE with a reason). The prompt's "mark it VERIFIED" means PASS.
- Never mark PASS because code was added. Run a test that proves it, and record the test.
- If you cannot test it (no running app, no DB access), mark PARTIAL and say what is untested.

Final assessment: READY FOR LAUNCH / READY WITH MINOR FIXES / NOT READY FOR LAUNCH. Any FAIL on items 1-8, 10, 13 means NOT READY FOR LAUNCH.

## Scripts (run, do not read)
- `bash scripts/scan-secrets.sh [path]` secrets in files and Git history, values masked.
- `bash scripts/check-headers.sh <url>` missing security headers and HTTP-to-HTTPS redirect.
- `bash scripts/audit-deps.sh [path]` runs npm, pip, or composer audit as detected. Exit 0 clean, 1 vulnerabilities, 3 could not run (shows the tool's error and a hint). `--create-lockfile` writes a missing npm lockfile: ask the user first.
- `python3 scripts/validate.py` checks this skill's own structure.

## Checklist files (read only the one you are on)
1 `references/checklist/01-secrets.md`
2 `references/checklist/02-git-secrets.md`
3 `references/checklist/03-client-db-key.md`
4 `references/checklist/04-row-level-security.md`
5 `references/checklist/05-encryption.md`
6 `references/checklist/06-server-side-authz.md`
7 `references/checklist/07-idor-bola.md`
8 `references/checklist/08-field-tampering.md`
9 `references/checklist/09-session-cookies.md`
10 `references/checklist/10-password-hashing.md`
11 `references/checklist/11-login-rate-limit.md`
12 `references/checklist/12-bot-abuse.md`
13 `references/checklist/13-parameterized-queries.md`
14 `references/checklist/14-input-validation.md`
15 `references/checklist/15-xss.md`
16 `references/checklist/16-file-uploads.md`
17 `references/checklist/17-api-responses.md`
18 `references/checklist/18-security-headers.md`
19 `references/checklist/19-https.md`
20 `references/checklist/20-dependencies.md`

## Other references
- `references/beyond-the-list.md` CSRF, SSRF, privilege escalation, race conditions, business logic.
- `references/report-template.md` exact report structure (`# PRE-LAUNCH SECURITY AUDIT`). Mirror it.
- `examples/example-report.md`, `examples/example-build-mode.md` only if the output format is unclear.

## Stack files (load one, at most two)
Detect from package.json, requirements.txt, composer.json, manage.py, firebase.json, supabase/ and similar.
- Next.js: `references/stacks/nextjs.md`
- Express/Node: `references/stacks/express-node.md`
- Django: `references/stacks/django.md`
- Laravel: `references/stacks/laravel.md`
- FastAPI: `references/stacks/fastapi.md`
- Supabase: `references/stacks/supabase.md`
- Firebase: `references/stacks/firebase.md`
- Mobile app talking to an API: `references/stacks/mobile-api.md`
