# Deployment guide

## Cloudflare Workers (recommended)

This app uses the Nuxt Nitro `cloudflare_module` preset. Build locally first:

```bash
npm ci
npm run build
npx wrangler deploy
```

Check current Nuxt/Nitro Cloudflare adapter requirements before production rollout. Keep a staging Worker and test SSR, auth, database policies, and error handling.

## Git-based deployment

Use Cloudflare Workers Builds / Git integration. Build with `npm run build` and deploy the generated Worker with Wrangler. Set Nuxt public Supabase values in the build environment. Do not commit `.env`.

## ZIP or folder

Extract the archive, install dependencies, set environment values, build, then deploy using Wrangler. Direct static ZIP upload is not suitable for this SSR Worker application.

## Supabase

Apply SQL migrations in order. Configure Auth email verification and allowed redirect URLs for localhost and production domain. Promote an administrator manually using the SQL in `scripts/promote-admin.sql`.
