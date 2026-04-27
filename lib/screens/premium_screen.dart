import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ad_service.dart';

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
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _features = [
    {'icon': '🚫', 'title': 'Zero Ads', 'desc': 'No banners. No interruptions. Pure chaos.'},
    {'icon': '⚡', 'title': 'Instant Results', 'desc': 'No interstitials between analyses'},
    {'icon': '🎨', 'title': 'Premium Report Cards', 'desc': 'Beautiful shareable result images'},
    {'icon': '📊', 'title': 'Deeper Breakdowns', 'desc': 'Extended personality analysis'},
    {'icon': '💾', 'title': 'Unlimited History', 'desc': 'Never lose a result — ever'},
    {'icon': '🔒', 'title': 'Private Mode', 'desc': 'Analyses stay between you and the app'},
  ];

  @override
  Widget build(BuildContext context) {
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
              // ── Header ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── Crown ──
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gold glow
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700)
                                      .withOpacity(0.35),
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
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFB300)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Center(
                              child:
                                  Text('👑', style: TextStyle(fontSize: 52)),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // ── Title ──
                      Text(
                        'Go Ad-Free',
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 6),

                      Text(
                        'Analyze freely. No interruptions.\nJust chaos.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 28),

                      // ── Features list ──
                      ..._features.asMap().entries.map(
                            (e) => _FeatureRow(
                              feature: e.value,
                              delay: 350 + (e.key * 70),
                            ),
                          ),

                      const SizedBox(height: 28),

                      // ── Watch Ad button (PRIMARY - free) ──
                      _buildWatchAdButton(),

                      const SizedBox(height: 14),

                      // ── Paid button ──
                      _buildPaidButton(),

                      const SizedBox(height: 16),

                      // ── Fine print ──
                      Text(
                        'Watch-ad removes ads for this session only.\nFull lifetime premium coming soon!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white24,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 900.ms),

                      const SizedBox(height: 20),

                      // ── chAs branding ──
                      _buildChAsTag().animate().fadeIn(delay: 1100.ms),

                      const SizedBox(height: 20),
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

  Widget _buildWatchAdButton() {
    return GestureDetector(
      onTap: _watchingAd ? null : _watchAd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          gradient: _watchingAd
              ? const LinearGradient(
                  colors: [Color(0xFF444), Color(0xFF333)])
              : const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _watchingAd
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                    Text(
                      'Loading ad...',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
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
                      'Watch Video — Remove Ads FREE',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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

  Widget _buildPaidButton() {
    return GestureDetector(
      onTap: _showComingSoon,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.08),
              const Color(0xFFFFB300).withOpacity(0.04),
            ],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👑', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Premium — \$0.99 Lifetime',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    'Coming Soon',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildChAsTag() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'by ',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white30),
        ),
        Text(
          'ch',
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white54),
        ),
        Text(
          'As',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFB830),
          ),
        ),
        Text(
          ' Tech Group',
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white30),
        ),
      ],
    );
  }

  Future<void> _watchAd() async {
    setState(() => _watchingAd = true);
    await AdService.instance.showRewarded(
      onRewarded: () {
        AdService.instance.setPremium(true);
        if (mounted) Navigator.pop(context, true);
        Future.delayed(Duration.zero, () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Ads removed! Enjoy the chaos ad-free!'),
                backgroundColor: const Color(0xFF00C853),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        });
      },
      onFailed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('😅 Ad not ready yet — try in a few seconds!'),
              backgroundColor: const Color(0xFFFF6B00),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
    );
    if (mounted) setState(() => _watchingAd = false);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            '💳 Paid premium dropping soon! Watch the ad for now 😄'),
        backgroundColor: const Color(0xFFFF6B9D),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
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
