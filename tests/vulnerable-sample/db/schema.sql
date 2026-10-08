-- Postgres / Supabase style. Item 4: RLS never enabled.
create table public.notes (
  id bigserial primary key,
  user_id uuid not null,
  body text,
  ssn text            -- item 5: sensitive data in plaintext
);
grant all on public.notes to anon, authenticated;
