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

  // ===== PUBLIC: ANALYZE =====
  AnalysisResult analyze(String name, GenderContext context) {
    final clean = name.trim();
    final capitalized = _capitalize(clean);
    final seed = _nameSeed(clean);

    final intro    = _pickIntro(capitalized, seed);
    final traits   = _pickTraits(context, seed, capitalized);
    final twist    = _pick(ContentPools.twists, seed + 999);
    final score    = _calculateChaos(clean, seed);
    final level    = _chaosLevel(score);
    final ending   = _riskEnding(level);
    final disc     = _pickDisclaimer(capitalized, seed);
    final flag     = _pickFlag(level);

    final result = AnalysisResult(
      id: _uuid.v4(),
      name: capitalized,
      genderContext: context,
      intro: intro,
      traits: traits,
      twist: twist,
      ending: ending,
      chaosLevel: level,
      chaosScore: score,
      disclaimer: disc,
      flagEmoji: flag,
      analyzedAt: DateTime.now(),
    );

    // Save in background — never await, never throw
    _saveToHistory(result);
    return result;
  }

  // ===== PRIVATE HELPERS =====

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
    final index = (_random.nextInt(pool.length) + seed) % pool.length;
    return pool[index];
  }

  String _pickIntro(String name, int seed) {
    return _pick(ContentPools.intros, seed)
        .replaceAll('{name}', name);
  }

  List<String> _pickTraits(GenderContext context, int seed, String name) {
    final traits = <String>[];

    // Special name overrides
    final special =
        ContentPools.specialNames[name.toLowerCase()];
    if (special != null && special.isNotEmpty) {
      traits.addAll(special.take(2));
    }

    // General traits
    final general = List<String>.from(ContentPools.generalTraits)
      ..shuffle(Random(seed));
    traits.addAll(general.take((3 - traits.length).clamp(0, 3)));

    // Context traits
    final List<String> ctxPool;
    switch (context) {
      case GenderContext.boyfriend:
        ctxPool = ContentPools.boyfriendTraits;
        break;
      case GenderContext.girlfriend:
        ctxPool = ContentPools.girlfriendTraits;
        break;
      case GenderContext.crush:
        ctxPool = ContentPools.crushTraits;
        break;
      case GenderContext.ex:
        ctxPool = ContentPools.exTraits;
        break;
      case GenderContext.general:
        ctxPool = ContentPools.generalTraits;
        break;
    }

    if (ctxPool.isNotEmpty) {
      final shuffled = List<String>.from(ctxPool)..shuffle(Random(seed + 42));
      traits.addAll(shuffled.take(2));
    }

    traits.shuffle(Random(seed + 7));
    return traits.take(5).toList();
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
      case ChaosLevel.low:
        return ContentPools.riskEndings['low']!;
      case ChaosLevel.medium:
        return ContentPools.riskEndings['medium']!;
      case ChaosLevel.high:
        return ContentPools.riskEndings['high']!;
      case ChaosLevel.extreme:
        return ContentPools.riskEndings['extreme']!;
    }
  }

  String _pickDisclaimer(String name, int seed) {
    return _pick(ContentPools.disclaimers, seed + 456)
        .replaceAll('{name}', name);
  }

  String _pickFlag(ChaosLevel level) {
    switch (level) {
      case ChaosLevel.low:     return '💚';
      case ChaosLevel.medium:  return '🚩';
      case ChaosLevel.high:    return '🚩🚩';
      case ChaosLevel.extreme: return '🚩🚩🚩';
    }
  }

  // ===== HISTORY =====

  /// Fire-and-forget — runs in background, never throws
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
      final history = prefs.getStringList('history') ?? [];
      final results = <AnalysisResult>[];
      for (final s in history) {
        try {
          results.add(AnalysisResult.fromJsonString(s));
        } catch (_) {
          // Skip corrupted entries
        }
      }
      return results;
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
