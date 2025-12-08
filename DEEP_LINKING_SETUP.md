# Deep Linking Setup Guide

This guide explains how to set up native deep linking for Android App Links and iOS Universal Links.

## Overview

The app uses native deep linking solutions:

- **Android**: App Links (Universal Links)
- **iOS**: Universal Links

Both platforms support deep links in the format:

- `https://coachapp.com/invite/{CODE}`
- `coachapp://invite/{CODE}` (custom scheme fallback)

## Prerequisites

1. A domain (`coachapp.com` or your custom domain) with HTTPS enabled
2. Ability to host files at `https://yourdomain.com/.well-known/`
3. Android app package name
4. iOS bundle identifier and Apple Developer Team ID

## Step 1: Android App Links Setup

### 1.1 Get SHA-256 Fingerprints

#### For Debug Builds:

```bash
cd android
./gradlew signingReport
```

Look for `SHA256:` under the `debug` variant in the output.

#### For Release Builds:

```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

### 1.2 Update assetlinks.json

Edit `.well-known/assetlinks.json`:

1. Replace `com.yourcompany.coach_dashboard` with your actual package name
   - Check `android/app/build.gradle` for `applicationId`
2. Replace the SHA-256 fingerprints:
   - Add your debug fingerprint
   - Add your release fingerprint

Example:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.coach_dashboard",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99",
        "11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF"
      ]
    }
  }
]
```

### 1.3 Host assetlinks.json

Upload the file to:

```
https://coachapp.com/.well-known/assetlinks.json
```

**Requirements:**

- ✅ HTTPS (required)
- ✅ Content-Type: `application/json`
- ✅ Accessible without authentication
- ✅ No redirects
- ✅ Returns 200 status code

### 1.4 Verify Android App Links

```bash
# Test file accessibility
curl https://coachapp.com/.well-known/assetlinks.json

# Verify app links (on device)
adb shell pm verify-app-links --re-verify com.yourcompany.coach_dashboard

# Check verification status
adb shell pm get-app-links com.yourcompany.coach_dashboard
```

## Step 2: iOS Universal Links Setup

### 2.1 Update apple-app-site-association

Edit `.well-known/apple-app-site-association`:

1. Replace `TEAM_ID` with your Apple Developer Team ID

   - Find it in Apple Developer Portal or Xcode

2. Replace `com.yourcompany.coach_dashboard` with your bundle identifier
   - Check `ios/Runner.xcodeproj` or Xcode project settings

Example:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "ABC123DEF4.com.example.coach_dashboard",
        "paths": ["/invite/*"]
      }
    ]
  }
}
```

### 2.2 Configure Associated Domains in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Associated Domains**
6. Add domain: `applinks:coachapp.com`

**Note:** The `Runner.entitlements` file has been created with this configuration. Xcode should automatically recognize it.

### 2.3 Host apple-app-site-association

Upload the file to:

```
https://coachapp.com/.well-known/apple-app-site-association
```

**Requirements:**

- ✅ HTTPS (required)
- ✅ Content-Type: `application/json` (or `application/pkcs7-mime` if signed)
- ✅ Accessible without authentication
- ✅ No redirects
- ✅ **No file extension** (important!)
- ✅ Returns 200 status code

### 2.4 Verify iOS Universal Links

```bash
# Test file accessibility
curl https://coachapp.com/.well-known/apple-app-site-association

# Should return JSON without errors
```

**Testing on Device:**

1. Open Safari on iOS device
2. Navigate to `https://coachapp.com/invite/ABC123`
3. If app is installed, a banner should appear at the top
4. Tap the banner to open the app

## Step 3: Hosting Options

### Option A: Firebase Hosting (Recommended)

1. Install Firebase CLI:

```bash
npm install -g firebase-tools
```

2. Initialize Firebase Hosting:

```bash
firebase init hosting
```

3. Create directory structure:

```bash
mkdir -p public/.well-known
```

4. Copy verification files:

```bash
cp .well-known/assetlinks.json public/.well-known/
cp .well-known/apple-app-site-association public/.well-known/
```

5. Deploy:

```bash
firebase deploy --only hosting
```

### Option B: Custom Server

Ensure your server:

- Serves files with correct Content-Type headers
- Supports HTTPS
- Allows access to `.well-known` directory
- Doesn't redirect these files

**Nginx Example:**

```nginx
location /.well-known/assetlinks.json {
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
}

location /.well-known/apple-app-site-association {
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
}
```

## Step 4: Testing Deep Links

### Android Testing

```bash
# Test App Link (Universal Link)
adb shell am start -a android.intent.action.VIEW \
  -d "https://coachapp.com/invite/ABC123" \
  com.yourcompany.coach_dashboard

# Test custom scheme (fallback)
adb shell am start -a android.intent.action.VIEW \
  -d "coachapp://invite/ABC123" \
  com.yourcompany.coach_dashboard
```

### iOS Testing

1. **Via Safari:**

   - Open `https://coachapp.com/invite/ABC123` in Safari
   - Banner should appear if app is installed

2. **Via Notes App:**

   - Create a note with the link
   - Long-press the link
   - Select "Open in Coach Dashboard"

3. **Via Terminal (Simulator):**

```bash
xcrun simctl openurl booted "https://coachapp.com/invite/ABC123"
```

## Step 5: Update Domain in Code

If you're using a different domain than `coachapp.com`, update:

1. **Android Manifest** (`android/app/src/main/AndroidManifest.xml`):

   - Update `android:host` in intent-filter

2. **iOS Info.plist** (`ios/Runner/Info.plist`):

   - Already configured via entitlements

3. **DeepLinkHandler** (`lib/utils/deep_link_handler.dart`):

   - Update host check in `extractInvitationCode()`

4. **InvitationService** (`lib/services/invitation_service.dart`):
   - Update link generation in `createInvitation()`

## Troubleshooting

### Android App Links Not Working

1. **Verify file is accessible:**

   ```bash
   curl https://coachapp.com/.well-known/assetlinks.json
   ```

2. **Check package name matches:**

   - `AndroidManifest.xml`
   - `assetlinks.json`
   - `build.gradle` (applicationId)

3. **Verify SHA-256 fingerprints:**

   ```bash
   adb shell pm get-app-links com.yourcompany.coach_dashboard
   ```

4. **Force re-verification:**
   ```bash
   adb shell pm set-app-links --package com.yourcompany.coach_dashboard 0 all
   adb shell pm verify-app-links --re-verify com.yourcompany.coach_dashboard
   ```

### iOS Universal Links Not Working

1. **Verify file is accessible:**

   ```bash
   curl https://coachapp.com/.well-known/apple-app-site-association
   ```

2. **Check file format:**

   - No file extension
   - Valid JSON
   - Correct Content-Type

3. **Verify Associated Domains:**

   - Xcode → Signing & Capabilities
   - Should show `applinks:coachapp.com`

4. **Check Team ID and Bundle ID:**

   - Must match in `apple-app-site-association`
   - Must match in Xcode project

5. **Test in Safari:**
   - Open link in Safari
   - Banner should appear if app is installed

## Production Checklist

- [ ] Replace `coachapp.com` with your actual domain
- [ ] Update package name in `assetlinks.json`
- [ ] Update bundle identifier in `apple-app-site-association`
- [ ] Add both debug and release SHA-256 fingerprints
- [ ] Add Apple Developer Team ID
- [ ] Host verification files on production domain
- [ ] Test on physical devices (not just emulators)
- [ ] Test both App Links and custom scheme fallback
- [ ] Test with app installed and not installed
- [ ] Verify HTTPS certificates are valid
- [ ] Test invitation flow end-to-end
- [ ] Monitor deep link analytics (if using third-party)

## Additional Resources

- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [iOS Universal Links Documentation](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
- [app_links Package Documentation](https://pub.dev/packages/app_links)
