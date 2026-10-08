I want you to perform a COMPLETE pre-launch security audit and implementation pass on my application.

Do NOT just tell me what I should do. Inspect the entire codebase, identify what is already implemented, implement/fix anything missing, and then verify every item.

Use the following 20-point checklist as a HARD REQUIREMENT. Do not skip any item:

1. Hide API keys
2. Purge Git secrets
3. Use the public/client DB key correctly
4. Enable Row-Level Security (RLS)
5. Encrypt sensitive data
6. Enforce server-side authentication/authorization
7. Lock down record access
8. Prevent/block field tampering
9. Secure session cookies
10. Hash passwords securely
11. Rate-limit login attempts
12. Add bot/abuse protection
13. Parameterize database queries
14. Validate ALL input
15. Escape/sanitize user-generated content
16. Restrict file uploads
17. Trim/minimize API responses
18. Add security headers
19. Force HTTPS
20. Scan and fix vulnerable dependencies

IMPORTANT:
- Work with the existing architecture and coding style rather than unnecessarily rewriting the application.
- First inspect the project structure, backend, frontend, database configuration, authentication, API routes, middleware, environment variables, file-upload functionality, package dependencies, and deployment configuration.
- Do not assume something is secure just because it appears to work.
- Test/verify each security control after implementing it.
- If something is already correctly implemented, leave it intact and mark it as VERIFIED.
- If something is partially implemented, improve it.
- If something is missing, implement it.
- If something is insecure, replace it with a secure implementation.

SECURITY REQUIREMENTS:

1. API KEYS
- Find all API keys, tokens, credentials, secrets, database credentials, JWT secrets, OAuth secrets, etc.
- Remove secrets from frontend/client-side code.
- Move private secrets to environment variables/server-side configuration.
- Make sure .env files containing secrets are ignored by Git.
- Make sure no secret is exposed through API responses or frontend bundles.
- Do NOT expose service-role/admin database keys to the client.

2. GIT SECRETS
- Search the repository history and current files for accidentally committed secrets.
- Check .gitignore.
- Identify potentially exposed credentials.
- If secrets were committed, explain what needs to be rotated/revoked.
- Do not merely delete the visible secret and claim the problem is solved if it remains in Git history.

3. PUBLIC/CLIENT DATABASE KEY
- If the application uses a database platform such as Supabase, use only the intended public/anonymous client key on the frontend.
- Keep service-role/private/admin keys strictly server-side.
- Verify that public keys cannot bypass authorization or RLS.

4. ROW-LEVEL SECURITY
- Inspect all database tables containing user/application data.
- Enable and properly configure RLS where supported.
- Create policies that enforce the intended ownership/access rules.
- Test that one user cannot access another user's records simply by changing an ID.

5. SENSITIVE DATA
- Identify sensitive information stored by the application.
- Encrypt sensitive data where appropriate.
- Never log passwords, tokens, secrets, or sensitive personal information.
- Do not store passwords in plaintext.

6. SERVER-SIDE AUTHORIZATION
- Never rely only on frontend route guards or hidden UI elements.
- Verify authentication and authorization on the server for every protected operation.
- Check both authentication and ownership/permissions.

7. RECORD ACCESS
- Prevent IDOR/BOLA vulnerabilities.
- For every endpoint that receives an ID, verify the authenticated user is allowed to access that specific record.
- Test unauthorized access attempts.

8. FIELD TAMPERING
- Never trust fields such as userId, role, price, amount, status, permissions, admin flags, etc. supplied by the client.
- Derive security-sensitive values server-side.
- Use allowlists for fields that users are actually permitted to modify.

9. SESSION COOKIES
- Use secure session configuration.
- Set HttpOnly where appropriate.
- Set Secure in production.
- Configure SameSite appropriately.
- Make sure authentication tokens are not unnecessarily exposed to JavaScript/localStorage.

10. PASSWORDS
- Use a modern password hashing algorithm such as Argon2id, bcrypt, or the framework's secure password hashing mechanism.
- Never use plain SHA-256/MD5 for password storage.
- Add appropriate password requirements without making them unreasonable.
- Do not log passwords.

11. LOGIN RATE LIMITING
- Protect login, registration, password reset, OTP and other authentication endpoints against brute-force attacks.
- Implement reasonable rate limits.
- Return safe error messages that do not reveal whether an account exists.

12. BOT/ABUSE PROTECTION
- Identify endpoints vulnerable to automated abuse.
- Add appropriate bot/abuse protection where necessary.
- Do not add unnecessary friction to normal users.

13. PARAMETERIZED QUERIES
- Search the entire backend for SQL/database queries.
- Eliminate SQL injection risks.
- Use parameterized queries, prepared statements, ORM-safe methods, or the database SDK's safe query mechanisms.
- Do not construct SQL queries by directly concatenating user input.

14. INPUT VALIDATION
- Validate ALL user-controlled input on the server.
- Validate type, format, length, range and allowed values.
- Do not rely exclusively on frontend validation.
- Reject unexpected fields where appropriate.

15. USER CONTENT
- Properly escape/sanitize user-generated content before rendering it.
- Prevent XSS.
- Pay special attention to HTML, rich text, URLs, comments, names, descriptions and any content rendered back to users.

16. FILE UPLOADS
- Restrict allowed file types/extensions.
- Validate MIME type and file signatures where appropriate.
- Enforce file-size limits.
- Generate safe filenames.
- Prevent executable files from being uploaded and executed.
- Prevent path traversal.
- Store uploads safely and do not expose sensitive files publicly.
- Review image/document upload handling carefully.

17. API RESPONSES
- Return only the fields the client actually needs.
- Do not accidentally return passwords, password hashes, internal IDs, tokens, secrets, admin information, database metadata or sensitive personal information.
- Review every major API endpoint for excessive data exposure.

18. SECURITY HEADERS
Configure appropriate production security headers, including where applicable:
- Content-Security-Policy
- Strict-Transport-Security
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy
- Frame protections / clickjacking protection

Do this in a way compatible with the application's actual frontend/backend architecture.

19. HTTPS
- Ensure production traffic is HTTPS.
- Redirect HTTP to HTTPS where appropriate.
- Ensure cookies marked Secure work correctly in production.
- Check for mixed-content problems.
- Do not hardcode insecure HTTP endpoints where HTTPS is available.

20. DEPENDENCY SECURITY
- Inspect package.json/package-lock.json or equivalent dependency files.
- Identify outdated or vulnerable dependencies.
- Run the appropriate package-manager security audit.
- Upgrade vulnerable dependencies where it is safe to do so.
- Be careful not to introduce breaking changes without checking compatibility.

AFTER IMPLEMENTATION:

Create a final security audit report with this exact structure:

# PRE-LAUNCH SECURITY AUDIT

## 1. Hide API Keys
Status: PASS / PARTIAL / FAIL
What I found:
What I changed:
How I verified it:

...repeat for all 20 items...

## Critical Issues Remaining
List ONLY issues that genuinely still require action.

## Files Changed
List every file you modified and briefly explain the change.

## Tests Performed
List the security tests/checks you ran and their results.

## Final Launch Assessment
Give one of:
- READY FOR LAUNCH
- READY WITH MINOR FIXES
- NOT READY FOR LAUNCH

Do not mark something PASS simply because you added code. Verify that the implementation actually works.

MOST IMPORTANT:
Treat this as an actual security audit, not a checklist exercise. Look for vulnerabilities beyond the exact wording of the 20 items, especially:
- authentication bypass
- authorization bypass
- IDOR/BOLA
- SQL injection
- XSS
- CSRF
- SSRF
- privilege escalation
- insecure direct object access
- exposed secrets
- excessive data exposure
- insecure file uploads
- weak session management
- race conditions
- business-logic vulnerabilities

Before making major architectural changes, understand how the existing application works and preserve existing functionality.

Start by inspecting the entire project and then work through the 20 requirements systematically.\
