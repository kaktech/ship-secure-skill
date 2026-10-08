#!/usr/bin/env bash
# Ship Secure: detect package managers and run the matching dependency audit.
# Usage: bash audit-deps.sh [path] [--create-lockfile]   (path default: current directory)
#   --create-lockfile  for npm projects with no lockfile, run `npm install --package-lock-only`
#                      (writes package-lock.json only; ask the user first).
# Read-only otherwise: never runs `audit fix`.
# Tool errors are shown in full, with a hint for common causes.
# Exit code: 0 = clean, 1 = vulnerabilities found, 3 = audit could not run (tool missing, no lockfile, cache or network error), 2 = bad usage.

set -u
ROOT="."; CREATE_LOCK=0; ARGS="$*"
for a in "$@"; do
  case "$a" in
    --create-lockfile) CREATE_LOCK=1;;
    -*) echo "error: unknown option '$a'" >&2; exit 2;;
    *) ROOT="$a";;
  esac
done
[ -d "$ROOT" ] || { echo "error: '$ROOT' is not a directory" >&2; exit 2; }
VULN=0; BLOCKED=0; RAN=0

dirs() { find "$ROOT" \( -name node_modules -o -name .git -o -name venv -o -name .venv -o -name vendor \) -prune -o -type f -name "$1" -print 2>/dev/null | xargs -I{} dirname {} | sort -u; }

# Print a hint for known tool failures. $1 = captured output.
hint() {
  case "$1" in
    *EACCES*|*"root-owned"*)
      echo "  HINT: npm cannot write its cache (usually root-owned files left by an old 'sudo npm')."
      echo "        Fix it: sudo chown -R \$(id -u):\$(id -g) ~/.npm     (not run for you)"
      echo "        Or retry with a throwaway cache: NPM_CONFIG_CACHE=\$(mktemp -d) bash $0 $ARGS";;
    *ENOLOCK*) echo "  HINT: npm audit needs a lockfile. Re-run with --create-lockfile after the user agrees.";;
    *ENOTFOUND*|*EAI_AGAIN*|*ETIMEDOUT*|*ECONNREFUSED*|*"network"*|*"ECONNRESET"*)
      echo "  HINT: the audit needs network access to the registry/advisory service. Check connectivity or proxy settings.";;
    *"command not found"*) echo "  HINT: a required tool is missing. Install it and re-run.";;
  esac
}

# run_audit <label> <command...>: run in the current dir, show output, classify the result.
run_audit() {
  label="$1"; shift
  out=$("$@" 2>&1); rc=$?
  [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/  /'
  [ "$rc" = 0 ] && return 0
  # Tool failure (not a vulnerability report) when the output carries an error code or no advisory data.
  if printf '%s' "$out" | grep -qE 'npm (error|ERR!) code E[A-Z]+|EACCES|ENOLOCK|ENOTFOUND|EAI_AGAIN|ETIMEDOUT|ECONNREFUSED|ECONNRESET|command not found|No such file|Traceback'; then
    echo "  >> $label: audit could not run (exit $rc). The error above is the tool's own output."
    hint "$out"; BLOCKED=1
  else
    VULN=1
  fi
}

# audit_in <dir> <label> <command...>: run_audit inside <dir>; propagate VULN/BLOCKED out of the subshell.
audit_in() {
  dir="$1"; shift; st=$(mktemp)
  ( cd "$dir" && VULN=0 && BLOCKED=0 && run_audit "$@"; echo "$VULN $BLOCKED" > "$st" )
  read -r v b < "$st"; rm -f "$st"
  [ "$v" = 1 ] && VULN=1; [ "$b" = 1 ] && BLOCKED=1
  return 0
}

for d in $(dirs package.json); do
  RAN=1; echo "== npm-family: $d =="
  if [ -f "$d/pnpm-lock.yaml" ] && command -v pnpm >/dev/null; then audit_in "$d" pnpm pnpm audit
  elif [ -f "$d/yarn.lock" ] && command -v yarn >/dev/null; then audit_in "$d" yarn yarn audit
  elif command -v npm >/dev/null; then
    if [ ! -f "$d/package-lock.json" ] && [ ! -f "$d/npm-shrinkwrap.json" ]; then
      if [ "$CREATE_LOCK" = 1 ]; then
        echo "  Creating package-lock.json (npm install --package-lock-only)..."
        lockout=$(cd "$d" && npm install --package-lock-only 2>&1); lrc=$?
        printf '%s\n' "$lockout" | sed 's/^/  /'
        if [ "$lrc" != 0 ] || [ ! -f "$d/package-lock.json" ]; then
          echo "  >> could not create a lockfile (exit $lrc). The error above is npm's own output."
          hint "$lockout"; BLOCKED=1; continue
        fi
      else
        echo "  SKIPPED: no package-lock.json, so npm cannot audit."
        hint "ENOLOCK"; BLOCKED=1; continue
      fi
    fi
    audit_in "$d" npm npm audit --audit-level=low
  else echo "  npm not installed"; BLOCKED=1; fi
done

for d in $(dirs requirements.txt) $(dirs pyproject.toml); do
  RAN=1; echo "== python: $d =="
  if command -v pip-audit >/dev/null; then
    if [ -f "$d/requirements.txt" ]; then audit_in "$d" pip-audit pip-audit -r requirements.txt; else audit_in "$d" pip-audit pip-audit; fi
  else echo "  pip-audit not found. Install in a venv (python3 -m venv .venv && .venv/bin/pip install pip-audit), then re-run."; BLOCKED=1; fi
done

for d in $(dirs composer.json); do
  RAN=1; echo "== composer: $d =="
  if command -v composer >/dev/null; then
    audit_in "$d" composer composer audit
  else echo "  composer not installed"; BLOCKED=1; fi
done

[ "$RAN" = 0 ] && { echo "No package.json, requirements.txt, pyproject.toml, or composer.json found."; exit 0; }
if [ "$BLOCKED" = 1 ]; then echo "RESULT: audit could not run for at least one project (see errors above)$([ "$VULN" = 1 ] && echo '; vulnerabilities also found in others')"; exit 3; fi
if [ "$VULN" = 1 ]; then echo "RESULT: vulnerabilities found"; exit 1; fi
echo "RESULT: no known vulnerabilities"; exit 0
