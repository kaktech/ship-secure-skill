# Contributing

Thanks for helping. Keep the skill short, accurate, and safe.

## Rules
- `SKILL.md` stays under 150 lines. Put detail in `references/` and link it directly from `SKILL.md` (one level deep).
- Reference files over 100 lines need a `## Contents` section.
- Plain imperative language. No filler. Do not explain what Claude already knows.
- Every checklist file keeps three sections: What to check, How to fix, How to verify. Verification must be something runnable.
- Never add a real secret, even in examples. Use fake values and keep them inside `tests/vulnerable-sample`.
- Scripts must be read-only by default, never print full secret values, and never touch production.
- Use forward slashes in paths. Name files by content.

## Adding a stack
Create `references/stacks/<name>.md` covering: where secrets live, session/cookie config, RLS or rules, middleware for headers and rate limits, validation library, upload handling, HTTPS settings. Link it in `SKILL.md` and add it to `EXPECTED_STACKS` in `scripts/validate.py`.

## Before opening a PR
```bash
python3 scripts/validate.py
bash tests/run-script-tests.sh
```
Then walk `tests/checklist.md`. Add a scenario to `tests/test-cases.md` for new behavior and a line to `CHANGELOG.md`.

## Reporting a vulnerability in this skill
Open a private security advisory on the repository. Do not post exploit details in public issues.
