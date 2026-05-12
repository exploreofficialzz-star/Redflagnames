import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/connectivity_service.dart';

/// Full-screen overlay displayed when there is no network connection OR
/// when a network interface exists but no internet traffic can flow.
class NoInternetOverlay extends StatefulWidget {
  final ConnectivityStatus status;
  final VoidCallback onRetry;

  const NoInternetOverlay({
    super.key,
    required this.status,
    required this.onRetry,
  });

  @override
  State<NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<NoInternetOverlay>
    with SingleTickerProviderStateMixin {
  bool _retrying = false;

  bool get _isNoNetwork =>
      widget.status == ConnectivityStatus.noNetwork;

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
            colors: [Color(0xFF0D0D1A), Color(0xFF0A0A15)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated icon ────────────────────────────────────────────
                _buildIcon(),
                const SizedBox(height: 36),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  _isNoNetwork
                      ? 'No Connection'
                      : 'Connected, No Data',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // ── Body ─────────────────────────────────────────────────────
                Text(
                  _isNoNetwork
                      ? 'RedFlag Names needs an internet connection to dish out the drama. Turn on WiFi or mobile data and try again.'
                      : 'Your device is connected to a network but can\'t reach the internet. Check your WiFi router or mobile data plan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white54,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // ── Tip card ─────────────────────────────────────────────────
                _buildTipCard(),

                const SizedBox(height: 40),

                // ── Retry button ─────────────────────────────────────────────
                _buildRetryButton(),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildIcon() {
    final IconData icon =
        _isNoNetwork ? Icons.wifi_off_rounded : Icons.signal_wifi_bad_rounded;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A2E),
        border: Border.all(
          color: const Color(0xFFFF3B5C).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B5C).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(icon, size: 52, color: const Color(0xFFFF3B5C)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut);
  }

  Widget _buildTipCard() {
    final tips = _isNoNetwork
        ? [
            ('📶', 'Turn on WiFi or mobile data'),
            ('✈️', 'Disable Airplane mode'),
            ('🔄', 'Restart your router or phone'),
          ]
        : [
            ('📡', 'Check your WiFi router is online'),
            ('💳', 'Verify your mobile data plan is active'),
            ('🔄', 'Toggle WiFi off and back on'),
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Things to try:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white38,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(t.$1, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.$2,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _retrying ? null : _handleRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3B5C),
          disabledBackgroundColor: const Color(0xFFFF3B5C).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFFFF3B5C).withOpacity(0.4),
        ),
        child: _retrying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Try Again',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }
}
