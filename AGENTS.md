# AGENTS.md

## Repo layout

Three independent apps, no shared build system or monorepo tool:

| Dir | Stack | Deploy |
|---|---|---|
| `be-apps-i-desa/` | Go 1.25, Fiber v2, GORM, PostgreSQL | Vercel serverless (`api/main.go`) or standalone `main.go` |
| `fe-i-desa/` | Flutter (Dart), Riverpod, Forui, go_router | Flutter web → GitHub Pages; desktop (Windows/macOS) |
| `simpoi/` | React 19, Vite, TypeScript, Tailwind v4 | Separate repo (`github.com/shinnwlfrd/simpoi`); cloned in-tree |

`simpoi/` is **gitignored** at the root level — never commit anything there.

## Backend (`be-apps-i-desa/`)

### Commands

```bash
cd be-apps-i-desa
go build ./...          # compile (also validates syntax)
go vet ./...            # static analysis
golangci-lint run       # linter (config: .golangci.yml)
go test ./services/...  # unit tests (no DB required)
```

### Architecture

Layered: `routes/ → controllers/ → services/ → repositories/ → GORM/Postgres`.

- **Entrypoints**: `main.go` (standalone server) and `api/main.go` (Vercel adaptor). Both call the same `routes.Setup*` functions.
- **DB connection** (`config/database.go`): retries 10× with exponential backoff (Railway DNS race). Repositories capture `config.DB` at construction — routes must be set up **after** `ConnectDB()`.
- **Migrations**: run automatically in `ConnectDB()` via `AutoMigrate`. Schema lives in code, not SQL files.
- **Auth**: JWT in `AppsIDesaCookie` cookie (same-origin) or `Authorization: Bearer` header (cross-origin web). Single-device enforcement via `session_id` claim.
- **Registration**: protected by `X-Admin-Token` header (env `ADMIN_REGISTRATION_TOKEN`). Fail-closed: unset token = registration disabled.

### Required env vars

`DATABASE_URL` (preferred) or `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`.
Plus: `JWT_SECRET`, `ADMIN_REGISTRATION_TOKEN`, `CORS_ALLOWED_ORIGINS`.

A `.env` file is loaded via `godotenv`; `.env` is gitignored.

### Gotchas

- `BodyLimit` is 15 MB (both `main.go` and `api/main.go`) — village Excel imports can be large. Keep both entrypoints in sync if you change this.
- CORS must explicitly allow `X-Admin-Token` in `AllowHeaders` or the browser silently drops registration requests.
- Two test files exist: `services/dashboard_breakdown_test.go` and `services/import_smoke_test.go`. No integration tests or DB-backed tests.

## Frontend (`fe-i-desa/`)

### Commands

```bash
cd fe-i-desa
flutter pub get                  # install deps
flutter run -d windows           # desktop (Windows)
flutter run -d macos             # desktop (macOS)
flutter build web --release      # web build
flutter analyze                  # lint (uses flutter_lints)
flutter test                     # unit/widget tests
dart run build_runner build      # codegen (freezed, riverpod_generator)
```

### Architecture

- **State**: Riverpod providers (`lib/providers/`). Provider invalidation on auth change prevents cross-village PII leaks — see `providers/session.dart`.
- **Routing**: `go_router` configured in `lib/core/router/`.
- **API layer**: `lib/data/services/api_service.dart` — Dio singleton. Web uses Bearer token; desktop uses cookies.
- **Codegen**: freezed + riverpod_generator + json_serializable. Generated files (`*.g.dart`, `*.freezed.dart`) are gitignored — run `build_runner` after editing annotated classes.
- **Mock mode**: `AppConfig.useMockApi` in `lib/core/config/app_config.dart` switches to `mock_api_service.dart`.

### Build-time defines

```
--dart-define=BASE_URL=...     # backend URL (default: https://apps-i-desa-v2-production.up.railway.app)
--dart-define=SIMPOI_URL=...   # SIMPOI link (default: https://shinnwlfrd.github.io/simpoi/)
```

CI defaults are in `.github/workflows/deploy-fe.yml`. Local builds hit `localhost:3000` if unset.

### Deployment

- **Web**: GitHub Pages via `.github/workflows/deploy-fe.yml` (push to `main`). Uses `--base-href "/apps-i-desa-v2/"` and `--no-web-resources-cdn` for PWA offline support.
- **Firebase Hosting**: configured in `firebase.json` for site `i-desa-app` (project `i-desa-f8777`). Not used by CI currently.
- `web/` directory is committed — do **not** run `flutter create` in CI or locally; it overwrites custom `manifest.json` and `index.html`.

### Gotchas

- `path_provider_foundation` is pinned to 2.5.1 in `dependency_overrides` to avoid a crash on Flutter web. Only safe because we don't target Apple platforms yet.
- `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` are enforced. `avoid_print` is **disabled**.
- Tests: `test/widget_test.dart`, `test/responsive_members_test.dart`, `test/responsive_dialog_test.dart`. Run `flutter test`.

## SIMPOI (`simpoi/`)

Separate repo, cloned here for reference. Uses Vite dev server on port 3000 — conflicts with the backend's default port. Do not modify files here; changes belong in the upstream repo.

## Common pitfalls

- **Port conflict**: Backend defaults to `:3000`, SIMPOI's Vite defaults to `--port=3000`. Run only one at a time locally, or override.
- **Cross-origin auth**: Web frontend (GitHub Pages / Firebase) is cross-origin to the backend. Cookies won't work — the frontend falls back to Bearer tokens automatically. Desktop apps use cookies.
- **Generated code**: After editing `freezed` or `riverpod_annotation` classes in the frontend, run `dart run build_runner build` or the app won't compile.
- **No monorepo tooling**: There is no root `package.json`, `Makefile`, or task runner. Each app is built independently.
