# 🚩 RedFlag Names

> **Funny Relationship Name Analyzer** — Turn any name into a hilarious relationship personality report. Built for virality.

[![Build Status](https://github.com/YOUR_USERNAME/redflag_names/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/redflag_names/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)](https://flutter.dev)
[![Made by chAs Tech Group](https://img.shields.io/badge/Made%20by-chAs%20Tech%20Group-FF3B5C)](https://github.com/YOUR_USERNAME)

---

## 📱 What It Does

Users enter any name → Get a hilarious "relationship personality prediction" combining:
- 🎭 Intro hook
- 🚩 Personality traits (funny, not offensive)
- 🌀 Plot twist
- 📊 Chaos Meter (0–100%)
- 💀 Risk Level: Low / Medium / High / EXTREME

**Results are purely for entertainment and satire.**

---

## ✨ Features

| Feature | Details |
|---|---|
| 🎯 Name Analysis | Randomized modular content engine → thousands of combos |
| 👤 Context Mode | General / Boyfriend / Girlfriend / Crush / Ex |
| 📊 Chaos Meter | Animated 0–100% chaos score with color coding |
| 🔊 Sound FX | 6 custom sounds (laugh, reveal, alert, ding, woosh, level-up) |
| 🔔 Notifications | Daily engagement notifications with default device sounds |
| 📤 Share | WhatsApp, Instagram, TikTok, Copy — aggressive sharing |
| 📋 History | Last 50 analyses stored locally |
| 💰 Ads | AdMob Banner + Interstitial (after every result) + Rewarded |
| 🎁 Remove Ads | Watch rewarded ad for ad-free session |

---

## 🚀 Setup & Build

### Prerequisites
- Flutter SDK 3.24+
- Java 17
- Android Studio / Xcode

### 1. Clone & Install
```bash
git clone https://github.com/YOUR_USERNAME/redflag_names.git
cd redflag_names
flutter pub get
```

### 2. Configure AdMob
Replace the test IDs in these files:

**`lib/services/ad_service.dart`**
```dart
// Android
'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'  // Interstitial
'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'  // Rewarded
'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'  // Banner

// iOS
'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
```

**`android/app/src/main/AndroidManifest.xml`**
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**`ios/Runner/Info.plist`**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### 3. Build Locally

```bash
# Debug APK (fast)
flutter build apk --debug

# Release APK
flutter build apk --release

# Play Store AAB
flutter build appbundle --release
```

---

## 🤖 GitHub Actions CI/CD

### Auto Build on Push
Every push to `main` or `develop` builds:
- ✅ Debug APK
- ✅ Release APK
- ✅ Release AAB

Artifacts are downloadable from the **Actions** tab.

### Create a Release
```bash
git tag v1.0.0
git push origin v1.0.0
```
→ GitHub automatically creates a Release with APK + AAB attached.

---

## 🏗️ Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # Routes & theme
├── models/
│   └── analysis_result.dart   # Data model
├── data/
│   └── content_pools.dart     # All funny content (intros, traits, twists...)
├── services/
│   ├── name_analyzer_service.dart  # Core analysis engine
│   ├── ad_service.dart             # AdMob (banner, interstitial, rewarded)
│   ├── notification_service.dart   # Push notifications
│   ├── sound_service.dart          # Audio playback
│   └── share_service.dart          # Share to social media
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── result_screen.dart
│   └── history_screen.dart
└── widgets/
    └── chaos_meter_widget.dart
```

---

## 💰 Monetization Strategy

| Placement | Type | Trigger |
|---|---|---|
| Home screen bottom | Banner | Always visible |
| After every result | Interstitial | 100% show rate |
| "Go Premium" button | Rewarded | User-initiated |

**Target: $0.30–$1.50 eCPM** with high engagement loops from social sharing.

---

## 🎯 Viral Strategy

The app is engineered for sharing:
1. User analyzes their name → laughs
2. Shares result to WhatsApp/TikTok/Instagram
3. Friends click → download app → analyze their names
4. Loop repeats

**Key viral triggers:**
- Relatable humor that hits differently
- "Try your crush's name" CTA
- "Try your ex's name" CTA (everyone has one 💀)

---

## 🔧 Customization

### Adding More Content
Edit `lib/data/content_pools.dart`:

```dart
// Add new traits
static const List<String> generalTraits = [
  "Your new funny trait here 😂",
  // ...
];

// Add special name responses
static const Map<String, List<String>> specialNames = {
  'newname': [
    "Specific trait for this name 🚩",
  ],
};
```

### Changing Colors
Edit `lib/app.dart` → `_buildTheme()`:
```dart
primary: Color(0xFFFF3B5C),    // Red (main)
secondary: Color(0xFFFFD700),  // Gold
```

---

## 📋 TODO / Roadmap

- [ ] Add 200+ more traits to content pools
- [ ] Name-based AI integration (optional upgrade)
- [ ] Shareable image card generation
- [ ] Premium tier ($0.99 one-time)
- [ ] Leaderboard — most analyzed names
- [ ] Play Store / App Store publishing
- [ ] Paystack/LemonSqueezy for premium

---

## 🏷️ Built With

- **Flutter** 3.24 — Cross-platform UI
- **google_mobile_ads** — AdMob monetization
- **flutter_local_notifications** — Push notifications
- **audioplayers** — Sound effects
- **share_plus** — Social sharing
- **screenshot** — Capture results as images
- **flutter_animate** — Smooth animations
- **google_fonts** — Beautiful typography
- **shared_preferences** — Local history storage

---

## ❤️ Made by chAs Tech Group

> *Turn simple ideas into viral apps.*

---

*⚠️ This app is 100% for entertainment. Results are randomly generated satire. No names were harmed in the making of this app.*
