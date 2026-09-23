-- Supabase SQL Editorで実行してください。何度実行しても安全です。

create table if not exists public.travel_memory_photos (
  id uuid primary key default gen_random_uuid(),
  day text not null,
  image_url text not null,
  created_at timestamptz not null default now()
);

alter table public.travel_memory_photos enable row level security;

insert into storage.buckets (id, name, public)
values ('travel-memories', 'travel-memories', true)
on conflict (id) do update set public = true;

drop policy if exists "Anyone can view travel memories" on public.travel_memory_photos;
drop policy if exists "Anyone can add travel memories" on public.travel_memory_photos;
drop policy if exists "Anyone can delete travel memory records" on public.travel_memory_photos;
drop policy if exists "Anyone can upload travel memory files" on storage.objects;
drop policy if exists "Anyone can view travel memory files" on storage.objects;
drop policy if exists "Anyone can delete travel memory files" on storage.objects;

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

create policy "Anyone can delete travel memory files"
on storage.objects for delete
to anon
using (bucket_id = 'travel-memories');

create policy "Anyone can delete travel memory records"
on public.travel_memory_photos for delete
to anon
using (true);
