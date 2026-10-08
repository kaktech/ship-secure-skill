# Release checklist (maintainers)

Tick every box before tagging a release.

## Structure
- [ ] `python3 scripts/validate.py` passes with 0 errors
- [ ] `bash scripts/package.sh` produces `ship-secure.zip` with `ship-secure/` at the zip root
- [ ] `SKILL.md` is under 150 lines; frontmatter has only `name` and `description`
- [ ] Description is third person, under 1024 chars, has trigger phrases for both modes
- [ ] Every file under `references/` is linked directly from `SKILL.md`
- [ ] `references/audit-prompt.md` is still the original prompt, unedited

## Scripts
- [ ] `bash tests/run-script-tests.sh` all PASS
- [ ] Scanner output never contains a full secret value
- [ ] `check-headers.sh` refuses non-local hosts without `--allow-remote`
- [ ] `audit-deps.sh` never runs `audit fix`

## Behavior (manual, with real Claude sessions)
- [ ] TC-01 to TC-15 in `tests/test-cases.md` pass
- [ ] Negative cases N1 to N3 do not trigger the skill
- [ ] Tested on Haiku, Sonnet, and Opus
- [ ] Tested on claude.ai upload, Claude Code (`~/.claude/skills/ship-secure`), and API if used

## Content
- [ ] Safety rules present: mask secrets, staging only, ask before history rewrite or rotation, pen-test disclaimer
- [ ] Stack files checked against current framework docs (see CONTRIBUTING)
- [ ] CHANGELOG updated
