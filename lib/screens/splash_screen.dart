import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [Color(0xFF2D0A1E), Color(0xFF0D0D1A)],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating emoji particles ──
            _buildParticles(context),

            // ── Main content ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Icon with glow ──
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Container(
                          width: 180 + (_pulseController.value * 20),
                          height: 180 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3B5C).withOpacity(
                                    0.25 * _pulseController.value),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF3B5C),
                                  Color(0xFFFF6B9D)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const Center(
                              child: Text('🚩',
                                  style: TextStyle(fontSize: 64)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 36),

                  // ── RedFlag title ──
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFFF6B9D)],
                    ).createShader(bounds),
                    child: Text(
                      'RedFlag',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 400.ms),

                  // ── NAMES pill ──
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF1744), Color(0xFFFF6B9D)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3B5C).withOpacity(0.55),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'N A M E S  🚩',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 550.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 550.ms),

                  const SizedBox(height: 14),

                  // ── Tagline ──
                  Text(
                    'Funny Relationship Name Analyzer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 750.ms, duration: 600.ms),

                  const Spacer(flex: 2),

                  // ── Loading dots ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 5),
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B5C),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(
                            onPlay: (c) => c.repeat(),
                            delay: Duration(milliseconds: 180 * i),
                          )
                          .scaleXY(
                            begin: 0.4,
                            end: 1.0,
                            duration: 600.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scaleXY(
                              begin: 1.0,
                              end: 0.4,
                              duration: 600.ms);
                    }),
                  ).animate().fadeIn(delay: 1000.ms),

                  const SizedBox(height: 12),

                  Text(
                    'Scanning the chaos...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                  ).animate().fadeIn(delay: 1200.ms),

                  const SizedBox(height: 40),

                  // ── by chAs Tech Group ──
                  _buildChAsTag()
                      .animate()
                      .fadeIn(delay: 1600.ms, duration: 800.ms)
                      .slideY(begin: 0.2, end: 0, delay: 1600.ms),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── by chAs Tech Group tag ──────────────────────
  Widget _buildChAsTag() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 40,
                height: 1,
                color: Colors.white.withOpacity(0.15)),
            const SizedBox(width: 12),
            Text(
              'by',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white38,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 12),
            Container(
                width: 40,
                height: 1,
                color: Colors.white.withOpacity(0.15)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFB830).withOpacity(0.12),
                const Color(0xFFFF3B5C).withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFB830).withOpacity(0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo circle
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB830), Color(0xFFFF3B5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'c',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ch',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                    TextSpan(
                      text: 'As',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFB830),
                      ),
                    ),
                    TextSpan(
                      text: ' Tech Group',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Floating particles — FIXED: uses MediaQuery not deprecated window ──
  Widget _buildParticles(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final particles = [
      {'emoji': '🚩', 'x': 0.08, 'y': 0.10, 'size': 22.0},
      {'emoji': '💀', 'x': 0.88, 'y': 0.08, 'size': 20.0},
      {'emoji': '😂', 'x': 0.05, 'y': 0.42, 'size': 18.0},
      {'emoji': '💅', 'x': 0.91, 'y': 0.35, 'size': 18.0},
      {'emoji': '😏', 'x': 0.10, 'y': 0.75, 'size': 16.0},
      {'emoji': '🔴', 'x': 0.86, 'y': 0.68, 'size': 16.0},
      {'emoji': '💔', 'x': 0.50, 'y': 0.06, 'size': 18.0},
      {'emoji': '🤣', 'x': 0.75, 'y': 0.88, 'size': 16.0},
      {'emoji': '👀', 'x': 0.20, 'y': 0.92, 'size': 16.0},
    ];

    return Stack(
      children: particles.asMap().entries.map((entry) {
        final p = entry.value;
        final i = entry.key;
        return Positioned(
          left: size.width * (p['x'] as double),
          top: size.height * (p['y'] as double),
          child: Text(
            p['emoji'] as String,
            style: TextStyle(fontSize: p['size'] as double),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
                delay: Duration(milliseconds: i * 200),
              )
              .moveY(
                begin: 0,
                end: -12,
                duration: Duration(milliseconds: 2200 + (i * 250)),
                curve: Curves.easeInOut,
              ),
        );
      }).toList(),
    );
  }
}
