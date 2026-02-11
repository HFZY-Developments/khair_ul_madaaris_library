# Android Release Signing Setup

This app now enforces release signing for production builds.

## Why this matters

- Release builds must be signed with a real keystore.
- For update compatibility, use the same signing key as existing installed versions.
- If signing config is missing, release tasks fail fast with a clear Gradle error.

## 1) Create or reuse your production keystore

If you already shipped builds, reuse that same keystore.

If you need a new one:

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

## 2) Create `android/key.properties`

Copy `android/key.properties.example` to `android/key.properties` and fill your real values.
Do not commit real secrets.

```properties
storeFile=../upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```

`storeFile` can be absolute or relative to the Android root project directory.

## 3) Build signed release

```bash
flutter build apk --release
```

If `key.properties` or the keystore path is invalid, release build stops with an actionable error.
