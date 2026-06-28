import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles "Remove Ads Forever" payment via Paystack.
/// Used as the billing path for non-Google-Play installs (e.g. Palm Store).
class PaystackService {
  static final PaystackService instance = PaystackService._();
  PaystackService._();

  static const String _publicKey =
      'pk_live_d145dd30b0e40a54e3d2533dfc544e41ea63fe94';
  static const String _prefKey = 'paystack_remove_ads_purchased';

  // Price in kobo (100 kobo = ₦1). Currently ₦1,500.
  // Change this value to adjust pricing for your market.
  static const int _amountKobo = 150000;
  static const String _currency = 'NGN';

  final PaystackPlugin _plugin = PaystackPlugin();
  bool _initialized = false;
  bool _purchased = false;
  bool _loading = false;

  bool get purchased => _purchased;
  bool get loading => _loading;

  /// Price shown to the user in the premium screen.
  String get priceString => '₦1,500';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _purchased = prefs.getBool(_prefKey) ?? false;
    if (!_initialized) {
      await _plugin.initialize(publicKey: _publicKey);
      _initialized = true;
    }
  }

  /// Launches Paystack card checkout sheet.
  /// Requires [userEmail] — Paystack uses it for receipts and fraud detection.
  Future<bool> purchase({
    required BuildContext context,
    required String userEmail,
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    if (_loading) return false;
    _loading = true;

    final ref = 'RFN_${DateTime.now().millisecondsSinceEpoch}';

    final charge = Charge()
      ..amount = _amountKobo
      ..email = userEmail
      ..currency = _currency
      ..reference = ref
      ..putCustomField('Product', 'Remove Ads Forever')
      ..putCustomField('App', 'RedFlag Names');

    try {
      final response = await _plugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );

      _loading = false;

      if (response.status == true && response.message == 'Success') {
        await _grant();
        onSuccess();
        return true;
      } else {
        onError(response.message ?? 'Payment was not completed.');
        return false;
      }
    } catch (_) {
      _loading = false;
      onError('Payment failed. Please try again.');
      return false;
    }
  }

  /// Checks local storage — Paystack has no server-side restore,
  /// so we rely on the SharedPreferences flag set at purchase time.
  Future<bool> restoreLocally() async {
    final prefs = await SharedPreferences.getInstance();
    _purchased = prefs.getBool(_prefKey) ?? false;
    return _purchased;
  }

  Future<void> _grant() async {
    _purchased = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
}
