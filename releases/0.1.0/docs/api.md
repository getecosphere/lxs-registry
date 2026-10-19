# releases API

Base path `/api/releases`. Files live at `<RELEASES_PREFIX>/<app>/<version>/<file>` in S3; each app has a
`manifest.json` next to them (no database). `app`, `version`, file and kind names: `[A-Za-z0-9._-]`, ≤ 100 chars.

| Method | Path | Auth | What |
|---|---|---|---|
| GET | `/health`, `/api/releases/health` | — | `{"status":"ok"}` |
| GET | `/api/releases/:app/appcast.xml` | — | Sparkle appcast, newest `APPCAST_ITEMS` releases with an `update` file (`sparkle:version` = build, `shortVersionString` = version, `minimumSystemVersion`, `edSignature`, `length`). Cached 5 min. |
| GET | `/api/releases/:app/latest.json` | — | Latest release (`version`, `build`, `min_os`, `notes`, `published_at`, `files[]`). 404 when none. |
| GET | `/api/releases/:app/latest/:kind` | — | 302 to the newest file of that kind (e.g. `installer` → the DMG). For download buttons. |
| GET | `/api/releases/:app/:version/:file` | — | The file, streamed; single `Range` → 206. `Content-Disposition: attachment`, immutable cache. |
| POST | `/api/releases/:app` | `Bearer RELEASES_TOKEN` | Publish (multipart): `version`, `build` (digits), optional `min_os`, `notes`; one file part per kind (part name = kind, e.g. `update`, `installer`); optional `<kind>_signature` text part (Sparkle EdDSA). Re-publishing a version replaces it. → 201 release JSON. |
| DELETE | `/api/releases/:app/:version` | `Bearer RELEASES_TOKEN` | Yank a release from the manifest (files stay). → 204. |

Errors are `{"error": "..."}`: 400 invalid input, 401 bad/missing token (publishing is off until `RELEASES_TOKEN`
is ≥ 24 chars), 404 unknown release/file, 502 storage unavailable.

## Example

```bash
curl -X POST "$BASE/relay" -H "Authorization: Bearer $RELEASES_TOKEN" \
  -F version=0.2.0 -F build=52 -F min_os=14.0 -F "notes=Perbaikan kecil" \
  -F update=@Relay-0.2.0.zip -F "update_signature=$ED_SIGNATURE" -F installer=@Relay-0.2.0.dmg
```
