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
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
            radius: 1.2,
            colors: [
              Color(0xFF2D0A1E),
              Color(0xFF0D0D1A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heart + Flag Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3B5C).withOpacity(0.4),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  // Icon
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 140,
                    height: 140,
                    errorBuilder: (_, __, ___) => const Text(
                      '🚩',
                      style: TextStyle(fontSize: 80),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),
                ],
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'RedFlag',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms)
                  .fadeIn(delay: 400.ms, duration: 500.ms),

              // Names pill
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3B5C), Color(0xFFFF6B9D)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B5C).withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'NAMES  🚩',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, end: 0, delay: 550.ms, duration: 500.ms)
                  .fadeIn(delay: 550.ms, duration: 500.ms),

              const SizedBox(height: 20),

              Text(
                'Funny Name Relationship Analyzer',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white54,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

              const SizedBox(height: 60),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B5C),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(),
                        delay: Duration(milliseconds: 200 * i),
                      )
                      .scaleXY(
                        begin: 0.5,
                        end: 1.0,
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 16),

              Text(
                'Analyzing the chaos...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
