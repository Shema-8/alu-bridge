# ALU Bridge

A mobile app that connects **ALU students** looking for internship experience
with **student-led startups** in the ALU ecosystem. Startups post opportunities,
students discover and apply, and everything updates in real time.

Built with **Flutter**, **Firebase** (Auth + Firestore), and **Riverpod** for
state management.

---

## The problem this solves

Two groups on campus have a matching problem:
- Students want internship experience but struggle to find it at established companies.
- Student founders need help (dev, design, marketing, research...) but have no easy way to reach students.

ALU Bridge is a focused marketplace for exactly that: startups post roles,
students apply, founders review. To keep the platform trustworthy, startups
can't post anything until an admin verifies they're a real, recognized ALU
venture.

---

## Features

**Core**
- Email/password authentication with email verification and password reset
- Role selection on first login (Student or Startup founder)
- Startup profile creation, pending admin verification before posting is unlocked
- Internship posting (title, skills, location, remote/paid, deadline, positions)
- Discovery with live search and category filtering
- Apply with a cover letter, with duplicate-apply prevention and deadline checks
- Everything is a live Firestore stream — no manual refresh, ever

**Beyond the minimum**
- Application status tracking (pending → reviewed → interview → accepted/rejected)
- Startup verification workflow with a dedicated admin review screen

**Not built yet (future work)**
- Notifications on application status change
- Bookmarking (UI exists on opportunity cards, not wired up yet)
- Skill-match scoring between a student's profile and a posting's required skills
- In-app messaging between founder and applicant

---

## Architecture

The app is layered so each piece only knows about the layer directly below it:

```
screens/       UI only. Watches providers, never talks to Firebase directly.
providers/     Riverpod providers. The only thing screens are allowed to watch.
repositories/  Business logic (e.g. "register" = create auth user + write profile doc).
services/      Thin wrappers around ONE Firebase product (Auth, or Firestore).
models/        Plain Dart classes mapped to Firestore documents.
```

**Why this shape?** If Firebase were ever swapped for another backend, only
`services/` would change. If a business rule changes (e.g. how registration
works), only `repositories/` changes. Screens never notice either change.

State management uses **Riverpod**:
- `StreamProvider` for anything that should update live (postings, applications, profile status)
- `AsyncNotifier` controllers for actions with loading/error states (register, apply, post)
- Small derived `Provider`s (e.g. filtered search results) that recompute automatically when their inputs change — no manual "refresh" logic anywhere

More detail in [`docs/architecture.md`](docs/architecture.md).
Firestore collections and fields in [`docs/firestore_schema.md`](docs/firestore_schema.md).

---

## Project structure

```
lib/
  core/            theme, colors, strings
  models/          data classes matching Firestore documents
  services/        FirebaseAuthService, FirestoreService
  repositories/    AuthRepository, StartupRepository, InternshipRepository, ApplicationRepository
  providers/       Riverpod providers — what screens actually watch
  routes/          AppRouter — reactive, state-driven navigation (no manual routing)
  screens/         UI, grouped by feature (auth/, student/, startup/)
  widgets/         shared, reusable UI pieces
docs/              architecture + schema notes
```

---

## Getting started

1. Install the Flutter SDK (3.x) and the FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   ```
2. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com) and enable:
   - Authentication → Email/Password sign-in
   - Firestore Database
3. Configure Firebase for this project:
   ```
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` for you.
4. In the Firebase Console, set your Firestore Security Rules so signed-in
   users can only read/write their own data (default rules block everything).
5. Install dependencies and run on a device or emulator (not a browser — this
   is a mobile app):
   ```
   flutter pub get
   flutter run
   ```

---

## Notes

- The Firebase config in `firebase_options.dart` is safe to commit — it's a
  public client identifier, not a secret. Actual access control lives in
  Firestore Security Rules, not in hiding this file.
