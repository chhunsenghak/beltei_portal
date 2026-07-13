# BELTEI Portal — Deployment Workflow

This document explains how the production web app is built and deployed. The workflow file lives at [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml).

For local Supabase setup and migration commands, see [README.md](../README.md).

---

## High-Level Flow

- A merge (or push) to the **`main`** branch triggers GitHub Actions.
- **Job 1 — Build:** compiles Flutter web with production Supabase credentials baked in.
- **Job 2 — Deploy:** downloads the build artifact and pushes it to Vercel as a prebuilt static site.
- **Production backend** (Supabase Cloud) is separate — database migrations are **not** auto-deployed by this workflow.

```
Push to main
    │
    ▼
┌─────────────────┐     artifact      ┌─────────────────┐     CDN      ┌──────────────┐
│  GitHub Actions │ ───────────────►  │  GitHub Actions │ ──────────►  │   Vercel     │
│  build job      │   build/web/      │  deploy job     │  prebuilt    │  (static)    │
└─────────────────┘                   └─────────────────┘              └──────────────┘
                                                                              │
                                                                              ▼
                                                                       ┌──────────────┐
                                                                       │ Supabase     │
                                                                       │ Cloud API    │
                                                                       └──────────────┘
```

---

## Trigger

- **Event:** `push` to branch `main`
- **When it runs:** automatically after a PR merge or direct push to `main`
- **What it does NOT trigger on:** pushes to feature branches (unless they are merged into `main`)

---

## Job 1 — Build Flutter Web Application

**Runner:** `ubuntu-latest`

### Steps (in order)

1. **Checkout code**
   - Uses `actions/checkout@v4` to clone the repository at the commit that triggered the workflow.

2. **Install Flutter**
   - Uses `subosito/flutter-action@v2` with the `stable` channel.
   - Ensures a consistent Flutter SDK on the CI runner.

3. **Build web app with injected variables**
   - Enables web support: `flutter config --enable-web`
   - Installs dependencies: `flutter pub get`
   - **Validates secrets early** — exits with error if `SUPABASE_URL` or `SUPABASE_ANON_KEY` GitHub secrets are missing (prevents deploying a broken build).
   - Compiles release web build:
     ```bash
     flutter build web --release \
       --dart-define=SUPABASE_URL="${{ secrets.SUPABASE_URL }}" \
       --dart-define=SUPABASE_ANON_KEY="${{ secrets.SUPABASE_ANON_KEY }}"
     ```
   - These `--dart-define` values are read at compile time by `main.dart` via `String.fromEnvironment(...)`.

4. **Archive production artifacts**
   - Uploads the `build/web/` directory as a GitHub Actions artifact named `web-build`.
   - Retention: **1 day** (artifact is temporary; Vercel holds the live deployment).

---

## Job 2 — Deploy to Vercel

**Runner:** `ubuntu-latest`  
**Depends on:** `build` job must succeed first  
**Environment:** `production` — requires GitHub Environment approval if configured (QA sign-off gate)

### Steps (in order)

1. **Checkout code**
   - Fresh checkout of the repo (source code only; build output comes from the artifact).

2. **Download build artifacts**
   - Downloads the `web-build` artifact into `build/web/`.
   - This is the compiled Flutter web output from Job 1.

3. **Install Vercel CLI**
   - Runs `npm install --global vercel@latest`.

4. **Link and deploy to Vercel**
   - **`vercel pull --yes --environment=production`**
     - Pulls Vercel **project settings** (not application source code).
     - Links the CI runner to the correct Vercel org/project using `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID`.
     - Downloads production environment configuration from Vercel.
   - **Create prebuilt output directory**
     - `mkdir -p .vercel/output/static`
     - Vercel's prebuilt deploy format expects static files under `.vercel/output/static/`.
   - **Write SPA routing config**
     - Creates `.vercel/output/config.json` with a catch-all route to `index.html`.
     - Fixes **404 on browser refresh** for client-side routes (GoRouter paths like `/admin/users`).
   - **Copy build files**
     - `cp -r build/web/. .vercel/output/static/`
     - Places compiled HTML, JS, WASM, and assets into the Vercel staging folder.
   - **Deploy prebuilt output**
     - `vercel deploy --prod --prebuilt`
     - Uploads the prebuilt bundle to Vercel production — **Vercel does not rebuild Flutter**; it only serves the static files CI prepared.

---

## Required GitHub Secrets

| Secret | Used in | Purpose |
|---|---|---|
| `SUPABASE_URL` | Build job | Production Supabase project URL |
| `SUPABASE_ANON_KEY` | Build job | Public anon/publishable key (safe to embed in client) |
| `VERCEL_TOKEN` | Deploy job | Vercel CLI authentication |
| `VERCEL_ORG_ID` | Deploy job | Identifies the Vercel team/org |
| `VERCEL_PROJECT_ID` | Deploy job | Identifies the Vercel project |

> **Never** add `SUPABASE_SERVICE_ROLE_KEY` to the web build secrets. The service role key bypasses RLS and must only be used server-side (e.g., local seeder).

---

## GitHub Environment Gate

- The deploy job uses `environment: production`.
- If configured in GitHub repo settings → Environments → `production`, a **required reviewer** must approve before deploy runs.
- This separates "build succeeded" from "release to production" — useful for QA sign-off.

---

## Local vs Production Configuration

| | Local development | Production (CI/Vercel) |
|---|---|---|
| **Supabase URL & key** | `.env` file + `flutter_dotenv` | `--dart-define` injected at build time |
| **How to run** | `flutter run` / `flutter run -d chrome` | GitHub Actions → Vercel |
| **Backend** | Local Supabase via Docker (`supabase start`) | Supabase Cloud (managed) |
| **Database changes** | `supabase db reset` locally | `supabase db push` manually after review |

---

## What Is NOT Part of This Workflow

- **Database migrations** — schema changes in `supabase/migrations/` are pushed separately with `supabase db push` after review. They are not auto-applied on web deploy.
- **Docker in production** — Docker is used locally for Supabase only. The live web app is static files on Vercel, not a container.
- **Mobile app store releases** — Android/iOS builds are not automated by this workflow.
- **Seeding production data** — the Dart seeder is for local/dev use only.

---

## Why Prebuilt Deploy (Not Vercel Native Build)

- Vercel has no native Flutter build support.
- Flutter must be compiled on a runner with the Flutter SDK (GitHub Actions).
- `--prebuilt` tells Vercel: "here are the final static files — just host them."
- This is the recommended pattern for Flutter web on Vercel.

---

## SPA Routing Fix

Flutter web + GoRouter uses client-side navigation. Without a fallback rule, refreshing `/admin/users` would return a 404 from the server.

The deploy step writes this config:

```json
{
  "version": 3,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/.*", "dest": "/index.html" }
  ]
}
```

- **`filesystem`** — serve actual static files (JS, assets, favicon) when they exist.
- **`/.* → /index.html`** — all other paths load the Flutter app; GoRouter handles routing in the browser.

---

## Manual Deployment Checklist

When releasing a new version:

1. Merge feature branch into `main` (triggers CI automatically).
2. Wait for **build** job to pass.
3. Approve **production** environment deploy if gate is enabled.
4. Verify the live Vercel URL loads and login works.
5. If this release includes DB migrations, run `supabase db push` separately and verify in Supabase dashboard.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Build fails immediately | Missing `SUPABASE_URL` or `SUPABASE_ANON_KEY` secret | Add secrets in GitHub repo settings |
| App loads but auth fails | Wrong Supabase URL/key in secrets | Update secrets to match production Supabase project |
| 404 on page refresh | SPA routing config missing | Confirm deploy step writes `.vercel/output/config.json` |
| Deploy job skipped | Build job failed | Fix build errors first |
| Deploy waiting | Production environment approval pending | Approve in GitHub Actions environment gate |
| Schema mismatch errors | Web deployed but DB not migrated | Run `supabase db push` for pending migrations |

---

## Related Documentation

| Document | Contents |
|---|---|
| [README.md](../README.md) | Local setup, Supabase CLI, migration workflow |
| [project_overview.md](./project_overview.md) | Full project scope, tech choices, and implemented features |
