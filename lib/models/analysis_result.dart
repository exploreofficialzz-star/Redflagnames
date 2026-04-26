import 'dart:convert';
import 'package:flutter/material.dart';

enum ChaosLevel { low, medium, high, extreme }

enum GenderContext { general, boyfriend, girlfriend, crush, ex }

class AnalysisResult {
  final String id;
  final String name;
  final GenderContext genderContext;
  final String intro;
  final List<String> traits;
  final String twist;
  final String ending;
  final ChaosLevel chaosLevel;
  final int chaosScore;
  final String disclaimer;
  final String flagEmoji;
  final DateTime analyzedAt;

  AnalysisResult({
    required this.id,
    required this.name,
    required this.genderContext,
    required this.intro,
    required this.traits,
    required this.twist,
    required this.ending,
    required this.chaosLevel,
    required this.chaosScore,
    required this.disclaimer,
    required this.flagEmoji,
    required this.analyzedAt,
  });

  String get chaosLevelText {
    switch (chaosLevel) {
      case ChaosLevel.low:    return '🟢 Low Chaos';
      case ChaosLevel.medium: return '🟡 Medium Chaos';
      case ChaosLevel.high:   return '🔴 High Chaos';
      case ChaosLevel.extreme:return '🚨 EXTREME CHAOS';
    }
  }

  String get chaosDescription {
    switch (chaosLevel) {
      case ChaosLevel.low:    return 'You might survive this one 😊';
      case ChaosLevel.medium: return 'Proceed with caution 👀';
      case ChaosLevel.high:   return 'You have been warned 💀';
      case ChaosLevel.extreme:return 'RUN. JUST RUN. 🏃‍♂️💨';
    }
  }

  Color get chaosColor {
    switch (chaosLevel) {
      case ChaosLevel.low:    return const Color(0xFF00C853);
      case ChaosLevel.medium: return const Color(0xFFFFD600);
      case ChaosLevel.high:   return const Color(0xFFFF6B00);
      case ChaosLevel.extreme:return const Color(0xFFFF1744);
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'genderContext': genderContext.index,
    'intro': intro,
    'traits': traits,
    'twist': twist,
    'ending': ending,
    'chaosLevel': chaosLevel.index,
    'chaosScore': chaosScore,
    'disclaimer': disclaimer,
    'flagEmoji': flagEmoji,
    'analyzedAt': analyzedAt.toIso8601String(),
  };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    id: json['id'],
    name: json['name'],
    genderContext: GenderContext.values[json['genderContext']],
    intro: json['intro'],
    traits: List<String>.from(json['traits']),
    twist: json['twist'],
    ending: json['ending'],
    chaosLevel: ChaosLevel.values[json['chaosLevel']],
    chaosScore: json['chaosScore'],
    disclaimer: json['disclaimer'],
    flagEmoji: json['flagEmoji'],
    analyzedAt: DateTime.parse(json['analyzedAt']),
  );

  String toJsonString() => jsonEncode(toJson());
  factory AnalysisResult.fromJsonString(String s) =>
      AnalysisResult.fromJson(jsonDecode(s));
}
