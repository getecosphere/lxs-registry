# email-manager — LXS

Everything an estate sends by email, in one place:

- **Templates with an admin UI** (`/email-admin`, estate superadmins): edit the
  subject, preview line and content of every email, see a live preview with
  sample data, send a test to yourself, publish as a new version, restore any
  earlier version, or go back to the bundled default. No agent or code change
  needed.
- **One branded layout** for all mail (logo, colour, support address, footer)
  from the estate config.
- **Delivery**: queue, retries, rate caps and warm-up, sent via Brevo.
- **Suppression**: hard bounces and complaints stop all mail; an unsubscribe
  stops marketing mail only (a password reset still arrives).
- **Privacy (GDPR)**: bodies dropped after 7 days and delivery records after 90
  (configurable); export and erase per address; suppressions kept only as a
  keyed hash; marketing mail carries a signed one-click unsubscribe (RFC 8058);
  every admin change is in an audit log kept for a year.

Other LXS send through it: the auth LXS sends verification, password-reset and
sign-in-link emails with `send-template`; the eco platform sends its billing
and usage notices the same way.

## Bundled templates

`auth.verify_email`, `auth.password_reset`, `auth.login_link`, `usage.limit`,
`overage.on|off|started|half|cap`, `billing.payment_received|payment_failed|payment_reminder|stop_tomorrow|estates_stopped|deletion_warning`,
`ops.notice`. Sources: `backend/templates/` (one HTML fragment each + `defaults.json`
for subject, preview line, variables; `layout.html` is the shared shell).

## Compose it

```yaml
services:
  email-manager-backend:
    lxs: email-manager@3.0.0
    grants: { secrets: [BREVO_API_KEY, MAIL_FROM_EMAIL, MAIL_FROM_NAME, EMAIL_SERVICE_TOKEN] }
    config:
      EMAIL_MANAGER_PUBLIC_URL: "https://example.com"
      EMAIL_BRAND_NAME: "Example"
      EMAIL_BRAND_LOGO_URL: "https://example.com/logo.png"
      EMAIL_SUPPORT_EMAIL: "help@example.com"
    access:
      routes:
        - { path: /email-admin, level: "role:superadmin", cookie: eco_token }
        - { path: /email-admin/*, level: "role:superadmin", cookie: eco_token }
        - { path: /email/unsubscribe, level: public }
```

Set the token once: `eco secrets set EMAIL_SERVICE_TOKEN` (any long random
string) and grant it to every service that sends mail (e.g. `auth-backend`).

## Docs index

- `api.md` — endpoints
- `changelog.md` — versions
- `gotchas.md` — constraints
