-- Run manually in Supabase SQL Editor after the first account has registered.
-- Replace the UUID with the intended administrator's auth.users.id.
-- Never expose admin role assignment in public registration.
insert into public.user_roles (user_id, role)
values ('00000000-0000-0000-0000-000000000000', 'admin')
on conflict (user_id) do update set role = 'admin';