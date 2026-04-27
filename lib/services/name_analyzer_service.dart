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

    final result = AnalysisResult(
      id: _uuid.v4(),
      name: capitalized,
      genderContext: context,
      intro: _pickIntro(capitalized, seed),
      traits: _pickTraits(context, seed, capitalized),
      twist: _pick(ContentPools.twists, seed + 999),
      ending: _riskEnding(_chaosLevel(_calculateChaos(clean, seed))),
      chaosLevel: _chaosLevel(_calculateChaos(clean, seed)),
      chaosScore: _calculateChaos(clean, seed),
      disclaimer: _pickDisclaimer(capitalized, seed),
      flagEmoji: _pickFlag(_chaosLevel(_calculateChaos(clean, seed))),
      analyzedAt: DateTime.now(),
    );

    _saveToHistory(result);
    return result;
  }

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

  List<String> _pickTraits(GenderContext context, int seed, String name) {
    final traits = <String>[];

    // 1) Special name (up to 2)
    final special = ContentPools.specialNames[name.toLowerCase()];
    if (special != null && special.isNotEmpty) {
      traits.addAll((List<String>.from(special)..shuffle(Random(seed))).take(2));
    }

    // 2) Context-specific (2)
    final ctxPool = _contextPool(context);
    if (ctxPool.isNotEmpty) {
      traits.addAll(
          (List<String>.from(ctxPool)..shuffle(Random(seed + 42))).take(2));
    }

    // 3) General (2)
    traits.addAll(
        (List<String>.from(ContentPools.generalTraits)..shuffle(Random(seed + 1)))
            .take(2));

    // 4) One spicy category
    final spicy = [
      ContentPools.lyingTraits,
      ContentPools.cheatingTraits,
      ContentPools.appearanceTraits,
      ContentPools.soloHabitTraits,
      ContentPools.intimateTraits,
    ][seed % 5];
    if (spicy.isNotEmpty) {
      traits.addAll(
          (List<String>.from(spicy)..shuffle(Random(seed + 99))).take(1));
    }

    return (traits.toSet().toList()..shuffle(Random(seed + 7))).take(6).toList();
  }

  List<String> _contextPool(GenderContext context) {
    switch (context) {
      case GenderContext.boyfriend: return ContentPools.boyfriendTraits;
      case GenderContext.girlfriend: return ContentPools.girlfriendTraits;
      case GenderContext.crush: return ContentPools.crushTraits;
      case GenderContext.ex: return ContentPools.exTraits;
      case GenderContext.general: return ContentPools.generalTraits;
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
    } catch (_) { return []; }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('history');
    } catch (_) {}
  }
}
