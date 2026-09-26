# auth-ui api

GET /signin, GET /signup — SSR pages that POST to AUTH_API_BASE (`/auth-api` by default).

GET /users — SSR admin page (sign-in required; gateway route `role:superadmin`).
Lists accounts (search, pagination, active/deactivated filter) and exposes
per-user actions: reset password (email link), deactivate/reactivate, force
logout, verify email, edit roles, and create user. Reads/writes
`GET/POST /auth-api/auth/admin/*` with the session bearer token. Requires a
`superadmin` account. There is no set-password action by design.

GET /forgot-password — SSR form that calls `POST /auth-api/auth/forgot-password`.

GET /reset-password?token=… — SSR form that calls `POST /auth-api/auth/reset-password`.
