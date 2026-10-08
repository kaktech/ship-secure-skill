# Report template

## Contents
- The exact report structure (20 numbered sections plus four closing sections)
- Rules

Copy this structure exactly. Heading text, field labels, and the three final values come from `audit-prompt.md`.
Allowed Status values: `PASS`, `PARTIAL`, `FAIL`, plus `NOT APPLICABLE (reason)` when an item does not apply.
(The prompt's "VERIFIED" for already-correct items maps to `PASS`: only use PASS after a test proved it.)

```markdown
# PRE-LAUNCH SECURITY AUDIT

## 1. Hide API Keys
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 2. Purge Git Secrets
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 3. Use the Public/Client DB Key Correctly
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 4. Enable Row-Level Security (RLS)
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 5. Encrypt Sensitive Data
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 6. Enforce Server-Side Authentication/Authorization
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 7. Lock Down Record Access
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 8. Prevent/Block Field Tampering
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 9. Secure Session Cookies
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 10. Hash Passwords Securely
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 11. Rate-Limit Login Attempts
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 12. Add Bot/Abuse Protection
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 13. Parameterize Database Queries
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 14. Validate ALL Input
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 15. Escape/Sanitize User-Generated Content
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 16. Restrict File Uploads
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 17. Trim/Minimize API Responses
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 18. Add Security Headers
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 19. Force HTTPS
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## 20. Scan and Fix Vulnerable Dependencies
Status: PASS / PARTIAL / FAIL / NOT APPLICABLE (reason)
What I found:
What I changed:
How I verified it:

## Critical Issues Remaining
List ONLY issues that genuinely still require action. Include "rotate these credentials" for any committed secret (by file:line and commit, never by value). Write "None" if empty.

## Files Changed
| File | Change |
|---|---|

## Tests Performed
| Test | Target | Result |
|---|---|---|

## Final Launch Assessment
READY FOR LAUNCH | READY WITH MINOR FIXES | NOT READY FOR LAUNCH
```

## Rules
- Fill every item; do not drop or merge items.
- Mask secrets. Cite `file:line`.
- Put the beyond-the-list findings (CSRF, SSRF, privilege escalation, race conditions, business logic, auth bypass) in the relevant item or in Critical Issues Remaining; add a short "Additional findings" list under Critical Issues Remaining if needed.
- After the assessment add one line: "Ship Secure does not replace a professional penetration test."
- Show an example in `examples/example-report.md`.
