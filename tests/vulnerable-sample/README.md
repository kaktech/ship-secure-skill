# vulnerable-sample

INTENTIONALLY INSECURE. All secrets are fake. Never deploy. Used only by `tests/run-script-tests.sh`
and by the scenarios in `tests/test-cases.md`. Excluded from `ship-secure.zip`.

| Flaw | Where | Checklist item |
|---|---|---|
| Hard-coded keys | `src/config.js` | 1 |
| `.env` committed (then deleted in test git history) | created by test runner | 2 |
| Service-role key in client code | `src/client.js` | 3 |
| Table without RLS | `db/schema.sql` | 4 |
| IDOR on `/api/notes/:id` | `src/app.js` | 7 |
| Mass assignment on `/api/register` | `src/app.js` | 8 |
| Insecure session cookie | `src/app.js`, `server.py` | 9 |
| MD5 passwords | `src/app.js` | 10 |
| No login rate limit | `src/app.js` | 11 |
| SQL injection | `src/app.js` | 13 |
| Stored XSS sink | `src/client.js` | 15 |
| Weak upload | `src/app.js` | 16 |
| Full-row responses | `src/app.js` | 17 |
| No security headers / no HTTPS redirect | `server.py` | 18, 19 |
| Vulnerable dependency (old lodash) | `package.json` | 20 |
