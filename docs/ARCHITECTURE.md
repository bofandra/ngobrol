# Architecture

## Stack decision
Flutter mobile/web; Supabase Auth, PostgreSQL, Realtime, Edge Functions. Earlier design DOCX's React/Node suggestion is superseded. No extra server unless justified. Server-side AI provider undecided. All live infrastructure is unprovisioned at handover.

## Current code
lib/main.dart: UI, seeded Topic/Post/Link objects, local in-memory actions, CustomPainter causal map, simple local XP. lib/backend.dart: optional Supabase initialization, anonymous Auth, select/insert shared posts, manual refresh. supabase/demo_schema.sql: limited authenticated sandbox posts table with RLS. web/index.html and pubspec.yaml included. Tests authored but not run. No lockfile or native host scaffold verified.

## Target boundaries
Flutter feature modules (discover, topic, talk, map, proposals/review, evidence, rewards, profile/moderation) → repository interfaces (local demo / Supabase) → Supabase Auth + PostgreSQL/RLS. Realtime authorized event stream; Edge Functions for orchestration, rate limits, AI provider calls and queue. Database transactions/RPC for authoritative version and XP operations. Treat model output and player posts as untrusted. Avoid exposing privileged functions or keys.

## Proposed persistent model
| Entity | Key fields / constraints |
|---|---|
| profiles | auth user id, display name, preferences; privacy |
| topics | id, owner, question, boundary, visibility, status, current graph version |
| memberships | topic/user unique; steward/contributor/viewer; authorized changes |
| posts | topic, author, type, parent, body, status, timestamps |
| evidence | citation, URL, note, relevance, limits, source and access |
| factors | stable IDs; immutable revision with label/definition/context/unit/status |
| links | stable IDs; revisions with from/to, sign, delay, rationale/context/status |
| proposals | topic/base version, operations, source IDs, uncertainty, origin, status |
| reviews | proposal/reviewer, decision and reason |
| votes | unique actor/target/revision, up/down/withdraw; agreement only |
| graph_versions | topic/version unique, parent, applied proposal, checksum |
| ai_jobs | idempotency input hash, state, model/prompt version, output/errors |
| xp_events | unique award key, delta, rule version, review, compensating reversal |
| follows/notifications/reports | actor, topic/target, read status, decision/audit |

All references must enforce same topic and visibility; private topics membership checks for reads, writes, search and Realtime. Use RLS and explicit grants for exposed tables; ownership predicates and WITH CHECK on updates. Do not trust user-editable JWT metadata for authorization. Use security invoker by default; privileged functions tightly scoped. Clients never write XP or canonical map versions directly. Keep service credentials server-side. Minimize personal data and configure Auth abuse protection before public access.

## AI pipeline
New post → authorized context selection and job queue → model structured JSON proposal → deterministic schema/domain validation → draft overlay + sources → human review → atomic version publish → events/notifications/XP.
Draft operation fields: operation, target ID or new factor definition, endpoints, polarity (+/-), optional delay, rationale, context, source post IDs, uncertainty, duplicate candidates. Reject dangling edges, cross-topic IDs, invented source IDs, malformed operations and self-links by default; identify cycles algorithmically. Do not infer causation from correlation alone. Model cannot execute tools or mutate DB based on post text. Token budget, retries and idempotency; manual proposal when unavailable. Separate quoted sources, observations, interpretations, assumptions and causal hypotheses. Show dissent and evidence quality.

## Concurrency/API contracts
Create topic, list/search, create/list posts, propose, vote/withdraw, review, apply against base version, list revisions/evidence/XP, report. Use cursor pagination, idempotency keys for writes, auth check every resource, 409 stale version, 422 invalid change, 403 unauthorized, 429 rate limit. Nonconflicting rebase may be offered, never silent overwrite. RLS verified for two independent users. No production implementation of these target contracts yet.

## Testing
Unit: polarity, cycles, duplicate detection, voting, XP rules, version conflict. Widget: topic create, composer, map/list, votes, pending proposal, profile. Integration: two-user Auth, RLS, Realtime, AI proposal provenance, stale publish, rollback, XP retries, moderation. CI Flutter analyze/test/build; secrets only in environment. Deployment approval separate.
