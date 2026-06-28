import 'package:flutter/services.dart';

/// Detects whether the app was installed via Google Play Store.
/// Used to route payment: Google Play IAP vs Paystack fallback.
class StoreDetectorService {
  static const _channel = MethodChannel('com.chastech.redflag_names/store');

  static bool? _cachedResult;

  /// Returns true if installed from Google Play (com.android.vending).
  /// Returns false for Palm Store, sideload, or any other source.
  /// Result is cached — only one native call per session.
  static Future<bool> isGooglePlay() async {
    _cachedResult ??= await _detect();
    return _cachedResult!;
  }

  static Future<bool> _detect() async {
    try {
      final installer =
          await _channel.invokeMethod<String>('getInstallerSource');
      return installer == 'com.android.vending';
    } catch (_) {
      // Default to Paystack path if detection fails
      return false;
    }
  }
}
