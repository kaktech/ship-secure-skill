# 10. Secure password hashing

## What to check
- Find where passwords are stored and verified. Flag MD5, SHA-1, SHA-256 without KDF, reversible encryption, plaintext, home-grown schemes.
- Check cost parameters and constant-time comparison.

## How to fix
- Use argon2id (preferred), bcrypt (cost >= 12), or scrypt via the framework's hasher.
- Rehash on login for legacy hashes. Enforce a minimum length (>= 8, prefer 12) and allow long passphrases.
- Never log passwords or reset tokens.

## How to verify
- Create a test user; inspect the stored hash prefix (`$argon2id$`, `$2b$`, `scrypt`).
- Unit test: correct password verifies, wrong one fails.
