# Changelog

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
