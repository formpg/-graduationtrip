-- Supabase SQL Editorで一度だけ実行してください。
-- Storage画面で travel-memories という公開バケットを作成した後に実行します。

create table if not exists public.travel_memory_photos (
  id uuid primary key default gen_random_uuid(),
  day text not null,
  image_url text not null,
  created_at timestamptz not null default now()
);

alter table public.travel_memory_photos enable row level security;

create policy "Anyone can view travel memories"
on public.travel_memory_photos for select
using (true);

create policy "Anyone can add travel memories"
on public.travel_memory_photos for insert
to anon
with check (true);

create policy "Anyone can upload travel memory files"
on storage.objects for insert
to anon
with check (bucket_id = 'travel-memories');

create policy "Anyone can view travel memory files"
on storage.objects for select
using (bucket_id = 'travel-memories');
