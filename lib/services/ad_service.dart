import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdService — Maximum aggressive monetization
/// Interstitial: every single result
/// Banner: every screen
/// Rewarded: premium gate + retry gate
/// Native: injected between traits in result screen
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  // ─────────────────────────────────────────────
  // 🔴 REPLACE ALL WITH YOUR REAL ADMOB IDs
  // ─────────────────────────────────────────────
  static String get _bannerId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get _interstitialId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static String get _rewardedId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  RewardedAd?     _rewardedAd;
  bool _isPremium  = false;
  bool _loadingInterstitial = false;
  bool _loadingRewarded     = false;

  bool get isPremium => _isPremium;

  // ─────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────
  Future<void> initialize() async {
    await _loadInterstitial();
    await _loadRewarded();
  }

  // ─────────────────────────────────────────────
  // BANNER — create fresh per screen
  // ─────────────────────────────────────────────
  BannerAd createBannerAd({AdSize size = AdSize.banner}) {
    return BannerAd(
      adUnitId: _bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
  }

  /// Persistent bottom banner widget for any screen
  Widget buildBannerWidget({AdSize size = AdSize.banner}) {
    if (_isPremium) return const SizedBox.shrink();
    final banner = createBannerAd(size: size)..load();
    return Container(
      height: size.height.toDouble() + 4,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: AdWidget(ad: banner),
    );
  }

  /// Inline banner card — inject between content
  Widget buildInlineBanner() {
    if (_isPremium) return const SizedBox.shrink();
    final banner = createBannerAd(size: AdSize.mediumRectangle)..load();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'SPONSORED',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INTERSTITIAL — show every single result
  // ─────────────────────────────────────────────
  Future<void> _loadInterstitial() async {
    if (_loadingInterstitial || _interstitialAd != null) return;
    _loadingInterstitial = true;
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _loadingInterstitial = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (_) {
                _interstitialAd = null;
                _loadInterstitial(); // preload next immediately
              },
              onAdFailedToShowFullScreenContent: (ad, _) {
                ad.dispose();
                _interstitialAd = null;
                _loadingInterstitial = false;
                _loadInterstitial();
              },
            );
          },
          onAdFailedToLoad: (_) {
            _loadingInterstitial = false;
            // Retry after delay
            Future.delayed(const Duration(seconds: 30), _loadInterstitial);
          },
        ),
      );
    } catch (_) {
      _loadingInterstitial = false;
    }
  }

  /// Show interstitial — call after EVERY result, EVERY history view
  Future<void> showInterstitial(BuildContext context) async {
    if (_isPremium) return;
    try {
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
      }
    } catch (_) {}
    // Always preload next
    _loadInterstitial();
  }

  // ─────────────────────────────────────────────
  // REWARDED — premium gate + retry gate
  // ─────────────────────────────────────────────
  Future<void> _loadRewarded() async {
    if (_loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    try {
      await RewardedAd.load(
        adUnitId: _rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _loadingRewarded = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (_) {
                _rewardedAd = null;
                _loadRewarded();
              },
              onAdFailedToShowFullScreenContent: (ad, _) {
                ad.dispose();
                _rewardedAd = null;
                _loadingRewarded = false;
                _loadRewarded();
              },
            );
          },
          onAdFailedToLoad: (_) {
            _loadingRewarded = false;
            Future.delayed(const Duration(seconds: 30), _loadRewarded);
          },
        ),
      );
    } catch (_) {
      _loadingRewarded = false;
    }
  }

  Future<bool> showRewarded({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) async {
    if (_rewardedAd == null) {
      onFailed?.call();
      _loadRewarded();
      return false;
    }
    bool rewarded = false;
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, __) {
          rewarded = true;
          onRewarded();
        },
      );
    } catch (_) {
      onFailed?.call();
    }
    return rewarded;
  }

  bool get rewardedReady => _rewardedAd != null;

  void setPremium(bool value) {
    _isPremium = value;
    if (!value) {
      // Re-enable ads — reload
      _loadInterstitial();
      _loadRewarded();
    }
  }

  // ─────────────────────────────────────────────
  // Aggressive prompt widget — shows on result screen
  // ─────────────────────────────────────────────
  Widget buildRemoveAdsPrompt(BuildContext context) {
    if (_isPremium) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/premium'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.15),
              const Color(0xFFFFB300).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remove All Ads — Watch a Video',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    'Enjoy ad-free chaos for this session',
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_rounded,
                color: Color(0xFFFFD700), size: 28),
          ],
        ),
      ),
    );
  }
}
