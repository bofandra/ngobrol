# ngobrol. — The game that never ends

Ngobrol is a cooperative game for learning Systems Thinking through conversation. Start with the hermit crab discussion or bring a question of your own. The web playtest runs without credentials and keeps your topics, contributions, and provisional XP for the current session.

## Run the web playtest

Use Flutter **3.35.2** with Dart **3.9.0**, the versions used by CI.

```sh
flutter pub get --enforce-lockfile
flutter run -d chrome
```

For a release preview, serve the built files over HTTP.

```sh
flutter build web --no-web-resources-cdn
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

Open [the local preview](http://127.0.0.1:8080). After a successful draft PR workflow run, its **ngobrol-flutter-web** artifact will contain the same web files. Extract it and point the server at the extracted directory. See the [web playtest guide](docs/WEB_PLAYTEST.md) for the walkthrough, screenshots, and verification.

## Build Android for Internal testing

The offline Android playtest uses `com.bofandra.ngobrol` and targets API 36. Use Flutter 3.35.2, JDK 17, Android SDK 36, and NDK 28.2.13676358. The Android project pins AGP 8.13.2, Gradle 8.13, and Kotlin 2.3.0.

On the release Mac, the PKCS12 keystore lives at `~/.android/ngobrol/upload.p12` with alias `ngobrol-upload`. The login Keychain stores its password under `com.bofandra.ngobrol.android-upload`. Keep the keystore and its password available for future updates.

```sh
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export NGOBROL_ANDROID_KEYSTORE="$HOME/.android/ngobrol/upload.p12"
export NGOBROL_ANDROID_STORE_PASSWORD="$(
  security find-generic-password -a "$USER" -s com.bofandra.ngobrol.android-upload -w
)"
flutter pub get --enforce-lockfile
flutter build appbundle --release --no-pub
unset NGOBROL_ANDROID_STORE_PASSWORD
```

The upload bundle is `build/app/outputs/bundle/release/app-release.aab`. See the [handover](docs/HANDOVER.md) for the release verification. Upload the signed bundle to the **Internal testing** track in Play Console.

## Optional Supabase sandbox

Use a dedicated development project with anonymous sign-ins enabled. Apply `supabase/demo_schema.sql` to that project. Shared sandbox posts are visible to authenticated sandbox players.

```sh
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Supply a publishable client key. The three built-in topics can share posts, and **Refresh shared posts** retrieves recent posts from other players. If sharing fails, the contribution is marked as kept on this device for the session. Topics you create, map votes, proposals, and XP are session data. See the [demo scope](docs/demo-scope.md) and [handover](docs/HANDOVER.md) for the current status of live sandbox verification.

## Verify

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-web-resources-cdn --no-pub
```

Project context starts in [AGENTS.md](AGENTS.md) and the [handover](docs/HANDOVER.md).
