# ngobrol. — The game that never ends

A Flutter-first playable prototype of a collective Systems Thinking game. The visual direction is midnight navy, ocean teal and golden XP. Start with the hermit crab discussion, or create a topic of your own.

## Run the prototype

Install a current stable Flutter SDK, then:

```sh
flutter pub get
flutter create --platforms=android,web --project-name=ngobrol .
flutter run -d chrome
```

The platform scaffold command generates missing host files; do not use --overwrite.
Offline mode is the default and needs no keys. Local changes are in memory and reset on restart. The web host is included for direct web builds.

## Optional Supabase sandbox

Use a dedicated development project. Enable anonymous sign-ins in Auth, configure CAPTCHA/rate limits before exposing it publicly, and run `supabase/demo_schema.sql` in the SQL editor. No production project has been created or modified.

```sh
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Only a client publishable key belongs in the app. Never put a service-role or AI-provider secret in Flutter. The remote demo reads public discussion posts and writes authenticated posts for the three built-in topics. Use Refresh to fetch other players' contributions. Custom topics, graph edits, votes and XP are local in this version. Do not enter confidential information. Remote connection failures show a banner and the app remains usable offline.

## Walkthrough

1. Discover → select the hermit crab topic.
2. Talk → ask a question, answer, or suggest an idea. Earn provisional XP.
3. Living map → inspect causal hypotheses, select a connection, vote up/down or propose a change.
4. Review → add a proposed relationship; it appears in the map's review queue, not as established fact.
5. Profile → inspect contribution history and XP. Return to any topic; no final winner.

The starter map is a directed causal hypothesis map, not a complete CLD: it has no demonstrated feedback cycle. The AI helper is a clearly labelled deterministic mock, not a deployed LLM. It suggests a next question; players can manually propose a relationship. Community agreement is not evidence of causation.

## Verification

```sh
flutter analyze
flutter test
flutter build web
```

See docs/demo-scope.md for limitations and next steps. No CI/build result is claimed until these commands succeed.
