# Firestore Schema

This matches the planned data model. Collections marked **(stub)** have
their Dart model defined in `lib/models/` but no repository/UI yet —
build those together in the next session.

## `users/{uid}`
| Field | Type | Notes |
|---|---|---|
| email | string | |
| name | string | |
| role | string | `"student"` \| `"startup"` |
| photoUrl | string? | nullable |
| onboardingComplete | bool | flips true after role selection |
| createdAt | timestamp | server timestamp |

## `startups/{uid}` (stub)
| Field | Type | Notes |
|---|---|---|
| name | string | |
| description | string | |
| industry | string | |
| logoUrl | string? | |
| founderName | string | |
| contactEmail | string | |
| status | string | `pending` \| `verified` \| `rejected` |

**Verification workflow:** founder submits → document created with
`status: pending` → an admin-only screen (TODO) lists pending startups →
approving sets `status: verified`. Internship posting should be gated
on `status == verified` in both the UI and Firestore security rules.

## `internships/{id}`
| Field | Type | Notes |
|---|---|---|
| startupId | string | FK -> startups, owner |
| title | string | |
| description | string | |
| skillsRequired | array<string> | drawn from a fixed vocabulary in `post_internship_screen.dart` so search/matching stays reliable |
| location | string | "Remote" when `remote == true` |
| remote | bool | |
| paid | bool | |
| deadline | timestamp (ISO string) | `InternshipModel.isOpen` derives open/closed from this — no separate status field needed |
| positions | number | |
| createdAt | timestamp (ISO string) | |

## `applications/{id}`
| Field | Type | Notes |
|---|---|---|
| studentId | string | FK -> users |
| internshipId | string | FK -> internships |
| coverLetter | string | |
| status | string | `pending`→`reviewed`→`interview`→`accepted`/`rejected` |
| submittedAt | timestamp | |

## Planned but not yet modeled
`messages`, `notifications`, `bookmarks` — add these as their own
collections when we build chat/notifications/bookmarking.

## Security rules (write before any stub becomes real)
- A user can only write their own `users/{uid}` document.
- Only the founder uid matching `startups/{uid}` can edit that startup.
- Only `status: verified` startups can create documents in `internships`.
- A student can only create an `applications` doc with their own uid as
  `studentId`; only the owning startup can update its `status`.
