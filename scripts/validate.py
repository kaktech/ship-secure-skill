#!/usr/bin/env python3
"""Validate the Ship Secure skill against Anthropic's documented Agent Skills rules.

Usage: python3 scripts/validate.py [skill_dir]
Exit code: 0 = valid (warnings allowed), 1 = errors.
Stdlib only.
"""
import os
import re
import sys

NAME_MAX, DESC_MAX, BODY_MAX_DOCS, BODY_MAX_OURS = 64, 1024, 500, 150
RESERVED = ("anthropic", "claude")
EXPECTED_STACKS = ["nextjs", "express-node", "django", "laravel", "fastapi", "supabase", "firebase", "mobile-api"]
EXPECTED_SCRIPTS = ["scan-secrets.sh", "check-headers.sh", "audit-deps.sh", "validate.py", "package.sh"]
EXPECTED_FILES = [
    "SKILL.md", "README.md", "CHANGELOG.md", "LICENSE", "CONTRIBUTING.md",
    "references/audit-prompt.md", "references/build-rules.md", "references/report-template.md",
    "references/beyond-the-list.md", "examples/example-report.md", "examples/example-build-mode.md",
    "tests/test-cases.md", "tests/checklist.md",
]

errors, warnings = [], []
err = errors.append
warn = warnings.append


def parse_frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    fm = {}
    for line in m.group(1).splitlines():
        if re.match(r"^[A-Za-z_-]+:", line):
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip().strip("\"'")
    return fm, text[m.end():]


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
    skill_md = os.path.join(root, "SKILL.md")
    if not os.path.isfile(skill_md):
        err("SKILL.md not found at skill root")
        return report()
    text = open(skill_md, encoding="utf-8").read()
    fm, body = parse_frontmatter(text)
    if fm is None:
        err("SKILL.md: missing or malformed YAML frontmatter (needs --- delimiters)")
        return report()

    # name
    name = fm.get("name", "")
    if not name:
        err("frontmatter: 'name' missing")
    else:
        if name != "ship-secure":
            err(f"frontmatter: name must be exactly 'ship-secure' (got '{name}')")
        if len(name) > NAME_MAX:
            err(f"name longer than {NAME_MAX} chars")
        if not re.fullmatch(r"[a-z0-9-]+", name):
            err("name must contain only lowercase letters, numbers, hyphens")
        if any(r in name for r in RESERVED):
            err("name contains a reserved word (anthropic/claude)")
        if "<" in name or ">" in name:
            err("name contains XML tags")
    if os.path.basename(root) != "ship-secure":
        warn(f"folder is named '{os.path.basename(root)}', expected 'ship-secure'")

    # description
    desc = fm.get("description", "")
    if not desc:
        err("frontmatter: 'description' missing or empty")
    else:
        if len(desc) > DESC_MAX:
            err(f"description is {len(desc)} chars, max {DESC_MAX}")
        if re.search(r"<[^>]+>", desc):
            err("description contains XML-like tags")
        if re.search(r"\b(I can|I will|you can use)\b", desc, re.I):
            err("description must be third person")
        for phrase in ["security audit", "pre-launch check", "is this safe to launch", "review security", "harden my app", "ship secure"]:
            if phrase not in desc.lower():
                err(f"description missing trigger phrase: '{phrase}'")
        if not re.search(r"auth|database|upload|payment", desc, re.I):
            warn("description does not mention build-mode triggers")
    extra = set(fm) - {"name", "description"}
    if extra:
        warn(f"extra frontmatter keys (not in docs): {sorted(extra)}")

    # size
    nlines = len(text.splitlines())
    if nlines > BODY_MAX_DOCS:
        err(f"SKILL.md is {nlines} lines; docs recommend < {BODY_MAX_DOCS}")
    elif nlines > BODY_MAX_OURS:
        err(f"SKILL.md is {nlines} lines; project limit is < {BODY_MAX_OURS}")

    # required files
    for rel in EXPECTED_FILES:
        if not os.path.isfile(os.path.join(root, rel)):
            err(f"missing file: {rel}")
    cl_dir = os.path.join(root, "references", "checklist")
    cl = sorted(f for f in os.listdir(cl_dir)) if os.path.isdir(cl_dir) else []
    nums = [f[:2] for f in cl]
    if nums != [f"{i:02d}" for i in range(1, 21)]:
        err(f"checklist must contain files 01..20 exactly once; found {cl}")
    for s in EXPECTED_STACKS:
        if not os.path.isfile(os.path.join(root, "references", "stacks", s + ".md")):
            err(f"missing stack file: references/stacks/{s}.md")
    for s in EXPECTED_SCRIPTS:
        p = os.path.join(root, "scripts", s)
        if not os.path.isfile(p):
            err(f"missing script: scripts/{s}")
        elif not os.access(p, os.X_OK):
            err(f"script not executable: scripts/{s} (chmod +x)")
    lic = os.path.join(root, "LICENSE")
    if os.path.isfile(lic) and "MIT License" not in open(lic, encoding="utf-8").read():
        err("LICENSE is not MIT")

    # links from SKILL.md: all resolve, and every reference file is linked directly (one level deep)
    linked = set(re.findall(r"`((?:references|examples|scripts)/[A-Za-z0-9_./-]+)`", body))
    for rel in sorted(linked):
        if not os.path.exists(os.path.join(root, rel)):
            err(f"SKILL.md references missing path: {rel}")
    for dirpath, _, files in os.walk(os.path.join(root, "references")):
        for f in files:
            rel = os.path.relpath(os.path.join(dirpath, f), root).replace(os.sep, "/")
            if rel not in linked:
                err(f"{rel} is not linked from SKILL.md (references must be one level deep)")

    # reference files: forward slashes, TOC when > 100 lines, no nested reference chains
    for dirpath, _, files in os.walk(os.path.join(root, "references")):
        for f in files:
            p = os.path.join(dirpath, f)
            t = open(p, encoding="utf-8").read()
            rel = os.path.relpath(p, root)
            if f == "audit-prompt.md":
                continue  # stored verbatim; do not edit to add a TOC
            if len(t.splitlines()) > 100 and not re.search(r"^## Contents", t, re.M):
                err(f"{rel}: over 100 lines without a '## Contents' table of contents")
            if "\\" in re.sub(r"```.*?```|`[^`]*`", "", t, flags=re.S) and re.search(r"[A-Za-z]\\[A-Za-z]", t):
                warn(f"{rel}: possible Windows-style path")

    # safety statements must be present
    low = text.lower()
    for needle, label in [("penetration test", "pen-test disclaimer"), ("never print secret", "no-secret-printing rule"),
                          ("rotate", "rotation rule"), ("force-pushing", "ask-before-force-push rule"),
                          ("staging", "local/staging-only rule")]:
        if needle not in low:
            err(f"SKILL.md missing {label}")

    # stand-in notice
    ap = os.path.join(root, "references", "audit-prompt.md")
    if os.path.isfile(ap):
        apt = open(ap, encoding="utf-8").read()
        if "STAND-IN NOTICE" in apt:
            warn("references/audit-prompt.md is still a drafted STAND-IN; replace with the original prompt")
        for must in ["# PRE-LAUNCH SECURITY AUDIT", "READY FOR LAUNCH", "NOT READY FOR LAUNCH", "20. DEPENDENCY SECURITY"]:
            if must not in apt:
                err(f"references/audit-prompt.md missing expected text: {must}")
    rt = os.path.join(root, "references", "report-template.md")
    if os.path.isfile(rt):
        rtt = open(rt, encoding="utf-8").read()
        if len(re.findall(r"^## \d+\. ", rtt, re.M)) != 20:
            err("report-template.md must contain 20 numbered '## N. ' sections")

    # no real-looking secrets in the shipped skill (sample project is excluded on purpose)
    pat = re.compile(r"AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|[sr]k_live_[A-Za-z0-9]{16,}|-----BEGIN [A-Z ]*PRIVATE KEY-----")
    for dirpath, dirs, files in os.walk(root):
        if "vulnerable-sample" in dirpath or "__pycache__" in dirpath or ".git" in dirpath.split(os.sep):
            continue
        for f in files:
            p = os.path.join(dirpath, f)
            if f.endswith((".zip", ".pyc")):
                continue
            try:
                t = open(p, encoding="utf-8").read()
            except (UnicodeDecodeError, OSError):
                continue
            if f == "validate.py":
                continue
            if pat.search(t):
                err(f"{os.path.relpath(p, root)}: contains a real-looking secret")
    return report()


def report():
    for w in warnings:
        print(f"WARN  {w}")
    for e in errors:
        print(f"ERROR {e}")
    if errors:
        print(f"FAILED: {len(errors)} error(s), {len(warnings)} warning(s)")
        return 1
    print(f"PASSED: 0 errors, {len(warnings)} warning(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
