import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// All possible app-level connectivity states.
enum ConnectivityStatus {
  /// No network interface active (airplane mode, no SIM, no WiFi).
  noNetwork,

  /// Network interface present but no real internet traffic possible
  /// (router has no WAN, exhausted mobile data plan, captive portal, etc.)
  noInternet,

  /// Internet reachable but Google Ad infrastructure is blocked.
  /// Detected via DNS resolution + TCP handshake on two separate ad domains.
  /// Triggered by DNS-based blockers, VPN/proxy blockers, and hosts-file blockers.
  adsBlocked,

  /// Everything is healthy — show the normal app.
  connected,
}

/// Singleton that monitors network health and emits [ConnectivityStatus]
/// changes. Injected into [AppOverlayWrapper] via [statusStream].
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();
  ConnectivityService._();

  // ─── Public API ──────────────────────────────────────────────────────────────
  ConnectivityStatus _current = ConnectivityStatus.connected;
  ConnectivityStatus get current => _current;

  final _controller = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  // ─── Private ─────────────────────────────────────────────────────────────────
  StreamSubscription? _platformSub;
  Timer? _pollTimer;

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  Future<void> initialize() async {
    await _performCheck();
    _platformSub =
        Connectivity().onConnectivityChanged.listen((_) => _performCheck());
    _pollTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _performCheck());
  }

  /// Force an immediate re-check — called by overlay retry buttons.
  Future<void> retry() => _performCheck();

  void dispose() {
    _platformSub?.cancel();
    _pollTimer?.cancel();
    _controller.close();
  }

  // ─── Check pipeline ──────────────────────────────────────────────────────────

  Future<void> _performCheck() async {
    final next = await _resolveStatus();
    if (next != _current) {
      _current = next;
      _controller.add(next);
    }
  }

  Future<ConnectivityStatus> _resolveStatus() async {
    // 1: Does the OS report any active network interface?
    final results = await Connectivity().checkConnectivity();
    if (!results.any((r) => r != ConnectivityResult.none)) {
      return ConnectivityStatus.noNetwork;
    }

    // 2: Is real internet reachable? (neutral, ultra-reliable host)
    if (!await _canReachViaDns('google.com')) {
      return ConnectivityStatus.noInternet;
    }

    // 3: Are Google's ad-serving domains reachable?
    //    Require BOTH domains to fail before flagging — prevents false positives.
    if (await _isAdInfraBlocked()) {
      return ConnectivityStatus.adsBlocked;
    }

    return ConnectivityStatus.connected;
  }

  // ─── Internet check ───────────────────────────────────────────────────────────

  Future<bool> _canReachViaDns(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 6));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─── Ad-block detection ───────────────────────────────────────────────────────

  Future<bool> _isAdInfraBlocked() async {
    final results = await Future.wait([
      _adDomainReachable('googleads.g.doubleclick.net'),
      _adDomainReachable('pagead2.googlesyndication.com'),
    ]);
    return !results[0] && !results[1];
  }

  /// Three-tier reachability check for a single ad domain:
  ///
  ///  Tier 1 – DNS lookup:
  ///    Catches DNS-based blockers (NextDNS, Pi-hole, AdGuard DNS,
  ///    1.1.1.1 for Families, custom resolver blocklists).
  ///
  ///  Tier 2 – Loopback / unroutable IP check:
  ///    Catches hosts-file blockers that redirect ad domains to
  ///    127.0.0.1, 0.0.0.0, or ::1.
  ///
  ///  Tier 3 – TCP handshake on port 443:
  ///    Catches VPN-based blockers (Blokada, AdGuard for Android/iOS,
  ///    Private DNS + blocklists) that allow DNS resolution but silently
  ///    drop the TCP connection before any data is sent.
  Future<bool> _adDomainReachable(String host) async {
    // Tier 1: DNS
    List<InternetAddress> addresses;
    try {
      addresses = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      return false;
    }
    if (addresses.isEmpty) return false;

    // Tier 2: Loopback / unroutable IP
    final ip = addresses.first.address;
    const loopback = {'127.0.0.1', '0.0.0.0', '::1'};
    if (loopback.contains(ip)) return false;

    // Tier 3: TCP connect
    try {
      final socket = await Socket.connect(
        host,
        443,
        timeout: const Duration(seconds: 6),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
