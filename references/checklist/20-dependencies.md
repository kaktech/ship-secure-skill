# 20. Scan and fix vulnerable dependencies

## What to check
- Run `bash scripts/audit-deps.sh .` (npm audit, pip-audit, composer audit as detected). Exit 3 means the audit did not run: read the printed tool error, fix the cause, and report the item as PARTIAL until it runs. Never report "no vulnerabilities" from a run that exited 3.
- No npm lockfile: with the user's OK, add `--create-lockfile`.
- Check lockfiles are committed; look for abandoned or typosquatted packages and unpinned `latest`.

## How to fix
- Upgrade to patched versions; prefer minimal bumps. Review breaking changes and run tests after each.
- Replace unmaintained packages. Do not use `--force` blindly.
- Add automated updates (Dependabot/Renovate) and CI audit step.

## How to verify
- Re-run the audit: no high or critical findings, or each remaining one is listed with a reason.
- Run the project's tests and build.
