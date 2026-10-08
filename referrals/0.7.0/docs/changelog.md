# referrals changelog

## 0.7.0
- **Inbound service API (`POST /api/internal/affiliate`).** A trusted peer domain (with `REFERRALS_SERVICE_TOKEN` as `x-referrals-token`) can ensure + read a user's personal affiliate code — used by the milestone-reward email to embed each member's referral link. Refactors the affiliate-ensure logic into one helper shared with `POST /api/affiliate`.

## 0.6.2
- **Privacy: never store the referred account's raw name.** The reward memo sent
  to ekoin is now masked (`"Bonus referral: ha**l ra**f"`) instead of embedding
  the username/email local-part, so the ledger memo carries no raw PII.

## 0.6.1
- Normalize `EKOIN_BASE_URL` at load (drop a trailing `/api`) so the internal
  grant call works both in dev (configgen emits `<host>:<port>/api`) and prod
  (raw `<host>:<port>`).

## 0.6.0
- **Referral bonus (ekoin).** On a new sign-up attribution whose code has an
  owner, the owner is granted `REFERRAL_BONUS_EKOIN` ekoin (default 10) via the
  ekoin internal API, tagged with origin `referral`. Paid at most once per
  referred account (`referral:<userId>` idempotency + a unique `rewards`
  index); owner-less codes (e.g. the default `rwid`) grant nothing.
  - New env: `EKOIN_BASE_URL`, `EKOIN_SERVICE_TOKEN` (secret),
    `REFERRAL_BONUS_EKOIN`.
  - `POST /api/attribute` now returns `bonus`; the owner's SSE `referral`
    event carries `bonus`.
  - `GET /api/me` adds `rewards: { total, perReferral }` so the app can show
    the accumulated bonus.

## 0.5.0
- `GET /api/admin/referrers` now includes each referrer's `sources` map (sign-ups
  per UTM source), so the report can rank which referral produces the most new
  sign-ups and show where they came from.

## 0.4.0
- **UTM attribution on sign-ups.** `POST /api/attribute` accepts optional
  `source`, `medium`, `campaign` (from the share link
  `?ref=CODE&utm_source=…`); stored on the attribution as safe slugs.
- `/api/me` `referrals.recent[]` now carries `source`/`medium`/`campaign`, and
  `referrals.bySource` breaks the referrer's sign-ups down per source
  (`direct` when no UTM was present).
- `GET /api/admin/report` adds `bySource` — sign-ups grouped by source estate-wide.

## 0.3.0
- **Realtime referral notifications.** On a new sign-up attribution the LXS
  pushes a `referral` event to the code owner's private SSE channel
  (`GET /api/me/stream`) — the app shows a bottom-left toast to the referrer.
  Per-owner channels only; never a global broadcast.

## 0.2.0
- **Per-user affiliate codes**: `POST /api/affiliate` idempotently creates a
  personal code (`kind: affiliate`, slugged from username) owned by the caller —
  any signed-in user can share `/?ref=CODE`.
- `GET /api/me` now returns `affiliate`, `ownedReferrers`, and
  `referrals` (total + recent attributed users).
- Attributions capture `referredName` (username) for the referral list.
- `GET /api/resolve/:user_id` adds `default: true` when unattributed.

## 0.1.0
- Initial release: referral codes (rwid / dedicated / pool), signup attribution
  (default RWID), code claims, per-referrer report, admin seed/list.
