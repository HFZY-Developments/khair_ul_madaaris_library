# 🚀 GitHub Setup - Next Steps

You've successfully committed your code! Here's what to do next:

---

## ✅ What You Just Did

```bash
✅ Fixed the 'nul' file issue
✅ Configured git for Windows
✅ Added .gitattributes for proper line endings
✅ Committed all changes to git
```

---

## 📋 STEP 1: Create GitHub Repository

### Option A: GitHub Website (Easiest)

1. **Go to GitHub**
   - Visit https://github.com
   - Click the **+** icon (top right)
   - Select **"New repository"**

2. **Configure Repository**
   - **Name:** `khair_ul_madaaris_library`
   - **Description:** `Premium Library Management System for Islamic Madrasahs`
   - **Visibility:** ✅ **PUBLIC** (required for direct APK downloads)
   - ❌ **DO NOT** check "Initialize with README" (you already have one!)
   - Click **"Create repository"**

3. **Copy the Commands**

After creating, GitHub will show you commands. **Copy them!**

They'll look like:
```bash
git remote add origin https://github.com/YOUR_USERNAME/khair_ul_madaaris_library.git
git branch -M main
git push -u origin main
```

---

## 📋 STEP 2: Link Your Local Repo to GitHub

**In your terminal, run the commands GitHub gave you:**

```bash
# Replace YOUR_USERNAME with your actual GitHub username!
git remote add origin https://github.com/YOUR_USERNAME/khair_ul_madaaris_library.git
git branch -M main
git push -u origin main
```

**Example (if your username is john_doe):**
```bash
git remote add origin https://github.com/john_doe/khair_ul_madaaris_library.git
git branch -M main
git push -u origin main
```

**Expected output:**
```
Enumerating objects: 20, done.
Counting objects: 100% (20/20), done.
...
To https://github.com/YOUR_USERNAME/khair_ul_madaaris_library.git
 * [new branch]      main -> main
```

---

## 📋 STEP 3: Build Your First Release APK

```bash
flutter build apk --release
```

**APK Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**File size:** ~35-45 MB

---

## 📋 STEP 4: Create GitHub Release

1. **Go to your repository on GitHub**
   ```
   https://github.com/YOUR_USERNAME/khair_ul_madaaris_library
   ```

2. **Click "Releases"** (right sidebar)

3. **Click "Create a new release"**

4. **Fill in details:**
   - **Tag:** `v1.0.0`
   - **Title:** `Version 1.0.0 - Initial Release`
   - **Description:**
     ```markdown
     ## 🎉 Initial Release

     ### Features
     - Complete library management system
     - QR code book scanning
     - Admin dashboard with statistics
     - Dark mode support
     - Google Sheets integration
     - In-app update system

     ### Installation
     1. Download the APK below
     2. Enable "Install from unknown sources"
     3. Install and enjoy!
     ```

5. **Upload APK**
   - Scroll to "Attach binaries"
   - Drag and drop: `build/app/outputs/flutter-apk/app-release.apk`

6. **Publish**
   - ✅ Check "Set as the latest release"
   - Click **"Publish release"**

---

## 📋 STEP 5: Get Download URL

1. After publishing, **right-click** on the APK in Assets
2. **Copy link address**
3. It will look like:
   ```
   https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/v1.0.0/app-release.apk
   ```

---

## 📋 STEP 6: Update version.json

**Edit the file `version.json` in your project:**

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
    "📚 Complete library management",
    "🔍 QR code scanning",
    "👨‍💼 Admin dashboard",
    "🌙 Dark mode",
    "🔄 Auto-update system"
  ]
}
```

**Replace YOUR_USERNAME with your actual GitHub username!**

**Then commit and push:**
```bash
git add version.json
git commit -m "Update version.json with release URL"
git push
```

---

## 📋 STEP 7: Update Code with Your Username

**File to edit:** `lib/services/app_update_service.dart` - Line 17

**Find this:**
```dart
static const String _versionCheckUrl =
    'https://raw.githubusercontent.com/YOUR_USERNAME/khair_ul_madaaris_library/main/version.json';
```

**Replace with (example for username john_doe):**
```dart
static const String _versionCheckUrl =
    'https://raw.githubusercontent.com/john_doe/khair_ul_madaaris_library/main/version.json';
```

**Commit and push:**
```bash
git add lib/services/app_update_service.dart
git commit -m "Configure update URL with GitHub username"
git push
```

---

## 🧪 STEP 8: Test the Update System

### Test Current Version

1. Install the APK on your device
2. Open Settings → About
3. Click "Check for Updates"
4. Should say: "You're up to date!"

### Test Update Detection

1. Update `pubspec.yaml` line 5:
   ```yaml
   version: 1.0.1+2  # Was 1.0.0+1
   ```

2. Build new APK:
   ```bash
   flutter build apk --release
   ```

3. Create new GitHub Release:
   - Tag: `v1.0.1`
   - Upload new APK

4. Update `version.json`:
   ```json
   {
     "version": "1.0.1",
     "versionCode": 2,
     "downloadUrl": "https://github.com/YOUR_USERNAME/.../v1.0.1/app-release.apk",
     "changelog": ["🐛 Test update", "✨ Update system works!"]
   }
   ```

5. Push to GitHub:
   ```bash
   git add version.json pubspec.yaml
   git commit -m "Release v1.0.1 - Test update"
   git push
   ```

6. **Test:** Open old app (v1.0.0) → Update popup should appear!

---

## ✅ Verification Checklist

Before rolling out to users:

- [ ] GitHub repository created and public
- [ ] Code pushed to GitHub successfully
- [ ] Release v1.0.0 created with APK
- [ ] version.json updated with correct download URL
- [ ] YOUR_USERNAME replaced in app_update_service.dart
- [ ] Tested on device - app installs correctly
- [ ] Tested update check button in Settings
- [ ] Created test update (v1.0.1) and verified detection

---

## 🎉 You're Done!

Once all steps are complete:
- ✅ Your code is on GitHub
- ✅ Users can download the APK
- ✅ Update system is active
- ✅ You can push updates instantly!

---

## 💡 Quick Reference

**Your Repository URL:**
```
https://github.com/YOUR_USERNAME/khair_ul_madaaris_library
```

**Raw version.json URL:**
```
https://raw.githubusercontent.com/YOUR_USERNAME/khair_ul_madaaris_library/main/version.json
```

**Release Download Pattern:**
```
https://github.com/YOUR_USERNAME/khair_ul_madaaris_library/releases/download/vX.X.X/app-release.apk
```

**Remember:** Always replace `YOUR_USERNAME` with your actual GitHub username!

---

## 🆘 Common Issues

### "Repository not found"
- Make sure repository is **public**
- Check you typed username correctly

### "Failed to push"
- Check internet connection
- Verify GitHub credentials
- Make sure you have push access

### "Update not detected"
- Verify version.json is accessible at raw URL
- Check versionCode is incremented
- Ensure YOUR_USERNAME is replaced in code
- Wait 2-3 seconds after opening app

---

**Need detailed help?** Check **GITHUB_SETUP_GUIDE.md** for complete instructions!
