#!/usr/bin/env bash
# Runs the Ship Secure scripts against tests/vulnerable-sample and asserts the expected findings.
# Usage: bash tests/run-script-tests.sh     (from the skill root)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLE="$ROOT/tests/vulnerable-sample"
TMP="$(mktemp -d)"; trap 'kill "${SRV:-0}" 2>/dev/null; rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
ok()   { echo "PASS  $1"; PASS=$((PASS+1)); }
bad()  { echo "FAIL  $1"; FAIL=$((FAIL+1)); }
expect() { # name, haystack, needle
  printf '%s' "$2" | grep -q -- "$3" && ok "$1" || bad "$1 (missing: $3)"
}
reject() { printf '%s' "$2" | grep -q -- "$3" && bad "$1 (leaked: $3)" || ok "$1"; }

echo "--- scan-secrets.sh on sample copy with git history ---"
cp -R "$SAMPLE" "$TMP/app"; cd "$TMP/app" || exit 1
git init -q . && git config user.email t@t && git config user.name t
printf 'STRIPE_KEY=sk_%s_FAKEHISTORYFAKEHISTORY99\n' live > .env  # built at runtime: no key-shaped literal ships
git add -A && git commit -qm "oops committed env" && git rm -q --cached .env && rm .env && git commit -qm "remove env"
OUT=$(bash "$ROOT/scripts/scan-secrets.sh" . 2>&1); RC=$?
[ "$RC" = 1 ] && ok "exit code 1 when findings" || bad "exit code was $RC"
expect "finds AWS key in file"      "$OUT" "AWS access key"
expect "finds Stripe key in file"   "$OUT" "Stripe live key"
expect "finds GitHub token"         "$OUT" "GitHub token"
expect "finds JWT in client code"   "$OUT" "client.js"
expect "finds URL credentials"      "$OUT" "URL with credentials"
expect "finds hard-coded password"  "$OUT" "Hard-coded credential"
expect "finds secret in history"    "$OUT" "rev "
expect "history warns to rotate"    "$OUT" "LEAKED"
expect ".env in history flagged"    "$OUT" "Sensitive file in history"
reject "never prints full AWS key"      "$OUT" "AKIA""IOSFODNN7EXAMPLE"
reject "never prints full Stripe key"   "$OUT" "FAKEFAKEFAKEFAKE12345678"
reject "never prints history secret"    "$OUT" "FAKEHISTORYFAKEHISTORY99"
reject "never prints password value"    "$OUT" "SuperSecretPassw0rd"
cd "$ROOT"
CLEAN="$TMP/clean"; mkdir "$CLEAN"; printf 'console.log("hi")\n' > "$CLEAN/a.js"; printf '.env*\n' > "$CLEAN/.gitignore"
bash scripts/scan-secrets.sh "$CLEAN" >/dev/null 2>&1 && ok "clean dir exits 0" || bad "clean dir should exit 0"

echo "--- check-headers.sh against local insecure server ---"
PORT=$((20000 + RANDOM % 20000))
python3 "$SAMPLE/server.py" "$PORT" & SRV=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do curl -s -o /dev/null "http://127.0.0.1:$PORT/" && break; sleep 0.3; done
OUT=$(bash scripts/check-headers.sh "http://127.0.0.1:$PORT/" 2>&1); RC=$?
[ "$RC" = 1 ] && ok "headers: exit 1 on missing" || bad "headers: exit was $RC"
expect "reports missing CSP"        "$OUT" "MISSING  Content-Security-Policy"
expect "reports missing nosniff"    "$OUT" "MISSING  X-Content-Type-Options"
expect "reports Server banner"      "$OUT" "PRESENT  Server"
expect "reports X-Powered-By"       "$OUT" "PRESENT  X-Powered-By"
expect "reports weak cookie"        "$OUT" "WEAK     cookie 'sid'"
OUT=$(bash scripts/check-headers.sh "https://example.com" 2>&1); RC=$?
[ "$RC" = 2 ] && expect "refuses remote without flag" "$OUT" "refusing" || bad "remote guard did not trigger (rc=$RC)"

echo "--- audit-deps.sh detection and error handling ---"
OUT=$(bash "$ROOT/scripts/audit-deps.sh" "$SAMPLE" 2>&1 </dev/null); RC=$?
expect "detects npm project"        "$OUT" "npm-family"
expect "no lockfile: says SKIPPED"  "$OUT" "SKIPPED"
expect "no lockfile: suggests flag" "$OUT" "create-lockfile"
[ "$RC" = 3 ] && ok "no lockfile: exit 3 (could not run)" || bad "no lockfile exit was $RC"
[ -z "$(find "$SAMPLE" -name package-lock.json)" ] && ok "sample not modified by audit" || bad "audit created a lockfile in sample"
# Stub npm so each outcome is deterministic and offline.
BIN="$TMP/bin"; mkdir -p "$BIN" "$TMP/proj"; printf '{"name":"p","version":"1.0.0"}' > "$TMP/proj/package.json"; printf '{}' > "$TMP/proj/package-lock.json"
cat > "$BIN/npm" <<'STUB'
#!/usr/bin/env bash
case "${STUB_MODE:-}" in
  clean) echo "found 0 vulnerabilities"; exit 0;;
  vuln)  echo "lodash  <=4.17.23"; echo "Severity: high"; echo "1 high severity vulnerability"; exit 1;;
  eacces) echo "npm error code EACCES"; echo "npm error Your cache folder contains root-owned files"; exit 1;;
  offline) echo "npm error code ENOTFOUND"; echo "npm error network request failed"; exit 1;;
  lockfail) echo "npm error code EACCES"; exit 1;;
esac
STUB
chmod +x "$BIN/npm"
run_deps() { STUB_MODE="$1" PATH="$BIN:$PATH" bash "$ROOT/scripts/audit-deps.sh" "$TMP/proj" "${@:2}" 2>&1; }
OUT=$(run_deps clean); RC=$?;  [ "$RC" = 0 ] && ok "clean audit: exit 0" || bad "clean exit $RC"
OUT=$(run_deps vuln);  RC=$?;  [ "$RC" = 1 ] && ok "vulnerabilities: exit 1" || bad "vuln exit $RC"
expect "vulnerabilities: output shown"  "$OUT" "Severity: high"
reject "vulnerabilities: not 'could not run'" "$OUT" "could not run"
OUT=$(run_deps eacces); RC=$?; [ "$RC" = 3 ] && ok "EACCES: exit 3" || bad "EACCES exit $RC"
expect "EACCES: npm error is shown"     "$OUT" "root-owned files"
expect "EACCES: says could not run"     "$OUT" "audit could not run"
expect "EACCES: gives chown hint"       "$OUT" "chown"
expect "EACCES: offers temp cache"      "$OUT" "NPM_CONFIG_CACHE"
OUT=$(run_deps offline); RC=$?; [ "$RC" = 3 ] && ok "offline: exit 3" || bad "offline exit $RC"
expect "offline: network hint"          "$OUT" "network access"
rm -f "$TMP/proj/package-lock.json"
OUT=$(run_deps lockfail --create-lockfile); RC=$?; [ "$RC" = 3 ] && ok "lockfile creation failure: exit 3" || bad "lockfail exit $RC"
expect "lockfile failure: npm error shown" "$OUT" "npm error code EACCES"
expect "lockfile failure: explained"       "$OUT" "could not create a lockfile"
OUT=$(bash "$ROOT/scripts/audit-deps.sh" --bogus 2>&1); RC=$?; [ "$RC" = 2 ] && ok "unknown flag: exit 2" || bad "bogus flag exit $RC"

echo "--- validate.py ---"
python3 "$ROOT/scripts/validate.py" "$ROOT" >/dev/null && ok "validate.py passes" || bad "validate.py failed"

echo; echo "Passed: $PASS  Failed: $FAIL"; [ "$FAIL" = 0 ]
