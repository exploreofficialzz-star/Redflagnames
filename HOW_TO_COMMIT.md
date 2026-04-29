# 🚩 RedFlag Names — Final Update Package
> Made by chAs Tech Group

## Copy each folder into your repo root and push

```
your-repo/
├── .github/workflows/
│   ├── android.yml       ← replace existing
│   └── ios.yml           ← replace existing
└── lib/
    ├── data/
    │   └── content_pools.dart        ← replace
    ├── screens/
    │   ├── splash_screen.dart        ← replace
    │   ├── home_screen.dart          ← replace
    │   ├── result_screen.dart        ← replace
    │   ├── history_screen.dart       ← replace
    │   └── premium_screen.dart       ← replace
    ├── services/
    │   ├── ad_service.dart           ← replace
    │   ├── name_analyzer_service.dart← replace
    │   ├── notification_service.dart ← replace
    │   ├── share_service.dart        ← replace
    │   └── sound_service.dart        ← replace
    └── widgets/
        └── chaos_meter_widget.dart   ← replace
```

## Suggested commit message
```
feat: Nigerian relationship vibes, ads before result, womanizer/nyash/d*ck content, bug fixes
```

## What changed this round

| File | Change |
|---|---|
| `content_pools.dart` | 50+ special names (Nigerian), womanizer, big/small d*ck, nyash, gold digger, sugar boy/man, pride/no-dey-gree, virgin claims, all vibes |
| `home_screen.dart` | 🔥 Interstitial ad fires BEFORE result is shown |
| `result_screen.dart` | Inline banner between chaos meter and twist + remove-ads prompt |
| `splash_screen.dart` | Fixed deprecated `window` → `MediaQuery.of(context).size` |
| `chaos_meter_widget.dart` | Removed unused import (build warning fixed) |
| `android.yml` | Test step now skips gracefully if no test/ folder |

*Made with ❤️ by chAs Tech Group*
