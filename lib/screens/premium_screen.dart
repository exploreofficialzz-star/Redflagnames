import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ad_service.dart';
import '../services/iap_service.dart';
import '../services/paystack_service.dart';
import '../services/store_detector_service.dart';
import 'paystack_web_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  bool _watchingAd = false;
  bool _paystackLoading = false;
  bool _isGooglePlay = false; // resolved in initState
  bool _storeResolved = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Wire IAP callbacks so we can update UI reactively
    IapService.instance.onStateChanged    = _refresh;
    IapService.instance.onPurchaseSuccess = _onPurchaseSuccess;
    IapService.instance.onPurchasePending = _onPurchasePending;
    IapService.instance.onPurchaseError   = _onPurchaseError;

    // Detect which store the app came from
    _resolveStore();
  }

  Future<void> _resolveStore() async {
    final fromGoogle = await StoreDetectorService.isGooglePlay();
    if (mounted) {
      setState(() {
        _isGooglePlay = fromGoogle;
        _storeResolved = true;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    IapService.instance.onStateChanged    = null;
    IapService.instance.onPurchaseSuccess = null;
    IapService.instance.onPurchasePending = null;
    IapService.instance.onPurchaseError   = null;
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  // ─── IAP handlers (Google Play) ──────────────────────────────────────────────

  void _onPurchaseSuccess() {
    if (!mounted) return;
    Navigator.pop(context, true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(
        '🎉 Ads removed forever! Enjoy the chaos!',
        const Color(0xFF00C853),
      ));
    });
  }

  void _onPurchasePending() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snack(
      '⏳ Purchase pending… we\'ll unlock when it clears.',
      const Color(0xFF2196F3),
    ));
  }

  void _onPurchaseError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snack(
      '❌ $msg',
      const Color(0xFFFF3B5C),
    ));
  }

  SnackBar _snack(String text, Color color) => SnackBar(
        content: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // ─── Features list ────────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _features = [
    {'icon': '🚫', 'title': 'Zero Ads — Forever', 'desc': 'No banners, no interstitials. Ever again.'},
    {'icon': '⚡', 'title': 'Instant Results', 'desc': 'No delays between analyses'},
    {'icon': '🎨', 'title': 'Premium Report Cards', 'desc': 'Beautiful shareable result images'},
    {'icon': '📊', 'title': 'Deeper Breakdowns', 'desc': 'Extended personality analysis'},
    {'icon': '💾', 'title': 'Unlimited History', 'desc': 'Never lose a result — ever'},
    {'icon': '🔒', 'title': 'Private Mode', 'desc': 'Your analyses stay between you and the app'},
  ];

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final iap = IapService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1200), Color(0xFF0D0D1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildCrown(),
                      const SizedBox(height: 24),
                      _buildTitle(),
                      const SizedBox(height: 28),
                      ..._features.asMap().entries.map((e) => _FeatureRow(
                            feature: e.value,
                            delay: 350 + (e.key * 70),
                          )),
                      const SizedBox(height: 28),

                      // ── PRIMARY BUY BUTTON ────────────────────────────────
                      // Show Google Play IAP or Paystack based on install source
                      if (!_storeResolved)
                        _buildLoadingPlaceholder()
                      else if (_isGooglePlay)
                        _buildBuyButton(iap)
                      else
                        _buildPaystackButton(),

                      const SizedBox(height: 12),

                      // ── WATCH AD FOR 24H (always available) ───────────────
                      _buildWatchAdButton(),
                      const SizedBox(height: 12),

                      // ── RESTORE ───────────────────────────────────────────
                      if (_storeResolved && _isGooglePlay && iap.available)
                        _buildRestoreButton(iap)
                      else if (_storeResolved && !_isGooglePlay)
                        _buildPaystackRestoreButton(),

                      const SizedBox(height: 20),
                      _buildFinePrint(iap),
                      const SizedBox(height: 16),
                      _buildChAsTag(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Loading placeholder while store is detected ──────────────────────────────

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              color: Color(0xFFFFD700), strokeWidth: 2.5),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Crown hero ───────────────────────────────────────────────────────────────

  Widget _buildCrown() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.35),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(child: Text('👑', style: TextStyle(fontSize: 52))),
        ),
      ],
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  // ─── Title block ──────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Remove Ads Forever',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 6),
        Text(
          'One-time purchase. No subscription.\nJust chaos, ad-free for life.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white60,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  // ─── Google Play IAP button ───────────────────────────────────────────────────

  Widget _buildBuyButton(IapService iap) {
    final isLoading = iap.loading;
    final price = iap.priceString;

    return GestureDetector(
      onTap: isLoading ? null : () => iap.buy(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(colors: [Color(0xFF444), Color(0xFF333)])
              : const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Text('Processing…',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remove Ads Forever — $price',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'One-time · No subscription',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: 700.ms,
        );
  }

  // ─── Paystack button (Palm Store / non-Play installs) ─────────────────────────

  Widget _buildPaystackButton() {
    final isLoading = _paystackLoading;
    final price = PaystackService.instance.priceString;

    return GestureDetector(
      onTap: isLoading ? null : _initiatePaystack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(colors: [Color(0xFF444), Color(0xFF333)])
              : const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Text('Processing…',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remove Ads Forever — $price',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Pay securely with Paystack · Card',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: 700.ms,
        );
  }

  /// Shows email dialog then navigates to Paystack WebView checkout.
  Future<void> _initiatePaystack() async {
    final email = await _showEmailDialog();
    if (email == null || email.isEmpty) return;

    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaystackWebScreen(userEmail: email),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(_snack(
          '🎉 Ads removed forever! Enjoy the chaos!',
          const Color(0xFF00C853),
        ));
      });
    } else {
      setState(() => _paystackLoading = false);
    }
  }

  /// Simple dialog to collect the user's email before Paystack checkout.
  Future<String?> _showEmailDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '📧 Enter your email',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paystack needs your email to send a receipt and protect your purchase.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0D0D1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFFFD700), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Continue',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Watch ad (24h) button ────────────────────────────────────────────────────

  Widget _buildWatchAdButton() {
    final remaining = AdService.instance.rewardedTimeRemaining;
    final isActive  = remaining != null;

    return GestureDetector(
      onTap: (_watchingAd || isActive) ? null : _watchAd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        decoration: BoxDecoration(
          gradient: (isActive || _watchingAd)
              ? const LinearGradient(colors: [Color(0xFF2A2A3D), Color(0xFF1E1E30)])
              : const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: (isActive || _watchingAd)
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _watchingAd
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text('Loading ad…',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                )
              : isActive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF00E676), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Ad-Free for ${_formatRemaining(remaining!)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Watch Video — Ad-Free for 24 Hours',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  String _formatRemaining(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ─── Restore buttons ──────────────────────────────────────────────────────────

  Widget _buildRestoreButton(IapService iap) {
    return TextButton(
      onPressed: iap.loading ? null : () => iap.restore(),
      child: Text(
        'Restore Purchase',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white38,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white24,
        ),
      ),
    ).animate().fadeIn(delay: 850.ms);
  }

  /// Paystack has no server restore — we just re-check local storage.
  Widget _buildPaystackRestoreButton() {
    return TextButton(
      onPressed: () async {
        final restored = await PaystackService.instance.restoreLocally();
        if (!mounted) return;
        if (restored) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(_snack(
            'No previous purchase found on this device.',
            const Color(0xFFFF6B00),
          ));
        }
      },
      child: Text(
        'Already Purchased? Restore',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white38,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white24,
        ),
      ),
    ).animate().fadeIn(delay: 850.ms);
  }

  // ─── Fine print ───────────────────────────────────────────────────────────────

  Widget _buildFinePrint(IapService iap) {
    final text = _isGooglePlay
        ? '${iap.priceString} one-time purchase. No recurring charges.\n'
            'Applies to this Google/Apple account. Restore anytime.'
        : '₦1,500 one-time payment via Paystack.\n'
            'No recurring charges. Purchase is tied to this device.';

    return Text(
      _storeResolved
          ? text
          : 'Watch the video for 24 hrs ad-free.\nPurchase requires an active store account.',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: Colors.white24,
        height: 1.6,
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  // ─── chAs branding ────────────────────────────────────────────────────────────

  Widget _buildChAsTag() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Made with ❤️ by ',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white30)),
        Text('ch',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white54)),
        Text('As',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFB830))),
        Text(' Technologies LLC',
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white30)),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }

  // ─── Watch ad flow ────────────────────────────────────────────────────────────

  Future<void> _watchAd() async {
    setState(() => _watchingAd = true);
    await AdService.instance.showRewarded(
      onRewarded: () {
        if (mounted) {
          setState(() => _watchingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(_snack(
            '🎉 Ads gone for 24 hours! Enjoy the chaos!',
            const Color(0xFF00C853),
          ));
        }
      },
      onFailed: () {
        if (mounted) {
          setState(() => _watchingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(_snack(
            '😅 Ad not ready yet — try again in a few seconds.',
            const Color(0xFFFF6B00),
          ));
        }
      },
    );
    if (mounted) setState(() => _watchingAd = false);
  }
}

// ─── Feature row widget ───────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final Map<String, dynamic> feature;
  final int delay;
  const _FeatureRow({required this.feature, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text(feature['icon'] as String,
              style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  feature['desc'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF00C853), size: 22),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.08, end: 0);
  }
}
