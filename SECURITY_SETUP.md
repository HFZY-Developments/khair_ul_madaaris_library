# Security Setup Guide

## ⚠️ IMPORTANT: Protecting Your Sensitive Credentials

This project uses a **secure configuration system** to prevent sensitive credentials from being exposed on GitHub.

## 🔒 What is Protected?

The following sensitive information is **excluded from git** and will NOT be pushed to GitHub:

1. **Google Sheets Spreadsheet ID** - Your private sheet document ID
2. **OAuth Client ID** - Your Google Cloud OAuth credentials
3. **Admin Password** - Your app's admin panel password

## 📁 File Structure

### Files in Your Project:

- ✅ `lib/core/constants/app_config.dart` - **NEVER committed** (excluded by .gitignore)
  - Contains your ACTUAL sensitive credentials
  - Stays only on your local machine

- ✅ `lib/core/constants/app_config.dart.template` - **Safe to commit**
  - Template file with placeholder values
  - Share this with other developers
  - No real credentials inside

- ✅ `lib/core/constants/app_constants.dart` - **Safe to commit**
  - Imports credentials from `app_config.dart`
  - Contains only non-sensitive constants

## 🚀 Setup for New Developers

If someone else clones your repository, they should:

1. Copy the template file:
   ```bash
   cp lib/core/constants/app_config.dart.template lib/core/constants/app_config.dart
   ```

2. Edit `lib/core/constants/app_config.dart` and fill in their own credentials:
   ```dart
   class AppConfig {
     // Replace with your actual Google Sheets ID
     static const String spreadsheetId = 'YOUR_SPREADSHEET_ID_HERE';

     // Replace with your OAuth Client ID
     static const String serverClientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';

     // Set a secure admin password
     static const String adminPassword = 'YOUR_SECURE_PASSWORD';
   }
   ```

3. Build and run the app as normal

## ✅ Verification Checklist

Before pushing to GitHub, verify:

- [ ] `.gitignore` contains: `lib/core/constants/app_config.dart`
- [ ] `app_config.dart` exists locally (for your development)
- [ ] `app_config.dart.template` exists with placeholder values
- [ ] Run `git status` - you should NOT see `app_config.dart` listed

## 🔍 How to Check What Will Be Pushed

Run this command to see what git is tracking:

```bash
git status
```

You should **NOT** see:
- ❌ `lib/core/constants/app_config.dart`

You **SHOULD** see (if you made changes):
- ✅ `lib/core/constants/app_config.dart.template`
- ✅ `lib/core/constants/app_constants.dart`
- ✅ `.gitignore`

## 🛡️ Additional Security Tips

1. **Never screenshot or share** your `app_config.dart` file
2. **Rotate credentials** if accidentally exposed:
   - Generate new OAuth Client ID in Google Cloud Console
   - Create a new Google Sheet and update the ID
   - Change your admin password

3. **For Google Sheets Protection**:
   - Use Google Sheets permissions to restrict who can edit
   - Set the sheet to "View only" for specific email addresses
   - Consider using a service account for production apps

4. **Admin Password**:
   - Change from default `admin123` to something secure
   - Use a password manager to generate a strong password
   - Consider adding password hashing in production

## 📚 Files in This Security System

| File | Purpose | Committed to Git? |
|------|---------|-------------------|
| `app_config.dart` | Your actual credentials | ❌ NO |
| `app_config.dart.template` | Template for developers | ✅ YES |
| `app_constants.dart` | App constants, imports config | ✅ YES |
| `.gitignore` | Specifies files to exclude | ✅ YES |

## ⚠️ What If I Already Pushed Sensitive Data?

If you accidentally committed sensitive credentials:

1. **Immediately rotate all credentials**:
   - Create new OAuth Client ID
   - Change admin password
   - Consider creating new Google Sheet

2. **Remove from git history** (advanced):
   ```bash
   # This rewrites git history - use carefully!
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/core/constants/app_constants.dart" \
     --prune-empty --tag-name-filter cat -- --all

   git push origin --force --all
   ```

3. **Consider the repository compromised** - it's safer to:
   - Create a new private repository
   - Use the new security system from the start
   - Never push the old sensitive files

## 🎯 Summary

✅ **Your credentials are NOW protected** from GitHub exposure
✅ **app_config.dart** stays on your machine only
✅ **Other developers** can use the template to set up their own credentials
✅ **Your Google Sheets** is safe from strangers accessing/destroying data

---

**Built with security in mind by HFZY Developments**
