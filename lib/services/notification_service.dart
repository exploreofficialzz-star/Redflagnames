import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _random = Random();
  bool _initialized = false;

  static const List<String> _messages = [
    "🚩 You've been thinking about that name again, haven't you?",
    "😂 Come analyze your ex's name. We dare you.",
    "💀 New names, new chaos. Come see!",
    "🔍 Your crush's name won't analyze itself...",
    "👀 Someone you know needs to be investigated. Just saying.",
    "😅 Your daily dose of relationship reality check is here!",
    "🚨 ALERT: Unanalyzed names detected in your life!",
    "💅 Ready to expose your situationship? Let's go.",
    "🤣 Today's results are... spicy. Come check.",
    "🏃 Are you running from the results? Come back!",
  ];

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(settings,
          onDidReceiveNotificationResponse: _onTap);
      await _requestPermissions();
      _initialized = true;
      // Schedule in background — don't block init
      _scheduleEngagement().catchError((_) {});
    } catch (_) {
      _initialized = true; // mark done even on error
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'redflag_main',
    'RedFlag Names',
    channelDescription: 'Funny relationship name notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    sound: null, // device default sound
    enableLights: true,
    color: Color(0xFFFF3B5C),
    ledColor: Color(0xFFFF3B5C),
    ledOnMs: 1000,
    ledOffMs: 500,
    icon: '@mipmap/ic_launcher',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: null, // device default sound
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  /// Called after each analysis — wrapped so it NEVER throws to caller
  Future<void> showResultNotification(
      String name, String chaosLevel) async {
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        '🚩 $name Analysis Complete!',
        'Risk: $chaosLevel — Tap to see the full report!',
        _details,
      );
    } catch (_) {}
  }

  Future<void> _scheduleEngagement() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}

    await _showEngagement(1, '☀️ Morning RedFlag Check', 10, 0);
    await _showEngagement(2, '😂 Afternoon Chaos Report', 14, 30);
    await _showEngagement(3, '🚩 Evening Name Analysis', 20, 0);
  }

  Future<void> _showEngagement(
      int id, String title, int hour, int minute) async {
    try {
      final body = _messages[_random.nextInt(_messages.length)];
      final androidDetails = AndroidNotificationDetails(
        'redflag_daily_$id',
        'Daily Reminders',
        channelDescription: 'Daily fun notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        sound: null,
        icon: '@mipmap/ic_launcher',
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: _iosDetails,
      );
      await _plugin.show(id, title, body, details);
    } catch (_) {}
  }

  void _onTap(NotificationResponse response) {}
}
