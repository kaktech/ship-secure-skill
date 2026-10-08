# 4. Row-Level Security

## What to check
- List every table in exposed schemas. Check RLS is enabled on each (Postgres: `relrowsecurity`; Supabase dashboard; Firebase rules for Firestore/Storage).
- Read each policy: scoped per operation to `auth.uid()` or tenant; no `USING (true)` on private data; `WITH CHECK` present for insert/update.
- Check views and SECURITY DEFINER functions that bypass RLS.

## How to fix
- `ALTER TABLE t ENABLE ROW LEVEL SECURITY;` then explicit policies for select, insert, update, delete.
- Add `WITH CHECK` so users cannot write rows they could not read.
- Default deny: no policy means no access. Use `security_invoker` views.

## How to verify
- On staging, use two test users. As user A, try to read, update, and delete user B's rows with the public key: expect denied.
- Anonymous request with the public key: expect denied on private tables.
- Record SQL or request used and results.
