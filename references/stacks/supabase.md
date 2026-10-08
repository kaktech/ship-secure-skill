# Supabase

## Keys
- Client: `anon` key only. `service_role` bypasses RLS: server/edge functions only, never in `NEXT_PUBLIC_*`/`VITE_*`/mobile apps.

## RLS (item 4)
```sql
alter table public.notes enable row level security;
create policy "own select" on public.notes for select using (auth.uid() = user_id);
create policy "own insert" on public.notes for insert with check (auth.uid() = user_id);
create policy "own update" on public.notes for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own delete" on public.notes for delete using (auth.uid() = user_id);
```
- Check every table in `public`: `select relname, relrowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and relkind='r';`
- Views: `create view ... with (security_invoker = true)`. `SECURITY DEFINER` functions: set `search_path`, check `auth.uid()` inside.
- Never base authorization on `user_metadata` (user-editable); use `app_metadata` or a roles table.
- Storage: add policies on `storage.objects` per bucket; make buckets private unless public by design.

## Auth and sessions
- Use `@supabase/ssr` for cookie sessions. Server: `supabase.auth.getUser()` (validates), not `getSession()`, for authorization.
- Dashboard: enable email confirmation, set password policy, CAPTCHA (Turnstile/hCaptcha) on signup, and rate limits.

## Edge functions
- Verify JWT (default on). Validate input with zod. Keep secrets via `supabase secrets set`.

## Verify
- Two test users on staging with the anon key: cross-user select/update/delete must fail. Run the Supabase security advisor.
