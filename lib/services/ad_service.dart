import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdService — Aggressive but professional ad placement system
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  // ===== AD UNIT IDs =====
  // 🔴 REPLACE THESE WITH YOUR REAL ADMOB IDs BEFORE PUBLISHING
  static String get _interstitialId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST - Replace
    }
    return 'ca-app-pub-3940256099942544/4411468910'; // iOS TEST - Replace
  }

  static String get _rewardedId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // TEST - Replace
    }
    return 'ca-app-pub-3940256099942544/1712485313'; // iOS TEST - Replace
  }

  static String get _bannerId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST - Replace
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS TEST - Replace
  }

  // ===== STATE =====
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _analysisCount = 0;
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  // ===== INIT =====
  Future<void> initialize() async {
    await _loadInterstitial();
    await _loadRewarded();
  }

  // ===== BANNER =====
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
  }

  Widget buildBannerWidget() {
    if (_isPremium) return const SizedBox.shrink();

    final banner = createBannerAd()..load();
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: AdWidget(ad: banner),
    );
  }

  // ===== INTERSTITIAL =====
  Future<void> _loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _interstitialAd = null;
              _loadInterstitial(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Show interstitial — called after every analysis
  Future<void> showInterstitial(BuildContext context) async {
    if (_isPremium) return;
    _analysisCount++;

    // Show EVERY time for aggressive monetization
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  // ===== REWARDED =====
  Future<void> _loadRewarded() async {
    await RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _rewardedAd = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  /// Show rewarded ad — grants premium features temporarily
  Future<bool> showRewarded({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) async {
    if (_rewardedAd == null) {
      onFailed?.call();
      return false;
    }

    bool rewarded = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
        onRewarded();
      },
    );
    return rewarded;
  }

  void setPremium(bool value) => _isPremium = value;
}
