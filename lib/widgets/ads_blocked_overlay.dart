import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen overlay shown when internet is available but ad-serving
/// domains are blocked (DNS or hosts-file ad-blocker detected).
///
/// Explains that ad revenue keeps the app free and guides the user to
/// disable the blocker, then tap "I've Disabled It" to retry.
class AdsBlockedOverlay extends StatefulWidget {
  final VoidCallback onRetry;

  const AdsBlockedOverlay({super.key, required this.onRetry});

  @override
  State<AdsBlockedOverlay> createState() => _AdsBlockedOverlayState();
}

class _AdsBlockedOverlayState extends State<AdsBlockedOverlay> {
  bool _retrying = false;

  Future<void> _handleRetry() async {
    setState(() => _retrying = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onRetry();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF100A0D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Icon ─────────────────────────────────────────────────────
                _buildIcon(),
                const SizedBox(height: 32),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  'Ads Are Blocked',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 14),

                // ── Subtitle ─────────────────────────────────────────────────
                Text(
                  'RedFlag Names is completely free.\nAds are how we keep the drama alive.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),

                // ── Why card ─────────────────────────────────────────────────
                _buildWhyCard(),
                const SizedBox(height: 20),

                // ── Steps card ───────────────────────────────────────────────
                _buildStepsCard(),
                const SizedBox(height: 32),

                // ── CTA button ───────────────────────────────────────────────
                _buildRetryButton(),

                const SizedBox(height: 16),

                Text(
                  'We detect ad servers are unreachable on your device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1A2E),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.12),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.block_rounded,
            size: 48,
            color: Color(0xFFFFD700),
          ),
        ),
        // Small "ad" badge at the corner
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B5C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AD',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.04,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildWhyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.10),
            const Color(0xFFFFB300).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💛', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Ad revenue pays for our servers, content, and the team that keeps adding chaotic name energy. Without it, the app can\'t stay free.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white70,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildStepsCard() {
    final steps = [
      ('1', Icons.shield_rounded, 'Open your ad-blocker or DNS-filter app (e.g. AdGuard, Blokada, 1.1.1.1 for Families)'),
      ('2', Icons.toggle_on_rounded, 'Pause or disable it temporarily'),
      ('3', Icons.replay_rounded, 'Tap "I\'ve Disabled It" below to continue'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO FIX THIS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B5C).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF3B5C).withOpacity(0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.$1,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF3B5C),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          s.$3,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _retrying ? null : _handleRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          disabledBackgroundColor: const Color(0xFFFFD700).withOpacity(0.4),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFFFD700).withOpacity(0.35),
        ),
        child: _retrying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "I've Disabled It",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }
}
