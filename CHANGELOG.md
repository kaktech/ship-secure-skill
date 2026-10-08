# Changelog

## [0.1.0] - 2026-10-08
### Added
- Initial release: build mode and audit mode, 20 checklist files, 8 stack files, beyond-the-list guide, report template.
- Scripts: `scan-secrets.sh`, `check-headers.sh`, `audit-deps.sh`, `validate.py`, `package.sh`.
- Examples, test cases, release checklist, intentionally vulnerable sample with script tests.
### Changed
- `audit-deps.sh` shows the tool's own error output, classifies failures (cache permissions, offline, missing lockfile, missing tool) with hints, and exits 3 when the audit could not run instead of reporting vulnerabilities. New opt-in `--create-lockfile`.
- `references/audit-prompt.md` holds the maintainer's original prompt verbatim; report template, example report, and statuses aligned to it.
