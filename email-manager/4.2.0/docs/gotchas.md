# Gotchas

Production-learned constraints not visible in the binary:

- **3.0: the send API needs `EMAIL_SERVICE_TOKEN`.** `/api/email/*` answers 503
  until the token is configured and 401 without `Authorization: Bearer <token>`.
  Upgrading from 2.x is breaking for every sender: set the secret and grant it.
- **Suppressions are hashed with the estate's own secret** (generated once into
  the `settings` collection). Restoring an old database without its `settings`
  makes existing suppressions unmatchable — back up the collection with the rest.
- **The admin UI needs `AUTH_BASE_URL`** (the auth LXS) to verify superadmins;
  eco resolves it automatically when auth is composed.
- **Errors are plain-text, not JSON.** Every non-2xx response body is a bare
  string (`invalid recipient email`, `message not found`, ...) except
  `/health`. Consumers must handle text error bodies, not parse `{error: ...}`.
- **Per-recipient daily cap is tracked but NOT enforced.** `EMAIL_PER_RECIPIENT_DAY`
  (default 5) increments a `recipient-day-<email>` counter after each send, but
  the worker never consults it to skip a recipient — only the **global hourly
  budget** gates sending (`EMAIL_GLOBAL_PER_HOUR`, default 400, ramped by
  warm-up). README.md advertises a per-recipient/day default of 5; the code
  only records it.
- **Warm-up ramp is calendar-based, not per-domain.** `warmup_rate` uses the
  day-of-year (`now.ordinal() % warmup_days`) — a new verified domain ramps
  `EMAIL_WARMUP_MAX_PER_HOUR`/`EMAIL_WARMUP_DAYS` from 1 up to the max in
  roughly `EMAIL_WARMUP_DAYS` steps, but the phase resets every year and is
  shared with the global budget; it is not "days since the domain was
  verified".
- **Worker cadence and batching.** A tick runs every 2 seconds and sends at
  most 20 messages per tick, capped by the remaining hourly budget. When
  `BREVO_API_KEY` or `MAIL_FROM_EMAIL` is empty the worker pauses entirely
  (`health.provider_configured` shows `false`), so enqueued messages sit as
  `queued`.
- **Retry + backoff.** On send failure: `attempts + 1`, backoff
  `30s * attempts` capped at 1800s (30 min), retried as `queued` until
  `attempts >= 5`, then marked `failed`. After 5 failures the message stays
  `failed` with `error` set.
- **Permanent Brevo rejections auto-suppress.** A Brevo error with status 400,
  or whose body contains `invalid`, `bounce`, or `suppress`, writes the
  recipient to `suppressions` (reason `brevo_rejected:<first 80 chars>`);
  hard bounces / spam reports arriving via Brevo are expected to be handled
  the same way. Suppressed recipients are refused at enqueue (422) and skipped
  by the worker (marked `suppressed`).
- **Provider integration is Brevo-only.** Sending is a hard-coded
  `POST https://api.brevo.com/v3/smtp/email` with the `api-key` header; the
  estate needs outbound HTTPS. No SMTP fallback.
- **Unsubscribe footer is auto-appended** to every message: an inline
  `<...>/unsubscribe?email=<to>` block plus a `List-Unsubscribe` mail header,
  using `EMAIL_MANAGER_PUBLIC_URL` (default `https://eco.stuff8.com`). A wrong
  or unreachable public URL means every recipient sees a broken unsubscribe
  link. The `X-Eco-Campaign` header carries the campaign id.
- **Validation rules for `to`:** after trim + lowercase, must have a non-empty
  local part, a domain containing `.` with length ≥ 4, no spaces, and no `..`
  anywhere. `foo@bar` (no dot) is rejected.
- **HTML-only.** `html` is required and non-empty; plain-text content is not
  accepted. Subject/body length is not capped.
- **Attachments are bounded and short-lived.** Each attachment is base64 in
  the request, with at most 5 files and 10 MB decoded data total. Names may not
  contain path separators. The worker removes attachment contents after Brevo
  accepts the message; status responses expose filenames only.
- **Datetimes are RFC 3339 strings** in Mongo (`created_at`, `sent_at`,
  `next_attempt_at`, rate-counter `window`) — fixed in 1.0.1. Do not feed
  integer epoch values.
- **Port precedence:** binds `PORT`, falling back to `SERVER_PORT`, then
  `8085`. The lxs.yml contract declares `SERVER_PORT`, so set `SERVER_PORT` for
  the composed service.
- **`API_BASE_PATH` is declared but ignored** in code — routes are hardcoded
  `/api/email/...` plus bare `/health`.
- **Suppression is by normalized email** (trim + lowercase). Addresses are
  stored normalized; mixed-case duplicates collapse to one suppression.
- **Batch is all-or-nothing:** any invalid/suppressed message in a batch fails
  the entire request (already-enqueued earlier messages in the batch remain
  enqueued; no rollback).
- **Campaigns are limited by the hourly budget.** A 2,000-person campaign at the default 400/hour takes ~5 hours to leave; raise
  `EMAIL_GLOBAL_PER_HOUR` / `EMAIL_WARMUP_MAX_PER_HOUR` only as far as the Brevo plan allows. Cancel drops what is still queued.
- **Media needs `EMAIL_MANAGER_PUBLIC_URL` and a public `/email/media/*` route.** Images in a sent mail are links to it; a wrong
  origin means broken images for every reader. Media lives in MongoDB (15 MB per file) and is included in database backups.
- **Audience is frozen at scheduling** (the admin's session is needed to read members); members who join later are not added.
