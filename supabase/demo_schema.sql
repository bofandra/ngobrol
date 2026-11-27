-- Run only in a disposable development Supabase project.
-- Shared posts are public to authenticated players; never store confidential data.
create table public.demo_posts (
  id uuid primary key default gen_random_uuid(),
  topic_id text not null check (topic_id in ('shell', 'transport', 'heat')),
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  kind text not null check (kind in ('Question','Answer','Suggestion')),
  body text not null check (char_length(btrim(body)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index demo_posts_topic_time on public.demo_posts(topic_id, created_at);
alter table public.demo_posts enable row level security;
revoke all on public.demo_posts from public, anon, authenticated;
grant select on public.demo_posts to authenticated;
grant insert (topic_id, author_id, kind, body) on public.demo_posts to authenticated;
create policy "Authenticated demo players read posts" on public.demo_posts
  for select to authenticated using (true);
create policy "Players insert only their own posts" on public.demo_posts
  for insert to authenticated with check ((select auth.uid()) = author_id);
-- No client update or delete. Admin moderation and abuse controls are next steps.
