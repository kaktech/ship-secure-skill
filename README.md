# Ship Secure

An open-source Agent Skill that makes Claude write secure code by default and run a full 20-point pre-launch security audit on request.

> Ship Secure does not replace a professional penetration test. It catches common, high-impact mistakes. It is not proof that an app is secure.

## What it does
- **Build mode (automatic).** When you ask Claude to build or change auth, APIs, database access, forms, uploads, payments, sessions, or deploy config, it applies `references/build-rules.md` and adds a short "Security controls applied" note. Pure UI work gets no extra friction.
- **Audit mode (on request).** Say "security audit", "pre-launch check", "is this safe to launch", "review security", "harden my app", or "ship secure". Claude inspects the codebase, fixes gaps, tests each fix, and writes a report with a status for all 20 items.

### The 20 items
1 Hide API keys, 2 Purge Git secrets, 3 Public/client DB key used correctly, 4 Row-Level Security, 5 Encrypt sensitive data, 6 Server-side authN/authZ, 7 Lock down record access (IDOR/BOLA), 8 Block field tampering, 9 Secure session cookies, 10 Secure password hashing, 11 Login rate limiting, 12 Bot/abuse protection, 13 Parameterized queries, 14 Validate all input, 15 Escape/sanitize user content (XSS), 16 Restrict file uploads, 17 Trim API responses, 18 Security headers, 19 Force HTTPS, 20 Scan and fix vulnerable dependencies.
It also checks CSRF, SSRF, privilege escalation, race conditions, and business-logic flaws.

## Install
Build the zip, or use the folder directly.
```bash
bash scripts/package.sh            # writes ../ship-secure.zip (root folder: ship-secure/)
```
- **claude.ai:** Settings > Features > upload `ship-secure.zip` (needs code execution enabled).
- **Claude Code:** copy the folder to `~/.claude/skills/ship-secure` (personal) or `.claude/skills/ship-secure` (project).
- **API:** upload through the Skills API (`/v1/skills`).
Skills do not sync across these surfaces; install on each.

## Safety rules built in
- Secret values are never printed. Reports show file and line with the value masked.
- Exploit-style tests run only against local or staging, never production.
- Claude asks before force-pushing, rewriting Git history, or rotating credentials.
- Any committed secret must be rotated; deleting it is not enough.

## Layout
```
ship-secure/
  SKILL.md                short core instructions (loads first)
  references/             loaded on demand: build rules, 20 checklist files, 8 stack files, report template
  scripts/                scan-secrets, check-headers, audit-deps, validate.py, package.sh
  examples/               sample audit report, sample build-mode result
  tests/                  test cases, release checklist, intentionally vulnerable sample + script tests
```

## Scripts
```bash
bash scripts/scan-secrets.sh .                         # files + Git history, values masked
bash scripts/check-headers.sh http://localhost:3000     # add --allow-remote only for staging
bash scripts/audit-deps.sh .                            # npm / pip-audit / composer audit (exit 0 clean, 1 vulns, 3 could not run)
python3 scripts/validate.py                             # checks this skill's structure
bash tests/run-script-tests.sh                          # runs the scripts against tests/vulnerable-sample
```
Requirements: bash, git, curl, python3 (stdlib only). `pip-audit`, `npm`, `composer` are used when present; the audit script never installs anything.

## Assumptions
1. `references/audit-prompt.md` is the maintainer's original audit prompt, stored verbatim. The report format (`PASS/PARTIAL/FAIL`, `READY FOR LAUNCH / READY WITH MINOR FIXES / NOT READY FOR LAUNCH`) follows it; the prompt's "VERIFIED" maps to PASS, and NOT APPLICABLE is allowed with a reason.
2. The skill name is `ship-secure` and the frontmatter has only `name` and `description` (the documented fields).
3. SKILL.md is kept under 150 lines (docs allow 500); all references are one level deep, as the docs recommend.
4. "NOT READY FOR LAUNCH" is forced by a FAIL on items 1-8, 10, or 13. This is a judgment call; edit `SKILL.md` to change it.
5. Stack files are concise patterns, current as of the CHANGELOG date. Check them against framework docs before relying on them.
6. `tests/vulnerable-sample` contains fake secrets and is left out of the zip.

## Limits
Static review plus targeted local tests cannot find everything. Get a professional penetration test before handling sensitive data or payments at scale.

## License
MIT. See `LICENSE`. Contributions: see `CONTRIBUTING.md`.
