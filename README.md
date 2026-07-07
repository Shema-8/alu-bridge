# ALU Bridge

Connects ALU students seeking internships with student-led startups in the
ALU ecosystem. Built with Flutter + Firebase + Riverpod.

## Status — all minimum requirements from the brief are implemented
✅ Authentication and onboarding (register, login, forgot password, logout, email verification, role selection)
✅ Startup profiles + verification (create/edit profile, pending → admin review → verified/rejected, dashboard gated on status)
✅ Internship/opportunity posting (verified startups only; title, description, skills, location, remote, paid, deadline, positions)
✅ Opportunity discovery and search (Discover + Explore tabs, category chips, live search)
✅ Application/interest submission (cover letter, duplicate-apply prevention, deadline gating)
✅ Real-time/dynamic updates (every screen above is a Firestore stream — a new posting appears on student screens instantly, an admin approval flips the founder's dashboard instantly)
✅ Persistent Firebase backend (Auth + Firestore throughout)
✅ Proper state management (Riverpod, layered services → repositories → providers → screens)

## Beyond the minimum (stretch features actually built)
✅ Application status tracking (pending → reviewed → interview → accepted/rejected)
✅ Startup verification workflow with admin review screen

## Stretch features NOT yet built (good "future work" material for the report)
🚧 Notifications (e.g. "your application moved to Interview")
🚧 Bookmarking (UI icons exist on opportunity cards, not yet wired to a `bookmarks` collection)
🚧 Skill matching (`skillsRequired` data already exists; a % match against the student's own skills is a natural next add)
🚧 Messaging/chat between founder and applicant
🚧 Real admin-role gating (see docs/architecture.md "known limitations")

See `docs/architecture.md` for the layered design and `docs/firestore_schema.md`
for the full data model (including collections not built yet).

## Setup
1. Install Flutter SDK (3.x) and the FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   ```
2. Create a Firebase project at console.firebase.google.com, enable:
   - Authentication → Email/Password
   - Firestore Database
   - Storage
3. From the project root, run:
   ```
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`. Then uncomment the
   `options:` line in `lib/main.dart`.
4. Install dependencies and run:
   ```
   flutter pub get
   flutter run
   ```

## Project structure
```
lib/
  core/            theme, colors, strings, shared utils
  models/          plain Dart data classes mapped to Firestore docs
  services/        thin wrappers around a single Firebase product
  repositories/    business logic combining one or more services
  providers/       Riverpod providers — the only thing screens watch
  routes/          AppRouter: reactive, state-driven navigation
  screens/         UI, grouped by feature (auth/, student/, startup/)
  widgets/         shared, reusable UI components
docs/              architecture + schema docs feeding the technical report
```
