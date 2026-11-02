# Security checklist

- Keep Supabase service-role credentials server-side only.
- RLS policies are mandatory; do not disable them to fix application errors.
- Promote admins manually and audit changes.
- Enforce email verification and strong passwords in Supabase Auth.
- Add CAPTCHA / signup rate limits before public registration.
- Validate and constrain uploaded files; use private buckets and signed URLs for non-public files.
- Add report review, account suspension, deletion and retention procedures before launch.
- Use HTTPS, secure headers, dependency updates, backups and restore tests.
- Run penetration testing and review all RLS policies before production.
