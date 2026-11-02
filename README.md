# Community Directory

A non-adult community and public-profile directory starter built with Nuxt 3, Vue 3, Supabase and Cloudflare Workers.

## Important status

This repository is a production-oriented implementation scaffold, not a claim that an external Supabase or Cloudflare account is already configured. You must configure credentials, apply migrations, create the R2 bucket and run the deployment checks before going live.

The supplied ZIP was a compiled frontend snapshot rather than the original source project. Its original compiled JavaScript is not executed by this application; this avoids relying on unknown third-party endpoints and undocumented behavior. Original images and SVG assets are retained under `legacy-assets/` for reference. Rebuild visual components from the available assets as needed.

## Requirements

- Node.js 20+
- npm
- Supabase project
- Cloudflare account with Workers and R2 enabled
- Wrangler authentication (`npx wrangler login`)

## Local setup

1. Copy `.env.example` to `.env`.
2. Set `NUXT_PUBLIC_SUPABASE_URL`, `NUXT_PUBLIC_SUPABASE_ANON_KEY`, and `NUXT_PUBLIC_SITE_URL`.
3. Install and run:

```bash
npm install
npm run dev
```

4. In Supabase SQL Editor, run `supabase/migrations/0001_initial_schema.sql`.
5. Register a first account. Copy its user UUID from Supabase Authentication > Users.
6. Replace the placeholder UUID in `scripts/promote-admin.sql` and run that SQL manually in the Supabase SQL Editor.
7. Sign in and visit `/admin`.

## Cloudflare setup

1. Create an R2 bucket named `community-directory-media` or change `bucket_name` in `wrangler.jsonc`.
2. Authenticate: `npx wrangler login`.
3. Add runtime secrets as appropriate:

```bash
npx wrangler secret put NUXT_PUBLIC_SUPABASE_URL
npx wrangler secret put NUXT_PUBLIC_SUPABASE_ANON_KEY
```

For this starter, the browser Supabase client reads public values from Nuxt runtime config. Configure them as build-time environment variables in your deployment environment. Never add the Supabase service-role key to a public variable or commit it.

4. Build and deploy:

```bash
npm install
npm run build
npx wrangler deploy
```

The exact Cloudflare output/config may need adjustment for your account and the Nuxt/Nitro versions installed. Verify the generated `.output` and Worker in a staging environment before production.

## GitHub auto deployment

- Push this repository to GitHub.
- Connect the repository to your Cloudflare Workers project.
- Configure the build command as `npm run build`.
- Configure deployment command as `npx wrangler deploy`.
- Set public Supabase environment values in the build environment.
- Store any server-only credentials as Worker secrets.

## ZIP / Folder deployment

- Extract the ZIP locally.
- Open the extracted project directory in a terminal.
- Run `npm install`, configure environment variables, then `npm run build` and `npx wrangler deploy`.
- A ZIP upload to a static-hosting drag-and-drop screen is not equivalent to deploying a Nuxt SSR Worker.

## Routes

- `/` public directory
- `/login` sign in
- `/register` registration
- `/dashboard` member profile
- `/admin` admin moderation

## Security notes

- RLS is enabled on application tables.
- Public listing is opt-in and requires admin approval.
- Admin role is assigned manually in Supabase SQL Editor.
- Never expose a service-role key in client-side code.
- Add CAPTCHA/email abuse controls, operational monitoring, backup/restore drills, and security review before public launch.
