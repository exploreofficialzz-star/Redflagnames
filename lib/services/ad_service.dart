import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'iap_service.dart';

/// AdService — production ad management.
///
/// Ad-free hierarchy (highest priority wins):
///   1. IAP "Remove Ads Forever" purchased  → permanent
///   2. Rewarded ad watched                 → ad-free for 24 full hours
///   3. Otherwise                           → all ad formats shown
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  // ─── Real Production Ad Unit IDs ─────────────────────────────────────────────
  // App ID (AndroidManifest.xml): ca-app-pub-2492078126313994~6674148778

  static String get _bannerId => Platform.isAndroid
      ? 'ca-app-pub-2492078126313994/7375416963'
      : 'ca-app-pub-2492078126313994/7375416963'; // add iOS ID when ready

  static String get _interstitialId => Platform.isAndroid
      ? 'ca-app-pub-2492078126313994/3693973666'
      : 'ca-app-pub-2492078126313994/3693973666'; // add iOS ID when ready

  static String get _rewardedId => Platform.isAndroid
      ? 'ca-app-pub-2492078126313994/2380891994'
      : 'ca-app-pub-2492078126313994/2380891994'; // add iOS ID when ready

  static String get _nativeId => Platform.isAndroid
      ? 'ca-app-pub-2492078126313994/5052505953'
      : 'ca-app-pub-2492078126313994/5052505953'; // add iOS ID when ready

  // ─── Prefs key ───────────────────────────────────────────────────────────────
  static const _kRewardedExpiry = 'rewarded_ad_expiry_ms';

  // ─── State ───────────────────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  RewardedAd?     _rewardedAd;
  bool _loadingInterstitial = false;
  bool _loadingRewarded     = false;
  int  _rewardedExpiryMs    = 0;

  // ─── Ad-free status ───────────────────────────────────────────────────────────

  /// True when the user should NOT see any ads.
  bool get isAdFree =>
      IapService.instance.purchased || _isRewardedActive;

  /// Backward-compat alias used by home_screen, result_screen, history_screen.
  bool get isPremium => isAdFree;

  bool get _isRewardedActive =>
      DateTime.now().millisecondsSinceEpoch < _rewardedExpiryMs;

  /// How much rewarded time remains (null if not active).
  Duration? get rewardedTimeRemaining {
    if (!_isRewardedActive) return null;
    return Duration(
      milliseconds: _rewardedExpiryMs - DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ─── Backward-compat setter (called by result_screen after rewarded ad) ──────
  /// Maps the old `setPremium(true)` call to the new 24-hour rewarded grant.
  void setPremium(bool value) {
    if (value) _grantRewardedAccess();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _rewardedExpiryMs = prefs.getInt(_kRewardedExpiry) ?? 0;

    if (!isAdFree) {
      _loadInterstitial();
      _loadRewarded();
    }
  }

  // ─── BANNER ──────────────────────────────────────────────────────────────────

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

  /// Sticky footer banner widget — returns empty box when ad-free.
  Widget buildBannerWidget({AdSize size = AdSize.banner}) {
    if (isAdFree) return const SizedBox.shrink();
    final banner = createBannerAd(size: size)..load();
    return Container(
      height: size.height.toDouble() + 4,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: AdWidget(ad: banner),
    );
  }

  /// Inline medium-rectangle banner — returns empty box when ad-free.
  Widget buildInlineBanner() {
    if (isAdFree) return const SizedBox.shrink();
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
          SizedBox(height: 250, child: AdWidget(ad: banner)),
        ],
      ),
    );
  }

  // ─── INTERSTITIAL ────────────────────────────────────────────────────────────

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
                _loadInterstitial();
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
            Future.delayed(const Duration(seconds: 30), _loadInterstitial);
          },
        ),
      );
    } catch (_) {
      _loadingInterstitial = false;
    }
  }

  Future<void> showInterstitial(BuildContext context) async {
    if (isAdFree) return;
    try {
      if (_interstitialAd != null) await _interstitialAd!.show();
    } catch (_) {}
    _loadInterstitial();
  }

  // ─── REWARDED ────────────────────────────────────────────────────────────────

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

  bool get rewardedReady => _rewardedAd != null;

  /// Shows the rewarded ad. On success, grants 24 hours of ad-free access.
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
        onUserEarnedReward: (_, __) async {
          rewarded = true;
          await _grantRewardedAccess();
          onRewarded();
        },
      );
    } catch (_) {
      onFailed?.call();
    }
    return rewarded;
  }

  /// Stores a 24-hour expiry timestamp in SharedPreferences.
  Future<void> _grantRewardedAccess() async {
    _rewardedExpiryMs = DateTime.now()
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRewardedExpiry, _rewardedExpiryMs);
  }

  // ─── Upsell widget ────────────────────────────────────────────────────────────

  Widget buildRemoveAdsPrompt(BuildContext context) {
    if (isAdFree) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/premium'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.15),
              const Color(0xFFFFB300).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Go Ad-Free — \$2.99 Forever',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    'Or watch a video for 24 hrs free',
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFFFFD700), size: 16),
          ],
        ),
      ),
    );
  }
}
