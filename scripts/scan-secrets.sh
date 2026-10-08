#!/usr/bin/env bash
# Ship Secure: scan files and Git history for leaked secrets.
# Usage: bash scan-secrets.sh [path]   (default: current directory)
# Output: type, file:line (or rev:file:line), and a MASKED value (first 4 chars + ****).
# Exit code: 0 = no findings, 1 = findings, 2 = bad usage.
# Read-only. Never prints a full secret value.

set -u
TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo "error: '$TARGET' is not a directory" >&2; exit 2; }
cd "$TARGET" || exit 2

US=$(printf '\037')
# NAME<US>ERE. Keep patterns specific to limit false positives.
PATTERNS=(
  "AWS access key${US}AKIA[0-9A-Z]{16}"
  "Private key block${US}-----BEGIN ((RSA|EC|DSA|OPENSSH|PGP) )?PRIVATE KEY"
  "GitHub token${US}gh[pousr]_[A-Za-z0-9]{36,}"
  "Slack token${US}xox[baprs]-[A-Za-z0-9-]{10,}"
  "Stripe live key${US}[sr]k_live_[A-Za-z0-9]{16,}"
  "Google API key${US}AIza[0-9A-Za-z_-]{35}"
  "Secret key (sk-...)${US}sk-[A-Za-z0-9_-]{20,}"
  "JWT${US}eyJ[A-Za-z0-9_-]{10,}\\.eyJ[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}"
  "URL with credentials${US}[a-zA-Z][a-zA-Z0-9+.-]*://[^:/[:space:]\"']+:[^@/[:space:]\"']{3,}@[^[:space:]\"']+"
  "Hard-coded credential${US}(password|passwd|secret|api[_-]?key|access[_-]?token|auth[_-]?token)[A-Za-z_]*[\"']?[[:space:]]*[:=][[:space:]]*[\"'][^\"'\$[:space:]{}]{8,}[\"']"
)
EXCLUDES=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build
  --exclude-dir=.next --exclude-dir=vendor --exclude-dir=venv --exclude-dir=.venv
  --exclude-dir=__pycache__ --exclude=package-lock.json --exclude=yarn.lock --exclude=pnpm-lock.yaml
  --exclude=composer.lock --exclude=*.min.js --exclude=*.map)

FOUND=0
mask() { # stdin: prefix fields..., last field is the matched text. $1 = label
  awk -v label="$1" -F: '{
    m=$0; n=split($0, p, ":");
    # file:line:match  (match may contain colons) -> rebuild
    f=p[1]; l=p[2]; sub("^" f ":" l ":", "", m);
    printf "  [%s] %s:%s  value=%s****\n", label, f, l, substr(m,1,4)
  }'
}

echo "== Current files =="
for entry in "${PATTERNS[@]}"; do
  name="${entry%%${US}*}"; re="${entry#*${US}}"
  out=$(grep -rIn -o -E "${EXCLUDES[@]}" -e "$re" . 2>/dev/null | sed 's#^\./##')
  if [ -n "$out" ]; then FOUND=1; echo "$out" | mask "$name"; fi
done

echo "== Sensitive files =="
SENS=$(find . \( -name node_modules -o -name .git -o -name venv -o -name .venv \) -prune -o -type f \
  \( -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.p12' -o -name '*.pfx' -o -name 'id_rsa' \
     -o -name 'id_ed25519' -o -name 'credentials.json' -o -name 'serviceAccount*.json' -o -name '*-firebase-adminsdk-*.json' \
     -o -name '.npmrc' -o -name '.pypirc' \) -print 2>/dev/null | sed 's#^\./##' | grep -v -E '\.(example|sample|template)$')
if [ -n "$SENS" ]; then
  FOUND=1
  echo "$SENS" | while read -r f; do
    ign="not-git-ignored"
    if git rev-parse --git-dir >/dev/null 2>&1 && git check-ignore -q -- "$f" 2>/dev/null; then ign="git-ignored"; fi
    echo "  [Sensitive file] $f ($ign)"
  done
fi

if git rev-parse --git-dir >/dev/null 2>&1 && git rev-parse HEAD >/dev/null 2>&1; then
  echo "== Git history (all branches, up to 1000 commits) =="
  REVS=$(git rev-list --all 2>/dev/null | head -1000)
  HIST=0
  for entry in "${PATTERNS[@]}"; do
    name="${entry%%${US}*}"; re="${entry#*${US}}"
    # shellcheck disable=SC2086
    out=$(git grep -I -n -o -E -e "$re" $REVS -- . ':!*lock*' ':!*.min.js' 2>/dev/null | head -200)
    if [ -n "$out" ]; then
      HIST=1; FOUND=1
      echo "$out" | awk -v label="$name" -F: '{
        rev=substr($1,1,8); f=$2; l=$3; m=$0; sub("^" $1 ":" f ":" l ":", "", m);
        key=f ":" substr(m,1,4); if (!(key in seen)) { seen[key]=1;
          printf "  [%s] rev %s %s:%s  value=%s****\n", label, rev, f, l, substr(m,1,4) } }'
    fi
  done
  # Sensitive filenames ever committed
  DEL=$(git log --all --name-only --pretty=format: 2>/dev/null | grep -E '(^|/)(\.env|.*\.pem|id_rsa|credentials\.json)$' | sort -u | head -50)
  if [ -n "$DEL" ]; then HIST=1; FOUND=1; echo "$DEL" | sed 's/^/  [Sensitive file in history] /'; fi
  if [ "$HIST" = 1 ]; then
    echo "  !! Secrets exist in Git history. Treat them as LEAKED: rotate them. Deleting from current files is not enough."
    echo "  !! Ask the user before rewriting history or force-pushing."
  fi
else
  echo "== Git history: skipped (not a Git repo or no commits) =="
fi

echo "== .gitignore check =="
if [ -f .gitignore ] && grep -qE '^\.env(\*|\.\*)?$|^\.env\*' .gitignore; then echo "  .env is git-ignored"
else echo "  WARN: .gitignore does not ignore .env files"; fi

[ "$FOUND" = 1 ] && { echo "RESULT: findings present"; exit 1; }
echo "RESULT: no findings"; exit 0
