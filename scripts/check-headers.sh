#!/usr/bin/env bash
# Ship Secure: report missing security headers and HTTPS redirect for a URL.
# Usage: bash check-headers.sh <url> [--allow-remote]
# Sends one GET (and one HTTP redirect probe). Non-destructive.
# Non-local hosts need --allow-remote: confirm the target is staging, NOT production.
# Exit code: 0 = all present, 1 = something missing, 2 = bad usage/unreachable.

set -u
URL="${1:-}"; FLAG="${2:-}"
[ -n "$URL" ] || { echo "usage: $0 <url> [--allow-remote]" >&2; exit 2; }
command -v curl >/dev/null || { echo "error: curl not found" >&2; exit 2; }
case "$URL" in http://*|https://*) ;; *) URL="https://$URL";; esac
HOST=$(printf '%s' "$URL" | sed -E 's#^https?://([^/:]+).*#\1#')
case "$HOST" in
  localhost|127.0.0.1|::1|*.local|*.test|*.localhost) ;;
  *) [ "$FLAG" = "--allow-remote" ] || { echo "refusing: $HOST is not local. Re-run with --allow-remote only if it is staging, not production." >&2; exit 2; };;
esac

HDRS=$(curl -sS -D - -o /dev/null --max-time 15 "$URL" 2>&1) || { echo "error: could not reach $URL" >&2; echo "$HDRS" >&2; exit 2; }
# Use the last response block (after redirects, none followed here)
STATUS=$(printf '%s' "$HDRS" | head -1 | tr -d '\r')
echo "URL: $URL"; echo "Status: $STATUS"
MISSING=0
has() { printf '%s\n' "$HDRS" | tr -d '\r' | grep -qi "^$1:"; }
val() { printf '%s\n' "$HDRS" | tr -d '\r' | grep -i "^$1:" | head -1 | cut -d: -f2- | sed 's/^ *//'; }

check() { # header, required-for-https-only(0/1)
  if has "$1"; then echo "  OK       $1"; else
    if [ "${2:-0}" = 1 ] && [ "${URL#https://}" = "$URL" ]; then echo "  SKIP     $1 (only meaningful over HTTPS)"
    else echo "  MISSING  $1"; MISSING=1; fi
  fi
}
echo "Required headers:"
check Content-Security-Policy
check Strict-Transport-Security 1
check X-Content-Type-Options
check Referrer-Policy
check Permissions-Policy
if has X-Frame-Options || val Content-Security-Policy | grep -qi 'frame-ancestors'; then echo "  OK       Clickjacking protection (X-Frame-Options or frame-ancestors)"
else echo "  MISSING  Clickjacking protection (X-Frame-Options or CSP frame-ancestors)"; MISSING=1; fi
if has X-Content-Type-Options && ! val X-Content-Type-Options | grep -qi nosniff; then echo "  WEAK     X-Content-Type-Options should be nosniff"; MISSING=1; fi

echo "Information-leak headers (should be absent):"
for h in Server X-Powered-By X-AspNet-Version; do
  if has "$h"; then echo "  PRESENT  $h: $(val "$h")"; else echo "  OK       $h absent"; fi
done
if val Access-Control-Allow-Origin | grep -q '^\*$'; then echo "  WARN     Access-Control-Allow-Origin: * (fine for public data only)"; fi

echo "Cookies:"
SC=$(printf '%s\n' "$HDRS" | tr -d '\r' | grep -i '^set-cookie:')
if [ -z "$SC" ]; then echo "  (none set on this response)"; else
  printf '%s\n' "$SC" | while read -r line; do
    n=$(printf '%s' "$line" | cut -d: -f2- | sed 's/^ *//' | cut -d= -f1)
    miss=""
    for f in HttpOnly Secure SameSite; do printf '%s' "$line" | grep -qi "$f" || miss="$miss $f"; done
    [ -z "$miss" ] && echo "  OK       cookie '$n' has HttpOnly, Secure, SameSite" || echo "  WEAK     cookie '$n' missing:$miss"
  done
fi

if [ "${URL#https://}" != "$URL" ]; then
  echo "HTTP -> HTTPS redirect:"
  HTTPURL="http://${URL#https://}"
  R=$(curl -sS -o /dev/null -D - --max-time 10 "$HTTPURL" 2>/dev/null | tr -d '\r')
  CODE=$(printf '%s' "$R" | head -1 | awk '{print $2}')
  LOC=$(printf '%s' "$R" | grep -i '^location:' | head -1 | cut -d: -f2- | sed 's/^ *//')
  case "$CODE" in 301|302|307|308) case "$LOC" in https://*) echo "  OK       $CODE -> $LOC";; *) echo "  FAIL     redirects to non-HTTPS: $LOC"; MISSING=1;; esac;;
    "") echo "  SKIP     port 80 not reachable";; *) echo "  FAIL     http:// answered $CODE without redirecting to https"; MISSING=1;; esac
fi
[ "$MISSING" = 1 ] && { echo "RESULT: issues found"; exit 1; }
echo "RESULT: all checks passed"; exit 0
