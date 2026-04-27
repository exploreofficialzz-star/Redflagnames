import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/analysis_result.dart';
import '../services/share_service.dart';
import '../services/ad_service.dart';
import '../services/sound_service.dart';
import '../widgets/chaos_meter_widget.dart';

class ResultScreen extends StatefulWidget {
  final AnalysisResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _flagController;

  @override
  void initState() {
    super.initState();
    _flagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flagController.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.result.chaosColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),

                      // ── Intro card ──
                      _buildIntroCard(),
                      const SizedBox(height: 14),

                      // ── Traits 1 & 2 ──
                      _buildTraitCard(widget.result.traits, 0),
                      _buildTraitCard(widget.result.traits, 1),

                      // 🔥 AD SLOT 1 — between traits
                      AdService.instance.buildInlineBanner(),

                      // ── Traits 3 & 4 ──
                      _buildTraitCard(widget.result.traits, 2),
                      _buildTraitCard(widget.result.traits, 3),

                      // ── Chaos meter ──
                      const SizedBox(height: 14),
                      _buildChaosMeter(),
                      const SizedBox(height: 14),

                      // ── Trait 5 ──
                      _buildTraitCard(widget.result.traits, 4),

                      // 🔥 AD SLOT 2 — remove ads prompt
                      const SizedBox(height: 8),
                      AdService.instance.buildRemoveAdsPrompt(context),
                      const SizedBox(height: 8),

                      // ── Trait 6 ──
                      _buildTraitCard(widget.result.traits, 5),

                      // ── Twist ──
                      const SizedBox(height: 14),
                      _buildTwistCard(),
                      const SizedBox(height: 14),

                      // 🔥 AD SLOT 3 — inline banner after twist
                      AdService.instance.buildInlineBanner(),

                      // ── Risk ending ──
                      _buildRiskCard(),
                      const SizedBox(height: 14),

                      // ── Disclaimer ──
                      _buildDisclaimer(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ──
          _buildActionButtons(),

          // 🔥 AD SLOT 4 — persistent bottom banner
          AdService.instance.buildBannerWidget(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D1A),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _showShareSheet,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _primaryColor.withOpacity(0.35),
                const Color(0xFF0D0D1A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _flagController,
                  builder: (_, __) => Transform.rotate(
                    angle: (_flagController.value - 0.5) * 0.18,
                    child: Text(widget.result.flagEmoji,
                        style: const TextStyle(fontSize: 64)),
                  ),
                ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.elasticOut),
                const SizedBox(height: 8),
                Text(
                  widget.result.name,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: _primaryColor.withOpacity(0.6),
                          blurRadius: 20)
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                Text(
                  widget.result.chaosLevelText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildIntroCard() {
    return _GlassCard(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColor.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PROFILE REPORT',
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.result.intro,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitCard(List<String> traits, int index) {
    if (index >= traits.length) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              traits[index],
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.88),
                  height: 1.5),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 150 + (index * 80)))
        .slideX(begin: -0.08, end: 0);
  }

  Widget _buildChaosMeter() {
    return _GlassCard(
      delay: 300,
      child: ChaosMeterWidget(result: widget.result),
    );
  }

  Widget _buildTwistCard() {
    return _GlassCard(
      delay: 400,
      child: Column(
        children: [
          Row(children: [
            const Text('🌀', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('But Wait...',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _primaryColor.withOpacity(0.15),
                _primaryColor.withOpacity(0.05)
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              widget.result.twist,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    return _GlassCard(
      delay: 500,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            _primaryColor.withOpacity(0.2),
            _primaryColor.withOpacity(0.05)
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _primaryColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              widget.result.ending.split('\n').first,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor),
            ),
            if (widget.result.ending.contains('\n')) ...[
              const SizedBox(height: 8),
              Text(
                widget.result.ending.split('\n').skip(1).join('\n'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        widget.result.disclaimer,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 12, color: Colors.white38, height: 1.5),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  // ─────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share — full width
          _gradientButton(
            label: '🚩  Share This Report',
            colors: const [Color(0xFF00B4D8), Color(0xFF0077B6)],
            shadowColor: const Color(0xFF00B4D8),
            onTap: _showShareSheet,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _outlineButton(
                  label: '🔄 Try Another',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineButton(
                  label: '👑 No Ads',
                  color: const Color(0xFFFFD700),
                  onTap: _watchRewardedAd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required List<Color> colors,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: shadowColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    Color color = Colors.white60,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  void _showShareSheet() async {
    try { await SoundService.instance.playShare(); } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ShareBottomSheet(result: widget.result),
    );
  }

  void _watchRewardedAd() {
    AdService.instance.showRewarded(
      onRewarded: () {
        AdService.instance.setPremium(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('🎉 Ads removed for this session!'),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
          setState(() {});
        }
      },
      onFailed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('😅 Ad not ready — try again shortly!'),
            backgroundColor: const Color(0xFFFF6B00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────
// Share Sheet
// ─────────────────────────────────────────────────
class _ShareBottomSheet extends StatelessWidget {
  final AnalysisResult result;
  const _ShareBottomSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text(
            'Share ${result.name}\'s Report 🚩',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Make your friends analyze their person too 😂',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareOption('💬', 'WhatsApp', const Color(0xFF25D366),
                  () { Navigator.pop(context); ShareService.instance.shareToWhatsApp(result); }),
              _ShareOption('📸', 'Instagram', const Color(0xFFE1306C),
                  () { Navigator.pop(context); ShareService.instance.shareResultAsText(result); }),
              _ShareOption('🎵', 'TikTok', const Color(0xFF010101),
                  () { Navigator.pop(context); ShareService.instance.shareResultAsText(result); }),
              _ShareOption('📋', 'Copy', const Color(0xFF6C63FF),
                  () { Navigator.pop(context); ShareService.instance.copyToClipboard(context, result); }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption(this.emoji, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Glass Card
// ─────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final int delay;
  const _GlassCard({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: child,
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.12, end: 0);
  }
}
