# 🚩 RedFlag Names — Setup Guide for chAs Tech Group

## ⚡ QUICK START (5 Steps)

---

### STEP 1 — Upload to GitHub

```bash
# Create a new repo on GitHub called: redflag_names
# Then run:

cd redflag_names
git init
git add .
git commit -m "🚩 Initial: RedFlag Names Flutter app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/redflag_names.git
git push -u origin main
```

GitHub Actions will **automatically build your APK** on push. ✅
Go to: `Actions` tab → click the latest run → download the APK artifact.

---

### STEP 2 — Get Your AdMob IDs

1. Go to [admob.google.com](https://admob.google.com)
2. Create a new App → "RedFlag Names" → Android
3. Create 3 ad units:
   - **Banner** ad
   - **Interstitial** ad  
   - **Rewarded** ad
4. Copy the IDs and replace in:

**`lib/services/ad_service.dart`** — Replace ALL 6 IDs (3 Android + 3 iOS)

**`android/app/src/main/AndroidManifest.xml`** — Replace App ID:
```xml
android:value="ca-app-pub-YOUR_APP_ID"
```

**`ios/Runner/Info.plist`** — Replace App ID:
```xml
<string>ca-app-pub-YOUR_APP_ID</string>
```

---

### STEP 3 — Create Your Android Icon (Already Done!)

Your icon from the uploaded image has been processed:
- ✅ White background removed
- ✅ All Android mipmap sizes generated (mdpi → xxxhdpi)
- ✅ Both regular and round variants

---

### STEP 4 — Build & Test

```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release

# Build for Play Store
flutter build appbundle --release
```

---

### STEP 5 — Create a GitHub Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the release job → creates a GitHub Release with your APK + AAB attached automatically! 🎉

---

## 🔔 NOTIFICATION SETUP

Notifications are already wired using **flutter_local_notifications**.

- Uses the **device's default notification sound** (no extra config needed)
- 3 daily engagement notifications scheduled automatically on first app launch
- Result notification shown after each analysis

**No Firebase or FCM needed** for local notifications.

---

## 🔊 SOUNDS

6 custom sounds are pre-bundled in `assets/sounds/`:

| File | When Played |
|---|---|
| `woosh.wav` | Name entered / scanning starts |
| `dramatic.wav` | Result reveals (medium chaos) |
| `laugh.wav` | High / Extreme chaos result |
| `level_up.wav` | Low chaos (green flag) result |
| `ding.wav` | Sharing a result |
| `alert.wav` | Extreme chaos alert |

---

## 💰 AD PLACEMENT STRATEGY

| Where | Ad Type | Aggressiveness |
|---|---|---|
| Home screen bottom | **Banner** | Always visible |
| After EVERY result | **Interstitial** | 100% — shows every single time |
| "Go Premium" button | **Rewarded** | User chooses |
| Result screen bottom | **Banner** | Always visible |

This setup maximizes revenue while keeping the experience entertaining enough that users return.

---

## 📦 PACKAGE CONTENTS

```
redflag_names/
├── 📁 lib/                    # All Flutter/Dart code
│   ├── main.dart              # Entry point
│   ├── app.dart               # Routes & theme
│   ├── models/                # Data models
│   ├── data/                  # Content pools (funny text)
│   ├── services/              # Ads, notifications, sound, share
│   ├── screens/               # All 5 screens
│   └── widgets/               # Chaos meter widget
├── 📁 android/                # Android project
│   └── app/src/main/res/      # Icons (all sizes)
├── 📁 ios/                    # iOS project  
├── 📁 assets/
│   ├── images/                # App icon (transparent)
│   └── sounds/                # 6 WAV sound effects
├── 📁 .github/workflows/      # GitHub Actions CI/CD
│   └── build.yml              # Auto-build APK + AAB
├── pubspec.yaml               # Dependencies
├── README.md                  # Full docs
└── SETUP_GUIDE.md             # This file
```

---

## 🚀 GOING VIRAL — TIPS

1. **TikTok first** — Record yourself testing names, react to results
2. **WhatsApp groups** — Share your result card in a group chat
3. **"Test your crush"** energy — People WILL share this
4. **Post in Nigerian Twitter/X** — "Test your ex's name 💀" hits every time
5. **Update content often** — Add trending names, new traits every week

---

## 📋 REPLACE BEFORE PUBLISHING

- [ ] AdMob App ID in `AndroidManifest.xml`
- [ ] AdMob App ID in `ios/Runner/Info.plist`  
- [ ] All 6 AdMob unit IDs in `lib/services/ad_service.dart`
- [ ] Your GitHub username in `README.md`
- [ ] Bundle ID if not using `com.chastech.redflag_names`
- [ ] Play Store listing assets (screenshots, description)

---

*Made with ❤️ by chAs Tech Group*
