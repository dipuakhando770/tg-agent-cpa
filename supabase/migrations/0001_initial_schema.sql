create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 60),
  bio text not null default '' check (char_length(bio) <= 300),
  city text not null default '' check (char_length(city) <= 80),
  avatar_url text,
  visibility text not null default 'private' check (visibility in ('private','public')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('member','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.public_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,
  display_name text not null,
  bio text not null default '',
  city text not null default '',
  avatar_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','hidden')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (char_length(reason) between 5 and 500),
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.moderation_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null references auth.users(id),
  profile_id uuid not null references public.profiles(id),
  action text not null,
  created_at timestamptz not null default now()
);

create index if not exists public_profiles_status_created_idx on public.public_profiles(status, created_at desc);
create index if not exists public_profiles_name_idx on public.public_profiles using gin (to_tsvector('simple', display_name));
create index if not exists reports_status_idx on public.reports(status, created_at desc);

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from public.user_roles where user_id = auth.uid() and role = 'admin');
$$;

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.public_profiles enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_logs enable row level security;

create policy "Members read own profile" on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());
create policy "Members create own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "Members update own profile" on public.profiles for update to authenticated using (id = auth.uid() or public.is_admin()) with check (id = auth.uid() or public.is_admin());

create policy "Users read own role" on public.user_roles for select to authenticated using (user_id = auth.uid() or public.is_admin());
-- Admin role assignment is intentionally not available to ordinary authenticated clients.
create policy "Anyone reads approved public profiles" on public.public_profiles for select to anon, authenticated using (status = 'approved' or id = auth.uid() or public.is_admin());
create policy "Members request own public listing" on public.public_profiles for insert to authenticated with check (id = auth.uid() and status = 'pending');
create policy "Members update own pending listing" on public.public_profiles for update to authenticated using (id = auth.uid() and status = 'pending') with check (id = auth.uid() and status = 'pending');
create policy "Admins moderate listings" on public.public_profiles for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "Members create reports" on public.reports for insert to authenticated with check (reporter_id = auth.uid());
create policy "Members read own reports" on public.reports for select to authenticated using (reporter_id = auth.uid() or public.is_admin());
create policy "Admins manage reports" on public.reports for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins read moderation logs" on public.moderation_logs for select to authenticated using (public.is_admin());
create policy "Admins write moderation logs" on public.moderation_logs for insert to authenticated with check (public.is_admin());

create or replace function public.sync_public_profile()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  if new.visibility = 'public' then
    insert into public.public_profiles (id, display_name, bio, city, avatar_url, status, updated_at)
    values (new.id, new.display_name, new.bio, new.city, new.avatar_url, 'pending', now())
    on conflict (id) do update set
      display_name = excluded.display_name,
      bio = excluded.bio,
      city = excluded.city,
      avatar_url = excluded.avatar_url,
      status = case when public_profiles.status = 'approved' then 'pending' else public_profiles.status end,
      updated_at = now();
  else
    delete from public.public_profiles where id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_sync_public on public.profiles;
create trigger profiles_sync_public after insert or update of display_name, bio, city, avatar_url, visibility
on public.profiles for each row execute function public.sync_public_profile();

create or replace function public.create_member_role()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.user_roles(user_id, role) values (new.id, 'member') on conflict do nothing;
  return new;
end;
$$;
drop trigger if exists auth_user_role on auth.users;
create trigger auth_user_role after insert on auth.users for each row execute function public.create_member_role();

grant usage on schema public to anon, authenticated;
grant select on public.public_profiles to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select on public.user_roles to authenticated;
grant select, insert, update on public.reports to authenticated;
grant select, insert on public.moderation_logs to authenticated;
