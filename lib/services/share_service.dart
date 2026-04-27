import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/analysis_result.dart';

class ShareService {
  static final ShareService instance = ShareService._();
  ShareService._();

  final ScreenshotController screenshotController = ScreenshotController();

  // ─────────────────────────────────────────────
  // Share as image (screenshot)
  // ─────────────────────────────────────────────
  Future<void> shareResultAsImage(
    BuildContext context,
    AnalysisResult result,
    Widget resultWidget,
  ) async {
    try {
      final image = await screenshotController.captureFromWidget(
        resultWidget,
        context: context,
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );
      await _shareImage(image, result);
    } catch (_) {
      // Fallback to text
      await shareResultAsText(result);
    }
  }

  Future<void> _shareImage(
      Uint8List imageBytes, AnalysisResult result) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/redflag_${result.name.toLowerCase()}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: _buildViralText(result),
      subject: '🚩 ${result.name} RedFlag Report',
    );
  }

  // ─────────────────────────────────────────────
  // Share as text
  // ─────────────────────────────────────────────
  Future<void> shareResultAsText(AnalysisResult result) async {
    await Share.share(
      _buildViralText(result),
      subject: '🚩 ${result.name} RedFlag Report',
    );
  }

  // ─────────────────────────────────────────────
  // WhatsApp specific
  // ─────────────────────────────────────────────
  Future<void> shareToWhatsApp(AnalysisResult result) async {
    await Share.share(
      _buildWhatsAppText(result),
      subject: '🚩 ${result.name} RedFlag Names',
    );
  }

  // ─────────────────────────────────────────────
  // Copy to clipboard
  // ─────────────────────────────────────────────
  Future<void> copyToClipboard(
      BuildContext context, AnalysisResult result) async {
    await Share.share(_buildViralText(result));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied! Paste it anywhere 🚩'),
          backgroundColor: const Color(0xFFFF3B5C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // VIRAL share text — engineered for engagement
  // ─────────────────────────────────────────────
  String _buildViralText(AnalysisResult result) {
    final traits = result.traits.take(3).map((t) => '• $t').join('\n');
    final contextLabel = _contextLabel(result.genderContext);

    return '''
🚩 RedFlag Names Report 🚩

${result.intro}

$contextLabel Analysis for: *${result.name}*

$traits

${result.twist}

${result.chaosLevelText} — Chaos Score: ${result.chaosScore}%
${result.chaosDescription}

${result.disclaimer}

━━━━━━━━━━━━━━━━━━━━━
😂 Test YOUR person's name!
📲 Download *RedFlag Names* — the app that exposes everyone 👀
🔗 Search "RedFlag Names" on Play Store / App Store

Made by chAs Tech Group ❤️
#RedFlagNames #RelationshipCheck #RedFlag
''';
  }

  String _buildWhatsAppText(AnalysisResult result) {
    final traits = result.traits.take(3).map((t) => '🔸 $t').join('\n');

    return '''
😂😂 *RedFlag Names* just exposed *${result.name}*!

${result.intro}

$traits

*${result.chaosLevelText}* — ${result.chaosScore}% chaos 🌡️

${result.twist}

Test your person 👇
📲 Download *RedFlag Names* on Play Store / App Store!

_by chAs Tech Group_ 🚩
''';
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
