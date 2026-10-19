# Changelog

## 4.2.1

- Campaigns editor: hidden panels (audience filters, schedule time) stay hidden, and the preview stays in view while scrolling a long email.

## 4.2.0

- **Campaigns** (admin UI tab). Compose an email from blocks (heading, text, image, button, video, audio, divider) on the estate's
  branded layout; `{{name}}` in the subject or text inserts the member's name. Live preview, a test send to yourself, real file
  attachments (5 files, 10 MB in all), an optional sender (`MAIL_FROM_ALLOWED`) and reply-to.
- **Audience**: all members, members matching roles / sign-up country / plan / member type / join dates (verified only, admins
  optional), or a pasted list. Resolved from the auth LXS with the signed-in admin's own session (no extra credential) and frozen
  when the campaign is scheduled; unsubscribed and bounced addresses are left out. The frozen list is dropped once everything is queued.
- **Schedule or send now.** Delivery uses the normal queue (hourly budget, warm-up, suppression, one-click unsubscribe). Message ids are
  `<campaign>-<n>`, so a restart never queues anyone twice. Cancel stops what has not left yet.
- **Media** is uploaded in the admin (images, audio, video, pdf, zip; 15 MB each), stored in the estate database and served publicly,
  unguessable, at `/email/media/:id` with range support. Add `/email/media/*` as a public route and set `EMAIL_MANAGER_PUBLIC_URL`.
  Mail clients cannot play audio or video inline: those blocks render a cover/button that opens the file or link.

## 4.1.0

- **Send as another address of the estate.** `POST /api/email/send`, each message of `batch`, and `send-template` accept an optional
  `from: { email, name }` and `reply_to: { email, name }`. `from` is accepted only when it is on the new
  `MAIL_FROM_ALLOWED` list (comma-separated exact addresses like `dev@example.com`, or whole domains like `@example.com`);
  anything else is refused with `403`, so a service token cannot be used to spoof arbitrary senders. Empty list (the
  default) = no override, same as 4.0.x. The domain must also be authenticated with the provider (Brevo).
- Replies: an explicit `reply_to` wins; a message sent with `from` takes replies at that address; otherwise the estate's
  support address, as before.

## 4.0.1 (2026-10-16)
- Every message carries `Reply-To: EMAIL_SUPPORT_EMAIL` (when set), so "reply to
  this email" reaches the estate's support inbox instead of the no-reply sender.

## 4.0.0 (2026-10-16) — breaking
- **No domain copy inside email-manager.** The bundled auth/billing/usage
  templates are gone. Each domain owns its templates and registers them as
  defaults, per locale: `PUT /api/email/templates/defaults`
  `{ "source": "auth", "templates": [{ key, locale, category, subject,
  preheader, footer_reason, body, variables }] }` (service token; idempotent;
  validated, unsafe markup refused, rendered with the samples before storing).
- Lookup: published(locale) → default(locale) → published(en) → default(en).
- **Localized layout.** The footer, help line and unsubscribe line follow the
  template's locale (en, id, ms, de, fr, ar); Arabic renders `dir="rtl"`. The
  name fallback ("there") is localized too. The unsubscribe page follows the
  browser's language.
- Admin UI lists registered templates with their owner and locales.
- Upgrading: a consumer must register its templates (auth ≥ 4.1.0 and
  eco-server do this on start and on a 404).

## 3.0.2 (2026-10-15)
- **Suppression fix.** Only a 400 about the recipient (invalid, bounced, blocked)
  suppresses an address. A provider account problem (401 bad key or
  unauthorised IP, 403, 429, 5xx) or a sender problem no longer opts the
  recipient out.
- The delivery error keeps Brevo's reason (e.g. "unrecognised IP address"), so
  the admin log says what to fix.

## 3.0.1 (2026-10-15)
- `auth.verify_email`: "Thanks for creating your {{brand_name}} account" (the
  old "a {{brand_name}}" read wrong before a vowel, e.g. "a Ecosphere").

## 3.0.0 (2026-10-15)
- **Templates + admin UI.** Bundled, branded templates (auth, usage, overage,
  billing, ops) rendered with a logic-less engine (every value escaped);
  `POST /api/email/send-template`; admin UI at `/email-admin` for superadmins:
  edit, live preview, test send to yourself, draft/publish, version history,
  restore, revert to default; audit log.
- **Branding from config** (`EMAIL_BRAND_*`, `EMAIL_SUPPORT_EMAIL`,
  `EMAIL_POSTAL_ADDRESS`) on one shared layout.
- **Breaking: service token.** `/api/email/*` requires `EMAIL_SERVICE_TOKEN`.
- **Transactional vs marketing.** Transactional mail no longer gets the old
  "signed up for updates from Eco" footer; marketing mail gets a signed one-click
  unsubscribe link and RFC 8058 headers. Unsubscribes block marketing only.
- **GDPR.** Body/log retention (7/90 days), export and erase per address,
  suppressions stored as keyed hashes (migrated on start), masked addresses in
  the admin UI.

## 2.1.3 (2026-08-20)
- Keep all MongoDB timestamp updates in RFC 3339 string form, matching inserted
  messages and preventing status/rate-counter deserialization failures.

## 2.1.2 (2026-08-20)
- Compare queued-message retry timestamps using their persisted RFC 3339
  string representation so due messages are selected reliably.

## 2.1.1 (2026-08-20)
- Fix the global hourly rate-limit window key so it rotates every UTC hour
  instead of accumulating all sends for an entire day.

## 2.1.0 (2026-08-20)
- Add optional CC recipients and base64 file attachments to single and batch
  email requests.
- Validate attachment count, decoded size, filename, and base64 encoding.
- Return attachment filenames only from status and discard attachment contents
  after successful provider submission.

## 1.0.2 (2026-08-20)
- Artifacts: added `darwin/arm64` for local `eco up dev`.

## 2.0.0 (2026-08-19)
- Logging contract: service logs now emitted as newline-delimited JSON (NDJSON) to stdout per the platform LXS logging contract (`ts`/`level`/`msg` + optional `service`,`request_id`,`status`,`latency_ms`,`user_id`,`error`). Breaking change — log output format changed.

## 1.0.1 (next release)
- Store rate-counter window and message datetimes consistently as RFC 3339
  strings for reliable queries (`bdffc3b`, `70dce31`)

## 1.0.0
- initial release — LXS manifest `email-manager@1.0.0` (`93c8596`). Pre-manifest
  development history:
  - Initial reusable domain: Brevo outbound, anti-spam queue, suppression,
    rate caps, warm-up ramp (`9c239eb`)
  - Single-binary composition via `bootstrap()` (`b5dbf3b`)
