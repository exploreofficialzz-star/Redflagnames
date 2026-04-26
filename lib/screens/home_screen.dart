import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/analysis_result.dart';
import '../services/name_analyzer_service.dart';
import '../services/ad_service.dart';
import '../services/sound_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  GenderContext _selectedContext = GenderContext.general;
  bool _isAnalyzing = false;
  late AnimationController _shakeController;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  final List<Map<String, dynamic>> _emojis = [
    {'emoji': '🚩', 'x': 0.1, 'y': 0.15},
    {'emoji': '💀', 'x': 0.85, 'y': 0.12},
    {'emoji': '😂', 'x': 0.05, 'y': 0.45},
    {'emoji': '💅', 'x': 0.9, 'y': 0.38},
    {'emoji': '😏', 'x': 0.15, 'y': 0.72},
    {'emoji': '🔴', 'x': 0.82, 'y': 0.68},
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadBanner();
    // Fire-and-forget — do NOT await here to avoid blocking UI
    SoundService.instance.initialize().catchError((_) {});
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
    _nameController.dispose();
    _shakeController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  static const _contexts = [
    {'value': GenderContext.general, 'label': '👤 General'},
    {'value': GenderContext.boyfriend, 'label': '💙 Boyfriend'},
    {'value': GenderContext.girlfriend, 'label': '💕 Girlfriend'},
    {'value': GenderContext.crush, 'label': '😍 Crush'},
    {'value': GenderContext.ex, 'label': '💔 Ex'},
  ];

  // ===== CORE FIX: try/finally ensures _isAnalyzing always resets =====
  Future<void> _analyze() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Play woosh sound — wrapped so it never blocks
      try {
        await SoundService.instance.playAnalyzing();
      } catch (_) {}

      // Dramatic scanning delay
      await Future.delayed(const Duration(milliseconds: 1800));

      // Generate result
      final result = NameAnalyzerService.instance.analyze(
        name,
        _selectedContext,
      );

      // Play result sound — wrapped so it never blocks
      try {
        switch (result.chaosLevel) {
          case ChaosLevel.low:
            await SoundService.instance.playGreenFlag();
            break;
          case ChaosLevel.high:
          case ChaosLevel.extreme:
            await SoundService.instance.playLaugh();
            break;
          default:
            await SoundService.instance.playReveal();
        }
      } catch (_) {}

      // Show notification — wrapped, permission may be denied
      try {
        await NotificationService.instance
            .showResultNotification(name, result.chaosLevelText);
      } catch (_) {}

      if (!mounted) return;

      // Navigate to result screen
      await Navigator.of(context).pushNamed('/result', arguments: result);

      // Show interstitial AFTER returning from result — wrapped
      if (mounted) {
        try {
          await AdService.instance.showInterstitial(context);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('❌ Analyze error: $e');
      // Show a snackbar so user knows something went wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong — please try again 😅'),
            backgroundColor: const Color(0xFFFF3B5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      // ALWAYS reset loading state — this is the critical fix
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          _buildBackground(),
          ..._buildFloatingEmojis(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildNameInput(),
                          const SizedBox(height: 24),
                          _buildContextSelector(),
                          const SizedBox(height: 32),
                          _buildAnalyzeButton(),
                          const SizedBox(height: 20),
                          _buildQuickStats(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_bannerLoaded &&
                    _bannerAd != null &&
                    !AdService.instance.isPremium)
                  SizedBox(
                    height: 60,
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0D2E),
            Color(0xFF0D0D1A),
            Color(0xFF1A0A12),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingEmojis() {
    final size = MediaQuery.of(context).size;
    return _emojis.asMap().entries.map((entry) {
      final e = entry.value;
      final i = entry.key;
      return Positioned(
        left: size.width * (e['x'] as double),
        top: size.height * (e['y'] as double),
        child: Text(
          e['emoji'] as String,
          style: const TextStyle(fontSize: 28),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -15,
              duration: Duration(milliseconds: 2000 + (i * 300)),
              curve: Curves.easeInOut,
            ),
      );
    }).toList();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B5C), Color(0xFFFF6B9D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3B5C).withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🚩', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'RedFlag Names',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _iconBtn(
                  icon: Icons.history_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed('/history'),
                ),
                const SizedBox(width: 8),
                _iconBtn(
                  icon: SoundService.instance.soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  onTap: () async {
                    await SoundService.instance.toggleSound();
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Enter a name.\nGet the truth. 😂',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'Purely for entertainment — no one is safe 🚩',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }

  Widget _buildNameInput() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final offset = t == 0 ? 0.0 : 8 * (0.5 - (t % 0.1) / 0.1).abs();
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B5C).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _nameController,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _analyze(),
          decoration: InputDecoration(
            hintText: 'Enter a name...',
            hintStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1E1E35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(color: Color(0xFFFF3B5C), width: 2),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(14),
              child: Text('🔍', style: TextStyle(fontSize: 22)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContextSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who is this person to you? 👀',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _contexts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final ctx = _contexts[i];
              final isSelected =
                  _selectedContext == ctx['value'] as GenderContext;
              return GestureDetector(
                onTap: () {
                  setState(() =>
                      _selectedContext = ctx['value'] as GenderContext);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF3B5C), Color(0xFFFF6B9D)],
                          )
                        : null,
                    color:
                        isSelected ? null : const Color(0xFF1E1E35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF3B5C).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    ctx['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: GestureDetector(
        onTap: _isAnalyzing ? null : _analyze,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: _isAnalyzing
                ? const LinearGradient(
                    colors: [Color(0xFF444), Color(0xFF333)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFF1744), Color(0xFFFF6B9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isAnalyzing
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFFF3B5C).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: _isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Scanning for flags...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '🚩  Analyze This Name',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('😂', '10M+', 'Analyses Done'),
          _divider(),
          _statItem('🚩', '98%', 'Accuracy*\n*satire'),
          _divider(),
          _statItem('💀', '∞', 'Name Combos'),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 50,
        color: Colors.white.withOpacity(0.08),
      );
}
