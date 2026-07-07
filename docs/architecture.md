# Architecture

```
Screens (UI, ConsumerWidget/ConsumerStatefulWidget)
      │ watches / reads
      ▼
Providers (Riverpod: StreamProvider, FutureProvider, AsyncNotifier)
      │ calls
      ▼
Repositories (combine 1+ services into one feature-level API)
      │ calls
      ▼
Services (thin wrappers around a single Firebase product)
      │ calls
      ▼
Firebase (Auth, Firestore, Storage)
```

## Why this many layers?
Each layer has exactly one job, which is what the rubric calls "proper
separation of concerns":

- **Services** know nothing about the app — only about one Firebase
  product. `FirebaseAuthService` could be swapped for a different auth
  provider without anything else changing.
- **Repositories** hold business logic that spans multiple services —
  e.g. registering a user touches both Auth *and* Firestore.
- **Providers** hold UI-facing state (loading/error/data) and are what
  screens actually watch. They contain zero Firebase imports.
- **Screens** are dumb: they read state and call provider methods.
  They never call Firebase directly.

## Why Riverpod specifically?
- Compile-time safety: `ref.watch(provider)` fails at compile time if
  the provider type changes, unlike `InheritedWidget`-based Provider
  package patterns that fail at runtime.
- `AsyncNotifier` + `AsyncValue` gives loading/error/data states for
  free — no separate `isLoading` boolean fields scattered around.
- Providers like `userProfileProvider` automatically re-run when an
  upstream provider they `watch` (like `firebaseUserProvider`)
  changes — this is the "state propagates automatically" behavior to
  demonstrate live in the demo (e.g. sign out and watch the whole app
  reroute to LoginScreen with no manual navigation call).

## How the auth + onboarding flow demonstrates this end-to-end
1. `RegisterScreen` calls `authControllerProvider.notifier.register(...)`.
2. `AuthController` (an `AsyncNotifier`) sets `state = AsyncLoading()`
   — the button's spinner appears automatically because the screen
   watches this provider.
3. `AuthController` calls `AuthRepository.register(...)`.
4. `AuthRepository` calls `FirebaseAuthService` to create the account,
   then `FirestoreService` to write the initial profile document.
5. Firebase Auth's `authStateChanges()` stream — wrapped by
   `firebaseUserProvider` — emits the new user.
6. `AppRouter` (which watches `firebaseUserProvider`) rebuilds and
   re-evaluates `userProfileProvider`, sees `onboardingComplete: false`,
   and shows `RoleSelectionScreen` — with **no explicit
   `Navigator.push` call anywhere in this flow**.
7. Picking a role calls `chooseRole()`, which writes to Firestore and
   invalidates `userProfileProvider`, which re-fetches, which makes
   `AppRouter` rebuild again and route to the correct dashboard.

## Scalability notes (for the report)
- Adding a new feature (e.g. internship posting) means adding one
  model, one repository, one or two providers, and screens — the
  existing layers don't need to change.
- Firestore's per-document reads mean `userProfileProvider` only ever
  reads one small document on every screen, not large nested objects —
  keeps reads cheap as the user base grows.
- Security rules (see `docs/firestore_schema.md`) enforce role-based
  write access at the database level, not just in the UI, so the
  architecture stays safe even as more screens are added by more
  contributors.

## How the Discover/Explore search demonstrates derived state
This is the second big "state propagation" example to show in the demo,
alongside the auth flow:

1. `searchQueryProvider` and `selectedCategoryProvider` are plain
   `StateProvider`s — the search field's `onChanged` writes directly
   to `searchQueryProvider`.
2. `filteredInternshipsProvider` `watch`es BOTH of those providers AND
   the live Firestore stream (`internshipsStreamProvider`). Riverpod
   automatically re-runs this computation whenever any of the three
   changes — typing a letter, tapping a category chip, or a startup
   posting a new internship in real time all trigger the same
   recomputation path.
3. Both `DiscoverScreen` and `ExploreScreen` watch this ONE computed
   provider. There is no duplicated filtering logic between the two
   screens, and no manual "refresh" button anywhere — it's reactive by
   construction.

## How startup verification demonstrates role-gated state
A third demo talking point, showing how state + Firestore rules
together enforce the brief's "only valid startups recognized at ALU"
requirement:

1. `myStartupProvider` watches `startups/{currentFounderUid}` in real
   time. If it's null, the dashboard shows "Create startup profile"
   instead of a posting UI — the UI branches purely on data, not on a
   separate "hasProfile" boolean someone has to remember to update.
2. Submitting the form writes `status: "pending"`. The SAME provider
   updates instantly and the dashboard now shows the `VerificationBanner`
   pending state — no manual refresh, no second screen needed.
3. `pendingStartupsProvider` (used by `AdminVerificationScreen`) is a
   completely separate query filtered `where status == pending`. The
   admin Approve/Reject buttons call `setStatus`, which flips the
   founder's own `myStartupProvider` stream to "verified" on THEIR
   device in real time — a good live demo: open two devices/emulators,
   approve on one, watch the banner change on the other.
4. Posting (next module) checks `startup.status == verified` before
   showing the "Post internship" button — UI-level gating that should
   be mirrored in Firestore security rules so it can't be bypassed by
   calling Firestore directly.

## How posting closes the loop end-to-end (the strongest single demo moment)
This is worth demonstrating live with two devices/emulators side by side:

1. A verified founder opens `PostInternshipScreen` and submits a posting.
   `InternshipController.post()` writes one new document to `internships`.
2. `internshipsStreamProvider` (watched by `DiscoverScreen`/`ExploreScreen`
   on a STUDENT's device) is a live Firestore listener — it fires
   immediately, no pull-to-refresh, no app restart.
3. `filteredInternshipsProvider` recomputes automatically (it watches
   that stream), so the new posting appears already passed through
   whatever search/category filter the student currently has active.
4. The student applies → `ApplicationController.apply()` writes to
   `applications` → `myInternshipsProvider` on the FOUNDER's dashboard
   doesn't change (applications aren't shown there yet — see
   limitations), but `myApplicationsProvider` on the student's own
   Applications tab updates instantly.

This single flow exercises CRUD (create + delete), real-time sync,
state propagation, and role-gated UI all at once — it's the one to
lead with in the demo video.

## Known limitations (be upfront about these in the report)
- **Admin access is not actually gated.** Any signed-in founder can
  open `AdminVerificationScreen` from the dashboard's app bar icon.
  Production fix: a custom Firebase Auth claim or an `admins`
  collection, checked both in the UI and in Firestore security rules.
- **Founders can't yet see WHO applied to their postings** — only
  students see their own application status. A "View applicants"
  screen on the startup side (reading `applications` filtered by
  `internshipId`, then letting the founder update `status`) is the
  natural next feature and reuses `ApplicationRepository` almost as-is.
- **No Firestore security rules file is included** — the schema doc
  describes what they SHOULD enforce, but writing and testing the
  actual `firestore.rules` file is still open work.
- **No automated tests.** Given Riverpod's repository injection
  pattern (every repository constructor accepts an optional override),
  unit-testing controllers with fake repositories is straightforward
  to add later without changing any production code.

## Reliability audit (fixed before final submission)
A full static pass was run across every file checking: provider references
resolve, imports resolve, brace/paren balance, and no calls to APIs from
undeclared packages. Three real issues were caught and fixed:
- `firstOrNull` was used in `applications_screen.dart` without the
  `collection` package declared — would have failed to compile. Replaced
  with a manual null-safe lookup.
- Discover screen's "Engineering" category could never match any
  posting because it wasn't in the postable skills vocabulary in
  `post_internship_screen.dart` — the button would always show zero
  results. Categories were aligned to the exact same vocabulary founders
  can select from when posting.
- `google_fonts` fetches its font over the network on first run, which
  is a real risk during a live grading demo on unreliable wifi. Removed
  in favor of the bundled system font — zero behavior change, zero
  network dependency.

## What's left to build (stretch features, prioritized)
