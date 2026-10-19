# releases

Hosts app releases for an estate: what an auto-updater (Sparkle on macOS) and a download page need, at stable
URLs, with publishing guarded by a per-project token. Files go to the estate's S3-compatible storage (MinIO), under
a prefix, so the bucket can be shared with the `storage` LXS. See `api.md`.

Compose: grant `S3_*` and `RELEASES_TOKEN` (per-project secret store), set `PUBLIC_BASE_URL` to the public URL of
`/api/releases`, route `/api/releases/*` as `level: public` (publishing is authorised by the token inside the
service). Optional friendly routes (e.g. `/relay/download` → `/api/releases/relay/latest/installer`).
