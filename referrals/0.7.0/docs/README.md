# referrals

Referral codes and **signup attribution**. Every sign-up is attributed to a
code owned by **RWID**, a **dedicated investor** (≥ Rp40jt), the **shared
pool** (< Rp40jt), or an **affiliate** (any signed-in user). A sale belongs to
the code's owner — not split across all investors (that was the flaw that
stacked RWID's obligations). Investors can **claim** their code to link it to a
real account.

## Affiliate codes
Every signed-in user can **share a referral link**: `POST /api/affiliate`
idempotently creates a personal code (`kind: affiliate`, slugged from the
username, label `@username`) owned by the caller, and returns the caller's
`/me` payload (code + referrals). The generated link is
`https://<estate>/?ref=CODE`; the frontend captures `?ref`, then attributes the
new user after sign-in.

## UTM attribution
The share link may carry UTM tags — `https://<estate>/?ref=CODE&utm_source=threads`
(plus optional `utm_medium` / `utm_campaign`). The frontend remembers them
alongside the referral cookie and sends them on `POST /api/attribute`; they are
stored on the attribution as safe slugs. A referrer sees the per-source
breakdown of their sign-ups (`referrals.bySource`) and each entry's `source`;
superadmin `/api/admin/report` adds an estate-wide `bySource`, and
`/api/admin/referrers` returns each referrer's `sources` so the report can rank
which referral produces the most new sign-ups. Sign-ups with no UTM are reported
as `direct`.

## Data (MongoDB)
- `referrers`: code, label, kind(rwid|dedicated|pool|affiliate), rateBps,
  capitalIdr, ownerUserId (after claim/creation).
- `attributions`: userId (unique) → code, referrerLabel, referredName,
  source/medium/campaign (UTM, optional).

## Flow
- Link `/?ref=CODE` → the user is attributed to CODE (unknown/empty → RWID).
- `POST /api/claim {code}` → links a seeded code to the caller's account.
- `POST /api/affiliate` → ensures the caller owns a personal affiliate code.
- `GET /api/me` → my attribution + owned codes + `referrals` (total + recent).
- Report: per-referrer attributed-user counts.

## Config
`SERVER_PORT`, `MONGODB_URI`, `JWT_SECRET`, `REFERRALS_DEFAULT_CODE` (default
`rwid`), `CORS_ALLOWED_ORIGINS`.

## Test
`cargo build` then `python3 tests/integration/run_referrals_integration.py`.
