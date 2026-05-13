import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ad_service.dart';
import '../services/iap_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  bool _watchingAd = false;
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
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    // Detach callbacks so a disposed widget isn't called
    IapService.instance.onStateChanged    = null;
    IapService.instance.onPurchaseSuccess = null;
    IapService.instance.onPurchasePending = null;
    IapService.instance.onPurchaseError   = null;
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  // ─── IAP handlers ────────────────────────────────────────────────────────────

  void _onPurchaseSuccess() {
    if (!mounted) return;
    Navigator.pop(context, true);
    // Small delay so the parent screen has mounted before showing snack
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

                      // ── PRIMARY: Buy forever ──────────────────────────────
                      _buildBuyButton(iap),
                      const SizedBox(height: 12),

                      // ── SECONDARY: Watch ad for 24h ───────────────────────
                      _buildWatchAdButton(),
                      const SizedBox(height: 12),

                      // ── Restore ───────────────────────────────────────────
                      if (iap.available) _buildRestoreButton(iap),
                      const SizedBox(height: 20),

                      // ── Fine print ────────────────────────────────────────
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

  // ─── Buy forever button ───────────────────────────────────────────────────────

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
                    Text(
                      'Processing…',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
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

  // ─── Restore button ───────────────────────────────────────────────────────────

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

  // ─── Fine print ───────────────────────────────────────────────────────────────

  Widget _buildFinePrint(IapService iap) {
    return Text(
      iap.available
          ? '${iap.priceString} one-time purchase. No recurring charges.\n'
              'Applies to this Google/Apple account. Restore anytime.'
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
