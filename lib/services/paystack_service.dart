import 'package:shared_preferences/shared_preferences.dart';

/// Manages Paystack "Remove Ads Forever" purchase state.
/// The actual checkout UI lives in PaystackWebScreen — this service
/// only handles granting/restoring the purchase via SharedPreferences.
class PaystackService {
  static final PaystackService instance = PaystackService._();
  PaystackService._();

  static const String publicKey =
      'pk_live_d145dd30b0e40a54e3d2533dfc544e41ea63fe94';
  static const String _prefKey = 'paystack_remove_ads_purchased';

  // ₦1,500 in kobo (100 kobo = ₦1). Adjust to change pricing.
  static const int amountKobo = 150000;
  static const String currency = 'NGN';

  bool _purchased = false;
  bool get purchased => _purchased;

  /// Price shown to the user in the premium screen.
  String get priceString => '₦1,500';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _purchased = prefs.getBool(_prefKey) ?? false;
  }

  /// Called by PaystackWebScreen after a confirmed successful payment.
  Future<void> grant() async {
    _purchased = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  /// Re-checks local storage. Paystack mobile has no server-side restore —
  /// the purchase is tied to this device via SharedPreferences.
  Future<bool> restoreLocally() async {
    final prefs = await SharedPreferences.getInstance();
    _purchased = prefs.getBool(_prefKey) ?? false;
    return _purchased;
  }

  /// Builds the HTML page with Paystack's inline JS popup.
  /// Values are injected at runtime — no hardcoded user data.
  static String buildCheckoutHtml({
    required String email,
    required String reference,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #0D0D1A; height: 100vh; overflow: hidden; }
  </style>
</head>
<body>
  <script src="https://js.paystack.co/v1/inline.js"></script>
  <script>
    window.onload = function() {
      try {
        var handler = PaystackPop.setup({
          key: '$publicKey',
          email: '$email',
          amount: $amountKobo,
          currency: '$currency',
          ref: '$reference',
          label: 'RedFlag Names',
          metadata: {
            custom_fields: [
              {
                display_name: 'Product',
                variable_name: 'product',
                value: 'Remove Ads Forever'
              },
              {
                display_name: 'App',
                variable_name: 'app',
                value: 'RedFlag Names'
              }
            ]
          },
          onClose: function() {
            FlutterPaystack.postMessage(JSON.stringify({ status: 'cancelled' }));
          },
          callback: function(response) {
            FlutterPaystack.postMessage(JSON.stringify({
              status: 'success',
              reference: response.reference
            }));
          }
        });
        handler.openIframe();
      } catch(e) {
        FlutterPaystack.postMessage(JSON.stringify({
          status: 'error',
          message: e.message
        }));
      }
    };
  </script>
</body>
</html>
''';
  }
}
