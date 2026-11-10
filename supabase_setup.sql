-- =====================================================================
--  BEAT RESOURCE MAPPING – DATABASE SETUP (run once)
--  Supabase → SQL Editor → New query → paste ALL of this → Run
--  Supabase → SQL Editor → New query → यह पूरा पेस्ट करें → Run दबाएँ
--  Safe to run again (already ran the old version? just run this again).
-- =====================================================================

-- 1) Main table / मुख्य तालिका ------------------------------------------
create table if not exists public.resources (
  id               bigint generated always as identity primary key,
  created_at       timestamptz not null default now(),
  client_uid       uuid unique,                 -- prevents duplicate offline re-sends
  client_time      timestamptz,
  category         text not null,
  place_name       text not null,
  ps_name          text not null,
  beat_no          text not null,
  beat_name        text,
  latitude         double precision not null check (latitude between -90 and 90),
  longitude        double precision not null check (longitude between -180 and 180),
  gps_accuracy     double precision,
  location_source  text,                        -- 'gps' or 'manual'
  address          text,
  contact_person   text,
  contact_phone    text,
  sensitivity      text not null default 'normal',
  remarks          text,
  photo_path       text,
  staff_name       text not null,
  staff_mobile     text,
  verified         boolean not null default false
);
create index if not exists resources_ps_beat_idx on public.resources (ps_name, beat_no);
create index if not exists resources_cat_idx     on public.resources (category);
create index if not exists resources_created_idx on public.resources (created_at desc);

-- 2) Staff PIN / स्टाफ पिन ---------------------------------------------------
create table if not exists public.app_settings (
  key   text primary key,
  value text not null
);
-- Starting staff PIN = 1234. After login, change it from the dashboard
-- ("🔑 Staff PIN" button). शुरुआती पिन 1234 है – डैशबोर्ड से बदलें।
insert into public.app_settings (key, value) values ('entry_code', '1234')
on conflict (key) do nothing;

-- 3) Officers who can open the dashboard / डैशबोर्ड देखने वाले अधिकारी ------
create table if not exists public.officers (
  email text primary key,
  name  text
);
-- >>> PUT YOUR EMAIL HERE / अपना ईमेल यहाँ डालें <<<
insert into public.officers (email, name) values ('your.email@example.com', 'SP Office')
on conflict (email) do nothing;

-- 4) Security (Row Level Security) ---------------------------------------
alter table public.resources    enable row level security;
alter table public.app_settings enable row level security;   -- nobody can read it from the website
alter table public.officers     enable row level security;   -- nobody can read it from the website

create or replace function public.is_officer()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.officers
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
grant execute on function public.is_officer() to anon, authenticated;

drop policy if exists "officers read"   on public.resources;
drop policy if exists "officers update" on public.resources;
drop policy if exists "officers delete" on public.resources;
create policy "officers read"   on public.resources for select to authenticated using (public.is_officer());
create policy "officers update" on public.resources for update to authenticated using (public.is_officer()) with check (public.is_officer());
create policy "officers delete" on public.resources for delete to authenticated using (public.is_officer());
-- Officers can see / change the staff PIN from the dashboard
drop policy if exists "officers read settings"   on public.app_settings;
drop policy if exists "officers update settings" on public.app_settings;
create policy "officers read settings"   on public.app_settings for select to authenticated using (public.is_officer());
create policy "officers update settings" on public.app_settings for update to authenticated using (public.is_officer()) with check (public.is_officer() and length(trim(value)) >= 4);

-- NOTE: no insert policy. Staff can add data ONLY through add_resource() below,
-- which checks the entry code. Staff can never read anyone's data.

-- 5a) PIN check for the staff PIN screen (returns only true / false)
create or replace function public.check_pin(p_code text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.app_settings where key = 'entry_code' and value = trim(coalesce(p_code, '')));
$$;
grant execute on function public.check_pin(text) to anon, authenticated;

-- 5) Function used by the staff form / स्टाफ फॉर्म का फंक्शन ---------------
create or replace function public.add_resource(p_code text, p_data jsonb)
returns bigint language plpgsql security definer set search_path = public as $$
declare
  v_id bigint;
  v_code text;
begin
  select value into v_code from public.app_settings where key = 'entry_code';
  if v_code is null or p_code is null or trim(p_code) <> v_code then
    raise exception 'INVALID_CODE';
  end if;

  if coalesce(trim(p_data->>'place_name'), '') = '' or coalesce(trim(p_data->>'ps_name'), '') = ''
     or coalesce(trim(p_data->>'beat_no'), '') = '' or coalesce(trim(p_data->>'staff_name'), '') = ''
     or (p_data->>'latitude') is null or (p_data->>'longitude') is null then
    raise exception 'MISSING_FIELDS';
  end if;

  insert into public.resources (
    client_uid, client_time, category, place_name, ps_name, beat_no, beat_name,
    latitude, longitude, gps_accuracy, location_source, address, contact_person,
    contact_phone, sensitivity, remarks, photo_path, staff_name, staff_mobile
  ) values (
    nullif(p_data->>'client_uid', '')::uuid,
    nullif(p_data->>'client_time', '')::timestamptz,
    coalesce(nullif(p_data->>'category', ''), 'other'),
    left(trim(p_data->>'place_name'), 300),
    left(trim(p_data->>'ps_name'), 120),
    left(upper(trim(p_data->>'beat_no')), 40),
    left(nullif(trim(p_data->>'beat_name'), ''), 120),
    (p_data->>'latitude')::double precision,
    (p_data->>'longitude')::double precision,
    nullif(p_data->>'gps_accuracy', '')::double precision,
    left(nullif(p_data->>'location_source', ''), 20),
    left(nullif(trim(p_data->>'address'), ''), 500),
    left(nullif(trim(p_data->>'contact_person'), ''), 150),
    left(nullif(trim(p_data->>'contact_phone'), ''), 40),
    coalesce(nullif(p_data->>'sensitivity', ''), 'normal'),
    left(nullif(trim(p_data->>'remarks'), ''), 2000),
    left(nullif(p_data->>'photo_path', ''), 300),
    left(trim(p_data->>'staff_name'), 150),
    left(nullif(trim(p_data->>'staff_mobile'), ''), 40)
  )
  on conflict (client_uid) do nothing
  returning id into v_id;

  return v_id;
end;
$$;
grant execute on function public.add_resource(text, jsonb) to anon, authenticated;

-- 6) Photo storage (private) / फोटो स्टोरेज (निजी) --------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 3145728, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "staff upload photos"   on storage.objects;
drop policy if exists "officers view photos"  on storage.objects;
drop policy if exists "officers delete photos" on storage.objects;
create policy "staff upload photos"   on storage.objects for insert to anon, authenticated with check (bucket_id = 'photos');
create policy "officers view photos"  on storage.objects for select to authenticated using (bucket_id = 'photos' and public.is_officer());
create policy "officers delete photos" on storage.objects for delete to authenticated using (bucket_id = 'photos' and public.is_officer());

-- Done / हो गया ✔
