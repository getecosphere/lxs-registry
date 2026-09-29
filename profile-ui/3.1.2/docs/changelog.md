# profile-ui changelog

## 3.1.2 (2026-09-29)
- **Language dropdown shows flags.** Options are the locale's flag + endonym
  (🇬🇧 English · 🇫🇷 Français · 🇩🇪 Deutsch) instead of a bare code.

## 3.1.1 (2026-09-29)
- **Language switcher is a dropdown.** The locale links that sat in a row are
  now a single compact `<select>` (English / Français / Deutsch); changing it
  remembers the choice in `eco_lang` and reloads with `?lang=`. CSS
  cache-buster is now `?v=4`.

## 3.1.0 (2026-09-29)
- **Multi-locale settings page.** The profile page renders in the visitor's
  language — resolved per request from `?lang=`, the `eco_lang` cookie, then
  `Accept-Language` (`en`, `fr`, `de`; default `en`). Adds a language switcher
  and sets `<html lang>`. English is the source, with per-key fallback. CSS
  cache-buster is now `?v=3`.

## 3.0.3 (2026-08-23)
- Publish a Darwin/arm64 binary alongside Linux so `eco up dev` can run the
  same profile settings UI locally instead of leaving a previous binary active.

## 3.0.2 (2026-08-23)
- Refresh the avatar after upload and persist the returned URL in the browser
  session cache, so the settings page reflects the chosen photo immediately.

## 3.0.1 (2026-08-23)
- Recover the browser session from the gateway `eco_token` cookie when
  `localStorage.eco_session` is missing. A user authenticated through an
  SSR/Gateway page can now open profile settings without an erroneous redirect
  to sign-in.

## 3.0.0 (2026-08-22)
- Settings now update name, bio, and avatar through the canonical
  `/api/profile/users/<id>` gateway prefix.
- Added signed-in password change through Auth and removed LXS-branded
  decorative copy from the white-label UI.

## 1.0.0 (2026-08-19)
- Logging contract: service logs now emitted as newline-delimited JSON (NDJSON) to stdout per the platform LXS logging contract (`ts`/`level`/`msg` + optional `service`,`request_id`,`status`,`latency_ms`,`user_id`,`error`). Breaking change — log output format changed.

## 0.1.0 — initial

White-label profile edit page (name, avatar, cover) for the profile LXS. 1.2 MB binary.
