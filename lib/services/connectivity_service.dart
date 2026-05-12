import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// The possible connectivity states of the app.
enum ConnectivityStatus {
  /// No network interface at all (airplane mode / no SIM / no WiFi)
  noNetwork,

  /// Connected to a network but no real internet traffic can flow
  /// (e.g. connected to a WiFi router that has no WAN link, or mobile
  ///  with exhausted data plan)
  noInternet,

  /// Internet is reachable but ad-serving domains are blocked
  /// (DNS-based or hosts-file ad-blocker detected)
  adsBlocked,

  /// Everything is fine – show the normal app
  connected,
}

/// Singleton service that continuously watches network + ad-server
/// reachability and exposes a [statusStream] for the overlay widget.
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();
  ConnectivityService._();

  // ─── Public state ───────────────────────────────────────────────────────────
  ConnectivityStatus _current = ConnectivityStatus.connected;
  ConnectivityStatus get current => _current;

  final _controller =
      StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  // ─── Internal ────────────────────────────────────────────────────────────────
  StreamSubscription? _connectivitySub;
  Timer? _pollTimer;

  /// Call once from [main] after [WidgetsFlutterBinding.ensureInitialized].
  Future<void> initialize() async {
    // Immediately perform first check so the overlay shows before the
    // first frame if needed.
    await _performCheck();

    // React immediately to platform connectivity changes.
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((_) => _performCheck());

    // Also poll every 12 s so we catch "data plan exhausted" situations
    // that don't trigger a connectivity-change event.
    _pollTimer =
        Timer.periodic(const Duration(seconds: 12), (_) => _performCheck());
  }

  Future<void> retry() => _performCheck();

  void dispose() {
    _connectivitySub?.cancel();
    _pollTimer?.cancel();
    _controller.close();
  }

  // ─── Check pipeline ──────────────────────────────────────────────────────────
  Future<void> _performCheck() async {
    final status = await _resolveStatus();
    if (status != _current) {
      _current = status;
      _controller.add(status);
    }
  }

  Future<ConnectivityStatus> _resolveStatus() async {
    // 1️⃣  Is any non-"none" interface available?
    final results = await Connectivity().checkConnectivity();
    final hasInterface =
        results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) return ConnectivityStatus.noNetwork;

    // 2️⃣  Can we reach a neutral, highly-available host?
    if (!await _canReach('google.com')) return ConnectivityStatus.noInternet;

    // 3️⃣  Can we reach Google's ad-serving infrastructure?
    //     Ad-blockers (DNS or hosts-based) block these domains.
    if (!await _canReach('googleads.g.doubleclick.net')) {
      return ConnectivityStatus.adsBlocked;
    }

    return ConnectivityStatus.connected;
  }

  /// DNS lookup with a 5 s timeout – fast and doesn't open a socket.
  Future<bool> _canReach(String host) async {
    try {
      final result =
          await InternetAddress.lookup(host).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
