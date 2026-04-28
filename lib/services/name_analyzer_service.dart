import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/content_pools.dart';
import '../models/analysis_result.dart';

class NameAnalyzerService {
  static final NameAnalyzerService instance = NameAnalyzerService._();
  NameAnalyzerService._();

  final _random = Random();
  final _uuid = const Uuid();

  AnalysisResult analyze(String name, GenderContext context) {
    final clean       = name.trim();
    final capitalized = _capitalize(clean);
    final seed        = _nameSeed(clean);
    final score       = _calculateChaos(clean, seed);
    final level       = _chaosLevel(score);

    final result = AnalysisResult(
      id: _uuid.v4(),
      name: capitalized,
      genderContext: context,
      intro: _pickIntro(capitalized, seed),
      traits: _pickTraits(context, seed, capitalized),
      twist: _pick(ContentPools.twists, seed + 999),
      ending: _riskEnding(level),
      chaosLevel: level,
      chaosScore: score,
      disclaimer: _pickDisclaimer(capitalized, seed),
      flagEmoji: _pickFlag(level),
      analyzedAt: DateTime.now(),
    );

    _saveToHistory(result);
    return result;
  }

  // ─── Helpers ─────────────────────────────────

  String _capitalize(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  int _nameSeed(String name) {
    int seed = 0;
    for (int i = 0; i < name.length; i++) {
      seed += name.codeUnitAt(i) * (i + 1);
    }
    return seed;
  }

  String _pick(List<String> pool, int seed) {
    if (pool.isEmpty) return '';
    return pool[(_random.nextInt(pool.length) + seed) % pool.length];
  }

  String _pickIntro(String name, int seed) =>
      _pick(ContentPools.intros, seed).replaceAll('{name}', name);

  /// Returns exactly 3 or 4 traits — focused, readable, not overwhelming
  List<String> _pickTraits(GenderContext context, int seed, String name) {
    final traits = <String>[];

    // 1) Special name override — max 1
    final special = ContentPools.specialNames[name.toLowerCase()];
    if (special != null && special.isNotEmpty) {
      final sp = List<String>.from(special)..shuffle(Random(seed));
      traits.add(sp.first);
    }

    // 2) Context-specific — 1 trait
    final ctxPool = _contextPool(context);
    if (ctxPool.isNotEmpty) {
      final shuffled = List<String>.from(ctxPool)..shuffle(Random(seed + 42));
      traits.add(shuffled.first);
    }

    // 3) General traits — fill remaining slots
    final gen = List<String>.from(ContentPools.generalTraits)
      ..shuffle(Random(seed + 1));

    for (final t in gen) {
      if (traits.length >= 4) break;
      if (!traits.contains(t)) traits.add(t);
    }

    // 4) One spicy category to add flavour — only if we have room
    if (traits.length < 4) {
      final spicyPools = [
        ContentPools.lyingTraits,
        ContentPools.cheatingTraits,
        ContentPools.appearanceTraits,
        ContentPools.intimateTraits,
      ];
      final spicy = spicyPools[seed % spicyPools.length];
      if (spicy.isNotEmpty) {
        final shuffled = List<String>.from(spicy)..shuffle(Random(seed + 99));
        final candidate = shuffled.first;
        if (!traits.contains(candidate)) traits.add(candidate);
      }
    }

    // Return 3–4 traits, deduplicated, shuffled
    final unique = traits.toSet().toList()..shuffle(Random(seed + 7));
    // Randomly decide 3 or 4
    final count = (seed % 2 == 0) ? 3 : 4;
    return unique.take(count).toList();
  }

  List<String> _contextPool(GenderContext context) {
    switch (context) {
      case GenderContext.boyfriend:  return ContentPools.boyfriendTraits;
      case GenderContext.girlfriend: return ContentPools.girlfriendTraits;
      case GenderContext.crush:      return ContentPools.crushTraits;
      case GenderContext.ex:         return ContentPools.exTraits;
      case GenderContext.general:    return ContentPools.generalTraits;
    }
  }

  int _calculateChaos(String name, int seed) {
    int score = (seed % 60) + 20;
    if (name.length <= 4) score += 10;
    if (name.length >= 8) score -= 5;
    score += _random.nextInt(20) - 10;
    return score.clamp(5, 100);
  }

  ChaosLevel _chaosLevel(int score) {
    if (score < 30) return ChaosLevel.low;
    if (score < 60) return ChaosLevel.medium;
    if (score < 85) return ChaosLevel.high;
    return ChaosLevel.extreme;
  }

  String _riskEnding(ChaosLevel level) {
    switch (level) {
      case ChaosLevel.low:     return ContentPools.riskEndings['low']!;
      case ChaosLevel.medium:  return ContentPools.riskEndings['medium']!;
      case ChaosLevel.high:    return ContentPools.riskEndings['high']!;
      case ChaosLevel.extreme: return ContentPools.riskEndings['extreme']!;
    }
  }

  String _pickDisclaimer(String name, int seed) =>
      _pick(ContentPools.disclaimers, seed + 456).replaceAll('{name}', name);

  String _pickFlag(ChaosLevel level) {
    switch (level) {
      case ChaosLevel.low:     return '💚';
      case ChaosLevel.medium:  return '🚩';
      case ChaosLevel.high:    return '🚩🚩';
      case ChaosLevel.extreme: return '🚩🚩🚩';
    }
  }

  // ─── History ─────────────────────────────────

  void _saveToHistory(AnalysisResult result) {
    SharedPreferences.getInstance().then((prefs) {
      final history = prefs.getStringList('history') ?? [];
      history.insert(0, result.toJsonString());
      if (history.length > 50) history.removeLast();
      prefs.setStringList('history', history);
    }).catchError((_) {});
  }

  Future<List<AnalysisResult>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList('history') ?? [])
          .map((s) {
            try { return AnalysisResult.fromJsonString(s); } catch (_) { return null; }
          })
          .whereType<AnalysisResult>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('history');
    } catch (_) {}
  }
}
