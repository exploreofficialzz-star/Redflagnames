import 'dart:async';
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import 'no_internet_overlay.dart';
import 'ads_blocked_overlay.dart';

/// Wraps the entire widget tree and renders full-screen overlays on top of
/// any screen whenever connectivity issues are detected.
///
/// Usage — place in [MaterialApp.builder]:
/// ```dart
/// builder: (context, child) => AppOverlayWrapper(child: child!),
/// ```
class AppOverlayWrapper extends StatefulWidget {
  final Widget child;

  const AppOverlayWrapper({super.key, required this.child});

  @override
  State<AppOverlayWrapper> createState() => _AppOverlayWrapperState();
}

class _AppOverlayWrapperState extends State<AppOverlayWrapper>
    with WidgetsBindingObserver {
  ConnectivityStatus _status = ConnectivityStatus.connected;
  StreamSubscription<ConnectivityStatus>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Pick up the initial status immediately (service already ran first check)
    _status = ConnectivityService.instance.current;

    // Listen for future changes
    _sub = ConnectivityService.instance.statusStream.listen((s) {
      if (mounted && s != _status) setState(() => _status = s);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check immediately when the user brings the app to the foreground
    // (e.g. they went to disable an ad-blocker and came back).
    if (state == AppLifecycleState.resumed) {
      ConnectivityService.instance.retry();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _retry() => ConnectivityService.instance.retry();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Normal app tree ───────────────────────────────────────────────
        widget.child,

        // ── Overlays ─────────────────────────────────────────────────────
        // AnimatedSwitcher gives a smooth fade when status changes.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildOverlay(),
        ),
      ],
    );
  }

  /// Returns the appropriate full-screen overlay or an empty box.
  Widget _buildOverlay() {
    switch (_status) {
      case ConnectivityStatus.noNetwork:
      case ConnectivityStatus.noInternet:
        return NoInternetOverlay(
          key: ValueKey(_status),
          status: _status,
          onRetry: _retry,
        );

      case ConnectivityStatus.adsBlocked:
        return AdsBlockedOverlay(
          key: const ValueKey('ads_blocked'),
          onRetry: _retry,
        );

      case ConnectivityStatus.connected:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }
}
