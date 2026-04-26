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

  // ===== ANALYZE NAME =====
  AnalysisResult analyze(String name, GenderContext context) {
    final cleanName = name.trim();
    final capitalizedName = _capitalize(cleanName);
    final seed = _nameSeed(cleanName);

    final intro = _pickIntro(capitalizedName, seed);
    final traits = _pickTraits(context, seed, capitalizedName);
    final twist = _pick(ContentPools.twists, seed + 999);
    final chaosScore = _calculateChaos(cleanName, seed);
    final chaosLevel = _chaoLevel(chaosScore);
    final ending = _riskEnding(chaosLevel);
    final disclaimer = _pickDisclaimer(capitalizedName, seed);
    final flagEmoji = _pickFlag(chaosLevel, seed);

    final result = AnalysisResult(
      id: _uuid.v4(),
      name: capitalizedName,
      genderContext: context,
      intro: intro,
      traits: traits,
      twist: twist,
      ending: ending,
      chaosLevel: chaosLevel,
      chaosScore: chaosScore,
      disclaimer: disclaimer,
      flagEmoji: flagEmoji,
      analyzedAt: DateTime.now(),
    );

    _saveToHistory(result);
    return result;
  }

  // ===== HELPERS =====
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
    // Use both seed and random for variation on re-analysis
    final index = (_random.nextInt(pool.length) + seed) % pool.length;
    return pool[index];
  }

  String _pickIntro(String name, int seed) {
    final template = _pick(ContentPools.intros, seed);
    return template.replaceAll('{name}', name);
  }

  List<String> _pickTraits(GenderContext context, int seed, String name) {
    final traits = <String>[];
    final lowerName = name.toLowerCase();

    // Check for special name response
    List<String>? specialTraits = ContentPools.specialNames[lowerName];
    if (specialTraits != null && specialTraits.isNotEmpty) {
      traits.addAll(specialTraits.take(2));
    }

    // General traits (always 2-3)
    final generalPool = List<String>.from(ContentPools.generalTraits);
    generalPool.shuffle(Random(seed));
    int generalCount = 3 - traits.length;
    traits.addAll(generalPool.take(generalCount));

    // Context-specific traits (1-2)
    List<String> contextPool;
    switch (context) {
      case GenderContext.boyfriend:
        contextPool = ContentPools.boyfriendTraits;
        break;
      case GenderContext.girlfriend:
        contextPool = ContentPools.girlfriendTraits;
        break;
      case GenderContext.crush:
        contextPool = ContentPools.crushTraits;
        break;
      case GenderContext.ex:
        contextPool = ContentPools.exTraits;
        break;
      case GenderContext.general:
        contextPool = ContentPools.generalTraits;
        break;
    }

    if (contextPool.isNotEmpty) {
      contextPool.shuffle(Random(seed + 42));
      traits.addAll(contextPool.take(2));
    }

    traits.shuffle(Random(seed + 7));
    return traits.take(5).toList();
  }

  int _calculateChaos(String name, int seed) {
    // Base score from name seed
    int score = (seed % 60) + 20; // 20–80 base

    // Adjust for name length (shorter names = more chaos lol)
    if (name.length <= 4) score += 10;
    if (name.length >= 8) score -= 5;

    // Random variance (different each analysis)
    score += _random.nextInt(20) - 10;

    return score.clamp(5, 100);
  }

  ChaosLevel _chaoLevel(int score) {
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
    final template = _pick(ContentPools.disclaimers, seed + 456);
    return template.replaceAll('{name}', name);
  }

  String _pickFlag(ChaosLevel level, int seed) {
    switch (level) {
      case ChaosLevel.low:
        return '💚';
      case ChaosLevel.medium:
        return '🚩';
      case ChaosLevel.high:
        return '🚩🚩';
      case ChaosLevel.extreme:
        return '🚩🚩🚩';
    }
  }

  // ===== HISTORY =====
  Future<void> _saveToHistory(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];
    history.insert(0, result.toJsonString());
    // Keep last 50
    if (history.length > 50) history.removeLast();
    await prefs.setStringList('history', history);
  }

  Future<List<AnalysisResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];
    return history.map((s) => AnalysisResult.fromJsonString(s)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
  }
}
