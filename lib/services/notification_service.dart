import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _random = Random();

  static const List<String> _messages = [
    "🚩 You've been thinking about that name again, haven't you?",
    "😂 Come analyze your ex's name. We dare you.",
    "💀 New names, new chaos. Come see!",
    "🔍 Your crush's name won't analyze itself...",
    "👀 Someone you know needs to be investigated. Just saying.",
    "😅 Your daily dose of relationship reality check is here!",
    "🚨 ALERT: Unanalyzed names detected in your life!",
    "💅 Ready to expose your situationship? Let's go.",
    "🤣 The results for today are... spicy. Come check.",
    "🏃 Are you running from the results? Come back!",
  ];

  Future<void> initialize() async {
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
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );
    await _requestPermissions();
    await _scheduleEngagement();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'redflag_main',
    'RedFlag Names',
    channelDescription: 'Funny relationship name notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    sound: null, // Uses device DEFAULT sound
    enableLights: true,
    color: Color(0xFFFF3B5C),
    ledColor: Color(0xFFFF3B5C),
    ledOnMs: 1000,
    ledOffMs: 500,
    icon: '@mipmap/ic_launcher',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  static const DarwinNotificationDetails _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: null, // Uses default iOS sound
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  Future<void> showResultNotification(String name, String chaosLevel) async {
    await _plugin.show(
      DateTime.now().millisecond,
      '🚩 $name Analysis Complete!',
      'Risk: $chaosLevel — Tap to see the full report!',
      _details,
    );
  }

  Future<void> _scheduleEngagement() async {
    await _plugin.cancelAll();
    await _showEngagement(1, '☀️ Morning RedFlag Check', 10, 0);
    await _showEngagement(2, '😂 Afternoon Chaos Report', 14, 30);
    await _showEngagement(3, '🚩 Evening Name Analysis', 20, 0);
  }

  Future<void> _showEngagement(int id, String title, int h, int m) async {
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
  }

  void _onTap(NotificationResponse response) {}
}
