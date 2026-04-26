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

  // ===== SHARE AS IMAGE =====
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
    } catch (e) {
      // Fallback to text share
      await shareResultAsText(result);
    }
  }

  Future<void> _shareImage(Uint8List imageBytes, AnalysisResult result) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/redflag_${result.name}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: _buildShareText(result),
      subject: '🚩 ${result.name} RedFlag Report',
    );
  }

  // ===== SHARE AS TEXT =====
  Future<void> shareResultAsText(AnalysisResult result) async {
    final text = _buildShareText(result);
    await Share.share(text, subject: '🚩 ${result.name} RedFlag Report');
  }

  String _buildShareText(AnalysisResult result) {
    final traits = result.traits.take(3).map((t) => '• $t').join('\n');
    return '''
🚩 RedFlag Names Report 🚩

${result.intro}

$traits

${result.twist}

${result.chaosLevelText} — ${result.chaosDescription}

📲 Download RedFlag Names — Analyze your person!
#RedFlagNames #RelationshipFlags #Funny
''';
  }

  // ===== DEEP LINKS (platform-specific) =====
  Future<void> shareToWhatsApp(AnalysisResult result) async {
    await Share.share(
      _buildShareText(result),
      subject: '🚩 ${result.name} Analysis',
    );
  }

  Future<void> copyToClipboard(BuildContext context, AnalysisResult result) async {
    // Uses Share.share fallback
    await Share.share(_buildShareText(result));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied! Share it anywhere 🚩'),
        backgroundColor: const Color(0xFFFF3B5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
