# 🚀 GitHub Repository Setup Guide

Complete step-by-step guide to set up your GitHub repository for hosting app updates.

---

## 📋 Prerequisites

- GitHub account (create one at https://github.com if you don't have)
- Git installed on your computer
- Your app's APK file ready

---

## 🎯 STEP 1: Create GitHub Repository

### Option A: Using GitHub Website (Easier)

1. **Go to GitHub**
   - Visit https://github.com
   - Log in to your account

2. **Create New Repository**
   - Click the `+` icon in top right corner
   - Select `New repository`

3. **Repository Settings**
   - **Repository name:** `khair_ul_madaaris_library`
   - **Description:** `Premium Library Management System for Madrasahs`
   - **Visibility:** ✅ Public (required for direct downloads)
   - **Initialize repository:** ✅ Check "Add a README file"
   - Click `Create repository`

### Option B: Using Command Line

```bash
# Navigate to your project folder
cd "c:\Users\Dell\Documents\flutter projects\khair_ul_madaaris_library"

# Initialize git (if not already done)
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Khair-ul-Madaaris Library v1.0.0"

# Add remote repository (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/khair_ul_madaaris_library.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## 🎯 STEP 2: Create version.json File

1. **In your project root**, create a file named `version.json`

2. **Copy this template:**

```json
{
  "version": "1.0.0",
  "versionCode": 1,
  "releaseDate": "2025-10-30",
  "downloadUrl": "https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/v1.0.0/app-release.apk",
  "fileSize": "40 MB",
  "mandatory": true,
  "changelog": [
    "✨ Initial release",
    "📚 Complete library management system",
    "🔍 QR code book scanning",
    "👨‍💼 Admin dashboard with statistics",
    "🌙 Dark mode support",
    "🔄 Google Sheets integration"
  ],
  "minAndroidVersion": 21,
  "sha256": ""
}
```

3. **Commit and push to GitHub:**

```bash
git add version.json
git commit -m "Add version.json for update system"
git push
```

---

## 🎯 STEP 3: Build Release APK

1. **Open terminal in your project folder**

2. **Build the release APK:**

```bash
flutter build apk --release
```

3. **Find your APK:**
   - Location: `build/app/outputs/flutter-apk/app-release.apk`
   - Size: Usually 35-45 MB

4. **Rename it (optional but recommended):**
   ```bash
   # Copy and rename
   cp "build/app/outputs/flutter-apk/app-release.apk" "app-release-v1.0.0.apk"
   ```

---

## 🎯 STEP 4: Create GitHub Release

### Using GitHub Website (Recommended)

1. **Go to your repository**
   - Navigate to `https://github.com/YOUR_USERNAME/khair_ul_madaaris_library`

2. **Create Release**
   - Click on `Releases` (right sidebar)
   - Click `Create a new release`

3. **Release Configuration**
   - **Choose a tag:** Type `v1.0.0` and click "Create new tag"
   - **Release title:** `Version 1.0.0 - Initial Release`
   - **Description:**
     ```markdown
     ## 🎉 Initial Release

     ### ✨ Features
     - Complete library management system
     - QR code book scanning
     - Admin dashboard with statistics
     - Dark mode support
     - Google Sheets integration
     - Offline-ready architecture

     ### 📥 Installation
     1. Download the APK below
     2. Allow installation from unknown sources
     3. Install and enjoy!

     ### 📊 Stats
     - Size: ~40 MB
     - Min Android: 5.0 (API 21)
     ```

4. **Attach APK**
   - Scroll down to "Attach binaries"
   - Drag and drop your `app-release.apk` file
   - OR click "Attach files" and select the APK

5. **Publish**
   - ✅ Check "Set as the latest release"
   - Click `Publish release`

---

## 🎯 STEP 5: Get Download URL

1. **After publishing**, you'll see your release page

2. **Right-click on the APK file** in the Assets section

3. **Copy link address** - it will look like:
   ```
   https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/v1.0.0/app-release.apk
   ```

4. **Update version.json** with this URL:
   ```json
   {
     "downloadUrl": "https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/v1.0.0/app-release.apk"
   }
   ```

5. **Commit and push:**
   ```bash
   git add version.json
   git commit -m "Update download URL in version.json"
   git push
   ```

---

## 🎯 STEP 6: Update Your App Code

1. **Open `lib/services/app_update_service.dart`**

2. **Find line 17** (the `_versionCheckUrl` constant)

3. **Replace with your actual URL:**
   ```dart
   static const String _versionCheckUrl =
       'https://raw.githubusercontent.com/YOUR_USERNAME/khair_ul_madaaris_library/main/version.json';
   ```

   **Replace `YOUR_USERNAME`** with your GitHub username!

4. **Example:**
   If your GitHub username is `john_doe`, it should be:
   ```dart
   static const String _versionCheckUrl =
       'https://raw.githubusercontent.com/john_doe/khair_ul_madaaris_library/main/version.json';
   ```

---

## 🎯 STEP 7: Test the Update System

### First Time Setup Test

1. **Install current version** (v1.0.0) on your device

2. **Create version 1.0.1:**
   - Update `pubspec.yaml`: Change `version: 1.0.0+1` to `version: 1.0.1+2`
   - Make a small change (e.g., add a comment somewhere)
   - Build new APK: `flutter build apk --release`

3. **Create new GitHub release:**
   - Tag: `v1.0.1`
   - Title: `Version 1.0.1 - Update Test`
   - Upload the new APK

4. **Update version.json:**
   ```json
   {
     "version": "1.0.1",
     "versionCode": 2,
     "releaseDate": "2025-10-30",
     "downloadUrl": "https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/v1.0.1/app-release.apk",
     "fileSize": "40 MB",
     "mandatory": true,
     "changelog": [
       "🐛 Bug fixes",
       "⚡ Performance improvements",
       "🔄 Updated update system"
     ]
   }
   ```

5. **Push changes:**
   ```bash
   git add version.json
   git commit -m "Release v1.0.1"
   git push
   ```

6. **Test on device:**
   - Open your app (still on v1.0.0)
   - Wait 2-3 seconds
   - Update dialog should appear!
   - Click "Download Update"
   - APK downloads and installs

---

## 🎯 STEP 8: Future Updates Process

### Every time you want to release an update:

1. **Update version in pubspec.yaml:**
   ```yaml
   version: 1.0.2+3  # Increment both numbers
   ```

2. **Build APK:**
   ```bash
   flutter build apk --release
   ```

3. **Create GitHub Release:**
   - Tag: `v1.0.2`
   - Upload APK
   - Write changelog

4. **Update version.json:**
   - Increment `versionCode`
   - Update `version`, `downloadUrl`, `releaseDate`, `changelog`

5. **Push to GitHub:**
   ```bash
   git add version.json pubspec.yaml
   git commit -m "Release v1.0.2"
   git push
   ```

6. **Done!** All users will get the update popup

---

## 📝 Quick Reference

### Important URLs (Replace YOUR_USERNAME)

**Repository:**
```
https://github.com/YOUR_USERNAME/khair_ul_madaaris_library
```

**Raw version.json:**
```
https://raw.githubusercontent.com/YOUR_USERNAME/khair_ul_madaaris_library/main/version.json
```

**Release download pattern:**
```
https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/vX.X.X/app-release.apk
```

---

## 🔧 Troubleshooting

### Issue: "Repository not found"
- Make sure repository is **Public**
- Check username spelling
- Ensure you're logged in

### Issue: "APK download fails"
- Verify APK is uploaded to GitHub Release
- Check download URL is correct
- Ensure release is published (not draft)

### Issue: "Update not detected"
- Check version.json is on `main` branch
- Verify `_versionCheckUrl` in code is correct
- Ensure `versionCode` in version.json is higher than current app
- Wait 2-3 seconds after opening app

### Issue: "Installation blocked"
- User needs to enable "Install from unknown sources"
- Android 8+: Permission is per-app
- Settings > Apps > Special access > Install unknown apps

---

## ✅ Verification Checklist

Before going live, verify:

- [ ] Repository is public on GitHub
- [ ] version.json exists in main branch
- [ ] v1.0.0 release is created with APK
- [ ] Download URL in version.json is correct
- [ ] `_versionCheckUrl` in code points to your repository
- [ ] Built and installed current version on test device
- [ ] Created v1.0.1 test release
- [ ] Update popup appears on test device
- [ ] APK downloads successfully
- [ ] App installs and opens correctly

---

## 🎉 You're Done!

Your app now has a professional update system! Users will automatically see update notifications, and you can push updates instantly without any app store delays.

---

## 💡 Pro Tips

1. **Always test updates** on a test device first
2. **Write clear changelogs** so users know what's new
3. **Keep version.json updated** immediately after releasing
4. **Use semantic versioning:** MAJOR.MINOR.PATCH (e.g., 1.0.0 → 1.0.1 → 1.1.0 → 2.0.0)
5. **Backup your release APKs** locally
6. **Consider staging releases** to a small group first

---

**Need Help?** Open an issue on GitHub or contact support!
