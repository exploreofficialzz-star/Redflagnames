import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the "Remove Ads Forever" one-time in-app purchase.
///
/// Product IDs to create in stores:
///   Google Play Console  → In-app product → ID: remove_ads_forever  → $2.99
///   App Store Connect    → In-App Purchase → Non-Consumable → ID: remove_ads_forever → $2.99
class IapService {
  static final IapService instance = IapService._();
  IapService._();

  // ─── Constants ────────────────────────────────────────────────────────────────
  static const String productId     = 'remove_ads_forever';
  static const String _prefKey      = 'iap_remove_ads_purchased';

  // ─── State ───────────────────────────────────────────────────────────────────
  bool _available   = false;
  bool _purchased   = false;
  bool _loading     = false;

  ProductDetails? _product;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get available  => _available;
  bool get purchased  => _purchased;
  bool get loading    => _loading;

  /// Formatted price string from the store (e.g. "$2.99").
  /// Falls back to "$2.99" if product hasn't loaded yet.
  String get priceString => _product?.price ?? '\$2.99';

  // ─── Callbacks (set by UI) ───────────────────────────────────────────────────
  VoidCallback?       onPurchaseSuccess;
  VoidCallback?       onPurchasePending;
  ValueChanged<String>? onPurchaseError;
  VoidCallback?       onStateChanged; // Generic UI refresh

  // ─── Initialise ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Fast local restore — avoid any async gap before showing UI
    final prefs = await SharedPreferences.getInstance();
    _purchased = prefs.getBool(_prefKey) ?? false;

    // 2. Is the billing client available on this device?
    _available = await InAppPurchase.instance.isAvailable();
    if (!_available) return;

    // 3. Subscribe to the purchase stream before doing anything else
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _sub?.cancel(),
      onError: (_) {},
    );

    // 4. Load product metadata from the store
    await _loadProduct();

    // 5. Restore any prior purchases (handles reinstalls, new devices)
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> _loadProduct() async {
    try {
      final response = await InAppPurchase.instance
          .queryProductDetails({productId});
      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
        onStateChanged?.call();
      }
    } catch (_) {}
  }

  // ─── Purchase ─────────────────────────────────────────────────────────────────

  Future<void> buy() async {
    if (!_available) {
      onPurchaseError?.call(
          'In-app purchases are not available on this device.');
      return;
    }
    if (_product == null) {
      onPurchaseError?.call(
          'Could not load product. Check your connection and try again.');
      return;
    }
    if (_loading) return;

    setState(() => _loading = true);
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: _product!),
      );
    } catch (e) {
      setState(() => _loading = false);
      onPurchaseError?.call('Purchase could not be started. Please try again.');
    }
  }

  Future<void> restore() async {
    if (!_available) return;
    setState(() => _loading = true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      setState(() => _loading = false);
      onPurchaseError?.call('Restore failed. Please try again.');
    }
  }

  // ─── Purchase stream handler ──────────────────────────────────────────────────

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          onPurchasePending?.call();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grant(purchase);
          break;

        case PurchaseStatus.error:
          setState(() => _loading = false);
          final msg = purchase.error?.message ?? 'Purchase failed.';
          onPurchaseError?.call(msg);
          break;

        case PurchaseStatus.canceled:
          setState(() => _loading = false);
          break;
      }
    }
  }

  Future<void> _grant(PurchaseDetails purchase) async {
    // Acknowledge the purchase with the store first
    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }

    // Persist locally so we never show ads again even offline
    _purchased = true;
    _loading   = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);

    onPurchaseSuccess?.call();
    onStateChanged?.call();
  }

  void setState(VoidCallback fn) {
    fn();
    onStateChanged?.call();
  }

  void dispose() => _sub?.cancel();
}
