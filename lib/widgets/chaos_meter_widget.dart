import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/analysis_result.dart';

class ChaosMeterWidget extends StatefulWidget {
  final AnalysisResult result;
  const ChaosMeterWidget({super.key, required this.result});

  @override
  State<ChaosMeterWidget> createState() => _ChaosMeterWidgetState();
}

class _ChaosMeterWidgetState extends State<ChaosMeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.result.chaosScore / 100.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _meterColor => widget.result.chaosColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Chaos Meter',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            // Animated score
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (_, __) => Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _meterColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (_, __) => LinearProgressIndicator(
              value: _progressAnimation.value,
              minHeight: 16,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(_meterColor),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Scale labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('💚 Chill', const Color(0xFF00C853)),
            _label('🟡 Hmm', const Color(0xFFFFD600)),
            _label('🔴 Chaos', const Color(0xFFFF6B00)),
            _label('🚨 RUN', const Color(0xFFFF1744)),
          ],
        ),

        const SizedBox(height: 14),

        // Verdict chip
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: _meterColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _meterColor.withOpacity(0.3)),
          ),
          child: Text(
            widget.result.chaosDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _meterColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
