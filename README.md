# LOL — Lot of Love · Admin Web Console

Next.js console for operating the LOL platform: users, safety & moderation, verification, matching, questionnaire,
content, billing, analytics and admin accounts (role-based; every action is audit-logged).

Sibling repositories:
- **Backend API** — https://github.com/usaikiran8978/LOL
- **Mobile app** — https://github.com/usaikiran8978/LOL-Mobile

## Run locally
```bash
npm install
API_URL=http://localhost:3000 npm run dev    # http://localhost:3001
npm test && npm run typecheck
```
The browser only talks to `/api/*` on this origin; the Next server forwards it to `API_URL/v1/*` (server-side only),
so the admin session cookie stays first-party.

`packages/shared/` holds the API contracts (zod schemas, error codes, permissions) and is **a copy of the one in the
backend repo** — keep them in sync when the API changes.

## Deploy
- Docker (from the repository root): `docker build -t lol-admin .` → listens on 3001.
  Set `API_URL` to the backend's internal URL at runtime.
- Or any Node host / Vercel: `npm ci && npm run build && npm start` with `API_URL` set.
- `deploy/k8s-admin.yaml`: Kubernetes manifest (Deployment + Service) if you deploy alongside the backend's k8s setup.

The backend must list this console's origin in `ADMIN_CONSOLE_URL` / `CORS_ORIGINS` and use `ADMIN_COOKIE_SECURE=true`
over HTTPS in production.
