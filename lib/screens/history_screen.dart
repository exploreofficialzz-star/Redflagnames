import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/analysis_result.dart';
import '../services/name_analyzer_service.dart';
import '../services/ad_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisResult> _history = [];
  bool _loading = true;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBanner();
  }

  Future<void> _loadData() async {
    // Show interstitial on history open — aggressive placement
    try {
      await AdService.instance.showInterstitial(context);
    } catch (_) {}

    final history = await NameAnalyzerService.instance.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  void _loadBanner() {
    try {
      _bannerAd = AdService.instance.createBannerAd()
        ..load().then((_) {
          if (mounted) setState(() => _bannerLoaded = true);
        }).catchError((_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Clear History? 🗑️',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'All your past analyses will be permanently deleted.',
          style: GoogleFonts.poppins(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B5C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Clear All',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await NameAnalyzerService.instance.clearHistory();
      if (mounted) setState(() => _history = []);
    }
  }

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
                // ── App bar ──
                SliverAppBar(
                  pinned: true,
                  backgroundColor: const Color(0xFF0D0D1A),
                  elevation: 0,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'History',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (_history.isNotEmpty)
                      TextButton(
                        onPressed: _clearHistory,
                        child: Text(
                          'Clear all',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF3B5C),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Stats bar ──
                if (_history.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildStatsBar(),
                  ),

                // ── Content ──
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3B5C),
                      ),
                    ),
                  )
                else if (_history.isEmpty)
                  SliverFillRemaining(child: _buildEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Inject inline banner ad every 5 items
                          if (!AdService.instance.isPremium &&
                              index > 0 &&
                              index % 5 == 0) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: AdService.instance.buildInlineBanner(),
                            );
                          }

                          // Adjust index for ad slots
                          final adsBefore = AdService.instance.isPremium
                              ? 0
                              : index ~/ 5;
                          final realIndex = index - adsBefore;

                          if (realIndex >= _history.length) {
                            return const SizedBox.shrink();
                          }

                          return _HistoryCard(
                            result: _history[realIndex],
                            index: realIndex,
                            onTap: () async {
                              await Navigator.of(context).pushNamed(
                                '/result',
                                arguments: _history[realIndex],
                              );
                              // Show interstitial after viewing a history result
                              if (mounted) {
                                try {
                                  await AdService.instance
                                      .showInterstitial(context);
                                } catch (_) {}
                              }
                            },
                          );
                        },
                        childCount: _history.isEmpty
                            ? 0
                            : _history.length +
                                (AdService.instance.isPremium
                                    ? 0
                                    : _history.length ~/ 5),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Persistent bottom banner ──
          if (_bannerLoaded && _bannerAd != null && !AdService.instance.isPremium)
            SizedBox(
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final extreme = _history
        .where((r) => r.chaosLevel == ChaosLevel.extreme)
        .length;
    final highChaos = _history
        .where((r) =>
            r.chaosLevel == ChaosLevel.high ||
            r.chaosLevel == ChaosLevel.extreme)
        .length;
    final avgScore = _history.isEmpty
        ? 0
        : _history.map((r) => r.chaosScore).reduce((a, b) => a + b) ~/
            _history.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF3B5C).withOpacity(0.12),
            const Color(0xFF1E1E35),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFF3B5C).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat('${_history.length}', 'Total', '📋'),
          _vDivider(),
          _miniStat('$avgScore%', 'Avg Chaos', '📊'),
          _vDivider(),
          _miniStat('$extreme', 'Extreme 🚨', '💀'),
          _vDivider(),
          _miniStat('$highChaos', 'High Risk', '🔴'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _miniStat(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withOpacity(0.08),
      );

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🗂️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            'No analyses yet!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go analyze someone\'s name 😂\nYou know you want to.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1744), Color(0xFFFF6B9D)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B5C).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                '🚩  Analyze a Name',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// History Card
// ─────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final int index;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.result,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: result.chaosColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Flag icon ──
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    result.chaosColor.withOpacity(0.25),
                    result.chaosColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: result.chaosColor.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  result.flagEmoji.length > 2
                      ? result.flagEmoji.substring(0, 2)
                      : result.flagEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Name + level ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.chaosLevelText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: result.chaosColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Context label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _contextLabel(result.genderContext),
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),

            // ── Score ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.chaosScore}',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: result.chaosColor,
                  ),
                ),
                Text(
                  '% chaos',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: Colors.white38),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 14),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 30 * index.clamp(0, 20)))
        .slideX(begin: 0.06, end: 0);
  }

  String _contextLabel(GenderContext ctx) {
    switch (ctx) {
      case GenderContext.boyfriend:  return '💙 Boyfriend';
      case GenderContext.girlfriend: return '💕 Girlfriend';
      case GenderContext.crush:      return '😍 Crush';
      case GenderContext.ex:         return '💔 Ex';
      case GenderContext.general:    return '👤 General';
    }
  }
}
