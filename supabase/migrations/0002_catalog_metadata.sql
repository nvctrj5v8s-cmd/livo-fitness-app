-- Catalog provenance and recipe detail fields.
-- Run after 0001_livo_schema.sql before importing external catalog data.
alter table public.foods add column if not exists source_url text;
alter table public.foods add column if not exists source_license text;
alter table public.foods add column if not exists source_attribution text;
alter table public.foods add column if not exists data_quality text not null default 'unreviewed';
alter table public.foods add column if not exists verified_at timestamptz;
alter table public.recipes add column if not exists instructions text[] not null default '{}';
alter table public.recipes add column if not exists source text not null default 'curated';
alter table public.recipes add column if not exists source_url text;
alter table public.recipes add column if not exists source_license text;
alter table public.recipes add column if not exists source_attribution text;
alter table public.foods drop constraint if exists foods_data_quality_check;
alter table public.foods add constraint foods_data_quality_check
  check (data_quality in ('unreviewed', 'imported', 'reviewed'));
create index if not exists foods_source_idx on public.foods (source);
create index if not exists foods_quality_idx on public.foods (data_quality);
