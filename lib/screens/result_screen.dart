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
      duration: const Duration(milliseconds: 600),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── Intro card ──
                      _buildIntroCard(),
                      const SizedBox(height: 16),

                      // ── All traits in one clean card ──
                      _buildTraitsCard(),
                      const SizedBox(height: 16),

                      // ── Chaos meter ──
                      _buildChaosMeter(),
                      const SizedBox(height: 16),

                      // 🔥 AD SLOT 1 — inline banner between meter and twist
                      if (!AdService.instance.isPremium)
                        AdService.instance.buildInlineBanner(),
                      if (!AdService.instance.isPremium)
                        const SizedBox(height: 16),

                      // ── Twist ──
                      _buildTwistCard(),
                      const SizedBox(height: 16),

                      // 🔥 AD SLOT 2 — remove ads prompt
                      if (!AdService.instance.isPremium)
                        AdService.instance.buildRemoveAdsPrompt(context),
                      if (!AdService.instance.isPremium)
                        const SizedBox(height: 16),

                      // ── Risk ending ──
                      _buildRiskCard(),
                      const SizedBox(height: 16),

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

          // 🔥 AD SLOT 3 — bottom banner always
          if (!AdService.instance.isPremium)
            AdService.instance.buildBannerWidget(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D1A),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _onShare,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
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
                _primaryColor.withOpacity(0.3),
                const Color(0xFF0D0D1A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _flagController,
                  builder: (_, __) => Transform.rotate(
                    angle: (_flagController.value - 0.5) * 0.16,
                    child: Text(widget.result.flagEmoji,
                        style: const TextStyle(fontSize: 60)),
                  ),
                ).animate().scale(
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.elasticOut),
                const SizedBox(height: 10),
                Text(
                  widget.result.name,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: _primaryColor.withOpacity(0.5),
                          blurRadius: 24)
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _primaryColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    widget.result.chaosLevelText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildIntroCard() {
    return _Card(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryColor.withOpacity(0.4)),
            ),
            child: Text(
              'PROFILE REPORT',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.result.intro,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  /// All 3-4 traits in one card — NO ads inside
  Widget _buildTraitsCard() {
    final traits = widget.result.traits;
    return _Card(
      delay: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔎', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'What we found',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...traits.asMap().entries.map((e) {
            final i = e.key;
            final trait = e.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < traits.length - 1 ? 14 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      trait,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.88),
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 250 + (i * 100)))
                  .slideX(begin: -0.06, end: 0),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildChaosMeter() {
    return _Card(
      delay: 350,
      child: ChaosMeterWidget(result: widget.result),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildTwistCard() {
    return _Card(
      delay: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌀', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'But here is the thing...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withOpacity(0.12),
                  _primaryColor.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: _primaryColor.withOpacity(0.25)),
            ),
            child: Text(
              widget.result.twist,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.88),
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildRiskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withOpacity(0.18),
            _primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            widget.result.ending.split('\n').first,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
            ),
          ),
          if (widget.result.ending.contains('\n')) ...[
            const SizedBox(height: 8),
            Text(
              widget.result.ending.split('\n').skip(1).join('\n'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white60, height: 1.6),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1, end: 0);
  }

  // ─────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Text(
        widget.result.disclaimer,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 12, color: Colors.white38, height: 1.6),
      ),
    ).animate().fadeIn(delay: 650.ms);
  }

  // ─────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GradientButton(
            label: '🚩  Share This Report',
            colors: const [Color(0xFF00B4D8), Color(0xFF0066CC)],
            glowColor: const Color(0xFF00B4D8),
            onTap: _onShare,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: '🔄 Try Another',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlineButton(
                  label: '👑 Remove Ads',
                  color: const Color(0xFFFFD700),
                  onTap: _onRemoveAds,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  void _onShare() async {
    try { await SoundService.instance.playShare(); } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ShareSheet(result: widget.result),
    );
  }

  void _onRemoveAds() {
    AdService.instance.showRewarded(
      onRewarded: () {
        AdService.instance.setPremium(true);
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Ads removed for this session!'),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      onFailed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Ad not ready — try again shortly'),
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
class _ShareSheet extends StatelessWidget {
  final AnalysisResult result;
  const _ShareSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Share ${result.name} Report 🚩',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text('Send it to someone who needs to see this 😂',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareBtn('💬', 'WhatsApp', const Color(0xFF25D366), () {
                Navigator.pop(context);
                ShareService.instance.shareToWhatsApp(result);
              }),
              _ShareBtn('📸', 'Instagram', const Color(0xFFE1306C), () {
                Navigator.pop(context);
                ShareService.instance.shareResultAsText(result);
              }),
              _ShareBtn('🎵', 'TikTok', const Color(0xFF111111), () {
                Navigator.pop(context);
                ShareService.instance.shareResultAsText(result);
              }),
              _ShareBtn('📋', 'Copy', const Color(0xFF6C63FF), () {
                Navigator.pop(context);
                ShareService.instance.copyToClipboard(context, result);
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ShareBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _ShareBtn(this.emoji, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Center(
                  child:
                      Text(emoji, style: const TextStyle(fontSize: 26)))),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final int delay;
  const _Card({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: child,
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color glowColor;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.label,
      required this.colors,
      required this.glowColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: glowColor.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineButton(
      {required this.label,
      this.color = Colors.white54,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
      ),
    );
  }
}
