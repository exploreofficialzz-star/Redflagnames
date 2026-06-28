import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/paystack_service.dart';

/// Full-screen WebView that hosts Paystack's inline JS payment popup.
/// Returns `true` to the caller on successful payment, `false` on cancel.
class PaystackWebScreen extends StatefulWidget {
  final String userEmail;

  const PaystackWebScreen({super.key, required this.userEmail});

  @override
  State<PaystackWebScreen> createState() => _PaystackWebScreenState();
}

class _PaystackWebScreenState extends State<PaystackWebScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final ref = 'RFN_${const Uuid().v4().replaceAll('-', '').substring(0, 16)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D0D1A))
      ..addJavaScriptChannel(
        'FlutterPaystack',
        onMessageReceived: _onJsMessage,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadHtmlString(
        PaystackService.buildCheckoutHtml(
          email: widget.userEmail,
          reference: ref,
        ),
      );
  }

  /// Handles messages posted from Paystack JS callback.
  void _onJsMessage(JavaScriptMessage message) async {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';

      switch (status) {
        case 'success':
          await PaystackService.instance.grant();
          if (mounted) Navigator.pop(context, true);
          break;
        case 'cancelled':
          if (mounted) Navigator.pop(context, false);
          break;
        case 'error':
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '❌ ${data['message'] ?? 'Payment error. Please try again.'}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: const Color(0xFFFF3B5C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
            Navigator.pop(context, false);
          }
          break;
      }
    } catch (_) {
      if (mounted) Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          '🔒 Secure Payment',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading secure payment...',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
