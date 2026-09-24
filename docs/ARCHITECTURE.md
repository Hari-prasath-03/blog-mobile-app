# Blog App — Architecture

> Status: **auth feature implemented** (signup / login / current-user with Supabase). Blog posts feature not yet added — the structure is ready for it.

This document describes how the codebase is organized and *why* it's set up this way, so any developer can extend it consistently and in the same spirit. Sections marked "Diagram" (or `> [DIAGRAM n ...]`) are placeholders — paste the corresponding visual there.

---

## 1. Project Structure

The project uses a **feature-first** layout with shared code promoted to `core/`:

```
lib/
├── main.dart                        # App entry — wires cubits/blocs via BlocProvider
├── init_dependencies.dart           # GetIt wiring (service locator) — one point of entry
├── core/                            # Shared, reusable code (not feature-specific)
│   ├── common/
│   │   ├── cubits/app_user/         # AppUserCubit + state — holds the logged-in user app-wide
│   │   ├── entities/user.dart       # User domain entity (pure Dart, no JSON)
│   │   └── widgets/loader.dart      # Shared loading spinner
│   ├── error/
│   │   ├── exceptions.dart          # ServerException (data layer)
│   │   └── failures.dart            # Failure (domain layer contract)
│   ├── secrets/
│   │   ├── app_secrets.example.dart # Committed placeholder with dummy values
│   │   └── app_secrets.dart         # Real Supabase keys — GITIGNORED, local only
│   ├── theme/                       # AppTheme + AppPallet (colors)
│   ├── usecase/usecase.dart         # UseCase<T, Params> + NoParams contract
│   └── utils/show_snackbar.dart     # showSnackBar helper
└── features/
    └── auth/                        # One folder per feature
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_data_source.dart      # abstract + Supabase impl
        │   ├── models/
        │   │   └── user_model.dart                  # UserModel extends User
        │   └── repositories/
        │       └── auth_repository_impl.dart        # data → domain mapping
        ├── domain/
        │   ├── repository/
        │   │   └── auth_repository.dart             # abstract interface
        │   └── usecases/
        │       ├── user_sign_up.dart
        │       ├── user_login.dart
        │       └── current_user.dart
        └── presentation/
            ├── bloc/
            │   ├── auth_bloc.dart                   # part file
            │   ├── auth_event.dart                  # part file
            │   └── auth_state.dart                  # part file
            ├── pages/
            │   ├── signup_page.dart
            │   └── login_page.dart
            └── widgets/
                ├── auth_form_field.dart
                └── auth_gradient_button.dart
```

> [DIAGRAM 1 — paste a folder-tree / feature tree visual here]

**Why:** grouping by feature (`features/auth/`) means everything that changes together stays near each other, and adding a new vertical (e.g. `features/blog/`) is just another folder. Code shared across features is pulled up into `core/` so it isn't duplicated. This is the canonical Flutter Clean-Architecture layout.

---

## 2. Clean Architecture Layers

The code is split into three layers per feature, and dependencies point **inward** (presentation → domain → data, all through `core/`):

```
Presentation (pages, bloc, widgets)
      │  dispatches events
      ▼
Domain (repository interface + usecases + entity)
      │  depends on an interface, not the implementation
      ▼
Data (remote datasource, models, repository impl)
      ▼
Supabase
```

> [DIAGRAM 2 — paste a layer-dependency / control-flow diagram here]

### Domain layer (pure Dart)
- `AuthRepository` — abstract interface returning `Either<Failure, User>`.
- Usecases (`UserSignUp`, `UserLogin`, `CurrentUser`) — thin, they delegate a single repository call and implement a shared `UseCase<T, Params>`.
- `User` entity lives in `core/common/entities/` — **no Flutter, no Supabase, no JSON** imports here.

### Data layer
- `AuthRemoteDataSource` is the abstract contract; `AuthRemoteDataSourceImpl` talks to Supabase.
- `UserModel` **extends** the `User` entity and adds `fromJson`/`toJson` — the domain stays JSON-free.
- `AuthRepositoryImpl` wraps the datasource and converts `ServerException → Failure`, returning `left(...)/right(...)`.

### Presentation layer
- `AuthBloc` orchestrates usecases and emits a sealed `AuthState` (Initial / Loading / Success / Failure).
- `AppUserCubit` (a global cubit) holds the logged-in `User` for the whole app; `AuthBloc` updates it on success.
- Pages are plain widgets: they dispatch events and react to state. No business logic lives in the UI.

**Why:** the dependency rule means the UI only knows an interface (`AuthRepository`), never the datasource or Supabase directly. That keeps the domain testable and swappable (e.g. a mock repo), and the layer boundaries are what make the app maintainable as features grow.

---

## 3. DI with GetIt

All wiring lives in `init_dependencies.dart` using a single GetIt instance (`sl`):

```dart
sl.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sbClient: sl()));
sl.registerFactory<AuthRepository>(() => AuthRepositoryImpl(authRemoteDataSource: sl()));

sl.registerFactory(() => UserSignUp(authRepository: sl()));
sl.registerFactory(() => UserLogin(authRepository: sl()));
sl.registerFactory(() => CurrentUser(authRepository: sl()));

sl.registerLazySingleton(() => AuthBloc(userSignUp: sl(), userLogin: sl(), currentUser: sl(), appUserCubit: sl()));
```

> [DIAGRAM 3 — paste the DI graph: datasource → repository → usecases → bloc → pages]

**Why:** dependencies are constructor-injected top-down (`sl()` resolves lazily at call time), so nothing is hard-wired inside widgets and the same usecases/repositories can be swapped for mocks in tests. GetIt is a small, dependency-light service locator.

---

## 4. Secrets Management

- The real `app_secrets.dart` (Supabase URL + anon key) is **gitignored** and untracked — it exists only locally, never pushed.
- `app_secrets.example.dart` is committed with placeholder values so a new developer knows exactly what fields to fill and their shape.

> [DIAGRAM 4 — optional: paste a "who has the key" / secrets-flow visual]

**Why:** credentials stay out of version control while keeping the example (and the expected structure) inside the repo for discoverability. On a fresh clone you copy `app_secrets.example.dart → app_secrets.dart` and fill the real values.

---

## 5. Theme & Shared Widgets

- `core/theme/app_pallet.dart` — the color palette (`AppPallet`).
- `core/theme/theme.dart` — `AppTheme.darkTheme` (dark Material theme, app bar and gradient input borders).
- `core/common/widgets/loader.dart` — reusable `Loader`.
- `core/utils/show_snackbar.dart` — global `showSnackBar` helper used by both pages.
- Auth UI widgets (`AuthFormField`, `AuthGradientButton`) are shared within the auth feature.

**Why:** presentational building blocks are centralized in `core/` rather than re-created per page, so styling stays consistent and changes to the palette/theme propagate everywhere.

---

## 6. Auth Feature Flow

The user creates an account, logs in, and the app restores the session on launch:

1. **On app start** — `main.dart` dispatches `AuthUserLoggedIn`; the `CurrentUser` usecase checks Supabase for an existing session and, if present, updates `AppUserCubit` + emits `AuthSuccess`.
2. **Signup** — `SignupPage` validates the form, dispatches `AuthSignUp(name, email, password)`; `AuthBloc` runs `UserSignUp` → repository → Supabase; on success updates `AppUserCubit` and shows the Home page; on failure shows a snackbar.
3. **Login** — `LoginPage` dispatches `AuthLogin(email, password)`; `AuthBloc` runs `UserLogin` with the same Either/Failure pattern.

```
SignupPage ──AuthSignUp──▶ AuthBloc ──UserSignUp usecase──▶ AuthRepository
      ▲                                                        │
      └────── AuthSuccess/AuthFailure ◀── AppUserCubit ◀──────┘
```

> [DIAGRAM 5 — paste the auth sequence/flow diagram here]

**Why:** every path returns `Either<Failure, User>` from the repository, so the bloc paints `AuthFailure` messages straight into a snackbar — uniform, predictable error handling with no exceptions leaking past the repository boundary.
