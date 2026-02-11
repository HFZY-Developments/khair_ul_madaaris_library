# In-App Update Release Process

Follow this checklist for each release used by the app updater.

## 1) Build release APK

```bash
flutter build apk --release
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

## 2) Compute SHA-256 hash

PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 build/app/outputs/flutter-apk/app-release.apk | Select-Object -ExpandProperty Hash
```

## 3) Update `version.json`

Set:

- `version`
- `versionCode`
- `releaseDate`
- `downloadUrl`
- `mandatory`
- `sha256` (must be 64 lowercase hex characters)

Important: do not publish `version.json` with a placeholder hash value. The updater now blocks installs unless the hash is valid and matches the downloaded APK.

## 4) Upload APK to GitHub Release

Tag format:

`vX.Y.Z`

Asset name:

`app-release.apk`

## 5) Publish metadata

Commit and push updated `version.json` so installed clients can detect the new release.
